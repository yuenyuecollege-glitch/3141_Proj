% This code analyses the difference between direct transmission time and
% compressed transmission time using ISO Standard JPEG Quantization.
clear; clc; close all;

network_bandwidth_Mbps = 2;
bandwidth_bps = network_bandwidth_Mbps * 1e6; 
scale_factors = [0.1, 0.5, 1.0, 1.5]; 
B = 8; 
y_scale = 0.5;
c_scale = 0.8;

[I_base, ~] = imread('inputs/train.png');
if size(I_base, 3) == 1
    I_base = cat(3, I_base, I_base, I_base); 
end

num_sizes = length(scale_factors);
megapixels = zeros(1, num_sizes);
t_direct = zeros(1, num_sizes);
t_total_comp = zeros(1, num_sizes);

% --- 1. Print Header ---
fprintf('\n%-6s | %-6s | %-6s | %-10s | %-11s | %-10s | %-12s | %-2s\n', ...
    'Scale', 'MP', 'MB', 'Direct (s)', 'DCT (s)', 'Comp Ratio', 'Data Removed', 'Speedup');
fprintf('------------------------------------------------------------------------------------------------------------\n');

for i = 1:num_sizes
    % Resize image
    I_rgb = imresize(I_base, scale_factors(i));
    [h, w, ~] = size(I_rgb);
    
    % --- ENCODER ---
    % Using your custom function which handles yCbCr conversion, blockproc, and quantization
    tic;
    [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr(I_rgb, y_scale, c_scale, B);
    t_enc = toc;
    
    % --- TRANSMISSION ---
    raw_bits = numel(I_rgb) * 8;
    % Calculate compressed bits based on non-zero coefficients (Standard efficiency metric)
    comp_bits = (nnz(dct_Y) + nnz(dct_Cb) + nnz(dct_Cr)) * 8;
    
    t_tx_raw = raw_bits / bandwidth_bps;
    t_tx_comp = comp_bits / bandwidth_bps;
    
    % --- DECODER ---
    tic;
    I_rec = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, y_scale, c_scale, B);
    t_dec = toc;
    
    % --- DATA CALCULATION ---
    megapixels(i) = (h * w) / 1e6;
    megabytes = numel(I_rgb) / (1024^2); 
    
    t_direct(i) = t_tx_raw;
    t_total_comp(i) = t_enc + t_tx_comp + t_dec;
    
    comp_ratio = raw_bits / comp_bits;
    reduction_pct = (1 - (comp_bits / raw_bits)) * 100;
    speedup = t_direct(i) / t_total_comp(i);
    
    % --- 2. Print row ---
    fprintf('%-6.1f | %-6.2f | %-6.2f | %-10.4f | %-11.4f | %-9.2fx | %-11.2f%% | %-2.2f times faster\n', ...
        scale_factors(i), megapixels(i), megabytes, t_direct(i), t_total_comp(i), comp_ratio, reduction_pct, speedup);
end

% --- 3. Plotting ---
figure;
plot(megapixels, t_direct, 'r-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r'); hold on;
plot(megapixels, t_total_comp, 'b-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
grid on;
legend('Direct Transmission', 'Compression (DCT2) Strategy');
xlabel('Megapixels'); ylabel('Total Time (Seconds)');
title(['Performance Analysis (Bandwidth: ', num2str(network_bandwidth_Mbps), ' Mbps)']);

% Summary Print
fprintf("\nThis code analyses a single data file transfer.")
fprintf("\nIn real life scenario, the compression before transmission is still superior to direct transmission \nno matter the Mbps.")
fprintf("\n\nThis is because reducing the data size increases the total system throughput, \nenabling more content to be delivered within the same network capacity.\n")