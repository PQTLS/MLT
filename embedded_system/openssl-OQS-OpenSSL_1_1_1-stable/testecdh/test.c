#include <stdio.h>
#include <openssl/ec.h>
#include <openssl/evp.h>
#include <openssl/ecdh.h>
#include <openssl/rand.h>
#include <sys/time.h>
#include <openssl/err.h>

#define MAX_TIME_SECONDS 3

// Function to perform ECDH key exchange
void perform_ecdh_key_exchange(const EC_GROUP *group, EC_KEY **private_key, EC_POINT **public_key) {
    *private_key = EC_KEY_new_by_curve_name(NID_secp384r1);
    EC_KEY_generate_key(*private_key);

    *public_key = EC_POINT_new(group);
    EC_POINT_copy(*public_key, EC_KEY_get0_public_key(*private_key));
}

// Function to perform key encapsulation (ECDH encryption)
void perform_key_encapsulation(const EC_GROUP *group, const EC_KEY *private_key, const EC_POINT *peer_public_key,
                               unsigned char **symmetric_key, size_t *symmetric_key_len) {
    ECDH_compute_key(*symmetric_key, *symmetric_key_len, peer_public_key, private_key, NULL);
}

int main() {
    // Initialize OpenSSL
    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();

    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp384r1);
    EC_KEY *private_key_A, *private_key_B;
    EC_POINT *public_key_A, *public_key_B;

    // Allocate memory for symmetric key
    size_t symmetric_key_len = EC_GROUP_get_degree(group) / 8;
    unsigned char *symmetric_key = malloc(symmetric_key_len);

    // Timing variables
    struct timeval start, end;

    // Variables for counting iterations
    int key_gen_iterations = 0, encap_iterations = 0, decap_iterations = 0;

    // Test ECDH key generation
    gettimeofday(&start, NULL);
    while (1) {
        perform_ecdh_key_exchange(group, &private_key_A, &public_key_A);
        //EC_POINT_free(public_key_A);
        //EC_KEY_free(private_key_A);
        key_gen_iterations++;
        gettimeofday(&end, NULL);
        if ((end.tv_sec - start.tv_sec) >= MAX_TIME_SECONDS) {
            break;
        }
    }
    EC_POINT_free(public_key_A);
    EC_KEY_free(private_key_A);
    printf("ECDH Key Generation Iterations: %d\n", key_gen_iterations);
    printf("Average Keygen Time: %.2f microseconds\n",  1000000*MAX_TIME_SECONDS / (float)key_gen_iterations);

    // Test ECDH key encapsulation (encryption)
    gettimeofday(&start, NULL);
    perform_ecdh_key_exchange(group, &private_key_A, &public_key_A);
    perform_ecdh_key_exchange(group, &private_key_B, &public_key_B);
    while (1) {
        perform_key_encapsulation(group, private_key_A, public_key_B, &symmetric_key, &symmetric_key_len);
        encap_iterations++;
        gettimeofday(&end, NULL);
        if ((end.tv_sec - start.tv_sec) >= MAX_TIME_SECONDS) {
            break;
        }
    }
    EC_KEY_free(private_key_A);
    EC_KEY_free(private_key_B);
    EC_POINT_free(public_key_A);
    EC_POINT_free(public_key_B);
    printf("ECDH Key Exchange: %d\n", encap_iterations);
    printf("Average Key Exchange Time: %.2f microseconds\n", 1000000*MAX_TIME_SECONDS / (float)encap_iterations);
    // Clean up
    EC_GROUP_free(group);
    free(symmetric_key);

    // Clean up OpenSSL
    ERR_free_strings();
    EVP_cleanup();

    return 0;
}
