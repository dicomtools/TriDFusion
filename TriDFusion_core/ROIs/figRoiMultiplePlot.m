function figRoiMultiplePlot(sType, atVoiRoiTag, bSUVUnit, bDoseKernel, bSegmented)
%function figRoiMultiplePlot(sType, atVoiRoiTag, bSUVUnit, bDoseKernel, bSegmented)
%Display a figure of multiple plot.
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

    tRoiInput = roiTemplate('get');
    atRoiVoiMetaData = dicomMetaData('get');

    tQuant = quantificationTemplate('get');
    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 0;
    end
    
    HIST_PANEL_X = 840;
    HIST_PANEL_y = 480;

    figRoiMultiplePlot = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-HIST_PANEL_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-HIST_PANEL_y/2) ...
               HIST_PANEL_X ...
               HIST_PANEL_y],...
               'Name', ' ',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'on', ...
               'Color', viewerBackgroundColor('get'), ...
               'Toolbar','none',...
               'SizeChangedFcn',@resizeFigRoiMultiplePlotCallback...
               );
           
    setMultiplePlotFigureName();
    
    aFigurePosition = get(figRoiMultiplePlot, 'Position');
            
    axeMultiplePlot = ...
        axes(figRoiMultiplePlot, ...
             'Units'   , 'pixels', ...
             'Position', [60 60 aFigurePosition(3)-360 aFigurePosition(4)-90], ...
             'Color'   , viewerAxesColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'on'...             
             );
         
    axeMultiplePlot.Title.String = sType;
    axeMultiplePlot.Title.Color  = viewerForegroundColor('get');
    
    if contains(lower(sType), 'cummulative')
        axeMultiplePlot.XLabel.String = 'Intensity';
        axeMultiplePlot.YLabel.String = 'Probability';
    else
        axeMultiplePlot.XLabel.String = 'cells';
        axeMultiplePlot.YLabel.String = 'Intensity';      
    end
            
    aAxePosition = get(axeMultiplePlot, 'Position');
    
    uiRoiListMainPanel = ...
        uipanel(figRoiMultiplePlot,...
                'Title'   , 'VOI/ROI List', ... 
                'Units'   , 'pixels',...
                'position', [aAxePosition(1)+aAxePosition(3)+5 ...                         
                             aAxePosition(2) ...
                             aFigurePosition(3)-aAxePosition(3)-aAxePosition(1)-5 ...
                             aAxePosition(4) ...
                            ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                              
                'Visible', 'on'...
                ); 
            
    aRoiListMainPosition = get(uiRoiListMainPanel, 'Position');
           
    uiRoiListPanel = ...
        uipanel(uiRoiListMainPanel,...
                'Units'   , 'pixels',...
                'position', [0 ...                         
                             0 ...
                             aRoiListMainPosition(3) ...
                             5000 ...
                            ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                              
                'Visible', 'on'...
                ); 

    aRoiListPosition = get(uiRoiListPanel, 'Position');

    uiRoiListPanelSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , uiRoiListMainPanel,...
                  'Units'   , 'pixels',...
                  'position', [aRoiListPosition(3)-20 ...
                               0 ...
                               20 ...
                               aRoiListMainPosition(4)-15 ...
                               ],...
                  'Value', 0, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                  
                  'Callback',@uiRoiListPanelSliderCallback ...
                  );
    addlistener(uiRoiListPanelSlider, 'Value', 'PreSet', @uiRoiListPanelSliderCallback);    
    
    setMultiplePlotRoiVoi(atVoiRoiTag);
        
    function resizeFigRoiMultiplePlotCallback(~, ~)
        
        if ~exist('figRoiMultiplePlot', 'var')
            return;
        end
        
        aFigurePosition  = get(figRoiMultiplePlot, 'Position');
        
        set(axeMultiplePlot, ...
            'Position', ...
            [60 ...
             60 ...
             aFigurePosition(3)-360 ...
             aFigurePosition(4)-90 ...
            ] ...
            );
        
        aAxePosition = get(axeMultiplePlot   , 'Position');
        
        set(uiRoiListMainPanel, ...
            'position', [aAxePosition(1)+aAxePosition(3)+5 ...                         
                         aAxePosition(2) ...
                         aFigurePosition(3)-aAxePosition(3)-aAxePosition(1)-5 ...
                         aAxePosition(4) ...
                        ]...
            );  
        
        aRoiListMainPosition = get(uiRoiListMainPanel, 'Position');
      
        set(uiRoiListPanel, ...
            'position', [0 ...                         
                         0 ...
                         aRoiListMainPosition(3) ...
                         5000 ...
                        ]...
            );         
               
        set(uiRoiListPanelSlider, ...
            'position', [aRoiListMainPosition(3)-20 ...
                         0 ...
                         20 ...
                         aRoiListMainPosition(4)-15 ...
                         ]...    
            );
                               
    end

    function uiRoiListPanelSliderCallback(~, ~)
        
        val = get(uiRoiListPanelSlider, 'Value');

        aPosition = get(uiRoiListPanel, 'Position');

        dPanelYSize  = aPosition(4);
        dPanelOffset = val * dPanelYSize;

        set(uiRoiListPanel, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function setMultiplePlotFigureName()
               
        sTitle = sType;

%        if bSegmented == true 
%            sSegmented = ' - Segmented Values';
%        else
%            sSegmented = '';
%        end

        if bDoseKernel == true
            sUnit = 'Unit: Dose';
        else

            if bSUVUnit == true

                if (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )
                    sUnit =  'Unit: SUV Weight';
                else

                    if (strcmpi(atRoiVoiMetaData{1}.Modality, 'ct'))
                       sUnit = 'Unit: HU';
                    else
                       sUnit = 'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(atRoiVoiMetaData{1}.Modality, 'ct'))
                    sUnit =  'Unit: HU';
                 else
                    if (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )
                        sUnit =  'Unit: BQML';
                    else
                        sUnit =  'Unit: Counts';
                    end
                end
            end
        end

        set(figRoiMultiplePlot, 'Name', [sTitle ' - ' atRoiVoiMetaData{1}.SeriesDescription ' - ' sUnit]);

    end 

    function setMultiplePlotRoiVoi(atVoiRoiTag)
        
        tRoiInput = roiTemplate('get');
        tVoiInput = voiTemplate('get');
        atRoiVoiMetaData = dicomMetaData('get');

        tQuant = quantificationTemplate('get');
        if isfield(tQuant, 'tSUV')
            dSUVScale = tQuant.tSUV.dScale;
        else
            dSUVScale = 0;
        end   
        
        aRoiListPosition = get(uiRoiListPanel, 'Position');
        
        dOffset=1;
        
        for aa=1:numel(atVoiRoiTag)
            
            bFoundTag = false;
                        
            for bb=1:numel(tVoiInput)
                if strcmp(atVoiRoiTag{aa}.Tag, tVoiInput{bb}.Tag)
                    
                    try
                    [imCData, logicalMask] = computeHistogram(dicomBuffer('get'), atRoiVoiMetaData, tVoiInput{bb}, tRoiInput, dSUVScale, bSUVUnit);
                    if bSegmented == true
                        imCDataMasked = imCData(logicalMask);
                        imCDataMasked = imCDataMasked(imCDataMasked>cropValue('get'));
                    else
                        imCDataMasked = imCData(logicalMask);
                    end  

                    set(axeMultiplePlot, 'XLim', [min(double(imCDataMasked),[],'all') max(double(imCDataMasked),[],'all')]);
                    set(axeMultiplePlot, 'YLim', [0 1]);        

                    ptrPlot = plotCummulative(axeMultiplePlot, imCDataMasked, tVoiInput{bb}.Color);

                    if dOffset==1
                        imCumCDataMasked = imCDataMasked;
                    else
                        imCumCDataMasked = [imCumCDataMasked;  imCDataMasked];
                    end

                    set(axeMultiplePlot, 'XLim', [min(double(imCumCDataMasked),[],'all') max(double(imCumCDataMasked),[],'all')]);

                    axeMultiplePlot.XColor = viewerForegroundColor('get');
                    axeMultiplePlot.YColor = viewerForegroundColor('get');
                    axeMultiplePlot.ZColor = viewerForegroundColor('get');

                    axeMultiplePlot.XLabel.String = 'Intensity';
                    axeMultiplePlot.YLabel.String = 'Probability';

                    axeMultiplePlot.Title.Color = viewerForegroundColor('get');
                    axeMultiplePlot.Color = viewerAxesColor('get'); 
                    
                    txtRoiList{dOffset} = ...
                        uicontrol(uiRoiListPanel,...
                                  'style'   , 'text',...
                                  'string'  , tVoiInput{bb}.Label,...
                                  'horizontalalignment', 'left',...
                                  'position', [5 (dOffset-1)*25 aRoiListPosition(3)-35 20],...
                                  'Enable', 'Inactive',...
                                  'UserData', ptrPlot, ...
                                  'ForegroundColor', tVoiInput{bb}.Color, ...
                                  'BackgroundColor', viewerBackgroundColor('get'), ...
                                  'ButtonDownFcn', @highlightPlotCallback...                                  
                                  );                                  
                    dOffset = dOffset+1;   
                    bFoundTag = true;
                    
                    catch
                    end
                    break;                                 
                end                    
            end
                
            if bFoundTag == false
                for bb=1:numel(tRoiInput)
                    if strcmp(atVoiRoiTag{aa}.Tag, tRoiInput{bb}.Tag)
                        try
                        [imCData, logicalMask] = computeHistogram(dicomBuffer('get'), atRoiVoiMetaData, tRoiInput{bb}, tRoiInput, dSUVScale, bSUVUnit);
                        if bSegmented == true
                            imCDataMasked = imCData(logicalMask);
                            imCDataMasked = imCDataMasked(imCDataMasked>cropValue('get'));
                        else
                            imCDataMasked = imCData(logicalMask);
                        end  

                        set(axeMultiplePlot, 'XLim', [min(double(imCDataMasked),[],'all') max(double(imCDataMasked),[],'all')]);
                        set(axeMultiplePlot, 'YLim', [0 1]);        
                        
                        ptrPlot = plotCummulative(axeMultiplePlot, imCDataMasked, tRoiInput{bb}.Color);

                        if dOffset==1
                            imCumCDataMasked = imCDataMasked;
                        else
                            imCumCDataMasked = [imCumCDataMasked;  imCDataMasked];
                        end

                        set(axeMultiplePlot, 'XLim', [min(double(imCumCDataMasked),[],'all') max(double(imCumCDataMasked),[],'all')]);

                        axeMultiplePlot.XColor = viewerForegroundColor('get');
                        axeMultiplePlot.YColor = viewerForegroundColor('get');
                        axeMultiplePlot.ZColor = viewerForegroundColor('get');

                        axeMultiplePlot.XLabel.String = 'Intensity';
                        axeMultiplePlot.YLabel.String = 'Probability';

                        axeMultiplePlot.Title.Color = viewerForegroundColor('get');
                        axeMultiplePlot.Color = viewerAxesColor('get'); 
                        
                        txtRoiList{dOffset} = ...
                            uicontrol(uiRoiListPanel,...
                                      'style'   , 'text',...
                                      'string'  , tRoiInput{bb}.Label,...
                                      'horizontalalignment', 'left',...
                                      'position', [5 (dOffset-1)*25 aRoiListPosition(3)-35 20],...
                                      'Enable', 'Inactive',...
                                      'UserData', ptrPlot, ...
                                      'ForegroundColor', tRoiInput{bb}.Color, ...
                                      'BackgroundColor', viewerBackgroundColor('get'), ...
                                      'ButtonDownFcn', @highlightPlotCallback...                                  
                                      );  
                                  
                        dOffset = dOffset+1;   
                        bFoundTag = true;
                        
                        catch
                        end
                        break;              

                    end
                end   
            end
        end
        
        if bFoundTag == true
            pCursor = datacursormode(figRoiMultiplePlot);
            pCursor.Enable = 'on';
        end
            
        function highlightPlotCallback(hObject, ~)
            
            for tt=1:numel(txtRoiList)
                txtRoiList{tt}.UserData.LineWidth = 0.5;
                txtRoiList{tt}.FontWeight = 'normal';
            end
            
            hObject.UserData.LineWidth = 2;
            hObject.FontWeight = 'bold';
        end
                
    end


end