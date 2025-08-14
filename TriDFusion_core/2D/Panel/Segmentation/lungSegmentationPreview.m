function lungSegmentationPreview(dThreshold, dRadius) 
%function lungSegmentationPreview(dThreshold, dRadius) 
%Create a Lung Segmentation preview to find the Threshold Value.
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

    aBuffer = dicomBuffer('get');            
    if isempty(aBuffer)
        return;
    end

    aBufferInit = aBuffer;
    
    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    try  
    
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
       
    
    % Get constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);     
    
    dImageMin = min(double(aBuffer),[], 'all');

    aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint
           
    progressBar(1 / 3, 'Computing axial preview');

    tSegmentMetaData = dicomMetaData('get');   
    dNbMeta = numel(tSegmentMetaData);

  %  tSegmentMetaData.RescaleIntercept + (aInput{i}(:,:,ii) * tSegmentMetaData.RescaleSlope)

    imSingle = im2single(aBuffer);

    imCoronal  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value') );
    imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value') );
    imAxial    = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value') );  

    iCoronal  = sliceNumber('get', 'coronal' );
    iSagittal = sliceNumber('get', 'sagittal');
    iAxial    = sliceNumber('get', 'axial'   );

    % Axial 

    b = aBuffer(:,:,iAxial);   

    XY = imSingle(:,:,iAxial);
    if dNbMeta >= iAxial
        BW = XY > dThreshold * tSegmentMetaData{iAxial}.RescaleIntercept; % Threshold 
    else
        BW = XY > dThreshold * tSegmentMetaData{1}.RescaleIntercept; % Threshold 
    end

    BW = imcomplement(BW);
    BW = imclearborder(BW);
    BW = imfill(BW, 'holes');
    radius = 13;
    decomposition = 0;
    se = strel('disk',radius,decomposition);
    BW = imerode(BW, se);
    maskedImageXY = XY;
    maskedImageXY(~BW) = 0;        

    mask(:,:,iAxial) = maskedImageXY;

    c = mask(:,:,iAxial);
    b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
    aBuffer(:,:,iAxial) = b;     
    
    aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint    

    imAxial.CData = aBuffer(:,:,iAxial);

    progressBar(2 / 3, 'Computing coronal preview');

    % Coronal 

    aBuffer = dicomBuffer('get');    
    aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint
    
    imSingle = im2single(aBuffer);

    b = permute(aBuffer(iCoronal,:,:), [3 2 1]);  

    XY = permute(imSingle(iCoronal,:,:), [3 2 1]);
    if dNbMeta >= iAxial
        BW = XY > dThreshold * tSegmentMetaData{iAxial}.RescaleIntercept; % Threshold 
    else
        BW = XY > dThreshold * tSegmentMetaData{1}.RescaleIntercept; % Threshold 
    end
    
    BW = imcomplement(BW);
    BW = imclearborder(BW);
    BW = imfill(BW, 'holes');
    radius = dRadius;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imerode(BW, se);
    maskedImageXY = XY;
    maskedImageXY(~BW) = 0;        

    maskc(iCoronal,:,:) = maskedImageXY;

    c = maskc(iCoronal,:,:);
    b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
    aBuffer(iCoronal,:,:) = permuteBuffer(b, 'coronal'); 
    
    aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint    

    imCoronal.CData  = permute(aBuffer(iCoronal,:,:), [3 2 1]);

    progressBar(2 / 3, 'Computing sagittal preview');

    % Sagittal 

    aBuffer = dicomBuffer('get');
    aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint

    imSingle = im2single(aBuffer);

    b = permute(aBuffer(:,iSagittal,:), [3 1 2]);  

    XY = permute(imSingle(:,iSagittal,:), [3 1 2]);
    if dNbMeta >= iAxial
        BW = XY > dThreshold * tSegmentMetaData{iAxial}.RescaleIntercept; % Threshold 
    else
        BW = XY > dThreshold * tSegmentMetaData{1}.RescaleIntercept; % Threshold 
    end
    
    BW = imcomplement(BW);
    BW = imclearborder(BW);
    BW = imfill(BW, 'holes');
    radius = 13;
    decomposition = 0;
    se = strel('disk',radius,decomposition);
    BW = imerode(BW, se);
    maskedImageXY = XY;
    maskedImageXY(~BW) = 0;        

    masks(:,iSagittal,:) = maskedImageXY;

    c = masks(:,iSagittal,:);
    b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
    aBuffer(:,iSagittal,:) = permuteBuffer(b, 'sagittal'); 
    
    aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint    

    imSagittal.CData = permute(aBuffer(:,iSagittal,:), [3 1 2]);

    progressBar(1, 'Ready');
    
    catch ME   
        logErrorToFile(ME);
        progressBar(1, 'Error:lungSegmentationPreview()');           
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
end
