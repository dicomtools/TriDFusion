function setOptionsCallback(~, ~)
%function setOptionsCallback(~, ~)
%Set Options Main Function.
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

    dlgOptions = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-240/2) ...
                            380 ...
                            280 ...
                            ],...
              'Color', viewerBackgroundColor('get'), ...
              'Name', 'Set Properties'...
               );

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%   javaFrame = get(dlgOptions,'JavaFrame');
%   javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));                              


         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D VOI Renderer',...
                  'horizontalalignment', 'left',...
                  'position', [20 237 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                  
                  'Enable', 'On'...
                  );
              
    sVoiRenderer = voi3DRenderer('get');
    if strcmpi(sVoiRenderer, 'VolumeRendering')
        dVoiRendererOffset = 1;
    else
        dVoiRendererOffset = 2;
    end
              
    uiVoiRenderer = ...
        uicontrol(dlgOptions, ...
                  'enable'  , 'on',...
                  'Style'   , 'popup', ...
                  'position', [200 240 160 20],...
                  'String'  , {'VolumeRendering', 'Isosurface'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , dVoiRendererOffset ...
                  );

    % Show border

    chkBorder = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , showBorder('get'),...
                  'position', [20 215 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @viewBorderCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Show Border',...
                  'horizontalalignment', 'left',...
                  'position', [40 212 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @viewBorderCallback...
                  );

    % Gate on series UID

    chkUseUID = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~gateUseSeriesUID('get'),...
                  'position', [20 190 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @gateUseSeriesUIDCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Gate all series',...
                  'horizontalalignment', 'left',...
                  'position', [40 187 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @gateUseSeriesUIDCallback...
                  );

     if gateUseSeriesUID('get') == false
         sChkEnable = 'on';
     else
         sChkEnable = 'off';
     end

     chkLookupTable = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , sChkEnable,...
                  'value'   , gateLookupTable('get'),...
                  'position', [40 165 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @gateLookupTableCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Adjust Lookup Table',...
                  'horizontalalignment', 'left',...
                  'position', [60 162 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @gateLookupTableCallback...
                  );

    if strcmpi(gateLookupType('get'), 'Relative')
        dLookupValue =1;
    else
        dLookupValue =2;
    end

    uiLookupTable = ...
        uicontrol(dlgOptions, ...
                  'enable'  , sChkEnable,...
                  'Style'   , 'popup', ...
                  'position', [200 165 160 20],...
                  'String'  , {'Relative', 'Absolute'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , dLookupValue ...
                  );

    % Ratio Aspect

    chkAspect = uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , aspectRatio('get'),...
                  'position', [20 140 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @aspectRatioCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Aspect ratio',...
                  'horizontalalignment', 'left',...
                  'position', [40 137 100 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @aspectRatioCallback...
                  );

   if aspectRatio('get')
       sEnableYXRatio = 'on';
       sEnableZRatio  = 'on';
   else
       sEnableYXRatio = 'off';
       sEnableZRatio  = 'off';
   end

   if(numel(dicomBuffer('get')))

        sXValue = num2str(aspectRatioValue('get', 'x'));
        sYValue = num2str(aspectRatioValue('get', 'y'));

        if size(dicomBuffer('get'), 3) == 1
            sEnableZRatio = 'off';
            sZValue = ' ';
        else
            sZValue = num2str(aspectRatioValue('get', 'z'));
        end
    else
        sXValue = ' ';
        sYValue = ' ';
        sZValue = ' ';
    end

   edtRatioX = ...
       uicontrol(dlgOptions,...
                 'style'     , 'edit',...
                 'enable'    , sEnableYXRatio,...
                 'Background', 'white',...
                 'string'    , sXValue,...
                 'position'  , [255 140 50 20],...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...                   
                 'Callback'  , @aspectRatioCallback...
                 );

   edtRatioY = ...
       uicontrol(dlgOptions,...
                 'style'     , 'edit',...
                 'enable'    , sEnableYXRatio,...
                 'Background', 'white',...
                 'string'    , sYValue,...
                 'position'  , [200 140 50 20],...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...                  
                 'Callback'  , @aspectRatioCallback...
                 );

   edtRatioZ = ...
       uicontrol(dlgOptions,...
                 'style'     , 'edit',...
                 'enable'    , sEnableZRatio,...
                 'Background', 'white',...
                 'string'    , sZValue,...
                 'position'  , [310 140 50 20],...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...                  
                 'Callback'  , @aspectRatioCallback...
                 );
    % 3D Engine

    chk3DEngine = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , is3DEngine('get'),...
                  'position', [20 115 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @set3DEngineCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D Engine',...
                  'horizontalalignment', 'left',...
                  'position', [40 112 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn', @set3DEngineCallback...
                  );
    % Shading

    if is3DEngine('get') == true
        sShadEnable = 'on';

    else
        sShadEnable = 'off';
    end

    chkShading = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , sShadEnable,...
                  'value'   , isShading('get'),...
                  'position', [40 90 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @shadingCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D Interpolated Shading',...
                  'horizontalalignment', 'left',...
                  'position', [60 87 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn', @shadingCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Crop Pixel Value',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 65 150 20]...
                  );

  edtCropValue = ...
      uicontrol(dlgOptions,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , num2str(cropValue('get')),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 65 50 20]...
                );

     % Cancel or Proceed

     uicontrol(dlgOptions,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelOptionsCallback...
               );

     uicontrol(dlgOptions,...
              'String','Ok',...
              'Position',[200 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @okOptionsCallback...
              );

     function set3DEngineCallback(hObject, ~)

        if get(chk3DEngine, 'Value') == 1
            if strcmpi(hObject.Style, 'checkbox')
                set(chk3DEngine, 'Value', 1);
            else
                set(chk3DEngine, 'Value', 0);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chk3DEngine, 'Value', 0);
            else
                set(chk3DEngine, 'Value', 1);
            end
        end

        if get(chk3DEngine, 'Value') == 1
            set(chkShading, 'Enable', 'on');
        else
            set(chkShading, 'Enable', 'off');
        end

     end

    function shadingCallback(hObject, ~)

        if get(chkShading, 'Value') == 1
            if strcmpi(hObject.Style, 'checkbox')
                set(chkShading, 'Value', 1);
            else
                set(chkShading, 'Value', 0);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkShading, 'Value', 0);
            else
                set(chkShading, 'Value', 1);
            end
        end

        if get(chkShading, 'Value') == 0
            if numel(dicomBuffer('get'))
                if size(dicomBuffer('get'), 3) == 1
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false

                        shading(axePtr('get'), 'flat');

                        if isFusion('get')
                            shading(axefPtr('get'), 'flat');
                        end

                    end
                else
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false

                        shading(axes1Ptr('get'), 'flat');
                        shading(axes2Ptr('get'), 'flat');
                        shading(axes3Ptr('get'), 'flat');

                        if isFusion('get')
                            shading(axes1fPtr('get'), 'flat');
                            shading(axes2fPtr('get'), 'flat');
                            shading(axes3fPtr('get'), 'flat');
                        end

                    end
                end
            end
        else
            if numel(dicomBuffer('get'))
                if size(dicomBuffer('get'), 3) == 1
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                        switchToMIPMode('get')   == false

                        shading(axePtr('get'), 'interp');
                        if isFusion('get')
                            shading(axefPtr('get'), 'interp');
                        end
                   end
                else
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false

                        shading(axes1Ptr('get'), 'interp');
                        shading(axes2Ptr('get'), 'interp');
                        shading(axes3Ptr('get'), 'interp');

                        if isFusion('get')
                            shading(axes1fPtr('get'), 'interp');
                            shading(axes2fPtr('get'), 'interp');
                            shading(axes3fPtr('get'), 'interp');
                        end

                    end
                end
            end
        end
    end

    function aspectRatioCallback(hObject, ~)

        if ~strcmpi(get(hObject, 'Style'), 'edit')

            if get(chkAspect, 'Value') == true
                if strcmpi(get(hObject, 'Style'), 'checkbox')
                    set(chkAspect, 'Value', true);
                else
                    set(chkAspect, 'Value', false);
                end
            else
                if strcmpi(get(hObject, 'Style'), 'checkbox')
                    set(chkAspect, 'Value', false);
                else
                    set(chkAspect, 'Value', true);
                end
            end
        end
        if get(chkAspect, 'Value') == 0

            set(edtRatioX, 'Enable', 'off');
            set(edtRatioY, 'Enable', 'off');
            set(edtRatioZ, 'Enable', 'off');

            if(numel(dicomBuffer('get')))
                if size(dicomBuffer('get'), 3) == 1

                    daspect(axePtr('get'), [1 1 1]);
                    axis(axePtr('get'), 'normal');

                    if isFusion('get') == true
                        daspect(axefPtr('get'), [1 1 1]);
                        axis(axefPtr('get'), 'normal');
                    end
                else
                    daspect(axes1Ptr('get'), [1 1 1]);
                    daspect(axes2Ptr('get'), [1 1 1]);
                    daspect(axes3Ptr('get'), [1 1 1]);

                    axis(axes1Ptr('get'), 'normal');
                    axis(axes2Ptr('get'), 'normal');
                    axis(axes3Ptr('get'), 'normal');

                    if isFusion('get') == true
                        daspect(axes1fPtr('get'), [1 1 1]);
                        daspect(axes2fPtr('get'), [1 1 1]);
                        daspect(axes3fPtr('get'), [1 1 1]);

                        axis(axes1fPtr('get'), 'normal');
                        axis(axes2fPtr('get'), 'normal');
                        axis(axes3fPtr('get'), 'normal');
                    end

                end
            end
        else

            set(edtRatioX, 'Enable', 'on');
            set(edtRatioY, 'Enable', 'on');
            set(edtRatioZ, 'Enable', 'on');

            if(numel(dicomBuffer('get')))
                if size(dicomBuffer('get'), 3) == 1

                    set(edtRatioZ, 'Enable', 'off');

                    % tCoreMetaData = dicomMetaData('get');
                    % daspect(axe, [computeAspectRatio('axes1', tCoreMetaData) 1 1]);

                    x = str2double(get(edtRatioX, 'String'));
                    y = str2double(get(edtRatioY, 'String'));

                    if x < 0
                       x = 0.1;
                       set(edtRatioX, 'String', num2str(x));
                    end
                    if y < 0
                       y = 0.1;
                       set(edtRatioY, 'String', num2str(y));
                    end

                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false
                        daspect(axePtr('get'), [x y 1]);
                        if isFusion('get') == true % TO DO, support fusion with is own aspect
                            daspect(axefPtr('get'), [x y 1]);
                        end

                    end

                else

                   x = str2double(get(edtRatioX, 'String'));
                   y = str2double(get(edtRatioY, 'String'));
                   z = str2double(get(edtRatioZ, 'String'));

                   if x < 0
                       x = 0.1;
                       set(edtRatioX, 'String', num2str(x));
                   end
                   if y < 0
                       y = 0.1;
                       set(edtRatioY, 'String', num2str(y));
                   end
                   if z < 0
                       z = 0.1;
                       set(edtRatioZ, 'String', num2str(z));
                   end
                   if switchTo3DMode('get')     == false && ...
                      switchToIsoSurface('get') == false && ...
                      switchToMIPMode('get')    == false

                       if strcmp(imageOrientation('get'), 'axial')
                            daspect(axes1Ptr('get'), [z x y]);
                            daspect(axes2Ptr('get'), [z y x]);
                            daspect(axes3Ptr('get'), [x y z]);
                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                daspect(axes1fPtr('get'), [z x y]);
                                daspect(axes2fPtr('get'), [z y x]);
                                daspect(axes3fPtr('get'), [x y z]);
                            end

                       elseif strcmp(imageOrientation('get'), 'coronal')
                            daspect(axes1Ptr('get'), [x y z]);
                            daspect(axes2Ptr('get'), [y z x]);
                            daspect(axes3Ptr('get'), [z x y]);
                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                daspect(axes1fPtr('get'), [x y z]);
                                daspect(axes2fPtr('get'), [y z x]);
                                daspect(axes3fPtr('get'), [z x y]);
                            end

                        elseif strcmp(imageOrientation('get'), 'sagittal')
                            daspect(axes1Ptr('get'), [y x z]);
                            daspect(axes2Ptr('get'), [x z y]);
                            daspect(axes3Ptr('get'), [z x y]);
                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                daspect(axes1fPtr('get'), [y x z]);
                                daspect(axes2fPtr('get'), [x z y]);
                                daspect(axes3fPtr('get'), [z x y]);
                            end
                       end
                   end
                end
            end
        end

    end

    function gateUseSeriesUIDCallback(hObject, ~)

        if get(chkUseUID, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUseUID, 'Value', true);

                set(chkLookupTable, 'Enable', 'on');
                set(uiLookupTable , 'Enable', 'on');
            else
                set(chkUseUID, 'Value', false);

                set(chkLookupTable, 'Enable', 'off');
                set(uiLookupTable , 'Enable', 'off');
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUseUID, 'Value', false);

                set(chkLookupTable, 'Enable', 'off');
                set(uiLookupTable , 'Enable', 'off');
            else
                set(chkUseUID, 'Value', true);

                set(chkLookupTable, 'Enable', 'on');
                set(uiLookupTable , 'Enable', 'on');
            end
        end
    end

    function gateLookupTableCallback(hObject, ~)

        if get(chkLookupTable, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLookupTable, 'Value', true);
                set(uiLookupTable , 'Enable', 'on');
            else
                set(chkLookupTable, 'Value', false);
                set(uiLookupTable , 'Enable', 'off');
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLookupTable, 'Value', false);
                set(uiLookupTable , 'Enable', 'off');
            else
                set(chkLookupTable, 'Value', true);
                set(uiLookupTable , 'Enable', 'on');
            end
        end
    end

    function viewBorderCallback(hObject, ~)

        if get(chkBorder, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkBorder, 'Value', true);
            else
                set(chkBorder, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkBorder, 'Value', false);
            else
                set(chkBorder, 'Value', true);
            end
        end

        if(numel(dicomBuffer('get')))
            if size(dicomBuffer('get'), 3) == 1 || ...
                switchTo3DMode('get')     == true || ...
                switchToIsoSurface('get') == true || ...
                switchToMIPMode('get')    == true

                set(uiOneWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
            else
                set(uiCorWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
                set(uiSagWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
                set(uiTraWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
            end
        end
    end

    function cancelOptionsCallback(~, ~)
        if numel(dicomBuffer('get')) && ...
           switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false

            if  gateUseSeriesUID('get') == true
                set(chkUseUID, 'Value', true);
            else
                set(chkUseUID, 'Value', false);
            end

            if  gateLookupTable('get') == true
                set(chkLookupTable, 'Value', true);
            else
                set(chkLookupTable, 'Value', false);
            end

            if size(dicomBuffer('get'), 3) == 1

                set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));

                if aspectRatio('get')
                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');

                    daspect(axePtr('get'), [x y 1]);
                    if isFusion('get') == true
                        daspect(axefPtr('get'), [x y 1]);
                    end
                else
                    daspect(axePtr('get'), [1 1 1]);
                    axis(axePtr('get'), 'normal');
                    if isFusion('get') == true
                        daspect(axefPtr('get'), [1 1 1]);
                        axis(axefPtr('get'), 'normal');
                    end
                end

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if isShading('get')
                        shading(axePtr('get'), 'interp');
                        if isFusion('get') == true
                            shading(axefPtr('get'), 'interp');
                        end

                    else
                        shading(axePtr('get'), 'flat');
                        if isFusion('get')
                            shading(axefPtr('get'), 'flat');
                        end

                    end
                end

            else
                set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));

                if aspectRatio('get')

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');
                    z = aspectRatioValue('get', 'z');

                   if strcmp(imageOrientation('get'), 'axial')
                        daspect(axes1Ptr('get'), [z x y]);
                        daspect(axes2Ptr('get'), [z y x]);
                        daspect(axes3Ptr('get'), [x y z]);
                        if isFusion('get')
                            daspect(axes1fPtr('get'), [z x y]);
                            daspect(axes2fPtr('get'), [z y x]);
                            daspect(axes3fPtr('get'), [x y z]);
                        end

                   elseif strcmp(imageOrientation('get'), 'coronal')
                        daspect(axes1Ptr('get'), [x y z]);
                        daspect(axes2Ptr('get'), [y z x]);
                        daspect(axes3Ptr('get'), [z x y]);
                        if isFusion('get')
                            daspect(axes1fPtr('get'), [x y z]);
                            daspect(axes2fPtr('get'), [y z x]);
                            daspect(axes3fPtr('get'), [z x y]);
                        end

                    elseif strcmp(imageOrientation('get'), 'sagittal')
                        daspect(axes1Ptr('get'), [y x z]);
                        daspect(axes2Ptr('get'), [x z y]);
                        daspect(axes3Ptr('get'), [z x y]);
                        if isFusion('get')
                            daspect(axes1fPtr('get'), [y x z]);
                            daspect(axes2fPtr('get'), [x z y]);
                            daspect(axes3fPtr('get'), [z x y]);
                        end
                   end
                else
                    daspect(axes1Ptr('get'), [1 1 1]);
                    daspect(axes2Ptr('get'), [1 1 1]);
                    daspect(axes3Ptr('get'), [1 1 1]);

                    axis(axes1Ptr('get'), 'normal');
                    axis(axes2Ptr('get'), 'normal');
                    axis(axes3Ptr('get'), 'normal');

                    if isFusion('get')
                        daspect(axes1fPtr('get'), [1 1 1]);
                        daspect(axes2fPtr('get'), [1 1 1]);
                        daspect(axes3fPtr('get'), [1 1 1]);

                        axis(axes1fPtr('get'), 'normal');
                        axis(axes2fPtr('get'), 'normal');
                        axis(axes3fPtr('get'), 'normal');
                    end

                end

                if isShading('get')
                    shading(axes1Ptr('get'), 'interp');
                    shading(axes2Ptr('get'), 'interp');
                    shading(axes3Ptr('get'), 'interp');
                    if isFusion('get')
                        shading(axes1fPtr('get'), 'interp');
                        shading(axes2fPtr('get'), 'interp');
                        shading(axes3fPtr('get'), 'interp');
                    end
                else
                    shading(axes1Ptr('get'), 'flat');
                    shading(axes2Ptr('get'), 'flat');
                    shading(axes3Ptr('get'), 'flat');
                    if isFusion('get')
                        shading(axes1fPtr('get'), 'flat');
                        shading(axes2fPtr('get'), 'flat');
                        shading(axes3fPtr('get'), 'flat');
                    end

                end
            end

        end

        delete(dlgOptions);
    end

    function okOptionsCallback(~, ~)

        bRefresh = false;
       
        if get(uiVoiRenderer, 'Value') == 1
            voi3DRenderer('set', 'VolumeRendering');
        else
            voi3DRenderer('set', 'Isosurface');
        end
       
        if get(chkBorder, 'Value') == 1
            showBorder('set', true);
        else
            showBorder('set', false);
        end


        if get(chkShading , 'Value') ~= isShading('get' ) || ...
           get(chk3DEngine, 'Value') ~= is3DEngine('get')
            bRefresh = true;
        end

        if get(chkUseUID, 'Value') == false
            gateUseSeriesUID('set', true);
        else
            gateUseSeriesUID('set', false);
        end

        if get(chkLookupTable, 'Value') == true
            gateLookupTable('set', true);
        else
            gateLookupTable('set', false);
        end

        dLookUpValue  = get(uiLookupTable, 'Value' );
        asLookUpValue = get(uiLookupTable, 'String');

        gateLookupType('set', asLookUpValue{dLookUpValue});

        if get(chkShading, 'Value') == true
            isShading('set', true);
        else
            isShading('set', false);
        end

        if get(chkAspect, 'Value') == true
            aspectRatio('set', true);
        else
            aspectRatio('set', false);
        end

        if get(chk3DEngine, 'Value') == true
            is3DEngine('set', true);
        else
            is3DEngine('set', false);
        end

        cropValue('set', str2double(get(edtCropValue, 'String')));

        aspectRatioValue('set', 'x', str2double(get(edtRatioX, 'String')));
        aspectRatioValue('set', 'y', str2double(get(edtRatioY, 'String')));
        aspectRatioValue('set', 'z', str2double(get(edtRatioZ, 'String')));

        delete(dlgOptions);

%                if gateUseSeriesUID('get') == false % resample buffer
%                    resampleRegisterSeries(gateLookupTable('get') , gateRegister('get'));
%                end

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false && ...
           bRefresh                  == true  && ...
           ~isempty(dicomBuffer('get'))

            bInitSegPanel = false;
            if  viewSegPanel('get') == true
                bInitSegPanel = true;
                viewSegPanel('set', false);
                objSegPanel = viewSegPanelMenuObject('get');
                if ~isempty(objSegPanel)
                    objSegPanel.Checked = 'off';
                end
            end

            bInitKernelPanel = false;
            if  viewKernelPanel('get') == true
                bInitKernelPanel = true;
                viewKernelPanel('set', false);
                objKernelPanel = viewKernelPanelMenuObject('get');
                if ~isempty(objKernelPanel)
                    objKernelPanel.Checked = 'off';
                end
            end

 %            triangulateCallback();

             clearDisplay();
             initDisplay(3);

             dicomViewerCore();

             if bInitSegPanel == true
                setViewSegPanel();
             end

             if bInitKernelPanel == true
                setViewKernelPanel();
             end
         end

%        if bRefreshImages == true
%            dicomViewerCore();
%        end
    end

end
