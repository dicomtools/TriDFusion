function setMachineLearningFDGBrownFatFullAI(sPredictScript, sDatasetId, tBrownFatFullAI, bDisplayError, bLogProgress, sLogFile)
%function setMachineLearningFDGBrownFatFullAI(sPredictScript, sDatasetId, tBrownFatFullAI, bDisplayError, bLogProgress, sLogFile)
%Run FDG brown Fat Full AI Segmentation.
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

    atInput = inputTemplate('get');

    % Modality validation

    % [dCTSerieOffset, dPTSerieOffset] = findDicomMatchingSeries(atInput, 'ct', 'pt');

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

    if isempty(dPTSerieOffset) || isempty(dCTSerieOffset)

        progressBar(1, 'Error: FDG brown fat full AI segmentation require a PT and CT image!');

        if bDisplayError == true

            errordlg('FDG brown fat full AI segmentation require a PT and CT image!', 'Modality Validation');
        end
        return;
    end

    aCTImage = [];

    if ~isempty(dCTSerieOffset)

        atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

        if isempty(atCTMetaData)
            atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
        end

        aCTImage = dicomBuffer('get', [], dCTSerieOffset);
        if isempty(aCTImage)
            aInputBuffer = inputBuffer('get');
            aCTImage = aInputBuffer{dCTSerieOffset};
        end

    end

    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
    end


    if isempty(atPTMetaData)

        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    % St Log field

    tPTEntry = parseDicomInfo(atPTMetaData{1});

    tLogField.PatientName        = tPTEntry.PatientName;
    tLogField.PatientID          = tPTEntry.PatientID;
    tLogField.Accession          = tPTEntry.Accession;
    tLogField.StudyInstanceUID   = tPTEntry.StudyInstanceUID;
    tLogField.SeriesInstanceUID1 = tPTEntry.SeriesInstanceUID;
    tLogField.SeriesInstanceUID2 = atCTMetaData{1}.SeriesInstanceUID;

    resetSeries(dPTSerieOffset, true);

    try

    if isInterpolated('get') == false

        isInterpolated('set', true);

        setImageInterpolation(true);
    end

%     set(fiMainWindowPtr('get'), 'Pointer', 'watch');
%     drawnow;


    % PT

    % Resample series

    progressBar(1/10, 'Resampling data series, please wait...');

    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

    progressBar(2/10, 'Resampling MIP, please wait...');

    refMip = mipBuffer('get', [], dCTSerieOffset);
    aMip   = mipBuffer('get', [], dPTSerieOffset);

    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

    mipBuffer('set', aMip, dPTSerieOffset);

    setQuantification(dPTSerieOffset);

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset

        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);
    end

    setSeriesCallback();

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    % Create an empty directory

    sNrrdTmpDir = sprintf('%stemp_nrrd_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end
    mkdir(char(sNrrdTmpDir));

    % Convert dicom to .nii

    progressBar(3/10, 'DICOM to NRRD conversion, please wait...');

    origin = atResampledPTMetaData{end}.ImagePositionPatient;

    pixelspacing = zeros(3,1);

    pixelspacing(1) = atResampledPTMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atResampledPTMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atResampledPTMetaData);

    sNrrdPTImagesName = sprintf('%sCase01_0000.nrrd', sNrrdTmpDir);

    nrrdWriter(sNrrdPTImagesName, squeeze(aResampledPTImage(:,:,end:-1:1)), pixelspacing, origin, 'raw'); % Write .nrrd images

    sNrrdPTFullFileName = '';

    f = java.io.File(char(sNrrdTmpDir)); % Get .nii file name
    dinfo = f.listFiles();
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName()), 'Case01_0000.nrrd')
                sNrrdPTFullFileName = sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName());
                break;
            end
        end
    end

    % CT

%     [aResampledCTImage, ~] = resampleImage(aCTImage, atCTMetaData, aPTImage, atPTMetaData, 'Linear', true, false);

    sNrrdCTFileName = sprintf('%sCase01_0001.nrrd', sNrrdTmpDir);

    nrrdWriter(sNrrdCTFileName, squeeze(aCTImage(:,:,end:-1:1)), pixelspacing, origin, 'raw'); % Write .nrrd images

    sNrrdCTFullFileName = '';

    f = java.io.File(char(sNrrdTmpDir)); % Get .nii file name
    dinfo = f.listFiles();
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName()), 'Case01_0001.nrrd')
                sNrrdCTFullFileName = sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName());
                break;
            end
        end
    end

    if isempty(sNrrdPTFullFileName) || isempty(sNrrdCTFullFileName)

        progressBar(1, 'Error: nrrd files not found!');

        if bDisplayError == true

            errordlg('nrrd files not found!!', '.nrrd file Validation');
        end

        if bLogProgress == true

            logWorkflowProgress(tLogField, sLogFile, 2, 'nrrd files not found!!');
        end
    else

        progressBar(4/10, 'Machine learning in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')

            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

            if tBrownFatFullAI.options.fastSegmentation == true

                sFastSegmentation = '--disable_tta -step_size 0.5';
            else
                sFastSegmentation = '';
            end

            if tBrownFatFullAI.options.CELossTrainer == true

                sCommandLine = sprintf('cmd.exe /c python.exe %s -p nnUNetPlans -f 0 1 2 3 4 -i %s -o %s -d %s -c 3d_fullres %s --save_probabilities -tr nnUNetTrainerDiceCELoss_noSmooth', sPredictScript, sNrrdTmpDir, sSegmentationFolderName, sDatasetId, sFastSegmentation);
            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -p nnUNetPlans -f 0 1 2 3 4 -i %s -o %s -d %s -c 3d_fullres %s --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName, sDatasetId, sFastSegmentation);
            end

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus

                progressBar( 1, 'Error: An error occur during machine learning segmentation!');

                if bDisplayError == true

                    errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
                end

                if bLogProgress == true

                    logWorkflowProgress(tLogField, sLogFile, 2, sCmdout);
                end


            else % Process succeed
                progressBar(5/10, 'Importing prediction, please wait.');

                [aMask, ~] = nrrdread( sprintf('%sCase01.nrrd', sSegmentationFolderName));

                aMask = aMask(:,:,end:-1:1);

                bClassifySegmentation = tBrownFatFullAI.options.classifySegmentation;
                bCELossTrainer        = tBrownFatFullAI.options.CELossTrainer;
                bSmoothMask           = tBrownFatFullAI.options.smoothMask;
                dSmallestValue        = tBrownFatFullAI.options.smallestVoiValue;
                bPixelEdge            = tBrownFatFullAI.options.pixelEdge;

                progressBar(6/10, 'Segmenting prediction mask, please wait.');

                maskAddVoiByTypeToSeries(aResampledPTImage, aMask, atResampledPTMetaData, dPTSerieOffset, dSmallestValue, bPixelEdge, bSmoothMask, bClassifySegmentation, 1);

                if exist(char(sSegmentationFolderName), 'dir')

                    rmdir(char(sSegmentationFolderName), 's');
                end

                if bCELossTrainer == false && ...
                   bClassifySegmentation == true

                    progressBar(6/10, 'Machine learning classification in progress, this might take several minutes, please be patient.');

                    sTotalSegmentorFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
                    if exist(char(sTotalSegmentorFolderName), 'dir')
                        rmdir(char(sTotalSegmentorFolderName), 's');
                    end
                    mkdir(char(sTotalSegmentorFolderName));

                    if ispc % Windows

                        % Get DICOM directory directory

                        [sFilePath, ~, ~] = fileparts(char(atInput(dCTSerieOffset).asFilesList{1}));

                        % Create an empty directory

                        sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
                        if exist(char(sNiiTmpDir), 'dir')
                            rmdir(char(sNiiTmpDir), 's');
                        end
                        mkdir(char(sNiiTmpDir));

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

                        [sSegmentatorScript, ~] = validateSegmentatorInstallation();

                        if ~isempty(sSegmentatorScript)

                            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sTotalSegmentorFolderName);

                            [bStatus, sCmdout] = system(sCommandLine);

                            if bStatus

                                progressBar( 1, 'Error: An error occur during machine learning classification!');

                                if bDisplayError == true

                                    errordlg(sprintf('An error occur during machine learning classification: %s', sCmdout), 'Segmentation Error');
                                end

                                if bLogProgress == true

                                    logWorkflowProgress(tLogField, sLogFile, 2, sCmdout);
                                end

                            else % Process succeed

                                aBrownFatMask = getBrownFatTotalSegmentorAnnotationMask(sTotalSegmentorFolderName, zeros(size(aCTImage)));

                                atVoiInput = voiTemplate('get', dPTSerieOffset);
                                atRoiInput = roiTemplate('get', dPTSerieOffset);

                                if ~isequal(size(aBrownFatMask), size(aResampledPTImage)) % Verify if both images are in the same field of view

                                     aBrownFatMask = resample3DImage(aBrownFatMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');

                                    if ~isequal(size(aBrownFatMask), size(aResampledPTImage)) % Verify if both images are in the same field of view
                                        aBrownFatMask = resizeMaskToImageSize(aBrownFatMask, aResampledPTImage);
                                    end

                                end

                                [atVoiInput, atRoiInput] = setBrownFatVoiTypeMask(aBrownFatMask, atVoiInput, atRoiInput);

                                voiTemplate('set', dPTSerieOffset, atVoiInput);
                                roiTemplate('set', dPTSerieOffset, atRoiInput);

                                clear aBrownFatMask;
                            end

                        end

                        if exist(char(sNiiTmpDir), 'dir')

                            rmdir(char(sNiiTmpDir), 's');
                        end

                    end

                    if exist(char(sTotalSegmentorFolderName), 'dir')

                        rmdir(char(sTotalSegmentorFolderName), 's');
                    end
                end
            end

        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');

            if bDisplayError == true

                errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');
            end

            if bLogProgress == true

                logWorkflowProgress(tLogField, sLogFile, 2, 'Machine Learning under Linux is not supported');
            end

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');

            if bDisplayError == true

                errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
            end

            if bLogProgress == true

                logWorkflowProgress(tLogField, sLogFile, 2, 'Machine Learning under Mac is not supported');
            end
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

    % Set intensity

    tQuant = atInput(dPTSerieOffset).tQuant;

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;

        dSeriesMin = 0/dSUVScale;
        dSeriesMax = 5/dSUVScale;
    else
        dSeriesMin = min(aResampledPTImage, [], 'all');
        dSeriesMax = max(aResampledPTImage, [], 'all');
    end

    windowLevel('set', 'max', dSeriesMax);
    windowLevel('set', 'min', dSeriesMin);

    setWindowMinMax(dSeriesMax, dSeriesMin);

    % Set fusion
%     if ~isempty(aCTImage)

        progressBar(7/10, 'Processing fusion, please wait.');

        if isFusion('get') == false

            set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

            sliderAlphaValue('set', 0.65);

            setFusionCallback();

            % Hot iron enhanced

            colorMapOffset('set', 20);

            refreshColorMap();

        end
%     end

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

%     refreshImages();
%
%     plotRotatedRoiOnMip(axesMipPtr('get', [], dPTSerieOffset), dicomBuffer('get', [], dPTSerieOffset), mipAngle('get'));

    clear aPTImage;
    clear aCTImage;
    clear aResampledPTImage;

    % Delete .nii folder

    if exist(char(sNrrdTmpDir), 'dir')

        rmdir(char(sNrrdTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setMachineLearningFDGBrownFatFullAI()' );

        if bLogProgress == true

            logWorkflowProgress(tLogField, sLogFile, 2, 'An error occur');
        end

    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
