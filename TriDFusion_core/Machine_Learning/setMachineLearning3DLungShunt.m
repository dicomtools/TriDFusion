function setMachineLearning3DLungShunt(sSegmentatorScript, sSegmentatorCombineMasks, bPixelEdge, bResampleSeries)
%function setMachineLearning3DLungShunt(sSegmentatorScript, sSegmentatorCombineMasks, bPixelEdge, bResampleSeries)
%Run machine learning 3D Lung Liver Ratio.
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

    dNMSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')
            dNMSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dNMSerieOffset)
        progressBar(1, 'Error: 3D Lung Liver Ratio require a CT and NM image!');
        errordlg('3D Lung Liver Ratio require a CT and NM image!', 'Modality Validation');
        return;
    end

    resetSeries(dNMSerieOffset, true);

    atNMMetaData = dicomMetaData('get', [], dNMSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aNMImage = dicomBuffer('get', [], dNMSerieOffset);
    if isempty(aNMImage)
        aInputBuffer = inputBuffer('get');
        aNMImage = aInputBuffer{dNMSerieOffset};

        clear aInputBuffer;
    end

    if isempty(atNMMetaData)
        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
    end

    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    try

    roiFaceAlphaValue('set', 0.1);
    set(uiSliderRoisFaceAlphaRoiPanelObject('get'), 'Value', roiFaceAlphaValue('get'));

    pixelEdge('set', bPixelEdge);

    % Set contour panel checkbox

    set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

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

    if isempty(sNiiFullFileName)

        progressBar(1, 'Error: nii file mot found!');
        errordlg('nii file mot found!!', '.nii file Validation');
    else
        progressBar(2/7, 'Segmentation in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            else

%                sRoiSubset = 'liver lung_lower_lobe_left lung_lower_lobe_right lung_middle_lobe_right lung_upper_lobe_left lung_upper_lobe_right';
%                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --roi_subset %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName, sRoiSubset);
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);
%            end

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed

                progressBar(3/7, 'Importing Lungs mask, please wait.');

                % Lung

                aColor= [1 0.5 1]; % Pink

                sNiiFileName = 'combined_lungs.nii.gz';

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s%s -m lung', sSegmentatorCombineMasks, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);

                [bStatus, sCmdout] = system(sCommandLine);

                if bStatus
                    progressBar( 1, 'Error: An error occur during lungs combine mask!');
                    errordlg(sprintf('An error occur during lungs combine mask: %s', sCmdout), 'Segmentation Error');
                else % Process succeed


                    sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);

                    if exist(sNiiFileName, 'file')

                        nii = nii_tool('load', sNiiFileName);

                        machineLearning3DMask('set', 'lungs', imrotate3(nii.img, 90, [0 0 1], 'nearest'), aColor, computeMaskVolume(nii.img, atCTMetaData));

                        aMask = transformNiiMask(nii.img, atCTMetaData, aNMImage, atNMMetaData);

                        maskToVoi(aMask, 'Lungs', 'Lung', aColor, 'axial', dNMSerieOffset, pixelEdge('get'));

                        clear aMask;
                   end

                end


                progressBar(4/7, 'Importing Liver mask, please wait.');

                % Liver

                aColor=[1 0.41 0.16]; % Orange

                sNiiFileName = 'liver.nii.gz';

                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);

                if exist(sNiiFileName, 'file')

                    nii = nii_tool('load', sNiiFileName);

                    machineLearning3DMask('set', 'liver', imrotate3(nii.img, 90, [0 0 1], 'nearest'), aColor, computeMaskVolume(nii.img, atCTMetaData));

                    aMask = transformNiiMask(nii.img, atCTMetaData, aNMImage, atNMMetaData);

                    maskToVoi(aMask, 'Liver', 'Liver', aColor, 'axial', dNMSerieOffset, pixelEdge('get'));

                    clear aMask;
                end

                if bResampleSeries == true

                    progressBar(5/7, 'Resamplig series, please wait.');

                    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
                    if isempty(aCTImage)
                        aInputBuffer = inputBuffer('get');
                        aCTImage = aInputBuffer{dCTSerieOffset};

                        clear aInputBuffer;
                    end

                    [aResampledNMImage, atResampledNMMeta] = resampleImage(aNMImage, atNMMetaData, aCTImage, atCTMetaData, 'Linear', false, false);

                    dicomMetaData('set', atResampledNMMeta, dNMSerieOffset);
                    dicomBuffer  ('set', aResampledNMImage, dNMSerieOffset);

                    % Resample NM to CT dimension
                    refMip = mipBuffer('get', [], dCTSerieOffset);
                    aMip   = mipBuffer('get', [], dNMSerieOffset);

                    aMip = resampleMip(aMip, atNMMetaData, refMip, atCTMetaData, 'Linear', false);

                    mipBuffer('set', aMip, dNMSerieOffset);

                    atRoi = roiTemplate('get', dNMSerieOffset);

                    atResampledRoi = resampleROIs(aNMImage, atNMMetaData, aResampledNMImage, atResampledNMMeta, atRoi, true);

                    roiTemplate('set', dNMSerieOffset, atResampledRoi);

                    setQuantification(dNMSerieOffset);

                    resampleAxes(aResampledNMImage, atResampledNMMeta);

                    setImagesAspectRatio();
                    
                    plotRotatedRoiOnMip(axesMipPtr('get', [], dNMSerieOffset), dicomBuffer('get', [], dNMSerieOffset), mipAngle('get'));       

                    refreshImages();

                    drawnow;

                    % Increase image intensity

                    dMax = max(aResampledNMImage, [], 'all')/5;
                    dMin = min(aResampledNMImage, [], 'all');

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
                    clear aResampledNMImage;

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

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();

    progressBar(6/7, 'Computing Lung Shunt, please wait.');

    generate3DLungShuntReport(true);

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    % Clear buffer

    clear aNMImage;

    progressBar(1, 'Ready');

    catch
        progressBar( 1 , 'Error: setMachineLearning3DLungShunt()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
