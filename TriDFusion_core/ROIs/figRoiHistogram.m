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
    
    paAxeBackgroundColor = viewerAxesColor('get');
    
    ptrHist = '';
    ptrPlotCummulative = '';
    ptrPlotProfile = '';

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

    mHistogram = uimenu(mHistOptions,'Label', 'Bar Histogram', 'Checked',sHistogramOption, 'Callback', @histogramTypeCallback);

    if cummulativeMenuOption('get') == true
        sCummulativeOption = 'on';
    else
        sCummulativeOption = 'off';
    end

    mCummulative = uimenu(mHistOptions,'Label', 'Cummulative DVH', 'Checked',sCummulativeOption, 'Callback', @histogramTypeCallback);

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

%    mHistTools = uimenu(figRoiHistogramWindow,'Label','Data Cursor');
%    uimenu(mHistTools, 'Label','Data Cursor', 'Checked', 'on', 'Callback', @setHistogramDataCursorCallback);

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
            axeHistogram.Title.String  = ['Volume Bar Histogram - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Region Bar Histogram - ' ptrObject.Label];
        end
        axeHistogram.Title.Color = viewerForegroundColor('get');
        axeHistogram.Color = paAxeBackgroundColor;

    elseif cummulativeMenuOption('get') == true

        set(edtBinsValue, 'String', num2str(dInitialBarWidth));
        set(txtBins, 'String', 'Bar Width');

        dLastSliderValue = 0;
        set(sliBins, 'Value', 0);     
        

      %      aXSum = cumsum(imCDataMasked, 'reverse');
      %      aYSum = 1:1:numel(imCDataMasked);
      
        try
            ptrPlotCummulative = plotCummulative(axeHistogram, imCDataMasked, ptrObject.Color);
        
            set(axeHistogram, 'XLim', [min(double(imCDataMasked),[],'all') max(double(imCDataMasked),[],'all')]);
            set(axeHistogram, 'YLim', [0 1]);
        catch
            ptrPlotCummulative = '';
        end
        
%        try
%            ptrBar = bar(axeHistogram, aXSum, aYSum, dInitialBarWidth, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
%        catch
%            ptrBar = '';
%        end
%        ptrLine = line(axeHistogram, aXSum, aYSum, 'Color', ptrObject.Color);
        
        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');
        
        axeHistogram.XLabel.String = 'Intensity';
        axeHistogram.YLabel.String = 'Probability';
        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Cummulative DVH Volume - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Cummulative DVH Region - ' ptrObject.Label];
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
        ptrPlotProfile = plot(axeHistogram, aProfile);
        set(ptrPlotProfile, 'Color', ptrObject.Color);
        
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
            sTitle = [sType ' Bar Histogram'];
        elseif cummulativeMenuOption('get') == true
            sTitle = ['Cummulative DVH' sType];
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

        if strcmpi(get(hObject, 'Label'), 'Cummulative DVH')

            if ~isempty(ptrHist)
                delete(ptrHist);
                ptrHist = '';
            end

            if ~isempty(ptrPlotProfile)
                delete(ptrPlotProfile);
                ptrPlotProfile = '';
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

       %     [counts, bins] = histcounts(imCDataMasked);
        %    cdf = cumsum(counts);           
            

      %      aXSum = cumsum(imCDataMasked, 'reverse');
      %      aYSum = 1:1:numel(imCDataMasked);
            try
                ptrPlotCummulative = plotCummulative(axeHistogram, imCDataMasked, ptrObject.Color);

                set(axeHistogram, 'XLim', [min(double(imCDataMasked),[],'all') max(double(imCDataMasked),[],'all')]);
                set(axeHistogram, 'YLim', [0 1]);
            catch
                ptrPlotCummulative = '';
            end
           
%            try
%                ptrBar = bar(axeHistogram, aXSum, aYSum, dInitialBarWidth, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);
%            catch
%                ptrBar = '';
%            end

      %      ptrLine = line(axeHistogram, aXSum, aYSum, 'Color', ptrObject.Color);
            
            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');
        
            axeHistogram.XLabel.String = 'Intensity';
            axeHistogram.YLabel.String = 'Probability';
            if strcmpi(ptrObject.ObjectType, 'voi')
                axeHistogram.Title.String  = ['Cummulative DVH Volume - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Cummulative DVH Region - ' ptrObject.Label];
            end
            axeHistogram.Title.Color = viewerForegroundColor('get');
            axeHistogram.Color = paAxeBackgroundColor;

            set(sliBins     , 'Visible', 'off');
            set(txtBins     , 'Visible', 'off');
            set(edtBinsValue, 'Visible', 'off');

        elseif strcmpi(get(hObject, 'Label'), 'Bar Histogram')

            if ~isempty(ptrPlotCummulative)
                delete(ptrPlotCummulative);
                ptrPlotCummulative = '';
            end

            if ~isempty(ptrPlotProfile)
                delete(ptrPlotProfile);
                ptrPlotProfile = '';
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
                axeHistogram.Title.String  = ['Volume Bar Histogram - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Region Bar Histogram - ' ptrObject.Label];
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

            if ~isempty(ptrPlotCummulative)
                delete(ptrPlotCummulative);
                ptrPlotCummulative = '';
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
            ptrPlotProfile = plot(axeHistogram, aProfile);
            set(ptrPlotProfile, 'Color', ptrObject.Color);
            
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

            try            
                matlab.io.internal.getExcelInstance;
                bUseWritecell = false; 
            catch exception %#ok<NASGU>
    %            warning(message('MATLAB:xlswrite:NoCOMServer'));
                bUseWritecell = true; 
            end   
       
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

                if bUseWritecell == true              
                    writecell(asHistHeader(:),sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A1');
                else
                    xlswrite(sprintf('%s%s', path, file), asHistHeader, 1, 'A1');
                end

                asXDataHeader{1,1} = 'XData';
                asYDataHeader{1,1} = 'YData';                
                if bUseWritecell == true              
                    writecell(asXDataHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A8');
                    writecell(asYDataHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A9');
                else                
                    xlswrite(sprintf('%s%s', path, file), asXDataHeader, 1, 'A8');
                    xlswrite(sprintf('%s%s', path, file), asYDataHeader, 1, 'A9');
                end

                if cummulativeMenuOption('get') == true && ...
                   ~isempty(ptrPlotCummulative)
                    
                    dNbElements = numel(ptrPlotCummulative.XData);
                    if dNbElements >= 10
                        aXDataToDisplay{1}  = ptrPlotCummulative.XData(1);
                        aXDataToDisplay{10} = ptrPlotCummulative.XData(10);
                       
                        aYDataToDisplay{1}  = ptrPlotCummulative.YData(1);
                        aYDataToDisplay{10} = ptrPlotCummulative.YData(10);      
                                                
                        dOffsetValue = 1;
                        for jj=2:9
                            aXDataToDisplay{jj} =  ptrPlotCummulative.XData(round(dOffsetValue+1));
                            aYDataToDisplay{jj} =  ptrPlotCummulative.YData(round(dOffsetValue+1));                          
                            dOffsetValue = dOffsetValue+1;
                        end                        
                    else 
                        aXDataToDisplay = ptrPlotCummulative.XData;
                        aYDataToDisplay = ptrPlotCummulative.YData;
                    end                              
                    
                    if bUseWritecell == true              
                        writetable(table(aXDataToDisplay), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                        writetable(table(aYDataToDisplay), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');
                    else
                        xlswrite(sprintf('%s%s', path, file), aXDataToDisplay, 1, 'B8:J8');
                        xlswrite(sprintf('%s%s', path, file), aYDataToDisplay, 1, 'B9:J9');     
                    end
                    
                    asXLimitsHeader{1,1} = 'XLimits';
                    if bUseWritecell == true                                  
                        writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                        writetable(table(ptrPlotCummulative.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');
                    else                    
                        xlswrite(sprintf('%s%s', path, file), asXLimitsHeader, 1, 'A10');
                        xlswrite(sprintf('%s%s', path, file), ptrPlotCummulative.Parent.XLim, 1, 'B10:C10'); 
                    end
                    
                    asYLimitsHeader{1,1} = 'YLimits';
                    if bUseWritecell == true                                  
                        writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                        writetable(table(ptrPlotCummulative.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');
                    else
                        xlswrite(sprintf('%s%s', path, file), asYLimitsHeader, 1, 'A11');
                        xlswrite(sprintf('%s%s', path, file), ptrPlotCummulative.Parent.YLim, 1, 'B11:C11'); 
                    end                    
                   
                    if bUseWritecell == false % Need excel to copy the figure                                 
                        xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A14');                       
                    end
                    
                elseif histogramMenuOption('get') == true && ...
                       ~isempty(ptrHist)

                    for ff=1:numel(ptrHist.Values)
                        aXData{ff} = ff;
                    end
                    
                    if bUseWritecell == true                                                      
                        writetable(table(aXData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                        writetable(table(ptrHist.Values), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');
                    else                    
                        xlswrite(sprintf('%s%s', path, file), aXData, 1, 'B8');
                        xlswrite(sprintf('%s%s', path, file), ptrHist.Values, 1, 'B9');                  
                    end
                    
                    asXLimitsHeader{1,1} = 'XLimits';
                    if bUseWritecell == true                                                                          
                        writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                        writetable(table(ptrHist.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');
                    else
                        xlswrite(sprintf('%s%s', path, file), asXLimitsHeader, 1, 'A10');
                        xlswrite(sprintf('%s%s', path, file), ptrHist.Parent.XLim, 1, 'B10:C10'); 
                    end
                    
                    asYLimitsHeader{1,1} = 'YLimits';
                    if bUseWritecell == true                                                                                              
                        writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                        writetable(table(ptrHist.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');
                    else
                        xlswrite(sprintf('%s%s', path, file), asYLimitsHeader, 1, 'A11');
                        xlswrite(sprintf('%s%s', path, file), ptrHist.Parent.YLim, 1, 'B11:C11'); 
                    end
                    
                    asNbBinsHeader{1,1} = 'Number of Bins';
                    if bUseWritecell == true                                                                                                                  
                        writecell(asNbBinsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A12');
                        writetable(table(ptrHist.NumBins), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B12');
                    else
                        xlswrite(sprintf('%s%s', path, file), asNbBinsHeader, 1, 'A12');
                        xlswrite(sprintf('%s%s', path, file), ptrHist.NumBins, 1, 'B12'); 
                    end
                    
                    asBinWidthHeader{1,1} = 'Bin Width';
                    if bUseWritecell == true                                                                                                                                      
                        writecell(asBinWidthHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A13');
                        writetable(table(ptrHist.BinWidth), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B13');
                    else
                        xlswrite(sprintf('%s%s', path, file), asBinWidthHeader, 1, 'A13');
                        xlswrite(sprintf('%s%s', path, file), ptrHist.BinWidth, 1, 'B13'); 
                    end
                    
                    if bUseWritecell == false % Need excel to copy the figure                                 
                        xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A15');
                    end
                     
                else
                    if ~isempty(ptrPlotProfile)
                        if bUseWritecell == true                                                                                                                                      
                            writetable(table(ptrPlotProfile.XData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B8');
                            writetable(table(ptrPlotProfile.YData), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B9');
                        else
                            xlswrite(sprintf('%s%s', path, file), ptrPlotProfile.XData, 1, 'B8');
                            xlswrite(sprintf('%s%s', path, file), ptrPlotProfile.YData, 1, 'B9');  
                        end
                        
                        asXLimitsHeader{1,1} = 'XLimits';
                        if bUseWritecell == true                                                                                                                                                              
                            writecell(asXLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A10');
                            writetable(table(ptrPlotProfile.Parent.XLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B10');
                        else
                            xlswrite(sprintf('%s%s', path, file), asXLimitsHeader, 1, 'A10');
                            xlswrite(sprintf('%s%s', path, file), ptrPlotProfile.Parent.XLim, 1, 'B10:C10'); 
                        end
                    
                        asYLimitsHeader{1,1} = 'YLimits';
                        if bUseWritecell == true                                                                                                                                                              
                            writecell(asYLimitsHeader,sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A11');
                            writetable(table(ptrPlotProfile.Parent.YLim), sprintf('%s%s', path, file), 'WriteVariableNames', false, 'Sheet', 1, 'Range', 'B11');
                        else
                            xlswrite(sprintf('%s%s', path, file), asYLimitsHeader, 1, 'A11');
                            xlswrite(sprintf('%s%s', path, file), ptrPlotProfile.Parent.YLim, 1, 'B11:C11'); 
                        end
                        
                        if bUseWritecell == false % Need excel to copy the figure                                 
                            xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', 'A13');                          
                        end
                        
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

    end

end
