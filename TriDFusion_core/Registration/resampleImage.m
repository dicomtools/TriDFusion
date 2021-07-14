function [resampImage, atDcmMetaData] = resampleImage(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, bUpdateDescription)
%function [resampImage, atDcmMetaData] = resampleImage(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
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

    if numel(dimsRef)==numel(dimsDcm)
        if dimsRef == dimsDcm
            resampImage = dcmImage;
            return;
        end
    end 
     
    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

    yScale = size(refImage,1)/size(dcmImage,1);
    xScale = size(refImage,2)/size(dcmImage,2);
    zScale = size(refImage,3)/size(dcmImage,3);
    f = [ yScale 0      0      0
          0      xScale 0      0
          0      0      zScale 0
          0      0      0      1];
      
    if dcmSliceThickness == 0  
        dcmSliceThickness = 1;
    end
      
    if atDcmMetaData{1}.PixelSpacing(1) == 0 && ...
       atDcmMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atDcmMetaData)
            atDcmMetaData{1}.PixelSpacing(1) =1;
            atDcmMetaData{1}.PixelSpacing(2) =1;
        end       
    end

    Rdcm  = imref3d(size(dcmImage), atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    % Rref  = imref3d(size(refImage),atRefMetaData{1}.PixelSpacing(2),atRefMetaData{1}.PixelSpacing(1), refSliceThickness);

     TF = affine3d(f);

    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')) );  

    if dimsRef(3) < numel(atDcmMetaData) && ...
       numel(atDcmMetaData) ~= 1   
        atDcmMetaData = atDcmMetaData(1:dimsRef(3));

    elseif dimsRef(3) > numel(atDcmMetaData) && ...
           numel(atDcmMetaData) ~= 1   

        for cc=1:dimsRef(3)- numel(atDcmMetaData)
            atDcmMetaData{end+1} = atDcmMetaData{end}; %Add missing slice
        end
    end

    for jj=1:numel(atDcmMetaData)
        if numel(atRefMetaData)==numel(atDcmMetaData)
            atDcmMetaData{jj}.PatientPosition = atRefMetaData{jj}.PatientPosition;  
            atDcmMetaData{jj}.InstanceNumber  = atRefMetaData{jj}.InstanceNumber;               
            atDcmMetaData{jj}.NumberOfSlices  = atRefMetaData{jj}.NumberOfSlices;
        else
            atDcmMetaData{jj}.PatientPosition = atRefMetaData{1}.PatientPosition;  
            atDcmMetaData{jj}.InstanceNumber  = jj;               
            atDcmMetaData{jj}.NumberOfSlices  = numel(atRefMetaData);                
        end
        atDcmMetaData{jj}.PixelSpacing(1) = dimsDcm(1)/dimsRef(1)*atDcmMetaData{jj}.PixelSpacing(1);
        atDcmMetaData{jj}.PixelSpacing(2) = dimsDcm(2)/dimsRef(2)*atDcmMetaData{jj}.PixelSpacing(2);
        atDcmMetaData{jj}.SliceThickness  = dimsDcm(3)/dimsRef(3)*atDcmMetaData{jj}.SliceThickness;
        atDcmMetaData{jj}.SpacingBetweenSlices  = dimsDcm(3)/dimsRef(3)*atDcmMetaData{jj}.SpacingBetweenSlices;
        
        if bUpdateDescription == true 
            atDcmMetaData{jj}.SeriesDescription  = sprintf('RSP %s', atDcmMetaData{1}.SeriesDescription);
        end           
    end
       
    newSliceThickness = dcmSliceThickness * (dimsDcm(3)/dimsRef(3));        
    for cc=1:numel(atDcmMetaData)-1
        if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + newSliceThickness;               
            atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation + newSliceThickness; 
        else
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - newSliceThickness;               
            atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation - newSliceThickness;             
        end
    end        
    
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset <= numel(inputTemplate('get')) && bUpdateDescription == true 
        asDescription = seriesDescription('get');
        asDescription{iOffset} = sprintf('RSP %s', asDescription{iOffset});
        seriesDescription('set', asDescription);
    end   
end  

