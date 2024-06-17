# PQ-TLS-TEST
PQ-TLS-Test is a project dedicated to testing post-quantum TLS handshakes in PQ-only and PQ-hybrid schemes on both general-purpose computer systems and embedded systems. The project aims to provide comprehensive insights into the performance of post-quantum cryptography (PQC) by evaluating various handshake modes, client scales, and network topologies. *This is the **artifact** of Assessing the Performance of Post-Quantum TLS 1.3: Handshake Modes, Client Scales, and Network Topologies submitted to **CoNEXT24**.*

## Key Features
1. Handshake Modes : The framework supports testing of 1-RTT, PSK, and 0-RTT handshake modes, allowing for assessment of the performance impact of different handshake methods with PQC.
2. Client Scales : The framework evaluates server performance under varying client loads, providing insights into how the number of clients affects server performance during PQC handshakes
3. Network Topologies : The framework creates multiple network namespaces to simulate different network configurations and topologies, such as ring, star and tree, enabling exploration of how various network topologies influence the efficiency of PQC handshakes.
## Getting Started
### 1.Prerequisites
#### 1.1 General-Purpose Computer System
* Operating system: Ubuntu 22.04.3 LTS
* Architecture: x86_64
* RAM: 8GB
* CPU: 16-core 11th Gen Intel(R) Core(TM) i7-11700 @ 2.50GHz
* GCC Version: 11.4.0 
#### 1.2 Embedded System
* Device: Raspberry Pi 4 Model B
* Processor: 64-bit quad-core ARM Cortex-A72 @ 1.8 GHz
* RAM: 4GB SDRAM
* GCC Version: 10.2.1
#### 1.3 Software Requriments
* OQS-OpenSSL: 1.1.1-stable
* liboqs: 0.9.0
### 2. Installation
#### 2.1 Update and upgrade your system:
```Shell
sudo apt update
sudo apt upgrade
```
#### 2.2 Setting up on a General-Purpose Computer
```shell
cd general-purpose_computer_system
sudo ./ubunntu_setup.sh
```
#### 2.3 Setting up on on a Raspberry Pi
```shell
cd embedded_system
sudo ./raspberry_setup.sh
```
### 3. Evaluation
For General-Purpose Computer
```shell
cd general-purpose_computer_system
```
For Raspberry Pi
```shell
cd  embedded_system
```
Algorithms involved in this experiment:
```python
#Signature algorithms to replace with:
- rsa:2048
- rsa:3072
- rsa:4096
- falcon512
- dilithium2
- dilithium3
- dilithium5
- p256_falcon512
- p256_dilithium2
- p384_dilithium3
- p521_dilithium5
#Key exchange algorithms to replace with:
- prime256v1 
- secp384r1 
- secp521r1
- kyber512 
- sntrup761 
- kyber768 
- kyber1024
- p256_kyber512 
- p256_sntrup761 
- p384_kyber768 
- p521_kyber1024
```

#### 3.1 KEM and SA combination experiment
```shell
cd exp_1
sudo ./setup_namespace.sh
#For each KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

#### 3.2 1-RTT experiment
```shell
cd exp_2
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```
#### 3.3 PSK experiment
```shell
cd exp_3
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

#### 3.4 0-RTT experiment
```shell
cd exp_4
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when client.py finished, press ctrl+c in comdline running server.py
sudo python extract.py
sudo python earlydata.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

#### 3.5 client scale experiment
```shell
cd exp_5
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

#### 3.6 four nodes linear connection experiment
```shell
cd exp_6
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```
#### 3.7 ring topology experiment
```shell
cd exp_7
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

#### 3.8 star topology experiment
```shell
cd exp_8
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```
#### 3.9 tree topology experiment
```shell
cd exp_9
sudo ./setup_namespace.sh
#For selected KEM and SA, modify the parameter in server.py and client.py respectively.
sudo python server.py
sudo python client.py
#when finishing this experiment, delete namespaces.
sudo ./delete_namespace.sh
```

