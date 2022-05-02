function [resampImage, atDcmMetaData] = resampleMipTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%function [resampImage, atDcmMetaData] = resampleMipTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%Resample any modalities using a transfer matrix.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    dimsRef = size(refImage);        
    dimsDcm = size(dcmImage);

    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);       

    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    xScale    = M(1,1);
    zScale    = M(3,3);
    xExtended = M(4,1);
    zExtended = M(4,3);
 
    f = [ xScale     0 0         0
          0          1 0         0
          0          0 zScale    0
          xExtended  0 zExtended 1];          
    
    TF = affine3d(f);
    
    Rdcm  = imref3d(size(dcmImage), atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    
    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')) );  
    
    if numel(resampImage) ~=  numel(refImage) % Temp patch

        if dimsDcm(3) ~= dimsRef(3)
            resampImage = imresize3(resampImage,[dimsRef(1) dimsRef(2) dimsRef(3)]);                
        else
            sameAsInput  = affineOutputView(size(refImage),TF,'BoundsStyle','SameAsInput');
            [resampImage, ~] = imwarp(dcmImage, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', sameAsInput );  
        end
    end
        

end