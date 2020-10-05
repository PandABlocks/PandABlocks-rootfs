# Top level make file for building u-boot, kernel, rootfs.

# Some definitions of source file checksums to try and ensure repeatability of
# builds.  These releases are downloaded (as .tar.gz files) from:
#      https://github.com/Xilinx/u-boot-xlnx
#      https://github.com/Xilinx/linux-xlnx
# Note: if these files have been downloaded through the releases directory then
# they need to be renamed with the appropriate {u-boot,linux}-xlnx- prefix so
# that the file name and contents match.
MD5_SUM_u-boot-xlnx-xilinx-v2015.1 = b6d212208b7694f748727883eebaa74e
MD5_SUM_linux-xlnx-xilinx-v2015.1  = 930d126df2113221e63c4ec4ce356f2c


# Define settings that may need to be overridden before including CONFIG.
SPHINX_BUILD = sphinx-build

# Locations of key files in the SDK
# Cross-compilation tuple for toolkit
COMPILER_PREFIX = arm-xilinx-linux-gnueabi

# The final boot image is assembled here
BOOT_IMAGE = $(PANDA_ROOT)/boot

# The zipped file will be called this
export GIT_VERSION_SUFFIX = \
    $(shell git describe --abbrev=7 --dirty --always --tags)
BOOT_ZIP = $(PANDA_ROOT)/boot-$(GIT_VERSION_SUFFIX).zip

# Tags for versions of u-boot and kernel
U_BOOT_TAG = xilinx-v2015.1
KERNEL_TAG = xilinx-v2015.1

# Configuration and local settings.
include CONFIG

## The following code is for future compatability with the Zynq Ultrascale+ MPSoC
## We need to specify different architecture and cross-compile toolchain for the 
## zynqmp platform, as well as u-boot config. It is commented out for the time being.
#
#PLATFORM ?= zynq
#
#ifeq($(PLATFORM),zynq)
#    ARCH=arm
#    # Use Linero (hard float) toolchain rather than CodeSourcery (soft float) toolchain?
#    COMPILER_PREFIX=arm-linux-gnueabihf-
#    # From Vivado 2020 onwards we can use the common defconfig
#    #UBOOT_CONFIG = xilinx_zynq_virt_defconfig
#    # For ealier Vivado we can specify zc70x as a generic config, as we are only using it to build mkimage
#    UBOOT_CONFIG = zynq_zc70x_config
#else ifeq($(PLATFORM,zynqmp)
#    ARCH=aarch64
#    COMPILER_PREFIX=aarch64-linux-gnu-
#    # From Vivado 2020 onwards we can use the common defconfig
#    #UBOOT_CONFIG = xilinx_zynqmp_virt_defconfig
#    # For earlier Vivado verions, we can try zcu102 as an initial guess for the relevant config.
#    UBOOT_CONFIG = xilinx_zynqmp_zcu102_rev1_0_defconfig
#else
#    $$(error Unknown PLATFORM specified. Must be 'zynq' or 'zynqmp')

CROSS_COMPILE = $(COMPILER_PREFIX)-

ifdef SDK_ROOT
    BOOTGEN ?= $(SDK_ROOT)/bin/bootgen
    BINUTILS_DIR ?= $(SDK_ROOT)/gnu/arm/lin
endif

ifdef BINUTILS_DIR
    SYSROOT ?= $(BINUTILS_DIR)/$(COMPILER_PREFIX)/libc
endif

# We'll check that these symbols have been defined.
REQUIRED_SYMBOLS = ROOTFS_TOP BOOTGEN BINUTILS_DIR SYSROOT TAR_FILES PANDA_ROOT


default: boot


ARCH = arm

SRC_ROOT = $(PANDA_ROOT)/src
BUILD_ROOT = $(PANDA_ROOT)/build

U_BOOT_BUILD = $(BUILD_ROOT)/u-boot
KERNEL_BUILD = $(BUILD_ROOT)/linux


U_BOOT_TOOLS = $(U_BOOT_BUILD)/tools

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
UIMAGE_LOADADDR = 0x8000

# Outputs from build: kernel uImage and device tree compiler, needed for u-boot
# and final boot configuration.
UIMAGE = $(KERNEL_BUILD)/arch/arm/boot/uImage
DTC = $(KERNEL_BUILD)/scripts/dtc/dtc


$(KERNEL_SRC):
	mkdir -p $(SRC_ROOT)
	$(call EXTRACT_FILE,$(KERNEL_NAME).tar.gz,$(MD5_SUM_$(KERNEL_NAME)))
	chmod -R a-w $(KERNEL_SRC)

$(KERNEL_BUILD)/.config: kernel/dot.config $(KERNEL_SRC)
	mkdir -p $(KERNEL_BUILD)
	cp $< $@
	$(MAKE_KERNEL) -j4 oldconfig

$(DTC): $(KERNEL_BUILD)/.config
	$(MAKE_KERNEL) scripts

$(UIMAGE): $(KERNEL_BUILD)/.config $(U_BOOT_TOOLS)/mkimage
	$(MAKE_KERNEL) uImage UIMAGE_LOADADDR=$(UIMAGE_LOADADDR)
	touch $@


kernel-menuconfig: $(KERNEL_BUILD)/.config
	$(MAKE_KERNEL) menuconfig
	cp $< kernel/dot.config


kernel-src: $(KERNEL_SRC)
kernel: $(UIMAGE)

.PHONY: kernel kernel-src kernel-save-config kernel-menuconfig



# ------------------------------------------------------------------------------
# Building mkimage from u-boot
#

U_BOOT_NAME = u-boot-xlnx-$(U_BOOT_TAG)
U_BOOT_SRC = $(SRC_ROOT)/$(U_BOOT_NAME)

MAKE_U_BOOT = $(EXPORTS) KBUILD_OUTPUT=$(U_BOOT_BUILD) $(MAKE) -C $(U_BOOT_SRC)

$(U_BOOT_SRC):
	mkdir -p $(SRC_ROOT)
	$(call EXTRACT_FILE,$(U_BOOT_NAME).tar.gz,$(MD5_SUM_$(U_BOOT_NAME)))
	chmod -R a-w $(U_BOOT_SRC)

$(U_BOOT_TOOLS)/mkimage: $(U_BOOT_SRC)
	mkdir -p $(U_BOOT_BUILD)
	$(MAKE_U_BOOT) zynq_zc70x_config
	$(MAKE_U_BOOT) tools

u-boot-src: $(U_BOOT_SRC)

u-boot-tools : $(U_BOOT_TOOLS)/mkimage

.PHONY: u-boot-src u-boot-tools

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
$(INITRAMFS): $(INITRAMFS_CPIO).gz $(U_BOOT_TOOLS)/mkimage
	mkimage -A arm -T ramdisk -C gzip -d $< $@


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
BOOT_FILES =
BOOT_FILES += $(UIMAGE)                 # Kernel image
BOOT_FILES += $(INITRAMFS)              # Initial ramfs image
BOOT_FILES += $(ROOTFS)                 # Target root file system
BOOT_FILES += boot/config.txt           # Configuration settings for target

$(BOOT_ZIP): $(BOOT_FILES)
	mkdir -p $(BOOT_IMAGE)
	cp $^ $(BOOT_IMAGE)
	zip -j $(BOOT_ZIP) $^

boot: $(BOOT_ZIP)
.PHONY: boot

github-release: $(BOOT_ZIP)
	./make-github-release.py PandABlocks-rootfs $(GIT_VERSION_SUFFIX) \
		$(BOOT_ZIP)


# ------------------------------------------------------------------------------
# Documentation

DOCS_BUILD_DIR = $(BUILD_ROOT)/html

$(DOCS_BUILD_DIR)/index.html: $(wildcard docs/*.rst docs/conf.py)
	$(SPHINX_BUILD) -nEW -b html docs $(DOCS_BUILD_DIR)

docs: $(DOCS_BUILD_DIR)/index.html

clean-docs:
	rm -rf $(DOCS_BUILD_DIR)

