---
title: Jupyter notebooks
---

## Introduction

The combination of Jupyter notebooks, the [pyhubio](https://github.com/pavel-demin/pyhubio) library and the [USB interface](/usb-interface.md) allows interactive communication with all parts of the FPGA configuration and visualization of input and output data, making testing and prototyping more dynamic.

The [notebooks](https://github.com/pavel-demin/usb104-a7-notes/tree/master/notebooks) directory contains a few examples of Jupyter notebooks.

![Jupyter notebooks](/img/jupyter-notebooks.png)

## Getting started

- Download and unpack the [release zip file]({{ site.release_file }})

- Install the WinUSB driver for the USB interface of the USB104 A7 board (USB ID `0403:6010` and `0403:6014`) using [Zadig](https://zadig.akeo.ie)

- Install Visual Studio Code following the platform-specific instructions below:

  - [macOS](https://code.visualstudio.com/docs/setup/mac)
  - [Linux](https://code.visualstudio.com/docs/setup/linux)
  - [Windows](https://code.visualstudio.com/docs/setup/windows)

- Install the following Visual Studio Code extensions:

  - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
  - [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
  - [Micromamba](https://marketplace.visualstudio.com/items?itemName=corker.vscode-micromamba)

- Open [notebooks](https://github.com/pavel-demin/usb104-a7-notes/tree/master/notebooks) directory in Visual Studio Code:

  - From the "File" menu select "Open Folder"
  - In the "Open Folder" dialog find and select [notebooks](https://github.com/pavel-demin/usb104-a7-notes/tree/master/notebooks) directory and click "Open"

- Create micromamba environment:
  - From the "View" menu select "Command Palette"
  - Type "micromamba create environment"

## Working with notebooks

- Open one of the notebooks in Visual Studio Code

- Make sure the micromamba environment called "usb104-a7-notes" is selected in the kernel/environment selector in the top right corner of the notebook view

- Run the code cells one by one by clicking the play icon in the top left corner of each cell
