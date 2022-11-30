# Nmap (7.92SVN) for KasperskyOS
This is a fork of [Nmap project](https://github.com/nmap/nmap.git) adapted to
be used with KasperskyOS. For more information about the target OS, please refer
to [KaspeksyOS Community Edition](https://support.kaspersky.com/help/KCE/1.1/en-US/community_edition.htm).

For general information on using Nmap, its features and so on, please see the
[Nmap website](https://nmap.org/docs.html).

Please refer to the original NMAP (parent) [README.md](https://github.com/nmap/nmap#readme)
for more details not related to this fork.

## How to build (on Linux host)

### Setup
In order to build the code successfully, you'll need to install Kaspersky OS SDK
on your system. The latest SDK version can be downloaded from [link](https://os.kaspersky.com/development/).

All of the files required to build Nmap and its dependencies with Kaspersky OS, and some
examples of how you can bridge it with your solution, are located in the folder:

```bash
./kos
````

Please note that the minimal version of KasperskyOS SDK, which is required is **1.1.0.24**.

### Build Nmap
Once you have cloned git repository with project sources and satisfied all the
requirements , KOS-specific build is performed as follows:

1. Go to `./kos`.
2. Add `<KOS SDK root>/toolchain/bin` to your `PATH` environment variable.
3. Invoke `make configure` to do actual project config (this is a wrapper for
   `./configure` with a pre-defined arguments list).
4. Invoke `make compile -j XX` (select number of threads XX according to your
   system's HW performance).

### Running Solution with Raspberry Pi4B
It is also possible to run Nmap based on KasperskyOS on the Raspberry Pi 4B board.

First of all it is advised to prepare bootable flash-card using the following
instruction from
[Kaspersky Labs](https://support.kaspersky.com/help/KCE/1.1/en-US/preparing_sd_card_rpi.htm) or using either [Raspberry Pi Imager](https://www.raspberrypi.com/news/raspberry-pi-imager-imaging-utility/)
or grab & flash pre-build board image, which could be found [here](https://www.raspberrypi.com/software/operating-systems/).

As the Raspberry Pi has no u-boot shipped with image, it is required to prepare
one for you specific board and update board boot configuration to start u-boot
binary instead of default RaspbianOS kernel (see guide from KasperskyLabs above
or do your own setup).

Then, the easiest way to prepare KasperskyOS image to run on hardware is
invoke following commands:
```
make qemubuild
make realhw
```
And eventually, copy the `kos/image_builder/build-arm64/einit/kos-image` file to
the first partition of the flash-card. Then plug it (sd-card) in, power-up the
board and have fun.

If you still need some hint how to run it using u-boot, so here are the
commands, assuming that your boot partition is formatted to FAT32.
```
fatload mmc 0 0x200000 kos-image
bootelf 0x200000
```
So the solution will start.

## Directory structure

* `Makefile` - main Makefile to configure & build Nmap project for KOS.
  Use `make help` target to see available options & usage guidelines.
* `image_builder` - sources and CMake-based build system for KOS images along
  with build output files.
  * `build-<arch>` - architecture-specific KOS build artifacts.
  * `einit` - sources and CMake build rules for Einit entity.
  * `nmap` - CMake build rules for Nmap itself.
  * `resources` - directory with additional project files.
    * `edl` - description files for all the entities.
    * `ramfs` - additional files to be added to the KOS image filesystems.
  * `CMakeLists.txt` - project-level CMake build rules.
* `rules` - build rules for the aarch64 Nmap customized project (all the files
  from this folder are included into main Makefile, see above).
  * `make-debug.mk` - a set of debug-enabled build targets.
  * `make-images.mk` - a set of rules to build KOS images.
  * `make-vars.mk` - declaration of variables to control build rules.

## Known issues and limitations
1. KasperskyOS-specific Nmap does not support privileged mode.
2. SCTP INIT Scan is unavailable because SCTP isn't implemented in Kaspesrky-OS at this moment.

## How to run tests
1. Go to `./kos`.
2. Invoke `make unittest-run`

It can be configured by `NMAP_ARGS` variable.
See target `unittest-run` in `kos/Makefile`.
Also, all scripts from directory `scripts` are added to the QEMU image to `/usr/local/share/nmap`.
You can explore them in [the official documents](https://nmap.org/docs.html).

## How to run Nmap
1. Go to `./kos`.
2. Invoke `make scan-run`

Kaspersky OS does not contain a terminal like Linux Bash - all arguments for Nmap must be specified before building the QEMU image.
Nmap can be configured by `NMAP_ARGS` variable.
See target scan-run in `kos/Makefile`.
Default scan is invoked from `10.0.2.2` for QEMU internal network enviroment in unprivileged mode.
Invoking in unprivileged mode is associated with `/dev/bpf` issues.

## Contributing
Please see the Contributing page for generic info.
We'll follow the parent project [contributing rules](https://github.com/nmap/nmap/blob/master/CONTRIBUTING.md) but would consider to accept only KasperskyOS-specific changes, so for that it is advised to use pull-requests.
If you'd like to report a bug, please open a new issue in this project.


## Licensing
Nmap is released under a custom license, which is based on (but not compatible with) GPLv2.
The Nmap license allows free usage by end users.
See Nmap Copyright and [Licensing](https://github.com/nmap/nmap/blob/master/LICENSE) for full details.
