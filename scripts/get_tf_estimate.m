% returns an avg tf estimate; uniform bins
function [tf_estimate, phs_estimate, fr_bins] = get_tf_estimate(audio_in, audio_out, Fs_in, Fs_out, fmax, nbins)

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
phs_avg_in  = zeros(1, nbins);
phs_avg_out = zeros(1, nbins);

for k = 1:nbins
    fft_avg_in(k) = sum(abs(fft_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1))))/length(fr_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1)));
    phs_avg_in(k) = sum(angle(fft_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1))))/length(fr_in(fr_bins(k) < fr_in & fr_in < fr_bins(k+1)));
end
fft_avg_in = [fft_avg_in fft_avg_in(end)]; % concatenate end value till end of freq range
phs_avg_in = [phs_avg_in phs_avg_in(end)];

for k = 1:nbins
    fft_avg_out(k) = sum(abs(fft_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1))))/length(fr_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1)));
    phs_avg_out(k) = sum(angle(fft_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1))))/length(fr_out(fr_bins(k) < fr_out & fr_out < fr_bins(k+1)));
end
fft_avg_out = [fft_avg_out fft_avg_out(end)]; % concatenate end value till end of freq range
phs_avg_out = [phs_avg_out phs_avg_out(end)];

% estimate transfer function
tf_estimate  = fft_avg_out./fft_avg_in;
phs_estimate = phs_avg_out - phs_avg_in;

% ffts and plots
% figure;
% plot(fr_in, abs(fft_in));
% title('Input FFT');
% 
% figure;
% plot(fr_out, abs(fft_out));
% title('Output FFT');
% 
% figure;
% stairs(fr_bins, fft_avg_in);
% title('Input FFT, Averaged Over Bins');
% 
% figure;
% stairs(fr_bins, fft_avg_out);
% title('Output FFT, Averaged Over Bins');
% 
% figure;
% stairs(fr_bins, tf_estimate);
% title('Estimated TF Magntiude');
% 
% figure;
% stairs(fr_bins, phs_estimate); % wrapTo2Pi
% title('Estimated TF Phase');

end
