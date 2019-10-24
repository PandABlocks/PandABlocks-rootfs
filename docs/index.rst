PandABlocks-rootfs
==================

PandABlocks-rootfs contains the sources to build the root filesystem that
will boot Linux on the Zynq module that is the heart of a PandABlocks enabled
device like PandABox.

What does the rootfs do?
------------------------

The rootfs is responsible for booting the Zynq, then setting up a number of
services on it:

- Bringing up the network as specified in a config.txt file on the SD card
- Running an SSH server that allows debugging access to those who have their
  public keys on the PandA
- Programming the FPGA and running services like the TCP server and Web Control
  as specified in packages
- Running a Web Admin server on port 80 that allows ZPG files to allow the
  installation and removal of packages, and addition of SSH keys from the USB
  stick

How is the documentation structured?
------------------------------------

The documentation is structured into a `quickstart_doc` guide that will
get the PandA on the network, a `ssh_doc` guide, and a `building_doc` guide
that will allow the rootfs to be rebuilt from source.
