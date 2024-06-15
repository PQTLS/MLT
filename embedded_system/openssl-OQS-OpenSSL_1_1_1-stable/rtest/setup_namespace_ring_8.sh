# ip netns add node1
# ip netns add node2
# ip netns add node3
# ip netns add node4
# ip netns add node5
# # 创建虚拟以太网卡（veth pair）来连接每个节点
# ip link add veth1 type veth peer name veth2
# ip link add veth3 type veth peer name veth4
# ip link add veth5 type veth peer name veth6
# ip link add veth7 type veth peer name veth8
# # 将虚拟网卡挂载到对应的网络命名空间中
# ip link set veth1 netns node1
# ip link set veth2 netns node2
# ip link set veth3 netns node2
# ip link set veth4 netns node3
# ip link set veth5 netns node3
# ip link set veth6 netns node4
# ip link set veth7 netns node4
# ip link set veth8 netns node5
# # 启动每个网络命名空间中的网络接口
# ip netns exec node1 ip link set dev lo up
# ip netns exec node1 ip link set dev veth1 up

# ip netns exec node2 ip link set dev lo up
# ip netns exec node2 ip link set dev veth2 up
# ip netns exec node2 ip link set dev veth3 up

# ip netns exec node3 ip link set dev lo up
# ip netns exec node3 ip link set dev veth4 up
# ip netns exec node3 ip link set dev veth5 up

# ip netns exec node4 ip link set dev lo up
# ip netns exec node4 ip link set dev veth6 up
# ip netns exec node4 ip link set dev veth7 up

# ip netns exec node5 ip link set dev lo up
# ip netns exec node5 ip link set dev veth8 up
# # 分配 IP 地址
# ip netns exec node1 ip addr add 192.168.1.1/24 dev veth1
# ip netns exec node2 ip addr add 192.168.1.2/24 dev veth2
# ip netns exec node2 ip addr add 192.168.2.1/24 dev veth3
# ip netns exec node3 ip addr add 192.168.2.2/24 dev veth4
# ip netns exec node3 ip addr add 192.168.3.1/24 dev veth5
# ip netns exec node4 ip addr add 192.168.3.2/24 dev veth6
# ip netns exec node4 ip addr add 192.168.4.1/24 dev veth7
# ip netns exec node5 ip addr add 192.168.4.2/24 dev veth8

# # 启用 IP 转发
# echo 1 > /proc/sys/net/ipv4/ip_forward

# # 在节点1和节点3之间添加路由
# ip netns exec node1 ip route add 192.168.2.0/24 via 192.168.1.2 dev veth1
# ip netns exec node3 ip route add 192.168.1.0/24 via 192.168.2.1 dev veth4
# ip netns exec node2 ip route add 192.168.3.0/24 via 192.168.2.2 dev veth3
# ip netns exec node4 ip route add 192.168.2.0/24 via 192.168.3.1 dev veth6

# ip netns exec node3 ip route add 192.168.4.0/24 via 192.168.3.2 dev veth5
# ip netns exec node5 ip route add 192.168.3.0/24 via 192.168.4.1 dev veth8

# ip netns exec node1 ip route add 192.168.3.0/24 via 192.168.1.2 dev veth1
# ip netns exec node4 ip route add 192.168.1.0/24 via 192.168.3.1 dev veth6

# ip netns exec node1 ip route add 192.168.4.0/24 via 192.168.1.2 dev veth1
# ip netns exec node5 ip route add 192.168.1.0/24 via 192.168.4.1 dev veth8

# ip netns exec node2 ip route add 192.168.4.0/24 via 192.168.2.2 dev veth3
# ip netns exec node5 ip route add 192.168.2.0/24 via 192.168.4.1 dev veth8
ip netns add node0
ip netns add node1
ip netns add node2
ip netns add node3
ip netns add node4
ip netns add node5
ip netns add node6
ip netns add node7
# 创建虚拟以太网卡（veth pair）来连接每个节点
ip link add veth0 type veth peer name veth1
ip link add veth2 type veth peer name veth3
ip link add veth4 type veth peer name veth5
ip link add veth6 type veth peer name veth7
ip link add veth8 type veth peer name veth9
ip link add veth10 type veth peer name veth11
ip link add veth12 type veth peer name veth13
ip link add veth14 type veth peer name veth15
# 将虚拟网卡挂载到对应的网络命名空间中
ip link set veth0 netns node0
ip link set veth15 netns node1
ip link set veth1 netns node1
ip link set veth2 netns node1
ip link set veth3 netns node2
ip link set veth4 netns node2
ip link set veth5 netns node3
ip link set veth6 netns node3
ip link set veth7 netns node4
ip link set veth8 netns node4
ip link set veth9 netns node5
ip link set veth10 netns node5
ip link set veth11 netns node6
ip link set veth12 netns node6
ip link set veth13 netns node7
ip link set veth14 netns node7
# 启动每个网络命名空间中的网络接口
ip netns exec node0 ip link set dev lo up
ip netns exec node0 ip link set dev veth0 up

ip netns exec node1 ip link set dev lo up
ip netns exec node1 ip link set dev veth15 up
ip netns exec node1 ip link set dev veth1 up
ip netns exec node1 ip link set dev veth2 up

ip netns exec node2 ip link set dev lo up
ip netns exec node2 ip link set dev veth3 up
ip netns exec node2 ip link set dev veth4 up

ip netns exec node3 ip link set dev lo up
ip netns exec node3 ip link set dev veth5 up
ip netns exec node3 ip link set dev veth6 up

ip netns exec node4 ip link set dev lo up
ip netns exec node4 ip link set dev veth7 up
ip netns exec node4 ip link set dev veth8 up

ip netns exec node5 ip link set dev lo up
ip netns exec node5 ip link set dev veth9 up
ip netns exec node5 ip link set dev veth10 up

ip netns exec node6 ip link set dev lo up
ip netns exec node6 ip link set dev veth11 up
ip netns exec node6 ip link set dev veth12 up

ip netns exec node7 ip link set dev lo up
ip netns exec node7 ip link set dev veth13 up
ip netns exec node7 ip link set dev veth14 up
# 分配 IP 地址
ip netns exec node0 ip addr add 192.168.1.1/24 dev veth0
ip netns exec node1 ip addr add 192.168.8.2/24 dev veth15
ip netns exec node1 ip addr add 192.168.1.2/24 dev veth1
ip netns exec node1 ip addr add 192.168.2.1/24 dev veth2
ip netns exec node2 ip addr add 192.168.2.2/24 dev veth3
ip netns exec node2 ip addr add 192.168.3.1/24 dev veth4
ip netns exec node3 ip addr add 192.168.3.2/24 dev veth5
ip netns exec node3 ip addr add 192.168.4.1/24 dev veth6
ip netns exec node4 ip addr add 192.168.4.2/24 dev veth7
ip netns exec node4 ip addr add 192.168.5.1/24 dev veth8
ip netns exec node5 ip addr add 192.168.5.2/24 dev veth9
ip netns exec node5 ip addr add 192.168.6.1/24 dev veth10
ip netns exec node6 ip addr add 192.168.6.2/24 dev veth11
ip netns exec node6 ip addr add 192.168.7.1/24 dev veth12
ip netns exec node7 ip addr add 192.168.7.2/24 dev veth13
ip netns exec node7 ip addr add 192.168.8.1/24 dev veth14

# 启用 IP 转发
echo 1 > /proc/sys/net/ipv4/ip_forward

# 在节点1和节点3之间添加路由
#2
ip netns exec node1 ip route add 192.168.3.0/24 via 192.168.2.2 dev veth2
ip netns exec node3 ip route add 192.168.2.0/24 via 192.168.3.1 dev veth5

ip netns exec node2 ip route add 192.168.4.0/24 via 192.168.3.2 dev veth4
ip netns exec node4 ip route add 192.168.3.0/24 via 192.168.4.1 dev veth7

ip netns exec node3 ip route add 192.168.5.0/24 via 192.168.4.2 dev veth6
ip netns exec node5 ip route add 192.168.4.0/24 via 192.168.5.1 dev veth9

ip netns exec node4 ip route add 192.168.6.0/24 via 192.168.5.2 dev veth8
ip netns exec node6 ip route add 192.168.5.0/24 via 192.168.6.1 dev veth11

ip netns exec node5 ip route add 192.168.7.0/24 via 192.168.6.2 dev veth10
ip netns exec node7 ip route add 192.168.6.0/24 via 192.168.7.1 dev veth13

ip netns exec node6 ip route add 192.168.8.0/24 via 192.168.7.2 dev veth12
ip netns exec node1 ip route add 192.168.7.0/24 via 192.168.8.1 dev veth15

#3
ip netns exec node1 ip route add 192.168.4.0/24 via 192.168.2.2 dev veth2
ip netns exec node4 ip route add 192.168.2.0/24 via 192.168.4.1 dev veth7

ip netns exec node2 ip route add 192.168.5.0/24 via 192.168.3.2 dev veth4
ip netns exec node5 ip route add 192.168.3.0/24 via 192.168.5.1 dev veth9

ip netns exec node3 ip route add 192.168.6.0/24 via 192.168.4.2 dev veth6
ip netns exec node6 ip route add 192.168.4.0/24 via 192.168.6.1 dev veth11

ip netns exec node4 ip route add 192.168.7.0/24 via 192.168.5.2 dev veth8
ip netns exec node7 ip route add 192.168.5.0/24 via 192.168.7.1 dev veth13

ip netns exec node5 ip route add 192.168.8.0/24 via 192.168.6.2 dev veth10
ip netns exec node1 ip route add 192.168.6.0/24 via 192.168.8.1 dev veth15

ip netns exec node6 ip route add 192.168.2.0/24 via 192.168.7.2 dev veth12
ip netns exec node2 ip route add 192.168.7.0/24 via 192.168.2.1 dev veth3

ip netns exec node7 ip route add 192.168.3.0/24 via 192.168.8.2 dev veth14
ip netns exec node3 ip route add 192.168.8.0/24 via 192.168.3.1 dev veth5

#4
ip netns exec node1 ip route add 192.168.5.0/24 via 192.168.2.2 dev veth2
ip netns exec node2 ip route add 192.168.6.0/24 via 192.168.3.2 dev veth4
ip netns exec node3 ip route add 192.168.7.0/24 via 192.168.4.2 dev veth6
ip netns exec node4 ip route add 192.168.8.0/24 via 192.168.5.2 dev veth8
ip netns exec node5 ip route add 192.168.2.0/24 via 192.168.6.2 dev veth10
ip netns exec node6 ip route add 192.168.3.0/24 via 192.168.7.2 dev veth12
ip netns exec node7 ip route add 192.168.4.0/24 via 192.168.8.2 dev veth14


ip netns exec node2 ip route add 192.168.1.0/24 via 192.168.2.1 dev veth3
ip netns exec node0 ip route add 192.168.2.0/24 via 192.168.1.2 dev veth0

ip netns exec node3 ip route add 192.168.1.0/24 via 192.168.3.1 dev veth5
ip netns exec node0 ip route add 192.168.3.0/24 via 192.168.1.2 dev veth0

ip netns exec node4 ip route add 192.168.1.0/24 via 192.168.4.1 dev veth7
ip netns exec node0 ip route add 192.168.4.0/24 via 192.168.1.2 dev veth0

ip netns exec node5 ip route add 192.168.1.0/24 via 192.168.6.2 dev veth10
ip netns exec node0 ip route add 192.168.6.0/24 via 192.168.1.2 dev veth0

ip netns exec node6 ip route add 192.168.1.0/24 via 192.168.7.2 dev veth12
ip netns exec node0 ip route add 192.168.7.0/24 via 192.168.1.2 dev veth0

ip netns exec node7 ip route add 192.168.1.0/24 via 192.168.8.2 dev veth14
ip netns exec node0 ip route add 192.168.8.0/24 via 192.168.1.2 dev veth0

#ip netns exec node4 ip route add 192.168.1.0/24 via 192.168.5.2 dev veth7
#ip netns exec node3 ip route add 192.168.1.0/24 via 192.168.3.1 dev veth5
ip netns exec node0 ip route add 192.168.5.0/24 via 192.168.1.2 dev veth0

sudo ip netns exec node1 tc qdisc add dev veth15 root netem
sudo ip netns exec node1 tc qdisc add dev veth2 root netem
sudo ip netns exec node2 tc qdisc add dev veth3 root netem
sudo ip netns exec node2 tc qdisc add dev veth4 root netem
sudo ip netns exec node3 tc qdisc add dev veth5 root netem
sudo ip netns exec node3 tc qdisc add dev veth6 root netem
sudo ip netns exec node4 tc qdisc add dev veth7 root netem
sudo ip netns exec node4 tc qdisc add dev veth8 root netem
sudo ip netns exec node5 tc qdisc add dev veth9 root netem
sudo ip netns exec node5 tc qdisc add dev veth10 root netem
sudo ip netns exec node6 tc qdisc add dev veth11 root netem
sudo ip netns exec node6 tc qdisc add dev veth12 root netem
sudo ip netns exec node7 tc qdisc add dev veth13 root netem
sudo ip netns exec node7 tc qdisc add dev veth14 root netem


