---
layout: page
title: USB interface
permalink: /usb-interface/
---

Requirements
-----

All applications in this repository have a structure similar to the one shown in the following diagram:

![Application structure]({{ "/img/application-structure.png" | prepend: site.baseurl }})

To control, monitor and communicate with all parts of the applications, the following items are required:

 - configuration registers
 - status registers
 - AXI4-Stream ports
 - BRAM ports

USB interface
-----

The USB interface consists of two 16 KB FIFO buffers and two AXI4-Stream ports. One of the FIFO buffers is used for data received from the computer and the other FIFO buffer is used for data to be sent to the computer.

The corresponding Verilog code can be found in [cores/axis_usb_v1_0/axis_usb.v](https://github.com/pavel-demin/usb104-a7-notes/blob/master/cores/axis_usb_v1_0/axis_usb.v).

Hub interface
-----

The hub interface consists of two AXI4-Stream ports used to communicate with the USB interface and all other required registers and ports connected to different parts of the applications.

The corresponding Verilog code can be found in [cores/axis_hub_v1_0/axis_hub.v](https://github.com/pavel-demin/usb104-a7-notes/blob/master/cores/axis_hub_v1_0/axis_hub.v).

Communication protocol
-----

Communication packets sent from the computer to the hub interface consist of a 32-bit command followed by 0-4096 32-bit data words.

The command consists of 32 bits containing the following information:

information   | bits
------------- | -------
port address  |  0 - 17
hub address   | 18 - 20
burst length  | 21 - 30
write/read#   | 31

If the write/read# bit is 1, then the next number of 32-bit data words corresponding to the burst length will be interpreted as data and written to consecutive addresses starting from the address specified in the command.

If the write/read# bit is 0, then no data is expected. Instead, the number of 32-bit data words corresponding to the burst length will be read from consecutive addresses starting from the address specified in the command.

The hub address is used to select one of the hub ports:

port            | hub address
--------------- | -----------
config register | 0
status register | 1
port 0          | 2
port 1          | 3
port 2          | 4
port 3          | 5
port 4          | 6
port 5          | 7

The port address is used to communicate with the configuration registers, status registers and BRAM modules connected to the BRAM ports.

The data sent from the USB interface to the computer consist of a number of 32-bit data words corresponding to the burst length in the commands with the write/read# bit set to 0.

Software
-----

A Python library based on [python-libusb1](https://github.com/vpelletier/python-libusb1) is used to communicate with configuration registers, status registers, AXI4-Stream and BRAM ports.

The Python code of this library can be found in [pyhubio](https://github.com/pavel-demin/pyhubio).

Usage examples
-----

A basic project with the USB interface connected to the ADC interface via an intermediate FIFO buffer is shown in the following diagram:

![Template project]({{ "/img/template-project.png" | prepend: site.baseurl }})

This template project can be used as a starting point for projects requiring ADC and USB interface. The Tcl code of this project can be found in [projects/template](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/template).

The code for other projects using this USB interface can be found at the following links:

 - [Test hub](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/test_hub)

 - [SDR receiver](https://github.com/pavel-demin/usb104-a7-notes/tree/master/projects/sdr_receiver)
