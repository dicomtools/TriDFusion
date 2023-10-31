function setMachineLearningFDHT(sSegmentatorScript, tFDHT)
%function setMachineLearningFDHT(sSegmentatorScript, tFDHT)
%Run FDHT threshold base segmentation with machine learning organ exclusion.
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

    gbProceedWithSegmentation = false;
    gdNormalLiverMean = [];
    gdNormalLiverSTD = [];

    atInput = inputTemplate('get');
    
    % Modality validation    
       
    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break
        end
    end

    dPTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
            dPTSerieOffset = tt;
            break
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)  
        progressBar(1, 'Error: FDHT tumor segmentation require a CT and PT image!');
        errordlg('FDHT tumor segmentation require a CT and PT image!', 'Modality Validation');  
        return;               
    end


    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    if isempty(atPTMetaData)
        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
    end

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 0;
    end 

    atRoiInput = roiTemplate('get', dPTSerieOffset);
   
    if ~isempty(atRoiInput)
        
        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Normal Liver'} );            
        dTagOffset = find(aTagOffset, 1);
        
        aSlice = [];
        
        if ~isempty(dTagOffset)
            
            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'                            
                    aSlice = permute(aPTImage(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    aSlice = permute(aPTImage(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                case 'axes3'
                    aSlice = aPTImage(:,:,atRoiInput{dTagOffset}.SliceNb);       
            end
            
            aLogicalMask = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);
                     
            gdNormalLiverMean = mean(aSlice(aLogicalMask), 'all')   * dSUVScale;


   %         H = fspecial('average',5); 
   %         blurred = imfilter(aSlice(aLogicalMask),H,'replicate'); 

            gdNormalLiverSTD = std(aSlice(aLogicalMask), [],'all') * dSUVScale;     
            
            clear aSlice;
        else
            waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));   

            FDHTNormalLiverMeanSDDialog();

            if gbProceedWithSegmentation == false
                return;
            end           
        end   
    else
        waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));   

        FDHTNormalLiverMeanSDDialog();

        if gbProceedWithSegmentation == false
            return;
        end
    end

    % Apply ROI constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dPTSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dPTSerieOffset);
    
    aPTImageTemp = aPTImage;
    aLogicalMask = roiConstraintToMask(aPTImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask); 
    aPTImageTemp(aLogicalMask==0) = 0;  % Set constraint 

    resetSeries(dPTSerieOffset, true);       

%     try 

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
    
    progressBar(1/8, 'DICOM to NII conversion, please wait.');

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

        progressBar(2/8, 'Machine learning in progress, this might take several minutes, please be patient.');
       
        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName)); 
    
        if ispc % Windows
      
%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);    
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);    
%            end
        
            [bStatus, sCmdout] = system(sCommandLine);
            
            if bStatus 
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed

                progressBar(4/8, 'Resampling series, please wait.');

                [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
                [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   

                dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);
            
                aResampledPTImage = aResampledPTImageTemp;

                clear aPTImageTemp;
                clear aResampledPTImageTemp;
            
                progressBar(5/8, 'Resampling mip, please wait.');
                        
                refMip = mipBuffer('get', [], dCTSerieOffset);                        
                aMip   = mipBuffer('get', [], dPTSerieOffset);
              
                aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                               
                mipBuffer('set', aMip, dPTSerieOffset);
            
                setQuantification(dPTSerieOffset);    
                       
                resampleAxes(aResampledPTImage, atResampledPTMetaData);
                
                setImagesAspectRatio();

                refreshImages();
                drawnow;

                progressBar(5/8, 'Computing ct map, please wait.');
            
                BWCT = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));
                BWCT = imfill(BWCT, 4, 'holes');
             
                if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view 

                    BWCT = resample3DImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                    BWCT = imbinarize(BWCT);

                    if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view 
                        BWCT = resizeMaskToImageSize(BWCT, aResampledPTImage); 
                    end
                else
                    BWCT = imbinarize(BWCT);
                end

%                 BWCT = resampleImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Linear', false, false);   
%                 BWCT = imageFieldOfView(BWCT, aResampledPTImage, atResampledPTMetaData); 


                progressBar(6/8, 'Importing exclusion masks, please wait.');

                aExcludeMask = getFDHTExcludeMask(tFDHT, sSegmentationFolderName, zeros(size(aCTImage)));
                aExcludeMask = imdilate(aExcludeMask, strel('sphere', 2)); % Increse mask by 2 pixels

                if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 

                     aExcludeMask = resample3DImage(aExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aExcludeMask = imbinarize(aExcludeMask);

                    if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                        aExcludeMask = resizeMaskToImageSize(aExcludeMask, aResampledPTImage); 
                    end
                else
                    aExcludeMask = imbinarize(aExcludeMask);                    
                end
%                 aExcludeMask = imageFieldOfView(aExcludeMask, aResampledPTImage, atResampledPTMetaData); 


                aResampledPTImage(aExcludeMask) = min(aResampledPTImage, [], 'all');  % Exclude mask

                clear aExcludeMask;


                progressBar(7/8, 'Computing mask, please wait.');
            
                aBWMask = aResampledPTImage;
            
                dMin = min(aBWMask, [], 'all');

                dTreshold = (1.5*gdNormalLiverMean) + (2*gdNormalLiverSTD);         
                if dTreshold < 3
                    dTreshold = 3;
                end

                aBWMask(aBWMask*dSUVScale<dTreshold)=dMin;
            
                aBWMask = imbinarize(aBWMask); 

                progressBar(8/10, 'Creating contours, please wait.');
            
                imMask = aResampledPTImage;
                imMask(aBWMask == 0) = dMin;
            
                setSeriesCallback();
            

                dSmalestVoiValue = tFDHT.options.smalestVoiValue;
                bPixelEdge = tFDHT.options.pixelEdge;

                sFormula = '(1.5 x Normal Liver SUVmean)+(2 x Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map';
                maskAddVoiToSeries(imMask, aBWMask, bPixelEdge, false, 0, false, 0, true, sFormula, BWCT, dSmalestVoiValue,  gdNormalLiverMean, gdNormalLiverSTD, 'TUMOR');    

                clear aResampledPTImage;
                clear aBWMask;
                clear refMip;                        
                clear aMip;
                clear BWCT;
                clear imMask;

            end

        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');
            errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');
            errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
        end

        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end         
    end

    setVoiRoiSegPopup();

    % Deactivate MIP Fusion

    link2DMip('set', false);

    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 
    set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
   
    % Set fusion

    if isFusion('get') == false

        set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

        setFusionCallback();
    end

    % Triangulate og 1st VOI

    atVoiInput = voiTemplate('get', dPTSerieOffset);

    if ~isempty(atVoiInput)

        dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

        triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
    end

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();

    clear aPTImage;
    clear aCTImage;

    % Delete .nii folder    
    
    if exist(char(sNiiTmpDir), 'dir')
        rmdir(char(sNiiTmpDir), 's');
    end       
    
    progressBar(1, 'Ready');

%     catch 
%         resetSeries(dPTSerieOffset, true);       
%         progressBar( 1 , 'Error: setSegmentationFDHT()' );
%     end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

      function FDHTNormalLiverMeanSDDialog()

        DLG_FDHT_MEAN_SD_X = 380;
        DLG_FDHT_MEAN_SD_Y = 150;
    
        dlgFDHTmeanSD = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_FDHT_MEAN_SD_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_FDHT_MEAN_SD_Y/2) ...
                                DLG_FDHT_MEAN_SD_X ...
                                DLG_FDHT_MEAN_SD_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'FDHT Segmentation Mean and SD',...
                   'Toolbar','none'...               
                   ); 

            % Normal Liver Mean
    
            uicontrol(dlgFDHTmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Mean',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 87 250 20]...
                      );
    
        edtFDHTNormalLiverMeanValue = ...
            uicontrol(dlgFDHTmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 90 75 20], ...
                      'String'  , num2str(FDHTNormalLiverMeanValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDHTNormalLiverMeanValueCallback ...
                      );

            % Normal Liver Standard Deviation
    
            uicontrol(dlgFDHTmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Standard Deviation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 62 250 20]...
                      );
    
        edtFDHTNormalLiverSDValue = ...
            uicontrol(dlgFDHTmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(FDHTNormalLiverSDValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDHTNormalLiverSDValueCallback ...
                      ); 

         % Cancel or Proceed
    
         uicontrol(dlgFDHTmeanSD,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelFDHTmeanSDCallback...
                   );
    
         uicontrol(dlgFDHTmeanSD,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedFDHTmeanSDCallback...
                  );

        waitfor(dlgFDHTmeanSD);

        function edtFDHTNormalLiverMeanValueCallback(~, ~)
    
            dMeanValue = str2double(get(edtFDHTNormalLiverMeanValue, 'Value'));
    
            if dMeanValue < 0 
                dMeanValue = 0.1;
                set(edtFDHTNormalLiverMeanValue, 'Value', num2str(dMeanValue));
            end
    
            FDHTNormalLiverMeanValue('set', dMeanValue);
        end
    
        function edtFDHTNormalLiverSDValueCallback(~, ~)
    
            dSDValue = str2double(get(edtFDHTNormalLiverSDValue, 'Value'));
    
            if dSDValue < 0 
                dSDValue = 0.1;
                set(edtFDHTNormalLiverSDValue, 'Value', num2str(dSDValue));
            end
    
            FDHTNormalLiverSDValue('set', dSDValue);
        end
    
        function proceedFDHTmeanSDCallback(~, ~)
    
            gdNormalLiverMean = str2double(get(edtFDHTNormalLiverMeanValue, 'String'));        
            gdNormalLiverSTD  = str2double(get(edtFDHTNormalLiverSDValue, 'String'));
    
            delete(dlgFDHTmeanSD);
            gbProceedWithSegmentation = true;      
        end
    
        function cancelFDHTmeanSDCallback(~, ~)
         
            delete(dlgFDHTmeanSD);
            gbProceedWithSegmentation = false;
        end
    end          
end