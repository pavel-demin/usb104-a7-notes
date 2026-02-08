from pyhubio import PyhubJTAG
import numpy as np
import time

jtag = PyhubJTAG()

jtag.start()
jtag.flush()
jtag.setup()
jtag.idle()

for i in range(11):
    jtag.write(np.uint32([i % 2]), port=0, addr=0)
    time.sleep(0.5)
