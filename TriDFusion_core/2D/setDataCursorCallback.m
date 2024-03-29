function setDataCursorCallback(~, ~)
%function setDataCursorCallback(~, ~)
%Activate/Deactivate Viewer 2D Data Cursor.
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
    isMoveImageActivated('set', false);
    
    releaseRoiWait();

    if dataCursorTool('get')
        set(dataCursorMenu('get'), 'Checked', 'off');

%              set(btnDataCursor, 'BackgroundColor', 'default');

        dataCursorTool('set', false);

%                toolsmenufcn Datatip;
        datacursormode(fiMainWindowPtr('get'), 'off');

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

   %         rotate3d on;
        else

          set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
          set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        end

    else
        if panTool('get')
            setPanCallback();
        end

        if zoomTool('get')
            setZoomCallback();
        end

        if rotate3DTool('get')
            setRotate3DCallback();
        end

        set(dataCursorMenu('get'), 'Checked', 'on');

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

%            set(btnDataCursor, 'BackgroundColor', 'White');

        dataCursorTool('set', true);

%                toolsmenufcn Datatip;
         datacursormode(fiMainWindowPtr('get'), 'on');
    end

end
