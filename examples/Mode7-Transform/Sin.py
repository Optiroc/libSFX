#!/usr/local/bin/python

import sys
import math
import struct

steps = 256

try:
    fname = sys.argv[1]
    f = open(fname, 'wb')
    for x in range(0, steps):
        sine = int(127.5 * math.sin(math.radians(float(x) * (360.0 / float(steps)))))
        f.write(struct.pack('b', sine))
    f.close()

except Exception as e:
    sys.exit(e)
