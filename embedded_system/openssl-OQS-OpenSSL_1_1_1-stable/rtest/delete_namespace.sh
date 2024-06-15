#!/bin/bash

# 参数设置
SERVER_NS="server_namespace"
CLIENT_NS="client_namespace"

echo "删除命名空间"
ip netns delete $SERVER_NS
ip netns delete $CLIENT_NS

echo "完成删除"
