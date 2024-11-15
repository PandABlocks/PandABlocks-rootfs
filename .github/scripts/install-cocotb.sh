#!/usr/bin/env bash
export PATH=$PATH:/usr/bin:/usr/sbin
cd /tmp && \
git clone -b "elab-args" https://github.com/jacob720/cocotb && \
cd cocotb
python3.12 -m pip install .