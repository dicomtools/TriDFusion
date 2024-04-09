function setMachineLearningFDGBrownFatSUV(sSegmentatorScript, sSegmentatorCombineMasks, tBrownFatSUV)
%function setMachineLearningFDGBrownFatSUV(sSegmentatorScript, sSegmentatorCombineMasks, tBrownFatSUV)
%Run FDG brown Fat Segmentation base on a SUV treshold.
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

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)  
        progressBar(1, 'Error: FDG brown fat segmentation require a CT and PT image!');
        errordlg('FDG brown fat segmentation require a CT and PT image!', 'Modality Validation');  
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

    % Apply ROI constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dPTSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dPTSerieOffset);
    
    aPTImageTemp = aPTImage;
    aLogicalMask = roiConstraintToMask(aPTImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask); 
    aPTImageTemp(aLogicalMask==0) = 0;  % Set constraint 

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
%                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);    
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s --fast --force_split --body_seg', sSegmentatorScript, sNiiFullFileName, sSegmentationFolderName);    
%            end
        
            [bStatus, sCmdout] = system(sCommandLine);
            
            if bStatus 
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed

                progressBar(3/12, 'Importing organ exclusion mask, please wait.');

                aExcludeMask = getBrownFatSUVExcludeMask(tBrownFatSUV, sSegmentationFolderName, sSegmentatorCombineMasks, zeros(size(aCTImage)));

                if tBrownFatSUV.exclude.organ.skeleton == true

                    progressBar(4/12, 'Importing bone exclusion mask, please wait.');

                    aBoneExcludeMask = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, zeros(size(aCTImage)));
                    aBoneExcludeMask = imfill(aBoneExcludeMask, 4, 'holes');   

%                     aBoneExcludeMask = imdilate(aBoneExcludeMask, strel('sphere', 2)); % Increse mask by 2 pixels

                    aExcludeMask(aBoneExcludeMask~=0) = 1;

                    clear aBoneExcludeMask;
                end

                progressBar(5/12, 'Processing image constraints, please wait.');

                % Top bottom image constraint

%                dLowerSlice = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'liver', 'lower');
                dLowerSlice = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'sacrum', 'upper');

                if ~isempty(dLowerSlice)
                    if dLowerSlice > 1 && dLowerSlice < size(aExcludeMask, 3)
                        aExcludeMask(:,:,dLowerSlice:end) = 1;
                    end
                end

                dUpperSlice = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'skull' , 'lower')-5;

                if ~isempty(dUpperSlice)
                    if dUpperSlice > 1 && dUpperSlice < size(aExcludeMask, 3)
    
                        aExcludeMask(:,:,1:dUpperSlice) = 1;
                    end
                end

                % Left right image constraint

                 dLeftColumn  = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'humerus_left' , 'left' )+25;
                 dRightColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'humerus_right', 'right')-25;
%                 dLeftColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'spleen', 'right');
%                 dRightColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'liver', 'left');

                if ~isempty(dLeftColumn)

                    if dLeftColumn > 1 && dLeftColumn < size(aExcludeMask, 2)
                        aExcludeMask(:,dLeftColumn:end,:) = 1;
                    end
%                 else
%                     dLeftColumn  = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'humerus_left' , 'left' );
%                     
%                     if ~isempty(dLeftColumn)
%     
%                         if dLeftColumn > 1 && dLeftColumn < size(aExcludeMask, 2)
%                             aExcludeMask(:,dLeftColumn:end,:) = 1;
%                         end
%                     end
                end

                if ~isempty(dRightColumn)

                    if dRightColumn > 1 && dRightColumn < size(aExcludeMask, 2)
                        aExcludeMask(:,1:dRightColumn,:) = 1;   
                    end
%                 else
%                     dRightColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'humerus_right', 'right');
% 
%                     if ~isempty(dRightColumn)
%     
%                         if dRightColumn > 1 && dRightColumn < size(aExcludeMask, 2)
%                             aExcludeMask(:,1:dRightColumn,:) = 1;   
%                         end
%                     end
                end                

                % C Vertebrae constraint

                dC4LeftColumn  = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'vertebrae_C4', 'right');
                dC4RightColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'vertebrae_C4', 'left' );

                dLowerSliceC7 = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'vertebrae_C7' , 'lower');

                if ~isempty(dC4LeftColumn)  && ...
                   ~isempty(dC4RightColumn) && ...    
                   ~isempty(dLowerSliceC7)
     
                    for ll=1:dLowerSliceC7
                        
                        aExcludeMask(:,dC4RightColumn:dC4LeftColumn,ll) = 1;
                    end
                end

                % Heart constraint

                dHeartLeftColumn  = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'heart', 'right');
                dHeartRightColumn = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'heart', 'left' );

                dHeartSlice = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'heart' , 'lower');

                if ~isempty(dHeartLeftColumn) && ...
                   ~isempty(dHeartRightColumn)  && ...    
                   ~isempty(dHeartSlice)
     
                    aMaskSize = size(aExcludeMask);         
                    
                    if dHeartLeftColumn  < aMaskSize(2) && ...
                       dHeartRightColumn < aMaskSize(2)

                        % Removed 15 slices beneith the heart

                        if dHeartSlice + 15 < aMaskSize(3)

                            for ll=1:15
                                
                                aExcludeMask(:,dHeartRightColumn:dHeartLeftColumn , dHeartSlice+ll) = 1;
    
                            end
                        end
                    end
                end
                
                % Under the liver, kidneys constraint

                dKidneyRight = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'kidney_right', 'left');
                dKidneyLeft  = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, 'kidney_left' , 'right');

                dLiverSlice = getTotalSegmentorObjectSliceNumber(sSegmentationFolderName, 'liver' , 'lower');

                if ~isempty(dKidneyRight) && ...
                   ~isempty(dKidneyLeft)  && ...    
                   ~isempty(dLiverSlice)
     
                    aMaskSize = size(aExcludeMask);         
                    
                    if dKidneyRight < aMaskSize(2) && ...
                       dKidneyLeft  < aMaskSize(2)

                        if dLiverSlice < aMaskSize(3)
                            for ll=1:dLiverSlice
                                
        %                         aExcludeMask(:,dKidneyRight:dKidneyLeft,aMaskZsize-ll) = 1;
                                aExcludeMask(:,1:dKidneyRight ,aMaskSize(3)-ll) = 1;
                                aExcludeMask(:,dKidneyLeft:end,aMaskSize(3)-ll) = 1;
                            end
                        end
                    end
                end
% if 0
%                 progressBar(5/12, 'Computing fuzzy c-means clustering, please wait.');
% 
%                 aFuzzImage = fuzzy3DSegmentation(aPTImage);
% %                 aFuzzImage = aFuzzImage >= tBrownFatSUV.options.fuzzyClusterSelection;
%                 aFuzzImage = aFuzzImage >= 2;
% 
% %                 aFuzzImage(aFuzzImage<4)= min(aFuzzImage, [], 'all');
% %                 aFuzzImage = imbinarize(aFuzzImage);
% 
%                 aPTImageTemp(aFuzzImage==0) = min(aPTImageTemp, [], 'all');   
% 
%                 clear aFuzzImage;
% end
                progressBar(6/12, 'Processing CT HU constraint, please wait.');

                aExcludeMask(aCTImage < tBrownFatSUV.options.HUThreshold.min) = 1;
                aExcludeMask(aCTImage > tBrownFatSUV.options.HUThreshold.max) = 1;


                progressBar(7/12, 'Resampling series, please wait.');

                [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
                [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   

                dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);
    
                aResampledPTImage = aResampledPTImageTemp;

                if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
            
                     aExcludeMask = resample3DImage(aExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
                     aExcludeMask = imbinarize(aExcludeMask);
            
                    if ~isequal(size(aExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                        
                        aExcludeMask = resizeMaskToImageSize(aExcludeMask, aResampledPTImage); 
                    end
                else
                    aExcludeMask = imbinarize(aExcludeMask);
                end

                aResampledPTImage(aExcludeMask) = min(aResampledPTImage, [], 'all');

% if 1                    
%                 progressBar(7/12, 'Computing CT HU exclusion mask, please wait.');
% 
%                 aHUExcludeMask = zeros(size(aCTImage));
% 
%                 aHUExcludeMask(aCTImage < tBrownFatSUV.options.HUThreshold.min) = 1;
%                 aHUExcludeMask(aCTImage > tBrownFatSUV.options.HUThreshold.max) = 1;
% 
% %                 aHUExcludeMask = imdilate(aHUExcludeMask, strel('sphere', 4)); % Increse mask by 4 pixels
% 
%                 if ~isequal(size(aHUExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
%             
%                      aHUExcludeMask = resample3DImage(aHUExcludeMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
%                      aHUExcludeMask = imbinarize(aHUExcludeMask);
%             
%                     if ~isequal(size(aHUExcludeMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
% 
%                         aHUExcludeMask = resizeMaskToImageSize(aHUExcludeMask, aResampledPTImage); 
%                     end
%                 else
%                     aHUExcludeMask = imbinarize(aHUExcludeMask);
%                 end
% 
%                 aResampledPTImage(aHUExcludeMask) = min(aResampledPTImage, [], 'all');
% 
%                 clear aHUExcludeMask;
% 
% end
                progressBar(8/12, 'Computing CT BW mask, please wait.');

                BWCT = imbinarize(aCTImage);

%                 dCTMin = min(aCTImage, [], 'all');
% 
%                 aCTImage(aCTImage < tBrownFatSUV.options.HUThreshold.min) = dCTMin;
%                 aCTImage(aCTImage > tBrownFatSUV.options.HUThreshold.max) = dCTMin;
%                  
%                 aResampledPTImage(aCTImage==dCTMin) = min(aResampledPTImage, [], 'all');

                clear aPTImageTemp;
                clear aResampledPTImageTemp;
                clear aExcludeMask;
            
                progressBar(9/12, 'Resampling mip, please wait.');
                        
                refMip = mipBuffer('get', [], dCTSerieOffset);                        
                aMip   = mipBuffer('get', [], dPTSerieOffset);
              
                aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                               
                mipBuffer('set', aMip, dPTSerieOffset);
            
                setQuantification(dPTSerieOffset);    
            
            
                progressBar(10/12, 'Computing SUV mask, please wait.');
            
% 
%                 aBWMask = aResampledPTImage;
%             
%                 dMin = min(aResampledPTImage, [], 'all');
% 
%                 aBWMask(aBWMask*dSUVScale<dTreshold) = dMin;
%      
%                 aBWMask = imbinarize(aBWMask);
         
                dMin = min(aResampledPTImage, [], 'all');
                dTreshold = tBrownFatSUV.options.SUVThreshold;

                imMask = aResampledPTImage;
                imMask(imMask*dSUVScale<dTreshold) = dMin;

                aBWMask = imbinarize(imMask);

                progressBar(11/12, 'Creating contours, please wait.');

                setSeriesCallback();
            
                sFormula = [];

                dSmalestVoiValue = tBrownFatSUV.options.smalestVoiValue;
                bPixelEdge = tBrownFatSUV.options.pixelEdge;

                maskAddVoiToSeries(imMask, aBWMask, bPixelEdge, false, dTreshold, false, 0, false, sFormula, BWCT, dSmalestVoiValue); 

                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                drawnow;    

                aBrownFatMask = getBrownFatTotalSegmentorAnnotationMask(sSegmentationFolderName, zeros(size(aCTImage)));

                atVoiInput = voiTemplate('get', dPTSerieOffset);
                atRoiInput = roiTemplate('get', dPTSerieOffset);

                if ~isequal(size(aBrownFatMask), size(aResampledPTImage)) % Verify if both images are in the same field of view 
            
                     aBrownFatMask = resample3DImage(aBrownFatMask, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
            
                    if ~isequal(size(aBrownFatMask), size(aResampledPTImage)) % Verify if both images are in the same field of view     
                        aBrownFatMask = resizeMaskToImageSize(aBrownFatMask, aResampledPTImage); 
                    end

                end

                [atVoiInput, atRoiInput] = setBrownFatVoiTypeMask(aBrownFatMask, atVoiInput, atRoiInput);

                voiTemplate('set', dPTSerieOffset, atVoiInput);
                roiTemplate('set', dPTSerieOffset, atRoiInput);

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

    catch 
        resetSeries(dPTSerieOffset, true);       
        progressBar( 1 , 'Error: setSegmentationFDGBrownFatSUV()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
   
    function aMask = getBrownFatTotalSegmentorAnnotationMask(sSegmentationFolderName, aMask)

        asSegmentList = {
        'rib_left_1.nii.gz',...
        'rib_left_2.nii.gz',...
        'rib_left_3.nii.gz',...
        'rib_left_4.nii.gz',...
        'rib_left_5.nii.gz',...
        'rib_left_6.nii.gz',...
        'rib_left_7.nii.gz',...
        'rib_left_8.nii.gz',...
        'rib_left_9.nii.gz',...
        'rib_left_10.nii.gz',...
        'rib_left_11.nii.gz',...
        'rib_left_12.nii.gz',...
        'rib_right_1.nii.gz',...
        'rib_right_2.nii.gz',...
        'rib_right_3.nii.gz',...
        'rib_right_4.nii.gz',...
        'rib_right_5.nii.gz',...
        'rib_right_6.nii.gz',...
        'rib_right_7.nii.gz',...
        'rib_right_8.nii.gz',...
        'rib_right_9.nii.gz',...
        'rib_right_10.nii.gz',...
        'rib_right_11.nii.gz',...
        'rib_right_12.nii.gz',...              
        'vertebrae_C1.nii.gz',...
        'vertebrae_C2.nii.gz',...
        'vertebrae_C3.nii.gz',...
        'vertebrae_C4.nii.gz',...
        'vertebrae_C5.nii.gz',...
        'vertebrae_C6.nii.gz',...
        'vertebrae_C7.nii.gz',...    
        'vertebrae_T1.nii.gz',...
        'vertebrae_T2.nii.gz',...
        'vertebrae_T3.nii.gz',...
        'vertebrae_T4.nii.gz',...
        'vertebrae_T5.nii.gz',...
        'vertebrae_T6.nii.gz',...
        'vertebrae_T7.nii.gz',...
        'vertebrae_T8.nii.gz',...
        'vertebrae_T9.nii.gz',...   
        'vertebrae_T10.nii.gz',...
        'vertebrae_T11.nii.gz',...
        'vertebrae_T12.nii.gz',...        
        'clavicula_right.nii.gz', ...
        'clavicula_left.nii.gz', ...
        'kidney_right.nii.gz', ...
        'kidney_left.nii.gz', ...  
        'scapula_right.nii.gz',...
        'scapula_left.nii.gz', ...
        'scapula.nii.gz', ...
        'sternum.nii.gz'};
     
        dNbElements = numel(asSegmentList);

        for bb=1:dNbElements

            if mod(bb,5)==1 || bb == 1 || bb == dNbElements
                
                progressBar( bb/dNbElements-0.0001, sprintf('Computing association item %d/%d, please wait.', bb, dNbElements) );
            end

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, asSegmentList{bb});  
    
            if exist(sNiiFileName, 'file')
    
                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
   
                if contains(asSegmentList{bb}, 'vertebrae_C') 
                    dMaskValue =1;

                elseif contains(asSegmentList{bb}, 'vertebrae_T') 
                    dMaskValue =2;               

                elseif contains(asSegmentList{bb}, 'clavicula')
                    dMaskValue =3;

                elseif contains(asSegmentList{bb}, 'kidney')
                    dMaskValue =4;

                elseif contains(asSegmentList{bb}, 'scapula')
                    dMaskValue =5;

                elseif contains(asSegmentList{bb}, 'sternum')
                    dMaskValue =6;     

                elseif contains(asSegmentList{bb}, 'rib')
                    dMaskValue =7;                     
                else
                    dMaskValue =0;                     
               end
                    
                aMask(aObjectMask~=0)=dMaskValue;
            end
        end

        aMask=aMask(:,:,end:-1:1);

        progressBar( 1, 'Ready' );

    end

    function [atVoiInput, atRoiInput] = setBrownFatVoiTypeMask(aAnnotatedMask, atVoiInput, atRoiInput)

        dNbElements = numel(atVoiInput);

        for cc=1:dNbElements

            if mod(cc,5)==1 || cc == 1 || cc == dNbElements
                
                progressBar( cc/dNbElements-0.0001, sprintf('Associating contour %d/%d, please wait.', cc, dNbElements) );
            end

            ptrVoiInput = atVoiInput{cc};

            imVoiMask = zeros(size(aAnnotatedMask));

            adRoiTags = zeros(1, numel(ptrVoiInput.RoisTag));
            dNbTags = numel(ptrVoiInput.RoisTag);

            for uu=1:dNbTags
        
                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrVoiInput.RoisTag{uu}]} );

                dOffset = find(aTagOffset, 1);

                ptrRoi = atRoiInput{dOffset};

                adRoiTags(uu) = dOffset;

                switch lower(ptrRoi.Axe)    

                    case 'axe'

                    imVoiMask(:, :) = imVoiMask(:, :)| aRoiLogicalMask;
        
                    case 'axes1'

                    aSlice = permute(aAnnotatedMask(ptrRoi.SliceNb,:,:), [3 2 1]);
                    
                    aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);

                    imVoiMask(ptrRoi.SliceNb, :, :) = imVoiMask(ptrRoi.SliceNb, :, :)|permuteBuffer(aRoiLogicalMask, 'coronal');
                    
                    case 'axes2'

                    aSlice = permute(aAnnotatedMask(:,ptrRoi.SliceNb,:), [3 1 2]) ;

                    aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);
             
                    imVoiMask(:, ptrRoi.SliceNb, :) = imVoiMask(:, ptrRoi.SliceNb, :)|permuteBuffer(aRoiLogicalMask, 'sagittal');
                    
                    case 'axes3'
                    
                    aSlice  = aAnnotatedMask(:,:,ptrRoi.SliceNb);  
                    
                    aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);

                    imVoiMask(:, :, ptrRoi.SliceNb) = imVoiMask(:, :, ptrRoi.SliceNb)|aRoiLogicalMask;
                end 

            end

            dClosestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask);

            switch dClosestMaskIndex

                case 1 % vertebrae_C
                    sLesionType = 'Cervical';

                case 2 % vertebrae_T
                    sLesionType = 'Paraspinal';

                case 3 % clavicula
                    sLesionType = 'Supraclavicular';

                case 4 % Kidneys
                    sLesionType = 'Abdominal';

                case 5 % scapula
                    sLesionType = 'Axillary';

                case 6 % sternum
                    sLesionType = 'Mediastinal';

                case 7 % ribs
                    sLesionType = 'Mediastinal';
            end

            sLesionShortName = '';
            [bLesionOffset, ~, asLesionShortName] = getLesionType(sLesionType);   
            for jj=1:numel(asLesionShortName)
                if contains(atVoiInput{cc}.Label, asLesionShortName{jj})
                    sLesionShortName = asLesionShortName{jj};
                    break;
                end
            end  

            for uu=1:dNbTags
       
                atRoiInput{adRoiTags(uu)}.LesionType = sLesionType;
                atRoiInput{adRoiTags(uu)}.Label = replace(atRoiInput{adRoiTags(uu)}.Label, sLesionShortName, asLesionShortName{bLesionOffset});      
            end

            atVoiInput{cc}.LesionType = sLesionType;
            atVoiInput{cc}.Label = replace(atVoiInput{cc}.Label, sLesionShortName, asLesionShortName{bLesionOffset});

        end

        progressBar( 1, 'Ready' );

    
    end

%     function closestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask)
%         
%         % Get the unique values in the annotated mask
%         uniqueValues = unique(aAnnotatedMask(:));
%     
%         % Remove 0 if it exists (assuming 0 is not a valid zone)
%         uniqueValues(uniqueValues == 0) = [];
%     
%         % Initialize the closest distance and index
%         closestDistance = inf;
%         closestMaskIndex = -1;
%     
%         % Iterate over each unique zone in the annotated mask
%         for i = 1:length(uniqueValues)
%             % Create a binary mask for the current zone
%             zoneMask = aAnnotatedMask == uniqueValues(i);
%     
%             % Calculate the distance to the voxel with value 1 in imVoiMask
%             distance = bwdist(zoneMask, 'euclidean');
%     
%             % Consider only the distances within the masked region
%             distanceInMask = distance(imVoiMask > 0);
%     
%             % Find the minimum distance within the masked region
%             minDistanceInMask = min(distanceInMask);
%     
%             % Update the closest distance and index if needed
%             if minDistanceInMask < closestDistance
%                 closestDistance = minDistanceInMask;
%                 closestMaskIndex = uniqueValues(i);
%             end
%         end
%     end

    function closestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask)

        % Get the unique values in the annotated mask excluding 0
        uniqueValues = unique(aAnnotatedMask(aAnnotatedMask > 0));
    
        % Find non-zero indices in imVoiMask
        [rows, cols, slices] = ind2sub(size(imVoiMask), find(imVoiMask > 0));
    
        % Initialize the closest distance and index

        closestDistance  = inf;
        closestMaskIndex = -1;
    
        % Iterate over each unique zone in the annotated mask

        for i = 1:length(uniqueValues)
            
            % Find indices of the current zone in aAnnotatedMask
            zoneIndices = find(aAnnotatedMask == uniqueValues(i));
    
            % Get coordinates of the points in the current zone
            [zoneRows, zoneCols, zoneSlices] = ind2sub(size(aAnnotatedMask), zoneIndices);
    
            % Create matrices of coordinates for pdist2
            maskPoints = [zoneRows, zoneCols, zoneSlices];
            voiPoints = [rows, cols, slices];
    
            % Compute pairwise distances between points
            distances = pdist2(maskPoints, voiPoints, 'euclidean');
    
            % Find the minimum distance within the masked region
            minDistanceInMask = min(distances(:));
    
            % Update the closest distance and index if needed
            if minDistanceInMask < closestDistance
                closestDistance = minDistanceInMask;
                closestMaskIndex = uniqueValues(i);
            end
        end
    end
end