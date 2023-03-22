# antsdr-fw-patch
This Repository is used to make Microphase software radio device firmware. 



## Build Instructions

The Firmware is built with the [Xilinx Vivado 2019.1](https://www.xilinx.com/member/forms/download/xef-vivado.html?filename=Xilinx_Vivado_SDK_Web_2019.1_0524_1430_Lin64.bin)(v0.34) or ([Xilinx Vivado 2021.1](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2021.1_0610_2318.tar.gz))(v0.35). You need to install the correct Vivado version in you Linux PC, and then,you can follow the instructions below to generate the firmware for [ANTSDR E310](https://item.taobao.com/item.htm?spm=a230r.1.14.16.34e21142YIlxqx&id=647986963313&ns=1&abbucket=2#detail) or [ANTSDR E200](https://item.taobao.com/item.htm?spm=a1z10.3-c-s.w4002-17060615344.9.4f201b9f6YDKU2&id=691394502321) and then.

### Install build requirements

```sh
sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache 
sudo apt-get install dfu-util u-boot-tools device-tree-compiler mtools
sudo apt-get install bc python cpio zip unzip rsync file wget 
sudo apt-get install libtinfo5 device-tree-compiler bison flex u-boot-tools
sudo apt-get purge gcc-arm-linux-gnueabihf
sudo apt-get remove libfdt-de
```

### Get source code and setup bash

1. get source from git
	- v0.34
		
		```sh
		git clone -b v0.34 --recursive https://github.com/MicroPhase/antsdr-fw-patch.git
		```
		
	- v0.35
		```sh
		git clone -b v0.35 --recursive https://github.com/MicroPhase/antsdr-fw-patch.git
		```
	
2. setup bash
	- v0.34
        ```sh
        export CROSS_COMPILE=arm-linux-gnueabihf- 
        export PATH=$PATH:/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin 
        export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2019.1/settings64.sh
        export PERL_MM_OPT=
        ```
    - v0.35
       ```sh
       export CROSS_COMPILE=arm-linux-gnueabihf- 
       export PATH=$PATH:/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin 
       export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2021.1/settings64.sh
       export PERL_MM_OPT=
       ```

### Export target

1. ant e310

   ```sh
   export TARGET=ant
   ```

2. ant e200
	```sh
	export TARGET=antsdre200
	```
	
3. ant e310v2

  ```sh
  export TARGET=e310v2
  ```

  

### Patch

After completing the above steps, start to Patch.

```sh
cd antsdr-fw-patch
```

1. ant e310

   ```sh
   sh patch.sh ant
   ```

2. ant e200

   ```sh
   sh patch.sh e200
   ```
   
3. ant e310v2

   ```sh
   sh patch.sh e310v2
   ```

   

If you patch is successfully applied, you can see the following information.

```txt
jcc@jcc:~/work/Git/mp/antsdr-fw-patch$ sh patch.sh e200
Patch check...
 ...
 ...
 Makefile               |   29 +++++++-
 scripts/antsdre200.its |  174 ++++++++++++++++++++++++++++++++++++++++++++++++
 scripts/antsdre200.mk  |   10 +++
 3 files changed, 211 insertions(+), 2 deletions(-)
Patch...
...
...
patch finish

```

### Build

Then you can make firmware.

```sh
cd plutosdr-fw
make
```

After the firmware building finished, you will see below file in the build folder. These files are used for flash updating.(This is e200 device)

```txt
jcc@jcc:~/work/Git/mp/antsdr-fw-patch/plutosdr-fw$ ls -AGhl build
总用量 319M
-rw-rw-r-- 1 jcc  12M 12月 26 11:06 antsdre200.dfu
-rw-rw-r-- 1 jcc  12M 12月 26 11:06 antsdre200.frm
-rw-rw-r-- 1 jcc   33 12月 26 11:06 antsdre200.frm.md5
-rw-rw-r-- 1 jcc  12M 12月 26 11:06 antsdre200.itb
-rw-rw-r-- 1 jcc  20M 12月 26 11:06 antsdr-fw-v0.34-dirty.zip
-rw-rw-r-- 1 jcc 670K 12月 26 11:06 antsdr-jtag-bootstrap-v0.34-dirty.zip
-rw-rw-r-- 1 jcc   69 12月 26 11:06 boot.bif
-rw-rw-r-- 1 jcc 508K 12月 26 11:06 boot.bin
-rw-rw-r-- 1 jcc 508K 12月 26 11:06 boot.dfu
-rw-rw-r-- 1 jcc 637K 12月 26 11:06 boot.frm
-rw-rw-r-- 1 jcc 245M 12月 26 11:06 legal-info-v0.34-dirty.tar.gz
-rw-rw-r-- 1 jcc 527K 12月 26 10:51 LICENSE.html
-rw-rw-r-- 1 jcc 524K 12月 26 11:05 ps7_init.c
-rw-rw-r-- 1 jcc 524K 12月 26 11:05 ps7_init_gpl.c
-rw-rw-r-- 1 jcc 4.2K 12月 26 11:05 ps7_init_gpl.h
-rw-rw-r-- 1 jcc 4.8K 12月 26 11:05 ps7_init.h
-rw-rw-r-- 1 jcc 2.8M 12月 26 11:05 ps7_init.html
-rw-rw-r-- 1 jcc  35K 12月 26 11:05 ps7_init.tcl
-rw-r--r-- 1 jcc 5.4M 12月 26 10:56 rootfs.cpio.gz
drwxrwxr-x 6 jcc 4.0K 12月 26 11:06 sdk
-rw-rw-r-- 1 jcc 2.3M 12月 26 11:06 system_top.bit
-rw-rw-r-- 1 jcc 568K 12月 26 11:05 system_top.hdf
-rwxrwxr-x 1 jcc 471K 12月 26 11:06 u-boot.elf
-rw-rw---- 1 jcc 128K 12月 26 11:06 uboot-env.bin
-rw-rw---- 1 jcc 129K 12月 26 11:06 uboot-env.dfu
-rw-rw-r-- 1 jcc 6.8K 12月 26 11:06 uboot-env.txt
-rwxrwxr-x 1 jcc 4.0M 12月 26 10:45 zImage
-rw-rw-r-- 1 jcc  19K 12月 26 10:56 zynq-antsdre200.dtb
```



## Make SD card boot image

After the firmware building finished, you can build the SD card boot image for device. Just type the following command.

```sh
make sdimg
```

You will see the SD boot image in the build_sdimg folder. You can just  copy all these files in that folder into a SD card, plug the SD card  into the ANTSDR, set the jumper into SD card boot mode.

## Update Flash by DFU

DFU mode is just for ant e310, e200 is unsupport. If your device is e310, You can update the flash by DFU. Set the jumper into Flash Boot mode.  When device is power up, push the DFU button, and then, you will see the both led in the device will turn green, now it's time to update the  flash. You should change into the build folder first,and plug a micro USB into  the OTG interface. After that, you should run the following command.

```sh
sudo dfu-util -a firmware.dfu -D ./ant.dfu
sudo dfu-util -a boot.dfu -D ./boot.dfu
sudo dfu-util -a uboot-env.dfu -D ./uboot-env.dfu
sudo dfu-util -a uboot-extra-env.dfu -U ./uboot-extra-env.dfu
```

Now you can repower device.

