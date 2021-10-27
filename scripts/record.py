# Records and saves audio from one or more microphones
# Based on https://gist.github.com/mabdrabo/8678538

# Example run command: python3 record.py -d 4 2 -f 400hz

# Need to find audio device index/indices using the info.py script before
# running this script
# If the script produces the error "OSError: [Errno -9981] Input overflowed",
# try reversing the order of the device index command line arguments to fix the
# error

import argparse
import pyaudio
import wave

FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
CHUNK = 1024    # Number of audio samples in buffer
RECORD_SECONDS = 10

# Get command line input arguments
parser = argparse.ArgumentParser(description=("Audio recording"))
# nargs specifies the number of arguments, with "+" inserting arguments of that
# type into a list
parser.add_argument("-d", "--device", required=True, nargs="+", metavar=("device"),
                    help="Device index/indices for microphone(s) to record from")
parser.add_argument("-f", "--file", required=True, metavar=("file"),
                    help="File name prefix for recording files")

args = parser.parse_args()
device_indices = list(map(int, args.device))   # This is a list of integers
num_devices = len(device_indices)
file_prefix = args.file

audio = pyaudio.PyAudio()

# Start recording for each microphone
streams = []
for i in range(num_devices):
    device_index = device_indices[i]
    # See Stream.__init__() for argument descriptions
    streams.append(audio.open(format=FORMAT, channels=CHANNELS,
                              rate=RATE, input=True,
                              input_device_index=device_index,
                              frames_per_buffer=CHUNK))
    print(f"Opened stream for device index {device_index}")
print("Recording...")

# Save audio samples while recording
frames = [[] for i in range(num_devices)]
print("Press Ctrl-C at any time to stop recording")
try:
    for t in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        for i in range(num_devices):
            data = streams[i].read(CHUNK)
            frames[i].append(data)
except KeyboardInterrupt:
    print("Finished recording")

# Stop recording
for i in range(num_devices):
    device_index = device_indices[i]
    streams[i].stop_stream()
    streams[i].close()
    print(f"Closed stream for device index {device_index}")

# Write audio to files
for i in range(num_devices):
    device_index = device_indices[i]

    info = audio.get_device_info_by_index(device_index)
    device_name = info["name"].replace(" ", "")  # Remove spaces for file name
    file_name = file_prefix + "-" + device_name + ".wav"

    wave_file = wave.open(file_name, "wb")
    wave_file.setnchannels(CHANNELS)
    wave_file.setsampwidth(audio.get_sample_size(FORMAT))
    wave_file.setframerate(RATE)
    wave_file.writeframes(b"".join(frames[i]))
    wave_file.close()
    print(
        f"Wrote recording for device index {device_index} to file {file_name}")

audio.terminate()
