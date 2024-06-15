#!/bin/bash

for i in {1..8}; do
    ip netns del node$i
done
