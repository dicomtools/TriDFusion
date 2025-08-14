function setMantleCellLymphomaSegmentation(sSegmentatorScript, tMantleCellLymphoma)
%function setMantleCellLymphomaSegmentation(sSegmentatorScript, tMantleCellLymphoma)
%Run Mantle Cell Lymphoma Tumor Segmentation.
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

    atInput = inputTemplate('get');

    % Modality validation

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break
        end
    end

    dPTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
            dPTSerieOffset = tt;
            break
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)
        progressBar(1, 'Error: Mantle Cell Lymphoma tumor segmentation require a CT and PT image!');
        errordlg('Mantle Cell Lymphoma tumor segmentation require a CT and PT image!', 'Modality Validation');
        return;
    end


    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    if isempty(atPTMetaData)
        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
    end

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    % Apply ROI constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dPTSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dPTSerieOffset);

    aPTImageTemp = aPTImage;
    aLogicalMask = roiConstraintToMask(aPTImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);

    if any(aLogicalMask(:) ~= 0)

        aPTImageTemp(aLogicalMask==0) = 0;  % Set constraint
    end

    resetSeries(dPTSerieOffset, true);

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if isInterpolated('get') == false

        isInterpolated('set', true);

        setImageInterpolation(true);
    end

    % Get DICOM directory directory

    [sFilePath, ~, ~] = fileparts(char(atInput(dCTSerieOffset).asFilesList{1}));

    % Create an empty directory

    sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end
    mkdir(char(sNiiTmpDir));

    % Convert dicom to .nii

    progressBar(1/11, 'Converting DICOM to NII, please wait...');

    dicm2nii(sFilePath, sNiiTmpDir, 1);

    sNiiFullFileName = '';

    f = java.io.File(char(sNiiTmpDir)); % Get .nii file name
    dinfo = f.listFiles();
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sNiiTmpDir, dinfo(K).getName()), '.nii.gz')
                sNiiFullFileName = sprintf('%s%s', sNiiTmpDir, dinfo(K).getName());
                break;
            end
        end
    end

    if isempty(sNiiFullFileName)

        progressBar(1, 'Error: nii file not found!');
        errordlg('nii file not found!!', '.nii file Validation');
    else

        progressBar(2/11, 'Machine learning in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            end

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed

                progressBar(4/11, 'Resampling data series, please wait...');

                [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);
                [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

                dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

                aResampledPTImage = aResampledPTImageTemp;

                clear aPTImageTemp;
                clear aResampledPTImageTemp;

                progressBar(5/11, 'Resampling MIP, please wait...');

                refMip = mipBuffer('get', [], dCTSerieOffset);
                aMip   = mipBuffer('get', [], dPTSerieOffset);

                aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

                mipBuffer('set', aMip, dPTSerieOffset);

                setQuantification(dPTSerieOffset);

                progressBar(6/11, 'Resampling axes, please wait...');

                resampleAxes(aResampledPTImage, atResampledPTMetaData);

                setImagesAspectRatio();

                refreshImages();

                % drawnow;

                progressBar(7/11, 'Computing CT map, please wait...');

                BWCT = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));
                BWCT = imfill(BWCT, 4, 'holes');

                progressBar(8/11, 'Importing exclusion masks, please wait...');

                aExcludeMask = getMantleCellLymphomaExcludeMask(tMantleCellLymphoma, sSegmentationFolderName, zeros(size(aCTImage)));

                if tMantleCellLymphoma.exclude.skeleton.all == true % Add skeleton

                    aExcludeMask(BWCT~=0)=1;
                end

                aExcludeMask = imdilate(aExcludeMask, strel('sphere', 2)); % Increse mask by 2 pixels

                if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view

                     aExcludeMask = resample3DImage(aExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aExcludeMask = imbinarize(aExcludeMask);

                    if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view
                        aExcludeMask = resizeMaskToImageSize(aExcludeMask, aResampledPTImage);
                    end
                else
                    aExcludeMask = imbinarize(aExcludeMask);
                end

                aResampledPTImage(aExcludeMask) = min(aResampledPTImage, [], 'all');  % Exclude mask

                clear aExcludeMask;


                progressBar(9/11, 'Computing mask, please wait...');


                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');

                if exist(sNiiFileName, 'file')

                    nii = nii_tool('load', sNiiFileName);
                    aLiverMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                    aLiverMask = aLiverMask(:,:,end:-1:1);

                    clear nii;

                    aBWMask = aResampledPTImage;

                    aLiver = aResampledPTImage(aLiverMask==1);

                    dMin      = min(aResampledPTImage, [], 'all');
                    dLiverMax = max(aLiver, [], 'all');

                    clear aLiverMask;

                    dThreshold = dLiverMax * ((100-tMantleCellLymphoma.options.percentOfLiverMax)/100) * dSUVScale;

                    if dThreshold > 0

                        aBWMask(aBWMask*dSUVScale<dThreshold)=dMin;

                        aBWMask = imbinarize(aBWMask);

                        progressBar(10/11, 'Generating contours, please wait...');

                        imMask = aResampledPTImage;
                        imMask(aBWMask == 0) = dMin;

                        setSeriesCallback();

                        dSmalestVoiValue = tMantleCellLymphoma.options.smalestVoiValue;
                        bPixelEdge = tMantleCellLymphoma.options.pixelEdge;

                        sFormula = 'Lymph Nodes & Bone SUV, CT Bone Map';
                        maskAddVoiToSeries(imMask, aBWMask, bPixelEdge, false, dThreshold, false, 0, true, sFormula, BWCT, dSmalestVoiValue, [],[],[], dThreshold);

                        clear imMask;

                    end

                    clear aBWMask;

                end

                clear aResampledPTImage;
                clear refMip;
                clear aMip;
                clear BWCT;

            end

        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');
            errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');
            errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
        end

        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
    end

    setVoiRoiSegPopup();

    % Deactivate MIP Fusion

    link2DMip('set', false);

    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    %  set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
    set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_grey.png'));

    % Set fusion

    if isFusion('get') == false

        set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

        sliderAlphaValue('set', 0.65);

        setFusionCallback();
    end

    % Triangulate to 1st VOI

    atVoiInput = voiTemplate('get', dPTSerieOffset);

    if ~isempty(atVoiInput)

        dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

        triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
    end

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();

    plotRotatedRoiOnMip(axesMipPtr('get', [], dPTSerieOffset), dicomBuffer('get', [], dPTSerieOffset), mipAngle('get'));

    clear aPTImage;
    clear aCTImage;

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setMantleCellLymphomaSegmentation()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
