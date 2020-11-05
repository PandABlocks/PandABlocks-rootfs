.. _ssh_doc:

Updating a PandA via SSH
========================

The Admin interface of the PandA can be used to update the firmware as detailed
in the `quickstart_doc`, but sometimes it is necessary to update a number of
PandAs at once. The SSH interface can be used to do this.

To gain access over SSH, either add an ``authorized_keys`` file to the SD card,
or load it from USB via the Admin interface.

It is then possible to log in remotely and perform operations on the PandA

.. warning::

    PandA only has a single user, root, and remote access is done as this user.
    Root has privileges to break the system, so be careful when running the
    commands below.

First update rootfs and then, after a reboot, update to the latest available zpkg packages (while making sure to match the major versions of everything).

Updating the rootfs
-------------------

Download a new ``boot-x.x.zip`` file from GitHub_ and unzip it somewhere. You
can then::

    $ md5sum imagefile.cpio.gz
    $ scp imagefile.cpio.gz root@my_panda_ip:/boot
    $ ssh root@my_panda_ip
    # sync
    # md5sum /boot/imagefile.cpio.gz

If the two md5 sums match then you can power cycle the box and it will install
the new rootfs. It they don't then retry from the beginning.

.. _GitHub: https://github.com/PandABlocks/PandABlocks-rootfs/releases

Updating zpkg packages
----------------------

Download new zpkg files from the appropriate GitHub repositories (these are shown at <PandA-URL>/admin/packages/list), then::

    $ scp *.zpg root@my_panda_ip:/tmp
    $ ssh root@my_panda_ip
    # zpkg install /tmp/*.zpg

This will install the new versions of the appropriate packages, and restart the services on the box to use them.

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


