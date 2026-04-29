clear; clc; close all;

img = imread('peppers.png');
img = imresize(img, [1024 1024]); 
y_scale = 1.0; % treating as constant 
c_scale = 1.0; 
B = 8;

segment_counts = [1, 4, 16, 64, 128]; 
execution_times = zeros(length(segment_counts), 1);
sse_results = zeros(length(segment_counts), 1);

fprintf('--- Segment performance ---\n');

for i = 1:length(segment_counts)
    N = segment_counts(i);
    segment_size = size(img, 1) / N;
    
    full_reconstruction = zeros(size(img));
    
    tic;
    for row = 1:N
        for col = 1:N
            r_idx = ((row-1)*segment_size + 1) : (row*segment_size);
            c_idx = ((col-1)*segment_size + 1) : (col*segment_size);
            img_segment = img(r_idx, c_idx, :);
            
            % Encode
            [dY, dCb, dCr] = dct_encoder_yCbCr(img_segment, y_scale, c_scale, B);
            
            % Decode
            reconstructed_seg = dct_decoder_yCbCr(dY, dCb, dCr, y_scale, c_scale, B);
            
            % Stitch back together
            full_reconstruction(r_idx, c_idx, :) = reconstructed_seg;
        end
    end
    execution_times(i) = toc;
    
    % Calculate SSE: sum((original - reconstructed)^2)
    % Converting to double for precision
    diff = im2double(img) - full_reconstruction;
    sse_results(i) = sum(diff(:).^2);
    
    fprintf('Segments: %dx%d | SSE: %.5f | Time: %.4f s\n', N, N, sse_results(i), execution_times(i));
end

% Visual Proof
figure('Color', 'w');
subplot(1,2,1);
bar(categorical(segment_counts), sse_results);
ylabel('Sum Squared Error (SSE)');
title('Mathematical Distortion (Does not get affected)');

subplot(1,2,2);
bar(categorical(segment_counts), execution_times);
ylabel('Time (s)');
title('Computational Effort');