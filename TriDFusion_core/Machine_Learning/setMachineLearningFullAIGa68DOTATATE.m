function setMachineLearningFullAIGa68DOTATATE(sSegmentatorScript, sOnnxPath, dModel, tGa68DOTATATE)
%function setMachineLearningFullAIGa68DOTATATE(sSegmentatorScript, sOnnxPath, dModel, tGa68DOTATATE)
%Run machine learning full AI Ga68 DOTATATE Segmentation.
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
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt') || ...
           strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')     
            dPTSerieOffset = tt;
            break
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)  
        progressBar(1, 'Error: Ga68 DOTATATE full AI segmentation require a CT and PT image!');
        errordlg('Ga68 DOTATATE full AI segmentation require a CT and PT image!', 'Modality Validation');  
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

    resetSeries(dPTSerieOffset, true);       

    try 

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    % Get DICOM directory directory    
    
    [sCTFilePath, ~, ~] = fileparts(char(atInput(dCTSerieOffset).asFilesList{1}));
    
    if dModel == 2 || tGa68DOTATATE.classification.enable == true

        % Create an empty directory    
    
        sCTNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sCTNiiTmpDir), 'dir')
            rmdir(char(sCTNiiTmpDir), 's');
        end
        mkdir(char(sCTNiiTmpDir));    
        
        % Convert CT dicom to .nii     
        
        progressBar(1/13, 'CT DICOM to NII conversion, please wait.');
    
        dicm2nii(sCTFilePath, sCTNiiTmpDir, 1);
        
        sCTNiiFullFileName = '';
        
        f = java.io.File(char(sCTNiiTmpDir)); % Get .nii file name
        dinfo = f.listFiles();                   
        for K = 1 : 1 : numel(dinfo)
            if ~(dinfo(K).isDirectory)
                if contains(sprintf('%s%s', sCTNiiTmpDir, dinfo(K).getName()), '.nii.gz')
                    sCTNiiFullFileName = sprintf('%s%s', sCTNiiTmpDir, dinfo(K).getName());
                    break;
                end
            end
        end  
    else
        sCTNiiTmpDir = '';
        sCTNiiFullFileName = '';
    end

    % Get DICOM directory directory    
    
    [sPTFilePath, ~, ~] = fileparts(char(atInput(dPTSerieOffset).asFilesList{1}));
    
    % Create an empty directory    

    sPTNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sPTNiiTmpDir), 'dir')
        rmdir(char(sPTNiiTmpDir), 's');
    end
    mkdir(char(sPTNiiTmpDir));    
    
    % Convert PT dicom to .nii     
    
    progressBar(2/13, 'PT DICOM to NII conversion, please wait.');

    dicm2nii(sPTFilePath, sPTNiiTmpDir, 1);
    
    sPTNiiFullFileName = '';
    
    f = java.io.File(char(sPTNiiTmpDir)); % Get .nii file name
    dinfo = f.listFiles();                   
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sPTNiiTmpDir, dinfo(K).getName()), '.nii.gz')
                sPTNiiFullFileName = sprintf('%s%s', sPTNiiTmpDir, dinfo(K).getName());
                break;
            end
        end
    end 

    if isempty(sCTNiiFullFileName) && isempty(sPTNiiFullFileName)
        
        progressBar(1, 'Error: nii file mot found!');
        errordlg('nii file mot found!!', '.nii file Validation'); 
    else

        progressBar(2/13, 'Machine learning classification in progress, this might take several minutes, please be patient.');
       
        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName)); 
    
        if ispc % Windows
      
            if tGa68DOTATATE.classification.enable == true 
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sCTNiiFullFileName, sSegmentationFolderName);    
        
                [bStatus, sCmdout] = system(sCommandLine);
            else
                bStatus = false;
            end
       
            if bStatus 
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed

                progressBar(3/13, 'Machine learning prediction in progress, this might take several minutes, please be patient.');

                sOnnxFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
                if exist(char(sOnnxFolderName), 'dir')
                    rmdir(char(sOnnxFolderName), 's');
                end
                mkdir(char(sOnnxFolderName)); 

                sOnnxOutputFileName = sprintf('%s/pet_ac_onnx_prediction.nii.gz', sOnnxFolderName);
                if dModel ==1
                    sCommandLine = sprintf('cmd.exe /c python.exe %srun_onnx_model.py -i %s -o %s', sOnnxPath, sPTNiiFullFileName, sOnnxOutputFileName);    
                else
                    sCommandLine = sprintf('cmd.exe /c python.exe %srun_onnx_model.py -i %s %s -o %s', sOnnxPath, sPTNiiFullFileName, sCTNiiFullFileName, sOnnxOutputFileName);    
                end
                [bStatus, sCmdout] = system(sCommandLine);

                if bStatus 
                    progressBar( 1, 'Error: An error occur during machine learning prediction!');
%                    errordlg(sprintf('An error occur during machine learning prediction: %s', sCmdout), 'Segmentation Error');  
                    errordlg(sprintf('An error occur during machine learning prediction'), 'Segmentation Error');  
                else % Process succeed
              
                    if exist(sOnnxOutputFileName, 'file')

                        progressBar(4/13, 'Importing prediction, please wait.');
          
                        nii = nii_tool('load', sOnnxOutputFileName);
                        aOnnxOutputMask = imrotate3(double(nii.img), 90, [0 0 1], 'nearest');
            
                        aOnnxOutputMask(aOnnxOutputMask~=0)=1;
            
                        clear nii;
                
                        aOnnxOutputMask = aOnnxOutputMask(:,:,end:-1:1);
  
                        if tGa68DOTATATE.classification.enable == true 

                            progressBar(5/13, 'Importing liver mask, please wait.');
                   
                            aLiverMask = getLiverMask(zeros(size(aCTImage)), sSegmentationFolderName);
            
                            aLiverMask =  imdilate(aLiverMask, strel('sphere', 4)); % Increse Liver mask by 3 pixels
    
    
                            progressBar(6/13, 'Computing bone map, please wait.');
                            
                            aBoneMask = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));
                            aBoneMask = imfill(aBoneMask, 4, 'holes');                       
%                            aBoneMask = imdilate(aBoneMask, strel('sphere', 1)); % Increse Liver mask by 3 pixels

                        end      


                        progressBar(7/13, 'Resampling series, please wait.');
                                
                        [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
                       
                        dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                        dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);
   
                        
%                         progressBar(8/13, 'Resampling roi, please wait.');
%         
%                         atRoi = roiTemplate('get', dPTSerieOffset);
%         
%                         atResampledRoi = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true);
%         
%                         roiTemplate('set', dPTSerieOffset, atResampledRoi);  
        
        
                        progressBar(9/13, 'Resampling mip, please wait.');
                                
                        refMip = mipBuffer('get', [], dCTSerieOffset);                        
                        aMip   = mipBuffer('get', [], dPTSerieOffset);
                      
                        aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                                       
                        mipBuffer('set', aMip, dPTSerieOffset);
        
                        setQuantification(dPTSerieOffset);            

                        progressBar(10/13, 'Resampling mask, please wait.');

                        setSeriesCallback();

                        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                        drawnow;

                        [aOnnxOutputMask, ~] = resampleImage(aOnnxOutputMask, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   

                        if tGa68DOTATATE.options.smoothMask == true
                            aOnnxOutputMask = smooth3DMask(aOnnxOutputMask, 1.0, 5 ,0.1);
                        end

                        if tGa68DOTATATE.classification.enable == true 

                            if ~isequal(size(aBoneMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
                        
                                 aBoneMask = resample3DImage(aBoneMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                                 aBoneMask = imbinarize(aBoneMask);
                        
                                if ~isequal(size(aBoneMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                                    aBoneMask = resizeMaskToImageSize(aBoneMask, aResampledPTImage); 
                                end
                            else
                                aBoneMask = imbinarize(aBoneMask);
                            end

                            if ~isequal(size(aLiverMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
                        
                                 aLiverMask = resample3DImage(aLiverMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                                 aLiverMask = imbinarize(aLiverMask);
                        
                                if ~isequal(size(aLiverMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                                    aLiverMask = resizeMaskToImageSize(aLiverMask, aResampledPTImage); 
                                end
                            else
                                aLiverMask = imbinarize(aLiverMask);
                            end

                            progressBar(11/13, 'Importing exclusion masks, please wait.');
            
                            aExcludeMask = getGa68DOTATATEExcludeMask(tGa68DOTATATE, sSegmentationFolderName, zeros(size(aCTImage)));

                            if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
                        
                                 aExcludeMask = resample3DImage(aExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                                 aExcludeMask = imbinarize(aExcludeMask);
                        
                                if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                                    aExcludeMask = resizeMaskToImageSize(aExcludeMask, aResampledPTImage); 
                                end
                            else
                                aExcludeMask = imbinarize(aExcludeMask);
                            end

                            aOnnxOutputMask(aExcludeMask) = 0;
                            
                            clear aExcludeMask;

                            progressBar(12/13, 'Classifying mask, please wait.');

                            if tGa68DOTATATE.classification.enhancedBoneMaskLesion == true

                                tQuant = quantificationTemplate('get');
                            
                                if isfield(tQuant, 'tSUV')
    
                                    dSUVScale = tQuant.tSUV.dScale;
    
                                    aWholebodyBWMask = zeros(size(aResampledPTImage));
                                    aWholebodyBWMask(aBoneMask) = aResampledPTImage(aBoneMask);
    
                                    aWholebodyBWMask(aWholebodyBWMask*dSUVScale < 3) = 0;                                
                                    aWholebodyBWMask(aWholebodyBWMask~=0)=1;

                                    aWholebodyBWMask(aLiverMask)=0;
                                    aOnnxOutputMask = aOnnxOutputMask | logical(aWholebodyBWMask);
                                    
                                    clear aWholebodyBWMask;
                                end
                            end

                            aClassificationMask = ones(size(aOnnxOutputMask)); % Soft Tissue
                            aClassificationMask(aBoneMask)  = 2; % Bone
                            aClassificationMask(aLiverMask) = 3; % Liver

                            clear aLiverMask;
                            clear aBoneMask;
                        else
                            aClassificationMask = []; % Soft Tissue
                        end

                        maskImageToVoi(aOnnxOutputMask, dPTSerieOffset, aClassificationMask, tGa68DOTATATE.classification.enable, tGa68DOTATATE.options.pixelEdge, tGa68DOTATATE.options.smalestVoiValue);

                        clear aOnnxOutputMask;
                        clear aClassificationMask;
                        clear aResampledPTImage;
                   end

                end

                if exist(char(sOnnxFolderName), 'dir')
                    rmdir(char(sOnnxFolderName), 's');
                end 
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

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end 

    % Set TCS Axes intensity

    dMin = 0/dSUVScale;
    dMax = 10/dSUVScale;

    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    setWindowMinMax(dMax, dMin);                    

    dMin = 0/dSUVScale;
    dMax = 20/dSUVScale;

    % Set MIP Axe intensity

    set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);                  
    

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

    [dMax, dMin] = computeWindowLevel(500, 50);

    fusionWindowLevel('set', 'max', dMax);
    fusionWindowLevel('set', 'min', dMin);

    setFusionWindowMinMax(dMax, dMin);                    

%     [dLevelMax, dLevelMin] = computeWindowLevel(2500, 415);
%     set(axesMipfPtr('get', [], dOffset), 'CLim', [dLevelMin dLevelMax]);

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
    
    if exist(char(sCTNiiTmpDir), 'dir')
        rmdir(char(sCTNiiTmpDir), 's');
    end       

    if exist(char(sPTNiiTmpDir), 'dir')
        rmdir(char(sPTNiiTmpDir), 's');
    end 

    progressBar(1, 'Ready');
 
     catch 
         resetSeries(dPTSerieOffset, true);       
         progressBar( 1 , 'Error: setMachineLearningFullAIGa68DOTATATE()' );
     end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function aLiverMask = getLiverMask(aLiverMask, sSegmentationFolderName)

        % Liver

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aLiverMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
        end 

        aLiverMask=aLiverMask(:,:,end:-1:1);
    end
end