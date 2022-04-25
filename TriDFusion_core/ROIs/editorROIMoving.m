function editorROIMoving(he, hf)
    % Snap editor ROI to grid
    he.Position = round(he.Position);

    % Check if the circle ROI's center is inside or outside the freehand ROI.
    center = he.Center;
    isAdd = hf.inROI(center(1), center(2));
    if isAdd
        % Green if inside (since we will add to the freehand).
        he.Color = 'g';
    else
        % Red otherwise.
        he.Color = 'r';
    end
end