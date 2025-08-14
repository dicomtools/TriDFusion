function machineLearningCTAnonymization(sSegmentatorScript, sAnonymizationModule, sAnonymizationTechnique, bAssociatedSeries, bDisplayErrorDialog, bExportSeries)
%function machineLearningCTAnonymization(sSegmentatorScript, sAnonymizationModule, sAnonymizationTechnique, bAssociatedSeries, bDisplayErrorDialog, bExportSeries)
%ML-Based Anonymization in CT Scans.
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

    dCTSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    % Modality validation

    if ~strcmpi(atInput(dCTSeriesOffset).atDicomInfo{1}.Modality, 'ct')
        dCTSeriesOffset = [];
        for jj=1:numel(atInput)
            if strcmpi(atInput(jj).atDicomInfo{1}.Modality, 'ct')
                dCTSeriesOffset = jj;
                break;
            end
        end
    end

    if isempty(dCTSeriesOffset)

        progressBar(1, 'Error: Anonymization require a CT image!');

        if bDisplayErrorDialog == true
            errordlg('Anonymization require a CT image!', 'Modality Validation');
        end

        return;        
    end

    dAssociatedSeriesOffset = [];
    if bAssociatedSeries == true
        for jj=1:numel(atInput)
            if strcmpi(atInput(jj).atDicomInfo{1}.StudyInstanceUID, atInput(dCTSeriesOffset).atDicomInfo{1}.StudyInstanceUID)
                if jj ~= dCTSeriesOffset
                    dAssociatedSeriesOffset = jj;
                    break;
                end
            end
        end        
    end


    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    % Get DICOM directory directory

    [sFilePath, ~, ~] = fileparts(char(atInput(dCTSeriesOffset).asFilesList{1}));

    % Create an empty directory

    sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end
    mkdir(char(sNiiTmpDir));

    % Convert dicom to .nii

    progressBar(1/4, 'Convertion dicom to nii, please wait.');

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
        progressBar(2/4, 'Prediction in progress, this might take several minutes, please be patient.');

       sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

            bStatus = false;

%             sOption = '--force_split';
            sOption = '';

            if strcmpi(sAnonymizationModule, 'face') || strcmpi(sAnonymizationModule, 'both')

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s %s -ta face', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName, sOption);
    
                [bStatusFace, sCmdout] = system(sCommandLine);

                if bStatusFace

                    bStatus = true;
                    progressBar( 1, 'Error: An error occur during machine learning face prediction!');

                    if bDisplayErrorDialog == true

                        errordlg(sprintf('An error occur during machine learning face prediction: %s', sCmdout), 'prediction Error');
                    end
                end
            end

            if strcmpi(sAnonymizationModule, 'skin') || strcmpi(sAnonymizationModule, 'both')

                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s %s -ta body', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName, sOption);
    
                [bStatusSkin, sCmdout] = system(sCommandLine);

                if bStatusSkin

                    bStatus = true;
                    progressBar( 1, 'Error: An error occur during machine learning skin prediction!');
                    
                    if bDisplayErrorDialog == true
               
                        errordlg(sprintf('An error occur during machine learning skin prediction: %s', sCmdout), 'Prediction Error');
                    end
                end
            end

     
            if bStatus == false

                bProceed = false;

                atCTMetaData = dicomMetaData('get', [], dCTSeriesOffset);
                if isempty(atCTMetaData)
                    atCTMetaData = atInput(dCTSeriesOffset).atDicomInfo;
                end

                aCTImage = dicomBuffer('get', [], dCTSeriesOffset);
                if isempty(aCTImage)
                    aBuffer = inputBuffer('get');
                    aCTImage = aBuffer{dCTSeriesOffset};

                    clear aBuffer;
                end
                    
                progressBar(3/4, 'Anonymization in progress, please be patient.');

                aMask = zeros(size(aCTImage));

                if strcmpi(sAnonymizationModule, 'face') || strcmpi(sAnonymizationModule, 'both')
           
                    sNiiFileName = sprintf('%sFace.nii.gz', sSegmentationFolderName);
    
                    if exist(sNiiFileName, 'file')

                        bProceed = true;

                        nii = nii_tool('load', sNiiFileName);
                        aMaskFace = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                        aMaskFace = aMaskFace(:,:,end:-1:1);

                        aMask(aMaskFace == 1) = 1;
                        clear aMaskFace;
                    end
                end

                if strcmpi(sAnonymizationModule, 'skin') || strcmpi(sAnonymizationModule, 'both')
           
                    sNiiFileName = sprintf('%sSkin.nii.gz', sSegmentationFolderName);
    
                    if exist(sNiiFileName, 'file')
 
                        bProceed = true;
    
                        nii = nii_tool('load', sNiiFileName);
                        aMaskSkin = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                        aMaskSkin = aMaskSkin(:,:,end:-1:1);
                       
                        aMask(aMaskSkin == 1) = 1;
                        clear aMaskSkin;
                    end
                end

                if bProceed == true

                    switch lower(sAnonymizationTechnique)

                        case 'mean'

                            aCTImage(aMask==1)=mean(aCTImage(aMask==1));
                        
                        case 'gauss filter'
                            x = 10;
                            y = 10;
                            z = 10;

                            sigmaX = x/atCTMetaData{1}.PixelSpacing(1);
                            if sigmaX == 0
                                sigmaX = x;
                            end 

                            sigmaY = y/atCTMetaData{1}.PixelSpacing(2);
                            if sigmaY == 0
                                sigmaY = y;
                            end      

                            dComputedeSpacing = computeSliceSpacing(atCTMetaData);
                            if dComputedeSpacing == 0
                                sigmaZ = z;
                            else
                                sigmaZ = z/dComputedeSpacing;
                            end               
                    
                            aBlurredImage = imgaussfilt3(aCTImage,[sigmaX,sigmaY,sigmaZ]);

%                             aBlurredImage = imgaussfilt(aCTImage, 100);

                            aCTImage(aMask==1)=aBlurredImage(aMask==1);

                            clear aBlurredImage;

                        case 'zero'

                            aCTImage(aMask==1) = 0;  

                        case 'min'

                            aCTImage(aMask==1) = min(aCTImage, [], 'all'); 

                        case 'random '

                            aCTImage(aMask==1) = randn(sum(aMask(:)), 1) * std(aCTImage(:)) + mean(aCTImage(:));                    
                    end

                    dicomBuffer('set', aCTImage, dCTSeriesOffset);
                    
                    setQuantification(dCTSeriesOffset);

                    sCurrentDate = datestr(now, 'yyyymmdd');  % Format: 'yyyyMMdd'
                    sCurrentTime = datestr(now, 'HHMMSS');    % Format: 'HHmmss'

                    sSeriesDescription = sprintf('ANO %s', atCTMetaData{1}.SeriesDescription);

                    for jj=1:numel(atCTMetaData)
            
                        atCTMetaData{jj}.SeriesDescription = sSeriesDescription;
            
                        atCTMetaData{jj}.InstanceCreationTime = sCurrentTime;
                        atCTMetaData{jj}.InstanceCreationDate = sCurrentDate;
            
                        atCTMetaData{jj}.ContentTime = sCurrentTime;
                        atCTMetaData{jj}.ContentDate = sCurrentDate;
                    end

                    asSeriesDescription = seriesDescription('get');
                    asSeriesDescription{dCTSeriesOffset} = sprintf('%s %s', sSeriesDescription, datetime([sCurrentDate sCurrentTime],'InputFormat','yyyyMMddHHmmss'));
                    seriesDescription('set', asSeriesDescription);

                    set(uiSeriesPtr('get'), 'String', asSeriesDescription);
                    set(uiFusedSeriesPtr('get'), 'String', asSeriesDescription);

                    dicomMetaData('set', atCTMetaData, dCTSeriesOffset);

                    if bExportSeries == true

                        sWriteDir = outputDir('get');
                        if ~isempty(sWriteDir)
                            writeDICOM(aCTImage, atCTMetaData, sWriteDir, dCTSeriesOffset, true);
                        end
                    end

                    clear aCTImage;

                    if ~isempty(dAssociatedSeriesOffset) 

%                         if strcmpi(atInput(jj).atDicomInfo{1}.Modality, 'nm')
%                             
%                         else
%                         end
                        atAssociatedMetaData = dicomMetaData('get', [], dAssociatedSeriesOffset);
                        if isempty(atAssociatedMetaData)
                            atAssociatedMetaData = atInput(dAssociatedSeriesOffset).atDicomInfo;
                        end
    
                        aAssociatedImage = dicomBuffer('get', [], dAssociatedSeriesOffset);
                        if isempty(aAssociatedImage)
                            aBuffer = inputBuffer('get');
                            aAssociatedImage = aBuffer{dAssociatedSeriesOffset};
    
                            clear aBuffer;
                        end

                        [aMask, ~] = resampleImage(aMask, atCTMetaData, aAssociatedImage, atAssociatedMetaData, 'Nearest', true, false);

                        switch lower(sAnonymizationTechnique)
    
                            case 'mean'
    
                                aAssociatedImage(aMask==1)=mean(aAssociatedImage(aMask==1));
                            
                            case 'gauss filter'
                                x = 10;
                                y = 10;
                                z = 10;
    
                                sigmaX = x/atAssociatedMetaData{1}.PixelSpacing(1);
                                if sigmaX == 0
                                    sigmaX = x;
                                end

                                sigmaY = y/atAssociatedMetaData{1}.PixelSpacing(2);
                                if sigmaY == 0
                                    sigmaY = y;
                                end  

                                dComputedeSpacing = computeSliceSpacing(atAssociatedMetaData);
                                if dComputedeSpacing == 0
                                    sigmaZ = z;
                                else
                                    sigmaZ = z/dComputedeSpacing;
                                end               
                        
                                aBlurredImage = imgaussfilt3(aAssociatedImage,[sigmaX,sigmaY,sigmaZ]);

%                                 aBlurredImage = imgaussfilt(aAssociatedImage, 100);
    
                                aAssociatedImage(aMask==1)=aBlurredImage(aMask==1);
    
                                clear aBlurredImage;
    
                            case 'zero'
    
                                aAssociatedImage(aMask==1) = 0;  
    
                            case 'min'
    
                                aAssociatedImage(aMask==1) = min(aAssociatedImage, [], 'all'); 
    
                            case 'random '
    
                                aAssociatedImage(aMask==1) = randn(sum(aMask(:)), 1) * std(aAssociatedImage(:)) + mean(aAssociatedImage(:));                    
                        end

                        dicomBuffer('set', aAssociatedImage, dAssociatedSeriesOffset);

                        setQuantification(dAssociatedSeriesOffset);
                      
%     
%                         sCurrentDate = datestr(now, 'yyyymmdd');  % Format: 'yyyyMMdd'
%                         sCurrentTime = datestr(now, 'HHMMSS');    % Format: 'HHmmss'
    
                        sSeriesDescription = sprintf('ANO %s', atAssociatedMetaData{1}.SeriesDescription);
    
                        for jj=1:numel(atAssociatedMetaData)
                
                            atAssociatedMetaData{jj}.SeriesDescription = sSeriesDescription;
                
                            atAssociatedMetaData{jj}.InstanceCreationTime = sCurrentTime;
                            atAssociatedMetaData{jj}.InstanceCreationDate = sCurrentDate;
                
                            atAssociatedMetaData{jj}.ContentTime = sCurrentTime;
                            atAssociatedMetaData{jj}.ContentDate = sCurrentDate;
                        end
    
                        asSeriesDescription = seriesDescription('get');
                        asSeriesDescription{dAssociatedSeriesOffset} = sprintf('%s %s', sSeriesDescription, datetime([sCurrentDate sCurrentTime],'InputFormat','yyyyMMddHHmmss'));
                        seriesDescription('set', asSeriesDescription);
    
                        set(uiSeriesPtr('get'), 'String', asSeriesDescription);
                        set(uiFusedSeriesPtr('get'), 'String', asSeriesDescription);
    
                        dicomMetaData('set', atAssociatedMetaData, dAssociatedSeriesOffset);    
                       
                        if bExportSeries == true

                            sWriteDir = outputDir('get');
                            if ~isempty(sWriteDir)
                                writeDICOM(aAssociatedImage, atAssociatedMetaData, sWriteDir, dAssociatedSeriesOffset, true);
                            end
                        end
         
                        clear aAssociatedImage;
                      
                    end

                    clear aMask;

                end

            end 


        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');
           
            if bDisplayErrorDialog == true
                errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');
            end

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');

            if bDisplayErrorDialog == true
                errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
            end
        end
    end

    refreshImages();

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);  
        progressBar( 1 , 'Error: machineLearningCTFaceAnonymization()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end