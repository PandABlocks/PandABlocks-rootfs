.. _ssh_doc:

Updating a PandA via SSH
========================

The Admin interface of the PandA can be used to update the firmware as detailed
in the `quickstart_doc`, but sometimes it is necessary to update a number of
PandAs at once. The SSH interface can be used to do this.

To gain access over SSH, either add an ``authorized_keys`` file to the SD card,
or load it from USB via the Admin interface.

It is then possible to log in remotely and perform operations on the PandA

.. warning:

    PandA only has a single user, root, and remote access is done as this user.
    Root has privileges to break the system, so be careful when running the
    commands below.

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

Updating a zpkg
---------------

Download a new zpkg files from the appropriate GitHub repositories, then::

    $ scp *.zpg root@my_panda_ip:/tmp
    $ ssh root@my_panda_ip
    # zpkg install /tmp/*.zpg

This will install the appropriate packages and restart the services to on the
box to use them.

