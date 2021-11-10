%% mic calibration
clear all;
close all;
clc;

[mic_1, Fs_1] = audioread('../recordings/mic_calib/white_calib_1.wav');
[mic_2, Fs_2] = audioread('../recordings/mic_calib/white_calib_2.m4a');

fmax  = 7500;
nbins = 1000;

% get calibration tf from mic 1 (input) to match mic 2 (output) recording
[tf_calib, fr_bins] = get_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins);

% apply tf to mic 1 FFT
M_1 = fftshift(fft(mic_1));
M_2 = fftshift(fft(mic_2));
N_1 = length(M_1);
N_2 = length(M_2);
df_1  = Fs_1/N_1;
df_2  = Fs_2/N_2;
fr_1  = -Fs_1/2:df_1:Fs_1/2-df_1;
fr_2  = -Fs_2/2:df_2:Fs_2/2-df_2;

idx_1 = fr_1(-fmax < fr_1 & fr_1 < fmax); idx_1 = round([(idx_1(1)-fr_1(1))/df_1 (idx_1(end)-fr_1(1))/df_1]);
idx_2 = fr_2(-fmax < fr_2 & fr_2 < fmax); idx_2 = round([(idx_2(1)-fr_2(1))/df_2 (idx_2(end)-fr_2(1))/df_2]);

for k = idx_1(1):idx_1(2)
    M_1(k) = apply_tf(fr_1(k), M_1(k), tf_calib, fmax, nbins);
end

% truncate FFTs after application of tf for (close-to) identical reconstruction within fmax
M_1(1:idx_1(1)-1) = 0;
M_1(idx_1(2)+1:end) = 0;
M_2(1:idx_2(1)-1) = 0;
M_2(idx_2(2)+1:end) = 0;

%% estimating mask tf
% step 1: get mask tf mic recordings
% step 2a: apply tf_calib to mic 1 to get comparable recording to mic 2
% step 2b: trim ffts after fmax and invert to get mic time-domain
% step 3: get tf estimate for calibrated and truncated spectra signals
% step 4: repeat for all recordings and average tf over all of them

% recording 1
[mic_1, Fs_1] = audioread('../recordings/mask_tf_estimate/mask_tf_1_1_trimmed.wav');
[mic_2, Fs_2] = audioread('../recordings/mask_tf_estimate/mask_tf_1_2_trimmed.m4a');

% calibrate mic 1 to mic 2
M_1 = fftshift(fft(mic_1));
M_2 = fftshift(fft(mic_2));
N_1 = length(M_1);
N_2 = length(M_2);
df_1  = Fs_1/N_1;
df_2  = Fs_2/N_2;
fr_1  = -Fs_1/2:df_1:Fs_1/2-df_1;
fr_2  = -Fs_2/2:df_2:Fs_2/2-df_2;

idx_1 = fr_1(-fmax < fr_1 & fr_1 < fmax); idx_1 = round([(idx_1(1)-fr_1(1))/df_1 (idx_1(end)-fr_1(1))/df_1]);
idx_2 = fr_2(-fmax < fr_2 & fr_2 < fmax); idx_2 = round([(idx_2(1)-fr_2(1))/df_2 (idx_2(end)-fr_2(1))/df_2]);

% apply calibration function to mic 1 recording
for k = idx_1(1):idx_1(2)
    M_1(k) = apply_tf(fr_1(k), M_1(k), tf_calib, fmax, nbins);
end

% truncate FFTs after application of tf for (close-to) identical reconstruction within fmax
M_1(1:idx_1(1)-1) = 0;
M_1(idx_1(2)+1:end) = 0;
M_2(1:idx_2(1)-1) = 0;
M_2(idx_2(2)+1:end) = 0;

% invert FFTs to time domain
mic_1_inv = ifft(ifftshift(M_1));
mic_2_inv = ifft(ifftshift(M_2));

% get tf estimate for mic 1 and mic 2 (after calibration)
[tf_mask_1, fr_bins] = get_tf_estimate(mic_1_inv, mic_2_inv, Fs_1, Fs_2, fmax, nbins);

%% tf apply helper function

function scaled_mag = apply_tf(f, mag, tf, fmax, nbins)
    if abs(f) > fmax
        scaled_mag = 0;
    else
        scaled_mag = mag * tf(floor(abs(f)/(fmax/nbins)) + 1);
    end
end
