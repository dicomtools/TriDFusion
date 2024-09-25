function computeVoxelDosimetry(sDosimetryScriptPath, sSegmentatorScript, stDosimetry, bInitDisplay)
%function computeVoxelDosimetry(sDosimetryScriptPath, sSegmentatorScript, stDosimetry, bInitDisplay)
%Run PHITS dosimetry monte-carlo.
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

    dSerieOffset = get(uiSeriesPtr('get'), 'Value');

    atMetaData = dicomMetaData('get', [], dSerieOffset);

    aImage = dicomBuffer('get', [], dSerieOffset);

    tMaterial = getDoseMaterialsTemplate();

    if isempty(tMaterial)

        progressBar(0, 'Error:computeVoxelDosimetry() material template not found!');
        msgbox('Error: computeVoxelDosimetry(): Material template not found!', 'Error');
        return;
    end
        
    gsInjDateTime = [];
    gsHalfLife    = [];

    try 

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    % Machine Learning Tissue Dependant

    sTempInputDir = sprintf('%stemp_input_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sTempInputDir), 'dir')
        rmdir(char(sTempInputDir), 's');
    end
    mkdir(char(sTempInputDir)); 

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct') && ...
           strcmpi(atInput(tt).atDicomInfo{1}.StudyInstanceUID, atInput(tt).atDicomInfo{dSerieOffset}.StudyInstanceUID)     
            dCTSerieOffset = tt;
            break;
        end
    end

    if ~isempty(dCTSerieOffset)  

        atCtVoiInput = voiTemplate('get', dCTSerieOffset); 
        atCtRoiInput = roiTemplate('get', dCTSerieOffset); 

        aCTImage = dicomBuffer('get', [], dCTSerieOffset);

        if isempty(aCTImage)
            aInputBuffer = inputBuffer('get');
            aCTImage = aInputBuffer{dCTSerieOffset};
        end 

        atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

        if isempty(atCTMetaData)
            atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
        end        
    else
        atCtVoiInput = [];
        atCtRoiInput = [];
        aCTImage     = [];
    end
% 
%     if ~isempty(atCtVoiInput)
% 
%         for jj=1:numel(atCtVoiInput)
% 
%             copyRoiVoiToSerie(dCTSerieOffset, dSerieOffset, atCtVoiInput{jj}, false); 
%         end
%     end

    atVoiInput = voiTemplate('get', dSerieOffset); 
    atRoiInput = roiTemplate('get', dSerieOffset); 

    aLabelImage = [];

    % Create Ctbl File 

    if stDosimetry.tissueDependant.machineLearning.enable == true

        if isempty(dCTSerieOffset)  

            progressBar(1, 'Error: Machine learning tissue dependant segmentation require a CT image!');
            errordlg('Machine learning tissue dependant segmentation require a CT image!', 'Modality Validation');  
            return;  
        end
     
        % Get DICOM directory directory    
        
        [sFilePath, ~, ~] = fileparts(char(atInput(dCTSerieOffset).asFilesList{1}));
        
        % Create an empty directory    
    
        sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sNiiTmpDir), 'dir')
            rmdir(char(sNiiTmpDir), 's');
        end
        mkdir(char(sNiiTmpDir));    
        
        % Convert dicom to .nii     
        
        progressBar(1/12, 'DICOM to NII conversion, please wait.');
    
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
       
            if ispc % Windows
    
                progressBar(2/12, 'Machine learning in progress, this might take several minutes, please be patient.');
               
                sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
                if exist(char(sSegmentationFolderName), 'dir')
                    rmdir(char(sSegmentationFolderName), 's');
                end
                mkdir(char(sSegmentationFolderName)); 
    
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);  
    
                [bStatus, sCmdout] = system(sCommandLine);
   
                if bStatus 
                    progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                    errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
    
                    if exist(char(sSegmentationFolderName), 'dir')
                        rmdir(char(sSegmentationFolderName), 's');
                    end     

                    if exist(char(sTempInputDir), 'dir')
                        rmdir(char(sTempInputDir), 's');
                    end   

                    if exist(char(sNiiTmpDir), 'dir') % Delete .nii folder    
                        rmdir(char(sNiiTmpDir), 's');
                    end                     
                    return;  
               end 
    
                if exist(char(sNiiTmpDir), 'dir') % Delete .nii folder    
                    rmdir(char(sNiiTmpDir), 's');
                end  

                cleanMachineLearningEmptyMask(sSegmentationFolderName);


%                 if == all
%                     atCtVoiInput
%                 end
                
                % Create CT label and cbl file

                progressBar(3/12, 'Computing CT label and cbl file.');

                [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atCtVoiInput, dCTSerieOffset, tMaterial, sSegmentationFolderName, stDosimetry.tissueDependant.background, [], []);

                aLabelImage = createSegmentationlabelImage(zeros(size(aCTImage)), atCtVoiInput, atCtRoiInput, tCblTemplate); 

                aLabelImage = resampleLabelImage(aLabelImage, atCTMetaData, aImage, atMetaData);

                % Create serie label and cbl file

                if ~isempty(atVoiInput) % Current serie VOI

                    dCTTemplateSize = numel(tCblTemplate);

                    [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atVoiInput, dSerieOffset, tMaterial, [], [], tCblTemplate, caCblParam);
                    
                    if numel(tCblTemplate) ~= dCTTemplateSize

                        aLabelImage = createSegmentationlabelImage(aLabelImage, atVoiInput, atRoiInput, tCblTemplate(dCTTemplateSize+1:end)); 
                    end
                end

            elseif isunix % Linux is not yet supported
    
                progressBar( 1, 'Error: Machine Learning under Linux is not supported');
                errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');
    
                if exist(char(sNiiTmpDir), 'dir') % Delete .nii folder    
                    rmdir(char(sNiiTmpDir), 's');
                end  

                if exist(char(sTempInputDir), 'dir')
                    rmdir(char(sTempInputDir), 's');
                end                  
                return;  
    
            else % Mac is not yet supported
    
                progressBar( 1, 'Error: Machine Learning under Mac is not supported');
                errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');  
    
                if exist(char(sNiiTmpDir), 'dir') % Delete .nii folder    
                    rmdir(char(sNiiTmpDir), 's');
                end    

                if exist(char(sTempInputDir), 'dir')
                    rmdir(char(sTempInputDir), 's');
                end                 
                return;  
            end
        end
    else

        % Create CT label and cbl file
 
        if ~isempty(atCtVoiInput)

            progressBar(3/12, 'Computing CT label and cbl file.');

            [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atCtVoiInput, dCTSerieOffset, tMaterial, [], stDosimetry.tissueDependant.background, [], []);
    
            aLabelImage = createSegmentationlabelImage(zeros(size(aCTImage)), atCtVoiInput, atCtRoiInput, tCblTemplate); 
    
            aLabelImage = resampleLabelImage(aLabelImage, atCTMetaData, aImage, atMetaData);
    
            % Create serie label and cbl file
    
            if ~isempty(atVoiInput) % Current serie VOI
    
                dCTTemplateSize = numel(tCblTemplate);
    
                [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atVoiInput, dSerieOffset, tMaterial, [], [], tCblTemplate, caCblParam);
                
                if numel(tCblTemplate) ~= dCTTemplateSize
    
                    aLabelImage = createSegmentationlabelImage(aLabelImage, atVoiInput, atRoiInput, tCblTemplate(dCTTemplateSize+1:end)); 
                end
            end      
        else
%             if ~isempty(atVoiInput) % Current serie VOI
    
                [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atVoiInput, dSerieOffset, tMaterial, [], stDosimetry.tissueDependant.background, [], []);  

                aLabelImage = createSegmentationlabelImage(zeros(size(aImage)), atVoiInput, atRoiInput, tCblTemplate); 
               
%             end           
        end
    end

    if ~isempty(aLabelImage)

        progressBar(4/12, 'Writing .nrrd label file, please wait.');

        % Create nrd label file

        sSegmentationLabelFileName = sprintf('%sSegmentation-label.nrrd',sTempInputDir);

        origin = atMetaData{end}.ImagePositionPatient;
        
        pixelspacing=zeros(3,1);
        pixelspacing(1) = atMetaData{1}.PixelSpacing(1);
        pixelspacing(2) = atMetaData{1}.PixelSpacing(2);
        pixelspacing(3) = computeSliceSpacing(atMetaData);   
%         if ~isempty(atMetaData{1}.SliceThickness)
%             if atMetaData{1}.SliceThickness ~= 0
%                 pixelspacing(3) = atMetaData{1}.SliceThickness;
%             else
%                 pixelspacing(3) = computeSliceSpacing(atMetaData);
%             end           
%         else    
%             pixelspacing(3) = computeSliceSpacing(atMetaData);
%         end             
%         aLabelImage = rotateNrrdImage(aLabelImage);
        aLabelImage = aLabelImage(:,:,end:-1:1);

        nrrdWriter(sSegmentationLabelFileName, double(aLabelImage), pixelspacing, origin, 'raw'); % Write .nrrd images 

%         clear aLabelImage;

        % Create cbl file

        sSegmentationLabelColorTableFileName = sprintf('%sSegmentation-label_ColorTable.ctbl',sTempInputDir);

        sDisplayBuffer = '';
        for ff=1:numel(caCblParam)
            sDisplayBuffer = sprintf('%s%s\n', sDisplayBuffer, caCblParam{ff});
        end
    
        fFileID = fopen(sSegmentationLabelColorTableFileName,'w');
        if fFileID ~= -1
            fwrite(fFileID, sDisplayBuffer);
            fclose(fFileID);
        end
    end

    progressBar(5/12, 'Writing .nrrd image file, please wait.');

    % Write .nrrd files 
    
    origin = atMetaData{end}.ImagePositionPatient;
    
    pixelspacing=zeros(3,1);
    pixelspacing(1) = atMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atMetaData);
%     if ~isempty(atMetaData{1}.SliceThickness)
%         if atMetaData{1}.SliceThickness ~= 0
%             pixelspacing(3) = atMetaData{1}.SliceThickness;
%         else
%             pixelspacing(3) = computeSliceSpacing(atMetaData);
%         end           
%     else    
%         pixelspacing(3) = computeSliceSpacing(atMetaData);
%     end

    sNrrdImagesName = sprintf('%simage.nrrd', sTempInputDir);
    
    aImage = aImage(:,:,end:-1:1);

%     aImage = rotateNrrdImage(aImage);

    nrrdWriter(sNrrdImagesName, double(aImage), pixelspacing, origin, 'raw'); % Write .nrrd images 

    progressBar(3/5, 'Dosimetry in progress, this might take several minutes to hours, please be patient.');


    if ispc % Windows
    
        % Call PHITS

        sRootPath   = viewerRootPath('get');
        sKernelPath = sprintf('%s/kernel/', sRootPath);

        sPhitsScript = sprintf('%sDose_Simulation_Controller.py', sKernelPath);

        sRadionuclide = stDosimetry.radionuclide;

        sPhysicalModel = [];

        % Alpha

        if stDosimetry.physicalModel.alpha.enable == true
            
            if strcmpi(stDosimetry.physicalModel.alpha.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -a m %s %s', sPhysicalModel, stDosimetry.physicalModel.alpha.sourceParticles, stDosimetry.physicalModel.alpha.sourceParticlesBatches);
            elseif strcmpi(stDosimetry.physicalModel.alpha.dosimetryType, 'Local Deposition')

                sPhysicalModel = sprintf('%s -a l', sPhysicalModel);

            end
        end

        % Beta

        if stDosimetry.physicalModel.beta.enable == true
            
            if strcmpi(stDosimetry.physicalModel.beta.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -b m %s %s', sPhysicalModel, stDosimetry.physicalModel.beta.sourceParticles, stDosimetry.physicalModel.beta.sourceParticlesBatches);

            elseif strcmpi(stDosimetry.physicalModel.beta.dosimetryType, 'Local Deposition')
                sPhysicalModel = sprintf('%s -b l', sPhysicalModel);
           end
        end

        % Gamma 

        if stDosimetry.physicalModel.gamma.enable == true
            
            if strcmpi(stDosimetry.physicalModel.gamma.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -g m %s %s', sPhysicalModel, stDosimetry.physicalModel.gamma.sourceParticles, stDosimetry.physicalModel.gamma.sourceParticlesBatches);

            elseif strcmpi(stDosimetry.physicalModel.gamma.dosimetryType, 'Local Deposition')

                sPhysicalModel = sprintf('%s -g l', sPhysicalModel);
           end
        end

        % Monoenergetic Electron

        if stDosimetry.physicalModel.monoenergeticElectron.enable == true
            
            if strcmpi(stDosimetry.physicalModel.monoenergeticElectron.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -m m %s %s', sPhysicalModel, stDosimetry.physicalModel.monoenergeticElectron.sourceParticles, stDosimetry.physicalModel.monoenergeticElectron.sourceParticlesBatches);

            elseif strcmpi(stDosimetry.physicalModel.monoenergeticElectron.dosimetryType, 'Local Deposition')

                sPhysicalModel = sprintf('%s -m l', sPhysicalModel);
            end
        end

        % Positron

        if stDosimetry.physicalModel.positron.enable == true
            
            if strcmpi(stDosimetry.physicalModel.positron.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -p m %s %s', sPhysicalModel, stDosimetry.physicalModel.positron.sourceParticles, stDosimetry.physicalModel.positron.sourceParticlesBatches);

            elseif strcmpi(stDosimetry.physicalModel.positron.dosimetryType, 'Local Deposition')

                sPhysicalModel = sprintf('%s -p l', sPhysicalModel);
            end
        end

        % xRay

        if stDosimetry.physicalModel.xRay.enable == true
            
            if strcmpi(stDosimetry.physicalModel.xRay.dosimetryType, 'Monte Carlo')

                sPhysicalModel = sprintf('%s -x m %s %s', sPhysicalModel, stDosimetry.physicalModel.xRay.sourceParticles, stDosimetry.physicalModel.xRay.sourceParticlesBatches);

            elseif strcmpi(stDosimetry.physicalModel.xRay.dosimetryType, 'Local Deposition')

                sPhysicalModel = sprintf('%s -x l %s %s', sPhysicalModel);
            end
        end
        
        if stDosimetry.options.debugWindowMode == true
    
            winopen(sTempInputDir);
        end

        if stDosimetry.options.debugWindowMode == true
            sCommandLine = sprintf('cmd.exe /c start /wait python.exe "%s" -d %s -o %s -s %s -l %s -c %s -r %s %s', ...
                sPhitsScript, sDosimetryScriptPath, sTempInputDir, sNrrdImagesName, sSegmentationLabelFileName, sSegmentationLabelColorTableFileName, sRadionuclide, sPhysicalModel);            
        else
            sCommandLine = sprintf('cmd.exe /c python.exe "%s" -d %s -o %s -s %s -l %s -c %s -r %s %s', ...
                sPhitsScript, sDosimetryScriptPath, sTempInputDir, sNrrdImagesName, sSegmentationLabelFileName, sSegmentationLabelColorTableFileName, sRadionuclide, sPhysicalModel);
        end

        % Call PHITS
        
        [bStatus, sCmdout] = system(sCommandLine);

        if bStatus 

            progressBar( 1, 'Error: An error occur during the dosimetry computation!');
            errordlg(sprintf('An error occur during the dosimetry computation: %s', sCmdout), 'Computation Error');   

            if stDosimetry.options.debugWindowMode == false

                if exist(char(sTempInputDir), 'dir')
                    
                    rmdir(char(sTempInputDir), 's');
                end             
            end

            return;  
       end   
    
    
        % Import .nrrd beta 

        if stDosimetry.options.y90timeIntegrationFactor == true

            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) || ...
               isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife)     

                DLG_RADIOPHRMACEUTICAL_X = 480;
                DLG_RADIOPHRMACEUTICAL_Y = 240;
            
                if getMainWindowSize('xsize') < DLG_RADIOPHRMACEUTICAL_X
            
                    DLG_RADIOPHRMACEUTICAL_X = getMainWindowSize('xsize');
                end
            
                if getMainWindowSize('ysize') < DLG_RADIOPHRMACEUTICAL_Y
            
                    DLG_RADIOPHRMACEUTICAL_Y = getMainWindowSize('ysize');
                end
            
                if viewerUIFigure('get') == true
            
                    dlgRadiopharmaceutical = ...
                        uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_RADIOPHRMACEUTICAL_X/2) ...
                                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_RADIOPHRMACEUTICAL_Y/2) ...
                                            DLG_RADIOPHRMACEUTICAL_X ...
                                            DLG_RADIOPHRMACEUTICAL_Y ...
                                            ],...
                               'Resize', 'off', ...
                               'Color', viewerBackgroundColor('get'),...
                               'WindowStyle', 'modal', ...
                               'Name' , 'Radiopharmaceutical Information'...
                               );
                else
            
                    dlgRadiopharmaceutical = ...
                        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_RADIOPHRMACEUTICAL_X/2) ...
                                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_RADIOPHRMACEUTICAL_Y/2) ...
                                            DLG_RADIOPHRMACEUTICAL_X ...
                                            DLG_RADIOPHRMACEUTICAL_Y ...
                                            ],...
                               'MenuBar'    , 'none',...
                               'Resize'     , 'off', ...    
                               'NumberTitle', 'off',...
                               'MenuBar'    , 'none',...
                               'Color'      , viewerBackgroundColor('get'), ...
                               'Name'       , 'Radiopharmaceutical Information',...
                               'Toolbar'    , 'none'...               
                               );      
                end

                % Radiopharmaceutical Start Date Time

                injDateTime = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;

                   uicontrol(dlgRadiopharmaceutical,...
                             'style'   , 'text',...
                             'string'  , 'Radiopharmaceutical Start Date Time',...
                             'horizontalalignment', 'left',...
                             'BackgroundColor', viewerBackgroundColor('get'), ...
                             'ForegroundColor', viewerForegroundColor('get'), ...
                             'position', [20 112 280 20]...
                             );
        
                   uicontrol(dlgRadiopharmaceutical,...
                             'style'   , 'text',...
                             'string'  , 'Format (yyyyMMddHHmmss.SS)',...
                             'horizontalalignment', 'left',...
                             'BackgroundColor', viewerBackgroundColor('get'), ...
                             'ForegroundColor', viewerForegroundColor('get'), ...
                             'position', [20 87 280 20]...
                             );
        
              edtInjDateTime = ...
                  uicontrol(dlgRadiopharmaceutical,...
                            'style'     , 'edit',...
                            'Background', 'white',...
                            'string'    , injDateTime,...
                            'BackgroundColor', viewerBackgroundColor('get'), ...
                            'ForegroundColor', viewerForegroundColor('get'), ...
                            'position'  , [300 90 160 20]...
                            );
        
                % Radiopharmaceutical Half Life

                halfLife = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;   
   
                   uicontrol(dlgRadiopharmaceutical,...
                             'style'   , 'text',...
                             'string'  , 'Radionuclide Half-Life',...
                             'horizontalalignment', 'left',...
                             'BackgroundColor', viewerBackgroundColor('get'), ...
                             'ForegroundColor', viewerForegroundColor('get'), ...
                             'position', [20 62 280 20]...
                             );
        
              edtHalfLife = ...
                  uicontrol(dlgRadiopharmaceutical,...
                            'style'     , 'edit',...
                            'Background', 'white',...
                            'string'    , halfLife,...
                            'BackgroundColor', viewerBackgroundColor('get'), ...
                            'ForegroundColor', viewerForegroundColor('get'), ...
                            'position'  , [300 65 160 20]...
                            );

                 % Cancel or Proceed
            
                 uicontrol(dlgRadiopharmaceutical,...
                           'String'  ,'Cancel',...
                           'Units'   , 'pixels',...
                           'position', [370 ...
                                        10 ...
                                        100 ...
                                        25], ... 
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...                
                           'Callback', @cancelRadiopharmaceuticalInformationSequenceCallback...
                           );
            
                 uicontrol(dlgRadiopharmaceutical,...
                           'String'    , 'Proceed',...
                           'Units'     , 'pixels',...
                           'FontWeight', 'bold',...
                           'position', [260 ...
                                        10 ...
                                        100 ...
                                        25], ...  
                          'BackgroundColor', [0.6300 0.6300 0.4000], ...
                          'ForegroundColor', [0.1 0.1 0.1], ...               
                          'Callback', @setRadiopharmaceuticalInformationSequenceCallback...
                          ); 

                waitfor(dlgRadiopharmaceutical);
   
                injDateTime = gsInjDateTime;
                acqTime     = atMetaData{1}.SeriesTime;
                acqDate     = atMetaData{1}.SeriesDate;
                halfLife    = gsHalfLife;
            else

                injDateTime = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
                acqTime     = atMetaData{1}.SeriesTime;
                acqDate     = atMetaData{1}.SeriesDate;
                halfLife    = str2double(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);
            end

            if numel(injDateTime) == 14
                injDateTime = sprintf('%s.00', injDateTime);
            end
        
            datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
            dateInjDate = datenum(datetimeInjDate);
        
            if numel(acqTime) == 6
                acqTime = sprintf('%s.00', acqTime);
            end
        
            datetimeAcqDate = datetime([acqDate acqTime],'InputFormat','yyyyMMddHHmmss.SS');
            dayAcqDate = datenum(datetimeAcqDate);
        
            TscanMinusTinjection = (dayAcqDate - dateInjDate)*(24*60*60); % Acquisition start time

            dFactor = halfLife/(log(2))*exp(log(2)/halfLife*TscanMinusTinjection);   
        else
            dFactor = 1;
        end

        % Alpha 

        aAlphaBuffer = [];

        if stDosimetry.physicalModel.alpha.enable == true

            sNrrdFile = sprintf('%s/alpha/alpha_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')
                [aAlphaBuffer, ~] = nrrdread( sNrrdFile );

                aAlphaBuffer = aAlphaBuffer(:,:,end:-1:1);

                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aAlphaBuffer = aAlphaBuffer*dFactor;
                end
            end
        end

        % Beta 

        aBetaBuffer = [];

        if stDosimetry.physicalModel.beta.enable == true

            sNrrdFile = sprintf('%s/beta/beta_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')

                [aBetaBuffer, ~] = nrrdread( sNrrdFile );

                aBetaBuffer = aBetaBuffer(:,:,end:-1:1);
        
                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aBetaBuffer = aBetaBuffer*dFactor;
                end
            end
        end

        % Gamma 

        aGammaBuffer = [];

        if stDosimetry.physicalModel.gamma.enable == true

            sNrrdFile = sprintf('%s/gamma/gamma_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')
    
                [aGammaBuffer, ~] = nrrdread( sNrrdFile );
               
                aGammaBuffer = aGammaBuffer(:,:,end:-1:1);
     
                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aGammaBuffer = aGammaBuffer*dFactor;
                end
            end
        end

        % Monoenergetic Electron

        aMonoenergeticElectronBuffer = [];

        if stDosimetry.physicalModel.monoenergeticElectron.enable == true

            sNrrdFile = sprintf('%s/monoenergetic_electron/monoenergetic_electron_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')

                [aMonoenergeticElectronBuffer, ~] = nrrdread( sNrrdFile );

                aMonoenergeticElectronBuffer = aMonoenergeticElectronBuffer(:,:,end:-1:1);
  
                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aMonoenergeticElectronBuffer = aMonoenergeticElectronBuffer*dFactor;
                end
            end
        end

        % Positron

        aPositronBuffer = [];

        if stDosimetry.physicalModel.positron.enable == true

            sNrrdFile = sprintf('%s/positron/positron_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')

                [aPositronBuffer, ~] = nrrdread( sNrrdFile );

                aPositronBuffer = aPositronBuffer(:,:,end:-1:1);
     
                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aPositronBuffer = aPositronBuffer*dFactor;
                end
            end
        end

        % Xray

        aXrayBuffer = [];

        if stDosimetry.physicalModel.xRay.enable == true

            sNrrdFile = sprintf('%s/xray/xray_VoxelDose.nrrd', sTempInputDir);

            if exist(sNrrdFile, 'file')

                [aXrayBuffer, ~] = nrrdread( sNrrdFile );

                aXrayBuffer = aXrayBuffer(:,:,end:-1:1);
      
                if stDosimetry.options.y90timeIntegrationFactor == true
        
                    aXrayBuffer = aXrayBuffer*dFactor;
                end
            end
        end

        % Initialize aDosimetry as an empty array
        
        aDosimetry = zeros(size(aImage));
        
        % Check and add each buffer if it's not empty

        ADD_SERIES = false;

        if ~isempty(aAlphaBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aAlphaBuffer;
            clear aAlphaBuffer;
        end
        
        if ~isempty(aBetaBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aBetaBuffer;
            clear aBetaBuffer;
        end
        
        if ~isempty(aGammaBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aGammaBuffer;
            clear aGammaBuffer;
        end
        
        if ~isempty(aMonoenergeticElectronBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aMonoenergeticElectronBuffer;
            clear aMonoenergeticElectronBuffer;
        end
        
        if ~isempty(aPositronBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aPositronBuffer;
            clear aPositronBuffer;
        end
        
        if ~isempty(aXrayBuffer)

            ADD_SERIES = true;
            aDosimetry = aDosimetry + aXrayBuffer;
            clear aXrayBuffer;
        end
        
        if ADD_SERIES == true
    
            atRtDoseHeader = createRtDoseDicomHeader(aDosimetry, atMetaData, dSerieOffset);
    
            dNewSeriesOffset = numel(atInput)+1;
        
            atInput(dNewSeriesOffset).asFilesList    = [];
            atInput(dNewSeriesOffset).asFilesList{1} = [];
            
            atInput(dNewSeriesOffset).sOrientationView    = 'Axial';
    
            atInput(dNewSeriesOffset).bEdgeDetection      = false;
            atInput(dNewSeriesOffset).bFlipLeftRight      = false;
            atInput(dNewSeriesOffset).bFlipAntPost        = false;
            atInput(dNewSeriesOffset).bFlipHeadFeet       = false;
            atInput(dNewSeriesOffset).bDoseKernel         = true;
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
    
            sSeriesDate = atRtDoseHeader{1}.InstanceCreationDate;
            sSeriesTime = atRtDoseHeader{1}.InstanceCreationTime;
                            
            sDateTime = sprintf('%s%s', sSeriesDate, sSeriesTime);    
            if contains(sDateTime,'.')
                sDateTime = extractBefore(sDateTime,'.');
            end
            sDateTime = datetime(sDateTime,'InputFormat','yyyyMMddHHmmss');
    
            asSeriesDescription = seriesDescription('get');
            asSeriesDescription{numel(asSeriesDescription)+1} = sprintf('%s %s', atRtDoseHeader{1}.SeriesDescription, sDateTime);
            seriesDescription('set', asSeriesDescription);

            atInput(dNewSeriesOffset).atDicomInfo = atRtDoseHeader;
                  
            inputTemplate('set', atInput);
        
            aInputBuffer = inputBuffer('get');        
            aInputBuffer{numel(aInputBuffer)+1} = aDosimetry;    
            inputBuffer('set', aInputBuffer);
        
            asSeries = get(uiSeriesPtr('get'), 'String');   
            asSeries{numel(asSeries)+1} = sprintf('%s %s', atRtDoseHeader{1}.SeriesDescription, sDateTime);  
    
            set(uiSeriesPtr('get'), 'String', asSeries);
            set(uiFusedSeriesPtr('get'), 'String', asSeries);
            
            dicomMetaData('set', atInput(dNewSeriesOffset).atDicomInfo, dNewSeriesOffset);
            dicomBuffer('set', aDosimetry, dNewSeriesOffset);
    
            setQuantification(dNewSeriesOffset);
            
            tQuant = quantificationTemplate('get');
            atInput(dNewSeriesOffset).tQuant = tQuant;
    
            aMip = computeMIP(aDosimetry);
            mipBuffer('set', aMip, dNewSeriesOffset) ;
            atInput(dNewSeriesOffset).aMip = aMip;   
    
            inputTemplate('set', atInput);  
    
            clear aMip;
            clear aDosimetry;            

            
            % Import contours 

            if stDosimetry.contours.all == true

                for jj=1:numel(tCblTemplate)
    
                    if isempty(tCblTemplate(jj).fileName) && ... 
                       isempty(tCblTemplate(jj).label)    && ... 
                       isempty(tCblTemplate(jj).tag) 
                        continue;
                    end

                    if isempty(tCblTemplate(jj).fileName) 

                        if tCblTemplate(jj).series == dSerieOffset
    
                            aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), tCblTemplate(jj).tag );
    
                            if aTagOffset(aTagOffset==1) % tag is a voi                        
    
                                dTagOffset = find(aTagOffset, 1);
    
                                if ~isempty(dTagOffset)
    
                                    copyRoiVoiToSerie(dSerieOffset, dNewSeriesOffset, atVoiInput{dTagOffset}, false);   

                                    bInitDisplay = true;
                                end
                            end
                        end

%                         if ~isempty(atCtVoiInput)
% 
%                             if tCblTemplate(jj).series == dCTSerieOffset
% 
%                                 aTagOffset = strcmp( cellfun( @(atCtVoiInput) atCtVoiInput.Tag, atCtVoiInput, 'uni', false ), tCblTemplate(jj).tag );
%         
%                                 if aTagOffset(aTagOffset==1) % tag is a voi                        
%         
%                                     dTagOffset = find(aTagOffset, 1);
%         
%                                     if ~isempty(dTagOffset)
%         
%                                         copyRoiVoiToSerie(dCTSerieOffset, dNewSeriesOffset, atCtVoiInput{dTagOffset}, false);   
%                                         
%                                         bInitDisplay = true;
%                                     end
%                                 end    
%                             end
%                         end
                        
                    end
                end

            else
                if stDosimetry.contours.single == true

                    if ~isempty(stDosimetry.contours.offset)

                        sVoiTag = atVoiInput{stDosimetry.contours.offset}.Tag;
        
                        for jj=1:numel(tCblTemplate)

                            if strcmp(tCblTemplate(jj).tag, sVoiTag)

                                copyRoiVoiToSerie(dSerieOffset, dNewSeriesOffset, atVoiInput{stDosimetry.contours.offset}, false);
                                
                                bInitDisplay = true;
                                break;
                            end
                        end
                    end
                else
                
%                     if ~isempty(atVoiInput)
% 
%                         for tt=1:numel(atVoiInput)
% 
%                             copyRoiVoiToSerie(dSerieOffset, dNewSeriesOffset, atVoiInput{tt}, false);                   
%                             bInitDisplay = true;
%                         end                    
%                     end
%                    
%                     if ~isempty(atCtVoiInput)
% 
%                         for tt=1:numel(atCtVoiInput)
% 
%                             copyRoiVoiToSerie(dCTSerieOffset, dNewSeriesOffset, atCtVoiInput{tt}, false); 
%                             bInitDisplay = true;
%                         end                    
%                     end                
                end
            end

            if bInitDisplay == true    
    
                set(uiSeriesPtr('get'), 'Value', dNewSeriesOffset);
    
                cropValue('set', min(dicomBuffer('get', [], dNewSeriesOffset), [], 'all'));
        
                clearDisplay();                       
                initDisplay(3); 
            
                initWindowLevel('set', true);
            
                dicomViewerCore();  
                
                setViewerDefaultColor(1, atRtDoseHeader);
                   
                refreshImages();

                plotRotatedRoiOnMip(axesMipPtr('get', [], dNewSeriesOffset), dicomBuffer('get', [], dNewSeriesOffset), mipAngle('get'));       
               
                % Activate playback
               
                setPlaybackToolbar('on');
                       
                setRoiToolbar('on');
                
            end

            if stDosimetry.contours.all == true

                aEmptyMask = false(size(aLabelImage));
                
                aLabelImage=aLabelImage(:,:,end:-1:1);

                for jj=1:numel(tCblTemplate)
    
                    if isempty(tCblTemplate(jj).fileName) && ... 
                       isempty(tCblTemplate(jj).label)    && ... 
                       isempty(tCblTemplate(jj).tag) 
                        continue;
                    end

                    if isempty(tCblTemplate(jj).tag)                                            

                        aMask = aEmptyMask;
                        aMask(aLabelImage==tCblTemplate(jj).value)=true;                         
                        
                        aVoiColor = zeros(1,3);
                        aVoiColor(1) = tCblTemplate(jj).color.red;
                        aVoiColor(2) = tCblTemplate(jj).color.green;
                        aVoiColor(3) = tCblTemplate(jj).color.blue;
        
                        maskToVoi(aMask, tCblTemplate(jj).label,  tCblTemplate(jj).lesionType, aVoiColor, 'axial', dNewSeriesOffset, true);
    
                        clear aMask;
                    end
                    
                end

                clear aEmptyMask;

                refreshImages();
               
            end

        else
            progressBar( 1, 'Error: No physical model computed image found!');
            errordlg('No physical model computed image found!', 'Machine Learning Error');            
        end

    elseif isunix % Linux is not yet supported

        progressBar( 1, 'Error: Dosimetry under Linux is not yet supported');
        errordlg('Dosimetry under Linux is not yet supported', 'Machine Learning Validation');

    else % Mac is not yet supported

        progressBar( 1, 'Error: Dosimetry under Mac is not yet supported');
        errordlg('Dosimetry under Mac is not yet supported', 'Dosimetry Validation');
    end 

    progressBar(1, 'Ready');


    catch 
        progressBar( 1 , 'Error: computeVoxelDosimetry()' );
        errordlg('An error occur during the computation', 'Dosimetry Error');
    end
    
    clear aImage;
    clear aCTImage;

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

% if 0

    if stDosimetry.options.debugWindowMode == false

        % Delete temp folder    
        
        if exist(char(sTempInputDir), 'dir')

            rmdir(char(sTempInputDir), 's');
        end 
    end
% else
%     winopen(sTempInputDir);
% end
    
% %    progressBar(1, 'Ready');
% 
%     function aImage = rotateNrrdImage(aImage)
% 
%         if size(aImage, 3) ~=1    
%             aImage = imrotate3(aImage, 90, [0 0 1], 'nearest');
%             aImage = aImage(end:-1:1,:,:);
%         else
%             aImage = imrotate(aImage, 90, 'nearest');
%             aImage = aImage(end:-1:1,:);        
%         end
%     end

    function cancelRadiopharmaceuticalInformationSequenceCallback(~, ~)
        
        delete(dlgRadiopharmaceutical);
    end

    function setRadiopharmaceuticalInformationSequenceCallback(~, ~)

        if isempty(get(edtInjDateTime, 'string'))

            msgbox('Error: Please enter an injection date and time', 'Error');
            return;
        end

        if numel(get(edtInjDateTime, 'string')) ~= 17

            msgbox('Error: Please input in the format yyyyMMddHHmmss.SS', 'Error');
            return;
        end

        if isempty(get(edtHalfLife, 'string'))

            msgbox('Error: Please enter a half-life value', 'Error');
            return;
        end

        gsInjDateTime = get(edtInjDateTime, 'string');
        gsHalfLife    = str2double(get(edtHalfLife, 'string'));

        delete(dlgRadiopharmaceutical);
    end

    function cleanMachineLearningEmptyMask(sMachineLearingFolderPath)

        aFiles = dir(fullfile(sMachineLearingFolderPath, '*.*'));
    
        % Loop through each file
    
        for i = 1:length(aFiles)
            
            if aFiles(i).isdir % Skip folders (directories)
                continue;
            end

            sCurrentFile = fullfile(sMachineLearingFolderPath, aFiles(i).name);

            % Read the NIfTI file
            niftiData = niftiread(sCurrentFile);
        
            % Check if all elements in the 3D mask are zero
            if all(niftiData(:) == 0)
                % If all elements are zero, delete the file
                delete(sCurrentFile);
            end
        end
    end

    function [tCblTemplate, caCblParam] = segmentationlabelColorTableTemplate(atVoiInput, dSerieOffset, tMaterial, sMachineLearingFolderPath, sTissueDependantBackground, tCblTemplate, caCblParam)
        
        % First run

        if isempty(tCblTemplate) || isempty(caCblParam)

            rng(255);

            dCurrentLine = 1;
    
            sTissueDependantBackground = lower(sTissueDependantBackground);
    
            if isfield(tMaterial, sTissueDependantBackground)
    
                % Generate a random color for each iteration
                aColor = rand(1, 3);

                % Scale the color to the [255 255 255] range
                aColorScaled = round(aColor * 255);

                caCblParam{1} = sprintf('%d  %s %03d %03d %03d %03d %d %s', ...
                    dCurrentLine, ...
                    sTissueDependantBackground, ...
                    aColorScaled(1), ...
                    aColorScaled(2), ...
                    aColorScaled(3), ...
                    255, ...
                    tMaterial.(sTissueDependantBackground).density, ...
                    tMaterial.(sTissueDependantBackground).composition);
    
                tCblTemplate(dCurrentLine).fileName   = [];
                tCblTemplate(dCurrentLine).label      = [];
                tCblTemplate(dCurrentLine).tag        = [];
                tCblTemplate(dCurrentLine).series     = [];
                tCblTemplate(dCurrentLine).lesionType = 'Unspecified';

                tCblTemplate(dCurrentLine).color.red   = aColor(1);
                tCblTemplate(dCurrentLine).color.green = aColor(2);
                tCblTemplate(dCurrentLine).color.blue  = aColor(3);
                tCblTemplate(dCurrentLine).color.alpha  = 1;
    
                tCblTemplate(dCurrentLine).value  = dCurrentLine;
    
            else
                tCblTemplate(dCurrentLine).fileName   = [];
                tCblTemplate(dCurrentLine).label      = [];
                tCblTemplate(dCurrentLine).tag        = [];
                tCblTemplate(dCurrentLine).series     = [];
                tCblTemplate(dCurrentLine).lesionType = [];
             
                tCblTemplate(dCurrentLine).color    = [];
                tCblTemplate(dCurrentLine).value    = [];
            end
        else

            dCurrentLine = numel(tCblTemplate);            
        end

        dCurrentLine = dCurrentLine+1;
        

        if ~isempty(sMachineLearingFolderPath) % Machine Learning
    
            % Get a list of all files in the folder
    
            aFiles = dir(fullfile(sMachineLearingFolderPath, '*.*'));
        
            % Loop through each file
        
            for i = 1:length(aFiles)
                
                if aFiles(i).isdir % Skip folders (directories)
                    continue;
                end
        
                % Get the current file name
                sCurrentFile = aFiles(i).name;
                sCurrentFile = strrep(sCurrentFile, '.nii.gz', '');

                if strcmpi(sCurrentFile, sTissueDependantBackground)
                    continue;
                end

                if isfield(tMaterial, sCurrentFile)

                    % Generate a random color for each iteration
                    aColor = rand(1, 3);
    
                    % Scale the color to the [255 255 255] range
                    aColorScaled = round(aColor * 255);
    
                    sCurrentFile = cleanString(sCurrentFile, '_');

                    caCblParam{dCurrentLine} = sprintf('%d  %s %03d %03d %03d %03d %d %s', ...
                        dCurrentLine, ...
                        sCurrentFile, ...
                        aColorScaled(1), ...
                        aColorScaled(2), ...
                        aColorScaled(3), ...
                        255, ...
                        tMaterial.(sCurrentFile).density, ...
                        tMaterial.(sCurrentFile).composition);

                    tCblTemplate(dCurrentLine).fileName   = fullfile(sMachineLearingFolderPath,aFiles(i).name);
                    tCblTemplate(dCurrentLine).label      = sCurrentFile;
                    tCblTemplate(dCurrentLine).tag        = [];
                    tCblTemplate(dCurrentLine).series     = dSerieOffset;
                    tCblTemplate(dCurrentLine).lesionType = 'Unspecified';

                    tCblTemplate(dCurrentLine).color.red   = aColor(1);
                    tCblTemplate(dCurrentLine).color.green = aColor(2);
                    tCblTemplate(dCurrentLine).color.blue  = aColor(3);
                    tCblTemplate(dCurrentLine).color.alpha = 1;

                    tCblTemplate(dCurrentLine).value  = dCurrentLine;

                    dCurrentLine = dCurrentLine+1;   

                end
                
            end
  
        end

        % Add VOI 

        if ~isempty(atVoiInput)

            for j=1:numel(atVoiInput) % To do: We need to detect the tumor location and set a different density and composition.

%                 if isfield(tMaterial, 'tumor')
                    
                   aColor = atVoiInput{j}.Color;

                    % Scale the color to the [255 255 255] range
                    aColorScaled = round(aColor * 255);

                    sVoiLabel = cleanString(atVoiInput{j}.Label, '_');

                    if isfield(tMaterial, sVoiLabel)
                        sMaterial = sVoiLabel;
                    else
                        if numel(sVoiLabel) > 4
                            if isfield(tMaterial, sVoiLabel(1:end-4))
                                sMaterial = sVoiLabel(1:end-4);
                            else
                                sMaterial = 'tumor';                                                           
                            end
                        else
                            sMaterial = 'tumor';                            
                        end
                    end

                    caCblParam{dCurrentLine} = sprintf('%d  %s %03d %03d %03d %03d %d %s', ...
                        dCurrentLine, ...
                        sVoiLabel, ...
                        aColorScaled(1), ...
                        aColorScaled(2), ...
                        aColorScaled(3), ...
                        255, ...
                        tMaterial.(sMaterial).density, ...
                        tMaterial.(sMaterial).composition);

                   tCblTemplate(dCurrentLine).fileName   = [];
                   tCblTemplate(dCurrentLine).label      = sVoiLabel;
                   tCblTemplate(dCurrentLine).tag        = atVoiInput{j}.Tag;
                   tCblTemplate(dCurrentLine).series     = dSerieOffset;
                   tCblTemplate(dCurrentLine).lesionType = atVoiInput{j}.LesionType;

                   tCblTemplate(dCurrentLine).color.red    = aColor(1);
                   tCblTemplate(dCurrentLine).color.green  = aColor(2);
                   tCblTemplate(dCurrentLine).color.blue   = aColor(3);
                   tCblTemplate(dCurrentLine).color.alpha  = 1;

                   tCblTemplate(dCurrentLine).value  = dCurrentLine;

                   dCurrentLine = dCurrentLine+1;   

%                 end
            end
        end        
        
    end


    function aLabelImage = createSegmentationlabelImage(aLabelImage, atVoiInput, atRoiInput, atCblTemplate)


        if all(aLabelImage(:) == 0) % aLabelImage is empty

            % Set label background 
    
            if ~isempty(atCblTemplate(1).color)
    
                aLabelImage = repmat(atCblTemplate(1).value, size(aLabelImage));
            end

            dLabelOffset = 2;
        else
            dLabelOffset = 1;
        end

        for tp=dLabelOffset:numel(atCblTemplate)
            
            if ~isempty(atCblTemplate(tp).fileName)

                if exist(atCblTemplate(tp).fileName, 'file')

                    nii = nii_tool('load', atCblTemplate(tp).fileName);

                    aObjectMask = logical(imrotate3(nii.img, 90, [0 0 1], 'nearest'));          
                    aObjectMask = aObjectMask(:,:,end:-1:1);

                    aLabelImage(aObjectMask) = atCblTemplate(tp).value;
                end

            end

            if ~isempty(atCblTemplate(tp).tag)

                aVoiTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), atCblTemplate(tp).tag );
                dVoiTagOffset = find(aVoiTagOffset, 1);       

                if ~isempty(dVoiTagOffset)

                    aVoiMask = voiToMask(atVoiInput{dVoiTagOffset}, atRoiInput, false(size(aLabelImage)));

                    aLabelImage(aVoiMask==true) = atCblTemplate(tp).value;
                end
                
            end
        end
  
    end


    function aMask = voiToMask(ptrVoiInput, atRoiInput, aMask)

        for uu=1:numel(ptrVoiInput.RoisTag)
    
            aMaskTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), ptrVoiInput.RoisTag{uu} );
            dMaskTagOffset = find(aMaskTagOffset, 1);  

            if ~isempty(dMaskTagOffset)               

                ptrRoi = atRoiInput{dMaskTagOffset};

                switch lower(ptrRoi.Axe)    
                    
                    case 'axe'
                        imCData = aMask(:,:); 
                        roiMask = roiTemplateToMask(ptrRoi, imCData);  
                        aMask(:, :) = aMask(:, :)|roiMask;
          
                    case 'axes1'
                        imCData = permute(aMask(ptrRoi.SliceNb,:,:), [3 2 1]);
                        roiMask = roiTemplateToMask(ptrRoi, imCData);  
                        aMask(ptrRoi.SliceNb, :, :) = aMask(ptrRoi.SliceNb, :, :)|permuteBuffer(roiMask, 'coronal');
             
                    case 'axes2'
                        imCData = permute(aMask(:,ptrRoi.SliceNb,:), [3 1 2]);
                        roiMask = roiTemplateToMask(ptrRoi, imCData);  
                        aMask(:, ptrRoi.SliceNb, :) = aMask(:, ptrRoi.SliceNb, :)|permuteBuffer(roiMask, 'sagittal');
                    
                    case 'axes3'
                        imCData  = aMask(:,:,ptrRoi.SliceNb);  
                        roiMask = roiTemplateToMask(ptrRoi, imCData);  
                        aMask(:, :, ptrRoi.SliceNb) = aMask(:, :, ptrRoi.SliceNb)|roiMask;
  
                end
            end 
        end
    end


    function aLabelImage = resampleLabelImage(aLabelImage, atCTMetaData, aImage, atMetaData)

 
         [aLabelImage, atResampledLabelMetaData] = resampleImage(aLabelImage, atCTMetaData, aImage, atMetaData, 'Nearest', true, false);   
 
         if ~isequal(size(aImage), size(aLabelImage)) % Verify if both images are in the same field of view 
 
             aLabelImage = resample3DImage(aImage, atMetaData, aLabelImage, atResampledLabelMetaData, 'Nearest');
         end
    end

end