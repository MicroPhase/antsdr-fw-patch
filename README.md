# ANTSDR E200 ADS-B Firmware and Host Clients

English | [简体中文](README.zh-CN.md)

This branch targets 1090 MHz ADS-B/Mode-S reception on the ANTSDR E200. The E200 performs IQ acquisition, synchronization, decoding, and CRC checking on-board using the AD9361, libiio, and readsb. Host applications consume decoded results only; they do not acquire IQ samples and do not require libiio.

## System Architecture

```text
E200 AD9361 -> local IIO -> readsb -> ADS-B decode/CRC
                                      ├─ TCP 8081: line-delimited JSON results
                                      ├─ TCP 30005: Beast binary results
                                      ├─ HTTP 8080: readsb API
                                      └─ HTTP 80 /tar1090/: web map
```

When readsb owns the local IIO receive buffer, the firmware temporarily stops `iiod` so the two processes do not compete for the same DMA buffer. The `iiod` service is restored when ADS-B is stopped.

## Build Requirements

You need Linux, Vivado/Vitis 2022.2, and the Buildroot host tools. The E200 configuration selects the ARM GNU external toolchain through Buildroot (`BR2_TOOLCHAIN_EXTERNAL_ARM_ARM`); the firmware build downloads or reuses that toolchain and exposes its wrappers under `buildroot/output/host/bin/`. You do not need to install a separate host ARM cross compiler. On Debian/Ubuntu:

```sh
sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache \
  dfu-util u-boot-tools device-tree-compiler mtools bc python3 cpio zip unzip \
  rsync file wget libtinfo5 bison flex
```

Set the Vivado environment (adjust the path as needed). Do not set `CROSS_COMPILE` or add an external cross-compiler directory to `PATH`; the Makefile selects the E200 prefix `arm-none-linux-gnueabihf-` and prepends Buildroot's host-tool directory for each sub-build.

```sh
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2022.2/settings64.sh
```

## Get the Source and Apply the E200 ADS-B Patches

```sh
git clone -b adsb --recursive https://github.com/MicroPhase/antsdr-fw-patch.git
cd antsdr-fw-patch
sh patch.sh e200
```

`patch.sh e200` applies the E200 patches to the `plutosdr-fw` HDL, U-Boot, Linux, Buildroot, and firmware scripts. The patches add readsb, tar1090, and support for the E200 `S12/16` IQ format. Before applying the patches again, make sure the submodule does not already contain the same changes.

## Build the Firmware

```sh
cd plutosdr-fw
env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make TARGET=e200
env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make TARGET=e200 sdimg
```

`LC_ALL=C LANGUAGE=C` avoids a locale parsing issue in this older Buildroot release. Normal artifacts are placed in `plutosdr-fw/build/`; SD-card files are placed in `plutosdr-fw/build_sdimg/`, including `BOOT.bin`, `uImage`, `uramdisk.image.gz`, `devicetree.dtb`, and `uEnv.txt`.

Copy `build_sdimg/` to a FAT SD card, set the E200 to SD boot, and power it on. The `sdimg` target sets `maxcpus=2`. To assign a unique management MAC address, edit only `ethaddr` in `uEnv.txt`.

> SD-card boot is recommended for the E200 ADS-B image. Confirm the target device and boot media before writing files.

## Firmware Installation and Boot

Power the board off, copy `build_sdimg/` to the FAT partition, insert the card, select the SD-boot position, and power on. After booting, log in through SSH or the serial console and check `adsb-control status` and the network address.

This branch does not use the E310 DFU workflow for the E200. Do not apply E310-specific `dfu-util` commands to an E200 ADS-B image. If your hardware revision has a separate QSPI procedure, follow that revision's hardware manual.

## Board-side Operation

The examples use `192.168.10.122`; replace it with your board address:

```sh
adsb-control status     # show readsb/iiod status
adsb-control off        # stop ADS-B and restore iiod
adsb-control on         # start ADS-B (also enabled at boot)
adsb-control restart    # restart the decoder service
```

Defaults are 1090 MHz center frequency, gain 50, and preamble threshold 58. Override them in `/mnt/jffs2/readsb.default`:

```sh
READSB_GAIN="60"
READSB_PREAMBLE_THRESHOLD="58"
```

Run `adsb-control restart` after changes. Logs are written to `/mnt/sdcard/adsb/readsb.log`, with a volatile fallback when no SD card is mounted.

| Address | Contents |
| --- | --- |
| `http://<e200-ip>/tar1090/` | tar1090 live map |
| `http://<e200-ip>/tar1090/data/aircraft.json` | current aircraft JSON |
| `<e200-ip>:8080` | readsb HTTP API |
| `<e200-ip>:8081` | line-delimited JSON ADS-B result stream |
| `<e200-ip>:30005` | Beast binary stream for aggregators |

Port 8081 is the interface used by the host clients. Each line normally contains `hex`, `flight`, `alt_baro`, `lat`, `lon`, `gs`, and `rssi`. Only results decoded and accepted by board-side readsb are sent through this stream.

## Python Host Client

The client is `host/python/adsb_json_client.py`; it uses only standard-library TCP/JSON and does not require libiio:

```sh
python3 host/python/adsb_json_client.py --host 192.168.10.122 --port 8081
```

Receive one result and exit:

```sh
python3 host/python/adsb_json_client.py --once
```

Save complete JSONL records:

```sh
python3 host/python/adsb_json_client.py --host 192.168.10.122 --output aircraft.jsonl
```

Add `--raw` to print complete JSON objects. The client reconnects every three seconds by default.

## C++ Host Client

The client is in `host/cpp/` and requires only POSIX sockets and C++17:

```sh
make -C host/cpp
./host/cpp/adsb_json_client 192.168.10.122 8081
```

Or use CMake:

```sh
cmake -S host/cpp -B host/cpp/build
cmake --build host/cpp/build
./host/cpp/build/adsb_json_client 192.168.10.122 8081
```

The example prints a summary and preserves each original JSON line. It uses a lightweight regular expression for common fields; applications needing every field can pass the original JSON to a full JSON library.

## Troubleshooting

1. Check the service: `ssh root@<e200-ip> 'adsb-control status'`.
2. Check connectivity: `nc -vz <e200-ip> 8081`. If no results arrive, inspect `tail -f /mnt/sdcard/adsb/readsb.log`.
3. Port 8081 is text JSON; port 30005 is Beast binary and must not be parsed as plain text.
4. After changing the antenna, RF gain, or threshold, verify aircraft in tar1090 or `aircraft.json` first.
5. To release IIO temporarily, run `adsb-control off`; run `adsb-control on` when testing is complete.

The goal is board-side ADS-B decoding with host-side access to final results. The host clients never access E200 IQ data and do not compete with readsb for the IIO buffer.
