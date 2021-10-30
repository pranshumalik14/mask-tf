close all
clear all

folder = "initial_mask_compare_recordings";

[data1, fs1] = audioread(folder + "/" + "white-default.wav");
t = linspace(0,length(data1)/fs1, length(data1))';

[data2, fs2] = audioread(folder + "/" + "white-mask-default.wav");

[tf, f] = tfestimate(data1, data2, length(data1), [], [], fs1);
figure;
plot(f, mag2db(abs(tf)));
loglog(f, abs(tf));
