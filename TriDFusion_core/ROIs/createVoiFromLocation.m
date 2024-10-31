function createVoiFromLocation(pAxe, ptX, ptY, aBuffer, dPercentOfMax, dSeriesOffset, bPixelEdge)
%function createVoiFromLocation(pAxe, ptX, ptY, aBuffer, dPercentOfMax, dSeriesOffset, bPixelEdge)
%Create a VOI from a 3D image xy coordinate.
%See TriDFuison.doc (or pdf) for more information about options.
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

    try

    pMousePointer = get(fiMainWindowPtr('get'), 'Pointer');

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
    drawnow;

    aImageSize = size(aBuffer);

    % Apply constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

    bInvertMask = invertConstraint('get');

    atRoiInput = roiTemplate('get', dSeriesOffset);

    aLogicalMask = roiConstraintToMask(aBuffer, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask); 

    aBuffer(aLogicalMask==0) = min(aBuffer, [], 'all'); % Apply constraint

    % Given:
    switch (pAxe)

        case axePtr('get', [], dSeriesOffset) % 2D

            [rows, cols] = size(aBuffer); % Get the image dimensions

        case axes1Ptr('get', [], dSeriesOffset) % Coronal
              [~, cols, rows] = size(aBuffer);

        case axes2Ptr('get', [], dSeriesOffset) % Coronal
             [rows, ~, cols] = size(aBuffer);

       case axes3Ptr('get', [], dSeriesOffset) % Coronal
            [rows, cols, ~] = size(aBuffer);
    end

    % Define a scaling factor (e.g., 1.5% of the minimum dimension)
    scaleFactor = 0.015;
    
    % Compute the neighborhood size based on a percentage of the minimum dimension
    neighborhoodSize = round(scaleFactor * min(rows, cols));
    
    % Make sure neighborhoodSize is at least 1
    neighborhoodSize = max(neighborhoodSize, 1);

    % Define the size of the neighborhood
    % neighborhoodSize = 3; % 1 for 3x3, 2 for 5x5, etc.

    dImageGrayThreshold = graythresh(aBuffer);

    switch (pAxe)

        case axePtr('get', [], dSeriesOffset) % 2D

            [row, cols] = size(aBuffer);
            
            % Determine the indices of the neighborhood in the coronal slice
            minX = max(ptX - neighborhoodSize, 1);
            maxX = min(ptX + neighborhoodSize, cols);
            minY = max(ptY - neighborhoodSize, 1);
            maxY = min(ptY + neighborhoodSize, row);
            
            % Extract the neighborhood
            neighborhood = aBuffer(minY:maxY, minX:maxX);
            
            % Calculate the threshold value based on the neighborhood of
            % image max
            if clickVoiPreSegmentationValue('get') ~= 0
                
                dValue = max(neighborhood(:)) * dPercentOfMax;
            else
                dValue = max(neighborhood(:)) * dImageGrayThreshold;
            end

            % if bRelativeToMax == true
            %     dValue = aBuffer(ptX,ptY) * dPercentOfMax;
            % else
            %     dValue = aBuffer(ptX,ptY) * dMinTreshold;
            % end

            aSlice = aBuffer(:,:);

        case axes1Ptr('get', [], dSeriesOffset) % Coronal

            iCoronal = sliceNumber('get', 'coronal');
    
%             if bRelativeToMax == true
%                 dValue = aBuffer(iCoronal,ptX,ptY) * dPercentOfMax;
%             else
%                 dValue = aBuffer(iCoronal,ptX,ptY) * dMinTreshold;
%             end
% 
%             aSlice = permute(aBuffer(iCoronal,:,:), [3 2 1]) ;
            % Get the size of the buffer
            [~, cols, slices] = size(aBuffer);
            
            % Determine the indices of the neighborhood in the coronal slice
            minX = max(ptX - neighborhoodSize, 1);
            maxX = min(ptX + neighborhoodSize, cols);
            minZ = max(ptY - neighborhoodSize, 1);
            maxZ = min(ptY + neighborhoodSize, slices);
            
            % Extract the neighborhood
            neighborhood = aBuffer(iCoronal, minX:maxX, minZ:maxZ);
            
            % Calculate the threshold value based on the neighborhood of
            % image max
            if clickVoiPreSegmentationValue('get') ~= 0
                
                dValue = max(neighborhood(:)) * dPercentOfMax;
            else
                dValue = max(neighborhood(:)) * dImageGrayThreshold;
            end

            aSlice = permute(aBuffer(iCoronal, :, :), [3 2 1]);

        case axes2Ptr('get', [], dSeriesOffset) % Sagittal

            iSagittal = sliceNumber('get', 'sagittal');
    
%             if bRelativeToMax == true
%                 dValue = aBuffer(ptX,iSagittal,ptY) * dPercentOfMax;
%             else
%                 dValue = aBuffer(ptX,iSagittal,ptY) * dMinTreshold;
%             end
% 
%             aSlice = permute(aBuffer(:,iSagittal,:), [3 1 2]) ;
            
            
            % Get the size of the buffer
            [rows, ~, slices] = size(aBuffer);
            
            % Determine the indices of the neighborhood in the sagittal slice
            minY = max(ptX - neighborhoodSize, 1);
            maxY = min(ptX + neighborhoodSize, rows);
            minZ = max(ptY - neighborhoodSize, 1);
            maxZ = min(ptY + neighborhoodSize, slices);
            
            % Extract the neighborhood
            neighborhood = aBuffer(minY:maxY, iSagittal, minZ:maxZ);
            
            % Calculate the threshold value based on the neighborhood of
            % image max
            if clickVoiPreSegmentationValue('get') ~= 0
                
                dValue = max(neighborhood(:)) * dPercentOfMax;
            else
                dValue = max(neighborhood(:)) * dImageGrayThreshold;
            end
     
            aSlice = permute(aBuffer(:, iSagittal, :), [3 1 2]);

        case axes3Ptr('get', [], dSeriesOffset) % Axial

            iAxial = sliceNumber('get', 'axial');
% 
%             if bRelativeToMax == true
%                 dValue = aBuffer(ptY,ptX,iAxial) * dPercentOfMax;
%             else
%                 dValue = aBuffer(ptY,ptX,iAxial) * dMinTreshold;
%             end
%             
%             aSlice = aBuffer(:, :, iAxial);

            
            % Get the size of the buffer
            [rows, cols, ~] = size(aBuffer);

        
            % Determine the indices of the neighborhood
            minY = max(ptY - neighborhoodSize, 1);
            maxY = min(ptY + neighborhoodSize, rows);
            minX = max(ptX - neighborhoodSize, 1);
            maxX = min(ptX + neighborhoodSize, cols);
            
            % Extract the neighborhood
            neighborhood = aBuffer(minY:maxY, minX:maxX, iAxial);

            % Calculate the threshold value based on the neighborhood of
            % image max
            if clickVoiPreSegmentationValue('get') ~= 0
                
                dValue = max(neighborhood(:)) * dPercentOfMax;
            else
                dValue = max(neighborhood(:)) * dImageGrayThreshold;
            end

            aSlice = aBuffer(:, :, iAxial);

    end

%     dImageMin = min(aBuffer, [], 'all');
%     dImageMax = max(aBuffer, [], 'all');

%     dValueRatio = dValue / dImageMax;
%     dScalingFactor = 177.75; 
%     dScalingFactor = 20; 
% Define neighborhood size for smoothing and adaptive methods

    % if size(aBuffer, 3) == 1
    %     smoothedBuffer = medfilt2(aBuffer, [3 3 3]); % Apply a median filter to reduce noise
    % else
    %     smoothedBuffer = medfilt3(aBuffer, [3 3 3]); % Apply a median filter to reduce noise
    % end

    % Step 1: Use Otsu's method for dynamic thresholding to set dPreSeg adaptively
    % [dOtsuThreshold, EF] = graythresh(aBuffer); % Otsu's global threshold

    if clickVoiPreSegmentationValue('get') ~= 0

        dPreSeg = max(aBuffer, [], 'all') * clickVoiPreSegmentationValue('get') / 100;

        dMin = min(aSlice, [], 'all');

        aSlice(aSlice<=dPreSeg) = dMin;
        aSlice(aSlice<=dValue ) = dMin;

        aSlice = imbinarize(aSlice);

    else
        dOtsuThreshold = multithresh(neighborhood(:));

        aSlice(aSlice<=dValue ) = min(aSlice, [], 'all');
        % aSlice = imbinarize(aSlice, dOtsuThreshold);
        aSlice = imbinarize(aSlice);
    end

    % dPreSeg = max(aBuffer, [], 'all') * dOtsuThreshold; % Use the Otsu threshold as dPreSeg

       % dPreSeg = max(aBuffer, [], 'all') * clickVoiPreSegmentationValue('get') / 100;

%     dPreSeg = max(aBuffer, [], 'all') * dValueRatio * dScalingFactor / 100;

%     dPreSeg = graythresh(aBuffer) * max(aBuffer, [], 'all');
%     if dValue < dPreSeg
%         dPreSeg = dValue;
%     end

     % aSlice(aSlice<=dPreSeg) = 0;
     % aSlice(aSlice~=0) =1; 

     boundary = bwboundaries(aSlice, 8, 'noholes');
%     boundary = bwboundaries(imbinarize(aSlice,graythresh(aSlice)), 8, 'noholes');
 

    if ~isempty(boundary)

        bBreak = false;

        aMask = zeros(size(aBuffer));

%         aBuffer(aBuffer<=dPreSeg)=0;
% 
%         aBuffer(aBuffer<=dValue)=0;
%         aBuffer(aBuffer~=0) =1;  

        xmin=0.5;
        xmax=1;
        aColor=xmin+rand(1,3)*(xmax-xmin);
        
        sLesionType = 'Unspecified';
      
        sLabel = sprintf('RMAX-%d-VOI%d', dPercentOfMax*100, numel(voiTemplate('get', dSeriesOffset))+1);

%         asTag = [];
        asTag = cell(1000, 1);

        dTagOffset=1;

        for jj=1:numel(boundary)

            if cancelCreateVoiRoiPanel('get') == true
                % bBreak = true;
                break;
            end

            inBoundary = inpolygon(ptX, ptY, boundary{jj}(:, 2), boundary{jj}(:, 1));

            if inBoundary
% 
                aSegmentedBuffer = aBuffer;

                if clickVoiPreSegmentationValue('get') ~= 0
                    
                    aSegmentedBuffer(aSegmentedBuffer<=dPreSeg) = min(aSegmentedBuffer, [], 'all');   
                    aSegmentedBuffer(aSegmentedBuffer<=dValue ) = min(aSegmentedBuffer, [], 'all');

                    aSegmentedBuffer = imbinarize(aSegmentedBuffer);
              % aSegmentedBuffer(aSegmentedBuffer~=0)=1;                    
                else
                    aSegmentedBuffer(aSegmentedBuffer<=dValue ) = min(aSegmentedBuffer, [], 'all');

                    if dValue/max(aBuffer, [], 'all') > 0.25
                        aSegmentedBuffer = imbinarize(aSegmentedBuffer);
                    else
                        aSegmentedBuffer = imbinarize(aSegmentedBuffer, dOtsuThreshold);
                    end
                end

                % aSegmentedBuffer(aSegmentedBuffer<=dPreSeg)=0;   
                % aSegmentedBuffer(aSegmentedBuffer~=0)=1;      

%                 boundary3D = bwconncomp(aSegmentedBuffer, 6);
                boundary3D = bwconncomp(aSegmentedBuffer, conndef(3,'maximal'));

                switch (pAxe)

                    case axePtr('get', [], dSeriesOffset) % 2D
                         linearIndex = sub2ind(aImageSize, ptY, ptX, 1);

                    case axes1Ptr('get', [], dSeriesOffset) % Coronal
                         linearIndex = sub2ind(aImageSize, iCoronal, ptX, ptY);

                    case axes2Ptr('get', [], dSeriesOffset) % Sagittal
                         linearIndex = sub2ind(aImageSize, ptX, iSagittal, ptY);

                   case axes3Ptr('get', [], dSeriesOffset) % Axial
                        linearIndex = sub2ind(aImageSize, ptY, ptX, iAxial);
                end

                for kk=1:numel(boundary3D.PixelIdxList)
                    
                    % if isscalar(numel(boundary3D.PixelIdxList{kk}))
                    %     continue;
                    % end

                    if cancelCreateVoiRoiPanel('get') == true
                        bBreak = true;
                        break;
                    end

                    linearIndices = boundary3D.PixelIdxList{kk};
                    isInsideComponent = ismember(linearIndex, linearIndices);

                    if isInsideComponent

                        aSegmentedBuffer = aBuffer;
    
                        dVoiMax = max(aSegmentedBuffer(boundary3D.PixelIdxList{kk}), [], 'all');    

%                         aMask=zeros(size(aSegmentedBuffer));
                        aMask(:) = 0;
                        aMask(boundary3D.PixelIdxList{kk})=1; 
                  
                        aMask(aSegmentedBuffer<=(dVoiMax*dPercentOfMax)) = 0;
                        
                        % Get the subscripts of the connected component voxels

                        switch (pAxe)
                            case axePtr('get', [], dSeriesOffset) % 2D
                                [~, ~, subZ] = ind2sub(boundary3D.ImageSize, linearIndices);  

                            case axes1Ptr('get', [], dSeriesOffset) % Coronal
                                [subZ, ~, ~] = ind2sub(boundary3D.ImageSize, linearIndices);  

                            case axes2Ptr('get', [], dSeriesOffset) % Sagittal
                                [~, subZ, ~] = ind2sub(boundary3D.ImageSize, linearIndices);  
                                 
                            case axes3Ptr('get', [], dSeriesOffset) % Axial
                                [~, ~, subZ] = ind2sub(boundary3D.ImageSize, linearIndices);                                   
                        end
                        
                        % Find unique subZ values
                        uniqueZ = unique(subZ);
                        
                        % Create images.roi.Freehand objects for each unique subZ
                        for i = 1:numel(uniqueZ)

                            if cancelCreateVoiRoiPanel('get') == true
                               bBreak = true;
                               break;
                            end

                            % Get the subscripts corresponding to the current uniqueZ value
                            currZ = uniqueZ(i);

                            if numel(uniqueZ) > 25
                                progressBar(i/numel(uniqueZ), sprintf('Processing mask slice %d/%d', i, numel(uniqueZ) ) );      
                            end

                            switch (pAxe)

                               case axePtr('get', [], dSeriesOffset) % 2D
                                    aSlice = aMask(:,:);

                               case axes1Ptr('get', [], dSeriesOffset) % Axial

                                    aSlice = permute(aMask(currZ,:,:), [3 2 1]) ;
                                    sliceNumber('set', 'coronal', currZ);

                               case axes2Ptr('get', [], dSeriesOffset) % Axial

                                    aSlice = permute(aMask(:,currZ,:), [3 1 2]) ;
                                    sliceNumber('set', 'sagittal', currZ);

                               case axes3Ptr('get', [], dSeriesOffset) % Axial

                                    aSlice = aMask(:,:,currZ); 
                                    sliceNumber('set', 'axial', currZ);
                            end

                            if bPixelEdge == true                    
                               aSlice = imresize(aSlice,3, 'nearest'); % do not go directly through pixel centers
                            end

                            B = bwboundaries(aSlice, 8, 'noholes');
                            if isempty(B)
                                continue;
                            end
                            
                            for ii = 1:numel(B)

                                if cancelCreateVoiRoiPanel('get') == true
                                    bBreak = true;
                                    break;
                                end
                                
                                aPosition = B{ii};
                                aPosition = flip(aPosition, 2);

                                if bPixelEdge == true                    
                                    aPosition = (aPosition +1)/3; 
                                else
                                    aPosition = smoothRoi(aPosition, aImageSize);
                                end

                                sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                if size(aBuffer, 3) ~= 1 %3D

                                    sRoiLabel = '';
                                else
                                    sRoiLabel = sprintf('RMAX-%d-ROI%d', dPercentOfMax*100, numel(roiTemplate('get', dSeriesOffset))+1);
                                end

                                % Create the images.roi.Freehand object
                                pRoi = images.roi.Freehand(pAxe, ...
                                                           'Smoothing'     , 1, ...
                                                           'Position'      , aPosition, ...
                                                           'Color'         , aColor, ...
                                                           'LineWidth'     , 1, ...
                                                           'Label'         , sRoiLabel, ...
                                                           'LabelVisible'  , 'off', ...
                                                           'Tag'           , sTag, ...
                                                           'Visible'       , 'off', ...
                                                           'FaceSelectable', 0, ...
                                                           'FaceAlpha'     , roiFaceAlphaValue('get')); 
                                pRoi.Waypoints(:) = false;
            
                                addRoi(pRoi, dSeriesOffset, sLesionType);                  
            
                                roiDefaultMenu(pRoi);
            
                                uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback); 
                                uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', pRoi, 'Callback', @clearWaypointsCallback); 
                                
                                constraintMenu(pRoi);
            
                                cropMenu(pRoi);
            
                                voiDefaultMenu(pRoi);
                            
                                uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');          

%                                 asTag{numel(asTag)+1} = sTag;
                                asTag{dTagOffset} = sTag;
                                dTagOffset = dTagOffset+1;

                                drawnow limitrate;
                                
                                if dTagOffset > numel(asTag)
                                    bBreak = true;
                                    break;
                                end

                                if bBreak == true
                                    break;
                                end                        
                            end

                            if bBreak == true
                                break;
                            end                        
                        end
                        
                        % clear aMask;

                        % bBreak = true;
                        % break;    
                    end

                    if bBreak == true
                        break;
                    end
                end

                clear aSegmentedBuffer;
            end

            if bBreak == true
                break;
            end            
        end

        asTag = asTag(~cellfun(@isempty, asTag));

        if ~isempty(asTag)

            if size(aBuffer, 3) ~= 1 %3D

                createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
                setVoiRoiSegPopup();
                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
            end
        end

        switch (pAxe)

            case axes1Ptr('get', [], dSeriesOffset) % Axial
                sliceNumber('set', 'coronal', iCoronal);

            case axes2Ptr('get', [], dSeriesOffset) % Axial
                sliceNumber('set', 'sagittal', iSagittal);

            case axes3Ptr('get', [], dSeriesOffset) % Axial
                sliceNumber('set', 'axial', iAxial);
        end

        refreshImages();

        clear aMask;
    end

    progressBar(1, 'Ready');      

    catch
        progressBar(1, 'Error:createVoiFromLocation()');          
    end  

    set(fiMainWindowPtr('get'), 'Pointer', pMousePointer);
    drawnow;  

    clear aLogicalMask;

end



