# Top level make file for building u-boot, kernel, rootfs.

include CONFIG


default: boot



SRC_ROOT = $(ZYNQ_ROOT)/src
BUILD_ROOT = $(ZYNQ_ROOT)/build

U_BOOT_BUILD = $(BUILD_ROOT)/u-boot
KERNEL_BUILD = $(BUILD_ROOT)/linux
BOOT_BUILD = $(BUILD_ROOT)/boot


U_BOOT_TOOLS = $(U_BOOT_BUILD)/tools

export PATH := $(BINUTILS_DIR):$(U_BOOT_TOOLS):$(PATH)


# ------------------------------------------------------------------------------
# Helper code lifted from rootfs

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


# ------------------------------------------------------------------------------
# Basic rules


clean:
	rm -rf $(BUILD_ROOT)

clean-all: clean
	-chmod -R +w $(SRC_ROOT)
	rm -rf $(ZYNQ_ROOT)

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

KERNEL_SRC = $(SRC_ROOT)/linux-$(KERNEL_TAG)
MAKE_KERNEL = $(EXPORTS) KBUILD_OUTPUT=$(KERNEL_BUILD) $(MAKE) -C $(KERNEL_SRC)
UIMAGE_LOADADDR = 0x8000

# Outputs from build: kernel uImage and device tree compiler, needed for u-boot
# and final boot configuration.
UIMAGE = $(KERNEL_BUILD)/arch/arm/boot/uImage
DTC = $(KERNEL_BUILD)/scripts/dtc/dtc


$(KERNEL_SRC):
	mkdir -p $(SRC_ROOT)
	tar xzf $(TAR_REPO)/linux-$(KERNEL_TAG).tgz -C $(SRC_ROOT)
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

kernel-save-config: $(KERNEL_BUILD)/.config
	cp $< kernel/dot.config


kernel-src: $(KERNEL_SRC)
kernel: $(UIMAGE)

.PHONY: kernel kernel-src kernel-save-config kernel-menuconfig



# ------------------------------------------------------------------------------
# Building u-boot
#

U_BOOT_SRC = $(SRC_ROOT)/u-boot-$(U_BOOT_TAG)
U_BOOT_ELF = $(U_BOOT_BUILD)/u-boot.elf

MAKE_U_BOOT = $(EXPORTS) KBUILD_OUTPUT=$(U_BOOT_BUILD) $(MAKE) -C $(U_BOOT_SRC)

DEVICE_TREE_DTB = $(BOOT_BUILD)/devicetree.dtb


# Rule to create binary device tree from device tree source.
$(DEVICE_TREE_DTB): boot/devicetree.dts $(DTC)
	$(DTC) -o $@ -O dtb -I dts $<

# # Inverse rule to extract device tree source from blob.
# %.dts: %.dtb
# 	$(DTC) -o $@ -O dts -I dtb $<


$(U_BOOT_SRC):
	mkdir -p $(SRC_ROOT)
	unzip -q $(TAR_REPO)/u-boot-$(U_BOOT_TAG).zip -d $(SRC_ROOT)
	patch -p1 -d $(U_BOOT_SRC) < u-boot/u-boot.patch
	ln -s $(PWD)/u-boot/PandA_defconfig $(U_BOOT_SRC)/configs
	ln -s $(PWD)/u-boot/PandA.h $(U_BOOT_SRC)/include/configs
	chmod -R a-w $(U_BOOT_SRC)

$(U_BOOT_ELF) $(U_BOOT_TOOLS)/mkimage: $(U_BOOT_SRC) $(DEVICE_TREE_DTB)
	mkdir -p $(U_BOOT_BUILD)
	$(MAKE_U_BOOT) PandA_config
	$(MAKE_U_BOOT) EXT_DTB=$(DEVICE_TREE_DTB)
	ln -sf u-boot $(U_BOOT_ELF)

u-boot: $(U_BOOT_ELF)
u-boot-src: $(U_BOOT_SRC)

.PHONY: u-boot u-boot-src



# ------------------------------------------------------------------------------
# File system building
#

# Command for building rootfs.  Need to specify both action and target name.
MAKE_ROOTFS = $(ROOTFS_TOP)/rootfs -r $(ZYNQ_ROOT) -t $(CURDIR)/$1 $2

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

INITRAMFS_O = $(ZYNQ_ROOT)/targets/initramfs
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

ROOTFS_O = $(ZYNQ_ROOT)/targets/rootfs
ROOTFS_CPIO = $(ROOTFS_O)/image/imagefile.cpio
ROOTFS = $(ROOTFS_CPIO).gz

$(ROOTFS_CPIO): $(wildcard rootfs/*)
	$(call MAKE_ROOTFS,rootfs,make)

rootfs: $(ROOTFS)

.PHONY: rootfs


# ------------------------------------------------------------------------------
# Boot image
#

# The first stage bootloader image is managed here under source control, despite
# being a binary, because it will never change and is build as part of the
# Xilinx build process.
FSBL_ELF = $(PWD)/boot/fsbl.elf

BOOT_FILES =
BOOT_FILES += $(BOOT_BUILD)/boot.bin    # Second stage bootloader
BOOT_FILES += boot/uEnv.txt             # u-boot environment
BOOT_FILES += $(UIMAGE)                 # Kernel image
BOOT_FILES += $(DEVICE_TREE_DTB)        # Device tree for kernel
BOOT_FILES += $(INITRAMFS)              # Initial ramfs image
BOOT_FILES += $(ROOTFS)                 # Target root file system


$(BOOT_BUILD)/boot.bif:
	mkdir -p $(BOOT_BUILD)
	scripts/make_boot.bif $@ $(FSBL_ELF) $(U_BOOT_ELF)

$(BOOT_BUILD)/boot.bin: $(BOOT_BUILD)/boot.bif $(FSBL_ELF) $(U_BOOT_ELF)
	cd $(BOOT_BUILD)  &&  $(BOOTGEN) -w -image boot.bif -o i $@

boot: $(BOOT_FILES)
	mkdir -p $(BOOT_IMAGE)
	cp $^ $(BOOT_IMAGE)

.PHONY: boot
