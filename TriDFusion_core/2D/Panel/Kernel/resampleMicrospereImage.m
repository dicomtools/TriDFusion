function [aResampledImage, atResampledMetaData] = resampleMicrospereImage(aImage, atMetaData, dSizeX, dSizeY, dSizeZ)
%function [aResampledImage, atMetaData] = resampleMicrospereImage(aImage, atMetaData, dSizeX, dSizeY, dSizeZ)
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

    imageOrientation('set', 'axial');
    
    dimsDcm = size(aImage);
    
    % Set new dicom information 
    
    dcmSliceThickness = atMetaData{1}.SpacingBetweenSlices;
        
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
    
    progressBar(0.5, 'Resampling image, please wait.');
    
    % Resample Image
        
    [M, ~] = getTransformMatrix(atMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);    
    
    Rdcm = imref3d(dimsDcm, atMetaData{1}.PixelSpacing(2), atMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    
    [aResampledImage, ~] = imwarp(aImage, Rdcm, TF,'Interp', 'Linear', 'FillValues', double(min(aImage,[],'all')));  
%    [aImage, ~] = imwarp(aImage, TF, 'Interp', 'Linear', 'FillValues', double(min(aImage,[],'all')), 'OutputView', imref3d(dimsRef));  

    % Set dicom header

    aResampledImageSize = size(aResampledImage);
    aResampledImage = imresize3(aImage, aResampledImageSize);
    
    atResampledMetaData = atMetaData;
    
    if numel(atResampledMetaData) ~= 1
        if aResampledImageSize(3) < numel(atResampledMetaData)
            atResampledMetaData = atResampledMetaData(1:aResampledImageSize(3)); % Remove some slices
        else
            for cc=1:aResampledImageSize(3) - numel(atResampledMetaData)
                atResampledMetaData{end+1} = atResampledMetaData{end}; %Add missing slice
            end            
        end                
    end
      
    for jj=1:numel(atResampledMetaData)
        
        atResampledMetaData{jj}.InstanceNumber  = jj;               
        atResampledMetaData{jj}.NumberOfSlices  = aResampledImageSize(3);                
        
        atResampledMetaData{jj}.PixelSpacing(1) = dSizeX;
        atResampledMetaData{jj}.PixelSpacing(2) = dSizeY;
        atResampledMetaData{jj}.SliceThickness  = dSizeZ;
        atResampledMetaData{jj}.SpacingBetweenSlices  = dSizeZ;

        atResampledMetaData{jj}.Rows    = aResampledImageSize(1);
        atResampledMetaData{jj}.Columns = aResampledImageSize(2);
        atResampledMetaData{jj}.NumberOfSlices = numel(atResampledMetaData);                  
    end
              
    for cc=1:numel(atResampledMetaData)-1
        if atResampledMetaData{1}.ImagePositionPatient(3) < atResampledMetaData{2}.ImagePositionPatient(3)
            atResampledMetaData{cc+1}.ImagePositionPatient(3) = atResampledMetaData{cc}.ImagePositionPatient(3) + dSizeZ;               
            atResampledMetaData{cc+1}.SliceLocation = atResampledMetaData{cc}.SliceLocation + dSizeZ; 
        else
            atResampledMetaData{cc+1}.ImagePositionPatient(3) = atResampledMetaData{cc}.ImagePositionPatient(3) - dSizeZ;               
            atResampledMetaData{cc+1}.SliceLocation = atResampledMetaData{cc}.SliceLocation - dSizeZ;             
        end
    end   
    
    % Resample ROIs

    uiSeries = uiSeriesPtr('get');
    dSeriesOffset = get(uiSeries, 'Value');

    atRoi = roiTemplate('get', dSeriesOffset);

    if ~isempty(atRoi)
        atResampledRoi = resampleROIs(aImage, atMetaData, aResampledImage, atResampledMetaData, atRoi, false);

        roiTemplate('set', dSeriesOffset, atResampledRoi);
    end
    
    progressBar(1, 'Ready');
                
end