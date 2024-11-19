function setMachineLearningPSMALu177ExportToSPECTCTNetworkCallback(hObject, ~)
%function setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(hObject)
%Export PSMA Lu177 SPECT\CT series and contours to a Lu177 AI trainning network, The tool is called from the main menu.
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

    dTaskNumber = 111;

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

    % Export NM series;

    dNMSerieOffset = [];
    if strcmpi(atInput(dSeriesOffset).atDicomInfo{1}.Modality, 'nm')

        dNMSerieOffset = dSeriesOffset;
    else

        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')
                dNMSerieOffset = tt;
                break;
            end
        end
    end

    if isempty(dNMSerieOffset)

        progressBar(1, 'Error: PSMA Lu177 export to AI network require a SPECT image!');

        if exist('hObject', 'var')
            errordlg('PSMA Lu177 export to AI network require a SPECT image!', 'Modality Validation');
        end
        delete(sDFolder);
        return;
    end

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct') && ...
           strcmpi(atInput(tt).atDicomInfo{1}.StudyInstanceUID, atInput(dNMSerieOffset).atDicomInfo{1}.StudyInstanceUID)

            dCTSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset)

        progressBar(1, 'Error: PSMA Lu177 SPECT/CT export to AI network require a CT image!');

        if exist('hObject', 'var')
            errordlg('PSMA Lu177 SPECT/CT export to AI network require a CT image!', 'Modality Validation');
        end
        delete(sDFolder);
        return;
    end


    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    atVoi = voiTemplate('get', dNMSerieOffset);

    if isempty(atVoi)

        progressBar(1, 'Error: PSMA Lu177 export to AI network require contours!');

        if exist('hObject', 'var')
            errordlg('PSMA Lu177 export to AI network require contours!', 'Contours Validation');
        end
        delete(sDFolder);
        return;
    end

    atNMMetaData  = dicomMetaData('get', [], dNMSerieOffset);
    if isempty(atNMMetaData)
        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
    end

    origin = atNMMetaData{end}.ImagePositionPatient;

    pixelspacing = zeros(3,1);

    pixelspacing(1) = atNMMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atNMMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atNMMetaData);

    sNrrdImagesName = sprintf('%sD%d.nrrd', sDFolder, dNewEntryNumber);

    aNMImage = dicomBuffer('get', [], dNMSerieOffset);

    if size(aNMImage, 3) ~=1

        aNMImage = aNMImage(:,:,end:-1:1);
    end

    dSUVconv = computeSUV(atNMMetaData, 'BW');

    if dSUVconv == 0
        dSUVconv = 1;
    end

    nrrdWriter(sNrrdImagesName, squeeze(aNMImage*dSUVconv), pixelspacing, origin, 'raw'); % Write .nrrd images

    atCTMetaData  = dicomMetaData('get', [], dCTSerieOffset);
    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    if size(aCTImage, 3) ~=1

        aCTImage = aCTImage(:,:,end:-1:1);
    end

%     [aResampledCTImage, ~] = resampleImage(aCTImage, atCTMetaData, aNMImage, atNMMetaData, 'Linear', false, false);

    tRegistration = registrationTemplate('get');

    [aResampledCTImage, ~, ~, ~, ~] = ...
        registerImage(aCTImage     , ...
                      atCTMetaData , ...
                      aNMImage     , ...
                      atNMMetaData , ...
                      []           , ...
                      'rigid'      , ...
                      'linear'   , ...
                      'automatic'  , ...
                      tRegistration.Optimizer, ...
                      tRegistration.Metric   , ...
                      true, ...
                      false);


    sNrrdImagesName = sprintf('%sD%d_ct.nrrd', sDFolder, dNewEntryNumber);

    nrrdWriter(sNrrdImagesName, squeeze(aResampledCTImage), pixelspacing, origin, 'raw'); % Write .nrrd images


    clear aNMImage;
    clear aCTImage;
    clear aResampledCTImage;


    aInputBuffer = inputBuffer('get');

    sNrrdMaskImagesName = sprintf('D%d_gt.nrrd', dNewEntryNumber);

    writeRoisToNrrdMask(sDFolder, false, sNrrdMaskImagesName,aInputBuffer{dNMSerieOffset}, atInput(dNMSerieOffset).atDicomInfo, dicomBuffer('get',[],dNMSerieOffset), dicomMetaData('get',[],dNMSerieOffset), dNMSerieOffset, 3);

    clear aInputBuffer;

    progressBar(1, sprintf('Export to %s completed', sDFolder));

    if ~exist('hObject', 'var')
        close(fiMainWindowPtr('get'));
    end

end
