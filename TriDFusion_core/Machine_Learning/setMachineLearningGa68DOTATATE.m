function setMachineLearningGa68DOTATATE(sSegmentatorScript, tGa68DOTATATE, bUseDefault)
%function setMachineLearningGa68DOTATATE(sSegmentatorScript, tGa68DOTATATE, bUseDefault)
%Run machine learning Ga68 DOTATATE Segmentation.
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

    gbProceedWithSegmentation = false;
    gdNormalLiverMean = [];
    gdNormalLiverSTD = [];

    atInput = inputTemplate('get');

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
        progressBar(1, 'Error: Ga68 DOTATATE segmentation require a CT and PT image!');
        errordlg('Ga68 DOTATATE segmentation require a CT and PT image!', 'Modality Validation');
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

                Ga68DOTATATENormalLiverMeanSDDialog();

                if gbProceedWithSegmentation == false
                    return;
                end
            else
                gdNormalLiverMean = Ga68DOTATATENormalLiverMeanValue('get');
                gdNormalLiverSTD  = Ga68DOTATATENormalLiverSDValue('get');
            end
        end
    else
        if bUseDefault == false

            waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));

            Ga68DOTATATENormalLiverMeanSDDialog();

            if gbProceedWithSegmentation == false
                return;
            end
        else
            gdNormalLiverMean = Ga68DOTATATENormalLiverMeanValue('get');
            gdNormalLiverSTD  = Ga68DOTATATENormalLiverSDValue('get');
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

    progressBar(1/12, 'Converting DICOM to NII, please wait...');

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

        progressBar(2/12, 'Machine learning in progress, this might take several minutes, please be patient.');

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

                progressBar(3/12, 'Importing exclusion masks, please wait...');

                aExcludeMask = getGa68DOTATATEExcludeMask(tGa68DOTATATE, sSegmentationFolderName, zeros(size(aCTImage)));


                progressBar(4/12, 'Importing liver mask, please wait.');

                aLiverMask = getLiverMask(zeros(size(aCTImage)));

                aLiverMask = imdilate(aLiverMask, strel('sphere', 4)); % Increse Liver mask by 3 pixels
                aExcludeMasksLiver = imdilate(aExcludeMask, strel('sphere', 1)); % Increse mask by 1 pixels

                progressBar(5/12, 'Resampling data series, please wait...');

                [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);
                [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

                dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

                aResampledPTImage = aResampledPTImageTemp;

                clear aPTImageTemp;
                clear aResampledPTImageTemp;

                if ~isequal(size(aLiverMask), size(aResampledPTImage)) % Verify if both images are in the same field of view

                     aLiverMask = resample3DImage(aLiverMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aLiverMask = imbinarize(aLiverMask);

                    if ~isequal(size(aLiverMask), size(aResampledPTImage)) % Verify if both images are in the same field of view
                        aLiverMask = resizeMaskToImageSize(aLiverMask, aResampledPTImage);
                    end
                else
                    aLiverMask = imbinarize(aLiverMask);
                end

                if ~isequal(size(aExcludeMasksLiver), size(aResampledPTImage)) % Verify if both images are in the same field of view

                     aExcludeMasksLiver = resample3DImage(aExcludeMasksLiver, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aExcludeMasksLiver = imbinarize(aExcludeMasksLiver);

                    if ~isequal(size(aExcludeMasksLiver), size(aResampledPTImage)) % Verify if both images are in the same field of view
                        aExcludeMasksLiver = resizeMaskToImageSize(aExcludeMasksLiver, aResampledPTImage);
                    end
                else
                    aExcludeMasksLiver = imbinarize(aExcludeMasksLiver);
                end
%
%                 progressBar(6/12, 'Resampling roi, please wait.');
%
%                 atRoi = roiTemplate('get', dPTSerieOffset);
%
%                 atResampledRoi = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true);
%
%                 roiTemplate('set', dPTSerieOffset, atResampledRoi);


                progressBar(7/12, 'Resampling MIP, please wait...');

                refMip = mipBuffer('get', [], dCTSerieOffset);
                aMip   = mipBuffer('get', [], dPTSerieOffset);

                aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

                mipBuffer('set', aMip, dPTSerieOffset);

                setQuantification(dPTSerieOffset);


                progressBar(8/12, 'Computing liver mask, please wait.');

%                dLiverThreshold = (1.5*gdNormalLiverMean) + (2*gdNormalLiverSTD);
                dLiverThreshold = (tGa68DOTATATE.options.normalLiverThresholdMultiplier*gdNormalLiverMean) + (2*gdNormalLiverSTD);
%                dLiverThreshold = (tGa68DOTATATE.options.normalLiverThresholdMultiplier*gdNormalLiverMean);

%                dLiverThreshold = (2*dLiverMean)

                aLiverBWMask = aResampledPTImage;

                dMin = min(aLiverBWMask, [], 'all');

                aLiverBWMask(aLiverBWMask*dSUVScale<dLiverThreshold)=dMin;

                aLiverBWMask(aLiverMask==0)=0;
                aLiverBWMask(aExcludeMasksLiver~=0)=0;


                progressBar(9/12, 'Computing wholebody mask, please wait.');

                dWholebodyThreshold = 3;

                aExcludeMasksWholebody = imdilate(aExcludeMask, strel('sphere', 3)); % Increse mask by 3 pixels

                if ~isequal(size(aExcludeMasksWholebody), size(aResampledPTImage)) % Verify if both images are in the same field of view

                     aExcludeMasksWholebody = resample3DImage(aExcludeMasksWholebody, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aExcludeMasksWholebody = imbinarize(aExcludeMasksWholebody);

                    if ~isequal(size(aExcludeMasksWholebody), size(aResampledPTImage)) % Verify if both images are in the same field of view
                        aExcludeMasksWholebody = resizeMaskToImageSize(aExcludeMasksWholebody, aResampledPTImage);
                    end
                else
                    aExcludeMasksWholebody = imbinarize(aExcludeMasksWholebody);
                end

                aWholebodyBWMask = aResampledPTImage;

                dMin = min(aWholebodyBWMask, [], 'all');


                aWholebodyBWMask(aWholebodyBWMask*dSUVScale<dWholebodyThreshold) = dMin;
%                if gdNormalLiverMean > dWholebodyThreshold
%                    aWholebodyBWMask(aWholebodyBWMask*dSUVScale<dWholebodyThreshold) = dMin;
%                else
%                    aWholebodyBWMask(aWholebodyBWMask*dSUVScale<gdNormalLiverMean) = dMin;
%                end

                aWholebodyBWMask = imbinarize(aWholebodyBWMask);
%                aWholebodyBWMask(aWholebodyBWMask==dMin)=0;
%                aWholebodyBWMask(aWholebodyBWMask~=0)=1;

                aWholebodyBWMask(aExcludeMasksWholebody~=0)=0;
                aWholebodyBWMask(aLiverMask~=0)=0;


                progressBar(10/12, 'Computing bone map, please wait.');

                BWCT = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));
                BWCT = imfill(BWCT, 4, 'holes');
%                BWCT =  imdilate(BWCT, strel('sphere', 1)); % Increse the mask by 1 pixel

                if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view

                     BWCT = resample3DImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     BWCT = imbinarize(BWCT);

                    if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view
                        BWCT = resizeMaskToImageSize(BWCT, aResampledPTImage);
                    end
                else
                    BWCT = imbinarize(BWCT);
                end


                progressBar(11/12, 'Generating contours, please wait...');

                imMask = aResampledPTImage;
                imMask(aWholebodyBWMask == 0) = dMin;

                dSmalestVoiValue = tGa68DOTATATE.options.smalestVoiValue;

                dPixelEdge = tGa68DOTATATE.options.pixelEdge;

                setSeriesCallback();

                sFormula = '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map';

                maskAddVoiToSeries(imMask, aWholebodyBWMask, dPixelEdge, false, dWholebodyThreshold, false, 0, true, sFormula, BWCT, dSmalestVoiValue, gdNormalLiverMean, gdNormalLiverSTD);

                sFormula = 'Liver';

                imMaskLiver = aResampledPTImage;
                imMaskLiver(aLiverBWMask == 0) = dMin;

                maskAddVoiToSeries(imMaskLiver, aLiverBWMask, dPixelEdge, false, dLiverThreshold, false, 0, false, sFormula, BWCT, dSmalestVoiValue);

                clear aExcludeMask;
                clear aExcludeMasksLiver;
                clear aExcludeMasksWholebody;
                clear aLiverMask;
                clear aResampledPTImage;
                clear aWholebodyBWMask;
                clear aLiverBWMask;
                clear refMip;
                clear aMip;
                clear BWCT;
                clear imMask;
                clear imMaskLiver;
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


    % Set TCS Axes intensity

    dMin = 0/dSUVScale;
    dMax = 10/dSUVScale;

%     set(uiSliderWindowPtr('get'), 'value', 0.5);
%     set(uiSliderLevelPtr('get') , 'value', 0.5);

%     set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
%     set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
%     set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);



    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    setWindowMinMax(dMax, dMin);

    dMin = 0/dSUVScale;
    dMax = 20/dSUVScale;

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

%     set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%     set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

    [dMax, dMin] = computeWindowLevel(500, 50);

%     set(axes1fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
%     set(axes2fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
%     set(axes3fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);

    fusionWindowLevel('set', 'max', dMax);
    fusionWindowLevel('set', 'min' ,dMin);

    setFusionWindowMinMax(dMax, dMin);

%     [dLevelMax, dLevelMin] = computeWindowLevel(2500, 415);
%     set(axesMipfPtr('get', [], dOffset), 'CLim', [dLevelMin dLevelMax]);

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

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setMachineLearningGa68DOTATATE()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function aLiverMask = getLiverMask(aLiverMask)

        % Liver

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aLiverMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
        end

        aLiverMask=aLiverMask(:,:,end:-1:1);
    end

    function Ga68DOTATATENormalLiverMeanSDDialog()

        DLG_Ga68DOTATATE_MEAN_SD_X = 380;
        DLG_Ga68DOTATATE_MEAN_SD_Y = 150;

        if viewerUIFigure('get') == true

            dlgGa68DOTATATEmeanSD = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Ga68DOTATATE_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Ga68DOTATATE_MEAN_SD_Y/2) ...
                                    DLG_Ga68DOTATATE_MEAN_SD_X ...
                                    DLG_Ga68DOTATATE_MEAN_SD_Y ...
                                    ],...
                       'Resize', 'off', ...
                       'Color', viewerBackgroundColor('get'),...
                       'WindowStyle', 'modal', ...
                       'Name' , 'Ga68 DOTATATE Segmentation Mean and SD'...
                       );
          else

            dlgGa68DOTATATEmeanSD = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Ga68DOTATATE_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Ga68DOTATATE_MEAN_SD_Y/2) ...
                                    DLG_Ga68DOTATATE_MEAN_SD_X ...
                                    DLG_Ga68DOTATATE_MEAN_SD_Y ...
                                    ],...
                       'MenuBar', 'none',...
                       'Resize', 'off', ...
                       'NumberTitle','off',...
                       'MenuBar', 'none',...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'Ga68 DOTATATE Segmentation Mean and SD',...
                       'Toolbar','none'...
                       );
        end

        setObjectIcon(dlgGa68DOTATATEmeanSD);

        % Normal Liver Mean

            uicontrol(dlgGa68DOTATATEmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Mean',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [20 90 250 20]...
                      );

        edtGa68DOTATATENormalLiverMeanValue = ...
            uicontrol(dlgGa68DOTATATEmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 90 75 20], ...
                      'String'  , num2str(Ga68DOTATATENormalLiverMeanValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtGa68DOTATATENormalLiverMeanValueCallback ...
                      );

        % Normal Liver Standard Deviation

            uicontrol(dlgGa68DOTATATEmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Standard Deviation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [20 65 250 20]...
                      );

        edtGa68DOTATATENormalLiverSDValue = ...
            uicontrol(dlgGa68DOTATATEmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(Ga68DOTATATENormalLiverSDValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtGa68DOTATATENormalLiverSDValueCallback ...
                      );

         % Cancel or Proceed

         uicontrol(dlgGa68DOTATATEmeanSD,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'Callback', @cancelGa68DOTATATEmeanSDCallback...
                   );

         uicontrol(dlgGa68DOTATATEmeanSD,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedGa68DOTATATEmeanSDCallback...
                  );

        waitfor(dlgGa68DOTATATEmeanSD);

        function edtGa68DOTATATENormalLiverMeanValueCallback(~, ~)

            dMeanValue = str2double(get(edtGa68DOTATATENormalLiverMeanValue, 'Value'));

            if dMeanValue < 0
                dMeanValue = 0.1;
                set(edtGa68DOTATATENormalLiverMeanValue, 'Value', num2str(dMeanValue));
            end

            Ga68DOTATATENormalLiverMeanValue('set', dMeanValue);
        end

        function edtGa68DOTATATENormalLiverSDValueCallback(~, ~)

            dSDValue = str2double(get(edtGa68DOTATATENormalLiverSDValue, 'Value'));

            if dSDValue < 0
                dSDValue = 0.1;
                set(edtGa68DOTATATENormalLiverSDValue, 'Value', num2str(dSDValue));
            end

            Ga68DOTATATENormalLiverSDValue('set', dSDValue);
        end

        function proceedGa68DOTATATEmeanSDCallback(~, ~)

            gdNormalLiverMean = str2double(get(edtGa68DOTATATENormalLiverMeanValue, 'String'));
            gdNormalLiverSTD  = str2double(get(edtGa68DOTATATENormalLiverSDValue, 'String'));

            delete(dlgGa68DOTATATEmeanSD);
            gbProceedWithSegmentation = true;
        end

        function cancelGa68DOTATATEmeanSDCallback(~, ~)

            delete(dlgGa68DOTATATEmeanSD);
            gbProceedWithSegmentation = false;
        end
    end

end
