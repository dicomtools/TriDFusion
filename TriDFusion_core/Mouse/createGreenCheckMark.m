function createGreenCheckMark(pAxe, dDuration)

    % Get the current axis dimensions
    axisWidth = diff(pAxe.XLim);  % Width of the axis
    axisHeight = diff(pAxe.YLim); % Height of the axis
    
    % Choose the smaller dimension to maintain proportional scaling
    axisDimension = min(axisWidth, axisHeight);
    
    % Define a scaling factor
    scaleFactor = axisDimension / 512;  % 512 is the base axis size
    
    % Calculate the scaled checkmark size
    dCheckmarkLength = 12 * scaleFactor;

    % Get the current mouse position in the figure window
    mousePos = get(pAxe, 'Currentpoint');
    x = mousePos(1,1)+dCheckmarkLength; % X-coordinate of the mouse
    y = mousePos(1,2); % Y-coordinate of the mouse
    
    % Coordinates for the first line of the checkmark
    x1 = x; % Starting X for the first line
    y1 = y; % Starting Y for the first line
    x2 = x + dCheckmarkLength/2; % Ending X for the first line
    y2 = y + dCheckmarkLength/2; % Ending Y for the first line
    
    % Draw the first diagonal line
    a=line([x1 x2], [y1 y2], 'Color', 'green', 'LineWidth', 2);
    
    % Coordinates for the second line of the checkmark
    x1 = x2; % Starting X for the second line
    y1 = y2; % Starting Y for the second line
    x2 = x + dCheckmarkLength; % Ending X for the second line
    y2 = y - dCheckmarkLength; % Ending Y for the second line
    
    % Draw the second diagonal line
    b=line([x1 x2], [y1 y2], 'Color', 'green', 'LineWidth', 2);

    pause(dDuration);

    delete(a);
    delete(b);

    drawnow;
end