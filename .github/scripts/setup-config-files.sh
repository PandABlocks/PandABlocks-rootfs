# !/bin/bash
# Generates config files in PandABlocks-rootfs and rootfs repositories and populates them with information.

# PandABlocks-rootfs:
CONFIG_PANDABLOCKS-ROOTFS = "
# Location of rootfs builder
ROOTFS_TOP = ${{ github.workspace }}/rootfs

# Toolchain used to build the target
TOOLCHAIN_ROOT = ${{ github.workspace }}/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf

# Where to find source files
TAR_FILES = ${{ github.workspace }}/tar-files

# Target location for build
PANDA_ROOT = ${{ github.workspace }}/build

# Whether the platform is zynq or zyqnmp
PLATFORM = zynq"

# Create and populate the CONFIG file
cd ${{ github.workspace }}/pandABlocks-rootfs
touch CONFIG
echo CONFIG_PANDABLOCKS-ROOTFS > CONFIG

# rootfs:
CONFIG_ROOTFS = "
TARGET = minimal

# This is the location where source and build files will be placed.
ROOTFS_ROOT = ${{ github.workspace }}/build

# This is where all of the source tar files will be found.
TAR_DIRS = ${{ github.workspace }}/tar-files"

# Create and populate the CONFIG file
cd ${{ github.workspace }}/rootfs
touch CONFIG.local
echo CONFIG_ROOTFS > CONFIG.local
