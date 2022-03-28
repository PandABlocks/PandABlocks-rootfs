#!/bin/bash

# Put in own dir
# Installs and extracts a GNU toolchains for both systems architectures
# ARM GNU Toolchains
TOOLCHAIN_ZYNQ=https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
TOOLCHAIN_ZYNQMP=https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz

# Download and extract both toolchains
curl -o toolchain-zynq.tar.xz -L $TOOLCHAIN_ZYNQ
curl -o toolchain-zynqmp.tar.xz -L $TOOLCHAIN_ZYNQMP

tar -xf toolchain-zynq.tar.xz
tar -xf toolchain-zynqmp.tar.xz

rm toolchain-zynq.tar.xz
rm toolchain-zynqmp.tar.xz
