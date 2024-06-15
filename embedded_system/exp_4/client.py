import subprocess
import csv
import multiprocessing
import time
import shlex
import os
import logging
import datetime
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
import subprocess

def handshake_earlydata_sessout(ke_alg):
    command = 'sudo ip netns exec client_namespace ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl s_client -connect 192.168.1.1:4433 -psk 123456  -quiet -sess_out session.txt > /dev/null 2>&1'
    return command

def handshake_earlydata_sessin(ke_alg):
    command = 'sudo ip netns exec client_namespace ../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl s_client -connect 192.168.1.1:4433 -psk 123456  -quiet -sess_in session.txt -early_data earlydatafile.log'
    return command

def run_client( ke_alg, count):
    first_lines = []
    for _ in range(count):
        process_out = subprocess.Popen(handshake_earlydata_sessout(ke_alg), shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        process_out.wait()
        time.sleep(0.1)
        process_in = subprocess.Popen(handshake_earlydata_sessin(ke_alg), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, _ = process_in.communicate()
        lines = output.decode('utf-8').splitlines()
        first_lines.append(lines[0])
        process_in.stdout.close()  
    return first_lines

def run_subprocess(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Command execution failed with return code %d: %s", e.returncode, e.stderr)
        raise

def netem_set(ns, dev,latency,loss):
    if loss == 0:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'rate', '1000mbit']
    else:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'loss','{0}%'.format(loss),'rate', '1000mbit']
    run_subprocess(command)
  
Ke_alg = ['prime256v1','secp384r1','secp521r1','kyber512','sntrup761','kyber768','kyber1024','p256_kyber512','p256_sntrup761','p384_kyber768','p521_kyber1024']
Lossrate = [0,3,5]
Latency = ['7.75ms','14.75ms','33.75ms']
count = 500
for i in range(0,3):
    latency_time = Latency[i]
    loss_rate =  Lossrate[i]
    current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    folder_path = os.path.join("data", str(loss_rate))
    os.makedirs(folder_path, exist_ok=True)
    netem_set('client_namespace', 'client_veth', latency=latency_time,loss=loss_rate)
    netem_set('server_namespace', 'server_veth', latency=latency_time,loss=loss_rate)   
    for ke_alg in Ke_alg:
        file_name = os.path.join(folder_path, '{}_earlydata_client.csv'.format(ke_alg))
        with open(file_name, 'w') as out:
            csv_out = csv.writer(out)
            with open('earlydatafile.log','w') as file:
                file.write("data"+"\n")
                algo = "{}".format(ke_alg)
                file.write(algo+"\n")
                file.write(str(loss_rate)+"\n")
                file.write("This is early data.")
            handshake_times = [ke_alg]
            handshake_time = run_client(ke_alg, count)
            handshake_times.extend(handshake_time)
            csv_out.writerow(handshake_times)

