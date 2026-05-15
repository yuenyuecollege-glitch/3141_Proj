% MATLAB Script for Color Image 2D DCT Encoding using YCbCr
clear; clc; close all;

% Read the input image
[I_rgb, map] = imread('inputs/train_low_res.png'); 

if ~isempty(map)
    I_rgb = ind2rgb(I_rgb, map); % Converts to M-by-N-by-3 double array [0,1]
end

figure(1);
imshow(I_rgb);

% Construct meshgrid of scale values
scales = linspace(2, 400, 20);

compression_percent = zeros(size(scales));
sse = zeros(size(scales));

fprintf("Total columns: %d\n", length(scales));

for a = 1:length(scales)
    [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr( ...
        I_rgb, ...
        scales(a), ...
        scales(a), ...
        8, ...
        0 ...
    );

    total_coefficients = 3 * prod(size(dct_Y));
    total_zero_coefficients = sum(dct_Y == 0, 'all') + sum(dct_Cb == 0, 'all') + sum(dct_Cr == 0, 'all');

    percent = total_zero_coefficients / total_coefficients * 100;
    compression_percent(a) = percent;
    
    output_img = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, scales(a), scales(a), 8, 0);
    trimmed_output_img = output_img(1:size(I_rgb, 1), 1:size(I_rgb, 2), :);

    diff = im2double(I_rgb) - trimmed_output_img;
    sse(a) = sum(diff(:).^2);
end

figure(2);
yyaxis left;
plot(scales, sse);
ylabel("SSE")

yyaxis right;
plot(scales, compression_percent);
ylabel("Compression (%)")

xlabel("Scale");
title("Compression and SSE vs scale")