function pObject = initVolShow(im, uiWindow, sRenderer, atMetaData) 
%function pObject = initVolShow(im, uiWindow, sRenderer, atMetaData) 
%Init MIP, Volume and ISO surface.
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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false
        return;
    end

    bUseViewer3d = shouldUseViewer3d();
    
    % 'VolumeRendering', 'Isosurface', 'MaximumIntensityProjection'
    pObject = [];

    if numel(im) && size(im, 3) ~= 1
         
%       multiFrame3DRecord('get') == false

         volObj = volObject('get');
         isoObj = isoObject('get');
         mipObj = mipObject('get');
         
         try % Clear object
             
            if exist('volObj', 'var') && isa(volObj, 'handle') && ~isvalid(volObj)
                volObj = [];
            end
        
            if exist('isoObj', 'var') && isa(isoObj, 'handle') && ~isvalid(isoObj)
                isoObj = [];
            end
        
            if exist('mipObj', 'var') && isa(mipObj, 'handle') && ~isvalid(mipObj)
                mipObj = [];
            end
         catch ME   
            logErrorToFile(ME);
         end

         
         im = squeeze(im(:,:,end:-1:1));


%             im(:,(399:400),:) = 0;
%             im(:,:,(399:400)) = 0;
%             im((44:45),:,:) = 0;
%             im(:,:,(1:2)) = 0;
%             im(:,(1:2),:) = 0;
%             im((1:2),:,:) = 0;

         bPlaybackState = multiFrame3DPlayback('get');
         if  bPlaybackState == true
             multiFrame3DPlayback('set', false);
         end
         
         aInputArguments = {'Parent', uiWindow, 'Renderer', sRenderer, 'BackgroundColor', surfaceColor('one', background3DOffset('get'))};

         % Set object position

         switch sRenderer

             case 'VolumeRendering'

                 if ~isempty(isoObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(isoObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end
                     % aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(isoObj, 'CameraUpVector')};                    
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       
                 elseif ~isempty(mipObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(mipObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end                     
                     % aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(mipObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];        
                 else                  
                     aCamera = {'CameraPosition', [1 0 0], ...
                                'CameraUpVector', [0 0 1]};
                                   
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];                               
                 end      

             case 'Isosurface'
                 if ~isempty(volObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(volObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end                     
                     % aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(volObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       

                 elseif ~isempty(mipObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(mipObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end                        
                     % aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(mipObj, 'CameraUpVector')}; 
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];  
                 else    
                     aCamera = {'CameraPosition', [1 0 0], ...
                                'CameraUpVector', [0 0 1]};
                            
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];  
                 end

             case 'MaximumIntensityProjection'
                 if ~isempty(volObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(volObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end                          
                     % aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(volObj, 'CameraUpVector')}; 
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       
                 elseif ~isempty(isoObj)

                     ptrViewer3d = viewer3dObject('get');
                     if isempty(ptrViewer3d)
                         aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                                    'CameraUpVector', get(isoObj, 'CameraUpVector')};
                     else
                         aCamera = {'CameraPosition', get(ptrViewer3d, 'CameraPosition'), ...
                                    'CameraUpVector', get(ptrViewer3d, 'CameraUpVector')};                         
                     end                       
                     % aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                     %            'CameraUpVector', get(isoObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       
                 else
                     aCamera = {'CameraPosition', [1 0 0], ...
                                'CameraUpVector', [0 0 1]};
                            
                    aInputArguments = [aInputArguments(:)', aCamera(:)'];  
                 end
         end                    

        % set aspect ratio

        if aspectRatio('get') == true

            x = aspectRatioValue('get', 'x');
            y = aspectRatioValue('get', 'y');
            z = aspectRatioValue('get', 'z');

%            if  strcmpi(imageOrientation('get'), 'axial')   

                aScaleFactors = [y x z];    
%            elseif strcmpi(imageOrientation('get'), 'coronal' )                           

%                aScaleFactors = [y z x];   
%            elseif strcmpi(imageOrientation('get'), 'sagittal') 

%                aScaleFactors = [x z y];
%            end

        else                    
            
          aScaleFactors = [1 1 1];

       end
        
      
        dScaleMax = max(aScaleFactors);

% if 0                                
%         % Normalize to 1
% 
%         aScaleFactors(1)=aScaleFactors(1)/dScaleMax;
%         aScaleFactors(2)=aScaleFactors(2)/dScaleMax;
%         aScaleFactors(3)=aScaleFactors(3)/dScaleMax;
% else
% 
% end                
        volumeScaleFator('set', 'x', aScaleFactors(1));
        volumeScaleFator('set', 'y', aScaleFactors(2));
        volumeScaleFator('set', 'z', aScaleFactors(3));

        % If another object exist, get other object ratio

        if ~isempty(volObj)   
            if isempty(viewer3dObject('get'))           
                aScaleFactors = get(volObj, 'ScaleFactors');
            else
                aScaleFactors = [];
            end
        end

        if ~isempty(isoObj)                        
            if isempty(viewer3dObject('get'))           
                aScaleFactors = get(isoObj, 'ScaleFactors');
            else
                aScaleFactors = [];
            end                
        end

        if ~isempty(mipObj)                        
            if isempty(viewer3dObject('get'))           
                aScaleFactors = get(mipObj, 'ScaleFactors');
            else
                aScaleFactors = [];
            end            
        end

        aInputArguments = [aInputArguments(:)', {'ScaleFactors'}, {[1 1 1]}];

        if init3DPanel('get') == true

            view3DPanel('set', true);

            obj3DPanel = view3DPanelMenuObject('get');
            if ~isempty(obj3DPanel)
                set(obj3DPanel, 'Checked', 'on');
            end

            init3DuicontrolPanel();
            
            ptrViewer3d = viewer3dObject('get');
            if ~isempty(ptrViewer3d)
                delete(ptrViewer3d);
            end

            viewer3dObject('set', []);

            if bUseViewer3d == true

                set(uiOneWindowPtr('get'), 'AutoResizeChildren', 'on');

                ptrViewer3d = viewer3d('Parent', uiWindow, ...
                                       'BackgroundColor', surfaceColor('one', background3DOffset('get')), ...
                                       'GradientColor', [0.98 0.98 0.98], ...
                                       'CameraZoom', 1.5000, ...
                                       'ScaleBar', 'on', ...
                                       'RenderingQuality', 'high', ...
                                       'Lighting','off'); 

                if volLighting('get') == true
                    set(ptrViewer3d, 'Lighting', 'on');
                else
                    set(ptrViewer3d, 'Lighting', 'off');
                end
   
                if background3DGradient('get') == true
                    set(ptrViewer3d, 'BackgroundGradient', 'on');
                else
                    set(ptrViewer3d, 'BackgroundGradient', 'off');
                end
              
                uiOneWindow = uiOneWindowPtr('get');
                if ~isempty(uiOneWindow)

                    uiOneWindowPosition = get(uiOneWindow, 'Position');

                    xOffset = uiOneWindowPosition(1);
                    yOffset = 0;
                    xSize   = uiOneWindowPosition(3);
                    ySize   = uiOneWindowPosition(4);
        
                    if view3DPanel('get') == true
                        xOffset = xOffset-680;
                    end
        
                    set(ptrViewer3d, 'Position', [xOffset yOffset xSize ySize]);  
                end

                viewer3dObject('set', ptrViewer3d);

            end
        end  

        if aspectRatio('get') == true

            if atMetaData{1}.PixelSpacing(1) == 0 || ...
               atMetaData{1}.PixelSpacing(2) == 0 || ...
               computeSliceSpacing(atMetaData) == 0

                if ~isempty(viewer3dObject('get'))

                    Mdti=[1 0 0 0; ...
                          0 1 0 0; ...
                          0 0 1 0; ...
                          0 0 0 1];                 
                    tform = affinetform3d(Mdti);
               end
           else
                if ~isempty(viewer3dObject('get'))

                    [Mdti,~] = TransformMatrix(atMetaData{1}, computeSliceSpacing(atMetaData), true);
                    
                    if volume3DZOffset('get') == false
                        Mdti(1,4) = 0;
                        Mdti(2,4) = 0;
                        Mdti(3,4) = 0;
                        Mdti(4,4) = 1;
                    end    
    
                    tform = affinetform3d(Mdti);
                end               
            end

        else                    
            
          if ~isempty(viewer3dObject('get'))
    
                Mdti=[1 0 0 0; ...
                      0 1 0 0; ...
                      0 0 1 0; ...
                      0 0 0 1];  
    
                tform = affinetform3d(Mdti);
           end
        end  

        switch sRenderer
            
            case 'VolumeRendering'
         %       intensity = [0 20 40 120 220 1024];
         %       alpha = [0 0 0.15 0.3 0.38 0.5];
         %       queryPoints = linspace(min(intensity),max(intensity),256);

         %       aAlphamap = interp1(intensity,alpha,queryPoints)';

                [aAlphamap, sType]  = getVolAlphaMap('get', im, atMetaData);
                aColormap = get3DColorMap('one', colorMapVolOffset('get'));                
                
%                    volshow(im, 'Parent', uiOneWindowPtr('get'), 'Renderer', sRenderer)
                if isempty(viewer3dObject('get'))

                    bLightingIsSupported = true;
                    if isMATLABReleaseOlderThan('R2020a')

                        bLightingIsSupported = false;                    
                    end
                    
                    if bLightingIsSupported == true                

                        bLighting = volLighting('get');
                        aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}, 'Lighting', bLighting];
                    else
                        aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];
                    end

                    if isMATLABReleaseOlderThan('R2022b')
                        pObject = volshow(squeeze(im), aInputArguments{:});
                    else
                         pObject = images.compatibility.volshow.R2022a.volshow(squeeze(im), aInputArguments{:});                   
                    end

                    set(pObject, 'ScaleFactors', aScaleFactors);
                   
                else
  
                    pObject = volshow(squeeze(im), ...
                                      'Parent'        , viewer3dObject('get'), ...
                                      'RenderingStyle', 'VolumeRendering',...
                                      'Alphamap'      , aAlphamap, ...
                                      'Colormap'      , aColormap, ...
                                      'Transformation', tform);
                end

                if isempty(isoObj) && isempty(mipObj) && ~isempty(viewer3dObject('get'))  

                    set3DView(viewer3dObject('get'), 1, 1);
                end

                if isempty(isoObj) && isempty(mipObj) && multiFrame3DZoom('get')==0

                    multiFrame3DZoom('set', 3*dScaleMax);  % Normalize to 1
                    
                end
     %           volObject('set',  pObject);

%                     if displayVolColorMap('get') == true                       
%                         uivolColorbar = volColorbar(uiOneWindowPtr('get'), aColormap);
%                         volColorObject('set', uivolColorbar);                               
%                     end

                if init3DPanel('get') == false

                   ic = volICObject('get');
            %       volObj = volObject('get');
            %       ic.surfObj = pObject; 

                    if strcmp(sType, 'custom')
                        set(pObject, 'Alphamap', computeAlphaMap(ic));
                    end
                end


            case 'Isosurface'

                aIsovalue = isoSurfaceValue('get');
                aIsosurfaceColor = surfaceColor('one', isoColorOffset('get'));

                if isempty(viewer3dObject('get'))

                    aInputArguments = [aInputArguments(:)', {'Isovalue'}, {aIsovalue}, {'IsosurfaceColor'}, {aIsosurfaceColor}];

                    if isMATLABReleaseOlderThan('R2022b')
    
                        pObject = volshow(squeeze(im), aInputArguments{:});
                    else
                        pObject = images.compatibility.volshow.R2022a.volshow(squeeze(im), aInputArguments{:});                   
                    end

                    set(pObject, 'ScaleFactors', aScaleFactors);                   
                else    

                    pObject = volshow(squeeze(im), ...
                                      'Parent'         , viewer3dObject('get'), ...
                                      'RenderingStyle' , 'Isosurface',...
                                      'IsosurfaceValue', aIsovalue, ...
                                      'Colormap'       , aIsosurfaceColor, ...
                                      'Transformation' , tform);
                end

                if isempty(volObj) && isempty(mipObj) && ~isempty(viewer3dObject('get'))  
                    
                    set3DView(viewer3dObject('get'), 1, 1);
                end

                if isempty(volObj) && isempty(mipObj) && multiFrame3DZoom('get')==0

                    multiFrame3DZoom('set', 3*dScaleMax);  % Normalize to 1
                end                        
 %               isoObject('set', pObject);

            case 'MaximumIntensityProjection'

           %    intensity = [0 20 40 120 220 1024];
           %    alpha = [0 0 0.15 0.3 0.38 0.5];
           %    queryPoints = linspace(min(intensity),max(intensity),256);

           %    aAlphamap = interp1(intensity,alpha,queryPoints)';

                [aAlphamap, sType]  = getMipAlphaMap('get', im, atMetaData);
                aColormap = get3DColorMap('one', colorMapMipOffset('get'));

                if isempty(viewer3dObject('get'))

                    aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];
    
                    if isMATLABReleaseOlderThan('R2022b')
    
                        pObject = volshow(squeeze(im), aInputArguments{:});
                    else
                        pObject = images.compatibility.volshow.R2022a.volshow(squeeze(im), aInputArguments{:});                   
                    end

                    set(pObject, 'ScaleFactors', aScaleFactors);

                else

                    pObject = volshow(squeeze(im), ...
                                      'Parent'        , viewer3dObject('get'), ...
                                      'RenderingStyle', 'MaximumIntensityProjection',...
                                      'Alphamap'      , aAlphamap, ...
                                      'Colormap'      , aColormap, ...
                                      'Transformation', tform);
                end

                 % set(pObject, 'ScaleFactors', aScaleFactors);

                if isempty(volObj) && isempty(isoObj) && ~isempty(viewer3dObject('get'))  
                    
                    set3DView(viewer3dObject('get'), 1, 1);
                end

                if isempty(volObj) && isempty(isoObj) && multiFrame3DZoom('get')==0

                    multiFrame3DZoom('set', 3*dScaleMax);  % Normalize to 1
                end                         
%                mipObject('set', pObject);    

                if init3DPanel('get') == false

                    ic = mipICObject('get');
%                   mipObj = mipObject('get');
%                   ic.surfObj = mipObj;

                    if strcmp(sType, 'custom')
                        set(pObject, 'Alphamap', computeAlphaMap(ic));
                    end

                end     
                      
  %             if displayMIPColorMap('get') == true        
  %                  uimipColorbar = mipColorbar(uiOneWindowPtr('get'), aColormap);
  %                  mipColorObject('set', uimipColorbar);                
  %             end

        end

        if  bPlaybackState == true                      
             multiFrame3DPlayback('set', true);
             multiFrame3D();
        end               
    end
end
