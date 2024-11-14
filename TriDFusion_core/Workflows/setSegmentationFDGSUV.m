function setSegmentationFDGSUV(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, dThreshold , dBoneThreshold)
%function setSegmentationFDGSUV(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, dThreshold , dBoneThreshold)
%Run FDG Segmentation base on a SUV Threshold .
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
        progressBar(1, 'Error: FDG SUV tumor segmentation require a CT and PT image!');
        errordlg('FDG SUV tumor segmentation require a CT and PT image!', 'Modality Validation');  
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
    
    if isInterpolated('get') == false
    
        isInterpolated('set', true);
    
        setImageInterpolation(true);
    end

    progressBar(5/10, 'Resampling series, please wait.');
            
    [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);   
   
    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

    aResampledPTImage = aResampledPTImageTemp;

    clear aPTImageTemp;
    clear aResampledPTImageTemp;


    progressBar(6/10, 'Resampling mip, please wait.');
            
    refMip = mipBuffer('get', [], dCTSerieOffset);                        
    aMip   = mipBuffer('get', [], dPTSerieOffset);
  
    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                   
    mipBuffer('set', aMip, dPTSerieOffset);

    setQuantification(dPTSerieOffset);    


    progressBar(7/10, 'Computing mask, please wait.');


    aBWMask = aResampledPTImage;

    dMin = min(aBWMask, [], 'all');

    aBWMask(aBWMask*dSUVScale<dThreshold )=dMin;

    aBWMask = imbinarize(aBWMask);

    progressBar(8/10, 'Computing ct map, please wait.');

    BWCT = aCTImage;
    BWCT(BWCT < dBoneMaskThreshold) = 0;                                    
    BWCT = imfill(BWCT, 4, 'holes'); 

%     % Thresholding to create a binary mask
%     BWCT = BWCT >= dBoneMaskThreshold;
%     
%     % Perform morphological closing to smooth contours and fill small gaps
%     se = strel('disk', 3); % Adjust the size as needed
%     BWCT = imclose(BWCT, se);
%     
%     % Fill holes in the binary image
%     BWCT = imfill(BWCT, 'holes');
%     
%     % Optional: Remove small objects that are not part of the bone
%     BWCT = bwareaopen(BWCT, 100); % Adjust the size threshold as needed
%     
%     % Perform another round of morphological closing if necessary
%     BWCT = imclose(BWCT, se);
%     
%     % Optional: Perform morphological opening to remove small spurious regions
%     BWCT = imopen(BWCT, se);

    if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view 

        BWCT = resample3DImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');
        
        BWCT = imbinarize(BWCT);

        if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view     
            BWCT = resizeMaskToImageSize(BWCT, aResampledPTImage); 
        end
    else
        BWCT = imbinarize(BWCT);
    end

    progressBar(9/10, 'Creating contours, please wait.');

    imMask = aResampledPTImage;
%     imMask(aBWMask == 0) = dMin;

    if dBoneThreshold ~= dThreshold
        aBWMask2 = aResampledPTImage;
    
        dMin = min(aBWMask2, [], 'all');
    
        aBWMask2(aBWMask2*dSUVScale<dBoneThreshold)=dMin;
%         aBWMask2(BWCT==0)=dMin;
    
%         aBWMask2 = imbinarize(aBWMask2);
%     
%         imMask(aBWMask2) = aResampledPTImage(aBWMask2);
    
        aBWMask = aBWMask|aBWMask2;
    
        clear aBWMask2;
    end

    setSeriesCallback();

    sFormula = 'Lymph Nodes & Bone SUV, CT Bone Map';

    maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, dThreshold , false, 0, true, sFormula, BWCT, dSmalestVoiValue, [],[],[], dBoneThreshold);                    

    clear aResampledPTImage;
    clear aBWMask;
    clear refMip;                        
    clear aMip;
    clear BWCT;
    clear imMask;


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
    
    plotRotatedRoiOnMip(axesMipPtr('get', [], dPTSerieOffset), dicomBuffer('get', [], dPTSerieOffset), mipAngle('get'));       

    clear aPTImage;
    clear aCTImage;
     

    progressBar(1, 'Ready');

    catch 
        resetSeries(dPTSerieOffset, true);       
        progressBar( 1 , 'Error: setSegmentationFDG()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end