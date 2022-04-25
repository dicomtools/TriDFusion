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
                  'Position',[15 480 100 25],...
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
                  'position', [15 430 200 20]...
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
                  'position', [15 430 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUseCTdoseMapKernelCallback...
                  );

    txtUseCTdoseMapKernel = ...
         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Use CT Map',...
                  'horizontalalignment', 'left',...
                  'position', [35 427 200 20],...
                  'Enable', sTxtUseCTdoseMapEnable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUseCTdoseMapKernelCallback...
                  );

    uiKernelSeries = ...
         uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 395 245 25], ...
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
                  'position', [15 370 20 20],...
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
                  'position', [35 367 200 20],...
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
                  'position', [15 345 200 20]...
                  );
    txtKernelVoiRoiUpperTresholdObject('set', uiTxtUpperTreshold);

    uiSliderKernelUpperTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 330 175 14], ...
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
                  'Position', [195 330 65 20], ...
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
                  'position', [15 300 200 20]...
                  );

    uiSliderKernelLowerTreshold = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 285 175 14], ...
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
                  'Position', [195 285 65 20], ...
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
                  'position', [15 252 125 20]...
                  );

    uiKernelModel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 255 125 20],...
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
                  'position', [15 227 125 20]...
                  );

    uiKernelTissue = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 230 125 20],...
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
                  'position', [15 202 125 20]...
                  );

    uiKernelIsotope = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 205 125 20],...
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
                  'position', [15 172 125 20]...
                  );

    uiKernelInterpolation = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [135 175 125 20],...
                  'String'  , asKernelInterpolation, ...
                  'Value'   , dIterpolationValue,...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiKernelInterpolationCallback...
                  );    
    
    
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

        bUseCtMap = get(chkUseCTdoseMapKernel, 'Value'); % CT Guided

        aRefBuffer = dicomBuffer('get');
        atRefMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');

        if bUseCtMap == true

            tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

            dCtOffset = get(uiKernelSeries, 'Value');

            dSerieOffset = get(uiSeriesPtr('get'), 'Value');

            set(uiSeriesPtr('get'), 'Value', tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

            aCtBuffer = dicomBuffer('get');

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

            atCtMetaData = dicomMetaData('get');
            if isempty(atCtMetaData)

                atCtMetaData = tInput(tKernelCtDoseMap{dCtOffset}.dSeriesNumber).atDicomInfo;
                dicomMetaData('set', atCtMetaData);
            end

            set(uiSeriesPtr('get'), 'Value', dSerieOffset);

           [aResamCt, ~] = resampleImage(aCtBuffer, atCtMetaData, aRefBuffer, atRefMetaData, 'Linear', true, false);
           
             % Get constraint 

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            aLogicalMask = roiConstraintToMask(aResamCt, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

            dImageMin = min(double(aResamCt),[], 'all');

            aResamCt(aLogicalMask==0) = dImageMin; % Apply constraint
       

            dCtMIn = min(double(aResamCt),[], 'all');

            dUpperValue = str2double( get(uiEditKernelUpperTreshold, 'String') );
            dLowerValue = str2double( get(uiEditKernelLowerTreshold, 'String') );
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

    function uiKernelInterpolationCallback(~, ~)
       
        asKernelInterpolation = get(uiKernelInterpolation, 'String');
        dInterpolationValue   = get(uiKernelInterpolation, 'Value');

        kernelInterpolation('set', asKernelInterpolation{dInterpolationValue});
           
    end

    function doseKernelCallback(hObject, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        set(uiKernelTissue       , 'Enable', 'off');
        set(uiKernelIsotope      , 'Enable', 'off');
        set(uiKernelModel        , 'Enable', 'off');
        set(uiKernelInterpolation, 'Enable', 'off');
        set(hObject              , 'Enable', 'off');

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

        set(uiKernelTissue       , 'Enable', 'on');
        set(uiKernelIsotope      , 'Enable', 'on');
        set(uiKernelModel        , 'Enable', 'on');
        set(uiKernelInterpolation, 'Enable', 'on');
        set(hObject              , 'Enable', 'on');

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

            % For radioembolization using microspheres loaded with isotope with half-life T1/2
            % 1)	From PET image – Activity A in kBq for each voxel at time of scan: Ascan= Bq/mL * Vvox(mL)
            % 2)	Activity at injection of microspheres: A0=A*2[(Tscan-Tinjection)/T1/2]
            % 3)	Calculate the total number of disintegrations in the voxel  [Bq * s] =
            % = Cumulative activity Acum= A0 * T1/2(s) / ln(2) = A0 (Bq) *1.442695* T1/2 (s)
            % 4)	Calculate total number of beta-particles (e.g. beta) using the yield Yb
            % Nb= Acum * Yb
            % 5)	Nb,scaled = Nb/(4*107  ) ; (4*10^7 primaries used per George Kagadis e-mail 5-14-20)

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

            TscanMinusTinjection = (dayAcqDate - dateInjDate)*(24*60*60); % Acquisition start time

            switch lower(asIsotope{dIsotope})
                case 'y90'
                    betaYield = 1; %Beta yield Y-90
%                    nbOfParticuleSimulated = 3.1867E5; % To double check
                    nbOfParticuleSimulated = 2E7; % To double check (number of particule simulated)

% Need validation                case 'i124'
% Need validation                   betaYield = 0.92; %Beta yield I124
% Need validation                   nbOfParticuleSimulated = 2E7;

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

            aActivity = aActivity*xPixel*yPixel*zPixel/1000;  % 1) From PET image – Activity A in kBq for each voxel at time of scan: Ascan= Bq/mL * Vvox(mL)
            A0 = aActivity*2^(TscanMinusTinjection/halfLife); % 2) Activity at injection of microspheres: A0=A*2[(Tscan-Tinjection)/T1/2]
            Acum  = A0 *halfLife *1/log(2);                   % 3) Calculate the total number of disintegrations in the voxel Acum = A0(Bq) *1.442695* T1/2(s)
            Nb = Acum*betaYield;                              % 4) Calculate total number of beta-particles (e.g. beta) using the yield Yb Nb = Acum * Yb
            NbScaled = Nb/nbOfParticuleSimulated;             % 5) Nb,scaled = Nb/(4*107  )

            aDose = aDoseR2./aDistance.^2;                    % 6) Cumulative Dose to point at distance r (mm), D(r) = Nb,scaled * DPKr2(r) / r2  ???

            aActivity = NbScaled;

            % Set Meshgrid

            dMax = max(aDose, [], 'all')/1000; % Dose kernel truncated to 1000th of the peak
            aVector = find(aDose<dMax);

            dFirst = aVector(1);

            dDistance = aDistance(dFirst);


            fromToX = ceil(dDistance/xPixel);
            fromX = -abs(fromToX);
            toX   =  abs(fromToX);

            fromToY = ceil(dDistance/yPixel);
            fromY = -abs(fromToY);
            toY   =  abs(fromToY);

            fromToZ = ceil(dDistance/zPixel);
            fromZ = -abs(fromToZ);
            toZ   =  abs(fromToZ);

            [X,Y,Z] = meshgrid(fromX:toX,fromY:toY,fromZ:toZ);

            % Interpolate Meshgrid

            distanceMatrix = sqrt((X*xPixel).^2+(Y*yPixel).^2+(Z*zPixel).^2);
%            vqKernel = interp1(aDistance, aDose, distanceMatrix, 'pchip', 'extrap'); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.

            asKernelInterpolation = get(uiKernelInterpolation, 'String');
            dInterpolationValue   = get(uiKernelInterpolation, 'Value');
            
            vqKernel = interp1(aDistance, aDose, distanceMatrix, asKernelInterpolation{dInterpolationValue}, 'extrap'); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.
       %     vqKernel = vqKernel/sum(vqKernel, 'all')*49.67;

            % Kernel Convolution

            doseBuffer = convn(aActivity, vqKernel, 'same');

            % Apply CT constraint 

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

                [aResamCt, ~] = resampleImage(aCtBuffer, atCtMetaData, aRefBuffer, atRefMetaData, 'Linear', true, false);

                dResampMIn = min(double(aResamCt),[], 'all');

                aResamCt(aResamCt==dResampMIn)=0;
                aResamCt(aResamCt~=0)=1;

                aBuffer = dicomBuffer('get');
                doseBuffer(aResamCt==0) = aBuffer(aResamCt==0);
            end
            
             % Apply ROI constraint 

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            aLogicalMask = roiConstraintToMask(aBuffer, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        
            
            doseBuffer(aLogicalMask==0) = aBuffer(aLogicalMask==0); % Set constraint      
            
            dicomBuffer('set', doseBuffer);

            if link2DMip('get') == true
                imMip = computeMIP(doseBuffer);
                mipBuffer('set', imMip, dOffset);
            end

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
        
        dOffset = get(uiSeriesPtr('get'), 'Value');
              
        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        resetSeries(dOffset, true);
        
        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error:resetKernelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

end
