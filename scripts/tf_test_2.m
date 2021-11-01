close all
clear all

folder = "initial_mask_compare_recordings";

[data1, fs1] = audioread(folder + "/" + "white-default.wav");
[data2, fs2] = audioread(folder + "/" + "white-mask-default.wav");

% f is a vector of frequencies (in Hz) from 0 to fs1/2
[tf, f] = tfestimate(data1, data2, [], [], [], fs1);

figure;
plot(f, abs(tf));

figure;
loglog(f, abs(tf));
