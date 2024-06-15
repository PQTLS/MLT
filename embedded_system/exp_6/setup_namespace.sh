ip netns add node0
ip netns add node1
ip netns add node2
ip netns add node3


ip link add veth0 type veth peer name veth1
ip link add veth2 type veth peer name veth3
ip link add veth4 type veth peer name veth5


ip link set veth0 netns node0
ip link set veth1 netns node1
ip link set veth2 netns node1
ip link set veth3 netns node2
ip link set veth4 netns node2
ip link set veth5 netns node3



ip netns exec node0 ip link set dev lo up
ip netns exec node0 ip link set dev veth0 up

ip netns exec node1 ip link set dev lo up
ip netns exec node1 ip link set dev veth1 up
ip netns exec node1 ip link set dev veth2 up

ip netns exec node2 ip link set dev lo up
ip netns exec node2 ip link set dev veth3 up
ip netns exec node2 ip link set dev veth4 up

ip netns exec node3 ip link set dev lo up
ip netns exec node3 ip link set dev veth5 up




ip netns exec node0 ip addr add 192.168.1.1/24 dev veth0
ip netns exec node1 ip addr add 192.168.1.2/24 dev veth1
ip netns exec node1 ip addr add 192.168.2.1/24 dev veth2
ip netns exec node2 ip addr add 192.168.2.2/24 dev veth3
ip netns exec node2 ip addr add 192.168.3.1/24 dev veth4
ip netns exec node3 ip addr add 192.168.3.2/24 dev veth5



echo 1 > /proc/sys/net/ipv4/ip_forward


ip netns exec node0 ip route add 192.168.2.0/24 via 192.168.1.2 dev veth0
ip netns exec node2 ip route add 192.168.1.0/24 via 192.168.2.1 dev veth3

ip netns exec node1 ip route add 192.168.3.0/24 via 192.168.2.2 dev veth2
ip netns exec node3 ip route add 192.168.2.0/24 via 192.168.3.1 dev veth5

ip netns exec node0 ip route add 192.168.3.0/24 via 192.168.1.2 dev veth0
ip netns exec node3 ip route add 192.168.1.0/24 via 192.168.3.1 dev veth5


sudo ip netns exec node0 tc qdisc add dev veth0 root netem
sudo ip netns exec node1 tc qdisc add dev veth1 root netem
sudo ip netns exec node1 tc qdisc add dev veth2 root netem
sudo ip netns exec node2 tc qdisc add dev veth3 root netem
sudo ip netns exec node2 tc qdisc add dev veth4 root netem
sudo ip netns exec node3 tc qdisc add dev veth5 root netem





