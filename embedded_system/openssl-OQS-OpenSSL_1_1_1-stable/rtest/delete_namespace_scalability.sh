#!/bin/bash
# 参数设置

echo "删除命名空间"
ip netns delete server_namespace1
ip netns delete server_namespace2
ip netns delete client_namespace
echo "完成删除"
