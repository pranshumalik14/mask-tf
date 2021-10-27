# Prints info on available microphones
# Example run command: python3 info.py

import pyaudio

audio = pyaudio.PyAudio()

num_devices = audio.get_device_count()
print(f"{num_devices} audio devices available")

print()
print("Default input device:")
print("- " + str(audio.get_default_input_device_info()))

print()
print("All devices:")
for i in range(num_devices):
    info = audio.get_device_info_by_index(i)
    index = info["index"]
    name = info["name"]
    print("- Device %d (%s): %s" % (index, name, str(info)))
