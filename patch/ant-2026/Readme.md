# AntSDR 2026
    AntSDR patches for recently linux and vivado

# Host Version
    1. GNU/Linux kernel 7.0.9
    2. Vivado 2025.2
    3. gcc version 16.1.1
    4. cmake version 4.3.2

# Enviroment variable
```
export VIVADO_SETTINGS=~/${your path to vivado}/vivado/2025.2/Vivado/settings64.sh

# for buildroot issue
export LD_LIBRARY_PATH= 
# for buildroot download packages
export http_proxy=http://${your proxy host}$:${your proxy port}
export https_proxy=http://${your proxy host}$:${your proxy port}
export ftp_proxy=http://${your proxy host}$:${your proxy port}
export no_proxy="localhost, 127.0.0.1"
```

# TroubleShooting

## Error: libad9361-iio-0.3 and libini-a467418 use cmake_minimum_required 2.8 or 3.1 is depracate in cmake 

This error jump out due to my cmake version 4.3.2 depracate cmake version under 3.5

In `plutosdr-fw/buildroot/output/build/libad9361-iio-0.3` and libini-a467418

Mandatory update cmake_minimum_required to 3.5 after buildroot package is been download
```
cmake_minimum_required(VERSION 3.5)
```

# Changes  

## 1. Buildroot cannot use LD_LIBRARY_PATH with empty ":"

which is a common issue , you can just tempory leave LD_LIBRARY_PATH empty
```
export LD_LIBRARY_PATH=
```

## 2. Nneed change vivado version
In plutosdr-fw/Makefile

`VIVADO_VERSION ?= 2025.2`

In `plutosdr-fw/hdl/scripts/adi_env.tcl`

`set required_vivado_version "2025.2"`

## 3. In u-boot-xlnx libfdt_env and libfdt.h conflict with /usr/include

rename `include <libfdt_env.h>` and `<libfdt.h>` to `include "libfdt_env_legacy.h"` and `"libfdt_legacy.h"`

## 4. buildroot wget and curl need setup proxy 

Notice: don't forget to set
```
export no_proxy="localhost, 127.0.0.1"
```
Or you may be cannot connect to local vitis server

## 5. m4-1.4.19 build need under gcc gnu17 
         
already upgrade to `m4-1.4.21`

Or you can mandatory change `GL_LIST_INLINE _GL_ATTRIBUTE_NODISCARD` to `_GL_ATTRIBUTE_NODISCARD GL_LIST_INLINE` in `m4-1.4.19` as a ad hoc 

## 6. XSCT cannot connect to vitis server and suggest migration to vitis -s 
In pluto-fw/Makefile  
```
    # we need use new vitis python api
    # change 
    # bash -c "source $(VIVADO_SETTINGS) && xsct scripts/create_fsbl_project.tcl"
    bash -c "source $(VIVADO_SETTINGS) && vitis -s scripts/create_fsbl_project.py"

    # python api output path is changed
    # change 
    build/sdk/fsbl/Release/fsbl.elf 
    # to 
    build/sdk/fsbl/export/fsbl/sw/boot/fsbl.elf 

```

Reffer:
    
(a) https://docs.amd.com/r/en-US/ug1400-vitis-embedded/XSCT-to-Python-API-Migration

(b) https://github.com/Xilinx/Vitis-Tutorials/tree/2024.1/Embedded_Software/Feature_Tutorials/04-vitis_scripting_flows
    


