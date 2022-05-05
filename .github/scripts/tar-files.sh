#!/bin/bash
# Installs all sources relevant to the rootfs build as tar files

# Enter the tar-files directory
mkdir /tar-files 
cd /tar-files

# If no argument is given
if [[ -z $1 ]]; then
    # Install tar file rootfs dependencies
    curl -OL https://github.com/libffi/libffi/releases/download/v3.3-rc2/libffi-3.3-rc2.tar.gz \
        -OL https://ftp.gnu.org/gnu/nano/nano-2.4.1.tar.gz \
        -o cothread-2-18.tar.gz -L https://github.com/dls-controls/cothread/archive/refs/tags/2-18.tar.gz \
        -OL https://zlib.net/fossils/zlib-1.2.8.tar.gz \
        -OL https://src.fedoraproject.org/repo/pkgs/ethtool/ethtool-2.6.36.tar.gz/3b2322695e9ee7bf447ebcdb85f93e83/ethtool-2.6.36.tar.gz \
        -OL https://infraroot.at/pub/mtd/mtd-utils-2.1.2.tar.bz2 \
        -OL https://busybox.net/downloads/busybox-1.23.2.tar.bz2 \
        -OL http://kmq.jp.distfiles.macports.org/procServ/procServ-2.6.0.tar.gz \
        -OL https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz \
        -OL https://qa.debian.org/watch/sf.php/e2fsprogs/e2fsprogs-1.46.2.tar.gz \
        -OL https://github.com/numpy/numpy/releases/download/v1.17.5/numpy-1.17.5.tar.gz \
        -OL http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz \
        -OL https://matt.ucc.asn.au/dropbear/releases/dropbear-2015.67.tar.bz2 \
        -OL https://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz \
        -OL https://busybox.net/downloads/busybox-1.33.1.tar.bz2 \
        -o tornado-6.0.3.tar.gz -L https://github.com/tornadoweb/tornado/archive/refs/tags/v6.0.3.tar.gz \
        -OL https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz \
        -OL https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz \
        -OL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.0.2.tar.gz \
        -OL https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz \
        -OL https://files.pythonhosted.org/packages/11/0a/7f13ef5cd932a107cd4c0f3ebc9d831d9b78e1a0e8c98a098ca17b1d7d97/setuptools-41.6.0.zip \
        -OL http://oe-lite.org/mirror/i2c-tools/i2c-tools-3.1.1.tar.bz2 \
        -OL https://ftp.gnu.org/gnu/screen/screen-4.2.1.tar.gz \
        -OL https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz \
        -OL https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz \
        -OL https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz

fi

# Install linux tar file dependencies
curl -o u-boot-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz \
    -o linux-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz

# Install tar file dependencies for PandAblocks-FPGA 
curl -o device-tree-xlnx-xilinx-v2020.2.tar.gz -L https://github.com/Xilinx/device-tree-xlnx/archive/refs/tags/xilinx-v2020.2.tar.gz \
    -o u-boot-xlnx-xilinx-v2020.2.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2020.2.tar.gz \
    -o arm-trusted-firmware-xilinx-v2020.2.tar.gz -L https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/xilinx-v2020.2.tar.gz \
    -o dtc-1.6.1.tar.gz -L https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-1.6.1.tar.gz

# Old url to i2c-tools tar file. No longer working
# -OL http://jdelvare.nerim.net/mirror/i2c-tools/i2c-tools-3.1.1.tar.bz2 \

# 2021.1 tar files
curl -o u-boot-xlnx-xilinx-v2021.1.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2021.1.tar.gz \
    -o linux-xlnx-xilinx-v2021.1.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2021.1.tar.gz


 curl -o device-tree-xlnx-xilinx_v2021.1.tar.gz -L https://github.com/Xilinx/device-tree-xlnx/archive/refs/tags/xilinx_v2021.1.tar.gz \
    -o u-boot-xlnx-xilinx-v2021.1.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2021.1.tar.gz \
    -o arm-trusted-firmware-xlnx_rebase_v2.4_2021.1.tar.gz -L https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/xlnx_rebase_v2.4_2021.1.tar.gz \
#    -o dtc-1.6.1.tar.gz -L https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-1.6.1.tar.gz  