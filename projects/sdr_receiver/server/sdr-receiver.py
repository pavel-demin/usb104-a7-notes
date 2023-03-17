#!/usr/bin/env python3

import sys
import time

import zmq

import numpy as np

from pyhubio import PyhubIO, PyhubJTAG

from PySide2.QtUiTools import loadUiType
from PySide2.QtCore import QObject, QThread, QTimer, QSocketNotifier, Signal
from PySide2.QtWidgets import QApplication, QMainWindow

Ui_Server, QMainWindow = loadUiType("sdr-receiver.ui")


class Window(QMainWindow, Ui_Server):
    bitstream = "sdr_receiver.bit"
    update_config = Signal(object)

    def __init__(self):
        super(Window, self).__init__()
        self.setupUi(self)
        # initialize variables
        self.thread = QThread()
        self.server = Server()
        self.server.moveToThread(self.thread)
        self.thread.started.connect(self.server.start)
        self.thread.finished.connect(self.server.stop)
        self.server.stopped.connect(self.stop)
        self.server.print.connect(self.print)
        self.update_config.connect(self.server.update_config)
        # create controls
        self.startButton.clicked.connect(self.start)
        self.inputBox.addItems(["CH1", "CH2"])
        self.inputBox.currentIndexChanged.connect(self.server.update_input)
        # create JTAG
        self.jtag = PyhubJTAG()
        # create control socket
        context = zmq.Context()
        self.ctrlSocket = context.socket(zmq.SUB)
        fd = self.ctrlSocket.getsockopt(zmq.FD)
        self.ctrlNotifier = QSocketNotifier(fd, QSocketNotifier.Read, self)
        self.ctrlNotifier.activated.connect(self.read_ctrl)

    def print(self, text):
        self.logViewer.appendPlainText(text)

    def start(self):
        try:
            self.jtag.program(self.bitstream)
        except:
            self.print("error: %s" % sys.exc_info()[1])
            return
        self.print("FPGA configured")
        time.sleep(0.1)
        self.ctrlSocket.connect("tcp://127.0.0.1:10002")
        self.ctrlSocket.setsockopt(zmq.SUBSCRIBE, b"")
        self.thread.start()
        self.startButton.setText("Stop")
        self.startButton.clicked.disconnect()
        self.startButton.clicked.connect(self.stop)
        self.print("server started")

    def stop(self):
        try:
            self.ctrlSocket.disconnect("tcp://127.0.0.1:10002")
        except:
            pass
        self.thread.quit()
        self.thread.wait()
        self.startButton.setText("Start")
        self.startButton.clicked.disconnect()
        self.startButton.clicked.connect(self.start)
        self.print("server stopped")

    def closeEvent(self, event):
        self.stop()

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
            self.update_config.emit(data)
        self.ctrlNotifier.setEnabled(True)


class Server(QObject):
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
        0x000503,
        0x000803,
        0x000800,
        0x000501,
        0x001431,
        0x000502,
        0x001425,
        0x000500,
        0x002A00,
    ]
    stopped = Signal()
    print = Signal(str)

    def __init__(self):
        super(Server, self).__init__()
        # initialize variables
        self.samples = np.zeros(65536, np.uint32)
        self.config = np.zeros(4, np.uint32)
        self.status = np.zeros(1, np.uint32)
        # create IO
        self.io = PyhubIO()
        # create data socket
        context = zmq.Context()
        self.dataSocket = context.socket(zmq.PUB)
        self.dataSocket.bind("tcp://127.0.0.1:10001")
        # create timers
        self.dataTimer = QTimer(self)
        self.dataTimer.timeout.connect(self.send_data)
        self.ctrlTimer = QTimer(self)
        self.ctrlTimer.timeout.connect(self.send_ctrl)

    def start(self):
        try:
            self.io.start()
            self.io.flush()
            self.io.write(np.uint32(self.adc_cfg), 2, 0)
        except:
            self.print.emit("error: %s" % sys.exc_info()[1])
            self.stopped.emit()
            return
        self.config.fill(0)
        self.config[1] = 5120
        self.reset_fifo()
        self.dataTimer.start(1)
        self.ctrlTimer.start(100)

    def stop(self):
        self.dataTimer.stop()
        self.ctrlTimer.stop()
        self.io.stop()

    def update_config(self, data):
        rate = data[0]
        if rate in self.rate_map:
            value = self.rate_map[rate]
            if self.config[1] != value:
                self.config[1] = value
                self.print.emit("sample rate: %d kS/s" % (rate // 1000))
        freq = data[1]
        value = np.floor(freq / 122.88e6 * (1 << 30) + 0.5)
        if self.config[2] != value:
            self.config[2] = value
            self.config[3] = self.config[2] == 0
            self.print.emit("RX frequency: %d Hz" % freq)

    def update_input(self, value):
        self.config[0] = value > 0

    def send_ctrl(self):
        try:
            self.io.write(self.config, 0, 1)
        except:
            self.print.emit("error: %s" % sys.exc_info()[1])
            self.stopped.emit()

    def reset_fifo(self):
        try:
            self.io.edge(0, 1, True, 0)
        except:
            self.print.emit("error: %s" % sys.exc_info()[1])
            self.stopped.emit()

    def send_data(self):
        try:
            self.io.read(self.status, 1, 0)
        except:
            self.print.emit("error: %s" % sys.exc_info()[1])
            self.stopped.emit()
            return

        cntr = self.status[0]
        if cntr >= 65536:
            self.print.emit("FIFO buffer overflow")
            self.reset_fifo()
            return

        m = cntr // 256

        if m < 1:
            return

        view = self.samples[: m * 256]

        try:
            self.io.read(view, 2, 0)
        except:
            self.print.emit("error: %s" % sys.exc_info()[1])
            self.stopped.emit()
            return

        self.dataSocket.send(view.tobytes())


app = QApplication(sys.argv)
window = Window()
window.show()
sys.exit(app.exec_())
