# image build specific variables; shouldn't be exposed to global make-vars.mk file
PART_0      = $(BUILD)/partition_0.img
ROOTFS_DIR ?= $(ROOTFS_SOURCE)/ramdisk0

# prepare test files to be placed to ramfs partition 0
$(ROOTFS_DIR): $(BUILD_ROOT)/../nmap
	@echo "First re-create $@"
	@rm -rf $@ && mkdir -p $@
	@mkdir -p $@/etc
	@echo "Copy all rootfs assets"
	@cp -r $(BUILD_ROOT)/image_builder/resources/ramfs/* $@
	@cp -r $< $@
	@echo "Done"

$(PART_0): $(ROOTFS_DIR)
	@echo "Preparing partition for ramdisk ..."
	@dd if=/dev/zero of=$@ bs=1M count=63
	@mkfs.ext2 $@ -d $< -L "TST_PART_0" -t ext2 -b 1024

# the ramdisk image is dependant on application(s) binaries
# which are build with respect tp KOS requirements
$(RAMDISK0): $(PART_0)
	@echo "Preparing $@ image"
	@mkdir -p $(dir $@)
	@echo "Creating empty image .."
	@dd if=/dev/zero of=$@ bs=1M count=64
	@echo "Creating partition ..."
	@printf "o\nn\np\n1\n\n\nw" | fdisk $@
	@dd if=$< of=$@ bs=512 seek=2048 conv=notrunc
	@echo "Image '$@' is ready"

.PHONY: image
image: $(RAMDISK0)
	@echo "$@ Done."

$(ROOTFS_SOURCE)/Nmap: ../out/Release/nmap
	@echo "Copy Nmap"
	$(Q)rm -f $(ROOTFS_SOURCE)/Nmap
	$(Q)cp ../out/Release/nmap  $(ROOTFS_SOURCE)/Nmap

# target to build image to be used on real hardware
.PHONY: realhw
realhw: image $(ROOTFS_SOURCE)/Nmap
	@echo " Preparing test HW image ..."
	$(Q)mkdir -p $(BUILD) && cd $(BUILD)/ && \
		cmake -G "Unix Makefiles" \
		-D CMAKE_BUILD_TYPE:STRING=Debug \
		-D CMAKE_INSTALL_PREFIX:STRING=$(INSTALL_PREFIX) \
		-D CMAKE_TOOLCHAIN_FILE=$(SDK_PREFIX)/toolchain/share/toolchain-$(TARGET).cmake \
		../ && make kos-image
	@echo " Image ($(BUILD)/einit/kos-image) ready."

.PHONY: qemubuild
qemubuild: image $(ROOTFS_SOURCE)/Nmap
	@echo "Make QEMU image ($(QEMU))"
	@echo "UART_OPTION: $(UART_OPTION)"
	$(Q)mkdir -p $(BUILD) && cd $(BUILD)/ && \
		cmake -G "Unix Makefiles" \
		-D CMAKE_BUILD_TYPE:STRING=Debug \
		-D CMAKE_INSTALL_PREFIX:STRING=$(INSTALL_PREFIX) \
		-D CMAKE_TOOLCHAIN_FILE=$(SDK_PREFIX)/toolchain/share/toolchain-$(TARGET).cmake \
		$(UART_OPTION) \
		../ && make kos-qemu-image

# image(s) clean-up rule
.PHONY: clean-image
clean-image:
	@echo " RM 	$(RAMDISK0)"
	@rm $(RAMDISK0)
	@echo " RM	$(PART_0)"
	@rm $(PART_0)
	@rm -rf ${ROOTFS_SOURCE}/ramdisk0
	@rm -rf ./rootfs/ramdisk0
	@rm -f  ./rootfs/Nmap


