function voiObj = initVoiIsoSurface(uiWindow)
%function voiObj = initVoiIsoSurface(uiWindow)
%Create ISO Surface Objects from VOIs.
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

    voiObj = '';

    atMetaData = dicomMetaData('get');            
    tInput = inputTemplate('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput)
        return;
    end

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false
        return;
    end

    volObj = volObject('get');
    isoObj = isoObject('get');
    mipObj = mipObject('get');

    tVoiInput = voiTemplate('get');

    aInputArguments = {'Parent', uiWindow, 'Renderer', 'Isosurface', 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    aIsovalue = 0.0000000000000001;

    if ~isempty(isoObj)
        aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                   'CameraUpVector', get(isoObj, 'CameraUpVector'), ...
                   'ScaleFactors'  , get(isoObj, 'ScaleFactors')};
        aInputArguments = [aInputArguments(:)', aCamera(:)'];       
    elseif ~isempty(mipObj)
        aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                   'CameraUpVector', get(mipObj, 'CameraUpVector'), ...
                   'ScaleFactors'  , get(mipObj, 'ScaleFactors')};
        aInputArguments = [aInputArguments(:)', aCamera(:)']; 
    elseif ~isempty(volObj)
        aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                   'CameraUpVector', get(volObj, 'CameraUpVector'), ...
                   'ScaleFactors'  , get(volObj, 'ScaleFactors')};
        aInputArguments = [aInputArguments(:)', aCamera(:)'];                                                           
    end     

    if ~isempty(tVoiInput)
        for aa=1:numel(tVoiInput)                       

            aBuffer = zeros(size(dicomBuffer('get')));
            if     strcmp(imageOrientation('get'), 'axial')
                im = permute(aBuffer, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal') 
                im = permute(aBuffer, [3 2 1]);    
            elseif strcmp(imageOrientation('get'), 'sagittal')
                im = permute(aBuffer, [3 1 2]);
            end        

            if numel(tInput(iSeriesOffset).asFilesList) ~= 1
                if atMetaData{2}.ImagePositionPatient(3) - ...
                   atMetaData{1}.ImagePositionPatient(3) > 0                    

                     im = im(:,:,end:-1:1);                   
                end
            else
                if strcmpi(atMetaData{1}.PatientPosition, 'FFS')
                     im = im(:,:,end:-1:1);                   
                end                       
            end 

            aIsosurfaceColor = tVoiInput{aa}.Color;

            aInputArguments = [aInputArguments(:)', {'Isovalue'}, {aIsovalue}, {'IsosurfaceColor'}, {aIsosurfaceColor}];

            for yy=1:numel(tVoiInput{aa}.tMask)                          

                if strcmpi(tVoiInput{aa}.tMask{yy}.Axe, 'Axes1')
                    im(tVoiInput{aa}.tMask{yy}.SliceNb, :, :) = permuteBuffer(tVoiInput{aa}.tMask{yy}.RoiMask, 'coronal');
                elseif strcmpi(tVoiInput{aa}.tMask{yy}.Axe, 'Axes2')    
                    im(:, tVoiInput{aa}.tMask{yy}.SliceNb, :) = permuteBuffer(tVoiInput{aa}.tMask{yy}.RoiMask, 'sagittal');
                else                                 
                    im(:, :, tVoiInput{aa}.tMask{yy}.SliceNb) = tVoiInput{aa}.tMask{yy}.RoiMask;
                end

            end             

            im = im(:,:,end:-1:1);
            im = smooth3(im);
            voiObj{aa} = volshow(im, aInputArguments{:});                                                                  
        end                     
    end                        

end     
