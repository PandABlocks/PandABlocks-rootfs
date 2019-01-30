.. _quickstart_doc:

Getting a PandA on the network
==============================

The SD card inside a PandA contains a ``config.txt`` file that allows control
of networking and other configuration settings

.. include:: default_config.txt

During startup the network will be configured as follows:

* If ``ADDRESS`` and ``NETMASK`` are set then a static IP will be assigned, and
  the remaining keys should also be set.

* Otherwise DHCP will be attempted.  If successful this will assign the IP
  address, gateway and DNS settings, and may assign hostname.

* If DCHP fails then "ZeroConf" is attempted.  If this also fails then PandA
  will not be reachable on the network.

Note that in the default configuration PandA will attempt to contact NTP servers
at ``0.pool.ntp.org`` etc.

Override file
-------------

If a static IP address needs to be set this can be configured after installation
via the following override mechanism.

If a USB drive is plugged into PandA while it is booting, and if the drive
contains this file:

    ``panda-config.txt``

then this file will be used for network configuration instead of ``config.txt``
on the SD card.

This override file can be made permanent by using the
``Show Network Configuration`` function of the `web_admin` as explained below.

Web Interface
-------------

Once a PandA is on the network, it exposes a Web Interface that is accessible
by typing it's ip address or hostname into a browser. This consists of a
number of areas:

- Home: A summary of the Web Interface sections
- Docs: Documentation on the hardware, firmware and software that make up the
  device
- Control: If the Web Control package is loaded then this allows the functional
  blocks that make up PandA to be wired together, parameters set, and the design
  saved and loaded.
- Admin: Allows installation of packages from a USB key, setting up SSH keys,
  and other remote administration.

.. _web_admin:

Web Admin
---------

This allows the following functions:

- System
  - Reboot/Restart
  - Show /var/log/messages
  - Show Network Configuration
- Packages
  - List Installed Packages
  - Install Packages from USB
  - Install Rootfs from USB
- SSH Keys
  - Show Authorised SSH Keys
  - Append SSH keys from USB

Instructions on each operation is available by visiting the relevant Web Admin
page.