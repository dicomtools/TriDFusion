function setVOIFatMetricsAnalyzerForPETCT(sSegmentatorScript, sCsvDir)
%function setVOIFatMetricsAnalyzerForPETCT(sSegmentatorScript, sCsvDir)
%Run AI VOI-Fat Metrics Analyzer for PET-CT.
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

    asClassName = ...
    {'Liver', ...
     'Autochthon Left', ...
     'Autochthon Right', ...                 
     'Gluteus Minimus Left', ...
     'Gluteus Minimus Right', ...
     'Gluteus Medius Left', ...
     'Gluteus Medius Right', ...
     'Gluteus Maximus Left', ...
     'Gluteus Maximus Right'};

     asTissueTypesName = ...
        {'Subcutaneous Fat'...
         'Torso Fat', ...
         'Skeletal Muscle' ...
         };

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

    if isempty(dPTSerieOffset) || isempty(dCTSerieOffset)
        progressBar(1, 'Error: AI VOI-Fat Metrics Analyzer for PET-CT segmentation require a PT and CT image!');
        errordlg('AI VOI-Fat Metrics Analyzer for PET-CT segmentation require a PT and CT image!', 'Modality Validation');
        return;
    end

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

    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
    end


    if isempty(atPTMetaData)

        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    % resetSeries(dPTSerieOffset, true);

    try

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

    progressBar(1/11, 'Converting DICOM to NII, please wait...');

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

        progressBar(1, 'Error: nii file not found!');
        errordlg('nii file not found!!', '.nii file Validation');
    else

        progressBar(2/11, 'Machine learning classes in progress, this might take several minutes, please be patient.');

        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else % Process succeed

                progressBar(3/11, 'Computing mask classes, please wait...');

                xPixelCT = atCTMetaData{1}.PixelSpacing(1)/10;
                yPixelCT = atCTMetaData{1}.PixelSpacing(2)/10;
                zPixelCT = computeSliceSpacing(atCTMetaData)/10; 

                voxVolumeCT = xPixelCT * yPixelCT * zPixelCT;
                
                % Preallocate atClass as a structured array

                atClass = repmat(struct('name', '', ...
                                        'ct', struct('volume', 0, 'mean', 0), ...
                                        'pt', struct('mean', 0, 'median', 0, 'max', 0)), ...
                                 1, numel(asClassName)+numel(asTissueTypesName));

                aClassMaskCT = zeros(size(aCTImage));
                aClassMaskPT = zeros(size(aPTImage));

                dSUVconv = computeSUV(atPTMetaData, 'BW');

                for jj=1:numel(asClassName)

                    sNiiFileName = replace(lower(asClassName{jj}), ' ', '_');
                    sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);

                    if exist(sNiiFileName, 'file')

                        nii = nii_tool('load', sNiiFileName);
                        aCTMask = imrotate3(nii.img, 90, [0 0 1],'nearest');
                        aCTMask = aCTMask(:,:,end:-1:1);

                        numVoxelsCT = nnz(aCTMask);

                        atClass(jj).name      = asClassName{jj};
                        atClass(jj).ct.volume = numVoxelsCT * voxVolumeCT;
                        atClass(jj).ct.mean   = mean(aCTImage(aCTMask>0));

                        [aPTMask, ~] = resampleImage(aCTMask, atCTMetaData, aPTImage, atPTMetaData, 'nearest', true, false);   

                        atClass(jj).pt.mean   = mean(aPTImage(aPTMask>0))   * dSUVconv;     
                        atClass(jj).pt.median = median(aPTImage(aPTMask>0)) * dSUVconv;   
                        atClass(jj).pt.max    = max(aPTImage(aPTMask>0))    * dSUVconv;          

                        aClassMaskCT(aCTMask>0) = jj;
                        aClassMaskPT(aPTMask>0) = jj;

                        clear aCTMask;
                        clear aPTMask;
                    end
                end

                progressBar(4/11, 'Machine learning tissue types in progress, this might take several minutes, please be patient.');

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --force_split -ta tissue_types', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);

                [bStatus, sCmdout] = system(sCommandLine);
         
                if bStatus
                    progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                    errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
                else
                    progressBar(5/11, 'Computing tissue types, please wait...');
                    
                    dClassOffset = numel(asClassName);

                    aSubcutaneousFatMaskCT = zeros(size(aCTImage));
                    aTorsoFatMaskCT        = zeros(size(aCTImage));
                    aSkeletalMuscleMaskCT  = zeros(size(aCTImage));

                    aSubcutaneousFatMaskPT = zeros(size(aPTImage));
                    aTorsoFatMaskPT        = zeros(size(aPTImage));
                    aSkeletalMuscleMaskPT  = zeros(size(aPTImage));

                    for jj=1:numel(asTissueTypesName)
                        
                        sNiiFileName = replace(lower(asTissueTypesName{jj}), ' ', '_');
                        sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
                        
                        if exist(sNiiFileName, 'file')    

                            nii = nii_tool('load', sNiiFileName);
    
                            aCTMask = imrotate3(nii.img, 90, [0 0 1],'nearest');
                            aCTMask = aCTMask(:,:,end:-1:1);
    
                            numVoxelsCT = nnz(aCTMask);
    
                            atClass(dClassOffset+jj).name      = asTissueTypesName{jj};
                            atClass(dClassOffset+jj).ct.volume = numVoxelsCT * voxVolumeCT;
                            atClass(dClassOffset+jj).ct.mean   = mean(aCTImage(aCTMask>0));
    
                            [aPTMask, ~] = resampleImage(aCTMask, atCTMetaData, aPTImage, atPTMetaData, 'nearest', true, false);   
    
                            atClass(dClassOffset+jj).pt.mean   = mean(aPTImage(aPTMask>0))   * dSUVconv;     
                            atClass(dClassOffset+jj).pt.median = median(aPTImage(aPTMask>0)) * dSUVconv;   
                            atClass(dClassOffset+jj).pt.max    = max(aPTImage(aPTMask>0))    * dSUVconv;          
    
                            switch jj 

                                case 1
                                aSubcutaneousFatMaskCT = aCTMask;
                                aSubcutaneousFatMaskPT = aPTMask;

                                case 2
                                aTorsoFatMaskCT = aCTMask;  
                                aTorsoFatMaskPT = aPTMask;

                                otherwise
                                aSkeletalMuscleMaskCT = aCTMask;
                                aSkeletalMuscleMaskPT = aPTMask;
                            end

                            clear aCTMask;
                            clear aPTMask;
                        end
                    end
    
                    progressBar(6/11, 'Computing CT class series, please wait...');
    
                    sCurrentDate = datestr(now, 'yyyymmdd');  % Format: 'yyyyMMdd'
                    sCurrentTime = datestr(now, 'HHMMSS');    % Format: 'HHmmss'
    
                    dNbCTFiles = numel(atInput(dCTSerieOffset).asFilesList);
                    atMetaDataCT = cell(dNbCTFiles, 1);

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
        
                        atMetaDataCT{jj} = dicominfo(atInput(dCTSerieOffset).asFilesList{jj});
    
                        atMetaDataCT{jj}.Modality = 'OT';
            
                        atMetaDataCT{jj}.SeriesDescription = 'Class CT mask';
            
                        atMetaDataCT{jj}.InstanceCreationTime = sCurrentTime;
                        atMetaDataCT{jj}.InstanceCreationDate = sCurrentDate;
            
                        atMetaDataCT{jj}.ContentTime = sCurrentTime;
                        atMetaDataCT{jj}.ContentDate = sCurrentDate;

                        atMetaDataCT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end
        
                    atMetaDataCT = flip(atMetaDataCT);
    
                    progressBar(7/11, 'Computing PT class series, please wait...');
    
                    dNbPTFiles = numel(atInput(dPTSerieOffset).asFilesList);
    
                    atMetaDataPT = cell(dNbPTFiles, 1);

                    sSeriesInstanceUID = dicomuid;
      
                    for jj=1:dNbPTFiles
        
                        atMetaDataPT{jj} = dicominfo(atInput(dPTSerieOffset).asFilesList{jj});
    
                        atMetaDataPT{jj}.Modality = 'OT';
            
                        atMetaDataPT{jj}.SeriesDescription = 'Class PT mask';
            
                        atMetaDataPT{jj}.InstanceCreationTime = sCurrentTime;
                        atMetaDataPT{jj}.InstanceCreationDate = sCurrentDate;
            
                        atMetaDataPT{jj}.ContentTime = sCurrentTime;
                        atMetaDataPT{jj}.ContentDate = sCurrentDate;      

                        atMetaDataPT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end
        
                    atMetaDataPT = flip(atMetaDataPT);
    
                    % Add CT mask
    
                    progressBar(8/11, 'Adding CT class series, please wait...');
    
                    addMaskToSeries(aClassMaskCT, atMetaDataCT);
    
                    clear aClassMaskCT;
    
                    % Add CT mask

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataCT{jj}.SeriesDescription = 'Subcutaneous fat CT mask';

                        atMetaDataCT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aSubcutaneousFatMaskCT, atMetaDataCT);

                    clear aSubcutaneousFatMaskCT;

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataCT{jj}.SeriesDescription = 'Torso fat CT mask';

                        atMetaDataCT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aTorsoFatMaskCT, atMetaDataCT);

                    clear aTorsoFatMaskCT;
                    
                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataCT{jj}.SeriesDescription = 'Skeletal muscle CT mask';

                        atMetaDataCT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aSkeletalMuscleMaskCT, atMetaDataCT);

                    clear aSkeletalMuscleMaskCT;

                    % Add PT mask
    
                    progressBar(9/11, 'Adding PT class series, please wait...');
    
                    addMaskToSeries(aClassMaskPT, atMetaDataPT)
    
                    clear aClassMaskPT;

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataPT{jj}.SeriesDescription = 'Subcutaneous fat PT mask';

                        atMetaDataPT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aSubcutaneousFatMaskPT, atMetaDataPT);

                    clear aSubcutaneousFatMaskPT;

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataPT{jj}.SeriesDescription = 'Torso fat mask PT';

                        atMetaDataPT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aTorsoFatMaskPT, atMetaDataPT);

                    clear aTorsoFatMaskPT;

                    sSeriesInstanceUID = dicomuid;

                    for jj=1:dNbCTFiles
       
                        atMetaDataPT{jj}.SeriesDescription = 'Skeletal muscle mask PT';

                        atMetaDataPT{jj}.SeriesInstanceUID = sSeriesInstanceUID;                       
                    end

                    addMaskToSeries(aSkeletalMuscleMaskPT, atMetaDataPT);

                    clear aSkeletalMuscleMaskPT;

                    progressBar(10/11, 'Creating .csv file, please wait...');

                    sSeriesDate = atPTMetaData{1}.SeriesDate;
            
                    if isempty(sSeriesDate)
                        sSeriesDate = '-';
                    else
                        sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
                    end
            
                    sFileName = sprintf('%s/%s_%s_%s_%s_STATISTICS_TriDFusion.csv' , ...
                        sCsvDir, cleanString(atPTMetaData{1}.PatientName), cleanString(atPTMetaData{1}.PatientID), cleanString(atPTMetaData{1}.SeriesDescription), sSeriesDate );

                    exportCsvStatistics(atPTMetaData, atClass, sFileName);

                end

            end
        end
    end

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')

        rmdir(char(sNiiTmpDir), 's');
    end

    clear aPTImage;
    clear aCTImage;

    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setVOIFatMetricsAnalyzerForPETCT()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function addMaskToSeries(aMask, atMetaData)

        atInput = inputTemplate('get');

        dNewSeriesOffset = numel(atInput)+1;
    
        atInput(dNewSeriesOffset).asFilesList    = [];
        atInput(dNewSeriesOffset).asFilesList{1} = [];
        
        atInput(dNewSeriesOffset).sOrientationView    = 'Axial';

        atInput(dNewSeriesOffset).bEdgeDetection      = false;
        atInput(dNewSeriesOffset).bFlipLeftRight      = false;
        atInput(dNewSeriesOffset).bFlipAntPost        = false;
        atInput(dNewSeriesOffset).bFlipHeadFeet       = false;
        atInput(dNewSeriesOffset).bDoseKernel         = false;
        atInput(dNewSeriesOffset).bMathApplied        = false;
        atInput(dNewSeriesOffset).bFusedDoseKernel    = false;
        atInput(dNewSeriesOffset).bFusedEdgeDetection = false;
        
        atInput(dNewSeriesOffset).tMovement = [];
        
        atInput(dNewSeriesOffset).tMovement.bMovementApplied = false;
        atInput(dNewSeriesOffset).tMovement.aGeomtform       = [];
        
        atInput(dNewSeriesOffset).tMovement.atSeq{1}.sAxe         = [];
        atInput(dNewSeriesOffset).tMovement.atSeq{1}.aTranslation = [];
        atInput(dNewSeriesOffset).tMovement.atSeq{1}.dRotation    = [];  

        atInput(dNewSeriesOffset).aDicomBuffer = [];

        imageOrientation('set', 'axial');


        sDateTime = datetime([sCurrentDate sCurrentTime],'InputFormat','yyyyMMddHHmmss');

        asSeriesDescription = seriesDescription('get');
        asSeriesDescription{numel(asSeriesDescription)+1} = sprintf('%s %s', atMetaData{1}.SeriesDescription, sDateTime);
        seriesDescription('set', asSeriesDescription);

        atInput(dNewSeriesOffset).atDicomInfo = atMetaData;
              
        inputTemplate('set', atInput);
            
        aInputBuffer = inputBuffer('get');        
        aInputBuffer{numel(aInputBuffer)+1} = aMask;    
        inputBuffer('set', aInputBuffer);

        clear aInputBuffer;
          
        asSeries = get(uiSeriesPtr('get'), 'String');   
        asSeries{numel(asSeries)+1} = sprintf('%s %s', atMetaData{1}.SeriesDescription, sDateTime);  

        set(uiSeriesPtr('get'), 'String', asSeries);
        set(uiFusedSeriesPtr('get'), 'String', asSeries);
        
        dicomMetaData('set', atInput(dNewSeriesOffset).atDicomInfo, dNewSeriesOffset);
        dicomBuffer('set', aMask, dNewSeriesOffset);

        setQuantification(dNewSeriesOffset);
        
        tQuant = quantificationTemplate('get');
        atInput(dNewSeriesOffset).tQuant = tQuant;

        aMip = computeMIP(aMask);
        mipBuffer('set', aMip, dNewSeriesOffset) ;
        atInput(dNewSeriesOffset).aMip = aMip;   

        inputTemplate('set', atInput);  
    end
    
    function exportCsvStatistics(atMetaData, atClass, sFileName)

        asClassHeader{1} = sprintf('Patient Name, %s'      , cleanString(atMetaData{1}.PatientName, '_'));
        asClassHeader{2} = sprintf('Patient ID, %s'        , atMetaData{1}.PatientID);
        asClassHeader{3} = sprintf('Series Description, %s', cleanString(atMetaData{1}.SeriesDescription, '_'));
        asClassHeader{4} = sprintf('Accession Number, %s'  , atMetaData{1}.AccessionNumber);
        asClassHeader{5} = sprintf('Series Date, %s'       , atMetaData{1}.SeriesDate);
        asClassHeader{6} = sprintf('Series Time, %s'       , atMetaData{1}.SeriesTime);
        asClassHeader{7} = sprintf('CT Unit, %s'              , 'HU');
        asClassHeader{8} = sprintf('PT Unit, %s'              , 'SUV');
        asClassHeader{9} = (' ');

        dNbClass = numel(atClass);

        dNumberOfLines = dNbClass + numel(asClassHeader) + 3; % Add header and cell description to number of needed lines % Add MTV and GTV
    
        asCell = cell(dNumberOfLines, 21); % Create an empty cell array

        dLineOffset = 1;

        for ll=1:numel(asClassHeader)

            asCell{dLineOffset,1}  = asClassHeader{ll};
            for ff=2:21
                asCell{dLineOffset,ff}  = (' ');
            end

            dLineOffset = dLineOffset+1;
        end

        asCell{dLineOffset,1} = 'Name';
        asCell{dLineOffset,2} = 'CT Volume (ml)';
        asCell{dLineOffset,3} = 'CT Mean';
        asCell{dLineOffset,4} = 'PT Mean';
        asCell{dLineOffset,5} = 'PT Median';
        asCell{dLineOffset,6} = 'PT Max';
        
        for ff=15:21
            asCell{dLineOffset,ff}  = (' ');
        end

        dLineOffset = dLineOffset+1;

        for cc=1:dNbClass

            asCell{dLineOffset,1}  = (atClass(cc).name);
            asCell{dLineOffset,2} = [atClass(cc).ct.volume];
            asCell{dLineOffset,3} = [atClass(cc).ct.mean];
            asCell{dLineOffset,4} = [atClass(cc).pt.mean];
            asCell{dLineOffset,5} = [atClass(cc).pt.median];
            asCell{dLineOffset,6} = [atClass(cc).pt.max];

            dLineOffset = dLineOffset+1;
       
        end

        cell2csv(sFileName, asCell, ',');

    end
end
