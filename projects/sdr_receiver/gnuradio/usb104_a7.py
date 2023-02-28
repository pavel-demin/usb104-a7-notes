from gnuradio import gr

import numpy as np

from pyhubio import IO

import time


class source(gr.sync_block):
    """USB104 A7 Source"""

    rates = {
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

    def __init__(self, freq, rate, corr):
        gr.sync_block.__init__(
            self, name="usb104_a7_source", in_sig=None, out_sig=[np.complex64]
        )
        self.io = IO()
        self.io.flush()
        self.io.write(np.uint32(source.adc_cfg), 2)
        self.config = np.zeros(4, np.uint32)
        self.status = np.zeros(1, np.uint32)
        self.set_freq(freq, corr)
        self.set_rate(rate)
        self.io.write(self.config, 0, 1)
        self.io.write(np.uint32([1]), 0, 0)

    def work(self, input_items, output_items):
        out = output_items[0]
        self.io.write(self.config, 0, 1)
        self.io.read(self.status, 1)
        cntr = self.status[0]
        if cntr >= 16384:
            print("overflow", cntr)
            self.io.write(np.uint32([0]), 0, 0)
            self.io.write(np.uint32([1]), 0, 0)
            cntr = 0
        while cntr < out.size * 2:
            time.sleep(0.0005)
            self.io.read(self.status, 1)
            cntr = self.status[0]
        self.io.read(out, 2)
        return out.size

    def set_freq(self, freq, corr):
        value = (1.0 + 1e-6 * corr) * freq
        self.config[2] = np.floor(value / 122.88e6 * (1 << 30) + 0.5)
        self.config[3] = self.config[2] == 0

    def set_rate(self, rate):
        if rate in source.rates:
            self.config[1] = source.rates[rate]
        else:
            raise ValueError(
                "acceptable sample rates are 24k, 48k, 96k, 192k, 384k, 768k, 1536k"
            )
