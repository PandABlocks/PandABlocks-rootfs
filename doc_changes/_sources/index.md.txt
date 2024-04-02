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

Documentation is split into four categories, also accessible from links in the top bar.

<!-- https://sphinx-design.readthedocs.io/en/latest/grids.html -->

::::{grid} 2
:gutter: 4

:::{grid-item-card} {material-regular}`directions_walk;2em`
```{toctree}
:maxdepth: 2
:hidden:
tutorials
```
+++
Tutorials for installation and typical usage. New users start here.
:::

:::{grid-item-card} {material-regular}`directions;2em`
```{toctree}
:maxdepth: 2
how-to
```
+++
Practical step-by-step guides for the more experienced user.
:::

:::{grid-item-card} {material-regular}`info;2em`
```{toctree}
:maxdepth: 2
:hidden:
explanations
```
+++
Explanations of how it works and why it works that way.
:::

:::{grid-item-card} {material-regular}`menu_book;2em`
```{toctree}
:maxdepth: 2
:hidden:
reference
```
+++
Technical reference material including APIs and release notes.
:::

::::
