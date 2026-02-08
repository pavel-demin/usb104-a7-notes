from pyhubio import PyhubJTAG
import numpy as np

jtag = PyhubJTAG()

jtag.start()
jtag.flush()
jtag.setup()
jtag.idle()

size = 131072

input = np.arange(0, size, 1, np.uint32)

output = np.zeros(size, np.uint32)

f = open("input.dat", "wb")
f.write(input.tobytes())
f.close()

jtag.write(input, port=4, addr=0)

jtag.read(output, port=4, addr=0)

f = open("output.dat", "wb")
f.write(output.tobytes())
f.close()
