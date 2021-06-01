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
                  'position', [15 410 200 20]...
                  );
              
      uiRoiVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [95 380 160 20],...
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
                  'position'  , [15 380 75 20],...
                  'String'  , asSegOptions, ...
                  'Value'   , 1,...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @segActionRoiPanelCallback...
                  );
    uiSegActRoiPanelObject('set', uiSegActRoiPanel);
                      
    tRoiPanelCT = roiPanelCtUiValues('get');
    if isempty(tRoiPanelCT) || size(aBuffer, 3) == 1
        
        dUnitTypeValue = false; 

        sUseCtEnable    = 'off';
        sChkUseCTEnable = 'off';
        sTxtUseCTEnable = 'on';
        
        asCTSeries = {' '};
    else
                
        sChkUseCTEnable = 'on'; 
        sTxtUseCTEnable = 'Inactive';
        
        if roiPanelUseCt('get') == true
            
            sUseCtEnable = 'on';            
        
        else
            sUseCtEnable = 'off';
        end          
                
        asCTSeries = num2cell(zeros(1,numel(tRoiPanelCT)));
        for ll=1:numel(tRoiPanelCT)
            asCTSeries{ll} = tRoiPanelCT{ll}.sSeriesDescription;
        end         
        
        dOffset = get(uiSeriesPtr('get'), 'Value');        
        sUnitDisplay = getSerieUnitValue(dOffset); 
        if strcmpi(sUnitDisplay, 'SUV')
            dUnitTypeValue = true;
        else
            dUnitTypeValue = false; 
        end
    end
    
        
    chkUnitTypeRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , sUseCtEnable,...
                  'value'   , dUnitTypeValue,...
                  'position', [15 350 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkUnitTypeRoiPanelCallback...
                  );
    chkUnitTypeRoiPanelObject('set', chkUnitTypeRoiPanel); 
                           
    txtUnitTypeRoiPanel = ...
         uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Unit in Percent',...
                  'horizontalalignment', 'left',...
                  'position', [35 347 200 20],...
                  'Enable', 'On',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkUnitTypeRoiPanelCallback...
                  );      

    chkUseCTRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , sChkUseCTEnable,...
                  'value'   , roiPanelUseCt('get'),...
                  'position', [15 325 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkUseCTRoiPanelCallback...
                  );
                            
    txtUseCTRoiPanel = ...
         uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Use CT Map',...
                  'horizontalalignment', 'left',...
                  'position', [35 322 200 20],...
                  'Enable', sTxtUseCTEnable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkUseCTRoiPanelCallback...
                  );
                  
    uiSeriesCTRoiPanel = ...
         uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 290 245 25], ...
                  'String'  , asCTSeries, ...
                  'Value'   , roiPanelCtSerieOffset('get'),...
                  'Enable'  , sUseCtEnable, ...
                  'Callback', @setCTRoiPanelSeriesCallback, ...
                  'BackgroundColor', viewerBackgroundColor ('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
    uiCTRoiPanelSeriesObject('set', uiSeriesCTRoiPanel); 
                                
    edtSmalestRegion = ...
         uicontrol(uiRoiPanelPtr('get'),...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(smalestRegionRoiPanelValue('get')),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [195 265 65 20],...
                  'Callback', @edtSmalestRegionCallback...
                  );
              
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Smalest ROI (nb pixels)',...
                  'horizontalalignment', 'left',...
                  'position', [15 262 165 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkRelativeToMaxRoiPanelCallback...
                  );
              
     chkRelativeToMaxRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [240 240 20 20],...
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
                  'position', [15 237 225 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkRelativeToMaxRoiPanelCallback...
                  );              
     
    chkInPercentRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [240 215 20 20],...
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
                  'position', [15 212 225 20],...
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
                  'position', [15 180 200 20]...
                  );

    uiSliderMaxTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 165 175 14], ...
                  'Value'   , maxTresholdSliderRoiPanelValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderMaxTresholdRoiPanelCallback ...
                  );
%    uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);
                 
    uiEditMaxTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 165 65 20], ...
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
                  'position', [15 130 200 20]...
                  );
              
    uiSliderMinTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 115 175 14], ...
                  'Value'   , minTresholdSliderRoiPanelValue('get'), ...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', {@sliderMinTresholdRoiPanelCallback} ...
                  );
%    uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);
                                 
    uiEditMinTresholdRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 115 65 20], ...
                  'String'  , num2str(minTresholdSliderRoiPanelValue('get')*100), ...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @editMinTresholdRoiPanelCallback ...
                  );
               
    if holesRoiPanel('get') == true
        sHolesDisplay = 'Contour Holes (Experimental)';
    else
        sHolesDisplay = 'No Holes';
    end
              
    txtHolesRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , sHolesDisplay,...
                  'horizontalalignment', 'left',...
                  'position', [35 77 320 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkHolesRoiPanelCallback...
                  );
              
    chkHolesRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , holesRoiPanel('get'),...
                  'position', [15 80 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkHolesRoiPanelCallback...
                  );  
    
    if pixelEdgeRoiPanel('get') == true
        sPixelEdgeDisplay = 'Pixel Edge';
    else
        sPixelEdgeDisplay = 'Pixel Center';
    end
              
    txtPixelEdgeRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , sPixelEdgeDisplay,...
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
                  'value'   , pixelEdgeRoiPanel('get'),...
                  'position', [15 55 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkPixelEdgeRoiPanelCallback...
                  );      
    
    if multipleObjectsRoiPanel('get') == true
        sMultipleObjectsDisplay = 'Multiple Objects';
    else
        sMultipleObjectsDisplay = 'Single Object';
    end              
              
    txtMultipleObjectsRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , sMultipleObjectsDisplay,...
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
                  'value'   , multipleObjectsRoiPanel('get'),...
                  'position', [15 30 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkMultipleObjectsRoiPanelCallback...
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
        
    
    function chkUnitTypeRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkUnitTypeRoiPanel, 'Value') == true
                
                set(chkUnitTypeRoiPanel, 'Value', false);
            else
                set(chkUnitTypeRoiPanel, 'Value', true);
            end
        end
        
        dOffset = get(uiSeriesPtr('get'), 'Value');        
                        
        sUnitDisplay = getSerieUnitValue(dOffset);
                        
        if strcmpi(sUnitDisplay, 'SUV') && ...
           get(chkUseCTRoiPanel, 'Value') == false

            
            if get(chkUnitTypeRoiPanel, 'Value') == true   
                set(txtUnitTypeRoiPanel , 'String', 'Unit in SUV');
                set(txtInPercentRoiPanel, 'String', 'Treshold in SUV');
            else
                set(txtUnitTypeRoiPanel , 'String', 'Unit in BQML');
                set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');
            end                 
        end
        
        if strcmpi(sUnitDisplay, 'HU') || ...
           get(chkUseCTRoiPanel, 'Value') == true
            
            if get(chkUnitTypeRoiPanel, 'Value') == true   
                set(txtUnitTypeRoiPanel , 'String', 'Unit in Window Level');
                set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');
            else
                set(txtUnitTypeRoiPanel , 'String', 'Unit in HU');
                set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
            end                    
        end    
                 
        if get(chkUseCTRoiPanel, 'Value') == true
            dMin = roiPanelCTMinValue('get');
            dMax = roiPanelCTMaxValue('get');                
        else            
            dMin = roiPanelMinValue('get');
            dMax = roiPanelMaxValue('get');                
        end       
        
        dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
        dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');
        
        dDiff = dMax - dMin;

        dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
        dMinValue = (dMinTresholdValue*dDiff)+dMin;

         if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
            tQuant = quantificationTemplate('get');                
            dMinValue = dMinValue*tQuant.tSUV.dScale;
            dMaxValue = dMaxValue*tQuant.tSUV.dScale;
        end            

        if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
            [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
            dMaxValue = dCTWindow;
            dMinValue = dCTLevel;                 
        end                
        
        set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));
        set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));         
        
        
    end
    
    function chkUseCTRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkUseCTRoiPanel, 'Value') == true
                
                set(chkUseCTRoiPanel, 'Value', false);
            else
                set(chkUseCTRoiPanel, 'Value', true);
            end
        end   
        
        if get(chkUseCTRoiPanel, 'Value') == true
            
            set(uiSeriesCTRoiPanel, 'Enable', 'on');                        
            tRoiPanelCT = roiPanelCtUiValues('get');
            
            dSerieOffset = get(uiSeriesCTRoiPanel, 'Value');
        
            dMaxValue = tRoiPanelCT{dSerieOffset}.dMax;
            dMinValue = tRoiPanelCT{dSerieOffset}.dMin;            
            
            roiPanelCTMaxValue('set', dMaxValue);
            roiPanelCTMinValue('set', dMinValue);
        else
            set(uiSeriesCTRoiPanel, 'Enable', 'off');
        end
        
        if get(chkInPercentRoiPanel, 'Value') == true % Use percentage of max            
            set(txtInPercentRoiPanel, 'String', 'Treshold in Percent');
            set(txtUnitTypeRoiPanel , 'String', 'Unit in Percent');     
   
            dOffset = get(uiSeriesPtr('get'), 'Value');                   
            sUnitDisplay = getSerieUnitValue(dOffset); 
                
            if get(chkUseCTRoiPanel, 'Value') == true % Use CT MAP
                set(chkUnitTypeRoiPanel, 'Value', false);                
            end    
            
            if strcmpi(sUnitDisplay, 'SUV') && ...
               get(chkUseCTRoiPanel, 'Value') == false     
                set(chkUnitTypeRoiPanel, 'Value', true);                
            end
            
        else
            if get(chkUseCTRoiPanel, 'Value') == true % Use CT MAP
                set(chkUnitTypeRoiPanel, 'Value', false);

                set(txtUnitTypeRoiPanel , 'String', 'Unit in HU');            
                set(txtInPercentRoiPanel, 'String', 'Treshold in HU');                
            else 
                
                dOffset = get(uiSeriesPtr('get'), 'Value');   
                
                sUnitDisplay = getSerieUnitValue(dOffset); 
                
                if strcmpi(sUnitDisplay, 'SUV')                    
                    
                    if get(chkUnitTypeRoiPanel, 'Value') == true
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in SUV');            
                        set(txtInPercentRoiPanel, 'String', 'Treshold in SUV');
                    else                        
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in BQML');            
                        set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');
                    end                    
                
                elseif strcmpi(sUnitDisplay, 'HU')                   
                    
                    if get(chkUnitTypeRoiPanel, 'Value') == true
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in Window Level');            
                        set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');
                    else                        
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in HU');            
                        set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
                    end  
                else
                    set(txtUnitTypeRoiPanel , 'String', sprintf('Unit in %s', sUnitDisplay)  );            
                    set(txtInPercentRoiPanel, 'String', sprintf('Treshold in %s', sUnitDisplay) );                    
                end               
                
            end
            
        end  
        
        if ~strcmpi(get(txtUnitTypeRoiPanel , 'String'), 'Unit in Percent')     
                                
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end       

            dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
            dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;

             if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end            

            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                dMaxValue = dCTWindow;
                dMinValue = dCTLevel;                 
            end                

            set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));
            set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));   
        end
    end
        
    function chkHolesRoiPanelCallback(hObject, ~)
        
        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkHolesRoiPanel, 'Value') == true
                
                set(chkHolesRoiPanel, 'Value', false);
            else
                set(chkHolesRoiPanel, 'Value', true);
            end
        end 
        
        if get(chkHolesRoiPanel, 'Value') == true
            set(txtHolesRoiPanel, 'String',  'Contour Holes (Experimental)');            
        else
            set(txtHolesRoiPanel, 'String', 'No Holes');            
        end    
        
        holesRoiPanel('set', get(chkHolesRoiPanel, 'Value'));
        
    end

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
        
        pixelEdgeRoiPanel('set', get(chkPixelEdgeRoiPanel, 'Value'));               
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
        
        multipleObjectsRoiPanel('set', get(chkMultipleObjectsRoiPanel, 'Value'));                 
        
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

    function edtSmalestRegionCallback(hObject, ~)
        
        sValue = get(hObject, 'String');
        dValue = str2double(sValue);
        
        if dValue < 0
             dValue = 0;   
             set(hObject, 'String', '0')
        end
        
        smalestRegionRoiPanelValue('set', dValue);
        
        previewRoiSegmentation(str2double(get(edtSmalestRegion, 'String')), ...
                               get(chkPixelEdgeRoiPanel, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );       
    end
                               

    function sliderMaxTresholdRoiPanelCallback(~, hEvent)
                    
        dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
        dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');
      
        if get(chkRelativeToMaxRoiPanel, 'Value') == false

            if dMaxTresholdValue < dMinTresholdValue
                dMaxTresholdValue = dMinTresholdValue;
            end            
        end        
                
        if get(chkInPercentRoiPanel, 'Value') == true
                        
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxTresholdValue*100));
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), 'Percent', dMaxTresholdValue);                  
            
        else
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end       

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;
                         
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end            

            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [dCTWindow, ~] = computeWindowMinMax(dMaxValue, dMinValue);
                dMaxValue = dCTWindow;
            end   
                               
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);  
            
            set(uiEditMaxTresholdRoiPanel  , 'String', num2str(dMaxValue));
           
        end          
        
        maxTresholdSliderRoiPanelValue('set', dMaxTresholdValue);       
       
        if strcmpi(hEvent.EventName, 'Action')        
            set(uiSliderMaxTresholdRoiPanel, 'Value',  maxTresholdSliderRoiPanelValue('get'));
        end   
        
        previewRoiSegmentation(str2double(get(edtSmalestRegion, 'String')), ...
                               get(chkPixelEdgeRoiPanel, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );        
    end

    function editMaxTresholdRoiPanelCallback(hObject, ~)
        
%        delete(uiSliderMaxTresholdRoiListener);
         
        sMaxValue = get(hObject, 'String');
        dMaxValue = str2double(sMaxValue);
        if isnan(dMaxValue)
            if get(chkInPercentRoiPanel, 'Value') == true
                dMaxValue = maxTresholdRoiPanelValue('get')*100;
            else
                dMaxValue = roiPanelMaxValue('get');
            end
        end
                
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
                                   
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end               
                                
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                                
                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end       
            
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMax, dMin);
                dMax = dCTWindow;
                dMin = dCTLevel;                 
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
        
%        uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);        
        
        previewRoiSegmentation(str2double(get(edtSmalestRegion, 'String')), ...
                               get(chkPixelEdgeRoiPanel, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );    
    end

    function sliderMinTresholdRoiPanelCallback(~, hEvent)
                    
        dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
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
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end       

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;
                         
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end            
            
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [~, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                dMinValue = dCTLevel;                 
            end             
                                                          
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
        
        previewRoiSegmentation(str2double(get(edtSmalestRegion, 'String')), ...
                               get(chkPixelEdgeRoiPanel, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );   
    end

    function editMinTresholdRoiPanelCallback(hObject, ~)
        
%        delete(uiSliderMinTresholdRoiListener);
         
        sMinValue = get(hObject, 'String');
        dMinValue = str2double(sMinValue);
        if isnan(dMinValue)
            if get(chkInPercentRoiPanel, 'Value') == true
                dMinValue = minTresholdRoiPanelValue('get')*100;
            else
                dMinValue = roiPanelMinValue('get');
            end
        end
        
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
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end                  
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
                     
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end            
             
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMax, dMin);
                dMax = dCTWindow;
                dMin = dCTLevel;                 
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
        
%        uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);    
        
        previewRoiSegmentation(str2double(get(edtSmalestRegion, 'String')), ...
                               get(chkPixelEdgeRoiPanel, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               ); 
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
%            delete(uiSliderMinTresholdRoiListener);
           
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

                if get(chkUseCTRoiPanel, 'Value') == true
                    dMin = roiPanelCTMinValue('get');
                    dMax = roiPanelCTMaxValue('get');                
                else            
                    dMin = roiPanelMinValue('get');
                    dMax = roiPanelMaxValue('get');                
                end            

                dDiff = dMax - dMin;
                
                if dMinTresholdValue > dMaxTresholdValue
                    dMinTresholdValue = dMaxTresholdValue;
                end
                
                dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
                dMinValue = (dMinTresholdValue*dDiff)+dMin;                                                

                if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                    tQuant = quantificationTemplate('get');                
                    dMinValue = dMaxValue*tQuant.tSUV.dScale;
                end        
                                
                 if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                    [~, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                    dMinValue = dCTLevel;                 
                end                                 

                set(uiEditMinTresholdRoiPanel  , 'String', num2str(dMinValue));                
                set(uiSliderMinTresholdRoiPanel, 'Value' , dMinTresholdValue);
                               
                minTresholdSliderRoiPanelValue('set', dMinTresholdValue);              
                minTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMinValue);  
                
            end
            
%            uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);        

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

%        delete(uiSliderMaxTresholdRoiListener);
%        if relativeToMaxRoiPanelValue('get') == false                
%            delete(uiSliderMinTresholdRoiListener);
%        end
        
        if get(chkInPercentRoiPanel, 'Value') == true 
            
            set(chkUnitTypeRoiPanel, 'Enable', 'off');
            set(txtUnitTypeRoiPanel, 'Enable', 'on');
            
            set(txtInPercentRoiPanel, 'String', 'Treshold in Percent');
            set(txtUnitTypeRoiPanel , 'String', 'Unit in Percent');            
                                  
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
            set(chkUnitTypeRoiPanel, 'Enable', 'on');
            set(txtUnitTypeRoiPanel, 'Enable', 'Inactive');
            
            aBuffer = dicomBuffer('get');
                        
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);
            
            if strcmpi(sUnitDisplay, 'SUV') 
                if get(chkUseCTRoiPanel, 'Value') == true
                    if get(chkUnitTypeRoiPanel, 'Value') == true
                        set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');    
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in Window Level');                       
                    else
                        set(txtInPercentRoiPanel, 'String', 'Treshold in HU');    
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in HU');                       
                    end                      
                else
                    if get(chkUnitTypeRoiPanel, 'Value') == true
                        set(txtInPercentRoiPanel, 'String', 'Treshold in SUV');    
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in SUV');                       
                    else
                        set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');    
                        set(txtUnitTypeRoiPanel , 'String', 'Unit in BQML');                       
                    end
                end
            elseif strcmpi(sUnitDisplay, 'HU')
                if get(chkUnitTypeRoiPanel, 'Value') == true
                    set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');    
                    set(txtUnitTypeRoiPanel , 'String', 'Unit in Window Level');                       
                else
                    set(txtInPercentRoiPanel, 'String', 'Treshold in HU');    
                    set(txtUnitTypeRoiPanel , 'String', 'Unit in HU');                       
                end                
            else            
                set(txtInPercentRoiPanel, 'String', sprintf('Treshold in %s', sUnitDisplay));    
                set(txtUnitTypeRoiPanel , 'String', sprintf('Unit in %s', sUnitDisplay));           
            end
                        
            dMaxTresholdValue = maxTresholdSliderRoiPanelValue('get');
            
            if get(chkUseCTRoiPanel, 'Value') == true
                dMin = roiPanelCTMinValue('get');
                dMax = roiPanelCTMaxValue('get');                
            else            
                dMin = roiPanelMinValue('get');
                dMax = roiPanelMaxValue('get');                
            end
            
            dDiff = dMax - dMin;
            
            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
                        
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')
                tQuant = quantificationTemplate('get');                
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end            
            
            dMinTresholdValue = minTresholdSliderRoiPanelValue('get');

            dMinValue = (dMinTresholdValue*dDiff)+dMin;
            
            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                dMaxValue = dCTWindow;
                dMinValue = dCTLevel;                 
            end                        
            
            set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));
            
            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);                  

            if strcmpi(get(txtUnitTypeRoiPanel, 'String'), 'Unit in SUV')                                   
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
        
%        uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);        
%        if relativeToMaxRoiPanelValue('get') == false                
%            uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);        
%        end                       
    end

    function previewRoiSegmentation(dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset)
        
        PIXEL_EDGE_RATIO = 3;
        
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
        
        if bUseCtMap == true
            dBufferMin = roiPanelCTMinValue('get');
            dBufferMax = roiPanelCTMaxValue('get');               
        else
            dBufferMin = roiPanelMinValue('get');
            dBufferMax = roiPanelMaxValue('get');                              
        end
        
        dBufferDiff = dBufferMax - dBufferMin;           
        
        dMinTreshold = (dSliderMin * dBufferDiff)+dBufferMin;
        dMaxTreshold = (dSliderMax * dBufferDiff)+dBufferMin;                
             
        if size(aBuffer, 3) == 1
                        
            vBoundAxePtr = visBoundAxePtr('get');
            if ~isempty(vBoundAxePtr)
                delete(vBoundAxePtr);
            end
            
            dBufferMIn = min(double(aBuffer),[], 'all');
            
            imAxe = imAxePtr ('get');
            aAxe  = imAxe.CData;

            if strcmpi(sActionType, 'Entire Image')
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold) = dBufferMIn;                                      
                else    
                    aAxe(aAxe<=dMinTreshold) = dBufferMIn;
                    aAxe(aAxe>=dMaxTreshold) = dBufferMIn;                                       
                end   

                if bPixelEdge == true                            
                    if bHoles == true
                        [originalMaskAxe,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);  
                    else
                        [originalMaskAxe,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);  
                    end  
                end
                            
                if bPixelEdge == true
                    aAxe = imresize(aAxe , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                if bHoles == true
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                else
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                end
                                
                if bPixelEdge == true
                    if ~isempty(maskAxe)
                        for jj=1:numel(maskAxe)
                            maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end               
                end     
                
                if ~isempty(maskAxe)
                
                    maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);
                    if ~isempty(maskAxe)
                        vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);
                        visBoundAxePtr('set', vBoundAxePtr);                
                    end
                end
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
                
                aVoiBuffer = zeros(size(aBuffer));
                
                if strcmpi(aobjList{uiRoiVoiRoiPanelValue}.ObjectType, 'voi')
                    
                    dNbRois = numel(aobjList{uiRoiVoiRoiPanelValue}.RoisTag);             
                                        
                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
                                objRoi = tRoiInput{cc}.Object;

                                switch objRoi.Parent
                                    case axePtr('get')
                                        aSlice = aBuffer(:,:); 
                                        roiMask = createMask(objRoi, aSlice); 
                                        
                                        aSlice( roiMask) =1;
                                        aSlice(~roiMask) =0;  
                                        
                                        aSliceMask =  aVoiBuffer(:,:);                                                                                  
                                        aVoiBuffer(:,:) = aSlice|aSliceMask;                                                                            
                                end                           

                                break; 
                             end
                        end
                    end
                else
                    objRoi   = aobjList{uiRoiVoiRoiPanelValue}.Object;
                                        
                    switch objRoi.Parent
                        case axePtr('get')
                            aSlice = aBuffer(:,:); 
                            roiMask = createMask(objRoi, aSlice);     

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;  

                            aVoiBuffer(:,:) = aSlice;                   
                    end                               
                end                        
                
                if strcmpi(sActionType, 'Outside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside all slices ROI\VOI')                    
                    aVoiBuffer = ~aVoiBuffer;                   
                end

                aAxe = aBuffer;
                aAxe(aVoiBuffer==0) = dBufferMIn;               
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold) = dBufferMIn;                    
                else    
                    aAxe(aAxe<=dMinTreshold) = dBufferMIn;
                    aAxe(aAxe>=dMaxTreshold) = dBufferMIn;                                       
                end  
                
                if bPixelEdge == true                            
                    if bHoles == true
                        [originalMaskAxe,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);  
                    else
                        [originalMaskAxe,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);  
                    end  
                end
                
                if bPixelEdge == true
                    aAxe = imresize(aAxe , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                if bHoles == true
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                else
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                end
                
                if bPixelEdge == true
                    if ~isempty(maskAxe)
                        for jj=1:numel(maskAxe)
                            maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end                  
                end   
                
                if ~isempty(maskAxe)
                    
                    maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);
                    if ~isempty(maskAxe)
                        vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);
                        visboundaries('set', vBoundAxePtr);
                    end
                end
                                                
            end                        
        else % 3D Image            
            
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');   
            
            if bUseCtMap == true
                                        
                atRefMetaData = dicomMetaData('get');

                tInput = inputTemplate('get');
                
                tRoiPanelCT = roiPanelCtUiValues('get');
                
                dSerieOffset = get(uiSeriesPtr('get'), 'Value');

                set(uiSeriesPtr('get'), 'Value', tRoiPanelCT{dCtOffset}.dSeriesNumber);

                aCtBuffer = dicomBuffer('get');

                atCtMetaData = dicomMetaData('get');
                if isempty(atCtMetaData)

                    atCtMetaData = tInput(tRoiPanelCT{dCtOffset}.dSeriesNumber).atDicomInfo;
                    dicomMetaData('set', atCtMetaData);            
                end      
                
                if isempty(aCtBuffer)   

                    aInput = inputBuffer('get');
                    aCtBuffer = aInput{tRoiPanelCT{dCtOffset}.dSeriesNumber};    
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

                [aBuffer, ~] = resampleImage(aCtBuffer, atCtMetaData, aBuffer, atRefMetaData, 'Linear');                
                
%                dResampMIn = min(double(aResamCt),[], 'all');
%                dRefMIn    = min(double(aBuffer),[], 'all');
                
                iCoronal  = sliceNumber('get', 'coronal' );
                iSagittal = sliceNumber('get', 'sagittal');
                iAxial    = sliceNumber('get', 'axial'   );
        
                aCoronal =  permute(aBuffer(iCoronal,:,:), [3 2 1]);
                aSagittal = permute(aBuffer(:,iSagittal,:), [3 1 2]);
                aAxial    = aBuffer(:,:,iAxial);                   
            else
                aCoronal   = imCoronal.CData;
                aSagittal  = imSagittal.CData;
                aAxial     = imAxial.CData;                      
            end
            
            dBufferMIn = min(double(aBuffer),[], 'all');
            
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
                    aCoronal(aCoronal<=dMaxTreshold)   = dBufferMIn;                    
                    aSagittal(aSagittal<=dMaxTreshold) = dBufferMIn;                    
                    aAxial(aAxial<=dMaxTreshold)       = dBufferMIn;                    
                else    
                    aCoronal(aCoronal<=dMinTreshold) = dBufferMIn;
                    aCoronal(aCoronal>=dMaxTreshold) = dBufferMIn;
                    
                    aSagittal(aSagittal<=dMinTreshold) = dBufferMIn;
                    aSagittal(aSagittal>=dMaxTreshold) = dBufferMIn;
                    
                    aAxial(aAxial<=dMinTreshold) = dBufferMIn;
                    aAxial(aAxial>=dMaxTreshold) = dBufferMIn;                                        
                end                

                if bPixelEdge == true
                    if bHoles == true
                        [originalMaskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'holes', 8);
                        [originalMaskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'holes', 8);           
                        [originalMaskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'holes', 8);                    
                    else
                        [originalMaskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'noholes', 8);
                        [originalMaskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'noholes', 8);           
                        [originalMaskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'noholes', 8);
                    end
                end
                
                if bPixelEdge == true
                    aCoronal  = imresize(aCoronal , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                    aSagittal = imresize(aSagittal, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                    aAxial    = imresize(aAxial   , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                if bHoles == true
                    [maskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'holes', 8);
                    [maskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'holes', 8);           
                    [maskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'holes', 8);                    
                else
                    [maskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'noholes', 8);
                    [maskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'noholes', 8);           
                    [maskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'noholes', 8);
                end
                                                
                if bPixelEdge == true
                    if ~isempty(maskCoronal)
                        for jj=1:numel(maskCoronal)
                            maskCoronal{jj} = (maskCoronal{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end
                    
                    if ~isempty(maskSagittal)
                        for jj=1:numel(maskSagittal)
                            maskSagittal{jj} = (maskSagittal{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end
                    
                    if ~isempty(maskAxial)
                        for jj=1:numel(maskAxial)
                            maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end                    
                end                        
                
                if ~isempty(maskCoronal)                    
                    maskCoronal = deleteSmallElements(originalMaskCoronal, maskCoronal, dSmalestRoiSize);   
                    if ~isempty(maskCoronal)                    
                        vBoundAxes1Ptr = visboundaries(axes1Ptr('get'), maskCoronal );                    
                        visBoundAxes1Ptr('set', vBoundAxes1Ptr);                    
                    end
                end
                
                if ~isempty(maskSagittal)                    
                    maskSagittal = deleteSmallElements(originalMaskSagittal, maskSagittal, dSmalestRoiSize);                    
                    if ~isempty(maskSagittal)
                        vBoundAxes2Ptr = visboundaries(axes2Ptr('get'), maskSagittal);                    
                        visBoundAxes2Ptr('set', vBoundAxes2Ptr);
                    end
                end
                
                if ~isempty(maskAxial)                                    
                    maskAxial = deleteSmallElements(originalMaskAxial, maskAxial, dSmalestRoiSize);
                    if ~isempty(maskAxial)                
                        vBoundAxes3Ptr = visboundaries(axes3Ptr('get'), maskAxial);
                        visBoundAxes3Ptr('set', vBoundAxes3Ptr);
                    end
                end
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
                    
%                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
%                       strcmpi(sActionType, 'Outside ROI\VOI')     
                        aVoiBuffer = zeros(size(aBuffer));
%                        aVoiBuffer(aVoiBuffer==0) = cropValue('get');
%                    else
%                        aVoiBuffer = aBuffer;
%                    end
                    
                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
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
                                       
                                            if dSliceNb == iAxial

                                                aSlice = aBuffer(:,:,dSliceNb); 
                                                roiMask = createMask(objRoi, aSlice); 

                                                aSlice( roiMask) =1;
                                                aSlice(~roiMask) =0;  
 
                                                aSliceMask =  aVoiBuffer(:,:,dSliceNb);                                                                                  
                                                aVoiBuffer(:,:,dSliceNb) = aSlice|aSliceMask;                                       
                                            end
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
                           

                                break; 
                             end
                        end
                    end
                    
                    if strcmpi(sActionType, 'Outside ROI\VOI') || ...
                       strcmpi(sActionType, 'Outside all slices ROI\VOI')                    
                        aVoiBuffer = ~aVoiBuffer;                   
                    end
                                       
                    aCoronal      = permute(aBuffer(iCoronal,:,:), [3 2 1]);
                    aCoronalMask  = permute(aVoiBuffer(iCoronal,:,:), [3 2 1]);
                    aCoronal(aCoronalMask==0) = dBufferMIn;
                    
                    aSagittal     = permute(aBuffer(:,iSagittal,:), [3 1 2]);
                    aSagittalMask = permute(aVoiBuffer(:,iSagittal,:), [3 1 2]);
                    aSagittal(aSagittalMask==0) = dBufferMIn;
                    
                    aAxial     = aBuffer(:,:,iAxial);
                    aAxialMask = aVoiBuffer(:,:,iAxial);
                    aAxial(aAxialMask==0) = dBufferMIn;
                else
                    objRoi   = aobjList{uiRoiVoiRoiPanel.Value}.Object;
                    dSliceNb = aobjList{uiRoiVoiRoiPanel.Value}.SliceNb;
                    
%                    if strcmpi(sActionType, 'Inside ROI\VOI') || ...
%                       strcmpi(sActionType, 'Outside ROI\VOI')                             
%                        aVoiBuffer = zeros(size(aBuffer));
%                    else
%                        aVoiBuffer = aBuffer;
%                    end
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
                                if dSliceNb == iCoronal
                                
                                    aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                    roiMask = createMask(objRoi, aSlice); 
                                    
                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                               end
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
                                if dSliceNb == iSagittal
                                
                                    aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                    roiMask = createMask(objRoi, aSlice); 
                                    
                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;                                   

                                    aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                                end

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
                                if dSliceNb == iAxial
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
                    
                    aCoronal      = permute(aBuffer(iCoronal,:,:), [3 2 1]);
                    aCoronalMask  = permute(aVoiBuffer(iCoronal,:,:), [3 2 1]);
                    aCoronal(aCoronalMask==0) = dBufferMIn;
                    
                    aSagittal     = permute(aBuffer(:,iSagittal,:), [3 1 2]);
                    aSagittalMask = permute(aVoiBuffer(:,iSagittal,:), [3 1 2]);
                    aSagittal(aSagittalMask==0) = dBufferMIn;
                    
                    aAxial     = aBuffer(:,:,iAxial);
                    aAxialMask = aVoiBuffer(:,:,iAxial);
                    aAxial(aAxialMask==0) = dBufferMIn;
                    
                end                
                
                if bRelativeToMax == true
                    aCoronal(aCoronal<=dMaxTreshold)   = dBufferMIn;                    
                    aSagittal(aSagittal<=dMaxTreshold) = dBufferMIn;                    
                    aAxial(aAxial<=dMaxTreshold)       = dBufferMIn;                    
                else    
                    aCoronal(aCoronal<=dMinTreshold) = dBufferMIn;
                    aCoronal(aCoronal>=dMaxTreshold) = dBufferMIn;
                    
                    aSagittal(aSagittal<=dMinTreshold) = dBufferMIn;
                    aSagittal(aSagittal>=dMaxTreshold) = dBufferMIn;
                    
                    aAxial(aAxial<=dMinTreshold) = dBufferMIn;
                    aAxial(aAxial>=dMaxTreshold) = dBufferMIn;                                        
                end                
                
                if bPixelEdge == true
                    if bHoles == true
                        [originalMaskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'holes', 8);
                        [originalMaskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'holes', 8);           
                        [originalMaskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'holes', 8);                    
                    else
                        [originalMaskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'noholes', 8);
                        [originalMaskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'noholes', 8);           
                        [originalMaskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'noholes', 8);
                    end
                end
                
                if bPixelEdge == true
                    aCoronal  = imresize(aCoronal , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                    aSagittal = imresize(aSagittal, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                    aAxial    = imresize(aAxial   , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end                         
                
                if bHoles == true
                    [maskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'holes', 8);
                    [maskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'holes', 8);           
                    [maskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'holes', 8);
                else
                    [maskCoronal ,~,~,~] = bwboundaries(bwimage(aCoronal , dBufferMIn), 'noholes', 8);
                    [maskSagittal,~,~,~] = bwboundaries(bwimage(aSagittal, dBufferMIn), 'noholes', 8);           
                    [maskAxial   ,~,~,~] = bwboundaries(bwimage(aAxial   , dBufferMIn), 'noholes', 8);
                end                
                
                if bPixelEdge == true
                    
                    if ~isempty(maskCoronal)
                        for jj=1:numel(maskCoronal)
                            maskCoronal{jj} = (maskCoronal{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end
                    
                    if ~isempty(maskSagittal)
                        for jj=1:numel(maskSagittal)
                            maskSagittal{jj} = (maskSagittal{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end
                    
                    if ~isempty(maskAxial)
                        for jj=1:numel(maskAxial)
                            maskAxial{jj} = (maskAxial{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end                    
                end 
                
                if ~isempty(maskCoronal)                    
                    maskCoronal = deleteSmallElements(originalMaskCoronal, maskCoronal , dSmalestRoiSize);   
                    if ~isempty(maskCoronal)                    
                        vBoundAxes1Ptr = visboundaries(axes1Ptr('get'), maskCoronal );                    
                        visBoundAxes1Ptr('set', vBoundAxes1Ptr);                    
                    end
                end
                
                if ~isempty(maskSagittal)                    
                    maskSagittal   = deleteSmallElements(originalMaskSagittal, maskSagittal, dSmalestRoiSize);                    
                    if ~isempty(maskSagittal)
                        vBoundAxes2Ptr = visboundaries(axes2Ptr('get'), maskSagittal);                    
                        visBoundAxes2Ptr('set', vBoundAxes2Ptr);
                    end
                end
                
                if ~isempty(maskAxial)                                    
                    maskAxial = deleteSmallElements(originalMaskAxial, maskAxial, dSmalestRoiSize);
                    if ~isempty(maskAxial)                
                        vBoundAxes3Ptr = visboundaries(axes3Ptr('get'), maskAxial);
                        visBoundAxes3Ptr('set', vBoundAxes3Ptr);
                    end
                end
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
            bHoles           = get(chkHolesRoiPanel, 'Value');
            dSmalestRoiSize  = str2double(get(edtSmalestRegion, 'String'));
            bUseCtMap        = get(chkUseCTRoiPanel  , 'Value');
            dCtOffset        = get(uiSeriesCTRoiPanel, 'Value');

%            set(uiCreateVoiRoiPanel, 'String', 'Cancel');
            
            cancelCreateVoiRoiPanel('set', false);                       

            createVoiRoi(bMultipleObjects, dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset);     
        end        
        
        cancelCreateVoiRoiPanel('set', false);                       
        
        set(uiCreateVoiRoiPanel, 'String', 'Segment');
        
    end

    function createVoiRoi(bMultipleObjects, dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset)
        
        PIXEL_EDGE_RATIO = 3;
        
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
        
        if bUseCtMap == true
            dBufferMin = roiPanelCTMinValue('get');
            dBufferMax = roiPanelCTMaxValue('get');               
        else
            dBufferMin = roiPanelMinValue('get');
            dBufferMax = roiPanelMaxValue('get');                              
        end                         
        
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
            
            dBufferMIn = min(double(aBuffer),[], 'all');            

            if strcmpi(sActionType, 'Entire Image')
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold) = dBufferMIn;                                      
                else    
                    aAxe(aAxe<=dMinTreshold) = dBufferMIn;
                    aAxe(aAxe>=dMaxTreshold) = dBufferMIn;                                       
                end   
                
                if bPixelEdge == true
                    if bHoles == true
                        [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                    else
                        [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                    end
                end
                
                if bPixelEdge == true
                    aAxe = imresize(aAxe , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                if bHoles == true
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                else
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                end
                
                if bPixelEdge == true
                    if ~isempty(maskAxe)
                        for jj=1:numel(maskAxe)
                            maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end               
                end     
                
                if ~isempty(maskAxe)
                
                    maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);
                    if ~isempty(maskAxe)
                
%                vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);

%                visBoundAxePtr('set', vBoundAxePtr);                
                    end
                end
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
                
                aVoiBuffer = zeros(size(aBuffer));
               
                if strcmpi(aobjList{uiRoiVoiRoiPanelValue}.ObjectType, 'voi')
                    
                    dNbRois = numel(aobjList{uiRoiVoiRoiPanelValue}.RoisTag);             
                                        
                    for bb=1:dNbRois

                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                                strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiRoiPanelValue}.RoisTag{bb})
                            
                                objRoi   = tRoiInput{cc}.Object;

                                switch objRoi.Parent
                                    case axePtr('get')
                                        aSlice = aBuffer(:,:); 
                                        roiMask = createMask(objRoi, aSlice); 
                                        
                                        aSlice( roiMask) =1;
                                        aSlice(~roiMask) =0;
                                        
                                        aSliceMask = aVoiBuffer(:,:);                                                                                  
                                        aVoiBuffer(:,:) = aSlice|aSliceMask;                                                                            
                                end                           

                                break; 
                             end
                        end
                    end
                else
                    objRoi   = aobjList{uiRoiVoiRoiPanelValue}.Object;
                                        
                    switch objRoi.Parent
                        case axePtr('get')
                            aSlice = aBuffer(:,:); 
                            roiMask = createMask(objRoi, aSlice);   
                            
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aVoiBuffer = aSlice;                   
                    end                               
                end
                
                if strcmpi(sActionType, 'Outside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside all slices ROI\VOI')                    
                    aVoiBuffer = ~aVoiBuffer;                   
                end

                aAxe = aBuffer;
                aAxe(aVoiBuffer==0) = dBufferMIn;                 
                
                if bRelativeToMax == true
                    aAxe(aAxe<=dMaxTreshold) = dBufferMIn;                    
                else    
                    aAxe(aAxe<=dMinTreshold) = dBufferMIn;
                    aAxe(aAxe>=dMaxTreshold) = dBufferMIn;                                       
                end                
                
                if bPixelEdge == true
                    if bHoles == true
                        [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                    else
                        [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                    end
                end
                
                if bPixelEdge == true
                    aAxe = imresize(aAxe , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                end
                
                if bHoles == true
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'holes', 8);
                else
                    [maskAxe ,~,~,~] = bwboundaries(bwimage(aAxe, dBufferMIn), 'noholes', 8);
                end
                
                if bPixelEdge == true
                    if ~isempty(maskAxe)
                        for jj=1:numel(maskAxe)
                            maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;                                                            
                        end
                    end               
                end     
                
                if ~isempty(maskAxe)
                    
                    maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);                                
                    if ~isempty(maskAxe)
                
%todo                vBoundAxePtr = visboundaries(axePtr('get'), maskAxe);

%todo                visboundaries('set', vBoundAxePtr);
                    end
                end                                
            end              
                        
        else % 3D Image             
            
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
            
            if bUseCtMap == true
                                        
                atRefMetaData = dicomMetaData('get');

                tInput = inputTemplate('get');
                
                tRoiPanelCT = roiPanelCtUiValues('get');
                
                dSerieOffset = get(uiSeriesPtr('get'), 'Value');

                set(uiSeriesPtr('get'), 'Value', tRoiPanelCT{dCtOffset}.dSeriesNumber);

                aCtBuffer = dicomBuffer('get');

                atCtMetaData = dicomMetaData('get');
                if isempty(atCtMetaData)

                    atCtMetaData = tInput(tRoiPanelCT{dCtOffset}.dSeriesNumber).atDicomInfo;
                    dicomMetaData('set', atCtMetaData);            
                end      
                
                if isempty(aCtBuffer)   

                    aInput = inputBuffer('get');
                    aCtBuffer = aInput{tRoiPanelCT{dCtOffset}.dSeriesNumber};    
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

                [aBuffer, ~] = resampleImage(aCtBuffer, atCtMetaData, aBuffer, atRefMetaData, 'Linear');                
                                                     
            end
            
            dBufferMIn = min(double(aBuffer),[], 'all');            
            
            if strcmpi(sActionType, 'Entire Image')        

                if bRelativeToMax == true
                    aBuffer(aBuffer<=dMaxTreshold) = dBufferMIn;                                       
                else    
                    aBuffer(aBuffer<=dMinTreshold) = dBufferMIn;
                    aBuffer(aBuffer>=dMaxTreshold) = dBufferMIn;                                        
                end                                    
                
                BW = bwimage(aBuffer, dBufferMIn);
                
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
                        BW = zeros(size(aBuffer));                
                        BW(CC.PixelIdxList{bb}) = 1;                
                    end
                    
                    asTag = [];
                     
                    progressBar( bb/dNbElements-0.0001, sprintf('Computing Volume %d/%d, please wait', bb, dNbElements) );  
                    
                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);
                    
                    aBufferSize = size(BW, 3);
                  
                    for aa=1:aBufferSize % Find ROI
                        
                        if bMultipleObjects == false
                            if mod(aa, 5)==1 || aa == aBufferSize         
                                progressBar( aa/aBufferSize-0.0001, sprintf('Computing slice %d/%d, please wait', aa, aBufferSize) );  
                            end
                        end
                            
                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end

                        aAxial = BW(:,:,aa);   
                        if aAxial(aAxial==1)
                            
                            if bPixelEdge == true                            
                                if bHoles == true
                                    [originalMaskAxial,~,~,~] = bwboundaries(aAxial, 'holes', 8);  
                                else
                                    [originalMaskAxial,~,~,~] = bwboundaries(aAxial, 'noholes', 8);  
                                end  
                            end
                            
                            if bPixelEdge == true
                                aAxial = imresize(aAxial, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                            end
                            
                            if bHoles == true
                                [maskAxial,~,~,~] = bwboundaries(aAxial, 'holes', 8);  
                            else
                                [maskAxial,~,~,~] = bwboundaries(aAxial, 'noholes', 8);  
                            end  
                            
                            if ~isempty(maskAxial)
                            
                                if bPixelEdge == true
                                    for ii=1:numel(maskAxial)
                                        maskAxial{ii} = (maskAxial{ii} +1)/PIXEL_EDGE_RATIO;                                
                                    end
                                end

                                maskAxial = deleteSmallElements(originalMaskAxial, maskAxial, dSmalestRoiSize);
                            end
                            
                            if ~isempty(maskAxial)
                                for jj=1:numel(maskAxial)

                                    if cancelCreateVoiRoiPanel('get') == true
                                        break;
                                    end

                                    curentMask = maskAxial(jj); 

                                    sliceNumber('set', 'axial', aa);

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                    aPosition = flip(curentMask{1}, 2);

                                    bAddRoi = true;
                                    pRoi = drawfreehand(axes3Ptr('get') , 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', 0);
                                    if dSmalestRoiSize > 0
                                        roiMask = pRoi.createMask();
                                        if numel(roiMask(roiMask==1)) < dSmalestRoiSize
                                            delete(pRoi);
                                            bAddRoi = false;
                                        end
                                    end
                                    
                                    if bAddRoi == true
                                   
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
                                         
                                        if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                                           strcmpi(sActionType, 'Outside ROI\VOI')  

                                            aSlice =  permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                            roiMask = createMask(objRoi, aSlice);                                   

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;  

                                            aSliceMask =  permute(aVoiBuffer(dSliceNb,:,:), [3 2 1]);                                         
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                                                
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
                                       
                                            aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                            roiMask = createMask(objRoi, aSlice);     

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0;                                        

                                            aSliceMask =  permute(aVoiBuffer(:,dSliceNb,:), [3 1 2]);                                         
                                            aSlice = aSlice|aSliceMask;
                                            aVoiBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);                                                
                                            
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
                           
                                break; 
                             end
                        end
                    end                     
                else 
                    
                    objRoi   = aobjList{uiRoiVoiRoiPanelValue}.Object;
                    dSliceNb = aobjList{uiRoiVoiRoiPanelValue}.SliceNb;                    
                    
                    aVoiBuffer = zeros(size(aBuffer));
                                           
                    for cc=1:numel(tRoiInput)

                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end                            

                        if isvalid(objRoi) 

                            switch objRoi.Parent

                                case axes1Ptr('get')

                                     if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...
                                        strcmpi(sActionType, 'Outside all slices ROI\VOI') 
                                        for dd=1:size(aVoiBuffer, 1)
                                             aSlice = permute(aBuffer(dd,:,:), [3 2 1]);
                                             roiMask = createMask(objRoi, aSlice);                                   

                                             aSlice( roiMask) =1;
                                             aSlice(~roiMask) =0; 
                                     
                                             aVoiBuffer(dd,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
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
                                        for dd=1:size(aVoiBuffer, 2)
                                            
                                            aSlice = permute(aBuffer(:,dd,:), [3 1 2]);
                                            roiMask = createMask(objRoi, aSlice);     
                                            
                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0; 
                                         
                                            aVoiBuffer(:,dd,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
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
                                        for dd=1:size(aVoiBuffer, 3)
                                            aSlice = aBuffer(:,:,dd); 
                                            roiMask = createMask(objRoi, aSlice); 

                                            aSlice( roiMask) =1;
                                            aSlice(~roiMask) =0; 

                                            aVoiBuffer(:,:,dd) = aSlice;
                                        end
                                     else
                                        aSlice = aBuffer(:,:,dSliceNb); 
                                        roiMask = createMask(objRoi, aSlice); 

                                        aSlice( roiMask) =1;
                                        aSlice(~roiMask) =0; 
                                     
                                        aVoiBuffer(:,:,dSliceNb) = aSlice;
                                     end                                       
                            end

                            break; 
                         end
                    end                                                             
                end
                
                if strcmpi(sActionType, 'Outside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside all slices ROI\VOI')                    
                    aVoiBuffer = ~aVoiBuffer;                   
                end                
                
                aBuffer(aVoiBuffer==0) = dBufferMIn;
                    
                if bRelativeToMax == true
                    aBuffer(aBuffer<=dMaxTreshold) = dBufferMIn;                                       
                else    
                    aBuffer(aBuffer<=dMinTreshold) = dBufferMIn;
                    aBuffer(aBuffer>=dMaxTreshold) = dBufferMIn;                                        
                end   

%                BW = aVoiBuffer;                
%                BW(BW == cropValue('get'))=0;
%                BW(BW ~= 0)=1;
                
                BW = bwimage(aBuffer, dBufferMIn);

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
                        B = zeros(size(aBuffer));  
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
                                if bHoles == true
                                    [originalMaskSlice,~,~,~] = bwboundaries(aSlice, 'holes', 8);  
                                else
                                    [originalMaskSlice,~,~,~] = bwboundaries(aSlice, 'noholes', 8);  
                                end  
                            end
                            
                            if bPixelEdge == true
                                aSlice = imresize(aSlice, PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
                            end
                            
                            if bHoles == true
                                [maskSlice, ~,~,~] = bwboundaries(aSlice, 'holes', 8); 
                            else
                                [maskSlice, ~,~,~] = bwboundaries(aSlice, 'noholes', 8); 
                            end
                            
                            if ~isempty(maskSlice)         
                                
                                if bPixelEdge == true
                                    for ii=1:numel(maskSlice)
                                        maskSlice{ii} = (maskSlice{ii} +1)/PIXEL_EDGE_RATIO;                                
                                    end
                                end

                                maskSlice = deleteSmallElements(originalMaskSlice, maskSlice, dSmalestRoiSize);
                            end
                            
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

                                    sliceNumber('set', 'axial', aa);

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                    aPosition = flip(curentMask{1}, 2);
                                    
                                    bAddRoi = true;
                                    pRoi = drawfreehand(axes3Ptr('get') , 'Position', aPosition, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'on', 'FaceSelectable', 0, 'FaceAlpha', 0);
                                    if dSmalestRoiSize > 0
                                        roiMask = pRoi.createMask();
                                        if numel(roiMask(roiMask==1)) < dSmalestRoiSize
                                            delete(pRoi);
                                            bAddRoi = false;
                                        end
                                    end
                                    
                                    if bAddRoi == true
                                        
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

    function aBW = bwimage(aImage, dMinValue)        
        
        aBW = aImage;
        
        aBW(aBW==dMinValue) = 0;
        aBW(aBW~=0) = 1;        
    end

    function aNewMask = deleteSmallElements(aOrigMask, aMask, dSmalestRoiSize)
          
        aNewMask = aMask;
        
        bDeleteElements = false;
        for jj=1:numel(aOrigMask)
            if size(aOrigMask{jj}, 1) < dSmalestRoiSize
                aNewMask{jj} = [];
                bDeleteElements = true;
            end   
        end

        if bDeleteElements == true
            aNewMask(cellfun(@isempty, aNewMask)) = [];                                                                    
        end
    end

end