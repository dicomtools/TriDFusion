function init3DuicontrolPanel()
%function init3DuicontrolPanel()
%Init 3D Panel Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
                  'FontWeight', 'bold',...
                  'position', [25 872 200 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
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
                     'Position', [135 875 510 20], ...
                     'String'  , as3DVolume, ...
                     'Value'   , 1 ,...
                     'Enable'  , sVolumeEnable, ...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...
                     'Callback', @set3DVolumeCallback...
                     );
       ui3DVolumePtr('set', ui3DVolume);

    % 3D VOI

       chkDispVoi = ...
           uicontrol(ui3DPanelPtr('get'),...
                     'style'   , 'checkbox',...
                     'enable'  , 'on',...
                     'value'   , displayVoi('get'),...
                     'position', [350 750 20 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...
                     'Callback', @display3DVoiCallback...
                     );
       ui3DDispVoiPtr('set', chkDispVoi);

          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'Display Contours',...
                    'horizontalalignment', 'left',...
                    'position', [375 747 250 20],...
                    'Enable', 'Inactive',...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'ButtonDownFcn', @display3DVoiTxtCallback...
                    );

        uicontrol(ui3DPanelPtr('get'),...
                  'Position', [505 720 140 25],...
                  'String'  , 'List',...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @voiEnableListCallback...
                  );

          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'Contour Setting',...
                    'horizontalalignment', 'left',...
                    'position', [350 717 150 20],...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'Enable', 'On'...
                    );
if 0
          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'VOI Transparency',...
                    'horizontalalignment', 'left',...
                    'position', [350 715 150 20],...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'Enable', 'On'...
                    );

    uislider3DVoiTransparency = ...
         uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [350 700 295 14], ...
                  'Value'   , slider3DVoiTransparencyValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @slider3DVoiTransparencyCallback ...
                  );
%    addlistener(uislider3DVoiTransparency, 'Value', 'PreSet', @slider3DVoiTransparencyCallback);
end
    % 3D Background

         uicontrol(ui3DPanelPtr('get'),...
                   'style'   , 'text',...
                   'string'  , 'Background Color',...
                   'horizontalalignment', 'left',...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'position', [350 822 200 20]...
                   );

    ui3DBackground = ...
         uicontrol(ui3DPanelPtr('get'), ...
                   'Style'   , 'popup', ...
                   'Position', [505 825 140 20], ...
                   'String'  , surfaceColor('all'), ...
                   'Value'   , background3DOffset('get'),...
                   'Enable'  , 'on', ...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'CallBack', @background3DCallback ...
                   );
    ui3DBackgroundPtr('set', ui3DBackground);

    % Volume Aspect Ration

    slider3DRatioLastValue('set', 0.5);
    uiSlider3DRatio = ...
         uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [631 565 14 70], ...
                  'Value'   , slider3DRatioLastValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @slider3DRatioCallback ...
                  );
%          addlistener(uiSlider3DRatio,'Value','PreSet',@slider3DRatioCallback);

    uiEdit3DXRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 615 120 20], ...
                  'String'  , volumeScaleFator('get', 'x'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D X-axis ratio',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 612 120 20]...
                  );

    uiEdit3DYRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 590 120 20], ...
                  'String'  , volumeScaleFator('get', 'y'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D Y-axis ratio',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 587 120 20]...
                  );

    uiEdit3DZRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 565 120 20], ...
                  'String'  , volumeScaleFator('get', 'z'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @edit3DRatioCallback ...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , '3D Z-axis ratio',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 562 120 20]...
                  );

    % Volume Lighting
    
    bLightingIsSupported = true;
    if verLessThan('matlab','9.8')
        bLightingIsSupported = false;                    
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
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @volLightingCallback...
                  );
     chk3DVolLightingPtr('set', chkVolLighting);

     txtVolLighting = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Lighting',...
                  'horizontalalignment', 'left',...
                  'position', [45 533 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @displayVolColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Display Volume Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [45 507 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @displayVolColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Colormap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 482 150 20]...
                  );

    uiColorVol = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 485 140 20], ...
                  'String'  , get3DColorMap('all'), ...
                  'Value'   , colorMapVolOffset('get'),...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @colorMapVolCallback ...
                  );
     ui3DVolColormapPtr('set', uiColorVol);


      % Volume Alphamap

         uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Alphamap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 457 150 20]...
                  );

    [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));

    [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, dicomMetaData('get'));

    uiVolumeAlphaMapType = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 460 140 20], ...
                  'String'  , {'Linear', 'Custom', 'MR', 'CT', 'PET'}, ...
                  'Value'   , dVolAlphaOffset,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @volAlphaMapTypeCallback ...
                  );
     ui3DVolAlphamapTypePtr('set', uiVolumeAlphaMapType);

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Linear Alphamap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 435 200 20]...
                  );

    uiSliderVolLinAlpha = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [25 420 295 14], ...
                  'Value'   , volLinearAlphaValue('get'), ...
                  'Enable'  , sVolMapSliderEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderVolLinearAlphaCallback ...
                  );
    ui3DSliderVolLinAlphaPtr('set', uiSliderVolLinAlpha);

    uiSliderVolLinAlphaListener = addlistener(uiSliderVolLinAlpha, 'Value', 'PreSet', @sliderVolLinearAlphaCallback);

    % Vol Alphamap Editor

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Volume Alphamap Editor',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 390 235 20]...
                  );

    axeVolAlphmap = ...
        axes(ui3DPanelPtr('get'),...
             'Units'   , 'pixels',...
             'Color'   , viewerAxesColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'position', [25 35 295 350]...
             );
    axe3DPanelVolAlphmapPtr('set', axeVolAlphmap);
 %   axeVolAlphmap.Title.String = 'Volume Alphamap';

    if strcmpi(sType, 'Custom')
        ic = customAlphaCurve(axeVolAlphmap,  volObject('get'), 'vol');
        volICObject('set', ic);
        alphaCurveMenu(axeVolAlphmap, 'vol');
    else
        displayAlphaCurve(aMap, axeVolAlphmap);
    end

    % ISO Surface Mask

    chkAddVoiIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , addVoiIsoMask('get'),...
                  'position', [25 750 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @addVoiIsoMaskCallback...
                  );
     chkAddVoiIsoMaskPtr('set', chkAddVoiIsoMask);

     txtAddVoiIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Add Contours',...
                  'horizontalalignment', 'left',...
                  'position', [45 747 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @addVoiIsoMaskCallback...
                  );
    txtAddVoiIsoMaskPtr('set', txtAddVoiIsoMask);
        
    chkPixelEdgeIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , pixelEdgeIsoMask('get'),...
                  'position', [45 725 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @pixelEdgeIsoMaskCallback...
                  );
     chkPixelEdgeIsoMaskPtr('set', chkPixelEdgeIsoMask);

     txtPixelEdgeIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Pixel Edge',...
                  'horizontalalignment', 'left',...
                  'position', [65 722 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @pixelEdgeIsoMaskCallback...
                  );
    txtPixelEdgeIsoMaskPtr('set', txtPixelEdgeIsoMask);    
    
    uiEditAddVoiIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 700 65 20], ...
                  'String'  , voiIsoMaskMax('get'), ...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editVoiIsoMaxValue ...
                  );
    uiEditAddVoiIsoMaskPtr('set', uiEditAddVoiIsoMask);
    
    sUnitDisplay = getSerieUnitValue( get(uiSeriesPtr('get'), 'Value'));
    if ~strcmpi(sUnitDisplay, 'SUV')
        percentOfPeakIsoMask('set', true);
    end

    chkPercentOfPeakIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , percentOfPeakIsoMask('get'),...
                  'position', [45 700 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @percentOfPeakIsoMaskCallback...
                  );
     chkPercentOfPeakIsoMaskPtr('set', chkPercentOfPeakIsoMask);

     txtPercentOfPeakIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Percent of Peak',...
                  'horizontalalignment', 'left',...
                  'position', [65 697 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @percentOfPeakIsoMaskCallback...
                  );
    txtPercentOfPeakIsoMaskPtr('set', txtPercentOfPeakIsoMask);

    if percentOfPeakIsoMask('get') == true
        set(uiEditAddVoiIsoMask    , 'String', num2str(voiIsoMaskMax('get')));
        set(txtPercentOfPeakIsoMask, 'String', 'Percent of Peak');
    else
        set(uiEditAddVoiIsoMask    , 'String', num2str(peakSUVMaxIsoMask('get')));
        set(txtPercentOfPeakIsoMask, 'String', 'Min SUV Value');
    end

    chkMultiplePeaksIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , multiplePeaksIsoMask('get'),...
                  'position', [65 675 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @multiplePeaksIsoMaskCallback...
                  );
     chkMultiplePeaksIsoMaskPtr('set', chkMultiplePeaksIsoMask);

     txtMultiplePeaksIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Multiple Peaks (% of peak)',...
                  'horizontalalignment', 'left',...
                  'position', [85 672 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @multiplePeaksIsoMaskCallback...
                  );
    txtMultiplePeaksIsoMaskPtr('set', txtMultiplePeaksIsoMask);


    uiEditPeakPercentIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 675 65 20], ...
                  'String'  , peakPercentIsoMask('get'), ...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editPeakPercentIsoMaskValue ...
                  );
    uiEditPeakPercentIsoMaskPtr('set', uiEditPeakPercentIsoMask);
    
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Min SUV Formula',...
                  'horizontalalignment', 'left',...
                  'position', [65 647 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On' ...
                  );

%    uiValueFormulaIsoMask = ...
%        uicontrol(ui3DPanelPtr('get'), ...
%                  'Style'   , 'popup', ...
%                  'Position', [180 650 140 20], ...
%                  'string'  , {'Fixed', ...
%                               '(4.30/SUVmean)x(SUVmean + SD)', ...
%                               '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map', ...
%                               '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT ISO Map', ...      
%                               'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map', ...
%                               'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map' ...                                  
%                               },...
%                  'Value'   , valueFormulaIsoMask('get'), ...
%                  'Enable'  , 'on', ...
%                  'BackgroundColor', viewerBackgroundColor('get'), ...
%                  'ForegroundColor', viewerForegroundColor('get'), ...
%                  'CallBack', @minSuvFromFormulaIsoMaskValue ...
%                  );
%    uiValueFormulaIsoMaskPtr('set', uiValueFormulaIsoMask);    

    uiValueFormulaIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 650 140 20], ...
                  'string'  , {'Fixed', ...
                               '(4.30/SUVmean)x(SUVmean + SD)', ...
                               '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map', ...
                               '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map', ...
                               'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map', ...
                               },...
                  'Value'   , valueFormulaIsoMask('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @minSuvFromFormulaIsoMaskValue ...
                  );
    uiValueFormulaIsoMaskPtr('set', uiValueFormulaIsoMask);  
    
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'Text',...
                  'string'  , 'Smallest Contour (ml)',...
                  'horizontalalignment', 'left',...
                  'position', [45 622 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On' ...
                  );

    uiEditSmalestIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 625 65 20], ...
                  'String'  , smalestIsoMask('get'), ...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editSmalestIsoMaskValue ...
                  );
    uiEditSmalestIsoMaskPtr('set', uiEditSmalestIsoMask);

    chkResampleToCTIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , resampleToCTIsoMask('get'),...
                  'position', [25 600 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resampleToCTIsoMaskCallback...
                  );
     chkResampleToCTIsoMaskPtr('set', chkResampleToCTIsoMask);

     txtResampleToCTIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Resample to CT',...
                  'horizontalalignment', 'left',...
                  'position', [45 597 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @resampleToCTIsoMaskCallback...
                  );
    txtResampleToCTIsoMaskPtr('set', txtResampleToCTIsoMask);

    tResampleToCT = resampleToCTIsoMaskUiValues('get');

    if isempty(tResampleToCT)
        asCTSeries = ' ';
        isoMaskCtSerieOffset('set', 1);
    else
        atDicomMeta = dicomMetaData('get');
        atInput = inputTemplate('get');
        
        asCTSeries = num2cell(zeros(1,numel(tResampleToCT)));

        for cc=1:numel(tResampleToCT)
            
            if strcmpi(atDicomMeta{1}.StudyInstanceUID, atInput(tResampleToCT{cc}.dSeriesNumber).atDicomInfo{1}.StudyInstanceUID)
                isoMaskCtSerieOffset('set', cc);
            end
            
            asCTSeries{cc} = tResampleToCT{cc}.sSeriesDescription;
        end
    end

    uiResampleToCTIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 600 140 20], ...
                  'String'  , asCTSeries, ...
                  'Value'   , isoMaskCtSerieOffset('get'),...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @resampleToCTOffsetCallback ...
                  );
     uiResampleToCTIsoMaskPtr('set', uiResampleToCTIsoMask);
     
%    chkResampledContoursIsoMask = ...
%        uicontrol(ui3DPanelPtr('get'),...
%                  'style'   , 'checkbox',...
%                  'enable'  , 'off',...
%                  'value'   , resampledContoursIsoMask('get'),...
%                  'position', [45 610 20 20],...
%                  'BackgroundColor', viewerBackgroundColor('get'), ...
%                  'ForegroundColor', viewerForegroundColor('get'), ...
%                  'Callback', @resampledContoursIsoMaskCallback...
%                  );
%     chkResampledContoursIsoMaskPtr('set', chkResampledContoursIsoMask);

%     txtResampledContoursIsoMask = ...
%       uicontrol(ui3DPanelPtr('get'),...
%                  'style'   , 'text',...
%                  'string'  , 'Contours from Resampled Matrix',...
%                  'horizontalalignment', 'left',...
%                  'position', [65 607 250 20],...
%                  'BackgroundColor', viewerBackgroundColor('get'), ...
%                  'ForegroundColor', viewerForegroundColor('get'), ...
%                  'Enable', 'On', ...
%                  'ButtonDownFcn', @resampledContoursIsoMaskCallback...
%                  );
%    txtResampledContoursIsoMaskPtr('set', txtResampledContoursIsoMask);  
                  
%         uicontrol(ui3DPanelPtr('get'),...
%                  'style'   , 'text',...
%                  'string'  , 'Isosurface Mask',...
%                  'horizontalalignment', 'left',...
%                  'BackgroundColor', viewerBackgroundColor('get'), ...
%                  'ForegroundColor', viewerForegroundColor('get'), ...
%                  'position', [25 575 200 20]...
%                  );

    uiCreateIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'Position', [180 565 140 25],...
                  'String'  , 'Create Mask',...
                  'Enable'  , 'off', ...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @createIsoMaskCallback...
                  );
    ui3DCreateIsoMaskPtr('set', uiCreateIsoMask);

    % ISO Surface Color

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Isosurface Color',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 822 150 20]...
                  );
    
    asColor = [surfaceColor('all') 'Custom'];
    uiIsoSurfaceColor = ...
       uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 825 140 20], ...
                  'String'  , asColor, ...
                  'Value'   , isoColorOffset('get'),...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @isoSurfaceColorCallback ...
                  );
    ui3DIsoSurfaceColorPtr('set', uiIsoSurfaceColor);

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Isosurface Scalar Value',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 800 300 20]...
                              );

    uiSliderIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [25 785 225 14], ...
                  'Value'   , isoSurfaceValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderIsoCallback ...
                  );
    ui3DSliderIsoSurfacePtr('set', uiSliderIsoSurface);
    
    bypassUiSliderIsoSurfaceListener('set', false);    
    uiSliderIsoSurfaceListener = addlistener(uiSliderIsoSurface,'Value','PreSet',@sliderIsoCallback);
    

    uiEditIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 785 65 20], ...
                  'String'  , num2str(isoSurfaceValue('get')*100), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @displayMIPColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Display MIP Colormap',...
                  'horizontalalignment', 'left',...
                  'position', [375 507 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @displayMIPColorMapCallback...
                  );

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Colormap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 482 100 20]...
                  );

    uiColorMip = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [505 485 140 20], ...
                  'String'  , get3DColorMap('all'), ...
                  'Value'   , colorMapMipOffset('get'),...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @colorMapMipCallback ...
                  );
    ui3DMipColormapPtr('set', uiColorMip);

    % MIP Alphamap

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Alphamap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 457 100 20]...
                  );

    [aMap, sType] = getMipAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));

    [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, dicomMetaData('get'));

    uiMipAlphaMapType = ...
         uicontrol(ui3DPanelPtr('get'), ...
                   'Style'   , 'popup', ...
                   'Position', [505 460 140 20], ...
                   'String'  , {'Linear', 'Custom', 'MR', 'CT', 'PET'}, ...
                   'Value'   , dMipAlphaOffset,...
                   'Enable'  , 'on', ...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'CallBack', @mipAlphaMapTypeCallback ...
                  );
     ui3DMipAlphamapTypePtr('set', uiMipAlphaMapType);

    % MIP Linear Alphamap

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Linear Alphamap',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 435 235 20]...
                  );

    uiSliderMipLinAlpha = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [350 420 295 14], ...
                  'Value'   , mipLinearAlphaValue('get'), ...
                  'Enable'  , sMipMapSliderEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderMipLinearAlphaCallback ...
                  );
    uiSliderMipLinAlphaListener = addlistener(uiSliderMipLinAlpha, 'Value', 'PreSet', @sliderMipLinearAlphaCallback);
    ui3DSliderMipLinAlphaPtr('set', uiSliderMipLinAlpha);

    % MIP Alphamap Editor

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'MIP Alphamap Editor',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [350 390 235 20]...
                  );

    axeMipAlphmap = ...
        axes(ui3DPanelPtr('get'),...
             'Units'   , 'pixels',...
             'Tag'     , 'Mip Alphamap',...
             'Color'   , viewerAxesColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'position', [350 35 295 350]...
             );
    axe3DPanelMipAlphmapPtr('set', axeMipAlphmap);
%      axeVolAlphmap.Title.String = 'MIP Alphamap';

    if strcmp(sType, 'Custom')
        ic = customAlphaCurve(axeMipAlphmap,  mipObject('get'), 'mip');
        mipICObject('set', ic);
        alphaCurveMenu(axeMipAlphmap, 'mip');
    else
        displayAlphaCurve(aMap, axeMipAlphmap);
    end

    hold off;

    function display3DVoiTxtCallback(~, ~)

        if get(ui3DDispVoiPtr('get'), 'Value') == true

            set(ui3DDispVoiPtr('get'), 'Value', false);

            display3DVoiCallback();
        else
            set(ui3DDispVoiPtr('get'), 'Value', true);
            
            display3DVoiCallback();
        end
    end

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

                [aMap, sType] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atFuseMetaData);

                set(uiVolumeAlphaMapType, 'Value' , dVolAlphaOffset);
                set(uiSliderVolLinAlpha , 'Enable', sVolMapSliderEnable);
                set(uiSliderVolLinAlpha , 'Value' , volLinearFusionAlphaValue('get'));

                if strcmpi(sType, 'Custom') && ...
                   isFusion('get')       == true &&...
                   switchTo3DMode('get') == true

                    ic = customAlphaCurve(axeVolAlphmap,  volFusionObj, 'volfusion');
                    ic.surfObj = volFusionObj;

                    volICFusionObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'volfusion');
                else
                    if isFusion('get') == false || ...
                       switchTo3DMode('get') == false
                        displayAlphaCurve(zeros(256,1), axeVolAlphmap);
                    else
                        displayAlphaCurve(aMap, axeVolAlphmap);
                    end
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

                [aMap, sType] = getMipFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, atFuseMetaData);

                set(uiMipAlphaMapType   , 'Value' , dMipAlphaOffset);
                set(uiSliderMipLinAlpha , 'Enable', sMipMapSliderEnable);
                set(uiSliderMipLinAlpha , 'Value' , mipLinearFuisonAlphaValue('get'));

                if strcmpi(sType, 'Custom') && ...
                   isFusion('get')        == true && ...
                   switchToMIPMode('get') == true

                    ic = customAlphaCurve(axeMipAlphmap,  mipFusionObj, 'mipfusion');
                    ic.surfObj = mipFusionObj;

                    mipICFusionObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mipfusion');
                else
                    if isFusion('get') == false || ...
                       switchToMIPMode('get') == false
                        displayAlphaCurve(zeros(256,1), axeMipAlphmap);
                    else
                        displayAlphaCurve(aMap, axeMipAlphmap);
                    end
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
            set(uiEditIsoSurface  , 'String', num2str(isoSurfaceFusionValue('get')*100));

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

                if strcmpi(sType, 'Custom') && switchTo3DMode('get') == true

                    ic = customAlphaCurve(axeVolAlphmap,  volObj, 'vol');
                    ic.surfObj = volObj;

                    volICObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'vol');
                else
                    if switchTo3DMode('get') == false
                        displayAlphaCurve(zeros(256,1), axeVolAlphmap);
                    else
                        displayAlphaCurve(aMap, axeVolAlphmap);
                    end
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

                if strcmpi(sType, 'Custom') && switchToMIPMode('get') == true
                    ic = customAlphaCurve(axeMipAlphmap,  mipObj, 'mip');
                    ic.surfObj = mipObj;

                    mipICObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mip');
                else
                    if switchToMIPMode('get') == false
                        displayAlphaCurve(zeros(256,1), axeMipAlphmap);
                    else
                        displayAlphaCurve(aMap, axeMipAlphmap);
                    end
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
            set(uiEditIsoSurface  , 'String', num2str(isoSurfaceValue('get')*100));

        end

        uiSliderMipLinAlphaListener = addlistener(uiSliderMipLinAlpha, 'Value', 'PreSet', @sliderMipLinearAlphaCallback);
        uiSliderVolLinAlphaListener = addlistener(uiSliderVolLinAlpha, 'Value', 'PreSet', @sliderVolLinearAlphaCallback);
        uiSliderIsoSurfaceListener  = addlistener(uiSliderIsoSurface , 'Value', 'PreSet', @sliderIsoCallback);
    end

    function voiEnableListCallback(~, ~)

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
%        for pp=1:numel(atVoiInput) % Patch, don't export total-mask
%            if strcmpi(atVoiInput{pp}.Label, 'TOTAL-MASK')
%                atVoiInput{pp} = [];
%                atVoiInput(cellfun(@isempty, atVoiInput)) = [];       
%            end
%        end     
        
        if ~isempty(atVoiInput)

            dlgVoiListEnable = ...
               dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-540/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-280/2) ...
                                    540 ...
                                    280 ...
                                    ],...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'Voi Setting'...
                       );

           uiVoiListWindow = ...
               uipanel(dlgVoiListEnable,...
                      'Units'   , 'pixels',...
                      'position', [0 ...
                                   0 ...
                                   540 ...
                                   2000 ...
                                   ], ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get') ...
                      );


           aVoiListEnablePosition = get(dlgVoiListEnable, 'position');
           uiVoiListSlider = ...
              uicontrol('Style'   , 'Slider', ...
                        'Parent'  , dlgVoiListEnable,...
                        'Units'   , 'pixels',...
                        'position', [aVoiListEnablePosition(3)-20 ...
                                     0 ...
                                     20 ...
                                     aVoiListEnablePosition(4) ...
                                     ],...
                        'Value', 0, ...
                        'BackgroundColor', viewerBackgroundColor('get'), ...
                        'ForegroundColor', viewerForegroundColor('get'), ...
                        'Callback', @uiVoiListEnableCallback ...
                        );
            addlistener(uiVoiListSlider,'Value','PreSet', @uiVoiListEnableCallback);

            aVoiEnableList = voi3DEnableList('get');
            if isempty(aVoiEnableList)
                for aa=1:numel(atVoiInput)
                    aVoiEnableList{aa} = true;
                end
            end

            aVoiTransparencyList = voi3DTransparencyList('get');
            if isempty(aVoiTransparencyList)
                for aa=1:numel(atVoiInput)
                    aVoiTransparencyList{aa} = slider3DVoiTransparencyValue('get');
                end
            end

            for aa=1:numel(atVoiInput)

                sVoiName  = atVoiInput{aa}.Label;
                aVoiColor = atVoiInput{aa}.Color;

                chkVoiList{aa} = ...
                    uicontrol(uiVoiListWindow,...
                              'style'   , 'checkbox',...
                              'enable'  , 'on',...
                              'value'   , aVoiEnableList{aa},...
                              'position', [20 aa*25 20 20],...
                              'UserData', aa, ...
                              'BackgroundColor', viewerBackgroundColor('get'), ...
                              'ForegroundColor', viewerForegroundColor('get'), ...
                              'Callback', @chkVoiListCallback...
                              );

                txtVoiList{aa} = ...
                    uicontrol(uiVoiListWindow,...
                              'style'   , 'text',...
                              'string'  , sVoiName,...
                              'horizontalalignment', 'left',...
                              'position', [40 chkVoiList{aa}.Position(2)-3 200 20],...
                              'Enable', 'Inactive',...
                              'UserData', aa, ...
                              'ForegroundColor', aVoiColor, ...
                              'BackgroundColor', viewerBackgroundColor('get'), ...
                              'ButtonDownFcn', @chkVoiListCallback...
                              );

                sliVoiList{aa} = ...
                    uicontrol(uiVoiListWindow, ...
                              'Style'   , 'Slider', ...
                              'Position', [250 chkVoiList{aa}.Position(2) 200 20], ...
                              'Value'   , aVoiTransparencyList{aa}, ...
                              'Enable'  , 'on', ...
                              'UserData', aa, ...
                              'BackgroundColor', viewerBackgroundColor('get'), ...
                              'ForegroundColor', viewerForegroundColor('get'), ...
                              'CallBack', @sliVoiListCallback ...
                              );

                edtVoiList{aa} = ...
                    uicontrol(uiVoiListWindow, ...
                              'Style'   , 'Edit', ...
                              'Position', [455 chkVoiList{aa}.Position(2) 55 20], ...
                              'String'  , aVoiTransparencyList{aa}, ...
                              'Enable'  , 'on', ...
                              'UserData', aa, ...
                              'BackgroundColor', viewerBackgroundColor('get'), ...
                              'ForegroundColor', viewerForegroundColor('get'), ...
                              'CallBack', @edtVoiListCallback ...
                              );

            end

        end

        initGate3DObject('set', true);

        function uiVoiListEnableCallback(~, ~)

            val = get(uiVoiListSlider, 'Value');

            aPosition = get(uiVoiListWindow, 'Position');

            dPanelYSize = aPosition(4);
            dPanelOffset = val * dPanelYSize;

            set(uiVoiListWindow, 'Position',[aPosition(1) 0-dPanelOffset aPosition(3) aPosition(4)])

        end

        function chkVoiListCallback(hObject, ~)

            try

            set(dlgVoiListEnable, 'Pointer', 'watch');
            drawnow;

            sUiStyle   = get(hObject, 'Style'   );
            dVoiOffset = get(hObject, 'UserData');
            dVoiValue  = get(chkVoiList{dVoiOffset}, 'Value');

            if strcmpi(sUiStyle, 'Text')
                if dVoiValue == true
                    dVoiValue = false;
                    set(chkVoiList{dVoiOffset}, 'Value', false);
                else
                    dVoiValue = true;
                    set(chkVoiList{dVoiOffset}, 'Value', true);
                end
            end

            aVoiEnableList{dVoiOffset} = dVoiValue;

            voi3DEnableList('set', aVoiEnableList);

            if displayVoi('get') == true
                voiObj = voiObject('get');
                if ~isempty(voiObj)
                    if strcmpi(voi3DRenderer('get'), 'VolumeRendering')

                        if aVoiEnableList{dVoiOffset} == true
                            aAlphamap = compute3DVoiAlphamap(aVoiTransparencyList{dVoiOffset});
                        else
                            aAlphamap = zeros(256,1);
                        end

                        set(voiObj{dVoiOffset}, 'Alphamap', aAlphamap);
                    else
                        if aVoiEnableList{dVoiOffset} == true
                            sRenderer = 'Isosurface';
                        else
                            sRenderer = 'LabelOverlayRendering';
                        end

                        dIsoValue = compute3DVoiTransparency(aVoiTransparencyList{dVoiOffset});

                        set(voiObj{dVoiOffset}, 'Isovalue', dIsoValue);
                        set(voiObj{dVoiOffset}, 'Renderer', sRenderer);
                    end
                end
            end

            catch
                progressBar(1, 'Error: chkVoiListCallback()');
            end

            set(dlgVoiListEnable, 'Pointer', 'default');
            drawnow;

        end

        function sliVoiListCallback(hObject, ~)

            dVoiOffset   = get(hObject, 'UserData');
            dSliderValue = get(hObject, 'Value');

            if displayVoi('get') == true

                voiObj = voiObject('get');

                if strcmpi(voi3DRenderer('get'), 'VolumeRendering')

                    if ~isempty(voiObj) && aVoiEnableList{dVoiOffset} == true
                        aAlphamap = compute3DVoiAlphamap(dSliderValue);
                        set(voiObj{dVoiOffset}, 'Alphamap', aAlphamap);
                    end
                else
                    if ~isempty(voiObj) && aVoiEnableList{dVoiOffset} == true
                        dIsoValue = compute3DVoiTransparency(dSliderValue);
                        set(voiObj{dVoiOffset}, 'Isovalue', dIsoValue);
                    end
                end
            end

            set(edtVoiList{dVoiOffset}, 'String', num2str(dSliderValue));

            aVoiTransparencyList{dVoiOffset} = dSliderValue;
            voi3DTransparencyList('set', aVoiTransparencyList);

        end

        function edtVoiListCallback(hObject, ~)

            dVoiOffset   = get(hObject, 'UserData');
            dSliderValue = str2double(get(hObject, 'String'));

            if dSliderValue < 0
                dSliderValue = 0;
            end

            if dSliderValue > 1
                dSliderValue = 1;
            end

            if displayVoi('get') == true

                voiObj = voiObject('get');

                if strcmpi(voi3DRenderer('get'), 'VolumeRendering')

                    if ~isempty(voiObj) && aVoiEnableList{dVoiOffset} == true
                        aAlphamap = compute3DVoiAlphamap(dSliderValue);
                        set(voiObj{dVoiOffset}, 'Alphamap', aAlphamap);
                    end
                else
                    if ~isempty(voiObj) && aVoiEnableList{dVoiOffset} == true
                        dIsoValue = compute3DVoiTransparency(dSliderValue);
                        set(voiObj{dVoiOffset}, 'Isovalue', dIsoValue);
                    end
                end
            end

            set(sliVoiList{dVoiOffset}, 'Value', dSliderValue);
            set(edtVoiList{dVoiOffset}, 'String', num2str(dSliderValue));

            aVoiTransparencyList{dVoiOffset} = dSliderValue;
            voi3DTransparencyList('set', aVoiTransparencyList);

        end
    end

    function slider3DVoiTransparencyCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end

        dSliderValue = get(hObject, 'Value');

        if displayVoi('get') == true

            voiObj = voiObject('get');

            aVoiEnableList = voi3DEnableList('get');
            if isempty(aVoiEnableList)
                for aa=1:numel(voiObj)
                    aVoiEnableList{aa} = true;
                end
            end

            if strcmpi(voi3DRenderer('get'), 'VolumeRendering')

                aAlphamap = compute3DVoiAlphamap(dSliderValue);
                if ~isempty(voiObj)
                    for ll=1:numel(voiObj)
                        progressBar(ll/numel(voiObj)-0.0001, sprintf('Processing VOI Transparency %d/%d', ll, numel(voiObj) ) );
                        if aVoiEnableList{ll} == true
                            set(voiObj{ll}, 'Alphamap', aAlphamap);
                        end
                    end
                end
            else
                dIsoValue = compute3DVoiTransparency(dSliderValue);
                if ~isempty(voiObj)
                    for ll=1:numel(voiObj)
                        progressBar(ll/numel(voiObj)-0.0001, sprintf('Processing VOI Transparency %d/%d', ll, numel(voiObj) ) );
                        if aVoiEnableList{ll} == true
                            set(voiObj{ll}, 'Isovalue', dIsoValue);
                        end
                    end
                end
            end
        end

        progressBar(1, 'Ready');

        slider3DVoiTransparencyValue('set', dSliderValue);

        initGate3DObject('set', true);
    end


    function background3DCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
        asColor = surfaceColor('get', get(hObject, 'Value'));
        if numel(asColor) ~= 1

            background3DOffset('set', get(hObject, 'Value'));

            volObj = volObject('get');
            if ~isempty(volObj)
                set(volObj, 'BackgroundColor', asColor);

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
                set(isoObj, 'BackgroundColor', asColor);
            end

            mipObj = mipObject('get');
            if ~isempty(mipObj)
                set(mipObj, 'BackgroundColor', asColor);

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
    end

    function resampleToCTOffsetCallback(hObject, ~)
        isoMaskCtSerieOffset('set', get(hObject, 'Value') );
    end

    function resampleToCTIsoMaskCallback(hObject, ~)

        if get(chkResampleToCTIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkResampleToCTIsoMask, 'Value', true);
            else
                set(chkResampleToCTIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkResampleToCTIsoMask, 'Value', false);
            else
                set(chkResampleToCTIsoMask, 'Value', true);
            end
        end
        
%        if get(chkResampleToCTIsoMask, 'Value') == true && ...
%          get(chkAddVoiIsoMask, 'Value') == true
                        
%            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'on');                
%            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'Inactive');
%        else
%            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'off');                
%            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'on');
%        end         
        
        resampleToCTIsoMask('set', get(chkResampleToCTIsoMask, 'Value'));
        
    end

%    function resampledContoursIsoMaskCallback(hObject, ~)
%
%        if get(chkResampledContoursIsoMask, 'Value') == true
%            if strcmpi(get(hObject, 'Style'), 'checkbox')
%                set(chkResampledContoursIsoMask, 'Value', true);
%            else
%                set(chkResampledContoursIsoMask, 'Value', false);
%            end
%        else
%            if strcmpi(get(hObject, 'Style'), 'checkbox')
%                set(chkResampledContoursIsoMask, 'Value', false);
%            else
%                set(chkResampledContoursIsoMask, 'Value', true);
%            end
%        end            
%        
%        resampledContoursIsoMask('set', get(chkResampledContoursIsoMask, 'Value'));
%        
%    end

    function addVoiIsoMaskCallback(hObject, ~)

        if get(chkAddVoiIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkAddVoiIsoMask, 'Value', true);
            else
                set(chkAddVoiIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkAddVoiIsoMask, 'Value', false);
            else
                set(chkAddVoiIsoMask, 'Value', true);
            end
        end

        addVoiIsoMask('set', get(chkAddVoiIsoMask, 'Value'));
    
        if addVoiIsoMask('get') == true
            
            set(chkPixelEdgeIsoMaskPtr     ('get'), 'Enable', 'on');
            set(txtPixelEdgeIsoMaskPtr     ('get'), 'Enable', 'Inactive' ); 
            
            set(uiEditAddVoiIsoMaskPtr('get'), 'Enable', 'on');

            sUnitDisplay = getSerieUnitValue( get(uiSeriesPtr('get'), 'Value'));
            if ~strcmpi(sUnitDisplay, 'SUV')
                percentOfPeakIsoMask('set', true);
                set(chkPercentOfPeakIsoMaskPtr('get'), 'Enable', 'off');
                set(txtPercentOfPeakIsoMaskPtr('get'), 'Enable', 'on');
            else
                set(chkPercentOfPeakIsoMaskPtr('get'), 'Enable', 'on');
                set(txtPercentOfPeakIsoMaskPtr('get'), 'Enable', 'Inactive');
            end

            if percentOfPeakIsoMask('get') == true
                set(uiEditAddVoiIsoMaskPtr('get')    , 'String', num2str(voiIsoMaskMax('get')));
                set(txtPercentOfPeakIsoMaskPtr('get'), 'String', 'Percent of Peak');

                set(chkMultiplePeaksIsoMaskPtr('get'), 'Enable', 'on');
                set(txtMultiplePeaksIsoMaskPtr('get'), 'Enable', 'Inactive');

                if multiplePeaksIsoMask('get') == true
                    set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'on');
                else
                    set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'off');
                end

            else
                set(uiEditAddVoiIsoMaskPtr('get')    , 'String', num2str(peakSUVMaxIsoMask('get')));
                set(txtPercentOfPeakIsoMaskPtr('get'), 'String', 'Min SUV Value');

                set(chkMultiplePeaksIsoMaskPtr('get'), 'Enable', 'off');
                set(txtMultiplePeaksIsoMaskPtr('get'), 'Enable', 'on');
                set(uiEditPeakPercentIsoMaskPtr        ('get'), 'Enable', 'off');
            end

            set(uiEditSmalestIsoMaskPtr('get'), 'Enable', 'on');
            
%            if get(chkResampleToCTIsoMask, 'Value') == true                        
%                set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'on');                
%                set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'Inactive');
%            end 
        
        else
            set(chkPixelEdgeIsoMaskPtr     ('get'), 'Enable', 'off');
            set(txtPixelEdgeIsoMaskPtr     ('get'), 'Enable', 'on' );            
            set(chkPercentOfPeakIsoMaskPtr ('get'), 'Enable', 'off');
            set(txtPercentOfPeakIsoMaskPtr ('get'), 'Enable', 'on' );
            set(uiEditAddVoiIsoMaskPtr     ('get'), 'Enable', 'off');
            set(chkMultiplePeaksIsoMaskPtr ('get'), 'Enable', 'off');
            set(txtMultiplePeaksIsoMaskPtr ('get'), 'Enable', 'on' );
            set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'off');
            set(uiEditSmalestIsoMaskPtr    ('get'), 'Enable', 'off');
%            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'off');                
%            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'on');            
        end

    end

    function editVoiIsoMaxValue(hObject, ~)

        dPercentMaxOrMaxSUVValue =  abs(str2double(get(hObject, 'String')));

        if get(chkPercentOfPeakIsoMask, 'Value') == true

            if dPercentMaxOrMaxSUVValue < 0
                dPercentMaxOrMaxSUVValue = 0;
            end

            if dPercentMaxOrMaxSUVValue > 100
                dPercentMaxOrMaxSUVValue = 100;
            end

            voiIsoMaskMax('set', dPercentMaxOrMaxSUVValue);
        else

            if dPercentMaxOrMaxSUVValue < 0
                dPercentMaxOrMaxSUVValue = 0;
            end

            peakSUVMaxIsoMask('set', dPercentMaxOrMaxSUVValue);
        end

        set(hObject, 'String', num2str(dPercentMaxOrMaxSUVValue));

    end


    function pixelEdgeIsoMaskCallback(hObject, ~)

        if get(chkPixelEdgeIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkPixelEdgeIsoMask, 'Value', true);
            else
                set(chkPixelEdgeIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkPixelEdgeIsoMask, 'Value', false);
            else
                set(chkPixelEdgeIsoMask, 'Value', true);
            end
        end

        pixelEdgeIsoMask('set', get(chkPixelEdgeIsoMask, 'Value'));

    end

    function percentOfPeakIsoMaskCallback(hObject, ~)

        if get(chkPercentOfPeakIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkPercentOfPeakIsoMask, 'Value', true);
            else
                set(chkPercentOfPeakIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkPercentOfPeakIsoMask, 'Value', false);
            else
                set(chkPercentOfPeakIsoMask, 'Value', true);
            end
        end

        percentOfPeakIsoMask('set', get(chkPercentOfPeakIsoMask, 'Value'));

        if percentOfPeakIsoMask('get') == true
            
            set(uiEditAddVoiIsoMaskPtr('get')    , 'Enable', 'on');
            set(uiEditAddVoiIsoMaskPtr('get')    , 'String', num2str(voiIsoMaskMax('get')));
            set(txtPercentOfPeakIsoMaskPtr('get'), 'String', 'Percent of Peak');

            set(chkMultiplePeaksIsoMaskPtr('get'), 'Enable', 'on');
            set(txtMultiplePeaksIsoMaskPtr('get'), 'Enable', 'Inactive');

            if multiplePeaksIsoMask('get') == true
                set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'on');
            else
                set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'off');
            end
            
            set(uiValueFormulaIsoMaskPtr('get'), 'Enable', 'off');
           
        else
            set(uiEditAddVoiIsoMaskPtr('get')    , 'String', num2str(peakSUVMaxIsoMask('get')));
            set(txtPercentOfPeakIsoMaskPtr('get'), 'String', 'Min SUV Value');

            set(chkMultiplePeaksIsoMaskPtr('get'), 'Enable', 'off');
            set(txtMultiplePeaksIsoMaskPtr('get'), 'Enable', 'on');
            set(uiEditPeakPercentIsoMaskPtr        ('get'), 'Enable', 'off');
            
            set(uiValueFormulaIsoMaskPtr('get'), 'Enable', 'on');
        
            asFormula = get(uiValueFormulaIsoMaskPtr('get'), 'String');
            dFormula  = get(uiValueFormulaIsoMaskPtr('get'), 'Value');
        
            if ~strcmpi(asFormula{dFormula}, 'Fixed')
                set(uiEditAddVoiIsoMaskPtr('get'), 'Enable', 'off');
            else
                set(uiEditAddVoiIsoMaskPtr('get'), 'Enable', 'on');
            end
        end

    end

    function multiplePeaksIsoMaskCallback(hObject, ~)

        if get(chkMultiplePeaksIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkMultiplePeaksIsoMask, 'Value', true);
            else
                set(chkMultiplePeaksIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkMultiplePeaksIsoMask, 'Value', false);
            else
                set(chkMultiplePeaksIsoMask, 'Value', true);
            end
        end

        multiplePeaksIsoMask('set', get(chkMultiplePeaksIsoMask, 'Value'));

        if multiplePeaksIsoMask('get') == true
            set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'on');
        else
            set(uiEditPeakPercentIsoMaskPtr('get'), 'Enable', 'off');
        end
    end

    function editPeakPercentIsoMaskValue(hObject, ~)

        dValue =  abs(str2double(get(hObject, 'String')));

        if dValue < 0
            dValue = 0;
        end

        if dValue > 100
            dValue = 100;
        end

        peakPercentIsoMask('set', dValue);

        set(hObject, 'String', num2str(dValue));

    end

    function minSuvFromFormulaIsoMaskValue(hObject, ~)
        
        asFormulaString = get(hObject, 'String');
        dFormulaValue   = get(hObject, 'Value');
        
        sFormula = asFormulaString{dFormulaValue};
        
        if strcmpi(sFormula, '(4.30/SUVmean)x(SUVmean + SD)')
            
            sSeriesUnit = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));            
            
            % Need a quantified PT or NM
            
            if ~strcmpi(sSeriesUnit, 'SUV') 
                set(hObject, 'Value', 1);
                valueFormulaIsoMask('set', 1);

                errordlg('Error: A quantified PT or NM must be activated to use this formula!', 'Formula Dialog');
                return;               
            end         
        end
        
        if strcmpi(sFormula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map') || ... % Use CT HU treshold value
           strcmpi(sFormula, '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map') || ...     
           strcmpi(sFormula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map')
            
            tResampleToCT = resampleToCTIsoMaskUiValues('get');
            
            dCTOffset = isoMaskCtSerieOffset('get');
            if isempty(tResampleToCT)
                set(hObject, 'Value', 1);
                valueFormulaIsoMask('set', 1);

                errordlg('Error: A quantified PT or NM and a CT is needed to use this formula!', 'Formula Dialog');
                return;                   
            else    
                
                dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;         

                sSeriesUnit = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));
                sCTUnit = getSerieUnitValue(dCTSeriesNumber);

                % Need a quantified PT or NM and a fused CT

                if ~(strcmpi(sSeriesUnit, 'SUV') && strcmpi(sCTUnit, 'HU'))
                    set(hObject, 'Value', 1);
                    valueFormulaIsoMask('set', 1);

                    errordlg('Error: A quantified PT or NM and a CT is needed to use this formula!', 'Formula Dialog');
                    return;               
                end 
            end
        end
        
        if strcmpi(sFormula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT ISO Map') || ... % Use CT ISO contour
           strcmpi(sFormula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')     
            
            btnFusion = btnFusionPtr('get');
            if strcmpi(get(btnFusion, 'Enable'), 'off')  % Need a fuse CT  
                set(hObject, 'Value', 1);
                valueFormulaIsoMask('set', 1);

                errordlg('Error: A quantified PT or NM and a fuse CT is needed to use this formula!', 'Formula Dialog');
                return;                   
            end
            
            sSeriesUnit = getSerieUnitValue(get(uiSeriesPtr('get')     , 'Value'));
            sFusionUnit = getSerieUnitValue(get(uiFusedSeriesPtr('get'), 'Value'));
            
            % Need a quantified PT or NM and a fused CT
                      
            if ~(strcmpi(sSeriesUnit, 'SUV') && strcmpi(sFusionUnit, 'HU'))
                set(hObject, 'Value', 1);
                valueFormulaIsoMask('set', 1);

                errordlg('Error: A quantified PT or NM and a fuse CT is needed to use this formula!', 'Formula Dialog');
                return;               
            end         
        end
                
        valueFormulaIsoMask('set', get(hObject, 'Value'));
                
        asFormula = get(hObject, 'String');
        dFormula  = get(hObject, 'Value');
        
        if ~strcmpi(asFormula{dFormula}, 'Fixed')
            set(uiEditAddVoiIsoMaskPtr('get'), 'Enable', 'off');
        else
            set(uiEditAddVoiIsoMaskPtr('get'), 'Enable', 'on');
        end
                        
%        tQuant = quantificationTemplate('get');
%        if isfield(tQuant, 'tSUV')
%            dSUVScale = tQuant.tSUV.dScale;
%        else
%            dSUVScale = 0;
%        end
        
%        dMean = mean(dicomBuffer('get'), 'all') * dSUVScale;
%        dSTD = std(dicomBuffer('get'), [],'all') * dSUVScale;
        
%        dSUVmin = (4.30/dMean)*(dMean + dSTD);
        
    end

    function editSmalestIsoMaskValue(hObject, ~)

        dSmalestValue =  abs(str2double(get(hObject, 'String')));

        if dSmalestValue < 0
            dSmalestValue = 0;
        end

        smalestIsoMask('set', dSmalestValue);

        set(hObject, 'String', num2str(dSmalestValue));

    end

    function createIsoMaskCallback(~, ~)
        
        isoObj = isoObject('get');
        if ~isempty(isoObj)

            try

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;
            
            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            set(uiSeriesPtr('get'), 'Enable', 'off');
            set(btnIsoSurfacePtr('get'), 'Enable', 'off');
            set(btn3DPtr('get'), 'Enable', 'off');
            set(btnMIPPtr('get'), 'Enable', 'off');

            progressBar(0.2, 'Creating mask, please wait');

            aSurfaceColor = surfaceColor('all');
            dColorOffset  = isoColorOffset('get');
            
            atInput = inputTemplate('get');

            im = dicomBuffer('get', [], dSeriesOffset);
            atMetaData = dicomMetaData('get');
            aInputBuffer = inputBuffer('get');
                    
            asFormula = get(uiValueFormulaIsoMask, 'String');
            dFormula  = get(uiValueFormulaIsoMask, 'Value');
            
            dLiverMean = 0;
            dLiverSTD  = 0;   
                
            if strcmpi(asFormula{dFormula}, '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map') 
                                        
                atRoiInput = roiTemplate('get', dSeriesOffset);
               
                if ~isempty(atRoiInput)
                    
                    aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Liver'} );            
                    dTagOffset = find(aTagOffset, 1);
                    
                    aSlice = [];
                    
                    if ~isempty(dTagOffset)
                        
                        switch lower(atRoiInput{dTagOffset}.Axe)

                            case 'axes1'                            
                                aSlice = permute(im(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                            case 'axes2'
                                aSlice = permute(im(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                            case 'axes3'
                                aSlice = im(:,:,atRoiInput{dTagOffset}.SliceNb);       
                        end
                        
                        aLogicalMask = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);
                        
                        tQuant = quantificationTemplate('get');

                        if isfield(tQuant, 'tSUV')
                            dSUVScale = tQuant.tSUV.dScale;
                        else
                            dSUVScale = 0;
                        end     
                        
                        dLiverMean = mean(aSlice(aLogicalMask), 'all') * dSUVScale;
                        dLiverSTD  = std(aSlice(aLogicalMask), [],'all') * dSUVScale;     
                        
                        clear aSlice;
                    else
                        msgbox('Error: createIsoMaskCallback(): Please define a Liver!', 'Error');   
                        return;
                    end                
                end
            end            
            
            
            % Resample to CT
            
            if resampledContoursIsoMask('get') == true

                tResampleToCT = resampleToCTIsoMaskUiValues('get');
                if resampleToCTIsoMask('get') == true && ...
                   ~isempty(tResampleToCT)

                    dCTOffset = isoMaskCtSerieOffset('get');
                    dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;

                    refImage = aInputBuffer{dCTSeriesNumber};
                    atRefMetaData = atInput(dCTSeriesNumber).atDicomInfo;           
                    
                    if numel(im) ~= numel(refImage)
                        
                        progressBar(0.3, sprintf('Resampling series, please wait'));
                        
                        if size(im, 3) ~= size(refImage, 3)
                            [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear', false, true);   
                        else
                            [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear', true, true);   
                        end

                        progressBar(0.6, sprintf('Resampling ROIs, please wait'));

                        atRoi = roiTemplate('get', dSeriesOffset);

                        atResampledRoi = resampleROIs(im, atMetaData, aResampledBuffer, atResampledMetaData, atRoi, true);

                        roiTemplate('set', dSeriesOffset, atResampledRoi);  

                        progressBar(0.99999, sprintf('Resampling MIP, please wait'));

                        dicomMetaData('set', atResampledMetaData);
                        dicomBuffer('set', aResampledBuffer);
                        
                        refMip = mipBuffer('get', [], dCTSeriesNumber);                        
                          aMip = mipBuffer('get', [], dSeriesOffset);
                      
                        if size(im, 3) ~= size(refImage, 3)
                            aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear', false);
                        else
                            aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear', true);
                        end
                        
                        mipBuffer('set', aResampledMip, dSeriesOffset);

                        setQuantification(dSeriesOffset);                               
                    end
                end
            end
            
            im = dicomBuffer('get');        
            atDcmMetaData = dicomMetaData('get');
            
            dMin = min(im, [], 'all');
            dMax = max(im, [], 'all');
            dScale = abs(dMin)+abs(dMax);
            dOffset = dScale*isoObj.Isovalue;
            dIsoValue = dMin+dOffset;

            % Get constraint 
            
            progressBar(0.3, sprintf('Applying constraint, please wait'));

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            atRoiInput = roiTemplate('get', dSeriesOffset);

            aLogicalMask = roiConstraintToMask(im, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

%            dImageMin = min(double(im),[], 'all');

%            im(aLogicalMask==0) = dImageMin; % Apply constraint            
            
            % Get ISO value
            
            progressBar(0.6, sprintf('Computing mask, please wait'));

            fv = isosurface(im, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"

            aVolume = polygon2voxel(fv, size(im), 'none');
            
            BW = imfill(aVolume, 4, 'holes');            

%            dScale = dMax*isoObj.Isovalue;
            
%            BW = im;
%            BW(BW<dScale) = dMin;            
%            BW(BW~=dMin) = 1;
%            BW(BW==dMin) = 0;
%            BW = imfill(BW, 4, 'holes');            
            
        
            BW(aLogicalMask==0) = 0;
            
       %     BW = volumeFill(aVolume);
                 
            BWLIVER = [];
            imMaskLiver = [];
 
            if strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map') || ...
               strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')
                               
                if ~isempty(atRoiInput)
                    
                    aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Liver'} );            
                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)

                        switch lower(atRoiInput{dTagOffset}.Axe)

                            case 'axes1'                            
                                aSlice = permute(im(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                            case 'axes2'
                                aSlice = permute(im(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                            case 'axes3'
                                aSlice = im(:,:,atRoiInput{dTagOffset}.SliceNb);       
                        end


    %                    fv = isosurface(im, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"
    %                    aVolume = polygon2voxel(fv, size(im), 'none');

                        aVolume = im;

                        aLogicalMask2 = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);

                        switch lower(atRoiInput{dTagOffset}.Axe)

                            case 'axes1'   

                                for kk=1:size(im, 1)

                                    aSlice = permute(aVolume(kk,:,:), [3 2 1]); % 10% of treshold Liver 
                                    aSlice(aLogicalMask2==0)=0;
                                    aVolume(kk,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);  

                                    aSlice = permute(BW(kk,:,:), [3 2 1]);  % Outside Liver 
                                    aSlice(aLogicalMask2==1)=0;
                                    BW(kk,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);                                                                                            
                                end

                            case 'axes2'

                                for kk=1:size(aVolume, 2)
                                    aSlice = permute(aVolume(:,kk,:), [3 1 2]); % 10% of treshold Liver 
                                    aSlice(aLogicalMask2==0)=0;
                                    aVolume(:,kk,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);  

                                    aSlice = permute(BW(:,kk,:), [3 1 2]);  % Outside Liver 
                                    aSlice(aLogicalMask2==1)=0;
                                    BW(:,kk,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]); 
                                end

                            case 'axes3'

                                for kk=1:size(aVolume, 3)
                                    aSlice = aVolume(:,:,kk); % 10% of treshold Liver 
                                    aSlice(aLogicalMask2==0)=0;
                                    aVolume(:,:,kk) = aSlice;  

                                    aSlice = BW(:,:,kk);  % Outside Liver 
                                    aSlice(aLogicalMask2==1)=0;
                                    BW(:,:,kk) = aSlice;                                 
                                end
                        end                    

                        dMin = min(aVolume, [], 'all');
                        dMax = max(aVolume, [], 'all');
                        dScale = abs(dMin)+abs(dMax);

                        dOffset = dScale*.20;
                        dIsoValue = dMin+dOffset;

                        fv = isosurface(aVolume, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"
                        aVolume = polygon2voxel(fv, size(im), 'none');
                        aVolume = imfill(aVolume, 4, 'holes');
                        aVolume(aLogicalMask==0) = 0;

%                        BW = BW|aVolume;
                        BWLIVER = aVolume;
                        imMaskLiver = im;
                        imMaskLiver(BWLIVER == 0) = dMin;
                    else
                        msgbox('Error: createIsoMaskCallback(): Please define a Liver!', 'Error');                          
                    end                
                end
             end
            
            imMask = im;
            imMask(BW == 0) = dMin;
            
            if get(chkAddVoiIsoMask, 'Value') == false % test
                                   
                atInput = inputTemplate('get');

                atInput(numel(atInput)+1) = atInput(dSeriesOffset);

                atInput(numel(atInput)).bEdgeDetection = false;
                atInput(numel(atInput)).bDoseKernel    = false;    
                atInput(numel(atInput)).bFlipLeftRight = false;
                atInput(numel(atInput)).bFlipAntPost   = false;
                atInput(numel(atInput)).bFlipHeadFeet  = false;
                atInput(numel(atInput)).bMathApplied   = false;
                atInput(numel(atInput)).bFusedDoseKernel    = false;
                atInput(numel(atInput)).bFusedEdgeDetection = false;
                atInput(numel(atInput)).tMovement = [];
                atInput(numel(atInput)).tMovement.bMovementApplied = false;
                atInput(numel(atInput)).tMovement.aGeomtform = [];                
                atInput(numel(atInput)).tMovement.atSeq{1}.sAxe = [];
                atInput(numel(atInput)).tMovement.atSeq{1}.aTranslation = [];
                atInput(numel(atInput)).tMovement.atSeq{1}.dRotation = [];            

                atInput(numel(atInput)).atDicomInfo = atDcmMetaData;

                asSeriesDescription = seriesDescription('get');
                asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('MASK %s', asSeriesDescription{dSeriesOffset});
                seriesDescription('set', asSeriesDescription);

                dSeriesInstanceUID = dicomuid;

                for hh=1:numel(atInput(numel(atInput)).atDicomInfo)
                    atInput(numel(atInput)).atDicomInfo{hh}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
                    atInput(numel(atInput)).atDicomInfo{hh}.SeriesInstanceUID = dSeriesInstanceUID;
                end

                atInput(numel(atInput)).aDicomBuffer = imMask;

                inputTemplate('set', atInput);

                aInputBuffer = inputBuffer('get');
                aInputBuffer{numel(aInputBuffer)+1} = imMask;
                inputBuffer('set', aInputBuffer);

                asSeries = get(uiSeriesPtr('get'), 'String');
                asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};
                set(uiSeriesPtr('get'), 'String', asSeries);
                set(uiFusedSeriesPtr('get'), 'String', asSeries);

                set(uiSeriesPtr('get'), 'Value', numel(atInput));
                dicomMetaData('set', atInput(numel(atInput)).atDicomInfo);
                dicomBuffer('set', imMask);
                setQuantification(numel(atInput));

                tQuant = quantificationTemplate('get');
                atInput(numel(atInput)).tQuant = tQuant;

                aMaskedMip = computeMIP(imMask);
                mipBuffer('set', aMaskedMip, numel(atInput));
                atInput(numel(atInput)).aMip = aMaskedMip;

                inputTemplate('set', atInput);
            end
            
            set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

            progressBar(1, sprintf('Mask completed'));

            set(uiSeriesPtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
            set(btn3DPtr('get'), 'Enable', 'on');
            set(btnMIPPtr('get'), 'Enable', 'on');            

            BWCT = [];            
                
            if get(chkAddVoiIsoMask, 'Value') == true
                              
                % Set Pixel Edge
                if get(chkPixelEdgeIsoMask, 'Value') == true
                    bPixelEdge = true;
                else
                    bPixelEdge = false;
                end

                % Set Percent to Max
                
                if get(chkPercentOfPeakIsoMask, 'Value') == true
                    
                    sMinSUVformula = [];                        
                    
                    bUseFormula = false;

                    bPercentOfPeak = true;
                    
                    dPercentMaxOrMaxSUVValue = abs(str2double(get(uiEditAddVoiIsoMask, 'String')));

                    if dPercentMaxOrMaxSUVValue < 0
                        dPercentMaxOrMaxSUVValue = 0;
                    end

                    if dPercentMaxOrMaxSUVValue > 100
                        dPercentMaxOrMaxSUVValue = 100;
                    end

                    voiIsoMaskMax('set', dPercentMaxOrMaxSUVValue);
                    
                    set(uiEditAddVoiIsoMask, 'String', num2str(dPercentMaxOrMaxSUVValue));                    
                else
                    bPercentOfPeak = false;                 
                        
                    asFormula = get(uiValueFormulaIsoMask, 'String');
                    dFormula  = get(uiValueFormulaIsoMask, 'Value');
                        
                    if strcmpi(asFormula{dFormula}, 'Fixed')
                        
                        sMinSUVformula = [];                        
                        
                        bUseFormula = false;
                        
                        dPercentMaxOrMaxSUVValue = abs(str2double(get(uiEditAddVoiIsoMask, 'String')));

                        if dPercentMaxOrMaxSUVValue < 0
                            dPercentMaxOrMaxSUVValue = 0;
                        end   
                    
                        peakSUVMaxIsoMask('set', dPercentMaxOrMaxSUVValue);
                        
                        set(uiEditAddVoiIsoMask, 'String', num2str(dPercentMaxOrMaxSUVValue));
                        
                    elseif strcmpi(asFormula{dFormula}, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map') || ...
                           strcmpi(asFormula{dFormula}, '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map') || ...
                           strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map')
                        
                        bUseFormula = true;   
                        
                        dPercentMaxOrMaxSUVValue = 0;
                        sMinSUVformula = asFormula{dFormula};                        
                        valueFormulaIsoMask('set', dFormula);
                        
                        tResampleToCT = resampleToCTIsoMaskUiValues('get');
                      
                        dCTOffset = isoMaskCtSerieOffset('get');
                        dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;
                        
                        BWCT = dicomBuffer('get', [], dCTSeriesNumber); 
                                                
                        if isempty(BWCT)        
                            
                            BWCT = aInputBuffer{dCTSeriesNumber};
                                                        
                            if     strcmpi(imageOrientation('get'), 'axial')
                            %    BWCT = BWCT;
                            elseif strcmpi(imageOrientation('get'), 'coronal')
                                BWCT = reorientBuffer(BWCT, 'coronal');
                            elseif strcmpi(imageOrientation('get'), 'sagittal')
                                BWCT = reorientBuffer(BWCT, 'sagittal');
                            end

                            if atInput(dCTSeriesNumber).bFlipLeftRight == true
                                BWCT=BWCT(:,end:-1:1,:);
                            end

                            if atInput(dCTSeriesNumber).bFlipAntPost == true
                                BWCT=BWCT(end:-1:1,:,:);
                            end

                            if atInput(dCTSeriesNumber).bFlipHeadFeet == true
                                BWCT=BWCT(:,:,end:-1:1);
                            end   
                        end
                                        
                        atFuseMetaData = dicomMetaData('get', [], dCTSeriesNumber);
                        if isempty(atFuseMetaData)
                            atFuseMetaData = atInput(dCTSeriesNumber).atDicomInfo;
                        end
                        
                        if resampleToCTIsoMask('get') == false || ... % Need to fit the CT to the PT or NM
                           (resampleToCTIsoMask('get') == true && resampledContoursIsoMask('get') == false)
                       
                            if numel(BWCT) ~= numel(im) 
                               progressBar(0.6, sprintf('Resampling ct, please wait'));
                               
                                [BWCT, ~] = resampleImage(BWCT, atFuseMetaData, im, atMetaData, 'Nearest', true, false);   
                                
                            end
                        end
                                                 
                        progressBar(0.6, sprintf('Computing ct bone map, please wait'));                        
                
                        BWCT(BWCT < 100) = 0;                                    
                        BWCT = imfill(BWCT, 4, 'holes');                       
                
                        BWCT(BWCT~=0) = 1;
                        BWCT(BWCT~=1) = 0;
                            
                    elseif strcmpi(asFormula{dFormula}, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT ISO Map') || ...
                           strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')

                        
                        bUseFormula = true;       
                        
                        dPercentMaxOrMaxSUVValue = 0;
                        sMinSUVformula = asFormula{dFormula};                        
                        valueFormulaIsoMask('set', dFormula);
                        
                        dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

                        BWCT = fusionBuffer('get', [], dFusedSeriesOffset); 
                                                                                    
                        if resampleToCTIsoMask('get') == true && resampledContoursIsoMask('get') == true
                       
                            if numel(BWCT) ~= numel(im) 
                                
                               BWCT = dicomBuffer('get', [], dFusedSeriesOffset); 
                                                                
                                if isempty(BWCT)    
                                    BWCT = aInputBuffer{dFusedSeriesOffset};

                                    if     strcmpi(imageOrientation('get'), 'axial')
                                    %    BWCT = BWCT;
                                    elseif strcmpi(imageOrientation('get'), 'coronal')
                                        BWCT = reorientBuffer(BWCT, 'coronal');
                                    elseif strcmpi(imageOrientation('get'), 'sagittal')
                                        BWCT = reorientBuffer(BWCT, 'sagittal');
                                    end

                                    if atInput(dFusedSeriesOffset).bFlipLeftRight == true
                                        BWCT=BWCT(:,end:-1:1,:);
                                    end

                                    if atInput(dFusedSeriesOffset).bFlipAntPost == true
                                        BWCT=BWCT(end:-1:1,:,:);
                                    end

                                    if atInput(dFusedSeriesOffset).bFlipHeadFeet == true
                                        BWCT=BWCT(:,:,end:-1:1);
                                    end  
                                end
                            end
                        end

                        isoFusionObj = isoFusionObject('get');
                        if ~isempty(isoFusionObj)
                                                        
                            aSurfaceColor = surfaceColor('all');
                            dColorFusionOffset  = isoColorFusionOffset('get');
            
                            dCTmin = min(BWCT, [], 'all');
                            dCTmax = max(BWCT, [], 'all');
                            dScale = abs(dCTmin)+abs(dCTmax);
                            dOffset = dScale*isoFusionObj.Isovalue;
                            dIsoValue = dCTmin+dOffset;  
                            
                            progressBar(0.6, sprintf('Computing ct iso map, please wait'));

                            fv = isosurface(BWCT, dIsoValue, aSurfaceColor{dColorFusionOffset}); % Make patch w. faces "out"

                            BWCT = imfill(polygon2voxel(fv, size(BWCT), 'none'), 4, 'holes');
                                                     
                            BWCT(BWCT~=0) = 1;
                            BWCT(BWCT~=1) = 0;
                       %     BW = volumeFill(aVolume);

%                            imCT(BWCT =~ 0) = dCTmin;                                                                                    
                        end                        
                    else            
                        bUseFormula = true;                  
                        
                        dPercentMaxOrMaxSUVValue = 0;
                        sMinSUVformula = asFormula{dFormula};                        
                        valueFormulaIsoMask('set', dFormula);
                    end                     
                end

                % Set Multiple Peaks

                if get(chkMultiplePeaksIsoMask, 'Value') == true

                    bMultiplePeaks = true;

                    dMultiplePeaksPercentValue =  abs(str2double(get(uiEditPeakPercentIsoMask, 'String')));

                    if dMultiplePeaksPercentValue < 0
                        dMultiplePeaksPercentValue = 0;
                    end

                    if dMultiplePeaksPercentValue > 100
                        dMultiplePeaksPercentValue = 100;
                    end

                    set(uiEditPeakPercentIsoMask, 'String',  num2str(dMultiplePeaksPercentValue));

                    peakPercentIsoMask('set', dMultiplePeaksPercentValue);

                else
                    bMultiplePeaks = false;
                    dMultiplePeaksPercentValue = [];
                end

                multiplePeaksIsoMask('set', bMultiplePeaks);

                % Smalest voi

                dSmalestVoiValue =  abs(str2double(get(uiEditSmalestIsoMask, 'String')));

                if dSmalestVoiValue < 0
                    dSmalestVoiValue = 0;
                end

                smalestIsoMask('set', dSmalestVoiValue);

                set(uiEditSmalestIsoMask, 'String', num2str(dSmalestVoiValue));

                % Deactivate Volume

                if switchTo3DMode('get') == true
                    set3DCallback();
                end

                % Deactivate MIP

                if switchToMIPMode('get') == true
                    setMIPCallback();
                end

                 % Deactivate ISO

                if switchToIsoSurface('get') == true
                    setIsoSurfaceCallback();
                end
                
                % Deactivate main tool bar 
                set(uiSeriesPtr('get'), 'Enable', 'off');                        
                mainToolBarEnable('off');
        
                % Create VOIs

                
                if strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map') || ...
                   strcmpi(asFormula{dFormula}, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')
               
                   maskAddVoiToSeries(imMask, BW, bPixelEdge, true, 42, true, 65, false, sMinSUVformula, BWCT, dSmalestVoiValue);                    
                   maskAddVoiToSeries(imMaskLiver, BWLIVER, bPixelEdge, true, 42, false, dMultiplePeaksPercentValue, false, sMinSUVformula, BWCT, dSmalestVoiValue);
                else
                    maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestVoiValue, dLiverMean, dLiverSTD);                    
                end
            
                % Resample to CT

                if resampledContoursIsoMask('get') == false

                    tResampleToCT = resampleToCTIsoMaskUiValues('get');
                    if resampleToCTIsoMask('get') == true && ...
                       ~isempty(tResampleToCT)


                        dCTOffset = isoMaskCtSerieOffset('get');
                        dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;
                        
                        im = dicomBuffer('get');        

                        refImage = aInputBuffer{dCTSeriesNumber};
                        atRefMetaData = atInput(dCTSeriesNumber).atDicomInfo;           

                        if numel(im) ~= numel(refImage)
                            
                            progressBar(0.3, sprintf('Resampling series, please wait'));
                            
                            if size(im, 3) ~= size(refImage, 3)
                                [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear', false, true);   
                            else
                                [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear', true, true);   
                            end

                            progressBar(0.6, sprintf('Resampling ROIs, please wait'));

                            atRoi = roiTemplate('get', dSeriesOffset);

                            atResampledRoi = resampleROIs(im, atMetaData, aResampledBuffer, atResampledMetaData, atRoi, true);

                            roiTemplate('set', dSeriesOffset, atResampledRoi);  

                            progressBar(0.99999, sprintf('Resampling MIP, please wait'));

                            dicomMetaData('set', atResampledMetaData);
                            dicomBuffer('set', aResampledBuffer);

                            refMip = mipBuffer('get', [], dCTSeriesNumber);
                            aMip = mipBuffer('get', [], dSeriesOffset);
                            
                            if size(im, 3) ~= size(refImage, 3)
                                aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear', false);
                            else
                                aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear', true);
                            end

                            mipBuffer('set', aResampledMip, dSeriesOffset);

                            setQuantification(dSeriesOffset);     
                                                        
                        end
                    end
                end
            
%                setSeriesCallback();                               
                
                if resampleToCTIsoMask('get') == true && ...
                   ~isempty(tResampleToCT) 
                
                    % Deactivate MIP Fusion

                    link2DMip('set', false);

                    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 
                    set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
                   
                    % Set fusion

                    if isFusion('get') == false

                        set(uiFusedSeriesPtr('get'), 'Value', dCTSeriesNumber);

                        setFusionCallback();
                    end
                    
                    progressBar(1, sprintf('Ready'));

                end

                % Triangulate og 1st VOI

                atVoiInput = voiTemplate('get', dSeriesOffset);

                if ~isempty(atVoiInput)

                    dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

                    triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
                end

                % Activate ROI Panel

                if viewRoiPanel('get') == false
                    setViewRoiPanel();
                end
                
            else

            end
                       
            catch
                progressBar(1, 'Error: createIsoMaskCallback()');
            end
            
            clear BW;            
            clear BWCT;       
            clear imMask;
            clear aVolume;
            clear BWLIVER;
            clear imMaskLiver;
                 
           % Reactivate main tool bar 
            set(uiSeriesPtr('get'), 'Enable', 'on');                        
            mainToolBarEnable('on');     
                
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;

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

        function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, bUseFormula, sMinSUVformula, BWCT, dSmalestValue, dLiverMean, dLiverSTD)

            try

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;

            uiSeries = uiSeriesPtr('get');
            dSeriesOffset = get(uiSeries, 'Value');
            
            atMetaData = dicomMetaData('get');
                  
            dPixelSizeX = atMetaData{1}.PixelSpacing(1);
            if dPixelSizeX == 0 
                dPixelSizeX = 1;
            end
            
            dPixelSizeY = atMetaData{1}.PixelSpacing(2);
            if dPixelSizeY == 0 
                dPixelSizeY = 1;
            end                    
            
            dPixelSizeZ = computeSliceSpacing(atMetaData);
            if dPixelSizeZ == 0  
                dPixelSizeZ = 1;
            end            

            dVoxelSize = dPixelSizeX * dPixelSizeY * dPixelSizeZ;
            
            dSmalestValueNbVoxels = round(dSmalestValue/(dVoxelSize/1000)); % In ml
            
%            SMALEST_ROI_SIZE = 0;
            PIXEL_EDGE_RATIO = 3;

            dMinValue = min(imMask, [], 'all');
%            dMaxValue = max(imMask, [], 'all');

            CC = bwconncomp(gather(BW), 6);
            dNbElements = numel(CC.PixelIdxList);

%            asAllTag = [];
             
            if canUseGPU()
                BW2       = gpuArray(zeros(size(imMask))); % Init BW2 buffer                                       
                BWCT2     = gpuArray(BWCT);
                BWANDBWCT = gpuArray(zeros(size(BWCT)));
            else
                BW2       = zeros(size(imMask)); % Init BW2 buffer                                       
                BWCT2     = BWCT;
                BWANDBWCT = zeros(size(BWCT));                
            end
            
            for bb=1:dNbElements  % Nb VOI

                progressBar( bb/dNbElements-0.0001, sprintf('Computing contour %d/%d, please wait', bb, dNbElements) );

%                if numel(CC.PixelIdxList{bb}) 

                BW2(BW2~=0) = 0; % Reset BW2 buffer

                BW2(CC.PixelIdxList{bb}) = imMask(CC.PixelIdxList{bb});

                if bPercentOfPeak == true % Percent of peak or SUV Value
                    
                    if  strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map') || ...
                        strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT ISO Map')  || ...
                        strcmpi(sMinSUVformula, '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map') || ...
                        strcmpi(sMinSUVformula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map')     || ...
                        strcmpi(sMinSUVformula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')
                        
                        BWANDBWCT = BW2&BWCT2;

                        dBWnbPixel        = numel(BW2(BW2~=0));
                        dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                        if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                            sLesionType = 'Bone';
                        else
                            sLesionType = 'Soft Tissue';
                        end
                        
                    else
                        sLesionType = 'Unspecified';
                    end
                        
                    if bMultiplePeaks == true % Multiple peaks

                        dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * (dPercentMaxOrMaxSUVValue) /100;
                        dMaxMaskValue = dMaxMaskValue * (dMultiplePeaksPercentValue) /100;

                        BW2(BW2 <= dMaxMaskValue) = dMinValue;

                        BW2(BW2 ~= dMinValue) = 1;
                        BW2(BW2 == dMinValue) = 0;

                    else % Single peak

                        dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * dPercentMaxOrMaxSUVValue /100;

                        BW2(BW2 <= dMaxMaskValue) = dMinValue;

                        BW2(BW2 ~= dMinValue) = 1;
                        BW2(BW2 == dMinValue) = 0;
                    end
                else
                    tQuant = quantificationTemplate('get');
                    
                    if isfield(tQuant, 'tSUV')
                        dSUVScale = tQuant.tSUV.dScale;
                    else
                        dSUVScale = 0;
                    end

                    if bUseFormula == false

                        if strcmpi(sMinSUVformula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT Bone Map') || ...
                           strcmpi(sMinSUVformula, 'Liver 42%, Soft Tissue & Bone 42% peaks at 65%, CT ISO Map')   
                            sLesionType = 'Liver';
                        else
                            sLesionType = 'Unspecified';
                        end
                            
                        BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                        BW2(BW2 ~= dMinValue) = 1;
                        BW2(BW2 == dMinValue) = 0;
                    else
                        if strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD)')      

                            sLesionType = 'Unspecified';

                            dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                            dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                            dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                            BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0;                                

                        elseif strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT Bone Map') 

                            BWANDBWCT = BW2&BWCT2;

                            dBWnbPixel        = numel(BW2(BW2~=0));
                            dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                            if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                                sLesionType = 'Bone';

                                dPercentMaxOrMaxSUVValue = 3;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            else
                                sLesionType = 'Soft Tissue';

                                dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                                dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                                dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            end

                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0;    

%                                clear(BWANDBWCT);
                        elseif strcmpi(sMinSUVformula, '(4.30/Liver SUVmean)x(Liver SUVmean + Liver SD), Soft Tissue & SUV 3, CT Bone Map')
                            
                            BWANDBWCT = BW2&BWCT2;

                            dBWnbPixel        = numel(BW2(BW2~=0));
                            dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                            if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                                sLesionType = 'Bone';

                                dPercentMaxOrMaxSUVValue = 3;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            else
                                sLesionType = 'Soft Tissue';

%                                dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
%                                dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;

                                dPercentMaxOrMaxSUVValue = (4.30/dLiverMean)*(dLiverMean + dLiverSTD);                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            end

                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0;                                
                            
                        elseif strcmpi(sMinSUVformula, '(4.30/SUVmean)x(SUVmean + SD), Soft Tissue & SUV 3, CT ISO Map') 

                            BWANDBWCT = BW2&BWCT2;

                            dBWnbPixel        = numel(BW2(BW2~=0));
                            dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                            if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                                sLesionType = 'Bone';

                                dPercentMaxOrMaxSUVValue = 3;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            else
                                sLesionType = 'Soft Tissue';

                                dMean = mean(BW2(BW2~=dMinValue), 'all') * dSUVScale;
                                dSTD = std(BW2(BW2~=dMinValue), [],'all') * dSUVScale;
                                
                                dPercentMaxOrMaxSUVValue = (4.30/dMean)*(dMean + dSTD);                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            end

                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0;     
                            
                        elseif strcmpi(sMinSUVformula, 'Liver SUV 10, Soft Tissue SUV 4, Bone SUV 3, CT Bone Map')
                            
                            BWANDBWCT = BW2&BWCT2;

                            dBWnbPixel        = numel(BW2(BW2~=0));
                            dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                            if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                                sLesionType = 'Bone';

                                dPercentMaxOrMaxSUVValue = 3;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            else
                                sLesionType = 'Soft Tissue';

                                dPercentMaxOrMaxSUVValue = 4;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            end

                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0; 
                            
                        elseif strcmpi(sMinSUVformula, 'Liver SUV 10, Soft Tissue SUV 4, Bone SUV 3, CT ISO Map')
                            
                            BWANDBWCT = BW2&BWCT2;

                            dBWnbPixel        = numel(BW2(BW2~=0));
                            dBWandBWCTnbPixel = numel(BWANDBWCT(BWANDBWCT~=0));

                            if (dBWandBWCTnbPixel/dBWnbPixel*100) > 10 % At least 10% of the legion is bone
                                sLesionType = 'Bone';

                                dPercentMaxOrMaxSUVValue = 3;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            else
                                sLesionType = 'Soft Tissue';

                                dPercentMaxOrMaxSUVValue = 4;                                
                                BW2(BW2*dSUVScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                            end

                            BW2(BW2 ~= dMinValue) = 1;
                            BW2(BW2 == dMinValue) = 0; 
%                                clear(BWANDBWCT);

                        else
                            return;
                        end
                    end
                end

                asTag = []; % Reset ROIs tag

                xmin=0.5;
                xmax=1;
                aColor=xmin+rand(1,3)*(xmax-xmin);

%                    dNbSlices = size(BW2, 3);

                aPixelsList = gather(find(BW2));
                if numel(aPixelsList) < dSmalestValueNbVoxels
                    continue;
                end

                [~,~,adSlices]=ind2sub(size(BW2), aPixelsList);
                adSlices = unique(adSlices);                
                
                dNbComputedSlices = numel(adSlices);

                for aa=1:dNbComputedSlices % Find ROI

                    dCurrentSlice = adSlices(aa);

                    aAxial = gather(BW2(:,:,dCurrentSlice));

                    if bPixelEdge == true
                        aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                    end
                    
                    maskAxial = bwboundaries(aAxial, 'noholes', 8);                    
                     
                    dSlicesNbElements = numel(maskAxial);
                    for jj=1:dSlicesNbElements

                        if bPixelEdge == true
                            maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;
                            maskAxial{jj} = reducepoly(maskAxial{jj});
                        end   

                        curentMask = maskAxial(jj);

%                                    sliceNumber('set', 'axial', aa);

                        sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                        aPosition = flip(curentMask{1}, 2);
%                                    aPosition(:,1) = aPosition(:,1) - 0.5;
%                                    aPosition(:,2) = aPosition(:,2) + 0.5;

%                                    bAddRoi = true;
                        sliceNumber('set', 'axial', dCurrentSlice);
                        
                        roiPtr = images.roi.Freehand(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'Smoothing', 1, 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', roiFaceAlphaValue('get'), 'Visible', 'off');
                        roiPtr.Waypoints(:) = false;                    
     
                        addRoi(roiPtr, get(uiSeriesPtr('get'), 'Value'), sLesionType);

                        roiDefaultMenu(roiPtr);

                        uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                        uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);

                        constraintMenu(roiPtr);

                        cropMenu(roiPtr);

                        voiMenu(roiPtr);

                        uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
                                           
%                        addContourToTemplate(dSeriesOffset, 'Axes3', dCurrentSlice, 'images.roi.freehand', aPosition, '', 'off', aColor, 1, roiFaceAlphaValue('get'), 0, 1, sTag, sLesionType);

                        asTag{numel(asTag)+1} = sTag;
                    end              
                end
                
                if ~isempty(asTag)

                    sLabel = sprintf('RMAX-%d-VOI%d', dPercentMaxOrMaxSUVValue, bb);

                    createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
                end           
            end
    
            setVoiRoiSegPopup();

            progressBar(1, 'Ready');

            catch
                progressBar(1, 'Error:maskAddVoiToSeries()');
            end
            
            clear BW2;
            clear BWCT2; 
            clear BWANDBWCT; 
            
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
        end

    end

    function isoSurfaceColorCallback(hObject, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
        
       asColor = surfaceColor('get', get(hObject, 'Value'), true);

        if get(ui3DVolume, 'Value') == 2 % Fusion

            isoColorFusionOffset('set', get(hObject, 'Value'));

            if switchToIsoSurface('get') == true && isFusion('get') == true
                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    if numel(asColor) ~= 1
                        set(isoFusionObj, 'IsosurfaceColor', asColor);
                    end
                end
            end
        else

           isoColorOffset('set', get(hObject, 'Value'));

           if switchToIsoSurface('get') == true
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    if numel(asColor) ~= 1
                        set(isoObj, 'IsosurfaceColor', asColor);
                    end
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

        if strcmpi(uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value}, 'Linear')

%%%            deleteAlphaCurve('vol');

            set(uiSliderVolLinAlpha, 'Enable', 'on');

            aAlphamap = linspace(0, get(uiSliderVolLinAlpha, 'Value'), 256)';

            if get(ui3DVolume, 'Value') == 2 % Fusion

                getVolFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Linear', aAlphamap);
                volLinearFusionAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));

                if switchTo3DMode('get') == true && isFusion('get') == true
                    if ~isempty(volFusionObj)
                        set(volFusionObj, 'Alphamap', aAlphamap);
                    end
                end

            else

                getVolAlphaMap('set', dicomBuffer('get'), 'Linear', aAlphamap);
                volLinearAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));

                if switchTo3DMode('get') == true
                    if ~isempty(volObj)
                        set(volObj, 'Alphamap', aAlphamap);
                    end
                end

            end

            displayAlphaCurve(aAlphamap, axeVolAlphmap);

         elseif strcmpi(uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value}, 'Custom')

            set(uiSliderVolLinAlpha, 'Enable', 'off');

            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion

                getVolFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Custom');

                if switchTo3DMode('get') == true && isFusion('get') == true

                    ic = customAlphaCurve(axeVolAlphmap,  volFusionObj, 'volfusion');
                    ic.surfObj = volFusionObj;

                    volICFusionObject('set', ic);

                    alphaCurveMenu(axeVolAlphmap, 'volfusion');
                else
                    tFuseInput  = inputTemplate('get');
                    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                    [aFusionAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                    displayAlphaCurve(aFusionAlphaMap, axeVolAlphmap);
                end

            else
                getVolAlphaMap('set', dicomBuffer('get'), 'Custom');

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
                    aAlphamap = defaultVolFusionAlphaMap(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});

                    getVolFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), uiVolumeAlphaMapType.String{uiVolumeAlphaMapType.Value});
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
            getVolFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Linear', aAlphamap);
        else
            if switchTo3DMode('get') == true
                volObj = volObject('get');
                if ~isempty(volObj)
                    set(volObj, 'Alphamap', aAlphamap);
                end
            end
            volLinearAlphaValue('set',  get(uiSliderVolLinAlpha, 'Value'));
            getVolAlphaMap('set', dicomBuffer('get'), 'Linear', aAlphamap);
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

        if strcmpi(uiMipAlphaMapType.String{uiMipAlphaMapType.Value}, 'Linear')

%%%            deleteAlphaCurve('mip');

            set(uiSliderMipLinAlpha, 'Enable', 'on');

            aAlphamap = linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)';

            mipLinearAlphaValue('set',  get(uiSliderMipLinAlpha, 'Value'));
%            getMipAlphaMap('set', dicomBuffer('get'), 'Linear', aAlphamap);

            displayAlphaCurve(aAlphamap, axeMipAlphmap);

            if get(ui3DVolume, 'Value') == 2 % Fusion
                getMipFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Linear', aAlphamap);
                if switchToMIPMode('get') == true && isFusion('get') == true
                    if ~isempty(mipFusionObj)
                        set(mipFusionObj, 'Alphamap', aAlphamap);
                    end
                end
            else
                getMipAlphaMap('set', dicomBuffer('get'), 'Linear', aAlphamap);

                if switchToMIPMode('get') == true
                    if ~isempty(mipObj)
                        set(mipObj, 'Alphamap', aAlphamap);
                    end
                end
            end

         elseif strcmpi(uiMipAlphaMapType.String{uiMipAlphaMapType.Value}, 'Custom')

            set(uiSliderMipLinAlpha, 'Enable', 'off');

            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion

                getMipFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Custom');

                if switchToMIPMode('get') == true && isFusion('get') == true

                    ic = customAlphaCurve(axeMipAlphmap,  mipFusionObj, 'mipfusion');
                    ic.surfObj = mipFusionObj;

                    mipICFusionObject('set', ic);

                    alphaCurveMenu(axeMipAlphmap, 'mipfusion');
                else
                    tFuseInput  = inputTemplate('get');
                    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                    [aFusionAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                    displayAlphaCurve(aFusionAlphaMap, axeMipAlphmap);
                end

            else
                getMipAlphaMap('set', dicomBuffer('get'), 'Custom');
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
                    aAlphamap = defaultMipFusionAlphaMap(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});

                    getMipFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), uiMipAlphaMapType.String{uiMipAlphaMapType.Value});
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
            getMipFusionAlphaMap('set', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Linear', aAlphamap);
        else
            if switchToMIPMode('get')    == true
                mipObj = mipObject('get');
                if ~isempty(mipObj)
                    set(mipObj, 'Alphamap', linspace(0, get(uiSliderMipLinAlpha, 'Value'), 256)');
                end
            end

            mipLinearAlphaValue('set',  get(uiSliderMipLinAlpha, 'Value'));
            getMipAlphaMap('set', dicomBuffer('get'), 'Linear', aAlphamap);
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
        
        if bypassUiSliderIsoSurfaceListener('get') == true
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

        set(uiEditIsoSurface, 'String', num2str(get(uiSliderIsoSurface, 'Value')*100));
        
        initGate3DObject('set', true);

    end

    function editIsoSurfaceCallback(~, ~)

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            return;
        end
                
        bypassUiSliderIsoSurfaceListener('set', true);

        dValue = abs(str2double(get(uiEditIsoSurface, 'String')));

        if dValue > 100
            dValue = 100;
        end

        if dValue < 0
            dValue = 0;
        end

        if get(ui3DVolume, 'Value') == 2 % Fusion

            isoFusionObj = isoFusionObject('get');
            if switchToIsoSurface('get') == true  && isFusion('get') == true
                if ~isempty(isoFusionObj)
                    set(isoFusionObj, 'Isovalue', dValue/100 );
                end
            end
            isoSurfaceFusionValue('set', dValue/100 );
        else
            if switchToIsoSurface('get') == true
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    set(isoObj, 'Isovalue', dValue/100 );
                end
            end
            isoSurfaceValue('set', dValue/100);
        end

        set(uiEditIsoSurface  , 'String', num2str(dValue));
        set(uiSliderIsoSurface, 'Value', dValue/100 );
        
        bypassUiSliderIsoSurfaceListener('set', false);

        initGate3DObject('set', true);

    end

end
