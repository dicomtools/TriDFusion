function lungSegmentation(dTreshold, dRadius)    
%function lungSegmentation(dTreshold, dRadius)  
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
    
    tSegmentMetaData = dicomMetaData('get');   
    dNbMeta = numel(tSegmentMetaData);
    
    % Get constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);     
    
    dImageMin = min(double(aBuffer),[], 'all');

    aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint
    
    % Axial 

    imSingle = im2single(aBuffer);
    sizeOf = size(aBuffer);
    mask = zeros(sizeOf);


    for iAxial=1:sizeOf(3)               

        b = aBuffer(:,:,iAxial);   

        XY = imSingle(:,:,iAxial);

        if dNbMeta == sizeOf(3)
            BW = XY > dTreshold * tSegmentMetaData{iAxial}.RescaleIntercept; % treshold
        else
            BW = XY > dTreshold * tSegmentMetaData{1}.RescaleIntercept; % treshold
        end

        BW = imcomplement(BW);
        BW = imclearborder(BW);
        BW = imfill(BW, 'holes');
        radius = dRadius;
        decomposition = 0;
        se = strel('disk',radius,decomposition);
        BW = imerode(BW, se);
        maskedImageXY = XY;
        maskedImageXY(~BW) = 0;        

        mask(:,:,iAxial) = maskedImageXY;

        c = mask(:,:,iAxial);
        b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
        aBuffer(:,:,iAxial) = b;     

        if mod(iAxial,5)==1 || iAxial == sizeOf(3)         
            progressBar(iAxial / sizeOf(3), sprintf('Computing lung segmentation axial plane %d/%d', iAxial, sizeOf(3)));
        end

    end
    
    aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint    
    
    dicomBuffer('set', aBuffer);
    
    if link2DMip('get') == true 
        aLungMip = computeMIP(aBuffer);
        mipBuffer('set', aLungMip, get(uiSeriesPtr('get'), 'Value'));
    end
                            
    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();
    
    progressBar(1, 'Ready');
    
    catch
        progressBar(1, 'Error:lungSegmentation()');           
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
end        
