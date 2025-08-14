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

    if viewerUIFigure('get') == true

        dlgOptions = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_OPTIONS_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_OPTIONS_Y/2) ...
                                DLG_OPTIONS_X ...
                                DLG_OPTIONS_Y ...
                                ],...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'WindowStyle', 'modal', ...
                   'Name' , 'Viewer Options'...
                   );
    else
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
                   'Name', 'Viewer Options',...
                   'Toolbar','none'...
                   );
    end

    setObjectIcon(dlgOptions);

    axeOptions = ...
        axes(dlgOptions, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 DLG_OPTIONS_X DLG_OPTIONS_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
    axeOptions.Interactions = [];
    % axeOptions.Toolbar.Visible = 'off';
    deleteAxesToolbar(axeOptions);
    disableDefaultInteractivity(axeOptions);

    chkenableErrorLogging = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , enableErrorLogging('get'),...
                  'position', [20 410 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @enableErrorLoggingCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Error Logging',...
                  'horizontalalignment', 'left',...
                  'position', [40 410 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @enableErrorLoggingCallback...
                  );

    chkLinkCoronalWithSagittal = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , linkCoronalWithSagittal('get'),...
                  'position', [20 385 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @linkCoronalWithSagittalCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Link Zoom\Pan between Coronal and Sagittal',...
                  'horizontalalignment', 'left',...
                  'position', [40 385 300 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @linkCoronalWithSagittalCallback...
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
                  'position', [20 360 200 20],...
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
                  'position', [200 360 160 25],...
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
                  'position', [20 330 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );

    chkUpdateWriteUID = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , updateDicomWriteSeriesInstanceUID('get'),...
                  'position', [40 305 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @updateWriteUIDCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Update DICOM Series Instance UID',...
                  'horizontalalignment', 'left',...
                  'position', [60 305 200 20],...
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
                  'position', [40 280 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @modifiedImagesContourMatrixCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Contours from Modified Images Matrix',...
                  'horizontalalignment', 'left',...
                  'position', [60 280 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @modifiedImagesContourMatrixCallback...
                  );


    % chkMip2DOnly = ...
    %     uicontrol(dlgOptions,...
    %               'style'   , 'checkbox',...
    %               'enable'  , 'on',...
    %               'value'   , playback2DMipOnly('get'),...
    %               'position', [20 255 20 20],...
    %               'BackgroundColor', viewerBackgroundColor('get'), ...
    %               'ForegroundColor', viewerForegroundColor('get'), ...
    %               'Callback', @mip2DOnlyCallback...
    %               );
    % 
    %      uicontrol(dlgOptions,...
    %               'style'   , 'text',...
    %               'string'  , '2D MIP Playback',...
    %               'horizontalalignment', 'left',...
    %               'position', [40 255 200 20],...
    %               'Enable', 'Inactive',...
    %               'BackgroundColor', viewerBackgroundColor('get'), ...
    %               'ForegroundColor', viewerForegroundColor('get'), ...
    %               'ButtonDownFcn', @mip2DOnlyCallback...
    %               );

     bVoiViewer3d = false;
     if ~isMATLABReleaseOlderThan('R2022b')

        if viewerUIFigure('get') == true || ...
           ~isMATLABReleaseOlderThan('R2025a')    
            
            bVoiViewer3d = true;
        end
     end
     

    if bVoiViewer3d == true
        sVoiRenderingEnable = 'off';
    else
        sVoiRenderingEnable = 'on';
    end

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , '3D VOI Renderer',...
                  'horizontalalignment', 'left',...
                  'position', [20 230 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', sVoiRenderingEnable...
                  );

    sVoiRenderer = voi3DRenderer('get');
    if strcmpi(sVoiRenderer, 'VolumeRendering')
       dVoiRendererOffset = 1;
    elseif strcmpi(sVoiRenderer, 'Isosurface')
       dVoiRendererOffset = 2;
    else
       dVoiRendererOffset = 3;
    end


    uiVoiRenderer = ...
        uicontrol(dlgOptions, ...
                  'Enable', sVoiRenderingEnable, ...
                  'Style'   , 'popup', ...
                  'position', [200 230 160 25],...
                  'String'  , {'VolumeRendering', 'Isosurface', 'LabelRendering'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'   , dVoiRendererOffset ...
                  );

    chk3DVoiSmooth = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'Enable', sVoiRenderingEnable,...
                  'value'   , voi3DSmooth('get'),...
                  'position', [40 205 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );

    if bVoiViewer3d == true
        sVoiRenderingEnable = 'off';
    else
        sVoiRenderingEnable = 'Inactive';
    end
         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Smooth 3D VOI',...
                  'horizontalalignment', 'left',...
                  'position', [60 205 200 20],...
                  'Enable', sVoiRenderingEnable,...
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
                  'position', [20 180 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @viewBorderCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Show Border',...
                  'horizontalalignment', 'left',...
                  'position', [40 180 200 20],...
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
                  'position', [20 155 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @gateUseSeriesUIDCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Gate all series',...
                  'horizontalalignment', 'left',...
                  'position', [40 155 200 20],...
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
                  'position', [40 130 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @gateLookupTableCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Adjust Lookup Table',...
                  'horizontalalignment', 'left',...
                  'position', [60 130 200 20],...
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
                  'position', [200 130 160 25],...
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
                  'position', [20 100 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @aspectRatioCallback...
                  );

         uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Aspect ratio',...
                  'horizontalalignment', 'left',...
                  'position', [40 100 100 20],...
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

   if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

        sXValue = num2str(aspectRatioValue('get', 'x'));
        sYValue = num2str(aspectRatioValue('get', 'y'));

        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
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
                 'position'  , [255 100 50 20],...
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
                 'position'  , [200 100 50 20],...
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
                 'position'  , [310 100 50 20],...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...
                 'Callback'  , @aspectRatioCallback...
                 );
    % 3D Engine

%     chk3DEngine = ...
%         uicontrol(dlgOptions,...
%                   'style'   , 'checkbox',...
%                   'enable'  , 'on',...
%                   'value'   , is3DEngine('get'),...
%                   'position', [20 75 20 20],...
%                   'BackgroundColor', viewerBackgroundColor('get'), ...
%                   'ForegroundColor', viewerForegroundColor('get'), ...
%                   'Callback', @set3DEngineCallback...
%                   );
%
%         uicontrol(dlgOptions,...
%                   'style'   , 'text',...
%                   'string'  , '3D Engine',...
%                   'horizontalalignment', 'left',...
%                   'position', [40 75 200 20],...
%                   'Enable', 'Inactive',...
%                   'BackgroundColor', viewerBackgroundColor('get'), ...
%                   'ForegroundColor', viewerForegroundColor('get'), ...
%                   'ButtonDownFcn', @set3DEngineCallback...
%                   );
    % Shading

%     if is3DEngine('get') == true
%         sShadEnable = 'on';
%
%     else
%         sShadEnable = 'off';
%     end

    chkInterpolate = ...
        uicontrol(dlgOptions,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , isInterpolated('get'),...
                  'position', [20 50 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @shadingCallback...
                  );

        uicontrol(dlgOptions,...
                  'style'   , 'text',...
                  'string'  , 'Press (I) to Toggle Image Bilinear Interpolation',...
                  'horizontalalignment', 'left',...
                  'position', [40 50 300 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @shadingCallback...
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

    function enableErrorLoggingCallback(hObject, ~)

        if get(chkenableErrorLogging, 'Value') == 1
            if strcmpi(hObject.Style, 'checkbox')
                set(chkenableErrorLogging, 'Value', 1);
            else
                set(chkenableErrorLogging, 'Value', 0);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkenableErrorLogging, 'Value', 0);
            else
                set(chkenableErrorLogging, 'Value', 1);
            end
        end

    end

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

%             set(uiSliderWindowPtr('get'), 'value', 0.5);
%             set(uiSliderLevelPtr('get') , 'value', 0.5);
        end

        if isFusion('get')

            sUnitDisplay = getSerieUnitValue(dFusionOffset);

            if strcmpi(sUnitDisplay, 'SUV')

                dFusionMax = dFusionMax/tInput(dFusionOffset).tQuant.tSUV.dScale;
                dFusionMin = dFusionMin/tInput(dFusionOffset).tQuant.tSUV.dScale;

                fusionWindowLevel('set', 'max', dFusionMax);
                fusionWindowLevel('set', 'min', dFusionMin);

%                 set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

            end

        end

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false

            sUnitDisplay = getSerieUnitValue(dSeriesOffset);
            if strcmpi(sUnitDisplay, 'SUV')

                setWindowMinMax(dMax, dMin);

%                 if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
%                     set(axePtr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
%                 else
%                     set(axes1Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
%                     set(axes2Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
%                     set(axes3Ptr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
%
%                     if link2DMip('get') == true && isVsplash('get') == false
%                         set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [dMin dMax]);
%                     end
%                 end
            end

            if isFusion('get')

                sUnitDisplay = getSerieUnitValue(dFusionOffset);
                if strcmpi(sUnitDisplay, 'SUV')
                    setFusionWindowMinMax(dFusionMax, dFusionMin);
                end

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

                            dFusionMax = fusionWindowLevel('get', 'max');
                            dFusionMin = fusionWindowLevel('get', 'min');

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

    % function set3DEngineCallback(hObject, ~)
    % 
    %     if get(chk3DEngine, 'Value') == 1
    %         if strcmpi(hObject.Style, 'checkbox')
    %             set(chk3DEngine, 'Value', 1);
    %         else
    %             set(chk3DEngine, 'Value', 0);
    %         end
    %     else
    %         if strcmpi(hObject.Style, 'checkbox')
    %             set(chk3DEngine, 'Value', 0);
    %         else
    %             set(chk3DEngine, 'Value', 1);
    %         end
    %     end
    % 
    %     if get(chk3DEngine, 'Value') == 1
    %         set(chkInterpolate, 'Enable', 'on');
    %     else
    %         set(chkInterpolate, 'Enable', 'off');
    %     end
    % 
    %  end

    function shadingCallback(hObject, ~)

        if get(chkInterpolate, 'Value') == 1
            if strcmpi(hObject.Style, 'checkbox')
                set(chkInterpolate, 'Value', 1);
            else
                set(chkInterpolate, 'Value', 0);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkInterpolate, 'Value', 0);
            else
                set(chkInterpolate, 'Value', 1);
            end
        end

        setImageInterpolation(get(chkInterpolate, 'Value'));
        
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

            if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

                    axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    daspect(axe, [1 1 1]);

                    axis(axe, 'normal');
                   
                    % axe.Toolbar.Visible = 'off';                                      

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);
                            if ~isempty(axef)

                                daspect(axef, [1 1 1]);

                                axis(axef, 'normal');
                                
                                % axef.Toolbar.Visible = 'off';                                      
                            end

                        end

                        if isPlotContours('get') == true

                            axefc = axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                            daspect(axefc, [1 1 1]);

                            % axefc.Toolbar.Visible = 'off';  
                       end
                    end
                else

                    axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    daspect(axes1, [1 1 1]);
                    daspect(axes2, [1 1 1]);
                    daspect(axes3, [1 1 1]);                                   

                    if isVsplash('get') == false
                        axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                        daspect(axesMip, [1 1 1]);
                    end

                    axis(axes1, 'normal');
                    axis(axes2, 'normal');
                    axis(axes3, 'normal');

                    % axes1.Toolbar.Visible = 'off';                                      
                    % axes2.Toolbar.Visible = 'off';                                      
                    % axes3.Toolbar.Visible = 'off';   

                    if isVsplash('get') == false

                        axis(axesMip, 'normal');

                        % axesMip.Toolbar.Visible = 'off';
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

                               % axes1f.Toolbar.Visible = 'off';   
                               % axes2f.Toolbar.Visible = 'off';   
                               % axes3f.Toolbar.Visible = 'off';   

                            end

                            if link2DMip('get') == true && isVsplash('get') == false

                                axesMipf = axesMipfPtr('get', [], rr);

                                if ~isempty(axesMipf)

                                    daspect(axesMipf, [1 1 1]);

                                    axis(axesMipf, 'normal');

                                    % axesMipf.Toolbar.Visible = 'off';                             
                                end
                            end
                        end
                    end

                    if isPlotContours('get') == true && isVsplash('get') == false

                        axes1fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        axes2fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        axes3fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                        daspect(axes1fc, [1 1 1]);
                        daspect(axes2fc, [1 1 1]);
                        daspect(axes3fc, [1 1 1]);

                        axis(axes1fc, 'normal');
                        axis(axes2fc, 'normal');
                        axis(axes3fc, 'normal');

                        % axes1fc.Toolbar.Visible = 'off';                             
                        % axes2fc.Toolbar.Visible = 'off';                             
                        % axes3fc.Toolbar.Visible = 'off';                             

                        if isVsplash('get') == false

                            axesMipfc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                            daspect(axesMipfc, [1 1 1]);

                            axis(axesMipfc, 'normal');

                            % axesMipfc.Toolbar.Visible = 'off';    
                        end
                    end

                end
            end
        else

            set(edtRatioX, 'Enable', 'on');
            set(edtRatioY, 'Enable', 'on');
            set(edtRatioZ, 'Enable', 'on');

            if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

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

                                    % axef.Toolbar.Visible = 'off';    
                                end
                            end

                            if isPlotContours('get') == true

                                axefc = axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                                daspect(axefc, [x y 1]);

                                % axefc.Toolbar.Visible = 'off';
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

                            axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                            axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                            axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                            daspect(axes1, [z x y]);
                            daspect(axes2, [z y x]);
                            daspect(axes3, [x y z]);

                            % axes1.Toolbar.Visible = 'off';
                            % axes2.Toolbar.Visible = 'off';
                            % axes3.Toolbar.Visible = 'off';

                            if isVsplash('get') == false

                                axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                                daspect(axesMip, [z y x]);

                                % axesMip.Toolbar.Visible = 'off';
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

                                        % axes1f.Toolbar.Visible = 'off';
                                        % axes2f.Toolbar.Visible = 'off';
                                        % axes3f.Toolbar.Visible = 'off';

                                    end

                                    if isVsplash('get') == false

                                        axesMipf = axesMipfPtr('get', [], rr);

                                        if ~isempty(axesMipf)

                                            daspect(axesMipf, [z y x]);

                                            % axesMipf.Toolbar.Visible = 'off';
                                        end
                                    end

                                end
                            end

                            if isPlotContours('get') == true && isVsplash('get') == false

                                axes1fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                                axes2fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                                axes3fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                                daspect(axes1fc, [z x y]);
                                daspect(axes2fc, [z y x]);
                                daspect(axes3fc, [x y z]);

                                % axes1fc.Toolbar.Visible = 'off';
                                % axes2fc.Toolbar.Visible = 'off';
                                % axes3fc.Toolbar.Visible = 'off';

                                if isVsplash('get') == false

                                    axesMipfc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                                    daspect(axesMipfc, [z y x]);

                                    % axesMipfc.Toolbar.Visible = 'off';
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


    % function mip2DOnlyCallback(hObject, ~)
    % 
    %     if get(chkMip2DOnly, 'Value') == true
    %         if strcmpi(hObject.Style, 'checkbox')
    %             set(chkMip2DOnly, 'Value', true);
    %         else
    %             set(chkMip2DOnly, 'Value', false);
    %         end
    %     else
    %         if strcmpi(hObject.Style, 'checkbox')
    %             set(chkMip2DOnly, 'Value', false);
    %         else
    %             set(chkMip2DOnly, 'Value', true);
    %         end
    %     end
    % end

    function linkCoronalWithSagittalCallback(hObject, ~)

        if get(chkLinkCoronalWithSagittal, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLinkCoronalWithSagittal, 'Value', true);
            else
                set(chkLinkCoronalWithSagittal, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLinkCoronalWithSagittal, 'Value', false);
            else
                set(chkLinkCoronalWithSagittal, 'Value', true);
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

        if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1 || ...
               switchTo3DMode('get')     == true || ...
               switchToIsoSurface('get') == true || ...
               switchToMIPMode('get')    == true

                if get(chkBorder, 'Value') == true
                    sBorderType = 'line';
                else
                    sBorderType = 'none';
                end

                 set(uiOneWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                 set(uiOneWindowPtr('get'), 'BorderType', sBorderType);

%                 set(uiOneWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
            else
%                 set(uiCorWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
%                 set(uiSagWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
%                 set(uiTraWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));
%                 set(uiMipWindowPtr('get'), 'BorderWidth', get(chkBorder, 'Value'));

                if get(chkBorder, 'Value') == true
                    sBorderType = 'line';
                else
                    sBorderType = 'none';
                end

                 set(uiCorWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                 set(uiSagWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                 set(uiTraWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                 set(uiMipWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);

                 set(uiCorWindowPtr('get'), 'BorderType', sBorderType);
                 set(uiSagWindowPtr('get'), 'BorderType', sBorderType);
                 set(uiTraWindowPtr('get'), 'BorderType', sBorderType);
                 set(uiMipWindowPtr('get'), 'BorderType', sBorderType);                 
            end
        end
    end

    function cancelOptionsCallback(~, ~)

        if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
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

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

                if showBorder('get') == true
                    sBorderType = 'line';
                else
                    sBorderType = 'none';
                end

                set(uiOneWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                set(uiOneWindowPtr('get'), 'BorderType', sBorderType);

%                 set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));

                if aspectRatio('get')

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');

                    axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    daspect(axe, [x y 1]);

                    % axe.Toolbar.Visible = 'off';

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);

                            if ~isempty(axef)

                                daspect(axef, [x y 1]);

                                % axef.Toolbar.Visible = 'off';
                            end
                        end
                    end
                else
                    axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    daspect(axe, [1 1 1]);

                    axis(axe, 'normal');

                    % axe.Toolbar.Visible = 'off';

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            axef = axefPtr('get', [], rr);

                            if ~isempty(axef)

                                daspect(axef, [1 1 1]);

                                axis(axef, 'normal');

                                % axef.Toolbar.Visible = 'off';
                            end
                        end
                    end
                end

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if isInterpolated('get')

                        % axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                       
%                         shading(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        set(imAxePtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'bilinear');
                     
                        % axe.Toolbar.Visible = 'off';

                        if isFusion('get') == true

                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                imAxef = imAxeFPtr('get', [] , rr);

                                if ~isempty(imAxef)
%                                     shading(axef, 'interp');
                                    set(imAxef,  'Interpolation', 'bilinear');

                                end

                                axef = axefPtr('get', [], rr);

                                if ~isempty(axef)
                                    % axef.Toolbar.Visible = 'off';
                                end

                            end
                        end

                    else
                        % axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
%                         shading(axe, 'flat');

                        set(imAxePtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'nearest');
                       
                        % axe.Toolbar.Visible = 'off';

                        if isFusion('get') == true

                            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                            for rr=1:dNbFusedSeries

                                imAxef = imAxeFPtr('get', [] , rr);

                                if ~isempty(imAxef)
%                                     shading(axef, 'interp');
                                    set(imAxef,  'Interpolation', 'nearest');

                                end

                                axef = axefPtr('get', [], rr);

                                if ~isempty(axef)

                                    % axef.Toolbar.Visible = 'off';
                               end
                            end
                        end

                    end
                end

            else

                if showBorder('get') == true
                    sBorderType = 'line';
                else
                    sBorderType = 'none';
                end

                set(uiCorWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                set(uiSagWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                set(uiTraWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
                set(uiMipWindowPtr('get'), 'HighlightColor', [0.7000 0.7000 0.7000]);
         
                set(uiCorWindowPtr('get'), 'BorderType', sBorderType);
                set(uiSagWindowPtr('get'), 'BorderType', sBorderType);
                set(uiTraWindowPtr('get'), 'BorderType', sBorderType);
                set(uiMipWindowPtr('get'), 'BorderType', sBorderType);

%                 set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
%                 set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
%                 set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
%                 set(uiMipWindowPtr('get'), 'BorderWidth', showBorder('get'));

                if aspectRatio('get')

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');
                    z = aspectRatioValue('get', 'z');

%                   if strcmpi(imageOrientation('get'), 'axial')
                        axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                        axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                        axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                        daspect(axes1, [z x y]);
                        daspect(axes2, [z y x]);
                        daspect(axes3, [x y z]);

                        % axes1.Toolbar.Visible = 'off';
                        % axes2.Toolbar.Visible = 'off';
                        % axes3.Toolbar.Visible = 'off';

                        if isVsplash('get') == false

                            axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                            daspect(axesMip, [z y x]);

                            % axesMip.Toolbar.Visible = 'off';
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

                                    % axes1f.Toolbar.Visible = 'off';
                                    % axes2f.Toolbar.Visible = 'off';
                                    % axes3f.Toolbar.Visible = 'off';
                                end

                                if isVsplash('get') == false

                                    axesMipf = axesMipfPtr('get', [], rr);
                                    if ~isempty(axesMipf)

                                        daspect(axesMipf, [z y x]);

                                        % axesMipf.Toolbar.Visible = 'off';
                                    end
                                end

                            end
                        end

                        if isPlotContours('get') && isVsplash('get') == false

                            axes1fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                            axes2fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                            axes3fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                            daspect(axes1fc, [z x y]);
                            daspect(axes2fc, [z y x]);
                            daspect(axes3fc, [x y z]);
                             
                            % axes1fc.Toolbar.Visible = 'off';
                            % axes2fc.Toolbar.Visible = 'off';
                            % axes3fc.Toolbar.Visible = 'off';

                            if isVsplash('get') == false

                                axesMipfc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                                daspect(axesMipfc, [z y x]);

                                % axesMipfc.Toolbar.Visible = 'off';
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
    
                    axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    daspect(axes1, [1 1 1]);
                    daspect(axes2, [1 1 1]);
                    daspect(axes3, [1 1 1]);

                    axis(axes1, 'normal');
                    axis(axes2, 'normal');
                    axis(axes3, 'normal');
            
                    % axes1.Toolbar.Visible = 'off';
                    % axes2.Toolbar.Visible = 'off';
                    % axes3.Toolbar.Visible = 'off';

                    if isVsplash('get') == false

                        axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                        daspect(axesMip, [1 1 1]);

                        axis(axesMip, 'normal');

                        % axesMip.Toolbar.Visible = 'off';
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
                                
                                % axes1f.Toolbar.Visible = 'off';
                                % axes2f.Toolbar.Visible = 'off';
                                % axes3f.Toolbar.Visible = 'off';
                            end

                            if isVsplash('get') == false

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)

                                    daspect(axesMipf, [1 1 1]);

                                    axis(axesMipf, 'normal');

                                    % axesMipf.Toolbar.Visible = 'off';
                                end
                            end

                        end
                    end

                    if isPlotContours('get') && isVsplash('get') == false

                        axes1fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        axes2fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        axes3fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                        daspect(axes1fc, [1 1 1]);
                        daspect(axes2fc, [1 1 1]);
                        daspect(axes3fc, [1 1 1]);

                        axis(axes1fc, 'normal');
                        axis(axes2fc, 'normal');
                        axis(axes3fc, 'normal');

                        % axes1fc.Toolbar.Visible = 'off';
                        % axes2fc.Toolbar.Visible = 'off';
                        % axes3fc.Toolbar.Visible = 'off';

                        if isVsplash('get') == false

                            axesMipfc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                            daspect(axesMipfc, [1 1 1]);

                            axis(axesMipfc, 'normal');

                            % axesMipfc.Toolbar.Visible = 'off';
                        end
                    end

                end

                if isInterpolated('get')

                    set(imCoronalPtr ('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'bilinear');
                    set(imSagittalPtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'bilinear');
                    set(imAxialPtr   ('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'bilinear');

%                     shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
%                     shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
%                     shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
% 
                    % axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    % axes1.Toolbar.Visible = 'off';
                    % axes2.Toolbar.Visible = 'off';
                    % axes3.Toolbar.Visible = 'off';

                    if link2DMip('get') == true && isVsplash('get') == false
%                         shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'interp');
                        set(imMipPtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'bilinear');

                        % axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                        % axesMip.Toolbar.Visible = 'off';
                    end

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            imCoronalF  = imCoronalFPtr ('get', [] , rr);
                            imSagittalF = imSagittalFPtr('get', [] , rr);
                            imAxialF    = imAxialFPtr   ('get', [] , rr);

                            if ~isempty(imCoronalF) && ~isempty(imSagittalF) && ~isempty(imAxialF)

                                set(imCoronalF ,  'Interpolation', 'bilinear');
                                set(imSagittalF,  'Interpolation', 'bilinear');
                                set(imAxialF   ,  'Interpolation', 'bilinear');
                            end

%                             axes1f = axes1fPtr('get', [], rr);
%                             axes2f = axes2fPtr('get', [], rr);
%                             axes3f = axes3fPtr('get', [], rr);
% 
%                             if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
% 
%                                 axes1f.Toolbar.Visible = 'off';
%                                 axes2f.Toolbar.Visible = 'off';
%                                 axes3f.Toolbar.Visible = 'off';
% 
% %                                 shading(axes1f, 'interp');
% %                                 shading(axes2f, 'interp');
% %                                 shading(axes3f, 'interp');
%                             end

                            if link2DMip('get') == true && isVsplash('get') == false

                                imMipF  = imMipFPtr ('get', [] , rr);
    
                                if ~isempty(imMipF)

                                    set(imMipF ,  'Interpolation', 'bilinear');                                    
                                end
% 
%                                 axesMipf = axesMipfPtr('get', [], rr);
% 
%                                 if ~isempty(axesMipf)
%                                     axesMipf.Toolbar.Visible = 'off';
% %                                     shading(axesMipf, 'interp');
%                                 end
                            end

                        end
                    end
                else

                    set(imCoronalPtr ('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'nearest');
                    set(imSagittalPtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'nearest');
                    set(imAxialPtr   ('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'nearest');

%                     shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
%                     shading(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
%                     shading(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');

                    % axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % 
                    % axes1.Toolbar.Visible = 'off';
                    % axes2.Toolbar.Visible = 'off';
                    % axes3.Toolbar.Visible = 'off';

                    if link2DMip('get') == true && isVsplash('get') == false
%                         shading(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'flat');
                        set(imMipPtr('get', [] , get(uiSeriesPtr('get'), 'Value')),  'Interpolation', 'nearest');
                        % 
                        % axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                        % axesMip.Toolbar.Visible = 'off';
                    end

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

                            imCoronalF  = imCoronalFPtr ('get', [] , rr);
                            imSagittalF = imSagittalFPtr('get', [] , rr);
                            imAxialF    = imAxialFPtr   ('get', [] , rr);

                            if ~isempty(imCoronalF) && ~isempty(imSagittalF) && ~isempty(imAxialF)

                                set(imCoronalF ,  'Interpolation', 'nearest');
                                set(imSagittalF,  'Interpolation', 'nearest');
                                set(imAxialF   ,  'Interpolation', 'nearest');
                            end

%                             axes1f = axes1fPtr('get', [], rr);
%                             axes2f = axes2fPtr('get', [], rr);
%                             axes3f = axes3fPtr('get', [], rr);
% 
%                             if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
% 
%                                 axes1f.Toolbar.Visible = 'off';
%                                 axes2f.Toolbar.Visible = 'off';
%                                 axes3f.Toolbar.Visible = 'off';
% 
% %                                 shading(axes1f, 'flat');
% %                                 shading(axes2f, 'flat');
% %                                 shading(axes3f, 'flat');
%                             end

                            if link2DMip('get') == true && isVsplash('get') == false

                                imMipF  = imMipFPtr ('get', [] , rr);
    
                                if ~isempty(imMipF)

                                    set(imMipF ,  'Interpolation', 'nearest');                                    
                                end

%                                 axesMipf = axesMipfPtr('get', [], rr);
% 
%                                 if ~isempty(axesMipf)
%                                     axesMipf.Toolbar.Visible = 'off';
% %                                     shading(axesMipf, 'flat');
%                                 end
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

        enableErrorLogging('set', get(chkenableErrorLogging, 'Value'));        

        setImageInterpolation(get(chkInterpolate, 'Value'));

        updateDicomWriteSeriesInstanceUID('set', get(chkUpdateWriteUID, 'Value'));

        modifiedImagesContourMatrix('set', get(chkOriginalMatrix, 'Value'));

        % playback2DMipOnly('set', get(chkMip2DOnly, 'Value'));

        linkCoronalWithSagittal('set', get(chkLinkCoronalWithSagittal, 'Value'));

        if get(uiVoiRenderer, 'Value') == 1
            voi3DRenderer('set', 'VolumeRendering');
        elseif get(uiVoiRenderer, 'Value') == 2
            voi3DRenderer('set', 'Isosurface');
        else
            voi3DRenderer('set', 'LabelRendering');
        end

        voi3DSmooth('set', get(chk3DVoiSmooth, 'Value'));

        showBorder('set', get(chkBorder, 'Value'));

        gateUseSeriesUID('set', ~get(chkUseUID, 'Value'));

        gateLookupTable('set', get(chkLookupTable, 'Value'));

        dLookUpValue  = get(uiLookupTable, 'Value' );
        asLookUpValue = get(uiLookupTable, 'String');

        gateLookupType('set', asLookUpValue{dLookUpValue});

        isInterpolated('set', get(chkInterpolate, 'Value'));

        aspectRatio('set', get(chkAspect, 'Value'));

        aspectRatioValue('set', 'x', str2double(get(edtRatioX, 'String')));
        aspectRatioValue('set', 'y', str2double(get(edtRatioY, 'String')));
        aspectRatioValue('set', 'z', str2double(get(edtRatioZ, 'String')));

        delete(dlgOptions);

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false && ...
           bRefresh                  == true  && ...
           ~isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

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
