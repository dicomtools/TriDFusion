function setZoomCallback(~, ~)
%function setZoomCallback(~, ~)
%Activate/Deactivate Viewer 2D Zoom.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if isempty(dicomBuffer('get'))
        
        return;
    end     
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');            
%    isMoveImageActivated('set', false);
    
    releaseRoiWait();

    if zoomTool('get')

        zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');

        set(zoomMenu('get'), 'Checked', 'off');

        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_grey.png'));           
       
        zoomTool('set', false);
        % zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');           

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            rotate3d(fiMainWindowPtr('get'), 'on');
        else

            set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

            set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));           
           
            if isMoveImageActivated('get') == true

                set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           
            end
        end
       
    else    
        set(zoomMenu('get'), 'Checked', 'on');

        if panTool('get')
            
            setPanCallback();
        end                

        if rotate3DTool('get')

            setRotate3DCallback();
        end  

        if dataCursorTool('get')

            setDataCursorCallback();
        end  

        set(zoomMenu('get'), 'Checked', 'on');

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_grey.png'));           
            
        set(btnZoomPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

        set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_white.png'));           
      
        zoomTool('set', true);

        % hCMZ = uicontextmenu(fiMainWindowPtr('get'));
        % uimenu('Parent',hCMZ,'Label','Zoom off', 'Callback',@setZoomCallback);
        % 
        % hZoom = zoom(fiMainWindowPtr('get'));
        % 
        % set(hZoom, 'UIContextMenu', hCMZ);



        % set(hZoom, 'ActionPostCallback', @(obj, evd) adjustAxesToPanel(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), uiMipWindowPtr('get')));
        % 
        % fig    = fiMainWindowPtr('get');    % your figure handle
        % hZoom  = zoom(fig);                 % get the zoom manager object
        % hZoom.Enable = 'on';
        % 
        % hzm = hZoom.UIContextMenu; 
        % uimenu(hzm, 'Label', 'Zoom off', 'Callback', @setZoomCallback);

        zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'on');
   end

    % % Custom function to adjust axes size based on panel and aspect ratio
    % function adjustAxesToPanel(hAxes, hPanel)
    %     % Get the size of the panel
    %     panelPos = getpixelposition(hPanel);
    % 
    %     % Get the current axes limits
    %     xLim = get(hAxes, 'XLim');
    %     yLim = get(hAxes, 'YLim');
    % 
    %     % Calculate the data aspect ratio based on the current limits
    %     dataAspectRatio = diff(xLim) / diff(yLim);
    % 
    %     % Calculate the panel aspect ratio (width/height)
    %     panelAspectRatio = panelPos(3) / panelPos(4);
    % 
    %     if panelAspectRatio > dataAspectRatio
    %         % The panel is wider than the data aspect ratio, so adjust x-axis limits
    %         newXLimWidth = diff(yLim) * panelAspectRatio;  % Maintain aspect ratio
    %         midX = mean(xLim);
    %         newXLim = [midX - newXLimWidth / 2, midX + newXLimWidth / 2];
    %         set(hAxes, 'XLim', newXLim);
    %     else
    %         % The panel is taller, so adjust y-axis limits
    %         newYLimHeight = diff(xLim) / panelAspectRatio;  % Maintain aspect ratio
    %         midY = mean(yLim);
    %         newYLim = [midY - newYLimHeight / 2, midY + newYLimHeight / 2];
    %         set(hAxes, 'YLim', newYLim);
    %     end
    % 
    %     % Set axes to fill the panel, maintaining proportions
    %     set(hAxes, 'Position', [0 0 1 1], 'DataAspectRatioMode', 'manual');
    % end          

end  