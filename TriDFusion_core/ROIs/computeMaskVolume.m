function dVolume = computeMaskVolume(imVolume, atMetaData)
%function dVolume = computeMaskVolume(imVolume, atMetaData)
%Compute the mask volume.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    xPixel = atMetaData{1}.PixelSpacing(1)/10;
    yPixel = atMetaData{1}.PixelSpacing(2)/10; 

    if size(imVolume, 3) == 1 

        zPixel = 1;
    else
        zPixel = computeSliceSpacing(atMetaData)/10; 

        if zPixel == 0 % We can't determine the z size of a pixel, we will presume the pixel is square.

            zPixel = xPixel;
        end
    end
    
    dVoxVolume = xPixel * yPixel * zPixel; 

    dNbCells = numel(imVolume(imVolume~=0));

    dVolume = dNbCells * dVoxVolume;  
    
end