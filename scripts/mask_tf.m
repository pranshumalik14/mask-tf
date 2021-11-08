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

idx_1 = fr_1(-fmax < fr_1 & fr_1 < fmax); idx_1 = [(idx_1(1)-fr_1(1))/df_1 (idx_1(end)-fr_1(1))/df_1];
idx_2 = fr_2(-fmax < fr_2 & fr_2 < fmax); idx_2 = [(idx_2(1)-fr_2(1))/df_2 (idx_2(end)-fr_2(1))/df_2];

for k = idx_1(1):idx_1(2)
    M_1(k) = apply_tf(fr_1(k), M_1(k), tf, fmax, nbins);
end

M_1(1:idx_1(1)-1) = 0;
M_1(idx_1(2)+1:end) = 0;
M_2(1:idx_2(1)-1) = 0;
M_2(idx_2(2)+1:end) = 0;

%%

%%

function scaled_mag = apply_tf(f, mag, tf, fmax, nbins)
    if abs(f) > fmax
        scaled_mag = 0;
    else
        scaled_mag = mag * tf(floor(abs(f)/floor(fmax/nbins)) + 1);
    end
end
