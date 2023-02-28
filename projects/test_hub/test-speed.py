from pyhubio import PyhubIO
import numpy as np
import time

io = PyhubIO()

data = np.arange(67108864, dtype=np.uint32)

buffer = np.zeros(4096, np.uint32)

parts = np.split(data, np.arange(4096, data.size, 4096))

f = open("input.dat", "wb")
f.write(data.tobytes())
f.close()

before = time.time()

f = open("output.dat", "wb")

for p in parts:
    io.write(p, 3)
    io.read(buffer, 3)
    f.write(buffer.tobytes())

f.close()

after = time.time()

duration = after - before
speed = data.view(np.uint8).size / duration

print("time, s:", np.format_float_positional(duration, precision=1))
print("speed, MB/s:", np.format_float_positional(speed / 2**20, precision=1))
