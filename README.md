# PQ-TLS-TEST
PQ-TLS-Test is a project dedicated to testing post-quantum TLS handshakes. The project aims to provide comprehensive insights into the performance of post-quantum cryptography (PQC) by evaluating various handshake modes, client scales, and network topologies.

## Key Features
1. Handshake Modes : Supports testing of 1-RTT, PSK, and 0-RTT handshake modes, allowing for assessment of the performance impact of different handshake methods within a post-quantum cryptography context.
2. Client Scales : Evaluates server performance under varying numbers of clients, providing insights into how the number of clients affects server performance during PQC handshakes
3. Network Topologies : Creates multiple network namespaces to simulate different network configurations and topologies, i.e., ring, star and tree, enabling exploration of how various network topologies influence the efficiency of PQC handshakes.
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