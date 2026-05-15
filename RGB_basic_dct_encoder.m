% MATLAB Script for Color Image 2D DCT Encoding using YCbCr
clear; clc; close all;

% 1. Read the color image
% 'peppers.png' is a standard built-in MATLAB color test image
[I_rgb, map] = imread('inputs/marmot.png'); 

if ~isempty(map)
    I_rgb = ind2rgb(I_rgb, map); % Converts to M-by-N-by-3 double array [0,1]
end

figure(1);
imshow(I_rgb);

scale = 2;

B = 8;
useQuantisationMatrix = 1;  % 0=no, 1=yes

[dct_R, dct_G, dct_B] = dct_encoder_rgb( ...
    I_rgb, ...
    scale, ...
    B, ...
    useQuantisationMatrix ...
);

total_coeffs = numel(dct_R) + numel(dct_G) + numel(dct_B);
    
kept_coeffs = nnz(dct_R) + nnz(dct_G) + nnz(dct_B);
removed_coeffs = total_coeffs - kept_coeffs;

compression_ratio = total_coeffs / kept_coeffs;
percent_removed = (removed_coeffs / total_coeffs) * 100;


output_img = dct_decoder_rgb(dct_R, dct_G, dct_B, scale, B, useQuantisationMatrix);

trimmed_output_img = output_img(1:size(I_rgb, 1), 1:size(I_rgb, 2), :);

diff = im2double(I_rgb) - trimmed_output_img;
sse = sum(diff(:).^2);

fprintf('\n--- Compression Results (Scale: %d, Block: %d) ---\n', scale, B);
fprintf('Total Coefficients:    %d\n', total_coeffs);
fprintf('Coefficients Kept:     %d\n', kept_coeffs);
fprintf('Coefficients Removed:  %d\n', removed_coeffs);
fprintf('Compression Ratio:     %.2f : 1\n', compression_ratio);
fprintf('Percent Data Removed:  %.2f%%\n', percent_removed);
fprintf('SSE:  %d\n', sse);
fprintf('--------------------------------------------------\n\n');

figure(2);
imshow(trimmed_output_img);
