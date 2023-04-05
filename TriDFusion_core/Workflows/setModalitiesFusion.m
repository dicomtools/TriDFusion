function setModalitiesFusion(sModality1, sModality2)
%function setModalitiesFusion(sModality1, sModality2)
%Run fusion between 2 modalities. The second modality is use as resample source.
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
       
    dSerie1Offset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, sModality1)
            dSerie1Offset = tt;
            break
        end
    end

    dSerie2Offset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, sModality2)
            dSerie2Offset = tt;
            break
        end
    end

    if isempty(dSerie1Offset) || ...
       isempty(dSerie2Offset)  
        progressBar(1, sprintf('Error: Fusion of %s %s not detected!', sModality1, sModality2));
        errordlg(sprintf('Fusion of %s %s not detected!', sModality1, sModality2), 'Modality Validation');  
        return;               
    end


    atSerie1MetaData = dicomMetaData('get', [], dSerie1Offset);
    atSerie2MetaData = dicomMetaData('get', [], dSerie2Offset);

    aSerie1Image = dicomBuffer('get', [], dSerie1Offset);
    if isempty(aSerie1Image)
        aInputBuffer = inputBuffer('get');
        aSerie1Image = aInputBuffer{dSerie1Offset};
    end

    aSerie2Image = dicomBuffer('get', [], dSerie2Offset);
    if isempty(aSerie2Image)
        aInputBuffer = inputBuffer('get');
        aSerie2Image = aInputBuffer{dSerie2Offset};
    end

    if isempty(atSerie1MetaData)
        atSerie1MetaData = atInput(dSerie1Offset).atDicomInfo;
    end

    if isempty(atSerie2MetaData)
        atSerie2MetaData = atInput(dSerie2Offset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dSerie1Offset

        set(uiSeriesPtr('get'), 'Value', dSerie1Offset);

        setSeriesCallback();
    end
 
    try 

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    progressBar(1/4, 'Resampling series, please wait.');
            
    [aResampledImage, atResampledMetaData] = resampleImage(aSerie1Image, atSerie1MetaData, aSerie2Image, atSerie2MetaData, 'Linear', true, true);   
    
    dicomMetaData('set', atResampledMetaData, dSerie1Offset);
    dicomBuffer  ('set', aResampledImage, dSerie1Offset);


    progressBar(6/10, 'Resampling mip, please wait.');
            
    refMip = mipBuffer('get', [], dSerie2Offset);                        
    aMip   = mipBuffer('get', [], dSerie1Offset);
  
    aMip = resampleMip(aMip, atSerie1MetaData, refMip, atSerie2MetaData, 'Linear', true);
                   
    mipBuffer('set', aMip, dSerie1Offset);

    setQuantification(dSerie1Offset);    

    resampleAxes(aResampledImage, atResampledMetaData);

    setImagesAspectRatio();

    progressBar(2/4, 'Resampling roi, please wait.');
    
    atRoi = roiTemplate('get', dSerie1Offset);
    
    if ~isempty(atRoi)
        atResampledRois = resampleROIs(aSerie1Image, atSerie1MetaData, aResampledImage, atResampledMetaData, atRoi, true);

        roiTemplate('set', dSerie1Offset, atResampledRois);                   

        % Activate ROI Panel
    
        if viewRoiPanel('get') == false
            setViewRoiPanel();
        end

         % Triangulate og 1st VOI
    
        atVoiInput = voiTemplate('get', dSerie1Offset);
    
        if ~isempty(atVoiInput)
    
            dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);
    
            triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
        end

    end

    clear aResampledImage;


    % Deactivate MIP Fusion

    link2DMip('set', false);

    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 
    set(btnLinkMipPtr('get'), 'FontWeight', 'normal');

    progressBar(3/4, 'Set fusion, please wait.');

    % Set fusion 

    if isFusion('get') == false

        set(uiFusedSeriesPtr('get'), 'Value', dSerie2Offset);

        setFusionCallback();
    end


    refreshImages();

    clear aSerie1Image;
    clear aSerie2Image;
     

    progressBar(1, 'Ready');

    catch 
        resetSeries(dSerie2Offset, true);       
        progressBar( 1 , 'Error: setSegmentationFDG()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end