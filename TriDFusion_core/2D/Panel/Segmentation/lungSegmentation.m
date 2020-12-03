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

    tSegmentMetaData = dicomMetaData('get');   

    % Axial 
    if strcmpi(sPlane, 'axial') ||  strcmpi(sPlane, 'all') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);

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

            progressBar(iAxial / sizeOf(3), 'Computing lung segmentation axial plane');

        end

        imPlane = im;
    end

    if strcmpi(sPlane, 'coronal')  ||  strcmpi(sPlane, 'all') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);

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

            maskc(iCoronal,:,:) = maskedImageXY;

            c = maskc(iCoronal,:,:);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
            im(iCoronal,:,:) = permuteBuffer(b, 'coronal'); 

            progressBar(iCoronal / sizeOf(1), 'Computing lung segmentation coronal plane');

        end

        if strcmpi(sPlane, 'all') 
            for idx = find(imPlane == cropValue('get'))
                imPlane(idx) = im(idx);
            end
        else                    
            imPlane = imCoronalPlane;
        end

    end

    if strcmpi(sPlane, 'sagittal')  ||  strcmpi(sPlane, 'all') 

        im = dicomBuffer('get');            
        imSingle = im2single(im);
        sizeOf = size(im);

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

            masks(:,iSagittal,:) = maskedImageXY;

            c = masks(:,iSagittal,:);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
            im(:,iSagittal,:) = permuteBuffer(b, 'sagittal');             

            progressBar(iSagittal / sizeOf(2), 'Computing lung segmentation sagittal plane');
        end

        if strcmpi(sPlane, 'all') 
            for idx = find(imPlane == cropValue('get'))
                imPlane(idx) = im(idx);
            end  
        else
            imPlane = imSagittalPlane;
        end

    end                        

    progressBar(1, 'Ready');

    dicomBuffer('set', imPlane);

    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();

end        
