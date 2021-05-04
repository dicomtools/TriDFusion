function initRoiPanel()
%function initRoiPanel()
%Kernel Panel Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
        roiPanelMinValue('set', min(double(aBuffer),[], 'all'));
        roiPanelMaxValue('set', max(double(aBuffer),[], 'all'));          
    end        
    
        % Roi/Voi segmentation

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'ROI/VOI Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 285 200 20]...
                  );
              
      uiRoiVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [95 250 160 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Enable'  , 'off', ...
                  'Callback', @segActionRoiPanelCallback...
                  );
     uiRoiVoiRoiPanelObject('set', uiRoiVoiRoiPanel);
     
     if size(aBuffer, 3) == 1
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI'};
     else
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI', 'Inside all slices ROI\VOI', 'Outside all slices ROI\VOI'};
     end     
            
     uiSegActRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 250 75 20],...
                  'String'  , asSegOptions, ...
                  'Value'   , 1,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @segActionRoiPanelCallback...
                  );
     uiSegActRoiPanelObject('set', uiSegActRoiPanel);
     
     chkRelativeToMaxRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [240 215 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkRelativeToMaxRoiPanelCallback...
                  );
     relativeToMaxRoiPanelValue('set', true);

     txtRelativeToMaxRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Upper Treshold to Max',...
                  'horizontalalignment', 'left',...
                  'position', [15 212 225 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkRelativeToMaxRoiPanelCallback...
                  );              
     
    chkInPercentRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [240 190 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkInPercentRoiPanelCallback...
                  );                           
    inPercentRoiPanelValue('set', true);

    txtInPercentRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Treshold in Percent',...
                  'horizontalalignment', 'left',...
                  'position', [15 187 225 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkInPercentRoiPanelCallback...
                  );
                  
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 155 200 20]...
                  );

    uiSliderMaxTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 140 175 14], ...
                  'Value'   , maxTresholdSliderRoiPanelValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', {@sliderMaxTresholdRoiPanelCallback} ...
                  );
    uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);
                 
    uiEditMaxTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 140 65 20], ...
                  'String'  , num2str(maxTresholdSliderRoiPanelValue('get')*100), ...
                  'Enable'  , 'On', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editMaxTresholdRoiPanelCallback ...
                  );
              
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Lower Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 105 200 20]...
                  );
              
    uiSliderMinTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 90 175 14], ...
                  'Value'   , minTresholdSliderRoiPanelValue('get'), ...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', {@sliderMinTresholdRoiPanelCallback} ...
                  );
    uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);
                                 
    uiEditMinTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 90 65 20], ...
                  'String'  , num2str(minTresholdSliderRoiPanelValue('get')*100), ...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editMinTresholdRoiPanelCallback ...
                  );
              
    uiCreateVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'String'  ,'Segment',...
                  'Position',[160 30 100 25],...
                  'Enable'  , 'On', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @createVoiRoiPanelCallback...
                  );

    minTresholdRoiPanelValue('set', true, 'Percent', minTresholdSliderRoiPanelValue('get'));                  
    maxTresholdRoiPanelValue('set', true, 'Percent', maxTresholdSliderRoiPanelValue('get'));   

    txtPixelEdgeRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Pixel Edge',...
                  'horizontalalignment', 'left',...
                  'position', [35 52 120 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkPixelEdgeRoiPanelCallback...
                  );
              
    chkPixelEdgeRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [15 55 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkPixelEdgeRoiPanelCallback...
                  );      
    
    
    txtMultipleObjectsRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Multiple Objects',...
                  'horizontalalignment', 'left',...
                  'position', [35 27 120 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkMultipleObjectsRoiPanelCallback...
                  );
              
    chkMultipleObjectsRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [15 30 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkMultipleObjectsRoiPanelCallback...
                  );  
              
    function chkPixelEdgeRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkPixelEdgeRoiPanel, 'Value') == true
                
                set(chkPixelEdgeRoiPanel, 'Value', false);
            else
                set(chkPixelEdgeRoiPanel, 'Value', true);
            end
        end 
        
        if get(chkPixelEdgeRoiPanel, 'Value') == true
            set(txtPixelEdgeRoiPanel, 'String', 'Pixel Edge');            
        else
            set(txtPixelEdgeRoiPanel, 'String', 'Pixel Center');            
        end
                       
    end

    function chkMultipleObjectsRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkMultipleObjectsRoiPanel, 'Value') == true
                
                set(chkMultipleObjectsRoiPanel, 'Value', false);
            else
                set(chkMultipleObjectsRoiPanel, 'Value', true);
            end
        end 
        
        if get(chkMultipleObjectsRoiPanel, 'Value') == true
            set(txtMultipleObjectsRoiPanel, 'String', 'Multiple Objects');            
        else
            set(txtMultipleObjectsRoiPanel, 'String', 'Single Object');            
        end
                       
    end
              
    function segActionRoiPanelCallback(hObject, ~)        
        
        setVoiRoiSegPopup();
              
        aActionType = get(hObject, 'String');
        dActionType = get(hObject, 'Value' );
        sActionType = aActionType{dActionType};       
        
        if strcmpi(sActionType, 'Entire Image')
            roiPanelMinValue('set', min(double(aBuffer),[], 'all'));
            roiPanelMaxValue('set', max(double(aBuffer),[], 'all'));        
        else         
            
            [dComputedMin, dComputedMax] = computeRoiPanelMinMax();
            
            if isempty(dComputedMin)||isempty(dComputedMax)
                
                set(uiSegActRoiPanel, 'Value' , 1);
                set(uiRoiVoiRoiPanel, 'Enable', 'off');

                return;
            else
                roiPanelMinValue('set', dComputedMin);
                roiPanelMaxValue('set', dComputedMax);                 
            end
                        
        end
%        delete(uiSliderMaxTresholdRoiListener);
%        delete(uiSliderMinTresholdRoiListener);
        
%        set(uiSliderMaxTresholdRoiPanel, 'Value', 1);
%        set(uiSliderMinTresholdRoiPanel, 'Value', 0);


        
 %       uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);  
 %       uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);  
        
    end 

    function sliderMaxTresholdRoiPanelCallback(~, hEvent)
                    
        dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
        
        if get(chkRelativeToMaxRoiPanel, 'Value') == false
            dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');

            if dMaxTresholdValue < dMinTresholdValue
                dMaxTresholdValue = dMinTresholdValue;
            end            
        end        
                
        if get(chkInPercentRoiPanel, 'Value') == true
                        
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxTresholdValue*100));
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Percent', dMaxTresholdValue);                  
            
        else
            aBuffer = dicomBuffer('get');                        
            
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                 
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);
            if strcmpi(sUnitDisplay, 'SUV')
                tQuant = quantificationTemplate('get');                                
                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end              
                                  
            dDiff = dMax - dMin;
            
            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            
            if dMaxValue < dMin
                dMaxValue = dMin;
            end
            
            if dMaxValue > dMax
                dMaxValue = dMax;
            end  
                        
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);  
            
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxValue));
           
        end          
        
        maxTresholdSliderRoiPanelValue('set', dMaxTresholdValue);       
       
        if strcmpi(hEvent.EventName, 'Action')        
            set(uiSliderMaxTresholdRoiPanel, 'Value',  maxTresholdSliderRoiPanelValue('get'));
        end   
        
        previewRoiSegmentation(get(chkPixelEdgeRoiPanel, 'Value'));
        
    end

    function editMaxTresholdRoiPanelCallback(hObject, ~)
        
        delete(uiSliderMaxTresholdRoiListener);
         
        sMaxValue = get(hObject, 'String');
        dMaxValue = str2double(sMaxValue);
        
        if get(chkRelativeToMaxRoiPanel, 'Value') == false
            sMinValue = get(uiEditMinTresholdRoiPanel, 'String');
            dMinValue = str2double(sMinValue);            
            if dMaxValue < dMinValue
                dMaxValue = dMinValue;
            end            
        end
            
        if get(chkInPercentRoiPanel, 'Value') == true
            
            if dMaxValue < 0
                dMaxValue = 0;
            end
            
            if dMaxValue > 100
                dMaxValue = 100;
            end
            
            maxTresholdSliderRoiPanelValue('set', dMaxValue/100);
            
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxValue));
            set(uiSliderMaxTresholdRoiPanel, 'Value' , dMaxValue/100);
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Percent', dMaxValue/100);                  

        else
            aBuffer = dicomBuffer('get');
                                   
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);
            if strcmpi(sUnitDisplay, 'SUV')
                tQuant = quantificationTemplate('get');                                
                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end              
            
            if dMaxValue < dMin
                dMaxValue = dMin;
            end
            
            if dMaxValue > dMax
                dMaxValue = dMax;
            end            
            
            dDiff = dMax - dMin;

            dRatio = (dMaxValue-dMin)/dDiff;            
                        
            maxTresholdSliderRoiPanelValue('set', dRatio);

            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxValue));
            set(uiSliderMaxTresholdRoiPanel, 'Value' , dRatio);
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);      
                        
        end          
        
        uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);        
        
        previewRoiSegmentation(get(chkPixelEdgeRoiPanel, 'Value'));

    end

    function sliderMinTresholdRoiPanelCallback(~, hEvent)
                    
        dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');
        
        if get(chkRelativeToMaxRoiPanel, 'Value') == false
            dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');

            if dMaxTresholdValue < dMinTresholdValue
                dMinTresholdValue = dMaxTresholdValue;
            end            
        end        
                
        if get(chkInPercentRoiPanel, 'Value') == true
                        
            set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinTresholdValue*100));
            
            minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Percent', dMinTresholdValue);                  
            
        else
            aBuffer = dicomBuffer('get');
                                   
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                  
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);
            if strcmpi(sUnitDisplay, 'SUV')
                tQuant = quantificationTemplate('get');                                
                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end              
                                  
            dDiff = dMax - dMin;
            
            dMinValue = (dMinTresholdValue*dDiff)+dMin;
            
            if dMinValue < dMin
                dMinValue = dMin;
            end
            
            if dMinValue > dMax
                dMinValue = dMax;
            end  
                        
            minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMinValue);  
            
            set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinValue));
           
        end          
        
        minTresholdSliderRoiPanelValue('set', dMinTresholdValue);       
       
        if strcmpi(hEvent.EventName, 'Action')        
            set(uiSliderMinTresholdRoiPanel, 'Value',  minTresholdSliderRoiPanelValue('get'));
        end   
        
        previewRoiSegmentation(get(chkPixelEdgeRoiPanel, 'Value'));

    end

    function editMinTresholdRoiPanelCallback(hObject, ~)
        
        delete(uiSliderMinTresholdRoiListener);
         
        sMinValue = get(hObject, 'String');
        dMinValue = str2double(sMinValue);
        
        if get(chkRelativeToMaxRoiPanel, 'Value') == false
            sMaxValue = get(uiEditMaxTresholdRoiPanel, 'String');
            dMaxValue = str2double(sMaxValue);            
            if dMaxValue < dMinValue
                dMinValue = dMaxValue;
            end            
        end
            
        if get(chkInPercentRoiPanel, 'Value') == true
            
            if dMinValue < 0
                dMinValue = 0;
            end
            
            if dMinValue > 100
                dMinValue = 100;
            end
            
            minTresholdSliderRoiPanelValue('set', dMinValue/100);
            
            set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinValue));
            set(uiSliderMinTresholdRoiPanel, 'Value' , dMinValue/100);
            
            minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Percent', dMinValue/100);                  

        else
            aBuffer = dicomBuffer('get');
                                   
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                  
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);
            if strcmpi(sUnitDisplay, 'SUV')
                tQuant = quantificationTemplate('get');                                
                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end              
            
            if dMinValue < dMin
                dMinValue = dMin;
            end
            
            if dMinValue > dMax
                dMinValue = dMax;
            end            
            
            dDiff = dMax - dMin;

            dRatio = (dMinValue-dMin)/dDiff;            
                        
            minTresholdSliderRoiPanelValue('set', dRatio);

            set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinValue));
            set(uiSliderMinTresholdRoiPanel, 'Value' , dRatio);
            
            minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMinValue);      
                        
        end          
        
        uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);    
        
        previewRoiSegmentation(get(chkPixelEdgeRoiPanel, 'Value'));

    end

    function chkRelativeToMaxRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkRelativeToMaxRoiPanel, 'Value') == true
                
                set(chkRelativeToMaxRoiPanel, 'Value', false);
            else
                set(chkRelativeToMaxRoiPanel, 'Value', true);
            end
        end
        
        relativeToMaxRoiPanelValue('set', get(chkRelativeToMaxRoiPanel, 'Value')); 
        
        if get(chkRelativeToMaxRoiPanel, 'Value') == true
            
            set(uiSliderMinTresholdRoiPanel, 'Enable', 'off');
            set(uiEditMinTresholdRoiPanel  , 'Enable', 'off');
            
            set(txtRelativeToMaxRoiPanel, 'String', 'Upper Treshold to Max');                
        else        
            delete(uiSliderMinTresholdRoiListener);
           
            set(uiSliderMinTresholdRoiPanel, 'Enable', 'on');
            set(uiEditMinTresholdRoiPanel  , 'Enable', 'on');            
            
            set(txtRelativeToMaxRoiPanel, 'String', 'Lower to Upper Treshold'); 
            
            if get(chkInPercentRoiPanel, 'Value') == true
                
                dMinPercentValue = minTresholdSliderRoiPanelValue('get');
                dMaxPercentValue = maxTresholdSliderRoiPanelValue('get');
                
                if dMinPercentValue > dMaxPercentValue
                    dMinPercentValue = dMaxPercentValue;
                end
            
                set(uiSliderMinTresholdRoiPanel, 'Value' , dMinPercentValue);
                set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinPercentValue*100));                                    
            
                minTresholdSliderRoiPanelValue('set', dMinPercentValue);              
                minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Persent', dMinPercentValue);                  
                                                                                
            else
                       
                aBuffer = dicomBuffer('get');

                dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');
                dMaxTresholdValue = maxTresholdSliderRoiPanelValue('get');

                dOffset = get(uiSeriesPtr('get'), 'Value');

                sUnitDisplay = getSerieUnitValue(dOffset);

                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                 

                dDiff = dMax - dMin;
                
                if dMinTresholdValue > dMaxTresholdValue
                    dMinTresholdValue = dMaxTresholdValue;
                end
                
                dMinValue = (dMinTresholdValue*dDiff)+dMin;                                                

                if strcmpi(sUnitDisplay, 'SUV')                
                    tQuant = quantificationTemplate('get');                
                    dMinValue = dMinValue*tQuant.tSUV.dScale;
                end                                

                set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinValue));                
                set(uiSliderMinTresholdRoiPanel, 'Value' , dMinTresholdValue);
                               
                minTresholdSliderRoiPanelValue('set', dMinTresholdValue);              
                minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMinValue);  
                
            end
            
            uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);        

        end
        
    end

    function chkInPercentRoiPanelCallback(hObject, ~)              
                       
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkInPercentRoiPanel, 'Value') == true
                
                set(chkInPercentRoiPanel, 'Value', false);
            else
                set(chkInPercentRoiPanel, 'Value', true);
            end
        end
        
       inPercentRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value')); 

        delete(uiSliderMaxTresholdRoiListener);
        if relativeToMaxRoiPanelValue('get') == false                
            delete(uiSliderMinTresholdRoiListener);
        end
        
        if get(chkInPercentRoiPanel, 'Value') == true
            
            set(txtInPercentRoiPanel, 'String', 'Treshold in Percent');
                                   
            dMaxPercentValue = maxTresholdSliderRoiPanelValue('get');
            
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxPercentValue*100));                                    
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Persent', dMaxPercentValue);  
            
            
            dMinPercentValue = minTresholdSliderRoiPanelValue('get');
            if relativeToMaxRoiPanelValue('get') == false                
                            
                set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinPercentValue*100));                                                
                minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Persent', dMinPercentValue);  
            else            
                set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinPercentValue*100));                 
            end

            
        else
            aBuffer = dicomBuffer('get');
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);

            set(txtInPercentRoiPanel, 'String', sprintf('Treshold in %s', sUnitDisplay));    
                        
            dMaxTresholdValue = maxTresholdSliderRoiPanelValue('get');
            
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                
            
            dDiff = dMax - dMin;
            
            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
                        
            if strcmpi(sUnitDisplay, 'SUV')                
                tQuant = quantificationTemplate('get');                
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end            
            
            set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);     
            
            dMinTresholdValue = minTresholdSliderRoiPanelValue('get');

            dMinValue = (dMinTresholdValue*dDiff)+dMin;

            if strcmpi(sUnitDisplay, 'SUV')                
                tQuant = quantificationTemplate('get');                
                dMinValue = dMinValue*tQuant.tSUV.dScale;
            end  
                
            if relativeToMaxRoiPanelValue('get') == false
                
                set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));
            
                minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMinValue); 
            else
                set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));                
            end
          
        end   
        
        uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);        
        if relativeToMaxRoiPanelValue('get') == false                
            uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);        
        end                       
    end

    function previewRoiSegmentation(bPixelEdge)
        
        aBuffer = dicomBuffer('get');
        if isempty(aBuffer)
            return;
        end
        
        if switchTo3DMode('get')     == true ||  ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            return;
        end        
        
        if isVsplash('get') == true
            return;
        end
        
        try  
                       
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;
        
        refreshImages();
        
        uiSegActRoiPanelObj = uiSegActRoiPanelObject('get');
        
        aActionType = get(uiSegActRoiPanelObj, 'String');
        dActionType = get(uiSegActRoiPanelObj, 'Value' );
        sActionType = aActionType{dActionType};
        
        uiRoiVoiRoiPanelObj   = uiRoiVoiRoiPanelObject('get');
        uiRoiVoiRoiPanelValue = get(uiRoiVoiRoiPanelObj, 'Value');
        
        bRelativeToMax = relativeToMaxRoiPanelValue('get');
 
        dSliderMin = minTresholdSliderRoiPanelValue('get');
        dSliderMax = maxTresholdSliderRoiPanelValue('get');
        
        dBufferMin = roiPanelMinValue('get');
        dBufferMax = roiPanelMaxValue('get');                              
        
        dBufferDiff = dBufferMax - dBufferMin;           
        
        dMinTreshold = (dSliderMin * dBufferDiff)+dBufferMin;
        dMaxTreshold = (dSliderMax * dBufferDiff)+dBufferMin;
            
        if size(aBuffer, 3) == 1
            
            vBoundAxePtr = visBoundAxePtr('get');
            if ~isempty(vBoundAxePtr)
                delete(vBoundAxePtr);
            end
            
            imAxe = imAxePtr ('get');
            aAxe  = imAxe.CData;

            if strcmpi(sActionType, 'Entire Image')
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold)   = cropValue('get');                                      
                else    
                    aAxe(aAxe<=dMinTreshold) = cropValue('get');
                    aAxe(aAxe>=dMaxTreshold) = cropValue('get');                                       
                end   
                
                [maskAxe ,~,~,~] = bwboundaries(imbinarize(aAxe), 'noholes', 4);

                vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);

                visBoundAxePtr('set', vBoundAxePtr);                
            else
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
                
                if strcmpi(aobjList{uiRoiVoiRoiPanelValue}.ObjectType, 'voi')
                    
                    dNbRois = numel(aobjList{uiRoiVoiRoiPanelValue}.RoisTag);             
                    
                    aVoiBuffer = zeros(size(aBuffer));
                    aVoiBuffer(aVoiBuffer==0) = cropValue('get');
                    
                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
                                objRoi   = tRoiInput{cc}.Object;

                                switch objRoi.Parent
                                    case axePtr('get')
                                        aSlice = aBuffer(:,:); 
                                        roiMask = createMask(objRoi, aSlice); 
                                        
                                        if strcmpi(sActionType, 'Inside ROI\VOI')                            
                                            aSlice(roiMask)  = cropValue('get'); 
                                        else
                                            aSlice(~roiMask) = cropValue('get');                              
                                        end
                                        
                                        aVoiBuffer(:,:) = aSlice;                                                                            
                                end                           

                                break; 
                             end
                        end
                    end
                    aAxe = aVoiBuffer(:,:);                
                else
                    objRoi   = aobjList{uiRoiVoiRoiPanelValue}.Object;
                    
                    aVoiBuffer = zeros(size(aBuffer));
                    
                    switch objRoi.Parent
                        case axePtr('get')
                            aSlice = aBuffer(:,:); 
                            roiMask = createMask(objRoi, aSlice);     

                            if strcmpi(sActionType, 'Outside ROI\VOI')                            
                                roiMask = ~roiMask;                              
                            end

                            aSlice(roiMask == 0) = roiMask(roiMask == 0); 
                            aVoiBuffer = aSlice;                   
                    end           
                    
                    aAxe = aVoiBuffer(:,:);                     
                end
                
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold)   = cropValue('get');                    
                else    
                    aAxe(aAxe<=dMinTreshold) = cropValue('get');
                    aAxe(aAxe>=dMaxTreshold) = cropValue('get');                                       
                end                
                
                if bPixelEdge == true
                    aAxe = imresize(aAxe , 3, 'nearest'); % do not go directly through pixel centers
                end
                
                [maskAxe ,~,~,~] = bwboundaries(imbinarize(aAxe) , 'noholes', 4);
                
                if bPixelEdge == true
                    if ~isempty(maskAxe)
                        for jj=1:numel(maskAxe)
                            maskAxe{jj} = (maskAxe{jj} +1)/3;                                                            
                        end
                    end                  
                end   
                
                vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);

                visboundaries('set', vBoundAxePtr);
                                                
            end                        
        else
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            aCoronal  = imCoronal.CData;
            aSagittal = imSagittal.CData;
            aAxial    = imAxial.CData;      
            
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
            
            if strcmpi(sActionType, 'Entire Image')
                                    
                if bRelativeToMax == true
                    aCoronal(aCoronal<=dMaxTreshold)   = cropValue('get');                    
                    aSagittal(aSagittal<=dMaxTreshold) = cropValue('get');                    
                    aAxial(aAxial<=dMaxTreshold)       = cropValue('get');                    
                else    
                    aCoronal(aCoronal<=dMinTreshold) = cropValue('get');
                    aCoronal(aCoronal>=dMaxTreshold) = cropValue('get');
                    
                    aSagittal(aSagittal<=dMinTreshold) = cropValue('get');
                    aSagittal(aSagittal>=dMaxTreshold) = cropValue('get');
                    
                    aAxial(aAxial<=dMinTreshold) = cropValue('get');
                    aAxial(aAxial>=dMaxTreshold) = cropValue('get');                                        
                end                
                                                
                if bPixelEdge == true
                    aCoronal  = imresize(aCoronal , 3, 'nearest'); % do not go directly through pixel centers
                    aSagittal = imresize(aSagittal, 3, 'nearest'); % do not go directly through pixel centers
                    aAxial    = imresize(aAxial   , 3, 'nearest'); % do not go directly through pixel centers
                end
                                
                [maskCoronal ,~,~,~] = bwboundaries(imbinarize(aCoronal ), 'noholes', 4);
                [maskSagittal,~,~,~] = bwboundaries(imbinarize(aSagittal), 'noholes', 4);           
                [maskAxial   ,~,~,~] = bwboundaries(imbinarize(aAxial)   , 'noholes', 4);
                
                if bPixelEdge == true
                    if ~isempty(maskCoronal)
                        for jj=1:numel(maskCoronal)
                            maskCoronal{jj} = (maskCoronal{jj} +1)/3;                                                            
                        end
                    end
                    if ~isempty(maskSagittal)
                        for jj=1:numel(maskSagittal)
                            maskSagittal{jj} = (maskSagittal{jj} +1)/3;                                                            
                        end
                    end
                    if ~isempty(maskAxial)
                        for jj=1:numel(maskAxial)
                            maskAxial{jj} = (maskAxial{jj} +1)/3;                                                            
                        end
                    end                    
                end                        
                                
                vBoundAxes1Ptr = visboundaries(axes1Ptr('get'), maskCoronal );
                vBoundAxes2Ptr = visboundaries(axes2Ptr('get'), maskSagittal);
                vBoundAxes3Ptr = visboundaries(axes3Ptr('get'), maskAxial   );

                visBoundAxes1Ptr('set', vBoundAxes1Ptr);
                visBoundAxes2Ptr('set', vBoundAxes2Ptr);
                visBoundAxes3Ptr('set', vBoundAxes3Ptr);

            else
                
                iCoronal  = sliceNumber('get', 'coronal' );
                iSagittal = sliceNumber('get', 'sagittal');
                iAxial    = sliceNumber('get', 'axial'   );
        
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
                
                if strcmpi(aobjList{uiRoiVoiRoiPanelValue}.ObjectType, 'voi')
                    
                    dNbRois = numel(aobjList{uiRoiVoiRoiPanelValue}.RoisTag);             
                    
                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                       strcmpi(sActionType, 'Outside ROI\VOI')     
                        aVoiBuffer = zeros(size(aBuffer));
                        aVoiBuffer(aVoiBuffer==0) = cropValue('get');
                    else
                        aVoiBuffer = aBuffer;
                    end
                    
                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
                                objRoi   = tRoiInput{cc}.Object;
                                dSliceNb = tRoiInput{cc}.SliceNb;

                                switch objRoi.Parent
                                        
                                    case axes1Ptr('get')
                                         aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                         roiMask = createMask(objRoi, aSlice);                                   
                                         
                                         if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Inside ROI\VOI') 
                                            aSlice(~roiMask) = cropValue('get'); 
                                         else
                                            aSlice(roiMask) = cropValue('get');                              
                                         end
                                         
                                         aVoiBuffer(dSliceNb,:,:) = aSlice;
                                        
                                    case axes2Ptr('get')
                                         aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                         roiMask = createMask(objRoi, aSlice);     
                                         
                                         if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...                         
                                            strcmpi(sActionType, 'Inside ROI\VOI') 
                                            aSlice(~roiMask) = cropValue('get'); 
                                         else
                                            aSlice(roiMask) = cropValue('get');                              
                                         end                                        
                                         
                                         aVoiBuffer(:,dSliceNb,:) = aSlice;
                                        
                                    case axes3Ptr('get')
                                        
                                        aSlice = aBuffer(:,:,dSliceNb); 
                                        roiMask = createMask(objRoi, aSlice); 
                                        
                                        if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...                           
                                           strcmpi(sActionType, 'Inside ROI\VOI') 
                                            aSlice(~roiMask)  = cropValue('get'); 
                                        else
                                            aSlice(roiMask) = cropValue('get');                              
                                        end   
                                        
                                        aVoiBuffer(:,:,dSliceNb) = aSlice;                                       
                                end
                           

                                break; 
                             end
                        end
                    end
                    aCoronal  = permute(aVoiBuffer(iCoronal,:,:), [3 2 1]);
                    aSagittal = permute(aVoiBuffer(:,iSagittal,:), [3 1 2]);
                    aAxial    = aVoiBuffer(:,:,iAxial);
                else
                    objRoi   = aobjList{uiRoiVoiRoiPanel.Value}.Object;
                    dSliceNb = aobjList{uiRoiVoiRoiPanel.Value}.SliceNb;
                    
                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                       strcmpi(sActionType, 'Outside ROI\VOI')                             
                        aVoiBuffer = zeros(size(aBuffer));
                    else
                        aVoiBuffer = aBuffer;
                    end
                    
                    switch objRoi.Parent

                        case axes1Ptr('get')
                            
                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                                for cc=1:size(aBuffer, 1)
                                    aSlice = permute(aBuffer(cc,:,:), [3 2 1]);
                                    roiMask = createMask(objRoi, aSlice);    

                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                                        roiMask = ~roiMask;                              
                                    end

                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    aVoiBuffer(cc,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);

                                end
                            else
                                aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                roiMask = createMask(objRoi, aSlice);    

                                if strcmpi(sActionType, 'Outside ROI\VOI')                            
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                            end

                        case axes2Ptr('get')

                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                for ss=1:size(aBuffer, 2)
                                    aSlice = permute(aBuffer(:,ss,:), [3 1 2]);
                                    roiMask = createMask(objRoi, aSlice);        

                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                                        roiMask = ~roiMask;                              
                                    end

                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    aVoiBuffer(:,ss,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                end
                            else
                                aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                roiMask = createMask(objRoi, aSlice);        

                                if strcmpi(sActionType, 'Outside ROI\VOI')                            
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                            end
                            
                        case axes3Ptr('get')

                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                               strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                           
                                for aa=1:size(aBuffer, 3)
                                    aSlice = aBuffer(:,:,aa); 
                                    roiMask = createMask(objRoi, aSlice);  

                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                                        roiMask = ~roiMask;                              
                                    end

                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    aVoiBuffer(:,:,aa) = aSlice;

                                end   
                            else
                                aSlice = aBuffer(:,:,dSliceNb); 
                                roiMask = createMask(objRoi, aSlice);  

                                if strcmpi(sActionType, 'Outside ROI\VOI')                            
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                aVoiBuffer(:,:,dSliceNb) = aSlice;

                            end
                    end           
                    
                    aCoronal  = permute(aVoiBuffer(iCoronal,:,:), [3 2 1]);
                    aSagittal = permute(aVoiBuffer(:,iSagittal,:), [3 1 2]);
                    aAxial    = aVoiBuffer(:,:,iAxial);                                                        
                end                
                
                if bRelativeToMax == true
                    aCoronal(aCoronal<=dMaxTreshold)   = cropValue('get');                    
                    aSagittal(aSagittal<=dMaxTreshold) = cropValue('get');                    
                    aAxial(aAxial<=dMaxTreshold)       = cropValue('get');                    
                else    
                    aCoronal(aCoronal<=dMinTreshold) = cropValue('get');
                    aCoronal(aCoronal>=dMaxTreshold) = cropValue('get');
                    
                    aSagittal(aSagittal<=dMinTreshold) = cropValue('get');
                    aSagittal(aSagittal>=dMaxTreshold) = cropValue('get');
                    
                    aAxial(aAxial<=dMinTreshold) = cropValue('get');
                    aAxial(aAxial>=dMaxTreshold) = cropValue('get');                                        
                end                
                
                if bPixelEdge == true
                    aCoronal  = imresize(aCoronal , 3, 'nearest'); % do not go directly through pixel centers
                    aSagittal = imresize(aSagittal, 3, 'nearest'); % do not go directly through pixel centers
                    aAxial    = imresize(aAxial   , 3, 'nearest'); % do not go directly through pixel centers
                end                         
                
                [maskCoronal ,~,~,~] = bwboundaries(imbinarize(aCoronal) , 'noholes', 4);
                [maskSagittal,~,~,~] = bwboundaries(imbinarize(aSagittal), 'noholes', 4);           
                [maskAxial   ,~,~,~] = bwboundaries(imbinarize(aAxial)   , 'noholes', 4);
                
                if bPixelEdge == true
                    if ~isempty(maskCoronal)
                        for jj=1:numel(maskCoronal)
                            maskCoronal{jj} = (maskCoronal{jj} +1)/3;                                                            
                        end
                    end
                    if ~isempty(maskSagittal)
                        for jj=1:numel(maskSagittal)
                            maskSagittal{jj} = (maskSagittal{jj} +1)/3;                                                            
                        end
                    end
                    if ~isempty(maskAxial)
                        for jj=1:numel(maskAxial)
                            maskAxial{jj} = (maskAxial{jj} +1)/3;                                                            
                        end
                    end                    
                end 
                
                vBoundAxes1Ptr = visboundaries(axes1Ptr('get'), maskCoronal );
                vBoundAxes2Ptr = visboundaries(axes2Ptr('get'), maskSagittal);
                vBoundAxes3Ptr = visboundaries(axes3Ptr('get'), maskAxial   );

                visBoundAxes1Ptr('set', vBoundAxes1Ptr);
                visBoundAxes2Ptr('set', vBoundAxes2Ptr);
                visBoundAxes3Ptr('set', vBoundAxes3Ptr);                
            end
           
        end
        catch
            progressBar(1, 'Error:previewRoiSegmentation()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;          
                       
    end

    function createVoiRoiPanelCallback(~, ~)
        
        if strcmpi(get(uiCreateVoiRoiPanel, 'String'), 'Cancel')
            cancelCreateVoiRoiPanel('set', true);                       
        else                   
            bPixelEdge       = get(chkPixelEdgeRoiPanel, 'Value');
            bMultipleObjects = get(chkMultipleObjectsRoiPanel, 'Value');

%            set(uiCreateVoiRoiPanel, 'String', 'Cancel');
            
            cancelCreateVoiRoiPanel('set', false);                       

            createVoiRoi(bMultipleObjects, bPixelEdge);     
        end        
        
        cancelCreateVoiRoiPanel('set', false);                       
        
        set(uiCreateVoiRoiPanel, 'String', 'Segment');
        
    end

    function createVoiRoi(bMultipleObjects, bPixelEdge)
        
        aBuffer = dicomBuffer('get');
        if isempty(aBuffer)
            return;
        end
        
        if switchTo3DMode('get')     == true ||  ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            return;
        end        
        
        if isVsplash('get') == true
            return;
        end    
        
        try                     
            
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;
        
        uiSeries = uiSeriesPtr('get');
        uiSeriesValue = get(uiSeries, 'Value');
%        refreshImages();
        
        uiSegActRoiPanelObj = uiSegActRoiPanelObject('get');
        
        aActionType = get(uiSegActRoiPanelObj, 'String');
        dActionType = get(uiSegActRoiPanelObj, 'Value' );
        sActionType = aActionType{dActionType};
        
        uiRoiVoiRoiPanelObj   = uiRoiVoiRoiPanelObject('get');
        uiRoiVoiRoiPanelValue = get(uiRoiVoiRoiPanelObj, 'Value');

        bRelativeToMax = relativeToMaxRoiPanelValue('get');
        bInPercent     = inPercentRoiPanelValue('get');
        
        dSliderMin = minTresholdSliderRoiPanelValue('get');
        dSliderMax = maxTresholdSliderRoiPanelValue('get');
        
        dBufferMin = roiPanelMinValue('get');
        dBufferMax = roiPanelMaxValue('get');                             
        
        dBufferDiff = dBufferMax - dBufferMin;           
        
        dMinTreshold = (dSliderMin * dBufferDiff)+dBufferMin;
        dMaxTreshold = (dSliderMax * dBufferDiff)+dBufferMin;
                    
        if size(aBuffer, 3) == 1
        else
            
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
            
            if strcmpi(sActionType, 'Entire Image')        

                if bRelativeToMax == true
                    aBuffer(aBuffer<=dMaxTreshold) = cropValue('get');                                       
                else    
                    aBuffer(aBuffer<=dMinTreshold) = cropValue('get');
                    aBuffer(aBuffer>=dMaxTreshold) = cropValue('get');                                        
                end                    
                
%                BW = aBuffer;                
%                BW(BW == cropValue('get'))=0;
%                BW(BW ~= 0)=1;
                
                BW = imbinarize(aBuffer);
                
                if bMultipleObjects == true                    
                    CC = bwconncomp(BW, 6);
%                    S = regionprops(CC, 'Area');
%                    L = labelmatrix(CC);     
                    dNbElements = numel(CC.PixelIdxList);
                else
                    dNbElements = 1;                        
                end                 
                
                for bb=1:dNbElements  % Nb VOI  
                    
                    if cancelCreateVoiRoiPanel('get') == true
                        break;
                    end
                        
                    if bMultipleObjects == true                    
                        B = zeros(size(BW));                
                        B(CC.PixelIdxList{bb}) = 1;                
                    else
                        B = BW;
                    end
                    
                    asTag = [];
                     
                    progressBar( bb/dNbElements-0.0001, sprintf('Computing Volume %d/%d, please wait', bb, dNbElements) );  
                    
                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);
                    
                    aBufferSize = size(B, 3);
                  
                    for aa=1:aBufferSize % Find ROI
                        
%                        progressBar( aa/aBufferSize, sprintf('Computing slice %d/%d, please wait', bb, aBufferSize) );  
                        
                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end

                        aAxial = B(:,:,aa);   
                        if aAxial(aAxial==1)
                            if bPixelEdge == true
                                aAxial = imresize(aAxial,3, 'nearest'); % do not go directly through pixel centers
                            end

                            [maskAxial,~,~,~] = bwboundaries(aAxial, 'noholes', 4);  
                            if ~isempty(maskAxial)
                                for jj=1:numel(maskAxial)

                                    if cancelCreateVoiRoiPanel('get') == true
                                        break;
                                    end

                                    curentMask = maskAxial(jj); 

                                    if bPixelEdge == true
                                        curentMask{1} = (curentMask{1} +1)/3;                                
                                    end

                                    sliceNumber('set', 'axial', aa);

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

     %                               pRoi = drawfreehand(axes3Ptr('get') , 'Position', curentMask, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', 0);
                                    aPosition = flip(curentMask{1}, 2);

                                    pRoi = drawfreehand(axes3Ptr('get') , 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', 0);
                                    pRoi.Waypoints(:) = false;

                                    addRoi(pRoi, uiSeriesValue);                  

                                    roiDefaultMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback); 
                                    uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback); 

                                    cropMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');                     

                                    asTag{numel(asTag)+1} = sTag; 
                                end
                            end
                        end
                    end
                    
                    if ~isempty(asTag) && cancelCreateVoiRoiPanel('get') == false
                        
                        if bInPercent == true
                            dMinValue = dSliderMin*100; 
                            dMaxValue = dSliderMax*100;                                 
                        else
                            dMinValue = dMinTreshold; 
                            dMaxValue = dMaxTreshold;                                  
                        end

                        if bRelativeToMax == true
                            if bMultipleObjects == true
                                sLabel = sprintf('RMAX-%d-VOI%d', dMaxValue, bb);
                            else
                                sLabel = sprintf('RMAX-%d', dMaxValue);
                            end
                        else
                            if bMultipleObjects == true
                                sLabel = sprintf('MIN-MAX-%d-%d-VOI%d', dMinValue, dMaxValue, bb);
                            else
                                sLabel = sprintf('MIN-MAX-%d-%d-%d', dMinValue, dMaxValue);
                            end
                        end
                            
                        createVoiFromRois(asTag, sLabel);
                        
                    end                     
                end
                
                setVoiRoiSegPopup();
                
                refreshImages();
                
                progressBar(1, 'Ready');  
                
            else
%                currentAxe = [];
                
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
                
                if strcmpi(aobjList{uiRoiVoiRoiPanelValue}.ObjectType, 'voi')
                    
                    dNbRois = numel(aobjList{uiRoiVoiRoiPanelValue}.RoisTag);             
                      
                    aVoiBuffer = zeros(size(aBuffer));
                    aVoiBuffer(aVoiBuffer==0) = cropValue('get');
                    
                    for bb=1:dNbRois
                        
                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end                        

                        for cc=1:numel(tRoiInput)
                            
                            if cancelCreateVoiRoiPanel('get') == true
                                break;
                            end                            
                            
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
                                objRoi   = tRoiInput{cc}.Object;
                                dSliceNb = tRoiInput{cc}.SliceNb;

                                switch objRoi.Parent
                                        
                                    case axes1Ptr('get')
%                                        currentAxe = axes1Ptr('get');
                                        
                                         aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                         roiMask = createMask(objRoi, aSlice);                                   
                                         
                                         if strcmpi(sActionType, 'Outside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside ROI\VOI') 
                                            roiMask = ~roiMask;                             
                                         end
                                         
                                         aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 
                                               
                                         if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                            for dd=1:size(aVoiBuffer, 1)
                                                aVoiBuffer(dd,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                            end
                                         else
                                            aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                         end
                                        
                                    case axes2Ptr('get')
%                                        currentAxe = axes2Ptr('get');
                                        
                                         aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                         roiMask = createMask(objRoi, aSlice);     
                                         
                                         if strcmpi(sActionType, 'Outside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside ROI\VOI') 
                                            roiMask = ~roiMask;                             
                                         end
                                         
                                         aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 
                                         
                                         if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                            for dd=1:size(aVoiBuffer, 2)
                                                aVoiBuffer(:,dd,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                                            end
                                         else
                                            aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                                         end                                         
                                        
                                    case axes3Ptr('get')
%                                        currentAxe = axes3Ptr('get');
                                        
                                         aSlice = aBuffer(:,:,dSliceNb); 
                                         roiMask = createMask(objRoi, aSlice); 
                                        
                                         if strcmpi(sActionType, 'Outside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside ROI\VOI') 
                                            roiMask = ~roiMask;                             
                                         end
                                         
                                         aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 
                                         
                                         if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                            strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                            for dd=1:size(aVoiBuffer, 3)
                                                aVoiBuffer(:,:,dd) = aSlice;
                                            end
                                         else
                                            aVoiBuffer(:,:,dSliceNb) = aSlice;
                                         end                                       
                                end
                           

                                break; 
                             end
                        end
                    end                     
                else 
                    
                    objRoi   = aobjList{uiRoiVoiRoiPanelValue}.Object;
                    dSliceNb = aobjList{uiRoiVoiRoiPanelValue}.SliceNb;                    
                    
                    aVoiBuffer = zeros(size(aBuffer));
                    aVoiBuffer(aVoiBuffer==0) = cropValue('get');
                                           
                    for cc=1:numel(tRoiInput)

                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end                            

                        if isvalid(objRoi) 

                            switch objRoi.Parent

                                case axes1Ptr('get')
%                                        currentAxe = axes1Ptr('get');

                                     if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                        strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                        for dd=1:size(aVoiBuffer, 1)
                                             aSlice = permute(aBuffer(dd,:,:), [3 2 1]);
                                             roiMask = createMask(objRoi, aSlice);                                   

                                             if strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                                roiMask = ~roiMask;                             
                                             end

                                             aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 

                                             aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                     
                                             aVoiBuffer(dd,:,:) = aSlice;
                                         end
                                     else
                                         aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                         roiMask = createMask(objRoi, aSlice);                                   

                                         if strcmpi(sActionType, 'Outside ROI\VOI') 
                                            roiMask = ~roiMask;                             
                                         end

                                         aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 

                                         aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                     
                                        aVoiBuffer(dSliceNb,:,:) = aSlice;
                                     end

                                case axes2Ptr('get')
%                                        currentAxe = axes2Ptr('get');

                                     if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                        strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                        for dd=1:size(aVoiBuffer, 2)
                                            
                                            aSlice = permute(aBuffer(:,dd,:), [3 1 2]);
                                            roiMask = createMask(objRoi, aSlice);     

                                            if strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                               roiMask = ~roiMask;                             
                                            end

                                            aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 

                                            aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                                         
                                            aVoiBuffer(:,dd,:) = aSlice;
                                        end
                                     else
                                         aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                         roiMask = createMask(objRoi, aSlice);     

                                         if strcmpi(sActionType, 'Outside ROI\VOI')                                             
                                            roiMask = ~roiMask;                             
                                         end

                                         aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 

                                         aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                                         
                                         aVoiBuffer(:,dSliceNb,:) = aSlice;
                                     end                                         

                                case axes3Ptr('get')
%                                        currentAxe = axes3Ptr('get');

                                     if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                        strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                        for dd=1:size(aVoiBuffer, 3)
                                            aSlice = aBuffer(:,:,dd); 
                                            roiMask = createMask(objRoi, aSlice); 

                                            if strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                               roiMask = ~roiMask;                             
                                            end

                                            aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0);                                             
                                            aVoiBuffer(:,:,dd) = aSlice;
                                        end
                                     else
                                        aSlice = aBuffer(:,:,dSliceNb); 
                                        roiMask = createMask(objRoi, aSlice); 

                                        if strcmpi(sActionType, 'Outside ROI\VOI') 
                                           roiMask = ~roiMask;                             
                                        end

                                        aSlice(roiMask == 0) = cropValue('get')-roiMask(roiMask == 0); 
                                     
                                        aVoiBuffer(:,:,dSliceNb) = aSlice;
                                     end                                       
                            end


                            break; 
                         end
                    end                                                             
                end
                                
               if bRelativeToMax == true
                    aVoiBuffer(aVoiBuffer<=dMaxTreshold) = cropValue('get');                                       
                else    
                    aVoiBuffer(aVoiBuffer<=dMinTreshold) = cropValue('get');
                    aVoiBuffer(aVoiBuffer>=dMaxTreshold) = cropValue('get');                                        
                end   

%                BW = aVoiBuffer;                
%                BW(BW == cropValue('get'))=0;
%                BW(BW ~= 0)=1;
                
                BW = imbinarize(aVoiBuffer);

                if bMultipleObjects == true                    
                    CC = bwconncomp(BW, 6);
%                        S = regionprops(CC, 'Area');
%                        L = labelmatrix(CC);     
                    dNbElements = numel(CC.PixelIdxList);
                else
                    dNbElements = 1;                        
                end

                for bb=1:dNbElements  % Nb VOI  

                    if cancelCreateVoiRoiPanel('get') == true
                        break;
                    end

                    if bMultipleObjects == true                                            
                        B = zeros(size(aVoiBuffer));  
                        B(CC.PixelIdxList{bb}) = 1;                
                    else
                        B = BW;
                    end

                    asTag = [];

                    progressBar( bb/dNbElements-0.0001, sprintf('Computing Volume %d/%d, please wait', bb, dNbElements) );  

                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);

%                        switch currentAxe
%                            case axes1Ptr('get')
%                                aBufferSize = size(B, 1);

%                            case axes2Ptr('get')
%                                aBufferSize = size(B, 2);

%                            case axes3Ptr('get')
%                                aBufferSize = size(B, 3);

%                            otherwise
%                                progressBar(1, 'Error: createVoiRoi() no axe found!');  
%                                break
%                        end

                    aBufferSize = size(B, 3);

                    for aa=1:aBufferSize % Find ROI

%                            progressBar( aa/aBufferSize, sprintf('Computing slice %d/%d, please wait', bb, aBufferSize) );  

                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end

%                            switch currentAxe
%                                case axes1Ptr('get')
%                                    aSlice = permute(B(aa,:,:), [3 2 1]);

%                                case axes2Ptr('get')
%                                    aSlice = permute(B(:,aa,:), [3 1 2]);

%                                case axes3Ptr('get')
%                                    aSlice = B(:,:,aa);
%                            end

                        aSlice = B(:,:,aa);
                        
                        if aSlice(aSlice~=0)
                            if bPixelEdge == true
                                aSlice = imresize(aSlice,3,'nearest'); % do not go directly through pixel centers
                            end

                            [maskSlice, ~,~,~] = bwboundaries(aSlice, 'noholes', 4); 
                            
                            if bMultipleObjects == false
                                if mod(aa, 5)==1 || aa == aBufferSize         
                                    progressBar( aa/aBufferSize-0.0001, sprintf('Computing slice %d/%d, please wait', aa, aBufferSize) );  
                                end
                            end

                            if ~isempty(maskSlice)
                                for jj=1:numel(maskSlice)

                                    if cancelCreateVoiRoiPanel('get') == true
                                        break;
                                    end

                                    curentMask = maskSlice(jj);
                                    if bPixelEdge == true
                                        curentMask{1} = (curentMask{1} +1)/3;                                
                                    end

                                    sliceNumber('set', 'axial', aa);

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                    aPosition = flip(curentMask{1}, 2);

                                    pRoi = drawfreehand(axes3Ptr('get') , 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', 0);
                                    pRoi.Waypoints(:) = false;

                                    addRoi(pRoi, uiSeriesValue);                  

                                    roiDefaultMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback); 
                                    uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback); 

                                    cropMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');                     

                                    asTag{numel(asTag)+1} = sTag;   
                                end
                            end
                        end
                    end

                    if ~isempty(asTag) && cancelCreateVoiRoiPanel('get') == false

                        if bInPercent == true
                            dMinValue = dSliderMin*100; 
                            dMaxValue = dSliderMax*100;                                 
                        else
                            dMinValue = dMinTreshold; 
                            dMaxValue = dMaxTreshold;                                  
                        end

                        if bRelativeToMax == true
                            if bMultipleObjects == true
                                sLabel = sprintf('RMAX-%d-VOI%d', dMaxValue, bb);
                            else
                                sLabel = sprintf('RMAX-%d', dMaxValue);
                            end
                        else
                            if bMultipleObjects == true
                                sLabel = sprintf('MIN-MAX-%d-%d-VOI%d', dMinValue, dMaxValue, bb);
                            else
                                sLabel = sprintf('MIN-MAX-%d-%d-%d', dMinValue, dMaxValue);
                            end
                        end

                        createVoiFromRois(asTag, sLabel);
                        
                    end                     
                end
                
                setVoiRoiSegPopup();

                progressBar(1, 'Ready');  

                refreshImages();                
            end
        end
        catch
            progressBar(1, 'Error:createVoiRoi()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;            
             
    end


end