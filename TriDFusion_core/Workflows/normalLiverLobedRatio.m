function normalLiverLobedRatio(dMarginSize, dPercentOfNormalLiver, bDisplayError)
%function normalLiverLobedRatio(dMarginSize, dPercentOfNormalLiver, bDisplayError)
%Split liver in 8 zones and export the statistics.
%
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

    try

    atInput = inputTemplate('get');
        
    % [dNMSerieOffset, dCTSerieOffset] = findDicomMatchingSeries(atInput, 'NM', 'CT');

    dNMSerieOffset = [];
    for tt=1:numel(atInput)

        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')

            atNmVoiInput = voiTemplate('get', tt);
            if isempty(atNmVoiInput)
                continue;
            end

            asLabels = lower(cellfun(@(s) s.Label, atNmVoiInput, 'UniformOutput', false));          

            if any(contains(asLabels, 'normal liver'))

                dNMSerieOffset = tt;
                break;
            end
        end
    end

    dCTSerieOffset = [];
    dPvCTSerieOffset = [];

    for tt=1:numel(atInput)

        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')

            atCTVoiInput = voiTemplate('get', tt);

            asLabels = lower(cellfun(@(s) s.Label, atCTVoiInput, 'UniformOutput', false));          

            if any(contains(asLabels, 'liver segment')) && ...
               any(contains(asLabels, 'liver-liv')) && ...
               any(contains(asLabels, 'lesion'))

                dCTSerieOffset = tt;
            elseif all(contains(asLabels, 'lesion'))

                dPvCTSerieOffset = tt;
            end
        end
    end

    if isempty(dNMSerieOffset) || isempty(dCTSerieOffset) || isempty(dPvCTSerieOffset)

        progressBar(1, 'Error: Liver ratio requires both a NM/CT and a contrast-enhanced CT image!');
        if bDisplayError == true
            errordlg('Error: Liver ratio requires both a NM/CT and a contrast-enhanced CT image!', 'Modality Validation');
        end
        return;
    end

    % Create Root directory

    if exist('G:/Documents', 'dir')
        sRootDirectory = 'G:/Documents/HAI_Pump_Step_Ratio';
    else
        sUserFolder = getenv('USERPROFILE'); % Gets "C:\Users\Username"
        sOneDrivePath = fullfile(sUserFolder, 'OneDrive - Memorial Sloan Kettering Cancer Center', 'Documents');

        if exist(sOneDrivePath, 'dir')

            sRootDirectory = sprintf('%s/HAI_Pump_Step_Ratio', sOneDrivePath);
        else
            sRootDirectory = 'C:/Temp/HAI_Pump_Step_Ratio';
        end
    end

    % sRootDirectory = 'C:/Temp/HAI_Pump_Ratio';

    if ~exist(sRootDirectory, 'dir')

        mkdir(sRootDirectory);
    end

    % sNMDirectory = sprintf('%s/NM_Statistics', sRootDirectory);
    % if ~exist(sNMDirectory, 'dir')
    % 
    %     mkdir(sNMDirectory);
    % end

    atNMMetaData = dicomMetaData('get', [], dNMSerieOffset);
    if isempty(atNMMetaData)

        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
    end

    sPatientName       = cleanString(atNMMetaData{1}.PatientName, '_');
    sAccession         = cleanString(atNMMetaData{1}.AccessionNumber, '_');
    sSeriesDescription = cleanString(atNMMetaData{1}.SeriesDescription, '_');

    sNMDirectory = sprintf('%s/%s', sRootDirectory, sPatientName);
    if ~exist(sNMDirectory, 'dir')

        mkdir(sNMDirectory);
    end

    sNMDirectory = sprintf('%s/%s', sNMDirectory, sAccession);
    if ~exist(sNMDirectory, 'dir')

        mkdir(sNMDirectory);
    end

    sNMDirectory = sprintf('%s/%s', sNMDirectory, sSeriesDescription);
    if ~exist(sNMDirectory, 'dir')

        mkdir(sNMDirectory);
    end

     % Procesing the NM series

    if get(uiSeriesPtr('get'), 'Value') ~= dCTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dCTSerieOffset);

        setSeriesCallback();
    end

    % Contours validation

    atCTVoiInput = voiTemplate('get', dCTSerieOffset);

    % Copy liver and liver segments to NM

    asLabels = lower(cellfun(@(s) s.Label, atCTVoiInput, 'UniformOutput', false));          

    for vv=1:numel(asLabels)
        if any(contains(asLabels, 'liver segment')) || ...
           any(contains(asLabels, 'liver-liv')) || ...
           any(contains(asLabels, 'lesion')) 
 
            copyRoiVoiToSerie(dCTSerieOffset, dNMSerieOffset, atCTVoiInput{vv}, false);
        end
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    atNMRoiInput = roiTemplate('get', dNMSerieOffset);    
    atNMVoiInput = voiTemplate('get', dNMSerieOffset);    

    % Extract all labels and convert to lowercase

    asLabels = lower(cellfun(@(s) s.Label, atNMVoiInput, 'UniformOutput', false));            

    % Set the flags by checking if any labels contain the respective substring
    bLiver         = any(contains(asLabels, 'liver-liv'));
    bLiverSegments = any(contains(asLabels, 'liver segment'));
    bNormalLiver   = any(contains(asLabels, 'normal liver'));
    bLiverLesions  = any(contains(asLabels, 'lesion'));

    if ~bLiver || ~bLiverSegments || ~bNormalLiver || ~bLiverLesions

        progressBar(1, sprintf('Error: No lesions, normal liver, liver segments or liver contours detected. Please draw a normal liver on the NM and segment the CT liver and segments before running the workflow!'));
        if bDisplayError == true
            errordlg(sprintf('Error: No lesions, normal liver, liver segments, or liver contours detected. Please draw a normal liver on the NM and segment the CT liver and segments before running the workflow!'));
        end
        return;        
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    aNMImage = dicomBuffer('get', [], dNMSerieOffset);
    if isempty(aNMImage)

        aInputBuffer = inputBuffer('get');
        aNMImage = aInputBuffer{dNMSerieOffset};
        clear aInputBuffer;
    end

    asNMLabels = lower(cellfun(@(s) s.Label, atNMVoiInput, 'UniformOutput', false));           

    % Left/Right Liver lobes
    dLiverOffset    = find(contains(asLabels, 'liver-liv'), 1);
    adLiverSegments = find(contains(asNMLabels, 'liver segment'));
    adLiverLesions  = find(contains(asNMLabels, 'lesion'));
  
    dNbSegments = numel(adLiverSegments);

    a3DLiverLogicalMask = voiTemplateToMask(atNMVoiInput{dLiverOffset}, atNMRoiInput, aNMImage);
    a3DLeftLiverLogicalMask  = false(size(aNMImage));
    a3DRightLiverLogicalMask = false(size(aNMImage));

    for jj=1:dNbSegments

        aSegmentMask = voiTemplateToMask(atNMVoiInput{adLiverSegments(jj)}, atNMRoiInput, aNMImage);

        % Left Lobe 
        if contains(atNMVoiInput{adLiverSegments(jj)}.Label, 'Liver Segment 2') || ... 
           contains(atNMVoiInput{adLiverSegments(jj)}.Label, 'Liver Segment 3') || ... 
           contains(atNMVoiInput{adLiverSegments(jj)}.Label, 'Liver Segment 4')  

            a3DLeftLiverLogicalMask = a3DLeftLiverLogicalMask|aSegmentMask&a3DLiverLogicalMask;
        else % Right Lobe 
            a3DRightLiverLogicalMask = a3DRightLiverLogicalMask|aSegmentMask&a3DLiverLogicalMask;

        end
    end

    maskToVoi(a3DLeftLiverLogicalMask , 'Liver Left Lobe' , 'Liver', [0.93, 0.69, 0.13], 'Axial', dNMSerieOffset, true);
    maskToVoi(a3DRightLiverLogicalMask, 'Liver Right Lobe', 'Liver', [0.72, 0.72, 0.15], 'Axial', dNMSerieOffset, true);
    
    for jj=1:dNbSegments
        aSegmentMask = voiTemplateToMask(atNMVoiInput{adLiverSegments(jj)}, atNMRoiInput, aNMImage) & a3DLiverLogicalMask;
        maskToVoi(aSegmentMask , sprintf('%s', atNMVoiInput{adLiverSegments(jj)}.Label) , 'Liver', atNMVoiInput{adLiverSegments(jj)}.Color, 'Axial', dNMSerieOffset, true);
        deleteContourObject(atNMVoiInput{adLiverSegments(jj)}.Tag, dNMSerieOffset);
    end

    atNMVoiInput = voiTemplate('get', dNMSerieOffset);    
    atNMRoiInput = roiTemplate('get', dNMSerieOffset);    

    asNMLabels = lower(cellfun(@(s) s.Label, atNMVoiInput, 'UniformOutput', false));           
    adLiverLesions  = find(contains(asNMLabels, 'lesion'));
    dNbLesions  = numel(adLiverLesions);

    xVoxelSize = atNMMetaData{1}.PixelSpacing(1);
    yVoxelSize = atNMMetaData{1}.PixelSpacing(2);
    zVoxelSize = computeSliceSpacing(atNMMetaData);

    for jj=1:dNbLesions
        aLesionMask = voiTemplateToMask(atNMVoiInput{adLiverLesions(jj)}, atNMRoiInput, aNMImage) & a3DLiverLogicalMask;
        maskToVoi(aLesionMask , sprintf('%s', atNMVoiInput{adLiverLesions(jj)}.Label) , 'Liver', atNMVoiInput{adLiverLesions(jj)}.Color, 'Axial', dNMSerieOffset, true);
        deleteContourObject(atNMVoiInput{adLiverLesions(jj)}.Tag, dNMSerieOffset);
    end

    atNMVoiInput = voiTemplate('get', dNMSerieOffset);    
    atNMRoiInput = roiTemplate('get', dNMSerieOffset);    

    asNMLabels = lower(cellfun(@(s) s.Label, atNMVoiInput, 'UniformOutput', false));           
    adLiverLesions  = find(contains(asNMLabels, 'lesion'));
    dNbLesions  = numel(adLiverLesions);

    for jj=1:dNbLesions
        aLesionMask = voiTemplateToMask(atNMVoiInput{adLiverLesions(jj)}, atNMRoiInput, aNMImage);
        aLesionMask = applyMarginToMask(aLesionMask, xVoxelSize, yVoxelSize, zVoxelSize, dMarginSize, dMarginSize, dMarginSize) & a3DLiverLogicalMask;
        maskToVoi(aLesionMask , sprintf('%s (with %dmm margin)', atNMVoiInput{adLiverLesions(jj)}.Label, dMarginSize), 'Liver', atNMVoiInput{adLiverLesions(jj)}.Color, 'Axial', dNMSerieOffset, true);
    end

    % Export NM Statistics To Excel

    sContoursFileName = sprintf('TriDFusion_NM_STATISTICS_%s_%s_%s.csv', sPatientName, sAccession, sSeriesDescription);
    exportNormalLiverRatioContoursReport(false, sprintf('%s/%s', sNMDirectory, sContoursFileName), dPercentOfNormalLiver);


    % Export NM Radiomics To Excel

    sRadiomicsFileName = sprintf('TriDFusion_NM_RADIOMICS_%s_%s_%s.xls', sPatientName, sAccession, sSeriesDescription);
    extractRadiomicsToXls(sprintf('%s/%s', sNMDirectory, sRadiomicsFileName), false, false, []);


    % Procesing the CT contrast series

    if get(uiSeriesPtr('get'), 'Value') ~= dPvCTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPvCTSerieOffset);

        setSeriesCallback();
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    atPvCTMetaData = dicomMetaData('get', [], dPvCTSerieOffset);
    if isempty(atPvCTMetaData)

        atPvCTMetaData = atInput(dPvCTSerieOffset).atDicomInfo;
    end

    % sCTDirectory = sprintf('%s/CT_Statistics', sRootDirectory);
    sAccession         = cleanString(atPvCTMetaData{1}.AccessionNumber, '_');
    sSeriesDescription = cleanString(atPvCTMetaData{1}.SeriesDescription, '_');

    sPvCTDirectory = sprintf('%s/%s', sRootDirectory, sPatientName); 
    if ~exist(sPvCTDirectory, 'dir')

        mkdir(sPvCTDirectory);
    end

    sPvCTDirectory = sprintf('%s/%s', sPvCTDirectory, sAccession); 
    if ~exist(sPvCTDirectory, 'dir')

        mkdir(sPvCTDirectory);
    end

    sPvCTDirectory = sprintf('%s/%s', sPvCTDirectory, sSeriesDescription); 
    if ~exist(sPvCTDirectory, 'dir')

        mkdir(sPvCTDirectory);
    end

    % Export CT PV Radiomics To Excel
    
    sRadiomicsFileName = sprintf('TriDFusion_PvCT_RADIOMICS_%s_%s_%s.xls', sPatientName, sAccession, sSeriesDescription);
    sStatisticsFileName = sprintf('TriDFusion_PvCT_STATISTICS_%s_%s_%s.csv', sPatientName, sAccession, sSeriesDescription);


    extractRadiomicsToXls(sprintf('%s/%s', sPvCTDirectory, sRadiomicsFileName), false, false, []);    
    exportContoursReport(false, false, false, false, sprintf('%s/%s', sPvCTDirectory, sStatisticsFileName), false);

    % Set TriDFusion to NM series for QA

    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    catch ME
        progressBar(1, 'Error: normalLiverLobedRatio()');
        logErrorToFile(ME);
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;    
end