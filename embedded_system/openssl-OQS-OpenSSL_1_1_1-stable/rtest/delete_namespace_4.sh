#!/bin/bash
# 参数设置

echo "删除命名空间"
ip netns delete node0
ip netns delete node1
ip netns delete node2
ip netns delete node3
echo "完成删除"
