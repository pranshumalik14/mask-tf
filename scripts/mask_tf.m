%% mic calibration
clear all;
close all;
clc;

[mic_1, Fs_1] = audioread('../recordings/mic_calib/white_calib_1.wav');
[mic_2, Fs_2] = audioread('../recordings/mic_calib/white_calib_2.m4a');

fmax  = 7500;
nbins = 1000;

% get calibration tf from mic 1 (input) to match mic 2 (output) recording
[tf_calib, ~, fr_bins] = get_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins);

[mic_1_calib, mic_2_calib] = calib_mics(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);

%% estimating mask tf
% step 1: get mask tf mic recordings
% step 2a: apply tf_calib to mic 1 to get comparable recording to mic 2
% step 2b: trim ffts after fmax and invert to get mic time-domain
% step 3: get tf estimate for calibrated and truncated spectra signals
% step 4: repeat for all recordings and average tf over all of them

% recording 1 tf
[mic_1, Fs_1]  = audioread('../recordings/mask_tf_estimate/mask_tf_1_1_trimmed.wav');
[mic_2, Fs_2]  = audioread('../recordings/mask_tf_estimate/mask_tf_1_2_trimmed.m4a');
[tf_mask_1, phs_mask_1, ~] = get_mask_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);

% recording 2 tf
[mic_1, Fs_1]  = audioread('../recordings/mask_tf_estimate/mask_tf_2_1_trimmed.wav');
[mic_2, Fs_2]  = audioread('../recordings/mask_tf_estimate/mask_tf_2_2_trimmed.m4a');
[tf_mask_2, phs_mask_2, ~] = get_mask_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);

% recording 3 tf
[mic_1, Fs_1]  = audioread('../recordings/mask_tf_estimate/mask_tf_3_1_trimmed.wav');
[mic_2, Fs_2]  = audioread('../recordings/mask_tf_estimate/mask_tf_3_2_trimmed.m4a');
[tf_mask_3, phs_mask_3, ~] = get_mask_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);

% average tf over all recordings
tf_mask_avg  = smooth((tf_mask_1 + tf_mask_2 + tf_mask_3)/3);
phs_mask_avg = smooth((phs_mask_1 + phs_mask_2 + phs_mask_3)/3);

% plot tf avg
figure;
stairs(fr_bins, tf_mask_avg);
title('Estimated Avg TF');

figure;
stairs(fr_bins, phs_mask_avg); % wrapTo2Pi
title('Estimated Avg Phase Response');

%% apply tf to a non-masked recording

% compare low context speech and see if we get a similar response
[unmask_all_codes, Fs_um_1]  = audioread('../recordings/postal_codes/all_postal_codes_unmasked_trimmed.m4a');
[mask_all_codes, Fs_m_1]     = audioread('../recordings/postal_codes/all_postal_codes_masked_trimmed.m4a');

[unmask_tfapp_all_codes, mask_trunc_all_codes] = calib_mics(unmask_all_codes, mask_all_codes, Fs_um_1, Fs_m_1, fmax, nbins, tf_mask_avg);
[post_tf_all_postal_codes, ~, ~] = get_tf_estimate(unmask_tfapp_all_codes, mask_trunc_all_codes, Fs_um_1, Fs_m_1, fmax, nbins);

% check if ffts of mic_1 and mic_2 match each other
UM_all_codes = fftshift(fft(unmask_all_codes));
M_all_codes = fftshift(fft(mask_all_codes));
figure;
plot(abs(UM_all_codes));
figure;
plot(abs(M_all_codes));

UM_tfapp_all_codes = fftshift(fft(unmask_tfapp_all_codes));
M_trunc_all_codes = fftshift(fft(mask_trunc_all_codes));
figure;
plot(abs(UM_tfapp_all_codes));
figure;
plot(abs(M_trunc_all_codes));

%% test difference in sound

% original recordings
sound(rescale(real(unmask_all_codes), -1, 1), Fs_um_1);
sound(rescale(real(mask_all_codes), -1, 1), Fs_m_1);

pause(16);

% transfer function applied
sound(rescale(real(unmask_tfapp_all_codes), -1, 1), Fs_um_1);
sound(rescale(real(mask_trunc_all_codes), -1, 1), Fs_m_1);

% save audio
audiowrite('../outputs/tfapp_all_postal_codes_unmasked_trimmed.m4a', rescale(real(unmask_tfapp_all_codes), -1, 1), Fs_um_1);
audiowrite('../outputs/trunc_all_postal_codes_masked_trimmed.m4a', rescale(real(mask_trunc_all_codes), -1, 1), Fs_m_1);

%% invert tf to get un-masked recording

% compare across white noise for testing over a broader band
[mic_1, Fs_1]  = audioread('../recordings/mask_tf_estimate/mask_tf_1_1_trimmed.wav');
[mic_2, Fs_2]  = audioread('../recordings/mask_tf_estimate/mask_tf_1_2_trimmed.m4a');
[mic_1, mic_2] = calib_mics(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);
[mic_2, mic_1] = calib_mics(mic_2, mic_1, Fs_2, Fs_1, fmax, nbins, 1./tf_mask_avg);

% check if ffts of mic_1 and mic_2 match each other
M_1 = fftshift(fft(mic_1));
M_2 = fftshift(fft(mic_2));
figure;
plot(abs(M_1));
figure;
plot(abs(M_2));

%% tf apply helper function

function scaled_mag = apply_tf(f, mag, tf, fmax, nbins)
    if abs(f) > fmax
        scaled_mag = 0;
    else
        scaled_mag = mag * tf(floor(abs(f)/(fmax/nbins)) + 1);
    end
end

%% mic calibration helper function

function [mic_1_calib, mic_2_calib] = calib_mics(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib)
    % get mic recording ffts
    M_1 = fftshift(fft(mic_1));
    M_2 = fftshift(fft(mic_2));
    N_1 = length(M_1);
    N_2 = length(M_2);
    df_1  = Fs_1/N_1;
    df_2  = Fs_2/N_2;
    fr_1  = -Fs_1/2:df_1:Fs_1/2-df_1;
    fr_2  = -Fs_2/2:df_2:Fs_2/2-df_2;

    % indices/bounds for calibration and truncation
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
    mic_1_calib = ifft(ifftshift(M_1));
    mic_2_calib = ifft(ifftshift(M_2));
end

%% mask tf estimate helper function (with calibration)

function [tf_mask, phs_estimate, fr_bins] = get_mask_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib)
    % calibrate mic 1 to mic 2
    [mic_1, mic_2] = calib_mics(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins, tf_calib);

    % get tf estimate for mic 1 and mic 2 (after calibration)
    [tf_mask, phs_estimate, fr_bins] = get_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, fmax, nbins);
end
