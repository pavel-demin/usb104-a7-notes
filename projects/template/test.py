from pyhubio import PyhubIO, PyhubJTAG
import numpy as np
import pylab as pl
import time

adc_cfg = [
    0x00003C,
    0x000803,
    0x000800,
    0x000502,
    0x001421,
    0x000501,
    0x001431,
]

io = PyhubIO()
jtag = PyhubJTAG()

# program FPGA
jtag.program("template.bit")
time.sleep(0.1)

# start IO
io.start()
io.flush()

# configure ADC
io.write(np.uint32(adc_cfg), 2, 0)
time.sleep(0.1)

# initialize variables
size = 131072
buffer = np.zeros(size * 2, np.int16)
status = np.zeros(1, np.uint32)

# reset FIFO buffer
io.edge(0, 1, True, 0)

# wait for FIFO buffer to become full
io.read(status, 1, 0)
while status[0] < size:
    time.sleep(0.1)
    io.read(status, 1, 0)

# read ADC samples
io.read(buffer, 2, 0)

# plot ADC samples separately for two channels
ch1 = buffer[0::2]
ch2 = buffer[1::2]

pl.figure(figsize=[8, 4], dpi=150, constrained_layout=True)

pl.plot(ch1)
pl.plot(ch2)

pl.xlabel("sample number")
pl.ylabel("ADC units")

pl.ylim(-9000, 9000)
pl.grid()

pl.show()
