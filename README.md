# antsdr-fw-patch
This Repository is used to make Microphase software radio device firmware. 



## Build Instructions

The Firmware is built with the [Xilinx Vivado 2023.2](https://account.amd.com/en/forms/downloads/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz)(v0.39). You need to install the correct Vivado version in you Linux PC, and then,you can follow the instructions below to generate the firmware for [ANTSDR E310](https://item.taobao.com/item.htm?spm=a230r.1.14.16.34e21142YIlxqx&id=647986963313&ns=1&abbucket=2#detail) or [ANTSDR E200](https://item.taobao.com/item.htm?spm=a1z10.3-c-s.w4002-17060615344.9.4f201b9f6YDKU2&id=691394502321) or [ANTSDR E310V2](https://item.taobao.com/item.htm?spm=a21xtw.29178619.product_shelf.8.3b923f77eJKa3u&id=708976727818&) and then.

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
	- v0.39
		
		```sh
		git clone -b v0.39 --recursive https://github.com/MicroPhase/antsdr-fw-patch.git
		```
2. Toolchain

   Due to incompatibility between the AMD/Xilinx GCC toolchain supplied with Vivado/Vitis and Buildroot. This project switched to Buildroot external Toolchain: Linaro GCC 7.3-2018.05 7.3.1
   https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabihf/


3. setup bash
	- v0.39
        ```sh
        export CROSS_COMPILE=arm-linux-gnueabihf-
        export PATH=$PATH:/Toolchain-PATH/gcc-linaro-7.3.1-2018.05-i686_arm-linux-gnueabihf/bin
        export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh
        ```

### Export target

1. ant e310

   ```sh
   export TARGET=ant
   ```

2. ant e200
	```sh
	export TARGET=e200
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



## Support 2r2t mode
If you want to use 2r2t mode, you need to enter the system and run the following command to write the mode configuradion into the nor flash. **But there is a little difference in sd card boot mode and qspi boot mode**

### QSPI mode
   ```sh
 fw_setenv attr_name compatible
 fw_setenv attr_val ad9361
 fw_setenv compatible ad9361
 fw_setenv mode 2r2t
 reboot
   ```

After restarting, use the command to detect whether the variable in the flash has been written. If the write is successful, then the 2r2t mode can be used.

Of course, thers is another way to configure the 2r2t mode, and use the command to write to the flash under uboot, such as

```sh
 setenv attr_name compatible
 setenv attr_val ad9361
 setenv compatible ad9361
 setenv mode 2r2t
 saveenv
 reset
```

 ### SD mode
 You need to modify some parameters in uEnv.txt file.

1. you need to modify the value of **adi_loadvals** as follows:

before fixing:
```txt
 adi_loadvals=fdt addr ${fit_load_address}......
```
after fixing:
 ```txt
 adi_loadvals=fdt addr ${devicetree_load_address}......
 ```

2. you need to modify the value of **mode** as follows:

before fixing:
```txt
maxcpus=1
mode=1r1t
```
after fixing:
```txt
maxcpus=1
mode=2r2t
```

3. you need to modify the value of **sdboot( add run adi_loadvals and #{fit_config})** as follows:

before fixing:
```txt
sdboot=if mmcinfo; then run uenvboot; echo Copying Linux from SD to RAM... && load mmc 0 ${fit_load_address} ${kernel_image} && load mmc 0 ${devicetree_load_address} ${devicetree_image} && load mmc 0 ${ramdisk_load_address} ${ramdisk_image} bootm ${fit_load_address} ${ramdisk_load_address} ${devicetree_load_address}; fi
```
after fixing:
```txt
sdboot=if mmcinfo; then run uenvboot; echo Copying Linux from SD to RAM... && load mmc 0 ${fit_load_address} ${kernel_image} && load mmc 0 ${devicetree_load_address} ${devicetree_image} && load mmc 0 ${ramdisk_load_address} ${ramdisk_image} && run adi_loadvals;bootm ${fit_load_address} ${ramdisk_load_address} ${devicetree_load_address}#{fit_config}; fi
```

4. you need to **add the following parameters(attr_name attr_val compatible)** in the last line:

before fixing:
```txt
usbboot=if usb start; then run uenvboot; echo Copying Linux from USB to RAM... && load usb 0 ${fit_load_address} ${kernel_image} && load usb 0 ${devicetree_load_address} ${devicetree_image} && load usb 0 ${ramdisk_load_address} ${ramdisk_image} && bootm ${fit_load_address} ${ramdisk_load_address} ${devicetree_load_address}; fi
```
after fixing:
```txt
usbboot=if usb start; then run uenvboot; echo Copying Linux from USB to RAM... && load usb 0 ${fit_load_address} ${kernel_image} && load usb 0 ${devicetree_load_address} ${devicetree_image} && load usb 0 ${ramdisk_load_address} ${ramdisk_image} && bootm ${fit_load_address} ${ramdisk_load_address} ${devicetree_load_address}; fi
attr_name=compatible
attr_val=ad9361
compatible=ad9361
```

Then you can enjoy the 2r2t mode.