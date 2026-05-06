clear; clc; close all;
img = imread('inputs/marmot.png');
img = imresize(img, [2048 2048]); 
if size(img, 3) == 1
    img = cat(3, img, img, img);
end

y_scale = 1.0; 
c_scale = 1.0; 
B = 8;
segment_counts = [1, 2, 4, 8, 16, 32, 64, 128, 256]; 
execution_times = zeros(length(segment_counts), 1);
sse_results = zeros(length(segment_counts), 1);

% Start the parallel pool if it isn't running
if isempty(gcp('nocreate')); parpool; end 

fprintf('--- Performance Simulation...Please Wait ---\n');

for i = 1:length(segment_counts)
    N = segment_counts(i);
    segment_size = size(img, 1) / N;
    
    % Use a temporary cell array to store segments (best for parfor)
    temp_reconstruction = cell(N, N);
    
    tic;
    % PARFOR distributes the segments across your CPU cores
    parfor row = 1:N
        for col = 1:N
            r_idx = ((row-1)*segment_size + 1) : (row*segment_size);
            c_idx = ((col-1)*segment_size + 1) : (col*segment_size);
            img_segment = img(r_idx, c_idx, :);
            
            % Encode & Decode
            [dY, dCb, dCr] = dct_encoder_yCbCr(img_segment, y_scale, c_scale, B);
            reconstructed_seg = dct_decoder_yCbCr(dY, dCb, dCr, y_scale, c_scale, B);
            
            % Store in temporary cell
            temp_reconstruction{row, col} = reconstructed_seg;
        end
    end
    execution_times(i) = toc;
    
    % Stitch back together (happens outside the timer to focus on transform time)
    full_reconstruction = zeros(size(img));
    for row = 1:N
        for col = 1:N
            r_idx = ((row-1)*segment_size + 1) : (row*segment_size);
            c_idx = ((col-1)*segment_size + 1) : (col*segment_size);
            full_reconstruction(r_idx, c_idx, :) = temp_reconstruction{row, col};
        end
    end
    
    % SSE Calculation
    diff = im2double(img) - full_reconstruction;
    sse_results(i) = sum(diff(:).^2);
    
    fprintf('Segments: %dx%d | SSE: %.5f | Time: %.4f s\n', N, N, sse_results(i), execution_times(i));
end

% --- Visualization ---
figure('Color', 'w');
plot(segment_counts, execution_times, '-o', 'LineWidth', 2, 'MarkerFaceColor', 'r');
grid on; xlabel('N (Segment Count)'); ylabel('Time (s)');
title('Parallel Execution Time');

% Find and highlight Diminishing Returns
[min_time, idx] = min(execution_times);
hold on;
plot(segment_counts(idx), min_time, 'gs', 'MarkerSize', 15, 'LineWidth', 2);
legend('Execution Time', 'Optimal Return');


% Sum squared error & Computation time
figure('Color', 'w');

subplot(1,2,1);

bar(categorical(segment_counts), sse_results);

ylabel('Sum Squared Error (SSE)');

title('Mathematical Distortion');

subplot(1,2,2);

bar(categorical(segment_counts), execution_times);

ylabel('Time (s)');

title('Computational Time');

fprintf('\nShutting down parallel pool...\n');
delete(gcp('nocreate'));