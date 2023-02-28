from pyhubio import PyhubIO
import numpy as np

io = PyhubIO()

data = [0xAAAAAA, 0x555555]

io.write(np.uint32(data), 2)
