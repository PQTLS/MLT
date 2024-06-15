import subprocess

def run_commands(signature=''):
    commands = [
        f'../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl req -x509 -new -newkey {signature} -keyout rootCA.key -out rootCA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl.cnf',
        f'../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl req -new -newkey {signature} -keyout server.key -out server.csr -nodes -subj "/CN=oqstest server" -config ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl.cnf',
        f'../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl x509 -req -in server.csr -out server.crt -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -days 365',
        'sudo ip netns exec server_namespace ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl s_server -cert server.crt -key server.key -tls1_3'

    ]
    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")

if __name__ == "__main__":
    signature = "rsa:3072"  # Replace with the desired signature algorithm in README.md
    run_commands(signature)
