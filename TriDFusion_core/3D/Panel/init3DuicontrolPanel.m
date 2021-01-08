function init3DuicontrolPanel()
%function init3DuicontrolPanel()
%Init 3D Panel Main Function.
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

    hold on;

    init3DPanel('set', false);
    
    % 3D Volume

         uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D Volume',...
                  'horizontalalignment', 'left',...
                  'position', [25 787 100 20]...
                  );
    
    asSeries = get(uiSeriesPtr('get'), 'String');
    dSeries  = get(uiSeriesPtr('get'), 'Value');   
    sSeries  = asSeries{dSeries};
   
    if isFusion('get')
        sVolumeEnable = 'on';
        
        asFusedSeries = get(uiFusedSeriesPtr('get'), 'String');
        dFusedSeries  = get(uiFusedSeriesPtr('get'), 'Value');   
        sFusedSeries  = asFusedSeries{dFusedSeries};                        
        
        as3DVolume{1} = sSeries;
        as3DVolume{2} = sFusedSeries;
        
    else
        sVolumeEnable = 'off';        
        
        as3DVolume{1} = sSeries;        
    end  
          
       ui3DVolume = ...
           uicontrol(ui3DPanelPtr('get'), ...
                     'Style'   , 'popup', ...
                     'Position', [180 790 465 20], ...
                     'String'  , as3DVolume, ...
                     'Value'   , 1 ,...
                     'Enable'  , sVolumeEnable, ...
                     'Callback', @set3DVolumeCallback...
                     );
       ui3DVolumePtr('set', ui3DVolume); 
       
    % 3D VOI
    
       chkDispVoi = ...
           uicontrol(ui3DPanelPtr('get'),...
                     'style'   , 'checkbox',...
                     'enable'  , 'on',...
                     'value'   , displayVoi('get'),...
                     'position', [350 740 20 20],...
                     'Callback', @displayVoiCallback...
                     );

          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'Display Volume-of-Interest',...
                    'horizontalalignment', 'left',...
                    'position', [375 737 150 20],...
                    'Enable', 'Inactive',...
                    'ButtonDownFcn', @displayVoiCallback...
                    );
                
          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'VOI Transparency',...
                    'horizontalalignment', 'left',...
                    'position', [350 715 150 20],...
                    'Enable', 'On'...
                    );
                
    uislider3DVoiTransparency = ...
         uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [350 700 295 14], ...
                  'Value'   , slider3DVoiTransparencyValue('get'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @slider3DVoiTransparencyCallback ...
                  );
    addlistener(uislider3DVoiTransparency, 'Value', 'PreSet', @slider3DVoiTransparencyCallback);

    % 3D Background

         uicontrol(ui3DPanelPtr('get'),...
                   'style'   , 'text',...
                   'string'  , '3D Background',...
                   'horizontalalignment', 'left',...
                   'position', [25 697 100 20]...
                   );
               
    ui3DBackground = ...
         uicontrol(ui3DPanelPtr('get'), ...
                   'Style'   , 'popup', ...
                   'Position', [180 700 140 20], ...
                   'String'  , surfaceColor('all'), ...
                   'Value'   , background3DOffset('get'),...
                   'Enable'  , 'on', ...
                   'CallBack', @background3DCallback ...
                   );
    ui3DBackgroundPtr('set', ui3DBackground);
    
    % Volume Aspect Ration

    slider3DRatioLastValue('set', 0.5);
    uiSlider3DRatio = ...
         uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [631 585 14 70], ...
                  'Value'   , slider3DRatioLastValue('get'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @slider3DRatioCallback ...
                  );
%          addlistener(uiSlider3DRatio,'Value','PreSet',@slider3DRatioCallback);

    uiEdit3DXRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 635 120 20], ...
                  'String'  , volumeScaleFator('get', 'x'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D X-axis ratio',...
                  'horizontalalignment', 'left',...
                  'position', [350 632 120 20]...
                  );

    uiEdit3DYRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 610 120 20], ...
                  'String'  , volumeScaleFator('get', 'y'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D Y-axis ratio',...
                  'horizontalalignment', 'left',...
                  'position', [350 607 120 20]...
                  );

    uiEdit3DZRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 585 120 20], ...
                  'String'  , volumeScaleFator('get', 'z'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D Z-axis ratio',...
                  'horizontalalignment', 'left',...
                  'position', [350 582 120 20]...
                  );
              
    % Volume Lighting

    sMatlabVersion = version();
    sMatlabVersion = extractBefore(sMatlabVersion,' ');
                
    bLightingIsSupported = false;
    if length(sMatlabVersion) > 3
        dMatlabVersion = str2double(sMatlabVersion(1:3));
        if dMatlabVersion >= 9.8
             bLightingIsSupported = true;
        end
    end
        
    if bLightingIsSupported == true
        sChkLightingEnable = 'on';
        sTxtLightingEnable = 'Inactive';
    else
        volLighting('set', false);
        sChkLightingEnable = 'off';
        sTxtLightingEnable = 'Off';
   end
    
    chkVolLighting = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , sChkLightingEnable,...
                  'value'   , volLighting('get'),...
                  'position', [25 535 20 20],...
                  'Callback', @volLightingCallback...
                  );
     chk3DVolLightingPtr('set', chkVolLighting);

     txtVolLighting = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Lighting',...
                  'horizontalalignment', 'left',...
                  'position', [45 533 200 20],...
                  'Enable', sTxtLightingEnable ...
                  );              
              
     if bLightingIsSupported == true
        set(txtVolLighting, 'ButtonDownFcn', @volLightingCallback);
     end
                       
     % Volume Colormap

    chkDispVolColormap = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , displayVolColorMap('get'),...
                  'position', [25 510 20 20],...
                  'Callback', @displayVolColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Display Volume Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [45 507 200 20],...
                  'Enable', 'Inactive',...
                  'ButtonDownFcn', @displayVolColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [25 482 100 20]...
                  );

    uiColorVol = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 485 140 20], ...
                  'String'  , get3DColorMap('all'), ...
                  'Value'   , colorMapVolOffset('get'),...
                  'Enable'  , 'on', ...
                  'CallBack', @colorMapVolCallback ...
                  );
     ui3DVolColormapPtr('set', uiColorVol);
             
              
      % Volume Alphamap

         uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Alphamap',...
                  'horizontalalignment', 'left',...
                  'position', [25 457 100 20]...
                  );

    [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));

    [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, dicomMetaData('get'));
    
    uiVolumeAlphaMapType = ...  
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 460 140 20], ...
                  'String'  , {'linear', 'custom', 'mr', 'ct', 'pt'}, ...
                  'Value'   , dVolAlphaOffset,...
                  'Enable'  , 'on', ...
                  'CallBack', @volAlphaMapTypeCallback ...
                  );
     ui3DVolAlphamapTypePtr('set', uiVolumeAlphaMapType);
    
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Linear Alphamap',...
                  'horizontalalignment', 'left',...
                  'position', [25 435 160 20]...
                  );

    uiSliderVolLinAlpha = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [25 420 295 14], ...
                  'Value'   , volLinearAlphaValue('get'), ...
                  'Enable'  , sVolMapSliderEnable, ...
                  'CallBack', @sliderVolLinearAlphaCallback ...
                  );
    ui3DSliderVolLinAlphaPtr('set', uiSliderVolLinAlpha);

    uiSliderVolLinAlphaListener = addlistener(uiSliderVolLinAlpha, 'Value', 'PreSet', @sliderVolLinearAlphaCallback);

    % Vol Alphamap Editor

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Alphamap Editor',...
                  'horizontalalignment', 'left',...
                  'position', [25 390 235 20]...
                  );

    axeVolAlphmap = ...
        axes(ui3DPanelPtr('get'),...
             'Units'   , 'pixels',...
             'Color'   , [0.99 0.99 0.99],...
             'XColor'  , [0.1500 0.1500 0.1500],...
             'YColor'  , [0.1500 0.1500 0.1500],...
             'position', [25 35 295 350]...
             );
    axe3DPanelVolAlphmapPtr('set', axeVolAlphmap);      
 %   axeVolAlphmap.Title.String = 'Volume Alphamap';

    if strcmp(sType, 'custom')
        ic = customAlphaCurve(axeVolAlphmap,  volObject('get'), 'vol');
        volICObject('set', ic);
        alphaCurveMenu(axeVolAlphmap, 'vol');
    else
        displayAlphaCurve(aMap, axeVolAlphmap);
    end

    % ISO Surface Color
    
         uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'ISO Create Mask',...
                  'horizontalalignment', 'left',...
                  'position', [25 650 100 20]...
                  );
              
    uiCreateIsoMask = ...             
        uicontrol(ui3DPanelPtr('get'),...
                  'Position', [180 650 140 25],...
                  'String'  , 'Create 3D Mask',...
                  'Enable'  , 'off', ...
                  'Callback', @createIsoMaskCallback...
                  );              
    ui3DCreateIsoMaskPtr('set', uiCreateIsoMask);
    
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'ISO Surface Color',...
                  'horizontalalignment', 'left',...
                  'position', [25 625 100 20]...
                  );
              
    uiIsoSurfaceColor = ...
       uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 625 140 20], ...
                  'String'  , surfaceColor('all'), ...
                  'Value'   , isoColorOffset('get'),...
                  'Enable'  , 'on', ...
                  'CallBack', @isoSurfaceColorCallback ...
                  );
    ui3DIsoSurfaceColorPtr('set', uiIsoSurfaceColor);
    
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'ISO Surface Value',...
                  'horizontalalignment', 'left',...
                  'position', [25 600 100 20]...
                              );

    uiSliderIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [25 585 225 14], ...
                  'Value'   , isoSurfaceValue('get'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @sliderIsoCallback ...
                  );
    ui3DSliderIsoSurfacePtr('set', uiSliderIsoSurface);              
    uiSliderIsoSurfaceListener = addlistener(uiSliderIsoSurface,'Value','PreSet',@sliderIsoCallback);

    uiEditIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 585 65 20], ...
                  'String'  , isoSurfaceValue('get'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @editIsoSurfaceCallback ...
                  );
    ui3DEditIsoSurfacePtr('set', uiEditIsoSurface);              
                            
    % MIP Colormap

    chkDispMipColormap = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , displayMIPColorMap('get'),...
                  'position', [350 510 20 20],...
                  'Callback', @displayMIPColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Display MIP Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [375 507 200 20],...
                  'Enable', 'Inactive',...
                  'ButtonDownFcn', @displayMIPColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [350 482 100 20]...
                  );

    uiColorMip = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [505 485 140 20], ...
                  'String'  , get3DColorMap('all'), ...
                  'Value'   , colorMapMipOffset('get'),...
                  'Enable'  , 'on', ...
                  'CallBack', @colorMapMipCallback ...
                  );
    ui3DMipColormapPtr('set', uiColorMip);

    % MIP Alphamap

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Alphamap',...
                  'horizontalalignment', 'left',...
                  'position', [350 457 100 20]...
                  );

    [aMap, sType] = getMipAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));

    [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, dicomMetaData('get'));
     
    uiMipAlphaMapType = ...  
         uicontrol(ui3DPanelPtr('get'), ...
                   'Style'   , 'popup', ...
                   'Position', [505 460 140 20], ...
                   'String'  , {'linear', 'custom', 'mr', 'ct', 'pt'}, ...
                   'Value'   , dMipAlphaOffset,...
                   'Enable'  , 'on', ...
                   'CallBack', @mipAlphaMapTypeCallback ...
                  );
     ui3DMipAlphamapTypePtr('set', uiMipAlphaMapType);

    % MIP Linear Alphamap

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Linear Alphamap',...
                  'horizontalalignment', 'left',...
                  'position', [350 435 235 20]...
                  );

    uiSliderMipLinAlpha = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [350 420 295 14], ...
                  'Value'   , mipLinearAlphaValue('get'), ...
                  'Enable'  , sMipMapSliderEnable, ...
                  'CallBack', @sliderMipLinearAlphaCallback ...
                  );
    uiSliderMipLinAlphaListener = addlistener(uiSliderMipLinAlpha, 'Value', 'PreSet', @sliderMipLinearAlphaCallback);
    ui3DSliderMipLinAlphaPtr('set', uiSliderMipLinAlpha);

    % MIP Alphamap Editor

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Alphamap Editor',...
                  'horizontalalignment', 'left',...
                  'position', [350 390 235 20]...
                  );

    axeMipAlphmap = ...
        axes(ui3DPanelPtr('get'),...
             'Units'   , 'pixels',...
             'Tag'     , 'Mip Alphamap',...
             'Color'   , [0.99 0.99 0.99],...
             'XColor'  , [0.1500 0.1500 0.1500],...
             'YColor'  , [0.1500 0.1500 0.1500],...
             'position', [350 35 295 350]...
             );
    axe3DPanelMipAlphmapPtr('set', axeMipAlphmap);    
%      axeVolAlphmap.Title.String = 'MIP Alphamap';

    if strcmp(sType, 'custom')
        ic = customAlphaCurve(axeMipAlphmap,  mipObject('get'), 'mip');
        mipICObject('set', ic);
        alphaCurveMenu(axeMipAlphmap, 'mip');
    else
        displayAlphaCurve(aMap, axeMipAlphmap);
    end

    hold off;

    function slider3DRatioCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        dOffsetValue = get(uiSlider3DRatio, 'Value');

        if slider3DRatioLastValue('get') > get(uiSlider3DRatio, 'Value')
            xValue = str2double(get(uiEdit3DXRatio, 'String')) * dOffsetValue;
            yValue = str2double(get(uiEdit3DYRatio, 'String')) * dOffsetValue;
            zValue = str2double(get(uiEdit3DZRatio, 'String')) * dOffsetValue;
        else
            xValue = str2double(get(uiEdit3DXRatio, 'String')) / dOffsetValue;
            yValue = str2double(get(uiEdit3DYRatio, 'String')) / dOffsetValue;
            zValue = str2double(get(uiEdit3DZRatio, 'String')) / dOffsetValue;
        end

        slider3DRatioLastValue('set', get(uiSlider3DRatio, 'Value'));

        set(uiEdit3DXRatio, 'String', num2str(xValue));
        set(uiEdit3DYRatio, 'String', num2str(yValue));
        set(uiEdit3DZRatio, 'String', num2str(zValue));

        edit3DRatioCallback();

    end

    function dObectValue = slider3DRatioLastValue(sAction, dValue)

         persistent pdObjectValue;

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

         if strcmp(sAction, 'set')
            pdObjectValue = dValue;
         end

         dObectValue = pdObjectValue;

    end

    function edit3DRatioCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        if str2double(get(uiEdit3DXRatio, 'String')) <= 0
            set(uiEdit3DXRatio, 'String', '0.1');
        end

        if str2double(get(uiEdit3DYRatio, 'String')) <= 0
            set(uiEdit3DYRatio, 'String', '0.1');
        end

        if str2double(get(uiEdit3DZRatio, 'String')) <= 0
            set(uiEdit3DZRatio, 'String', '0.1');
        end

        xValue = str2double(get(uiEdit3DXRatio, 'String'));
        yValue = str2double(get(uiEdit3DYRatio, 'String'));
        zValue = str2double(get(uiEdit3DZRatio, 'String'));

        volumeScaleFator('set', 'x', xValue);
        volumeScaleFator('set', 'y', yValue);
        volumeScaleFator('set', 'z', zValue);

        volObj = volObject('get');
        if ~isempty(volObj)
            set(volObj, 'ScaleFactors', [xValue yValue zValue]);
        end

        isoObj = isoObject('get');
        if ~isempty(isoObj)
            set(isoObj, 'ScaleFactors', [xValue yValue zValue]);
        end

        mipObj = mipObject('get');
        if ~isempty(mipObj)
            set(mipObj, 'ScaleFactors', [xValue yValue zValue]);
        end
        
        volFusionObj = volFusionObject('get');
        if ~isempty(volFusionObj)
            set(volFusionObj, 'ScaleFactors', [xValue yValue zValue]);
        end

        isoFusionObj = isoFusionObject('get');
        if ~isempty(isoFusionObj)
            set(isoFusionObj, 'ScaleFactors', [xValue yValue zValue]);
        end

        mipFusionObj = mipFusionObject('get');
        if ~isempty(mipFusionObj)
            set(mipFusionObj, 'ScaleFactors', [xValue yValue zValue]);
        end
        
        voiObj = voiObject('get');
        if ~isempty(voiObj)
            for ff=1:numel(voiObj)
                set(voiObj{ff}, 'ScaleFactors', [xValue yValue zValue]);
            end
        end

        initGate3DObject('set', true);

    end

    function volLightingCallback(hObject, ~)
        
        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        if get(chkVolLighting, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkVolLighting, 'Value', true);
            else
                set(chkVolLighting, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkVolLighting, 'Value', false);
            else
                set(chkVolLighting, 'Value', true);
            end
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            volFusionLighting('set', get(chkVolLighting, 'Value'));
            
            volFusionObj = volFusionObject('get');
            if ~isempty(volFusionObj)
                set(volFusionObj, 'Lighting', volFusionLighting('get'));
            end              
        else
            volLighting('set', get(chkVolLighting, 'Value'));
            
            volObj = volObject('get');
            if ~isempty(volObj)
                set(volObj, 'Lighting', volLighting('get'));
            end            
        end
       
        initGate3DObject('set', true);
      
    end

    function displayVolColorMapCallback(hObject, ~)

        mGate = gateIconMenuObject('get');
        mPlay = playIconMenuObject('get');

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        if get(chkDispVolColormap, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkDispVolColormap, 'Value', true);
            else
                set(chkDispVolColormap, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkDispVolColormap, 'Value', false);
            else
                set(chkDispVolColormap, 'Value', true);
            end
        end

        if get(chkDispVolColormap, 'Value') == true

            if switchTo3DMode('get') == true && ...
               ~(strcmpi(get(mPlay, 'State'), 'on') && ...
                 strcmpi(get(mGate, 'State'), 'on') )

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', '');
                end

                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('get', get(uiColorVol, 'Value')));
                volColorObject('set', uivolColorbar);

            end
        else
            volColorObj = volColorObject('get');
            if ~isempty(volColorObj)
                delete(volColorObj);
                volColorObject('set', '');
            end

            if switchToMIPMode('get') == true && ...
               ~(strcmpi(get(mPlay, 'State'), 'on') && ...
                 strcmpi(get(mGate, 'State'), 'on') )

                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj)
                    delete(mipColorObj);
                    mipColorObject('set', '');

                    uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('get', get(uiColorMip, 'Value')));
                    mipColorObject('set', uimipColorbar);

                end
            end

        end

        displayVolColorMap('set', get(chkDispVolColormap, 'Value'));

        initGate3DObject('set', true);

    end

    function displayMIPColorMapCallback(hObject, ~)

        mGate = gateIconMenuObject('get');
        mPlay = playIconMenuObject('get');

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        if get(chkDispMipColormap, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkDispMipColormap, 'Value', true);
            else
                set(chkDispMipColormap, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkDispMipColormap, 'Value', false);
            else
                set(chkDispMipColormap, 'Value', true);
            end
        end

        if get(chkDispMipColormap, 'Value') == true

            if switchToMIPMode('get') == true && ...
               ~(strcmpi(get(mPlay, 'State'), 'on') && ...
                 strcmpi(get(mGate, 'State'), 'on') )

                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj)
                    delete(mipColorObj);
                    mipColorObject('set', '');
                end

                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('get', get(uiColorMip, 'Value')));
                mipColorObject('set', uimipColorbar);

            end
         else
            mipColorObj = mipColorObject('get');
            if ~isempty(mipColorObj)
                delete(mipColorObj);
                mipColorObject('set', '');
            end

            if switchTo3DMode('get') == true && ...
               ~(strcmpi(get(mPlay, 'State'), 'on') && ...
                 strcmpi(get(mGate, 'State'), 'on') )

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', '');

                    uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('get', get(uiColorVol, 'Value')));
                    volColorObject('set', uivolColorbar);
                end
            end
        end

        displayMIPColorMap('set', get(chkDispMipColormap, 'Value'));

        initGate3DObject('set', true);

    end

    function colorMapVolCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            colorMapVolFusionOffset('set', get(hObject, 'Value'));

            volFusionObj = volFusionObject('get');
            if ~isempty(volFusionObj)                
                
                if switchTo3DMode('get') == true

                    set(volFusionObj, 'Colormap', get3DColorMap('get', get(hObject, 'Value')));

                    volColorObj = volColorObject('get');
                    if ~isempty(volColorObj) && ...
                       get(chkDispVolColormap, 'Value') == 1

                        delete(volColorObj);
                        volColorObject('set', '');
                        uivolColorbar = volColorbar(uiOneWindowPtr('get'), get(volFusionObj, 'Colormap'));
                        volColorObject('set', uivolColorbar);
                    end                
                end
            end                       
                
        else
            colorMapVolOffset('set', get(hObject, 'Value'));

            volObj = volObject('get');
            if ~isempty(volObj)

                if switchTo3DMode('get') == true

                    set(volObj, 'Colormap', get3DColorMap('get', get(hObject, 'Value')));

                    volColorObj = volColorObject('get');
                    if ~isempty(volColorObj) && ...
                       get(chkDispVolColormap, 'Value') == 1

                        delete(volColorObj);
                        volColorObject('set', '');
                        uivolColorbar = volColorbar(uiOneWindowPtr('get'), get(volObj, 'Colormap'));
                        volColorObject('set', uivolColorbar);
                    end
                end
            end
        end

        initGate3DObject('set', true);

    end

    function set3DVolumeCallback(~, ~)

        delete(uiSliderMipLinAlphaListener);
        delete(uiSliderVolLinAlphaListener);
        delete(uiSliderIsoSurfaceListener );
        
        if  get(ui3DVolume, 'Value') == 2 % Fusion
            
            set(uiCreateIsoMask, 'Enable', 'off');
            
            tFuseInput     = inputTemplate('get');
            iFuseOffset    = get(uiFusedSeriesPtr('get'), 'Value');   
            atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;            
                 
            % Volume
            
            volFusionObj = volFusionObject('get');
            if ~isempty(volFusionObj)
                ic = volICFusionObject('get');
                if ~isempty(ic)                
                    ic.surfObj = volFusionObj;
                end

                [aMap, sType] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atFuseMetaData);

                set(uiVolumeAlphaMapType, 'Value' , dVolAlphaOffset);
                set(uiSliderVolLinAlpha , 'Enable', sVolMapSliderEnable);               
                set(uiSliderVolLinAlpha , 'Value' , volLinearFusionAlphaValue('get'));

                if strcmpi(sType, 'custom')
                    ic = customAlphaCurve(axeVolAlphmap,  volFusionObj, 'volfusion');            
                    ic.surfObj = volFusionObj;  

                    volICFusionObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'volfusion');
                else
                    displayAlphaCurve(aMap, axeVolAlphmap);                
                end
                
                set(uiColorVol, 'Value', colorMapVolFusionOffset('get'));
                
                set(chkVolLighting, 'Value', volFusionLighting('get'));    
                
                volColorObj = volColorObject('get');
                if ~isempty(volColorObj) && ...
                   get(chkDispVolColormap, 'Value') == true

                    delete(volColorObj);
                    volColorObject('set', '');
                    uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolFusionOffset('get')));
                    volColorObject('set', uivolColorbar);
                end
                                               
            end
        
            % Mip
            
            mipFusionObj = mipFusionObject('get');
            if ~isempty(mipFusionObj)
                ic = mipICFusionObject('get');
                if ~isempty(ic)
                    ic.surfObj = mipFusionObj;
                end

                [aMap, sType] = getMipFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, atFuseMetaData);

                set(uiMipAlphaMapType   , 'Value' , dMipAlphaOffset);
                set(uiSliderMipLinAlpha , 'Enable', sMipMapSliderEnable);
                set(uiSliderMipLinAlpha , 'Value' , mipLinearFuisonAlphaValue('get'));

                if strcmpi(sType, 'custom')
                    ic = customAlphaCurve(axeMipAlphmap,  mipFusionObj, 'mipfusion');     
                    ic.surfObj = mipFusionObj;  

                    mipICFusionObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mipfusion');
                else
                    displayAlphaCurve(aMap, axeMipAlphmap);                
                end
                
                set(uiColorMip, 'Value', colorMapMipFusionOffset('get'));               
                
                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj) && ...
                   get(chkDispMipColormap, 'Value') == true

                    delete(mipColorObj);
                    mipColorObject('set', '');
                    uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipFusionOffset('get')));
                    mipColorObject('set', uimipColorbar);
                end
                                               
            end
            
            % ISO
            set(uiIsoSurfaceColor , 'Value', isoColorFusionOffset('get') );            
            set(uiSliderIsoSurface, 'Value', isoSurfaceFusionValue('get'));
            set(uiEditIsoSurface  , 'String', num2str(isoSurfaceFusionValue('get')));
                       
        else
            if switchToIsoSurface('get') == true
                set(uiCreateIsoMask, 'Enable', 'on');
            end
            
            atMetaData = dicomMetaData('get');
            
            % Volume
            
            volObj = volObject('get');
            if ~isempty(volObj)
                ic = volICObject('get');
                if ~isempty(ic)
                    ic.surfObj = volObj;                
                end
                                          
                [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get'), atMetaData);

                [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atMetaData);

                set(uiVolumeAlphaMapType, 'Value' , dVolAlphaOffset);
                set(uiSliderVolLinAlpha , 'Enable', sVolMapSliderEnable);
                set(uiSliderVolLinAlpha , 'Value' , volLinearAlphaValue('get'));

                if strcmpi(sType, 'custom')
                    ic = customAlphaCurve(axeVolAlphmap,  volObj, 'vol');            
                    ic.surfObj = volObj;  

                    volICObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'vol');
                else
                    displayAlphaCurve(aMap, axeVolAlphmap);                
                end
                
                volColorObj = volColorObject('get');
                if ~isempty(volColorObj) && ...
                   get(chkDispVolColormap, 'Value') == true

                    delete(volColorObj);
                    volColorObject('set', '');
                    uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')));
                    volColorObject('set', uivolColorbar);
                end
                
                set(uiColorVol    , 'Value', colorMapVolOffset('get'));                               
                set(chkVolLighting, 'Value', volLighting('get'));               
            end            
            
            % Mip
            
            mipObj = mipObject('get');
            if ~isempty(mipObj)
                ic = mipICObject('get');
                if ~isempty(ic)                
                    ic.surfObj = mipObj;
                end
            
                [aMap, sType] = getMipAlphaMap('get', dicomBuffer('get'), atMetaData);

                [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, atMetaData);

                set(uiMipAlphaMapType   , 'Value' , dMipAlphaOffset);
                set(uiSliderMipLinAlpha , 'Enable', sMipMapSliderEnable);
                set(uiSliderMipLinAlpha , 'Value' , mipLinearAlphaValue('get'));

                if strcmpi(sType, 'custom')
                    ic = customAlphaCurve(axeMipAlphmap,  mipObj, 'mip');            
                    ic.surfObj = mipObj;  

                    mipICObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mip');
                else
                    displayAlphaCurve(aMap, axeMipAlphmap);                
                end
                
                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj) && ...
                   get(chkDispMipColormap, 'Value') == true

                    delete(mipColorObj);
                    mipColorObject('set', '');
                    uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
                    mipColorObject('set', uimipColorbar);
                end
                
                set(uiColorMip, 'Value', colorMapMipOffset('get'));               
                                
            end     
            
            % ISO
            
            set(uiIsoSurfaceColor , 'Value' , isoColorOffset('get') ); 
            set(uiSliderIsoSurface, 'Value' , isoSurfaceValue('get'));            
            set(uiEditIsoSurface  , 'String', num2str(isoSurfaceValue('get')));
            
        end
        
        uiSliderMipLinAlphaListener = addlistener(uiSliderMipLinAlpha, 'Value', 'PreSet', @sliderMipLinearAlphaCallback);
        uiSliderVolLinAlphaListener = addlistener(uiSliderVolLinAlpha, 'Value', 'PreSet', @sliderVolLinearAlphaCallback);
        uiSliderIsoSurfaceListener  = addlistener(uiSliderIsoSurface , 'Value', 'PreSet', @sliderIsoCallback);
    end

    function displayVoiCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

         if get(chkDispVoi, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'Checkbox')
                set(chkDispVoi, 'Value', true);
            else
                set(chkDispVoi, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')
                set(chkDispVoi, 'Value', false);
            else
                set(chkDispVoi, 'Value', true);
            end
         end

        displayVoi('set', get(chkDispVoi, 'Value'));

        voiObj = voiObject('get');
        if isempty(voiObj)
            voiObj = initVoiIsoSurface(uiOneWindowPtr('get'));
            voiObject('set', voiObj);
        else
            for ll=1:numel(voiObj)
                if get(chkDispVoi, 'Value') == true
                    set(voiObj{ll}, 'Renderer', 'Isosurface');
                else
                    set(voiObj{ll}, 'Renderer', 'LabelOverlayRendering');
               end
            end
        end

        initGate3DObject('set', true);        

    end

    function slider3DVoiTransparencyCallback(~, ~)
        
        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;            
        end
        
        dSliderValue = get(uislider3DVoiTransparency, 'Value');
                                    
        if displayVoi('get') == true   
                                    
            dValue = compute3DVoiTransparency(dSliderValue);
            
            voiObj = voiObject('get');
            if ~isempty(voiObj)
                for ll=1:numel(voiObj)
                    set(voiObj{ll}, 'Isovalue', dValue);
                end          
            end

        end        
        
        slider3DVoiTransparencyValue('set', dSliderValue);
      
        initGate3DObject('set', true);        
    end


    function background3DCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        background3DOffset('set', get(hObject, 'Value'));

        volObj = volObject('get');
        if ~isempty(volObj)
            set(volObj, 'BackgroundColor', surfaceColor('get', get(hObject, 'Value')));

            if displayVolColorMap('get') == true

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', '');
                end

                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('get', get(uiColorVol, 'Value')));
                volColorObject('set', uivolColorbar);
            end
        end

        isoObj = isoObject('get');
        if ~isempty(isoObj)
            set(isoObj, 'BackgroundColor', surfaceColor('get', get(hObject, 'Value')));
        end

        mipObj = mipObject('get');
        if ~isempty(mipObj)
            set(mipObj, 'BackgroundColor', surfaceColor('get', get(hObject, 'Value')));

            if displayMIPColorMap('get') == true

                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj)
                    delete(mipColorObj);
                    mipColorObject('set', '');
                end

                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', get(uiColorMip, 'Value')) );
                mipColorObject('set', uimipColorbar);

            end
        end

        logoObj = logoObject('get');
        if ~isempty(logoObj)
            delete(logoObj);
            logoObject('set', '');
        end

        uiLogo = displayLogo(uiOneWindowPtr('get'));
        logoObject('set', uiLogo);

        initGate3DObject('set', true);

    end

    function createIsoMaskCallback(~, ~)

        isoObj = isoObject('get');
        if ~isempty(isoObj)

            set(uiSeriesPtr('get'), 'Enable', 'off');
            set(btnIsoSurfacePtr('get'), 'Enable', 'off');
            set(btn3DPtr('get'), 'Enable', 'off');
            set(btnMIPPtr('get'), 'Enable', 'off');

            progressBar(0.999999, 'Creating mask, please wait');

            aSurfaceColor = surfaceColor('all');
            dColorOffset = isoColorOffset('get');

            im = dicomBuffer('get');

            atDcmMetaData = dicomMetaData('get');

            dMin = min(im, [], 'all');
            dMax = max(im, [], 'all');
            dScale = abs(dMin)+abs(dMax);
            dOffset = dScale*isoObj.Isovalue;
            dIsoValue = dMin+dOffset;


            fv = isosurface(im, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"


            aVolume = polygon2voxel(fv, size(im), 'none');
            BW = imfill(aVolume, 'holes');
            imMask = im;

        %    BW = aVolume;
        %    BW(aVolume ~=0) = 1;
%CC = bwconncomp(BW);
%L = labelmatrix(CC);
%S = regionprops(CC,'Centroid');
%centroids = cat(1,S.Centroid);

%st = regionprops(CC, 'PixelIdxList', 'PixelList');

%XY=[s.Centroid];
%plot(axes3Ptr('get'),XY(1:2:end),XY(2:2:end),'*')

            imMask(BW == 0) = cropValue('get')-BW(BW == 0);
       %     imMask = permute(imMask, [2 1 3]);

            iSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            tInput = inputTemplate('get');
            tInput(numel(tInput)+1) = tInput(iSeriesOffset);
            tInput(numel(tInput)).atDicomInfo = atDcmMetaData;

            asSeriesDescription = seriesDescription('get');
            asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('MASK-%s', asSeriesDescription{iSeriesOffset});
            seriesDescription('set', asSeriesDescription);

            for jj=1:numel(tInput(numel(tInput)).atDicomInfo)
                tInput(numel(tInput)).atDicomInfo{jj}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
            end

            inputTemplate('set', tInput);

            aInputBuffer = inputBuffer('get');
            aInputBuffer{numel(aInputBuffer)+1} = imMask;
            inputBuffer('set', aInputBuffer);

            asSeries = get(uiSeriesPtr('get'), 'String');
            asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};
            set(uiSeriesPtr('get'), 'String', asSeries);
            set(uiFusedSeriesPtr('get'), 'String', asSeries);

            set(uiSeriesPtr('get'), 'Value', numel(tInput));
            dicomMetaData('set', tInput(numel(tInput)).atDicomInfo);
            dicomBuffer('set', imMask);
            setQuantification(numel(tInput));

            tQuant = quantificationTemplate('get');
            tInput(numel(tInput)).tQuant = tQuant;
            inputTemplate('set', tInput);

            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

            progressBar(1, sprintf('Mask completed'));

            set(uiSeriesPtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
            set(btn3DPtr('get'), 'Enable', 'on');
            set(btnMIPPtr('get'), 'Enable', 'on');
        else
            progressBar(1, 'Error: Please initiate the iso surface!');
            h = msgbox('Error: writeISOtoSTL(): Please initiate the iso surface!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end
%
%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));                
        end

    end

    function isoSurfaceColorCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            isoColorFusionOffset('set', get(hObject, 'Value'));            

            if switchToIsoSurface('get') == true && isFusion('get') == true   
                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    set(isoFusionObj, 'IsosurfaceColor', surfaceColor('get', get(hObject, 'Value')));
                end
            end
        else
            
           isoColorOffset('set', get(hObject, 'Value'));
             
           if switchToIsoSurface('get') == true
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    set(isoObj, 'IsosurfaceColor', surfaceColor('get', get(hObject, 'Value')));
                end
            end
        end
        
        initGate3DObject('set', true);

    end

    function colorMapMipCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            colorMapMipFusionOffset('set', get(hObject, 'Value'));

            mipFusionObj = mipFusionObject('get');
            if ~isempty(mipFusionObj)
                
                if switchToMIPMode('get') == true && isFusion('get') == true   

                    set(mipFusionObj, 'Colormap', get3DColorMap('get', get(hObject, 'Value')));

                    mipColorObj = mipColorObject('get');
                    if ~isempty(mipColorObj) && ...
                       get(chkDispMipColormap, 'Value') == true

                        delete(mipColorObj);
                        mipColorObject('set', '');

                        uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get(mipFusionObj, 'Colormap'));
                        mipColorObject('set', uimipColorbar);
                    end     
                end
            end
                
        else
            colorMapMipOffset('set', get(hObject, 'Value'));

            mipObj = mipObject('get');
            if ~isempty(mipObj)
                
                if switchToMIPMode('get') == true

                    set(mipObj, 'Colormap', get3DColorMap('get', get(hObject, 'Value')));

                    mipColorObj = mipColorObject('get');
                    if ~isempty(mipColorObj) && ...
                       get(chkDispMipColormap, 'Value') == true

                        delete(mipColorObj);
                        mipColorObject('set', '');

                        uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get(mipObj, 'Colormap'));
                        mipColorObject('set', uimipColorbar);
                    end
                end
            end
        end
        
        initGate3DObject('set', true);

    end

    function volAlphaMapTypeCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        volObj       = volObject('get');
        volFusionObj = volFusionObject('get');

        if strcmpi(uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value}, 'linear')

%%%            deleteAlphaCurve('vol');

            set(uiSliderVolLinAlpha, 'Enable', 'on');

            aAlphamap = linspace(0, get(uiSliderVolLinAlpha, 'Value'), 256)';

            if get(ui3DVolume, 'Value') == 2 % Fusion
                
                getVolFusionAlphaMap('set', fusionBuffer('get'), 'linear', aAlphamap);
                volLinearFusionAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));
                
                if switchTo3DMode('get') == true && isFusion('get') == true   
                    if ~isempty(volFusionObj) 
                        set(volFusionObj, 'Alphamap', aAlphamap);                    
                    end 
                end
                
            else             
                
                getVolAlphaMap('set', dicomBuffer('get'), 'linear', aAlphamap);
                volLinearAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));
                
                if switchTo3DMode('get') == true 
                    if ~isempty(volObj)
                        set(volObj, 'Alphamap', aAlphamap);
                    end                            
                end
                
            end             
            
            displayAlphaCurve(aAlphamap, axeVolAlphmap);
           
         elseif strcmpi(uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value}, 'custom')
             
            set(uiSliderVolLinAlpha, 'Enable', 'off');
            
            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                
                getVolFusionAlphaMap('set', fusionBuffer('get'), 'custom');
                
                if switchTo3DMode('get') == true && isFusion('get') == true   

                    ic = customAlphaCurve(axeVolAlphmap,  volFusionObj, 'volfusion');
                    ic.surfObj = volFusionObj;  

                    volICFusionObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'volfusion');
                else
                    tFuseInput  = inputTemplate('get');
                    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    
                    [aFusionAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                    displayAlphaCurve(aFusionAlphaMap, axeVolAlphmap);                  
                end
                
            else
                getVolAlphaMap('set', dicomBuffer('get'), 'custom');
                
                if switchTo3DMode('get') == true 
              
                    ic = customAlphaCurve(axeVolAlphmap,  volObj, 'vol');
                    ic.surfObj = volObj;                              

                    volICObject('set', ic);
                    alphaCurveMenu(axeVolAlphmap, 'vol');
                else
                    [aAlphaMap, ~] = getVolAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));
                    displayAlphaCurve(aAlphaMap, axeVolAlphmap);                  
                end
                    
            end 


        else
%%%            deleteAlphaCurve('vol');

            set(uiSliderVolLinAlpha, 'Enable', 'off');

            if get(ui3DVolume, 'Value') == 2 % Fusion
                if ~isempty(volFusionObj)
                    aAlphamap = defaultVolFusionAlphaMap(fusionBuffer('get'), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});

                    getVolFusionAlphaMap('set', fusionBuffer('get'), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});
                    displayAlphaCurve(aAlphamap, axeVolAlphmap);
                    
                    if switchTo3DMode('get') == true && isFusion('get') == true   
                        set(volFusionObj, 'Alphamap', aAlphamap);
                    end
                end 
            else
                if ~isempty(volObj)
                    aAlphamap = defaultVolAlphaMap(dicomBuffer('get'), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});
                    getVolAlphaMap('set', dicomBuffer('get'), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});
                    displayAlphaCurve(aAlphamap, axeVolAlphmap);
                    
                    if switchTo3DMode('get') == true 
                        set(volObj, 'Alphamap', aAlphamap);
                    end
                end                            
            end 
        end

        initGate3DObject('set', true);

    end

    function sliderVolLinearAlphaCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        aAlphamap = linspace(0, get(uiSliderVolLinAlpha, 'Value'), 256)';
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            if switchTo3DMode('get') == true && isFusion('get') == true   
                volFusionObj = volFusionObject('get');
                if ~isempty(volFusionObj)
                    set(volFusionObj, 'Alphamap', aAlphamap);
                end
            end
            
            volLinearFusionAlphaValue('set', get(uiSliderVolLinAlpha, 'Value'));
            getVolFusionAlphaMap('set', fusionBuffer('get'), 'linear', aAlphamap);            
        else
            if switchTo3DMode('get') == true
                volObj = volObject('get');
                if ~isempty(volObj)
                    set(volObj, 'Alphamap', aAlphamap);
                end
            end
            volLinearAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));
            getVolAlphaMap('set', dicomBuffer('get'), 'linear', aAlphamap);
        end
        
        displayAlphaCurve(aAlphamap, axeVolAlphmap);
      
        initGate3DObject('set', true);

    end

    function mipAlphaMapTypeCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        mipObj       = mipObject('get');
        mipFusionObj = mipFusionObject('get');
            
        if strcmpi(uiMipAlphaMapType.String{uiMipAlphaMapType.Value}, 'linear')

%%%            deleteAlphaCurve('mip');

            set(uiSliderMipLinAlpha, 'Enable', 'on');

            aAlphamap = linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)';

            mipLinearAlphaValue('set',  get(uiSliderMipLinAlpha, 'Value'));
%            getMipAlphaMap('set', dicomBuffer('get'), 'linear', aAlphamap);
            
            displayAlphaCurve(aAlphamap, axeMipAlphmap);
            
            if get(ui3DVolume, 'Value') == 2 % Fusion
                getMipFusionAlphaMap('set', fusionBuffer('get'), 'linear', aAlphamap);
                if switchToMIPMode('get') == true && isFusion('get') == true                 
                    if ~isempty(mipFusionObj)
                        set(mipFusionObj, 'Alphamap', aAlphamap);
                    end 
                end
            else
                getMipAlphaMap('set', dicomBuffer('get'), 'linear', aAlphamap);
                
                if switchToMIPMode('get') == true
                    if ~isempty(mipObj)
                        set(mipObj, 'Alphamap', aAlphamap);
                    end
                end                            
            end
            
         elseif strcmpi(uiMipAlphaMapType.String{uiMipAlphaMapType.Value}, 'custom')
             
            set(uiSliderMipLinAlpha, 'Enable', 'off');

            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                
                getMipFusionAlphaMap('set', fusionBuffer('get'), 'custom');
                
                if switchToMIPMode('get') == true && isFusion('get') == true   
               
                    ic = customAlphaCurve(axeMipAlphmap,  mipFusionObj, 'mipfusion');
                    ic.surfObj = mipFusionObj;  

                    mipICFusionObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mipfusion');
                else
                    tFuseInput  = inputTemplate('get');
                    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    
                    [aFusionAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);
                    
                    displayAlphaCurve(aFusionAlphaMap, axeMipAlphmap);                   
                end
               
            else
                getMipAlphaMap('set', dicomBuffer('get'), 'custom');
                if switchToMIPMode('get') == true

                    ic = customAlphaCurve(axeMipAlphmap,  mipObj, 'mip');
                    ic.surfObj = mipObj;                              

                    mipICObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mip');
                else
                    [aAlphaMap, ~] = getVolAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));                    
                    displayAlphaCurve(aAlphaMap, axeMipAlphmap);                   
               end
            
            end             

%            getMipAlphaMap('set', dicomBuffer('get'), 'custom');

        else
%%%            deleteAlphaCurve('mip');

            set(uiSliderMipLinAlpha, 'Enable', 'off');
            
            if get(ui3DVolume, 'Value') == 2 % Fusion
                if ~isempty(mipFusionObj)
                    aAlphamap = defaultMipFusionAlphaMap(fusionBuffer('get'), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});

                    getMipFusionAlphaMap('set', fusionBuffer('get'), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});
                    displayAlphaCurve(aAlphamap, axeMipAlphmap);
                    
                    if switchToMIPMode('get') == true && isFusion('get') == true   
                        set(mipFusionObj, 'Alphamap', aAlphamap);
                    end
                end 
            else
                if ~isempty(mipObj)
              
                    aAlphamap = defaultMipAlphaMap(dicomBuffer('get'), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});
                    getMipAlphaMap('set', dicomBuffer('get'), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});
                    displayAlphaCurve(aAlphamap, axeMipAlphmap);
            
                    if switchToMIPMode('get') == true
                        set(mipObj, 'Alphamap', aAlphamap);
                    end
                end                            
            end             
        end

        initGate3DObject('set', true);

    end

    function sliderMipLinearAlphaCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        aAlphamap = linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)';
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            if switchToMIPMode('get') == true && isFusion('get') == true   
                mipFusionObj = mipFusionObject('get');
                if ~isempty(mipFusionObj)
                    set(mipFusionObj, 'Alphamap', linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)');
                end
            end
            mipLinearFuisonAlphaValue('set',  get(uiSliderMipLinAlpha, 'Value'));
            getMipFusionAlphaMap('set', fusionBuffer('get'), 'linear', aAlphamap);            
        else
            if switchToMIPMode('get')    == true
                mipObj = mipObject('get');
                if ~isempty(mipObj)
                    set(mipObj, 'Alphamap', linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)');
                end
            end
            
            mipLinearAlphaValue('set',  get(uiSliderMipLinAlpha, 'Value'));
            getMipAlphaMap('set', dicomBuffer('get'), 'linear', aAlphamap);
        end
        
        displayAlphaCurve(aAlphamap, axeMipAlphmap);

        initGate3DObject('set', true);

    end

    function sliderIsoCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            if switchToIsoSurface('get') == true && isFusion('get') == true   
                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    set(isoFusionObj, 'Isovalue', get(uiSliderIsoSurface, 'Value'));
                end
            end
            
            isoSurfaceFusionValue('set', get(uiSliderIsoSurface, 'Value'));

        else
            if switchToIsoSurface('get') == true          
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    set(isoObj, 'Isovalue', get(uiSliderIsoSurface, 'Value'));
                end
            end
            
            isoSurfaceValue('set', get(uiSliderIsoSurface, 'Value'));
        end
        
        set(uiEditIsoSurface, 'String', num2str(get(uiSliderIsoSurface, 'Value')));            
       
        initGate3DObject('set', true);

    end

    function editIsoSurfaceCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        sValue = get(uiEditIsoSurface, 'String');

        if str2double(sValue) > 1
            sValue = '1';
        end
        
        if get(ui3DVolume, 'Value') == 2 % Fusion
            
            isoFusionObj = isoFusionObject('get');
            if switchToIsoSurface('get') == true  && isFusion('get') == true          
                if ~isempty(isoFusionObj)
                    set(isoFusionObj, 'Isovalue', str2double(sValue) );
                end
            end
            isoSurfaceFusionValue('set', str2double(sValue));            
        else
            if switchToIsoSurface('get') == true          
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    set(isoObj, 'Isovalue', str2double(sValue) );
                end
            end
            isoSurfaceValue('set', str2double(sValue));
        end
        
        set(uiEditIsoSurface  , 'String', sValue);
        set(uiSliderIsoSurface, 'Value', str2double(sValue) );

        initGate3DObject('set', true);

    end

end
