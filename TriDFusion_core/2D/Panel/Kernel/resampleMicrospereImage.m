function [aImage, atMetaData] = resampleMicrospereImage(aImage, atMetaData, dSizeX, dSizeY, dSizeZ)
%function [aImage, atMetaData] = resampleMicrospereImage(aImage, atMetaData, dSizeX, dSizeY, dSizeZ)
%resample a microshere image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dimsDcm = size(aImage);
    
    dcmSliceThickness = computeSliceSpacing(atMetaData);
    
%    Rdcm = imref3d(dimsDcm, atMetaData{1}.PixelSpacing(2), atMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    
    if ~any(atMetaData{1}.ImageOrientationPatient, 'all')
        aImageOrientationPatient = zeros(6,1);
        
        % Axial
        aImageOrientationPatient(1) = 1;
        aImageOrientationPatient(5) = 1;
        
        for pp=1:numel(atMetaData)
            atMetaData{pp}.ImageOrientationPatient = aImageOrientationPatient;
        end
    end
    
%    if ~any(atMetaData{1}.ImagePositionPatient, 'all')
%        aImagePositionPatient = zeros(3,1);
        
%        aImagePositionPatient(1) = 1;
%        aImagePositionPatient(2) = 1;
%        aImagePositionPatient(3) = 1;
        
%        for pp=1:numel(atMetaData)
%            atMetaData{1}.ImagePositionPatient = aImagePositionPatient;
%        end
%    end
    
    atRefMetaData = atMetaData;
    for tt=1:numel(atRefMetaData)
        atRefMetaData{tt}.PixelSpacing(1) = dSizeX;
        atRefMetaData{tt}.PixelSpacing(2) = dSizeY;   
    end
    
    refSliceThickness = dSizeZ;
    
    dimsRef = zeros(1,3);

    dimsRef(1,1) = round(dimsDcm(1,1) * atMetaData{1}.PixelSpacing(1)/atRefMetaData{1}.PixelSpacing(1));
    dimsRef(1,2) = round(dimsDcm(1,2) * atMetaData{1}.PixelSpacing(2)/atRefMetaData{1}.PixelSpacing(2));
    dimsRef(1,3) = dimsDcm(1,3);
    
    [M, ~] = getTransformMatrix(atMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    M(3,3) = 1;
    TF = affine3d(M);    
    
%    [aImage, ~] = imwarp(aImage, Rdcm, TF,'Interp', 'Linear', 'FillValues', double(min(aImage,[],'all')));  
    [aImage, ~] = imwarp(aImage, TF, 'Interp', 'Linear', 'FillValues', double(min(aImage,[],'all')), 'OutputView', imref3d(dimsRef));  

    aResampledImageSize = size(aImage);
   
    computedSliceThikness = (dSizeZ * refSliceThickness) / aResampledImageSize(3); 
  
    for jj=1:numel(atMetaData)
        
        atMetaData{jj}.InstanceNumber  = jj;               
        atMetaData{jj}.NumberOfSlices  = aResampledImageSize(3);                
        
        atMetaData{jj}.PixelSpacing(1) = dimsDcm(1)/aResampledImageSize(1)*atMetaData{jj}.PixelSpacing(1);
        atMetaData{jj}.PixelSpacing(2) = dimsDcm(2)/aResampledImageSize(2)*atMetaData{jj}.PixelSpacing(2);
        atMetaData{jj}.SliceThickness  = computedSliceThikness;
        atMetaData{jj}.SpacingBetweenSlices  = computedSliceThikness;

        atMetaData{jj}.Rows    = aResampledImageSize(1);
        atMetaData{jj}.Columns = aResampledImageSize(2);
        atMetaData{jj}.NumberOfSlices = numel(atMetaData);                  
    end
              
    for cc=1:numel(atMetaData)-1
        if atMetaData{1}.ImagePositionPatient(3) < atMetaData{2}.ImagePositionPatient(3)
            atMetaData{cc+1}.ImagePositionPatient(3) = atMetaData{cc}.ImagePositionPatient(3) + computedSliceThikness;               
            atMetaData{cc+1}.SliceLocation = atMetaData{cc}.SliceLocation + computedSliceThikness; 
        else
            atMetaData{cc+1}.ImagePositionPatient(3) = atMetaData{cc}.ImagePositionPatient(3) - computedSliceThikness;               
            atMetaData{cc+1}.SliceLocation = atMetaData{cc}.SliceLocation - computedSliceThikness;             
        end
    end    
end