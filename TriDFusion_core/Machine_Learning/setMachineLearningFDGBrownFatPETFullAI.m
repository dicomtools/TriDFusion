function setMachineLearningFDGBrownFatPETFullAI(sPredictScript, tBrownFatFullAI)
%function setMachineLearningFDGBrownFatPETFullAI(sPredictScript, tBrownFatFullAI)
%Run FDG brown Fat PET Full AI Segmentation.
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

    if isempty(dPTSerieOffset)        
        progressBar(1, 'Error: FDG brown fat full AI segmentation require a PT image!');
        errordlg('FDG brown fat full AI segmentation require a PT image!', 'Modality Validation');  
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

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
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
    
    
    % Create an empty directory    

    sNrrdTmpDir = sprintf('%stemp_nrrd_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end
    mkdir(char(sNrrdTmpDir));    
    
    % Convert dicom to .nii     
    
    progressBar(1/10, 'DICOM to NRRD conversion, please wait.');

    sNrrdImagesName = sprintf('%sPT_0001.nrrd', sNrrdTmpDir);

    dSUVconv = computeSUV(atPTMetaData, 'LBM');

    if dSUVconv == 0
        dSUVconv = computeSUV(atPTMetaData, 'BW');
    end

    if dSUVconv == 0
        dSUVconv = 1;
    end

    series2nrrd(dPTSerieOffset, sNrrdImagesName, dSUVconv);
    
    sNrrdFullFileName = '';
    
    f = java.io.File(char(sNrrdTmpDir)); % Get .nii file name
    dinfo = f.listFiles();                   
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            if contains(sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName()), '.nrrd')
                sNrrdFullFileName = sprintf('%s%s', sNrrdTmpDir, dinfo(K).getName());
                break;
            end
        end
    end 

    if isempty(sNrrdFullFileName)
        
        progressBar(1, 'Error: nrrd file mot found!');
        errordlg('nrrd file mot found!!', '.nrrd file Validation'); 
    else

        progressBar(2/10, 'Machine learning in progress, this might take several minutes, please be patient.');
       
        sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sSegmentationFolderName), 'dir')
            rmdir(char(sSegmentationFolderName), 's');
        end
        mkdir(char(sSegmentationFolderName)); 
    
        if ispc % Windows
%            if fastMachineLearningDialog('get') == true
%                sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --fast', sPredictScript, sNiiFullFileName, sSegmentationFolderName);    
%            else
                sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s -d 098 -c 3d_fullres --save_probabilities', sPredictScript, sNrrdTmpDir, sSegmentationFolderName);    
%            end
        
            [bStatus, sCmdout] = system(sCommandLine);
            
            if bStatus 
                progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed


                progressBar(3/10, 'Importing prediction, please wait.');

                [aMask, ~] = nrrdread( sprintf('%sPT.nrrd',sSegmentationFolderName));
            
                aMask = aMask(:,:,end:-1:1);
                
                dSmalestValue = tBrownFatFullAI.options.smalestVoiValue;
                bPixelEdge    = tBrownFatFullAI.options.pixelEdge;
     

                progressBar(4/10, 'Segmenting prediction mask, please wait.');

                maskAddBrownFatVoiToSeries(aPTImageTemp, aMask, atPTMetaData, dPTSerieOffset, dSmalestValue, bPixelEdge);
                
                clear aPTImageTemp;

                if exist(char(sSegmentationFolderName), 'dir')
            
                    rmdir(char(sSegmentationFolderName), 's');
                end    

                if ~isempty(aCTImage)

                    progressBar(5/10, 'Resampling series, please wait.');
    
                    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
    
                    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
                    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

                    progressBar(6/10, 'Resampling mip, please wait.');
                        
                    refMip = mipBuffer('get', [], dCTSerieOffset);                        
                    aMip   = mipBuffer('get', [], dPTSerieOffset);
                  
                    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                                   
                    mipBuffer('set', aMip, dPTSerieOffset);
                
                    setQuantification(dPTSerieOffset);     

                    progressBar(7/10, 'Resampling contours, please wait.');


                    atRoi = roiTemplate('get', dPTSerieOffset);
    
                    atResampledRoi = resampleROIs(aPTImage, atPTMetaData, aResampledPTImage, atResampledPTMetaData, atRoi, true);
    
                    roiTemplate('set', dPTSerieOffset, atResampledRoi); 

                    progressBar(8/10, 'Resampling axes, please wait.');

                    resampleAxes(aResampledPTImage, atResampledPTMetaData);

                    setImagesAspectRatio();

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

    % Deactivate MIP Fusion

    link2DMip('set', false);

    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 
    set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
   
    % Set fusion
    if ~isempty(aCTImage)
        
        progressBar(9/10, 'Processing fusion, please wait.');

        if isFusion('get') == false
    
            set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);
    
            setFusionCallback();
        end
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
    
    if exist(char(sNrrdTmpDir), 'dir')

        rmdir(char(sNrrdTmpDir), 's');
    end       
    
    progressBar(1, 'Ready');

    catch 
        resetSeries(dPTSerieOffset, true);       
        progressBar( 1 , 'Error: setMachineLearningFDGBrownFatFullAI()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
   
    function maskAddBrownFatVoiToSeries(aImage, aMask, atMetaData, dSeriesOffset, dSmalestValue, bPixelEdge)

        PIXEL_EDGE_RATIO = 3;

        dPixelSizeX = atMetaData{1}.PixelSpacing(1);
        if dPixelSizeX == 0 
            dPixelSizeX = 1;
        end
        
        dPixelSizeY = atMetaData{1}.PixelSpacing(2);
        if dPixelSizeY == 0 
            dPixelSizeY = 1;
        end                    
        
        dPixelSizeZ = computeSliceSpacing(atMetaData);
        if dPixelSizeZ == 0  
            dPixelSizeZ = 1;
        end            
    
        dVoxelSize = dPixelSizeX * dPixelSizeY * dPixelSizeZ;
        
        dSmalestValueNbVoxels = round(dSmalestValue/(dVoxelSize/1000)); % In ml
     
        aBWImage = imbinarize(aImage);

        aBWImage(aMask==0) = 0;

        CC = bwconncomp(aBWImage, 26);
        dNbElements = numel(CC.PixelIdxList);

        for bb=1:dNbElements  % Nb VOI

            if mod(bb,5)==1 || bb == 1 || bb == dNbElements
  
                progressBar( bb/dNbElements-0.0001, sprintf('Computing contour %d/%d, please wait.', bb, dNbElements) );
            end   

            BW = zeros(size(aBWImage));
    
            BW(CC.PixelIdxList{bb}) = aBWImage(CC.PixelIdxList{bb});

            asTag = [];
    
            xmin=0.5;
            xmax=1;
            aColor=xmin+rand(1,3)*(xmax-xmin);
        
            aPixelsList = find(BW);
            if numel(aPixelsList) < dSmalestValueNbVoxels
                continue;
            end
    
            [~,~,adSlices] = ind2sub(size(BW), aPixelsList);
            adSlices = unique(adSlices);                
            
            dNbComputedSlices = numel(adSlices);

            sLesionType = getMaskLessionType(aMask(CC.PixelIdxList{bb}));
    
            for aa=1:dNbComputedSlices % Find ROI
    
                if cancelCreateVoiRoiPanel('get') == true
                    break;
                end
    
                dCurrentSlice = adSlices(aa);
    
                aAxial = BW(:, :, dCurrentSlice);

                if bPixelEdge == true
                    aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                [maskAxial, ~, dNbSlicesElements] = bwboundaries(aAxial, 8, 'noholes');                    
                                 
                for jj=1:dNbSlicesElements
    
                    if cancelCreateVoiRoiPanel('get') == true
                        break;
                    end
    
                    if bPixelEdge == true
                        maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;
                        maskAxial{jj} = reducepoly(maskAxial{jj});
                    end   
    
                    curentMask = maskAxial(jj);
        
                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
    
                    aPosition = flip(curentMask{1}, 2);

                    if bPixelEdge == false
                
                        aPosition = smoothRoi(aPosition, size(aImage));
                    end
    
                    sliceNumber('set', 'axial', dCurrentSlice);
                    
                    roiPtr = images.roi.Freehand(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'Smoothing', 1, 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', roiFaceAlphaValue('get'), 'Visible', 'off');
                    roiPtr.Waypoints(:) = false;                    
    
                    addRoi(roiPtr, get(uiSeriesPtr('get'), 'Value'), sLesionType);
    
                    roiDefaultMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);
    
                    constraintMenu(roiPtr);
    
                    cropMenu(roiPtr);
    
                    voiMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
                                           
                    asTag{numel(asTag)+1} = sTag;

                    if viewRoiPanel('get') == true
                        drawnow limitrate;
                    end
                end
            end

            if ~isempty(asTag)
    
                if exist('sVOIName', 'var')
                    sLabel = sprintf('%s %d', sVOIName, bb);
                else
                    sLabel = sprintf('VOI%d', bb);
                end
    
                createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
            end  

            clear BW;
        end

        clear aBWImage;
    end

    function  sLesionType = getMaskLessionType(aMask)

        dLesionTypeOffset = max(aMask(aMask~=0), [], 'all');

        switch dLesionTypeOffset

            case 1
                sLesionType = 'Cervical';

            case 2
                sLesionType = 'Supraclavicular';

            case 3
                sLesionType = 'Mediastinal';

            case 4
                sLesionType = 'Paraspinal';

            case 5
                sLesionType = 'Axillary';

            case 6
                sLesionType = 'Abdominal';

            otherwise
                sLesionType = 'Unknow';
            
        end

    end
end