#!/bin/bash
# Installs all sources relevant to the rootfs build as tar files

# Create the tar-files directory
mkdir tar-files
cd tar-files

# Install tar files
curl -OL https://github.com/libffi/libffi/releases/download/v3.3-rc2/libffi-3.3-rc2.tar.gz \
     -OL https://ftp.gnu.org/gnu/nano/nano-2.4.1.tar.gz \
     -o cothread-2-18.tar.gz -L https://github.com/dls-controls/cothread/archive/refs/tags/2-18.tar.gz \
     -OL https://zlib.net/fossils/zlib-1.2.8.tar.gz \
     -o ethtool-2.6.36.tar.gz -L https://sourceforge.net/projects/gkernel/files/ethtool/2.6.36/ethtool-2.6.36.tar.gz/download \
     -OL https://infraroot.at/pub/mtd/mtd-utils-2.1.2.tar.bz2 \
     -OL https://busybox.net/downloads/busybox-1.23.2.tar.bz2 \
     -OL https://github.com/ralphlange/procServ/releases/download/V2.6.1-rc1/procServ-2.6.1-rc1.tar.gz \
     -o procServ-2.6.0.tar.gz -L https://sourceforge.net/projects/procserv/files/2.6.0/procServ-2.6.0.tar.gz/download \
     -OL https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz \
     -OL https://fossies.org/linux/misc/legacy/e2fsprogs-1.46.2.tar.gz \
     -OL https://github.com/numpy/numpy/releases/download/v1.17.5/numpy-1.17.5.tar.gz \
     -OL http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz \
     -OL https://matt.ucc.asn.au/dropbear/releases/dropbear-2015.67.tar.bz2 \
     -OL https://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz \
     -OL https://busybox.net/downloads/busybox-1.33.1.tar.bz2 \
     -o tornado-6.0.3.tar.gz -L https://github.com/tornadoweb/tornado/archive/refs/tags/v6.0.3.tar.gz \
     -OL https://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz \
     -OL https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz \
     -OL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.0.2.tar.gz \
     -OL https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz \
     -OL https://files.pythonhosted.org/packages/11/0a/7f13ef5cd932a107cd4c0f3ebc9d831d9b78e1a0e8c98a098ca17b1d7d97/setuptools-41.6.0.zip \
     -OL http://jdelvare.nerim.net/mirror/i2c-tools/i2c-tools-3.1.1.tar.bz2 \
     -OL https://ftp.gnu.org/gnu/screen/screen-4.2.1.tar.gz \
     -OL https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz \
     -OL https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz \
     -OL https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz \
     -o u-boot-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz \
     -o linux-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz

# Adjust checksums to the new versioned packages (temporary)
cd ../rootfs/scripts/makefiles
# Addressed bug encountered with v1.4.18 (Bug: "Please port gnulib freadahead.c to your platform!")
# sed -i 's/3b53feb7063fea08ed47e874ac5ce802/f4a2b0284d80353b995f8ef2385ed73c/g' TOOLKIT_DEFS #v1.4.19
sed -i 's/3b53feb7063fea08ed47e874ac5ce802/a077779db287adf4e12a035029002d28/g' TOOLKIT_DEFS # v1.4.18
# sed -i 's/1.4.18/1.4.19/g' TOOLKIT_DEFS