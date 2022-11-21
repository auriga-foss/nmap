# TARGET_PROJECT = nmap

TARGET_ARCH ?= arm64
SDK_TYPE    ?= Community
DEBUG_ENABLED ?= n
GDB_SUPPORT   ?= y

QEMU_SERIAL_PORT ?= 12345

# simple helper to enable/disable commands echoing
ifeq ($(strip $(V)),1)
Q=
else
Q=@
MAKEFLAGS += -s --no-print-directory
endif

# SET aarch64 build by default
ifeq ($(strip $(TARGET_ARCH)),arm64)
TARGET       := aarch64-kos
HOST          = x86_64-linux-gnu
SDK_VERSION  ?= 1.1.0.368
DEST_CPU      = arm64
ARCH_CFG_ARGS =
QEMU          = qemu-system-aarch64
# TODO: need to figure out proper args for aarch64 and arm32
#       qemu since at the KOS-SDK it is used as '-machine virt'
QEMU_OPTS     = -smp 4 -machine vexpress-a15,secure=on -cpu cortex-a72
endif

QEMU_OPTS += -m 2048
QEMU_OPTS += -serial stdio
QEMU_OPTS += -nographic
QEMU_OPTS += -monitor none

SDK_PREFIX     = /opt/KasperskyOS-$(SDK_TYPE)-Edition-$(SDK_VERSION)
# system varibale, will be exported among the others later
PATH          :=/usr/sbin:$(SDK_PREFIX)/toolchain/bin:${PATH}
BUILD          = $(BUILD_ROOT)/image_builder/build-$(TARGET_ARCH)
ROOTFS_SOURCE  = $(BUILD)/rootfs
RAMDISK0       = $(BUILD)/ramdisk0.img
INSTALL_PREFIX = $(BUILD)/../install
PKG_CONFIG     = ""

CC=$(TARGET)-gcc
CXX=$(TARGET)-g++

CC_HOST=$(HOST)-gcc
CCX_HOST=$(HOST)-g++

# Nmap configure arguments list
CONFIG_ARGS = --host=aarch64-kos --target=aarch64-kos --build=x86_64-linux-gnu --disable-shared --enable-static --with-libpcap=internal --with-libpcre=internal --with-nbase=internal --with-nsock=internal --without-libssh2 --without-openssl --without-ndiff --without-zenmap --without-nmap-update ac_cv_header_net_if_tun_h=no

# default qemu gdb port
GDB_SERVER_PORT = 1234

# test if we want to have debug-enabled build
ifeq ($(strip $(DEBUG_ENABLED)),y)
CONFIG_ARGS += --debug -g
# enable GDB support
CONFIG_ARGS += --gdb

# redirecting serial device
QEMU_OPTS += -serial tcp::$(QEMU_SERIAL_PORT),server,nowait
# suspend gues execution (??) untill it would be explicitly run from gdb
QEMU_OPTS += -S
# enabling qemu listening incoming gdb connection
QEMU_OPTS += -gdb tcp::$(GDB_SERVER_PORT)
endif

# ok, we're all set now. lets export build control variables to let
# subsequent make call(s) 'see' them properly

# export config & build conrol variables
BUILD_DIR=$(BUILD_ROOT)
LDFLAGS= -Wl,--whole-archive -lvfs_remote -Wl,--no-whole-archive
CFLAGS= -static -g -ggdb
CPPFLAGS= $(CFLAGS) -static-libstdc++

TOOL_PREFIX=/opt/KasperskyOS-$(SDK_TYPE)-Edition-$(SDK_VERSION)/toolchain/bin/$(TARGET)
RANLIB=$(TOOL_PREFIX)-ranlib
CC=$(TOOL_PREFIX)-gcc
LD=$(TOOL_PREFIX)-ld
AR=$(TOOL_PREFIX)-ar
CXX=$(TOOL_PREFIX)-g++
CPP="$(TOOL_PREFIX)-g++ -E"

export LDFLAGS
export CFLAGS
export CPPFLAGS

export BUILD_DIR
export CONFIG_ARGS
export CC
export CCX
export CC_HOST
export CCX_HOST

export SDK_PREFIX
export PATH
export BUILD_ROOT
export BUILD
export ROOTFS_SOURCE
export RAMDISK0
export INSTALL_PREFIX
export PKG_CONFIG

# export qemu control variabled
export QEMU_OPTS
export QEMU
export TARGET
export QEMU_NET
export GDB_SERVER_PORT
export LANG=C
export GDB_SUPPORT
export DEBUG_ENABLED
export QEMU_SERIAL_PORT
