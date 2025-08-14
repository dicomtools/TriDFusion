function I = getObjectFrame(pObj)
%function I = getObjectFrame(pObj)
%Get an object frame, this function is an alternative of getframe.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
    
    bFrame2im = false;

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true 

        if ~isempty(viewer3dObject('get'))

            bFrame2im = true;
        end
    end

    if bFrame2im == true
  
        I = frame2im(getframe(pObj));
    else
        % Create a figure and axes (if not already existing)
        figureHandle = pObj;
        
        % Define a temporary folder location to store the image (for exportgraphics)
        sTmpDir = fullfile(tempdir, 'temp_exportgraphics');
        if ~exist(sTmpDir, 'dir')
            mkdir(sTmpDir);
        end
        
        % Create a unique file name based on the current date and time
        sFileName = fullfile(sTmpDir, sprintf('im_%s.png', datetime('now','Format','yyyyMMdd_HHmmss')));
        
        % Export the axes to a temporary file (this step is optional if you want to store)
        exportgraphics(figureHandle, sFileName);
        
        % Read the exported image file
        I = imread(sFileName);
        
        % Optionally, clean up the temporary directory (only if you need to)
        rmdir(sTmpDir, 's');  
    end
end