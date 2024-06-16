import subprocess
import csv
import multiprocessing
import time
import shlex
import os
import logging
import datetime
from multiprocessing import Pool

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def netem_set(ns, dev, lossrate, latency):
    if lossrate == 0:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'rate', '1000mbit']
    else:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'loss', '{0}%'.format(lossrate), 'latency', latency, 'rate', '1000mbit']
    run_command(command,1)

def handshake_command(ke_alg,ip):
    command = [ 'ip', 'netns', 'exec', 'client_namespace', '../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl', 's_time','-curves', ke_alg, '-ip',ip]
    return command

def run_command(command,num,identifier=''):
    try:
        results =[identifier]
        for i in range(num):
            result = subprocess.run(command, capture_output=True, text=True, check=True)
            results.append(result.stdout)
        return results
    except subprocess.CalledProcessError as e:
        logging.error("Command execution failed with return code %d: %s", e.returncode, e.stderr)
        raise

def rtt_time():
    command = ['ip', 'netns', 'exec', 'client_namespace', 'ping', '192.168.1.1', '-c', '3']
    result = run_command(command,1)
    result_fmt = str(result).splitlines()[-1].split("/")
    return result_fmt[4].replace(".", "p")

def run_handshake(num_processes,num_test, ke_alg):
    ip1='192.168.1.1:4433'
    ip2='192.168.1.2:4433'
    with Pool(processes=num_processes) as pool:
        tasks = [1] * num_processes
        commands = [handshake_command(ke_alg,ip1)] * num_test +  [handshake_command(ke_alg,ip2)] * (num_processes-num_test)
        iden = ['id1'] * num_test + ['id2'] * (num_processes-num_test)
        results = pool.starmap(run_command, zip(commands, tasks, iden))
    return results

if __name__ == "__main__":
    ke_alg = 'prime256v1'
    Lossrate = [0,3,5]
    Latency = ['7.75ms','14.75ms','33.75ms']
    for k in range(0,3):
        num_clients = multiprocessing.cpu_count()
        count       = 1
        for i in range(1,num_clients):
            current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
            folder_path1 = os.path.join("data",ke_alg,'server1')
            folder_path2 = os.path.join("data",ke_alg,'server2')
            os.makedirs(folder_path1, exist_ok=True)
            os.makedirs(folder_path2, exist_ok=True)
            latency_time = Latency[k]
            netem_set('client_namespace', 'client_veth1', 0, latency=latency_time)
            netem_set('client_namespace', 'client_veth2', 0, latency=latency_time)
            netem_set('server_namespace1', 'server_veth1', 0, latency=latency_time)
            netem_set('server_namespace2', 'server_veth2', 0, latency=latency_time)
            rtt_str = rtt_time()

            file_name1 = os.path.join(folder_path1, '{}_{}ms_{}.csv'.format(ke_alg, rtt_str,i))
            file_name2 = os.path.join(folder_path2, '{}_{}ms_{}.csv'.format(ke_alg, rtt_str,num_clients-i))
            with open(file_name1, 'w') as out1, open(file_name2, 'w') as out2 :
                csv_out1 = csv.writer(out1)
                csv_out2 = csv.writer(out2)
                lossrate = Lossrate[k]
                netem_set('client_namespace', 'client_veth1', lossrate, latency=latency_time)
                netem_set('client_namespace', 'client_veth2', lossrate, latency=latency_time)
                netem_set('server_namespace1', 'server_veth1', lossrate, latency=latency_time)
                netem_set('server_namespace2', 'server_veth2', lossrate, latency=latency_time)
                handshake_times1 = [lossrate]
                handshake_times2 = [lossrate]
                for j in range(count):
                    handshake_time = run_handshake(num_clients,i,ke_alg)
                    for sublist in handshake_time:
                        handshake_time =sublist[1]
                        if sublist[0] == 'server1':
                            handshake_times1.append(handshake_time)
                        elif sublist[0] == 'server2':
                            handshake_times2.append(handshake_time)
                csv_out1.writerow(handshake_times1)
                csv_out2.writerow(handshake_times2)