#!/bin/sh
TMP=/tmp/rootfs-version
mkdir -p $TMP
cd $TMP
gunzip -c $1 | cpio -d -i etc/version
cat $TMP/etc/version
rm -rf $TMP
