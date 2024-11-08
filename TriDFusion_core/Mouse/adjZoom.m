function adjZoom(dInitCoord)
%function adjZoom(dInitCoord)
%Ajust 2D zoom using mouse middle click.
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

    persistent pdInitialCoord;

    if exist('dInitCoord', 'var')

        multiFrameZoom('set', 'in', 1);
        multiFrameZoom('set', 'out', 1);

        pdInitialCoord = dInitCoord;
        return;
    end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    
    pFigure = fiMainWindowPtr('get');
           
    pAxe = getAxeFromMousePosition(dSeriesOffset);

    switch pAxe

        case axePtr('get', [], dSeriesOffset)

            axesHandle = axePtr('get', [], dSeriesOffset);

        case axes1Ptr('get', [], dSeriesOffset)

            axesHandle = axes1Ptr('get', [], dSeriesOffset);

        case axes2Ptr('get', [], dSeriesOffset)

            axesHandle = axes2Ptr('get', [], dSeriesOffset);
            
        case axes3Ptr('get', [], dSeriesOffset)

            axesHandle = axes3Ptr('get', [], dSeriesOffset);
            
        case axesMipPtr('get', [], dSeriesOffset)

            axesHandle = axesMipPtr('get', [], dSeriesOffset);
            
        otherwise

            axesHandle = axes3Ptr('get', [], dSeriesOffset);

    end 
 
    dWLAdjCoe = 0.0050;

    if isempty(pdInitialCoord)
        pdInitialCoord = pFigure.CurrentPoint;
    end

    aPosDiff = pFigure.CurrentPoint(1, 1:2) - pdInitialCoord;

    if aPosDiff(2) > 0

        multiFrameZoom('set', 'out', 1);

        if multiFrameZoom('get', 'axe') ~= axesHandle
            multiFrameZoom('set', 'in', 1);
        end
    
        dZFactor = multiFrameZoom('get', 'in')+dWLAdjCoe;
        multiFrameZoom('set', 'in', dZFactor);
        
    else
        multiFrameZoom('set', 'in', 1);


        if multiFrameZoom('get', 'axe') ~= pAxe
            multiFrameZoom('set', 'out', 1);
        end
         
        dZFactor = multiFrameZoom('get', 'out')-dWLAdjCoe;
        multiFrameZoom('set', 'out', dZFactor);       
    end


    if isempty(getappdata(axesHandle, 'matlab_graphics_resetplotview'))

        initAxePlotView(axesHandle);
    end

    % Get the current axes limits

    xLim = get(axesHandle, 'XLim');
    yLim = get(axesHandle, 'YLim');

    % Handle infinite limits by replacing with reasonable defaults
    
    if any(isinf(xLim))
       
        xData = get(axesHandle.Children, 'XData');  % Assuming children are the plotted data
        xLim = [min(cell2mat(xData),[],"all"), max(cell2mat(xData),[],"all")];      % Set to the range of the data
    end
    
    if any(isinf(yLim))
   
        yData = get(axesHandle.Children, 'YData');  % Assuming children are the plotted data
        yLim = [min(cell2mat(yData),[],"all"), max(cell2mat(yData),[],"all")];      % Set to the range of the data
    end  

    % Compute the center of the current axes

    xCenter = mean(xLim);
    yCenter = mean(yLim);

    % Calculate the new limits based on the zoom factor

    newXLim = xCenter + (xLim - xCenter) / dZFactor;  % Zoom in/out
    newYLim = yCenter + (yLim - yCenter) / dZFactor;

    % Apply the new limits to the axes
    set(axesHandle, 'XLim', newXLim, 'YLim', newYLim);
   
    multiFrameZoom('set', 'axe', axesHandle);

    % windowButton('set', 'down');  

    % rightClickMenu('off');

    pdInitialCoord = pFigure.CurrentPoint(1, 1:2);
    drawnow limitrate nocallbacks;
      
end
