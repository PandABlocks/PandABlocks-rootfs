#!/bin/bash

wsdir=$(realpath $(dirname ${BASH_SOURCE[0]})/..)

# remove previous build artifacts
for i in tar-files build gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu ; do
    if [ -d ${wsdir}/$i ]; then
        echo "removing ${wsdir}/$i ..."
        chmod +w -R ${wsdir}/$i
        rm -rf ${wsdir}/$i
    fi
done