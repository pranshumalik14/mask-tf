close all
clear all

folder = "initial_mask_compare_recordings";

Files=dir(folder + "/*.wav");
for k=1:length(Files)
    FileName=strrep(Files(k).name, ".wav", "")

    % Get time domain data
    [data, fs] = audioread(folder + "/" + FileName + ".wav");
    t = linspace(0,length(data)/fs, length(data))';

    % Plot time domain
%     figure;
%     plot(t,data,'-g');
%     title(FileName + " Time");

    % Get FFT data
    N=length(t);
    data_fft = fftshift(fft(data));
    dF=fs/N;
    f=-fs/2:dF:fs/2-dF;

    % Plot FFT
    figure;
    plot  (f(f >= 0), abs(data_fft(f >= 0,1)), '-b');
%     loglog(f(f >= 0), abs(data_fft(f >= 0,1)), '-b');
    title(FileName + " FFT");
    saveas(gcf, folder + "/" + FileName + ".png");

    % Save data to file
    save(folder + "/" + FileName, "fs", "data_fft");
end
