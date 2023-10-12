function figRoiMultiplePlot(sType, aInputBuffer, atInputMetaData, atVoiRoiTag, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)
%function figRoiMultiplePlot(sType, aInputBuffer, atInputMetaData, atVoiRoiTag, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)
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

    gtxtRoiList = [];

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atRoiVoiMetaData = dicomMetaData('get', [],  get(uiSeriesPtr('get'), 'Value'));

    tQuant = quantificationTemplate('get');
    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 0;
    end

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    FIG_MPLOT_Y = ySize*0.75;
    FIG_MPLOT_X = FIG_MPLOT_Y;

    figRoiMultiplePlot = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_MPLOT_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_MPLOT_Y/2) ...
               FIG_MPLOT_X ...
               FIG_MPLOT_Y],...
               'Name', ' ',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'on', ...
               'Color', viewerBackgroundColor('get'), ...
               'Toolbar','none',...
               'SizeChangedFcn',@resizeFigRoiMultiplePlotCallback...
               );

    setMultiplePlotFigureName();

    mMultiplePlotFile = uimenu(figRoiMultiplePlot,'Label','File');
    uimenu(mMultiplePlotFile,'Label', 'Export to .csv...','Callback', @exportCurrentMultiplePlotCallback);
    uimenu(mMultiplePlotFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');


    mMultiplePlotEdit = uimenu(figRoiMultiplePlot,'Label','Edit');
    uimenu(mMultiplePlotEdit,'Label', 'Copy Display', 'Callback', @copyMultiplePlotDisplayCallback);

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
    axeMultiplePlot.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeMultiplePlot.Toolbar = [];

    axeMultiplePlot.Title.String = sType;
    axeMultiplePlot.Title.Color  = viewerForegroundColor('get');

    if contains(lower(sType), 'cumulative')
        if bDoseKernel == true
            axeMultiplePlot.XLabel.String = 'Intensity (Gy)';          
        else
            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) 

                if bSUVUnit == true                 
                    axeMultiplePlot.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                else
                    axeMultiplePlot.XLabel.String = 'Intensity (BQML)';
                end
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct') 

                    axeMultiplePlot.XLabel.String = 'Intensity (HU)';
                else
 
                    axeMultiplePlot.XLabel.String = 'Intensity (Count)';                    
                end
            end             
        end

        axeMultiplePlot.YLabel.String = 'Fraction';
    else
        axeMultiplePlot.XLabel.String = 'cells';
        if bDoseKernel == true
            axeMultiplePlot.YLabel.String = 'Intensity (Gy)';
        else
            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                if bSUVUnit == true                 
                    axeMultiplePlot.YLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                else
                    axeMultiplePlot.YLabel.String = 'Intensity (BQML)';
                end
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct') 
                    axeMultiplePlot.YLabel.String = 'Intensity (HU)';
                else
                    axeMultiplePlot.YLabel.String = 'Intensity (Count)';                    
                end
            end  
        end
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
                
        if bModifiedMatrix == true           
            sModified = ' - Cells Value: Display Image';
        else
            sModified = ' - Cells Value: Unmodified Image';
        end   
        
        if bSegmented == true 
            sSegmented = ' - Masked Cells Subtracted';
        else
            sSegmented = '';
        end
        

        if bDoseKernel == true
            sUnits = 'Unit: Dose';
        else

            if bSUVUnit == true

                if (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                    sSUVtype = viewerSUVtype('get');
                    sUnits =  sprintf('Unit: SUV/%s', sSUVtype);
                else

                    if (strcmpi(atRoiVoiMetaData{1}.Modality, 'ct'))
                       sUnits = 'Unit: HU';
                    else
                       sUnits = 'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(atRoiVoiMetaData{1}.Modality, 'ct'))
                    sUnits =  'Unit: HU';
                 else
                    if (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )
                        sUnits =  'Unit: BQML';
                    else
                        sUnits =  'Unit: Counts';
                    end
                end
            end
        end

        set(figRoiMultiplePlot, 'Name', [sTitle ' - ' atRoiVoiMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented]);

    end

    function setMultiplePlotRoiVoi(atVoiRoiTag)

        try

        txtRoiList = [];

        set(figRoiWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atRoiVoiMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

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

                    imCData = computeHistogram(aInputBuffer, ...
                                               atInputMetaData, ...
                                               dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                                               atRoiVoiMetaData, ...
                                               tVoiInput{bb}, ...
                                               tRoiInput, ...
                                               dSUVScale, ...
                                               bSUVUnit, ...
                                               bModifiedMatrix, ...
                                               bSegmented, ...
                                               bDoseKernel, ...
                                               bMovementApplied);

                    set(axeMultiplePlot, 'XLim', [min(double(imCData),[],'all') max(double(imCData),[],'all')]);
                    set(axeMultiplePlot, 'YLim', [0 1]);

                    ptrPlot = plotCummulative(axeMultiplePlot, imCData, tVoiInput{bb}.Color);

                    if dOffset==1
                        imCumCDataMasked = imCData;
                    else
                        imCumCDataMasked = [imCumCDataMasked;  imCData];
                    end

                    set(axeMultiplePlot, 'XLim', [min(double(imCumCDataMasked),[],'all') max(double(imCumCDataMasked),[],'all')]);

                    axeMultiplePlot.XColor = viewerForegroundColor('get');
                    axeMultiplePlot.YColor = viewerForegroundColor('get');
                    axeMultiplePlot.ZColor = viewerForegroundColor('get');

                    if bDoseKernel == true
                        axeMultiplePlot.XLabel.String = 'Intensity (Gy)';
                    else
                        if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                             strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                             strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) 

                            if bSUVUnit == true                 
                                axeMultiplePlot.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                            else
                                axeMultiplePlot.XLabel.String = 'Intensity (BQML)';
                            end
                        else
                            if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct') 

                                axeMultiplePlot.XLabel.String = 'Intensity (HU)';
                            else

                                axeMultiplePlot.XLabel.String = 'Intensity (Count)';                                
                            end
                        end                
                    end
                    axeMultiplePlot.YLabel.String = 'Fraction';

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
                        imCData = computeHistogram(aInputBuffer, ...
                                                   atInputMetaData, ...
                                                   dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                                                   atRoiVoiMetaData, ...
                                                   tRoiInput{bb}, ...
                                                   tRoiInput, ...
                                                   dSUVScale, ...
                                                   bSUVUnit, ...
                                                   bModifiedMatrix, ...
                                                   bSegmented, ...
                                                   bDoseKernel, ...
                                                   bMovementApplied);

                        set(axeMultiplePlot, 'XLim', [min(double(imCData),[],'all') max(double(imCData),[],'all')]);
                        set(axeMultiplePlot, 'YLim', [0 1]);

                        ptrPlot = plotCummulative(axeMultiplePlot, imCData, tRoiInput{bb}.Color);

                        if dOffset==1
                            imCumCDataMasked = imCData;
                        else
                            imCumCDataMasked = [imCumCDataMasked;  imCData];
                        end

                        set(axeMultiplePlot, 'XLim', [min(double(imCumCDataMasked),[],'all') max(double(imCumCDataMasked),[],'all')]);

                        axeMultiplePlot.XColor = viewerForegroundColor('get');
                        axeMultiplePlot.YColor = viewerForegroundColor('get');
                        axeMultiplePlot.ZColor = viewerForegroundColor('get');

                        if bDoseKernel == true
                            axeMultiplePlot.XLabel.String = 'Intensity (Gy)';
                        else
                            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) 

                                if bSUVUnit == true                 
                                    axeMultiplePlot.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                                else
                                    axeMultiplePlot.XLabel.String = 'Intensity (BQML)';
                                end
                            else
                                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct') 

                                    axeMultiplePlot.XLabel.String = 'Intensity (HU)';
                                else
                                    axeMultiplePlot.XLabel.String = 'Intensity (Count)';
                                end
                            end 
                        end
                        axeMultiplePlot.YLabel.String = 'Fraction';

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

        catch
            progressBar(1, 'Error:figRoiHistogram()');
        end

        set(figRoiWindowPtr('get'), 'Pointer', 'default');
        drawnow;

        function highlightPlotCallback(hObject, ~)

            for tt=1:numel(txtRoiList)
                txtRoiList{tt}.UserData.LineWidth = 0.5;
                txtRoiList{tt}.FontWeight = 'normal';
            end

            hObject.UserData.LineWidth = 2;
            hObject.FontWeight = 'bold';
        end

        gtxtRoiList = txtRoiList;
    end

    function copyMultiplePlotDisplayCallback(~, ~)

        try

            set(figRoiMultiplePlot, 'Pointer', 'watch');

%            rdr = get(hFig,'Renderer');
            inv = get(figRoiMultiplePlot,'InvertHardCopy');

%            set(hFig,'Renderer','Painters');
            set(figRoiMultiplePlot,'InvertHardCopy','Off');

            drawnow;
            hgexport(figRoiMultiplePlot,'-clipboard');

%            set(hFig,'Renderer',rdr);
            set(figRoiMultiplePlot,'InvertHardCopy',inv);
        catch
        end

        set(figRoiMultiplePlot, 'Pointer', 'default');
    end

    function exportCurrentMultiplePlotCallback(~, ~)

        tInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInput)
            return;
        end

        atMetaData = dicomMetaData('get', [], iOffset);

        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aDisplayBuffer = dicomBuffer('get', [], iOffset);

        aInput = inputBuffer('get');

        if     strcmpi(imageOrientation('get'), 'axial')
            aInputBuffer = aInput{iOffset};
        elseif strcmpi(imageOrientation('get'), 'coronal')
            aInputBuffer = reorientBuffer(aInput{iOffset}, 'coronal');
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            aInputBuffer = reorientBuffer(aInput{iOffset}, 'sagittal');
        end

        if size(aInputBuffer, 3) ==1

            if tInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if tInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if tInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if tInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if tInput(iOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end 
            
        atInputMetaData = tInput(iOffset).atDicomInfo;

        try
            matlab.io.internal.getExcelInstance;
            bExcelInstance = true;
        catch exception %#ok<NASGU>
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
            bExcelInstance = false;
        end

        filter = {'*.csv'};
        info = dicomMetaData('get', [], iOffset);

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastHistDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
            load('-mat', sMatFile); % lastDirMat mat file exists, load it
            if exist('saveHistLastUsedDir', 'var')
                sCurrentDir = saveHistLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end
        
%        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sSeriesDate = info{1}.SeriesDate;
        
        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save Histogram Result', sprintf('%s/%s_%s_%s_%s_MULTI_CUMULATIVE_DVH_TriDFusion.csv' , ...
            sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription), sSeriesDate) );

        if file ~= 0

        %     try

            set(figRoiMultiplePlot, 'Pointer', 'watch');
            drawnow;

            try
                saveHistLastUsedDir = [path '/'];
                save(sMatFile, 'saveHistLastUsedDir');
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                    if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                    else
%                        sLogo = './logo.png';
%                    end

%                    javaFrame = get(h, 'JavaFrame');
%                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            if exist(sprintf('%s%s', path, file), 'file')
                delete(sprintf('%s%s', path, file));
            end


            % Count number of elements

            dNumberOfLines =1;
            for tt=1:numel(atVoiRoiTag)

                for vv=1:numel(tVoiInput)

                    if strcmp(atVoiRoiTag{tt}.Tag, tVoiInput{vv}.Tag) % Found a VOI
                       if strcmpi(tVoiInput{vv}.ObjectType, 'voi')

                           if ~isempty(tVoiInput{vv}.RoisTag)

                               dNumberOfLines = dNumberOfLines+1;

                                for cc=1:numel(tVoiInput{vv}.RoisTag)
                                    for bb=1:numel(tRoiInput)
                                       if isvalid(tRoiInput{bb}.Object)
                                            if strcmpi(tVoiInput{vv}.RoisTag{cc}, tRoiInput{bb}.Tag) % Found a VOI/ROI
                                                dNumberOfLines = dNumberOfLines+1;
                                            end
                                        end
                                    end
                                end
                           end
                       end
                    end
                end

                for rr=1:numel(tRoiInput)

                    if strcmp(atVoiRoiTag{tt}.Tag, tRoiInput{rr}.Tag)  % Found a ROI
                        if ~strcmpi(tRoiInput{rr}.ObjectType, 'voi')
                            dNumberOfLines = dNumberOfLines+1;
                        end
                    end
                end
            end

            if bDoseKernel == true
                sUnits = 'Dose';
            else

                if bSUVUnit == true

                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atMetaData{1}.Units, 'BQML' )

                        sSUVtype = viewerSUVtype('get');
                        sUnits   = sprintf('SUV/%s', sSUVtype);
                    else

                        if (strcmpi(atMetaData{1}.Modality, 'ct'))
                           sUnits = 'HU';
                        else
                           sUnits = 'Counts';
                        end
                    end
                else
                     if (strcmpi(atMetaData{1}.Modality, 'ct'))
                        sUnits = 'HU';
                     else
                        if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                            strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                            strcmpi(atMetaData{1}.Units, 'BQML' )
                            sUnits = 'BQML';
                        else
                            sUnits = 'Counts';
                        end
                    end
                end
            end

            asVoiRoiHeader{1} = sprintf('Patient Name, %s'      , cleanString(atMetaData{1}.PatientName, '_'));
            asVoiRoiHeader{2} = sprintf('Patient ID, %s'        , atMetaData{1}.PatientID);
            asVoiRoiHeader{3} = sprintf('Series Description, %s', cleanString(atMetaData{1}.SeriesDescription, '_'));
            asVoiRoiHeader{4} = sprintf('Accession Number, %s'  , atMetaData{1}.AccessionNumber);
            asVoiRoiHeader{5} = sprintf('Series Date, %s'       , atMetaData{1}.SeriesDate);
            asVoiRoiHeader{6} = sprintf('Series Time, %s'       , atMetaData{1}.SeriesTime);
            asVoiRoiHeader{7} = sprintf('Units, %s'             , sUnits);
            asVoiRoiHeader{8} = (' ');

            dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader)+(3*numel(gtxtRoiList)+(1*numel(gtxtRoiList))+3); % Add header and cell description and footer to number of needed lines

            asCell = cell(dNumberOfLines, 21); % Create an empty cell array

            dLineOffset = 1;
            for ll=1:numel(asVoiRoiHeader)

                asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                for tt=2:21
                    asCell{dLineOffset,tt}  = (' ');
                end

                dLineOffset = dLineOffset+1;
            end

            asCell{dLineOffset,1}  = 'Name';
            asCell{dLineOffset,2}  = 'Image number';
            asCell{dLineOffset,3}  = 'NB Pixels';
            asCell{dLineOffset,4}  = 'Total';
            asCell{dLineOffset,5}  = 'Mean';
            asCell{dLineOffset,6}  = 'Min';
            asCell{dLineOffset,7}  = 'Max';
            asCell{dLineOffset,8}  = 'Median';
            asCell{dLineOffset,9}  = 'Deviation';
            asCell{dLineOffset,10} = 'Peak';
            asCell{dLineOffset,11} = 'Max XY cm';
            asCell{dLineOffset,12} = 'Max CY cm';
            asCell{dLineOffset,13} = 'Area cm2';
            asCell{dLineOffset,14} = 'Max distance cm';
            asCell{dLineOffset,15} = 'Volume cm3';
            for tt=16:21
                asCell{dLineOffset,tt}  = (' ');
            end
            
            bMovementApplied = tInput(iOffset).tMovement.bMovementApplied;

            dLineOffset = dLineOffset+1;
            for rt=1:numel(atVoiRoiTag)
                dNbVois = numel(tVoiInput);
                for vv=1:dNbVois

                    if strcmp(atVoiRoiTag{rt}.Tag, tVoiInput{vv}.Tag) % Found a VOI
                       if strcmpi(tVoiInput{vv}.ObjectType, 'voi')
                           
                            if ~isempty(tVoiInput{vv}.RoisTag)

                                if dNbVois > 10
                                    if mod(vv, 5)==1 || vv == dNbVois
                                        progressBar(vv/dNbVois-0.0001, sprintf('Computing VOI %d/%d', vv, dNbVois ) );
                                    end
                                end

                                [tVoiComputed, atRoiComputed] = ...
                                    computeVoi(aInputBuffer, ...
                                               atInputMetaData, ...
                                               aDisplayBuffer, ...
                                               atMetaData, ...
                                               tVoiInput{vv}, ...
                                               tRoiInput, ...
                                               dSUVScale, ...
                                               bSUVUnit, ...
                                               bModifiedMatrix, ...
                                               bSegmented, ...
                                               bDoseKernel, ...
                                               bMovementApplied);
               
                                if ~isempty(tVoiComputed)

                                    sVoiName = tVoiInput{vv}.Label;

                                    asCell{dLineOffset,1}  = (sVoiName);
                                    asCell{dLineOffset,2}  = (' ');
                                    asCell{dLineOffset,3}  = [tVoiComputed.cells];
                                    asCell{dLineOffset,4}  = [tVoiComputed.sum];
                                    asCell{dLineOffset,5}  = [tVoiComputed.mean];
                                    asCell{dLineOffset,6}  = [tVoiComputed.min];
                                    asCell{dLineOffset,7}  = [tVoiComputed.max];
                                    asCell{dLineOffset,8}  = [tVoiComputed.median];
                                    asCell{dLineOffset,9}  = [tVoiComputed.std];
                                    asCell{dLineOffset,10} = [tVoiComputed.peak];
                                    asCell{dLineOffset,11} = (' ');
                                    asCell{dLineOffset,12} = (' ');
                                    asCell{dLineOffset,13} = (' ');
                                    if tVoiComputed.maxDistance == 0
                                        asCell{dLineOffset,14} = ('NaN');
                                    else
                                        asCell{dLineOffset,14} = [tVoiComputed.maxDistance];
                                    end                                   
                                    asCell{dLineOffset,15} = [tVoiComputed.volume];
                                    for tt=16:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end

                                    dLineOffset = dLineOffset+1;

                                    dNbTags = numel(atRoiComputed);
                                    for bb=1:dNbTags

                                        if ~isempty(atRoiComputed{bb})

                                            if dNbTags > 100
                                                 if mod(bb, 10)==1 || bb == dNbTags
                                                     progressBar( bb/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );
                                                 end
                                            end

                                            if strcmpi(atRoiComputed{bb}.Axe, 'Axe')
                                                sSliceNb = num2str(atRoiComputed{bb}.SliceNb);
                                            elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes1')
                                                sSliceNb = ['C:' num2str(atRoiComputed{bb}.SliceNb)];
                                            elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes2')
                                                sSliceNb = ['S:' num2str(atRoiComputed{bb}.SliceNb)];
                                            elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes3')
                                                sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-atRoiComputed{bb}.SliceNb+1)];
                                            end

                                            asCell{dLineOffset,1}  = (' ');
                                            asCell{dLineOffset,2}  = (sSliceNb);
                                            asCell{dLineOffset,3}  = [atRoiComputed{bb}.cells];
                                            asCell{dLineOffset,4}  = [atRoiComputed{bb}.sum];
                                            asCell{dLineOffset,5}  = [atRoiComputed{bb}.mean];
                                            asCell{dLineOffset,6}  = [atRoiComputed{bb}.min];
                                            asCell{dLineOffset,7}  = [atRoiComputed{bb}.max];
                                            asCell{dLineOffset,8}  = [atRoiComputed{bb}.median];
                                            asCell{dLineOffset,9}  = [atRoiComputed{bb}.std];
                                            asCell{dLineOffset,10} = [atRoiComputed{bb}.peak];
                                            if ~isempty(atRoiComputed{bb}.MaxDistances)
                                                if atRoiComputed{bb}.MaxDistances.MaxXY.Length == 0
                                                    asCell{dLineOffset, 11} = ('NaN');
                                                else
                                                    asCell{dLineOffset, 11} = [atRoiComputed{bb}.MaxDistances.MaxXY.Length];
                                                end
                
                                                if atRoiComputed{bb}.MaxDistances.MaxCY.Length == 0
                                                    asCell{dLineOffset, 12} = ('NaN');
                                                else
                                                    asCell{dLineOffset, 12} = [atRoiComputed{bb}.MaxDistances.MaxCY.Length];
                                                end
                                            else
                                                asCell{dLineOffset,11} = (' ');
                                                asCell{dLineOffset,12} = (' ');
                                            end
                                            asCell{dLineOffset,13} = [atRoiComputed{bb}.area];
                                            asCell{dLineOffset,14} = (' ');
                                            asCell{dLineOffset,15} = (' ');
                                            
                                            for tt=16:21
                                                asCell{dLineOffset,tt}  = (' ');
                                            end

                                            dLineOffset = dLineOffset+1;
                                        end
                                    end
                                end
                            end
                       end
                    end
                end

               dNbRois = numel(tRoiInput);
                for bb=1:dNbRois

                    if strcmp(atVoiRoiTag{rt}.Tag, tRoiInput{bb}.Tag)  % Found a ROI
                        if ~strcmpi(tRoiInput{bb}.ObjectType, 'voi')

                            if dNbRois > 100
                                if mod(bb, 10)==1 || bb == dNbRois
                                    progressBar( bb/dNbRois-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbRois) );
                                end
                            end
                            
                            if isvalid(tRoiInput{bb}.Object)

                                tRoiComputed = ...
                                    computeRoi(aInputBuffer, ...
                                               atInputMetaData, ...
                                               aDisplayBuffer, ...
                                               atMetaData, ...
                                               tRoiInput{bb}, ...
                                               dSUVScale, ...
                                               bModifiedMatrix, ...
                                               bSUVUnit, ...
                                               bSegmented, ...
                                               bDoseKernel, ...
                                               bMovementApplied);

                                sRoiName = tRoiInput{bb}.Label;

                                if strcmpi(tRoiInput{bb}.Axe, 'Axe')
                                    sSliceNb = num2str(tRoiInput{bb}.SliceNb);
                                elseif strcmpi(tRoiInput{bb}.Axe, 'Axes1')
                                    sSliceNb = ['C:' num2str(tRoiInput{bb}.SliceNb)];
                                elseif strcmpi(tRoiInput{bb}.Axe, 'Axes2')
                                    sSliceNb = ['S:' num2str(tRoiInput{bb}.SliceNb)];
                                elseif strcmpi(tRoiInput{bb}.Axe, 'Axes3')
                                    sSliceNb = ['A:' num2str(size(dicomBuffer('get', [], iOffset), 3)-tRoiInput{bb}.SliceNb+1)];
                                end

                                asCell{dLineOffset, 1}  = (sRoiName);
                                asCell{dLineOffset, 2}  = (sSliceNb);
                                asCell{dLineOffset, 3}  = [tRoiComputed.cells];
                                asCell{dLineOffset, 4}  = [tRoiComputed.sum];
                                asCell{dLineOffset, 5}  = [tRoiComputed.mean];
                                asCell{dLineOffset, 6}  = [tRoiComputed.min];
                                asCell{dLineOffset, 7}  = [tRoiComputed.max];
                                asCell{dLineOffset, 8}  = [tRoiComputed.median];
                                asCell{dLineOffset, 9}  = [tRoiComputed.std];
                                asCell{dLineOffset, 10} = [tRoiComputed.peak];
                                if ~isempty(tRoiComputed.MaxDistances)
                                    if tRoiComputed.MaxDistances.MaxXY.Length == 0
                                        asCell{dLineOffset, 11} = ('NaN');
                                    else
                                        asCell{dLineOffset, 11} = [tRoiComputed.MaxDistances.MaxXY.Length];
                                    end
    
                                    if tRoiComputed.MaxDistances.MaxCY.Length == 0
                                        asCell{dLineOffset, 12} = ('NaN');
                                    else
                                        asCell{dLineOffset, 12} = [tRoiComputed.MaxDistances.MaxCY.Length];
                                    end
                                else
                                    asCell{dLineOffset, 11} = (' ');
                                    asCell{dLineOffset, 12} = (' ');
                                end
                                asCell{dLineOffset, 13} = tRoiComputed.area;
                                asCell{dLineOffset, 14} = (' ');
                                asCell{dLineOffset, 15} = (' ');
                                
                                for tt=16:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end

                                dLineOffset = dLineOffset+1;
                            end
                        end
                    end
                end
            end
            
            progressBar( 0.99, sprintf('Writing file %s, please wait', file) );

            % Blank line

            for bl=1:21
                asCell{dLineOffset,bl}  = (' ');
            end

            dLineOffset = dLineOffset+1;

            for pp=1:numel(gtxtRoiList)

                ptrPlotCummulative = gtxtRoiList{pp}.UserData;

                % Object name

                asCell{dLineOffset,1}  = (gtxtRoiList{pp}.String);

                dLineOffset = dLineOffset+1;

                % XYData

                asCell{dLineOffset,1}    = ('XData');
                asCell{dLineOffset+1,1}  = ('YData');

                dNbElements = numel(ptrPlotCummulative.XData);
                if dNbElements >= 20
                    asCell{dLineOffset,2}  = (ptrPlotCummulative.XData(1));
                    asCell{dLineOffset,21} = (ptrPlotCummulative.XData(end));

                    asCell{dLineOffset+1,2}  = (ptrPlotCummulative.YData(1));
                    asCell{dLineOffset+1,21} = (ptrPlotCummulative.YData(end));

                    dOffsetValue = dNbElements/20;
                    for jj=2:19
                        asCell{dLineOffset  ,jj+1} =  (ptrPlotCummulative.XData(round(jj*dOffsetValue)));
                        asCell{dLineOffset+1,jj+1} =  (ptrPlotCummulative.YData(round(jj*dOffsetValue)));
                    end
                else
                    for kk=1:dNbElements
                        asCell{dLineOffset  ,kk+1} =  (ptrPlotCummulative.XData(kk));
                        asCell{dLineOffset+1,kk+1} =  (ptrPlotCummulative.YData(kk));
                    end

                    for bb=dNbElements:21
                        asCell{dLineOffset  , bb+1} =  (' ');
                        asCell{dLineOffset+1, bb+1} =  (' ');
                    end
                end

                dLineOffset = dLineOffset+2;

                % Blank line

                for bl=1:21
                    asCell{dLineOffset,bl} = (' ');
                end

                dLineOffset = dLineOffset+1;
            end

            if numel(gtxtRoiList)

                ptrPlotCummulative = gtxtRoiList{1}.UserData;

                % XYLimits

                asCell{dLineOffset  ,1}  = ('XLimits');
                asCell{dLineOffset+1,1}  = ('YLimits');

                asCell{dLineOffset,  2}  = (ptrPlotCummulative.Parent.XLim(1));
                asCell{dLineOffset+1,2}  = (ptrPlotCummulative.Parent.YLim(1));
                asCell{dLineOffset,  3}  = (ptrPlotCummulative.Parent.XLim(2));
                asCell{dLineOffset+1,3}  = (ptrPlotCummulative.Parent.YLim(2));
                for xy=4:21
                    asCell{dLineOffset  ,xy} = (' ');
                    asCell{dLineOffset+1,xy} = (' ');
                end
            end

            cell2csv(sprintf('%s%s', path, file), asCell, ',');

            if bExcelInstance == true
                winopen(sprintf('%s%s', path, file));
            end

            progressBar(1, sprintf('Write %s%s completed', path, file));

      %      catch
      %          progressBar(1, 'Error: exportCurrentMultiplePlotCallback()');
      %       end

            clear aDisplayBuffer;
            clear aInput;

            set(figRoiMultiplePlot, 'Pointer', 'default');
            drawnow;
        end

    end

end
