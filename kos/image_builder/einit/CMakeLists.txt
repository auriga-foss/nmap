project (einit)

# Toolchain for work with NK-parser.
include (platform/image)

# Set compilation flags.
project_header_default ("STANDARD_GNU_11:YES" "STRICT_WARNINGS:NO")

# Define an ENTITIES variable with a list of entities.
set (ENTITIES
	Nmap
	${ns_ENTITY}
	${precompiled_vfsVfsNet}
	${precompiled_vfsVfsRamFs}
	${rump_DHCPCD_ENTITY})

set (SECURITY_PSL_FILE "src/security.psl")

set (FILES
     $ENV{RAMDISK0}
)

if (NOT "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "aarch64")
     message (FATAL_ERROR "${CMAKE_SYSTEM_PROCESSOR} architecture is not supported." )
endif ()

if ("$ENV{NMAP_ARGS}" STREQUAL "")
    message(FATAL_ERROR "no NMAP_ARGS were provided")
else()
    set(NMAP_ARGS_INIT_YAML "  args:")
    separate_arguments (NMAP_ARGS_LIST UNIX_COMMAND $ENV{NMAP_ARGS})
    foreach (ARG ${NMAP_ARGS_LIST})
        __append_string_on_new_line(NMAP_ARGS_INIT_YAML "    - ${ARG}")
    endforeach ()
    message(STATUS "nmap arguments:\n" ${NMAP_ARGS_INIT_YAML})
endif()

set_target_properties (${rump_DHCPCD_ENTITY} PROPERTIES
  EXTRA_CONNECTIONS "\
  - target: kl.VfsNet
    id: kl.VfsNet
  - target: kl.VfsRamFs
    id: kl.VfsRamFs"
  EXTRA_ENV "\
    VFS_FILESYSTEM_BACKEND: client{fs->net}:kl.VfsRamFs
    VFS_NETWORK_BACKEND: client:kl.VfsNet"
  EXTRA_ARGS "\
    - '-4'
    - -f
    - /etc/dhcpcd.conf"
)

# Building Kaspersky OS solution image for a hardware platform.
build_kos_hw_image (kos-image
                    EINIT_ENTITY EinitHw
                    CONNECTIONS_CFG "src/init.yaml.in"
                    SECURITY_PSL ${SECURITY_PSL_FILE}
                    IMAGE_FILES ${ENTITIES}
                                ${FILES})

# Building Kaspersky OS solution image for a QEMU platform.
build_kos_qemu_image (kos-qemu-image
                      EINIT_ENTITY EinitQemu
                      CONNECTIONS_CFG "src/init.yaml.in"
                      SECURITY_PSL ${SECURITY_PSL_FILE}
                      IMAGE_FILES ${ENTITIES}
                                  ${FILES})
