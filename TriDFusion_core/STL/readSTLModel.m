function readSTLModel(sPath, sFile, xBufSize, yBufSize, zBufSize, dPixelValue, bFillHoles)
%function readSTLModel(sPath, sFile, xBufSize, yBufSize, zBufSize, dPixelValue, bFillHoles)
%Read .stl Model.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    tInput = inputTemplate('get');
    atDcmMetaData = dicomMetaData('get');   

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(inputTemplate('get'))  
        return;
    end 

    progressBar(0.999999, 'Processing import stl, please wait');

    FV = stlread(sprintf('%s%s', sPath, sFile));            

%        aVolume = polygon2voxel(FV, [xBufSize yBufSize zBufSize], 'auto');
    aVolume = polygon2voxel(FV, [xBufSize yBufSize zBufSize], 'auto');
    if bFillHoles == true
        aVolume = imfill(aVolume, 'holes');
    end
    aVolume = aVolume(:,:,end:-1:1);
    aVolume = double(aVolume);
    aVolume(aVolume~=0) = dPixelValue;

if 0        
        x = aspectRatioValue('get', 'x');
        y = aspectRatioValue('get', 'y');
        z = aspectRatioValue('get', 'z');                                                                    

        if  strcmp(imageOrientation('get'), 'axial')   

            aScaleFactors = [x y z];    
        elseif strcmp(imageOrientation('get'), 'coronal' )                           

            aScaleFactors = [y z x];   
        elseif strcmp(imageOrientation('get'), 'sagittal') 

            aScaleFactors = [x z y];
        end

        dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

        dimsRef = size(aVolume);        
        dimsDcm = size(aVolume); 
        dimsRef(1) =  dimsRef(1)*aScaleFactors(1);
        dimsRef(2) =  dimsRef(2)*aScaleFactors(2);
        dimsRef(3) =  dimsRef(3)*aScaleFactors(3);

        f = diag([dimsRef(:) ./ dimsDcm(:);1]);

        TF = affine3d(f);

        Rdcm  = imref3d(size(aVolume),atDcmMetaData{1}.PixelSpacing(2),atDcmMetaData{1}.PixelSpacing(1),dcmSliceThickness);

        sMode = 'linear';
        [resampImage, ~] = imwarp(aVolume, Rdcm, TF, 'Interp', sMode, 'FillValues', cropValue('get'));          
        aVolume = resampImage;
end        

    tInput(numel(tInput)+1) = tInput(iSeriesOffset);
    tInput(numel(tInput)).atDicomInfo = atDcmMetaData;

    asSeriesDescription = seriesDescription('get');
    asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('STL-%s', sFile);
    seriesDescription('set', asSeriesDescription);

    for jj=1:numel(tInput(numel(tInput)).atDicomInfo)
        tInput(numel(tInput)).atDicomInfo{jj}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
        tInput(numel(tInput)).atDicomInfo{jj}.Modality = 'OT';
   %     tInput(numel(tInput)).atDicomInfo{jj}.PixelSpacing(1) = 1;
   %     tInput(numel(tInput)).atDicomInfo{jj}.PixelSpacing(2) = 1;
   %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(1)=0;
   %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(2)=0;
   %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(3)=jj;
    end

    inputTemplate('set', tInput);

    aInputBuffer = inputBuffer('get');        
    aInputBuffer{numel(aInputBuffer)+1} = aVolume;    
    inputBuffer('set', aInputBuffer);

    asSeries = get(uiSeriesPtr('get'), 'String');
    asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};
    set(uiSeriesPtr('get'), 'String', asSeries);
    set(uiFusedSeriesPtr('get'), 'String', asSeries);

    set(uiSeriesPtr('get'), 'Value', numel(tInput));
    dicomMetaData('set', tInput(numel(tInput)).atDicomInfo);
    dicomBuffer('set', aVolume);
    setQuantification(numel(tInput));

    tQuant = quantificationTemplate('get');
    tInput(numel(tInput)).tQuant = tQuant;
    inputTemplate('set', tInput);  

    clearDisplay();                       
    initDisplay(3); 

    initWindowLevel('set', true);

    dicomViewerCore();  

    triangulateCallback();            

    refreshImages();     

    progressBar(1, sprintf('Import %s completed', sFile));

end