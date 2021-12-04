# https://stackoverflow.com/questions/23377665/python-scipy-fft-wav-files

import glob
import matplotlib.pyplot as plt
from scipy.io import wavfile  # get the api
from scipy.fftpack import fft
from pylab import *

BITS_PER_SAMPLE = 16.


def f(filename):
    fs, data = wavfile.read(filename)  # load the data
    a = data.T
    # this is 16-bit track (depending on BITS_PER_SAMPLE), b is now normalized on [-1,1)
    b = [(ele/2**BITS_PER_SAMPLE)*2-1 for ele in a]
    c = fft(b)     # create a list of complex number
    d = len(c)//2  # you only need half of the fft list
    plt.plot(abs(c[1:(d-1)]), 'r')
    savefig(filename+'.png', bbox_inches='tight')


files = glob.glob(
    '/home/pranshumalik14/Documents/projects/mask-tf/recordings/mic_test/*.wav')
for ele in files:
    print(ele)
    f(ele)
quit()
