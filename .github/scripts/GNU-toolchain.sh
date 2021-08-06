#!/bin/bash
# Installs and extracts a GNU toolchain based on the systems architecture

PLATFORM=$1

# ARM GNU Toolchain
# Determine which toolchain to use
if [ "$PLATFORM" == "zynq" ]; 
    then
    TOOLCHAIN=https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
elif [ "$PLATFORM" == "zynqmp" ] 
    then
    TOOLCHAIN=https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz
fi

# Download and extract toolchain
curl -o toolchain.tar.xz -L $TOOLCHAIN
tar -xf toolchain.tar.xz
rm toolchain.tar.xz
