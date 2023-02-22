function extractRadiomicsFromContours(sRadiomicsPath, tReadiomics, bSUVUnit, dSUVScale, bEntireVolume, dContourOffset)
%function extractRadiomicsFromContours(sRadiomicsPath, tReadiomics, bSUVUnit, dSUVScale, bEntireVolume, dContourOffset)
%Run PyRadiomics, from a mask created from all contours.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atDicomMeta = dicomMetaData('get', [], dSeriesOffset);                              
    atMetaData  = atInput(dSeriesOffset).atDicomInfo;

    % Validate contours

    atVoiInput = voiTemplate('get', dSeriesOffset);
    if isempty(atVoiInput)
        progressBar(1, 'Error: No contours (voi) detected!');
        errordlg('No contours (voi) detected!', 'Contours Validation');  
        return;
    end

    atRoiInput = roiTemplate('get', dSeriesOffset);
    if isempty(atRoiInput)
        progressBar(1, 'Error: No contours (roi) detected!');
        errordlg('No contours (roi) detected!', 'Contours Validation');  
        return;
    end

    % Validate images

    aInputImages = inputBuffer('get');
    aImages = aInputImages{dSeriesOffset};
    if isempty(aImages)
        progressBar(1, 'Error: No images detected!');
        errordlg('No images detected!', 'Image Validation');  
        return;
    end

    asPatientInfoHeader{1,1} = sprintf('Patient Name');
    asPatientInfoHeader{2,1} = sprintf('Patient ID');
    asPatientInfoHeader{3,1} = sprintf('Series Description');
    asPatientInfoHeader{4,1} = sprintf('Accession Number');
    asPatientInfoHeader{5,1} = sprintf('Series Date');
    asPatientInfoHeader{6,1} = sprintf('Series Time');
    asPatientInfoHeader{7,1} = sprintf('Units');

    asPatientInfoHeader{1,2} = sprintf('%s', cleanString(atMetaData{1}.PatientName, '_'));
    asPatientInfoHeader{2,2} = sprintf('%s', atMetaData{1}.PatientID);
    asPatientInfoHeader{3,2} = sprintf('%s', cleanString(atMetaData{1}.SeriesDescription, '_'));
    asPatientInfoHeader{4,2} = sprintf('%s', atMetaData{1}.AccessionNumber);
    asPatientInfoHeader{5,2} = sprintf('%s', atMetaData{1}.SeriesDate);
    asPatientInfoHeader{6,2} = sprintf('%s', atMetaData{1}.SeriesTime);
    asPatientInfoHeader{7,2} = sprintf('%s', getSerieUnitValue(get(uiSeriesPtr('get'), 'Value')));

    % Create an empty directory    

    sNrrdTmpDir = sprintf('%stemp_nrrd_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end
    mkdir(char(sNrrdTmpDir));  
   
    filter = {'*.xls'};

    sCurrentDir  = viewerRootPath('get');

    sMatFile = [sCurrentDir '/' 'lastRadiomicsDir.mat'];
    
    % load last data directory
    if exist(sMatFile, 'file')
                    % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('saveRadiomicsLastUsedDir', 'var')
           sCurrentDir = saveRadiomicsLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
    end
        
    sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
    [file, path] = uiputfile(filter, 'Save contour report', sprintf('%s/%s_%s_%s_%s_RADIOMICS_TriDFusion.xls' , ...
        sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sDate) );

    if file ~= 0

        try
            matlab.io.internal.getExcelInstance;
            bExcelInstance = true;
        catch exception %#ok<NASGU>
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
            bExcelInstance = false;
        end

        try 
    
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        try
            saveRadiomicsLastUsedDir = path;
            save(sMatFile, 'saveRadiomicsLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end 

        sXlsFileName = sprintf('%s%s', path, file);
        
        if exist(sXlsFileName, 'file')
            delete(sXlsFileName);
        end

        progressBar(1/5, 'Computing images mask, please wait.');
    
        % Create an empty mask
    
        aImagesMask = zeros(size(aImages));
 
        % If a contour offset is specified, will compute it

        if exist('dContourOffset', 'var') 
            dVoiOffset = dContourOffset;
            dNbVois = dContourOffset;
        else % All contours
            dVoiOffset = 1;
            dNbVois = numel(atVoiInput);
        end

        % Create mask
     
        for vv=dVoiOffset:dNbVois
    
            for uu=1:numel(atVoiInput{vv}.RoisTag)
    
                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[atVoiInput{vv}.RoisTag{uu}]} );                
                    
                tRoi = atRoiInput{find(aTagOffset, 1)};
    
                % Resample ROI to original image size
    
                if numel(aImages) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                    pTemp{1} = tRoi;
                    ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImages, atMetaData, pTemp, false);
                    tRoi = ptrRoiTemp{1};
                end  
    
                % Extrac ROI mask
    
                switch lower(tRoi.Axe)                    
                    case 'axe'
                        aImagesSlice = aImages(:,:);
                        aMaskSlice   = aImagesMask(:,:);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
                    
                    case 'axes1'
                        aImagesSlice = permute(aImages(tRoi.SliceNb,:,:), [3 2 1]);
                        aMaskSlice   = permute(aImagesMask(tRoi.SliceNb,:,:), [3 2 1]);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
    
                     
                    case 'axes2'
                        aImagesSlice = permute(aImages(:,tRoi.SliceNb,:), [3 1 2]);
                        aMaskSlice   = permute(aImagesMask(:,tRoi.SliceNb,:), [3 1 2]);
    
                        aCurrentMask  = roiTemplateToMask(tRoi, aImagesSlice);
                        
                   case 'axes3'
                        aImagesSlice = aImages(:,:,tRoi.SliceNb);
                        aMaskSlice   = aImagesMask(:,:,tRoi.SliceNb);
    
                        aCurrentMask  = roiTemplateToMask(tRoi, aImagesSlice);
                end 
    
                % Set mask to voi number
                
                aMaskSlice(aCurrentMask==1) = vv;
    
                switch lower(tRoi.Axe)                    
                    case 'axe'
                        aImagesMask(:,:) = aMaskSlice;
                        
                    case 'axes1'
                        aImagesMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
    
                    case 'axes2'
                        aImagesMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                      
                    case 'axes3'
                        aImagesMask(:,:,tRoi.SliceNb) = aMaskSlice;
    
                end 
    
            end
        end
    
        if bEntireVolume == true
            aEntireImagesMask = aImagesMask;
            aEntireImagesMask(aEntireImagesMask~=0)=1;
        end

        progressBar(2/5, 'Writing .nrrd files, please wait.');
    
        % Write .nrrd files 
        
        origin=atMetaData{1}.ImagePositionPatient;
        
        pixelspacing=zeros(3,1);
        pixelspacing(1)=atMetaData{1}.PixelSpacing(1);
        pixelspacing(2)=atMetaData{1}.PixelSpacing(2);
        pixelspacing(3)=computeSliceSpacing(atMetaData);
    
        sNrrdImagesName = sprintf('%simges.nrrd', sNrrdTmpDir);
        sNrrdMaskName   = sprintf('%smask.nrrd' , sNrrdTmpDir);
    
        if bSUVUnit == true
            aImages = aImages*dSUVScale;
        end

        nrrdWriter(sNrrdImagesName, squeeze(aImages)    , pixelspacing, origin, 'raw'); % Write .nrrd images 
        nrrdWriter(sNrrdMaskName  , squeeze(aImagesMask), pixelspacing, origin, 'raw'); % Write .nrrd mask

        if bEntireVolume == true
            sNrrdEntireMaskName = sprintf('%sentire_mask.nrrd' , sNrrdTmpDir);
            nrrdWriter(sNrrdEntireMaskName, squeeze(aEntireImagesMask), pixelspacing, origin, 'raw'); % Write .nrrd mask
        end

        % Compute all contours
    
        progressBar(3/5, 'Computing radiomics, please wait');

        acResultFile = cell(dNbVois, 1);
        
        sAllContoursCmdout = '';

        if ispc % Windows

            if bEntireVolume == true % Entire volume

                progressBar(1/2, sprintf('Computing radiomics total contoured volume, it can take several minutes, please be patient.'));

                sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                writeYamlFile(sParametersFile, tReadiomics, 1);

                sCommandLine = sprintf('cmd.exe /c %spyradiomics.exe %s %s', sRadiomicsPath, sNrrdImagesName, sNrrdEntireMaskName);    

                sEntireMaskResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'TOTAL-CONTOURED-VOLUME');

                [bStatus, sCmdout] = system([sCommandLine ' -o ' sEntireMaskResultFile ' -p ' sParametersFile]);

                if bStatus 
                    progressBar( 1, 'Error: An error occur during radiomics extraction!');
                    errordlg(sprintf('An error occur during radiomics entire volume extraction: %s', sCmdout), 'Extraction Error');  
                end                

            end

            for vv=dVoiOffset:dNbVois
               
     %           if mod(vv, 5)==1 || vv == dNbVois
                    progressBar(vv/dNbVois-0.009, sprintf('Computing radiomics contour %s (%d/%d), it can take several minutes, please be patient.', atVoiInput{vv}.Label, vv, dNbVois));
     %           end
    
                sParametersFile = sprintf('%sparameters%d.yaml', sNrrdTmpDir, vv);
                writeYamlFile(sParametersFile, tReadiomics, vv);
        
                sCommandLine = sprintf('cmd.exe /c %spyradiomics.exe %s %s', sRadiomicsPath, sNrrdImagesName, sNrrdMaskName);    
    
                acResultFile{vv} = sprintf('%s%s.csv', sNrrdTmpDir, cleanString(atVoiInput{vv}.Label));
                
                [bStatus, sCmdout] = system([sCommandLine ' -o ' acResultFile{vv} ' -p ' sParametersFile]);
                
                if bStatus 
                    progressBar( 1, 'Error: An error occur during radiomics extraction!');
                    if exist('dContourOffset', 'var') % All contours
                        errordlg(sprintf('An error occur during radiomics extraction: %s', sCmdout), 'Extraction Error');  
                    else % All contours
                        if isempty(sAllContoursCmdout)
                            sAllContoursCmdout = sCmdout;
                        end
                    end
                else % Process succeed
                end
            end

            if ~exist('dContourOffset', 'var') % All contours
            
                if ~isempty(sAllContoursCmdout) 
                    errordlg(sprintf('An error occur during radiomics extraction: %s', sAllContoursCmdout), 'Extraction Error');  
                end
            end

            % Combine all .xls to a file
            progressBar(4/5, 'Combining results, please wait.');

            if bEntireVolume == true % Entire volume

                current_table = readtable(sEntireMaskResultFile); 

                current_table.(1) = [];
    
                aCurrentTableSize = size(current_table);
                aPatientHeaderSize = size(asPatientInfoHeader);

                cCurrenTable = table2cell(current_table);

                if aCurrentTableSize(2) == 3
                    cTempTable = cell(aCurrentTableSize(1), 4);
                    for spl=1:aCurrentTableSize(1)
                        cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                        asSpLit = strsplit(cCurrenTable{spl,3},':');
                        
                        if numel(asSpLit) == 2
                            cTempTable{spl,3}=asSpLit{1};
                            cTempTable{spl,4}=asSpLit{2};
                        end
                    end
                    cCurrenTable = cTempTable;
                    aCurrentTableSize = size(cTempTable);
                end

                cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));

                cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);

                cCombineTable = cell2table([cTempTable; cCurrenTable]);

                writetable(cCombineTable, sXlsFileName, 'Sheet', 'TOTAL-CONTOURED-VOLUME', 'WriteVariableNames', false);
            end

            bFirstLoop = true;
            for vv=dVoiOffset:dNbVois        
                current_table = readtable(acResultFile{vv}); 

                current_table.(1) = [];
    
                aCurrentTableSize = size(current_table);
                aPatientHeaderSize = size(asPatientInfoHeader);

                cCurrenTable = table2cell(current_table);

                if aCurrentTableSize(2) == 3
                    cTempTable = cell(aCurrentTableSize(1), 4);
                    for spl=1:aCurrentTableSize(1)
                        cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                        asSpLit = strsplit(cCurrenTable{spl,3},':');
                        
                        if numel(asSpLit) == 2
                            cTempTable{spl,3}=asSpLit{1};
                            cTempTable{spl,4}=asSpLit{2};
                        end
                    end
                    cCurrenTable = cTempTable;
                    aCurrentTableSize = size(cTempTable);
                end

                cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));

                cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);

                cCombineTable = cell2table([cTempTable; cCurrenTable]);

                if bFirstLoop == false || bEntireVolume == true
    
                    [~,B]=xlsfinfo(sXlsFileName);
                    if any(strcmp(B, acResultFile{vv})) % If name exist 
                        writetable(cCombineTable, sXlsFileName, 'Sheet', vv, 'WriteVariableNames', false);
                    else
                        writetable(cCombineTable, sXlsFileName, 'Sheet', atVoiInput{vv}.Label, 'WriteVariableNames', false);
                    end
                else
                    bFirstLoop = false;
                    writetable(cCombineTable, sXlsFileName, 'Sheet', atVoiInput{vv}.Label, 'WriteVariableNames', false);
                end
            end
    
        elseif isunix % Linux is not yet supported
    
            progressBar( 1, 'Error: Radiomics under Linux is not yet supported');
            errordlg('Radiomics under Linux is not yet supported', 'Machine Learning Validation');
    
        else % Mac is not yet supported
    
            progressBar( 1, 'Error: Radiomics under Mac is not yet supported');
            errordlg('Radiomics under Mac is not yet supported', 'Machine Learning Validation');
        end 

        catch 
            progressBar( 1 , 'Error: extractRadiomicsFromAllContours()' );
        end

        if bExcelInstance == true
            winopen(sXlsFileName);
        end

        progressBar(1, sprintf('Write %s completed', sXlsFileName));

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

        % Clear mask

        clear aImagesMask;

        if bEntireVolume == true % Entire volume
            clear aEntireImagesMask;
        end

    end


    % Clear memory

    clear aImages;
    clear aInputImages;

    % Delete .nrrd folder    
    
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end 

%    progressBar(1, 'Ready');

end