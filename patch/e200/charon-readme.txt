ANTSDR E200 / Charon SD-card bring-up
=====================================

Build
-----

From a fresh v0.38 checkout:

    sh patch.sh e200
    env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make -C plutosdr-fw TARGET=e200
    env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make -C plutosdr-fw TARGET=e200 sdimg

LC_ALL=C and LANGUAGE=C are required because this older Buildroot parses
the compiler's English "Target:" line while checking the external ARM
toolchain. A localized compiler may otherwise be misdetected as OABI.

Copy every file from plutosdr-fw/build_sdimg to the FAT partition of the
SD card. The common Charon settings are already present:

    maxcpus=2
    enable_charon=1
    freq_rxtx_hz=915000000
    rf_bandwidth=250000
    tx_output_power_minus_dbm=10
    ref_correction_ppm=5.0

Before booting, give each card a unique MAC by editing uEnv.txt:

    # Card for 192.168.1.10
    ethaddr=02:00:00:00:01:0a

    # Card for 192.168.1.11
    ethaddr=02:00:00:00:01:0b

Do not use the same ethaddr on both cards; otherwise the switch MAC table
will oscillate and SSH connections will intermittently time out.

Network layout
--------------

eth0 remains the management interface and is never added to the RF bridge.
Charon derives the mesh address from eth0's last octet:

    eth0 192.168.1.10 -> mesh-bridge 192.168.10.10
    eth0 192.168.1.11 -> mesh-bridge 192.168.10.11

This avoids a layer-2 loop when both management ports share a switch. Set
the optional U-Boot variable mesh_ipaddr only when a different RF subnet is
required.

Verification
------------

On each radio:

    nproc
    pidof charon
    ip -br addr
    batctl if
    batctl originators
    tail -n 50 /var/log/charon.log

Expected interfaces are eth0, ofdm0, bat0, and mesh-bridge. eth0 keeps its
192.168.1.x address; mesh-bridge has the matching 192.168.10.x address.

From the 192.168.1.10 radio, test the RF path (not the Ethernet management
path) with:

    ping -I mesh-bridge 192.168.10.11

The two radios must use the same RF frequency, bandwidth, and correction
settings. Use a legal frequency/power and suitable attenuation for a
cabled bench test.

Disable/recover
---------------

    /etc/init.d/S99start_charon stop
    fw_setenv enable_charon 0
    reboot

For SD boot, putting enable_charon=0 in uEnv.txt also disables automatic
startup without changing the management Ethernet configuration.
