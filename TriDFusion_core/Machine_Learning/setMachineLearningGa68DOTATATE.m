function setMachineLearningGa68DOTATATE(sSegmentatorPath, tGa68DOTATATE, dNormalLiverTresholdMultiplier)
%function setMachineLearningGa68DOTATATE(sSegmentatorPath, tGa68DOTATATE, dNormalLiverTresholdMultiplier)
%Run machine learning Ga68 DOTATATE Segmentation.
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
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
            dPTSerieOffset = tt;
            break
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)  
        progressBar(1, 'Error: Ga68 DOTATATE segmentation require a CT and PT image!');
        errordlg('Ga68 DOTATATE segmentation require a CT and PT image!', 'Modality Validation');  
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
                     
            dNormalLiverMean = mean(aSlice(aLogicalMask), 'all')   * dSUVScale;
            dNormalLiverSTD  = std(aSlice(aLogicalMask), [],'all') * dSUVScale;     
            
            clear aSlice;
        else
            msgbox('Error: setMachineLearningGa68DOTATATE(): Please define a Normal Liver ROI. Draw a ROI on the normal liver, right click on it and select Predefined Label \ Normal Liver.', 'Error');   
            return;
        end   
    else
        msgbox('Error: setMachineLearningGa68DOTATATE(): Please define a Normal Liver ROI. Draw a ROI on the normal liver, right click on it and select Predefined Label \ Normal Liver.', 'Error');   
        return;
    end

    resetSeries(dPTSerieOffset, true);       

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

        progressBar(2/12, 'Machine learning in progress, this might take several minutes, please be patient.');
       
        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName)); 
    
        if ispc % Windows
      
%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast', sSegmentatorPath, sNiiFullFileName, sSegmentationFolderName);    
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast --force_split --body_seg', sSegmentatorPath, sNiiFullFileName, sSegmentationFolderName);    
%            end
        
            [bStatus, sCmdout] = system(sCommandLine);
            
            if bStatus 
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed

                progressBar(3/12, 'Importing exclusion masks, please wait.');

                aExcludeMask = getExcludeMask(tGa68DOTATATE, zeros(size(aCTImage)));


                progressBar(4/12, 'Importing liver mask, please wait.');
       
                aLiverMask   = getLiverMask(zeros(size(aCTImage)));

                aLiverMask =  imdilate(aLiverMask, strel('sphere', 3)); % Increse Liver mask by 3 pixels
                aExcludeMasksLiver = imdilate(aExcludeMask, strel('sphere', 1)); % Increse mask by 1 pixels

                progressBar(5/12, 'Resampling series, please wait.');
                        
                [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, true);   
                
                dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

                
                progressBar(6/12, 'Resampling roi, please wait.');

                atRoi = roiTemplate('get', dPTSerieOffset);

                atResampledRoi = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true);

                roiTemplate('set', dPTSerieOffset, atResampledRoi);  


                progressBar(7/12, 'Resampling mip, please wait.');
                        
                refMip = mipBuffer('get', [], dCTSerieOffset);                        
                aMip   = mipBuffer('get', [], dPTSerieOffset);
              
                aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                               
                mipBuffer('set', aMip, dPTSerieOffset);

                setQuantification(dPTSerieOffset);    


                progressBar(8/12, 'Computing liver mask, please wait.');

                dLiverTreshold = (1.5*dNormalLiverMean) + (2*dNormalLiverSTD);
%                dLiverTreshold = (dNormalLiverTresholdMultiplier*dNormalLiverMean);

%                dLiverTreshold = (2*dLiverMean)

                aLiverBWMask = aResampledPTImage;
    
                dMin = min(aLiverBWMask, [], 'all');

                aLiverBWMask(aLiverBWMask*dSUVScale<dLiverTreshold)=dMin;

                aLiverBWMask = imbinarize(aLiverBWMask);
  
                aLiverBWMask(aLiverMask==0)=0; 
                aLiverBWMask(aExcludeMasksLiver~=0)=0; 


                progressBar(9/12, 'Computing wholebody mask, please wait.');

                dWholebodyTreshold = 3;

                aExcludeMasksWholebody = imdilate(aExcludeMask, strel('sphere', 3)); % Increse mask by 3 pixels

                aWholebodyBWMask = aResampledPTImage;

                dMin = min(aWholebodyBWMask, [], 'all');
          
                aWholebodyBWMask(aWholebodyBWMask*dSUVScale<dWholebodyTreshold) = dMin;
                aWholebodyBWMask = imbinarize(aWholebodyBWMask);

                aWholebodyBWMask(aExcludeMasksWholebody~=0)=0;
                aWholebodyBWMask(aLiverMask~=0)=0;


                progressBar(10/12, 'Computing ct map, please wait.');
                
                BWCT = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));

                if ~aCTImage(aCTImage~=0) % If wholeBody mask fail
                    BWCT = aCTImage;
    
                    BWCT(BWCT < 100) = 0;                                    
                    BWCT = imfill(BWCT, 4, 'holes');                       
            
                    BWCT(BWCT~=0) = 1;
                    BWCT(BWCT~=1) = 0;
                end


                progressBar(11/12, 'Creating contours, please wait.');

                imMask = aResampledPTImage;
                imMask(aWholebodyBWMask == 0) = dMin;

                dSmalestVoiValue = 0.3;

                setSeriesCallback();

                sFormula = '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map';

                maskAddVoiToSeries(imMask, aWholebodyBWMask, true, false, dWholebodyTreshold, false, 0, true, sFormula, BWCT, dSmalestVoiValue, dNormalLiverMean, dNormalLiverSTD);                    

                sFormula = 'Liver';

                imMaskLiver = aResampledPTImage;
                imMaskLiver(aLiverBWMask == 0) = dMin;

                maskAddVoiToSeries(imMaskLiver, aLiverBWMask, true, false, dLiverTreshold, false, 0, false, sFormula, BWCT, dSmalestVoiValue);                    

                clear aExcludeMask;
                clear aExcludeMasksLiver;
                clear aExcludeMasksWholebody;
                clear aLiverMask;
                clear aResampledPTImage;
                clear aWholebodyBWMask;
                clear aLiverBWMask;
                clear refMip;                        
                clear aMip;
                clear BWCT;
                clear imMask;
                clear imMaskLiver;
           end


        elseif isunix % Linux is not yet supported

            progressBar( 1, 'Error: Machine Learning under Linux is not supported');
            errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

        else % Mac is not yet supported

            progressBar( 1, 'Error: Machine Learning under Mac is not supported');
            errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
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

    catch 
        resetSeries(dPTSerieOffset, true);       
        progressBar( 1 , 'Error: setMachineLearningGa68DOTATATE()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function aLiverMask = getLiverMask(aLiverMask)

        % Liver

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aLiverMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
        end 

        aLiverMask=aLiverMask(:,:,end:-1:1);
   end

    function aExcludeMask = getExcludeMask(tGa68DOTATATE, aExcludeMask)

        % Brain

        if tGa68DOTATATE.organ.brain == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'brain.nii.gz');  

            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Trachea

        if tGa68DOTATATE.organ.trachea == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'trachea.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Adrenal gland left

        if tGa68DOTATATE.organ.adrenalGlandLeft == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'adrenal_gland_left.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Adrenal gland right

        if tGa68DOTATATE.organ.adrenalGlandRight == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'adrenal_gland_right.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Spleen

        if tGa68DOTATATE.organ.spleen == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'spleen.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Gallbladder

        if tGa68DOTATATE.organ.gallbladder == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'gallbladder.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end   

        % Pancreas

        if tGa68DOTATATE.organ.pancreas == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'pancreas.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end 

        % kidney Left

        if tGa68DOTATATE.organ.kidneyLeft == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_left.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end 

        % kidney Right

        if tGa68DOTATATE.organ.kidneyRight == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_right.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end 

        % Gastrointestinal Tract Name

        % Urinary Bladder

        if tGa68DOTATATE.gastrointestinal.urinaryBladder == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'urinary_bladder.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end 

        % Esophagus

        if tGa68DOTATATE.gastrointestinal.esophagus == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'esophagus.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end    

        % Stomach

        if tGa68DOTATATE.gastrointestinal.stomach == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'stomach.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end     

        % Duodenum

        if tGa68DOTATATE.gastrointestinal.duodenum == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'duodenum.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Small Bowel

        if tGa68DOTATATE.gastrointestinal.smallBowel == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'small_bowel.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end

        % Colon

        if tGa68DOTATATE.gastrointestinal.colon == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'colon.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end  

        % Urinary Bladder

        if tGa68DOTATATE.gastrointestinal.urinaryBladder == true

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'urinary_bladder.nii.gz');
        
            if exist(sNiiFileName, 'file')

                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;

                clear aObjectMask;
                clear nii;
            end
        end                  
        
        aExcludeMask=aExcludeMask(:,:,end:-1:1);

    end

end