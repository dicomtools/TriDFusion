function interior_filled = volumeFill(aVolume)

grayImage = aVolume;

% Create a binary image.
binaryImage = grayImage ~= 0;

% Fill the object by scanning across all columns and 
% drawing a line from the top-most pixel to the bottom-most pixel.
[rows, columns, depth] = size(binaryImage);
for ii=1: depth
    for col = 1 : columns
        % Find the top most pixel.
        topRow = find(binaryImage(:, col, ii), 1, 'first');
        if ~isempty(topRow)
            % If there is a pixel in this column, then find the lowest/bottom one.
            bottomRow = find(binaryImage(:, col, ii), 1, 'last');
            % Fill from top to bottom.
            binaryImage(topRow : bottomRow, col, ii) = true;
        end
    end
end

interior_filled = binaryImage;

end