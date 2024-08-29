function createVoiFromLocation(pAxe, ptX, ptY, aBuffer, dMinTreshold, dMaxTreshold, bRelativeToMax, bInPercent, dSeriesOffset, bPixelEdge)
%function createVoiFromLocation(pAxe, ptX, ptY, aBuffer, dMinTreshold, dMaxTreshold, bRelativeToMax, bInPercent, dSeriesOffset, bPixelEdge)
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

    switch (pAxe)

        case axePtr('get', [], dSeriesOffset) % 2D

        case axes1Ptr('get', [], dSeriesOffset) % Coronal

        case axes2Ptr('get', [], dSeriesOffset) % Sagittal

        case axes3Ptr('get', [], dSeriesOffset) % Axial

        otherwise
            return;
    end


    pMousePointer = get(fiMainWindowPtr('get'), 'Pointer');

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
    drawnow;

    aMaskSize = size(aBuffer);

    % Apply constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

    bInvertMask = invertConstraint('get');

    atRoiInput = roiTemplate('get', dSeriesOffset);

    aLogicalMask = roiConstraintToMask(aBuffer, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask); 

    aBuffer(aLogicalMask==0) = min(aBuffer, [], 'all'); % Apply constraint

    % Define the size of the neighborhood
    neighborhoodSize = 2; % 1 for 3x3, 2 for 5x5, etc.

    switch (pAxe)

        case axePtr('get', [], dSeriesOffset) % 2D

            if bRelativeToMax == true
                dValue = aBuffer(ptX,ptY) * dMaxTreshold;
            else
                dValue = aBuffer(ptX,ptY) * dMinTreshold;
            end

            aSlice = aBuffer(:,:);

        case axes1Ptr('get', [], dSeriesOffset) % Coronal

            iCoronal = sliceNumber('get', 'coronal');
    
%             if bRelativeToMax == true
%                 dValue = aBuffer(iCoronal,ptX,ptY) * dMaxTreshold;
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
            
            % Calculate the threshold value based on the neighborhood
            if bRelativeToMax == true
                dValue = max(neighborhood(:)) * dMaxTreshold;
            else
                dValue = max(neighborhood(:)) * dMinTreshold;
            end
            
            aSlice = permute(aBuffer(iCoronal, :, :), [3 2 1]);

        case axes2Ptr('get', [], dSeriesOffset) % Sagittal

            iSagittal = sliceNumber('get', 'sagittal');
    
%             if bRelativeToMax == true
%                 dValue = aBuffer(ptX,iSagittal,ptY) * dMaxTreshold;
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
            
            % Calculate the threshold value based on the neighborhood
            if bRelativeToMax == true
                dValue = max(neighborhood(:)) * dMaxTreshold;
            else
                dValue = max(neighborhood(:)) * dMinTreshold;
            end
            
            aSlice = permute(aBuffer(:, iSagittal, :), [3 1 2]);
        case axes3Ptr('get', [], dSeriesOffset) % Axial

            iAxial = sliceNumber('get', 'axial');
% 
%             if bRelativeToMax == true
%                 dValue = aBuffer(ptY,ptX,iAxial) * dMaxTreshold;
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

            % Calculate the mean value of the neighborhood
            if bRelativeToMax == true
                dValue = max(neighborhood(:)) * dMaxTreshold;
            else
                dValue = max(neighborhood(:)) * dMinTreshold;
            end

            aSlice = aBuffer(:, :, iAxial);

    end

    dImageMax = max(aBuffer, [], 'all');

    dValueRatio = dValue / dImageMax;
%     dScalingFactor = 177.75; 
    dScalingFactor = 20; 

       dPreSeg = max(aBuffer, [], 'all') * clickVoiPreSegmentationValue('get') / 100;

%     dPreSeg = max(aBuffer, [], 'all') * dValueRatio * dScalingFactor / 100;

%     dPreSeg = graythresh(aBuffer) * max(aBuffer, [], 'all');
%     if dValue < dPreSeg
%         dPreSeg = dValue;
%     end

     aSlice(aSlice<=dPreSeg) = 0;
     aSlice(aSlice~=0) =1; 

     boundary = bwboundaries(imbinarize(aSlice), 8, 'noholes');
%     boundary = bwboundaries(imbinarize(aSlice,graythresh(aSlice)), 8, 'noholes');

    if ~isempty(boundary)

        aBuffer(aBuffer<=dPreSeg)=min(aBuffer, [], 'all');

        bBreak = false;

        xmin=0.5;
        xmax=1;
        aColor=xmin+rand(1,3)*(xmax-xmin);
        
        sLesionType = 'Unspecified';

        if bRelativeToMax == true
            sLabel = sprintf('RMAX-%d-VOI%d', dMaxTreshold*100, numel(voiTemplate('get', dSeriesOffset))+1);
        else
            sLabel = sprintf('MIN-MAX-%d-%d-VOI%d', dMinTreshold*100, dMaxTreshold*100, numel(voiTemplate('get', dSeriesOffset))+1);
        end

        asTag = [];

        for jj=1:numel(boundary)

            if cancelCreateVoiRoiPanel('get') == true
                break;
            end

            inBoundary = inpolygon(ptX, ptY, boundary{jj}(:, 2), boundary{jj}(:, 1));

            if inBoundary
% 
                aBuffer(aBuffer<=dValue)=0;
                aBuffer(aBuffer~=0) =1;     

                boundary3D = bwconncomp(imbinarize(aBuffer), 6);
                switch (pAxe)
                    case axePtr('get', [], dSeriesOffset) % 2D
                         linearIndex = sub2ind(size(aBuffer), ptX, ptY, 1);

                    case axes1Ptr('get', [], dSeriesOffset) % Coronal
                         linearIndex = sub2ind(size(aBuffer), iCoronal, ptX, ptY);

                    case axes2Ptr('get', [], dSeriesOffset) % Sagittal
                         linearIndex = sub2ind(size(aBuffer), ptX, iSagittal, ptY);

                   case axes3Ptr('get', [], dSeriesOffset) % Axial
                        linearIndex = sub2ind(size(aBuffer), ptY, ptX, iAxial);
                end

                for kk=1:numel(boundary3D.PixelIdxList)

                    if cancelCreateVoiRoiPanel('get') == true
                        break;
                    end

                    linearIndices = boundary3D.PixelIdxList{kk};
                    isInsideComponent = ismember(linearIndex, linearIndices);

                    if isInsideComponent

                        aBuffer = dicomBuffer('get', [], dSeriesOffset);
    
                        dVoiMax = max(aBuffer(boundary3D.PixelIdxList{kk}), [], 'all');    

                        aMask=zeros(size(aBuffer));
                        aMask(boundary3D.PixelIdxList{kk})=1; 

                        if bRelativeToMax == true
                            aMask(aBuffer<=(dVoiMax*dMaxTreshold)) = 0;
                        else
                            aMask(aBuffer>=(dVoiMax*dMaxTreshold)) = 0;
                            aMask(aBuffer<=(dVoiMax*dMinTreshold)) = 0;
                        end
                    
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
                                    break;
                                end
                                
                                aPosition = B{ii};
                                aPosition = flip(aPosition, 2);

                                if bPixelEdge == true                    
                                    aPosition = (aPosition +1)/3; 
                                else
                                    aPosition = smoothRoi(aPosition, aMaskSize);
                                end

                                sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                % Create the images.roi.Freehand object
                                pRoi = images.roi.Freehand(pAxe, ...
                                                           'Smoothing'     , 1, ...
                                                           'Position'      , aPosition, ...
                                                           'Color'         , aColor, ...
                                                           'LineWidth'     , 1, ...
                                                           'Label', ''     , ...
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
            
                                voiMenu(pRoi);
                            
                                uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');          

                                asTag{numel(asTag)+1} = sTag;

                                drawnow limitrate;
                        
                            end
                        end
                        
                        clear aMask;

                        bBreak = true;
                        break;    
                    end
                end

                if bBreak == true
                    break;
                end

            end
            
        end

        if ~isempty(asTag)
            createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
            setVoiRoiSegPopup();
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

    end

    progressBar(1, 'Ready');      

    catch
        progressBar(1, 'Error:createVoiFromLocation()');          
    end  

    set(fiMainWindowPtr('get'), 'Pointer', pMousePointer);
    drawnow;  

    clear aLogicalMask;

end



