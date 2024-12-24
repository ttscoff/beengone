#!/bin/bash

cd $(git rev-parse --show-toplevel)
xcodebuild -scheme beengone -target beengone -arch x86_64 -arch arm64 build