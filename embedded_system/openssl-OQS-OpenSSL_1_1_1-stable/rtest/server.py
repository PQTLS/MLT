import subprocess

def run_commands(signature=''):
    commands = [
        f'../apps/openssl req -x509 -new -newkey {signature} -keyout rootCA.key -out rootCA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config ../apps/openssl.cnf',
        f'../apps/openssl req -new -newkey {signature} -keyout server.key -out server.csr -nodes -subj "/CN=oqstest server" -config ../apps/openssl.cnf',
        f'../apps/openssl x509 -req -in server.csr -out server.crt -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -days 365',
        'sudo ip netns exec server_namespace ../apps/openssl s_server -cert server.crt -key server.key -tls1_3'
        #'sudo ip netns exec server_namespace ../apps/openssl s_server -nocert -psk 123456 -tls1_3'
    ]
    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")

if __name__ == "__main__":

    #falcon512   dilithium2 dilithium3  dilithium5

    #p256_falcon512  p256_dilithium2 p384_dilithium3 p521_dilithium5

    #rsa:2048 rsa:3072 rsa:4096
    signature = "p521_dilithium5"  # 设置你想要的值
    run_commands(signature)
