function convert3DSeriesToPlanar(sPlane, sMethod, dFromSlice, dToSlice)
%function convert3DSeriesToPlanar(sPlane, sMethod, dFromSlice, dToSlice)
%RConvert a 3D series to a planar series.
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
  
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    aOriginalImage    = dicomBuffer  ('get', [], dSeriesOffset);
    aOriginalMetaData = dicomMetaData('get', [], dSeriesOffset);      


    dXPixel = aOriginalMetaData{1}.PixelSpacing(1);
    dYPixel = aOriginalMetaData{1}.PixelSpacing(2);
    dZPixel = computeSliceSpacing(aOriginalMetaData);


    if strcmpi(sPlane, 'coronal')     
        
        switch lower(sMethod)
            case 'all slices max'
                aOriginalImage = aOriginalImage(dFromSlice:dToSlice,:,:);
                aNewImage = squeeze(max(aOriginalImage, [], 1));                  
                aNewImage = permute(aNewImage, [2 1]);

            case 'current slice'
                aNewImage = squeeze(permute(aOriginalImage(sliceNumber('get', 'coronal' ),:,:), [3 2 1]));  

            case 'all slices add'
                aOriginalImage = aOriginalImage(dFromSlice:dToSlice,:,:);
                aNewImage = squeeze(permute(aOriginalImage(1,:,:), [3 2 1]));  
                for jj=2:size(aOriginalImage, 2)
                    aNewImage = squeeze(permute(aOriginalImage(jj,:,:), [3 2 1]))+aNewImage;
                end                          
        end

        aOriginalMetaData{1}.PixelSpacing(1) = dZPixel;
        aOriginalMetaData{1}.PixelSpacing(2) = dXPixel;

    elseif strcmpi(sPlane, 'sagittal')     
        
        switch lower(sMethod)
            case 'all slices max'
                aOriginalImage = aOriginalImage(:,dFromSlice:dToSlice,:);
                aNewImage = squeeze(max(aOriginalImage, [], 2));
                aNewImage = permute(aNewImage, [2 1]);

            case 'current slice'
                aNewImage = squeeze(permute(aOriginalImage(:,sliceNumber('get', 'sagittal'),:), [3 1 2])); 

            case 'all slices add'
                aOriginalImage = aOriginalImage(:,dFromSlice:dToSlice,:);
                aNewImage = squeeze(permute(aOriginalImage(:,1,:), [3 1 2]));
                for jj=2:size(aOriginalImage, 2)
                    aNewImage = permute(aOriginalImage(:,jj,:), [3 1 2])+aNewImage;
                end                        
        end

        aOriginalMetaData{1}.PixelSpacing(1) = dZPixel;
        aOriginalMetaData{1}.PixelSpacing(2) = dYPixel;                
    else
%        aOriginalImageSize = size(aOriginalImage);

        switch lower(sMethod)
            case 'all slices max'
                aOriginalImage=aOriginalImage(:,:,end:-1:1);
                aOriginalImage = aOriginalImage(:,:,dFromSlice:dToSlice);
                aOriginalImage=aOriginalImage(:,:,end:-1:1);
                aNewImage = squeeze(max(aOriginalImage, [], 3));

            case 'current slice'
                aNewImage = squeeze(aOriginalImage(:,:,sliceNumber('get', 'axial'))); 

            case 'all slices add'
                aOriginalImage=aOriginalImage(:,:,end:-1:1);
                aOriginalImage = aOriginalImage(:,:,dFromSlice:dToSlice);
                aOriginalImage=aOriginalImage(:,:,end:-1:1);
                aNewImage = squeeze(aOriginalImage(:,:,1));
                for jj=2:size(aOriginalImage, 3)
                    aNewImage = squeeze(aOriginalImage(:,:,jj)+aNewImage);
                end
        end
        
        aOriginalMetaData{1}.PixelSpacing(1) = dXPixel;
        aOriginalMetaData{1}.PixelSpacing(2) = dYPixel;              
    end

    atInput = inputTemplate('get');

    atInput(numel(atInput)+1) = atInput(dSeriesOffset);

    atInput(numel(atInput)).bEdgeDetection = false;
    atInput(numel(atInput)).bDoseKernel    = false;    
    atInput(numel(atInput)).bFlipLeftRight = false;
    atInput(numel(atInput)).bFlipAntPost   = false;
    atInput(numel(atInput)).bFlipHeadFeet  = false;
    atInput(numel(atInput)).bMathApplied   = false;
    atInput(numel(atInput)).bFusedDoseKernel    = false;
    atInput(numel(atInput)).bFusedEdgeDetection = false;
    atInput(numel(atInput)).tMovement = [];
    atInput(numel(atInput)).tMovement.bMovementApplied = false;
    atInput(numel(atInput)).tMovement.aGeomtform = [];                
    atInput(numel(atInput)).tMovement.atSeq{1}.sAxe = [];
    atInput(numel(atInput)).tMovement.atSeq{1}.aTranslation = [];
    atInput(numel(atInput)).tMovement.atSeq{1}.dRotation = [];            
    atInput(numel(atInput)).aMip = [];

    atInput(numel(atInput)).atDicomInfo = aOriginalMetaData(1);

    asSeriesDescription = seriesDescription('get');
    asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('PLANAR %s', asSeriesDescription{dSeriesOffset});
    seriesDescription('set', asSeriesDescription);

    dSeriesInstanceUID = dicomuid;

    for hh=1:numel(atInput(numel(atInput)).atDicomInfo)
        atInput(numel(atInput)).atDicomInfo{hh}.Modality = 'ot';
        atInput(numel(atInput)).atDicomInfo{hh}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
        atInput(numel(atInput)).atDicomInfo{hh}.SeriesInstanceUID = dSeriesInstanceUID;
    end

% To reduce memory usage                
%    atInput(numel(atInput)).aDicomBuffer = aNewImage;
% To reduce memory usage                

    inputTemplate('set', atInput);

    aInputBuffer = inputBuffer('get');
    aInputBuffer{numel(aInputBuffer)+1} = aNewImage;
    inputBuffer('set', aInputBuffer);

    asSeries = get(uiSeriesPtr('get'), 'String');
    asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};
    set(uiSeriesPtr('get'), 'String', asSeries);
    set(uiFusedSeriesPtr('get'), 'String', asSeries);

    set(uiSeriesPtr('get'), 'Value', numel(atInput));
    dicomMetaData('set', atInput(numel(atInput)).atDicomInfo);
    dicomBuffer('set', aNewImage);
    setQuantification(numel(atInput));

    tQuant = quantificationTemplate('get');
    atInput(numel(atInput)).tQuant = tQuant;

    inputTemplate('set', atInput);
        
    clearDisplay();
    initDisplay(1);

    initWindowLevel('set', true);
    
    dicomViewerCore();
     
end