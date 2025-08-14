function setMachineLearningFDGBATExportToNetworkCallback(hObject, ~)
%function setMachineLearningFDGBATExportToNetworkCallback(hObject)
%Export BAT PET\CT series and contours to a BAT AI trainning network, The tool is called from the main menu.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atInput = inputTemplate('get');

    sEnvironment = 'nnUNet_raw_data_base';

    sRawFolderPath = getenv(sEnvironment);

    if isempty(sRawFolderPath)

        progressBar( 1, sprintf('Error: %s environment variable not detected!', sEnvironment));

        if exist('hObject', 'var')
            errordlg(sprintf('%s environment variable not detected!\n Please define an environment variable', sEnvironment), sprintf('%s Validation', sEnvironment));
        end

        return;
    end

    dTaskNumber = 106;

    aListing = dir(sRawFolderPath);

    bFoundTask = false;
    for dd=1:numel(aListing)
        if aListing(dd).isdir == true
            if strfind(aListing(dd).name, num2str(dTaskNumber))
                bFoundTask = true;
                sTaskFolderPath = sprintf('%s/%s', sRawFolderPath, aListing(dd).name);
                break;
            end
        end
    end

    if bFoundTask == false

        progressBar( 1, sprintf('Error: Task %s environment variable not detected!', num2str(dTaskNumber)));

        if exist('hObject', 'var')
            errordlg(sprintf('Task %s not detected!\n Please create a task under %s', num2str(dTaskNumber), sEnvironment), sprintf('Task %s Validation', num2str(dTaskNumber)));
        end

        return;
    end

    aListing = dir(sTaskFolderPath);

    bFoundData0 = false;
    for dd=1:numel(aListing)
        if aListing(dd).isdir == true
            if strcmpi(aListing(dd).name, 'data0')
                bFoundData0 = true;
                break;
            end
        end
    end

    if bFoundData0 == false
        mkdir(sprintf('%s/data0', sTaskFolderPath));
        mkdir(sprintf('%s/data0/training', sTaskFolderPath));
        mkdir(sprintf('%s/data0/testing', sTaskFolderPath));
    end

    sTrainingFoder = sprintf('%s/data0/training', sTaskFolderPath);

    aListing = dir(sTrainingFoder);

    dNewEntryNumber = 1;
    for dd=1:numel(aListing)
        if strcmpi(aListing(dd).name, '.') || strcmpi(aListing(dd).name, '..')
            continue;
        else
            if aListing(dd).isdir == true
                dNewEntryNumber = dNewEntryNumber+1;
            end
        end
    end

    sDFolder = sprintf('%s/D%d/', sTrainingFoder, dNewEntryNumber); % Create an empty D%d folder

    mkdir(sDFolder);

    % Export PT series;

    dPTSerieOffset = [];
    if strcmpi(atInput(dSeriesOffset).atDicomInfo{1}.Modality, 'pt')

        dPTSerieOffset = dSeriesOffset;
    else

        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
                dPTSerieOffset = tt;
                break;
            end
        end
    end

    if isempty(dPTSerieOffset)

        progressBar(1, 'Error: FDG Brown fat export to AI network require a PT image!');

        if exist('hObject', 'var')
            errordlg('FDG Brown fat export to AI network require a PT image!', 'Modality Validation');
        end
        delete(sDFolder);
        return;
    end

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct') && ...
           strcmpi(atInput(tt).atDicomInfo{1}.StudyInstanceUID, atInput(dPTSerieOffset).atDicomInfo{1}.StudyInstanceUID)

            dCTSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset)

        progressBar(1, 'Error: FDG Brown fat PET/CT export to AI network require a CT image!');

        if exist('hObject', 'var')
            errordlg('FDG Brown fat PET/CT export to AI network require a CT image!', 'Modality Validation');
        end
        delete(sDFolder);
        return;
    end


    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
    end

    atVoi = voiTemplate('get', dPTSerieOffset);

    if isempty(atVoi)

        progressBar(1, 'Error: FDG Brown fat export to AI network require contours!');

        if exist('hObject', 'var')
            errordlg('FDG Brown fat export to AI network require contours!', 'Contours Validation');
        end
        delete(sDFolder);
        return;
    end

    atPTMetaData  = dicomMetaData('get', [], dPTSerieOffset);
    if isempty(atPTMetaData)
        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);

    % if size(aPTImage, 3) ~=1
    %
    %     aPTImage = aPTImage(:,:,end:-1:1);
    % end

    % dSUVconv = computeSUV(atPTMetaData, 'LBM');
    %
    % if dSUVconv == 0
    %     dSUVconv = computeSUV(atPTMetaData, 'BW');
    % end
    %
    % if dSUVconv == 0
    %     dSUVconv = 1;
    % end

    atCTMetaData  = dicomMetaData('get', [], dCTSerieOffset);
    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    % if size(aCTImage, 3) ~=1
    %
    %     aCTImage = aCTImage(:,:,end:-1:1);
    % end

    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

    refMip = mipBuffer('get', [], dCTSerieOffset);
    aMip   = mipBuffer('get', [], dPTSerieOffset);

    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

    mipBuffer('set', aMip, dPTSerieOffset);

    dicomBuffer('set', aResampledPTImage, dPTSerieOffset);
    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);

    atRoi = roiTemplate('get', dPTSerieOffset);
    atVoi = voiTemplate('get', dPTSerieOffset);

    [atResampledRoi, atResampledVoi] = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true, atVoi, dPTSerieOffset);

    roiTemplate('set', dPTSerieOffset, atResampledRoi);
    voiTemplate('set', dPTSerieOffset, atResampledVoi);

    setQuantification(dPTSerieOffset);

    resampleAxes(aResampledPTImage, atResampledPTMetaData);

    setImagesAspectRatio();

    plotRotatedRoiOnMip(axesMipPtr('get', [], dPTSerieOffset), dicomBuffer('get', [], dPTSerieOffset), mipAngle('get'));

    aImageSize = size(aResampledPTImage);

    set(uiSliderSagPtr('get'), 'Value', round(aImageSize(1)/2));
    set(uiSliderCorPtr('get'), 'Value', round(aImageSize(2)/2));
    set(uiSliderTraPtr('get'), 'Value', round(aImageSize(3)/2));

    sliceNumber('set', 'coronal' , round(aImageSize(1)/2));
    sliceNumber('set', 'sagittal', round(aImageSize(2)/2));
    sliceNumber('set', 'axial'   , round(aImageSize(3)/2));

    refreshImages();

    origin = atResampledPTMetaData{end}.ImagePositionPatient;

    pixelspacing = zeros(3,1);

    pixelspacing(1) = atResampledPTMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atResampledPTMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atResampledPTMetaData);

    sNrrdImagesName = sprintf('%sD%d_ct.nrrd', sDFolder, dNewEntryNumber);

    nrrdWriter(sNrrdImagesName, squeeze(aCTImage(:,:,end:-1:1)), pixelspacing, origin, 'raw'); % Write .nrrd images

    sNrrdImagesName = sprintf('%sD%d.nrrd', sDFolder, dNewEntryNumber);

    % nrrdWriter(sNrrdImagesName, squeeze(aResampledPTImage*dSUVconv), pixelspacing, origin, 'raw'); % Write .nrrd images
    nrrdWriter(sNrrdImagesName, squeeze(aResampledPTImage(:,:,end:-1:1)), pixelspacing, origin, 'raw'); % Write .nrrd images

    % aInputBuffer = inputBuffer('get');

    sNrrdMaskImagesName = sprintf('D%d_gt.nrrd', dNewEntryNumber);

    writeRoisToNrrdMask(sDFolder, false, sNrrdMaskImagesName, aResampledPTImage, atResampledPTMetaData, aResampledPTImage, atResampledPTMetaData, dPTSerieOffset, 2);

    clear aPTImage;
    clear aCTImage;
    clear aResampledPTImage;

    % clear aInputBuffer;

    progressBar(1, sprintf('Export to %s completed', sDFolder));

    % if ~exist('hObject', 'var')
    %     close(fiMainWindowPtr('get'));
    % end

end
