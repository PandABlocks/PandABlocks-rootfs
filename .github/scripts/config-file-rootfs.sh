#!/bin/bash
# Generates and populates CONFIG file for rootfs repo.

cat >> rootfs/CONFIG.local << 'EOL'
TARGET = minimal

# This is the location where source and build files will be placed.
ROOTFS_ROOT = $(GITHUB_WORKSPACE)/build

# This is where all of the source tar files will be found.
TAR_DIRS = $(GITHUB_WORKSPACE)/tar-files
EOL
