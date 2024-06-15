SERVER_NS1="server_namespace1"
SERVER_NS2="server_namespace2"
CLIENT_NS="client_namespace"
SERVER_IP1="192.168.1.1"
SERVER_IP2="192.168.1.2"
CLIENT_IP1="192.168.1.3"
CLIENT_IP2="192.168.1.4"
NETMASK="24"
SERVER_VT1='server_veth1'
SERVER_VT2='server_veth2'
CLIENT_VT1='client_veth1'
CLIENT_VT2='client_veth2'
SERVER_VT_ADDR1="00:00:00:00:00:01"
SERVER_VT_ADDR2="00:00:00:00:00:02"
CLIENT_VT_ADDR1="00:00:00:00:00:03"
CLIENT_VT_ADDR2="00:00:00:00:00:04"
echo "创建命名空间：$SERVER_NS1"
ip netns add $SERVER_NS1
echo "创建命名空间：$SERVER_NS2"
ip netns add $SERVER_NS2
echo "创建命名空间：$CLIENT_NS"
ip netns add $CLIENT_NS
echo "创建虚拟以太网设备：$SERVER_VT1 和 $CLIENT_VT1"
ip link add $SERVER_VT1 address $SERVER_VT_ADDR1 type veth peer name $CLIENT_VT1 address $CLIENT_VT_ADDR1
echo "创建虚拟以太网设备：$SERVER_VT2 和 $CLIENT_VT2"
ip link add $SERVER_VT2 address $SERVER_VT_ADDR2 type veth peer name $CLIENT_VT2 address $CLIENT_VT_ADDR2
echo "将虚拟设备连接到相应的命名空间"
ip link set $SERVER_VT1 netns $SERVER_NS1
ip link set $SERVER_VT2 netns $SERVER_NS2
ip link set $CLIENT_VT1 netns $CLIENT_NS
ip link set $CLIENT_VT2 netns $CLIENT_NS

echo "为每个命名空间分配 IP 地址"
ip netns exec $SERVER_NS1 ip addr add $SERVER_IP1/$NETMASK dev $SERVER_VT1
ip netns exec $SERVER_NS2 ip addr add $SERVER_IP2/$NETMASK dev $SERVER_VT2
echo "启动虚拟设备"
ip netns exec $SERVER_NS1 ip link set dev $SERVER_VT1 up
ip netns exec $SERVER_NS2 ip link set dev $SERVER_VT2 up

ip netns exec $CLIENT_NS ip addr add $CLIENT_IP1/$NETMASK dev $CLIENT_VT1
ip netns exec $CLIENT_NS ip addr add $CLIENT_IP2/$NETMASK dev $CLIENT_VT2
ip netns exec $CLIENT_NS ip link set dev $CLIENT_VT1 up
ip netns exec $CLIENT_NS ip link set dev $CLIENT_VT2 up
echo "启用 IP 转发"
sysctl -w net.ipv4.ip_forward=1
echo "添加路由"
echo "添加路由"
ip netns exec $SERVER_NS1 ip route add $CLIENT_IP1 via $SERVER_IP1
ip netns exec $SERVER_NS2 ip route add $CLIENT_IP2 via $SERVER_IP2
ip netns exec $CLIENT_NS ip route add $SERVER_IP1 via $CLIENT_IP1
ip netns exec $CLIENT_NS ip route add $SERVER_IP2 via $CLIENT_IP2

echo "客户端添加队列"
sudo ip netns exec $CLIENT_NS tc qdisc add dev $CLIENT_VT1 root netem
echo "服务器添加队列"
sudo ip netns exec $SERVER_NS1 tc qdisc add dev $SERVER_VT1 root netem
echo "客户端添加队列"
sudo ip netns exec $CLIENT_NS tc qdisc add dev $CLIENT_VT2 root netem
echo "服务器添加队列"
sudo ip netns exec $SERVER_NS2 tc qdisc add dev $SERVER_VT2 root netem
echo "完成设置"
