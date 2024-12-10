function interpolateBetweenROIs(tRoi1, tRoi2, dSeriesOffset, bCreateVoi) 
%function interpolateBetweenROIs(tRoi1, tRoi2, dSeriesOffset, bCreateVoi)
%Insert interpolated ROIs between two regions.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if isempty(tRoi1)||isempty(tRoi2)
        return;
    end

    if tRoi1.SliceNb == tRoi2.SliceNb
        return;
    end


    if ~strcmpi(tRoi1.Axe, tRoi2.Axe) 
        return;
    end

    if bCreateVoi == true && ...
        strcmpi(tRoi1.ObjectType, 'roi') && strcmpi(tRoi2.ObjectType, 'roi')
        bCreateVoiFromRois = true;
    else
        bCreateVoiFromRois = false;
    end

    if abs(tRoi1.SliceNb - tRoi2.SliceNb) < 2

        if bCreateVoi == true
            
            if strcmpi(tRoi1.ObjectType, 'roi') && strcmpi(tRoi2.ObjectType, 'roi')

                asTag = {tRoi1.Tag, tRoi2.Tag};
    
                if ~isempty(asTag)
    
                    createVoiFromRois(dSeriesOffset, asTag, [], tRoi2.Color, tRoi2.LesionType);
    
                    setVoiRoiSegPopup();
                end

                return;
               
            elseif strcmpi(tRoi1.ObjectType, 'voi-roi') || strcmpi(tRoi2.ObjectType, 'voi-roi')

                atRoiInput = roiTemplate('get', dSeriesOffset);
                atVoiInput = voiTemplate('get', dSeriesOffset);

                dVoiOffset1 = [];
                sRoi1Tag = tRoi1.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi1Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset1 = vo;
                        break;
                    end
                end

                dVoiOffset2 = [];
                sRoi2Tag = tRoi2.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi2Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset2 = vo;
                        break;
                    end
                end

                % Add new roi to existing voi

                if ~isempty(dVoiOffset1) || ~isempty(dVoiOffset2)

                    if isempty(dVoiOffset1) && ~isempty(dVoiOffset2)
                        
                        atVoiInput{dVoiOffset2}.RoisTag{end+1} = sRoi1Tag;

                        dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoi1Tag}), 1);

                        if ~isempty(dTagOffset)
                            % voiDefaultMenu(atRoiInput{dTagOffset}.Object, atVoiInput{dVoiOffset2}.Tag);
                            bEditRoisLabel = true;
                        end

                        voiTemplate('set', dSeriesOffset, atVoiInput);

                        dVoiOffset1 = dVoiOffset2;
                    else
                        atVoiInput{dVoiOffset1}.RoisTag{end+1} = sRoi2Tag;

                        dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoi2Tag}), 1);
                        
                        if ~isempty(dTagOffset)
                            % voiDefaultMenu(atRoiInput{dTagOffset}.Object, atVoiInput{dVoiOffset1}.Tag);
                            bEditRoisLabel = true;
                        end

                        voiTemplate('set', dSeriesOffset, atVoiInput);

                    end
                end
            else
                return;
                
            end

        else
            return;
        end
    end

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);

    imRoi = dicomBuffer('get', [], dSeriesOffset);

    switch lower(tRoi1.Axe)

        case 'axes1'
            imCData = permute(imRoi(tRoi1.SliceNb,:,:), [3 2 1]);
            sPlane = 'coronal';
            pAxe = axes1Ptr('get', [], dSeriesOffset);

        case 'axes2'
            imCData = permute(imRoi(:,tRoi1.SliceNb,:), [3 1 2]) ;
            sPlane = 'sagittal';
            pAxe = axes2Ptr('get', [], dSeriesOffset);

        case 'axes3'
            imCData  = imRoi(:,:,tRoi1.SliceNb);
            sPlane = 'axial';
            pAxe = axes3Ptr('get', [], dSeriesOffset);

        otherwise
            return;
    end

    aMask1 = roiTemplateToMask(tRoi1, imCData);

    switch lower(tRoi2.Axe)

        case 'axes1'
            imCData = permute(imRoi(tRoi2.SliceNb,:,:), [3 2 1]);

        case 'axes2'
            imCData = permute(imRoi(:,tRoi2.SliceNb,:), [3 1 2]) ;

        case 'axes3'
            imCData  = imRoi(:,:,tRoi2.SliceNb);

        otherwise
            return;
    end

    aMask2 = roiTemplateToMask(tRoi2, imCData);

    clear imRoi;

    if tRoi1.SliceNb > tRoi2.SliceNb
        dNbSlices = tRoi1.SliceNb - tRoi2.SliceNb -1;
%                 if strcmpi(sPlane, 'Axial')
            dStartSliceOffset = tRoi1.SliceNb;
%                 else
%                     dStartSliceOffset = tRoi2.SliceNb;
%                 end
    else
        dNbSlices = tRoi2.SliceNb - tRoi1.SliceNb -1;
%                 if strcmpi(sPlane, 'Axial')
            dStartSliceOffset = tRoi1.SliceNb;
%                 else
%                     dStartSliceOffset = tRoi2.SliceNb;
%                 end
    end

    dCurrentSliceNumber = sliceNumber('get', sPlane);

    asTag = cell(1, 10000);
    asTag{1} = tRoi1.Tag;   
    asTag{2} = tRoi2.Tag;   
    dTagOffset = 3;
    bAddLastDrawnROI = true;

    % Linear interpolation between the two masks
    for i = 1:dNbSlices
%                 if strcmpi(sPlane, 'Axial')
        if tRoi1.SliceNb > tRoi2.SliceNb

            sliceNumber('set', sPlane, dStartSliceOffset-i);
        else
            sliceNumber('set', sPlane, dStartSliceOffset+i);
        end
%                 else
%                     sliceNumber('set', sPlane, dStartSliceOffset+i);
%                 end

%                 alpha = i / (dNbSlices + 1); % Interpolation factor
%                 aInterpolatedMask = (1 - alpha) * aMask1 + alpha * aMask2;
%
%                 aInterpolatedMask = imbinarize(aInterpolatedMask);

        adQueryPoints = linspace(1, 2, dNbSlices); % Assuming you're interpolating between masks 1 and 2
        aInterpolatedMask = interpmask([1, 2], cat(3, aMask1, aMask2), adQueryPoints(i));

        [B,~,n,~] = bwboundaries(aInterpolatedMask, 8, 'noholes');
%                 dBoundaryOffset = getLargestboundary(B);
        clear aInterpolatedMask;

        bEditRoisLabel = false;

        for dBoundaryOffset = 1: n

            aPosition = [B{dBoundaryOffset}(:, 2), B{dBoundaryOffset}(:, 1)];

            sRoiTag = num2str(randi([-(2^52/2),(2^52/2)],1));

            asTag{dTagOffset} = sRoiTag;
            dTagOffset = dTagOffset+1;

            aColor = tRoi1.Color;
            sLesionType = tRoi1.LesionType;

            pRoi = images.roi.Freehand(pAxe, ...
                                       'Color'         , aColor, ...
                                       'Position'      , aPosition, ...
                                       'lineWidth'     , 1, ...
                                       'Label'         , roiLabelName(), ...
                                       'LabelVisible'  , 'off', ...
                                       'Tag'           , sRoiTag, ...
                                       'FaceSelectable', 0, ...
                                       'FaceAlpha'     , roiFaceAlphaValue('get') ...
                                       );

            if ~isempty(pRoi.Waypoints(:))
                
                pRoi.Waypoints(:) = false;
            end
%                     pRoi.InteractionsAllowed = 'none';

            % Add ROI right click menu

            addRoi(pRoi, dSeriesOffset, sLesionType);

            addRoiMenu(pRoi);

            % addlistener(pRoi, 'WaypointAdded'  , @waypointEvents);
            % addlistener(pRoi, 'WaypointRemoved', @waypointEvents); 

            % voiDefaultMenu(pRoi);
            % 
            % roiDefaultMenu(pRoi);
            % 
            % uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
            % uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);
            % 
            % constraintMenu(pRoi);
            % 
            % cropMenu(pRoi);

            % uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics' , 'UserData', pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            if strcmpi(tRoi1.ObjectType, 'voi-roi') && ...
               strcmpi(tRoi2.ObjectType, 'voi-roi')

                dVoiOffset1 = [];
                sRoi1Tag = tRoi1.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi1Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset1 = vo;
                        break;
                    end
                end

                dVoiOffset2 = [];
                sRoi2Tag = tRoi2.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi2Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset2 = vo;
                        break;
                    end
                end

                % Add new roi to existing voi

                if ~isempty(dVoiOffset1) && ~isempty(dVoiOffset2)

                    if dVoiOffset1 == dVoiOffset2

                        atRoiInput = roiTemplate('get', dSeriesOffset);
                        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoiTag} );

                        if ~isempty(aTagOffset)

                            dNewRoiOffset = find(aTagOffset,1);

                            if ~isempty(dNewRoiOffset)

                                atVoiInput{dVoiOffset1}.RoisTag{end+1} = sRoiTag;

                                % voiDefaultMenu(atRoiInput{dNewRoiOffset}.Object, atVoiInput{dVoiOffset1}.Tag);
                                bEditRoisLabel = true;
                            end
                        end
                    end
                end
            elseif strcmpi(tRoi1.ObjectType, 'voi-roi') || ...
                   strcmpi(tRoi2.ObjectType, 'voi-roi')

                dVoiOffset1 = [];
                sRoi1Tag = tRoi1.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi1Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset1 = vo;
                        break;
                    end
                end

                dVoiOffset2 = [];
                sRoi2Tag = tRoi2.Tag;
                for vo=1:numel(atVoiInput)

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoi2Tag), 1);

                    if ~isempty(dTagOffset) % tag exist
                        dVoiOffset2 = vo;
                        break;
                    end
                end

                % Add new roi to existing voi

                if ~isempty(dVoiOffset1) || ~isempty(dVoiOffset2)

                    if ~isempty(dVoiOffset1)

                        if bAddLastDrawnROI == true

                            atVoiInput{dVoiOffset1}.RoisTag{end+1} = sRoi2Tag;
                            bAddLastDrawnROI = false;
                        end

                    else
                        if bAddLastDrawnROI == true

                            atVoiInput{dVoiOffset2}.RoisTag{end+1} = sRoi1Tag;
                            bAddLastDrawnROI = false;
                        end

                        dVoiOffset1 = dVoiOffset2;
                    end

                    atRoiInput = roiTemplate('get', dSeriesOffset);
                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoiTag} );

                    if ~isempty(aTagOffset)

                        dNewRoiOffset = find(aTagOffset,1);

                        if ~isempty(dNewRoiOffset)

                            atVoiInput{dVoiOffset1}.RoisTag{end+1} = sRoiTag;

                            % voiDefaultMenu(atRoiInput{dNewRoiOffset}.Object, atVoiInput{dVoiOffset1}.Tag);
                            bEditRoisLabel = true;
                        end
                    end
                end                
                    
            end
        end
    end

    clear aMask1;
    clear aMask2;

    % Rename voi-roi label

    if bEditRoisLabel == true

        dNbTags = numel(atVoiInput{dVoiOffset1}.RoisTag);

        for dRoiNb=1:dNbTags

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{dVoiOffset1}.RoisTag{dRoiNb} );

            if ~isempty(aTagOffset)

                dTagOffset = find(aTagOffset, 1);

                if~isempty(dTagOffset)

                    sLabel = sprintf('%s (roi %d/%d)', atVoiInput{dVoiOffset1}.Label, dRoiNb, dNbTags);

                    atRoiInput{dTagOffset}.Label = sLabel;
                    atRoiInput{dTagOffset}.Object.Label = sLabel;
                    atRoiInput{dTagOffset}.ObjectType  = 'voi-roi';
                    atRoiInput{dTagOffset}.Object.UserData = 'voi-roi';
               end
            end
        end

        roiTemplate('set', dSeriesOffset, atRoiInput);
        voiTemplate('set', dSeriesOffset, atVoiInput);
    else
        if bCreateVoiFromRois == true

            asTag = asTag(~cellfun(@isempty, asTag));

            if ~isempty(asTag)

                createVoiFromRois(dSeriesOffset, asTag, [], tRoi2.Color, tRoi2.LesionType);

                setVoiRoiSegPopup();

                uiDeleteVoiRoiPanel = uiDeleteVoiRoiPanelObject('get');
                uiLesionTypeVoiRoiPanel = uiLesionTypeVoiRoiPanelObject('get');

                if ~isempty(uiDeleteVoiRoiPanel) && ...
                   ~isempty(uiLesionTypeVoiRoiPanel)

                    atVoiInput = voiTemplate('get', dSeriesOffset);
                    dVoiOffset = numel(atVoiInput);

                    set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

                    sLesionType = atVoiInput{dVoiOffset}.LesionType;
                    [bLesionOffset, ~, ~] = getLesionType(sLesionType);
                    set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
                end

            end

        end
    end

    sliceNumber('set', sPlane, dCurrentSliceNumber);

    refreshImages();

    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
    end
end