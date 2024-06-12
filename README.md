# pq-tls-test

PQ-TLS-Test is a project dedicated to testing post-quantum secure TLS handshakes. The project aims to provide comprehensive insights into the performance of post-quantum cryptography (PQC) by evaluating various handshake modes, client loads, and network topologies.

## Key Features
1. Handshake Modes : Supports testing of 1-RTT, PSK, and 0-RTT handshake modes.  
2. Client Load : Evaluates server performance under varying numbers of client connections.  
3. Network Topologies : Creates multiple network namespaces to simulate different network configurations and topologies, i.e., ring, star and tree.

## Objectives
* To assess the performance impact of different handshake modes in a post-quantum cryptography context.  
* To understand how the number of clients affects server performance during PQC handshakes.  
* To explore the influence of various network topologies on the efficiency of PQC handshakes.  

## Getting Started
### Prerequisites
1. General-Purpose Computer System:
* Operating system: Ubuntu 22.04.3 LTS
* Architecture: x86_64
* RAM: 8GB
* CPU: 16-core 11th Gen Intel(R) Core(TM) i7-11700 @ 2.50GHz
* GCC Version: 11.4.0
2. Embedded System:
* Device: Raspberry Pi 4 Model B
* Processor: 64-bit quad-core ARM Cortex-A72 @ 1.8 GHz
* RAM: 4GB SDRAM
* GCC Version: 10.2.1
3. Software Requriments
* OQS-OpenSSL: 1.1.1-stable
* liboqs: 0.9.0