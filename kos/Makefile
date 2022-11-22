BUILD_ROOT = $(PWD)

include ./rules/make-vars.mk

all:
	@echo " The 'all' target is intentionally left empty. Please conder to check possible targets with 'make help'"
.PHONY: all

.PHONY: dump-vars
dump-vars:
	@echo "	[VAR]	BUILD_ROOT=$(BUILD_ROOT)"
	@echo "	[VAR]	BUILD=$(BUILD)"
	@echo "	[VAR]	SDK_VERSION=$(SDK_VERSION)"
	@echo "	[VAR]	TARGET_ARCH=$(TARGET_ARCH)"
	@echo "	[VAR]	ROOTFS_SOURCE=$(ROOTFS_SOURCE)"
	@echo "	[VAR]	RAMDISK0=$(RAMDISK0)"
	@echo "	[VAR]	PATH=$(PATH)"
	@echo "	[VAR]	TARGET=$(TARGET)"

# Help info with respect to build/make targets
.PHONY: help
help:
	@echo "Help:"
	@echo ""
	@echo " Makefile is used to generate (and start with qemu) image with test application"
	@echo " linked with KOS image (qemu or HW). Build controls over following variables:"
	@echo ""
	@echo " Makefile has following (most used) targets:"
	@echo ""
	@echo "  NOTE: invoking make without any target will act like 'make all'"
	@echo "  all          - build compile and ramdisk0 for specified architecture"
	@echo "  configure    - do NMAP configure with respect to KOS project"
	@echo "  compile      - do compile NMAP and its' dependencies"
	@echo "  qemubuild    - do build image to be flashed and started on QEMU"
	@echo "  realhw       - do build image to be flashed and started on real HW"
	@echo "  scan-run     - run nmap in QEMU with arguments set for nmap scanning"
	@echo "  unittest-run - run nmap in QEMU with arguments set for nmap unittest"
	@echo "  qemurun      - run image in QEMU manually providing NMAP_ARGS"
	@echo "  dump-vars    - [DEBUG] dump build control variables;"

.PHONY: configure
configure:
	$(Q)echo "Running configure for $(TARGET_ARCH) ..."
	$(Q)cd .. && CPP=$(CPP) AR=$(AR) RANLIB=$(RANLIB) CC=$(CC) CXX=$(CXX) CC_host=$(CC_HOST) CXX_host=$(CCX_HOST) ./configure $(CONFIG_ARGS)
	$(Q)echo "Configured to be run with TARGET_ARCH=$(TARGET_ARCH)"

.PHONY: compile
compile:
	$(MAKE) -C ../
	$(Q)mkdir -p ../out/Release
	$(Q)cp ../nmap ../out/Release/nmap

.PHONY: run
run: clean-arch ${RAMDISK0} clean-tmp
	$(Q)$(MAKE) qemubuild QEMU_NET=1
	$(Q)$(MAKE) qemurun

.PHONY: qemurun
qemurun:
	$(Q)$(SDK_PREFIX)/toolchain/bin/$(QEMU) $(QEMU_OPTS) -kernel $(BUILD)/einit/kos-qemu-image

.PHONY: unittest-run
unittest-run:
	$(Q)$(MAKE) run NMAP_ARGS='-d --datadir /usr/local/share/nmap --script=unittest --script-args=unittest.run'

.PHONY: scan-run
scan-run:
	$(Q)$(MAKE) run NMAP_ARGS='--unprivileged -vv -dd -Pn \"10.0.2.2\" --max-parallelism \"1\" -p1-6000 --script \"safe\ and\ default\"'

clean-arch:
	@echo " RM	arch-build directory for $(TARGET_ARCH)."
	$(Q)rm -rf $(BUILD)

clean-nmap:
	@echo " RM	NMAP 'out' directory."
	$(Q)rm -rf ../out;

clean-tmp:
	$(Q)echo " RM	build articafts at /tmp"
	$(Q)rm -f /tmp/psl-base-c.*

# obvious ...
clean-all: clean-arch clean-nmap clean-tmp
	$(Q)$(MAKE) clean -C ../


# include rules for building ramfs & real HW image(s)
include ./rules/make-images.mk

# include debug-enabled build specific targets
include ./rules/make-debug.mk

