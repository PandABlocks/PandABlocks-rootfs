#!/bin/bash
# Installs and extracts a GNU toolchain based on the systems architecture

GITHUB_WORKSPACE='/home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs'
PLATFORM=$1

# ARM GNU Toolchain
if [ "$PLATFORM" == "zynq" ]; 
then
    curl -o zynq-gnu-toolchain.tar.xz -L https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
    tar -xf zynq-gnu-toolchain.tar.xz
    rm zynq-gnu-toolchain.tar.xz
elif [ "$PLATFORM" == "zynqmp" ] 
then
    curl -o zynqmp-gnu-toolchain.tar.xz -L https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz
    tar -xf zynqmp-gnu-toolchain.tar.xz
    rm zynqmp-gnu-toolchain.tar.xz
fi