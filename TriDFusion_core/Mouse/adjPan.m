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

    if ~strcmpi(get(fiMainWindowPtr('get'),'Pointer'), 'arrow') 
        return;
    end

    persistent pdClickDown;

    % If initial coord is provided, set and return
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

    % Determine series offset and metadata
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    atMetaData    = dicomMetaData('get', [], dSeriesOffset);
    pFigure       = fiMainWindowPtr('get');
    pAxe          = getAxeFromMousePosition(dSeriesOffset);

    % Select axes handle and pixel spacing
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

    % Guard against zero spacing
    if xPixel == 0, xPixel = 1; end
    if yPixel == 0, yPixel = 1; end

    % Initialize click point
    if isempty(pdClickDown)
        pdClickDown = pFigure.CurrentPoint;
    end
    aPosDiff = pFigure.CurrentPoint(1,1:2) - pdClickDown;

    % Ensure plot view is initialized
    if isempty(getappdata(axesHandle, 'matlab_graphics_resetplotview'))
        initAxePlotView(axesHandle);
    end

    % Get and sanitize limits
    xLim = get(axesHandle, 'XLim');
    yLim = get(axesHandle, 'YLim');
    
    if any(isinf(xLim))
        try
            xData = get(axesHandle.Children, 'XData');
            xLim = [min(cell2mat(xData),[],"all"), max(cell2mat(xData),[],"all")];
        catch ME
            logErrorToFile(ME); 
            return;
        end
    end
    if any(isinf(yLim))
        try
            yData = get(axesHandle.Children, 'YData');
            yLim = [min(cell2mat(yData),[],"all"), max(cell2mat(yData),[],"all")];
        catch ME
            logErrorToFile(ME); 
            return;
        end
    end

    % Calculate pan shifts
    dxShift = -aPosDiff(1)/xPixel;
    dyShift =  aPosDiff(2)/yPixel;
    newXLim = xLim + dxShift;
    newYLim = yLim + dyShift;

    % Apply new limits to active axes
    set(axesHandle, 'XLim', newXLim, 'YLim', newYLim);

    if linkCoronalWithSagittal('get') == true

        % Mirror pan between axes1 and axes2
        axes1Handle = axes1Ptr('get', [], dSeriesOffset);
        axes2Handle = axes2Ptr('get', [], dSeriesOffset);
        if isequal(axesHandle, axes1Handle)
            set(axes2Handle, 'XLim', newXLim, 'YLim', newYLim);
        elseif isequal(axesHandle, axes2Handle)
            set(axes1Handle, 'XLim', newXLim, 'YLim', newYLim);
        end
    end

    % Update click point and hide menu
    pdClickDown = pFigure.CurrentPoint(1,1:2);
    showRightClickMenu(false);
end