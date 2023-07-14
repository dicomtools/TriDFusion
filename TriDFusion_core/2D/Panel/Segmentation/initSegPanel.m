function initSegPanel()
%function initSegPanel()
%Segmentation Panel Main Function.
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

    if isempty(dicomBuffer('get'))
         return;
    else
        if size(dicomBuffer('get'), 3) == 1
            sLungTresholdEnable = 'off';
        else
            atMetaData = dicomMetaData('get');
            if strcmpi(atMetaData{1}.Modality, 'ct')
                sLungTresholdEnable = 'on';
            else
                sLungTresholdEnable = 'off';
            end
        end
    end

    % Reset or Proceed

        uicontrol(uiSegPanelPtr('get'),...
                  'String','Reset',...
                  'Position',[15 580 100 25],...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.2 0.039 0.027], ...
                  'ForegroundColor', [0.94 0.94 0.94], ...
                  'Callback', @resetSegmentationCallback...
                  );

    % Edge Segmentation

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Edge Detection Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 540 250 20]...
                  );


         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Fudge Factor Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 515 200 20]...
                  );

    uiSliderFudgeFactor = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 500 175 14], ...
                  'Value'   , fudgeFactorSegValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderFudgeFactorCallback ...
                  );
%    addlistener(uiSliderFudgeFactor,'Value','PreSet',@sliderImageUpperTreshCallback);
%    sliderImageVoiRoiUpperTresholdObject('set', uiSliderImageUpperTreshold);

    uiFudgeFactorValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 500 65 20], ...
                  'String'  , num2str(fudgeFactorSegValue('get')), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @editFudgeFactorCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'String'  , 'Segment',...
                  'Position', [160 460 100 25],...
                  'Enable'  , 'on', ...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @proceedEdgeDetectionCallback...
                  );

         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Method',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 460 60 20]...
                  );

    aEdgeMethod = {'Sobel', 'Prewitt', 'Canny', 'Approxcanny'};

    sEdgeSegMethod = edgeSegMethod('get');
    switch lower(sEdgeSegMethod)
        case lower('Sobel')
            dEdgeMethod = 1;
        case lower('Prewitt')
            dEdgeMethod = 2;
        case lower('Canny')
            dEdgeMethod = 3;
        case lower('Approxcanny')
            dEdgeMethod = 4;
        otherwise
            dEdgeMethod = 1;
    end

    uiEdgeMethod = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [70 463 85 20],...
                  'String'  , aEdgeMethod, ...
                  'Value'   , dEdgeMethod,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @setEdgeMethodCallback...
                  );

    % Options

        uicontrol(uiSegPanelPtr('get'),...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'string'    , 'Image Options',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 420 200 20]...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Mask Pixel Value',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [15 392 150 20]...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(cropValue('get')),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                 
                  'position'  , [195 395 65 20],...
                  'Callback', @edtCropValueCallback...
                  );

    % Image segmentation

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 355 200 20]...
                  );


    sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));

    if strcmpi(sUnitDisplay, 'SUV') ||  strcmpi(sUnitDisplay, 'HU')
        bUnitEnable = 'on';
    else
        bUnitEnable = 'off';
    end

    if strcmpi(sUnitDisplay, 'HU')
        bChkValue = false;
    else
        bChkValue = true;
    end

    if strcmpi(sUnitDisplay, 'SUV')
        sSUVtype = viewerSUVtype('get');
        sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
    else
        sUnitType = sprintf('Unit in %s', sUnitDisplay);
    end

    chkUnitTypeVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , bUnitEnable,...
                  'value'   , bChkValue,...
                  'position', [15 330 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUnitTypeVoiRoiCallback...
                  );

    txtUnitTypeVoiRoi = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , sUnitType,...
                  'horizontalalignment', 'left',...
                  'position', [35 327 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUnitTypeVoiRoiCallback...
                  );

    uiTxtUpperTreshold = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 300 200 20]...
                  );
    txtImageVoiRoiUpperTresholdObject('set', uiTxtUpperTreshold);

    uiSliderImageUpperTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 285 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'upper'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderImageUpperTreshCallback ...
                  );
%    lstSliderImageUpperTresh = addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);
    sliderImageVoiRoiUpperTresholdObject('set', uiSliderImageUpperTreshold);

    tQuant = quantificationTemplate('get');

%    dUpperValue = imageSegEditValue('get', 'upper');
%    dLowerValue = imageSegEditValue('get', 'lower');

    dUpperValue = max(dicomBuffer('get'), [], 'all');
    dLowerValue = min(dicomBuffer('get'), [], 'all');

    if strcmpi(sUnitDisplay, 'SUV') ||  strcmpi(sUnitDisplay, 'Window Level')
         if strcmpi(sUnitDisplay, 'Window Level')

             [dCTWindow, dCTLevel] = computeWindowMinMax(dUpperValue, dLowerValue);
             dUpperValue = dCTWindow;
             dLowerValue = dCTLevel;
         else
             if isfield(tQuant, 'tSUV')
                dUpperValue = dUpperValue*tQuant.tSUV.dScale;
                dLowerValue = dLowerValue*tQuant.tSUV.dScale;
             end
         end

         imageSegEditValue('set', 'upper', dUpperValue);
         imageSegEditValue('set', 'lower', dLowerValue);
    end

    dInitUpperValue = imageSegEditValue('get', 'upper');
    dInitLowerValue = imageSegEditValue('get', 'lower');

    uiEditImageUpperTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 285 65 20], ...
                  'String'  , num2str(dUpperValue), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editImageUpperTreshCallback ...
                  );
    editImageVoiRoiUpperTresholdObject('set', uiEditImageUpperTreshold);

    if useCropEditValue('get', 'upper') == true
        sCropEditUpperEnable = 'on';
    else
        sCropEditUpperEnable = 'off';
    end

    uiUpperCropValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 260 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'upper')), ...
                  'Enable'  , sCropEditUpperEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiUpperCropValueCallback...
                  );

       uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'inactive', ...
                  'string'  , 'Use Mask Pixel Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 257 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUpperTreshUseCropCallback...
                  );

    chkUpperTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'upper'), ...
                  'position', [15 255 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkUpperTreshUseCropCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'on', ...
                  'string'  , 'Lower Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 225 200 20]...
                  );

    uiSliderImageLowerTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 205 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'lower'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderImageLowerTreshCallback ...
                  );
%    lstSliderImageLowerTresh = addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);

    uiEditImageLowerTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 205 65 20], ...
                  'String'  ,  num2str(dLowerValue), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editImageLowerTreshCallback ...
                  );

    if useCropEditValue('get', 'lower') == true
        sCropEditLowerEnable = 'on';
    else
        sCropEditLowerEnable = 'off';
    end

    uiLowerCropValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 180 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'lower')), ...
                  'Enable'  , sCropEditLowerEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiLowerCropValueCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive', ...
                  'string'  , 'Use Mask Pixel Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 177 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkLowerTreshUseCropCallback...
                  );

    chkLowerTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'lower'), ...
                  'position', [15 180 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkLowerTreshUseCropCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'String','Segment',...
                  'Position',[160 145 100 25],...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @proceedImageSegCallback...
                  );

    % CT segmentation

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'CT Lung Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 105 200 20]...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 80 200 20]...
                  );

    uiSliderLungTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 65 175 14], ...
                  'Value'   , lungSegTreshValue('get'), ...
                  'Enable'  , sLungTresholdEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderLungTreshCallback ...
                  );
%      addlistener(uiSliderLungTreshold,'Value','PreSet',@sliderLungTreshCallback);

    uiEditLungTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 65 65 20], ...
                  'String'  , num2str(lungSegTreshValue('get')), ...
                  'Enable'  , sLungTresholdEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editLungTreshCallback ...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'String'  ,'Segment',...
                  'Position',[160 30 100 25],...
                  'Enable'  , sLungTresholdEnable, ...
                  'FontWeight', 'bold',...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @proceedLungSegCallback...
                  );

     uiLungRadius = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'     , 'Edit', ...
                  'position'  , [70 33 85 20],...
                  'String'    ,  num2str(lungSegRadiusValue('get')), ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable'  , sLungTresholdEnable, ...
                  'CallBack', @editLungSegRadiusValueCallback ...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Radius',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 30 35 20]...
                  );

    function chkUnitTypeVoiRoiCallback(hObject, ~)

            if strcmpi(get(chkUnitTypeVoiRoi, 'Enable'), 'off')
                return;
            end

            if strcmpi(get(hObject, 'Style'), 'text')
                if get(chkUnitTypeVoiRoi, 'Value') == true

                    set(chkUnitTypeVoiRoi, 'Value', false);

                else
                    set(chkUnitTypeVoiRoi, 'Value', true);
                end
            end

            if  get(chkUnitTypeVoiRoi, 'Value') == false
                if strcmpi(sUnitDisplay, 'SUV')
                    sUnitDisplay = 'BQML';
                else
                    sUnitDisplay = 'HU';
                end
            else
                if strcmpi(sUnitDisplay, 'BQML')
                    sUnitDisplay = 'SUV';
                else
                    sUnitDisplay = 'Window Level';
                end
            end

            if strcmpi(sUnitDisplay, 'SUV')
                sSUVtype = viewerSUVtype('get');
                sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                sUnitType = sprintf('Unit in %s', sUnitDisplay);
            end

            set(txtUnitTypeVoiRoi, 'String', sUnitType);

            dLowerValue = imageSegEditValue('get', 'lower');
            dUpperValue = imageSegEditValue('get', 'upper');

            switch (sUnitDisplay)
                case 'Window Level'

                    [dWindow, dLevel] = computeWindowMinMax(dUpperValue, dLowerValue);

                    dLowerValue = dLevel;
                    dUpperValue = dWindow;

                    [dInitWindow, dInitLevel] = computeWindowMinMax(dInitUpperValue, dInitLowerValue);

                    dInitLowerValue = dInitLevel;
                    dInitUpperValue = dInitWindow;

                case 'HU'
                   [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
                   [dInitUpperValue, dInitLowerValue] = computeWindowLevel(dInitUpperValue, dInitLowerValue);


                case 'SUV'
                    tQuant = quantificationTemplate('get');

                    dLowerValue = dLowerValue*tQuant.tSUV.dScale;
                    dUpperValue = dUpperValue*tQuant.tSUV.dScale;

                    dInitLowerValue = dInitLowerValue*tQuant.tSUV.dScale;
                    dInitUpperValue = dInitUpperValue*tQuant.tSUV.dScale;
                case 'BQML'

                    tQuant = quantificationTemplate('get');

                    dLowerValue = dLowerValue/tQuant.tSUV.dScale;
                    dUpperValue = dUpperValue/tQuant.tSUV.dScale;

                    dInitLowerValue = dInitLowerValue/tQuant.tSUV.dScale;
                    dInitUpperValue = dInitUpperValue/tQuant.tSUV.dScale;
            end

            set(uiEditImageLowerTreshold, 'String', num2str(dLowerValue));
            set(uiEditImageUpperTreshold, 'String', num2str(dUpperValue));

            imageSegEditValue('set', 'lower', dLowerValue);
            imageSegEditValue('set', 'upper', dUpperValue);

    end

    function uiUpperCropValueCallback(hObject, ~)
        dValue = str2double(get(hObject, 'string'));
        imageCropEditValue('set', 'upper', dValue);
    end

    function chkUpperTreshUseCropCallback(hObject, ~)

%        [asConstraintTagList, ~] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));
                        
%        if isempty(asConstraintTagList)
            if get(chkUpperTreshUseCrop, 'Value') == true
                if strcmpi(hObject.Style, 'checkbox')
                    set(chkUpperTreshUseCrop, 'Value', true);
                    set(uiUpperCropValue, 'Enable', 'off');
                    useCropEditValue('set', 'upper', false);
               else
                    set(chkUpperTreshUseCrop, 'Value', false);
                    set(uiUpperCropValue, 'Enable', 'on');
                    useCropEditValue('set', 'upper', true);
               end
            else
                if strcmpi(hObject.Style, 'checkbox')
                    set(chkUpperTreshUseCrop, 'Value', false);
                    set(uiUpperCropValue, 'Enable', 'on');
                    useCropEditValue('set', 'upper', true);
              else
                    set(chkUpperTreshUseCrop, 'Value', true);
                    set(uiUpperCropValue, 'Enable', 'off');
                    useCropEditValue('set', 'upper', false);
               end
            end
        end
%    end

    function uiLowerCropValueCallback(hObject, ~)
        dValue = str2double(get(hObject, 'string'));
        imageCropEditValue('set', 'lower', dValue);
    end

    function chkLowerTreshUseCropCallback(hObject, ~)

        if get(chkLowerTreshUseCrop, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLowerTreshUseCrop, 'Value', true);
                set(uiLowerCropValue, 'Enable', 'off');
                useCropEditValue('set', 'lower', false);
            else
                set(chkLowerTreshUseCrop, 'Value', false);
                set(uiLowerCropValue, 'Enable', 'on');
                useCropEditValue('set', 'lower', true);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkLowerTreshUseCrop, 'Value', false);
                set(uiLowerCropValue, 'Enable', 'on');
                useCropEditValue('set', 'lower', true);
           else
                set(chkLowerTreshUseCrop, 'Value', true);
                set(uiLowerCropValue, 'Enable', 'off');
                useCropEditValue('set', 'lower', false);
           end
        end
    end

    function sliderImageUpperTreshCallback(~, ~)

        dMax = dInitUpperValue;
        dMin = dInitLowerValue;

        dMaxTresholdValue = get(uiSliderImageUpperTreshold, 'Value');
        dMinTresholdValue = get(uiSliderImageLowerTreshold, 'Value');

        if dMaxTresholdValue < dMinTresholdValue
            dMaxTresholdValue = dMinTresholdValue;

%            delete(lstSliderImageUpperTresh);

            set(uiSliderImageUpperTreshold, 'Value', dMinTresholdValue);

%            lstSliderImageUpperTresh = addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);

        end

        dDiff = dMax - dMin;

        dMaxValue = (dMaxTresholdValue*dDiff)+dMin;

        imageSegEditValue('set', 'upper', dMaxValue);

        set(uiEditImageUpperTreshold, 'String', num2str(dMaxValue));

        editImageTreshold();

    end

    function sliderImageLowerTreshCallback(~, ~)

        dMax = dInitUpperValue;
        dMin = dInitLowerValue;

        dMaxTresholdValue = get(uiSliderImageUpperTreshold, 'Value');
        dMinTresholdValue = get(uiSliderImageLowerTreshold, 'Value');

        if dMinTresholdValue > dMaxTresholdValue
            dMinTresholdValue = dMaxTresholdValue;

%            delete(lstSliderImageLowerTresh);

            set(uiSliderImageLowerTreshold, 'Value', dMaxTresholdValue);

%            lstSliderImageLowerTresh = addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);

        end

        dDiff = dMax - dMin;

        dMinValue = (dMinTresholdValue*dDiff)+dMin;

        imageSegEditValue('set', 'lower', dMinValue);

        set(uiEditImageLowerTreshold, 'String', num2str(dMinValue));

        editImageTreshold();

    end

    function editImageUpperTreshCallback(hObject, ~)

%        delete(lstSliderImageUpperTresh);

        set(uiSliderImageUpperTreshold, 'Value', 1);

        dInitUpperValue = str2double(get(hObject, 'String'));
        if isnan(dInitUpperValue)
            dInitUpperValue = imageSegEditValue('get', 'upper');
            set(hObject, 'String', num2str(dInitUpperValue));
        end

        imageSegEditValue('set', 'upper', dInitUpperValue);

        editImageTreshold();

%        lstSliderImageUpperTresh = addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);

    end

    function editImageLowerTreshCallback(hObject, ~)

%        delete(lstSliderImageLowerTresh);

        set(uiSliderImageLowerTreshold, 'Value', 0);

        dInitLowerValue = str2double(get(hObject, 'String'));
        if isnan(dInitLowerValue)
            dInitLowerValue = imageSegEditValue('get', 'lower');
            set(hObject, 'String', num2str(dInitLowerValue));
        end

        imageSegEditValue('set', 'lower', dInitLowerValue);

        editImageTreshold();

%        lstSliderImageLowerTresh = addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);

    end

    function editImageTreshold()
        
        aBuffer = dicomBuffer('get');
        if isempty(aBuffer)
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

        dLowerTreshold = imageSegEditValue('get', 'lower');
        dUpperTreshold = imageSegEditValue('get', 'upper');

        switch (sUnitDisplay)
            case 'Window Level'

                [dUpperTreshold, dLowerTreshold] = computeWindowLevel(dUpperTreshold, dLowerTreshold);

            case 'HU'

            case 'SUV'
                tQuant = quantificationTemplate('get');

                dLowerTreshold = dLowerTreshold/tQuant.tSUV.dScale;
                dUpperTreshold = dUpperTreshold/tQuant.tSUV.dScale;

            case 'BQML'
        end
                   
        aBufferInit = aBuffer;

        if useCropEditValue('get', 'upper') == true
            aBuffer(aBuffer >= dUpperTreshold) = imageCropEditValue('get', 'upper');
        else
            aBuffer(aBuffer >= dUpperTreshold) = cropValue('get');
        end

        if useCropEditValue('get', 'lower') == true
            aBuffer(aBuffer <= dLowerTreshold) = imageCropEditValue('get', 'lower');
        else
            aBuffer(aBuffer <= dLowerTreshold) = cropValue('get');
        end

        % Get constraint 

        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

        bInvertMask = invertConstraint('get');

        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

        aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint
        
        if size(aBuffer, 3) == 1

            imAxe = imAxePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
            
            imAxe.CData = aBuffer;
            
        else
            imCoronal  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value'));
            imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
            imAxial    = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value'));

            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            aCoronal  = permute(aBuffer(iCoronal,:,:), [3 2 1]);
            aSagittal = permute(aBuffer(:,iSagittal,:), [3 1 2]);
            aAxial    = aBuffer(:,:,iAxial);
                        
            imCoronal.CData  = aCoronal;
            imSagittal.CData = aSagittal;
            imAxial.CData    = aAxial;
        end

        catch
            progressBar(1, 'Error:editImageTreshold()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end


    function proceedImageSegCallback(~, ~)

        aBuffer = dicomBuffer('get');
        if isempty(aBuffer)
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

        dLowerTreshold = imageSegEditValue('get', 'lower');
        dUpperTreshold = imageSegEditValue('get', 'upper');

        switch (sUnitDisplay)
            case 'Window Level'

                [dUpperTreshold, dLowerTreshold] = computeWindowLevel(dUpperTreshold, dLowerTreshold);

            case 'HU'

            case 'SUV'
                tQuant = quantificationTemplate('get');

                dLowerTreshold = dLowerTreshold/tQuant.tSUV.dScale;
                dUpperTreshold = dUpperTreshold/tQuant.tSUV.dScale;

            case 'BQML'
        end
                   
        aBufferInit = aBuffer;

        if useCropEditValue('get', 'upper') == true
            aBuffer(aBuffer >= dUpperTreshold) = imageCropEditValue('get', 'upper');
        else
            aBuffer(aBuffer >= dUpperTreshold) = cropValue('get');
        end

        if useCropEditValue('get', 'lower') == true
            aBuffer(aBuffer <= dLowerTreshold) = imageCropEditValue('get', 'lower');
        else
            aBuffer(aBuffer <= dLowerTreshold) = cropValue('get');
        end

        % Get constraint 

        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

        bInvertMask = invertConstraint('get');

        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

        aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0);

        dicomBuffer('set', aBuffer);

        iOffset = get(uiSeriesPtr('get'), 'Value');

        setQuantification(iOffset);

        refreshImages();
        
        computeMIPCallback();
       
        modifiedMatrixValueMenuOption('set', true);

        catch
            progressBar(1, 'Error:proceedImageSegCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function sliderLungTreshCallback(hObject, ~)

        dLungSegTreshValue = get(hObject, 'Value');

        lungSegTreshValue('set', dLungSegTreshValue);

        dLungSegRadiusValue = str2double(get(uiLungRadius, 'String'));

        set(uiEditLungTreshold, 'String', num2str(dLungSegTreshValue) );

        lungSegmentationPreview(dLungSegTreshValue, dLungSegRadiusValue);

    end

    function editLungSegRadiusValueCallback(hObject, ~)

        dLungSegRadiusValue = str2double(get(hObject, 'String'));

        if dLungSegRadiusValue < 0
            dLungSegRadiusValue = 0;
            set(hObject, 'String', num2str(dLungSegRadiusValue));
        end

        lungSegRadiusValue('set', dLungSegRadiusValue);

        dLungSegTreshValue = str2double(get(uiEditLungTreshold, 'String'));

        lungSegmentationPreview(dLungSegTreshValue, dLungSegRadiusValue);

    end

    function editLungTreshCallback(hObject, ~)

        dLungSegTreshValue = str2double(get(hObject, 'String'));
        if isnan(dLungSegTreshValue)
            dLungSegTreshValue = lungSegTreshValue('get');
            set(hObject, 'String', num2str(dLungSegTreshValue));
        end

        if dLungSegTreshValue < 0
            dLungSegTreshValue = 0;
            set(hObject, 'String', num2str(dLungSegTreshValue));
        end

        if dLungSegTreshValue > 1
            dLungSegTreshValue = 1;
            set(hObject, 'String', num2str(dLungSegTreshValue));
        end

        lungSegTreshValue('set', dLungSegTreshValue);
  %      resetSegmentationCallback();

        dLungSegRadiusValue = str2double(get(uiLungRadius, 'String'));

        set(uiSliderLungTreshold, 'Value', dValue);

        lungSegmentationPreview(dLungSegTreshValue, dLungSegRadiusValue);

    end

    function resetSegmentationCallback(~, ~)

              
        try
            
        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                
        mainToolBarEnable('off');
        
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        resetSeries(get(uiSeriesPtr('get'), 'Value'), true);        
        
        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error:resetSegmentationCallback()');
        end
        
        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');                
        mainToolBarEnable('on');
        
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function proceedLungSegCallback(~, ~)

        dLungSegTreshValue  = str2double(get(uiEditLungTreshold, 'String'));
        dLungSegRadiusValue = str2double(get(uiLungRadius, 'String'));

        lungSegmentation(dLungSegTreshValue, dLungSegRadiusValue);

        lungSegTreshValue('set', str2double(get(uiEditLungTreshold, 'String')));

    end

    function editFudgeFactorCallback(hObject, ~)

        dFactor = str2double(get(hObject, 'String'));
        if isnan(dFactor)
            dFactor = fudgeFactorSegValue('get');
            set(hObject, 'String', num2str(dFactor));
        end

        fudgeFactorSegValue('set', dFactor);

        set(uiSliderFudgeFactor, 'Value', dFactor);

        edgeDetectionPreview();

    end

    function sliderFudgeFactorCallback(hObject, ~)

        dFactor = get(hObject, 'Value');

        fudgeFactorSegValue('set', dFactor);

        set(uiFudgeFactorValue, 'String', num2str(dFactor));

        edgeDetectionPreview();
    end

    function setEdgeMethodCallback(~, ~)

        aMethod = get(uiEdgeMethod, 'String');
        dValue  = get(uiEdgeMethod, 'Value' );

        edgeSegMethod('set', aMethod{dValue});

        edgeDetectionPreview();
    end

    function edgeDetectionPreview()

        if switchTo3DMode('get')     == true ||  ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            return;
        end

        aBuffer     = dicomBuffer('get');
        aBufferInit = aBuffer;
        if isempty(aBuffer)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        aMethod = get(uiEdgeMethod, 'String');
        dValue  = get(uiEdgeMethod, 'Value' );

        dFudgeFactor = str2double(get(uiFudgeFactorValue, 'String'));

        fudgeFactorSegValue('set', dFudgeFactor);
        edgeSegMethod('set', aMethod{dValue});

        aSize = size(aBuffer);

        if size(dicomBuffer('get'), 3) == 1
            
            imAxe  = imAxePtr ('get', [], get(uiSeriesPtr('get'), 'Value'));

            [~,dThreshold] = edge(aBuffer, aMethod{dValue});
            imEdge = edge(aBuffer, aMethod{dValue}, dThreshold * dFudgeFactor);

            imMask(:,:) = imEdge;

            lMin = min(aBuffer, [], 'all');
            lMax = max(aBuffer, [], 'all');

            aBuffer(imMask == 0) = lMin;
            aBuffer(imMask ~= 0) = lMax;
            
            % Get constraint 

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

            aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint
        
            imAxe.CData = aBuffer;

        else
            imMask = zeros(aSize);

            imCoronal  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value'));
            imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
            imAxial    = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value'));

            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            for aa=1:aSize(3)
                progressBar(aa/aSize(3), sprintf('Processing %s Step %d/%d', aMethod{dValue}, aa, aSize(3)));
                im2D = aBuffer(:,:,aa);

                [~,dThreshold] = edge(im2D, aMethod{dValue});
                imEdge = edge(im2D, aMethod{dValue}, dThreshold * dFudgeFactor);

                imMask(:,:,aa) = imEdge;
            end

            progressBar(1, 'Ready');

            lMin = min(aBuffer, [], 'all');
            lMax = max(aBuffer, [], 'all');

            aBuffer(imMask == 0) = lMin;
            aBuffer(imMask ~= 0) = lMax;
            
            % Get constraint 

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

            bInvertMask = invertConstraint('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

            aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint
            
            imCoronal.CData  = permute(aBuffer(iCoronal,:,:), [3 2 1]);
            imSagittal.CData = permute(aBuffer(:,iSagittal,:), [3 1 2]) ;
            imAxial.CData    = aBuffer(:,:,iAxial);
        end

        catch
            progressBar(1, 'Error:edgeDetectionPreview()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function proceedEdgeDetectionCallback(hObject, ~)

        tInput = inputTemplate('get');

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
        if dSerieOffset > numel(tInput)
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

        set(hObject, 'Enable', 'off');

        aMethod = get(uiEdgeMethod, 'String');
        dValue  = get(uiEdgeMethod, 'Value' );

        dFudgeFactor = str2double(get(uiFudgeFactorValue, 'String'));

        fudgeFactorSegValue('set', dFudgeFactor);
        edgeSegMethod('set', aMethod{dValue});

        aBuffer = dicomBuffer('get');

        aBuffer = getEdgeDetection(aBuffer, aMethod{dValue}, dFudgeFactor);

        tInput(dSerieOffset).bEdgeDetection = true;
        if numel(tInput) == 1 && isFusion('get') == false
            tInput(dSerieOffset).bFusedEdgeDetection = true;
        end

        inputTemplate('set', tInput);

        dicomBuffer('set', aBuffer);
        
        if link2DMip('get') == true 
            aEdgeMip = computeMIP(aBuffer);
            mipBuffer('set', aEdgeMip, get(uiSeriesPtr('get'), 'Value'));
        end
    
        refreshImages();

        set(hObject, 'Enable', 'on');

        catch
            progressBar(1, 'Error:proceedEdgeDetectionCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function edtCropValueCallback(hObject, ~)

        cropValue('set', str2double(get(hObject, 'String')) );
    end

end
