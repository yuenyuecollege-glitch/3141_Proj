function [output_img] = dct_decoder_yCbCr(dct_Y, dct_Cb, dct_Cr, y_scale, c_scale, B)

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

Q_Y_scaled = max(1, round(Q_Y * y_scale));
Q_C_scaled = max(1, round(Q_C * c_scale));

decode_Y = @(block_struct) idct2(block_struct.data .* Q_Y_scaled);
decode_C = @(block_struct) idct2(block_struct.data .* Q_C_scaled);

Y_rec  = blockproc(double(dct_Y),  [B B], decode_Y);
Cb_rec = blockproc(double(dct_Cb), [B B], decode_C);
Cr_rec = blockproc(double(dct_Cr), [B B], decode_C);

I_ycbcr_rec = cat(3, Y_rec, Cb_rec, Cr_rec) / 255;
I_rgb_rec = ycbcr2rgb(I_ycbcr_rec);
output_img = max(0, min(1, I_rgb_rec));

end