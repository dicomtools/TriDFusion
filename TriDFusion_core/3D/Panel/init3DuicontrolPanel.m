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
                  'position', [350 837 100 20], ...
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
                     'Position', [460 840 185 20], ...
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
                     'position', [350 715 20 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...
                     'Callback', @display3DVoiCallback...
                     );
       ui3DDispVoiPtr('set', chkDispVoi);

          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'Display Volume-of-Interest',...
                    'horizontalalignment', 'left',...
                    'position', [375 712 250 20],...
                    'Enable', 'Inactive',...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'ButtonDownFcn', @display3DVoiTxtCallback...
                    );

        uicontrol(ui3DPanelPtr('get'),...
                  'Position', [505 685 140 25],...
                  'String'  , 'List',...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @voiEnableListCallback...
                  );

          uicontrol(ui3DPanelPtr('get'),...
                    'style'   , 'text',...
                    'string'  , 'VOI Settings',...
                    'horizontalalignment', 'left',...
                    'position', [350 682 150 20],...
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
                   'string'  , '3D Background',...
                   'horizontalalignment', 'left',...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'position', [350 797 100 20]...
                   );

    ui3DBackground = ...
         uicontrol(ui3DPanelPtr('get'), ...
                   'Style'   , 'popup', ...
                   'Position', [460 800 185 20], ...
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
                  'Position', [631 575 14 70], ...
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
                  'Position', [505 625 120 20], ...
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
                  'position', [350 622 120 20]...
                  );

    uiEdit3DYRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 600 120 20], ...
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
                  'position', [350 597 120 20]...
                  );

    uiEdit3DZRatio = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [505 575 120 20], ...
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
                  'position', [350 572 120 20]...
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
                  'position', [25 760 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @addVoiIsoMaskCallback...
                  );
     chkAddVoiIsoMaskPtr('set', chkAddVoiIsoMask);

     txtAddVoiIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Add Contours from ISO Mask',...
                  'horizontalalignment', 'left',...
                  'position', [45 757 200 20],...
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
                  'position', [45 735 20 20],...
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
                  'position', [65 732 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @pixelEdgeIsoMaskCallback...
                  );
    txtPixelEdgeIsoMaskPtr('set', txtPixelEdgeIsoMask);    
    
    uiEditAddVoiIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 710 65 20], ...
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
                  'position', [45 710 20 20],...
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
                  'position', [65 707 150 20],...
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
                  'position', [65 685 20 20],...
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
                  'position', [85 682 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @multiplePeaksIsoMaskCallback...
                  );
    txtMultiplePeaksIsoMaskPtr('set', txtMultiplePeaksIsoMask);


    uiEditPeakPercentIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 685 65 20], ...
                  'String'  , peakPercentIsoMask('get'), ...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editPeakPercentIsoMaskValue ...
                  );
    uiEditPeakPercentIsoMaskPtr('set', uiEditPeakPercentIsoMask);


       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Smallest Contour (ml)',...
                  'horizontalalignment', 'left',...
                  'position', [45 660 200 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On' ...
                  );

    uiEditSmalestIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 660 65 20], ...
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
                  'position', [25 635 20 20],...
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
                  'position', [45 632 200 20],...
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
        asCTSeries = num2cell(zeros(1,numel(tResampleToCT)));
        for cc=1:numel(tResampleToCT)
            asCTSeries{cc} = tResampleToCT{cc}.sSeriesDescription;
        end
    end

    uiResampleToCTIsoMask = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 635 140 20], ...
                  'String'  , asCTSeries, ...
                  'Value'   , isoMaskCtSerieOffset('get'),...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @resampleToCTOffsetCallback ...
                  );
     uiResampleToCTIsoMaskPtr('set', uiResampleToCTIsoMask);
     
    chkResampledContoursIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , resampledContoursIsoMask('get'),...
                  'position', [45 610 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resampledContoursIsoMaskCallback...
                  );
     chkResampledContoursIsoMaskPtr('set', chkResampledContoursIsoMask);

     txtResampledContoursIsoMask = ...
       uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Contours from Resampled Matrix',...
                  'horizontalalignment', 'left',...
                  'position', [65 607 250 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable', 'On', ...
                  'ButtonDownFcn', @resampledContoursIsoMaskCallback...
                  );
    txtResampledContoursIsoMaskPtr('set', txtResampledContoursIsoMask);  
                  
         uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'ISO Create Mask',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 575 150 20]...
                  );

    uiCreateIsoMask = ...
        uicontrol(ui3DPanelPtr('get'),...
                  'Position', [180 575 140 25],...
                  'String'  , 'Create 3D Mask',...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @createIsoMaskCallback...
                  );
    ui3DCreateIsoMaskPtr('set', uiCreateIsoMask);

    % ISO Surface Color

        uicontrol(ui3DPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'ISO Surface Color',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 837 150 20]...
                  );
    
    asColor = [surfaceColor('all') 'Custom'];
    uiIsoSurfaceColor = ...
       uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [180 840 140 20], ...
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
                  'string'  , 'ISO Surface Value',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [25 815 200 20]...
                              );

    uiSliderIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [25 800 225 14], ...
                  'Value'   , isoSurfaceValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderIsoCallback ...
                  );
    ui3DSliderIsoSurfacePtr('set', uiSliderIsoSurface);
    uiSliderIsoSurfaceListener = addlistener(uiSliderIsoSurface,'Value','PreSet',@sliderIsoCallback);

    uiEditIsoSurface = ...
        uicontrol(ui3DPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [255 800 65 20], ...
                  'String'  , isoSurfaceValue('get'), ...
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
            set(uiEditIsoSurface  , 'String', num2str(isoSurfaceValue('get')));

        end

        uiSliderMipLinAlphaListener = addlistener(uiSliderMipLinAlpha, 'Value', 'PreSet', @sliderMipLinearAlphaCallback);
        uiSliderVolLinAlphaListener = addlistener(uiSliderVolLinAlpha, 'Value', 'PreSet', @sliderVolLinearAlphaCallback);
        uiSliderIsoSurfaceListener  = addlistener(uiSliderIsoSurface , 'Value', 'PreSet', @sliderIsoCallback);
    end

    function voiEnableListCallback(~, ~)

        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        for pp=1:numel(tVoiInput) % Patch, don't export total-mask
            if strcmpi(tVoiInput{pp}.Label, 'TOTAL-MASK')
                tVoiInput{pp} = [];
                tVoiInput(cellfun(@isempty, tVoiInput)) = [];       
            end
        end     
        
        if ~isempty(tVoiInput)

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

            for aa=1:numel(tVoiInput)

                sVoiName  = tVoiInput{aa}.Label;
                aVoiColor = tVoiInput{aa}.Color;

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
                progressBar(1, 'Error:chkVoiListCallback()');
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
        
        if get(chkResampleToCTIsoMask, 'Value') == true && ...
           get(chkAddVoiIsoMask, 'Value') == true
                        
            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'on');                
            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'Inactive');
        else
            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'off');                
            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'on');
        end         
        
        resampleToCTIsoMask('set', get(chkResampleToCTIsoMask, 'Value'));
        
    end

    function resampledContoursIsoMaskCallback(hObject, ~)

        if get(chkResampledContoursIsoMask, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkResampledContoursIsoMask, 'Value', true);
            else
                set(chkResampledContoursIsoMask, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkResampledContoursIsoMask, 'Value', false);
            else
                set(chkResampledContoursIsoMask, 'Value', true);
            end
        end            
        
        resampledContoursIsoMask('set', get(chkResampledContoursIsoMask, 'Value'));
        
    end

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
            
            if get(chkResampleToCTIsoMask, 'Value') == true                        
                set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'on');                
                set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'Inactive');
            end 
        
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
            set(chkResampledContoursIsoMaskPtr('get'), 'Enable', 'off');                
            set(txtResampledContoursIsoMaskPtr('get'), 'Enable', 'on');            
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
            dColorOffset = isoColorOffset('get');
            
            tInput = inputTemplate('get');

            im = dicomBuffer('get');
            atMetaData = dicomMetaData('get');
            aInputBuffer = inputBuffer('get');
                    
            % Resample to CT
            
            if resampledContoursIsoMask('get') == true

                tResampleToCT = resampleToCTIsoMaskUiValues('get');
                if resampleToCTIsoMask('get') == true && ...
                   ~isempty(tResampleToCT)

                    dCTOffset = isoMaskCtSerieOffset('get');
                    dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;

                    refImage = aInputBuffer{dCTSeriesNumber};
                    atRefMetaData = tInput(dCTSeriesNumber).atDicomInfo;           
                    
                    if numel(im) ~= numel(refImage)
                        
                        progressBar(0.3, sprintf('Resampling series, please wait'));

                        [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear',  true);   

                        progressBar(0.6, sprintf('Resampling ROIs, please wait'));

                        atRoi = roiTemplate('get', dSeriesOffset);

                        atResampledRoi = resampleROIs(im, atMetaData, aResampledBuffer, atResampledMetaData, atRoi, true);

                        roiTemplate('set', dSeriesOffset, atResampledRoi);  

                        progressBar(0.99999, sprintf('Resampling MIP, please wait'));

                        dicomMetaData('set', atResampledMetaData);
                        dicomBuffer('set', aResampledBuffer);

                        refMip = mipBuffer('get', [], dCTSeriesNumber);

                        aMip = mipBuffer('get', [], dSeriesOffset);
                        aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear');

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

            tRoiInput = roiTemplate('get', dSeriesOffset);

            aLogicalMask = roiConstraintToMask(im, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

            dImageMin = min(double(im),[], 'all');

            im(aLogicalMask==0) = dImageMin; % Apply constraint            
            
            % Get ISO value
            
            progressBar(0.6, sprintf('Computing mask, please wait'));

            fv = isosurface(im, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"

            aVolume = polygon2voxel(fv, size(im), 'none');
            BW = imfill(aVolume, 4, 'holes');
       %     BW = volumeFill(aVolume);

            imMask = im;
            imMask(BW == 0) = dMin;

            tInput = inputTemplate('get');
                                    
            tInput(numel(tInput)+1) = tInput(dSeriesOffset);
            
            tInput(numel(tInput)).bEdgeDetection = false;
            tInput(numel(tInput)).bDoseKernel    = false;    
            tInput(numel(tInput)).bFlipLeftRight = false;
            tInput(numel(tInput)).bFlipAntPost   = false;
            tInput(numel(tInput)).bFlipHeadFeet  = false;
            tInput(numel(tInput)).bMathApplied   = false;
            tInput(numel(tInput)).bFusedDoseKernel    = false;
            tInput(numel(tInput)).bFusedEdgeDetection = false;
            tInput(numel(tInput)).tMovement = [];
            tInput(numel(tInput)).tMovement.bMovementApplied = false;
            tInput(numel(tInput)).tMovement.aGeomtform = [];                
            tInput(numel(tInput)).tMovement.atSeq{1}.sAxe = [];
            tInput(numel(tInput)).tMovement.atSeq{1}.aTranslation = [];
            tInput(numel(tInput)).tMovement.atSeq{1}.dRotation = [];            
                                  
            tInput(numel(tInput)).atDicomInfo = atDcmMetaData;

            asSeriesDescription = seriesDescription('get');
            asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('MASK %s', asSeriesDescription{dSeriesOffset});
            seriesDescription('set', asSeriesDescription);

            dSeriesInstanceUID = dicomuid;

            for hh=1:numel(tInput(numel(tInput)).atDicomInfo)
                tInput(numel(tInput)).atDicomInfo{hh}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
                tInput(numel(tInput)).atDicomInfo{hh}.SeriesInstanceUID = dSeriesInstanceUID;
            end
            
            tInput(numel(tInput)).aDicomBuffer = imMask;
                
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

            aMaskedMip = computeMIP(imMask);
            mipBuffer('set', aMaskedMip, numel(tInput));
            tInput(numel(tInput)).aMip = aMaskedMip;

            set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

            progressBar(1, sprintf('Mask completed'));

            set(uiSeriesPtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
            set(btn3DPtr('get'), 'Enable', 'on');
            set(btnMIPPtr('get'), 'Enable', 'on');

            if get(chkAddVoiIsoMask, 'Value') == true
                
                % Set Pixel Edge
                if get(chkPixelEdgeIsoMask, 'Value') == true
                    bPixelEdge = true;
                else
                    bPixelEdge = false;
                end

                % Set Percent to Max

                dPercentMaxOrMaxSUVValue = abs(str2double(get(uiEditAddVoiIsoMask, 'String')));

                if get(chkPercentOfPeakIsoMask, 'Value') == true

                    bPercentOfPeak = true;

                    if dPercentMaxOrMaxSUVValue < 0
                        dPercentMaxOrMaxSUVValue = 0;
                    end

                    if dPercentMaxOrMaxSUVValue > 100
                        dPercentMaxOrMaxSUVValue = 100;
                    end

                    voiIsoMaskMax('set', dPercentMaxOrMaxSUVValue);
                else
                    bPercentOfPeak = false;

                    if dPercentMaxOrMaxSUVValue < 0
                        dPercentMaxOrMaxSUVValue = 0;
                    end

                    peakSUVMaxIsoMask('set', dPercentMaxOrMaxSUVValue);
                end

                set(uiEditAddVoiIsoMask, 'String', num2str(dPercentMaxOrMaxSUVValue));

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

                % Create VOIs

                maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, dSmalestVoiValue);

                % Resample to CT

                if resampledContoursIsoMask('get') == false

                    tResampleToCT = resampleToCTIsoMaskUiValues('get');
                    if resampleToCTIsoMask('get') == true && ...
                       ~isempty(tResampleToCT)


                        dCTOffset = isoMaskCtSerieOffset('get');
                        dCTSeriesNumber = tResampleToCT{dCTOffset}.dSeriesNumber;
                        
                        im = dicomBuffer('get');        

                        refImage = aInputBuffer{dCTSeriesNumber};
                        atRefMetaData = tInput(dCTSeriesNumber).atDicomInfo;           

                        if numel(im) ~= numel(refImage)
                            
                            progressBar(0.3, sprintf('Resampling series, please wait'));
                        
                            [aResampledBuffer, atResampledMetaData] = resampleImage(im, atMetaData, refImage, atRefMetaData, 'Linear',  true);   

                            progressBar(0.6, sprintf('Resampling ROIs, please wait'));

                            atRoi = roiTemplate('get', dSeriesOffset);

                            atResampledRoi = resampleROIs(im, atMetaData, aResampledBuffer, atResampledMetaData, atRoi, true);

                            roiTemplate('set', dSeriesOffset, atResampledRoi);  

                            progressBar(0.99999, sprintf('Resampling MIP, please wait'));

                            dicomMetaData('set', atResampledMetaData);
                            dicomBuffer('set', aResampledBuffer);

                            refMip = mipBuffer('get', [], dCTSeriesNumber);

                            aMip = mipBuffer('get', [], dSeriesOffset);
                            aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, 'Linear');

                            mipBuffer('set', aResampledMip, dSeriesOffset);

                            setQuantification(dSeriesOffset);     
                                                        
                        end
                    end
                end
            
                setSeriesCallback();                               
                
                if resampleToCTIsoMask('get') == true && ...
                   ~isempty(tResampleToCT) 
                
                    % Deactivate MIP Fusion

                    link2DMip('set', false);

                    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 

                    % Set fusion

                    set(uiFusedSeriesPtr('get'), 'Value', dCTSeriesNumber);

                    setFusionCallback();

                    progressBar(1, sprintf('Ready'));

                end

                % Triangulate og 1st VOI

                tVoiInput = voiTemplate('get', dSeriesOffset);

                if ~isempty(tVoiInput)

                    dRoiOffset = round(numel(tVoiInput{1}.RoisTag)/2);

                    triangulateRoi(tVoiInput{1}.RoisTag{dRoiOffset}, true);
                end

                % Activate ROI Panel

                if viewRoiPanel('get') == false
                    setViewRoiPanel();
                end
            else

            end
           
            
            catch
                progressBar(1, 'Error:createIsoMaskCallback()');
            end

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

        function maskAddVoiToSeries(imMask, BW, bPixelEdge, bPercentOfPeak, dPercentMaxOrMaxSUVValue, bMultiplePeaks, dMultiplePeaksPercentValue, dSmalestValue)

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
            dMaxValue = max(imMask, [], 'all');

            CC = bwconncomp(BW, 6);
            dNbElements = numel(CC.PixelIdxList);

            asAllTag = [];

            BW = zeros(size(imMask)); % Init BW buffer

                        
            for bb=1:dNbElements  % Nb VOI

                progressBar( bb/dNbElements-0.0001, sprintf('Computing Volume %d/%d, please wait', bb, dNbElements) );

                if numel(CC.PixelIdxList{bb}) >= dSmalestValueNbVoxels

                    BW(BW ~=0) = 0; % Reset BW buffer

                    BW(CC.PixelIdxList{bb}) = imMask(CC.PixelIdxList{bb});

                    if bPercentOfPeak == true % Percent of peak or SUV Value

                        if bMultiplePeaks == true % Multiple peaks
if 0
                            MASK_PEAKS = zeros(size(imMask)); % Init PEAK buffer

                            BW_PEAKS = imregionalmax(BW, 6); % Search for peaks
                            CC_PEAKS = bwconncomp(BW_PEAKS, 6);

                            dNbMaxPeaks = numel(CC_PEAKS.PixelIdxList);

                            BW(BW ~=0) = 0; % Reset BW buffer

                            for mm=1:dNbMaxPeaks  % Nb Peaks

                                MASK_PEAKS(MASK_PEAKS ~=0) = 0;

                                dCurrentPeakValue = max(imMask(CC_PEAKS.PixelIdxList{mm}), [], 'all');
                                dMaxMaskValue     = max(imMask(CC.PixelIdxList{bb}), [], 'all');

                                if dCurrentPeakValue >= dMaxMaskValue * (dMultiplePeaksPercentValue /100) % Inside the Ratio

                                    dMinPeakValue = dCurrentPeakValue * (dPercentMaxOrMaxSUVValue /100);

                                    MASK_PEAKS(CC.PixelIdxList{bb}) = imMask(CC.PixelIdxList{bb});
                                    MASK_PEAKS(MASK_PEAKS <= dMinPeakValue) = dMinValue;

                                    BW(MASK_PEAKS ~= dMinValue) = dMaxValue;
                                end

                            end

                            BW(BW ~= dMaxValue) = 0;
                            BW(BW == dMaxValue) = 1;
else
    

                            dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * (dPercentMaxOrMaxSUVValue) /100;
                            dMaxMaskValue = dMaxMaskValue * (dMultiplePeaksPercentValue) /100;
                            
                            BW(BW <= dMaxMaskValue) = dMinValue;

                            BW(BW ~= dMinValue) = 1;
                            BW(BW == dMinValue) = 0;
end

                        else % Single peak

                            dMaxMaskValue = max(imMask(CC.PixelIdxList{bb}), [], 'all') * dPercentMaxOrMaxSUVValue /100;

                            BW(BW <= dMaxMaskValue) = dMinValue;

                            BW(BW ~= dMinValue) = 1;
                            BW(BW == dMinValue) = 0;
                        end
                    else
                        tQuant = quantificationTemplate('get');

                        BW(BW*tQuant.tSUV.dScale <= dPercentMaxOrMaxSUVValue) = dMinValue;
                        BW(BW ~= dMinValue) = 1;
                        BW(BW == dMinValue) = 0;
                    end

                    asTag = []; % Reset ROIs tag

                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);

                    dNbSlices = size(BW, 3);

                    [~,~,adSlices]=ind2sub(size(BW), CC.PixelIdxList{bb});

                    dFirstSlice = adSlices(1);
                    dLastSlice  = adSlices(end);
                                                
                    for aa=dFirstSlice:dLastSlice % Find ROI

                        aAxial = BW(:,:,aa);
                        if aAxial(aAxial==1)

                            if mod(aa, 5)==1 || aa == dNbSlices
                                progressBar( aa/dNbSlices-0.0001, sprintf('Computing slice %d/%d, please wait', aa, dNbSlices) );
                            end

                           if bPixelEdge == true
                                aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                            end

                            [maskAxial,~,~,~] = bwboundaries(aAxial, 'noholes', 4);

                            if ~isempty(maskAxial)

                                if bPixelEdge == true
                                    for ii=1:numel(maskAxial)
                                        maskAxial{ii} = (maskAxial{ii} +1)/PIXEL_EDGE_RATIO;
                                    end
                                end

                            end

                            if ~isempty(maskAxial)
                                for jj=1:numel(maskAxial)

                                    curentMask = maskAxial(jj);
                                    
%                                    sliceNumber('set', 'axial', aa);

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                    aPosition = flip(curentMask{1}, 2);

%                                    bAddRoi = true;
%                                    pRoi = drawfreehand(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'Smoothing', 1, 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', roiFaceAlphaValue('get'));
                                    addContourToTemplate(dSeriesOffset, 'Axes3', aa, 'images.roi.freehand', aPosition, '', 'off', aColor, 1, roiFaceAlphaValue('get'), 0, 1, sTag);
                           %         if SMALEST_ROI_SIZE > 0
                           %             roiMask = pRoi.createMask();
                           %             if numel(roiMask(roiMask==1)) < SMALEST_ROI_SIZE
                           %                 delete(pRoi);
                           %                 bAddRoi = false;
                           %             end
                           %         else
                           %             MASK_FLAG(BW ~= dMinValue) = 0; % Set flag to 0 for that region
                           %         end

%                                    if bAddRoi == true

%                                        pRoi.Waypoints(:) = false;

%                                        addRoi(pRoi, dSeriesOffset);

%                                        roiDefaultMenu(pRoi);

%                                        uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
%                                        uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

%                                        cropMenu(pRoi);

%                                        uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                                        asTag{numel(asTag)+1} = sTag;
                                        asAllTag{numel(asAllTag)+1} = sTag;
%                                    end
                                end
                            end
                        end
                    end

                    if ~isempty(asTag)

                        sLabel = sprintf('RMAX-%d-VOI%d', dPercentMaxOrMaxSUVValue, bb);

                        createVoiFromRois(dSeriesOffset, asTag, sLabel);

                    end
                end
            end

            if ~isempty(asAllTag)

                sLabel = sprintf('TOTAL-MASK');

                createVoiFromRois(dSeriesOffset, asAllTag, sLabel);
            end

%            setVoiRoiSegPopup();
%            setSeriesCallback();

            progressBar(1, 'Ready');

            catch
                progressBar(1, 'Error:maskAddVoiToSeries()');
            end

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

        dValue = abs(str2double(get(uiEditIsoSurface, 'String')));

        if dValue > 1
            dValue = 1;
        end

        if dValue < 0
            dValue = 0;
        end

        if get(ui3DVolume, 'Value') == 2 % Fusion

            isoFusionObj = isoFusionObject('get');
            if switchToIsoSurface('get') == true  && isFusion('get') == true
                if ~isempty(isoFusionObj)
                    set(isoFusionObj, 'Isovalue', dValue );
                end
            end
            isoSurfaceFusionValue('set', dValue );
        else
            if switchToIsoSurface('get') == true
                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    set(isoObj, 'Isovalue', dValue );
                end
            end
            isoSurfaceValue('set', dValue);
        end

        set(uiEditIsoSurface  , 'String', num2str(dValue));
        set(uiSliderIsoSurface, 'Value', dValue );

        initGate3DObject('set', true);

    end

end
