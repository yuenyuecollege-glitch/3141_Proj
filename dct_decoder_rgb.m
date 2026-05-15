% Written by Jack Bradley 33114145
% Adapted from https://www.mathworks.com/help/images/discrete-cosine-transform.html
% and https://pomodo.io/tech-archive/jpeg-definitive-guide/
%
% Last modified: 05/05/2026


function [output_img] = dct_decoder_rgb(dct_R, dct_G, dct_B, scale, B, useQuantMtx)
arguments
        dct_R              % Required
        dct_G              % Required
        dct_B              % Required
        scale              % Required
        B = 8              % Optional (default=8)   
        useQuantMtx = 1    % Optional (default=0) [0=no 1=yes]
end

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

decode_channel = @(block_struct) idct2(block_struct.data .* quant_matrix);

% NOTE: You will have to remove this padding manually after decoding
% to get an image with the same resolution as the input
R_rec  = blockproc(double(dct_R),  [B B], decode_channel, 'PadPartialBlocks', true);
G_rec = blockproc(double(dct_G), [B B], decode_channel, 'PadPartialBlocks', true);
B_rec = blockproc(double(dct_B), [B B], decode_channel, 'PadPartialBlocks', true);

I_rgb_rec = cat(3, R_rec, G_rec, B_rec) / 255;

output_img = max(0, min(1, I_rgb_rec));

end