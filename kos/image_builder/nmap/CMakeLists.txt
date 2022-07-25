project (nmap)

# Tools for using NK parser.
include (platform/nk)

# Set compile flags.
project_header_default ("STANDARD_GNU_11:YES" "STRICT_WARNINGS:NO")

nk_build_edl_files (nmap_edl_files NK_MODULE "nmap" EDL "${CMAKE_SOURCE_DIR}/resources/edl/Nmap.edl")

add_executable (Nmap IMPORTED GLOBAL)

set_property(TARGET Nmap PROPERTY IMPORTED_LOCATION $ENV{ROOTFS_SOURCE}/Nmap)
add_dependencies (Nmap nmap_edl_files)
target_link_libraries (Nmap)
