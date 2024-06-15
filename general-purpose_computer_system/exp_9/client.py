#Client
import subprocess
import csv
import time
import shlex
import os
import logging
import datetime
from functools import partial
from multiprocessing import Pool

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def netem_set(ns, dev, lossrate, latency):
    if lossrate == 0:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'latency', latency, 'rate', '1000mbit']
    else:
        command = ['ip', 'netns', 'exec', ns, 'tc', 'qdisc', 'change', 'dev', dev, 'root', 'netem', 'limit', '1000', 'loss', '{0}%'.format(lossrate), 'latency', latency, 'rate', '1000mbit']
    run_subprocess(command)

def handshake_full(node_id,ke_alg):
    command = [ 'ip', 'netns', 'exec', 'node'+str(node_id), '../openssl-OQS-OpenSSL_1_1_1-stable/apps/openssl', 's_time','-curves', ke_alg]
    return command

def run_client(node_id, ke_alg, count):
    handshake_times = []
    for _ in range(count):
        process = subprocess.Popen(handshake_full(node_id,ke_alg), stdout=subprocess.PIPE, text=True)
        output, _ = process.communicate()
        handshake_times.append(output)
    return handshake_times

def run_subprocess(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Command execution failed with return code %d: %s", e.returncode, e.stderr)
        raise


def test_node(node_id,latency_time,ke_alg,lossrate,current_time):
    count = 5
    folder_path = os.path.join("data", 'node'+str(node_id))
    os.makedirs(folder_path, exist_ok=True)
    file_name = os.path.join(folder_path, '{}_{}.csv'.format(ke_alg, latency_time))
    with open(file_name, 'a') as out:
        csv_out = csv.writer(out)
        handshake_times = [lossrate]
        handshake_time = run_client(node_id, ke_alg, count)
        handshake_times.extend(handshake_time)
        csv_out.writerow(handshake_times)
def run_timers(kex_alg,latency_time,lossrate,current_time, timer_pool):
    timer_pool.starmap(test_node, [(3,latency_time,kex_alg,lossrate,current_time),(4,latency_time,kex_alg,lossrate,current_time),
                                   (5,latency_time,kex_alg,lossrate,current_time),(6,latency_time,kex_alg,lossrate,current_time),(7,latency_time,kex_alg,lossrate,current_time),(8,latency_time,kex_alg,lossrate,current_time)])
#prime256v1 secp384r1 secp521r1

#kyber512 sntrup761 kyber768 kyber1024

#p256_kyber512 p256_sntrup761 p384_kyber768 p521_kyber1024
if __name__ == "__main__":
    timer_pool = Pool(processes=6)
    ke_alg = 'prime256v1'
    Latency     = ['0ms','5ms','10ms']
    Lossrate    = [0,3,5]
    for i in range(0,3):
        latency_time = Latency[i]
        lossrate = Lossrate[i]
        netem_set('node2', 'veth3', lossrate, latency=latency_time)
        netem_set('node2', 'veth4', lossrate, latency=latency_time)
        netem_set('node3', 'veth5', lossrate, latency=latency_time)
        netem_set('node3', 'veth7', lossrate, latency=latency_time)
        netem_set('node3', 'veth8', lossrate, latency=latency_time)
        netem_set('node4', 'veth6', lossrate, latency=latency_time)
        netem_set('node4', 'veth9', lossrate, latency=latency_time)
        netem_set('node4', 'veth10', lossrate, latency=latency_time)
        netem_set('node5', 'veth11', lossrate, latency=latency_time)
        netem_set('node6', 'veth12', lossrate, latency=latency_time)
        netem_set('node7', 'veth13', lossrate, latency=latency_time)
        netem_set('node8', 'veth14', lossrate, latency=latency_time)
        current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        run_timers(ke_alg,latency_time,lossrate,current_time,timer_pool)
    timer_pool.close()
    timer_pool.join()



