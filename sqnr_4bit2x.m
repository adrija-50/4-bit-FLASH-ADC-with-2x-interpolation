num_bits = 5;

% upload the appropriate csv file and uncomment the required 
% file path data table and corresponding input frequency 
% to get the spectrum accordingly

% uncomment the below two lines for 2x interpolated low freq spectrum
% data = lowfreqdata2x.DIG_OUT_SINE_inputY;
% fin = (1/1024)*20000000;    % input low frequency

% uncomment the below two lines for 2x interpolated high freq spectrum
% data = highfreqdata2x.DIG_OUT_SINE_inputY;
% fin = (507/1024)*20000000;    % input high frequency

fs = 20000000;                  %sampling frequency
t = 0:1/fs:1;        
A = 1.8;   
num_levels = 2^num_bits;
step_size = (2 * A) / num_levels;
data = round(data);
size_data = size(data);              % mid- rise quantization
for i = 1:size_data(1)
    if data(i) == 0
        data(i) = step_size-A;        % handle corner cases since 
    elseif data(i) == 29              % only 29 bits could be interpolated
        data(i) = A-step_size;
    else
        data(i) = (data(i)-15)*step_size + step_size/2;
    end
end

N = 1024;                                  % 1024-pt DFT
ft = fft(data, N);
PSD = (2/N^2)*(abs(ft(1:N/2)).^2);         % 1-sided normalized PSD
signal_bin = round(N*fin/fs)+1;
signal_power = PSD(signal_bin);
noise_power = sum(PSD) - signal_power;
sqnr = 10*log10(signal_power/noise_power);
t = 1024*fin*t/(signal_bin-1);
PSD_db = 10*log10(PSD);                    % plot spectrum in dB
figure;
plot(t(1:N/2), PSD_db);
xlabel("N");
ylabel("Power (dB)");
disp(['SQNR = ', num2str(sqnr), ' dB']);