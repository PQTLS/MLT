/*
 * Copyright 1995-2021 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the OpenSSL license (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <openssl/opensslconf.h>

#ifndef OPENSSL_NO_SOCK

#include "apps.h"
#include "progs.h"
#include <openssl/x509.h>
#include <openssl/ssl.h>
#include <openssl/pem.h>
#include "s_apps.h"
#include <openssl/err.h>
#include <internal/sockets.h>
#include<time.h>
#if !defined(OPENSSL_SYS_MSDOS)
# include OPENSSL_UNISTD 
#endif
#define NS_IN_MS 1000000.0
#define MS_IN_S 1000
#define SSL_CONNECT_NAME        "192.168.1.1:4433"
//#define SSL_CONNECT_NAME        "localhost:4433"
#define BUFSIZZ 1024*8
static char *sess_out = NULL;
static SSL *doConnection(SSL_CTX *ctx,const char* host);

static SSL_SESSION *psksess = NULL;
    /* Default PSK identity and key */
static char *psk_identity = "Client_identity";
//add begin
static int c_debug = 0;
static BIO *bio_c_out = NULL;
char *p;

static unsigned int psk_client_cb(SSL *ssl, const char *hint, char *identity,
                                  unsigned int max_identity_len,
                                  unsigned char *psk,
                                  unsigned int max_psk_len)
{
    int ret;
    long key_len;
    unsigned char *key;

    if (c_debug)
        BIO_printf(bio_c_out, "psk_client_cb\n");
    if (!hint) {
        /* no ServerKeyExchange message */
        if (c_debug)
            BIO_printf(bio_c_out,
                       "NULL received PSK identity hint, continuing anyway\n");
    } else if (c_debug) {
        BIO_printf(bio_c_out, "Received PSK identity hint '%s'\n", hint);
    }

    /*
     * lookup PSK identity and PSK key based on the given identity hint here
     */
    ret = BIO_snprintf(identity, max_identity_len, "%s", psk_identity);
    if (ret < 0 || (unsigned int)ret > max_identity_len)
        goto out_err;
    if (c_debug)
        BIO_printf(bio_c_out, "created identity '%s' len=%d\n", identity,
                   ret);

    /* convert the PSK key to binary */
    key = OPENSSL_hexstr2buf(psk_key, &key_len);
    if (key == NULL) {
        BIO_printf(bio_err, "Could not convert PSK key '%s' to buffer\n",
                   psk_key);
        return 0;
    }
    if (max_psk_len > INT_MAX || key_len > (long)max_psk_len) {
        BIO_printf(bio_err,
                   "psk buffer of callback is too small (%d) for key (%ld)\n",
                   max_psk_len, key_len);
        OPENSSL_free(key);
        return 0;
    }

    memcpy(psk, key, key_len);
    OPENSSL_free(key);

    if (c_debug)
        BIO_printf(bio_c_out, "created PSK len=%ld\n", key_len); 

    return key_len;
 out_err:
    if (c_debug)
        BIO_printf(bio_err, "Error in PSK client callback\n");
    return 0;
}



static int psk_use_session_cb(SSL *s, const EVP_MD *md,
                              const unsigned char **id, size_t *idlen,
                              SSL_SESSION **sess)
{
    SSL_SESSION *usesess = NULL;
    const SSL_CIPHER *cipher = NULL;

    if (psksess != NULL) {
        SSL_SESSION_up_ref(psksess);
        usesess = psksess;
    } else {
        long key_len;
        unsigned char *key = OPENSSL_hexstr2buf(psk_key, &key_len);

        if (key == NULL) {
            BIO_printf(bio_err, "Could not convert PSK key '%s' to buffer\n",
                       psk_key);
            return 0;
        }

        /* We default to SHA-256 */
        cipher = SSL_CIPHER_find(s, tls13_aes128gcmsha256_id);
        if (cipher == NULL) {
            BIO_printf(bio_err, "Error finding suitable ciphersuite\n");
            OPENSSL_free(key);
            return 0;
        }

        usesess = SSL_SESSION_new();
        if (usesess == NULL
                || !SSL_SESSION_set1_master_key(usesess, key, key_len)
                || !SSL_SESSION_set_cipher(usesess, cipher)
                || !SSL_SESSION_set_protocol_version(usesess, TLS1_3_VERSION)) {
            OPENSSL_free(key);
            goto err;
        }
        OPENSSL_free(key);
    }

    cipher = SSL_SESSION_get0_cipher(usesess);
    if (cipher == NULL)
        goto err;

    if (md != NULL && SSL_CIPHER_get_handshake_digest(cipher) != md) {
        /* PSK not usable, ignore it */
        *id = NULL;
        *idlen = 0;
        *sess = NULL;
        SSL_SESSION_free(usesess);
    } else {
        *sess = usesess;
        *id = (unsigned char *)psk_identity;
        *idlen = strlen(psk_identity);
    }

    return 1;

 err:
    SSL_SESSION_free(usesess);
    return 0;
}

/*
 * Define a HTTP get command globally.
 * Also define the size of the command, this is two bytes less than
 * the size of the string because the %s is replaced by the URL.
 */
static const char fmt_http_get_cmd[] = "GET %s HTTP/1.0\r\n\r\n";
static const size_t fmt_http_get_cmd_size = sizeof(fmt_http_get_cmd) - 2;

typedef enum OPTION_choice {
    OPT_ERR = -1, OPT_EOF = 0, OPT_HELP,
    OPT_CONNECT, OPT_CIPHER, OPT_CIPHERSUITES, OPT_CERT, OPT_NAMEOPT, OPT_KEY,
    OPT_CAPATH, OPT_CAFILE, OPT_NOCAPATH, OPT_NOCAFILE, OPT_NEW, OPT_REUSE,
    OPT_BUGS, OPT_VERIFY, OPT_SSL3, OPT_CURVES,
    OPT_WWW,     
    //add begin
    OPT_PSK_IDENTITY, OPT_PSK, OPT_PSK_SESS,OPT_IP
} OPTION_CHOICE;

const OPTIONS s_time_options[] = {
    {"help", OPT_HELP, '-', "Display this summary"},
    {"connect", OPT_CONNECT, 's',
     "Where to connect as post:port (default is " SSL_CONNECT_NAME ")"},
    {"cipher", OPT_CIPHER, 's', "TLSv1.2 and below cipher list to be used"},
    {"ciphersuites", OPT_CIPHERSUITES, 's',
     "Specify TLSv1.3 ciphersuites to be used"},
    {"cert", OPT_CERT, '<', "Cert file to use, PEM format assumed"},
    {"nameopt", OPT_NAMEOPT, 's', "Various certificate name options"},
    {"key", OPT_KEY, '<', "File with key, PEM; default is -cert file"},
    {"CApath", OPT_CAPATH, '/', "PEM format directory of CA's"},
    {"cafile", OPT_CAFILE, '<', "PEM format file of CA's"},
    {"CAfile", OPT_CAFILE, '<', "PEM format file of CA's"},
    {"no-CAfile", OPT_NOCAFILE, '-',
     "Do not load the default certificates file"},
    {"no-CApath", OPT_NOCAPATH, '-',
     "Do not load certificates from the default certificates directory"},
    {"new", OPT_NEW, '-', "Just time new connections"},
    {"reuse", OPT_REUSE, '-', "Just time connection reuse"},
    {"bugs", OPT_BUGS, '-', "Turn on SSL bug compatibility"},
    {"verify", OPT_VERIFY, 'p',
     "Turn on peer certificate verification, set depth"},
    {"www", OPT_WWW, 's', "Fetch specified page from the site"},
#ifndef OPENSSL_NO_SSL3
    {"ssl3", OPT_SSL3, '-', "Just use SSLv3"},
#endif
    {"curves", OPT_CURVES, 's', "Curves to be announced by client"},
    //add begin
    {"psk_identity", OPT_PSK_IDENTITY, 's', "PSK identity"},
    {"psk", OPT_PSK, 's', "PSK in hex (without 0x)"},
    {"psk_session", OPT_PSK_SESS, '<', "File to read PSK SSL session from"},
    {"ip", OPT_IP, 's', "ip address"},
    {NULL}
};


static int new_session_cb(SSL *s, SSL_SESSION *sess)
{

    if (sess_out != NULL) {
        BIO *stmp = BIO_new_file(sess_out, "w");

        if (stmp == NULL) {
            BIO_printf(bio_err, "Error writing session file %s\n", sess_out);
        } else {
            PEM_write_bio_SSL_SESSION(stmp, sess);
            BIO_free(stmp);
        }
    }

   
     /* Session data gets dumped on connection for TLSv1.2 and below, and on
     * arrival of the NewSessionTicket for TLSv1.3.
     */
    if (SSL_version(s) == TLS1_3_VERSION) {
        BIO_printf(bio_c_out,
                   "---\nPost-Handshake New Session Ticket arrived:\n");
        SSL_SESSION_print(bio_c_out, sess);
        BIO_printf(bio_c_out, "---\n");
    }

  
     /* We always return a "fail" response so that the session gets freed again
     * because we haven't used the reference.
     */
    return 0;
}

int s_time_main(int argc, char **argv)
{
    char buf[1024 * 8];
    SSL *scon = NULL;
    SSL_CTX *ctx = NULL;
    const SSL_METHOD *meth = NULL;
    char *CApath = NULL, *CAfile = NULL, *cipher = NULL;
    char *www_path = NULL;
    char *certfile = NULL, *keyfile = NULL, *prog;
    char *host = SSL_CONNECT_NAME;
    char *curves = NULL;
    double totalTime = 0.0;
    int noCApath = 0, noCAfile = 0;
    int  nConn = 0, perform = 3, ret = 1, i, st_bugs = 0;
    long bytes_read = 0, finishtime = 0;
    OPTION_CHOICE o;
    int max_version = 0, ver, buf_len;
    size_t buf_size;
    //add begin
    char *psksessf = NULL;
    
    const char *early_data_file = NULL;
    SSL *con = NULL;
    char *cbuf = NULL;
    char *sess_in = NULL, *crl_file = NULL, *p;
    int s = -1;
    BIO *sbio;
    char *port = OPENSSL_strdup(PORT);
    char *bindhost = NULL, *bindport = NULL;
    int socket_family = AF_UNSPEC, socket_type = SOCK_STREAM, protocol = 0;
    char *ip;
    ip = malloc(strlen("192.168.1.1:4433") + 1);  // Allocate memory for the IP address
    strcpy(ip, "192.168.1.1:4433");
    //ip = malloc(strlen("localhost:4433") + 1);  // Allocate memory for the IP address
    //strcpy(ip, "localhost:4433");
    cbuf = app_malloc(BUFSIZZ, "cbuf");
    meth = TLS_client_method();
    prog = opt_init(argc, argv, s_time_options);
    while ((o = opt_next()) != OPT_EOF) {
        switch (o) {
        case OPT_EOF:
        case OPT_ERR:
 opthelp:
            BIO_printf(bio_err, "%s: Use -help for summary.\n", prog);
            goto end;
        case OPT_HELP:
            opt_help(s_time_options);
            ret = 0;
            goto end;
        case OPT_CONNECT:
            host = opt_arg();
            break;
        case OPT_REUSE:
            perform = 2;
            break;
        case OPT_NEW:
            perform = 1;
            break;
        case OPT_VERIFY:
            if (!opt_int(opt_arg(), &verify_args.depth))
                goto opthelp;
            BIO_printf(bio_err, "%s: verify depth is %d\n",
                       prog, verify_args.depth);
            break;
        case OPT_CERT:
            certfile = opt_arg();
            break;
        case OPT_NAMEOPT:
            if (!set_nameopt(opt_arg()))
                goto end;
            break;
        case OPT_KEY:
            keyfile = opt_arg();
            break;
        case OPT_CAPATH:
            CApath = opt_arg();
            break;
        case OPT_CAFILE:
            CAfile = opt_arg();
            break;
        case OPT_NOCAPATH:
            noCApath = 1;
            break;
        case OPT_NOCAFILE:
            noCAfile = 1;
            break;
        case OPT_CIPHER:
            cipher = opt_arg();
            break;
        case OPT_BUGS:
            st_bugs = 1;
            break;
        case OPT_WWW:
            www_path = opt_arg();
            buf_size = strlen(www_path) + fmt_http_get_cmd_size;
            if (buf_size > sizeof(buf)) {
                BIO_printf(bio_err, "%s: -www option is too long\n", prog);
                goto end;
            }
            break;
        case OPT_SSL3:
            max_version = SSL3_VERSION;
            break;
        case OPT_CURVES:
            curves = opt_arg();
            break;
        case OPT_PSK_IDENTITY:
            psk_identity = opt_arg();
            break;
        case OPT_PSK:
            for (p = psk_key = opt_arg(); *p; p++) {
                if (isxdigit(_UC(*p)))
                    continue;
                BIO_printf(bio_err, "Not a hex number '%s'\n", psk_key);
                goto end;
            }
            break;
        case OPT_PSK_SESS:
            psksessf = opt_arg();
            break;
        case OPT_IP:
            strcpy(ip, opt_arg());
        
    }
    }
    argc = opt_num_rest();
    if (argc != 0)
        goto opthelp;

    if (cipher == NULL)
        cipher = getenv("SSL_CIPHER");

    if ((ctx = SSL_CTX_new(meth)) == NULL)
        goto ossl_error;

    SSL_CTX_set_mode(ctx, SSL_MODE_AUTO_RETRY);
    SSL_CTX_set_quiet_shutdown(ctx, 1);
    if (SSL_CTX_set_max_proto_version(ctx, max_version) == 0)
        goto end;
    SSL_CTX_set_options(ctx, SSL_OP_NO_COMPRESSION);
    if (ret != 1)
    {
        goto ossl_error;
    }
    if (curves && !SSL_CTX_set1_curves_list(ctx, curves)) {
        ERR_print_errors(bio_err);
        goto end;
    }
    //add begin
    if (psk_key != NULL) {
        if (c_debug)
            BIO_printf(bio_c_out, "PSK key given, setting client callback\n");
        SSL_CTX_set_psk_client_callback(ctx, psk_client_cb);
    }
    BIO *stmp;
    if (psksessf != NULL) {
        stmp = BIO_new_file(psksessf, "r");
        if (stmp == NULL) {
            BIO_printf(bio_err, "Can't open PSK session file %s\n", psksessf);
            ERR_print_errors(bio_err);
            goto end;
        }
        psksess = PEM_read_bio_SSL_SESSION(stmp, NULL, 0, NULL);
        BIO_free(stmp);
        if (psksess == NULL) {
            BIO_printf(bio_err, "Can't read PSK session file %s\n", psksessf);
            ERR_print_errors(bio_err);
            goto end;
        }
    }
    if (psk_key != NULL || psksess != NULL)
        {
            SSL_CTX_set_psk_use_session_callback(ctx, psk_use_session_cb);
        }

    //SSL_CTX_set_session_cache_mode(ctx, SSL_SESS_CACHE_CLIENT
    //                                    | SSL_SESS_CACHE_NO_INTERNAL_STORE);
    SSL_CTX_sess_set_new_cb(ctx, new_session_cb);
    con = SSL_new(ctx);
    if (sess_in != NULL) {
        SSL_SESSION *sess;
        BIO *stmp = BIO_new_file(sess_in, "r");
        if (stmp == NULL) {
            BIO_printf(bio_err, "Can't open session file %s\n", sess_in);
            ERR_print_errors(bio_err);
            goto end;
        }

        sess = PEM_read_bio_SSL_SESSION(stmp, NULL, 0, NULL);
        BIO_free(stmp);
        if (sess == NULL) {
            BIO_printf(bio_err, "Can't open session file %s\n", sess_in);
            ERR_print_errors(bio_err);
            goto end;
        }

        if (!SSL_set_session(con, sess)) {
            BIO_printf(bio_err, "Can't set session\n");
            ERR_print_errors(bio_err);
            goto end;
        }
        SSL_SESSION_free(sess);
    }
    // SSL_CTX_set_ciphersuites(ctx, "TLS_AES_256_GCM_SHA384");
    SSL_CTX_set_ciphersuites(ctx, "TLS_AES_128_GCM_SHA256");
    size_t measurements_to_make = 1;
    //握手次数初始化为0
    size_t measurements = 0;
    //测量握手时间的 timespec 结构体
    struct timespec start, finish;
    double* handshake_times_ms = malloc(measurements_to_make * sizeof(*handshake_times_ms));
    while(measurements < measurements_to_make)
    {
        //记录握手开始和结束时间，调用 do_tls_handshake 函数执行 TLS 握手
        clock_gettime(CLOCK_MONOTONIC_RAW, &start);
        scon = doConnection(ctx,ip);
        clock_gettime(CLOCK_MONOTONIC_RAW, &finish);
        if (!scon)
        {
            //如果握手失败，进行重试。此注释提到在高丢包率下，connect() 系统调用有时会失败，而无法重试的错误由手动检查日志捕捉。
            /* Retry since at high packet loss rates,
             * the connect() syscall fails sometimes.
             * Non-retryable errors are caught by manual
             * inspection of logs, which has sufficed
             * for our purposes */
            continue;
        }
        //关闭 SSL 连接。
        SSL_set_shutdown(scon, SSL_SENT_SHUTDOWN | SSL_RECEIVED_SHUTDOWN);

        ret = BIO_closesocket(SSL_get_fd(scon));
        if(ret == -1)
        {
            goto ossl_error;
        }
        SSL_free(scon);
        //记录握手时间
        handshake_times_ms[measurements] = ((finish.tv_sec - start.tv_sec) * MS_IN_S) + ((finish.tv_nsec - start.tv_nsec) / NS_IN_MS);
        measurements++;
    }
    //打印握手时间数组的值。

    for(size_t i = 0; i < measurements - 1; i++)
    {
        printf("%f,", handshake_times_ms[i]);
    }
    printf("%f", handshake_times_ms[measurements - 1]);

    ret = 0;
    goto end;
//错误处理和清理
ossl_error:
    fprintf(stderr, "Unrecoverable OpenSSL error.\n");
    ERR_print_errors_fp(stderr);
end:
    SSL_SESSION_free(psksess);
    SSL_CTX_free(ctx);

    return ret;
}

/*-
 * doConnection - make a connection
 */
//const char* host = "192.168.1.1:4433";
static SSL *doConnection(SSL_CTX *ctx,const char* host)
{
    BIO *conn;
    SSL *serverCon;
    int i;
    if ((conn = BIO_new(BIO_s_connect())) == NULL)
        return NULL;

    BIO_set_conn_hostname(conn, host);
    BIO_set_conn_mode(conn, BIO_SOCK_NODELAY);
    //SSL_CTX_clear_options(ctx, SSL_OP_ENABLE_MIDDLEBOX_COMPAT); 
    //serverCon = SSL_new(ctx);
    serverCon = SSL_new(ctx);
    SSL_set_bio(serverCon, conn, conn);
    /* ok, lets connect */
    //SSL_connect有段错误
    i = SSL_connect(serverCon);
    if (i <= 0) {
        ERR_print_errors_fp(stderr); 
        SSL_free(serverCon);
        return NULL;
    }
    return serverCon;
}
#endif /* OPENSSL_NO_SOCK */
