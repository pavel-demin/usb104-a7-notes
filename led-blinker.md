---
layout: page
title: LED blinker
permalink: /led-blinker/
---

Introduction
-----

For my experiments with the USB104 A7 board, I'd like to have the following development environment:
- recent version of the [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html)
- recent version of the [Debian distribution](https://www.debian.org/releases/bullseye) on the development machine
- basic project with all the USB104 A7 peripherals connected
- mostly command-line tools
- shallow directory structure

Here is how I set it all up.

Pre-requirements
-----

My development machine has the following installed:
- [Debian](https://www.debian.org/releases/bullseye) 11.6 (amd64)
- [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html) 2020.2

Here are the commands to install all the other required packages:
{% highlight bash %}
apt-get update

apt-get --no-install-recommends install \
  bc binfmt-support bison build-essential ca-certificates curl \
  debootstrap device-tree-compiler dosfstools flex fontconfig git \
  libgtk-3-0 libncurses-dev libssl-dev libtinfo5 parted qemu-user-static \
  squashfs-tools sudo u-boot-tools x11-utils xvfb zerofree zip xc3sprog
{% endhighlight %}

Source code
-----

The source code is available at

<https://github.com/pavel-demin/usb104-a7-notes>

This repository contains the following components:

- [Makefile](https://github.com/pavel-demin/usb104-a7-notes/blob/master/Makefile) that builds everything (almost)
- [cfg](https://github.com/pavel-demin/usb104-a7-notes/tree/master/cfg) directory with constraints and board definition files
- [cores](https://github.com/pavel-demin/usb104-a7-notes/tree/master/cores) directory with IP cores written in Verilog
- [projects](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects) directory with Vivado projects written in Tcl
- [scripts](https://github.com/pavel-demin/usb104-a7-notes/tree/master/scripts) directory with Tcl scripts for Vivado

Getting started
-----

Setting up the Vitis and Vivado environment:
{% highlight bash %}
source /opt/Xilinx/Vitis/2020.2/settings64.sh
{% endhighlight %}

Cloning the source code repository:
{% highlight bash %}
git clone https://github.com/pavel-demin/usb104-a7-notes
cd usb104-a7-notes
{% endhighlight %}

Building `led_blinker.bit`:
{% highlight bash %}
make NAME=led_blinker bit
{% endhighlight %}

Configuring the FPGA:
{% highlight bash %}
make NAME=led_blinker run
{% endhighlight %}

Reprogramming FPGA
-----

It is possible to reprogram the FPGA using the `xc3sprog` program:
{% highlight bash %}
xc3sprog -v -c jtaghs1_fast tmp/led_blinker.bit
{% endhighlight %}