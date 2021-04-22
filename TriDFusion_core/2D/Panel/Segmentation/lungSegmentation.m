function lungSegmentation(sPlane, dTreshold)    
%function lungSegmentation(sPlane, dTreshold)  
%Extract the Lung of CT Images.
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

    if isempty(dicomBuffer('get'))
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
    
    tSegmentMetaData = dicomMetaData('get');   

    % Axial 
    if strcmpi(sPlane, 'Axial') ||  strcmpi(sPlane, 'All') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);
        mask = zeros(sizeOf);
        
        for iAxial=1:sizeOf(3)               

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

            if mod(iAxial,5)==1 || iAxial == sizeOf(3)         
                progressBar(iAxial / sizeOf(3), sprintf('Computing lung segmentation axial plane %d/%d', iAxial, sizeOf(3)));
            end

        end

        imPlane = im;
        
        clear mask;        
    end

    if strcmpi(sPlane, 'Coronal')  ||  strcmpi(sPlane, 'All') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);
        maskc = zeros(sizeOf);

        for iCoronal=1:sizeOf(1)               

            b = permute(im(iCoronal,:,:), [3 2 1]);  

            XY = permute(imSingle(iCoronal,:,:), [3 2 1]);
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

            maskc(iCoronal,:,:) = permuteBuffer(maskedImageXY, 'coronal');

            c = maskc(iCoronal,:,:);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
            im(iCoronal,:,:) = permuteBuffer(b, 'coronal'); 

            if mod(iCoronal,5)==1 || iCoronal == sizeOf(1)         
                progressBar(iCoronal / sizeOf(1), sprintf('Computing lung segmentation coronal plane %d/%d', iCoronal, sizeOf(1)));
            end

        end
                
        if strcmpi(sPlane, 'All') 
            for idx = find(imPlane == cropValue('get'))
                imPlane(idx) = im(idx);
            end
        else                    
            imPlane = imCoronalPlane;
        end
        
        clear maskc;

    end

    if strcmpi(sPlane, 'Sagittal')  ||  strcmpi(sPlane, 'All') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);
        masks = zeros(sizeOf);

        for iSagittal=1:sizeOf(2)               

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

            masks(:,iSagittal,:) = permuteBuffer(maskedImageXY, 'sagittal');

            c = masks(:,iSagittal,:);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
            im(:,iSagittal,:) = permuteBuffer(b, 'sagittal');             

            if mod(iSagittal,5)==1 || iSagittal == sizeOf(2)         
                progressBar(iSagittal / sizeOf(2), sprintf('Computing lung segmentation sagittal plane %d/%d', iSagittal, sizeOf(2)));
            end
        end

        if strcmpi(sPlane, 'All') 
            for idx = find(imPlane == cropValue('get'))
                imPlane(idx) = im(idx);
            end  
        else
            imPlane = imSagittalPlane;
        end
        
        clear masks;

    end                        

    progressBar(1, 'Ready');

    dicomBuffer('set', imPlane);

    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();
    
    catch
        progressBar(1, 'Error:lungSegmentation()');           
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
end        
