function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestValue, dLiverMean, dLiverSTD, sVOIName, dBoneThreshold)
%function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestValue, dLiverMean, dLiverSTD, sVOIName, dBoneThreshold)
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
        
        % Disable ROI UI controls during processing
        if viewRoiPanel('get')
            set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable','off');
            set(uiDeleteVoiRoiPanelObject   ('get'), 'Enable','off');
            set(uiAddVoiRoiPanelObject      ('get'), 'Enable','off');
            set(uiPrevVoiRoiPanelObject     ('get'), 'Enable','off');
            set(uiDelVoiRoiPanelObject      ('get'), 'Enable','off');
            set(uiNextVoiRoiPanelObject     ('get'), 'Enable','off');
            set(uiUndoVoiRoiPanelObject     ('get'), 'Enable','off');
            uiCreateVoiRoiPanel = uiCreateVoiRoiPanelObject('get');
            set(uiCreateVoiRoiPanel, 'String','Cancel', ...
                'Background',[0.3255, 0.1137, 0.1137], ...
                'Foreground',[0.94 0.94 0.94]);
            cancelCreateVoiRoiPanel('set', false);
        end

        % MATLAB release check
        bMATLABReleaseOlderThan2023b = isMATLABReleaseOlderThan('R2023b');

        % Busy pointer
        set(fiMainWindowPtr('get'), 'Pointer','watch');
        drawnow limitrate;

        % Load DICOM metadata & compute voxel volume
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        atMetaData    = dicomMetaData('get', [], dSeriesOffset);
        dPixelSizeX   = atMetaData{1}.PixelSpacing(1);
        dPixelSizeY   = atMetaData{1}.PixelSpacing(2);
        if dPixelSizeX==0, dPixelSizeX=1; end
        if dPixelSizeY==0, dPixelSizeY=1; end
        dPixelSizeZ   = computeSliceSpacing(atMetaData);
        if dPixelSizeZ==0, dPixelSizeZ=1; end
        dVoxelSize    = dPixelSizeX * dPixelSizeY * dPixelSizeZ;         % mm^3
        dSmalestValueNbVoxels = round(dSmalestValue/(dVoxelSize/1000));  % convert mL to voxels

        % Prepare mask components
        PIXEL_EDGE_RATIO = 3;
        dMinValue        = single(min(imMask, [], 'all'));

        CC = bwconncomp(gather(BW), 26);
        dNbElements = numel(CC.PixelIdxList);

        if canUseGPU()
            BW2   = gpuArray(single(zeros(size(imMask))));
            BWCT2 = gpuArray(BWCT);
        else
            BW2   = single(zeros(size(imMask)));
            BWCT2 = BWCT;
        end

        % Process each connected component (VOI candidate)
        for bb = 1:dNbElements
            if mod(bb,10)==1 || bb==1 || bb==dNbElements
                progressBar(bb/dNbElements-0.0001, ...
                    sprintf('Processing contour %d/%d, please wait.', bb, dNbElements));
            end
            if cancelCreateVoiRoiPanel('get'), break; end

            % Reset and fill BW2 for this VOI
            BW2(:) = 0;
            BW2(CC.PixelIdxList{bb}) = imMask(CC.PixelIdxList{bb});

            % Thresholding / formula logic to binarize BW2
            if bPercentOfPeak
                %--- Percent-of-peak thresholding ---
                if isempty(sMinSUVformula)
                    sLesionType = 'Unspecified';
                else
                    % Determine lesion type from formula name or CT overlap
                    switch lower(sMinSUVformula)
                        case 'liver'
                            sLesionType = 'Liver';
                        case 'soft tissue'
                            sLesionType = 'Soft Tissue';
                        case 'lymph nodes'
                            sLesionType = 'Lymph Nodes';
                        case 'bone'
                            sLesionType = 'Bone';
                        otherwise
                            if contains(sMinSUVformula,'ct bone map','IgnoreCase',true) || ...
                               contains(sMinSUVformula,'ct iso map','IgnoreCase',true)
                                BWANDBWCT = BW2 & BWCT2;
                                dBWand = nnz(BWANDBWCT);
                                dBW     = nnz(BW2);
                                if (dBWand/dBW)*100 > 10
                                    sLesionType = 'Bone';
                                else
                                    if contains(sMinSUVformula,'lymph','IgnoreCase',true)
                                        sLesionType = 'Lymph Nodes';
                                    else
                                        sLesionType = 'Soft Tissue';
                                    end
                                end
                            else
                                sLesionType = 'Unspecified';
                            end
                    end
                end

                % Compute threshold value
                if bMultiplePeaks
                    dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') ...
                                    * dPercentMaxOrMaxSUVValue/100 ...
                                    * dMultiplePeaksPercentValue/100;
                else
                    dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') ...
                                    * dPercentMaxOrMaxSUVValue/100;
                end
                BW2(BW2 <= dMaxMaskValue) = dMinValue;
                BW2(BW2 ~= dMinValue)    = 1;
                BW2(BW2 == dMinValue)    = 0;
            else
                %--- Absolute/formula-based SUV thresholding ---
                tQuant = quantificationTemplate('get');
                if isfield(tQuant,'tSUV')
                    dSUVScale = tQuant.tSUV.dScale;
                else
                    dSUVScale = 1;
                end

                if ~bUseFormula
                    % Simple absolute threshold
                    if isempty(sMinSUVformula)
                        sLesionType = 'Unspecified';
                    else
                        % Determine lesion type as above
                        switch lower(sMinSUVformula)
                            case 'liver'
                                sLesionType = 'Liver';
                            case 'soft tissue'
                                sLesionType = 'Soft Tissue';
                            case 'lymph nodes'
                                sLesionType = 'Lymph Nodes';
                            case 'bone'
                                sLesionType = 'Bone';
                            otherwise
                                if contains(sMinSUVformula,'ct bone map','IgnoreCase',true) || ...
                                   contains(sMinSUVformula,'ct iso map','IgnoreCase',true)
                                    BWANDBWCT = BW2 & BWCT2;
                                    if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                        sLesionType = 'Bone';
                                    else
                                        if contains(sMinSUVformula,'lymph','IgnoreCase',true)
                                            sLesionType = 'Lymph Nodes';
                                        else
                                            sLesionType = 'Soft Tissue';
                                        end
                                    end
                                else
                                    sLesionType = 'Unspecified';
                                end
                        end
                    end
                    BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                    BW2(BW2 ~= dMinValue)    = 1;
                    BW2(BW2 == dMinValue)    = 0;
                else
                    %--- Formula-based thresholds ---
                    formula = lower(strtrim(sMinSUVformula));
                    switch formula
                        case '(4.30/suvmean)x(suvmean + sd)'
                            sLesionType = 'Unspecified';
                            vals        = gather(BW2(BW2~=dMinValue))*dSUVScale;
                            dMean       = mean(vals,'all');
                            dSTD        = std(vals,[], 'all');
                            thr         = (4.30/dMean)*(dMean + dSTD);
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(4.30/suvmean)x(suvmean + sd), soft tissue & bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                vals = gather(BW2(BW2~=dMinValue))*dSUVScale;
                                thr  = (4.30/mean(vals,'all'))*(mean(vals,'all') + std(vals,[], 'all'));
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(4.30/normal liver suvmean)x(normal liver suvmean + normal liver sd), soft tissue & bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = (4.30/dLiverMean)*(dLiverMean + dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(4.44/normal liver suvmean)x(normal liver suvmean + normal liver sd), soft tissue & bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = (4.44/dLiverMean)*(dLiverMean + dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(4.44/normal liver suvmean)x(normal liver suvmean + normal liver sd), lymph nodes & bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Lymph Nodes';
                                thr = (4.44/dLiverMean)*(dLiverMean + dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(4.30/suvmean)x(suvmean + sd), soft tissue & bone suv 3, ct iso map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                vals = gather(BW2(BW2~=dMinValue))*dSUVScale;
                                thr  = (4.30/mean(vals,'all'))*(mean(vals,'all') + std(vals,[], 'all'));
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case 'liver suv 10, soft tissue suv 4, bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = 4;
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case 'liver suv 10, soft tissue suv 4, bone suv 3, ct iso map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = 4;
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(1.5 x normal liver suvmean)+(2 x normal liver sd), soft tissue & bone suv 3, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 3;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = (1.5*dLiverMean)+(2*dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(1.5 x normal liver suvmean)+(2 x normal liver sd), lymph nodes & bone suv 2.5, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 2.5;
                            else
                                sLesionType = 'Lymph Nodes';
                                thr = (1.5*dLiverMean)+(2*dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(1.2 x normal liver suvmean)+(2 x normal liver sd), soft tissue & bone suv 2, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 2;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = (1.2*dLiverMean)+(2*dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case '(1.5 x normal liver suvmean)+(2 x normal liver sd), soft tissue & bone suv 2.5, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                thr = 2.5;
                            else
                                sLesionType = 'Soft Tissue';
                                thr = (1.5*dLiverMean)+(2*dLiverSTD);
                            end
                            BW2(BW2*dSUVScale < thr) = dMinValue;
                        case 'lymph nodes & bone suv, ct bone map'
                            BWANDBWCT = BW2 & BWCT2;
                            if (nnz(BWANDBWCT)/nnz(BW2))*100 > 10
                                sLesionType = 'Bone';
                                BW2(BW2*dSUVScale < dBoneThreshold) = dMinValue;
                            else
                                sLesionType = 'Lymph Nodes';
                                BW2(BW2*dSUVScale < dPercentMaxOrMaxSUVValue) = dMinValue;
                            end
                        otherwise
                            return;
                    end
                    BW2(BW2 ~= dMinValue) = 1;
                    BW2(BW2 == dMinValue) = 0;
                end
            end

            % Collect slice-by-slice contours
            asTag      = cell(5000,1);
            dTagOffset = 1;
            aColor     = generateUniqueColor(false);

            aPixelsList = gather(find(BW2));
            if numel(aPixelsList) < dSmalestValueNbVoxels
                continue;
            end
            [~,~,adSlices]    = ind2sub(size(BW2), aPixelsList);
            adSlices          = unique(adSlices);
            dNbComputedSlices = numel(adSlices);

            for aa = 1:dNbComputedSlices
                if cancelCreateVoiRoiPanel('get'), break; end
                dCurrentSlice = adSlices(aa);
                aAxial        = gather(BW2(:,:,dCurrentSlice));

                % optimized pixel‐edge block 
                if bPixelEdge
                    if bMATLABReleaseOlderThan2023b
                        %aProcAxial = imresize(aSlice,PIXEL_EDGE_RATIO, 'nearest');
                        aProcAxial = repelem(aAxial, PIXEL_EDGE_RATIO, PIXEL_EDGE_RATIO);
                        extraArgs  = {};
                    else
                        aProcAxial = aAxial;
                        extraArgs  = {'TraceStyle','pixeledge'};
                    end
                else
                    aProcAxial = aAxial;
                    extraArgs  = {};
                end

                [maskAxial, ~, dNbSlicesElements] = bwboundaries( ...
                    aProcAxial, 8, 'noholes', extraArgs{:} );

                if bPixelEdge && bMATLABReleaseOlderThan2023b
                    for k = 1:numel(maskAxial)
                        maskAxial{k} = (maskAxial{k} + 1) / PIXEL_EDGE_RATIO;
                        maskAxial{k} = reducepoly(maskAxial{k});
                    end
                end
                % end optimized block 

                for jj = 1:dNbSlicesElements
                    if cancelCreateVoiRoiPanel('get'), break; end
                    curMask   = maskAxial(jj);
                    sTag      = num2str(generateUniqueNumber(false));
                    aPosition = flip(curMask{1}, 2);
                    if ~bPixelEdge
                        aPosition = smoothRoi(aPosition, size(imMask));
                    end

                    sliceNumber('set','axial',dCurrentSlice);
                    roiPtr = images.roi.Freehand(axes3Ptr('get',[],dSeriesOffset), ...
                        'Smoothing',1, 'Position',aPosition, 'Color',aColor, ...
                        'LineWidth',1, 'Label','', 'LabelVisible','off', ...
                        'Tag',sTag, 'Visible','on', 'FaceSelectable',0, ...
                        'FaceAlpha',roiFaceAlphaValue('get'),'Visible','off');
                    if ~isempty(roiPtr.Waypoints(:))
                        roiPtr.Waypoints(:) = false;
                    end
                    addRoi(roiPtr, dSeriesOffset, sLesionType);
                    addRoiMenu(roiPtr);

                    asTag{dTagOffset} = sTag;
                    dTagOffset = dTagOffset + 1;
                end
            end

            % Remove empty tags
            asTag = asTag(~cellfun(@isempty, asTag));

            % Create VOI grouping all ROIs
            if ~isempty(asTag)
                if exist('sVOIName','var') && ~isempty(sVOIName)
                    sLabel = sprintf('%s %d', sVOIName, bb);
                else
                    bUseBoneThreshold = strcmpi(sLesionType,'Bone') && ...
                                       exist('dBoneThreshold','var') && ~isempty(dBoneThreshold);
                    if bUseBoneThreshold
                        sLabel = sprintf('RMAX-%.2f-VOI%d', dBoneThreshold, bb);
                    else
                        sLabel = sprintf('RMAX-%.2f-VOI%d', dPercentMaxOrMaxSUVValue, bb);
                    end
                end
                createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
            end

        end  % end for bb

        % Finalize display & cleanup
        setVoiRoiSegPopup();
        if size(dicomBuffer('get',[],dSeriesOffset),3) ~= 1
            plotRotatedRoiOnMip(axesMipPtr('get',[],dSeriesOffset), ...
                dicomBuffer('get',[],dSeriesOffset), mipAngle('get'));
        end
        progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:maskAddVoiToSeries()');
    end

    % Re-enable ROI UI controls
    if viewRoiPanel('get')
        if ~isempty(voiTemplate('get', dSeriesOffset))
            set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable','on');
            set(uiDeleteVoiRoiPanelObject   ('get'), 'Enable','on');
            set(uiAddVoiRoiPanelObject      ('get'), 'Enable','on');
            set(uiPrevVoiRoiPanelObject     ('get'), 'Enable','on');
            set(uiDelVoiRoiPanelObject      ('get'), 'Enable','on');
            set(uiNextVoiRoiPanelObject     ('get'), 'Enable','on');
            set(uiUndoVoiRoiPanelObject     ('get'), 'Enable','on');
        end
        cancelCreateVoiRoiPanel('set', false);
        set(uiCreateVoiRoiPanel, 'String','Segment', ...
            'Background',[0.6300 0.6300 0.4000], ...
            'Foreground',[0.1 0.1 0.1]);
    end

    clear BW2 BWCT2 BWANDBWCT;
    set(fiMainWindowPtr('get'), 'Pointer','default');
    drawnow limitrate;
    
end