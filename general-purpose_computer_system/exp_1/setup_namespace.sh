#!/bin/bash

SERVER_NS="server_namespace"
CLIENT_NS="client_namespace"
SERVER_IP="192.168.1.1"
CLIENT_IP="192.168.1.2"
NETMASK="24"
SERVER_VT='server_veth'
CLIENT_VT='client_veth'

echo "Creating namespaces: $SERVER_NS"
ip netns add $SERVER_NS
echo "Creating namespaces: $CLIENT_NS"
ip netns add $CLIENT_NS

echo "Creating virtual Ethernet devices: $SERVER_VT and $CLIENT_VT"
ip link add $SERVER_VT type veth peer name $CLIENT_VT

echo "Connecting virtual devices to their respective namespaces"
ip link set $SERVER_VT netns $SERVER_NS
ip link set $CLIENT_VT netns $CLIENT_NS

echo "Assigning IP addresses to each namespace"
ip netns exec $SERVER_NS ip addr add $SERVER_IP/$NETMASK dev $SERVER_VT
ip netns exec $CLIENT_NS ip addr add $CLIENT_IP/$NETMASK dev $CLIENT_VT

echo "Enabling IP forwarding"
sysctl -w net.ipv4.ip_forward=1

echo "Starting virtual devices"
ip netns exec $SERVER_NS ip link set dev lo up
ip netns exec $SERVER_NS ip link set dev $SERVER_VT up
ip netns exec $CLIENT_NS ip link set dev lo up
ip netns exec $CLIENT_NS ip link set dev $CLIENT_VT up

echo "Adding routes"
ip netns exec $SERVER_NS ip route add default via $CLIENT_IP dev $SERVER_VT
ip netns exec $CLIENT_NS ip route add default via $SERVER_IP dev $CLIENT_VT

echo "Adding queue on client side"
sudo ip netns exec $CLIENT_NS tc qdisc add dev $CLIENT_VT root netem
echo "Adding queue on server side"
sudo ip netns exec $SERVER_NS tc qdisc add dev $SERVER_VT root netem

echo "Setup completed"
