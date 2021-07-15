#!/bin/bash
# Generates config files in PandABlocks-rootfs and rootfs repositories and populates them with information.

GITHUB_WORKSPACE='/home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs'
PLATFORM=$1

# PandABlocks-rootfs:
# Create the CONFIG file
cd $GITHUB_WORKSPACE/pandABlocks-rootfs
touch CONFIG
# Populate the CONFIG file
if [ "$PLATFORM" == "zynq" ]; 
then
cat >> CONFIG <<EOL
# Location of rootfs builder
ROOTFS_TOP = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/rootfs

# Toolchain used to build the target
TOOLCHAIN_ROOT = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf

# Where to find source files
TAR_FILES = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/tar-files

# Target location for build
PANDA_ROOT = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/build

# Whether the platform is zynq or zyqnmp
PLATFORM = zynq
EOL
elif [ "$PLATFORM" == "zynqmp" ]
then
cat >> CONFIG <<EOL
# Location of rootfs builder
ROOTFS_TOP = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/rootfs

# Toolchain used to build the target
TOOLCHAIN_ROOT = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu

# Where to find source files
TAR_FILES = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/tar-files

# Target location for build
PANDA_ROOT = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/build

# Whether the platform is zynq or zyqnmp
PLATFORM = zynqmp
EOL
fi

# rootfs:
# Create the CONFIG file
cd $GITHUB_WORKSPACE/rootfs
touch CONFIG.local
# Populate the CONFIG file
cat >> CONFIG.local <<EOL
TARGET = minimal

# This is the location where source and build files will be placed.
ROOTFS_ROOT = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/build

# This is where all of the source tar files will be found.
TAR_DIRS = /home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs/tar-files
EOL
