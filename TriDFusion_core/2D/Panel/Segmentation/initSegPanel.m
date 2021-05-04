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
            sEnable = 'off';
        else
            sEnable = 'on';
        end
    end

    % Reset or Proceed

        uicontrol(uiSegPanelPtr('get'),...
                  'String','Reset',...
                  'Position',[15 625 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
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
                  'position', [15 575 250 20]...
                  );


         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Fudge Factor Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 550 200 20]...
                  );

    uiSliderFudgeFactor = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 535 175 14], ...
                  'Value'   , fudgeFactorSegValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderFudgeFactorCallback ...
                  );
%    addlistener(uiSliderFudgeFactor,'Value','PreSet',@sliderImageUpperTreshCallback);
%    sliderVoiRoiUpperTresholdObject('set', uiSliderImageUpperTreshold);

    uiFudgeFactorValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 535 65 20], ...
                  'String'  , num2str(fudgeFactorSegValue('get')), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @editFudgeFactorCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'String'  , 'Segment',...
                  'Position', [160 495 100 25],...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedEdgeDetectionCallback...
                  );

         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Method',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 495 60 20]...
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
                  'position'  , [70 498 85 20],...
                  'String'  , aEdgeMethod, ...
                  'Value'   , dEdgeMethod,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @setEdgeMethodCallback...
                  );

    % Image segmentation
    
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 445 200 20]...
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
    
    sUnitType = sprintf('Unit in %s', sUnitDisplay);
    
    chkUnitTypeVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , bUnitEnable,...
                  'value'   , bChkValue,...
                  'position', [20 420 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkUnitTypeVoiRoiCallback...
                  );

    txtUnitTypeVoiRoi = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , sUnitType,...
                  'horizontalalignment', 'left',...
                  'position', [40 417 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkUnitTypeVoiRoiCallback...
                  );              

    chkClipVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , 0,...
                  'position', [240 395 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkClipVoiRoiCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Crop Under Crop to Value',...
                  'horizontalalignment', 'left',...
                  'position', [15 392 225 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkClipVoiRoiCallback...
                  );

    chkSegmentVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'position', [240 370 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkSegmentVoiRoiCallback...
                  );
    chkVoiRoiSubstractObject('set', chkSegmentVoiRoi);

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Lower Treshold Value',...
                  'horizontalalignment', 'left',...
                  'position', [95 367 125 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkSegmentVoiRoiCallback...
                  );

    asSegOperation = {'Subtract', 'Add', 'Multiply', 'Divide'};
    uiSegOperation = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 370 75 20],...
                  'String'  , asSegOperation, ...
                  'Value'   , 1,...
                  'Enable'  , 'off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiSegmentOperationCallback...
                  );

     uiRoiVoiSeg = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [95 340 160 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable'  , 'off' ...
                  );
     voiRoiSegObject('set', uiRoiVoiSeg);

     imSeg = dicomBuffer('get');
     if size(imSeg, 3) == 1
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI'};
     else
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI', 'Inside all slices ROI\VOI', 'Outside all slices ROI\VOI'};
     end

     uiSegAction = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 340 75 20],...
                  'String'  , asSegOptions, ...
                  'Value'   , 1,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @segActionCallback...
                  );
     voiRoiActObject('set', uiSegAction);

    uiTxtUpperTreshold = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 305 200 20]...
                  );
     txtVoiRoiUpperTresholdObject('set', uiTxtUpperTreshold);

    uiSliderImageUpperTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 290 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'upper'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderImageUpperTreshCallback ...
                  );
    lstSliderImageUpperTresh = addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);
    sliderVoiRoiUpperTresholdObject('set', uiSliderImageUpperTreshold);
        
    tQuant = quantificationTemplate('get');                                
        
    dUpperValue = imageSegEditValue('get', 'upper');
    dLowerValue = imageSegEditValue('get', 'lower');
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
                  'Position', [195 290 65 20], ...
                  'String'  , num2str(dUpperValue), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editImageUpperTreshCallback ...
                  );
    editVoiRoiUpperTresholdObject('set', uiEditImageUpperTreshold);

    if useCropEditValue('get', 'upper') == true
        sCropEditUpperEnable = 'on';
    else
        sCropEditUpperEnable = 'off';
    end

    uiUpperCropValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 265 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'upper')), ...
                  'Enable'  , sCropEditUpperEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiUpperCropValueCallback...
                  );

       uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'inactive', ...
                  'string'  , 'Use Crop Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 262 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkUpperTreshUseCropCallback...
                  );

    chkUpperTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'upper'), ...
                  'position', [15 265 20 20],...
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
                  'position', [15 230 200 20]...
                  );

    uiSliderImageLowerTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 215 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'lower'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderImageLowerTreshCallback ...
                  );
    lstSliderImageLowerTresh = addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);

    uiEditImageLowerTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 215 65 20], ...
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
                  'Position', [195 190 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'lower')), ...
                  'Enable'  , sCropEditLowerEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @uiLowerCropValueCallback...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive', ...
                  'string'  , 'Use Crop Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 187 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkLowerTreshUseCropCallback...
                  );

    chkLowerTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'lower'), ...
                  'position', [15 190 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkLowerTreshUseCropCallback...
                  );

    btnProceedImageSeg = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'String','Segment',...
                  'Position',[160 155 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedImageSegCallback...
                  );

    edtCoefficient = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'String'    , '1',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [115 157 40 20]...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Slider Factor',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 155 100 20]...
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
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderLungTreshCallback ...
                  );
%      addlistener(uiSliderLungTreshold,'Value','PreSet',@sliderLungTreshCallback);

    uiEditLungTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 65 65 20], ...
                  'String'  , lungSegTreshValue('get'), ...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editLungTreshCallback ...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'String'  ,'Segment',...
                  'Position',[160 30 100 25],...
                  'Enable'  , sEnable, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedLungSegCallback...
                  );
              
     uiLungPlane = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [70 33 85 20],...
                  'String'  , {'Axial', 'Coronal', 'Sagittal', 'All'}, ...
                  'Value'   , 4,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable'  , 'on' ...
                  );

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Plane',...
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
          
            sUnitType = sprintf('Unit in %s', sUnitDisplay);
                                            
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

        if get(chkSegmentVoiRoi, 'Value') == false
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
    end

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

    function chkClipVoiRoiCallback(hObject, ~)

        if get(chkSegmentVoiRoi, 'Value') == true
            if get(chkClipVoiRoi, 'Value') == true
                if strcmpi(hObject.Style, 'checkbox')
                    set(chkClipVoiRoi, 'Value', true);
                else
                    set(chkClipVoiRoi, 'Value', false);
                end
            else
                if strcmpi(hObject.Style, 'checkbox')
                    set(chkClipVoiRoi, 'Value', false);
                else
                    set(chkClipVoiRoi, 'Value', true);
                end
            end
        end
    end

    function chkSegmentVoiRoiCallback(hObject, ~)

        if get(chkSegmentVoiRoi, 'Value') == true

            if strcmpi(hObject.Style, 'checkbox')
                set(chkSegmentVoiRoi, 'Value', true);
            else
                set(chkSegmentVoiRoi, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkSegmentVoiRoi, 'Value', false);
            else
                set(chkSegmentVoiRoi, 'Value', true);
            end
        end

        if get(chkSegmentVoiRoi, 'Value') == true

            set(uiSliderImageUpperTreshold, 'Enable', 'off');
            set(uiEditImageUpperTreshold  , 'Enable', 'off');
            set(btnProceedImageSeg        , 'String', ...
                uiSegOperation.String(get(uiSegOperation, 'Value')));
            set(uiSegOperation            , 'Enable', 'on');
            set(chkClipVoiRoi             , 'Enable', 'on');

            set(uiUpperCropValue    , 'Enable', 'off');
            set(chkUpperTreshUseCrop, 'Enable', 'off');
        else
            set(uiSliderImageUpperTreshold, 'Enable', 'on');
            set(uiEditImageUpperTreshold  , 'Enable', 'on');
            set(btnProceedImageSeg        , 'String', 'Segment');
            set(uiSegOperation            , 'Enable', 'off');
            set(chkClipVoiRoi             , 'Enable', 'off');
            set(chkUpperTreshUseCrop      , 'Enable', 'on');

            if useCropEditValue('get', 'upper') == true
                set(uiUpperCropValue    , 'Enable', 'on');
            else
                set(uiUpperCropValue    , 'Enable', 'off');
            end

       end

    end

    function uiSegmentOperationCallback(hObject, ~)

        set(btnProceedImageSeg, 'String', ...
            hObject.String(get(hObject, 'Value')));
    end

    function segActionCallback(~, ~)

        setVoiRoiSegPopup();

    end

    function sliderImageUpperTreshCallback(~, ~)
        
        dMax = dInitUpperValue;
        dMin = dInitLowerValue; 
        
        dQuantDifference = dMax - dMin;
        dWindow = dQuantDifference /2;

        dUpper = dMax - ((dWindow - (dWindow * get(uiSliderImageUpperTreshold, 'Value'))) / str2double(get(edtCoefficient, 'String')));

        set(uiEditImageUpperTreshold, 'String', num2str(dUpper));

        imageSegEditValue('set', 'upper', dUpper);
                
        editImageTreshold();

    end

    function sliderImageLowerTreshCallback(~, ~)

        dMax = dInitUpperValue;
        dMin = dInitLowerValue;   

        dQuantDifference = dMax - dMin;
        dWindow = dQuantDifference /2;

        dLower = dMin + ((dWindow * get(uiSliderImageLowerTreshold, 'Value') ) / str2double(get(edtCoefficient, 'String')));

        set(uiEditImageLowerTreshold, 'String', num2str(dLower));
        
        imageSegEditValue('set', 'lower', dLower);

        editImageTreshold();
    end

    function editImageUpperTreshCallback(hObject, ~)
        
        delete(lstSliderImageUpperTresh);
        
        set(uiSliderImageUpperTreshold, 'Value', 1);
        
        dInitUpperValue = str2double(get(hObject, 'String'));

        imageSegEditValue('set', 'upper', str2double(get(hObject, 'String')));

        editImageTreshold();
        
        lstSliderImageUpperTresh = addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);

    end

    function editImageLowerTreshCallback(hObject, ~)
        
        delete(lstSliderImageLowerTresh);
        
        set(uiSliderImageLowerTreshold, 'Value', 0);
        
        dInitLowerValue = str2double(get(hObject, 'String'));
        
        imageSegEditValue('set', 'lower', str2double(get(hObject, 'String')));

        editImageTreshold();
        
        lstSliderImageLowerTresh = addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);

    end

    function editImageTreshold()

        im = dicomBuffer('get');
        if isempty(im)
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
            
        if size(im, 3) == 1

            imAxe = imAxePtr('get');

            if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')

                if useCropEditValue('get', 'upper') == true
                    im(im  > dUpperTreshold) = imageCropEditValue('get', 'upper');
                else
                    im(im  > dUpperTreshold) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    im(im  < dLowerTreshold) = imageCropEditValue('get', 'lower');
               else
                    im(im  < dLowerTreshold) = cropValue('get');
               end

            else

                objRoi = aobjList{uiRoiVoiSeg.Value}.Object;

                roiMask = createMask(objRoi, im);
                if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Inside ROI\VOI')
                    roiMask = ~roiMask;
                end

                aTreshold = im;
                if useCropEditValue('get', 'upper') == true
                    aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                else
                    aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                else
                    aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                end

                im(roiMask == 0 ) = aTreshold(roiMask == 0);

            end

            imAxe.CData = im;

        else
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')

                if isVsplash('get') == true

                    imVsplash = im;
                    if useCropEditValue('get', 'upper') == true
                        imVsplash(imVsplash > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                    else
                        imVsplash(imVsplash > dUpperTreshold ) = cropValue('get');
                    end

                    if useCropEditValue('get', 'lower') == true
                        imVsplash(imVsplash < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                    else
                        imVsplash(imVsplash < dLowerTreshold ) = cropValue('get');
                    end

                    imComputed = computeMontage(imVsplash, 'coronal', iCoronal);

                    imAxSize = size(imCoronal.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                    imCoronal.CData = imComputed;

                    imComputed = computeMontage(imVsplash, 'sagittal', iSagittal);

                    imAxSize = size(imSagittal.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                    imSagittal.CData = imComputed;

                    imComputed = computeMontage(imVsplash(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                    imAxSize = size(imAxial.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                    imAxial.CData = imComputed;

                else
                    aCoronal  = permute(im(iCoronal,:,:), [3 2 1]);
                    aSagittal = permute(im(:,iSagittal,:), [3 1 2]);
                    aAxial    = im(:,:,iAxial);

                    if useCropEditValue('get', 'upper') == true
                        aCoronal(aCoronal > dUpperTreshold )   = imageCropEditValue('get', 'upper');
                        aSagittal(aSagittal > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                        aAxial(aAxial > dUpperTreshold )       = imageCropEditValue('get', 'upper');
                    else
                        aCoronal(aCoronal > dUpperTreshold )   = cropValue('get');
                        aSagittal(aSagittal > dUpperTreshold ) = cropValue('get');
                        aAxial(aAxial > dUpperTreshold )       = cropValue('get');
                    end

                    if useCropEditValue('get', 'lower') == true
                        aCoronal(aCoronal < dLowerTreshold )   = imageCropEditValue('get', 'lower');
                        aSagittal(aSagittal < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                        aAxial(aAxial < dLowerTreshold )       = imageCropEditValue('get', 'lower');
                    else
                        aCoronal(aCoronal < dLowerTreshold )   = cropValue('get');
                        aSagittal(aSagittal < dLowerTreshold ) = cropValue('get');
                        aAxial(aAxial < dLowerTreshold )       = cropValue('get');
                    end

                    imCoronal.CData  = aCoronal;
                    imSagittal.CData = aSagittal;
                    imAxial.CData    = aAxial;
                end

            else

                if strcmpi(aobjList{uiRoiVoiSeg.Value}.ObjectType, 'voi')
                    for bb=1:numel(aobjList{uiRoiVoiSeg.Value}.RoisTag)
                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                               strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiSeg.Value}.RoisTag{bb})
                                objRoi   = tRoiInput{cc}.Object;
                                dSliceNb = tRoiInput{cc}.SliceNb;

                                if objRoi.Parent  == axes1Ptr('get') && ...
                                   iCoronal == dSliceNb
                               
                                    set(fiMainWindowPtr('get'), 'Pointer', 'default');
                                    drawnow;                                 
                                    
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);                                    
                                    return;
                                end
                                
                                if objRoi.Parent  == axes2Ptr('get') && ...
                                   iSagittal == dSliceNb
                               
                                    set(fiMainWindowPtr('get'), 'Pointer', 'default');
                                    drawnow;   
                                    
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);
                                    return;
                                end
                                
                                if objRoi.Parent  == axes3Ptr('get') && ...
                                   iAxial == dSliceNb
                               
                                    set(fiMainWindowPtr('get'), 'Pointer', 'default');
                                    drawnow;   
                                    
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);
                                    return;
                                end
                            end
                        end
                    end
                else
                    objRoi   = aobjList{uiRoiVoiSeg.Value}.Object;
                    dSliceNb = aobjList{uiRoiVoiSeg.Value}.SliceNb;

                    tresholdVoiRoi(im, objRoi, dSliceNb, false, true);
                end

            end

        end
        
        catch
            progressBar(1, 'Error:editImageTreshold()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;  
        
    end

    function im = tresholdVoiRoi(im, objRoi, dSliceNb, bMathOperation, bUpdateScreen)
        
        if isempty(im)
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
        
        if isempty(axes1Ptr('get')) && ...
           isempty(axes2Ptr('get')) && ...
           isempty(axes3Ptr('get'))

            roiMask = createMask(objRoi, im);

            if bMathOperation == true
                if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI')
                    roiMask = ~roiMask;
                end

                switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                    case 'Subtract'

                       im(roiMask) = im(roiMask) - dLowerTreshold;

                    case 'Add'
                        im(roiMask) = im(roiMask) + dLowerTreshold;

                    case 'Multiply'
                        im(roiMask) = im(roiMask) * dLowerTreshold;

                    case 'Divide'

                        im(roiMask) = im(roiMask) / dLowerTreshold;

                    otherwise
                end

                aTreshold = im;
                if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                    aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                end
                im(roiMask) = aTreshold(roiMask);
            end

        else
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            if objRoi.Parent == axes1Ptr('get')

                if dSliceNb == 0 % all slices

                    dBufferSize = size(im);
                    for iCoronal=1:dBufferSize(1)
                        aCoronal = permute(im(iCoronal,:,:), [3 2 1]);

                        roiMask = createMask(objRoi, aCoronal);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end

                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aCoronal(roiMask) = aCoronal(roiMask) - dLowerTreshold;

                                case 'Add'
                                    aCoronal(roiMask) = aCoronal(roiMask) + dLowerTreshold;

                                case 'Multiply'
                                    aCoronal(roiMask) = aCoronal(roiMask) * dLowerTreshold;

                                case 'Divide'
                                    aCoronal(roiMask) = aCoronal(roiMask) / dLowerTreshold;

                                otherwise
                            end

                            aTreshold = aCoronal;
                            if get(chkClipVoiRoi, 'value')  == true % Clip under crop value
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                            end
                            aCoronal(roiMask) = aTreshold(roiMask);

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end

                            aTreshold = aCoronal;

                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                            else
                                aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                            end

                            aCoronal(roiMask == 0) = aTreshold(roiMask == 0);
                        end

                        im(iCoronal,:,:) = permuteBuffer(aCoronal, 'coronal');
                    end
                else % Image preview and one slice
                    sliceNumber('set', 'coronal', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();
                    end

                    iCoronal = dSliceNb;
                    aCoronal = permute(im(iCoronal,:,:), [3 2 1]);

                    roiMask = createMask(objRoi, aCoronal);

                    if bMathOperation == true
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                            case 'Subtract'
                                aCoronal(roiMask) = aCoronal(roiMask) - dLowerTreshold;

                            case 'Add'
                                aCoronal(roiMask) = aCoronal(roiMask) + dLowerTreshold;

                           case 'Multiply'
                                aCoronal(roiMask) = aCoronal(roiMask) * dLowerTreshold;

                            case 'Divide'
                                aCoronal(roiMask) = aCoronal(roiMask) / dLowerTreshold;

                            otherwise
                        end

                        aTreshold = aCoronal;

                        if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aCoronal(roiMask) = aTreshold(roiMask);

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        aTreshold = aCoronal;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                        else
                            aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                        end

                        aCoronal(roiMask == 0) = aTreshold(roiMask == 0);
                    end

                    im(iCoronal,:,:) = permuteBuffer(aCoronal , 'coronal');

                    if isVsplash('get') == true
                        imComputed = computeMontage(im, 'coronal', iCoronal);

                        imAxSize = size(imCoronal.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                        imCoronal.CData = imComputed;
                    else
                        imCoronal.CData = aCoronal;
                    end

                end

            end

            if objRoi.Parent == axes2Ptr('get')

                if dSliceNb == 0 % all slices
                    dBufferSize = size(im);
                    for iSagittal=1:dBufferSize(2)
                        aSagittal = permute(im(:,iSagittal,:), [3 1 2]);

                        roiMask = createMask(objRoi, aSagittal);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end

                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aSagittal(roiMask) = aSagittal(roiMask) - dLowerTreshold;

                                case 'Add'
                                    aSagittal(roiMask) = aSagittal(roiMask) + dLowerTreshold;

                               case 'Multiply'
                                    aSagittal(roiMask) = aSagittal(roiMask) * dLowerTreshold;

                                case 'Divide'
                                    aSagittal(roiMask) = aSagittal(roiMask) / dLowerTreshold;

                                otherwise
                            end

                            aTreshold = aSagittal;

                            if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                            end

                            aSagittal(roiMask) = aTreshold(roiMask);

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end

                            aTreshold = aSagittal;
                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                            else
                                aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                            end

                            aSagittal(roiMask == 0) = aTreshold(roiMask == 0);
                        end
                        im(:,iSagittal,:) = permuteBuffer(aSagittal, 'sagittal');
                    end
                else % Image preview and one slice
                    sliceNumber('set', 'sagittal', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();
                    end

                    iSagittal = dSliceNb;
                    aSagittal = permute(im(:,iSagittal,:), [3 1 2]);

                    roiMask = createMask(objRoi, aSagittal);

                    if bMathOperation == true

                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}

                            case 'Subtract'
                                aSagittal(roiMask) = aSagittal(roiMask) - dLowerTreshold;

                            case 'Add'
                                aSagittal(roiMask) = aSagittal(roiMask) + dLowerTreshold;

                           case 'Multiply'
                                aSagittal(roiMask) = aSagittal(roiMask) * dLowerTreshold;

                            case 'Divide'
                                aSagittal(roiMask) = aSagittal(roiMask) / dLowerTreshold;

                            otherwise
                        end

                        aTreshold = aSagittal;

                        if get(chkClipVoiRoi, 'value')  == true % Clip under crop value
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aSagittal(roiMask) = aTreshold(roiMask);

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        aTreshold = aSagittal;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                        else
                            aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                        end

                        aSagittal(roiMask == 0) = aTreshold(roiMask == 0);
                    end

                    im(:,iSagittal,:) = permuteBuffer(aSagittal, 'sagittal');

                    if isVsplash('get') == true
                        imComputed = computeMontage(im, 'sagittal', iSagittal);

                        imAxSize = size(imSagittal.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                        imSagittal.CData = imComputed;
                    else
                        imSagittal.CData = aSagittal;
                    end

                end
            end

            if objRoi.Parent == axes3Ptr('get')
                if dSliceNb == 0 % all slices
                    dBufferSize = size(im);
                    for iAxial=1:dBufferSize(3)
                        aAxial = im(:,:,iAxial);

                        roiMask = createMask(objRoi, aAxial);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end
                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aAxial(roiMask) = aAxial(roiMask) - dLowerTreshold;

                                case 'Add'
                                    aAxial(roiMask) = aAxial(roiMask) + dLowerTreshold;

                               case 'Multiply'
                                    aAxial(roiMask) = aAxial(roiMask) * dLowerTreshold;

                                case 'Divide'
                                    aAxial(roiMask) = aAxial(roiMask) / dLowerTreshold;

                                otherwise
                            end

                            aTreshold = aAxial;

                            if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                            end

                            aAxial(roiMask) = aTreshold(roiMask);

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                                roiMask = ~roiMask;
                            end

                            aTreshold = aAxial;
                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                            else
                                aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                            end

                            aAxial(roiMask == 0) = aTreshold(roiMask == 0);
                        end

                        im(:,:,iAxial) = aAxial;
                    end
                else % Image preview and one slice
                    sliceNumber('set', 'axial', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();
                    end

                    iAxial = dSliceNb;
                    aAxial = im(:,:,iAxial);

                    roiMask = createMask(objRoi, aAxial);

                    if bMathOperation == true

                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}

                            case 'Subtract'
                                aAxial(roiMask) = aAxial(roiMask) - dLowerTreshold;

                            case 'Add'
                                aAxial(roiMask) = aAxial(roiMask) + dLowerTreshold;

                           case 'Multiply'
                                aAxial(roiMask) = aAxial(roiMask) * dLowerTreshold;

                            case 'Divide'
                                aAxial(roiMask) = aAxial(roiMask) / dLowerTreshold;

                            otherwise
                        end

                        aTreshold = aAxial;

                        if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aAxial(roiMask) = aTreshold(roiMask);

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')
                            roiMask = ~roiMask;
                        end

                        aTreshold = aAxial;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > dUpperTreshold ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > dUpperTreshold ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < dLowerTreshold ) = imageCropEditValue('get', 'lower');
                        else
                            aTreshold(aTreshold < dLowerTreshold ) = cropValue('get');
                        end

                        aAxial(roiMask == 0) = aTreshold(roiMask == 0);
                    end

                    im(:,:,iAxial) = aAxial;

                    if isVsplash('get') == true
                        imComputed = computeMontage(im(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                        imAxSize = size(imAxial.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                        imAxial.CData = imComputed;
                    else
                        imAxial.CData  = aAxial;
                    end

                end
            end
        end
        
        catch
            progressBar(1, 'Error:tresholdVoiRoi()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;        
    end

    function proceedImageSegCallback(~, ~)

        im = dicomBuffer('get');
        if isempty(im)
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
        
        if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')
            if get(chkSegmentVoiRoi, 'Value') == true

                switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                    case 'Subtract'
                        im = im - dLowerTreshold;

                    case 'Add'
                        im = im + dLowerTreshold;

                    case 'Multiply'
                        im = im * dLowerTreshold;

                    case 'Divide'
                        im = im / dLowerTreshold;

                    otherwise
                end

                aTreshold = im;

                if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                    aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                end

                im = aTreshold;

            else
                if useCropEditValue('get', 'upper') == true
                    im(im  > dUpperTreshold) = imageCropEditValue('get', 'upper');
                else
                    im(im  > dUpperTreshold) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    im(im  < dLowerTreshold) = imageCropEditValue('get', 'lower');
                else
                    im(im  < dLowerTreshold) = cropValue('get');
                end
            end
        else
            if strcmpi(aobjList{uiRoiVoiSeg.Value}.ObjectType, 'voi')
                for bb=1:numel(aobjList{get(uiRoiVoiSeg, 'Value')}.RoisTag)
                    for cc=1:numel(tRoiInput)
                        if isvalid(tRoiInput{cc}.Object) && ...
                            strcmpi(tRoiInput{cc}.Tag, aobjList{get(uiRoiVoiSeg, 'Value')}.RoisTag{bb})
                            objRoi   = tRoiInput{cc}.Object;
                            dSliceNb = tRoiInput{cc}.SliceNb;

                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                               strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI')
                                im = tresholdVoiRoi(im, objRoi, dSliceNb, get(chkSegmentVoiRoi, 'Value'), false);
                            else
                                im = tresholdVoiRoi(im, objRoi, 0, get(chkSegmentVoiRoi, 'Value'), false);
                            end
                         end
                    end
                end
            else
                objRoi   = aobjList{uiRoiVoiSeg.Value}.Object;
                dSliceNb = aobjList{uiRoiVoiSeg.Value}.SliceNb;

                if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                   strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI')
                    im = tresholdVoiRoi(im, objRoi, dSliceNb, get(chkSegmentVoiRoi, 'Value'), false);
                else
                    im = tresholdVoiRoi(im, objRoi, 0, get(chkSegmentVoiRoi, 'Value'), false);
               end
            end
        end

        dicomBuffer('set', im);

        iOffset = get(uiSeriesPtr('get'), 'Value');

        setQuantification(iOffset);

        refreshImages();
        
        catch
            progressBar(1, 'Error:proceedImageSegCallback()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
    end

    function sliderLungTreshCallback(hObject, ~)

   %     resetSegmentationCallback();

        lungSegmentationPreview(hObject.Value)

        set(uiEditLungTreshold, 'String', num2str(hObject.Value) );

    end

    function editLungTreshCallback(hObject, ~)

        if str2double(hObject.String) < 0
            hObject.String = '0';
        end

  %      resetSegmentationCallback();

        lungSegmentationPreview(str2double(hObject.String));

        if str2double(hObject.String) > 1
            set(uiSliderLungTreshold, 'Value', 1);
        else
            set(uiSliderLungTreshold, 'Value', str2double(hObject.String) );
        end
    end

    function resetSegmentationCallback(~, ~)

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
        
        dicomBuffer('set', aBuffer);

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

%         aInput = inputBuffer('get');
%         dicomBuffer('set', aInput{iOffset});

%         setQuantification(iOffset);


        refreshImages();
        
        catch
            progressBar(1, 'Error:resetSegmentationCallback()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
    end

    function proceedLungSegCallback(~, ~)

        lungSegmentation(uiLungPlane.String{get(uiLungPlane, 'Value')}, str2double(get(uiEditLungTreshold, 'String')));
        
        lungSegTreshValue('set', str2double(get(uiEditLungTreshold, 'String')));

    end

    function editFudgeFactorCallback(hObject, ~)

        dFactor = str2double(get(hObject, 'String'));

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
        
        im = dicomBuffer('get');
        if isempty(im)
            
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

        aSize = size(im);

        if size(dicomBuffer('get'), 3) == 1
            imAxe  = imAxePtr ('get');

            im2D = im(:,:);

            [~,dThreshold] = edge(im2D, aMethod{dValue});
            imEdge = double(edge(im2D, aMethod{dValue}, dThreshold * dFudgeFactor));

            imMask(:,:) = imEdge;

            lMin = min(im, [], 'all');
            lMax = max(im, [], 'all');

            im(imMask == 0) = lMin;
            im(imMask ~= 0) = lMax;

            imAxe.CData = im;

        else

            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            for aa=1:aSize(3)
                progressBar(aa/aSize(3), sprintf('Processing %s Step %d/%d', aMethod{dValue}, aa, aSize(3)));
                im2D = im(:,:,aa);

                [~,dThreshold] = edge(im2D, aMethod{dValue});
                imEdge = double(edge(im2D, aMethod{dValue}, dThreshold * dFudgeFactor));

                imMask(:,:,aa) = imEdge;
            end

            progressBar(1, 'Ready');

            lMin = min(im, [], 'all');
            lMax = max(im, [], 'all');

            im(imMask == 0) = lMin;
            im(imMask ~= 0) = lMax;

            imCoronal.CData  = permute(im(iCoronal,:,:), [3 2 1]);
            imSagittal.CData = permute(im(:,iSagittal,:), [3 1 2]) ;
            imAxial.CData    = im(:,:,iAxial);
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

        im = dicomBuffer('get');

        imEdge = getEdgeDetection(im, aMethod{dValue}, dFudgeFactor);

        tInput(dSerieOffset).bEdgeDetection = true;
        if numel(tInput) == 1 && isFusion('get') == false
            tInput(dSerieOffset).bFusedEdgeDetection = true;
        end

        inputTemplate('set', tInput);

        dicomBuffer('set', imEdge);

        refreshImages();

        set(hObject, 'Enable', 'on');
        
        catch
            progressBar(1, 'Error:proceedEdgeDetectionCallback()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;         

    end

end
