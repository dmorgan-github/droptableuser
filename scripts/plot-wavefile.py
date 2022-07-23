import matplotlib.pyplot as plt
import numpy as np
import sys
from scipy.io import wavfile
import scipy.io

sr, data  = wavfile.read("SC_220627_181122-8-chan.wav", "r")
plt.plot(data)
plt.show()
