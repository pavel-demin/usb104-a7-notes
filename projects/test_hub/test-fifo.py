from pyhubio import PyhubIO
import numpy as np
import time

io = PyhubIO()

io.start()

input = np.arange(0, 64 * 2**20, 1, np.uint32)

output = np.zeros(4096, np.uint32)

parts = np.split(input, np.arange(4096, input.size, 4096))

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

f = open("output.dat", "wb")

before = time.time()

for p in parts:
    io.write(p, 3)
    io.read(output, 3)
    f.write(output.tobytes())

after = time.time()

f.close()

duration = after - before
speed = input.view(np.uint8).size / duration

print("time, s:", np.format_float_positional(duration, precision=1))
print("speed, MB/s:", np.format_float_positional(speed / 2**20, precision=1))
