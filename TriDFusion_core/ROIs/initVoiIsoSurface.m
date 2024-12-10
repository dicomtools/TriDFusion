function voiObj = initVoiIsoSurface(uiWindow, bSmoothVoi)
%function voiObj = initVoiIsoSurface(uiWindow, bSmoothVoi)
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

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    
%    for pp=1:numel(atVoiInput) % Patch, don't export total-mask
%        if strcmpi(atVoiInput{pp}.Label, 'TOTAL-MASK')
%            atVoiInput{pp} = [];
%            atVoiInput(cellfun(@isempty, atVoiInput)) = [];       
%        end
%    end   
        
    if strcmpi(voi3DRenderer('get'), 'VolumeRendering')
        aInputArguments = {'Parent', uiWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    elseif strcmpi(voi3DRenderer('get'), 'Isosurface')
        aInputArguments = {'Parent', uiWindow, 'Renderer', 'Isosurface', 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    else % LabelRendering
        aInputArguments = {'Parent', uiWindow, 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};
    end
           

    if ~isempty(isoObj)

        if isempty(viewer3dObject('get'))           
       
            aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                       'CameraUpVector', get(isoObj, 'CameraUpVector'), ...
                       'ScaleFactors'  , get(isoObj, 'ScaleFactors')};
            aInputArguments = [aInputArguments(:)', aCamera(:)'];
        else
            tform = get(isoObj, 'Transformation');
        end

    elseif ~isempty(mipObj)

        if isempty(viewer3dObject('get'))           
            aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                       'CameraUpVector', get(mipObj, 'CameraUpVector'), ...
                       'ScaleFactors'  , get(mipObj, 'ScaleFactors')};
            aInputArguments = [aInputArguments(:)', aCamera(:)'];
        else
            tform = get(mipObj, 'Transformation');
        end

    elseif ~isempty(volObj)

        if isempty(viewer3dObject('get'))  
            aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                       'CameraUpVector', get(volObj, 'CameraUpVector'), ...
                       'ScaleFactors'  , get(volObj, 'ScaleFactors')};
            aInputArguments = [aInputArguments(:)', aCamera(:)'];
        else
            tform = get(volObj, 'Transformation');
        end
    end
    

    if ~isempty(atVoiInput)

        aVoiEnableList = voi3DEnableList('get');
        if isempty(aVoiEnableList)
            for aa=1:numel(atVoiInput)
                aVoiEnableList{aa} = true;
            end
        end
        voi3DEnableList('set', aVoiEnableList);

        aVoiTransparencyList = voi3DTransparencyList('get');
        if isempty(aVoiTransparencyList)
            for aa=1:numel(atVoiInput)
                aVoiTransparencyList{aa} = slider3DVoiTransparencyValue('get');
            end
        end
        voi3DTransparencyList('set', aVoiTransparencyList);

        aColormap = zeros(256,3);

        aBuffer = false(size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))));

        if ~isempty(viewer3dObject('get'))        
            aLabelBuffer = zeros((size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))));
            aLabelColorMap = zeros(numel(atVoiInput)+1, 3);
            aLabelAlphaMap = zeros(numel(atVoiInput)+1, 1);
        else
            if strcmpi(voi3DRenderer('get'), 'LabelRendering')  
                aLabelBuffer = zeros((size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))));
                aLabelColorMap = zeros(numel(atVoiInput)+1, 3);
                aLabelAlphaMap = zeros(numel(atVoiInput)+1, 1);                
            end
        end

        for aa=1:numel(atVoiInput)

            progressBar(aa/numel(atVoiInput)-0.0001, sprintf('Processing VOI %d/%d', aa, numel(atVoiInput) ) );

            aBuffer(:) = false;

            aIsosurfaceColor = atVoiInput{aa}.Color;

            aColormap(:,1) = aIsosurfaceColor(1);
            aColormap(:,2) = aIsosurfaceColor(2);
            aColormap(:,3) = aIsosurfaceColor(3);

            aIsovalue = compute3DVoiTransparency(aVoiTransparencyList{aa});
            aAlphamap = compute3DVoiAlphamap(aVoiTransparencyList{aa});

            if strcmpi(voi3DRenderer('get'), 'VolumeRendering') 
                aInputArguments = [aInputArguments(:)', {'Colormap'}, {aColormap}, {'Alphamap'}, {aAlphamap}];
            elseif strcmpi(voi3DRenderer('get'), 'Isosurface')
                aInputArguments = [aInputArguments(:)', {'Isovalue'}, {aIsovalue}, {'IsosurfaceColor'}, {aIsosurfaceColor}];
            else
                aLabelColor = zeros(2,3);
                aLabelColor(1,:) = atVoiInput{aa}.Color;
                aLabelColor(2,:) = atVoiInput{aa}.Color;

                aInputArguments = [aInputArguments(:)', {'LabelColor'}, {aLabelColor}];
                
            end
            
            dNbTags = numel(atVoiInput{aa}.RoisTag);
            for yy=1:dNbTags

                if dNbTags > 100
                    if mod(yy, 10)==1 || yy == dNbTags
                        progressBar( yy/dNbTags, sprintf('Computing ROI %d/%d, please wait', yy, dNbTags) );
                    end
                end
                
                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{aa}.RoisTag{yy} );
                dRoiTagOffset = find(aTagOffset, 1); 
                
                if ~isempty(dRoiTagOffset)
                    
                    sAxe = atRoiInput{dRoiTagOffset}.Axe;
                    dSliceNb = atRoiInput{dRoiTagOffset}.SliceNb;

                    switch lower(sAxe)
                        
                        case 'axes1'
                        im = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                        
                        case 'axes2'
                        im = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                        
                        otherwise
                        im = aBuffer(:,:,dSliceNb);
                    end                                    
                                
                    bw = roiTemplateToMask(atRoiInput{dRoiTagOffset}, im);
                    
                    switch lower(sAxe)
                        
                        case 'axes1'
                        aBuffer(dSliceNb, :, :) = aBuffer(dSliceNb, :, :)|permuteBuffer(bw, 'coronal');
                        
                        case 'axes2'
                        aBuffer(:, dSliceNb, :) = aBuffer(:, dSliceNb, :)|permuteBuffer(bw, 'sagittal');
                        
                        otherwise
                        aBuffer(:, :, dSliceNb) = aBuffer(:, :, dSliceNb)|bw;
                   end 
                   
                end
            end

            % if bSmoothVoi == true && isempty(viewer3dObject('get'))
            %     aBuffer = smooth3(aBuffer(:,:,end:-1:1), 'box', 3);
            % else
            aBuffer = aBuffer(:,:,end:-1:1);
            % end

%            Ds = interp3(im);
%            Ds = smooth3(im, 'gaussian', 15);

%            im(im==1) = 999999;
%            K1 = squeeze(im);
%            K2 = padarray(K1,[10 10 10],'both');
%            Ds = smooth3(K2);

%            if contains(atVoiInput{aa}.Label, 'Lung' )
%                aInputArguments{4} = 'VolumeRendering';
%                voi3DRenderer('set', 'VolumeRendering');
%            else
%                aInputArguments{4} = 'Isosurface';
%                voi3DRenderer('set', 'Isosurface');               
%            end


     %       voiObj{aa} = volshow(aBuffer, aInputArguments{:});
            if isempty(viewer3dObject('get'))           

                if strcmpi(voi3DRenderer('get'), 'LabelRendering')
                    
                    aLabelBuffer(aBuffer==1) = aa;
                    aLabelColorMap(aa+1, :) = atVoiInput{aa}.Color;
                    aLabelAlphaMap(aa+1, :) = aVoiTransparencyList{aa};
                else 

                    if bSmoothVoi == true && isempty(viewer3dObject('get'))
                        
                        aBuffer = smooth3(aBuffer, 'box', 3);
                    end


                    if isMATLABReleaseOlderThan('R2022b')
                        voiObj{aa} = volshow(squeeze(aBuffer), aInputArguments{:});
                    else
                        voiObj{aa} = images.compatibility.volshow.R2022a.volshow(squeeze(aBuffer), aInputArguments{:});
                    end
                           
                    set(voiObj{aa}, 'InteractionsEnabled', false);
    
                    if aVoiEnableList{aa} == false
                        if strcmpi(voi3DRenderer('get'), 'VolumeRendering')
                            set(voiObj{aa}, 'Alphamap', zeros(256,1));
                        else
                            set(voiObj{aa}, 'Renderer', 'LabelOverlayRendering');
                        end
                    end
                end
            else

                aLabelBuffer(aBuffer) = aa;
                aLabelColorMap(aa+1, :) = atVoiInput{aa}.Color;
                aLabelAlphaMap(aa+1, :) = aVoiTransparencyList{aa};
            end


        %    setVolume(voiObj{aa},im);

        end
   
        % aLabelBuffer = aLabelBuffer(:,:,end:-1:1);
        if ~isempty(viewer3dObject('get')) % with viewer3d, we are now using the LabelOverlay for the voi           

            voiObj{1} = volshow(squeeze(false(size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))))), ...
                                'Parent'          , viewer3dObject('get'), ...
                                'RenderingStyle'  , 'VolumeRendering',...
                                'OverlayColormap' , aLabelColorMap, ...
                                'OverlayAlphamap' , aLabelAlphaMap, ...
                                'OverlayData'     , aLabelBuffer, ...
                                'IsosurfaceValue' , aIsovalue, ...
                                'OverlayThreshold', 0, ...
                                'Transformation'  , tform);  
            
            clear aLabelBuffer;
        else
            if strcmpi(voi3DRenderer('get'), 'LabelRendering')

                voiObj{1} = labelvolshow(squeeze(aLabelBuffer), ...
                                         'Parent'        , uiWindow, ...
                                         aCamera{:}, ...
                                         'BackgroundColor', surfaceColor('one', background3DOffset('get')), ...
                                         'LabelColor'     , aLabelColorMap, ...
                                         'LabelOpacity'   , aLabelAlphaMap);          
                clear aLabelBuffer;
            end
        end

        clear aBuffer;

%        aVolSize = size(dicomBuffer('get'));
%        aDummyBuffer = zeros(size(dicomBuffer('get')));

%        voiObj{numel(voiObj)+1} = volshow(aDummyBuffer, aInputArguments{:});
%        voiObj{numel(voiObj)}.Alphamap(:) = 0;
%        voiObj{numel(voiObj)}.InteractionsEnabled = 0;

        progressBar(1, 'Ready');
    end

end
