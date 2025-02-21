#!/usr/bin/env bash
export PATH=$PATH:/usr/bin:/usr/sbin
cd /tmp && \
git clone -b "r1.14.0" https://github.com/nickg/nvc && \
cd nvc && \
./autogen.sh && \
mkdir build && \
cd build && \
../configure --with-llvm=/usr/bin/llvm-config --prefix=/usr && \
make && \
make install && \
cd && \
rm -rf /tmp/nvc
