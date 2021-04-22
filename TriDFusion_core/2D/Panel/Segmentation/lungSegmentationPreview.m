function lungSegmentationPreview(dTreshold) 
%function lungSegmentationPreview(dTreshold) 
%Create a Lung Segmentation preview to find the Treshold Value.
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

    im = dicomBuffer('get');            
    if isempty(im)
        return;
    end

    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    try  
    
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
        
    progressBar(1 / 3, 'Computing axial preview');

    tSegmentMetaData = dicomMetaData('get');   

  %  tSegmentMetaData.RescaleIntercept + (aInput{i}(:,:,ii) * tSegmentMetaData.RescaleSlope)

    imSingle = im2single(im);

    imCoronal  = imCoronalPtr ('get');
    imSagittal = imSagittalPtr('get');
    imAxial    = imAxialPtr   ('get');  

    iCoronal  = sliceNumber('get', 'coronal' );
    iSagittal = sliceNumber('get', 'sagittal');
    iAxial    = sliceNumber('get', 'axial'   );

    % Axial 

    b = im(:,:,iAxial);   

    XY = imSingle(:,:,iAxial);
    BW = XY > dTreshold * tSegmentMetaData{1}.RescaleIntercept; % treshold

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
    im(:,:,iAxial) = b;     

    imAxial.CData = im(:,:,iAxial);

     progressBar(2 / 3, 'Computing coronal preview');

    % Coronal 

    im = dicomBuffer('get');
    imSingle = im2single(im);

    b = permute(im(iCoronal,:,:), [3 2 1]);  

    XY = permute(imSingle(iCoronal,:,:), [3 2 1]);
    BW = XY > dTreshold * tSegmentMetaData{1}.RescaleIntercept; % treshold

    BW = imcomplement(BW);
    BW = imclearborder(BW);
    BW = imfill(BW, 'holes');
    radius = 13;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imerode(BW, se);
    maskedImageXY = XY;
    maskedImageXY(~BW) = 0;        

    maskc(iCoronal,:,:) = maskedImageXY;

    c = maskc(iCoronal,:,:);
    b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
    im(iCoronal,:,:) = permuteBuffer(b, 'coronal'); 

    imCoronal.CData  = permute(im(iCoronal,:,:), [3 2 1]);

    progressBar(2 / 3, 'Computing sagittal preview');

    % Sagittal 

    im = dicomBuffer('get');
    imSingle = im2single(im);

    b = permute(im(:,iSagittal,:), [3 1 2]);  

    XY = permute(imSingle(:,iSagittal,:), [3 1 2]);
    BW = XY > dTreshold * tSegmentMetaData{1}.RescaleIntercept; % treshold

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
    im(:,iSagittal,:) = permuteBuffer(b, 'sagittal'); 

    imSagittal.CData = permute(im(:,iSagittal,:), [3 1 2]);

    progressBar(1, 'Ready');
    
    catch
        progressBar(1, 'Error:lungSegmentationPreview()');           
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
end
