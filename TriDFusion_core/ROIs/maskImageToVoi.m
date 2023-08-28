function maskImageToVoi(aMask, dSeriesOffset, aClassificationMask, bLesionClassification, bPixelEdge, dSmalestVoiValue)
%function maskImageToVoi(aMask, dSeriesOffset, aClassificationMask, bLesionClassification, bPixelEdge, dSmalestVoiValue)
%Create VOIs from a 3D mask image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by: Daniel Lafontaine
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

    sLesionType = 'Unspecified';

    PIXEL_EDGE_RATIO = 3;

    atMetaData = dicomMetaData('get', [], dSeriesOffset);
          
    dPixelSizeX = atMetaData{1}.PixelSpacing(1);
    if dPixelSizeX == 0 
        dPixelSizeX = 1;
    end
    
    dPixelSizeY = atMetaData{1}.PixelSpacing(2);
    if dPixelSizeY == 0 
        dPixelSizeY = 1;
    end                    
    
    dPixelSizeZ = computeSliceSpacing(atMetaData);
    if dPixelSizeZ == 0  
        dPixelSizeZ = 1;
    end            

    dVoxelSize = dPixelSizeX * dPixelSizeY * dPixelSizeZ;
    
    dSmalestValueNbVoxels = round(dSmalestVoiValue/(dVoxelSize/1000)); % In ml

    CC = bwconncomp(gather(aMask), 26);
    dNbElements = numel(CC.PixelIdxList);
         
    aMskSize = size(aMask);
    if canUseGPU()
        BW = gpuArray(zeros(aMskSize)); % Init BW buffer                                       
    else
        BW = zeros(aMskSize); % Init BW buffer                                       
    end
    
    for bb=1:dNbElements  % Nb VOI

        if numel(CC.PixelIdxList{bb}) < dSmalestValueNbVoxels
            continue;
        end

        progressBar( bb/dNbElements-0.0001, sprintf('Computing contour %d/%d, please wait', bb, dNbElements) );
    
        BW(BW~=0) = 0; % Reset BW buffer

        BW(CC.PixelIdxList{bb}) = aMask(CC.PixelIdxList{bb});

        asTag = []; % Reset ROIs tag

        xmin=0.5;
        xmax=1;
        aColor=xmin+rand(1,3)*(xmax-xmin);
    
        aPixelsList = gather(find(BW));

        [~,~,adSlices]=ind2sub(size(BW), aPixelsList);
        adSlices = unique(adSlices);                
        
        dNbComputedSlices = numel(adSlices);

        if bLesionClassification == true

            adClassification = aClassificationMask(CC.PixelIdxList{bb});

            if ~isempty(adClassification)

                dNbValues = numel(adClassification);

%                    dNbSoftTissue = sum(adClassification(:) == 1);          
                dNbBone  = sum(adClassification(:) == 2);          
                dNbLiver = sum(adClassification(:) == 3);          

                if dNbLiver > (dNbValues * 0.1) % At least 10%
                    sLesionType = 'Liver';
                else
                    if dNbBone > (dNbValues * 0.1) % At least 10%
                        sLesionType = 'Bone';
                    else
                        sLesionType = 'Soft Tissue';
                    end
                end
            end

        end

        for aa=1:dNbComputedSlices % Find ROI

            dCurrentSlice = adSlices(aa);

            aAxial = gather(BW(:,:,dCurrentSlice));

            if bPixelEdge == true
                aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
            end
            
            maskAxial = bwboundaries(aAxial, 'noholes', 8);                    
             
            dSlicesNbElements = numel(maskAxial);
            
            for jj=1:dSlicesNbElements

                if bPixelEdge == true
                    maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;
                    maskAxial{jj} = reducepoly(maskAxial{jj});
                end   

                curentMask = maskAxial(jj);
    
                sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                aPosition = flip(curentMask{1}, 2);

                if bPixelEdge == false
            
                    aPosition = smoothRoi(aPosition, size(aMask));
                 end

                sliceNumber('set', 'axial', dCurrentSlice);
                
                roiPtr = images.roi.Freehand(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'Smoothing', 1, 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', roiFaceAlphaValue('get'), 'Visible', 'off');
                roiPtr.Waypoints(:) = false;                    

                addRoi(roiPtr, get(uiSeriesPtr('get'), 'Value'), sLesionType);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);

                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
                                   
%                        addContourToTemplate(dSeriesOffset, 'Axes3', dCurrentSlice, 'images.roi.freehand', aPosition, '', 'off', aColor, 1, roiFaceAlphaValue('get'), 0, 1, sTag, sLesionType);

                asTag{numel(asTag)+1} = sTag;
            end              
        end
        
        if ~isempty(asTag)

            sLabel = sprintf('LESION-%d', bb);

            createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
        end           
    end

    clear BW;
end