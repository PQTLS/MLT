#!/bin/bash

for i in {0..7}; do
    ip netns del node$i
done
