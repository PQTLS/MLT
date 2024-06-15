import subprocess
import csv
import multiprocessing
import time
import shlex
import os
import logging
import datetime
from multiprocessing import Pool

# 设置日志配置
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def handshake_earlydata_sessout(ke_alg):
    command = 'sudo ip netns exec client_namespace apps/openssl s_client -connect 192.168.1.1:4433 -psk 123456  -quiet -sess_out session.txt > /dev/null 2>&1'
    return command

def handshake_earlydata_sessin(ke_alg):
    command = 'sudo ip netns exec client_namespace apps/openssl s_client -connect 192.168.1.1:4433 -psk 123456  -quiet -sess_in session.txt -early_data earlydatafile.log'
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
        process_in.stdout.close()  # 关闭管道
    return first_lines

def run_subprocess(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Command execution failed with return code %d: %s", e.returncode, e.stderr)
        raise



def netem_set(ns, dev, lossrate, latency):
    if lossrate == 0:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'rate', '1000mbit']
    else:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'loss', '{0}%'.format(lossrate), 'latency', latency, 'rate', '1000mbit']
    #logging.info("Executing command: %s", ' '.join(command))
    run_command(command,1)

# def run_handshake(process,ke_alg, count):
#     with Pool(processes=process) as pool:  # 创建一个包含10个进程的进程池
#         results = pool.map(run_command, [handshake_command(ke_alg)] * count)  # 每个进程执行相同的命令 count 次
#     return results
def run_handshake(num_processes,num_test, ke_alg):
    ip1='192.168.1.1:4433'
    ip2='192.168.1.2:4433'
    with Pool(processes=num_processes) as pool:
        tasks = [1] * num_processes
        commands = [handshake_command(ke_alg,ip1)] * num_test +  [handshake_command(ke_alg,ip2)] * (num_processes-num_test)
        iden = ['id1'] * num_test + ['id2'] * (num_processes-num_test)
        results = pool.starmap(run_command, zip(commands, tasks, iden))
    return results
     
#prime256v1 secp384r1 secp521r1

#kyber512 sntrup761 kyber768 kyber1024

#p256_kyber512 p256_sntrup761 p384_kyber768 p521_kyber1024
Latency = ['33.75ms']
Lossrate = [5]
Ke_alg      = ['p521_kyber1024']
Lossrate    = [5]
num_clients = multiprocessing.cpu_count()
count       = 100
for i in range(1,num_clients):
    current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    folder_path = os.path.join("data518", current_time)
    os.makedirs(folder_path, exist_ok=True)

    for latency_time in Latency:
        # 获取实际 (模拟) RTT
        netem_set('client_namespace', 'client_veth1', 0, latency=latency_time)
        netem_set('client_namespace', 'client_veth2', 0, latency=latency_time)
        netem_set('server_namespace1', 'server_veth1', 0, latency=latency_time)
        netem_set('server_namespace2', 'server_veth2', 0, latency=latency_time)

        for ke_alg in Ke_alg:
            # 在文件夹中创建测试数据文件
            file_name1 = os.path.join(folder_path, '{}_{}ms_full_id1_{}.csv'.format(ke_alg, rtt_str,i))
            file_name2 = os.path.join(folder_path, '{}_{}ms_full_id2_{}.csv'.format(ke_alg, rtt_str,num_clients-i))
            with open(file_name1, 'w') as out1, open(file_name2, 'w') as out2 :
                # 每一行包含: lossrate, observations
                csv_out1 = csv.writer(out1)
                csv_out2 = csv.writer(out2)
                for lossrate in Lossrate:
                    netem_set('client_namespace', 'client_veth1', lossrate, latency=latency_time)
                    netem_set('client_namespace', 'client_veth2', lossrate, latency=latency_time)
                    netem_set('server_namespace1', 'server_veth1', lossrate, latency=latency_time)
                    netem_set('server_namespace2', 'server_veth2', lossrate, latency=latency_time)
                    # 创建多个进程代表不同的客户端
                    handshake_times1 = []
                    handshake_times2 = []
                    for j in range(count):
                        handshake_time = run_handshake(num_clients,i,ke_alg)
                        for sublist in handshake_time:
                            handshake_time =sublist[1]
                            if sublist[0] == 'id1':
                                handshake_times1.append(handshake_time)
                            elif sublist[0] == 'id2':
                                handshake_times2.append(handshake_time)
                    csv_out1.writerow(handshake_times1)
                    csv_out2.writerow(handshake_times2)