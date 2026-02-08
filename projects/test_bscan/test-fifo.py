from pyhubio import PyhubJTAG
import numpy as np
import time

jtag = PyhubJTAG()

jtag.start()
jtag.flush()
jtag.setup()
jtag.idle()

input = np.arange(0, 2 * 2**20, 1, np.uint32)

output = np.zeros(4096, np.uint32)

parts = np.split(input, np.arange(4096, input.size, 4096))

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

f = open("output.dat", "wb")

before = time.time()

for p in parts:
    jtag.write(p, port=3, addr=0)
    jtag.read(output, port=3, addr=0)
    f.write(output.tobytes())

after = time.time()

f.close()

duration = after - before
speed = input.view(np.uint8).size / duration

print("time, s:", np.format_float_positional(duration, precision=1))
print("speed, MB/s:", np.format_float_positional(speed / 2**20, precision=1))
