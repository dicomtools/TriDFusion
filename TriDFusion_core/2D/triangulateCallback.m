function triangulateCallback(~, ~)
%function triangulateCallback(~, ~)
%Triangulate the 2D images. 
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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...  
       switchToMIPMode('get')    == false

        % % Restore the original colorbar limits after zooming or panning     
        % 
        % set(axeColorbarPtr('get'), 'XLim', [0 1], 'YLim', [0 1], 'View', [0 90]);
        % 
        % % Restore the original fusion colorbar limits after zooming or panning    
        % 
        % if isFusion('get') == true
        %     set(axeFusionColorbarPtr('get'), 'XLim', [0 1], 'YLim', [0 1], 'View', [0 90]);
        % end

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

        set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));           
            
        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'Enable', 'on');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_grey.png'));           

        zoomTool('set', false);
        zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'Enable', 'on');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));    

        set(btnPanPtr('get'), 'CData', resizeTopBarIcon('pan_grey.png'));           

        panTool('set', false);
        panMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');           

        set(rotate3DMenu('get'), 'Checked', 'off');
   %     set(btnRegisterPtr('get'), 'Enable', 'on');            
   %     set(btnRegisterPtr('get'), 'BackgroundColor', 'default');            
        rotate3DTool('set', false);
        rotate3d(fiMainWindowPtr('get'), 'off');

        set(dataCursorMenu('get'), 'Checked', 'off');
%              set(btnDataCursor, 'BackgroundColor', 'default');
        dataCursorTool('set', false);              
        datacursormode(fiMainWindowPtr('get'), 'off');       
        
        if isMoveImageActivated('get') == true
            
            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           
        end   
    end

end
