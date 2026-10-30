"""Print the CoCo 1/2 32x16 text screen from an XRoar snapshot.
Finds the screen by the marker 'ZQX' the test program prints at the top-left."""
import sys, os
p = sys.argv[1]
if not os.path.exists(p):
    sys.exit("NO SNAPSHOT: the program never reached the EXEC &H7FF0 trap (crash, hang or error)")
d = open(p, 'rb').read()
i = d.find(b'ZQX')
if i < 0: sys.exit("marker ZQX not found on screen")
s = d[i:i + 512]
dec = lambda b: chr((b & 0x3F) + 64) if (b & 0x3F) < 32 else chr(b & 0x3F)
for r in range(16):
    line = ''.join(dec(b) for b in s[r*32:r*32+32]).rstrip()
    if line: print(line)
