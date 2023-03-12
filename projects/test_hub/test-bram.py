from pyhubio import PyhubIO
import numpy as np

io = PyhubIO()

io.start()

size = 131072

input = np.arange(0, 131072, 1, np.uint32)

output = np.zeros(size, np.uint32)

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

io.write(input, 4)

io.read(output, 4, 0)

f = open("output.dat", "wb")
f.write(output.tobytes())
f.close()
