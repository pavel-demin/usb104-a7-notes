from pyhubio import PyhubIO
import numpy as np
import time

io = PyhubIO()

for i in range(11):
    io.write(np.uint32([i % 2]), 0)
    time.sleep(0.5)
