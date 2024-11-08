function adjPan(dInitCoord)
%function adjPan(dInitCoord)
%Ajust 2D pan using mouse right click.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
%
% This file is part of The Triple Dimention Fusion (TriDFusion).
%
% TriDFusion development has been led by:  Daniel Lafontaine
%
% TriDFusion is distributed under the terms of the Lesser GNU Public License.
%
%     This version of TriDFusion is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.

    persistent pdClickDown;

    if exist('dInitCoord', 'var')

        multiFrameZoom('set', 'in', 1);
        multiFrameZoom('set', 'out', 1);

        pdClickDown = dInitCoord;

        if ~isempty(copyRoiPtr('get')) 
            
            rightClickMenu('off');
        end

        showRightClickMenu(true);

        return;
    end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atMetaData = dicomMetaData('get', [], dSeriesOffset);
    
    pFigure = fiMainWindowPtr('get');
           
    pAxe = getAxeFromMousePosition(dSeriesOffset);

    switch pAxe

        case axePtr('get', [], dSeriesOffset)

            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = atMetaData{1}.PixelSpacing(2);

            axesHandle = axePtr('get', [], dSeriesOffset);

        case axes1Ptr('get', [], dSeriesOffset)

            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = computeSliceSpacing(atMetaData);  

            axesHandle = axes1Ptr('get', [], dSeriesOffset);

        case axes2Ptr('get', [], dSeriesOffset)

            xPixel = atMetaData{1}.PixelSpacing(2);
            yPixel = computeSliceSpacing(atMetaData);

            axesHandle = axes2Ptr('get', [], dSeriesOffset);
            
        case axes3Ptr('get', [], dSeriesOffset)

            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = atMetaData{1}.PixelSpacing(2);

            axesHandle = axes3Ptr('get', [], dSeriesOffset);
            
        case axesMipPtr('get', [], dSeriesOffset)

            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = computeSliceSpacing(atMetaData); 

            axesHandle = axesMipPtr('get', [], dSeriesOffset);
            
        otherwise

            axesHandle = axes3Ptr('get', [], dSeriesOffset);

    end 

    % set(axesHandle, 'LooseInset', get(axesHandle,'TightInset'));

    if xPixel == 0
        xPixel = 1;
    end
    
    if yPixel == 0
        yPixel = 1;
    end

    if isempty(pdClickDown)
        
        pdClickDown = pFigure.CurrentPoint;
    end

    aPosDiff = pFigure.CurrentPoint(1, 1:2) - pdClickDown;

    if isempty(getappdata(axesHandle, 'matlab_graphics_resetplotview'))

        initAxePlotView(axesHandle);
    end

    % Get the current axes limits

    xLim = get(axesHandle, 'XLim');
    yLim = get(axesHandle, 'YLim');

    % Handle infinite limits by replacing with reasonable defaults

    if any(isinf(xLim))
        try
        xData = get(axesHandle.Children, 'XData');  % Assuming children are the plotted data
        xLim = [min(cell2mat(xData),[],"all"), max(cell2mat(xData),[],"all")];      % Set to the range of the data
        catch
            return;
        end
    end
    
    if any(isinf(yLim))
        try
        yData = get(axesHandle.Children, 'YData');  % Assuming children are the plotted data
        yLim = [min(cell2mat(yData),[],"all"), max(cell2mat(yData),[],"all")];      % Set to the range of the data
        catch
            return;
        end        
    end
   
    % Calculate the pan shift based on the difference
    dxShift = -aPosDiff(1)/xPixel;  
    dyShift =  aPosDiff(2)/yPixel;

    % Calculate the new limits based on the pan shift
    newXLim = xLim + dxShift;  % Shift x-axis by dxShift
    newYLim = yLim + dyShift;  % Shift y-axis by dyShift

    % Apply the new limits to the axes

% Store parents of drawfreehand objects
% freehandObjects = findall(axesHandle, 'Type', 'images.roi.Freehand');
% originalParents = arrayfun(@(obj) obj.Parent, freehandObjects, 'UniformOutput', false);
% 
% % Temporarily remove objects from axes
% set(freehandObjects, 'Parent', []);

    set(axesHandle, 'XLim', newXLim, 'YLim', newYLim);
    % axesHandle.XLim = newXLim;
    % axesHandle.YLim = newYLim;
    % 
   % drawnow update;

    % xlim
    % axesHandle.XLim = newXLim;
    % axesHandle.YLim = newYLim;

    windowButton('set', 'down');  

    pdClickDown = pFigure.CurrentPoint(1, 1:2);

    showRightClickMenu(false);

    drawnow limitrate nocallbacks;
    % Restore objects to their original parent
% for k = 1:numel(freehandObjects)
%     freehandObjects(k).Parent = originalParents{k};
% end
end
