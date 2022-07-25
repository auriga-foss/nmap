cmake_minimum_required (VERSION 3.12)
project (nmap)

# Initialize CMake library for Kaspersky OS SDK.
include (platform)
initialize_platform ()

# Add functions for installing artefacts.
include (platform/install)

# Toolchain for work with NK-parser.
include (platform/nk)

# Add a Name Server package
find_package (ns REQUIRED)

# Attach a package with the virtual file system implementation.
find_package (vfs REQUIRED)
include_directories (${vfs_INCLUDE})

# Add package importing components for working with
# virtual file system.
find_package (precompiled_vfs REQUIRED)
include_directories (${precompiled_vfs_INCLUDE})

# Add package importing components for working with
# DHCPCD_ENTITY.
find_package (rump REQUIRED COMPONENTS DHCPCD_ENTITY)
include_directories (${rump_INCLUDE})

# Payload
add_subdirectory (nmap)

# Binary image of KasperskyOS.
add_subdirectory (einit)

