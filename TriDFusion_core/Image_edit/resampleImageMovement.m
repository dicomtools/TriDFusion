function aResampledImage = resampleImageMovement(aImage, aAxe, aPosition)
%function  resampleImageRotation(aImage, aAxe, aPosition)
%Resample the Movement of an Image. 
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
    else
        
        aImageSize = size(aImage);

        sizeX = aImageSize(1);
        sizeY = aImageSize(2);
        sizeZ = aImageSize(3);

        xMoveOffset = aPosition(1);
        yMoveOffset = aPosition(2);
        
        switch aAxe
            case axes1Ptr('get') % Coronal    
                [Xq,Yq,Zq] = meshgrid([1:sizeX]+xMoveOffset,[1:sizeY],[1:sizeZ]+yMoveOffset);
                aResampledImage = interp3(aImage, Xq, Yq, Zq, 'cubic');

            case axes2Ptr('get') % Sagittal  
                [Xq,Yq,Zq] = meshgrid([1:sizeX],[1:sizeY]+xMoveOffset,[1:sizeZ]+yMoveOffset);
                aResampledImage = interp3(aImage, Xq, Yq, Zq, 'cubic');

            case axes3Ptr('get') % Axial  
if 0                
                [Xq,Yq,Zq] = meshgrid([1:sizeX]+xMoveOffset,[1:sizeY]+yMoveOffset,[1:sizeZ]);
                aResampledImage = interp3(aImage, Xq, Yq, Zq, 'cubic');   
else


Sx = 1;
Sy = 1;
Sz = 1;

atDcmMetaData = dicomMetaData('get'); 
dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
Rdcm  = imref3d(size(aImage), atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);

Rdcm.XWorldLimits(1) = Rdcm.XWorldLimits(1)+xMoveOffset;
Rdcm.XWorldLimits(2) = Rdcm.XWorldLimits(2)+xMoveOffset;
  
Rdcm.YWorldLimits(1) = Rdcm.YWorldLimits(1)+yMoveOffset;
Rdcm.YWorldLimits(2) = Rdcm.YWorldLimits(2)+yMoveOffset;
tform = affine3d([Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; 0 0 0 1]);

aResampledImage = imwarp(aImage, Rdcm, tform, 'Interp', 'Linear', 'FillValues', double(min(aImage,[],'all')));

%M = [1 0 0 yMoveOffset; 0 1 0 xMoveOffset; 0 0 1 0; 0 0 0 1]; 
%aResampledImage = affine3d_2(aImage,M,1:sizeX,1:sizeY,1:sizeZ); 
end
            otherwise
                aResampledImage = [];
                return;
        end

                
    end
end