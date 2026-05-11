% Load a sample image
input_img = imread('peppers.png'); % Built-in MATLAB image
original = im2double(input_img);

% Parameters
B = 8; % Block size
scales = [0.1, 0.5, 1, 2, 5, 10, 20, 40, 70, 100]; % Range of quantization scales
sse_values = zeros(size(scales));
zero_coeffs_pct = zeros(size(scales));

fprintf('Processing scales...\n');

for i = 1:length(scales)
    s = scales(i);
    
    % 1. Encode using your function
    [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr(input_img, s, s, B);
    
    % 2. Decode using your function
    reconstructed = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, s, s, B);
    
    % 3. Calculate Distortion (Sum Squared Error)
    % We calculate error on the [0, 1] double representation
    diff = original - reconstructed;
    sse_values(i) = sum(diff(:).^2);
    
    % 4. Optional: Calculate % of coefficients "thrown away" (set to zero)
    total_coeffs = numel(dct_Y) + numel(dct_Cb) + numel(dct_Cr);
    zeros_count = sum(dct_Y(:) == 0) + sum(dct_Cb(:) == 0) + sum(dct_Cr(:) == 0);
    zero_coeffs_pct(i) = (zeros_count / total_coeffs) * 100;
    
    fprintf('Scale: %.1f | SSE: %.2f | Zeros: %.1f%%\n', s, sse_values(i), zero_coeffs_pct(i));
end


% Plot 1: SSE vs Quantization Scale
figure(1);
plot(scales, sse_values, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Quantization Scale (Lower is more accurate)');
ylabel('Distortion (Sum Squared Error)');
title('Distortion vs. Quantization Scale');

% Plot 2: SSE vs % of Coefficients Thrown Away
figure(2);
plot(zero_coeffs_pct, sse_values, 's-', 'Color', [0.85 0.33 0.1], 'LineWidth', 2);
grid on;
xlabel('% of DCT Coefficients set to Zero');
ylabel('Distortion (Sum Squared Error)');
title('Distortion vs. Data Compression');

% Add the functions below the script or ensure they are in your path