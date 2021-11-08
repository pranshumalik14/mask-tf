%% mic calibration

[mic_1, Fs_1] = audioread('../recordings/mic_calib/white_calib_1.wav');
[mic_2, Fs_2] = audioread('../recordings/mic_calib/white_calib_2.m4a');

get_tf_estimate(mic_1, mic_2, Fs_1, Fs_2, 11000, 20);

%%
