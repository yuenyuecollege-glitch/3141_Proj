function [zigzag] = zigzag_encode(array_2d)

[rows, cols] = size(array_2d);
zigzag = [];
for i = 1:rows
    if mod(i, 2) == 0
        % Even row: reverse
        zigzag = [zigzag, fliplr(array_2d(i, :))];
    else
        % Odd row: normal
        zigzag = [zigzag, array_2d(i, :)];
    end
end

end