function setPanCallback(~, ~)
%function setPanCallback(~, ~)
%Activate/Deactivate Viewer 2D Pan.
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

    if panTool('get')
        set(panMenu('get'), 'Checked', 'off');

        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnPanPtr('get'), 'FontWeight', 'normal');

        panTool('set', false);
        pan(fiMainWindowPtr('get'), 'off'); 

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            rotate3d on
        else
            set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
            
            if isMoveImageActivated('get') == true
                set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           
            end            
        end
    else
        set(panMenu('get'), 'Checked', 'on');

        if zoomTool('get')
            setZoomCallback();
        end

        if rotate3DTool('get')
            setRotate3DCallback();
        end  

        if dataCursorTool('get')
            setDataCursorCallback();
        end  
        
        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnTriangulatePtr('get'), 'FontWeight', 'normal');
            
        set(btnPanPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnPanPtr('get'), 'FontWeight', 'bold');
        
        panTool('set', true);

        hCMZ = uicontextmenu;
        uimenu('Parent',hCMZ,'Label','Pan off', 'Callback',@setPanCallback);
        
        hPan = pan(fiMainWindowPtr('get'));
        hPan.UIContextMenu = hCMZ;
        pan(fiMainWindowPtr('get'), 'on');          
    end           
end