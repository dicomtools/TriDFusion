function figRoiHistogram(ptrObject, bSUVUnit, bDoseKernel, bSegmented, dSubtraction)
%function figRoiHistogram(ptrObject, bSUVUnit, bDoseKernel, bSegmented, dSubtraction)
%Figure ROI Histogram Main Function.
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
    
    paAxeBackgroundColor = [0 0 0];
    
    ptrBar  = '';
    ptrHist = '';
    ptrLine = '';
    ptrPlot = '';

    dLastSliderValue = '';
    dInitialBinsValue = 256;
    dInitialBarWidth  = 1;

    HIST_PANEL_X = 840;
    HIST_PANEL_y = 480;

    figRoiHistogramWindow = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-HIST_PANEL_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-HIST_PANEL_y/2) ...
               HIST_PANEL_X ...
               HIST_PANEL_y],...
               'Name', ' ',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Color', viewerBackgroundColor('get'), ...
               'Toolbar','none'...
               );

    setHistFigureName();

    mHistFile = uimenu(figRoiHistogramWindow,'Label','File');
    uimenu(mHistFile,'Label', 'Export to Excel...','Callback', @exportCurrentHistogramCallback);
    uimenu(mHistFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mHistOptions = uimenu(figRoiHistogramWindow,'Label','Options');

    if histogramMenuOption('get') == true
        sHistogramOption = 'on';
    else
        sHistogramOption = 'off';
    end

    mHistogram = uimenu(mHistOptions,'Label', 'Histogram', 'Checked',sHistogramOption, 'Callback', @histogramTypeCallback);

    if cummulativeMenuOption('get') == true
        sCummulativeOption = 'on';
    else
        sCummulativeOption = 'off';
    end

    mCummulative = uimenu(mHistOptions,'Label', 'Cummulative', 'Checked',sCummulativeOption, 'Callback', @histogramTypeCallback);

    if profileMenuOption('get') == true
        sProfileOption = 'on';
    else
        sProfileOption = 'off';
    end

    mProfile = uimenu(mHistOptions,'Label', 'Profile', 'Checked',sProfileOption, 'Callback', @histogramTypeCallback);
    if isfield(ptrObject, 'Type')
        if ~strcmpi(ptrObject.Type, 'images.roi.line')
            set(mProfile, 'Visible', 'off');
        end
    else
        set(mProfile, 'Visible', 'off');
    end

    mHistTools = uimenu(figRoiHistogramWindow,'Label','Data Cursor');
    uimenu(mHistTools, 'Label','Data Cursor', 'Checked', 'on', 'Callback', @setHistogramDataCursorCallback);

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(figRoiHistogramWindow, 'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

    axeHistogram = ...
        axes(figRoiHistogramWindow, ...
             'Units'   , 'pixels', ...
             'Position', [60 60 HIST_PANEL_X-130 HIST_PANEL_y-90], ...
             'Color'   , paAxeBackgroundColor,...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'on'...             
             );
        
    sliBins = ...
        uicontrol(figRoiHistogramWindow, ...
                  'Style'   , 'Slider', ...
                  'Position', [HIST_PANEL_X-60 110 20 HIST_PANEL_y-140], ...
                  'Value'   , 0.5, ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @sliderBinsCallback ...
                  );
     addlistener(sliBins,'Value','PreSet',@sliderBinsCallback);

     txtBins = ...
        uicontrol(figRoiHistogramWindow,...
                  'style'   , 'text',...
                  'string'  , 'Bin Counts',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                  
                  'position', [HIST_PANEL_X-60 80 60 20]...
                  );

     edtBinsValue = ...
        uicontrol(figRoiHistogramWindow,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , 256,...
                  'position'  , [HIST_PANEL_X-60 60 50 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'CallBack', @editBinsCallback ...
                  );

    [imCData, logicalMask] = computeHistogram(dicomBuffer('get'), atRoiVoiMetaData, ptrObject, tRoiInput, dSUVScale, bSUVUnit);
    if bSegmented == true
        imCDataMasked = imCData(logicalMask);
        imCDataMasked = imCDataMasked(imCDataMasked>cropValue('get'));
    else
        imCDataMasked = imCData(logicalMask);
    end

    if histogramMenuOption('get') == true

        ptrHist = histogram(axeHistogram, imCDataMasked, dInitialBinsValue, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
        
        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');

        axeHistogram.XLabel.String = 'Intensity';
        axeHistogram.YLabel.String = 'Frequency';
        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Volume Histogram - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Region Histogram - ' ptrObject.Label];
        end
        axeHistogram.Title.Color = viewerForegroundColor('get');
        axeHistogram.Color = paAxeBackgroundColor;

    elseif cummulativeMenuOption('get') == true

        set(edtBinsValue, 'String', num2str(dInitialBarWidth));
        set(txtBins, 'String', 'Bar Width');

        dLastSliderValue = 0;
        set(sliBins, 'Value', 0);

        aXSum = cumsum(imCDataMasked, 'reverse');
        aYSum = 1:1:numel(imCDataMasked);

        try
            ptrBar = bar(axeHistogram, aXSum, aYSum, dInitialBarWidth, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
        catch
            ptrBar = '';
        end
        ptrLine = line(axeHistogram, aXSum, aYSum, 'Color', ptrObject.Color);
        
        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');
        
        axeHistogram.XLabel.String = 'Intensity (dose)';
        axeHistogram.YLabel.String = 'Volume (cells)';
        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Cummulative Volume - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Cummulative Region - ' ptrObject.Label];
        end
        axeHistogram.Title.Color = viewerForegroundColor('get');
        axeHistogram.Color = paAxeBackgroundColor;

        set(sliBins     , 'Visible', 'off');
        set(txtBins     , 'Visible', 'off');
        set(edtBinsValue, 'Visible', 'off');
    else % profile

        set(edtBinsValue, 'String', num2str(dInitialBarWidth));
        set(txtBins, 'String', 'Bar Width');

        dLastSliderValue = 0;
        set(sliBins, 'Value', 0);

        xValues = ptrObject.Position(:,1);
        yValues = ptrObject.Position(:,2);

        aProfile = improfile(imCData, xValues, yValues);
        ptrPlot = plot(axeHistogram, aProfile);
        set(ptrPlot, 'Color', ptrObject.Color);
        
        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');
        
        axeHistogram.XLabel.String = 'cells';
        axeHistogram.YLabel.String = 'Intensity';
        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Volume Profile - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Region Profile - ' ptrObject.Label];
        end
        axeHistogram.Title.Color = viewerForegroundColor('get');
        axeHistogram.Color = paAxeBackgroundColor;

        set(sliBins     , 'Visible', 'off');
        set(txtBins     , 'Visible', 'off');
        set(edtBinsValue, 'Visible', 'off');
    end

    dcmObject = datacursormode(figRoiHistogramWindow);
    set(dcmObject, 'Enable', 'on');

    function setHistFigureName()
        
       sType = '';
       if isfield(ptrObject, 'Type')
            if strcmpi(ptrObject.Type, 'voi')
                sType = 'Volume';
            else
                sType = 'Region';
            end
       else
            if isfield(ptrObject, 'ObjectType')
                if strcmpi(ptrObject.ObjectType, 'voi')
                    sType = 'Volume';
                else
                    sType = 'Region';
                end
            end
        end

        if histogramMenuOption('get') == true
            sTitle = [sType ' Histogram'];
        elseif cummulativeMenuOption('get') == true
            sTitle = ['Cummulative ' sType];
        else
            sTitle = [sType ' Profile'];
       end

        if bSegmented == true && ...
           dSubtraction ~= 0
            sSegmented = ' - Segmented Values';
        else
            sSegmented = '';
        end

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

        figRoiHistogramWindow.Name = [sTitle ' - ' atRoiVoiMetaData{1}.SeriesDescription ' - ' sUnit sSegmented];

    end

    function histogramTypeCallback(hObject, ~)

        if strcmpi(get(hObject, 'Label'), 'Cummulative')

            if ~isempty(ptrHist)
                delete(ptrHist);
                ptrHist = '';
            end

            if ~isempty(ptrPlot)
                delete(ptrPlot);
                ptrPlot = '';
            end

            histogramMenuOption  ('set', false);
            cummulativeMenuOption('set', true );
            profileMenuOption    ('set', false);

            set(mHistogram  , 'Checked', 'off' );
            set(mCummulative, 'Checked', 'on');
            set(mProfile    , 'Checked', 'off');

            set(edtBinsValue, 'String', num2str(dInitialBarWidth));
            set(txtBins, 'String', 'Bar Width');

            dLastSliderValue = 0;
            set(sliBins, 'Value', 0);

            aXSum = cumsum(imCDataMasked, 'reverse');
            aYSum = 1:1:numel(imCDataMasked);

            try
                ptrBar = bar(axeHistogram, aXSum, aYSum, dInitialBarWidth, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
            catch
                ptrBar = '';
            end

            ptrLine = line(axeHistogram, aXSum, aYSum, 'Color', ptrObject.Color);
            
            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');
        
            axeHistogram.XLabel.String = 'Intensity (dose)';
            axeHistogram.YLabel.String = 'Volume (cells)';
            if strcmpi(ptrObject.ObjectType, 'voi')
                axeHistogram.Title.String  = ['Cummulative Volume - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Cummulative Region - ' ptrObject.Label];
            end
            axeHistogram.Title.Color = viewerForegroundColor('get');
            axeHistogram.Color = paAxeBackgroundColor;

            set(sliBins     , 'Visible', 'off');
            set(txtBins     , 'Visible', 'off');
            set(edtBinsValue, 'Visible', 'off');

        elseif strcmpi(get(hObject, 'Label'), 'Histogram')

            if ~isempty(ptrBar)
                delete(ptrBar);
                ptrBar = '';
            end

            if ~isempty(ptrLine)
                delete(ptrLine);
                ptrLine = '';
            end

            if ~isempty(ptrPlot)
                delete(ptrPlot);
                ptrPlot = '';
            end

            histogramMenuOption  ('set', true);
            cummulativeMenuOption('set', false);
            profileMenuOption    ('set', false);

            set(mHistogram  , 'Checked', 'on' );
            set(mCummulative, 'Checked', 'off');
            set(mProfile    , 'Checked', 'off');

            set(hObject, 'Checked', 'on');

            set(edtBinsValue, 'String', num2str(dInitialBinsValue));
            set(txtBins, 'String', 'Bin Counts');

            dLastSliderValue = 0.5;
            set(sliBins, 'Value', 0.5);

            ptrHist = histogram(axeHistogram, imCDataMasked, dInitialBinsValue, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
            
            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');
            
            axeHistogram.XLabel.String = 'Intensity';
            axeHistogram.YLabel.String = 'Frequency';
            if strcmpi(ptrObject.ObjectType, 'voi')
                axeHistogram.Title.String  = ['Volume Histogram - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Region Histogram - ' ptrObject.Label];
            end
            axeHistogram.Title.Color = viewerForegroundColor('get');
            axeHistogram.Color = paAxeBackgroundColor;

            set(sliBins     , 'Visible', 'on');
            set(txtBins     , 'Visible', 'on');
            set(edtBinsValue, 'Visible', 'on');

        else % Profile

            if ~isempty(ptrHist)
                delete(ptrHist);
                ptrHist = '';
            end

            if ~isempty(ptrBar)
                delete(ptrBar);
                ptrBar = '';
            end

            if ~isempty(ptrLine)
                delete(ptrLine);
                ptrLine = '';
            end

            histogramMenuOption  ('set', false);
            cummulativeMenuOption('set', false);
            profileMenuOption    ('set', true);

            set(mHistogram  , 'Checked', 'off' );
            set(mCummulative, 'Checked', 'off');
            set(mProfile    , 'Checked', 'on');

            dLastSliderValue = 0;
            set(sliBins, 'Value', 0);

            xValues = ptrObject.Position(:,1);
            yValues = ptrObject.Position(:,2);

            aProfile = improfile(imCData, xValues, yValues);
            ptrPlot = plot(axeHistogram, aProfile);
            set(ptrPlot, 'Color', ptrObject.Color);
            
            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');
            
            axeHistogram.XLabel.String = 'Cells';
            axeHistogram.YLabel.String = 'Intensity';
            if strcmpi(ptrObject.ObjectType, 'voi')
                axeHistogram.Title.String  = ['Volume Profile - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Region Profile - ' ptrObject.Label];
            end
            axeHistogram.Title.Color = viewerForegroundColor('get');
            axeHistogram.Color = paAxeBackgroundColor;

            set(sliBins     , 'Visible', 'off');
            set(txtBins     , 'Visible', 'off');
            set(edtBinsValue, 'Visible', 'off');
        end

        setHistFigureName();

    end

    function setHistogramDataCursorCallback(hObject, ~)

        if strcmpi(hObject.Checked, 'off')
            set(hObject, 'Checked', 'on');
            set(dcmObject, 'Enable', 'on');
        else
            set(hObject, 'Checked', 'off');
            set(dcmObject, 'Enable', 'off');
        end
    end

    function sliderBinsCallback(~, ~)

        dSliderValue = get(sliBins,'Value');

        if ~isempty(ptrHist)

     %       if dSliderValue > dLastSliderValue
     %           dNumBins = ptrHist.NumBins + 6;
     %       else
     %           if ptrHist.NumBins - 6 > 0
     %               dNumBins = ptrHist.NumBins - 6;
     %           else
     %               dNumBins = ptrHist.NumBins;
     %           end
     %       end
            dNumBins = round((dInitialBinsValue*2)*dSliderValue);
            if dNumBins == 0
                dNumBins =1;
            end
            ptrHist.NumBins = dNumBins;

            set(edtBinsValue, 'String', num2str(dNumBins));

        end

        if ~isempty(ptrBar) % Cummulative histogram

            dBarWidth = round((dInitialBinsValue*2)*dSliderValue);
            if dBarWidth == 0
                dBarWidth =1;
            end
            ptrBar.BarWidth = dBarWidth;

            set(edtBinsValue, 'String', num2str(dBarWidth));

        end

        dLastSliderValue = dSliderValue;

    end

    function editBinsCallback(hObject, ~)

        dEditValue = round(str2double(get(hObject, 'String')));
        if dEditValue <= 0
            dEditValue = 1;
            set(hObject, 'String', num2str(dEditValue));
        end

        if histogramMenuOption('get') == true && ...
           ~isempty(ptrHist)

            dInitialBinsValue = dEditValue;
            ptrHist.NumBins = dEditValue;

            set(sliBins, 'Value', 0.5);

        end

    end

    function exportCurrentHistogramCallback(~, ~)

        if histogramMenuOption('get')   == true || ...
           cummulativeMenuOption('get') == true || ...
           profileMenuOption('get')     == true

            filter = {'*.xlsx'};
            info = dicomMetaData('get');

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

            [file, path] = uiputfile(filter, 'Save Histogram result', sprintf('%s/%s_%s_%s_histogram_TriDFusion.xlsx' , ...
                sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription)) );

            if file ~= 0
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

                asHistHeader{1,1} = sprintf('Patient Name: %s', info{1}.PatientName);
                asHistHeader{2,1} = sprintf('Patient ID: %s', info{1}.PatientID);
                asHistHeader{3,1} = sprintf('Series Description: %s', info{1}.SeriesDescription);
                asHistHeader{4,1} = sprintf('Accession Number: %s', info{1}.AccessionNumber);
                asHistHeader{5,1} = sprintf('Series Date: %s', info{1}.SeriesDate);
                asHistHeader{6,1} = sprintf('Series Time: %s', info{1}.SeriesTime);

                writecell(asHistHeader(:),sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A1');

                asXDataHeader{1,1} = 'XData';
                asYDataHeader{1,1} = 'YData';

                writecell(asXDataHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A8');
                writecell(asYDataHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A9');

                if cummulativeMenuOption('get') == true && ...
                   ~isempty(ptrBar)

                    writetable(table(ptrBar.XData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                    writetable(table(ptrBar.YData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');

                    asXLimitsHeader{1,1} = 'XLimits';
                    writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                    writetable(table(ptrBar.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');

                    asYLimitsHeader{1,1} = 'YLimits';
                    writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                    writetable(table(ptrBar.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');

                    asBarWidthHeader{1,1} = 'Bar Width';
                    writecell(asBarWidthHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A12');
                    writetable(table(ptrBar.BarWidth), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B12');

                    xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A14');
                elseif histogramMenuOption('get') == true && ...
                       ~isempty(ptrHist)

                    for ff=1:numel(ptrHist.Values)
                        aXData{ff} = ff;
                    end

                     writetable(table(aXData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                     writetable(table(ptrHist.Values), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');

                     asXLimitsHeader{1,1} = 'XLimits';
                     writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                     writetable(table(ptrHist.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');

                     asYLimitsHeader{1,1} = 'YLimits';
                     writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                     writetable(table(ptrHist.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');

                     asNbBinsHeader{1,1} = 'Number of Bins';
                     writecell(asNbBinsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A12');
                     writetable(table(ptrHist.NumBins), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B12');

                     asBinWidthHeader{1,1} = 'Bin Width';
                     writecell(asBinWidthHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A13');
                     writetable(table(ptrHist.BinWidth), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B13');

                     xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A15');
                else
                    if ~isempty(ptrPlot)

                        writetable(table(ptrPlot.XData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                        writetable(table(ptrPlot.YData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');

                        asXLimitsHeader{1,1} = 'XLimits';
                        writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                        writetable(table(ptrPlot.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');

                        asYLimitsHeader{1,1} = 'YLimits';
                        writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                        writetable(table(ptrPlot.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');

                        xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A13');
                    end
                end

                winopen(sprintf('%s%s', path, file));

                try
                    saveHistLastUsedDir = path;
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

                progressBar(1, sprintf('Write %s%s completed', path, file));

            end
        end

        function xlswritefig(hFig,filename,sheetname,xlcell)

            if nargin==0 || isempty(hFig)
                hFig = gcf;
            end

            if nargin<2 || isempty(filename)
                filename ='';
                dontsave = true;
            else
                dontsave = false;

                % Create full file name with path
                filename = fullfilename(filename);
            end

            if nargin < 3 || isempty(sheetname)
                sheetname = 'Sheet1';
            end

            if nargin<4
                xlcell = 'A1';
            end

            % Put figure in clipboard
            % New graphics system in R2014b changed the default renderer from painters
            % to opengl, which impacts figure export. Manually setting to Painters
            % seems to work pretty well.
            r = get(hFig,'Renderer');
            set(hFig,'Renderer','Painters')
            drawnow
            hgexport(hFig,'-clipboard')
            set(hFig,'Renderer',r)
            % Open Excel, add workbook, change active worksheet,
            % get/put array, save.
            % First, open an Excel Server.
            Excel = actxserver('Excel.Application');
            % Two cases:
            % * Open a new workbook, save with given file name
            % * Open an existing workbook
            if exist(filename,'file')==0
                % The following case if file does not exist (Creating New File)
                op = invoke(Excel.Workbooks,'Add');
                %     invoke(op, 'SaveAs', [pwd filesep filename]);
                new=1;
            else
                % The following case if file does exist (Opening File)
                %     disp(['Opening Excel File ...(' filename ')']);
                op = invoke(Excel.Workbooks, 'open', filename);
                new=0;
            end

            % set(Excel, 'Visible', 0);
            % Make the specified sheet active.
            try
                Sheets = Excel.ActiveWorkBook.Sheets;
                target_sheet = get(Sheets, 'Item', sheetname);
            catch %#ok<CTCH>   Suppress so that this function works in releases without MException
                % Add the sheet if it doesn't exist
                target_sheet = Excel.ActiveWorkBook.Worksheets.Add();
                target_sheet.Name = sheetname;
            end

            invoke(target_sheet, 'Activate');
            Activesheet = Excel.Activesheet;
            % Paste to specified cell
            Paste(Activesheet,get(Activesheet,'Range',xlcell,xlcell))
            % Save and clean up
            if new && ~dontsave
                invoke(op, 'SaveAs', filename);
            elseif ~new
                invoke(op, 'Save');
            else  % New, but don't save
                set(Excel, 'Visible', 1);
                return  % Bail out before quitting Excel
            end

            invoke(Excel, 'Quit');
            delete(Excel)
        end

        function filename = fullfilename(filename)
            [filepath, filename, fileext] = fileparts(filename);
            if isempty(filepath)
                filepath = pwd;
            end
            if isempty(fileext)
                fileext = '.xlsx';
            end
            filename = fullfile(filepath, [filename fileext]);
        end

    end

end
