from pyhubio import PyhubJTAG
import sys

if len(sys.argv) != 2:
    print("Usage: program.py path", file=sys.stderr)
    print(" path - path to bistream file", file=sys.stderr)
    sys.exit(1)

jtag = PyhubJTAG()
jtag.start()
jtag.flush()
jtag.setup()
jtag.idle()
jtag.program(sys.argv[1])
