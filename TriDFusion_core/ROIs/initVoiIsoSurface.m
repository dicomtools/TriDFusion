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

    tRoiInput = roiTemplate('get');
    tVoiInput = voiTemplate('get');

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

            for yy=1:numel(tVoiInput{aa}.RoisTag)                       
                for rr=1:numel(tRoiInput)
                    if strcmpi(tVoiInput{aa}.RoisTag{yy}, tRoiInput{rr}.Tag)
                        sAxe = tRoiInput{rr}.Axe;
                        dSliceNb = tRoiInput{rr}.SliceNb;
                        aPosition = tRoiInput{rr}.Position;
                        sType = tRoiInput{rr}.Type;
                        
                        switch sType
                            case lower('images.roi.ellipse')
                                dRotationAngle = tRoiInput{rr}.RotationAngle;
                                aSemiAxes =  tRoiInput{rr}.SemiAxes;
                                
                            case lower('images.roi.circle')
                                dRadius = tRoiInput{rr}.Radius;
                        end
                        
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
                
                
                switch sType
                    case lower('images.roi.rectangle')
                        
                        rectMask = zeros(size(im, 1), size(im, 2)); % generate grid of ones
                        
                        top    = int32(aPosition(2));
                        bottom = int32(aPosition(2)+aPosition(4));
                        left   = int32(aPosition(1));
                        right  = int32(aPosition(1)+aPosition(3));
                        
                        rectMask(top:bottom,left:right) = 1; % rectMask( Y values, X values)     
                        
                        bw = logical(rectMask);

                        
                    case lower('images.roi.ellipse')
                        
                        phi  = dRotationAngle;

                        xCenter = aPosition(1);
                        yCenter = aPosition(2);
                        xRadius = aSemiAxes(1);
                        yRadius = aSemiAxes(2);
                        theta = 0 : 0.01 : 2*pi;
                        X_cen = [xCenter;yCenter];
                        X = [xRadius * cos(theta);
                             yRadius * sin(theta)];
                        R = [cos(phi) -sin(phi);
                             sin(phi) cos(phi)];
                        Xr = R*X + X_cen;
                        x = Xr(1,:);
                        y = Xr(2,:);
                        
                        bw = poly2mask(x(:),y(:), size(im,1), size(im,2));                        
                        
                    case lower('images.roi.circle')           
                        
                        xCenter = aPosition(1);
                        yCenter = aPosition(2);
                        
                        theta = 0 : 0.01 : 2*pi;
                        radius = dRadius;
                        x = radius * cos(theta) + xCenter;
                        y = radius * sin(theta) + yCenter;  
                                             
                        bw = poly2mask(x(:),y(:), size(im,1), size(im,2));                        
                                                
                    otherwise

                        bw = poly2mask(aPosition(:,1),aPosition(:,2), size(im,1), size(im,2));                        
                end
                
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
