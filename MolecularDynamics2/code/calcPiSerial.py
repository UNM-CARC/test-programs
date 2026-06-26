#!/usr/bin/env python3
import math
import sys


def approximate_pi(steps):
    width = 1.0 / steps
    total = 0.0
    for i in range(steps):
        x = (i + 0.5) * width
        total += 4.0 / (1.0 + x * x)
    return total * width


if __name__ == "__main__":
    nsteps = int(sys.argv[1])
    pi_value = approximate_pi(nsteps)
    error = abs(math.pi - pi_value)
    print(f"steps={nsteps} pi={pi_value:.12f} error={error:.3e}")
