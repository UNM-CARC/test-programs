#!/usr/bin/env python3
import sys

steps = int(sys.argv[1])
if steps <= 0:
    raise SystemExit("steps must be positive")

inside = 0
for i in range(steps):
    x = ((i * 37) % steps) / steps
    y = ((i * 91) % steps) / steps
    if x * x + y * y <= 1.0:
        inside += 1

print(f"steps = {steps} pi = {4.0 * inside / steps:.6f}")
