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
    glibc-langpack-en \
    gnutls-devel \
    gmp-devel \
    libffi-devel \
    libmpc-devel \
    libjpeg-turbo-devel \
    libuuid-devel \
    llvm-devel \
    ncurses-compat-libs \
    openssl-devel \
    patch \
    python3-devel \
    python3-setuptools \ 
    python3.12-devel \
    python3.12-pip \
    readline-devel \
    unzip \ 
    xorg-x11-server-Xvfb \
    xorg-x11-utils \
    xz \
    zlib-devel

# cocotb requires python 3.7+
RUN update-alternatives --set python /usr/bin/python3.12
RUN update-alternatives --set python3 /usr/bin/python3.12

RUN yum -y group install "Development Tools"

# Get dependencies from EPEL repo
RUN yum -y install fakeroot gcc-gnat gtkwave

# Copy in scripts and dls rootfs, annotypes, pymalcolm, and malcolmjs
COPY PandABlocks-rootfs/.github/scripts /scripts
COPY rootfs /rootfs
COPY annotypes /annotypes
COPY pymalcolm /pymalcolm
COPY malcolmjs /malcolmjs

# Needed for cocotb install
RUN dnf -y --enablerepo=powertools install libstdc++-static

# Toolchains and tar files
RUN bash scripts/GNU-toolchain.sh
RUN bash scripts/tar-files.sh
RUN bash scripts/install-ghdl.sh
RUN bash scripts/install-nvc.sh   
RUN bash scripts/install-cocotb.sh

# For the documentation
RUN pip3 install \
    matplotlib \ 
    rst2pdf \
    sphinx \
    sphinx-rtd-theme \
    --upgrade docutils==0.16

# For cocotb
RUN pip3 install \
    coverage \
    vhdeps

# Create config file for dls-rootfs
RUN bash scripts/config-file-rootfs.sh

# Make sure git doesn't fail when used to obtain a tag name
RUN git config --global --add safe.directory '*'

# Entrypoint into the container
WORKDIR /repos
CMD ["/bin/bash"]
