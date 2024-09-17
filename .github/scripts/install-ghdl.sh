#!/usr/bin/env bash

cd /tmp
git clone -b 'v4.0.0' https://github.com/ghdl/ghdl
cd ghdl
./configure --prefix=/usr/local
make
make install
cd
rm -r /tmp/ghdl
