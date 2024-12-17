function setMachineLearningPSMALu177SPECTFullAI(sPredictScript, tPSMALu177SPECTFullAI)
%function setMachineLearningPSMALu177SPECTFullAI(sPredictScript, tPSMALu177SPECTFullAI)
%Run PSMA Lu177 SPECT Full AI Segmentation.
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

    if isempty(dNMSerieOffset)
        progressBar(1, 'Error: PSMA Lu177 full AI segmentation require a NM image!');
        errordlg('PSMA Lu177 full AI segmentation require a NM image!', 'Modality Validation');
        return;
    end

    resetSeries(dNMSerieOffset, true);

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

    atNMMetaData = dicomMetaData('get', [], dNMSerieOffset);

    aNMImage = dicomBuffer('get', [], dNMSerieOffset);
    if isempty(aNMImage)
        aInputBuffer = inputBuffer('get');
        aNMImage = aInputBuffer{dNMSerieOffset};
    end


    if isempty(atNMMetaData)
        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    if ~isempty(aCTImage)

        if isInterpolated('get') == false
        
            isInterpolated('set', true);
        
            setImageInterpolation(true);
        end

        progressBar(5/10, 'Resampling data series, please wait...');

        [aNMImage, atNMMetaData] = resampleImage(aNMImage, atNMMetaData, aCTImage, atCTMetaData, 'Linear', false, false);

        dicomMetaData('set', atNMMetaData, dNMSerieOffset);
        dicomBuffer  ('set', aNMImage, dNMSerieOffset);

        progressBar(6/10, 'Resampling MIP, please wait...');

%         refMip = mipBuffer('get', [], dCTSerieOffset);
%         aMip   = mipBuffer('get', [], dNMSerieOffset);
% 
%         aMip = resampleMip(aMip, atNMMetaData, refMip, atCTMetaData, 'Linear', false);
        
        mipBuffer('set', computeMIP(gather(aNMImage)), dNMSerieOffset);

        setQuantification(dNMSerieOffset);

        progressBar(7/10, 'Resampling contours, please wait.');


%         atRoi = roiTemplate('get', dNMSerieOffset);
% 
%         if ~isempty(atRoi)
% 
%             atResampledRoi = resampleROIs(aNMImage, atNMMetaData, aResampledNMImage, atResampledNMMetaData, atRoi, true);
% 
%             roiTemplate('set', dNMSerieOffset, atResampledRoi);
%         end

        progressBar(8/10, 'Resampling axes, please wait...');

        resampleAxes(aNMImage, atNMMetaData);

        setImagesAspectRatio();

        refreshImages();

    end

%     % Apply ROI constraint
%     [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dNMSerieOffset);
% 
%     bInvertMask = invertConstraint('get');
% 
%     tRoiInput = roiTemplate('get', dNMSerieOffset);
% 
%     aNMImageTemp = aNMImage;
%     aLogicalMask = roiConstraintToMask(aNMImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);
%     aNMImageTemp(aLogicalMask==0) = 0;  % Set constraint

%     resetSeries(dNMSerieOffset, true);


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

%     if tPSMALu177SPECTFullAI.options.SUVScaled == true

        dSUVconv = computeSUV(atNMMetaData, 'BW');

        if dSUVconv == 0
            dSUVconv = 1;
        end

        series2nrrd(dNMSerieOffset, sNrrdImagesName, dSUVconv);
%     else
%         series2nrrd(dNMSerieOffset, sNrrdImagesName, 1);
%     end

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

        progressBar(1, 'Error: nrrd file not found!');
        errordlg('nrrd file not found!!', '.nrrd file Validation');
    else

        progressBar(2/10, 'Machine learning in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows


            if tPSMALu177SPECTFullAI.options.CELossTrainer == true

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 112 -c 3d_fullres --save_probabilities -tr nnUNetTrainerDiceCELoss_noSmooth', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);

            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 110 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);
            end

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed


                progressBar(3/10, 'Importing prediction, please wait.');

                [aMask, ~] = nrrdread( sprintf('%sCase01.nrrd',sSegmentationFolderName));

                aMask = aMask(:,:,end:-1:1);

                bClassifySegmentation = tPSMALu177SPECTFullAI.options.classifySegmentation;
                bSmoothMask           = tPSMALu177SPECTFullAI.options.smoothMask;
                dSmallestValue        = tPSMALu177SPECTFullAI.options.smallestVoiValue;
                bPixelEdge            = tPSMALu177SPECTFullAI.options.pixelEdge;

                progressBar(4/10, 'Segmenting prediction mask, please wait.');

                maskAddVoiByTypeToSeries(aNMImage, aMask, atNMMetaData, dNMSerieOffset, dSmallestValue, bPixelEdge, bSmoothMask, bClassifySegmentation, 2);
                
%                 clear aNMImageTemp;

                if exist(char(sSegmentationFolderName), 'dir')

                    rmdir(char(sSegmentationFolderName), 's');
                end

%                 if ~isempty(aCTImage)
% 
%                     progressBar(5/10, 'Resampling data series, please wait...');
% 
%                     [aResampledNMImage, atResampledNMMetaData] = resampleImage(aNMImage, atNMMetaData, aCTImage, atCTMetaData, 'Linear', false, false);
% 
%                     dicomMetaData('set', atResampledNMMetaData, dNMSerieOffset);
%                     dicomBuffer  ('set', aResampledNMImage, dNMSerieOffset);
% 
%                     progressBar(6/10, 'Resampling MIP, please wait...');
% 
%                     refMip = mipBuffer('get', [], dCTSerieOffset);
%                     aMip   = mipBuffer('get', [], dNMSerieOffset);
% 
%                     aMip = resampleMip(aMip, atNMMetaData, refMip, atCTMetaData, 'Linear', false);
% 
%                     mipBuffer('set', aMip, dNMSerieOffset);
% 
%                     setQuantification(dNMSerieOffset);
% 
%                     progressBar(7/10, 'Resampling contours, please wait.');
% 
% 
%                     atRoi = roiTemplate('get', dNMSerieOffset);
% 
%                     if ~isempty(atRoi)
% 
%                         atResampledRoi = resampleROIs(aNMImage, atNMMetaData, aResampledNMImage, atResampledNMMetaData, atRoi, true);
% 
%                         roiTemplate('set', dNMSerieOffset, atResampledRoi);
%                     end
% 
%                     progressBar(8/10, 'Resampling axes, please wait...');
% 
%                     resampleAxes(aResampledNMImage, atResampledNMMetaData);
% 
%                     setImagesAspectRatio();
% 
%                 end


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

            computeMIPCallback();
        end
    end

    % Triangulate og 1st VOI

    atVoiInput = voiTemplate('get', dNMSerieOffset);

    if ~isempty(atVoiInput)

        dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

        triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
    end

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();
    
    plotRotatedRoiOnMip(axesMipPtr('get', [], dNMSerieOffset), dicomBuffer('get', [], dNMSerieOffset), mipAngle('get'));       

    clear aNMImage;
    clear aCTImage;

    % Delete .nii folder

    if exist(char(sNrrdTmpDir), 'dir')

        rmdir(char(sNrrdTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch
        resetSeries(dNMSerieOffset, true);
        progressBar( 1 , 'Error: setMachineLearningPSMALu177SPECTFullAI()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
