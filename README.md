# pq-tls-test

PQ-TLS-Test is a project dedicated to testing post-quantum secure TLS handshakes. The project aims to provide comprehensive insights into the performance of post-quantum cryptography (PQC) by evaluating various handshake modes, client loads, and network topologies.

## Key Features
**Handshake Modes** : Supports testing of 1-RTT, PSK, and 0-RTT handshake modes.  
**Client Load** : Evaluates server performance under varying numbers of client connections.  
**Network Topologies** : Creates multiple network namespaces to simulate different network configurations and topologies, i.e., ring, star and tree.

## Objectives
(1) To assess the performance impact of different handshake modes in a post-quantum cryptography context.  
(2) To understand how the number of clients affects server performance during PQC handshakes.  
(3) To explore the influence of various network topologies on the efficiency of PQC handshakes.  