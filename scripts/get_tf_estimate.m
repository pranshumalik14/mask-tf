% returns an avg tf estimate; uniform bins
function [tf_estimate, fr_bins] = get_tf_estimate(audio_in, audio_out, Fs_in, Fs_out, fmax, nbins)

fft_in  = fftshift(fft(audio_in));
fft_out = fftshift(fft(audio_out));

% signal lengths
N_in  = length(fft_in);
N_out = length(fft_out);

% frequency range and increments
df_in  = Fs_in/N_in;         
df_out = Fs_out/N_out;
fr_in  = -Fs_in/2:df_in:Fs_in/2-df_in;
fr_out = -Fs_out/2:df_out:Fs_out/2-df_out;

% tf sampling intervals
df_bin   = fmax/nbins;
fr_bins  = 0:df_bin:fmax;

% get average over the bins
fft_avg_in  = zeros(1, nbins);
fft_avg_out = zeros(1, nbins);

for k = 1:nbins
    fft_avg_in(k) = sum(abs(fft_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1))))/length(fr_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1)));
end
fft_avg_in = [fft_avg_in fft_avg_in(end)]; % concatenate end value till end of freq range

for k = 1:nbins
    fft_avg_out(k) = sum(abs(fft_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1))))/length(fr_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1)));
end
fft_avg_out = [fft_avg_out fft_avg_out(end)]; % concatenate end value till end of freq range

% estimate transfer function
tf_estimate = fft_avg_out./fft_avg_in;

% Fs_sub = 8000;                    % sub-sampling frequency, in hertz
% N_sub  = floor(dur*Fs_sub);       % number of points in sub-sampled signal
% t_sub  = linspace(0, dur, N_sub); % time range
% dt = seglen/fs;        % dt per column
% t  = 0:T*dt:N/fs;      % time range
% fr = fs/2:-F*df:0;     % frequency range

% ffts and plots
figure;
plot(fr_in, abs(fft_in));

figure;
plot(fr_out, abs(fft_out));

figure;
stairs(fr_bins, fft_avg_in);

figure;
stairs(fr_bins, fft_avg_out);

figure;
stairs(fr_bins, tf_estimate);

end

