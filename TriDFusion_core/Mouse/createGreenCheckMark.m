function createGreenCheckMark(pRoi, dDuration)

    if isempty(pRoi)
        return;
    end
    
    % aColor = pRoi.Color;
    % 
    % pRoi.Color = [0 1 0];
    pAxe = pRoi.Parent;

    % Get the current axis dimensions
    axisWidth = diff(pAxe.XLim);  % Width of the axis
    axisHeight = diff(pAxe.YLim); % Height of the axis
    
    % Choose the smaller dimension to maintain proportional scaling
    axisDimension = min(axisWidth, axisHeight);
    
    % Define a scaling factor
    scaleFactor = axisDimension / 512;  % 512 is the base axis size
    
    % Calculate the scaled checkmark size
    dCheckmarkLength = 12 * scaleFactor;

    % % % Get the current mouse position in the figure window
    %  mousePos = get(pAxe, 'Currentpoint');
    %  x = mousePos(1,1)+dCheckmarkLength % X-coordinate of the mouse
    %  y = mousePos(1,2) % Y-coordinate of the mouse

    switch pRoi.Type
    
        case 'images.roi.rectangle'
    
            dRoiFarthestPointRight = pRoi.Position(1) + pRoi.Position(3);  % x + width
            dRoiAssiciatedPointY = pRoi.Position(2) + pRoi.Position(4) / 2;  % y + height/2 (centered y)
    
        case 'images.roi.ellipse'
            
            dRoiFarthestPointRight = pRoi.Center(1) + pRoi.SemiAxes(1);  % x_center + semi-major axis
            dRoiAssiciatedPointY = pRoi.Center(2);  
    
        case 'images.roi.circle'
    
            dRoiFarthestPointRight = pRoi.Position(1) + pRoi.Radius;  
            dRoiAssiciatedPointY   = pRoi.Position(2);  
    
        otherwise
    
            [dRoiFarthestPointRight, index] = max( pRoi.Position(:, 1));
            dRoiAssiciatedPointY = pRoi.Position(index, 2);
    end

    x = dRoiFarthestPointRight + (3 * scaleFactor);
    y = dRoiAssiciatedPointY;
    
    % Coordinates for the first line of the checkmark
    x1 = x; % Starting X for the first line
    y1 = y; % Starting Y for the first line
    x2 = x + dCheckmarkLength/2; % Ending X for the first line
    y2 = y + dCheckmarkLength/2; % Ending Y for the first line
    
    % Draw the first diagonal line
    a=line(pAxe, [x1 x2], [y1 y2], 'Color', 'green', 'LineWidth', 2);
    
    % Coordinates for the second line of the checkmark
    x1 = x2; % Starting X for the second line
    y1 = y2; % Starting Y for the second line
    x2 = x + dCheckmarkLength; % Ending X for the second line
    y2 = y - dCheckmarkLength; % Ending Y for the second line
    
    % Draw the second diagonal line
    b=line(pAxe, [x1 x2], [y1 y2], 'Color', 'green', 'LineWidth', 2);

    pause(dDuration);

    delete(a);
    delete(b);

    % pRoi.Color = aColor;

    drawnow;
end