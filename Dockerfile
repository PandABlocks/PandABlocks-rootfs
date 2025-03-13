# ./Dockerfile

FROM rockylinux:8.5  as developer

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
    lzop \
    llvm-devel \
    ncurses-compat-libs \
    openssl-devel \
    patch \
    python3-devel \
    python3-setuptools \ 
    python3.12-devel \
    python3.12-pip \
    readline-devel \
    sudo \
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
    vhdeps \
    pandas \
    pytest \
    git+https://github.com/cocotb/cocotb.git@6649d76

# Create config file for dls-rootfs
RUN bash scripts/config-file-rootfs.sh

# Make sure git doesn't fail when used to obtain a tag name
RUN git config --global --add safe.directory '*'

WORKDIR /repos
CMD ["/bin/bash"]

FROM developer AS ci

# ARC setup arguments
ARG TARGETPLATFORM=linux/amd64
ARG RUNNER_VERSION=2.316.0
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.0

# Use 1001 and 121 for compatibility with GitHub-hosted runners
# runner UID assigned to allow automatic switch to user on IRIS runners
ARG RUNNER_UID=1000
ARG DOCKER_GID=1001

# Adds runner user to sudoer, required to change file permissions during CI workflow
RUN adduser --comment "" --uid $RUNNER_UID runner \
    && groupadd docker --gid $DOCKER_GID \
    && usermod -aG wheel runner \
    && usermod -aG wheel root \
    && usermod -aG docker runner \
    && echo "%wheel   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

# Setup actions runner controller
ENV RUNNER_ASSETS_DIR=/runnertmp
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
    && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x64 ; fi \
    && mkdir -p "$RUNNER_ASSETS_DIR" \
    && cd "$RUNNER_ASSETS_DIR" \
    && curl -fLo runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./runner.tar.gz \
    && rm -f runner.tar.gz \
    && ./bin/installdependencies.sh

# Install container hooks
RUN cd "$RUNNER_ASSETS_DIR" \
    && curl -fLo runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip \
    && unzip ./runner-container-hooks.zip -d ./k8s \
    && rm -f runner-container-hooks.zip

# Add Tini to attach a zombie process subreaper to vivado jobs in container
RUN yum -y install tini

# Sets working directory
WORKDIR /repos
# Entrypoint into container
CMD ["/bin/bash"]

ARG PYTHON_VERSION=3.12