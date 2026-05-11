% ECE3141: Visualizing the "Throwing Away" of DCT Coefficients
clear; clc; close all;

I = imread('cameraman.tif');
I_double = double(I);

row_start = 64; 
col_start = 64;
block_8x8 = I_double(row_start:row_start+7, col_start:col_start+7);

dct_raw = dct2(block_8x8);

Q_Y = [16  11  10  16  24  40  51  61;
       12  12  14  19  26  58  60  55;
       14  13  16  24  40  57  69  56;
       14  17  22  29  51  87  80  62;
       18  22  37  56  68 109 103  77;
       24  35  55  64  81 104 113  92;
       49  64  78  87 103 121 120 101;
       72  92  95  98 112 100 103  99];

y_scale = 2; 
Q_scaled = max(1, round(Q_Y * y_scale));

dct_quantized = round(dct_raw ./ Q_scaled);

figure('Name', 'DCT Quantization Process', 'Position', [100, 100, 1000, 800]);

cmap = parula; cmap(1,:) = [1 1 1]; 

% --- Subplot 1: Raw DCT Coefficients ---
subplot(2,2,1);
imagesc(abs(dct_raw)); colormap(cmap);
title('1. Raw DCT Coefficients (Before)');
axis off; hold on;
% Overlay the numbers
for i = 1:8
    for j = 1:8
        text(j, i, sprintf('%.1f', dct_raw(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 8);
    end
end

% --- Subplot 2: The Quantization Matrix ---
subplot(2,2,2);
imagesc(Q_scaled); colormap(cmap);
title(sprintf('2. Quantization Matrix (Scale = %d)', y_scale));
axis off; hold on;
% Overlay the numbers
for i = 1:8
    for j = 1:8
        text(j, i, sprintf('%d', Q_scaled(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'white');
    end
end

% --- Subplot 3: Quantized Coefficients ---
subplot(2,2,3);
imagesc(abs(dct_quantized) == 0); colormap([1 1 1; 0.8 0.2 0.2]); % Highlight zeros in red
title('3. Quantized Coefficients (After Throwing)');
axis off; hold on;
% Overlay the numbers
for i = 1:8
    for j = 1:8
        % If it's zero, make the text gray, otherwise black
        if dct_quantized(i,j) == 0
            txt_color = [0.6 0.6 0.6];
        else
            txt_color = [0 0 0];
        end
        text(j, i, sprintf('%d', dct_quantized(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', txt_color, 'FontWeight', 'bold');
    end
end

% --- Subplot 4: De-Quantized (What the decoder receives) ---
dct_reconstructed = dct_quantized .* Q_scaled;
subplot(2,2,4);
imagesc(abs(dct_reconstructed)); colormap(cmap);
title('4. Reconstructed DCT (Lossy Data)');
axis off; hold on;
for i = 1:8
    for j = 1:8
        if dct_reconstructed(i,j) == 0
            txt_color = [0.6 0.6 0.6];
        else
            txt_color = [0 0 0];
        end
        text(j, i, sprintf('%d', dct_reconstructed(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', txt_color);
    end
end

sgtitle('The Compression Mechanism: 8x8 Block Analysis', 'FontSize', 16, 'FontWeight', 'bold');