from pyhubio import PyhubJTAG
import numpy as np
import time

jtag = PyhubJTAG()

jtag.start()
jtag.flush()
jtag.setup()
jtag.idle()

size = 1000000

input = np.arange(0, size, 1, np.uint32)

output = np.zeros(size, np.uint32)

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

f = open("output.dat", "wb")

before = time.time()
jtag.read(output, port=2, addr=0)
after = time.time()

f.write(output.tobytes())
f.close()

duration = after - before
speed = input.view(np.uint8).size / duration

print("time, s:", np.format_float_positional(duration, precision=1))
print("speed, MB/s:", np.format_float_positional(speed / 2**20, precision=1))
