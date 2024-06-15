import subprocess

def run_commands():
    commands = [
        'sudo ip netns exec server_namespace ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl s_server -nocert -psk 123456 -tls1_3'
    ]
    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")

if __name__ == "__main__":
    run_commands()
