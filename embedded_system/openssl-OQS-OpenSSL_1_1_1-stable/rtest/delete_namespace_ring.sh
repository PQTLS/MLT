#!/bin/bash

# 删除5个命名空间
for i in {0..8}; do
    ip netns del node$i
done
