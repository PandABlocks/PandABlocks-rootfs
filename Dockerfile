# ./Dockerfile

FROM rockylinux:8.5

# Host dependencies 
RUN yum -y upgrade && yum -y install \
    bc \
    bzip2 \
    cpio \
    dbus-x11 \
    diffutils \
    epel-release \
    expat-devel \ 
    git \
    glibc-devel \
    libffi-devel \
    libjpeg-turbo-devel \
    ncurses-compat-libs \
    openssl-devel \
    patch \
    python3-devel \
    python3-setuptools \ 
    readline-devel \
    unzip \ 
    xorg-x11-server-Xvfb \
    xorg-x11-utils \
    xz \
    zlib-devel


RUN yum -y group install "Development Tools"

# Get fakeroot which needs epel-release 
RUN yum -y install fakeroot

# Copy in scripts and dls rootfs, annotypes, pymalcolm, and malcolmjs
COPY PandABlocks-rootfs/.github/scripts /scripts
COPY rootfs /rootfs
COPY annotypes /annotypes
COPY pymalcolm /pymalcolm
COPY malcolmjs /malcolmjs

# Toolchains and tar files
RUN bash scripts/GNU-toolchain.sh
RUN bash scripts/tar-files.sh

# For the documentation
RUN pip3 install matplotlib \ 
    rst2pdf \
    sphinx \
    sphinx-rtd-theme \
    --upgrade docutils==0.16

# Create config file for dls-rootfs
RUN bash scripts/config-file-rootfs.sh

# Error can't find python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Entrypoint into the container 
WORKDIR /repos
CMD ["/bin/bash"]