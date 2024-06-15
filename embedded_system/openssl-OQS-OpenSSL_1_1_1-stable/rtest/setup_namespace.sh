#!/bin/bash

# 参数设置

# SERVER_VT_ADDR="00:00:00:00:00:01"
# CLIENT_VT_ADDR="00:00:00:00:00:02"



# ip link add name $SERVER_VT address $SERVER_VT_ADDR netns $SERVER_NS type veth peer name $CLIENT_VT address $CLIENT_VT_ADDR  netns $CLIENT_NS

# ip netns exec $SERVER_NS ip link set dev $SERVER_VT up
# ip netns exec $SERVER_NS ip link set dev lo up
# ip netns exec $SERVER_NS ip addr add $SERVER_IP/$NETMASK dev $SERVER_VT

# ip netns exec $CLIENT_NS ip link set dev $CLIENT_VT up
# ip netns exec $CLIENT_NS ip link set dev lo up
# ip netns exec $CLIENT_NS ip addr add $CLIENT_IP/$NETMASK dev $CLIENT_VT



# ip netns exec $CLIENT_NS ethtool -K $CLIENT_VT gso off gro off tso off

# ip netns exec $SERVER_NS ethtool -K $SERVER_VT gso off gro off tso off

# ip netns exec $CLIENT_NS tc qdisc add dev $CLIENT_VT root netem
# ip netns exec $SERVER_NS tc qdisc add dev $SERVER_VT root netem

SERVER_NS="server_namespace"
CLIENT_NS="client_namespace"
SERVER_IP="192.168.1.1"
CLIENT_IP="192.168.1.2"
NETMASK="24"
SERVER_VT='server_veth'
CLIENT_VT='client_veth'


echo "创建命名空间：$SERVER_NS"
ip netns add $SERVER_NS
echo "创建命名空间：$CLIENT_NS"
ip netns add $CLIENT_NS
echo "创建虚拟以太网设备：$SERVER_VT 和 $CLIENT_VT"
ip link add $SERVER_VT type veth peer name $CLIENT_VT

echo "将虚拟设备连接到相应的命名空间"
ip link set $SERVER_VT netns $SERVER_NS
ip link set $CLIENT_VT netns $CLIENT_NS

echo "为每个命名空间分配 IP 地址"
ip netns exec $SERVER_NS ip addr add $SERVER_IP/$NETMASK dev $SERVER_VT
ip netns exec $CLIENT_NS ip addr add $CLIENT_IP/$NETMASK dev $CLIENT_VT

echo "启用 IP 转发"
sysctl -w net.ipv4.ip_forward=1

echo "启动虚拟设备"
ip netns exec $SERVER_NS ip link set dev lo up
ip netns exec $SERVER_NS ip link set dev $SERVER_VT up
ip netns exec $CLIENT_NS ip link set dev lo up
ip netns exec $CLIENT_NS ip link set dev $CLIENT_VT up

echo "添加路由"
ip netns exec $SERVER_NS ip route add default via $CLIENT_IP dev $SERVER_VT
ip netns exec $CLIENT_NS ip route add default via $SERVER_IP dev $CLIENT_VT

echo "客户端添加队列"
sudo ip netns exec $CLIENT_NS tc qdisc add dev $CLIENT_VT root netem
echo "服务器添加队列"
sudo ip netns exec $SERVER_NS tc qdisc add dev $SERVER_VT root netem
echo "完成设置"
