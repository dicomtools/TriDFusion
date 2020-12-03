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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...  
       switchToMIPMode('get')    == false

        set(btnTriangulatePtr('get'), 'BackgroundColor', 'white');

        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'Enable', 'on');
        set(btnZoomPtr('get'), 'BackgroundColor', 'default');
        zoomTool('set', false);
        zoom('off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'Enable', 'on');
        set(btnPanPtr('get'), 'BackgroundColor', 'default');            
        panTool('set', false);
        pan('off');     

        set(rotate3DMenu('get'), 'Checked', 'off');
   %     set(btnRegisterPtr('get'), 'Enable', 'on');            
   %     set(btnRegisterPtr('get'), 'BackgroundColor', 'default');            
        rotate3DTool('set', false);
        rotate3d off;

        set(dataCursorMenu('get'), 'Checked', 'off');
%              set(btnDataCursor, 'BackgroundColor', 'default');
        dataCursorTool('set', false);              
        datacursormode('off');       

    end

end
