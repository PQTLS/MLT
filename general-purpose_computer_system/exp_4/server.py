import subprocess
command = "sudo ip netns exec server_namespace ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl s_server -nocert -psk 123456 -early_data"
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

with open('s_server_output.csv', 'w') as output_file:
    early_data_started = False 
    for line in iter(process.stdout.readline, b''):
        line_str = line.decode(errors='ignore').strip()
        if early_data_started:
            if line_str == "End of early data":
                early_data_started = False
            else:
                output_file.write(line_str + '\n')
        elif line_str.startswith("Early data received:"):
            early_data_started = True


