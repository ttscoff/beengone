#!/bin/bash

cd $(git rev-parse --show-toplevel)/build/Debug

for l in $(seq 1 15); do
    ./beengone
    sleep 1
done

