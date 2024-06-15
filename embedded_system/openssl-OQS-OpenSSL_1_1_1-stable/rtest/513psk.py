#Client
import subprocess
import csv
import multiprocessing
import time
import shlex
import os
import logging
import datetime

# 设置日志配置
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# 预先获取sudo权限

def netem_set(ns, dev,latency,loss):
    if loss == 0:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'rate', '1000mbit']
    else:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'loss','{0}%'.format(loss),'rate', '1000mbit']
    #logging.info("Executing command: %s", ' '.join(command))
    run_subprocess(command)

def handshake_psk(ke_alg):
    command = [ 'ip', 'netns', 'exec', 'client_namespace', '../apps/openssl', 's_time','-curves', ke_alg, '-psk','123456']
    return command
def rtt_time():
    command = ['ip', 'netns', 'exec', 'client_namespace', 'ping', '192.168.1.1', '-c', '10']
    #logging.info("Executing command: %s", ' '.join(command))
    result = run_subprocess(command)
    result_fmt = result.splitlines()[-1].split("/")
    return result_fmt[4].replace(".", "p")

def run_client(ke_alg, count):
    handshake_times = []
    for _ in range(count):
        process = subprocess.Popen(handshake_psk(ke_alg), stdout=subprocess.PIPE, text=True)
        output, _ = process.communicate()
        handshake_times.append(output)
        #time.sleep(0.1)  # 暂停秒，可以根据需要调整间隔时间
    return handshake_times

def run_subprocess(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Command execution failed with return code %d: %s", e.returncode, e.stderr)
        raise
#25 50 75
#Ke_alg      =['secp521r1','kyber1024','hqc256','bikel5']
#Ke_alg      =['secp384r1','kyber768','hqc192','bikel3']
#Ke_alg      = ['prime256v1','kyber512','hqc128','bikel1']
#Ke_alg      =['secp521r1','p521_kyber1024','p521_hqc256','p521_bikel5']
#Ke_alg      =['secp384r1','p384_kyber768','p384_hqc192','p384_bikel3']
#Ke_alg      = ['prime256v1','p256_kyber512','p256_hqc128','p256_bikel1']

#prime256v1 secp384r1 secp521r1

#kyber512 sntrup761 kyber768 kyber1024

#p256_kyber512 p256_sntrup761 p384_kyber768 p521_kyber1024

Ke_alg   = ['prime256v1', 'secp384r1', 'secp521r1','kyber512','sntrup761','kyber768','kyber1024','p256_kyber512','p256_sntrup761','p384_kyber768','p521_kyber1024',]
Lossrate = [0,3,5]
Latency  = ['7.75ms','14.75ms','33.75ms']
count = 500

current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
folder_path = os.path.join("data/522pskemulation", current_time)
os.makedirs(folder_path, exist_ok=True)
for i in range(0,3):
    latency_time =Latency[i]
    loss_rate=Lossrate[i]
    # 获取实际 (模拟) RTT
    netem_set('client_namespace', 'client_veth',  latency=latency_time,loss = 0)
    netem_set('server_namespace', 'server_veth',  latency=latency_time,loss = 0)
    rtt_str = rtt_time()
    for ke_alg in Ke_alg:
        # 在文件夹中创建测试数据文件
        file_name = os.path.join(folder_path, '{}_{}ms_psk.csv'.format(ke_alg, rtt_str))
        with open(file_name, 'w') as out:
            # 每一行包含: lossrate, observations
            csv_out = csv.writer(out)
            netem_set('client_namespace', 'client_veth', latency=latency_time,loss=loss_rate)
            netem_set('server_namespace', 'server_veth', latency=latency_time,loss=loss_rate)
            # 创建多个进程代表不同的客户端
            handshake_times = [loss_rate]
            handshake_time = run_client(ke_alg,count)
            handshake_times.extend(handshake_time)
            csv_out.writerow(handshake_times)

            # for client in range(1, num_clients + 1):
            #     handshake_times = run_client(client, ke_alg, count)
            #     # 将握手时间写入CSV文件s
            #     csv_out.writerow([lossrate, handshake_times])
