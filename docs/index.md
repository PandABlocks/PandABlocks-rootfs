---
html_theme.sidebar_secondary.remove: true
---

```{include} ../README.md
:end-before: <!-- README only content
```

What does the rootfs do?
-------------------------

The rootfs is responsible for booting the Zynq, then setting up a number of services on it:

- Bringing up the network as specified in a config.txt file on the SD card
- Running an SSH server that allows debugging access to those who have their public keys on the PandA
- Programming the FPGA and running services like the TCP server and Web Control as specified in packages
- Running a Web Admin server on port 80 that allows ZPG files to allow the installation and removal of packages, and addition of SSH keys from the USB stick

How the documentation is structured
-----------------------------------

<!-- https://sphinx-design.readthedocs.io/en/latest/grids.html -->

::::{grid} 3
:gutter: 2

:::{grid-item-card} {material-regular}`directions;2em`
:link: how-to/building.md
:link-type: ref
:::

:::{grid-item-card} {material-regular}`directions;2em`
:link: how-to/remote.md
:link-type: ref
:::

:::{grid-item-card} {material-regular}`directions;2em`
:link: how-to/quickstart.md
:link-type: ref
:::

::::

```{toctree}
:hidden:
how-to/building.md
how-to/remote.md
how-to/quickstart.md
```
