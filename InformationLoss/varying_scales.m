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
[c_scale, y_scale] = meshgrid(0:0.1:2);

compression_percent = zeros(size(c_scale));
mse = zeros(size(c_scale));

fprintf("Total columns: %d\n", length(c_scale));

for c = 1:length(c_scale(1,:))
    for y = 1:length(y_scale(:, 1))
        [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr( ...
            I_rgb, ...
            y_scale(y, 1), ...
            c_scale(1, c), ...
            8 ...
        );

        total_coefficients = 3 * prod(size(dct_Y));
        total_zero_coefficients = sum(dct_Y == 0, 'all') + sum(dct_Cb == 0, 'all') + sum(dct_Cr == 0, 'all');

        percent = total_zero_coefficients / total_coefficients * 100;
        compression_percent(y, c) = percent;
        
        output_img = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, y_scale(y, 1), c_scale(1, c), 8);
        trimmed_output_img = output_img(1:size(I_rgb, 1), 1:size(I_rgb, 2), :);
        err = immse(I_rgb, im2uint8(trimmed_output_img));
        mse(y, c) = err;
    end

    fprintf('Finished column %d\n', c);
end

figure(2);
surf(c_scale, y_scale, compression_percent);
xlabel("Colour scale");
ylabel("Luminance scale");
zlabel("Percentage zero coefficient");
title("Information loss vs channel scales");

figure(3);
surf(c_scale, y_scale, mse);
xlabel("Colour scale");
ylabel("Luminance scale");
zlabel("MSE");
title("Information loss vs channel scales");

