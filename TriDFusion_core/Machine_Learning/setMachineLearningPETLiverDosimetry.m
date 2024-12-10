function setMachineLearningPETLiverDosimetry(sSegmentatorScript, bResampleSeries)
%function setMachineLearningPETLiverDosimetry(sSegmentatorScript, bResampleSeries)
%Run machine learning PET Y90 Dosimetry.
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

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)
        progressBar(1, 'Error: 3D Lung Liver Ratio require a CT and PT image!');
        errordlg('3D Lung Liver Ratio require a CT and PT image!', 'Modality Validation');
        return;
    end

    resetSeries(dPTSerieOffset, true);

    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
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

    try

    roiFaceAlphaValue('set', 0.1);
    set(uiSliderRoisFaceAlphaRoiPanelObject('get'), 'Value', roiFaceAlphaValue('get'));

    pixelEdge('set', true);

    % Set contour panel checkbox
    set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));

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

    progressBar(1/7, 'DICOM to NII conversion, please wait.');

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

    progressBar(2/7, 'Applying Y90 dose kernel, please wait.');

    setDoseKernel('Local Deposition', 1, 'SoftTissue', 'Y90', getKernelDefaultCutoffValue('Y90'), 'Linear', false, dCTSerieOffset, true);

    dDoseSerieOffset = get(uiSeriesPtr('get'), 'Value');


    if isempty(sNiiFullFileName)

        progressBar(1, 'Error: nii file not found!');
        errordlg('nii file not found!!', '.nii file Validation');
    else
        progressBar(3/7, 'Segmentation in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            end

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed


                progressBar(4/7, 'Importing Liver mask, please wait.');

                % Liver

                aColor=[1 0.41 0.16]; % Orange

                sNiiFileName = 'liver.nii.gz';

                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);

                if exist(sNiiFileName, 'file')

                    % Generate Liver

                    nii = nii_tool('load', sNiiFileName);

                    machineLearning3DMask('set', 'liver', imrotate3(nii.img, 90, [0 0 1], 'nearest'), aColor, computeMaskVolume(nii.img, atCTMetaData));

                    aMask = transformNiiMask(nii.img, atCTMetaData, aPTImage, atPTMetaData);

                    maskToVoi(aMask, 'Liver', 'Liver', aColor, 'axial', dDoseSerieOffset, pixelEdge('get'));

                    % Import all other contours

                %    atRoiInput = roiTemplate('get', dCTSerieOffset);
                    atVoiInput = voiTemplate('get', dCTSerieOffset);

                    if ~isempty(atVoiInput)

                    %    aCTImage = dicomBuffer('get', [], dCTSerieOffset);

                        for jj=1:numel(atVoiInput)

                            if ~contains(atVoiInput{jj}.Label, 'Liver')

                                copyRoiVoiToSerie(dCTSerieOffset, dDoseSerieOffset, atVoiInput{jj}, false);

                            end
                        end

                        clear aCTImage;
                    end

                end

                if bResampleSeries == true

                    progressBar(5/7, 'Resamplig series, please wait.');

                    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
                    if isempty(aCTImage)
                        aInputBuffer = inputBuffer('get');
                        aCTImage = aInputBuffer{dCTSerieOffset};

                        clear aInputBuffer;
                    end

                    aDoseImage = dicomBuffer('get', [], dDoseSerieOffset);
                    atDoseMetaData = dicomMetaData('get', [], dDoseSerieOffset);

                    [aResampledDoseImage, atResampledDoseMeta] = resampleImage(aDoseImage, atDoseMetaData, aCTImage, atCTMetaData, 'Nearest', false, false);

                    dicomMetaData('set', atResampledDoseMeta, dDoseSerieOffset);
                    dicomBuffer  ('set', aResampledDoseImage, dDoseSerieOffset);

                    % Resample NM to CT dimension
                    refMip = mipBuffer('get', [], dCTSerieOffset);
                    aMip   = mipBuffer('get', [], dDoseSerieOffset);

                    aMip = resampleMip(aMip, atDoseMetaData, refMip, atCTMetaData, 'Nearest', false);

                    mipBuffer('set', aMip, dDoseSerieOffset);

                    atRoi = roiTemplate('get', dDoseSerieOffset);

                    atResampledRoi = resampleROIs(aDoseImage, atDoseMetaData, aResampledDoseImage, atResampledDoseMeta, atRoi, true);

                    roiTemplate('set', dDoseSerieOffset, atResampledRoi);

                    setQuantification(dDoseSerieOffset);

                    resampleAxes(aResampledDoseImage, atResampledDoseMeta);

                    setImagesAspectRatio();

                    refreshImages();

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dDoseSerieOffset), dicomBuffer('get', [], dDoseSerieOffset), mipAngle('get'));

                    drawnow;

                    % Increase image intensity

                    dMax = max(aResampledDoseImage, [], 'all')/5;
                    dMin = min(aResampledDoseImage, [], 'all');

                    windowLevel('set', 'max', dMax);
                    windowLevel('set', 'min' ,dMin);

                    setWindowMinMax(dMax, dMin);

                    % Set fusion

                    if isFusion('get') == false

                        set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

                        setFusionCallback();
                    end

                    % Set CT Window to Soft Tissue

                    [dMax, dMin] = computeWindowLevel(500, 50);

                    fusionWindowLevel('set', 'max', dMax);
                    fusionWindowLevel('set', 'min' ,dMin);

                    setFusionWindowMinMax(dMax, dMin);

                    % Set MIP CT Window to Temporal Bone

                    [dMax, dMin] = computeWindowLevel(1000, 350);

                    if link2DMip('get') == true && isVsplash('get') == false
                        set(axesMipfPtr('get', [], dCTSerieOffset), 'CLim', [dMin dMax]);
                    end

                    sliderCorCallback();
                    sliderSagCallback();
                    sliderTraCallback();

                    % Clear buffer

                    clear aMip;
                    clear refMip;
                    clear aCTImage;
                    clear aDoseImage;
                    clear aResampledDoseImage;

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

%     refreshImages();

    set(uiFusedSeriesPtr('get'), 'Value', dDoseSerieOffset);

    setFusionSeriesCallback();

    setPlotContoursCallback();

    progressBar(6/7, 'Computing Y90 dosimetry, please wait.');

    generatePETLiverDosimetryReportCallback();

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch
        progressBar( 1 , 'Error: setMachineLearningPETLiverDosimetry()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
