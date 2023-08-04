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

    if isempty(dicomBuffer('get'))
        return;
    end

      % Report
  
         uicontrol(uiRoiPanelPtr('get'),...
                  'String'  ,'Report',...
                  'FontWeight', 'bold',...
                  'Position',[160 645 100 25],...
                  'Enable'  , 'On', ...
                  'BackgroundColor', [0.75 0.75 0.75], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @generateContourReportCallback...
                  );
              
    % Contour Review
              
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'string'    , 'Contour Review',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 620 200 20]...
                  );                
              
              
     uiDeleteVoiRoiPanel = ...
         uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 590 245 25], ...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , 'Off', ...
                  'Callback', @setVoiSeriesOffsetRoiPanelCallback, ...
                  'BackgroundColor', viewerBackgroundColor ('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
    uiDeleteVoiRoiPanelObject('set', uiDeleteVoiRoiPanel);
    
    uiLesionTypeVoiRoiPanel = ...
         uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'Position', [15 560 245 25], ...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , 'Off', ...
                  'Callback', @setLesionTypeRoiPanelCallback, ...
                  'BackgroundColor', viewerBackgroundColor ('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
    uiLesionTypeVoiRoiPanelObject('set', uiLesionTypeVoiRoiPanel);
    
    uiAddVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'pushbutton',...
                  'String'  ,'Add',...
                  'Position',[15 535 32 25],...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', [0.5300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @addVoiRoiPanelCallback...
                  ); 
    uiAddVoiRoiPanelObject('set', uiAddVoiRoiPanel);
              
    uiPrevVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'pushbutton',...
                  'String'  ,'Previous',...
                  'Position',[48 535 75 25],...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @previousVoiRoiPanelCallback...
                  );
    uiPrevVoiRoiPanelObject('set', uiPrevVoiRoiPanel);

    uiDelVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'pushbutton',...
                  'String'  ,'Delete',...
                  'Position',[124 535 60 25],...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', [0.2 0.039 0.027], ...
                  'ForegroundColor', [0.94 0.94 0.94], ...
                  'Callback', @deleteVoiRoiPanelCallback...
                  );
    uiDelVoiRoiPanelObject('set', uiDelVoiRoiPanel);

    uiNextVoiRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'pushbutton',...
                  'String'  ,'Next',...
                  'Position',[185 535 75 25],...
                  'Enable'  , 'Off', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @nextVoiRoiPanelCallback...
                  );
    uiNextVoiRoiPanelObject('set', uiNextVoiRoiPanel);    

    % Contour Options

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'string'    , 'Contour Options',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 495 200 20]...
                  );

    % Roi Face Alpha

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'normal',...
                  'string'  , 'Contour Transparency',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 470 200 20]...
                  );

    uiSliderRoisFaceAlphaRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 455 245 14], ...
                  'Value'   , roiFaceAlphaValue('get'), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderRoisFaceAlphaRoiPanelCallback ...
                  );
    uiSliderRoisFaceAlphaRoiPanelObject('set', uiSliderRoisFaceAlphaRoiPanel);
%    addlistener(uiSliderRoisFaceAlphaRoiPanel, 'Value', 'PreSet', @sliderRoisFaceAlphaRoiPanelCallback);

    % Sphere Diameter

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'normal',...
                  'string'  , 'Sphere Diameter (mm)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 417 200 20]...
                  );

         uicontrol(uiRoiPanelPtr('get'),...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(sphereDefaultDiameter('get')),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [195 420 65 20],...
                  'Callback', @edtSphereDiameterCallback...
                  );

    % Contour segmentation

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Contour Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 380 200 20]...
                  );

    tRoiPanelCT = roiPanelCtUiValues('get');
    if isempty(tRoiPanelCT) || size(dicomBuffer('get'), 3) == 1

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
    end

    btnUnitTypeRoiPanel = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'pushbutton',...
                  'String'  ,'Toggle Unit',...
                  'enable'  , sUseCtEnable,...
                  'position', [15 350 91 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @btnUnitTypeRoiPanelCallback...
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
                  'string'  , 'Smalest Contour (pixels)',...
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
                  'string'  , 'Upper Treshold Relative Max',...
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
                  'string'  , 'Upper Treshold',...
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
                  'string'  , 'Lower Treshold',...
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

        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'Inactive',...
                  'string'  , 'Pixel Edge',...
                  'horizontalalignment', 'left',...
                  'position', [35 52 150 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @chkPixelEdgeCallback...
                  );

    chkPixelEdge = ...
        uicontrol(uiRoiPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , pixelEdge('get'),...
                  'position', [15 55 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @chkPixelEdgeCallback...
                  );
    chkPixelEdgePtr('set', chkPixelEdge);

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
                  'FontWeight', 'bold',...
                  'Position',[160 30 100 25],...
                  'Enable'  , 'On', ...
                  'BackgroundColor', [0.6300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @createVoiRoiPanelCallback...
                  );

    uiCreateVoiRoiPanelObject('set', uiCreateVoiRoiPanel);

    minTresholdRoiPanelValue('set', true, 'Percent', minTresholdSliderRoiPanelValue('get'));
    maxTresholdRoiPanelValue('set', true, 'Percent', maxTresholdSliderRoiPanelValue('get'));

    
    function setLesionTypeRoiPanelCallback(hObject, ~)
        
        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
                        
        atRoiInput = roiTemplate('get', dSerieOffset);
        atVoiInput = voiTemplate('get', dSerieOffset);

        if ~isempty(atVoiInput)

            try

            set(uiDeleteVoiRoiPanel     , 'Enable', 'off');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'off');

            set(uiAddVoiRoiPanel , 'Enable', 'off');
            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;

            dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value');

            bLesionOffset = get(hObject, 'Value');
            asLesionType  = get(hObject, 'String');
            sLesionType = asLesionType{bLesionOffset};
                                    
            atVoiInput{dVoiOffset}.LesionType = sLesionType; 

            sLesionShortName = '';
            [bLesionOffset, ~, asLesionShortName] = getLesionType(sLesionType);   
            for jj=1:numel(asLesionShortName)
                if contains(atVoiInput{dVoiOffset}.Label, asLesionShortName{jj})
                    sLesionShortName = asLesionShortName{jj};
                    atVoiInput{dVoiOffset}.Label = replace(atVoiInput{dVoiOffset}.Label, asLesionShortName{jj}, asLesionShortName{bLesionOffset});
                    break;
                end
            end

            voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atVoiInput);
                        
            for rr=1:numel(atVoiInput{dVoiOffset}.RoisTag) % Set ROIs template
                for tt=1:numel(atRoiInput)
                    if strcmp(atVoiInput{dVoiOffset}.RoisTag{rr}, atRoiInput{tt}.Tag)
                        if contains(atRoiInput{tt}.Label, sLesionShortName)
                            atRoiInput{tt}.Label = replace(atRoiInput{tt}.Label, sLesionShortName, asLesionShortName{bLesionOffset});
                            atRoiInput{tt}.Object.Label = atRoiInput{tt}.Label;
                        end                      
                        atRoiInput{tt}.LesionType = sLesionType;
                        break;
                    end                   
                end
            end

            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);

            setVoiRoiSegPopup();

            catch
                progressBar(1, 'Error:setLesionTypeRoiPanelCallback()');
            end

            set(uiDeleteVoiRoiPanel     , 'Enable', 'on');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'on');

            set(uiAddVoiRoiPanel , 'Enable', 'on');
            set(uiPrevVoiRoiPanel, 'Enable', 'on');
            set(uiNextVoiRoiPanel, 'Enable', 'on');
            set(uiDelVoiRoiPanel , 'Enable', 'on');

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;         
        end
                

    end

    function setVoiSeriesOffsetRoiPanelCallback(hObject, ~)


        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        dNbVOIs = numel(atVoiInput);

        if ~isempty(atVoiInput)

            try

            set(uiDeleteVoiRoiPanel     , 'Enable', 'off');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'off');

            set(uiAddVoiRoiPanel , 'Enable', 'off');
            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');

            setCrossVisibility(false);                    

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;

            dVoiOffset = get(hObject, 'Value');

            if dVoiOffset <= 0
                dVoiOffset = dNbVOIs;
            end

            set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);
            
            sLesionType = atVoiInput{dVoiOffset}.LesionType;
            [bLesionOffset, ~, ~] = getLesionType(sLesionType);
            set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
                    
            sRoiTag = getLargestArea(atVoiInput{dVoiOffset}.RoisTag);
            
%            dRodSerieOffset = round(numel(atVoiInput{dVoiOffset}.RoisTag)/2);

            triangulateRoi(sRoiTag);

            catch
                progressBar(1, 'Error:setVoiSeriesOffsetRoiPanelCallback()');
            end

            setCrossVisibility(true);                    

            set(uiDeleteVoiRoiPanel     , 'Enable', 'on');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'on');

            set(uiAddVoiRoiPanel , 'Enable', 'on');
            set(uiPrevVoiRoiPanel, 'Enable', 'on');
            set(uiNextVoiRoiPanel, 'Enable', 'on');
            set(uiDelVoiRoiPanel , 'Enable', 'on');     
            
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;             
        end


    end

    
    function addVoiRoiPanelCallback(~, ~)
        
        triangulateCallback()
        
        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
                
        aBuffer = dicomBuffer('get', [], dSerieOffset);
        
        dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value');
                
        atVoiInput = voiTemplate('get', dSerieOffset);
                
        if size(aBuffer, 3) == 1
            pAxe = axePtr('get', [], dSerieOffset);
        else
            pAxe = axes3Ptr('get', [], dSerieOffset);
        end
        
        % Set axe & viewer for ROI

        setCrossVisibility(false);
     
        roiSetAxeBorder(true, pAxe);

        mainToolBarEnable('off');
        mouseFcn('reset');
        
        sRoiTag = num2str(randi([-(2^52/2),(2^52/2)],1));
       
        pRoi = drawfreehand(pAxe, 'Color', atVoiInput{dVoiOffset}.Color, 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', sRoiTag, 'FaceSelectable', 1, 'FaceAlpha', 0);
        pRoi.FaceAlpha = roiFaceAlphaValue('get');

        if is2DBrush('get') == true    
            pRoi.Waypoints(:) = false;
            pRoi.InteractionsAllowed = 'none';              
        end

        % Add ROI right click menu

        addRoi(pRoi, dSerieOffset, atVoiInput{dVoiOffset}.LesionType);

        roiDefaultMenu(pRoi);

        uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
        uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

        constraintMenu(pRoi);

        cropMenu(pRoi);

        voiMenu(pRoi);

        uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData', pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
        
        % Restore axe & viewer
                        
        windowButton('set', 'up');
        mouseFcn('set');
        mainToolBarEnable('on');

        if is2DBrush('get') == false
 
            roiSetAxeBorder(false, pAxe);
           
            setCrossVisibility(true);
        end

        % Add ROI to VOI
        
              
        atVoiInput{dVoiOffset}.RoisTag{end+1} = sRoiTag;
                        
        dRoiNb  = numel(atVoiInput{dVoiOffset}.RoisTag);
        dNbTags = numel(atVoiInput{dVoiOffset}.RoisTag);
        
        atRoi = roiTemplate('get', dSerieOffset);
        
        if ~isempty(atRoi)
            aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {sRoiTag} );
            dTagOffset = find(aTagOffset, 1);       

            if ~isempty(dTagOffset)

                atRoi{dTagOffset}.ObjectType  = 'voi-roi';

                sLabel = sprintf('%s (roi %d/%d)', atVoiInput{dVoiOffset}.Label, dRoiNb, dNbTags);

                atRoi{dTagOffset}.Label = sLabel;
                atRoi{dTagOffset}.Object.Label = sLabel;   

                voiDefaultMenu(atRoi{dTagOffset}.Object, atVoiInput{dVoiOffset}.Tag);

            end
        end
        
        roiTemplate('set', dSerieOffset, atRoi);
        voiTemplate('set', dSerieOffset, atVoiInput);
                
        
%        catch
%        end
            
%        set(fiMainWindowPtr('get'), 'Pointer', 'default');
%        drawnow;                
        
%        atVoiInput{dVoiOffset}.RoisTag
   
    end

    function previousVoiRoiPanelCallback(~, ~)

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        dNbVOIs = numel(atVoiInput);

        if ~isempty(atVoiInput)
                        
            try

            set(uiDeleteVoiRoiPanel     , 'Enable', 'off');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'off');

            set(uiAddVoiRoiPanel , 'Enable', 'off');
            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');

            setCrossVisibility(false);                    

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;
            
            dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value')-1;

            if dVoiOffset <= 0
                dVoiOffset = dNbVOIs;
            end

            set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

            sLesionType = atVoiInput{dVoiOffset}.LesionType;
            [bLesionOffset, ~, ~] = getLesionType(sLesionType);
            set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
                 
            sRoiTag = getLargestArea(atVoiInput{dVoiOffset}.RoisTag);
%            dRodSerieOffset = round(numel(atVoiInput{dVoiOffset}.RoisTag)/2);

            triangulateRoi(sRoiTag);

            if is2DBrush('get') == false

                bViewAxeBorder = false;       
                if dVoiOffset == 1 && dNbVOIs > 1
                    bViewAxeBorder = true;       
                end
        
                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                    set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    set(uiOneWindowPtr('get'), 'BorderWidth'   , bViewAxeBorder);
                else
                    set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    set(uiTraWindowPtr('get'), 'BorderWidth'   , bViewAxeBorder);
                end
            else
                if dVoiOffset == 1 && dNbVOIs > 1
                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                        set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    else
                        set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    end  
                else
                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                        set(uiOneWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    else
                        set(uiTraWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    end                      
                end

            end

            catch
                progressBar(1, 'Error:previousVoiRoiPanelCallback()');
            end

            setCrossVisibility(true);                    

            set(uiDeleteVoiRoiPanel     , 'Enable', 'on');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'on');

            set(uiAddVoiRoiPanel , 'Enable', 'on');
            set(uiPrevVoiRoiPanel, 'Enable', 'on');
            set(uiNextVoiRoiPanel, 'Enable', 'on');
            set(uiDelVoiRoiPanel , 'Enable', 'on');

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;             
        end

    end

    function nextVoiRoiPanelCallback(~, ~)

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        dNbVOIs = numel(atVoiInput);

        if ~isempty(atVoiInput)
            
            try

            set(uiDeleteVoiRoiPanel     , 'Enable', 'off');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'off');

            set(uiAddVoiRoiPanel , 'Enable', 'off');
            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');

            setCrossVisibility(false);                    

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;

            dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value')+1;

            if dVoiOffset > dNbVOIs
                dVoiOffset = 1;
            end

            set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);
            
            sLesionType = atVoiInput{dVoiOffset}.LesionType;
            [bLesionOffset, ~, ~] = getLesionType(sLesionType);
            set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
            
            sRoiTag = getLargestArea(atVoiInput{dVoiOffset}.RoisTag);

            triangulateRoi(sRoiTag);

            if is2DBrush('get') == false
        
                bViewAxeBorder = false;       
                if dVoiOffset == 1 && dNbVOIs > 1
                    bViewAxeBorder = true;       
                end
    
                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                    set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    set(uiOneWindowPtr('get'), 'BorderWidth'   , bViewAxeBorder);
                else
                    set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    set(uiTraWindowPtr('get'), 'BorderWidth'   , bViewAxeBorder);
                end
            else
                if dVoiOffset == 1 && dNbVOIs > 1
                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                        set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    else
                        set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 0]);
                    end  
                else
                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                        set(uiOneWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    else
                        set(uiTraWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    end                      
                end
       
            end


            catch
                progressBar(1, 'Error:nextVoiRoiPanelCallback()');
            end

            setCrossVisibility(true);                    

            set(uiDeleteVoiRoiPanel     , 'Enable', 'on');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'on');

            set(uiAddVoiRoiPanel , 'Enable', 'on');
            set(uiPrevVoiRoiPanel, 'Enable', 'on');
            set(uiNextVoiRoiPanel, 'Enable', 'on');
            set(uiDelVoiRoiPanel , 'Enable', 'on');

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;            
        end

    end

    function deleteVoiRoiPanelCallback(~, ~)

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
        
        atRoiInput = roiTemplate('get', dSerieOffset);
        atVoiInput = voiTemplate('get', dSerieOffset);

        if ~isempty(atVoiInput)    
            
            try
    
            set(uiDeleteVoiRoiPanel     , 'Enable', 'off');
            set(uiLesionTypeVoiRoiPanel , 'Enable', 'off');

            set(uiAddVoiRoiPanel , 'Enable', 'off');
            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');

            setCrossVisibility(false);                    

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;
              
            dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value');
            ptrObject = atVoiInput{dVoiOffset};
            
            % Clear VOI input template
            
            if ~isempty(atVoiInput)
                aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {[ptrObject.Tag]} );
                dTagOffset = find(aTagOffset, 1);       
                
                if ~isempty(dTagOffset)
                    atVoiInput(dTagOffset) = [];            
%                    atVoiInput(cellfun(@isempty, atVoiInput)) = [];
                end                   

                voiTemplate('set', dSerieOffset, atVoiInput);
            end
            
            % Clear ROI input template
            
            aRoisTagOffset = zeros(1, numel(ptrObject.RoisTag));
            if ~isempty(atRoiInput)
                
                for rr=1:numel(ptrObject.RoisTag)
                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrObject.RoisTag{rr}]} );
                    aRoisTagOffset(rr) = find(aTagOffset, 1);    
                end
                               
                for rr=1:numel(ptrObject.RoisTag)
                    
                    % Clear it constraint

                    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSerieOffset);

                    if ~isempty(asConstraintTagList)
                        dConstraintOffset = find(contains(asConstraintTagList, ptrObject.RoisTag(rr)));
                        if ~isempty(dConstraintOffset) % tag exist
                             roiConstraintList('set', dSerieOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                        end    
                    end

                     % Delete farthest distance objects
        
                    if ~isempty(atRoiInput{aRoisTagOffset(rr)}.MaxDistances)
                        objectsToDelete = [atRoiInput{aRoisTagOffset(rr)}.MaxDistances.MaxXY.Line, ...
                                           atRoiInput{aRoisTagOffset(rr)}.MaxDistances.MaxCY.Line, ...
                                           atRoiInput{aRoisTagOffset(rr)}.MaxDistances.MaxXY.Text, ...
                                           atRoiInput{aRoisTagOffset(rr)}.MaxDistances.MaxCY.Text];
                        delete(objectsToDelete(isvalid(objectsToDelete)));
                    end                   
                    
                    % Delete ROI object 

                    if isvalid(atRoiInput{aRoisTagOffset(rr)}.Object)
                        delete(atRoiInput{aRoisTagOffset(rr)}.Object)
                    end           

                    atRoiInput{aRoisTagOffset(rr)} = [];
                end

                atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                roiTemplate('set', dSerieOffset, atRoiInput);            
            end
            
                       
            dNbVOIs = numel(atVoiInput);

            if dVoiOffset > dNbVOIs || ...
                dNbVOIs == 0
                dVoiOffset = 1;

                if dNbVOIs ~= 0
                    
%                    if is2DBrush('get') == false

                        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                            set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 0]);
                            set(uiOneWindowPtr('get'), 'BorderWidth'   , true);
                        else
                            set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 0]);
                            set(uiTraWindowPtr('get'), 'BorderWidth'   , true);
                        end
                      
                        setCrossVisibility(true);                    
%                    end
     %               warndlg('Warning: End of list, returning to first contour', 'Contour list');
                end
            end

            set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

            if numel(atVoiInput) >= dVoiOffset
                sLesionType = atVoiInput{dVoiOffset}.LesionType;
                [bLesionOffset, ~, ~] = getLesionType(sLesionType);
                set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
            else
                set(uiLesionTypeVoiRoiPanel, 'Value' , 1);
                set(uiLesionTypeVoiRoiPanel, 'Enable', 'off');
                set(uiLesionTypeVoiRoiPanel, 'String', ' ');                   
            end

            if dNbVOIs ~= 0
                sRoiTag = getLargestArea(atVoiInput{dVoiOffset}.RoisTag);

                triangulateRoi(sRoiTag);
            else
                if is2DBrush('get') == true
                    releaseRoiWait();                
                end
            end

            setVoiRoiSegPopup();
           
            setCrossVisibility(true);                    
          
            catch
                progressBar(1, 'Error:deleteVoiRoiPanelCallback()');                
            end

            if numel(atVoiInput)

                set(uiDeleteVoiRoiPanel     , 'Enable', 'on');
                set(uiLesionTypeVoiRoiPanel , 'Enable', 'on');
    
                set(uiAddVoiRoiPanel , 'Enable', 'on');
                set(uiPrevVoiRoiPanel, 'Enable', 'on');
                set(uiNextVoiRoiPanel, 'Enable', 'on');
                set(uiDelVoiRoiPanel , 'Enable', 'on');
            end

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
        end
    end
    
    function sliderRoisFaceAlphaRoiPanelCallback(~, ~)

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        roiFaceAlphaValue('set', get(uiSliderRoisFaceAlphaRoiPanel, 'Value'));

        tRefreshRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        if ~isempty(tRefreshRoi)

            for bb=1:numel(tRefreshRoi)
                if isvalid(tRefreshRoi{bb}.Object)
                    if ~strcmpi(tRefreshRoi{bb}.Type, 'images.roi.line')
                        tRefreshRoi{bb}.Object.FaceAlpha = roiFaceAlphaValue('get');
                        tRefreshRoi{bb}.FaceAlpha = roiFaceAlphaValue('get');
                    end
               end
            end

            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRefreshRoi);
        end

        catch
            progressBar(1, 'Error:sliderRoisFaceAlphaRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function edtSphereDiameterCallback(hObject, ~)

        dSphereDiameter = str2double(get(hObject, 'String'));

        if dSphereDiameter <= 0
            dSphereDiameter = 1;
            set(hObject, 'String', 1);
        end

        sphereDefaultDiameter('set', dSphereDiameter);

    end

    function btnUnitTypeRoiPanelCallback(~, ~)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        dOffset = get(uiSeriesPtr('get'), 'Value');

        sUnitDisplay = getSerieUnitValue(dOffset);

        if strcmpi(sUnitDisplay, 'SUV') && ...
           get(chkUseCTRoiPanel, 'Value') == false

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in BQML')

                set(txtInPercentRoiPanel, 'String', sprintf('Treshold in SUV/%s', sSUVtype));
            else
                set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');
            end
        end

        if strcmpi(sUnitDisplay, 'HU') || ...
           get(chkUseCTRoiPanel, 'Value') == true

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in HU')
                set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');
            else
                set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
            end
        end

        [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

        dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
        dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');

        dDiff = dMax - dMin;

        dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
        dMinValue = (dMinTresholdValue*dDiff)+dMin;

        sSUVtype = viewerSUVtype('get');

        if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
            tQuant = quantificationTemplate('get');
            dMinValue = dMinValue*tQuant.tSUV.dScale;
            dMaxValue = dMaxValue*tQuant.tSUV.dScale;
        end

        if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
            [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
            dMaxValue = dCTWindow;
            dMinValue = dCTLevel;
        end

        set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));
        set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));

        catch
            progressBar(1, 'Error:btnUnitTypeRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function chkUseCTRoiPanelCallback(hObject, ~)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

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

            dOffset = get(uiSeriesPtr('get'), 'Value');
            sUnitDisplay = getSerieUnitValue(dOffset);
        else
            if get(chkUseCTRoiPanel, 'Value') == true % Use CT MAP
                
                set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
            else

                dOffset = get(uiSeriesPtr('get'), 'Value');

                sUnitDisplay = getSerieUnitValue(dOffset);

                if strcmpi(sUnitDisplay, 'SUV')

                    set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');

                elseif strcmpi(sUnitDisplay, 'HU')

                    set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
                   
                else
                    set(txtInPercentRoiPanel, 'String', sprintf('Treshold in %s', sUnitDisplay) );
                end

            end

        end

        if ~strcmpi(get(txtInPercentRoiPanel , 'String'), 'Treshold in Percent')

            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            dMaxTresholdValue = get(uiSliderMaxTresholdRoiPanel, 'Value');
            dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                dMaxValue = dCTWindow;
                dMinValue = dCTLevel;
            end

            set(uiEditMinTresholdRoiPanel, 'String', num2str(dMinValue));
            set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));
        end

        catch
            progressBar(1, 'Error:chkUseCTRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;      
    end

    function chkHolesRoiPanelCallback(hObject, ~)

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

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

        catch
            progressBar(1, 'Error:chkHolesRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
    end

    function chkPixelEdgeCallback(hObject, ~)

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkPixelEdge, 'Value') == true

                set(chkPixelEdge, 'Value', false);
            else
                set(chkPixelEdge, 'Value', true);
            end
        end

        pixelEdge('set', get(chkPixelEdge, 'Value'));

        catch
            progressBar(1, 'Error:chkPixelEdgeCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;        
    end

    function chkMultipleObjectsRoiPanelCallback(hObject, ~)

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

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

        catch
            progressBar(1, 'Error:chkMultipleObjectsRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
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
                               get(chkPixelEdge, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );
      
    end


    function sliderMaxTresholdRoiPanelCallback(~, hEvent)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

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

            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
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
                               get(chkPixelEdge, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );
    end

    function editMaxTresholdRoiPanelCallback(hObject, ~)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

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

            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');

                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
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
                               get(chkPixelEdge, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );
    end

    function sliderMinTresholdRoiPanelCallback(~, hEvent)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

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
            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
            dMinValue = (dMinTresholdValue*dDiff)+dMin;

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');
                dMinValue = dMinValue*tQuant.tSUV.dScale;
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
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
                               get(chkPixelEdge, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );
    end

    function editMinTresholdRoiPanelCallback(hObject, ~)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

%        delete(uiSliderMinTresholdRoiListener);

        sMinValue = get(hObject, 'String');
        dMinValue = str2double(sMinValue);
        if isnan(dMinValue)
            if get(chkInPercentRoiPanel, 'Value') == true
                dMinValue = minTresholdRoiPanelValue('get')*100;
            else
                [dMinValue, ~] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), false);
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
            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            dOffset = get(uiSeriesPtr('get'), 'Value');

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');
                dMin = dMin*tQuant.tSUV.dScale;
                dMax = dMax*tQuant.tSUV.dScale;
            end

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
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
                               get(chkPixelEdge, 'Value'), ...
                               get(chkHolesRoiPanel    , 'Value'), ...
                               get(chkUseCTRoiPanel    , 'Value'), ...
                               get(uiSeriesCTRoiPanel  , 'Value') ...
                               );
    end

    function chkRelativeToMaxRoiPanelCallback(hObject, ~)

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

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

            set(txtRelativeToMaxRoiPanel, 'String', 'Upper Treshold relative Max');
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

                dMinTresholdValue = get(uiSliderMinTresholdRoiPanel, 'Value');
                dMaxTresholdValue = maxTresholdSliderRoiPanelValue('get');

                dOffset = get(uiSeriesPtr('get'), 'Value');

                sUnitDisplay = getSerieUnitValue(dOffset);

                [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

                dDiff = dMax - dMin;

                if dMinTresholdValue > dMaxTresholdValue
                    dMinTresholdValue = dMaxTresholdValue;
                end

                dMaxValue = (dMaxTresholdValue*dDiff)+dMin;
                dMinValue = (dMinTresholdValue*dDiff)+dMin;

                sSUVtype = viewerSUVtype('get');

                if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                    tQuant = quantificationTemplate('get');
                    dMinValue = dMaxValue*tQuant.tSUV.dScale;
                end

                 if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
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

        catch
            progressBar(1, 'Error:chkRelativeToMaxRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function chkInPercentRoiPanelCallback(hObject, ~)
        
        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isempty(aBuffer)
            return;
        end

        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

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

            set(btnUnitTypeRoiPanel, 'Enable', 'off');

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
            set(btnUnitTypeRoiPanel, 'Enable', 'on');

            dOffset = get(uiSeriesPtr('get'), 'Value');

            sUnitDisplay = getSerieUnitValue(dOffset);

            if strcmpi(sUnitDisplay, 'SUV')
                if get(chkUseCTRoiPanel, 'Value') == true
                    if get(btnUnitTypeRoiPanel, 'Value') == true
                        set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');
                    else
                        set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
                    end
                else
                    if get(btnUnitTypeRoiPanel, 'Value') == true

                        sSUVtype = viewerSUVtype('get');

                        set(txtInPercentRoiPanel, 'String', sprintf('Treshold in SUV/%s', sSUVtype));
                    else
                        set(txtInPercentRoiPanel, 'String', 'Treshold in BQML');
                    end
                end
            elseif strcmpi(sUnitDisplay, 'HU')
                if get(btnUnitTypeRoiPanel, 'Value') == true
                    set(txtInPercentRoiPanel, 'String', 'Treshold in Window Level');
                else
                    set(txtInPercentRoiPanel, 'String', 'Treshold in HU');
                end
            else
                set(txtInPercentRoiPanel, 'String', sprintf('Treshold in %s', sUnitDisplay));
            end

            dMaxTresholdValue = maxTresholdSliderRoiPanelValue('get');

            [dMin, dMax] = getTresholdMinMax(aBuffer, get(uiSeriesPtr('get'), 'Value'), get(chkUseCTRoiPanel, 'Value'));

            dDiff = dMax - dMin;

            dMaxValue = (dMaxTresholdValue*dDiff)+dMin;

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
                tQuant = quantificationTemplate('get');
                dMaxValue = dMaxValue*tQuant.tSUV.dScale;
            end

            dMinTresholdValue = minTresholdSliderRoiPanelValue('get');

            dMinValue = (dMinTresholdValue*dDiff)+dMin;

            if strcmpi(get(txtInPercentRoiPanel, 'String'), 'Treshold in Window Level')
                [dCTWindow, dCTLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                dMaxValue = dCTWindow;
                dMinValue = dCTLevel;
            end

            set(uiEditMaxTresholdRoiPanel, 'String', num2str(dMaxValue));

            maxTresholdRoiPanelValue('set', get(chkInPercentRoiPanel, 'Value'), sUnitDisplay, dMaxValue);

            sSUVtype = viewerSUVtype('get');

            if strcmpi(get(txtInPercentRoiPanel, 'String'), sprintf('Treshold in SUV/%s', sSUVtype))
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

        catch
            progressBar(1, 'Error:chkInPercentRoiPanelCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

%        uiSliderMaxTresholdRoiListener = addlistener(uiSliderMaxTresholdRoiPanel, 'Value', 'PreSet', @sliderMaxTresholdRoiPanelCallback);
%        if relativeToMaxRoiPanelValue('get') == false
%            uiSliderMinTresholdRoiListener = addlistener(uiSliderMinTresholdRoiPanel, 'Value', 'PreSet', @sliderMinTresholdRoiPanelCallback);
%        end
    end

    function previewRoiSegmentation(dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset)

        PIXEL_EDGE_RATIO = 3;

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
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
            
        bRelativeToMax = relativeToMaxRoiPanelValue('get');

        dSliderMin = minTresholdSliderRoiPanelValue('get');
        dSliderMax = maxTresholdSliderRoiPanelValue('get');
       
        % Get constraint 

        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

        bInvertMask = invertConstraint('get');

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aLogicalMask = roiConstraintToMask(aBuffer, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        
                
        dImageMin = min(double(aBuffer),[], 'all');        
        
        if size(aBuffer, 3) == 1
            
            aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint
            
            if bUseCtMap == true
                dTresholdMin = roiPanelCTMinValue('get');
                dTresholdMax = roiPanelCTMaxValue('get');
            else
                dTresholdMin = min(double(aBuffer),[], 'all');
                dTresholdMax = max(double(aBuffer),[], 'all');
            end

            dBufferDiff = dTresholdMax - dTresholdMin;

            dMinTreshold = (dSliderMin * dBufferDiff)+dTresholdMin;
            dMaxTreshold = (dSliderMax * dBufferDiff)+dTresholdMin; 
        
            vBoundAxePtr = visBoundAxePtr('get');
            if ~isempty(vBoundAxePtr)
                delete(vBoundAxePtr);
            end
                                               
            if bRelativeToMax == true
                aBuffer(aBuffer<=dMaxTreshold) = dImageMin;
            else
                aBuffer(aBuffer<=dMinTreshold) = dImageMin;
                aBuffer(aBuffer>=dMaxTreshold) = dImageMin;
            end

            if bHoles == true
                originalMaskAxe = bwboundaries(bwimage(aBuffer, dImageMin), 'holes', 8);
            else
                originalMaskAxe = bwboundaries(bwimage(aBuffer, dImageMin), 'noholes', 8);
            end

            if bPixelEdge == true
                aBuffer = imresize(aBuffer , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
            end

            if bHoles == true
                maskAxe = bwboundaries(bwimage(aBuffer, dImageMin), 'holes', 8);
            else
                maskAxe = bwboundaries(bwimage(aBuffer, dImageMin), 'noholes', 8);
            end

            if bPixelEdge == true
                
                if ~isempty(maskAxe)
                    for jj=1:numel(maskAxe)
                        maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;
                        maskAxe{jj} = reducepoly(maskAxe{jj});
                    end
                end
            end

            if ~isempty(maskAxe)

                maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);

                if ~isempty(maskAxe)
                    vBoundAxePtr = visboundaries(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), maskAxe);
                    visBoundAxePtr('set', vBoundAxePtr);
                end
            end

        else % 3D Image

            if bUseCtMap == true % Apply ct mask

                dSerieOffset   = get(uiSeriesPtr('get'), 'Value');

                atRefMetaData = dicomMetaData('get', [], dSerieOffset);

                tInput        = inputTemplate('get');
                tRoiPanelCT   = roiPanelCtUiValues('get');
                
                aCtBuffer    = dicomBuffer('get', [], tRoiPanelCT{dCtOffset}.dSeriesNumber);
                atCtMetaData = dicomMetaData('get', [], tRoiPanelCT{dCtOffset}.dSeriesNumber);
                
                if isempty(atCtMetaData)
                    atCtMetaData = tInput(tRoiPanelCT{dCtOffset}.dSeriesNumber).atDicomInfo;
                    dicomMetaData('set', atCtMetaData, tRoiPanelCT{dCtOffset}.dSeriesNumber);
                end
                
                if isempty(aCtBuffer)
                    aInput = inputBuffer('get');
                    aCtBuffer = aInput{tRoiPanelCT{dCtOffset}.dSeriesNumber};
                    
                    if strcmpi(imageOrientation('get'), 'coronal')
                        aCtBuffer = reorientBuffer(aCtBuffer, 'coronal');
                    elseif strcmpi(imageOrientation('get'), 'sagittal')
                        aCtBuffer = reorientBuffer(aCtBuffer, 'sagittal');
                    end
                    
                    if tInput(dSerieOffset).bFlipLeftRight == true
                        aCtBuffer = aCtBuffer(:,end:-1:1,:);
                    end
                    
                    if tInput(dSerieOffset).bFlipAntPost == true
                        aCtBuffer = aCtBuffer(end:-1:1,:,:);
                    end
                    
                    if tInput(dSerieOffset).bFlipHeadFeet == true
                        aCtBuffer = aCtBuffer(:,:,end:-1:1);
                    end
                    
                    dicomBuffer('set', aCtBuffer, tRoiPanelCT{dCtOffset}.dSeriesNumber);
                end
                
                [aBuffer, ~] = resampleImage(aCtBuffer, atCtMetaData, aBuffer, atRefMetaData, 'Nearest', 2, false);
                
                dImageMin = min(double(aBuffer), [], 'all');
            end
            
            aBuffer(aLogicalMask == 0) = dImageMin; % Apply constraint
            
            if bUseCtMap == true
                dTresholdMin = roiPanelCTMinValue('get');
                dTresholdMax = roiPanelCTMaxValue('get');
            else
                dTresholdMin = min(double(aBuffer), [], 'all');
                dTresholdMax = max(double(aBuffer), [], 'all');
            end
            
            dBufferDiff = dTresholdMax - dTresholdMin;
            dMinTreshold = (dSliderMin * dBufferDiff) + dTresholdMin;
            dMaxTreshold = (dSliderMax * dBufferDiff) + dTresholdMin;
            
            iCoronal  = sliceNumber('get', 'coronal');
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial');
            
            aCoronal  = permute(aBuffer(iCoronal, :, :), [3 2 1]);
            aSagittal = permute(aBuffer(:, iSagittal, :), [3 1 2]);
            aAxial    = aBuffer(:, :, iAxial);
            
            if bRelativeToMax == true
                aCoronal(aCoronal <= dMaxTreshold) = dImageMin;
                aSagittal(aSagittal <= dMaxTreshold) = dImageMin;
                aAxial(aAxial <= dMaxTreshold) = dImageMin;
            else
                aCoronal(aCoronal <= dMinTreshold | aCoronal >= dMaxTreshold) = dImageMin;
                aSagittal(aSagittal <= dMinTreshold | aSagittal >= dMaxTreshold) = dImageMin;
                aAxial(aAxial <= dMinTreshold | aAxial >= dMaxTreshold) = dImageMin;
            end
            
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
            
            if bHoles == true
                originalMaskCoronal  = bwboundaries(bwimage(aCoronal , dImageMin), 'holes', 8);
                originalMaskSagittal = bwboundaries(bwimage(aSagittal, dImageMin), 'holes', 8);
                originalMaskAxial    = bwboundaries(bwimage(aAxial   , dImageMin), 'holes', 8);
            else
                originalMaskCoronal  = bwboundaries(bwimage(aCoronal , dImageMin), 'noholes', 8);
                originalMaskSagittal = bwboundaries(bwimage(aSagittal, dImageMin), 'noholes', 8);
                originalMaskAxial    = bwboundaries(bwimage(aAxial   , dImageMin), 'noholes', 8);
            end
            
            if bPixelEdge == true
                aCoronal  = imresize(aCoronal  , PIXEL_EDGE_RATIO, 'nearest');
                aSagittal = imresize(aSagittal, PIXEL_EDGE_RATIO, 'nearest');
                aAxial    = imresize(aAxial   , PIXEL_EDGE_RATIO, 'nearest');
            end
            
            if bHoles == true
                maskCoronal  = bwboundaries(bwimage(aCoronal , dImageMin), 'holes', 8);
                maskSagittal = bwboundaries(bwimage(aSagittal, dImageMin), 'holes', 8);
                maskAxial    = bwboundaries(bwimage(aAxial   , dImageMin), 'holes', 8);
            else
                maskCoronal  = bwboundaries(bwimage(aCoronal , dImageMin), 'noholes', 8);
                maskSagittal = bwboundaries(bwimage(aSagittal, dImageMin), 'noholes', 8);
                maskAxial    = bwboundaries(bwimage(aAxial   , dImageMin), 'noholes', 8);
            end
            
            if bPixelEdge == true

                if ~isempty(maskCoronal)
                    for jj = 1:numel(maskCoronal)
                        maskCoronal{jj} = (maskCoronal{jj} + 1) / PIXEL_EDGE_RATIO;
                        maskCoronal{jj} = reducepoly(maskCoronal{jj});
                    end
                end
            
                if ~isempty(maskSagittal)
                    for jj = 1:numel(maskSagittal)
                        maskSagittal{jj} = (maskSagittal{jj} + 1) / PIXEL_EDGE_RATIO;
                        maskSagittal{jj} = reducepoly(maskSagittal{jj});
                    end
                end
            
                if ~isempty(maskAxial)
                    for jj = 1:numel(maskAxial)
                        maskAxial{jj} = (maskAxial{jj} + 1) / PIXEL_EDGE_RATIO;
                        maskAxial{jj} = reducepoly(maskAxial{jj});
                    end
                end
            end
            
            if ~isempty(maskCoronal)

                maskCoronal = deleteSmallElements(originalMaskCoronal, maskCoronal, dSmalestRoiSize);

                if ~isempty(maskCoronal)
                    vBoundAxes1Ptr = visboundaries(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), maskCoronal);
                    visBoundAxes1Ptr('set', vBoundAxes1Ptr);
                end
            end
            
            if ~isempty(maskSagittal)

                maskSagittal = deleteSmallElements(originalMaskSagittal, maskSagittal, dSmalestRoiSize);

                if ~isempty(maskSagittal)
                    vBoundAxes2Ptr = visboundaries(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), maskSagittal);
                    visBoundAxes2Ptr('set', vBoundAxes2Ptr);
                end
            end
            
            if ~isempty(maskAxial)

                maskAxial = deleteSmallElements(originalMaskAxial, maskAxial, dSmalestRoiSize);
                
                if ~isempty(maskAxial)
                    vBoundAxes3Ptr = visboundaries(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), maskAxial);
                    visBoundAxes3Ptr('set', vBoundAxes3Ptr);
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
            bPixelEdge       = get(chkPixelEdge, 'Value');
            bMultipleObjects = get(chkMultipleObjectsRoiPanel, 'Value');
            bHoles           = get(chkHolesRoiPanel, 'Value');
            dSmalestRoiSize  = str2double(get(edtSmalestRegion, 'String'));
            bUseCtMap        = get(chkUseCTRoiPanel  , 'Value');
            dCtOffset        = get(uiSeriesCTRoiPanel, 'Value');

            set(uiCreateVoiRoiPanel, 'String', 'Cancel');

            set(uiCreateVoiRoiPanel, 'Background', [0.2 0.039 0.027]);
            set(uiCreateVoiRoiPanel, 'Foreground', [0.94 0.94 0.94]);

            if is2DBrush('get') == true
                releaseRoiWait();                  
            end

            cancelCreateVoiRoiPanel('set', false);

            createVoiRoi(bMultipleObjects, dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset);

            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            dNbVOIs = numel(atVoiInput);

            if ~isempty(atVoiInput)

                dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value');

                if dVoiOffset <= 0
                    dVoiOffset = dNbVOIs;
                end

                set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

%                dRodSerieOffset = round(numel(atVoiInput{dVoiOffset}.RoisTag)/2);

%                triangulateRoi(atVoiInput{dVoiOffset}.RoisTag{dRodSerieOffset}, true);
            end

            cancelCreateVoiRoiPanel('set', false);
    
            set(uiCreateVoiRoiPanel, 'String', 'Segment');

            set(uiCreateVoiRoiPanel, 'Background', [0.6300 0.6300 0.4000]);
            set(uiCreateVoiRoiPanel, 'Foreground', [0.1 0.1 0.1]);            

        end

    end

    function createVoiRoi(bMultipleObjects, dSmalestRoiSize, bPixelEdge, bHoles, bUseCtMap, dCtOffset)

        PIXEL_EDGE_RATIO = 3;

        aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

        if isempty(aBuffer)
            return;
        end

        aBufferSize = size(aBuffer);

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
        dSerieOffset = get(uiSeries, 'Value');        
        
        bRelativeToMax = relativeToMaxRoiPanelValue('get');
        bInPercent     = inPercentRoiPanelValue('get');

        dSliderMin = minTresholdSliderRoiPanelValue('get');
        dSliderMax = maxTresholdSliderRoiPanelValue('get');
        
        % Roi constraint 

        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

        bInvertMask = invertConstraint('get');

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aLogicalMask = roiConstraintToMask(aBuffer, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        
                
        dImageMin = min(double(aBuffer),[], 'all');

        aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint
        
        if bUseCtMap == true
            dTresholdMin = roiPanelCTMinValue('get');
            dTresholdMax = roiPanelCTMaxValue('get');
        else
            dTresholdMin = min(double(aBuffer),[], 'all');
            dTresholdMax = max(double(aBuffer),[], 'all');
        end

        dBufferDiff = dTresholdMax - dTresholdMin;

        dMinTreshold = (dSliderMin * dBufferDiff)+dTresholdMin;
        dMaxTreshold = (dSliderMax * dBufferDiff)+dTresholdMin;     
                        
        if size(aBuffer, 3) == 1

            vBoundAxePtr = visBoundAxePtr('get');
            if ~isempty(vBoundAxePtr)
                delete(vBoundAxePtr);
            end

            if bRelativeToMax == true
                aBuffer(aBuffer<=dMaxTreshold) = dImageMin;
            else
                aBuffer(aBuffer<=dMinTreshold) = dImageMin;
                aBuffer(aBuffer>=dMaxTreshold) = dImageMin;
            end

            if bHoles == true
                [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aBuffer, dImageMin), 'holes', 8);
            else
                [originalMaskAxe ,~,~,~] = bwboundaries(bwimage(aBuffer, dImageMin), 'noholes', 8);
            end

            if bPixelEdge == true
                aBuffer = imresize(aBuffer , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
            end

            if bHoles == true
                [maskAxe ,~,~,~] = bwboundaries(bwimage(aBuffer, dImageMin), 'holes', 8);
            else
                [maskAxe ,~,~,~] = bwboundaries(bwimage(aBuffer, dImageMin), 'noholes', 8);
            end

            if bPixelEdge == true
                if ~isempty(maskAxe)
                    for jj=1:numel(maskAxe)
                        maskAxe{jj} = (maskAxe{jj} +1)/PIXEL_EDGE_RATIO;
                        maskAxe{jj} = reducepoly(maskAxe{jj});                        
                    end
                end
            end

            if ~isempty(maskAxe)

                maskAxe = deleteSmallElements(originalMaskAxe, maskAxe, dSmalestRoiSize);
                if ~isempty(maskAxe)

                    if bMultipleObjects == false
                        xmin=0.5;
                        xmax=1;
                        aColor=xmin+rand(1,3)*(xmax-xmin);
                    end

                    dMaskSize = numel(maskAxe);

                    asTag = [];

                    for jj=1:dMaskSize

                        if cancelCreateVoiRoiPanel('get') == true
                            break;
                        end

                        if bMultipleObjects == true
                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);
                        end

                        curentMask = maskAxe(jj);

                        sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                        aPosition = flip(curentMask{1}, 2);

                        if bPixelEdge == false    

                            aPosition = smoothRoi(aPosition, aBufferSize);
                        end

                        bAddRoi = true;
                        
                        pRoi = images.roi.Freehand(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                                                   'Smoothing'     , 1, ...
                                                   'Position'      , aPosition, ...
                                                   'Color'         , aColor, ...
                                                   'LineWidth'     , 1, ...
                                                   'Label'         , '', ...
                                                   'LabelVisible'  , 'off', ...
                                                   'Tag'           , sTag, ...
                                                   'Visible'       , 'off', ...
                                                   'FaceSelectable', 0, ...
                                                   'FaceAlpha'     , roiFaceAlphaValue('get') ...
                                                   );
                                               
              
%                        if dSmalestRoiSize > 0
%                            roiMask = pRoi.createMask();
%                            if numel(roiMask(roiMask==1)) < dSmalestRoiSize
%                                delete(pRoi);
%                                bAddRoi = false;
%                            end
%                        end

                        if bAddRoi == true

                            if bMultipleObjects == true

                                if bInPercent == true
                                    dMinValue = dSliderMin*100;
                                    dMaxValue = dSliderMax*100;
                                else
                                    dMinValue = dMinTreshold;
                                    dMaxValue = dMaxTreshold;
                                end

                                if bRelativeToMax == true
                                    sLabel = sprintf('RMAX-%d-ROI%d', dMaxValue, jj);
                                else
                                    sLabel = sprintf('MIN-MAX-%d-%d-ROI%d', dMinValue, dMaxValue, jj);
                                end

                                pRoi.Label = sLabel;
                            end

                            pRoi.Waypoints(:) = false;

                            addRoi(pRoi, dSerieOffset, 'Unspecified');

                            roiDefaultMenu(pRoi);

                            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
                            uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

                            constraintMenu(pRoi);

                            cropMenu(pRoi);
                            
                            voiMenu(pRoi);

                            uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                            asTag{numel(asTag)+1} = sTag;
                        end

                        drawnow limitrate;
                    end

   %                 asTag(cellfun(@isempty, asTag)) = [];

                    if ~isempty(asTag)

                        if bInPercent == true
                            dMinValue = dSliderMin*100;
                            dMaxValue = dSliderMax*100;
                        else
                            dMinValue = dMinTreshold;
                            dMaxValue = dMaxTreshold;
                        end

                        if bRelativeToMax == true
                            sLabel = sprintf('RMAX-%d', dMaxValue);
                        else
                            sLabel = sprintf('MIN-MAX-%d-%d-%d', dMinValue, dMaxValue);
                        end

                        createVoiFromRois(dSerieOffset, asTag, sLabel, aColor, 'Unspecified');

                    end
                    
                    setVoiRoiSegPopup();
        
                    refreshImages();
        
                    progressBar(1, 'Ready');                    
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
            
            % CT constraint 

            if bUseCtMap == true

                atRefMetaData = dicomMetaData('get');

                tInput = inputTemplate('get');

                tRoiPanelCT = roiPanelCtUiValues('get');

                dSerieOffset = get(uiSeriesPtr('get'), 'Value');

     %           set(uiSeriesPtr('get'), 'Value', tRoiPanelCT{dCtOffset}.dSeriesNumber);

                aCtBuffer = dicomBuffer('get', [], tRoiPanelCT{dCtOffset}.dSeriesNumber);

                atCtMetaData = dicomMetaData('get', [], tRoiPanelCT{dCtOffset}.dSeriesNumber);
                if isempty(atCtMetaData)

                    atCtMetaData = tInput(tRoiPanelCT{dCtOffset}.dSeriesNumber).atDicomInfo;
                    dicomMetaData('set', atCtMetaData, tRoiPanelCT{dCtOffset}.dSeriesNumber);
                end

                if isempty(aCtBuffer)

                    aInput = inputBuffer('get');
                    aCtBuffer = aInput{tRoiPanelCT{dCtOffset}.dSeriesNumber};
                    
                    if     strcmpi(imageOrientation('get'), 'axial')
                     %   aCtBuffer = aCtBuffer;
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

                    dicomBuffer('set', aCtBuffer, tRoiPanelCT{dCtOffset}.dSeriesNumber);

                    clear aCtBuffer;
                    clear aInput;
                end

%                set(uiSeriesPtr('get'), 'Value', dSerieOffset);

                [aBuffer, ~] = ...
                    resampleImage(aCtBuffer, ...
                                  atCtMetaData, ...
                                  aBuffer, ...
                                  atRefMetaData, ...
                                  'Nearest', ...
                                  2, ...
                                  false);
                
                aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint to CT

            end

            if bRelativeToMax == true
                aBuffer(aBuffer<=dMaxTreshold) = dImageMin;
            else
                aBuffer(aBuffer<=dMinTreshold) = dImageMin;
                aBuffer(aBuffer>=dMaxTreshold) = dImageMin;
            end

            BW = bwimage(aBuffer, dImageMin);

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


                progressBar( bb/dNbElements-0.0001, sprintf('Computing Volume %d/%d, please wait', bb, dNbElements) );

                xmin=0.5;
                xmax=1;
                aColor=xmin+rand(1,3)*(xmax-xmin);

                aBufferSize = size(BW, 3);

                asTag = [];

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

                        if bHoles == true
                            [originalMaskAxial,~,~,~] = bwboundaries(aAxial, 'holes', 8);
                        else
                            [originalMaskAxial,~,~,~] = bwboundaries(aAxial, 'noholes', 8);
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
                                    maskAxial{ii} = reducepoly(maskAxial{ii});
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

%                                bAddRoi = true;
                                if bPixelEdge == false
                                
                                    aPosition = smoothRoi(aPosition, aBufferSize);
                                end

                                pRoi = images.roi.Freehand(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                                                           'Smoothing'     , 1, ...
                                                           'Position'      , aPosition, ...
                                                           'Color'         , aColor, ...
                                                           'LineWidth'     , 1, ....
                                                           'Label'         , '', ...
                                                           'LabelVisible'  , 'off', ...
                                                           'Tag'           , sTag, ...
                                                           'Visible'       , 'off', ...
                                                           'FaceSelectable', 0, ...
                                                           'FaceAlpha'     , roiFaceAlphaValue('get') ...
                                                           );
                                 if bPixelEdge == true
                                     reduce(pRoi);
                                 end                                                
%                                if dSmalestRoiSize > 0
%                                    roiMask = pRoi.createMask();
%                                    if numel(roiMask(roiMask==1)) < dSmalestRoiSize
%                                        delete(pRoi);
%                                        bAddRoi = false;
%                                    end
%                                end

%                                if bAddRoi == true

                                    pRoi.Waypoints(:) = false;

                                    addRoi(pRoi, dSerieOffset, 'Unspecified');

                                    roiDefaultMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
                                    uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

                                    constraintMenu(pRoi);

                                    cropMenu(pRoi);
                                    
                                    voiMenu(pRoi);

                                    uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                                    asTag{numel(asTag)+1} = sTag;
%                                end
                                drawnow limitrate;
                            end
                        end
                    end
                end

    %            asTag(cellfun(@isempty, asTag)) = [];

                if ~isempty(asTag) 

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

                    createVoiFromRois(dSerieOffset, asTag, sLabel, aColor, 'Unspecified');
                end
            end
            
            clear BW;

            setVoiRoiSegPopup();

            refreshImages();

            progressBar(1, 'Ready');

        end

        catch
            progressBar(1, 'Error:createVoiRoi()');
        end

        clear aBuffer;

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

    function [dMin, dMax] = getTresholdMinMax(aBuffer, dOffset, dUseCT)
        
        if dUseCT == true
            dMin = roiPanelCTMinValue('get');
            dMax = roiPanelCTMaxValue('get');
        else                            
            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dOffset);

            bInvertMask = invertConstraint('get');

            atRoiInput = roiTemplate('get', dOffset);

            aLogicalMask = roiConstraintToMask(aBuffer, atRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);      

            dImageMin = min(double(aBuffer),[], 'all');

            aBuffer(aLogicalMask==0) = dImageMin; % Apply constraint

            dMin = min(double(aBuffer),[], 'all');
            dMax = max(double(aBuffer),[], 'all'); 
        end
    end

    function sRoiTag = getLargestArea(asRoisTag)
        
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        imRoi = dicomBuffer('get');

        dLargestMaskNbPixels = 0;

        sRoiTag = asRoisTag{round(numel(asRoisTag)/2)};

        for at=1:numel(asRoisTag)
            
            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asRoisTag{at} );
            dRoiTagOffset = find(aTagOffset, 1); 
            
            if ~isempty(dRoiTagOffset)
                
                switch lower(atRoiInput{dRoiTagOffset}.Axe)
                    
                    case 'axe'
                    imCData = imRoi(:,:); 
                                           
                    case 'axes1'
                    imCData = permute(imRoi(atRoiInput{dRoiTagOffset}.SliceNb,:,:), [3 2 1]);
                       
                    case 'axes2'
                    imCData = permute(imRoi(:,atRoiInput{dRoiTagOffset}.SliceNb,:), [3 1 2]) ;
                        
                    case 'axes3'
                    imCData  = imRoi(:,:,atRoiInput{dRoiTagOffset}.SliceNb);  
                       
                end                
                
                mask = roiTemplateToMask(atRoiInput{dRoiTagOffset}, imCData);      

                dMaskNbPixels = numel(imCData(mask));

                if dMaskNbPixels > dLargestMaskNbPixels 
                    dLargestMaskNbPixels = dMaskNbPixels;
                    sRoiTag = asRoisTag{at};                    
                end                                               
            end                
        end
    end

end
