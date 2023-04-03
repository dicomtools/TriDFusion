function setSegmentationFDG()
%function setSegmentationFDG()
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
        progressBar(1, 'Error: FDG tumor segmentation require a CT and PT image!');
        errordlg('FDG tumor segmentation require a CT and PT image!', 'Modality Validation');  
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
    
    resetSeries(dPTSerieOffset, true);       

    try 

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    progressBar(5/10, 'Resampling series, please wait.');
            
    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, true);   
    
    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);


    progressBar(6/10, 'Resampling mip, please wait.');
            
    refMip = mipBuffer('get', [], dCTSerieOffset);                        
    aMip   = mipBuffer('get', [], dPTSerieOffset);
  
    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);
                   
    mipBuffer('set', aMip, dPTSerieOffset);

    setQuantification(dPTSerieOffset);    


    progressBar(7/10, 'Computing liver mask, please wait.');

    dTreshold = 4; % SUV treshold


    aBWMask = aResampledPTImage;

    dMin = min(aBWMask, [], 'all');

    aBWMask(aBWMask*dSUVScale<dTreshold)=dMin;

    aBWMask = imbinarize(aBWMask);

    progressBar(8/10, 'Computing ct map, please wait.');

    BWCT = aCTImage;

    BWCT(BWCT < 100) = 0;                                    
    BWCT = imfill(BWCT, 4, 'holes');                       

    BWCT(BWCT~=0) = 1;
    BWCT(BWCT~=1) = 0;

    progressBar(9/10, 'Creating contours, please wait.');

    imMask = aResampledPTImage;
    imMask(aBWMask == 0) = dMin;

    dSmalestVoiValue = 0;

    setSeriesCallback();

    sFormula = 'CT Bone Map';

    maskAddVoiToSeries(imMask, aBWMask, true, false, dTreshold, false, 0, false, sFormula, BWCT, dSmalestVoiValue);                    
  

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