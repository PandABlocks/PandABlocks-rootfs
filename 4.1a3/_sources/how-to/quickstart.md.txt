# Getting a PandA on the network

The SD card inside a PandA contains a `config.txt` file that allows control of networking and other configuration settings

```
# This file contains configuration settings.  In this file network and other
# settings can be adjusted.

# If ADDRESS and NETMASK are not both specified DHCP will be used instead.
# The ADDRESS field can be set to a four part dotted IP address followed by a
# network mask specification thus:
#
#   ADDRESS = 172.23.252.202
#   NETMASK = 255.255.240.0

# If the ADDRESS field has been set then the GATEWAY and DNS fields should be
# set:
#
#   GATEWAY = 172.23.240.254
#   DNS = 172.23.5.13 172.23.4.1 130.246.8.13

# Optionally the DNS search domain can be set:
#
#   DNS_SEARCH = diamond.ac.uk

# The NTP server or servers can be specified here:
#
#   NTP = 172.23.240.2 172.23.199.1

# The machine hostname can be specified here:
#
#   HOSTNAME = panda

# To skip loading any zpackages at startup, either for testing or as an
# override to recover from a faulty zpkg install:
#
#   NO_ZPKG
```

During startup the network will be configured as follows:

- If `ADDRESS` and `NETMASK` are set then a static `IP` will be assigned, and the remaining keys should also be set. Additionally, `NTP` can be set to specify a list of `NTP` servers.
- Otherwise DHCP will be attempted. If successful this will assign the IP address, gateway and DNS settings, and may assign hostname. If the DHCP server provides the NTP option, it will be used to set the NTP servers. This will take priority over the `NTP` parameter.
- If DCHP fails then “ZeroConf” is attempted. If this also fails then PandA will not be reachable on the network.

Note that in the default configuration PandA will attempt to contact NTP servers at `0.pool.ntp.org` etc.

## Override file

If a static IP address needs to be set this can be configured after installation via the following override mechanism.

If a USB drive is plugged into PandA while it is booting, and if the drive contains this file:

	`panda-config.txt`

then this file will be used for network configuration instead of `config.txt` on the `SD` card.

This override file can be made permanent by using the `Show Network Configuration` function of the Web Admin as explained below.

## Web Interface

Once a PandA is on the network, it exposes a Web Interface that is accessible by typing it’s ip address or hostname into a browser. This consists of a number of areas:

- Home: A summary of the Web Interface sections
- Docs: Documentation on the hardware, firmware and software that make up the device
- Control: If the Web Control package is loaded then this allows the functional blocks that make up PandA to be wired together, parameters set, and the design saved and loaded.
- Admin: Allows installation of packages from a USB key, setting up SSH keys, and other remote administration.

## Web Admin

This allows the following functions:

- System
  * Reboot/Restart
  * Show /var/log/messages
  * Show Network Configuration
- Packages
  * List Installed Packages
  * Install Packages from USB
  * Install Rootfs from USB
- SSH Keys
  * Show Authorised SSH Keys
  * Append SSH keys from USB

Instructions on each operation is available by visiting the relevant Web Admin page.
