function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestValue, dLiverMean, dLiverSTD)
%function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestValue, dLiverMean, dLiverSTD)
%create contour from a mask and formula.
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

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    uiSeries = uiSeriesPtr('get');
    dSeriesOffset = get(uiSeries, 'Value');
    
    atMetaData = dicomMetaData('get');
          
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
    
    dSmalestValueNbVoxels = round(dSmalestValue/(dVoxelSize/1000)); % In ml
    
%            SMALEST_ROI_SIZE = 0;
    PIXEL_EDGE_RATIO = 3;

    dMinValue = min(imMask, [], 'all');
%            dMaxValue = max(imMask, [], 'all');

%    CC = bwconncomp(gather(BW), 18);
    CC = bwconncomp(gather(BW), 26);
    dNbElements = numel(CC.PixelIdxList);

%            asAllTag = [];
     
    if canUseGPU()
        BW2       = gpuArray(zeros(size(imMask))); % Init BW2 buffer                                       
        BWCT2     = gpuArray(BWCT);
        BWANDBWCT = gpuArray(zeros(size(BWCT)));
    else
        BW2       = zeros(size(imMask)); % Init BW2 buffer                                       
        BWCT2     = BWCT;
        BWANDBWCT = zeros(size(BWCT));                
    end
    
    for bb=1:dNbElements  % Nb VOI

        progressBar( bb/dNbElements-0.0001, sprintf('Computing contour %d/%d, please wait', bb, dNbElements) );

%                if numel(CC.PixelIdxList{bb}) 

        BW2(BW2~=0) = 0; % Reset BW2 buffer

        BW2(CC.PixelIdxList{bb}) = imMask(CC.PixelIdxList{bb});

        if bPercentOfPeak == true % Percent of peak or SUV Value
            
            if isempty(sMinSUVformula)
                sLesionType = 'Unspecified';
            else
                if  contains(sMinSUVformula, 'CT Bone Map') || ...
                    contains(sMinSUVformula, 'CT ISO Map')  
                    
                    BWANDBWCT = BW2&BWCT2;
    
                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));
    
                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';
                    else
                        sLesionType = 'Soft Tissue';
                    end
    
                elseif  strcmpi(sMinSUVformula, 'Liver') 
                    sLesionType = 'Liver';
              
                else
                    sLesionType = 'Unspecified';
                end
            end

            if bMultiplePeaks == true % Multiple peaks

                dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * (dPercentMaxOrMaxSUVValue) /100;
                dMaxMaskValue = dMaxMaskValue * (dMultiplePeaksPercentValue) /100;

                BW2(BW2 <= dMaxMaskValue) = dMinValue;

                BW2(BW2 ~= dMinValue) = 1;
                BW2(BW2 == dMinValue) = 0;

            else % Single peak

                dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * dPercentMaxOrMaxSUVValue /100;

                BW2(BW2 <= dMaxMaskValue) = dMinValue;

                BW2(BW2 ~= dMinValue) = 1;
                BW2(BW2 == dMinValue) = 0;
            end
        else
            tQuant = quantificationTemplate('get');
            
            if isfield(tQuant, 'tSUV')
                dSUVScale = tQuant.tSUV.dScale;
            else
                dSUVScale = 0;
            end

            if bUseFormula == false

                if isempty(sMinSUVformula)
                    sLesionType = 'Unknow';
                else
                    if  contains(sMinSUVformula, 'CT Bone Map') || ...
                        contains(sMinSUVformula, 'CT ISO Map')   
    
                        BWANDBWCT = BW2&BWCT2;
    
                        dBWnbPixel        = numel(BW2(BW2~=0));
                        dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));
    
                        if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                            sLesionType = 'Bone';
                        else
                            sLesionType = 'Soft Tissue';
                        end
                        
                    elseif  strcmpi(sMinSUVformula, 'Liver') 
                        sLesionType = 'Liver';
                    end
                end

                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                BW2(BW2 ~= dMinValue) = 1;
                BW2(BW2 == dMinValue) = 0;
            else
                if strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD)')      

                    sLesionType = 'Unspecified';

                    dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                    dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                    dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                    BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;                                

                elseif strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & Bone SUV 3, CT Bone Map') 

                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

                        dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                        dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                        dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;    

%                                clear(BWANDBWCT);
                elseif strcmpi(sMinSUVformula, '(4.30/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map')
                    
                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

%                                dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
%                                dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                        dPercentMaxOrMaxSUVValue = (4.30/dLiverMean)*(dLiverMean + dLiverSTD);                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;  

                elseif strcmpi(sMinSUVformula, '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map')
                    
                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

%                                dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
%                                dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                        dPercentMaxOrMaxSUVValue = (4.44/dLiverMean)*(dLiverMean + dLiverSTD);                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;                      
                elseif strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & Bone SUV 3, CT ISO Map') 

                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

                        dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                        dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;
                        
                        dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;     
                    
                elseif strcmpi(sMinSUVformula, 'Liver SUV 10, Soft Tissue SUV 4, Bone SUV 3, CT Bone Map')
                    
                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

                        dPercentMaxOrMaxSUVValue = 4;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0; 
                    
                elseif strcmpi(sMinSUVformula, 'Liver SUV 10, Soft Tissue SUV 4, Bone SUV 3, CT ISO Map')
                    
                    BWANDBWCT = BW2&BWCT2;

                    dBWnbPixel        = numel(BW2(BW2~=0));
                    dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                    if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                        sLesionType = 'Bone';

                        dPercentMaxOrMaxSUVValue = 3;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    else
                        sLesionType = 'Soft Tissue';

                        dPercentMaxOrMaxSUVValue = 4;                                
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    end

                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0; 
%                                clear(BWANDBWCT);

                else
                    return;
                end
            end
        end

        asTag = []; % Reset ROIs tag

        xmin=0.5;
        xmax=1;
        aColor=xmin+rand(1,3)*(xmax-xmin);

%                    dNbSlices = size(BW2, 3);

        aPixelsList = gather(find(BW2));
        if numel(aPixelsList) < dSmalestValueNbVoxels
            continue;
        end

        [~,~,adSlices]=ind2sub(size(BW2), aPixelsList);
        adSlices = unique(adSlices);                
        
        dNbComputedSlices = numel(adSlices);

        for aa=1:dNbComputedSlices % Find ROI

            dCurrentSlice = adSlices(aa);

            aAxial = gather(BW2(:,:,dCurrentSlice));

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

%                                    sliceNumber('set', 'axial', aa);

                sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                aPosition = flip(curentMask{1}, 2);
%                                    aPosition(:,1) = aPosition(:,1) - 0.5;
%                                    aPosition(:,2) = aPosition(:,2) + 0.5;

%                                    bAddRoi = true;

                if bPixelEdge == false
            
                    aPosition = smoothRoi(aPosition, size(imMask));
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

            sLabel = sprintf('RMAX-%d-VOI%d', dPercentMaxOrMaxSUVValue, bb);

            createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
        end           
    end

    setVoiRoiSegPopup();

    progressBar(1, 'Ready');

    catch
        progressBar(1, 'Error:maskAddVoiToSeries()');
    end
    
    clear BW2;
    clear BWCT2; 
    clear BWANDBWCT; 
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end