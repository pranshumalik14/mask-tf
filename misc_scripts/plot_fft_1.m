close all
clear all

[data, fs] = audioread('bruno_mic_test_recordings_1027/ba-headset-2000Hz-default.wav');
t = linspace(0,length(data)/fs, length(data))';
plot(t,data)

N=length(t)

data_fft = fftshift(fft(data));
dF=fs/N
f=-fs/2:dF:fs/2-dF;
% f = linspace(0,length(data_fft)/fs, length(data_fft));
plot(f, abs(data_fft(:,1)/N))
