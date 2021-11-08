%% mic calibration
clear all;
close all;
clc;

[mic_1, Fs_1] = audioread('../recordings/mic_calib/white_calib_1.wav');
[mic_2, Fs_2] = audioread('../recordings/mic_calib/white_calib_2.m4a');

fmax  = 8000;
nbins = 100;
[tf, fr_bins] = get_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins);

% apply tf to mic 1
M_1 = fftshift(fft(mic_1));
M_2 = fftshift(fft(mic_2));
N_1 = length(M_1);
N_2 = length(M_2);
df_1  = Fs_1/N_1;
df_2  = Fs_2/N_2;
fr_1  = -Fs_1/2:df_1:Fs_1/2-df_1;
fr_2  = -Fs_2/2:df_2:Fs_2/2-df_2;

for k = N_1/2:N_1/2+ceil(fmax/df_1)
    M_1(k) = apply_tf(fr_1(k), M_1(k), tf, fmax, nbins);
end

% clip the tf for mic 2 after fmax as well

%%

%%

function scaled_mag = apply_tf(f, mag, tf, fmax, nbins)
    if abs(f) > fmax
        scaled_mag = 0;
    else
        scaled_mag = mag * tf(floor(abs(f)/floor(fmax/nbins)) + 1);
    end
end
