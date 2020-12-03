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

    % 'VolumeRendering', 'Isosurface', 'MaximumIntensityProjection'
    pObject = [];

    if numel(im) && size(im, 3) ~= 1
         
%       multiFrame3DRecord('get') == false

         volObj = volObject('get');
         isoObj = isoObject('get');
         mipObj = mipObject('get');

         im = im(:,:,end:-1:1);


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
                     aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                                'CameraUpVector', get(isoObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       
                 elseif ~isempty(mipObj)
                     aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                                'CameraUpVector', get(mipObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];        
                 else  
                     aCamera = {'CameraPosition', [1 0 0], ...
                                'CameraUpVector', [0 0 1]};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];                               
                 end      

             case 'Isosurface'
                 if ~isempty(volObj)
                     aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                                'CameraUpVector', get(volObj, 'CameraUpVector')};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       

                 elseif ~isempty(mipObj)
                     aCamera = {'CameraPosition', get(mipObj, 'CameraPosition'), ...
                                'CameraUpVector', get(mipObj, 'CameraUpVector')}; 
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];  
                 else    
                     aCamera = {'CameraPosition', [1 0 0], ...
                                'CameraUpVector', [0 0 1]};
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];  
                 end

             case 'MaximumIntensityProjection'
                 if ~isempty(volObj)
                     aCamera = {'CameraPosition', get(volObj, 'CameraPosition'), ...
                                'CameraUpVector', get(volObj, 'CameraUpVector')}; 
                     aInputArguments = [aInputArguments(:)', aCamera(:)'];       
                 elseif ~isempty(isoObj)
                     aCamera = {'CameraPosition', get(isoObj, 'CameraPosition'), ...
                                'CameraUpVector', get(isoObj, 'CameraUpVector')};
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

            if  strcmp(imageOrientation('get'), 'axial')   

                aScaleFactors = [x y z];    
            elseif strcmp(imageOrientation('get'), 'coronal' )                           

                aScaleFactors = [y z x];   
            elseif strcmp(imageOrientation('get'), 'sagittal') 

                aScaleFactors = [x z y];
            end

        else                    
            aScaleFactors = [1 1 1];
        end
        
        dScaleMax = max(aScaleFactors);

if 0                                
        % Normalize to 1
        
        aScaleFactors(1)=aScaleFactors(1)/dScaleMax;
        aScaleFactors(2)=aScaleFactors(2)/dScaleMax;
        aScaleFactors(3)=aScaleFactors(3)/dScaleMax;
else

end                
        volumeScaleFator('set', 'x', aScaleFactors(1));
        volumeScaleFator('set', 'y', aScaleFactors(2));
        volumeScaleFator('set', 'z', aScaleFactors(3));

        % If another object exist, get other object ratio

        if ~isempty(volObj)                        
            aScaleFactors = get(volObj, 'ScaleFactors');
        end

        if ~isempty(isoObj)                        
            aScaleFactors = get(isoObj, 'ScaleFactors');
        end

        if ~isempty(mipObj)                        
            aScaleFactors = get(mipObj, 'ScaleFactors');
        end

        aInputArguments = [aInputArguments(:)', {'ScaleFactors'}, {aScaleFactors}];

        if init3DPanel('get') == true
            view3DPanel('set', true);

            obj3DPanel = view3DPanelMenuObject('get');
            if ~isempty(obj3DPanel)
                set(obj3DPanel, 'Checked', 'on');
            end
            init3DuicontrolPanel();

         end  

        switch sRenderer
            case 'VolumeRendering'
         %       intensity = [0 20 40 120 220 1024];
         %       alpha = [0 0 0.15 0.3 0.38 0.5];
         %       queryPoints = linspace(min(intensity),max(intensity),256);

         %       aAlphamap = interp1(intensity,alpha,queryPoints)';

                [aAlphamap, sType]  = getVolAlphaMap('get', im, atMetaData);
                aColormap = get3DColorMap('one', colorMapVolOffset('get'));
                bLighting = volLighting('get');

                aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}, 'Lighting', bLighting];

%                    volshow(im, 'Parent', uiOneWindowPtr('get'), 'Renderer', sRenderer)

                pObject = volshow(im, aInputArguments{:});
                if isempty(isoObj)&&isempty(mipObj)&&multiFrame3DZoom('get')==0
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

                aInputArguments = [aInputArguments(:)', {'Isovalue'}, {aIsovalue}, {'IsosurfaceColor'}, {aIsosurfaceColor}];

                pObject = volshow(im, aInputArguments{:});
                if isempty(volObj)&&isempty(mipObj)&&multiFrame3DZoom('get')==0
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

               aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

               pObject = volshow(im, aInputArguments{:});
               if isempty(volObj)&&isempty(isoObj)&&multiFrame3DZoom('get')==0
                    multiFrame3DZoom('set', 3*dScaleMax);  % Normalize to 1
               end                         
%               mipObject('set', pObject);    

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
