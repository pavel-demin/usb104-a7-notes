from gnuradio import gr

import numpy as np

from pyftdi.ftdi import Ftdi


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

    dac_cfg = [
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

        self.device = Ftdi()
        self.device.open(vendor=0x0403, product=0x6014)

        self.device.set_bitmode(0xFF, Ftdi.BitMode.RESET)
        self.device.set_bitmode(0xFF, Ftdi.BitMode.SYNCFF)

        self.send_command(0, 0)

        while self.device.read_data(512):
            continue

        self.device.purge_buffers()

        for value in source.dac_cfg:
            self.send_command(1 << 24, value)

        self.set_freq(freq, corr)
        self.set_rate(rate)

        self.send_command(0, 1)

    def work(self, input_items, output_items):
        out = output_items[0]
        view = out.view(np.uint8)
        offset = 0
        limit = view.size
        while offset < limit:
            data = self.device.read_data(limit - offset)
            data = np.frombuffer(data, np.uint8)
            size = data.size
            view[offset : offset + size] = data
            offset += size
        return out.size

    def send_command(self, addr, value):
        command = np.uint64((addr << 32) + value)
        self.device.write_data(command.tobytes())

    def set_freq(self, freq, corr):
        value = (1.0 + 1e-6 * corr) * freq
        self.send_command(3, np.floor(value / 122.88e6 * (1 << 30) + 0.5))
        if value == 0:
            self.send_command(4, 1)
        else:
            self.send_command(4, 0)

    def set_rate(self, rate):
        if rate in source.rates:
            value = source.rates[rate]
            self.send_command(2, value)
        else:
            raise ValueError(
                "acceptable sample rates are 24k, 48k, 96k, 192k, 384k, 768k, 1536k"
            )
