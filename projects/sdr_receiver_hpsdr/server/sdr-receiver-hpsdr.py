#!/usr/bin/env python3

import sys
import time

from functools import partial

import numpy as np

from pyhubio import PyhubIO, PyhubJTAG

from PySide2.QtUiTools import loadUiType
from PySide2.QtCore import QTimer
from PySide2.QtWidgets import QApplication, QMainWindow, QLabel, QComboBox
from PySide2.QtNetwork import QUdpSocket, QHostAddress

Ui_Server, QMainWindow = loadUiType("sdr-receiver-hpsdr.ui")


class Server(QMainWindow, Ui_Server):
    bitstream = "sdr_receiver_hpsdr.bit"
    # fmt: off
    reply = [0xef, 0xfe, 0x02, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x19, 0x01, 0x52, 0x5f, 0x50, 0x49, 0x54, 0x41, 0x59, 0x41, 0x08]
    # fmt: on
    header = [
        [127, 127, 127, 0, 0, 33, 17, 25],
        [127, 127, 127, 8, 0, 0, 0, 0],
        [127, 127, 127, 16, 0, 0, 0, 0],
        [127, 127, 127, 24, 0, 0, 0, 0],
        [127, 127, 127, 32, 66, 66, 66, 66],
    ]
    rate_map = [1280, 640, 320, 160]
    adc_cfg = [
        0x00003C,
        0x000803,
        0x000800,
        0x000502,
        0x001421,
        0x000501,
        0x001431,
    ]

    def __init__(self):
        super(Server, self).__init__()
        self.setupUi(self)
        # initialize variables
        self.idle = True
        self.samples = np.zeros(48 * 4096, np.uint8)
        self.buffer = np.zeros(1032, np.uint8)
        self.buffer.view(np.uint32)[0:4] = 0x0601FEEF
        self.counter = np.zeros(4, np.uint8)
        self.addr = QHostAddress.Null
        self.port = 0
        self.active = 0
        self.offset = 0
        self.receivers = 0
        self.config = np.zeros(10, np.uint32)
        self.status = np.zeros(1, np.uint32)
        self.config[1] = 2560
        # create controls
        self.startButton.clicked.connect(self.start)
        for i in range(8):
            label = QLabel("RX%d input" % (i + 1))
            self.inputLayout.addWidget(label, i * 2 + 0, 0)
            input = QComboBox()
            input.addItems(["CH1", "CH2"])
            input.currentIndexChanged.connect(partial(self.update_input, i))
            self.inputLayout.addWidget(input, i * 2 + 1, 0)
        # create IO
        self.jtag = PyhubJTAG()
        self.io = PyhubIO()
        # create UDP socket
        self.socket = QUdpSocket(self)
        self.socket.bind(1024)
        # create timers
        self.dataTimer = QTimer(self)
        self.dataTimer.timeout.connect(self.send_data)
        self.ctrlTimer = QTimer(self)
        self.ctrlTimer.timeout.connect(self.send_ctrl)

    def start(self):
        self.startButton.setEnabled(False)
        if self.idle:
            try:
                self.jtag.program(self.bitstream)
            except:
                self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
                self.startButton.setEnabled(True)
                return
            self.logViewer.appendPlainText("FPGA configured")
            time.sleep(0.1)
            try:
                self.io.start()
                self.io.flush()
                self.io.write(np.uint32(self.adc_cfg), 2)
            except:
                self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
                self.startButton.setEnabled(True)
                return
            self.socket.readyRead.connect(self.read_data)
            self.startButton.setText("Stop")
            self.logViewer.appendPlainText("server started")
            self.idle = False
        else:
            self.active = 0
            self.dataTimer.stop()
            self.ctrlTimer.stop()
            self.socket.readyRead.disconnect()
            self.io.stop()
            self.startButton.setText("Start")
            self.logViewer.appendPlainText("server stopped")
            self.idle = True
        self.startButton.setEnabled(True)

    def read_data(self):
        datagram = self.socket.receiveDatagram()
        addr = datagram.senderAddress()
        port = datagram.senderPort()
        data = np.frombuffer(datagram.data(), np.uint8)
        if data.size < 4:
            return
        code = data[0:4].view(np.uint32)[0]
        if code == 0x0201FEEF:
            self.update_config(data[11:16])
            self.update_config(data[523:528])
        elif code == 0x0002FEEF:
            self.buffer.fill(0)
            self.buffer[0:20] = self.reply
            self.buffer[2] = 2 + self.active
            self.socket.writeDatagram(self.buffer[:60].tobytes(), addr, port)
        elif code == 0x0004FEEF:
            self.active = 0
            self.dataTimer.stop()
            self.ctrlTimer.stop()
            self.logViewer.appendPlainText("client disconnected")
        elif code in {0x0104FEEF, 0x0204FEEF, 0x0304FEEF}:
            self.counter.fill(0)
            self.addr = addr
            self.port = port
            self.active = 1
            self.offset = 0
            self.receivers = 0
            self.config.fill(0)
            self.config[1] = 2560
            self.reset_fifo()
            self.dataTimer.start(5)
            self.ctrlTimer.start(100)
            self.logViewer.appendPlainText("client connected")

    def update_config(self, data):
        code = data[0]
        freq = np.flip(data[1:5]).copy().view(np.uint32)[0]
        if code in {0, 1}:
            value = ((data[4] >> 3) & 7) + 1
            if self.receivers != value:
                self.receivers = value
                self.logViewer.appendPlainText("number of receivers: %d" % value)
            value = self.rate_map[data[1] & 3]
            if self.config[1] != value:
                self.config[1] = value
                rate = 61440 // value
                self.logViewer.appendPlainText("sample rate: %d kS/s" % rate)
        elif 4 <= code <= 17:
            n = code // 2
            value = np.floor(freq / 122.88e6 * (1 << 30) + 0.5)
            if self.config[n] != value:
                self.config[n] = value
                self.logViewer.appendPlainText("RX%d frequency: %d Hz" % (n - 1, freq))
        elif code in {36, 37}:
            value = np.floor(freq / 122.88e6 * (1 << 30) + 0.5)
            if self.config[9] != value:
                self.config[9] = value
                self.logViewer.appendPlainText("RX8 frequency: %d Hz" % freq)

    def update_input(self, index, value):
        if value > 0:
            self.config[0] |= 1 << index
        else:
            self.config[0] &= ~(1 << index)

    def send_ctrl(self):
        try:
            self.io.write(self.config, 0, 1)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()

    def reset_fifo(self):
        try:
            self.io.edge(0, 0, True, 0)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()

    def send_data(self):
        size = self.receivers * 6 + 2
        n = 504 // size

        try:
            self.io.read(self.status, 1, 0)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()
            return

        cntr = self.status[0]
        if cntr >= 4096:
            self.logViewer.appendPlainText("FIFO buffer overflow")
            self.reset_fifo()
            return

        m = cntr // (n * 2)

        if m < 1:
            return

        view = self.samples[: m * n * 96]

        try:
            self.io.read(view, 2, 0)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()
            return

        self.counter.view(np.uint32)[0] += 1
        self.buffer[4:8] = np.flip(self.counter)

        offset = 0
        src_slice = np.mod(np.arange(48 * n), 48) < size - 2
        dst_slice = np.mod(np.arange(size * n), size) < size - 2
        for i in range(m):
            self.buffer[8:16] = self.header[self.offset]
            self.offset += 1
            if self.offset > 4:
                self.offset = 0

            src = self.samples[offset : offset + 48 * n]
            dst = self.buffer[16 : 16 + size * n]
            dst[dst_slice] = src[src_slice]
            offset += 48 * n

            self.buffer[520:528] = self.header[self.offset]
            self.offset += 1
            if self.offset > 4:
                self.offset = 0

            src = self.samples[offset : offset + 48 * n]
            dst = self.buffer[528 : 528 + size * n]
            dst[dst_slice] = src[src_slice]
            offset += 48 * n

            self.socket.writeDatagram(self.buffer.tobytes(), self.addr, self.port)


app = QApplication(sys.argv)
window = Server()
window.show()
sys.exit(app.exec_())
