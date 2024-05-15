function setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(hObject, ~)
%function setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(hObject)
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

    sTask99FolderPath = getenv('nnUnet_Task99_BAT_PETAC_CTAC');

    if isempty(sTask99FolderPath)

       progressBar( 1, 'Error: nnUnet_Task99_BAT_PETAC_CTAC environment variable not detected!');
       if exist('hObject', 'var')   
            errordlg(sprintf('nnUnet_Task99_BAT_PETAC_CTAC environment variable detected!\n Please define an environment variable nnUnet_Task99_BAT_PETAC_CTAC'), 'nnUnet_Task99_BAT_PETAC_CTAC Validation');  
        end
        return;
    end

    aListing = dir(sTask99FolderPath);

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
        mkdir(sprintf('%s/data0', sTask99FolderPath));
        mkdir(sprintf('%s/data0/training', sTask99FolderPath));
        mkdir(sprintf('%s/data0/testing', sTask99FolderPath));
    end

    sTrainingFoder = sprintf('%s/data0/training', sTask99FolderPath);

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
                 
    origin = atPTMetaData{end}.ImagePositionPatient;
    
    pixelspacing = zeros(3,1);

    pixelspacing(1) = atPTMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atPTMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atPTMetaData);

    sNrrdImagesName = sprintf('%sD%d.nrrd', sDFolder, dNewEntryNumber);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);

    if size(aPTImage, 3) ~=1

        aPTImage = aPTImage(:,:,end:-1:1);
    end

    dSUVconv = computeSUV(atPTMetaData, 'LBM');

    if dSUVconv == 0
        dSUVconv = computeSUV(atPTMetaData, 'BW');
    end

    if dSUVconv == 0
        dSUVconv = 1;
    end

    aPTImage = aPTImage*dSUVconv;

    nrrdWriter(sNrrdImagesName, squeeze(aPTImage), pixelspacing, origin, 'raw'); % Write .nrrd images     

    atCTMetaData  = dicomMetaData('get', [], dCTSerieOffset);
    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end
        

    [aResampledCTImage, ~] = resampleImage(aCTImage, atCTMetaData, aPTImage, atPTMetaData, 'Linear', true, false);   

    sNrrdImagesName = sprintf('%sD%d_ct.nrrd', sDFolder, dNewEntryNumber);

    nrrdWriter(sNrrdImagesName, squeeze(aResampledCTImage), pixelspacing, origin, 'raw'); % Write .nrrd images 


    clear aPTImage;
    clear aCTImage;
    clear aResampledCTImage;


    aInputBuffer = inputBuffer('get');

    sNrrdMaskImagesName = sprintf('D%d_gt.nrrd', dNewEntryNumber);

    writeRoisToNrrdMask(sDFolder, false, sNrrdMaskImagesName,aInputBuffer{dPTSerieOffset}, atInput(dPTSerieOffset).atDicomInfo, dicomBuffer('get',[],dPTSerieOffset), dicomMetaData('get',[],dPTSerieOffset), dPTSerieOffset, 2);

    clear aInputBuffer;

    progressBar(1, sprintf('Export to %s completed', sDFolder));

    if ~exist('hObject', 'var')
        close(fiMainWindowPtr('get'));     
    end

end