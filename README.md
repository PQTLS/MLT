# PQ-TLS-TEST
PQ-TLS-Test is a project dedicated to testing post-quantum TLS handshakes in PQ-only and PQ-hybrid schemes. The project aims to provide comprehensive insights into the performance of post-quantum cryptography (PQC) by evaluating various handshake modes, client scales, and network topologies.

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
#### 23 Setting up on on a Raspberry Pi
```shell
cd embedded_system
sudo ./raspberry_setup.sh
```