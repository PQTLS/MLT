#!/bin/bash

k=8
for ((i=1; i<=k; i++))
do
    echo "Creating namespace: node${i}"
    ip netns add node${i}
done

ip link add veth1 type veth peer name veth2
c=2
for ((i=2; i<=k-1; i<<=1))
do
    for ((j=1; j<=i; j+=1))
    do
        ip link add veth$((c+j)) type veth peer name veth$((c+i+j))
    done
     c=$((c+2*i))
done


ip link set veth1 netns node1
ip link set veth2 netns node2
ip link set veth3 netns node2
ip link set veth4 netns node2
ip link set veth5 netns node3
ip link set veth7 netns node3
ip link set veth8 netns node3
ip link set veth6 netns node4
ip link set veth9 netns node4
ip link set veth10 netns node4
ip link set veth11 netns node5
ip link set veth12 netns node6
ip link set veth13 netns node7
ip link set veth14 netns node8



ip netns exec node1 ip link set dev lo up
ip netns exec node1 ip link set dev veth1 up

ip netns exec node2 ip link set dev lo up
ip netns exec node2 ip link set dev veth2 up
ip netns exec node2 ip link set dev veth3 up
ip netns exec node2 ip link set dev veth4 up

ip netns exec node3 ip link set dev lo up
ip netns exec node3 ip link set dev veth5 up
ip netns exec node3 ip link set dev veth7 up
ip netns exec node3 ip link set dev veth8 up

ip netns exec node4 ip link set dev lo up
ip netns exec node4 ip link set dev veth6 up
ip netns exec node4 ip link set dev veth9 up
ip netns exec node4 ip link set dev veth10 up

ip netns exec node5 ip link set dev lo up
ip netns exec node5 ip link set dev veth11 up

ip netns exec node6 ip link set dev lo up
ip netns exec node6 ip link set dev veth12 up

ip netns exec node7 ip link set dev lo up
ip netns exec node7 ip link set dev veth13 up

ip netns exec node8 ip link set dev lo up
ip netns exec node8 ip link set dev veth14 up

ip netns exec node1 ip addr add 192.168.1.1/24 dev veth1

ip netns exec node2 ip addr add 192.168.1.2/24 dev veth2
ip netns exec node2 ip addr add 192.168.2.1/24 dev veth3
ip netns exec node2 ip addr add 192.168.3.1/24 dev veth4

ip netns exec node3 ip addr add 192.168.2.2/24 dev veth5
ip netns exec node3 ip addr add 192.168.4.1/24 dev veth7
ip netns exec node3 ip addr add 192.168.5.1/24 dev veth8

ip netns exec node4 ip addr add 192.168.3.2/24 dev veth6
ip netns exec node4 ip addr add 192.168.6.1/24 dev veth9
ip netns exec node4 ip addr add 192.168.7.1/24 dev veth10

ip netns exec node5 ip addr add 192.168.4.2/24 dev veth11

ip netns exec node6 ip addr add 192.168.5.2/24 dev veth12

ip netns exec node7 ip addr add 192.168.6.2/24 dev veth13

ip netns exec node8 ip addr add 192.168.7.2/24 dev veth14


echo 1 > /proc/sys/net/ipv4/ip_forward

ip netns exec node3 ip route add 192.168.1.0/24 via 192.168.2.1 dev veth5
ip netns exec node1 ip route add 192.168.2.0/24 via 192.168.1.2 dev veth1

ip netns exec node4 ip route add 192.168.1.0/24 via 192.168.3.1 dev veth6
ip netns exec node1 ip route add 192.168.3.0/24 via 192.168.1.2 dev veth1
#
ip netns exec node5 ip route add 192.168.2.0/24 via 192.168.4.1 dev veth11
ip netns exec node2 ip route add 192.168.4.0/24 via 192.168.2.2 dev veth3

ip netns exec node6 ip route add 192.168.2.0/24 via 192.168.5.1 dev veth12
ip netns exec node2 ip route add 192.168.5.0/24 via 192.168.2.2 dev veth3

ip netns exec node7 ip route add 192.168.3.0/24 via 192.168.6.1 dev veth13
ip netns exec node2 ip route add 192.168.6.0/24 via 192.168.3.2 dev veth4

ip netns exec node8 ip route add 192.168.3.0/24 via 192.168.7.1 dev veth14
ip netns exec node2 ip route add 192.168.7.0/24 via 192.168.3.2 dev veth4

#
ip netns exec node5 ip route add 192.168.1.0/24 via 192.168.4.1 dev veth11
ip netns exec node1 ip route add 192.168.4.0/24 via 192.168.1.2 dev veth1

ip netns exec node6 ip route add 192.168.1.0/24 via 192.168.5.1 dev veth12
ip netns exec node1 ip route add 192.168.5.0/24 via 192.168.1.2 dev veth1

ip netns exec node7 ip route add 192.168.1.0/24 via 192.168.6.1 dev veth13
ip netns exec node1 ip route add 192.168.6.0/24 via 192.168.1.2 dev veth1

ip netns exec node8 ip route add 192.168.1.0/24 via 192.168.7.1 dev veth14
ip netns exec node1 ip route add 192.168.7.0/24 via 192.168.1.2 dev veth1


sudo ip netns exec node1 tc qdisc add dev veth1 root netem
sudo ip netns exec node2 tc qdisc add dev veth2 root netem
sudo ip netns exec node2 tc qdisc add dev veth3 root netem
sudo ip netns exec node2 tc qdisc add dev veth4 root netem
sudo ip netns exec node3 tc qdisc add dev veth5 root netem
sudo ip netns exec node3 tc qdisc add dev veth7 root netem
sudo ip netns exec node3 tc qdisc add dev veth8 root netem
sudo ip netns exec node4 tc qdisc add dev veth6 root netem

sudo ip netns exec node4 tc qdisc add dev veth9 root netem
sudo ip netns exec node4 tc qdisc add dev veth10 root netem
sudo ip netns exec node5 tc qdisc add dev veth11 root netem
sudo ip netns exec node6 tc qdisc add dev veth12 root netem
sudo ip netns exec node7 tc qdisc add dev veth13 root netem
sudo ip netns exec node8 tc qdisc add dev veth14 root netem