function initKernelPanel()
%function initKernelPanel()
%Kernel Panel Main Function.
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

    aBuffer = dicomBuffer('get');
    if isempty(aBuffer)
         return;
    else
        if size(aBuffer, 3) == 1
            sEnable = 'off';
        else
            sEnable = 'on';
        end
    end

%    tQuant = quantificationTemplate('get');


    % Reset or Proceed

        uicontrol(uiKernelPanelPtr('get'),...
                  'String'  ,'Reset',...
                  'Position',[15 625 100 25],...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.3255, 0.1137, 0.1137], ...
                  'ForegroundColor', [0.94 0.94 0.94], ...
                  'Callback', @resetKernelCallback...
                  );

% 3D Dose Kernel

    tDoseKernel = getDoseKernelTemplate();

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'    , 'On', ...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'string'    , '3D Dose Kernel',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 580 200 20]...
                  );

    tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

    if isempty(tKernelCtDoseMap) || size(aBuffer, 3) == 1
        dUpperValue = 0;
        dLowerValue = 0;

        sUseCtDoseMapEnable = 'off';
        sChkUseCTdoseMapEnable = 'off';
        sTxtUseCTdoseMapEnable = 'on';

        asKernelSeries = {' '};
    else

        dUpperValue = kernelSegEditValue('get', 'upper');
        dLowerValue = kernelSegEditValue('get', 'lower');

        sChkUseCTdoseMapEnable = 'on';
        sTxtUseCTdoseMapEnable = 'Inactive';
        if kernelUseCtDoseMap('get') == true
            sUseCtDoseMapEnable = 'on';
        else
            sUseCtDoseMapEnable = 'off';
        end

        asKernelSeries = num2cell(zeros(1,numel(tKernelCtDoseMap)));
        for ll=1:numel(tKernelCtDoseMap)
            asKernelSeries{ll} = tKernelCtDoseMap{ll}.sSeriesDescription;
        end

        if kernelUnitTypeWindow('get') == true
            [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
            dUpperValue = dCTWindow;
            dLowerValue = dCTLevel;
        end

    end

    chkUseCTdoseMapKernel = ...
        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , sChkUseCTdoseMapEnable,...
                  'value'   , kernelUseCtDoseMap('get'),...
                  'position', [15 555 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUseCTdoseMapKernelCallback...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Use CT Map',...
                  'horizontalalignment', 'left',...
                  'position', [35 555 200 20],...
                  'Enable', sTxtUseCTdoseMapEnable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUseCTdoseMapKernelCallback...
                  );

    uiKernelSeries = ...
         uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 525 245 25], ...
                  'String'  , asKernelSeries, ...
                  'Value'   , kernelCtSerieOffset('get'),...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'Callback', @setKernelSeriesCallback, ...
                  'BackgroundColor', viewerBackgroundColor ('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
    uiKernelSeriesObject('set', uiKernelSeries);

    chkUnitTypeKernel = ...
        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , sUseCtDoseMapEnable,...
                  'value'   , kernelUnitTypeWindow('get'),...
                  'position', [15 500 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUnitTypeKernelCallback...
                  );
    chkUnitTypeKernelObject('set', chkUnitTypeKernel);

    txtUnitTypeKernel = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Unit in HU',...
                  'horizontalalignment', 'left',...
                  'position', [35 500 200 20],...
                  'Enable', 'On',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUnitTypeKernelCallback...
                  );

    uiTxtUpperThreshold = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Threshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 475 200 20]...
                  );
    txtKernelVoiRoiUpperThresholdObject('set', uiTxtUpperThreshold);

    uiSliderKernelUpperThreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 455 175 20], ...
                  'Value'   , kernelSegTreshValue('get', 'upper'), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderKernelUpperTreshCallback ...
                  );
%    addlistener(uiSliderKernelUpperThreshold,'Value','PreSet',@sliderKernelUpperTreshCallback);
    sliderKernelVoiRoiUpperThresholdObject('set', uiSliderKernelUpperThreshold);

    uiEditKernelUpperThreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 455 65 20], ...
                  'String'  , num2str(dUpperValue), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editKernelUpperTreshCallback ...
                  );
    editKernelVoiRoiUpperThresholdObject('set', uiEditKernelUpperThreshold);

        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'on', ...
                  'string'  , 'Lower Threshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 430 200 20]...
                  );

    uiSliderKernelLowerThreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 410 175 20], ...
                  'Value'   , kernelSegTreshValue('get', 'lower'), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderKernelLowerTreshCallback ...
                  );
%    lstSliderKernelLowerTresh = addlistener(uiSliderKernelLowerThreshold,'Value','PreSet',@sliderKernelLowerTreshCallback);

    uiEditKernelLowerThreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 410 65 20], ...
                  'String'  ,  num2str(dLowerValue), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editKernelLowerTreshCallback ...
                  );
    editKernelVoiRoiLowerThresholdObject('set', uiEditKernelLowerThreshold);



         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Kernel Method',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 365 125 20]...
                  );

    uiKernelMethod = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 365 125 25],...
                  'String'  , {'Local Deposition', 'Kernel Convolution', 'Bypass'}, ...
                  'Value'   , kernelMethod('get'),...
                  'Enable'  , 'On', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelMethodCallback...
                  );


         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Kernel Model',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 325 125 20]...
                  );

    uiKernelModel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 325 125 25],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelModelCallback...
                  );

   if ~isempty(tDoseKernel)
     set(uiKernelModel, 'String', tDoseKernel.ModelName);
   end

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Tissue Dependent',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 295 125 20]...
                  );

    uiKernelTissue = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 295 125 25],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelTissueCallback...
                 );

  if ~isempty(tDoseKernel)
    set(uiKernelTissue, 'String', tDoseKernel.Tissue{get(uiKernelModel, 'Value')});
  end

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Isotope',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 265 125 20]...
                  );

    uiKernelIsotope = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 265 125 25],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelIsotopeCallback...
                  );

    if ~isempty(tDoseKernel)
        set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
    end

    sUserInterpolation = kernelInterpolation('get');
    asKernelInterpolation = {'Linear', 'Nearest', 'Next', 'Pchip', 'Makima', 'Spline'};

    for dIterpolationValue =1: numel(asKernelInterpolation)
        if strcmpi(asKernelInterpolation{dIterpolationValue}, sUserInterpolation)
            break;
        end
    end

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Interpolation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 235 125 20]...
                  );

    uiKernelInterpolation = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 235 125 25],...
                  'String'  , asKernelInterpolation, ...
                  'Value'   , dIterpolationValue,...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelInterpolationCallback...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Cutoff distance (mm)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 202 200 20]...
                  );

    uiPlotDistance = ...
        uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'String', 'Plot',...
                  'Position',[160 205 33 20],...
                  'BackgroundColor', [0.75 0.75 0.75], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @plotKernelDistanceCallback...
                  );


    dTissue   = get(uiKernelTissue , 'Value' );
    asTissue  = get(uiKernelTissue , 'String');

    dIsotope  = get(uiKernelIsotope, 'Value' );
    asIsotope = get(uiKernelIsotope, 'String');

    dCutoffValue = getKernelDefaultCutoffValue(asIsotope{dIsotope});

    uiEditKernelCutoff = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 205 65 20], ...
                  'String'  , num2str(dCutoffValue), ...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editKernelCutoffCallback ...
                  );

    chkMicrosphereInSpecimen = ...
        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , kernelMicrosphereInSpecimen('get'),...
                  'position', [15 175 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkMicrosphereInSpecimenCallback...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Microsphere In Specimen',...
                  'horizontalalignment', 'left',...
                  'position', [35 175 200 20],...
                  'Enable'  , 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkMicrosphereInSpecimenCallback...
                  );

    uiDoseKernelPanel = ...
        uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'String', 'Apply',...
                  'Position',[160 140 100 25],...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @doseKernelCallback...
                  );

    % 3D Gauss Filter

        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , '3D Gauss Filter',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 90 200 20]...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Kernel size (mm)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 62 200 20]...
                  );

    edtGaussFilterX = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , gaussFilterValue('get', 'x'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [130 65 40 20]...
                  );

    edtGaussFilterY = ...
        uicontrol(uiKernelPanelPtr('get'),...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , gaussFilterValue('get', 'y'),...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...
                 'position'  , [175 65 40 20]...
                 );

        edtGaussFilterZ = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'enable'    , sEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , gaussFilterValue('get', 'z'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 65 40 20]...
                  );

        uicontrol(uiKernelPanelPtr('get'),...
                  'String','Filter',...
                  'Position',[160 30 100 25],...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @gaussFilterCallback...
                  );

    function setKernelSeriesCallback(hObject, ~)

        dSerieOffset = get(hObject, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        kernelCtSerieOffset('set', get(hObject, 'Value') );

        dUpperValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dLowerValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        if get(chkUnitTypeKernel, 'Value') == true
            [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
            dUpperValue = dCTWindow;
            dLowerValue = dCTLevel;
        end

        kernelSegEditValue('set', 'upper', dUpperValue);
        kernelSegEditValue('set', 'lower', dLowerValue);

        set(uiEditKernelUpperThreshold, 'String', num2str(dUpperValue));
        set(uiEditKernelLowerThreshold, 'String', num2str(dLowerValue));

        kernelSegTreshValue('get', 'upper', 1);
        kernelSegTreshValue('get', 'lower', 0);

        set(uiSliderKernelUpperThreshold, 'Value', 1);
        set(uiSliderKernelLowerThreshold, 'Value', 0);

    end

    function chkUseCTdoseMapKernelCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkUseCTdoseMapKernel, 'Value') == true

                set(chkUseCTdoseMapKernel, 'Value', false);
            else
                set(chkUseCTdoseMapKernel, 'Value', true);
            end
        end

        if get(chkUseCTdoseMapKernel, 'Value') == true

            set(txtUnitTypeKernel          , 'Enable', 'Inactive');
            set(chkUnitTypeKernel          , 'Enable', 'On');
            set(uiKernelSeries             , 'Enable', 'On');
            set(uiSliderKernelUpperThreshold, 'Enable', 'On');
            set(uiEditKernelUpperThreshold, 'Enable', 'On');
            set(uiSliderKernelLowerThreshold, 'Enable', 'On');
            set(uiEditKernelLowerThreshold, 'Enable', 'On');
        else
            set(txtUnitTypeKernel          , 'Enable', 'On');
            set(chkUnitTypeKernel          , 'Enable', 'Off');
            set(uiKernelSeries             , 'Enable', 'Off');
            set(uiSliderKernelUpperThreshold, 'Enable', 'Off');
            set(uiEditKernelUpperThreshold, 'Enable', 'Off');
            set(uiSliderKernelLowerThreshold, 'Enable', 'Off');
            set(uiEditKernelLowerThreshold, 'Enable', 'Off');
        end

        kernelUseCtDoseMap('set', get(chkUseCTdoseMapKernel, 'Value'));

    end

    function chkUnitTypeKernelCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkUnitTypeKernel, 'Value') == true

                set(chkUnitTypeKernel, 'Value', false);
            else
                set(chkUnitTypeKernel, 'Value', true);
            end
        end

        dUpperValue = kernelSegEditValue('get', 'upper');
        dLowerValue = kernelSegEditValue('get', 'lower');

        if get(chkUnitTypeKernel, 'Value') == true
            set(txtUnitTypeKernel, 'String', 'Unit in Window Level');

            [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
            dUpperValue = dCTWindow;
            dLowerValue = dCTLevel;

        else
            set(txtUnitTypeKernel, 'String', 'Unit in HU');
            [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
        end

        kernelUnitTypeWindow('set', get(chkUnitTypeKernel, 'Value'));

        kernelSegEditValue('set', 'upper', dUpperValue);
        kernelSegEditValue('set', 'lower', dLowerValue);

        set(uiEditKernelUpperThreshold, 'String', num2str(dUpperValue));
        set(uiEditKernelLowerThreshold, 'String', num2str(dLowerValue));

    end

    function previewCTdoseMapKernel()

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        vBoundAxes1Ptr = visBoundAxes1Ptr('get');
        vBoundAxes2Ptr = visBoundAxes2Ptr('get');
        vBoundAxes3Ptr = visBoundAxes3Ptr('get');

        if ~isempty(vBoundAxes1Ptr)
            delete(vBoundAxes1Ptr);
        end

        if ~isempty(vBoundAxes2Ptr)
            delete(vBoundAxes2Ptr);
        end

        if ~isempty(vBoundAxes3Ptr)
            delete(vBoundAxes3Ptr);
        end

        bUseCtMap = get(chkUseCTdoseMapKernel, 'Value'); % CT Guided

        aRefBuffer = dicomBuffer('get');
        atRefMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');

        if bUseCtMap == true

            tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

            dCtOffset = get(uiKernelSeries, 'Value');

            dSerieOffset = get(uiSeriesPtr('get'), 'Value');

%            set(uiSeriesPtr('get'), 'Value', tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

            aCtBuffer = dicomBuffer('get', [], tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

            if isempty(aCtBuffer)

                aInput = inputBuffer('get');
                aCtBuffer = aInput{tKernelCtDoseMap{dCtOffset}.dSeriesNumber};

                if     strcmpi(imageOrientation('get'), 'axial')
                %    aCtBuffer = aCtBuffer;
                elseif strcmpi(imageOrientation('get'), 'coronal')
                    aCtBuffer = reorientBuffer(aCtBuffer, 'coronal');
                elseif strcmpi(imageOrientation('get'), 'sagittal')
                    aCtBuffer = reorientBuffer(aCtBuffer, 'sagittal');
                end

                if tInput(dSerieOffset).bFlipLeftRight == true
                    aCtBuffer=aCtBuffer(:,end:-1:1,:);
                end

                if tInput(dSerieOffset).bFlipAntPost == true
                    aCtBuffer=aCtBuffer(end:-1:1,:,:);
                end

                if tInput(dSerieOffset).bFlipHeadFeet == true
                    aCtBuffer=aCtBuffer(:,:,end:-1:1);
                end

                dicomBuffer('set', aCtBuffer, tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

            end

            atCtMetaData = dicomMetaData('get', [], tKernelCtDoseMap{dCtOffset}.dSeriesNumber);
            if isempty(atCtMetaData)

                atCtMetaData = tInput(tKernelCtDoseMap{dCtOffset}.dSeriesNumber).atDicomInfo;
                dicomMetaData('set', atCtMetaData, tKernelCtDoseMap{dCtOffset}.dSeriesNumber);
            end

  %          set(uiSeriesPtr('get'), 'Value', dSerieOffset);

            [aResamCt, ~] = ...
                resampleImage(aCtBuffer, ...
                              atCtMetaData, ...
                              aRefBuffer, ...
                              atRefMetaData, ...
                              'Nearest', ...
                              2, ...
                              false);

            % Get constraint

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            aLogicalMask = ...
                roiConstraintToMask(aResamCt, ...
                                    tRoiInput, ...
                                    asConstraintTagList, ...
                                    asConstraintTypeList, ...
                                    bInvertMask);

            dImageMin = min(double(aResamCt),[], 'all');

            aResamCt(aLogicalMask==0) = dImageMin; % Apply constraint

            dCtMIn = min(double(aResamCt),[], 'all');

            dUpperValue = str2double( get(uiEditKernelUpperThreshold, 'String') );
            dLowerValue = str2double( get(uiEditKernelLowerThreshold, 'String') );
            if get(chkUnitTypeKernel, 'Value') == true
                [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
            end

            aResamCt(aResamCt<=dLowerValue) = dCtMIn;
            aResamCt(aResamCt>=dUpperValue) = dCtMIn;

        else
            aResamCt = aRefBuffer;
        end

        dRefMIn    = min(double(aRefBuffer),[], 'all');
        dResampMIn = min(double(aResamCt),[], 'all');

        aResamCt(aResamCt==dResampMIn)=0;
        aResamCt(aResamCt~=0)=1;

        imCoronal  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value') );
        imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value') );
        imAxial    = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value') );

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );

        aCtCoronal  =  permute(aResamCt(iCoronal,:,:), [3 2 1]);
        aCtSagittal =  permute(aResamCt(:,iSagittal,:), [3 1 2]);
        aCtAxial    =  aResamCt(:,:,iAxial);

        aCoronal  =  permute(aRefBuffer(iCoronal,:,:), [3 2 1]);
        aSagittal =  permute(aRefBuffer(:,iSagittal,:), [3 1 2]);
        aAxial    =  aRefBuffer(:,:,iAxial);

        aCoronal(aCtCoronal==0) = dRefMIn;
        aSagittal(aCtSagittal==0) = dRefMIn;
        aAxial(aCtAxial==0) = dRefMIn;

        imCoronal.CData  = aCoronal;
        imSagittal.CData = aSagittal;
        imAxial.CData    = aAxial;

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:previewCTdoseMapKernel()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function editKernelLowerTreshCallback(~, ~)

        dUpperThreshold = str2double(get(uiEditKernelUpperThreshold, 'String'));

        dLowerThreshold = str2double(get(uiEditKernelLowerThreshold, 'String'));
        if isnan(dLowerThreshold)
            dLowerThreshold = kernelSegEditValue('get', 'lower');
            set(uiEditKernelLowerThreshold, 'String', num2str(dLowerThreshold));
        end

        if dLowerThreshold > dUpperThreshold
            dLowerThreshold = dUpperThreshold;
            set(uiEditKernelLowerThreshold, 'String', num2str(dLowerThreshold));
        end

        if get(chkUnitTypeKernel, 'Value') == true
            [~, dLowerThreshold] = computeWindowLevel(dUpperThreshold, dLowerThreshold);
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        if dLowerThreshold < dMinValue
            dLowerThreshold = dMinValue;
            set(uiEditKernelLowerThreshold, 'String', num2str(dLowerThreshold));
        end

        dDiff = dMaxValue - dMinValue;
        dLowerSliderValue = (dLowerThreshold-dMinValue)/dDiff;

        set(uiSliderKernelLowerThreshold, 'Value', dLowerSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            [~, dCTLevel] = computeWindowMinMax(dUpperThreshold, dLowerThreshold);
            dLowerThreshold = dCTLevel;
        end

        kernelSegTreshValue('set', 'lower', dLowerSliderValue);
        kernelSegEditValue('set', 'lower', dLowerThreshold);

        previewCTdoseMapKernel();

    end

    function editKernelUpperTreshCallback(~, ~)

        dLowerThreshold = str2double(get(uiEditKernelLowerThreshold, 'String'));

        dUpperThreshold = str2double(get(uiEditKernelUpperThreshold, 'String'));
        if isnan(dUpperThreshold)
            dUpperThreshold = kernelSegEditValue('get', 'upper');
            set(uiEditKernelUpperThreshold, 'String', num2str(dUpperThreshold));
        end

        if dUpperThreshold < dLowerThreshold
            dUpperThreshold = dLowerThreshold;
            set(uiEditKernelUpperThreshold, 'String', num2str(dUpperThreshold));
        end

        if get(chkUnitTypeKernel, 'Value') == true
            [dUpperThreshold, ~] = computeWindowLevel(dUpperThreshold, dLowerThreshold);
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        if dUpperThreshold > dMaxValue
            dUpperThreshold = dMaxValue;
            set(uiEditKernelUpperThreshold, 'String', num2str(dUpperThreshold));
        end

        dDiff = dMaxValue - dMinValue;
        dUpperSliderValue = (dUpperThreshold-dMinValue)/dDiff;

        set(uiSliderKernelUpperThreshold, 'Value', dUpperSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            [dCTWindow, ~] = computeWindowMinMax(dUpperThreshold, dLowerThreshold);
            dUpperThreshold = dCTWindow;
        end

        kernelSegTreshValue('set', 'upper', dUpperSliderValue);
        kernelSegEditValue('set', 'upper', dUpperThreshold);

        previewCTdoseMapKernel();
    end

    function sliderKernelUpperTreshCallback(~, ~)

        dUpperSliderValue = get(uiSliderKernelUpperThreshold, 'Value');
        dLowerSliderValue = get(uiSliderKernelLowerThreshold, 'Value');

        if dUpperSliderValue < dLowerSliderValue
            set(uiSliderKernelUpperThreshold, 'Value', dLowerSliderValue);
            dUpperSliderValue = dLowerSliderValue;
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        dDiff = dMaxValue - dMinValue;
        dUpperValue =  dMinValue + (dDiff * dUpperSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            dLowerValue =  dMinValue + (dDiff * dLowerSliderValue);

            [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
            dUpperValue = dCTWindow;
        end

        kernelSegTreshValue('set', 'upper', dUpperSliderValue);
        kernelSegEditValue('set', 'upper', dUpperValue);

        set(uiEditKernelUpperThreshold, 'String', num2str(dUpperValue));

        previewCTdoseMapKernel();

    end

    function sliderKernelLowerTreshCallback(~, ~)

        dUpperSliderValue = get(uiSliderKernelUpperThreshold, 'Value');
        dLowerSliderValue = get(uiSliderKernelLowerThreshold, 'Value');

        if dLowerSliderValue > dUpperSliderValue
            set(uiSliderKernelLowerThreshold, 'Value', dUpperSliderValue);
            dLowerSliderValue = dUpperSliderValue;
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        dDiff = dMaxValue - dMinValue;
        dLowerValue =  dMinValue + (dDiff * dLowerSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            dUpperValue =  dMinValue + (dDiff * dUpperSliderValue);

            [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
            dLowerValue = dCTLevel;
        end

        kernelSegTreshValue('set', 'lower', dLowerSliderValue);
        kernelSegEditValue('set', 'lower', dLowerValue);

        set(uiEditKernelLowerThreshold, 'String', num2str(dLowerValue));

        previewCTdoseMapKernel();

    end


    function uiKernelMethodCallback(~, ~)

        kernelMethod('set', get(uiKernelMethod, 'Value'));

    end

    function uiKernelModelCallback(~, ~)

        if ~isempty(tDoseKernel)
            set(uiKernelTissue, 'Value', 1);
            set(uiKernelTissue, 'String', tDoseKernel.Tissue{get(uiKernelModel, 'Value')});
        end

        if ~isempty(tDoseKernel)
           set(uiKernelIsotope, 'Value', 1);
           set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
        end
    end

    function uiKernelTissueCallback(~, ~)

        if ~isempty(tDoseKernel)
            set(uiKernelIsotope, 'Value', 1);
            set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
        end
    end

    function uiKernelIsotopeCallback(~, ~)

        dTissue   = get(uiKernelTissue , 'Value' );
        asTissue  = get(uiKernelTissue , 'String');

        dIsotope  = get(uiKernelIsotope, 'Value' );
        asIsotope = get(uiKernelIsotope, 'String');

        dCutOffValue = getKernelDefaultCutoffValue(asIsotope{dIsotope});

        set(uiEditKernelCutoff, 'String', num2str(dCutOffValue));

    end

    function uiKernelInterpolationCallback(~, ~)

        asKernelInterpolation = get(uiKernelInterpolation, 'String');
        dInterpolationValue   = get(uiKernelInterpolation, 'Value');

        kernelInterpolation('set', asKernelInterpolation{dInterpolationValue});
    end

    function plotKernelDistanceCallback(~, ~)

        % Get custom distance

        dDistance = str2double(get(uiEditKernelCutoff, 'String'));

        % Get kernel details

        dModel    = get(uiKernelModel   , 'Value');

        dTissue   = get(uiKernelTissue , 'Value' );
        asTissue  = get(uiKernelTissue , 'String');

        dIsotope  = get(uiKernelIsotope, 'Value' );
        asIsotope = get(uiKernelIsotope, 'String');

        tKernel = tDoseKernel.Kernel{dModel}.(asTissue{dTissue}).(asIsotope{dIsotope});

        asField = fieldnames(tKernel);

        if numel(asField) == 2
            aDistance = tKernel.(asField{1});
            aDoseR2   = tKernel.(asField{2});
        else
            return;
        end

        % Build plot figure

        dScreenSize  = get(groot, 'Screensize');

        ySize = dScreenSize(4);

        PLOT_FIGURE_Y = ySize*0.75;
        PLOT_FIGURE_X = PLOT_FIGURE_Y;

        sPlotKernelFigureName = sprintf('Distance Plot: Tissue Dependent %s, Isotope %s', asTissue{dTissue}, asIsotope{dIsotope});

        figPlotKernelDistance = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-PLOT_FIGURE_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-PLOT_FIGURE_Y/2) ...
                   PLOT_FIGURE_X ...
                   PLOT_FIGURE_Y],...
                   'Name', sPlotKernelFigureName,...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'), ...
                   'Toolbar','none'...
                   );

        aFigurePosition = get(figPlotKernelDistance, 'Position');

        axePlotKernelDistance = ...
            axes(figPlotKernelDistance, ...
                 'Units'   , 'pixels', ...
                 'Position', [60 60 aFigurePosition(3)-90 aFigurePosition(4)-90], ...
                 'Color'   , viewerAxesColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...
                 'Visible' , 'on'...
                 );
        axePlotKernelDistance.Interactions = [];
        disableDefaultInteractivity(axePlotKernelDistance);
        delete(axePlotKernelDistance.Toolbar);

        pDistancePlot = plot(axePlotKernelDistance, aDistance, log10(aDoseR2./aDistance.^2));
        set(pDistancePlot, 'Color', [0.0000, 0.9608, 0.8275]);
%        set(axePlotKernelDistance,'XDir','Reverse');
%        set(axePlotKernelDistance,'YDir','Reverse');

        axePlotKernelDistance.XLabel.String = 'Distance (mm)';
        axePlotKernelDistance.YLabel.String = 'Log10 of kernel';

        axePlotKernelDistance.XColor = viewerForegroundColor('get');
        axePlotKernelDistance.YColor = viewerForegroundColor('get');
        axePlotKernelDistance.ZColor = viewerForegroundColor('get');

        axePlotKernelDistance.Title.Color = viewerForegroundColor('get');
        axePlotKernelDistance.Color = viewerAxesColor('get');

        cDataCursor = datacursormode(figPlotKernelDistance);
        cDataCursor.UpdateFcn = @displayCursorCoordinates;
        set(cDataCursor, 'Enable', 'on');

        dTip = createDatatip(cDataCursor, pDistancePlot);

        [~, dIndex] = min(abs(pDistancePlot.XData-dDistance));

%        dIndex = find(pDistancePlot.XData == dDistance);

        xPosition = pDistancePlot.XData(dIndex);
        yPosition = pDistancePlot.YData(dIndex);

        dTip.Position = [xPosition yPosition];

        function txt = displayCursorCoordinates(~,info)
            x = info.Position(1);
            y = info.Position(2);
            txt = ['(' num2str(x) ', ' num2str(y) ')'];

            set(uiEditKernelCutoff, 'String', num2str(x));

            kernelCutoff('set', x);
        end

    end

    function editKernelCutoffCallback(~, ~)

        dDistance = str2double(get(uiEditKernelCutoff, 'string'));

        % Get kernel details

        dModel    = get(uiKernelModel   , 'Value');

        dTissue   = get(uiKernelTissue , 'Value' );
        asTissue  = get(uiKernelTissue , 'String');

        dIsotope  = get(uiKernelIsotope, 'Value' );
        asIsotope = get(uiKernelIsotope, 'String');

        tKernel = tDoseKernel.Kernel{dModel}.(asTissue{dTissue}).(asIsotope{dIsotope});

        asField = fieldnames(tKernel);

        if numel(asField) == 2
            aDistance = tKernel.(asField{1});
%            aDoseR2   = tKernel.(asField{2});
        else
            return;
        end

        [~, dIndex] = min(abs(aDistance-dDistance));
        dKernelCutoff = aDistance(dIndex);

        kernelCutoff('set', dKernelCutoff);

        set(uiEditKernelCutoff, 'string', num2str(dKernelCutoff));
    end

    function chkMicrosphereInSpecimenCallback(hObject, ~)

       if get(chkMicrosphereInSpecimen, 'Value') == 1
           if strcmpi(hObject.Style, 'checkbox')
                set(chkMicrosphereInSpecimen, 'Value', 1);
            else
                set(chkMicrosphereInSpecimen, 'Value', 0);
           end
        else
           if strcmpi(hObject.Style, 'checkbox')
                set(chkMicrosphereInSpecimen, 'Value', 0);
            else
                set(chkMicrosphereInSpecimen, 'Value', 1);
           end
       end

       kernelMicrosphereInSpecimen('set', get(chkMicrosphereInSpecimen, 'Value'));

    end

    function doseKernelCallback(~, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        try
            % Dectivate uipanel

            set(uiKernelMethod       , 'Enable', 'off');
            set(uiKernelTissue       , 'Enable', 'off');
            set(uiKernelIsotope      , 'Enable', 'off');
            set(uiKernelModel        , 'Enable', 'off');
            set(uiKernelInterpolation, 'Enable', 'off');
            set(uiDoseKernelPanel    , 'Enable', 'off');
            set(uiEditKernelCutoff   , 'Enable', 'off');
            set(uiPlotDistance       , 'Enable', 'off');

            dMethod  = get(uiKernelMethod, 'Value');
            asMethod = get(uiKernelMethod, 'String');
            sMethod  = asMethod{dMethod};

            dModel    = get(uiKernelModel   , 'Value');

            dTissue   = get(uiKernelTissue , 'Value' );
            asTissue  = get(uiKernelTissue , 'String');

            dIsotope  = get(uiKernelIsotope , 'Value' );
            asIsotope = get(uiKernelIsotope, 'String');

            asKernelInterpolation = get(uiKernelInterpolation, 'String');
            dInterpolationValue   = get(uiKernelInterpolation, 'Value');

            dKernelKernelCutoffDistance = str2double(get(uiEditKernelCutoff, 'String'));

            bUseCtMap = get(chkUseCTdoseMapKernel, 'Value'); % CT Guided
            dCtOffset = get(uiKernelSeries, 'Value');

            setDoseKernel(sMethod,  ...
                          dModel, ...
                          asTissue{dTissue}, ...
                          asIsotope{dIsotope}, ...
                          dKernelKernelCutoffDistance, ...
                          asKernelInterpolation{dInterpolationValue}, ...
                          bUseCtMap, ...
                          dCtOffset, ...
                          true);

            setColorbarLabel();

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error: An error occur during kernel processing!');

            f = msgbox('Error: doseKernelCallback(): An error occur during kernel processing!', 'Error');
            setObjectIcon(f);

%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

        % Activate uipanel

        if isvalid(uiKernelMethod)
              set(uiKernelMethod, 'Enable', 'on');
        end

        if isvalid(uiKernelTissue)

            set(uiKernelTissue, 'Enable', 'on');
        end

        if isvalid(uiKernelIsotope)

            set(uiKernelIsotope, 'Enable', 'on');
        end

        if isvalid(uiKernelModel)
            set(uiKernelModel, 'Enable', 'on');
        end

        if isvalid(uiKernelInterpolation)
            set(uiKernelInterpolation, 'Enable', 'on');
        end

        if isvalid(uiDoseKernelPanel)
            set(uiDoseKernelPanel, 'Enable', 'on');
        end

        if isvalid(uiEditKernelCutoff)
            set(uiEditKernelCutoff, 'Enable', 'on');
        end

        if isvalid(uiPlotDistance)
            set(uiPlotDistance       , 'Enable', 'on');
        end


    end

    function gaussFilterCallback(~, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        if switchTo3DMode('get')     == true ||  ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            return;
        end

        tInput = inputTemplate('get');

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(tInput)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        aBuffer = dicomBuffer('get', [], dSeriesOffset);

        x = str2double(get(edtGaussFilterX, 'String'));
        y = str2double(get(edtGaussFilterY, 'String'));
        z = str2double(get(edtGaussFilterZ, 'String'));

        atCoreMetaData = dicomMetaData('get');

        if x <= 0
            set(edtGaussFilterX, 'String', '0.1');
            x = 0.1;
        end

        if y <= 0
            set(edtGaussFilterY, 'String', '0.1');
            y = 0.1;
        end

        if z <= 0
            set(edtGaussFilterZ, 'String', '0.1');
            z = 0.1;
        end

        sigmaX = x/atCoreMetaData{1}.PixelSpacing(1);
        sigmaY = y/atCoreMetaData{1}.PixelSpacing(2);

        if size(aBuffer, 3) == 1
            sigmaZ = 1;
        else
            dComputed = computeSliceSpacing(atCoreMetaData);
            if dComputed == 0
                sigmaZ = z/1;
            else
                sigmaZ = z/dComputed;
           end
        end

%        if strcmp(imageOrientation('get'), 'coronal')
%            xPixel = sigmaX;
%            yPixel = sigmaZ;
%            zPixel = sigmaY;
%        end
%        if strcmp(imageOrientation('get'), 'sagittal')
%            xPixel = sigmaY;
%            yPixel = sigmaZ;
%            zPixel = sigmaX;
%        end
%        if strcmp(imageOrientation('get'), 'axial')
            xPixel = sigmaX;
            yPixel = sigmaY;
            zPixel = sigmaZ;
%        end

        aActivity = imgaussfilt3(aBuffer,[xPixel,yPixel,zPixel]);

        % Apply ROI constraint

        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

        bInvertMask = invertConstraint('get');

        tRoiInput = roiTemplate('get', dSeriesOffset);

        aLogicalMask = roiConstraintToMask(aBuffer, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);

        aActivity(aLogicalMask==0) = aBuffer(aLogicalMask==0); % Set constraint

        dicomBuffer('set', aActivity);

        setColorbarLabel();

        refreshImages();

        modifiedMatrixValueMenuOption('set', true);

        clear aActivity;
        clear aBuffer;

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:setDoseKernel()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function resetKernelCallback(~, ~)

        try

        % Deactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'off');
        mainToolBarEnable('off');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        resetSeries(get(uiSeriesPtr('get'), 'Value'), true);

        progressBar(1, 'Ready');

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:resetKernelCallback()');
        end

        % Reactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'on');
        mainToolBarEnable('on');

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

end
