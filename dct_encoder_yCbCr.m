function [dct_Y, dct_Cb, dct_Cr] = dct_encoder_yCbCr(input_img, y_scale, c_scale, B)

% Convert to double for mathematical precision
I_rgb = im2double(input_img); 

% Convert to YCbCr Color Space
I_ycbcr = rgb2ycbcr(I_rgb) * 255;

Y  = I_ycbcr(:, :, 1);  % Luminance (Brightness)
Cb = I_ycbcr(:, :, 2);  % Blue-difference chrominance (Color)
Cr = I_ycbcr(:, :, 3);  % Red-difference chrominance (Color)

% Standard ISO JPEG Quantization Matrices
% Luminance (Brightness) Matrix - Preserves structural detail
Q_Y = [16  11  10  16  24  40  51  61;
       12  12  14  19  26  58  60  55;
       14  13  16  24  40  57  69  56;
       14  17  22  29  51  87  80  62;
       18  22  37  56  68 109 103  77;
       24  35  55  64  81 104 113  92;
       49  64  78  87 103 121 120 101;
       72  92  95  98 112 100 103  99];

% Chrominance (Color) Matrix - Aggressively destroys high-frequency color
Q_C = [17  18  24  47  99  99  99  99;
       18  21  26  66  99  99  99  99;
       24  26  56  99  99  99  99  99;
       47  66  99  99  99  99  99  99;
       99  99  99  99  99  99  99  99;
       99  99  99  99  99  99  99  99;
       99  99  99  99  99  99  99  99;
       99  99  99  99  99  99  99  99];

% Modify our matricies to comply with the block size
if (B > 8)
    Q_Y = padarray(Q_Y, [B-8 B-8], 99, 'post');
    Q_C = padarray(Q_C, [B-8 B-8], 99, 'post');
elseif (B < 8)
    Q_Y = Q_Y(1:B, 1:B);
    Q_C = Q_C(1:B, 1:B);
end

Q_Y_scaled = max(1, round(Q_Y * y_scale));
Q_C_scaled = max(1, round(Q_C * c_scale));

% 2D DCT in BxB blocks on each channel
encode_Y = @(block_struct) round(dct2(block_struct.data) ./ Q_Y_scaled);
encode_C = @(block_struct) round(dct2(block_struct.data) ./ Q_C_scaled);

dct_Y  = int16(blockproc(Y,  [B B], encode_Y, 'PadPartialBlocks', true));
dct_Cb = int16(blockproc(Cb, [B B], encode_C, 'PadPartialBlocks', true));
dct_Cr = int16(blockproc(Cr, [B B], encode_C, 'PadPartialBlocks', true));

end