---
layout: page
title: SDR receiver compatible with HPSDR
permalink: /sdr-receiver-hpsdr/
---

Introduction
-----

This SDR receiver emulates a [Hermes](https://openhpsdr.org/hermes.php) module with eight receivers. It may be useful for projects that require eight receivers compatible with the programs that support the HPSDR/Metis communication protocol.

The HPSDR/Metis communication protocol is described in the following documents:

 - [Metis - How it works](https://github.com/TAPR/OpenHPSDR-SVN/raw/master/Metis/Documentation/Metis- How it works_V1.33.pdf)

 - [HPSDR - USB Data Protocol](https://github.com/TAPR/OpenHPSDR-SVN/raw/master/Documentation/USB_protocol_V1.58.doc)

This application requires the Zmod Digitizer module to be connected to the ZMOD A connector of the USB104 A7 board.

Hardware
-----

The FPGA configuration consists of eight identical digital down-converters (DDC). Their structure is shown in the following diagram:

![HPSDR receiver]({{ "/img/sdr-receiver-hpsdr.png" | prepend: site.baseurl }})

The I/Q data rate is configurable and four settings are available: 48, 96, 192, 384 kSPS.

The tunable frequency range covers from 0 Hz to 61.44 MHz.

The [projects/sdr_receiver_hpsdr](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver_hpsdr) directory contains two Tcl files: [block_design.tcl](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver_hpsdr/block_design.tcl), [rx.tcl](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver_hpsdr/rx.tcl). The code in these files instantiates, configures and interconnects all the needed IP cores.

The [projects/sdr_receiver_hpsdr/filters](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver_hpsdr/filters) directory contains the source code of the [R](https://www.r-project.org) script used to calculate the coefficients of the FIR filters.

Software
-----

The [projects/sdr_receiver_hpsdr/server](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver_hpsdr/server) directory contains the source code of the UDP server ([sdr-receiver-hpsdr.py](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver_hpsdr/server/sdr-receiver-hpsdr.py)) that receives control commands and transmits the I/Q data streams to the SDR programs.

This SDR receiver should work with the programs that support the HPSDR/Metis communication protocol. It was tested with the following programs:

 - [CW Skimmer Server](https://dxatlas.com/skimserver)

 - [extio-iw0hdv](https://github.com/IW0HDV/extio-iw0hdv/releases/tag/v1.0.5) and [SDR#](https://www.dropbox.com/sh/5fy49wae6xwxa8a/AAAdAcU238cppWziK4xPRIADa/sdr/sdrsharp_v1.0.0.1361_with_plugins.zip?dl=1)

![Skimmer Server]({{ "/img/skimmer-server.png" | prepend: site.baseurl }})

Getting started
-----

 - Download and unpack the [release zip file]({{ site.release-file }}).
 - Copy the contents of the zip file to a directory.
 - Install the WinUSB driver for the USB interface of the USB104 A7 board (USB ID `0403:6010` and `0403:6014`) using [Zadig](https://zadig.akeo.ie).
 - Run the `sdr-receiver-hpsdr.exe` program.
 - Press the Start button.
 - Install and run one of the HPSDR programs.

Running CW Skimmer Server and Reverse Beacon Network Aggregator
-----

 - Install [CW Skimmer Server](https://dxatlas.com/skimserver).
 - Copy [HermesIntf.dll](https://github.com/k3it/HermesIntf/releases) to the CW Skimmer Server program directory (C:\Program Files (x86)\Afreet\SkimSrv).
 - Install [Reverse Beacon Network Aggregator](https://www.reversebeacon.net/pages/Aggregator+34).
 - Start CW Skimmer Server, configure frequencies and your call sign.
 - Start Reverse Beacon Network Aggregator.

Building from source
-----

The structure of the source code and of the development chain is described at [this link]({{ "/led-blinker/" | prepend: site.baseurl }}).

Setting up the Vitis and Vivado environment:
{% highlight bash %}
source /opt/Xilinx/Vitis/2020.2/settings64.sh
{% endhighlight %}

Cloning the source code repository:
{% highlight bash %}
git clone https://github.com/pavel-demin/usb104-a7-notes
cd usb104-a7-notes
{% endhighlight %}

Building `sdr_receiver_hpsdr.bit`:
{% highlight bash %}
make NAME=sdr_receiver_hpsdr bit
{% endhighlight %}

Configuring the FPGA:
{% highlight bash %}
make NAME=sdr_receiver_hpsdr run
{% endhighlight %}
