function exportNrrdBrownFatMaskCallback(~, ~)
%function exportNrrdBrownFatMaskCallback()
%Export BAT contours to a BAT AI trainning network, The tool is called from the main menu.
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
        return;
    end

    atPTMetaData  = dicomMetaData('get', [], dPTSerieOffset);
    if isempty(atPTMetaData)
        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);

    atCTMetaData  = dicomMetaData('get', [], dCTSerieOffset);
    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

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
    sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'exportNrrdLastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('exportNrrdLastUsedDir', 'var')
            sCurrentDir = exportNrrdLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

     [sNrrdMaskImagesName, sDFolder] = uigetfile(sprintf('%s%s', char(sCurrentDir), '*.nrrd'), 'Export .nrrd mask file');

     if sNrrdMaskImagesName ~= 0

        try
            exportNrrdLastUsedDir = sDFolder;
            save(sMatFile, 'exportNrrdLastUsedDir');
        catch ME
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end

        writeRoisToNrrdMask(sDFolder, false, sNrrdMaskImagesName, aResampledPTImage, atResampledPTMetaData, aResampledPTImage, atResampledPTMetaData, dPTSerieOffset, 2);
    end

    clear aPTImage;
    clear aCTImage;
    clear aResampledPTImage;

    progressBar(1, sprintf('Export %s completed', sNrrdMaskImagesName));

end
