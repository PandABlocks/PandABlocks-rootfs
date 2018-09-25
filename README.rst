PandA Root File System
======================

This project builds a complete system image for booting PandA.  The following
components are built in turn:

* The U-Boot boot loader is built and assembled together with the Zynq stage-1
  boot loader.

* The Linux kernel is built.

* Two target root file systems are assembled: one for final system
  bootstrapping, one to act as the final system.


Build Dependencies
==================

The following must be installed before building this project:

* Xilinx Zynq SDK.

* U-Boot and Linux kernel sources.  This project requires the Xilinx branches of
  these projects.

* The Diamond rootfs builder.  This can be downloaded from
  https://github.com/araneidae/rootfs

* Sources needed for rootfs build.  This list is quite long, see below.


Configuring ``CONFIG``
----------------------

All of the build dependencies are configured in the file ``CONFIG``.  This
is designed to not be under version control.  Copy the file ``CONFIG.example``
and modify the following fields as required:

``PANDA_ROOT``:
    This is where the entire build occurs.  At least 2GB of storage must be free
    in this area.

``TAR_FILES``:
    All of the source files require to build the system will be looked for in
    this directory.  This can also be a list of directories if necessary.

``SDK_ROOT``:
    Location of the Xilinx SDK that will be used to build the system.

``ROOTFS_TOP``:
    This needs to point to the root directory of the Diamond rootfs builder,
    download from the github location given above.


Sources
-------

The rootfs requires a long list of dependencies that are freely available on the
web. They have been gathered together in one tar file here:

http://www.ohwr.org/attachments/download/5133/rootfs-tarfiles-0.6.tar

They consist of the following sources, listed below with their MD5 checksums::

    930d126df2113221e63c4ec4ce356f2c linux-xilinx-v2015.1.tar.gz
    b6d212208b7694f748727883eebaa74e u-boot-xlnx-xilinx-v2015.1.tar.gz

    82d05e03b93e45f5a39b828dc9c6c29b autoconf-2.69.tar.gz
    716946a105ca228ab545fc37a70df3a3 automake-1.15.tar.gz
    0b65a216ce9dc9c1a7e20a729dd7c05b backports_abc-0.4.tar.gz
    788214f20214c64631f0859dc79f23c6 backports.ssl_match_hostname-3.4.0.2.tar.gz
    7925683d7dd105aabe9b6b618d48cc73 busybox-1.23.2.tar.bz2
    bb13834970c468f73415618437f3feac conserver-8.2.0.tar.gz
    5d69a1b712fb8fec6ad461e676bf1097 cothread-2.14.tar.gz
    e967e320344cd4bfebe321e3ab8514d6 dropbear-2015.67.tar.bz2
    bc759fc62666786f5436e2075beb3265 e2fsprogs-1.42.13.tar.gz
    ac80f432ac9373e7d162834b264034b6 enum34-1.0.4.tar.gz
    3b2322695e9ee7bf447ebcdb85f93e83 ethtool-2.6.36.tar.gz
    5154c00201d599acc00194c6c278ca23 iperf-3.0.2.tar.gz
    277e4bd258fd4fb2aadaed760320c566 libressl-2.2.0.tar.gz
    addf44b646ddb4e3919805aa88fa7c5e libtool-2.4.6.tar.gz
    1b29c10db4aa88afcaeeaabeef6790db lsof_4.88.tar.bz2
    a5e9954b1dae036762f7b13673a2cf76 m4-1.4.17.tar.gz
    4ad1f758d49615efe14edb107eddac5c mtd-utils-1.5.1.tar.bz2
    1c612b478f976abf8ef926480c7a3684 nano-2.4.1.tar.gz
    8cb9c412e5f2d96bc6f459aa8c6282a1 ncurses-5.9.tar.gz
    fa37049383316322d060ec9061ac23a9 ntp-4.2.8p2.tar.gz
    a1ed53432dbcd256398898d35bc8e645 numpy-1.9.2.tar.gz
    aa3c86e67551adc3ac865160e34a2a0d pkg-config-0.28.tar.gz
    bbf052e7fcc6fa403d2514219346da04 procServ-2.6.0.tar.gz
    d7547558fd673bd9d38e2108c6b42521 Python-2.7.10.tgz
    33c8fb279e981274f485fd91da77e94a readline-6.3.tar.gz
    419a0594e2b25039239af8b90eda7d92 screen-4.2.1.tar.gz
    af2fc6a3d6cc5a02d0bf54d909785fcb singledispatch-3.4.0.3.tar.gz
    107a5be455493861189e9b57a3a51912 strace-4.10.tar.xz
    d13a99dc0b60ba69f5f8ec1235e5b232 tornado-4.3.tar.gz
    44d667c142d7cda120332623eab69f40 zlib-1.2.8.tar.gz

These packages are used as follows in the build:

autoconf, automake, libtool, m4, pkg-config:
    The rootfs builder needs specific and up to date versions of these tools.

busybox:
    The entire target system environment is run with busybox.

e2fsprogs, mtd-utils:
    These packages are needed by the initramfs bootstrap process.

dropbear, ntp:
    These provide fundamental target resources: dropbear provides an ssh server,
    ntp is used for accurate timestamps.

Python, enum34, libressl, numpy, cothread, ws4py:
    Python and a variety of supporting libraries will be used for running a
    number of system components.

conserver, procServ, screen:
    It is possible that these may be used for server management.

ethtool, iperf, lsof, strace, nano:
    These are useful debugging utilities, together with an easy to use editor.

ncurses, readline, zlib:
    These are all libraries used by some of the packages above.



Output Files
============

When built the following files are placed in ``$(BOOT_IMAGE)`` (see ``CONFIG``
to define this):

``boot.bin``:
    This file is loaded by the Zynq stage-0 boot loader and contains a standard
    stage 1 boot loader together with U-Boot, which acts as the stage-2 boot
    loader.

``uEnv.txt``:
    This is read by U-Boot to override a couple of default boot settings.

``uImage``:
    This is the Linux kernel image loaded by U-Boot.

``devicetree.dtb``:
    This is passed to the kernel to define the system hardware resources.

``uinitramfs``:
    This is the initial user-space system executed by the kernel.

``imagefile.cpio.gz``:
    This file will be used to prepare the initial state of the file system.

``config.txt``:
    This is designed to be user editable and contains network configuration
    settings.


Boot Process
============

The boot process is as follows:

0.  The stage-0 boot loader is hard wired into Zynq.  This loads ``boot.bin``
    from the SD card into memory and executes the next step.

1.  The stage-1 boot loader loads U-Boot from the ``boot.bin`` file.

2.  The stage-2 boot loader is U-Boot.  This loads the kernel into memory
    together with the device tree and initial ram filesystem image.

3.  The kernel initialises hardware resources and then prepares the initial file
    system image loaded from ``uinitramfs``.  The init script in this image is
    executed.

4.  The initial init script checks the configuration and prompts for a MAC
    address if necessary, and repartitions the SD card if necessary before
    uncompressing ``imagefile.cpio.gz`` onto the target system.

5.  Finally the target system is executed.
