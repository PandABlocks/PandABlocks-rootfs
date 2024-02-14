#!/bin/bash
# Installs all sources relevant to the rootfs build as tar files

# Enter the tar-files directory
mkdir /tar-files 
cd /tar-files

# If no argument is given
if [[ -z $1 ]]; then
    # Install tar file rootfs dependencies
    curl -OL https://github.com/libffi/libffi/releases/download/v3.3-rc2/libffi-3.3-rc2.tar.gz \
        -o cothread-2-18.tar.gz -L https://github.com/dls-controls/cothread/archive/refs/tags/2-18.tar.gz \
        -OL https://zlib.net/fossils/zlib-1.2.8.tar.gz \
        -OL https://www.netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2 \
        -OL https://mirrors.edge.kernel.org/pub/software/network/ethtool/ethtool-6.3.tar.gz \
        -OL https://infraroot.at/pub/mtd/mtd-utils-2.1.2.tar.bz2 \
        -OL https://busybox.net/downloads/busybox-1.23.2.tar.bz2 \
        -OL https://github.com/ralphlange/procServ/releases/download/v2.8.0/procServ-2.8.0.tar.gz \
        -OL https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz \
        -OL https://qa.debian.org/watch/sf.php/e2fsprogs/e2fsprogs-1.46.2.tar.gz \
        -OL https://github.com/numpy/numpy/releases/download/v1.17.5/numpy-1.17.5.tar.gz \
        -OL http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz \
        -OL https://mirror.dropbear.nl/mirror/releases/dropbear-2022.83.tar.bz2 \
        -OL https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz \
        -OL https://busybox.net/downloads/busybox-1.36.1.tar.bz2 \
        -o tornado-6.0.3.tar.gz -L https://github.com/tornadoweb/tornado/archive/refs/tags/v6.0.3.tar.gz \
        -OL https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz \
        -OL https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz \
        -OL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.0.2.tar.gz \
        -OL https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz \
        -OL https://files.pythonhosted.org/packages/11/0a/7f13ef5cd932a107cd4c0f3ebc9d831d9b78e1a0e8c98a098ca17b1d7d97/setuptools-41.6.0.zip \
        -OL https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz \
        -OL https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz \
        -OL https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz

fi

# Install tar file dependencies
curl -o u-boot-xlnx-xilinx-v2022.2.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2022.2.tar.gz \
    -o u-boot-xlnx-xilinx-v2023.2.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2023.2.tar.gz \
    -o linux-xlnx-xilinx-v2022.2.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2022.2.tar.gz \
    -o linux-xlnx-xilinx-v2023.2.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2023.2.tar.gz \
    -o device-tree-xlnx-xilinx_v2022.2.tar.gz -L https://github.com/Xilinx/device-tree-xlnx/archive/refs/tags/xilinx_v2022.2.tar.gz \
    -o device-tree-xlnx-xilinx_v2023.2.tar.gz -L https://github.com/Xilinx/device-tree-xlnx/archive/refs/tags/xilinx_v2023.2.tar.gz \
    -o arm-trusted-firmware-xilinx-v2022.2.tar.gz -L https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/xilinx-v2022.2.tar.gz \
    -o arm-trusted-firmware-xilinx-v2023.2.tar.gz -L https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/xilinx-v2023.2.tar.gz \
    -o dtc-1.7.0.tar.gz -L https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-1.7.0.tar.gz

# Old url to i2c-tools tar file. No longer working
# -OL http://jdelvare.nerim.net/mirror/i2c-tools/i2c-tools-3.1.1.tar.bz2 \

