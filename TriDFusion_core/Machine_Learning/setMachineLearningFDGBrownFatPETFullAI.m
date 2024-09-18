function setMachineLearningFDGBrownFatPETFullAI(sPredictScript, tBrownFatFullAI)
%function setMachineLearningFDGBrownFatPETFullAI(sPredictScript, tBrownFatFullAI)
%Run FDG brown Fat PET Full AI Segmentation.
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

    if isempty(dPTSerieOffset)
        progressBar(1, 'Error: FDG brown fat full AI segmentation require a PT image!');
        errordlg('FDG brown fat full AI segmentation require a PT image!', 'Modality Validation');
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

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
    end


    % Apply ROI constraint
    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dPTSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dPTSerieOffset);

    aPTImageTemp = aPTImage;
    aLogicalMask = roiConstraintToMask(aPTImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);
    aPTImageTemp(aLogicalMask==0) = 0;  % Set constraint

    resetSeries(dPTSerieOffset, true);


    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;


    % Create an empty directory

    sNrrdTmpDir = sprintf('%stemp_nrrd_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end
    mkdir(char(sNrrdTmpDir));

    % Convert dicom to .nii

    progressBar(1/10, 'DICOM to NRRD conversion, please wait.');

    sNrrdImagesName = sprintf('%sCase01_0000.nrrd', sNrrdTmpDir);

    if tBrownFatFullAI.options.SUVScaled == true

        dSUVconv = computeSUV(atPTMetaData, 'LBM');

        if dSUVconv == 0
            dSUVconv = computeSUV(atPTMetaData, 'BW');
        end

        if dSUVconv == 0
            dSUVconv = 1;
        end

        if tBrownFatFullAI.options.SUVNormalization == true
            if dSUVconv ~= 1
                dSUVconv = 1+dSUVconv;
            end
        end

        series2nrrd(dPTSerieOffset, sNrrdImagesName, dSUVconv);
    else
        series2nrrd(dPTSerieOffset, sNrrdImagesName, 1);
    end

    sNrrdFullFileName = '';

    f = java.io.File(char(sNrrdTmpDir)); % Get .nii file name
    dinfo = f.listFiles();
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName()), '.nrrd')
                sNrrdFullFileName = sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName());
                break;
            end
        end
    end

    if isempty(sNrrdFullFileName)

        progressBar(1, 'Error: nrrd file mot found!');
        errordlg('nrrd file mot found!!', '.nrrd file Validation');
    else

        progressBar(2/10, 'Machine learning in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows
% %            if fastMachineLearningDialog('get') == true
% %                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast', sPredictScript, sNiiFullFileName, sSegmentationFolderName);
% %            else
%                 if tBrownFatFullAI.options.SUVScaled == true
%                     if tBrownFatFullAI.options.SUVNormalization == true
%                         sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 100 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
%                     else
%                         sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 098 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
%                     end
%                 else
%                     sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 096 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
%                 end
% %            end

                if tBrownFatFullAI.options.CELossTrainer == true

                    if tBrownFatFullAI.options.SUVScaled == true
                        if tBrownFatFullAI.options.SUVNormalization == true
                            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 100 -c 3d_fullres --save_probabilities -tr nnUNetTrainerDiceCELoss_noSmooth', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                        else
                            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 098 -c 3d_fullres --save_probabilities -tr nnUNetTrainerDiceCELoss_noSmooth', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                        end
                    else
                        sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 96 -c 3d_fullres --save_probabilities -tr nnUNetTrainerDiceCELoss_noSmooth', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                    end
                else
                    if tBrownFatFullAI.options.SUVScaled == true
                        if tBrownFatFullAI.options.SUVNormalization == true
                            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 091 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                        else
                            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 093 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                        end
                    else
                        sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 095 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
                    end
                end

%                          sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 095 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed


                progressBar(3/10, 'Importing prediction, please wait.');

                [aMask, ~] = nrrdread( sprintf('%sCase01.nrrd',sSegmentationFolderName));

                aMask = aMask(:,:,end:-1:1);

                bCELossTrainer        = tBrownFatFullAI.options.CELossTrainer;
                bClassifySegmentation = tBrownFatFullAI.options.classifySegmentation;
                bSmoothMask           = tBrownFatFullAI.options.smoothMask;
                dSmallestValue        = tBrownFatFullAI.options.smallestVoiValue;
                bPixelEdge            = tBrownFatFullAI.options.pixelEdge;

                progressBar(4/10, 'Segmenting prediction mask, please wait.');

                if bCELossTrainer == false

                    maskAddVoiByTypeToSeries(aPTImageTemp, aMask, atPTMetaData, dPTSerieOffset, dSmallestValue, bPixelEdge, bSmoothMask, false, 1);
                else

                    maskAddVoiByTypeToSeries(aPTImageTemp, aMask, atPTMetaData, dPTSerieOffset, dSmallestValue, bPixelEdge, bSmoothMask, bClassifySegmentation, 1);
                end

                clear aPTImageTemp;

                if exist(char(sSegmentationFolderName), 'dir')

                    rmdir(char(sSegmentationFolderName), 's');
                end

                if ~isempty(aCTImage)

                    progressBar(5/10, 'Resampling series, please wait.');

                    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

                    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

                    progressBar(6/10, 'Resampling mip, please wait.');

                    refMip = mipBuffer('get', [], dCTSerieOffset);
                    aMip   = mipBuffer('get', [], dPTSerieOffset);

                    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

                    mipBuffer('set', aMip, dPTSerieOffset);

                    setQuantification(dPTSerieOffset);

                    progressBar(7/10, 'Resampling contours, please wait.');


                    atRoi = roiTemplate('get', dPTSerieOffset);

                    if ~isempty(atRoi)

                        atResampledRoi = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true);

                        roiTemplate('set', dPTSerieOffset, atResampledRoi);
                   end

                    progressBar(8/10, 'Resampling axes, please wait.');

                    resampleAxes(aResampledPTImage, atResampledPTMetaData);

                    setImagesAspectRatio();

                    if bCELossTrainer == false && ...
                       bClassifySegmentation == true && ...
                       ~isempty(atRoi)

                        progressBar(9/10, 'Machine learning classification in progress, this might take several minutes, please be patient.');

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
                                    errordlg(sprintf('An error occur during machine learning classification: %s', sCmdout), 'Segmentation Error');
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
    set(btnLinkMipPtr('get'), 'FontWeight', 'normal');

    % Set fusion
    if ~isempty(aCTImage)

        progressBar(9/10, 'Processing fusion, please wait.');

        if isFusion('get') == false

            set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

            setFusionCallback();
        end
    end

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

    if exist(char(sNrrdTmpDir), 'dir')

        rmdir(char(sNrrdTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setMachineLearningFDGBrownFatFullAI()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
