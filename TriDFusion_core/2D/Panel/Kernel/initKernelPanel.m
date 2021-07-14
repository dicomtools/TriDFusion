function initKernelPanel()
%function initKernelPanel()
%Kernel Panel Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        Brad Beattie, beattieb@mskcc.org
%        C. Ross Schmidtlein, schmidtr@mskcc.org
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
                  'Position',[15 510 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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
                  'position', [15 460 200 20]...
                  );

      uiRoiVoiKernelPanel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [95 430 165 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable'  , 'off', ...
                  'Callback', @segActionKernelPanelCallback...
                  );
     uiRoiVoiKernelPanelObject('set', uiRoiVoiKernelPanel);

     if size(aBuffer, 3) == 1
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI'};
     else
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI', 'Inside all slices ROI\VOI', 'Outside all slices ROI\VOI'};
     end

     uiSegActKernelPanel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 430 75 20],...
                  'String'  , asSegOptions, ...
                  'Value'   , 1,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @segActionKernelPanelCallback...
                  );
    uiSegActKernelPanelObject('set', uiSegActKernelPanel);

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
                  'position', [15 400 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUseCTdoseMapKernelCallback...
                  );

    txtUseCTdoseMapKernel = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Use CT Map',...
                  'horizontalalignment', 'left',...
                  'position', [35 397 200 20],...
                  'Enable', sTxtUseCTdoseMapEnable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUseCTdoseMapKernelCallback...
                  );

    uiKernelSeries = ...
         uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 365 245 25], ...
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
                  'position', [15 340 20 20],...
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
                  'position', [35 337 200 20],...
                  'Enable', 'On',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUnitTypeKernelCallback...
                  );

    uiTxtUpperTreshold = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 315 200 20]...
                  );
    txtKernelVoiRoiUpperTresholdObject('set', uiTxtUpperTreshold);

    uiSliderKernelUpperTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 300 175 14], ...
                  'Value'   , kernelSegTreshValue('get', 'upper'), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderKernelUpperTreshCallback ...
                  );
%    addlistener(uiSliderKernelUpperTreshold,'Value','PreSet',@sliderKernelUpperTreshCallback);
    sliderKernelVoiRoiUpperTresholdObject('set', uiSliderKernelUpperTreshold);

    uiEditKernelUpperTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 300 65 20], ...
                  'String'  , num2str(dUpperValue), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editKernelUpperTreshCallback ...
                  );
    editKernelVoiRoiUpperTresholdObject('set', uiEditKernelUpperTreshold);

        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'on', ...
                  'string'  , 'Lower Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 270 200 20]...
                  );

    uiSliderKernelLowerTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 255 175 14], ...
                  'Value'   , kernelSegTreshValue('get', 'lower'), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderKernelLowerTreshCallback ...
                  );
%    lstSliderKernelLowerTresh = addlistener(uiSliderKernelLowerTreshold,'Value','PreSet',@sliderKernelLowerTreshCallback);

    uiEditKernelLowerTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 255 65 20], ...
                  'String'  ,  num2str(dLowerValue), ...
                  'Enable'  , sUseCtDoseMapEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editKernelLowerTreshCallback ...
                  );
    editKernelVoiRoiLowerTresholdObject('set', uiEditKernelLowerTreshold);

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , 'On', ...
                  'style'   , 'text',...
                  'string'  , 'Kernel Model',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 222 125 20]...
                  );

    uiKernelModel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 225 125 20],...
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
                  'position', [15 197 125 20]...
                  );

    uiKernelTissue = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 200 125 20],...
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
                  'position', [15 172 125 20]...
                  );

    uiKernelIsotope = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 175 125 20],...
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

        uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'String', 'Apply',...
                  'Position',[160 140 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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

        set(uiEditKernelUpperTreshold, 'String', num2str(dUpperValue));
        set(uiEditKernelLowerTreshold, 'String', num2str(dLowerValue));

        kernelSegTreshValue('get', 'upper', 1);
        kernelSegTreshValue('get', 'lower', 0);

        set(uiSliderKernelUpperTreshold, 'Value', 1);
        set(uiSliderKernelLowerTreshold, 'Value', 0);

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
            set(uiSliderKernelUpperTreshold, 'Enable', 'On');
            set(uiEditKernelUpperTreshold  , 'Enable', 'On');
            set(uiSliderKernelLowerTreshold, 'Enable', 'On');
            set(uiEditKernelLowerTreshold  , 'Enable', 'On');
        else
            set(txtUnitTypeKernel          , 'Enable', 'On');
            set(chkUnitTypeKernel          , 'Enable', 'Off');
            set(uiKernelSeries             , 'Enable', 'Off');
            set(uiSliderKernelUpperTreshold, 'Enable', 'Off');
            set(uiEditKernelUpperTreshold  , 'Enable', 'Off');
            set(uiSliderKernelLowerTreshold, 'Enable', 'Off');
            set(uiEditKernelLowerTreshold  , 'Enable', 'Off');
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

        set(uiEditKernelUpperTreshold, 'String', num2str(dUpperValue));
        set(uiEditKernelLowerTreshold, 'String', num2str(dLowerValue));

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

        aRefBuffer = dicomBuffer('get');
        atRefMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dCtOffset = get(uiKernelSeries, 'Value');

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');

        set(uiSeriesPtr('get'), 'Value', tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

        aCtBuffer = dicomBuffer('get');

        atCtMetaData = dicomMetaData('get');
        if isempty(atCtMetaData)

            atCtMetaData = tInput(tKernelCtDoseMap{dCtOffset}.dSeriesNumber).atDicomInfo;
            dicomMetaData('set', atCtMetaData);
        end

        if isempty(aCtBuffer)

            aInput = inputBuffer('get');
            aCtBuffer = aInput{tKernelCtDoseMap{dCtOffset}.dSeriesNumber};
            if strcmp(imageOrientation('get'), 'coronal')
                aCtBuffer = permute(aCtBuffer, [3 2 1]);
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aCtBuffer = permute(aCtBuffer, [2 3 1]);
            else
                aCtBuffer = permute(aCtBuffer, [1 2 3]);
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

            dicomBuffer('set', aCtBuffer);

        end

        set(uiSeriesPtr('get'), 'Value', dSerieOffset);

        dUpperValue = str2double( get(uiEditKernelUpperTreshold, 'String') );
        dLowerValue = str2double( get(uiEditKernelLowerTreshold, 'String') );
        if get(chkUnitTypeKernel, 'Value') == true
            [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
        end

        dCtMIn = min(double(aCtBuffer),[], 'all');

        aCtBuffer(aCtBuffer<=dLowerValue) = dCtMIn;
        aCtBuffer(aCtBuffer>=dUpperValue) = dCtMIn;

        aCtBuffer(aCtBuffer==dCtMIn)=0;
        aCtBuffer(aCtBuffer~=0)=1;

        [aResamCt, ~] = resampleImage(aCtBuffer, atCtMetaData, aRefBuffer, atRefMetaData, 'Linear', false);

        uiSegActString = get(uiSegActKernelPanel, 'String');
        uiSegActValue  = get(uiSegActKernelPanel, 'Value' );
        sActionType = uiSegActString{uiSegActValue};

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );

        dResampMIn = min(double(aResamCt),[], 'all');

        if ~strcmpi(sActionType, 'Entire Image')

            uiRoiVoiKernelValue = get(uiRoiVoiKernelPanel, 'Value');

            aobjList = '';

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput)
                for aa=1:numel(tVoiInput)
                    aobjList{numel(aobjList)+1} = tVoiInput{aa};
                end
            end

            if ~isempty(tRoiInput)
                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        aobjList{numel(aobjList)+1} = tRoiInput{cc};
                    end
                end
            end

            if strcmpi(aobjList{uiRoiVoiKernelValue}.ObjectType, 'voi')

                dNbRois = numel(aobjList{uiRoiVoiKernelValue}.RoisTag);

                aVoiBuffer = zeros(size(aResamCt));

                for bb=1:dNbRois

                    for cc=1:numel(tRoiInput)
                        if isvalid(tRoiInput{cc}.Object) && ...
                            strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiKernelValue}.RoisTag{bb})

                            objRoi   = tRoiInput{cc}.Object;
                            dSliceNb = tRoiInput{cc}.SliceNb;

                            switch objRoi.Parent

                                case axes1Ptr('get')
                                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                       strcmpi(sActionType, 'Outside ROI\VOI')

                                        if dSliceNb == iCoronal
                                            aSlice =  permute(aResamCt(dSliceNb,:,:), [3 2 1]);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  permute(aVoiBuffer(dSliceNb,:,:), [3 2 1]);
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);

                                        end
                                    else
                                        for ccc=1:size(aResamCt, 1)

                                            aSlice = permute(aResamCt(ccc,:,:), [3 2 1]);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  permute(aVoiBuffer(dSliceNb,:,:), [3 2 1]);
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(ccc,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                        end
                                    end

                                case axes2Ptr('get')

                                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                       strcmpi(sActionType, 'Outside ROI\VOI')

                                        if dSliceNb == iSagittal
                                            aSlice = permute(aResamCt(:,dSliceNb,:), [3 1 2]);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  permute(aVoiBuffer(:,dSliceNb,:), [3 1 2]);
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                        end
                                    else
                                        for sss=1:size(aResamCt, 2)
                                            aSlice = permute(aResamCt(:,sss,:), [3 1 2]);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  permute(aVoiBuffer(:,dSliceNb,:), [3 1 2]);
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(:,sss,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                        end
                                    end

                                case axes3Ptr('get')
                                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                       strcmpi(sActionType, 'Outside ROI\VOI')

                                        aSlice = aResamCt(:,:,dSliceNb);
                                        roiMask = createMask(objRoi, aSlice);

                                        aSlice( roiMask) =1;
                                        aSlice(~roiMask) =0;

                                        aSliceMask =  aVoiBuffer(:,:,dSliceNb);
                                        aVoiBuffer(:,:,dSliceNb) = aSlice|aSliceMask;
                                    else
                                        for aaa=1:size(aResamCt, 3)
                                            aSlice = aResamCt(:,:,aaa);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  aVoiBuffer(:,:,dSliceNb);
                                            aVoiBuffer(:,:,aaa) = aSlice|aSliceMask;
                                        end
                                    end
                            end
                        end
                    end
                end

            else
                objRoi   = aobjList{uiRoiVoiKernelValue}.Object;
                dSliceNb = aobjList{uiRoiVoiKernelValue}.SliceNb;

                aVoiBuffer = zeros(size(aResamCt));

                switch objRoi.Parent

                    case axes1Ptr('get')

                        if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                           strcmpi(sActionType, 'Outside all slices ROI\VOI')
                            for cc=1:size(aResamCt, 1)

                                aSlice = permute(aResamCt(cc,:,:), [3 2 1]);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(cc,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                            end
                        else
                            aSlice = permute(aResamCt(dSliceNb,:,:), [3 2 1]);
                            roiMask = createMask(objRoi, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                        end

                    case axes2Ptr('get')

                        if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                           strcmpi(sActionType, 'Outside all slices ROI\VOI')

                            for ss=1:size(aResamCt, 2)
                                aSlice = permute(aResamCt(:,ss,:), [3 1 2]);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(:,ss,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                            end
                        else
                            aSlice = permute(aResamCt(:,dSliceNb,:), [3 1 2]);
                            roiMask = createMask(objRoi, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                        end

                    case axes3Ptr('get')

                        if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                           strcmpi(sActionType, 'Outside all slices ROI\VOI')

                            for aa=1:size(aResamCt, 3)
                                aSlice = aResamCt(:,:,aa);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(:,:,aa) = aSlice;
                            end
                        else
                            aSlice = aResamCt(:,:,dSliceNb);
                            roiMask = createMask(objRoi, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aVoiBuffer(:,:,dSliceNb) = aSlice;
                        end
                end
            end

            if strcmpi(sActionType, 'Outside ROI\VOI') || ...
               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                aVoiBuffer = ~aVoiBuffer;
            end

            aResamCt(aVoiBuffer == 0) = dResampMIn; % Apply Mask

        end

        aResamCt(aResamCt==dResampMIn)=0;
        aResamCt(aResamCt~=0)=1;

        aCtCoronal  =  permute(aResamCt(iCoronal,:,:), [3 2 1]);
        aCtSagittal =  permute(aResamCt(:,iSagittal,:), [3 1 2]);
        aCtAxial    =  aResamCt(:,:,iAxial);

        [maskCoronal ,~,~,~] = bwboundaries(aCtCoronal , 'holes', 8);
        [maskSagittal,~,~,~] = bwboundaries(aCtSagittal, 'holes', 8);
        [maskAxial   ,~,~,~] = bwboundaries(aCtAxial   , 'holes', 8);

        if ~isempty(maskCoronal)
            vBoundAxes1Ptr = visboundaries(axes1Ptr('get'), maskCoronal );
            visBoundAxes1Ptr('set', vBoundAxes1Ptr);
        end

        if ~isempty(maskSagittal)
            vBoundAxes2Ptr = visboundaries(axes2Ptr('get'), maskSagittal );
            visBoundAxes2Ptr('set', vBoundAxes2Ptr);
        end

        if ~isempty(maskAxial)
            vBoundAxes3Ptr = visboundaries(axes3Ptr('get'), maskAxial );
            visBoundAxes3Ptr('set', vBoundAxes3Ptr);
        end

        catch
            progressBar(1, 'Error:previewCTdoseMapKernel()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function editKernelLowerTreshCallback(~, ~)

        dUpperTreshold = str2double(get(uiEditKernelUpperTreshold, 'String'));

        dLowerTreshold = str2double(get(uiEditKernelLowerTreshold, 'String'));
        if isnan(dLowerTreshold)
            dLowerTreshold = kernelSegEditValue('get', 'lower');
            set(uiEditKernelLowerTreshold, 'String', num2str(dLowerTreshold));
        end

        if dLowerTreshold > dUpperTreshold
            dLowerTreshold = dUpperTreshold;
            set(uiEditKernelLowerTreshold, 'String', num2str(dLowerTreshold));
        end

        if get(chkUnitTypeKernel, 'Value') == true
            [~, dLowerTreshold] = computeWindowLevel(dUpperTreshold, dLowerTreshold);
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        if dLowerTreshold < dMinValue
            dLowerTreshold = dMinValue;
            set(uiEditKernelLowerTreshold, 'String', num2str(dLowerTreshold));
        end

        dDiff = dMaxValue - dMinValue;
        dLowerSliderValue = (dLowerTreshold-dMinValue)/dDiff;

        set(uiSliderKernelLowerTreshold, 'Value', dLowerSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            [~, dCTLevel] = computeWindowMinMax(dUpperTreshold, dLowerTreshold);
            dLowerTreshold = dCTLevel;
        end

        kernelSegTreshValue('set', 'lower', dLowerSliderValue);
        kernelSegEditValue('set', 'lower', dLowerTreshold);

        previewCTdoseMapKernel();

    end

    function editKernelUpperTreshCallback(~, ~)

        dLowerTreshold = str2double(get(uiEditKernelLowerTreshold, 'String'));

        dUpperTreshold = str2double(get(uiEditKernelUpperTreshold, 'String'));
        if isnan(dUpperTreshold)
            dUpperTreshold = kernelSegEditValue('get', 'upper');
            set(uiEditKernelUpperTreshold, 'String', num2str(dUpperTreshold));
        end

        if dUpperTreshold < dLowerTreshold
            dUpperTreshold = dLowerTreshold;
            set(uiEditKernelUpperTreshold, 'String', num2str(dUpperTreshold));
        end

        if get(chkUnitTypeKernel, 'Value') == true
            [dUpperTreshold, ~] = computeWindowLevel(dUpperTreshold, dLowerTreshold);
        end

        dSerieOffset = get(uiKernelSeries, 'Value');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        dMaxValue = tKernelCtDoseMap{dSerieOffset}.dMax;
        dMinValue = tKernelCtDoseMap{dSerieOffset}.dMin;

        if dUpperTreshold > dMaxValue
            dUpperTreshold = dMaxValue;
            set(uiEditKernelUpperTreshold, 'String', num2str(dUpperTreshold));
        end

        dDiff = dMaxValue - dMinValue;
        dUpperSliderValue = (dUpperTreshold-dMinValue)/dDiff;

        set(uiSliderKernelUpperTreshold, 'Value', dUpperSliderValue);

        if get(chkUnitTypeKernel, 'Value') == true
            [dCTWindow, ~] = computeWindowMinMax(dUpperTreshold, dLowerTreshold);
            dUpperTreshold = dCTWindow;
        end

        kernelSegTreshValue('set', 'upper', dUpperSliderValue);
        kernelSegEditValue('set', 'upper', dUpperTreshold);

        previewCTdoseMapKernel();
    end

    function sliderKernelUpperTreshCallback(~, ~)

        dUpperSliderValue = get(uiSliderKernelUpperTreshold, 'Value');
        dLowerSliderValue = get(uiSliderKernelLowerTreshold, 'Value');

        if dUpperSliderValue < dLowerSliderValue
            set(uiSliderKernelUpperTreshold, 'Value', dLowerSliderValue);
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

        set(uiEditKernelUpperTreshold, 'String', num2str(dUpperValue));

        previewCTdoseMapKernel();

    end

    function sliderKernelLowerTreshCallback(~, ~)

        dUpperSliderValue = get(uiSliderKernelUpperTreshold, 'Value');
        dLowerSliderValue = get(uiSliderKernelLowerTreshold, 'Value');

        if dLowerSliderValue > dUpperSliderValue
            set(uiSliderKernelLowerTreshold, 'Value', dUpperSliderValue);
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

        set(uiEditKernelLowerTreshold, 'String', num2str(dLowerValue));

        previewCTdoseMapKernel();

    end

    function segActionKernelPanelCallback(~, ~)

        setVoiRoiSegPopup();
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
    end

    function doseKernelCallback(hObject, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        set(uiRoiVoiKernelPanel, 'Enable', 'off');
        set(uiSegActKernelPanel, 'Enable', 'off');

        set(uiKernelTissue , 'Enable', 'off');
        set(uiKernelIsotope, 'Enable', 'off');
        set(uiKernelModel  , 'Enable', 'off');
        set(hObject        , 'Enable', 'off');

        try
            setDoseKernel();
        catch
            progressBar(1, 'Error: An error occur during kernel processing!');
            h = msgbox('Error: doseKernelCallback(): An error occur during kernel processing!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end

        uiSegActString = get(uiSegActKernelPanel, 'String');
        uiSegActValue  = get(uiSegActKernelPanel, 'Value' );

        if ~strcmpi(uiSegActString{uiSegActValue}, 'Entire Image')
            set(uiRoiVoiKernelPanel, 'Enable', 'on');
        end
        set(uiSegActKernelPanel, 'Enable', 'on');

        set(uiKernelTissue , 'Enable', 'on');
        set(uiKernelIsotope, 'Enable', 'on');
        set(uiKernelModel  , 'Enable', 'on');
        set(hObject        , 'Enable', 'on');

        function setDoseKernel()

            tInput = inputTemplate('get');

            dOffset = get(uiSeriesPtr('get'), 'Value');
            if dOffset > numel(tInput)
                return;
            end

            if switchTo3DMode('get')     == true ||  ...
               switchToIsoSurface('get') == true || ...
               switchToMIPMode('get')    == true

                return;
            end

            if isempty(dicomBuffer('get'))
                return;
            end

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

            tInput(dOffset).bDoseKernel = false;
            if numel(tInput) == 1 && isFusion('get') == false
                tInput(dOffset).bFusedDoseKernel = false;
            end

            progressBar(0.999, 'Processing kernel, please wait');

            dModel    = get(uiKernelModel   , 'Value');

            dTissue   = get(uiKernelTissue , 'Value' );
            asTissue  = get(uiKernelTissue , 'String');

            dIsotope  = get(uiKernelIsotope , 'Value' );
            asIsotope = get(uiKernelIsotope, 'String');

            tKernel = tDoseKernel.Kernel{dModel}.(asTissue{dTissue}).(asIsotope{dIsotope});

            asField = fieldnames(tKernel);

            if numel(asField) == 2
                aDistance = tKernel.(asField{1});
                aDoseR2   = tKernel.(asField{2});
            end

            aActivity = double(dicomBuffer('get'));

            uiSegActString = get(uiSegActKernelPanel, 'String');
            uiSegActValue  = get(uiSegActKernelPanel, 'Value' );
            sActionType = uiSegActString{uiSegActValue};

            if ~strcmpi(sActionType, 'Entire Image')

                uiRoiVoiKernelValue = get(uiRoiVoiKernelPanel, 'Value');

                aobjList = '';

                tRoiInput = roiTemplate('get');
                tVoiInput = voiTemplate('get');

                if ~isempty(tVoiInput)
                    for aa=1:numel(tVoiInput)
                        aobjList{numel(aobjList)+1} = tVoiInput{aa};
                    end
                end

                if ~isempty(tRoiInput)
                    for cc=1:numel(tRoiInput)
                        if isvalid(tRoiInput{cc}.Object)
                            aobjList{numel(aobjList)+1} = tRoiInput{cc};
                        end
                    end
                end

                if strcmpi(aobjList{uiRoiVoiKernelValue}.ObjectType, 'voi')

                    dNbRois = numel(aobjList{uiRoiVoiKernelValue}.RoisTag);

                    aVoiBuffer = zeros(size(aActivity));

                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiKernelValue}.RoisTag{bb})

                                objRoi   = tRoiInput{cc}.Object;
                                dSliceNb = tRoiInput{cc}.SliceNb;

                                switch objRoi.Parent

                                    case axes1Ptr('get')
                                        if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                           strcmpi(sActionType, 'Outside ROI\VOI')

                                            if dSliceNb == iCoronal
                                                aSlice =  permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                                roiMask = createMask(objRoi, aSlice);

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;

                                                aSliceMask =  permute(aVoiBuffer(dSliceNb,:,:), [3 2 1]);
                                                aSlice = aSlice|aSliceMask;
                                                aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);

                                            end
                                        else
                                            for ccc=1:size(aBuffer, 1)

                                                aSlice = permute(aBuffer(ccc,:,:), [3 2 1]);
                                                roiMask = createMask(objRoi, aSlice);

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;

                                                aSliceMask =  permute(aVoiBuffer(dSliceNb,:,:), [3 2 1]);
                                                aSlice = aSlice|aSliceMask;
                                                aVoiBuffer(ccc,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                            end
                                        end

                                    case axes2Ptr('get')

                                        if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                           strcmpi(sActionType, 'Outside ROI\VOI')

                                            if dSliceNb == iSagittal
                                                aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                                roiMask = createMask(objRoi, aSlice);

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;

                                                aSliceMask =  permute(aVoiBuffer(:,dSliceNb,:), [3 1 2]);
                                                aSlice = aSlice|aSliceMask;
                                                aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                            end
                                        else
                                            for sss=1:size(aBuffer, 2)
                                                aSlice = permute(aBuffer(:,sss,:), [3 1 2]);
                                                roiMask = createMask(objRoi, aSlice);

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;

                                                aSliceMask =  permute(aVoiBuffer(:,dSliceNb,:), [3 1 2]);
                                                aSlice = aSlice|aSliceMask;
                                                aVoiBuffer(:,sss,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                            end
                                        end

                                    case axes3Ptr('get')
                                        if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                           strcmpi(sActionType, 'Outside ROI\VOI')

                                            aSlice = aBuffer(:,:,dSliceNb);
                                            roiMask = createMask(objRoi, aSlice);

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;

                                            aSliceMask =  aVoiBuffer(:,:,dSliceNb);
                                            aVoiBuffer(:,:,dSliceNb) = aSlice|aSliceMask;
                                        else
                                            for aaa=1:size(aBuffer, 3)
                                                aSlice = aBuffer(:,:,aaa);
                                                roiMask = createMask(objRoi, aSlice);

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;

                                                aSliceMask =  aVoiBuffer(:,:,dSliceNb);
                                                aVoiBuffer(:,:,aaa) = aSlice|aSliceMask;
                                            end
                                        end
                                end
                            end
                        end
                    end
                else
                    objRoi   = aobjList{uiRoiVoiKernelValue}.Object;
                    dSliceNb = aobjList{uiRoiVoiKernelValue}.SliceNb;

                    aVoiBuffer = zeros(size(aBuffer));

                    switch objRoi.Parent

                        case axes1Ptr('get')

                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                                for cc=1:size(aBuffer, 1)

                                    aSlice = permute(aBuffer(cc,:,:), [3 2 1]);
                                    roiMask = createMask(objRoi, aSlice);

                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aVoiBuffer(cc,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                end
                            else
                                aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                            end

                        case axes2Ptr('get')

                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')

                                for ss=1:size(aBuffer, 2)
                                    aSlice = permute(aBuffer(:,ss,:), [3 1 2]);
                                    roiMask = createMask(objRoi, aSlice);

                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aVoiBuffer(:,ss,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                end
                            else
                                aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                            end

                        case axes3Ptr('get')

                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')

                                for aa=1:size(aBuffer, 3)
                                    aSlice = aBuffer(:,:,aa);
                                    roiMask = createMask(objRoi, aSlice);

                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aVoiBuffer(:,:,aa) = aSlice;
                                end
                            else
                                aSlice = aBuffer(:,:,dSliceNb);
                                roiMask = createMask(objRoi, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aVoiBuffer(:,:,dSliceNb) = aSlice;
                            end
                    end
                end

                if strcmpi(sActionType, 'Outside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside all slices ROI\VOI')
                    aVoiBuffer = ~aVoiBuffer;
                end

            end

            % For radioembolization using microspheres loaded with isotope with half-life T1/2
            % 1)	From PET image – Activity A in kBq for each voxel at time of scan: Ascan= Bq/mL * Vvox(mL)
            % 2)	Activity at injection of microspheres: A0=A*2[(Tscan-Tinjection)/T1/2]
            % 3)	Calculate the total number of disintegrations in the voxel  [Bq * s] =
            % = Cumulative activity Acum= A0 * T1/2(s) / ln(2) = A0 (Bq) *1.442695* T1/2 (s)
            % 4)	Calculate total number of beta-particles (e.g. beta) using the yield Yb
            % Nb= Acum * Yb
            % 5)	Nb,scaled = Nb/(4*107  )    ; (4*10^7 primaries used per George Kagadis e-mail 5-14-20)

            % 6)	Cumulative Dose to point at distance r (mm), D(r) = Nb,scaled * DPKr2(r) / r2

            % For Y-90:
            % T1/2 = 2.6684 d
            % Yb = 1.0

            % Note for non-microsphere tracers:  There will be:
            % - uptake curve which will change step 2
            % - effective half-life due to biological clearance which will change step 3 and trapezoidal integration may be used instead

            atCoreMetaData = dicomMetaData('get');

            sigmaX = atCoreMetaData{1}.PixelSpacing(1)/10;
            sigmaY = atCoreMetaData{1}.PixelSpacing(2)/10;
            sigmaZ = computeSliceSpacing(atCoreMetaData)/10;

            if strcmp(imageOrientation('get'), 'coronal')
                xPixel = sigmaX;
                yPixel = sigmaZ;
                zPixel = sigmaY;
            end
            if strcmp(imageOrientation('get'), 'sagittal')
                xPixel = sigmaY;
                yPixel = sigmaZ;
                zPixel = sigmaX;
            end
            if strcmp(imageOrientation('get'), 'axial')
                xPixel = sigmaX;
                yPixel = sigmaY;
                zPixel = sigmaZ;
            end

            if isempty(atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime)

                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;

                progressBar(1, 'Error: Dose RadiopharmaceuticalStartDateTime is missing!');
                h = msgbox('Error: setDoseKernel(): Dose RadiopharmaceuticalStartDateTime is missing!', 'Error');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                return;
            end

            injDateTime = atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
            acqTime     = atCoreMetaData{1}.SeriesTime;
            acqDate     = atCoreMetaData{1}.SeriesDate;
            halfLife    = str2double(atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);

            for jj=1:numel(atCoreMetaData)
                if isfield(atCoreMetaData{jj}, 'RescaleSlope')
                    atCoreMetaData{jj}.RescaleSlope = 1;
                end
                if isfield(atCoreMetaData{jj}, 'RescaleIntercept')
                    atCoreMetaData{jj}.RescaleIntercept = 0;
                end
                if isfield(atCoreMetaData{jj}, 'Units')
                    atCoreMetaData{jj}.Units = 'DOSE';
                end
            end

            dicomMetaData('set', atCoreMetaData);

            if numel(injDateTime) == 14
                injDateTime = sprintf('%s.00', injDateTime);
            end

            datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
            dateInjDate = datenum(datetimeInjDate);

            if numel(acqTime) == 6
                acqTime = sprintf('%s.00', acqTime);
            end

            datetimeAcqDate = datetime([acqDate acqTime],'InputFormat','yyyyMMddHHmmss.SS');
            dayAcqDate = datenum(datetimeAcqDate);

            relT = (dayAcqDate - dateInjDate)*(24*60*60); % Acquisition start time

            switch lower(asIsotope{dIsotope})
                case 'y90'
                    betaYield = 1; %Beta yield Y-90
                    betaFactor = 4E7; % To double check

                case 'i124'
                    betaYield = 0.92; %Beta yield I124
                    betaFactor = 4E7;

                otherwise

                    set(fiMainWindowPtr('get'), 'Pointer', 'default');
                    drawnow;

                     progressBar(1, 'Error: This isotope is not yet validated!');
                     h = msgbox('Error: setDoseKernel(): This isotope is not yet validated!', 'Error');
%                     if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                     else
%                        sLogo = './logo.png';
%                     end

%                     javaFrame = get(h, 'JavaFrame');
%                     javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                     return;

             end

%                     aActivity = aActivity*xPixel*yPixel*zPixel; % in mm
             aActivity = aActivity*xPixel*yPixel*zPixel/1000; % in cm
             aActivity = aActivity*2^(relT/halfLife)*halfLife/log(2)*betaYield/betaFactor; %%%To double check

%             aDose = zeros(numel(aDoseR2),1);
%             for kk=1:numel(aDoseR2)
%                 aDose(kk) = aDoseR2(kk)/aDistance(kk)^2;
%             end
            aDose = aDoseR2./aDistance.^2;

if 0
            dMax = max(aDose, [], 'all')/1000;
            aVector = find(aDose<dMax);

            dFirst = aVector(1);

            dDistance = aDistance(dFirst);
else

%            dMax = max(aDose, [], 'all')/10;
%            aVector = find(aDose<dMax);

%            dFirst = aVector(1);

%            dDistance = aDistance(dFirst);
            dDistance = max(aDistance, [], 'all')/10;

end

            aXYZPixel = zeros(3,1);
            aXYZPixel(1)=xPixel;
            aXYZPixel(2)=yPixel;
            aXYZPixel(3)=zPixel;

            fromTo = ceil(dDistance/min(aXYZPixel, [], 'all'));
            from = -abs(fromTo);
            to = abs(fromTo);
            [X,Y,Z] = meshgrid(from:to,from:to,from:to);

            distanceMatrix = sqrt((X*xPixel).^2+(Y*yPixel).^2+(Z*zPixel).^2);
            vqKernel = interp1(aDistance, aDose, distanceMatrix, 'linear', 'extrap'); %%% Linear, cubic, nearest...
            doseBuffer = convn(aActivity, vqKernel, 'same');

            if ~strcmpi(sActionType, 'Entire Image')
                aBuffer = dicomBuffer('get');
                doseBuffer(aVoiBuffer==0) = aBuffer(aVoiBuffer==0);
            end

            bUseCtMap = get(chkUseCTdoseMapKernel, 'Value'); % CT Guided
            if bUseCtMap == true

                aRefBuffer = dicomBuffer('get');
                atRefMetaData = dicomMetaData('get');

                tInput = inputTemplate('get');

                tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

                dCtOffset = get(uiKernelSeries, 'Value');

                dSerieOffset = get(uiSeriesPtr('get'), 'Value');

                set(uiSeriesPtr('get'), 'Value', tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

                aCtBuffer = dicomBuffer('get');

                atCtMetaData = dicomMetaData('get');
                if isempty(atCtMetaData)

                    atCtMetaData = tInput(tKernelCtDoseMap{dCtOffset}.dSeriesNumber).atDicomInfo;
                    dicomMetaData('set', atCtMetaData);
                end

                if isempty(aCtBuffer)

                    aInput = inputBuffer('get');
                    aCtBuffer = aInput{tKernelCtDoseMap{dCtOffset}.dSeriesNumber};
                    if strcmp(imageOrientation('get'), 'coronal')
                        aCtBuffer = permute(aCtBuffer, [3 2 1]);
                    elseif strcmp(imageOrientation('get'), 'sagittal')
                        aCtBuffer = permute(aCtBuffer, [2 3 1]);
                    else
                        aCtBuffer = permute(aCtBuffer, [1 2 3]);
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

                    dicomBuffer('set', aCtBuffer);

                end

                set(uiSeriesPtr('get'), 'Value', dSerieOffset);

                dUpperValue = str2double( get(uiEditKernelUpperTreshold, 'String') );
                dLowerValue = str2double( get(uiEditKernelLowerTreshold, 'String') );
                if get(chkUnitTypeKernel, 'Value') == true
                    [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
                end

                dCtMIn = min(double(aCtBuffer),[], 'all');

                aCtBuffer(aCtBuffer<=dLowerValue) = dCtMIn;
                aCtBuffer(aCtBuffer>=dUpperValue) = dCtMIn;

                aCtBuffer(aCtBuffer==dCtMIn)=0;
                aCtBuffer(aCtBuffer~=0)=1;

                [aResamCt, ~] = resampleImage(aCtBuffer, atCtMetaData, aRefBuffer, atRefMetaData, 'Linear', false);

                dResampMIn = min(double(aResamCt),[], 'all');

                aResamCt(aResamCt==dResampMIn)=0;
                aResamCt(aResamCt~=0)=1;

                aBuffer = dicomBuffer('get');
                doseBuffer(aResamCt==0) = aBuffer(aResamCt==0);
            end

            dicomBuffer('set', doseBuffer);

            dMin = min(doseBuffer, [], 'all');
            dMax = max(doseBuffer, [], 'all');

            setWindowMinMax(dMax, dMin);

            tInput(dOffset).bDoseKernel = true;
            if numel(tInput) == 1 && isFusion('get') == false
                tInput(dOffset).bFusedDoseKernel = true;
            end

            inputTemplate('set', tInput);

            refreshImages();

            progressBar(1, 'Ready');

            catch
                progressBar(1, 'Error:setDoseKernel()');
            end

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;

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
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(tInput)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        aBuffer = dicomBuffer('get');

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

        if size(dicomBuffer('get'), 3) == 1
            sigmaZ = 1;
        else
            dComputed = computeSliceSpacing(atCoreMetaData);
            if dComputed == 0
                sigmaZ = z/1;
            else
                sigmaZ = z/dComputed;
           end
        end

        if strcmp(imageOrientation('get'), 'coronal')
            xPixel = sigmaX;
            yPixel = sigmaZ;
            zPixel = sigmaY;
        end
        if strcmp(imageOrientation('get'), 'sagittal')
            xPixel = sigmaY;
            yPixel = sigmaZ;
            zPixel = sigmaX;
        end
        if strcmp(imageOrientation('get'), 'axial')
            xPixel = sigmaX;
            yPixel = sigmaY;
            zPixel = sigmaZ;
        end

        dicomBuffer('set', imgaussfilt3(aBuffer,[xPixel,yPixel,zPixel]));

        refreshImages();

        catch
            progressBar(1, 'Error:setDoseKernel()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function resetKernelCallback(~, ~)

        tInitInput = inputTemplate('get');

        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInitInput)
            return;
        end

        if switchTo3DMode('get')     == true ||  ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        aInput = inputBuffer('get');

        if ~strcmp(imageOrientation('get'), 'axial')
            imageOrientation('set', 'axial');
        end

        if     strcmp(imageOrientation('get'), 'axial')
            aBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aBuffer = permute(aInput{iOffset}, [3 1 2]);
        end

        tInitInput(iOffset).bEdgeDetection = false;
        tInitInput(iOffset).bFlipLeftRight = false;
        tInitInput(iOffset).bFlipAntPost   = false;
        tInitInput(iOffset).bFlipHeadFeet  = false;
        tInitInput(iOffset).bDoseKernel    = false;
        tInitInput(iOffset).bFusedDoseKernel    = false;
        tInitInput(iOffset).bFusedEdgeDetection = false;

        dFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
        if dFuseOffset <= numel(tInitInput)
            tInitInput(dFuseOffset).bEdgeDetection = false;
        end

        inputTemplate('set', tInitInput);

        if isfield(tInitInput(iOffset), 'tRoi')
            atRoi = roiTemplate('get');
            for kk=1:numel(atRoi)
                atRoi{kk}.SliceNb  = tInitInput(iOffset).tRoi{kk}.SliceNb;
                atRoi{kk}.Position = tInitInput(iOffset).tRoi{kk}.Position;
                atRoi{kk}.Object.Position = tInitInput(iOffset).tRoi{kk}.Position;
            end
            roiTemplate('set', atRoi);
        end

        dicomBuffer('set',aBuffer);

        dicomMetaData('set', tInitInput(iOffset).atDicomInfo);

        setQuantification(iOffset);

        fusionBuffer('reset');
        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        clearDisplay();
        initDisplay(3);

        initWindowLevel('set', true);
        quantificationTemplate('set', tInitInput(iOffset).tQuant);

        dicomViewerCore();

        triangulateCallback();

        refreshImages();

        catch
            progressBar(1, 'Error:resetKernelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

end
