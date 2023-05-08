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

    DLG_OPTIONS_X = 380;
    DLG_OPTIONS_Y = 455;
    
    dlgOptions = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_OPTIONS_X/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_OPTIONS_Y/2) ...
                            DLG_OPTIONS_X ...
                            DLG_OPTIONS_Y ...
                            ],...
               'MenuBar', 'none',...
               'Resize', 'off', ...    
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Color', viewerBackgroundColor('get'), ...
               'Name', 'Set Properties',...
               'Toolbar','none'...               
               );           
           
        axes(dlgOptions, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 DLG_OPTIONS_X DLG_OPTIONS_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             );           
%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%   javaFrame = get(dlgOptions,'JavaFrame');
%   javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));                              
    % Show border

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'SUV Type',...
                  'horizontalalignment', 'left',...
                  'position', [20 412 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    gsSUVType = viewerSUVtype('get'); 

    if strcmpi(gsSUVType, 'BW') % Body Weight
        dSUVoffset = 1;
    elseif strcmpi(gsSUVType, 'FDG') % Brads FDG specific SUV
        dSUVoffset = 2;
    elseif strcmpi(gsSUVType, 'BSA') % body surface area
        dSUVoffset = 3;            
    elseif strcmpi(gsSUVType, 'LBM') % lean body mass 
        dSUVoffset = 4;
    elseif strcmpi(gsSUVType, 'LBMJANMA') % lean body mass by Janmahasatian method
        dSUVoffset = 5;
    else
        dSUVoffset = 1;
    end

        uicontrol(dlgOptions, ...
                  'enable'  , 'on',...
                  'Style'   , 'popup', ...
                  'position', [200 415 160 20],...
                  'String'  , {'BW', 'FDG', 'BSA', 'LBM', 'LBMJANMA'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , dSUVoffset, ...
                  'Callback', @updateSUVCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Export DICOM',...
                  'horizontalalignment', 'left',...
                  'position', [20 387 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );
              
    chkUpdateWriteUID = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , updateDicomWriteSeriesInstanceUID('get'),...
                  'position', [40 365 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @updateWriteUIDCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Update DICOM Series Instance UID',...
                  'horizontalalignment', 'left',...
                  'position', [60 362 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @updateWriteUIDCallback...
                  );

    chkOriginalMatrix = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , modifiedImagesContourMatrix('get'),...
                  'position', [40 340 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @modifiedImagesContourMatrixCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Modified Images Contour Matrix',...
                  'horizontalalignment', 'left',...
                  'position', [60 337 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @modifiedImagesContourMatrixCallback...
                  );              
              
              
    chkMip2DOnly = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , playback2DMipOnly('get'),...
                  'position', [20 315 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @mip2DOnlyCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '2D MIP Playback',...
                  'horizontalalignment', 'left',...
                  'position', [40 312 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @mip2DOnlyCallback...
                  );
              
         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D VOI Renderer',...
                  'horizontalalignment', 'left',...
                  'position', [20 287 200 20],...
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
                  'position', [200 290 160 20],...
                  'String'  , {'VolumeRendering', 'Isosurface'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , dVoiRendererOffset ...
                  );

    chk3DVoiSmooth = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , voi3DSmooth('get'),...
                  'position', [40 265 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Smooth 3D VOI',...
                  'horizontalalignment', 'left',...
                  'position', [60 262 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chk3DVoiSmoothCallback...
                  );

    % Show border

    chkBorder = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , showBorder('get'),...
                  'position', [20 240 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @viewBorderCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Show Border',...
                  'horizontalalignment', 'left',...
                  'position', [40 237 200 20],...
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
                  'position', [20 215 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @gateUseSeriesUIDCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Gate all series',...
                  'horizontalalignment', 'left',...
                  'position', [40 212 200 20],...
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
                  'position', [40 190 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @gateLookupTableCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Adjust Lookup Table',...
                  'horizontalalignment', 'left',...
                  'position', [60 187 200 20],...
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
                  'position', [200 190 160 20],...
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
                  'position', [20 165 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @aspectRatioCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Aspect ratio',...
                  'horizontalalignment', 'left',...
                  'position', [40 162 100 20],...
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
                 'position'  , [255 165 50 20],...
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
                 'position'  , [200 165 50 20],...
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
                 'position'  , [310 165 50 20],...
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
                  'position', [20 140 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @set3DEngineCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D Engine',...
                  'horizontalalignment', 'left',...
                  'position', [40 137 200 20],...
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
                  'position', [40 115 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @shadingCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D Interpolated Shading',...
                  'horizontalalignment', 'left',...
                  'position', [60 112 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn', @shadingCallback...
                  );
              
        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Sphere diameter (mm)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 87 150 20]...
                  );

  edtSphereValue = ...
      uicontrol(dlgOptions,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , num2str(sphereDefaultDiameter('get')),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 90 160 20]...
                );
            
        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Mask Pixel Value',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 62 150 20]...
                  );

  edtCropValue = ...
      uicontrol(dlgOptions,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , num2str(cropValue('get')),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 65 160 20]...
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

    function updateSUVCallback(hObject, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        dFusionOffset = get(uiFusedSeriesPtr('get'), 'Value');

        asSUVType = get(hObject, 'String');
        dSUVType  = get(hObject, 'Value');

        viewerSUVtype('set', asSUVType{dSUVType});         

        tInput = inputTemplate('get');                
      
        sUnitDisplay = getSerieUnitValue(dSeriesOffset);            
        if strcmpi(sUnitDisplay, 'SUV')
            dMax = windowLevel('get', 'max')*tInput(dSeriesOffset).tQuant.tSUV.dScale;
            dMin = windowLevel('get', 'min')*tInput(dSeriesOffset).tQuant.tSUV.dScale;
        end

        if isFusion('get')

            sUnitDisplay = getSerieUnitValue(dFusionOffset);            
            if strcmpi(sUnitDisplay, 'SUV')        
                dFusionMax = fusionWindowLevel('get', 'max')*tInput(dFusionOffset).tQuant.tSUV.dScale;
                dFusionMin = fusionWindowLevel('get', 'min')*tInput(dFusionOffset).tQuant.tSUV.dScale;
            end
        end

        if numel(tInput) ~= 0
            for dTemplateLoop = 1 : numel(tInput)       
                setQuantification(dTemplateLoop);
            end
        end

        tInput = inputTemplate('get');                

        sUnitDisplay = getSerieUnitValue(dSeriesOffset);            
        if strcmpi(sUnitDisplay, 'SUV')
            dMax = dMax/tInput(dSeriesOffset).tQuant.tSUV.dScale;
            dMin = dMin/tInput(dSeriesOffset).tQuant.tSUV.dScale;

            windowLevel('set', 'max', dMax);
            windowLevel('set', 'min', dMin);

            set(uiSliderWindowPtr('get'), 'value', 0.5);
            set(uiSliderLevelPtr('get') , 'value', 0.5);           
        end

        if isFusion('get')

            sUnitDisplay = getSerieUnitValue(dFusionOffset);            
            
            if strcmpi(sUnitDisplay, 'SUV') 
    
                dFusionMax = dFusionMax/tInput(dFusionOffset).tQuant.tSUV.dScale;
                dFusionMin = dFusionMin/tInput(dFusionOffset).tQuant.tSUV.dScale;

                fusionWindowLevel('set', 'max', dFusionMax);
                fusionWindowLevel('set', 'min', dFusionMin);
    
                set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
                set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

            end

        end 

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false

            sUnitDisplay = getSerieUnitValue(dSeriesOffset);            
            if strcmpi(sUnitDisplay, 'SUV')
    
                if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1            
                    set(axePtr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
                else
                    set(axes1Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
                    set(axes2Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
                    set(axes3Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
                    
                    if link2DMip('get') == true && isVsplash('get') == false
                        set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);            
                    end
                end
            end

            if isFusion('get')

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    sUnitDisplay = getSerieUnitValue(rr);            
                
                    if strcmpi(sUnitDisplay, 'SUV') 
    
                        if size(dicomBuffer('get', [], dNbFusedSeries), 3) == 1 
    
                            axefPtr = axefPtr('get', [], rr);
                            if ~isempty(axefPtr)
                                set(axefPtr, 'CLim', [dFusionMin dFusionMax]);
                            end
                        else
                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);
        
                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                set(axes1f, 'CLim', [dFusionMin dFusionMax]);
                                set(axes2f, 'CLim', [dFusionMin dFusionMax]);
                                set(axes3f, 'CLim', [dFusionMin dFusionMax]);                            
                            end
    
                            if link2DMip('get') == true && isVsplash('get') == false
                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    set(axesMipf, 'CLim', [dFusionMin dFusionMax]);            
                                end
                            end
                          
                        end
                    end
                end
               
            end
       
            refreshImages();
        end        

    end

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

                        shading(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');

                        if isFusion('get') == true
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axef = axefPtr('get', [], rr);

                                if ~isempty(axef) 
                                    shading(axef, 'flat');
                                end
                            end
                        end

                    end
                else
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false

                        shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        
                        if link2DMip('get') == true && isVsplash('get') == false                                               
                            shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        end
                        
                        if isFusion('get') == true
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axes1f = axes1fPtr('get', [], rr);
                                axes2f = axes2fPtr('get', [], rr);
                                axes3f = axes3fPtr('get', [], rr);

                                if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                    shading(axes1f, 'flat');
                                    shading(axes2f, 'flat');
                                    shading(axes3f, 'flat');                                    
                                end

                                if link2DMip('get') == true && isVsplash('get') == false 
                                    axesMipf = axesMipfPtr('get', [], rr);
                                    if ~isempty(axesMipf)
                                        shading(axesMipf, 'flat');
                                    end                                    
                                end                                
                            end
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

                        shading(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        if isFusion('get') == true
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axef = axefPtr('get', [], rr);

                                if ~isempty(axef) 
                                    shading(axef, 'interp');
                                end
                            end                           
                        end
                   end
                else
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false

                        shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        
                        if link2DMip('get') == true && isVsplash('get') == false                       
                            shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        end

                        if isFusion('get') == true
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axes1f = axes1fPtr('get', [], rr);
                                axes2f = axes2fPtr('get', [], rr);
                                axes3f = axes3fPtr('get', [], rr);

                                if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                    shading(axes1f, 'interp');
                                    shading(axes2f, 'interp');
                                    shading(axes3f, 'interp');                                    
                                end

                                if link2DMip('get') == true && isVsplash('get') == false

                                    axesMipf = axesMipfPtr('get', [], rr);
                                    if ~isempty(axesMipf)
                                        shading(axesMipf, 'interp');
                                    end
                                end

                            end
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

                    daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    axis(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');

                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);
                            if ~isempty(axef) 
                                daspect(axef, [1 1 1]);
                                axis(axef, 'normal');                                
                            end

                        end   
                        
                        if isPlotContours('get') == true 
                            daspect(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);                            
                       end    
                    end
                else
                    daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    
                    if isVsplash('get') == false                      
                        daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    end

                    axis(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    
                    if isVsplash('get') == false                                          
                        axis(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    end

                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries
                            
                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);
                            
                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                daspect(axes1f, [1 1 1]);
                                daspect(axes2f, [1 1 1]);
                                daspect(axes3f, [1 1 1]);
                                
                                axis(axes1f, 'normal');
                                axis(axes2f, 'normal');
                                axis(axes3f, 'normal');
                            end
                            
                            if link2DMip('get') == true && isVsplash('get') == false    
                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    daspect(axesMipf, [1 1 1]);
                                    axis(axesMipf, 'normal');
                                end
                            end
                        end
                    end
                    
                    if isPlotContours('get') == true && isVsplash('get') == false

                        daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        
                        axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                        
                        
                        if isVsplash('get') == false                                               
                            daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                            axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        end
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
                   
                        daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y 1]);
                        
                        if isFusion('get') == true % TO DO, support fusion with is own aspect
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axef = axefPtr('get', [], rr);
                                if ~isempty(axef)                          
                                    daspect(axef, [x y 1]);
                                end
                            end

                            if isPlotContours('get') == true 
                                daspect(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y 1]);                            
                           end                           
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

 %                      if strcmpi(imageOrientation('get'), 'axial')
                           
                            daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                            daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                            daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
                            
                            if isVsplash('get') == false                       
                                daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                            end
                            
                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                
                                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                                for rr=1:dNbFusedSeries

                                    axes1f = axes1fPtr('get', [], rr);
                                    axes2f = axes2fPtr('get', [], rr);
                                    axes3f = axes3fPtr('get', [], rr);

                                    if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                        daspect(axes1f, [z x y]);
                                        daspect(axes2f, [z y x]);
                                        daspect(axes3f, [x y z]);                                        
                                    end
                                    
                                    if isVsplash('get') == false    
                                        axesMipf = axesMipfPtr('get', [], rr);
                                        if ~isempty(axesMipf)
                                            daspect(axesMipf, [z y x]);
                                        end
                                    end
                                    
                                end
                            end
                            
                            if isPlotContours('get') == true && isVsplash('get') == false
                                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
                                
                                if isVsplash('get') == false                                                       
                                    daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                                end                                
                            end

%                       elseif strcmpi(imageOrientation('get'), 'coronal')
%                           
%                            daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                            daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y z x]);
%                            daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                            
%                            if link2DMip('get') == true && isVsplash('get') == false                                                   
%                                daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                            end
                            
%                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                
%                                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
%                                for rr=1:dNbFusedSeries

%                                    axes1f = axes1fPtr('get', [], rr);
%                                    axes2f = axes2fPtr('get', [], rr);
%                                    axes3f = axes3fPtr('get', [], rr);

%                                    if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                        daspect(axes1f, [x y z]);
%                                        daspect(axes2f, [y z x]);
%                                        daspect(axes3f, [z x y]);                                        
%                                    end
                                    
%                                    if link2DMip('get') == true && isVsplash('get') == false 
                                        
%                                        axesMipf = axesMipfPtr('get', [], rr);
%                                        if ~isempty(axesMipf)
%                                            daspect(axesMipf, [x y z]);
%                                        end
%                                    end                                    
%                                end

%                            end
                            
%                            if isPlotContours('get') == true && isVsplash('get') == false
                                
%                                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
%                                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y z x]);
%                                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                                
%                                if link2DMip('get') == true && isVsplash('get') == false                                                       
%                                    daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
%                                end                                
%                            end
                            
%                        elseif strcmpi(imageOrientation('get'), 'sagittal')
                            
%                            daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                            daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]);
%                            daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                            
%                            if link2DMip('get') == true && isVsplash('get') == false                                                   
%                                daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                            end
                            
%                            if isFusion('get') == true % TO DO, support fusion with is own aspect
                                
%                                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
%                                for rr=1:dNbFusedSeries

%                                    axes1f = axes1fPtr('get', [], rr);
%                                    axes2f = axes2fPtr('get', [], rr);
%                                    axes3f = axes3fPtr('get', [], rr);

%                                    if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                        daspect(axes1f, [y x z]);
%                                        daspect(axes2f, [x z y]);
%                                        daspect(axes3f, [z x y]);                                          
%                                    end
                                    
%                                    if link2DMip('get') == true && isVsplash('get') == false   
                                        
%                                        axesMipf = axesMipfPtr('get', [], rr);
%                                        if ~isempty(axesMipf)
%                                            daspect(axesMipf, [y x z]);
%                                        end
%                                    end                                     
%                                end

%                            end
                            
%                            if isPlotContours('get') == true && isVsplash('get') == false
                                
%                                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y x z]);
%                                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x z y]);
%                                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                                
%                                if link2DMip('get') == true && isVsplash('get') == false                                                       
%                                    daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y x z]);
%                                end                                
%                            end                            
%                       end
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

    function updateWriteUIDCallback(hObject, ~)

        if get(chkUpdateWriteUID, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUpdateWriteUID, 'Value', true);
            else
                set(chkUpdateWriteUID, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUpdateWriteUID, 'Value', false);
            else
                set(chkUpdateWriteUID, 'Value', true);
            end
        end
    end

    function modifiedImagesContourMatrixCallback(hObject, ~)

        if get(chkOriginalMatrix, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkOriginalMatrix, 'Value', true);
            else
                set(chkOriginalMatrix, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkOriginalMatrix, 'Value', false);
            else
                set(chkOriginalMatrix, 'Value', true);
            end
        end
    end


    function mip2DOnlyCallback(hObject, ~)

        if get(chkMip2DOnly, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkMip2DOnly, 'Value', true);
            else
                set(chkMip2DOnly, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkMip2DOnly, 'Value', false);
            else
                set(chkMip2DOnly, 'Value', true);
            end
        end
    end


    function chk3DVoiSmoothCallback(~, ~)

        if get(chk3DVoiSmooth, 'Value') == false
            set(chk3DVoiSmooth, 'Value', true );
        else
            set(chk3DVoiSmooth, 'Value', false);
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
                set(uiMipWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
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

                    daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y 1]);
                    
                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);
                            if ~isempty(axef)                                        
                                daspect(axef, [x y 1]);
                            end
                        end
                    end
                else
                    daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    axis(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    
                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);
                            if ~isempty(axef) 
                                daspect(axef, [1 1 1]);
                                axis(axef, 'normal');                                
                            end
                        end
                    end
                end

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if isShading('get')
                        shading(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        
                        if isFusion('get') == true
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axef = axefPtr('get', [], rr);
                                if ~isempty(axef) 
                                    shading(axef, 'interp');
                                end
                            end
                        end

                    else
                        
                        shading(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        
                        if isFusion('get') == true
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axef = axefPtr('get', [], rr);
                                if ~isempty(axef) 
                                    shading(axef, 'flat');
                                end
                            end                            
                        end

                    end
                end

            else
                set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiMipWindowPtr('get'), 'BorderWidth', showBorder('get'));

                if aspectRatio('get')

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');
                    z = aspectRatioValue('get', 'z');

%                   if strcmpi(imageOrientation('get'), 'axial')
                       
                        daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                        daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                        daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
                        
                        if isVsplash('get') == false                       
                            daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                        end
                        
                        if isFusion('get') == true
                            
                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                axes1f = axes1fPtr('get', [], rr);
                                axes2f = axes2fPtr('get', [], rr);
                                axes3f = axes3fPtr('get', [], rr);

                                if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                    daspect(axes1f, [z x y]);
                                    daspect(axes2f, [z y x]);
                                    daspect(axes3f, [x y z]);                                    
                                end

                                if isVsplash('get') == false

                                    axesMipf = axesMipfPtr('get', [], rr);
                                    if ~isempty(axesMipf)
                                        daspect(axesMipf, [z y x]);
                                    end
                                end

                            end
                        end
                        
                        if isPlotContours('get') && isVsplash('get') == false 
                            
                            daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                            daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                            daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
                            
                            if isVsplash('get') == false                        
                                daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                            end
                        end
                        
%                   elseif strcmpi(imageOrientation('get'), 'coronal')
                       
%                        daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                        daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y z x]);
%                        daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                        
%                        if link2DMip('get') == true && isVsplash('get') == false                                               
%                            daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                        end
                        
%                        if isFusion('get') == true
                            
%                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
%                            for rr=1:dNbFusedSeries

%                                axes1f = axes1fPtr('get', [], rr);
%                                axes2f = axes2fPtr('get', [], rr);
%                                axes3f = axes3fPtr('get', [], rr);

%                                if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                    daspect(axes1f, [x y z]);
%                                    daspect(axes2f, [y z x]);
%                                    daspect(axes3f, [z x y]);                                    
%                                end

%                                if link2DMip('get') == true && isVsplash('get') == false

%                                    axesMipf = axesMipfPtr('get', [], rr);
%                                    if ~isempty(axesMipf)
%                                        daspect(axesMipf, [x y z]);
%                                    end
%                                end

%                            end                            
%                        end
                       
%                        if isPlotContours('get') && isVsplash('get') == false 
                            
%                            daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
%                            daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y z x]);
%                            daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                            
%                            if link2DMip('get') == true && isVsplash('get') == false                      
%                                daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
%                            end
%                        end
                       
%                    elseif strcmpi(imageOrientation('get'), 'sagittal')
                        
%                        daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                        daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]);
%                        daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                        
%                        if link2DMip('get') == true && isVsplash('get') == false                                               
%                            daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                        end
                        
%                        if isFusion('get') == true
                            
%                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
%                            for rr=1:dNbFusedSeries

%                                axes1f = axes1fPtr('get', [], rr);
%                                axes2f = axes2fPtr('get', [], rr);
%                                axes3f = axes3fPtr('get', [], rr);

%                                if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                    daspect(axes1f, [y x z]);
%                                    daspect(axes2f, [x z y]);
%                                    daspect(axes3f, [z x y]);                                    
%                                end

%                                if link2DMip('get') == true && isVsplash('get') == false

%                                    axesMipf = axesMipfPtr('get', [], rr);
%                                    if ~isempty(axesMipf)
%                                        daspect(axesMipf, [y x z]);
%                                    end
%                                end

%                            end                            
%                        end
                        
%                        if isPlotContours('get') && isVsplash('get') == false 
                            
%                            daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y x z]);
%                            daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x z y]);
%                            daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                            
%                            if link2DMip('get') == true && isVsplash('get') == false                                   
%                                daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [y x z]);
%                            end
%                        end
%                   end
                else
                    daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                    
                    axis(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');                    
                    
                    if isVsplash('get') == false                                           
                        daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [1 1 1]);
                        axis(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
                    end

                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);

                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                daspect(axes1f, [1 1 1]);
                                daspect(axes2f, [1 1 1]);
                                daspect(axes3f, [1 1 1]);                                                                

                                axis(axes1f, 'normal');
                                axis(axes2f, 'normal');
                                axis(axes3f, 'normal');                                
                            end

                            if isVsplash('get') == false

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    daspect(axesMipf, [1 1 1]);
                                    axis(axesMipf, 'normal');
                                end
                            end

                        end                                                
                    end
                    
                    if isPlotContours('get') && isVsplash('get') == false 
                        
                        daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                        
                        axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        
                        if isVsplash('get') == false                                               
                            daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                            axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                        end                       
                    end

                end

                if isShading('get')
                    
                    shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                    shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                    shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                    if link2DMip('get') == true && isVsplash('get') == false                                           
                        shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                    end
                    
                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);

                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                shading(axes1f, 'interp');
                                shading(axes2f, 'interp');
                                shading(axes3f, 'interp');
                            end

                            if link2DMip('get') == true && isVsplash('get') == false

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    shading(axesMipf, 'interp');
                                end
                            end

                        end
                    end
                else
                    shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                    shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                    shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                    
                    if link2DMip('get') == true && isVsplash('get') == false                                           
                        shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                    end
                    
                    if isFusion('get') == true
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);

                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                                shading(axes1f, 'flat');
                                shading(axes2f, 'flat');
                                shading(axes3f, 'flat');                                
                            end

                            if link2DMip('get') == true && isVsplash('get') == false

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    shading(axesMipf, 'flat');
                                end
                            end
                        end
                    end

                end
            end

        end

        delete(dlgOptions);
    end

    function okOptionsCallback(~, ~)

        bRefresh = false;
        
        if get(chkUpdateWriteUID, 'Value') == true
            updateDicomWriteSeriesInstanceUID('set', true);
        else
            updateDicomWriteSeriesInstanceUID('set', false);
        end
        
        if get(chkOriginalMatrix, 'Value') == true
            modifiedImagesContourMatrix('set', true);
        else
            modifiedImagesContourMatrix('set', false);
        end
        
        if get(chkMip2DOnly, 'Value') == true
            playback2DMipOnly('set', true);
        else
            playback2DMipOnly('set', false);
        end
        
        if get(uiVoiRenderer, 'Value') == true
            voi3DRenderer('set', 'VolumeRendering');
        else
            voi3DRenderer('set', 'Isosurface');
        end
       
        if get(chk3DVoiSmooth, 'Value') == true
            voi3DSmooth('set', true);
        else
            voi3DSmooth('set', false);
        end

        if get(chkBorder, 'Value') == true
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
        
        sphereDefaultDiameter('set', str2double(get(edtSphereValue, 'String')));

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
            
            bInitRoiPanel = false;
            if  viewRoiPanel('get') == true
                bInitRoiPanel = true;
                viewRoiPanel('set', false);
                objRoiPanel = viewRoiPanelMenuObject('get');
                if ~isempty(objRoiPanel)
                    objRoiPanel.Checked = 'off';
                end
            end
            
 %            triangulateCallback();
 
             bInitContours = false;   
             if isPlotContours('get') == true % Deactivate Contours
                 bInitContours = true;
                 setPlotContoursCallback();
             end

             clearDisplay();
             initDisplay(3);

             if isFusion('get') == true
                 if bInitContours == true % Reactivate Contours
                    setPlotContoursCallback();                     
                 end
             end
             
             dicomViewerCore();

             if bInitSegPanel == true
                setViewSegPanel();
             end

             if bInitKernelPanel == true
                setViewKernelPanel();
             end
             
             if bInitRoiPanel == true
                setViewRoiPanel();
             end             
         end

%        if bRefreshImages == true
%            dicomViewerCore();
%        end
    end

end
