% MATLAB Script for Color Image 2D DCT Encoding using YCbCr
clear; clc; close all;

% Read the input image
[I_rgb, map] = imread('inputs/train_low_res.png'); 

if ~isempty(map)
    I_rgb = ind2rgb(I_rgb, map); % Converts to M-by-N-by-3 double array [0,1]
end

figure(1);
imshow(I_rgb);

% Set n values to test
n_values = 2:1:90;
compression_percent = zeros(size(n_values));
mse = zeros(size(n_values));

% Calculate information loss
for n=1:length(n_values)
    [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr( ...
        I_rgb, ...
        0, ...
        0, ...
        n_values(n) ...
    );
    
    total_coefficients = 3 * prod(size(dct_Y));
    total_zero_coefficients = sum(dct_Y == 0, 'all') + sum(dct_Cb == 0, 'all') + sum(dct_Cr == 0, 'all');

    percent = total_zero_coefficients / total_coefficients * 100;
    compression_percent(n) = percent;
    fprintf("N value: %d\n", n);

    output_img = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, 0, 0, n_values(n));
    trimmed_output_img = output_img(1:size(I_rgb, 1), 1:size(I_rgb, 2), :);
    err = immse(I_rgb, im2uint8(trimmed_output_img));
    mse(n) = err;
end

figure(2);
title("Information loss vs N value");
xlabel("N value");

yyaxis left;
plot(n_values, compression_percent);
ylabel("Percentage zero coefficient");

yyaxis right;
plot(n_values, mse);
ylabel("MSE");

