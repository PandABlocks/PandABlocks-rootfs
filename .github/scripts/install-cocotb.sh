#!/usr/bin/env bash
export PATH=$PATH:/usr/bin:/usr/sbin
cd /tmp && \
git clone https://github.com/cocotb/cocotb && \
cd cocotb && \
git reset --hard 6649d76
python3 -m pip install .