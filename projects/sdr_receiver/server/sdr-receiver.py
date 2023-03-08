#!/usr/bin/env python3

import sys
import time

import zmq

import numpy as np

from pyhubio import PyhubIO, PyhubJTAG

from PySide2.QtUiTools import loadUiType
from PySide2.QtCore import QTimer, QSocketNotifier
from PySide2.QtWidgets import QApplication, QMainWindow

Ui_Server, QMainWindow = loadUiType("sdr-receiver.ui")


class Server(QMainWindow, Ui_Server):
    bitstream = "sdr_receiver.bit"
    rate_map = {
        24000: 2560,
        48000: 1280,
        96000: 640,
        192000: 320,
        384000: 160,
        768000: 80,
        1536000: 40,
    }
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
        self.samples = np.zeros(16384, np.uint32)
        self.config = np.zeros(4, np.uint32)
        self.status = np.zeros(1, np.uint32)
        self.config[1] = 5120
        # create controls
        self.startButton.clicked.connect(self.start)
        self.inputBox.addItems(["CH1", "CH2"])
        self.inputBox.currentIndexChanged.connect(self.update_input)
        # create IO
        self.jtag = PyhubJTAG()
        self.io = PyhubIO()
        # create ZMQ sockets
        context = zmq.Context()
        self.dataSocket = context.socket(zmq.PUB)
        self.dataSocket.bind("tcp://127.0.0.1:10001")
        self.ctrlSocket = context.socket(zmq.SUB)
        fd = self.ctrlSocket.getsockopt(zmq.FD)
        self.ctrlNotifier = QSocketNotifier(fd, QSocketNotifier.Read, self)
        self.ctrlNotifier.activated.connect(self.read_ctrl)
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
                self.io.write(np.uint32(self.adc_cfg), 2, 0)
            except:
                self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
                self.startButton.setEnabled(True)
                return
            self.reset_fifo()
            self.ctrlSocket.connect("tcp://127.0.0.1:10002")
            self.ctrlSocket.setsockopt(zmq.SUBSCRIBE, b"")
            self.dataTimer.start(5)
            self.ctrlTimer.start(100)
            self.startButton.setText("Stop")
            self.logViewer.appendPlainText("server started")
            self.idle = False
        else:
            self.config.fill(0)
            self.config[1] = 5120
            self.dataTimer.stop()
            self.ctrlTimer.stop()
            self.ctrlSocket.disconnect("tcp://127.0.0.1:10002")
            self.io.stop()
            self.startButton.setText("Start")
            self.logViewer.appendPlainText("server stopped")
            self.idle = True
        self.startButton.setEnabled(True)

    def read_ctrl(self):
        self.ctrlNotifier.setEnabled(False)
        buffer = None
        flags = self.ctrlSocket.getsockopt(zmq.EVENTS)
        while flags:
            if flags & zmq.POLLIN:
                buffer = self.ctrlSocket.recv()
            flags = self.ctrlSocket.getsockopt(zmq.EVENTS)
        if buffer and len(buffer) == 8:
            data = np.frombuffer(buffer, np.uint32)
            self.update_config(data)
        self.ctrlNotifier.setEnabled(True)

    def update_config(self, data):
        rate = data[0]
        if rate in self.rate_map:
            value = self.rate_map[rate]
            if self.config[1] != value:
                self.config[1] = value
                self.logViewer.appendPlainText("sample rate: %d kS/s" % (rate // 1000))
        freq = data[1]
        value = np.floor(freq / 122.88e6 * (1 << 30) + 0.5)
        if self.config[2] != value:
            self.config[2] = value
            self.config[3] = self.config[2] == 0
            self.logViewer.appendPlainText("RX frequency: %d Hz" % freq)

    def update_input(self, value):
        self.config[0] = value > 0

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
        try:
            self.io.read(self.status, 1, 0)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()
            return

        cntr = self.status[0]
        if cntr >= 32768:
            self.logViewer.appendPlainText("FIFO buffer overflow")
            self.reset_fifo()
            return

        m = cntr // 256

        if m < 1:
            return

        view = self.samples[: m * 256]

        try:
            self.io.read(view, 2, 0)
        except:
            self.logViewer.appendPlainText("error: %s" % sys.exc_info()[1])
            self.start()
            return

        self.dataSocket.send(view.tobytes())


app = QApplication(sys.argv)
window = Server()
window.show()
sys.exit(app.exec_())
