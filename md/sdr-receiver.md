# SDR receiver

## Introduction

This is a simple SDR receiver that can be used with GNU Radio.

This application requires the Zmod Digitizer module to be connected to the ZMOD A connector of the USB104 A7 board.

## Hardware

The implementation of the SDR receiver is quite straightforward:

- An antenna is connected to one of the inputs of the Zmod Digitizer module
- The on-board ADC (122.88 MS/s sampling frequency, 14-bit resolution) digitizes the RF signal from the antenna
- The data coming from the ADC is processed by a in-phase/quadrature (I/Q) digital down-converter (DDC) running on the FPGA

The tunable frequency range covers from 0 Hz to 122.88 MHz.

The I/Q data rate is configurable and five settings are available: 24, 48, 96, 192, 384, 768 and 1536 kSPS.

The basic blocks of the digital down-converter (DDC) are shown in the following diagram:

![SDR receiver](/img/sdr-receiver.png)

The [projects/sdr_receiver](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver) directory contains two Tcl files: [block_design.tcl](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver/block_design.tcl), [rx.tcl](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver/rx.tcl). The code in these files instantiates, configures and interconnects all the needed IP cores.

## Software

The [projects/sdr_receiver/server](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver/server) directory contains the source code of the ZMQ server ([sdr-receiver.py](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver/server/sdr-receiver.py)) that receives control commands and transmits the I/Q data streams to the SDR programs.

The [projects/sdr_receiver/gnuradio](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver/gnuradio) directory directory contains flowgraph configuration examples for [GNU Radio Companion](https://wiki.gnuradio.org/index.php/GNURadioCompanion).

The screenshot below shows [GNU Radio Companion](https://wiki.gnuradio.org/index.php/GNURadioCompanion) running the FM receiver flow graph ([fm_zmq.grc](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver/gnuradio/fm_zmq.grc)) and communicating with the ZMQ server ([sdr-receiver.py](https://github.com/pavel-demin/usb104-a7-notes/blob/master/projects/sdr_receiver/server/sdr-receiver.py)).

![GNU Radio Companion](/img/sdr-receiver-fm-zmq.png)

## Getting started with GNU Radio on Windows

- Connect an antenna to the CH1 connector of the Zmod Digitizer module
- Connect the USB104 A7 board to a USB port
- Download and unpack the [release zip file](release_file)
- Install the WinUSB driver for the USB interface of the USB104 A7 board (USB ID `0403:6010` and `0403:6014`) using [Zadig](https://zadig.akeo.ie)
- Run the `sdr-receiver.exe` program
- Press the Start button
- Download and install [radioconda](https://github.com/ryanvolz/radioconda)
- Run [GNU Radio Companion](https://wiki.gnuradio.org/index.php/GNURadioCompanion) and open the FM receiver flow graph ([fm_zmq.grc](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver/gnuradio/fm_zmq.grc))

## Getting started with GNU Radio on Linux

- Connect an antenna to the CH1 connector of the Zmod Digitizer module
- Connect the USB104 A7 board to a USB port
- Install [GNU Radio](https://www.gnuradio.org) and [python3-libusb1](https://github.com/vpelletier/python-libusb1):

```bash
sudo apt-get install gnuradio python3-usb1
```

- Install [pyhubio](https://github.com/pavel-demin/pyhubio):

```bash
pip install pyhubio
```

- Clone the source code repository:

```bash
git clone https://github.com/pavel-demin/usb104-a7-notes
cd usb104-a7-notes
```

- Build the `sdr_receiver.bit` bitstream file for FPGA configuration:

```bash
make NAME=sdr_receiver bit
```

- Run [GNU Radio Companion](https://wiki.gnuradio.org/index.php/GNURadioCompanion) and open the FM receiver flow graph ([fm_usb.grc](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver/gnuradio/fm_usb.grc)):

```bash
cp tmp/sdr_receiver.bit projects/sdr_receiver/gnuradio
cd projects/sdr_receiver/gnuradio
gnuradio-companion fm_usb.grc
```

## Building from source

The structure of the source code and of the development chain is described at [this link](/led-blinker/).

Setting up the Vitis and Vivado environment:

```bash
source /opt/Xilinx/Vitis/2023.1/settings64.sh
```

Cloning the source code repository:

```bash
git clone https://github.com/pavel-demin/usb104-a7-notes
cd usb104-a7-notes
```

Building `sdr_receiver.bit`:

```bash
make NAME=sdr_receiver bit
```

Configuring the FPGA:

```bash
make NAME=sdr_receiver run
```
