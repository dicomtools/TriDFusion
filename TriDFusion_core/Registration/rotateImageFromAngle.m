function aResampledImage = rotateImageFromAngle(aImage, aAxe, dRotation)
%function  rotateImageFromAngle(aImage, aAxe, dRotation)
%Rotate Image from an angle. 
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

    if size(aImage, 3) == 1 
        try
            aResampledImage = imrotate(aImage(:,:), dRotation, 'linear','crop');
        catch
            aResampledImage = imrotate(aImage(:,:), dRotation,'crop');
        end
    else
        switch aAxe
            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Coronal    
                aResampledImage = imrotate3(aImage, dRotation,[0 -1 0], 'linear','crop', 'FillValues', min(aImage, [], 'all'));

            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Sagittal  
                aResampledImage = imrotate3(aImage, dRotation,[1 0 0], 'linear','crop', 'FillValues', min(aImage, [], 'all'));

            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Axial       
                aResampledImage = imrotate3(aImage, dRotation,[0 0 1], 'linear','crop', 'FillValues', min(aImage, [], 'all')); 

            otherwise
                aResampledImage = aImage;
                return;
        end
    end

end