from pyhubio import PyhubIO
import numpy as np
import time

io = PyhubIO()

io.start()

size = 100000000

input = np.arange(0, size, 1, np.uint32)

output = np.zeros(size, np.uint32)

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

f = open("output.dat", "wb")

before = time.time()
io.read(output, 2)
after = time.time()

f.write(output.tobytes())
f.close()

duration = after - before
speed = input.view(np.uint8).size / duration

print("time, s:", np.format_float_positional(duration, precision=1))
print("speed, MB/s:", np.format_float_positional(speed / 2**20, precision=1))
