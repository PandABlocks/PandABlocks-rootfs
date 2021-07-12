#!/bin/bash
# Installs all sources relevant to the rootfs build as tar files

GITHUB_WORKSPACE='/home/runner/work/PandABlocks-rootfs/PandABlocks-rootfs'

# Create the tar-files directory
mkdir $GITHUB_WORKSPACE/tar-files
cd $GITHUB_WORKSPACE/tar-files

# Install tar files
curl -O -L https://github.com/libffi/libffi/releases/tag/v3.3-rc2 \
     -O -L https://git.savannah.gnu.org/cgit/nano.git/snapshot/nano-2.4.1.tar.gz \
     -o cothread-2-18.tar.gz -L https://github.com/dls-controls/cothread/archive/refs/tags/2-18.tar.gz \
     -o zlib-1.2.8.tar.gz -L https://github.com/madler/zlib/archive/refs/tags/v1.2.8.tar.gz \
     -O -L https://git.kernel.org/pub/scm/network/ethtool/ethtool.git/snapshot/ethtool-2.6.36.tar.gz \
     -O -L https://infraroot.at/pub/mtd/mtd-utils-2.1.2.tar.bz2 \
     -O -L https://git.busybox.net/busybox/snapshot/busybox-1_23_2.tar.bz2 \
     -O -L https://github.com/ralphlange/procServ/releases/download/V2.6.1-rc1/procServ-2.6.1-rc1.tar.gz \
     -o procServ-2.6.0.tar.gz -L https://github.com/ralphlange/procServ/archive/refs/tags/V2.6.0.tar.gz \
     -o autoconf-2.69.tar.gz -L https://github.com/autotools-mirror/autoconf/archive/refs/tags/v2.69.tar.gz \
     -o e2fsprogs-1.46.2.tar.gz -L https://github.com/tytso/e2fsprogs/archive/refs/tags/v1.46.2.tar.gz \
     -O -L https://github.com/numpy/numpy/releases/download/v1.17.5/numpy-1.17.5.tar.gz \
     -O -L http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz \
     -O -L https://matt.ucc.asn.au/dropbear/releases/dropbear-2015.67.tar.bz2 \
     -O -L http://git.savannah.gnu.org/cgit/readline.git/snapshot/readline-6.3.tar.gz \
     -O -L https://git.busybox.net/busybox/snapshot/busybox-1_33_1.tar.bz2 \
     -o tornado-6.0.3.tar.gz -L https://github.com/tornadoweb/tornado/archive/refs/tags/v6.0.3.tar.gz \
     -O -L http://git.savannah.gnu.org/cgit/automake.git/snapshot/automake-1.15.tar.gz \
     -o Python-3.8.0.tgz -L https://github.com/python/cpython/archive/refs/tags/v3.8.0.tar.gz \
     -o libressl-3.0.2.tar.gz -L https://github.com/libressl-portable/portable/archive/refs/tags/v3.0.2.tar.gz \
     -o m4-1.4.18.tar.gz -L https://github.com/tar-mirror/gnu-m4/archive/refs/tags/v1.4.18.tar.gz \
     -O -L https://files.pythonhosted.org/packages/11/0a/7f13ef5cd932a107cd4c0f3ebc9d831d9b78e1a0e8c98a098ca17b1d7d97/setuptools-41.6.0.zip \
     -O -L https://snapshot.debian.org/archive/debian/20140303T040015Z/pool/main/i/i2c-tools/i2c-tools_3.1.1.orig.tar.bz2 \
     -O -L https://ftp.gnu.org/gnu/screen/screen-4.2.1.tar.gz \
     -O -L https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz \
     -o ncurses-6.1.tar.gz -L https://github.com/mirror/ncurses/archive/refs/tags/v6.1.tar.gz \
     -O -L https://gitlab.freedesktop.org/pkg-config/pkg-config/-/archive/pkg-config-0.28/pkg-config-pkg-config-0.28.tar.gz \
     -o u-boot-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/u-boot-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz \
     -o linux-xlnx-xilinx-v2020.2.2-k26.tar.gz -L https://github.com/Xilinx/linux-xlnx/archive/refs/tags/xilinx-v2020.2.2-k26.tar.gz