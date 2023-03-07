from pyhubio import PyhubIO
import numpy as np

io = PyhubIO()

io.start()

data = np.arange(131072, dtype=np.uint32)

buffer = np.zeros(131072, np.uint32)

f = open("input.dat", "wb")
f.write(data.tobytes())
f.close()

io.write(data, 4)

io.read(buffer, 4, 0)

f = open("output.dat", "wb")
f.write(buffer.tobytes())
f.close()
