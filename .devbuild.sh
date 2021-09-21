# This script is used to kick off a build from within a devcontainer
#
# to launch the dev container make sure your rootfs project is a peer to
# this project and then run the following command:
#
# docker run -it -v $(pwd)/..:/workspace ghcr.io/pandablocks/dev-pandablocks-rootfs:latest
#
# TODO verify above volume and image addr once image is published
#

cd /workspace

mv /tools/gcc* /tools/tar-files .
sed s='$(GITHUB_WORKSPACE)'='/workspace'= /tools/PandABlocks-rootfs/CONFIG > PandABlocks-rootfs/CONFIG
sed s='$(GITHUB_WORKSPACE)'='/workspace'= /tools/rootfs/CONFIG.local > rootfs/CONFIG.local

cd PandABlocks-rootfs
make zips
