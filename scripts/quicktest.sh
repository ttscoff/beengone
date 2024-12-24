#!/bin/bash

cd $(git rev-parse --show-toplevel)/build/Debug

for l in $(seq 1 15); do
    ./beengone
    if [ $l == 5 ]; then
        ./beengone -i
    fi
    sleep 1
done

