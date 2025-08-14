function [tReport, adVoiAllContoursMask, gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid)
%function [tReport, adVoiAllContoursMask, gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid)
%The function return an array of statistics by anatomical sites.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    gdFarthestDistance = [];
    gadFarthestXYZ1 = [];
    gadFarthestXYZ2 = [];

    adVoiAllContoursMask = [];
    tReport = [];

    atInput = inputTemplate('get');
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

    sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));
    tQuantification = quantificationTemplate('get');

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if isempty(atVoiInput)
        return;
    end

    if bModifiedMatrix == false && ...
       bMovementApplied == false        % Can't use input buffer if movement have been applied

        atDicomMeta = dicomMetaData('get', [], dSeriesOffset);
        atMetaData  = atInput(dSeriesOffset).atDicomInfo;
        aImage      = inputBuffer('get');

        aImage = aImage{dSeriesOffset};

        if     strcmpi(imageOrientation('get'), 'axial')
%                 aImage = aImage;
        elseif strcmpi(imageOrientation('get'), 'coronal')
            aImage = reorientBuffer(aImage, 'coronal');
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            aImage = reorientBuffer(aImage, 'sagittal');
        end

        if size(aImage, 3) ==1

            if atInput(dSeriesOffset).bFlipLeftRight == true
                aImage = aImage(:,end:-1:1);
            end

            if atInput(dSeriesOffset).bFlipAntPost == true
                aImage = aImage(end:-1:1,:);
            end
        else
            if atInput(dSeriesOffset).bFlipLeftRight == true
                aImage = aImage(:,end:-1:1,:);
            end

            if atInput(dSeriesOffset).bFlipAntPost == true
                aImage = aImage(end:-1:1,:,:);
            end

            if atInput(dSeriesOffset).bFlipHeadFeet == true
                aImage = aImage(:,:,end:-1:1);
            end
        end

    else
        atMetaData = dicomMetaData('get', [], dSeriesOffset);
        aImage     = dicomBuffer('get', [], dSeriesOffset);
    end

    % Set Voxel Size

    xPixel = atMetaData{1}.PixelSpacing(1)/10;
    yPixel = atMetaData{1}.PixelSpacing(2)/10;

    if size(aImage, 3) == 1
        zPixel = 1;
    else
        zPixel = computeSliceSpacing(atMetaData)/10;

        if zPixel == 0 % We can't determine the z size of a pixel, we will presume the pixel is square.
            zPixel = xPixel;
        end
    end

    dVoxVolume = xPixel * yPixel * zPixel;

    aDicomImage = dicomBuffer('get', [], dSeriesOffset);

    if bModifiedMatrix == false && ...
       bMovementApplied == false        % Can't use input buffer if movement have been applied

        if ~isequal(size(aImage), size(aDicomImage))
            [atRoiInput, atVoiInput] = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, atRoiInput, false, atVoiInput, dSeriesOffset);
        end
    end

    % Count Lesion Type number of contour

    dUnspecifiedCount     = 0;
    dBoneCount            = 0;
    dSoftTissueCount      = 0;
    dUnknowCount          = 0;
    dLungCount            = 0;
    dLiverCount           = 0;
    dParotidCount         = 0;
    dBloodPoolCount       = 0;
    dLymphNodesCount      = 0;
    dPrimaryDiseaseCount  = 0;
    dCervicalCount        = 0;
    dSupraclavicularCount = 0;
    dMediastinalCount     = 0;
    dParaspinalCount      = 0;
    dAxillaryCount        = 0;
    dAbdominalCount       = 0;
    dNecroticCount        = 0;

    dNbUnspecifiedRois     = 0;
    dNbBoneRois            = 0;
    dNbSoftTissueRois      = 0;
    dNbUnknowRois          = 0;
    dNbLungRois            = 0;
    dNbLiverRois           = 0;
    dNbParotidRois         = 0;
    dNbBloodPoolRois       = 0;
    dNbLymphNodesRois      = 0;
    dNbPrimaryDiseaseRois  = 0;
    dNbCervicalRois        = 0;
    dNbSupraclavicularRois = 0;
    dNbMediastinalRois     = 0;
    dNbParaspinalRois      = 0;
    dNbAxillaryRois        = 0;
    dNbAbdominalRois       = 0;
    dNbNecroticRois        = 0;

    for vv=1:numel(atVoiInput)

        dNbRois = numel(atVoiInput{vv}.RoisTag);

        switch lower(atVoiInput{vv}.LesionType)

            case 'unspecified'
                dUnspecifiedCount = dUnspecifiedCount+1;
                dNbUnspecifiedRois = dNbUnspecifiedRois+dNbRois;

            case 'bone'
                dBoneCount  = dBoneCount+1;
                dNbBoneRois = dNbBoneRois+dNbRois;

            case 'soft tissue'
                dSoftTissueCount  = dSoftTissueCount+1;
                dNbSoftTissueRois = dNbSoftTissueRois+dNbRois;

            case 'lung'
                dLungCount  = dLungCount+1;
                dNbLungRois = dNbLungRois+dNbRois;

            case 'liver'
                dLiverCount  = dLiverCount+1;
                dNbLiverRois = dNbLiverRois+dNbRois;

            case 'parotid'
                dParotidCount  = dParotidCount+1;
                dNbParotidRois = dNbParotidRois+dNbRois;

            case 'blood pool'
                dBloodPoolCount  = dBloodPoolCount+1;
                dNbBloodPoolRois = dNbBloodPoolRois+dNbRois;

             case 'lymph nodes'
                dLymphNodesCount  = dLymphNodesCount+1;
                dNbLymphNodesRois = dNbLymphNodesRois+dNbRois;

            case 'primary disease'
                dPrimaryDiseaseCount  = dPrimaryDiseaseCount+1;
                dNbPrimaryDiseaseRois = dNbPrimaryDiseaseRois+dNbRois;

            case 'cervical'
                dCervicalCount  = dCervicalCount+1;
                dNbCervicalRois = dNbCervicalRois+dNbRois;

            case 'supraclavicular'
                dSupraclavicularCount  = dSupraclavicularCount+1;
                dNbSupraclavicularRois = dNbSupraclavicularRois+dNbRois;

            case 'mediastinal'
                dMediastinalCount  = dMediastinalCount+1;
                dNbMediastinalRois = dNbMediastinalRois+dNbRois;

            case 'paraspinal'
                dParaspinalCount  = dParaspinalCount+1;
                dNbParaspinalRois = dNbParaspinalRois+dNbRois;

            case 'axillary'
                dAxillaryCount  = dAxillaryCount+1;
                dNbAxillaryRois = dNbAxillaryRois+dNbRois;

            case 'abdominal'
                dAbdominalCount  = dAbdominalCount+1;
                dNbAbdominalRois = dNbAbdominalRois+dNbRois;

            case 'necrotic'
                dNecroticCount  = dNecroticCount+1;
                dNbNecroticRois = dNbNecroticRois+dNbRois;                

            otherwise
                dUnknowCount  = dUnknowCount+1;
                dNbUnknowRois = dNbUnknowRois+dNbRois;
        end
    end

    % Set report type count

    if dUnspecifiedCount == 0
        tReport.Unspecified.Count = [];
    else
        tReport.Unspecified.Count = dUnspecifiedCount;
    end

    if dBoneCount == 0
        tReport.Bone.Count = [];
    else
        tReport.Bone.Count = dBoneCount;
    end

    if dSoftTissueCount == 0
        tReport.SoftTissue.Count = [];
    else
        tReport.SoftTissue.Count = dSoftTissueCount;
    end

    if dLungCount == 0
        tReport.Lung.Count = [];
    else
        tReport.Lung.Count = dLungCount;
    end

    if dLiverCount == 0
        tReport.Liver.Count = [];
    else
        tReport.Liver.Count = dLiverCount;
    end

    if dParotidCount == 0
        tReport.Parotid.Count = [];
    else
        tReport.Parotid.Count = dParotidCount;
    end

    if dBloodPoolCount == 0
        tReport.BloodPool.Count = [];
    else
        tReport.BloodPool.Count = dBloodPoolCount;
    end

    if dLymphNodesCount == 0
        tReport.LymphNodes.Count = [];
    else
        tReport.LymphNodes.Count = dLymphNodesCount;
    end

    if dPrimaryDiseaseCount == 0
        tReport.PrimaryDisease.Count = [];
    else
        tReport.PrimaryDisease.Count = dPrimaryDiseaseCount;
    end

    if dCervicalCount == 0
        tReport.Cervical.Count = [];
    else
        tReport.Cervical.Count = dCervicalCount;
    end

    if dSupraclavicularCount == 0
        tReport.Supraclavicular.Count = [];
    else
        tReport.Supraclavicular.Count = dSupraclavicularCount;
    end

    if dMediastinalCount == 0
        tReport.Mediastinal.Count = [];
    else
        tReport.Mediastinal.Count = dMediastinalCount;
    end

    if dParaspinalCount == 0
        tReport.Paraspinal.Count = [];
    else
        tReport.Paraspinal.Count = dParaspinalCount;
    end

    if dAxillaryCount == 0
        tReport.Axillary.Count = [];
    else
        tReport.Axillary.Count = dAxillaryCount;
    end

    if dAbdominalCount == 0
        tReport.Abdominal.Count = [];
    else
        tReport.Abdominal.Count = dAbdominalCount;
    end

    if dNecroticCount == 0
        tReport.Necrotic.Count = [];
    else
        tReport.Necrotic.Count = dNecroticCount;
    end    

    if dUnspecifiedCount    + ...
       dBoneCount           + ...
       dSoftTissueCount     + ...
       dLungCount           + ...
       dLiverCount          + ...
       dParotidCount        + ...
       dBloodPoolCount      + ...
       dLymphNodesCount     + ...
       dPrimaryDiseaseCount + ...
       dCervicalCount       + ...
       dSupraclavicularCount+ ...
       dMediastinalCount    + ...
       dParaspinalCount     + ...
       dAxillaryCount       + ...
       dAbdominalCount      + ...
       dNecroticCount       + ...
       dUnknowCount         == 0

        tReport.All.Count = [];
    else
        tReport.All.Count = dUnspecifiedCount    + ...
                            dBoneCount           + ...
                            dSoftTissueCount     + ...
                            dLungCount           + ...
                            dLiverCount          + ...
                            dParotidCount        + ...
                            dBloodPoolCount      + ...
                            dLymphNodesCount     + ...
                            dPrimaryDiseaseCount + ...
                            dCervicalCount       + ...
                            dSupraclavicularCount+ ...
                            dMediastinalCount    + ...
                            dParaspinalCount     + ...
                            dAxillaryCount       + ...
                            dAbdominalCount      + ...
                            dNecroticCount       + ...
                            dUnknowCount;
    end

    % Clasify ROIs by lession type

    tReport.Unspecified.RoisTag     = cell(1, dNbUnspecifiedRois);
    tReport.Bone.RoisTag            = cell(1, dNbBoneRois);
    tReport.SoftTissue.RoisTag      = cell(1, dNbSoftTissueRois);
    tReport.Lung.RoisTag            = cell(1, dNbLungRois);
    tReport.Liver.RoisTag           = cell(1, dNbLiverRois);
    tReport.Parotid.RoisTag         = cell(1, dNbParotidRois);
    tReport.BloodPool.RoisTag       = cell(1, dNbBloodPoolRois);
    tReport.LymphNodes.RoisTag      = cell(1, dNbLymphNodesRois);
    tReport.PrimaryDisease.RoisTag  = cell(1, dNbPrimaryDiseaseRois);
    tReport.Cervical.RoisTag        = cell(1, dNbCervicalRois);
    tReport.Supraclavicular.RoisTag = cell(1, dNbSupraclavicularRois);
    tReport.Mediastinal.RoisTag     = cell(1, dNbMediastinalRois);
    tReport.Paraspinal.RoisTag      = cell(1, dNbParaspinalRois);
    tReport.Axillary.RoisTag        = cell(1, dNbAxillaryRois);
    tReport.Abdominal.RoisTag       = cell(1, dNbAbdominalRois);
    tReport.Necrotic.RoisTag        = cell(1, dNbNecroticRois);

    tReport.All.RoisTag             = cell(1, dUnspecifiedCount    + ...
                                              dBoneCount           + ...
                                              dSoftTissueCount     + ...
                                              dLungCount           + ...
                                              dLiverCount          + ...
                                              dParotidCount        + ...
                                              dBloodPoolCount      + ...
                                              dLymphNodesCount     + ...
                                              dPrimaryDiseaseCount + ...
                                              dCervicalCount       + ...
                                              dSupraclavicularCount+ ...
                                              dMediastinalCount    + ...
                                              dParaspinalCount     + ...
                                              dAxillaryCount       + ...
                                              dAbdominalCount      + ...
                                              dNecroticCount       + ...
                                              dUnknowCount);

    dUnspecifiedRoisOffset     = 1;
    dBoneRoisOffset            = 1;
    dSoftTissueRoisOffset      = 1;
    dLungRoisOffset            = 1;
    dLiverRoisOffset           = 1;
    dParotidRoisOffset         = 1;
    dBloodPoolRoisOffset       = 1;
    dLymphNodesRoisOffset      = 1;
    dPrimaryDiseaseRoisOffset  = 1;
    dCervicalRoisOffset        = 1;
    dSupraclavicularRoisOffset = 1;
    dMediastinalRoisOffset     = 1;
    dParaspinalRoisOffset      = 1;
    dAxillaryRoisOffset        = 1;
    dAbdominalRoisOffset       = 1;
    dNecroticRoisOffset        = 1;
    dAllRoisOffset             = 1;

    for vv=1:numel(atVoiInput)

        dNbRois = numel(atVoiInput{vv}.RoisTag);

        dFrom = dAllRoisOffset;
        dTo   = dAllRoisOffset+dNbRois-1;

        tReport.All.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

        dAllRoisOffset = dAllRoisOffset+dNbRois;

        switch lower(atVoiInput{vv}.LesionType)

            case 'unspecified'
                dFrom = dUnspecifiedRoisOffset;
                dTo   = dUnspecifiedRoisOffset+dNbRois-1;

                tReport.Unspecified.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dUnspecifiedRoisOffset = dUnspecifiedRoisOffset+dNbRois;

            case 'bone'
                dFrom = dBoneRoisOffset;
                dTo   = dBoneRoisOffset+dNbRois-1;

                tReport.Bone.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dBoneRoisOffset = dBoneRoisOffset+dNbRois;

            case 'soft tissue'
                dFrom = dSoftTissueRoisOffset;
                dTo   = dSoftTissueRoisOffset+dNbRois-1;

                tReport.SoftTissue.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dSoftTissueRoisOffset = dSoftTissueRoisOffset+dNbRois;

            case 'lung'
                dFrom = dLungRoisOffset;
                dTo   = dLungRoisOffset+dNbRois-1;

                tReport.Lung.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dLungRoisOffset = dLungRoisOffset+dNbRois;

            case 'liver'
                dFrom = dLiverRoisOffset;
                dTo   = dLiverRoisOffset+dNbRois-1;

                tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dLiverRoisOffset = dLiverRoisOffset+dNbRois;

            case 'parotid'
                dFrom = dParotidRoisOffset;
                dTo   = dParotidRoisOffset+dNbRois-1;

                tReport.Parotid.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dParotidRoisOffset = dParotidRoisOffset+dNbRois;

            case 'blood pool'
                dFrom = dBloodPoolRoisOffset;
                dTo   = dBloodPoolRoisOffset+dNbRois-1;

                tReport.BloodPool.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dBloodPoolRoisOffset = dBloodPoolRoisOffset+dNbRois;

            case 'lymph nodes'
                dFrom = dLymphNodesRoisOffset;
                dTo   = dLymphNodesRoisOffset+dNbRois-1;

                tReport.LymphNodes.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dLymphNodesRoisOffset = dLymphNodesRoisOffset+dNbRois;

            case 'primary disease'
                dFrom = dPrimaryDiseaseRoisOffset;
                dTo   = dPrimaryDiseaseRoisOffset+dNbRois-1;

                tReport.PrimaryDisease.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dPrimaryDiseaseRoisOffset = dPrimaryDiseaseRoisOffset+dNbRois;

            case 'cervical'
                dFrom = dCervicalRoisOffset;
                dTo   = dCervicalRoisOffset+dNbRois-1;

                tReport.Cervical.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dCervicalRoisOffset = dCervicalRoisOffset+dNbRois;

            case 'supraclavicular'
                dFrom = dSupraclavicularRoisOffset;
                dTo   = dSupraclavicularRoisOffset+dNbRois-1;

                tReport.Supraclavicular.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dSupraclavicularRoisOffset = dSupraclavicularRoisOffset+dNbRois;

            case 'mediastinal'
                dFrom = dMediastinalRoisOffset;
                dTo   = dMediastinalRoisOffset+dNbRois-1;

                tReport.Mediastinal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dMediastinalRoisOffset = dMediastinalRoisOffset+dNbRois;

            case 'paraspinal'
                dFrom = dParaspinalRoisOffset;
                dTo   = dParaspinalRoisOffset+dNbRois-1;

                tReport.Paraspinal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dParaspinalRoisOffset = dParaspinalRoisOffset+dNbRois;

            case 'axillary'
                dFrom = dAxillaryRoisOffset;
                dTo   = dAxillaryRoisOffset+dNbRois-1;

                tReport.Axillary.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dAxillaryRoisOffset = dAxillaryRoisOffset+dNbRois;

            case 'abdominal'
                dFrom = dAbdominalRoisOffset;
                dTo   = dAbdominalRoisOffset+dNbRois-1;

                tReport.Abdominal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dAbdominalRoisOffset = dAbdominalRoisOffset+dNbRois;

            case 'necrotic'
                dFrom = dNecroticRoisOffset;
                dTo   = dNecroticRoisOffset+dNbRois-1;

                tReport.Necrotic.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                dNecroticRoisOffset = dNecroticRoisOffset+dNbRois;

        end
    end


    % Compute lesion type

    % Compute Unspecified lesion

    progressBar( 1/17, 'Computing unspecified lesion, please wait');

    if numel(tReport.Unspecified.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Unspecified.RoisTag));
        voiData = cell(1, numel(tReport.Unspecified.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Unspecified.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Unspecified.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Unspecified.Cells  = dNbCells;
        tReport.Unspecified.Volume = dNbCells*dVoxVolume;
        tReport.Unspecified.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Unspecified.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Unspecified.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Unspecified.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Unspecified.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Unspecified.Mean = mean(voiData, 'all');
                tReport.Unspecified.Max  = max (voiData, [], 'all');
                tReport.Unspecified.Peak = computePeak(voiData);
           end
        else
            tReport.Unspecified.Mean = mean(voiData, 'all');
            tReport.Unspecified.Max  = max (voiData, [], 'all');
            tReport.Unspecified.Peak = computePeak(voiData);
        end

        if isempty(tReport.Unspecified.Mean)
            tReport.Unspecified.Mean = nan;
        end

        if isempty(tReport.Unspecified.Max)
            tReport.Unspecified.Max = nan;
        end

        if isempty(tReport.Unspecified.Peak)
            tReport.Unspecified.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Unspecified.Cells   = [];
        tReport.Unspecified.Volume  = [];
        tReport.Unspecified.Mean    = [];
        tReport.Unspecified.Max     = [];
        tReport.Unspecified.Peak    = [];
        tReport.Unspecified.voiData = [];
    end

    % Compute bone lesion

    progressBar( 2/17, 'Computing bone lesion, please wait') ;

    if numel(tReport.Bone.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Bone.RoisTag));
        voiData = cell(1, numel(tReport.Bone.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Bone.RoisTag)

            aTagOffset  = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Bone.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Bone.Cells  = dNbCells;
        tReport.Bone.Volume = dNbCells*dVoxVolume;
        tReport.Bone.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Bone.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Bone.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Bone.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Bone.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Bone.Mean = mean(voiData, 'all');
                tReport.Bone.Max  = max (voiData, [], 'all');
                tReport.Bone.Peak = computePeak(voiData);
            end
        else
            tReport.Bone.Mean = mean(voiData, 'all');
            tReport.Bone.Max  = max (voiData, [], 'all');
            tReport.Bone.Peak = computePeak(voiData);
        end

        if isempty(tReport.Bone.Mean)
            tReport.Bone.Mean = nan;
        end

        if isempty(tReport.Bone.Max)
            tReport.Bone.Max = nan;
        end

        if isempty(tReport.Bone.Peak)
            tReport.Bone.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Bone.Cells   = [];
        tReport.Bone.Volume  = [];
        tReport.Bone.Mean    = [];
        tReport.Bone.Max     = [];
        tReport.Bone.Peak    = [];
        tReport.Bone.voiData = [];
    end

    % Compute SoftTissue lesion

    progressBar( 3/17, 'Computing soft tissue lesion, please wait' );

    if numel(tReport.SoftTissue.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.SoftTissue.RoisTag));
        voiData = cell(1, numel(tReport.SoftTissue.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.SoftTissue.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.SoftTissue.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.SoftTissue.Cells  = dNbCells;
        tReport.SoftTissue.Volume = dNbCells*dVoxVolume;
        tReport.SoftTissue.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.SoftTissue.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.SoftTissue.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.SoftTissue.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.SoftTissue.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.SoftTissue.Mean = mean(voiData, 'all');
                tReport.SoftTissue.Max  = max (voiData, [], 'all');
                tReport.SoftTissue.Peak = computePeak(voiData);
            end
        else
            tReport.SoftTissue.Mean = mean(voiData, 'all');
            tReport.SoftTissue.Max  = max (voiData, [], 'all');
            tReport.SoftTissue.Peak = computePeak(voiData);
        end

        if isempty(tReport.SoftTissue.Mean)
            tReport.SoftTissue.Mean = nan;
        end

        if isempty(tReport.SoftTissue.Max)
            tReport.SoftTissue.Max = nan;
        end

        if isempty(tReport.SoftTissue.Peak)
            tReport.SoftTissue.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.SoftTissue.Cells   = [];
        tReport.SoftTissue.Volume  = [];
        tReport.SoftTissue.Mean    = [];
        tReport.SoftTissue.Max     = [];
        tReport.SoftTissue.Peak    = [];
        tReport.SoftTissue.voiData = [];
    end

    % Compute Lung lesion

    progressBar( 4/17, 'Computing lung lesion, please wait' );

    if numel(tReport.Lung.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Lung.RoisTag));
        voiData = cell(1, numel(tReport.Lung.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Lung.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Lung.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if numel(aImage) ~= numel(dicomBuffer('get'), [], dSeriesOffset)
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Lung.Cells  = dNbCells;
        tReport.Lung.Volume = dNbCells*dVoxVolume;
        tReport.Lung.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Lung.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Lung.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Lung.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Lung.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Lung.Mean = mean(voiData, 'all');
                tReport.Lung.Max  = max (voiData, [], 'all');
                tReport.Lung.Peak = computePeak(voiData);
            end
        else
            tReport.Lung.Mean = mean(voiData, 'all');
            tReport.Lung.Max  = max (voiData, [], 'all');
            tReport.Lung.Peak = computePeak(voiData);
        end

        if isempty(tReport.Lung.Mean)
            tReport.Lung.Mean = nan;
        end

        if isempty(tReport.Lung.Max)
            tReport.Lung.Max = nan;
        end

        if isempty(tReport.Lung.Peak)
            tReport.Lung.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Lung.Cells   = [];
        tReport.Lung.Volume  = [];
        tReport.Lung.Mean    = [];
        tReport.Lung.Max     = [];
        tReport.Lung.Peak    = [];
        tReport.Lung.voiData = [];
    end

    % Compute Liver lesion

    progressBar( 5/17, 'Computing liver lesion, please wait' );

    if numel(tReport.Liver.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Liver.RoisTag));
        voiData = cell(1, numel(tReport.Liver.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Liver.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Liver.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Liver.Cells  = dNbCells;
        tReport.Liver.Volume = dNbCells*dVoxVolume;
        tReport.Liver.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Liver.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Liver.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Liver.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Liver.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Liver.Mean = mean(voiData, 'all');
                tReport.Liver.Max  = max (voiData, [], 'all');
                tReport.Liver.Peak = computePeak(voiData);
            end
        else
            tReport.Liver.Mean = mean(voiData, 'all');
            tReport.Liver.Max  = max (voiData, [], 'all');
            tReport.Liver.Peak = computePeak(voiData);
        end

        if isempty(tReport.Liver.Mean)
            tReport.Liver.Mean = nan;
        end

        if isempty(tReport.Liver.Max)
            tReport.Liver.Max = nan;
        end

        if isempty(tReport.Liver.Peak)
            tReport.Liver.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Liver.Cells   = [];
        tReport.Liver.Volume  = [];
        tReport.Liver.Mean    = [];
        tReport.Liver.Max     = [];
        tReport.Liver.Peak    = [];
        tReport.Liver.voiData = [];
    end

    % Compute Parotid lesion

    progressBar( 6/17, 'Computing parotid lesion, please wait' );

    if numel(tReport.Parotid.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Parotid.RoisTag));
        voiData = cell(1, numel(tReport.Parotid.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Parotid.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Parotid.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Parotid.Cells  = dNbCells;
        tReport.Parotid.Volume = dNbCells*dVoxVolume;
        tReport.Parotid.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Parotid.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Parotid.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Parotid.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Parotid.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Parotid.Mean = mean(voiData, 'all');
                tReport.Parotid.Max  = max (voiData, [], 'all');
                tReport.Parotid.Peak = computePeak(voiData);
            end
        else
            tReport.Parotid.Mean = mean(voiData, 'all');
            tReport.Parotid.Max  = max (voiData, [], 'all');
            tReport.Parotid.Peak = computePeak(voiData);
        end

        if isempty(tReport.Parotid.Mean)
            tReport.Parotid.Mean = nan;
        end

        if isempty(tReport.Parotid.Max)
            tReport.Parotid.Max = nan;
        end

        if isempty(tReport.Parotid.Peak)
            tReport.Parotid.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Parotid.Cells   = [];
        tReport.Parotid.Volume  = [];
        tReport.Parotid.Mean    = [];
        tReport.Parotid.Max     = [];
        tReport.Parotid.Peak    = [];
        tReport.Parotid.voiData = [];
    end

    % Compute BloodPool lesion

    progressBar( 7/17, 'Computing blood pool lesion, please wait' );

    if numel(tReport.BloodPool.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.BloodPool.RoisTag));
        voiData = cell(1, numel(tReport.BloodPool.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.BloodPool.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.BloodPool.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.BloodPool.Cells  = dNbCells;
        tReport.BloodPool.Volume = dNbCells*dVoxVolume;
        tReport.BloodPool.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.BloodPool.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.BloodPool.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.BloodPool.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.BloodPool.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.BloodPool.Mean = mean(voiData, 'all');
                tReport.BloodPool.Max  = max (voiData, [], 'all');
                tReport.BloodPool.Peak = computePeak(voiData);
            end
        else
            tReport.BloodPool.Mean = mean(voiData, 'all');
            tReport.BloodPool.Max  = max (voiData, [], 'all');
            tReport.BloodPool.Peak = computePeak(voiData);
        end

        if isempty(tReport.BloodPool.Mean)
            tReport.BloodPool.Mean = nan;
        end

        if isempty(tReport.BloodPool.Max)
            tReport.BloodPool.Max = nan;
        end

        if isempty(tReport.BloodPool.Peak)
            tReport.BloodPool.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.BloodPool.Cells   = [];
        tReport.BloodPool.Volume  = [];
        tReport.BloodPool.Mean    = [];
        tReport.BloodPool.Max     = [];
        tReport.BloodPool.Peak    = [];
        tReport.BloodPool.voiData = [];
    end

    % Compute LymphNodes lesion

    progressBar( 8/17, 'Computing lymph nodes lesion, please wait' );

    if numel(tReport.LymphNodes.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.LymphNodes.RoisTag));
        voiData = cell(1, numel(tReport.LymphNodes.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.LymphNodes.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LymphNodes.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.LymphNodes.Cells  = dNbCells;
        tReport.LymphNodes.Volume = dNbCells*dVoxVolume;
        tReport.LymphNodes.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.LymphNodes.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.LymphNodes.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.LymphNodes.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.LymphNodes.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.LymphNodes.Mean = mean(voiData, 'all');
                tReport.LymphNodes.Max  = max (voiData, [], 'all');
                tReport.LymphNodes.Peak = computePeak(voiData);
            end
        else
            tReport.LymphNodes.Mean = mean(voiData, 'all');
            tReport.LymphNodes.Max  = max (voiData, [], 'all');
            tReport.LymphNodes.Peak = computePeak(voiData);
        end

        if isempty(tReport.LymphNodes.Mean)
            tReport.LymphNodes.Mean = nan;
        end

        if isempty(tReport.LymphNodes.Max)
            tReport.LymphNodes.Max = nan;
        end

        if isempty(tReport.LymphNodes.Peak)
            tReport.LymphNodes.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.LymphNodes.Cells  = [];
        tReport.LymphNodes.Volume  = [];
        tReport.LymphNodes.Mean    = [];
        tReport.LymphNodes.Max     = [];
        tReport.LymphNodes.Peak    = [];
        tReport.LymphNodes.voiData = [];
    end

    % Compute Primary Disease lesion

    progressBar( 9/17, 'Computing primary disease lesion, please wait' );

    if numel(tReport.PrimaryDisease.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.PrimaryDisease.RoisTag));
        voiData = cell(1, numel(tReport.PrimaryDisease.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.PrimaryDisease.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.PrimaryDisease.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.PrimaryDisease.Cells  = dNbCells;
        tReport.PrimaryDisease.Volume = dNbCells*dVoxVolume;
        tReport.PrimaryDisease.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.PrimaryDisease.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.PrimaryDisease.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.PrimaryDisease.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.PrimaryDisease.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.PrimaryDisease.Mean = mean(voiData, 'all');
                tReport.PrimaryDisease.Max  = max (voiData, [], 'all');
                tReport.PrimaryDisease.Peak = computePeak(voiData);
            end
        else
            tReport.PrimaryDisease.Mean = mean(voiData, 'all');
            tReport.PrimaryDisease.Max  = max (voiData, [], 'all');
            tReport.PrimaryDisease.Peak = computePeak(voiData);
        end

        if isempty(tReport.PrimaryDisease.Mean)
            tReport.PrimaryDisease.Mean = nan;
        end

        if isempty(tReport.PrimaryDisease.Max)
            tReport.PrimaryDisease.Max = nan;
        end

        if isempty(tReport.PrimaryDisease.Peak)
            tReport.PrimaryDisease.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.PrimaryDisease.Cells   = [];
        tReport.PrimaryDisease.Volume  = [];
        tReport.PrimaryDisease.Mean    = [];
        tReport.PrimaryDisease.Max     = [];
        tReport.PrimaryDisease.Peak    = [];
        tReport.PrimaryDisease.voiData = [];
    end

    % Compute Cervical

    progressBar( 10/17, 'Computing cervical, please wait' );

    if numel(tReport.Cervical.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Cervical.RoisTag));
        voiData = cell(1, numel(tReport.Cervical.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Cervical.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Cervical.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Cervical.Cells  = dNbCells;
        tReport.Cervical.Volume = dNbCells*dVoxVolume;
        tReport.Cervical.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Cervical.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Cervical.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Cervical.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Cervical.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Cervical.Mean = mean(voiData, 'all');
                tReport.Cervical.Max  = max (voiData, [], 'all');
                tReport.Cervical.Peak = computePeak(voiData);
            end
        else
            tReport.Cervical.Mean = mean(voiData, 'all');
            tReport.Cervical.Max  = max (voiData, [], 'all');
            tReport.Cervical.Peak = computePeak(voiData);
        end

        if isempty(tReport.Cervical.Mean)
            tReport.Cervical.Mean = nan;
        end

        if isempty(tReport.Cervical.Max)
            tReport.Cervical.Max = nan;
        end

        if isempty(tReport.Cervical.Peak)
            tReport.Cervical.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Cervical.Cells   = [];
        tReport.Cervical.Volume  = [];
        tReport.Cervical.Mean    = [];
        tReport.Cervical.Max     = [];
        tReport.Cervical.Peak    = [];
        tReport.Cervical.voiData = [];
    end

    % Compute Supraclavicular

    progressBar( 11/17, 'Computing supraclavicular, please wait' );

    if numel(tReport.Supraclavicular.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Supraclavicular.RoisTag));
        voiData = cell(1, numel(tReport.Supraclavicular.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Supraclavicular.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Supraclavicular.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Supraclavicular.Cells  = dNbCells;
        tReport.Supraclavicular.Volume = dNbCells*dVoxVolume;
        tReport.Supraclavicular.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Supraclavicular.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Supraclavicular.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Supraclavicular.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Supraclavicular.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Supraclavicular.Mean = mean(voiData, 'all');
                tReport.Supraclavicular.Max  = max (voiData, [], 'all');
                tReport.Supraclavicular.Peak = computePeak(voiData);
            end
        else
            tReport.Supraclavicular.Mean = mean(voiData, 'all');
            tReport.Supraclavicular.Max  = max (voiData, [], 'all');
            tReport.Supraclavicular.Peak = computePeak(voiData);
        end

        if isempty(tReport.Supraclavicular.Mean)
            tReport.Supraclavicular.Mean = nan;
        end

        if isempty(tReport.Supraclavicular.Max)
            tReport.Supraclavicular.Max = nan;
        end

        if isempty(tReport.Supraclavicular.Peak)
            tReport.Supraclavicular.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Supraclavicular.Cells   = [];
        tReport.Supraclavicular.Volume  = [];
        tReport.Supraclavicular.Mean    = [];
        tReport.Supraclavicular.Max     = [];
        tReport.Supraclavicular.Peak    = [];
        tReport.Supraclavicular.voiData = [];
    end

    % Compute Mediastinal

    progressBar( 12/17, 'Computing mediastinal, please wait' );

    if numel(tReport.Mediastinal.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Mediastinal.RoisTag));
        voiData = cell(1, numel(tReport.Mediastinal.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Mediastinal.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Mediastinal.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Mediastinal.Cells  = dNbCells;
        tReport.Mediastinal.Volume = dNbCells*dVoxVolume;
        tReport.Mediastinal.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Mediastinal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Mediastinal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Mediastinal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Mediastinal.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Mediastinal.Mean = mean(voiData, 'all');
                tReport.Mediastinal.Max  = max (voiData, [], 'all');
                tReport.Mediastinal.Peak = computePeak(voiData);
            end
        else
            tReport.Mediastinal.Mean = mean(voiData, 'all');
            tReport.Mediastinal.Max  = max (voiData, [], 'all');
            tReport.Mediastinal.Peak = computePeak(voiData);
        end

        if isempty(tReport.Mediastinal.Mean)
            tReport.Mediastinal.Mean = nan;
        end

        if isempty(tReport.Mediastinal.Max)
            tReport.Mediastinal.Max = nan;
        end

        if isempty(tReport.Mediastinal.Peak)
            tReport.Mediastinal.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Mediastinal.Cells   = [];
        tReport.Mediastinal.Volume  = [];
        tReport.Mediastinal.Mean    = [];
        tReport.Mediastinal.Max     = [];
        tReport.Mediastinal.Peak    = [];
        tReport.Mediastinal.voiData = [];
    end

    % Compute Paraspinal

    progressBar( 13/17, 'Computing paraspinal, please wait' );

    if numel(tReport.Paraspinal.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Paraspinal.RoisTag));
        voiData = cell(1, numel(tReport.Paraspinal.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Paraspinal.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Paraspinal.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Paraspinal.Cells  = dNbCells;
        tReport.Paraspinal.Volume = dNbCells*dVoxVolume;
        tReport.Paraspinal.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Paraspinal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Paraspinal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Paraspinal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Paraspinal.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Paraspinal.Mean = mean(voiData, 'all');
                tReport.Paraspinal.Max  = max (voiData, [], 'all');
                tReport.Paraspinal.Peak = computePeak(voiData);
            end
        else
            tReport.Paraspinal.Mean = mean(voiData, 'all');
            tReport.Paraspinal.Max  = max (voiData, [], 'all');
            tReport.Paraspinal.Peak = computePeak(voiData);
        end

        if isempty(tReport.Paraspinal.Mean)
            tReport.Paraspinal.Mean = nan;
        end

        if isempty(tReport.Paraspinal.Max)
            tReport.Paraspinal.Max = nan;
        end

        if isempty(tReport.Paraspinal.Peak)
            tReport.Paraspinal.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Paraspinal.Cells   = [];
        tReport.Paraspinal.Volume  = [];
        tReport.Paraspinal.Mean    = [];
        tReport.Paraspinal.Max     = [];
        tReport.Paraspinal.Peak    = [];
        tReport.Paraspinal.voiData = [];
    end

    % Compute Paraspinal

    progressBar( 14/17, 'Computing axillary, please wait' );

    if numel(tReport.Axillary.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Axillary.RoisTag));
        voiData = cell(1, numel(tReport.Axillary.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Axillary.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Axillary.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Axillary.Cells  = dNbCells;
        tReport.Axillary.Volume = dNbCells*dVoxVolume;
        tReport.Axillary.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Axillary.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Axillary.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Axillary.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Axillary.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Axillary.Mean = mean(voiData, 'all');
                tReport.Axillary.Max  = max (voiData, [], 'all');
                tReport.Axillary.Peak = computePeak(voiData);
            end
        else
            tReport.Axillary.Mean = mean(voiData, 'all');
            tReport.Axillary.Max  = max (voiData, [], 'all');
            tReport.Axillary.Peak = computePeak(voiData);
        end

        if isempty(tReport.Axillary.Mean)
            tReport.Axillary.Mean = nan;
        end

        if isempty(tReport.Axillary.Max)
            tReport.Axillary.Max = nan;
        end

        if isempty(tReport.Axillary.Peak)
            tReport.Axillary.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Axillary.Cells   = [];
        tReport.Axillary.Volume  = [];
        tReport.Axillary.Mean    = [];
        tReport.Axillary.Max     = [];
        tReport.Axillary.Peak    = [];
        tReport.Axillary.voiData = [];
    end

    % Compute Abdominal

    progressBar( 15/17, 'Computing abdominal, please wait' );

    if numel(tReport.Abdominal.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Abdominal.RoisTag));
        voiData = cell(1, numel(tReport.Abdominal.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Abdominal.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Abdominal.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Abdominal.Cells  = dNbCells;
        tReport.Abdominal.Volume = dNbCells*dVoxVolume;
        tReport.Abdominal.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Abdominal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Abdominal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Abdominal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Abdominal.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Abdominal.Mean = mean(voiData, 'all');
                tReport.Abdominal.Max  = max (voiData, [], 'all');
                tReport.Abdominal.Peak = computePeak(voiData);
            end
        else
            tReport.Abdominal.Mean = mean(voiData, 'all');
            tReport.Abdominal.Max  = max (voiData, [], 'all');
            tReport.Abdominal.Peak = computePeak(voiData);
        end

        if isempty(tReport.Abdominal.Mean)
            tReport.Abdominal.Mean = nan;
        end

        if isempty(tReport.Abdominal.Max)
            tReport.Abdominal.Max = nan;
        end

        if isempty(tReport.Abdominal.Peak)
            tReport.Abdominal.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Abdominal.Cells   = [];
        tReport.Abdominal.Volume  = [];
        tReport.Abdominal.Mean    = [];
        tReport.Abdominal.Max     = [];
        tReport.Abdominal.Peak    = [];
        tReport.Abdominal.voiData = [];
    end

    % Compute Necrotic lesion

    progressBar( 16/17, 'Computing necrotic, please wait' );

    if numel(tReport.Necrotic.RoisTag) ~= 0

        voiMask = cell(1, numel(tReport.Necrotic.RoisTag));
        voiData = cell(1, numel(tReport.Necrotic.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.Necrotic.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Necrotic.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)
                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.Necrotic.Cells  = dNbCells;
        tReport.Necrotic.Volume = dNbCells*dVoxVolume;
        tReport.Necrotic.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.Necrotic.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.Necrotic.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.Necrotic.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.Necrotic.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.Necrotic.Mean = mean(voiData, 'all');
                tReport.Necrotic.Max  = max (voiData, [], 'all');
                tReport.Necrotic.Peak = computePeak(voiData);
            end
        else
            tReport.Necrotic.Mean = mean(voiData, 'all');
            tReport.Necrotic.Max  = max (voiData, [], 'all');
            tReport.Necrotic.Peak = computePeak(voiData);
        end

        if isempty(tReport.Necrotic.Mean)
            tReport.Necrotic.Mean = nan;
        end

        if isempty(tReport.Necrotic.Max)
            tReport.Necrotic.Max = nan;
        end

        if isempty(tReport.Necrotic.Peak)
            tReport.Necrotic.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.Necrotic.Cells   = [];
        tReport.Necrotic.Volume  = [];
        tReport.Necrotic.Mean    = [];
        tReport.Necrotic.Max     = [];
        tReport.Necrotic.Peak    = [];
        tReport.Necrotic.voiData = [];
    end

    % Compute All lesion

    progressBar( 0.99999 , 'Computing all lesion, please wait' );

    if numel(tReport.All.RoisTag) ~= 0

        adVoiAllContoursMask = false(size(aImage));

        voiMask = cell(1, numel(tReport.All.RoisTag));
        voiData = cell(1, numel(tReport.All.RoisTag));

        dNbCells = 0;

        for uu=1:numel(tReport.All.RoisTag)

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.All.RoisTag{uu}]} );

            tRoi = atRoiInput{find(aTagOffset, 1)};

            % if bModifiedMatrix  == false && ...
            %    bMovementApplied == false        % Can't use input buffer if movement have been applied
            % 
            %     if bDifferentImageSize == true 
            %         pTemp{1} = tRoi;
            %         ptrRoiTemp = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, pTemp, false, atVoiInput, dSeriesOffset);
            %         tRoi = ptrRoiTemp{1};
            %     end
            % end

            switch lower(tRoi.Axe)

                case 'axe'
                    voiData{uu} = aImage(:,:);
                    voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                    adVoiAllContoursMask(:,:) = adVoiAllContoursMask(:,:)|voiMask{uu};

                case 'axes1'
                    aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                    adVoiAllContoursMask(tRoi.SliceNb,:,:) = adVoiAllContoursMask(tRoi.SliceNb,:,:)| permute(voiMask{uu}, [3 2 1]);

                case 'axes2'
                    aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                    adVoiAllContoursMask(:,tRoi.SliceNb,:) = adVoiAllContoursMask(:,tRoi.SliceNb,:)| permute(voiMask{uu}, [2 3 1]);

               case 'axes3'
                    aSlice = aImage(:,:,tRoi.SliceNb);
                    voiData{uu} = aSlice;
                    voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                    adVoiAllContoursMask(:,:,tRoi.SliceNb) = adVoiAllContoursMask(:,:,tRoi.SliceNb)|voiMask{uu};

            end

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiDataTemp = voiData{uu}(voiMask{uu});
                voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                dNbCells = dNbCells+numel(voiDataTemp);
            else
                dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
            end
        end

        % if bModifiedMatrix  == true && ...
        %    bMovementApplied == true        % Can't use input buffer if movement have been applied
        % 
        %     if bDifferentImageSize == true 
        %         if size(aImage, 3) ~= size(aDicomImage, 3)
        %             [adVoiAllContoursMask, ~] = resampleImage(adVoiAllContoursMask, atMetaData, aDicomImage,  atDicomMeta, 'Nearest', false, true);
        %         else
        %             [adVoiAllContoursMask, ~] = resampleImage(adVoiAllContoursMask, atMetaData, aDicomImage,  atDicomMeta, 'Nearest', true, true);
        %         end
        %     end
        % end

        voiMask = cat(1, voiMask{:});
        voiData = cat(1, voiData{:});

        voiData(voiMask~=1) = [];

        if bSegmented  == true && ...
           bModifiedMatrix == true % Can't use original buffer

            voiData = voiData(voiData>cropValue('get'));
        end

        tReport.All.Cells  = dNbCells;
        tReport.All.Volume = dNbCells*dVoxVolume;
        tReport.All.voiData = voiData;

        if strcmpi(sUnitDisplay, 'SUV')

            if bSUVUnit == true
                tReport.All.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                tReport.All.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                tReport.All.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                tReport.All.voiData = voiData *tQuantification.tSUV.dScale;
            else
                tReport.All.Mean = mean(voiData, 'all');
                tReport.All.Max  = max (voiData, [], 'all');
                tReport.All.Peak = computePeak(voiData);
            end
        else
            tReport.All.Mean = mean(voiData, 'all');
            tReport.All.Max  = max (voiData, [], 'all');
            tReport.All.Peak = computePeak(voiData);
        end

        if isempty(tReport.All.Mean)
            tReport.All.Mean = nan;
        end

        if isempty(tReport.All.Max)
            tReport.All.Max = nan;
        end

        if isempty(tReport.All.Peak)
            tReport.All.Peak = nan;
        end

        clear voiMask;
        clear voiData;
    else
        tReport.All.Cells   = [];
        tReport.All.Volume  = [];
        tReport.All.Mean    = [];
        tReport.All.Max     = [];
        tReport.All.Peak    = [];
        tReport.All.voiData = [];
    end

    if ~isempty(adVoiAllContoursMask)
        [gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeMaskFarthestPoint(adVoiAllContoursMask(:,:,end:-1:1), atMetaData, bCentroid);
    end

    clear aImage;

    progressBar( 1 , 'Ready' );

end