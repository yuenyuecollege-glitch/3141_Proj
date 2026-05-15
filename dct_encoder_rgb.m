% Written by Jack Bradley 33114145
% Adapted from https://www.mathworks.com/help/images/discrete-cosine-transform.html
% and https://pomodo.io/tech-archive/jpeg-definitive-guide/
%
% Last modified: 15/05/2026


function [dct_R, dct_G, dct_B] = dct_encoder_rgb(input_img, scale, B, useQuantMtx)
arguments
        input_img          % Required
        scale              % Required
        B = 8              % Optional (default=8)   
        useQuantMtx = 1    % Optional (default=0) [0=no 1=yes]
end

% Convert to double for mathematical precision
I_rgb = im2double(input_img) * 255; 

r_channel  = I_rgb(:, :, 1);  % Red channel
g_channel = I_rgb(:, :, 2);  % Green channel
b_channel = I_rgb(:, :, 3);  % Blue channel

% Aggressively destroys high-frequency color
quant_matrix = [17  18  24  47  99  99  99  99;
                18  21  26  66  99  99  99  99;
                24  26  56  99  99  99  99  99;
                47  66  99  99  99  99  99  99;
                99  99  99  99  99  99  99  99;
                99  99  99  99  99  99  99  99;
                99  99  99  99  99  99  99  99;
                99  99  99  99  99  99  99  99];

% Modify our matricies to comply with the block size
if (B > 8)
    quant_matrix = padarray(quant_matrix, [B-8 B-8], 99, 'post');
elseif (B < 8)
    quant_matrix = quant_matrix(1:B, 1:B);
end

if (useQuantMtx == 0)
    quant_matrix = max(1, ones(size(quant_matrix)) * scale);
else
    quant_matrix = max(1, round(quant_matrix * scale));
end

% 2D DCT in BxB blocks on each channel
encode_channel = @(block_struct) round(dct2(block_struct.data) ./ quant_matrix);

% NOTE: You will have to remove this padding manually after decoding
% to get an image with the same resolution as the input
dct_R  = int16(blockproc(r_channel,  [B B], encode_channel, 'PadPartialBlocks', true));
dct_G = int16(blockproc(g_channel, [B B], encode_channel, 'PadPartialBlocks', true));
dct_B = int16(blockproc(b_channel, [B B], encode_channel, 'PadPartialBlocks', true));

end