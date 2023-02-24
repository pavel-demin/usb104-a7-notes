from pyftdi.ftdi import Ftdi

import numpy as np

device = Ftdi()

device.open(vendor=0x0403, product=0x6014)

device.set_bitmode(0xFF, Ftdi.BitMode.RESET)
device.set_bitmode(0xFF, Ftdi.BitMode.SYNCFF)

device.purge_buffers()

data = np.zeros(2, dtype=np.uint64)

data[:] = [(1 << 56) + 0xAAAAAA, (1 << 56) + 0x555555]

device.write_data(data.tobytes())
