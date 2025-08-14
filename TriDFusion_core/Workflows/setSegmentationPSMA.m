function setSegmentationPSMA(sSegmentatorScript, tGa68, bUseDefault)
%function setSegmentationPSMA(sSegmentatorScript, tGa68, bUseDefault)
%Run PSMA Segmentation base on normal liver Threshold.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    gbProceedWithSegmentation = false;
    gbBypassOrgansSegmentation = false;

    gdNormalLiverMean = [];
    gdNormalLiverSTD = [];

    gdLymphNodesSUVThresholdValue = [];
    gdBoneSUVThresholdValue  = [];

    gbLymphNodesSegmentation = [];
    gbBoneSegmentation = [];

    atInput = inputTemplate('get');

    bExcludeOrgansFromSegmentation = tGa68.options.excludeOrgansFromSegmentation;
    bOrganMargins      = tGa68.options.excludeOrganMargins;
    dBoneMaskThreshold = tGa68.options.boneMaskThresholdValue;
    dSmalestVoiValue   = tGa68.options.smalestVoiValue;
    dPixelEdge         = tGa68.options.pixelEdge;

    % Modality validation

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break;
        end
    end

    dPTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
            dPTSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)
        progressBar(1, 'Error: PSMA tumor segmentation require a CT and PT image!');
        errordlg('PSMA tumor segmentation require a CT and PT image!', 'Modality Validation');
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

    atRoiInput = roiTemplate('get', dPTSerieOffset);

    bResetSeries = true;

    if ~isempty(atRoiInput)

        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Normal Liver'} );
        dTagOffset = find(aTagOffset, 1);

        aSlice = [];

        if ~isempty(dTagOffset)

            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'
                    aSlice = permute(aPTImage(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    aSlice = permute(aPTImage(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                case 'axes3'
                    aSlice = aPTImage(:,:,atRoiInput{dTagOffset}.SliceNb);
            end

            aLogicalMask = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);

            gdNormalLiverMean = mean(aSlice(aLogicalMask), 'all')   * dSUVScale;


   %         H = fspecial('average',5);
   %         blurred = imfilter(aSlice(aLogicalMask),H,'replicate');

            gdNormalLiverSTD = std(aSlice(aLogicalMask), [],'all') * dSUVScale;

            clear aSlice;
        else
            if bUseDefault == false

                waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));

                PSMAThresholdValuesDialog();

                if gbProceedWithSegmentation == false
                    return;
                end

                bResetSeries = false;
            else
                gbLymphNodesSegmentation = true;
                gbBoneSegmentation = true;

                gdLymphNodesSUVThresholdValue = PSMALymphNodesSUVThresholdValue('get');
                gdBoneSUVThresholdValue       = PSMABoneSUVThresholdValue('get');
            end
        end
    else

        if bUseDefault == false

            waitfor(msgbox('Warning: Normal Liver ROI not found. Draw an ROI on the normal liver, right-click on the ROI, and select the predefined label ''Normal Liver,'' or manually input the Lymph Nodes and Bone SUV Threshold into the following dialog.', 'Warning'));

            PSMAThresholdValuesDialog();

            if gbProceedWithSegmentation == false
                return;
            end

            if gbLymphNodesSegmentation == false
                gbBypassOrgansSegmentation = true;
            end

            if gbLymphNodesSegmentation == false && gbBoneSegmentation == false
                gbBypassOrgansSegmentation = true;
            end

            bResetSeries = false;

        else
            gbLymphNodesSegmentation = true;
            gbBoneSegmentation = true;

            gdLymphNodesSUVThresholdValue = PSMALymphNodesSUVThresholdValue('get');
            gdBoneSUVThresholdValue       = PSMABoneSUVThresholdValue('get');
        end
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

    if bResetSeries == true

        resetSeries(dPTSerieOffset, true);
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if isInterpolated('get') == false

        isInterpolated('set', true);

        setImageInterpolation(true);
    end

    progressBar(5/13, 'Resampling data series, please wait...');

    [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);
    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

    aResampledPTImage = aResampledPTImageTemp;

    clear aPTImageTemp;
    clear aResampledPTImageTemp;

    progressBar(6/13, 'Resampling MIP, please wait...');

    refMip = mipBuffer('get', [], dCTSerieOffset);
    aMip   = mipBuffer('get', [], dPTSerieOffset);

    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

    mipBuffer('set', aMip, dPTSerieOffset);

    setQuantification(dPTSerieOffset);

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    progressBar(7/13, 'Computing mask, please wait...');

    aBWMask = aResampledPTImage;

    dMin = min(aBWMask, [], 'all');

    if isempty(gbLymphNodesSegmentation) && ...
       isempty(gbBoneSegmentation)

    %     dThreshold = max(aResampledPTImage, [], 'all')*dBoundaryPercent;
        dThreshold = (4.44/gdNormalLiverMean)*(gdNormalLiverMean+gdNormalLiverSTD);

        if dThreshold < 3

            dThreshold = 3;
        end

        aBWMask(aBWMask*dSUVScale<dThreshold)=dMin;

        aBWMask = imbinarize(aBWMask);
    end

    progressBar(8/13, 'Computing CT map, please wait...');

    BWCT = aCTImage >= dBoneMaskThreshold;   % Logical mask creation
    BWCT = imfill(single(BWCT), 4, 'holes'); % Fill holes in the binary mask

    if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view

        BWCT = resample3DImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');

        BWCT = imbinarize(BWCT);

        if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view
            BWCT = resizeMaskToImageSize(BWCT, aResampledPTImage);
        end
    else
        BWCT = imbinarize(BWCT);
    end

    if bExcludeOrgansFromSegmentation == true && ...
       gbBypassOrgansSegmentation == false

        % Get DICOM directory directory

        [sFilePath, ~, ~] = fileparts(char(atInput(dCTSerieOffset).asFilesList{1}));

        % Create an empty directory

        sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sNiiTmpDir), 'dir')
            rmdir(char(sNiiTmpDir), 's');
        end
        mkdir(char(sNiiTmpDir));

        % Convert dicom to .nii

        progressBar(9/13, 'Converting DICOM to NII, please wait...');

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

            progressBar(10/13, 'Machine learning in progress, this might take several minutes, please be patient.');

            sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
            if exist(char(sSegmentationFolderName), 'dir')
                rmdir(char(sSegmentationFolderName), 's');
            end
            mkdir(char(sSegmentationFolderName));

            if ispc % Windows

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);

                [bStatus, sCmdout] = system(sCommandLine);

                if bStatus
                    progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                    errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
                else % Process succeed

                    progressBar(10/13, 'Importing exclusion masks, please wait...');

                    aExcludeMask = getPSMAExcludeMask(tGa68, sSegmentationFolderName, zeros(size(aCTImage)));
                    aExcludeMask = imdilate(aExcludeMask, strel('sphere', bOrganMargins)); % Increse mask by 2 pixels

                    if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view

                         aExcludeMask = resample3DImage(aExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                         aExcludeMask = imbinarize(aExcludeMask);

                        if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view
                            aExcludeMask = resizeMaskToImageSize(aExcludeMask, aResampledPTImage);
                        end
                    else
                        aExcludeMask = imbinarize(aExcludeMask);
                    end

                    aBWMask(aExcludeMask) = dMin;

                    clear aExcludeMask;

                    if exist(char(sNiiTmpDir), 'dir')
                        rmdir(char(sNiiTmpDir), 's');
                    end

                    if exist(char(sSegmentationFolderName), 'dir')
                        rmdir(char(sSegmentationFolderName), 's');
                    end
                end
            elseif isunix % Linux is not yet supported

                progressBar( 1, 'Error: Machine Learning under Linux is not supported');
                errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

            else % Mac is not yet supported

                progressBar( 1, 'Error: Machine Learning under Mac is not supported');
                errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
            end
        end

    end

    progressBar(12/13, 'Generating contours, please wait...');

    imMask = aResampledPTImage;
%     imMask(aBWMask == 0) = dMin;

    setSeriesCallback();

    if isempty(gbLymphNodesSegmentation) && ...
       isempty(gbBoneSegmentation)

        sFormula = '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Lymph Nodes & Bone SUV 3, CT Bone Map';
        maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, 0, false, 0, true, sFormula, BWCT, dSmalestVoiValue,  gdNormalLiverMean, gdNormalLiverSTD);
    else

        if gbLymphNodesSegmentation == true && ... % Lymph Nodes and Bone
           gbBoneSegmentation == true

            aBWMask(aBWMask*dSUVScale<gdLymphNodesSUVThresholdValue)=dMin;
            aBWMask = imbinarize(aBWMask);

            sFormula = 'Lymph Nodes & Bone SUV, CT Bone Map';
            maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdLymphNodesSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue, [],[],[], gbBoneSegmentation);
        else
            if gbLymphNodesSegmentation== true % Lymph Nodes

                aBWMask(aBWMask*dSUVScale<gdLymphNodesSUVThresholdValue)=dMin;

                aBWMask(BWCT==1) = dMin;
                aBWMask = imbinarize(aBWMask);

                sFormula = 'Lymph Nodes';
                maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdLymphNodesSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue);
            else % Bone
                aBWMask(aBWMask*dSUVScale<gdBoneSUVThresholdValue)=dMin;

                aBWMask(BWCT==0) = dMin;
                aBWMask = imbinarize(aBWMask);

                sFormula = 'Bone';
                maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdBoneSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue);
            end
        end
    end

    clear aResampledPTImage;
    clear aBWMask;
    clear refMip;
    clear aMip;
    clear BWCT;
    clear imMask;

    setVoiRoiSegPopup();

    % Set TCS Axes intensity

    dMin = 0/dSUVScale;
    dMax = 7/dSUVScale;

    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    setWindowMinMax(dMax, dMin);

    dMin = 0/dSUVScale;
    dMax = 7/dSUVScale;

    % Set MIP Axe intensity

    set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);

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

    [dMax, dMin] = computeWindowLevel(500, 50);

    fusionWindowLevel('set', 'max', dMax);
    fusionWindowLevel('set', 'min' ,dMin);

    setFusionWindowMinMax(dMax, dMin);

    % Triangulate og 1st VOI

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


    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setSegmentationPSMA()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function PSMAThresholdValuesDialog()

        DLG_PSMA_MEAN_SD_X = 380;
        DLG_PSMA_MEAN_SD_Y = 215;

        if viewerUIFigure('get') == true

            dlgPSMASUVThreshold = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_PSMA_MEAN_SD_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_PSMA_MEAN_SD_Y/2) ...
                                DLG_PSMA_MEAN_SD_X ...
                                DLG_PSMA_MEAN_SD_Y ...
                                ],...
                       'Resize', 'off', ...
                       'Color', viewerBackgroundColor('get'),...
                       'WindowStyle', 'modal', ...
                       'Name' , 'PSMA Segmentation Threshold'...
                       );
        else
            dlgPSMASUVThreshold = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_PSMA_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_PSMA_MEAN_SD_Y/2) ...
                                    DLG_PSMA_MEAN_SD_X ...
                                    DLG_PSMA_MEAN_SD_Y ...
                                    ],...
                       'MenuBar', 'none',...
                       'Resize', 'off', ...
                       'NumberTitle','off',...
                       'MenuBar', 'none',...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'PSMA Segmentation SUV Threshold',...
                       'Toolbar','none'...
                       );
        end

        setObjectIcon(dlgPSMASUVThreshold);

        % Lymph Nodes Segmentation

        chkLymphNodesSegmentation = ...
            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , PSMALymphNodesSegmentation('get'),...
                      'position', [20 165 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @chkLymphNodesSegmentationCallback...
                      );

            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Lymph Nodes Segmentation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'ButtonDownFcn'  , @chkLymphNodesSegmentationCallback, ...
                      'position', [40 165 250 20]...
                      );

       if get(chkLymphNodesSegmentation, 'Value') == true
           sLymphNodesEnable = 'on';
       else
           sLymphNodesEnable = 'off';
       end

            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Lymph Nodes SUV Threshold Value',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [40 140 245 20]...
                      );

        edtPSMALymphNodesSUVThresholdValue = ...
            uicontrol(dlgPSMASUVThreshold, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 140 75 20], ...
                      'String'  , num2str(PSMALymphNodesSUVThresholdValue('get')), ...
                      'Enable'  , sLymphNodesEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtPSMALymphNodesSUVThresholdValueCallback ...
                      );

        % Bone Segmentation

        chkBoneSegmentation = ...
            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , PSMABoneSegmentation('get'),...
                      'position', [20 90 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @chkBoneSegmentationCallback...
                      );

            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Bone Segmentation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'ButtonDownFcn'  , @chkBoneSegmentationCallback, ...
                      'position', [40 90 250 20]...
                      );

       if get(chkBoneSegmentation, 'Value') == true
           sBoneEnable = 'on';
       else
           sBoneEnable = 'off';
       end
            uicontrol(dlgPSMASUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Bone SUV Threshold Value',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [40 65 245 20]...
                      );

        edtPSMABoneSUVThresholdValue = ...
            uicontrol(dlgPSMASUVThreshold, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(PSMABoneSUVThresholdValue('get')), ...
                      'Enable'  , sBoneEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtPSMABoneSUVThresholdValueCallback ...
                      );

         % Cancel or Proceed

         uicontrol(dlgPSMASUVThreshold,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'Callback', @cancelPSMASUVThreshold...
                   );

         uicontrol(dlgPSMASUVThreshold,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedPSMASUVThreshold...
                  );

        waitfor(dlgPSMASUVThreshold);

        function chkLymphNodesSegmentationCallback(hObject, ~)

            bObjectValue = get(chkLymphNodesSegmentation, 'Value');

            if strcmpi(get(hObject, 'Style'), 'text')

                set(chkLymphNodesSegmentation, 'Value', ~bObjectValue);
            end

            bObjectValue = get(chkLymphNodesSegmentation, 'Value');

            if bObjectValue == true

                set(edtPSMALymphNodesSUVThresholdValue, 'Enable', 'On');
            else
                set(edtPSMALymphNodesSUVThresholdValue, 'Enable', 'Off');
            end

            PSMALymphNodesSegmentation('set', bObjectValue);

        end

        function edtPSMALymphNodesSUVThresholdValueCallback(~, ~)

            dSUVValue = str2double(get(edtPSMALymphNodesSUVThresholdValue, 'String'));

            if dSUVValue < 0

                set(edtPSMALymphNodesSUVThresholdValue, 'String', num2str(1));
            end

            PSMALymphNodesSUVThresholdValue('set', dSUVValue);
        end

        function chkBoneSegmentationCallback(hObject, ~)

            bObjectValue = get(chkBoneSegmentation, 'Value');

            if strcmpi(get(hObject, 'Style'), 'text')

                set(chkBoneSegmentation, 'Value', ~bObjectValue);
            end

            bObjectValue = get(chkBoneSegmentation, 'Value');

            if bObjectValue == true

                set(edtPSMABoneSUVThresholdValue, 'Enable', 'On');
            else
                set(edtPSMABoneSUVThresholdValue, 'Enable', 'Off');
            end

            PSMABoneSegmentation('set', bObjectValue);

        end

        function edtPSMABoneSUVThresholdValueCallback(~, ~)

            dSUVValue = str2double(get(edtPSMABoneSUVThresholdValue, 'String'));

            if dSUVValue < 0

                set(edtPSMABoneSUVThresholdValue, 'String', num2str(1));
            end

            PSMABoneSUVThresholdValue('set', dSUVValue);
        end

        function proceedPSMASUVThreshold(~, ~)

            gbLymphNodesSegmentation = get(chkLymphNodesSegmentation, 'Value');
            gbBoneSegmentation       = get(chkBoneSegmentation, 'Value');

            gdLymphNodesSUVThresholdValue = str2double(get(edtPSMALymphNodesSUVThresholdValue, 'String'));
            gdBoneSUVThresholdValue       = str2double(get(edtPSMABoneSUVThresholdValue, 'String'));

            delete(dlgPSMASUVThreshold);

            gbProceedWithSegmentation = true;
        end

        function cancelPSMASUVThreshold(~, ~)

            delete(dlgPSMASUVThreshold);
            gbProceedWithSegmentation = false;
        end
    end
end
