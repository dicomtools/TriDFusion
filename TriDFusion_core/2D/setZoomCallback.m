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

        set(zoomMenu('get'), 'Checked', 'off');

        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnZoomPtr('get'), 'FontWeight', 'normal');
        
        zoomTool('set', false);
        zoom(fiMainWindowPtr('get'), 'off');           

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            rotate3d(fiMainWindowPtr('get'), 'on');
        else

            % Restore the original colorbar limits after zooming     
    
            set(axeColorbarPtr('get'), 'XLim', [0 1], 'YLim', [0 1], 'View', [0 90]);
    
            % Restore the original fusion colorbar limits after zooming     
    
            if isFusion('get') == true
                set(axeFusionColorbarPtr('get'), 'XLim', [0 1], 'YLim', [0 1], 'View', [0 90]);
            end

            set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
            
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
        set(btnTriangulatePtr('get'), 'FontWeight', 'normal');
            
        set(btnZoomPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnZoomPtr('get'), 'FontWeight', 'bold');
      
        zoomTool('set', true);

        hCMZ = uicontextmenu(fiMainWindowPtr('get'));
        uimenu('Parent',hCMZ,'Label','Zoom off', 'Callback',@setZoomCallback);
        
        hZoom = zoom(fiMainWindowPtr('get'));

        set(hZoom, 'UIContextMenu', hCMZ);

        zoom(fiMainWindowPtr('get'), 'on');           
    end           
end  