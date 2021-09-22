#!/bin/bash

# This script is used to kick off a build from within a devcontainer
#
# to launch the dev container make sure your rootfs project is a cloned as a peer to
# this project and then run the following command:
#
# module load gcloud
# podman run --security-opt=label=type:container_runtime_t --rm -it -v $(pwd)/..:/workspaces gcr.io/diamond-pubreg/controls/devcontainers/pandablocks-rootfs:latest
#
# To update the devcontainer modify Dockerfile and rebuild with
# module load gcloud
# podman build --net=host -t gcr.io/diamond-pubreg/controls/devcontainers/pandablocks-rootfs .
# podman push gcr.io/diamond-pubreg/controls/devcontainers/pandablocks-rootfs


workspace=$(realpath $(pwd)/..)

echo "copying assets into workspace ..."
cp -r /tools/gcc* /tools/tar-files ..
sed s='$(GITHUB_WORKSPACE)'=${workspace}= /tools/PandABlocks-rootfs/CONFIG > CONFIG
sed s='$(GITHUB_WORKSPACE)'=${workspace}= /tools/rootfs/CONFIG.local > ../rootfs/CONFIG.local

make zips
