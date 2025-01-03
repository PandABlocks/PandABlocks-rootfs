.. _ssh_doc:

Updating a PandA via SSH
========================

The Admin interface of the PandA can be used to update the firmware as detailed
in the _web_doc, but sometimes it is necessary to update a number of
PandAs at once. The SSH interface can be used to do this.

To gain access over SSH, either add an ``authorized_keys`` file to the SD card,
or load it from USB via the Admin interface.

It is then possible to log in remotely and perform operations on the PandA.

.. warning::

    PandA only has a single user; root, and remote access is done as this user.
    Root has privileges to break the system, so be careful when running the
    commands below.

First update rootfs and then, after a reboot, update to the latest available zpkg 
packages (while making sure to match the major versions of everything).

Updating the rootfs
-------------------

Download a new ``boot-x.x.zip`` file from GitHub_ and unzip it somewhere. You
can then::

    $ md5sum boot/imagefile.cpio.gz
    $ scp boot/* root@my_panda_ip:/boot
    $ ssh root@my_panda_ip
    # sync
    # md5sum /boot/imagefile.cpio.gz


If the two md5 sums match it has copied correctly. Within /boot you should find::
    - boot.scr
    - uImage
    - boot.bin
    - devicetree.dtb
    - uinitramfs

.. note::
    For PandA v3.0 and beyond boot.bin and devicetree.dtb now come from the PandABlocks-FPGA build
    but are combined in the ``boot-x.x.zip`` on the rootfs release page.

You can power cycle the box and it will install the new rootfs.


Updating zpkg packages
----------------------

A PandA firmware installation consists of 4 Zpkgs:
    - panda-fpga\@*.zpg
    - panda-server\@*.zpg
    - panda-webcontrol\@*.zpg
    - panda-slowfpga\@*.zpg (PandA 3.0 onwards)

Download new zpkg files from GitHub_, then::

    $ scp *.zpg root@my_panda_ip:/tmp
    $ ssh root@my_panda_ip
    # zpkg install /tmp/*.zpg

This will install the new versions of the appropriate packages, and restart the services
on the box to use them. From the PandA 3.0 release and beyond, a new zpkg file will be 
needed: panda-slowfpga\@*.zpg.

.. note::

    Release 1.0 of the rootfs contained a bug which means that if 1.0 or later
    versions of the FPGA zpkg were installed, then any subsequent installations
    of the FPGA zpkg with **ANY** version of the rootfs would fail with 
    message::

        File lib/python2.7/site-packages/malcolm/modules/web/www/fpga_docs already exists

    Once you have seen this error, run::

        rm /opt/lib/python2.7/site-packages/malcolm/modules/web/www/fpga_docs

    and then retry the ``zpkg`` command and it should succeed. Release 1.1 of
    the rootfs fixes this, but you will still have to follow the steps above to
    correct the error.

.. _GitHub: https://github.com/PandABlocks/PandABlocks.github.io/releases

Update 24V eeprom
-----------------

PandA 3.0 requires an update to the EEPROM of 24Vio FMC cards to do this:


    - Find the right ipmi_definition file according the the product and revision (the one for FMC24V_ is under its module folder)
    - Copy it to panda
    - Run /opt/bin/write_eeprom <path-to-ipmi-definition>
    - After writing, the script will read the EEPROM to confirm the content matches

.. _FMC24V: https://github.com/PandABlocks/PandABlocks-FPGA/blob/master/modules/fmc_24vio/ipmi_definition.ini