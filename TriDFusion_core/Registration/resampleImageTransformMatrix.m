function [resampImage, atDcmMetaData] = resampleImageTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%function [resampImage, atDcmMetaData] = resampleImageTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
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
    TF = affine3d(M);

%    if dimsDcm(3) == dimsRef(3)
        Rdcm = imref3d(size(dcmImage), atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
        Rref = imref3d(size(refImage), atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), refSliceThickness);
        [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
        
        if numel(resampImage) ~=  numel(refImage) % Temp patch

            if dimsDcm(3) ~= dimsRef(3)
                resampImage = imresize3(resampImage,[dimsRef(1) dimsRef(2) dimsRef(3)]);                
            else
                sameAsInput  = affineOutputView(size(refImage),TF,'BoundsStyle','SameAsInput');
                [resampImage, ~] = imwarp(dcmImage, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', sameAsInput );  
            end
                     
        end
%    end

    if numel(atRefMetaData) < numel(atDcmMetaData) && ...
       numel(atDcmMetaData) ~= 1   
        atDcmMetaData = atDcmMetaData(1:numel(atRefMetaData));

    elseif numel(atRefMetaData) > numel(atDcmMetaData) && ...
           numel(atDcmMetaData) ~= 1   

        for cc=1:numel(atRefMetaData)- numel(atDcmMetaData)
            atDcmMetaData{end+1} = atDcmMetaData{end}; %Add missing slice
        end
    end
    
    aResampledImageSize = size(resampImage);

    for jj=1:numel(atDcmMetaData)
        if numel(atRefMetaData)==numel(atDcmMetaData)
            atDcmMetaData{jj}.PatientPosition = atDcmMetaData{jj}.PatientPosition;  
            atDcmMetaData{jj}.InstanceNumber  = atRefMetaData{jj}.InstanceNumber;               
            atDcmMetaData{jj}.NumberOfSlices  = atRefMetaData{jj}.NumberOfSlices;
        else
            atDcmMetaData{jj}.PatientPosition = atRefMetaData{1}.PatientPosition;  
            atDcmMetaData{jj}.InstanceNumber  = jj;               
            atDcmMetaData{jj}.NumberOfSlices  = numel(atRefMetaData);                
        end

        atDcmMetaData{jj}.PixelSpacing(1) = atRefMetaData{jj}.PixelSpacing(1);
        atDcmMetaData{jj}.PixelSpacing(2) = atRefMetaData{jj}.PixelSpacing(2);
        atDcmMetaData{jj}.SliceThickness  = atRefMetaData{jj}.SliceThickness;
        atDcmMetaData{jj}.SpacingBetweenSlices  = refSliceThickness;
        
        atDcmMetaData{jj}.Rows    = aResampledImageSize(1);
        atDcmMetaData{jj}.Columns = aResampledImageSize(2);      
    end
       
    for cc=1:numel(atDcmMetaData)        
        atDcmMetaData{cc}.ImagePositionPatient = atRefMetaData{cc}.ImagePositionPatient;               
        atDcmMetaData{cc}.SliceLocation = atDcmMetaData{cc}.SliceLocation - refSliceThickness;                                      
    end       
    
end