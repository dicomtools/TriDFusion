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

    releaseRoiWait();

    if zoomTool('get')
        set(zoomMenu('get'), 'Checked', 'off');

        set(btnZoomPtr('get'), 'BackgroundColor', 'default');

        zoomTool('set', false);
        zoom('off');           

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            rotate3d('on');
        else
            set(btnTriangulatePtr('get'), 'BackgroundColor', 'white');
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

        set(btnTriangulatePtr('get'), 'BackgroundColor', 'default');

        set(btnZoomPtr('get'), 'BackgroundColor', 'White');
        zoomTool('set', true);

        hCMZ = uicontextmenu;
        uimenu('Parent',hCMZ,'Label','Zoom off',...
        'Callback',@setZoomCallback);
        hZoom = zoom(fiMainWindowPtr('get'));
        hZoom.UIContextMenu = hCMZ;
        zoom('on');           
    end           
end  