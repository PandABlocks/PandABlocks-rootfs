#!/bin/bash
# Generates and populates CONFIG file for PandABlocks-rootfs repo.

PLATFORM=$1

# Determine the toolchain to use
if [ "$PLATFORM" == "zynq" ]; then
    TOOLCHAIN=gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf
elif [ "$PLATFORM" == "zynqmp" ]; then
    TOOLCHAIN=gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu
fi

cat >> PandABlocks-rootfs/CONFIG << 'EOL'
# Location of rootfs builder
ROOTFS_TOP = $(GITHUB_WORKSPACE)/rootfs

# Where to find source files
TAR_FILES = $(GITHUB_WORKSPACE)/tar-files

# Target location for build
PANDA_ROOT = $(GITHUB_WORKSPACE)/build

EOL

cat >> PandABlocks-rootfs/CONFIG << EOL
# Toolchain used to build the target
TOOLCHAIN_ROOT = $(GITHUB_WORKSPACE)/$TOOLCHAIN

# Whether the platform is zynq or zyqnmp
PLATFORM = $PLATFORM

EOL
