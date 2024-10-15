function maskAddVoiByTypeToSeries(aImage, aMask, atMetaData, dSeriesOffset, dSmallestValue, bPixelEdge, bSmoothMask, bClassifySegmentation, bType)
%function maskAddVoiByTypeToSeries(aImage, aMask, atMetaData, dSeriesOffset, dSmallestValue, bPixelEdge, bSmoothMask, bClassifySegmentation, bType)
%Add brown fat machine learning segmentation to a series.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    PIXEL_EDGE_RATIO = 3;

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
    
    if dSmallestValue > 0
        dSmallestValueNbVoxels = round(dSmallestValue/(dVoxelSize/1000)); % In ml
    end
 
    aBWImage = imbinarize(aImage);

    aBWImage(aMask==0) = 0;

    CC = bwconncomp(aBWImage, 26);
    dNbElements = numel(CC.PixelIdxList);

    for bb=1:dNbElements  % Nb VOI

        if mod(bb,5)==1 || bb == 1 || bb == dNbElements

            progressBar( bb/dNbElements-0.0001, sprintf('Computing contour %d/%d, please wait.', bb, dNbElements) );
        end   

        BW = zeros(size(aBWImage));

        BW(CC.PixelIdxList{bb}) = aBWImage(CC.PixelIdxList{bb});

        asTag = cell(5000, 1);
        dTagOffset =1;

        bBreak = false;

        xmin=0.5;
        xmax=1;
        aColor=xmin+rand(1,3)*(xmax-xmin);
    
        aPixelsList = find(BW);

        if dSmallestValue > 0

            if numel(aPixelsList) < dSmallestValueNbVoxels
                continue;
            end
        end

        [~,~,adSlices] = ind2sub(size(BW), aPixelsList);
        adSlices = unique(adSlices);                
        
        dNbComputedSlices = numel(adSlices);


        if bClassifySegmentation == true
             sLesionType = getMaskLessionType(aMask(CC.PixelIdxList{bb}), bType);
%             sLesionType = 'Unspecified';
        else
            sLesionType = 'Unspecified';
        end

        for aa=1:dNbComputedSlices % Find ROI

            if cancelCreateVoiRoiPanel('get') == true
                break;
            end

            dCurrentSlice = adSlices(aa);

            aAxial = BW(:, :, dCurrentSlice);

            if bPixelEdge == true
                aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
            end
            
            [maskAxial, ~, dNbSlicesElements] = bwboundaries(aAxial, 8, 'noholes');                    
                             
            for jj=1:dNbSlicesElements

                if cancelCreateVoiRoiPanel('get') == true
                    break;
                end

                if bPixelEdge == true
                    maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;
                    maskAxial{jj} = reducepoly(maskAxial{jj});
                end   

                curentMask = maskAxial(jj);
    
                sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                aPosition = flip(curentMask{1}, 2);

                if bSmoothMask == true
            
                    aPosition = smoothRoi(aPosition, size(aImage));
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

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
                                       
                asTag{dTagOffset} = sTag;
                dTagOffset = dTagOffset+1;
                
                if dTagOffset > numel(asTag)
                    bBreak = true;
                    break;
                end

                if viewRoiPanel('get') == true
                    drawnow limitrate;
                end
            end

            if bBreak == true
                break;
            end

        end

        asTag = asTag(~cellfun(@isempty, asTag));

        if ~isempty(asTag)

            if exist('sVOIName', 'var')
                sLabel = sprintf('%s %d', sVOIName, bb);
            else
                sLabel = sprintf('VOI%d', bb);
            end

            createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
        end  

        clear BW;
    end

    clear aBWImage;

    setVoiRoiSegPopup();
    
    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
    end

end

function  sLesionType = getMaskLessionType(aMask, bType)

    dLesionTypeOffset = max(aMask(aMask~=0), [], 'all');

    if bType == 1 % Brown fat

        switch dLesionTypeOffset
    
            case 1
                sLesionType = 'Cervical';
    
            case 2
                sLesionType = 'Supraclavicular';
    
            case 3
                sLesionType = 'Mediastinal';
    
            case 4
                sLesionType = 'Paraspinal';
    
            case 5
                sLesionType = 'Axillary';
    
            case 6
                sLesionType = 'Abdominal';
    
            otherwise
                sLesionType = 'Unknow';
            
        end

    elseif bType == 2 % PSMA

        switch dLesionTypeOffset
    
            case 1
                sLesionType = 'Lymph Nodes';
    
            case 2
                sLesionType = 'Soft Tissue';
    
            case 3
                sLesionType = 'Bone';
    
            case 4
                sLesionType = 'Liver';
    
            case 5
                sLesionType = 'Primary Disease';
    
            case 6
                sLesionType = 'Lung';

            case 7
                sLesionType = 'Parotid';

            case 8
                sLesionType = 'Blood Pool';  

            otherwise
                sLesionType = 'Unknow';
        end
        
    elseif bType == 3 % Breast Cancer

        switch dLesionTypeOffset
    
            case 1
                sLesionType = 'Lymph Nodes';
    
            case 2
                sLesionType = 'Bone';
    
            case 3
                sLesionType = 'Liver';
    
            case 4
                sLesionType = 'Lung';

            case 5
                sLesionType = 'Primary Disease'; 

            case 6
                sLesionType = 'Soft Tissue'; 

            otherwise
                sLesionType = 'Unknow';

        end
    else
    end
end