function setFDGBrownFatFullAIExportToExcelCallback(~, ~)
%function setFDGBrownFatFullAIExportToExcelCallback()
%Run FDG Brown Fat PET BQML Segmentation, saved an RT-structure and add result to excel.
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

    EXTRACT_RADIOMICS = false;
    EXPORT_REPORT = false;
    EXPORT_STATISTICS = true;
    PROCESS_PT = true;
    PROCESS_CT = true;

    atInput = inputTemplate('get');

    dCTSerieOffset = [];
    for tt=1:numel(atInput)

        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')

            dCTSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset)

        return;
    end

    dPTSerieOffset = [];
    for tt=1:numel(atInput)

        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')

            dPTSerieOffset = tt;
            break;
        end
    end

    if isempty(dPTSerieOffset)

        return;
    end 

    [sPredictScript] = validateNnUNetv2Installation();

    if isempty(sPredictScript) % External Segmentor is not installed

        return;            
    end

    % Create Root directory

    sRootDirectory = 'P:\Dali\Daniel\BAT_STATISTICS';

    % if exist('G:/Documents', 'dir')
    % 
    %     sRootDirectory = 'G:/Documents/BAT_STATISTICS';
    % else
    %     sUserFolder = getenv('USERPROFILE'); % Gets "C:\Users\Username"
    %     sOneDrivePath = fullfile(sUserFolder, 'OneDrive - Memorial Sloan Kettering Cancer Center', 'Documents');
    % 
    %     if exist(sOneDrivePath, 'dir')
    % 
    %         sRootDirectory = sprintf('%s/BAT_STATISTICS', sOneDrivePath);
    %     else
    %         sRootDirectory = 'C:/Temp/BAT_STATISTICS';
    %     end
    % end

    if ~exist(sRootDirectory, 'dir')

        mkdir(sRootDirectory);
    end

    % Segment the PT series using AI
     
    % setMachineLearningFDGBrownFatFullAICallback();
    % Options

    tBrownFatFullAI.options.CELossTrainer        = true;
    tBrownFatFullAI.options.classifySegmentation = true;
    tBrownFatFullAI.options.smoothMask           = machineLearningFDGBrownFatSmoothMask('get');
    tBrownFatFullAI.options.smallestVoiValue     = machineLearningFDGBrownFatSmallestVoiValue('get');
    tBrownFatFullAI.options.pixelEdge            = pixelEdge('get');
    tBrownFatFullAI.options.fastSegmentation     = false;

    sWorkflowLog = sprintf('%s/3df_setMachineLearningFDGBrownFatFullAI_log.txt', sRootDirectory);

    setMachineLearningFDGBrownFatFullAI(sPredictScript, '106', tBrownFatFullAI, false, true, sWorkflowLog);

    atInput      = inputTemplate('get');    
    aInputBuffer = inputBuffer('get');

    atRoiInput = roiTemplate('get', dPTSerieOffset);
    atVoiInput = voiTemplate('get', dPTSerieOffset);

    if ~isempty(atVoiInput)

    if isFusion('get') == true % Deactivate the fusion

        setFusionCallback();
    end
    
    atMetaData = dicomMetaData('get', [], dPTSerieOffset);

    sPatientName       = cleanString(atMetaData{1}.PatientName, '_');
    sAccession         = cleanString(atMetaData{1}.AccessionNumber, '_');
    sSeriesDescription = cleanString(atMetaData{1}.SeriesDescription, '_');
    
    if EXPORT_REPORT == true || EXTRACT_RADIOMICS == true || isempty(outputDir('get'))

        sPatientNameDir = sprintf('%s/Patients_Database/%s', sRootDirectory, sPatientName);
        if ~exist(sPatientNameDir, 'dir')
    
            mkdir(sPatientNameDir);
        end
    
        sAccessionDir = sprintf('%s/%s', sPatientNameDir, sAccession);
        if ~exist(sAccessionDir, 'dir')
    
            mkdir(sAccessionDir);
        end
    
        sSeriesDescriptionDir = sprintf('%s/%s', sAccessionDir, sSeriesDescription);
        if ~exist(sSeriesDescriptionDir, 'dir')
    
            mkdir(sSeriesDescriptionDir);
        else
            sSeriesDescription = sprintf('%s-%s', sSeriesDescription, char(datetime('now', 'Format', 'yyyyMMddHHmmss')));
            sSeriesDescriptionDir = sprintf('%s/%s', sAccessionDir, sSeriesDescription);
            mkdir(sSeriesDescriptionDir);
        end
    end

    % Export RT-structure

    bSubDir = false;
    
    sOutDir = outputDir('get');
    if isempty(sOutDir)

        bSubDir = true;
        sOutDir = sprintf('%s/', sAccessionDir);
    end

    writeRtStruct(sOutDir, bSubDir, aInputBuffer{dPTSerieOffset}, atInput(dPTSerieOffset).atDicomInfo, dicomBuffer('get', [], dPTSerieOffset), atMetaData, dPTSerieOffset, false);

    % Copy all VOIs to CT

    if ~isempty(atVoiInput)

        dNbVois = numel(atVoiInput);

        for aa=1:dNbVois

            copyRoiVoiToSerie(dPTSerieOffset, dCTSerieOffset, atVoiInput{aa}, false);
        end
    end

    % Copy all ROIs

    if ~isempty(atRoiInput)
      
        dNbRois = numel(atRoiInput);

        for bb=1:dNbRois

            if ~strcmpi(atRoiInput{bb}.ObjectType, 'voi-roi')

                copyRoiVoiToSerie(dPTSerieOffset, dCTSerieOffset, atRoiInput{bb}, false);
            end            
        end
    end

    if PROCESS_PT == true
   
        if ~isempty(atRoiInput)
            [atRoiInput, atVoiInput] = ...
                resampleROIs(aInputBuffer{dCTSerieOffset}, ...
                             atInput(dCTSerieOffset).atDicomInfo, ...
                             aInputBuffer{dPTSerieOffset}, ...
                             atInput(dPTSerieOffset).atDicomInfo, ...                              
                             atRoiInput, ...
                             false, ...
                             atVoiInput, ...
                             dPTSerieOffset);
        
            roiTemplate('set', dPTSerieOffset, atRoiInput);
            voiTemplate('set', dPTSerieOffset, atVoiInput);
        end
        
        dicomBuffer('set', aInputBuffer{dPTSerieOffset}, dPTSerieOffset);
    
        dicomMetaData('set', atInput(dPTSerieOffset).atDicomInfo, dPTSerieOffset);
    
        mipBuffer('set', computeMIP(aInputBuffer{dPTSerieOffset}), dPTSerieOffset);
        
        setQuantification(dPTSerieOffset);
        
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);
    
        setSeriesCallback();

        % Export PT Statistics To Excel
        if EXPORT_STATISTICS == true
    
            exportBrownFatContoursToXls(sprintf('%s/BAT_PT_STATISTICS_All_Patients.xls', sRootDirectory)); 
        end

        % Export PT Contours Report
        if EXPORT_REPORT == true
    
            sReportFileName = sprintf('TriDFusion_REPORT_%s_%s_%s.pdf', sPatientName, sAccession, sSeriesDescription);   
            generateContourReport(true, sprintf('%s/%s', sSeriesDescriptionDir, sReportFileName));
        end
    
        % Export PT Radiomics To Excel
        if EXTRACT_RADIOMICS == true
    
            sRadiomicsFileName = sprintf('TriDFusion_RADIOMICS_%s_%s_%s.xls', sPatientName, sAccession, sSeriesDescription);
            extractRadiomicsToXls(sprintf('%s/%s', sSeriesDescriptionDir, sRadiomicsFileName), true, true, []);
        end
    end

    % Select the CT

    if PROCESS_CT == true
    
        set(uiSeriesPtr('get'), 'Value', dCTSerieOffset);
        setSeriesCallback();
    
        atMetaData = dicomMetaData('get', [], dCTSerieOffset);
    
        sPatientName       = cleanString(atMetaData{1}.PatientName, ' ');
        sAccession         = cleanString(atMetaData{1}.AccessionNumber);
        sSeriesDescription = cleanString(atMetaData{1}.SeriesDescription);
    
        if EXPORT_REPORT == true || EXTRACT_RADIOMICS == true
    
            sPatientNameDir = sprintf('%s/Patients_Database/%s', sRootDirectory, sPatientName);
            if ~exist(sPatientNameDir, 'dir')
        
                mkdir(sPatientNameDir);
            end
        
            sAccessionDir = sprintf('%s/%s', sPatientNameDir, sAccession);
            if ~exist(sAccessionDir, 'dir')
        
                mkdir(sAccessionDir);
            end
        
            sSeriesDescriptionDir = sprintf('%s/%s', sAccessionDir, sSeriesDescription);
            if ~exist(sSeriesDescriptionDir, 'dir')
        
                mkdir(sSeriesDescriptionDir);
            else
                sSeriesDescription = spritf('%s-%s', sSeriesDescription, char(datetime('now', 'Format', 'yyyyMMddHHmmss')));
                sSeriesDescriptionDir = sprintf('%s/%s', sAccessionDir, sSeriesDescription);
                mkdir(sSeriesDescriptionDir);
            end
        end

        % Export CT Statistics To Excel
        if EXPORT_STATISTICS == true
    
            exportBrownFatContoursToXls(sprintf('%s/BAT_CT_STATISTICS_All_Patients.xls', sRootDirectory)); 
        end

        % Export CT Contours Report
        if EXPORT_REPORT == true
    
            sReportFileName = sprintf('TriDFusion_REPORT_%s_%s_%s.pdf', sPatientName, sAccession, sSeriesDescription);    
            generateContourReport(true, sprintf('%s/%s', sSeriesDescriptionDir, sReportFileName));
        end
    
        % Export CT Radiomics To Excel
        if EXTRACT_RADIOMICS == true
        
            sRadiomicsFileName = sprintf('TriDFusion_RADIOMICS_%s_%s_%s.xls', sPatientName, sAccession, sSeriesDescription);
            extractRadiomicsToXls(sprintf('%s/%s', sSeriesDescriptionDir, sRadiomicsFileName), true, true, []);
        end
    end

    end

    catch ME
        logErrorToFile(ME);
    end

    clear aInputBuffer;

    % Exit the compiled executable

    close(fiMainWindowPtr('get'));       
end