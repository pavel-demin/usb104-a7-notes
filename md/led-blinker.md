---
title: LED blinker
---

## Introduction

For my experiments with the USB104 A7 board, I'd like to have the following development environment:

- recent version of the [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html)
- recent version of the [Debian distribution](https://www.debian.org/releases/bookworm) on the development machine
- basic project with all the USB104 A7 peripherals connected
- mostly command-line tools
- shallow directory structure

Here is how I set it all up.

## Pre-requirements

My development machine has the following installed:

- [Debian](https://www.debian.org/releases/bookworm) 12 (amd64)
- [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html) 2020.2

Here are the commands to install all the other required packages:

```bash
apt-get update

apt-get --no-install-recommends install \
  bc binfmt-support bison build-essential ca-certificates curl \
  debootstrap device-tree-compiler dosfstools flex fontconfig git \
  libgtk-3-0 libncurses-dev libssl-dev libtinfo5 parted qemu-user-static \
  squashfs-tools sudo u-boot-tools x11-utils xvfb zerofree zip xc3sprog
```

## Source code

The source code is available at

<https://github.com/pavel-demin/usb104-a7-notes>

This repository contains the following components:

- [Makefile](https://github.com/pavel-demin/usb104-a7-notes/blob/master/Makefile) that builds everything (almost)
- [cfg](https://github.com/pavel-demin/usb104-a7-notes/tree/master/cfg) directory with constraints and board definition files
- [cores](https://github.com/pavel-demin/usb104-a7-notes/tree/master/cores) directory with IP cores written in Verilog
- [projects](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects) directory with Vivado projects written in Tcl
- [scripts](https://github.com/pavel-demin/usb104-a7-notes/tree/master/scripts) directory with Tcl scripts for Vivado

## Getting started

Setting up the Vitis and Vivado environment:

```bash
source /opt/Xilinx/Vitis/2020.2/settings64.sh
```

Cloning the source code repository:

```bash
git clone https://github.com/pavel-demin/usb104-a7-notes
cd usb104-a7-notes
```

Building `led_blinker.bit`:

```bash
make NAME=led_blinker bit
```

Configuring the FPGA:

```bash
make NAME=led_blinker run
```

## Reprogramming FPGA

It is possible to reprogram the FPGA using the `xc3sprog` program:

```bash
xc3sprog -v -c jtaghs1_fast tmp/led_blinker.bit
```
