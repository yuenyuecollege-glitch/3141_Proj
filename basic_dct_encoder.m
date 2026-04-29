% MATLAB Script for Color Image 2D DCT Encoding using YCbCr
clear; clc; close all;

% 1. Read the color image
% 'peppers.png' is a standard built-in MATLAB color test image
I_rgb = imread('input_images/DSCF5372.JPG'); 

figure(1);
imshow(I_rgb);

y_scale = 5;
c_scale = 3;

[dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr( ...
    I_rgb, ...
    y_scale, ...
    c_scale, ...
    8 ...
);

output_img = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, y_scale, c_scale, 8);

figure(2);
imshow(output_img);




% 
% 
% % Convert to double for mathematical precision
% I_rgb = im2double(I_rgb); 
% 
% % 2. Convert RGB to YCbCr Color Space
% I_ycbcr = rgb2ycbcr(I_rgb);
% 
% % Separate the channels
% Y  = I_ycbcr(:, :, 1); % Luminance (Brightness)
% Cb = I_ycbcr(:, :, 2); % Blue-difference chrominance (Color)
% Cr = I_ycbcr(:, :, 3); % Red-difference chrominance (Color)
% 
% % 3. Perform 2D DCT in 8x8 blocks on each channel separately
% dct_func = @(block_struct) dct2(block_struct.data);
% 
% DCT_Y  = blockproc(Y,  [8 8], dct_func);
% DCT_Cb = blockproc(Cb, [8 8], dct_func);
% DCT_Cr = blockproc(Cr, [8 8], dct_func);
% 
% % 4. "Encoding" (Compression via Thresholding)
% % We use a lower threshold for Y (keeping more detail) and a 
% % higher threshold for Cb/Cr (compressing color more aggressively).
% threshold_Y = 0.3; 
% threshold_C = 0.50; % Compress color data twice as hard
% 
% % Apply thresholds
% DCT_Y(abs(DCT_Y) < threshold_Y) = 0;
% DCT_Cb(abs(DCT_Cb) < threshold_C) = 0;
% DCT_Cr(abs(DCT_Cr) < threshold_C) = 0;
% 
% % Calculate compression statistics across all channels
% total_coeffs = numel(DCT_Y) + numel(DCT_Cb) + numel(DCT_Cr);
% kept_coeffs = nnz(DCT_Y) + nnz(DCT_Cb) + nnz(DCT_Cr);
% compression_ratio = total_coeffs / kept_coeffs;
% 
% fprintf('Total Coefficients: %d\n', total_coeffs);
% fprintf('Coefficients Kept: %d (%.2f%%)\n', kept_coeffs, (kept_coeffs/total_coeffs)*100);
% fprintf('Estimated Compression Ratio: %.2f:1\n', compression_ratio);
% 
% % 5. Reconstruct the image (Decoding) using Inverse DCT
% idct_func = @(block_struct) idct2(block_struct.data);
% 
% Y_rec  = blockproc(DCT_Y,  [8 8], idct_func);
% Cb_rec = blockproc(DCT_Cb, [8 8], idct_func);
% Cr_rec = blockproc(DCT_Cr, [8 8], idct_func);
% 
% % 6. Recombine channels and convert back to RGB
% % Stack the 2D arrays back into a 3D matrix
% I_ycbcr_rec = cat(3, Y_rec, Cb_rec, Cr_rec);
% 
% % Convert back to RGB for display
% I_rgb_rec = ycbcr2rgb(I_ycbcr_rec);
% 
% % Ensure values stay within the valid [0, 1] range after math operations
% I_rgb_rec = max(0, min(1, I_rgb_rec));
% 
% % 7. Visualization
% figure('Name', 'Color 2D DCT Image Encoding', 'Position', [100, 100, 1200, 400]);
% 
% % Original Image
% subplot(1, 3, 1);
% imshow(I_rgb);
% title('Original RGB Image');
% 
% % DCT Coefficients (Showing Luminance only for visualization)
% subplot(1, 3, 2);
% % We only show the Y channel's DCT here, as displaying 3D DCT data is difficult
% imshow(log(abs(DCT_Y)), []);
% colormap(gca, jet(64));
% title('DCT Coefficients (Y-Channel Only)');
% 
% % Reconstructed Image
% subplot(1, 3, 3);
% imshow(I_rgb_rec);
% title('Reconstructed RGB Image');