function resampImage = resampleMip(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%function resampImage = resampleMip(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%Resample any modalities.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

%    dimsRef = size(refImage);        
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
       
    Rdcm  = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
%    Rref  = imref3d(size(refImage), atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);

    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));      

end