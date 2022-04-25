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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false
        return;
    end

    volObj = volObject('get');
    isoObj = isoObject('get');
    mipObj = mipObject('get');

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    
    for pp=1:numel(tVoiInput) % Patch, don't export total-mask
        if strcmpi(tVoiInput{pp}.Label, 'TOTAL-MASK')
            tVoiInput{pp} = [];
            tVoiInput(cellfun(@isempty, tVoiInput)) = [];       
        end
    end   
        
    if strcmpi(voi3DRenderer('get'), 'VolumeRendering')
        aInputArguments = {'Parent', uiWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    else
        aInputArguments = {'Parent', uiWindow, 'Renderer', 'Isosurface', 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    end

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

        aVoiEnableList = voi3DEnableList('get');
        if isempty(aVoiEnableList)
            for aa=1:numel(tVoiInput)
                aVoiEnableList{aa} = true;
            end
        end

        aVoiTransparencyList = voi3DTransparencyList('get');
        if isempty(aVoiTransparencyList)
            for aa=1:numel(tVoiInput)
                aVoiTransparencyList{aa} = slider3DVoiTransparencyValue('get');
            end
        end

        aColormap = zeros(256,3);

        for aa=1:numel(tVoiInput)

            progressBar(aa/numel(tVoiInput)-0.0001, sprintf('Processing VOI %d/%d', aa, numel(tVoiInput) ) );

            aBuffer = zeros(size(dicomBuffer('get')));

            aIsosurfaceColor = tVoiInput{aa}.Color;

            aColormap(:,1) = aIsosurfaceColor(1);
            aColormap(:,2) = aIsosurfaceColor(2);
            aColormap(:,3) = aIsosurfaceColor(3);

            aIsovalue = compute3DVoiTransparency(aVoiTransparencyList{aa});
            aAlphamap = compute3DVoiAlphamap(aVoiTransparencyList{aa});

            aInputArguments = [aInputArguments(:)', {'Isovalue'}, {aIsovalue}, {'IsosurfaceColor'}, {aIsosurfaceColor}, {'Colormap'}, {aColormap}, {'Alphamap'}, {aAlphamap}];

            dNbTags = numel(tVoiInput{aa}.RoisTag);
            for yy=1:dNbTags

                if dNbTags > 100
                    if mod(yy, 10)==1 || yy == dNbTags
                        progressBar( yy/dNbTags, sprintf('Computing ROI %d/%d, please wait', yy, dNbTags) );
                    end
                end

                for rr=1:numel(tRoiInput)
                    if strcmpi(tVoiInput{aa}.RoisTag{yy}, tRoiInput{rr}.Tag)
                                                                        
                        sAxe = tRoiInput{rr}.Axe;
                        dSliceNb = tRoiInput{rr}.SliceNb;

                        if     strcmpi(sAxe, 'Axes1')
                            im = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                        elseif strcmpi(sAxe, 'Axes2')
                            im = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                        else
                            im = aBuffer(:,:,dSliceNb);
                        end

                        break;
                    end
                end
                
                bw = roiTemplateToMask(tRoiInput{rr}, im);

                if strcmpi(sAxe, 'Axes1')
                    aBuffer(dSliceNb, :, :) = aBuffer(dSliceNb, :, :)|permuteBuffer(bw, 'coronal');
                elseif strcmpi(sAxe, 'Axes2')
                    aBuffer(:, dSliceNb, :) = aBuffer(:, dSliceNb, :)|permuteBuffer(bw, 'sagittal');
                else
                    aBuffer(:, :, dSliceNb) = aBuffer(:, :, dSliceNb)|bw;
                end

            end

            aBuffer = aBuffer(:,:,end:-1:1);
%            Ds = interp3(im);
%            Ds = smooth3(im, 'gaussian', 15);

%            im(im==1) = 999999;
%            K1 = squeeze(im);
%            K2 = padarray(K1,[10 10 10],'both');
%            Ds = smooth3(K2);


            voiObj{aa} = volshow(aBuffer, aInputArguments{:});
            set(voiObj{aa}, 'InteractionsEnabled', false);

            if aVoiEnableList{aa} == false
                if strcmpi(voi3DRenderer('get'), 'VolumeRendering')
                    set(voiObj{aa}, 'Alphamap', zeros(256,1));
                else
                    set(voiObj{aa}, 'Renderer', 'LabelOverlayRendering');
                end
            end

        %    setVolume(voiObj{aa},im);

        end


%        aVolSize = size(dicomBuffer('get'));
%        aDummyBuffer = zeros(size(dicomBuffer('get')));

%        voiObj{numel(voiObj)+1} = volshow(aDummyBuffer, aInputArguments{:});
%        voiObj{numel(voiObj)}.Alphamap(:) = 0;
%        voiObj{numel(voiObj)}.InteractionsEnabled = 0;

        progressBar(1, 'Ready');


    end

end
