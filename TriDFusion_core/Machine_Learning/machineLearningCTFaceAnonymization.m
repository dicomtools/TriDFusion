function machineLearningCTFaceAnonymization(sSegmentatorScript, sAnonymizationType)
%function machineLearningCTFaceAnonymization(sSegmentatorScript, sAnonymizationType)
%ML-Based Face Anonymization in CT Scans.
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

    dCTSerieOffset = get(uiSeriesPtr('get'), 'Value');

    % Modality validation

    if ~strcmpi(atInput(dCTSerieOffset).atDicomInfo{1}.Modality, 'ct')
        progressBar(1, 'Error: Face Anonymization require a CT image!');
        errordlg('Face Anonymization require a CT image!', 'Modality Validation');
        return;        
    end

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

        progressBar(1, 'Error: nii file mot found!');
        errordlg('nii file mot found!!', '.nii file Validation');
    else
        progressBar(2/4, 'Segmentation in progress, this might take several minutes, please be patient.');

       sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName));

        if ispc % Windows

            sOption = '--force_split';

            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s %s -ta face', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName, sOption);

            [bStatus, sCmdout] = system(sCommandLine);
     
            if bStatus
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');
            else

                sNiiFileName = sprintf('%sFace.nii.gz', sSegmentationFolderName);

                if exist(sNiiFileName, 'file')

                    progressBar(3/4, 'Anonymization in progress, please be patient.');

                    nii = nii_tool('load', sNiiFileName);
                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                    aMask = aMask(:,:,end:-1:1);

                    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);
                    aCTImage     = dicomBuffer('get', [], dCTSerieOffset);

                    switch lower(sAnonymizationType)

                        case 'mean'

                            aCTImage(aMask==1)=mean(aCTImage(:));
                        
                        case 'gauss filter'

                            aBlurredImage = imgaussfilt(aCTImage, 10);

                            aCTImage(aMask==1)=aBlurredImage(aMask == 1);

                            clear aBlurredImage;

                        case 'zero'

                            aCTImage(aMask == 1) = 0;  

                        case 'random '

                            aCTImage(aMask == 1) = randn(sum(aMask(:)), 1) * std(aCTImage(:)) + mean(aCTImage(:));                    
                    end

                    dicomBuffer('set', aCTImage, dCTSerieOffset);
                    
                    clear aCTImage;

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
                    asSeriesDescription{dCTSerieOffset} = sprintf('%s %s', sSeriesDescription, datetime([sCurrentDate sCurrentTime],'InputFormat','yyyyMMddHHmmss'));
                    seriesDescription('set', asSeriesDescription);

                    set(uiSeriesPtr('get'), 'String', asSeriesDescription);
                    set(uiFusedSeriesPtr('get'), 'String', asSeriesDescription);

                    dicomMetaData('set', atCTMetaData, dCTSerieOffset);

                end

            end 


        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');
            errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');
            errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
        end
    end

    refreshImages();

    % Delete .nii folder

    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end

    progressBar(1, 'Ready');

    catch
        progressBar( 1 , 'Error: machineLearningCTFaceAnonymization()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end