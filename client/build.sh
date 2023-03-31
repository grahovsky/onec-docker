#!/bin/bash
PLATFORM_VERSION=$(find ../distr -name 'server*.tar.gz' | grep -Po '\d+(\.\d+){3}')

docker build --tag alse-1c-client:latest \
    --build-arg baseImage=alse:latest \
    --build-arg PLATFORM_VERSION=${PLATFORM_VERSION} \
    -f ./Dockerfile \
    $1 -- ..