# ANTSDR E200 ADS-B 固件与上位机

[English](README.md) | 中文

本分支面向 ANTSDR E200 的 1090 MHz ADS-B/Mode-S 接收。E200 在板端通过
AD9361、libiio 和 readsb 完成 IQ 采集、同步、解码和 CRC 校验；上位机只接收
readsb 已经解析出的结果，不再采集 IQ，也不需要安装 libiio。

## 系统结构

```text
E200 AD9361 -> 本地 IIO -> readsb -> ADS-B 解码/CRC
                                      ├─ TCP 8081：逐行 JSON 结果
                                      ├─ TCP 30005：Beast 二进制结果
                                      ├─ HTTP 8080：readsb API
                                      └─ HTTP 80 /tar1090/：网页地图
```

readsb 使用独占本地 IIO 接收缓冲区时，固件会暂时停止 `iiod`，避免两个进程
竞争同一个 DMA buffer。关闭 ADS-B 后会自动恢复 `iiod`。

## 构建环境

需要 Linux、Vivado/Vitis 2022.2 和 Buildroot 主机工具。E200 配置通过 Buildroot 的 `BR2_TOOLCHAIN_EXTERNAL_ARM_ARM` 选择 ARM GNU 外部工具链；构建时 Buildroot 会下载或复用该工具链，并在 `buildroot/output/host/bin/` 下提供工具链包装器。不需要另外安装主机 ARM 交叉编译器。Debian/Ubuntu 可先安装：

```sh
sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache \
  dfu-util u-boot-tools device-tree-compiler mtools bc python3 cpio zip unzip \
  rsync file wget libtinfo5 bison flex
```

设置 Vivado 环境（路径按实际安装位置修改）。不要手动设置 `CROSS_COMPILE` 或把外部交叉编译器目录加入 `PATH`；Makefile 会为 E200 选择 `arm-none-linux-gnueabihf-` 前缀，并在各子构建中自动使用 Buildroot 的主机工具目录：

```sh
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2022.2/settings64.sh
```

## 获取源码并应用 E200 ADS-B 补丁

```sh
git clone -b adsb --recursive https://github.com/MicroPhase/antsdr-fw-patch.git
cd antsdr-fw-patch
sh patch.sh e200
```

`patch.sh e200` 会向 `plutosdr-fw` 的 HDL、U-Boot、Linux、Buildroot 和脚本
仓库应用 E200 补丁，其中包括 readsb、tar1090 以及 E200 的 `S12/16` IQ 格式
适配。重复应用前请确认子仓库没有已经应用过同名补丁。

## 构建固件

```sh
cd plutosdr-fw
env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make TARGET=e200
env -u LD_LIBRARY_PATH LC_ALL=C LANGUAGE=C make TARGET=e200 sdimg
```

`LC_ALL=C LANGUAGE=C` 用于规避旧版 Buildroot 的 locale 解析问题。普通构建
产物在 `plutosdr-fw/build/`；SD 卡启动所需文件在
`plutosdr-fw/build_sdimg/`，包括 `BOOT.bin`、`uImage`、`uramdisk.image.gz`、
`devicetree.dtb` 和 `uEnv.txt`。

将 `build_sdimg/` 中的文件复制到 FAT SD 卡，E200 设置为 SD 启动后上电即可。
`sdimg` 目标会为 E200 设置 `maxcpus=2`。每台设备如需固定管理 MAC 地址，
只修改 SD 卡中的 `uEnv.txt` 的 `ethaddr`。

> E200 的 ADS-B 使用 SD 启动镜像最方便；刷写前请确认目标设备和启动介质，
> 避免覆盖其他设备的数据。

## 固件写入与启动

当前 E200 流程是“生成 SD 镜像并从 SD 卡启动”：关机后把
`build_sdimg/` 文件复制到 FAT 分区，插入 E200，拨到 SD 启动档位再上电。
系统启动后通过 SSH 或串口登录，确认 `adsb-control status` 和网络地址。
本分支不把 E200 当作 E310 的 DFU 目标；E200 的 ADS-B 镜像不使用 E310 专用的
`dfu-util` 烧写命令。若产品硬件另有 QSPI 烧写流程，应以该硬件版本的启动手册
为准，不要把 E310 的 DFU 参数直接用于 E200。

## 板端使用

以下示例假定 E200 地址为 `192.168.10.122`，可替换为实际 IP。登录 E200 后：

```sh
adsb-control status     # 查看 readsb/iiod 状态
adsb-control off        # 停止 ADS-B，恢复 iiod
adsb-control on         # 启动 ADS-B（默认开机自动启动）
adsb-control restart    # 重启解码服务
```

默认 readsb 参数为：中心频率 1090 MHz、增益 50、前导码阈值 58。可在板端
`/mnt/jffs2/readsb.default` 覆盖配置，例如：

```sh
READSB_GAIN="60"
READSB_PREAMBLE_THRESHOLD="58"
```

修改后执行 `adsb-control restart`。日志默认写入
`/mnt/sdcard/adsb/readsb.log`（无 SD 卡时使用易失目录）。

网络接口如下：

| 地址 | 内容 |
| --- | --- |
| `http://<e200-ip>/tar1090/` | tar1090 实时地图 |
| `http://<e200-ip>/tar1090/data/aircraft.json` | 当前飞机列表 JSON |
| `<e200-ip>:8080` | readsb HTTP API |
| `<e200-ip>:8081` | 每行一个 JSON 的 ADS-B 结果流 |
| `<e200-ip>:30005` | Beast 二进制流，供专业聚合器使用 |

8081 是本项目上位机使用的接口。每一行通常包含 `hex`、`flight`、`alt_baro`、
`lat`、`lon`、`gs`、`rssi` 等字段；只有已由板端 readsb 解码并通过其校验的
结果才会出现在这里。

## 上位机：Python

Python 客户端位于 `host/python/adsb_json_client.py`，使用标准库 TCP/JSON，
不依赖 libiio：

```sh
python3 host/python/adsb_json_client.py \
  --host 192.168.10.122 --port 8081
```

只接收一条结果并退出：

```sh
python3 host/python/adsb_json_client.py --once
```

保存完整 JSONL，同时在终端显示摘要：

```sh
python3 host/python/adsb_json_client.py \
  --host 192.168.10.122 --output aircraft.jsonl
```

加入 `--raw` 可直接打印完整 JSON。程序断线后默认每 3 秒自动重连。

## 上位机：C++

C++ 客户端位于 `host/cpp/`，仅依赖 POSIX socket 和 C++17 标准库：

```sh
make -C host/cpp
./host/cpp/adsb_json_client 192.168.10.122 8081
```

也可以使用 CMake：

```sh
cmake -S host/cpp -B host/cpp/build
cmake --build host/cpp/build
./host/cpp/build/adsb_json_client 192.168.10.122 8081
```

C++ 示例输出摘要并保留原始 JSON。它使用轻量正则提取常用字段，生产系统如
需处理全部字段可将原始 JSON 交给应用层 JSON 库。

## 故障排查

1. 查看服务：`ssh root@<e200-ip> 'adsb-control status'`。
2. 确认端口：`nc -vz <e200-ip> 8081`；8081 无数据时检查
   `tail -f /mnt/sdcard/adsb/readsb.log`。
3. 8081 是文本 JSON 流，不能按 30005 的 Beast 二进制协议解析；不要把 30005
   的数据直接当作字符串打印。
4. 修改天线、射频增益或阈值后，先用 tar1090 或 `aircraft.json` 确认板端有
   有效飞机，再运行上位机。
5. 如需临时释放 IIO 给其他程序，执行 `adsb-control off`；测试完成后执行
   `adsb-control on`。

本分支的目标是“E200 板端完成解码，上位机获取最终结果”。上位机代码不会
重新访问 E200 的 IQ 数据，也不会与 readsb 争用 IIO 缓冲区。
