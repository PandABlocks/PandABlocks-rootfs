# Top level make file for building u-boot, kernel, rootfs.
TOP := $(CURDIR)

# Some definitions of source file checksums to try and ensure repeatability of
# builds.  These releases are downloaded (as .tar.gz files) from:
#      https://github.com/Xilinx/u-boot-xlnx
#      https://github.com/Xilinx/linux-xlnx
# Note: if these files have been downloaded through the releases directory then
# they need to be renamed with the appropriate {u-boot,linux}-xlnx- prefix so
# that the file name and contents match.
MD5_SUM_u-boot-xlnx-xilinx-v2022.2 = a9e54fff739d5702465c786b5420d31e
MD5_SUM_linux-xlnx-xilinx-v2022.2 = 5f156f71acadfb849eb3e1f65e1a42f0

# Define settings that may need to be overridden before including CONFIG.
SPHINX_BUILD = sphinx-build

# Cross-compilation tuple for toolkit
COMPILER_PREFIX_zynq = arm-none-linux-gnueabihf
COMPILER_PREFIX_zynqmp = aarch64-none-linux-gnu
COMPILER_PREFIX = $(COMPILER_PREFIX_$(PLATFORM))

# The final boot image is assembled here
BOOT_IMAGE = $(PANDA_ROOT)/boot

# The zipped file will be called this
export GIT_VERSION_SUFFIX = \
    $(shell git describe --abbrev=7 --dirty --always --tags)
BOOT_ZIP = $(PANDA_ROOT)/boot@$(PLATFORM)-$(GIT_VERSION_SUFFIX).zip
DEPS_ZIP = $(PANDA_ROOT)/deps@$(PLATFORM)-$(GIT_VERSION_SUFFIX).zip

# Tags for versions of u-boot and kernel
U_BOOT_TAG = xilinx-v2022.2
KERNEL_TAG = xilinx-v2022.2

# Configuration and local settings.
include CONFIG

# convenient platform dependent makefile
-include Makefile.$(PLATFORM)

CROSS_COMPILE = $(COMPILER_PREFIX)-

ifdef TOOLCHAIN_ROOT
    BINUTILS_DIR ?= $(TOOLCHAIN_ROOT)
endif

ifdef BINUTILS_DIR
    SYSROOT ?= $(BINUTILS_DIR)/$(COMPILER_PREFIX)/libc
endif

# We'll check that these symbols have been defined.
REQUIRED_SYMBOLS += ROOTFS_TOP
REQUIRED_SYMBOLS += BINUTILS_DIR
REQUIRED_SYMBOLS += SYSROOT
REQUIRED_SYMBOLS += TAR_FILES
REQUIRED_SYMBOLS += PANDA_ROOT
REQUIRED_SYMBOLS += PLATFORM


default: boot

ARCH_zynq = arm
ARCH_zynqmp = arm64
ARCH = $(ARCH_$(PLATFORM))

SRC_ROOT = $(PANDA_ROOT)/src
BUILD_ROOT = $(PANDA_ROOT)/build

U_BOOT_BUILD = $(BUILD_ROOT)/u-boot
KERNEL_BUILD = $(BUILD_ROOT)/linux
BOOT_BUILD = $(BUILD_ROOT)/boot

U_BOOT_CONFIG_zynq = xilinx_zynq_virt_defconfig
U_BOOT_CONFIG_zynqmp = xilinx_zynqmp_virt_defconfig
U_BOOT_CONFIG = $(U_BOOT_CONFIG_$(PLATFORM))

U_BOOT_TOOLS = $(U_BOOT_BUILD)/tools
U_BOOT_MKIMAGE = $(U_BOOT_TOOLS)/mkimage

export PATH := $(BINUTILS_DIR)/bin:$(U_BOOT_TOOLS):$(PATH)


# ------------------------------------------------------------------------------
# Helper code lifted from rootfs and other miscellaneous functions

# Perform a sanity check: make sure the user has defined all the symbols that
# need to be defined.
define _CHECK_SYMBOL
    ifndef $1
        $$(error Must define symbol $1 in CONFIG)
    endif
endef
CHECK_SYMBOL = $(eval $(_CHECK_SYMBOL))
$(foreach sym,$(REQUIRED_SYMBOLS),$(call CHECK_SYMBOL,$(sym)))


# Function for safely quoting a string before exposing it to the shell.
# Wraps string in quotes, and escapes all internal quotes.  Invoke as
#
#   $(call SAFE_QUOTE,string to expand)
#
SAFE_QUOTE = '$(subst ','\'',$(1))'

# )' (Gets vim back in sync)

# Passing makefile exports through is a bit tiresome.  We could mark our
# symbols with export -- but that means *every* command gets them, and I
# don't like that.  This macro instead just exports the listed symbols into a
# called function, designed to be called like:
#
#       $(call EXPORT,$(EXPORTS)) script
#
EXPORT = $(foreach var,$(1),$(var)=$(call SAFE_QUOTE,$($(var))))


# Both kernel and u-boot builds need CROSS_COMPILE and ARCH to be exported
EXPORTS = $(call EXPORT,CROSS_COMPILE ARCH)

# Use the rootfs extraction tool to decompress our source trees.
EXTRACT_FILE = $(ROOTFS_TOP)/scripts/extract-tar $(SRC_ROOT) $1 $2 $(TAR_FILES)


# ------------------------------------------------------------------------------
# Basic rules


clean:
	rm -rf $(BUILD_ROOT)

clean-all: clean
	-chmod -R +w $(SRC_ROOT)
	rm -rf $(PANDA_ROOT)

.PHONY: clean clean-all



# ------------------------------------------------------------------------------
# Kernel
#

# Note that there is something close to a circular dependency between the kernel
# and u-boot builds.  The kernel build depends on mkimage from u-boot, and the
# u-boot build depends on dtc from the kernel tools.  We resolve this circular
# loop via the kernel scripts target which buils dtc, so the build order is now:
#
#    dtc -> u-boot -> uImage

KERNEL_NAME = linux-xlnx-$(KERNEL_TAG)
KERNEL_SRC = $(SRC_ROOT)/$(KERNEL_NAME)
MAKE_KERNEL = $(EXPORTS) KBUILD_OUTPUT=$(KERNEL_BUILD) $(MAKE) -C $(KERNEL_SRC)
UIMAGE_LOADADDR_zynq = 0x8000
UIMAGE_LOADADDR_zynqmp = 0x80000
UIMAGE_LOADADDR = $(UIMAGE_LOADADDR_$(PLATFORM))

# Outputs from build: kernel uImage and device tree compiler, needed for u-boot
# and final boot configuration.
IMAGE = $(KERNEL_BUILD)/arch/$(ARCH)/boot/Image
UIMAGE = $(KERNEL_BUILD)/arch/$(ARCH)/boot/uImage

# Wrapper for boot script
U_BOOT_SCRIPT = $(BOOT_BUILD)/boot.scr
U_BOOT_CMD = $(TOP)/boot/boot.cmd

$(KERNEL_SRC):
	mkdir -p $(SRC_ROOT)
	$(call EXTRACT_FILE,$(KERNEL_NAME).tar.gz,$(MD5_SUM_$(KERNEL_NAME)))
	chmod -R a-w $(KERNEL_SRC)

$(KERNEL_BUILD)/.config: kernel/$(PLATFORM).config $(KERNEL_SRC)
	mkdir -p $(KERNEL_BUILD)
	cp $< $@
	$(MAKE_KERNEL) -j4 oldconfig

$(IMAGE): $(KERNEL_BUILD)/.config
	$(MAKE_KERNEL) Image
	touch $@

$(UIMAGE): $(IMAGE) $(U_BOOT_MKIMAGE)
	mkimage -n 'Kernel Image' -A $(ARCH) -O linux -C none -T kernel \
            -a $(UIMAGE_LOADADDR) -e $(UIMAGE_LOADADDR) -d $(IMAGE) $(UIMAGE)

$(U_BOOT_SCRIPT): $(U_BOOT_CMD) $(U_BOOT_MKIMAGE)
	mkdir -p $(BOOT_BUILD)
	mkimage -A $(ARCH) -C none -T script -d $< $@

kernel-menuconfig: $(KERNEL_BUILD)/.config
	$(MAKE_KERNEL) menuconfig
	cp -f $< kernel/$(PLATFORM).config

kernel-src: $(KERNEL_SRC)
kernel: $(UIMAGE)

.PHONY: kernel kernel-src kernel-save-config kernel-menuconfig



# ------------------------------------------------------------------------------
# Building u-boot tools
#

U_BOOT_NAME = u-boot-xlnx-$(U_BOOT_TAG)
U_BOOT_SRC = $(SRC_ROOT)/$(U_BOOT_NAME)

MAKE_U_BOOT = $(EXPORTS) KBUILD_OUTPUT=$(U_BOOT_BUILD) $(MAKE) -C $(U_BOOT_SRC)

$(U_BOOT_SRC):
	mkdir -p $(SRC_ROOT)
	$(call EXTRACT_FILE,$(U_BOOT_NAME).tar.gz,$(MD5_SUM_$(U_BOOT_NAME)))
	chmod -R a-w $(U_BOOT_SRC)

$(U_BOOT_MKIMAGE): $(U_BOOT_SRC)
	mkdir -p $(U_BOOT_BUILD)
	$(MAKE_U_BOOT) $(U_BOOT_CONFIG)
	$(MAKE_U_BOOT) tools

u-boot-mkimage: $(U_BOOT_MKIMAGE)
u-boot-src: $(U_BOOT_SRC)

.PHONY: u-boot-mkimage u-boot-src

# ------------------------------------------------------------------------------
# File system building
#

# Command for building rootfs.  Need to specify both action and target name.
MAKE_ROOTFS = \
    $(call EXPORT,COMPILER_PREFIX SYSROOT) \
    $(ROOTFS_TOP)/rootfs -f '$(TAR_FILES)' -r $(PANDA_ROOT) -t $(CURDIR)/$1 $2

%.gz: %
	gzip -c -1 $< >$@

# The following targets are to make it easier to edit the busybox configuration.
#
%-menuconfig: phony
	$(call MAKE_ROOTFS,$*,package busybox menuconfig)

%-busybox: phony
	$(call MAKE_ROOTFS,$*,package busybox) KEEP_BUILD=1

.PHONY: phony



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initial Ramfs image (initramfs)
#
# This is the first image loaded by the kernel on booting.

INITRAMFS_O = $(PANDA_ROOT)/targets/initramfs
INITRAMFS_CPIO = $(INITRAMFS_O)/image/imagefile.cpio
INITRAMFS = $(INITRAMFS_O)/image/uinitramfs

$(INITRAMFS_CPIO): $(wildcard initramfs/*)
	$(call MAKE_ROOTFS,initramfs,make)

# So that u-boot can load the initramfs it needs to be wrapped with mkimage
$(INITRAMFS): $(INITRAMFS_CPIO).gz $(U_BOOT_MKIMAGE)
	mkimage -A $(ARCH) -T ramdisk -C gzip -d $< $@


initramfs: $(INITRAMFS)

.PHONY: initramfs


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Root file system
#
# This is the installed target file system

ROOTFS_O = $(PANDA_ROOT)/targets/rootfs
ROOTFS_CPIO = $(ROOTFS_O)/image/imagefile.cpio
ROOTFS = $(ROOTFS_CPIO).gz

$(ROOTFS_CPIO): $(shell find rootfs -type f)
	$(call MAKE_ROOTFS,rootfs,make)

rootfs: $(ROOTFS)

.PHONY: rootfs


# ------------------------------------------------------------------------------
# Boot image
#

BOOT_FILES += $(U_BOOT_SCRIPT)          # Boot script
BOOT_FILES += $(UIMAGE)                 # Kernel image
BOOT_FILES += $(INITRAMFS)              # Initial ramfs image
BOOT_FILES += $(ROOTFS)                 # Target root file system
BOOT_FILES += boot/config.txt           # Configuration settings for target


boot: $(BOOT_FILES)
	mkdir -p $(BOOT_IMAGE)
	cp $^ $(BOOT_IMAGE)

.PHONY: boot

$(BOOT_ZIP): $(BOOT_FILES)
	zip -j $@ $^

# These are the untarred versions of the tar files that rootfs makes
SRC_DIRS = $(wildcard $(SRC_ROOT)/*)

# Dubious hack, for each untarred dir, guess that there is a source tar file in
# the TAR_FILES dir that starts with the untarred dir name. These can be
# collected in one zip file to make the deps zip
SRC_TARS = $(wildcard $(patsubst $(SRC_ROOT)/%,$(TAR_FILES)/%*,$(SRC_DIRS)))

$(DEPS_ZIP): $(BOOT_ZIP)
	zip -j $@ $(SRC_TARS)

zips: $(BOOT_ZIP) $(DEPS_ZIP)
.PHONY: zips

# ------------------------------------------------------------------------------
# Documentation

DOCS_BUILD_DIR = $(BUILD_ROOT)/html

$(DOCS_BUILD_DIR)/index.html: $(wildcard docs/*.rst docs/conf.py)
	$(SPHINX_BUILD) -nEW -b html docs $(DOCS_BUILD_DIR)

docs: $(DOCS_BUILD_DIR)/index.html

clean-docs:
	rm -rf $(DOCS_BUILD_DIR)

-include RULES.$(PLATFORM)

