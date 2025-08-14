function figRoiHistogram(aInputBuffer, atInputMetaData, ptrObject, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied, bSimplified)
%function figRoiHistogram(aInputBuffer, atInputMetaData, ptrObject, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied, bSimplified)
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

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atRoiInput       = roiTemplate('get', dSeriesOffset);
    atVoiInput       = voiTemplate('get', dSeriesOffset);
    atRoiVoiMetaData = dicomMetaData('get', [], dSeriesOffset);
    aDisplayBuffer   = dicomBuffer('get', [], dSeriesOffset);
    
    bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

    if bModifiedMatrix  == false && ... 
       bSegmented       == false && ...
       bMovementApplied == false % Can't use input buffer if movement have been applied

        if numel(aInputBuffer) ~= ...
           numel(aDisplayBuffer)

            [atRoiInput, atVoiInput] = resampleROIs(aDisplayBuffer, atRoiVoiMetaData, aInputBuffer, atInputMetaData, atRoiInput, false, atVoiInput, dSeriesOffset);
        end
    end

    tQuant = quantificationTemplate('get');
    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    paAxeBackgroundColor = viewerAxesColor('get');

    ptrHist = '';
    ptrPlotCummulative = '';
    ptrPlotProfile = '';

    dInitialBinsValue = 256;
    dInitialBarWidth  = 1;

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    FIG_HIST_Y = ySize*0.75;
    FIG_HIST_X = FIG_HIST_Y*0.85;

    if viewerUIFigure('get') == true

        figRoiHistogramWindow = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_HIST_X/2) ...
                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_HIST_Y/2) ...
                    FIG_HIST_X ...
                    FIG_HIST_Y],...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'Name' , ' '...
                   );
    else
        figRoiHistogramWindow = ...
            figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_HIST_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_HIST_Y/2) ...
                    FIG_HIST_X ...
                    FIG_HIST_Y],...
                   'Name', ' ',...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'), ...
                   'Toolbar','none'...
                   );
    end

    setObjectIcon(figRoiHistogramWindow);

    setHistFigureName();

    mHistFile = uimenu(figRoiHistogramWindow,'Label','File');
    uimenu(mHistFile,'Label', 'Export to .csv...','Callback', @exportCurrentHistogramCallback);
    uimenu(mHistFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mHistEdit = uimenu(figRoiHistogramWindow,'Label','Edit');
    uimenu(mHistEdit,'Label', 'Copy Display', 'Callback', @copyHistogramDisplayCallback);

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

    mCummulative = uimenu(mHistOptions,'Label', 'Cumulative DVH', 'Checked',sCummulativeOption, 'Callback', @histogramTypeCallback);

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
             'Position', [60 60 FIG_HIST_X-130 FIG_HIST_Y-90], ...
             'Color'   , paAxeBackgroundColor,...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'on'...
             );
    axeHistogram.Interactions = [];
    % axeHistogram.Toolbar.Visible = 'off';
    deleteAxesToolbar(axeHistogram);
    disableDefaultInteractivity(axeHistogram);

    sliBins = ...
        uicontrol(figRoiHistogramWindow, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_HIST_X-60 110 20 FIG_HIST_Y-140], ...
                  'Value'   , 0.5, ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Visible' , 'off',...
                  'CallBack', @sliderBinsCallback ...
                  );
%      addlistener(sliBins,'Value','PreSet',@sliderBinsCallback);
     addlistener(sliBins, 'ContinuousValueChange', @sliderBinsCallback);

     txtBins = ...
        uicontrol(figRoiHistogramWindow,...
                  'style'   , 'text',...
                  'string'  , 'Bin Counts',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Visible' , 'off',...
                  'position', [FIG_HIST_X-60 80 60 20]...
                  );

     edtBinsValue = ...
        uicontrol(figRoiHistogramWindow,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , 256,...
                  'position'  , [FIG_HIST_X-60 60 50 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Visible' , 'off',...
                  'CallBack', @editBinsCallback ...
                  );

    try

    set(figRoiWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if histogramMenuOption('get') == true

        imCData = computeHistogram(aInputBuffer, ...
                                   aDisplayBuffer, ...
                                   atRoiVoiMetaData, ...
                                   ptrObject, ...
                                   atRoiInput, ...
                                   dSUVScale, ...
                                   bSUVUnit, ...
                                   bModifiedMatrix, ...
                                   bSegmented, ...
                                   bMovementApplied);

        ptrHist = histogram(axeHistogram, ...
                            imCData, ...
                            dInitialBinsValue, ...
                            'EdgeColor', 'none', ...
                            'FaceColor', ptrObject.Color);

        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');
        % axeHistogram.Toolbar.VisibaxeHistogramle = 'off';
        disableAxesToolbar(axeHistogram);
        disableDefaultInteractivity(axeHistogram);

        if bDoseKernel == true
            axeHistogram.XLabel.String = 'Intensity (Gy)';
        else
            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                if bSUVUnit == true
                    axeHistogram.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                else
                    axeHistogram.XLabel.String = 'Intensity (BQML)';
                end
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')

                    axeHistogram.XLabel.String = 'Intensity (HU)';
                else

                    axeHistogram.XLabel.String = 'Intensity (Count)';
                end
            end
        end

        axeHistogram.YLabel.String = 'Frequency';

        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Volume Bar Histogram - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Region Bar Histogram - ' ptrObject.Label];
        end
        axeHistogram.Title.Color = viewerForegroundColor('get');
        axeHistogram.Color = paAxeBackgroundColor;

%        axeHistogram.Position(3) = axeHistogram.Parent.Position(3)-100;

        set(sliBins     , 'Visible', 'on');
        set(txtBins     , 'Visible', 'on');
        set(edtBinsValue, 'Visible', 'on');

    elseif cummulativeMenuOption('get') == true

        imCData = computeHistogram(aInputBuffer, ...
                                   aDisplayBuffer, ...
                                   atRoiVoiMetaData, ...
                                   ptrObject, ...
                                   atRoiInput, ...
                                   dSUVScale, ...
                                   bSUVUnit, ...
                                   bModifiedMatrix, ...
                                   bSegmented, ...
                                   bMovementApplied);

        set(edtBinsValue, 'String', num2str(dInitialBarWidth));
        set(txtBins, 'String', 'Bar Width');

        dLastSliderValue = 0;
        set(sliBins, 'Value', 0);


      %      aXSum = cumsum(imCData, 'reverse');
      %      aYSum = 1:1:numel(imCData);

        try
            ptrPlotCummulative = plotCummulative(axeHistogram, ...
                                                 imCData, ...
                                                 ptrObject.Color);

  %          set(axeHistogram, 'XLim', [min(double(imCData),[],'all') max(double(imCData),[],'all')]);
  %          set(axeHistogram, 'YLim', [0 1]);
        catch ME 
            logErrorToFile(ME); 
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
        % axeHistogram.Toolbar.Visible = 'off';
        disableAxesToolbar(axeHistogram);
        disableDefaultInteractivity(axeHistogram);

        if bDoseKernel == true
            axeHistogram.XLabel.String = 'Intensity (Gy)';
        else
            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                if bSUVUnit == true
                    axeHistogram.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                else
                    axeHistogram.XLabel.String = 'Intensity (BQML)';
                end
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')

                    axeHistogram.XLabel.String = 'Intensity (HU)';
                else
                   axeHistogram.XLabel.String = 'Intensity (Count)';

                end
            end
        end

        axeHistogram.YLabel.String = 'Fraction';
        if strcmpi(ptrObject.ObjectType, 'voi')
            axeHistogram.Title.String  = ['Cumulative DVH Volume - ' ptrObject.Label];
        else
            axeHistogram.Title.String  = ['Cumulative DVH Region - ' ptrObject.Label];
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

        imCData = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        if bModifiedMatrix  == false && ... 
           bSegmented       == false && ...
           bMovementApplied == false        % Can't use input buffer if movement have been applied

            % if numel(aInputBuffer) ~= numel(imCData)
            %     pTemp{1} = ptrObject;
            %     ptrRoiTemp = resampleROIs(imCData, atRoiVoiMetaData, aInputBuffer, atInputMetaData, pTemp, false);
            %     ptrObject = ptrRoiTemp{1};
            % end

            idx = find(cellfun(@(s) strcmp(s.Tag, ptrObject.Tag), atRoiInput), 1);
            if ~isempty(idx)
                ptrObject = atRoiInput{idx}; 
            end

            imCData = aInputBuffer;
        end

        if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
             strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
             strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) && ...
             bSUVUnit == true
            imCData = imCData * dSUVScale;
         end

%        if bSegmented  == true && ...
%           bModifiedMatrix == true    % Can't use original matrix

%            imCData = imCData(imCData>cropValue('get'));
%        end


        if strcmpi(ptrObject.Type, 'images.roi.rectangle')

            % Define the coordinates of the rectangle corners
            xValues = [ptrObject.Position(1), ptrObject.Position(3), ptrObject.Position(3), ptrObject.Position(1), ptrObject.Position(1)];
            yValues = [ptrObject.Position(2), ptrObject.Position(2), ptrObject.Position(4), ptrObject.Position(4), ptrObject.Position(2)];

        else
            xValues = ptrObject.Position(:,1);
            yValues = ptrObject.Position(:,2);
        end

        switch lower(ptrObject.Axe)

            case 'axe'
                imCData = imCData(:,:);

            case 'axes1'
                imCData = permute(imCData(ptrObject.SliceNb,:,:), [3 2 1]);

            case 'axes2'
                imCData = permute(imCData(:,ptrObject.SliceNb,:), [3 1 2]) ;

            case 'axes3'
                imCData  = imCData(:,:,ptrObject.SliceNb);

            otherwise
                return;
        end

        aProfile = improfile(imCData, xValues, yValues);
        ptrPlotProfile = plot(axeHistogram, aProfile);
        set(ptrPlotProfile, 'Color', ptrObject.Color);

        axeHistogram.XColor = viewerForegroundColor('get');
        axeHistogram.YColor = viewerForegroundColor('get');
        axeHistogram.ZColor = viewerForegroundColor('get');
        % axeHistogram.Toolbar.Visible = 'off';
        % delete(axeHistogram.Toolbar);
        disableAxesToolbar(axeHistogram);
        disableDefaultInteractivity(axeHistogram);

        axeHistogram.XLabel.String = 'Cells';
        if bDoseKernel == true
            axeHistogram.YLabel.String = 'Intensity (Gy)';
        else
            if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')
                axeHistogram.YLabel.String = 'Intensity (HU)';
            else
                if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                     strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                     strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                    if bSUVUnit == true
                        axeHistogram.YLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                    else
                        axeHistogram.YLabel.String = 'Intensity (BQML)';
                    end
                else
                    axeHistogram.YLabel.String = 'Intensity (Count)';
                end
            end
        end

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

    catch ME 
        logErrorToFile(ME); 
        progressBar(1, 'Error:figRoiHistogram()');
    end

    set(figRoiWindowPtr('get'), 'Pointer', 'default');
    drawnow;

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
            sTitle = ['Cumulative DVH' sType];
        else
            sTitle = [sType ' Profile'];
        end

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

             if isfield(atRoiVoiMetaData{1}, 'DoseUnits')

                if ~isempty(atRoiVoiMetaData{1}.DoseUnits)

                    sUnits = sprintf('Unit: %s', char(atRoiVoiMetaData{1}.DoseUnits));
                else
                    sUnits = 'Unit: dose';
                end
            else
                sUnits = 'Unit: dose';
            end
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

        figRoiHistogramWindow.Name = [sTitle ' - ' atRoiVoiMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented];

    end

    function copyHistogramDisplayCallback(~, ~)

        try        
            set(figRoiHistogramWindow, 'Pointer', 'watch');
            drawnow;

            copyFigureToClipboard(figRoiHistogramWindow);

        catch ME 
            logErrorToFile(ME); 
            progressBar(1, 'Error:copyHistogramDisplayCallback()');
        end

        set(figRoiHistogramWindow, 'Pointer', 'default');
        drawnow;
    end

    function histogramTypeCallback(hObject, ~)
        try

        set(figRoiHistogramWindow, 'Pointer', 'watch');
        drawnow;

        if strcmpi(get(hObject, 'Label'), 'Cumulative DVH')

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

       %     [counts, bins] = histcounts(imCData);
        %    cdf = cumsum(counts);


      %      aXSum = cumsum(imCData, 'reverse');
      %      aYSum = 1:1:numel(imCData);
            try
                ptrPlotCummulative = plotCummulative(axeHistogram, imCData, ptrObject.Color);

      %          set(axeHistogram, 'XLim', [min(double(imCData),[],'all') max(double(imCData),[],'all')]);
      %          set(axeHistogram, 'YLim', [0 1]);
            catch ME 
                logErrorToFile(ME); 
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
            % axeHistogram.Toolbar.Visible = 'off';
            disableAxesToolbar(axeHistogram);
            disableDefaultInteractivity(axeHistogram);

            if bDoseKernel == true

                if isfield(atRoiVoiMetaData{1}, 'DoseUnits')

                    if ~isempty(atRoiVoiMetaData{1}.DoseUnits)

                        sUnit = char(atRoiVoiMetaData{1}.DoseUnits);
                    else
                        sUnit = 'dose';
                    end
                else
                    sUnit = 'dose';
                end

                axeHistogram.XLabel.String = sprintf('Intensity (%s)', sUnit);
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')
                    axeHistogram.XLabel.String = 'Intensity (HU)';
                else
                    if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                         strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                         strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                        if bSUVUnit == true
                            axeHistogram.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                        else
                            axeHistogram.XLabel.String = 'Intensity (BQML)';
                        end
                    else
                        axeHistogram.XLabel.String = 'Intensity (Count)';
                    end
                end
            end

            axeHistogram.YLabel.String = 'Fraction';

            if strcmpi(ptrObject.ObjectType, 'voi')
                axeHistogram.Title.String  = ['Cumulative DVH Volume - ' ptrObject.Label];
            else
                axeHistogram.Title.String  = ['Cumulative DVH Region - ' ptrObject.Label];
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

            ptrHist = histogram(axeHistogram, imCData, dInitialBinsValue, 'EdgeColor', 'none', 'FaceColor', ptrObject.Color);

            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');

            if bDoseKernel == true

                if isfield(atRoiVoiMetaData{1}, 'DoseUnits')

                    if ~isempty(atRoiVoiMetaData{1}.DoseUnits)

                        sUnit = char(atRoiVoiMetaData{1}.DoseUnits);
                    else
                        sUnit = 'dose';
                    end
                else
                    sUnit = 'dose';
                end

                axeHistogram.XLabel.String = sprintf('Intensity (%s)', sUnit);

            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')
                    axeHistogram.XLabel.String = 'Intensity (HU)';
                else
                    if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                         strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                         strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                        if bSUVUnit == true
                            axeHistogram.XLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));

                        else
                            axeHistogram.XLabel.String = 'Intensity (BQML)';
                        end
                    else
                        axeHistogram.XLabel.String = 'Intensity (Count)';
                    end
                end
            end

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

            set(edtBinsValue, 'String', num2str(dInitialBarWidth));
            set(txtBins, 'String', 'Bar Width');

            imCData = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

            if bModifiedMatrix  == false && ... 
               bSegmented       == false && ...
               bMovementApplied == false       % Can't use input buffer if movement have been applied

                % if numel(aInputBuffer) ~= numel(imCData)
                %     pTemp{1} = ptrObject;
                %     ptrRoiTemp = resampleROIs(imCData, atRoiVoiMetaData, aInputBuffer, atInputMetaData, pTemp, false);
                %     ptrObject = ptrRoiTemp{1};
                % end

                idx = find(cellfun(@(s) strcmp(s.Tag, ptrObject.Tag), atRoiInput), 1);
                if ~isempty(idx)
                    ptrObject = atRoiInput{idx}; 
                end

                imCData = aInputBuffer;
            end

            if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                 strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                 strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) && ...
                 bSUVUnit == true
                imCData = imCData * dSUVScale;
             end

    %        if bSegmented  == true && ...
    %           bModifiedMatrix == true    % Can't use original matrix

    %            imCData = imCData(imCData>cropValue('get'));
    %        end


            if strcmpi(ptrObject.Type, 'images.roi.rectangle')

                % Define the coordinates of the rectangle corners
                xValues = [ptrObject.Position(1), ptrObject.Position(3), ptrObject.Position(3), ptrObject.Position(1), ptrObject.Position(1)];
                yValues = [ptrObject.Position(2), ptrObject.Position(2), ptrObject.Position(4), ptrObject.Position(4), ptrObject.Position(2)];

            else
                xValues = ptrObject.Position(:,1);
                yValues = ptrObject.Position(:,2);
            end

            switch lower(ptrObject.Axe)

                case 'axe'
                    imCData = imCData(:,:);

                case 'axes1'
                    imCData = permute(imCData(ptrObject.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    imCData = permute(imCData(:,ptrObject.SliceNb,:), [3 1 2]) ;

                case 'axes3'
                    imCData  = imCData(:,:,ptrObject.SliceNb);

                otherwise
                    return;
            end

            aProfile = improfile(imCData, xValues, yValues);
            ptrPlotProfile = plot(axeHistogram, aProfile);
            set(ptrPlotProfile, 'Color', ptrObject.Color);

            axeHistogram.XColor = viewerForegroundColor('get');
            axeHistogram.YColor = viewerForegroundColor('get');
            axeHistogram.ZColor = viewerForegroundColor('get');
            % axeHistogram.Toolbar.Visible = 'off';
            disableAxesToolbar(axeHistogram);
            disableDefaultInteractivity(axeHistogram);

            axeHistogram.XLabel.String = 'Cells';
            if bDoseKernel == true
                axeHistogram.YLabel.String = 'Intensity (Gy)';
            else
                if  strcmpi(atRoiVoiMetaData{1}.Modality, 'ct')
                    axeHistogram.YLabel.String = 'Intensity (HU)';
                else
                    if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
                         strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
                         strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' )

                        if bSUVUnit == true
                            axeHistogram.YLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                        else
                            axeHistogram.YLabel.String = 'Intensity (BQML)';
                        end
                    else
                        axeHistogram.YLabel.String = 'Intensity (Count)';
                    end
                end
            end

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

        catch ME 
            logErrorToFile(ME); 
            progressBar(1, 'Error:histogramTypeCallback()');
        end

        set(figRoiHistogramWindow, 'Pointer', 'default');

        drawnow;
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

            atInput = inputTemplate('get');

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            atMetaData = dicomMetaData('get', [], dSeriesOffset);

            atVoiInput = voiTemplate('get', dSeriesOffset);
            atRoiInput = roiTemplate('get', dSeriesOffset);

            if isfigVoiExpendVoi('get') == true

                bExpendedDisplay = true;
            else
                bExpendedDisplay = false;

                if ~isempty(atRoiInput)

                    if any(cellfun(@(roi) strcmpi(roi.ObjectType, 'roi'), atRoiInput))

                        bExpendedDisplay = true;
                    end
                end
            end

            aDisplayBuffer = dicomBuffer('get', [], dSeriesOffset);

            aInput = inputBuffer('get');
            if     strcmpi(imageOrientation('get'), 'axial')
                aInputBuffer = aInput{dSeriesOffset};
            elseif strcmpi(imageOrientation('get'), 'coronal')
                aInputBuffer = reorientBuffer(aInput{dSeriesOffset}, 'coronal');
            elseif strcmpi(imageOrientation('get'), 'sagittal')
                aInputBuffer = reorientBuffer(aInput{dSeriesOffset}, 'sagittal');
            end

            if size(aInputBuffer, 3) ==1

                if atInput(dSeriesOffset).bFlipLeftRight == true
                    aInputBuffer = aInputBuffer(:,end:-1:1);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aInputBuffer = aInputBuffer(end:-1:1,:);
                end
            else
                if atInput(dSeriesOffset).bFlipLeftRight == true
                    aInputBuffer = aInputBuffer(:,end:-1:1,:);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aInputBuffer = aInputBuffer(end:-1:1,:,:);
                end

                if atInput(dSeriesOffset).bFlipHeadFeet == true
                    aInputBuffer = aInputBuffer(:,:,end:-1:1);
                end
            end

            atInputMetaData = atInput(dSeriesOffset).atDicomInfo;

            bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;
    
            transM = eye(3);
    
            if bModifiedMatrix  == false && ... 
               bMovementApplied == false && ...     
               bSegmented       == false        % Can't use input buffer if movement have been applied
       
                if numel(aInputBuffer) ~= ...
                   numel(aDisplayBuffer)
    
                    [atRoiInput, atVoiInput, transM] = resampleROIs(aDisplayBuffer, atMetaData, aInputBuffer, atInputMetaData, atRoiInput, false, atVoiInput, dSeriesOffset);
                end
            end

            try
                matlab.io.internal.getExcelInstance;
                bExcelInstance = true;
            catch exception
                logErrorToFile(exception);                 
    %            warning(message('MATLAB:xlswrite:NoCOMServer'));
                bExcelInstance = false;
            end

            filter = {'*.csv'};
            info = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

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

            if     histogramMenuOption('get') == true
                sHystogramType = 'BAR_HYSTOGRAM';
            elseif cummulativeMenuOption('get') == true
                sHystogramType = 'CUMULATIVE_DVH';
            elseif profileMenuOption ('get') == true
                sHystogramType = 'PROFILE';
            else
                sHystogramType = '';
            end

 %           sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

            sSeriesDate = info{1}.SeriesDate;

            if isempty(sSeriesDate)
                sSeriesDate = '-';
            else
                sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
            end

            [file, path] = uiputfile(filter, 'Save Histogram Result', sprintf('%s/%s_%s_%s_%s_%s_TriDFusion.csv' , ...
                sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription), sSeriesDate, sHystogramType));

            if file ~= 0

                try

                set(figRoiHistogramWindow, 'Pointer', 'watch');
                drawnow;

                try
                    saveHistLastUsedDir = [path '/'];
                    save(sMatFile, 'saveHistLastUsedDir');

                catch ME 
                    logErrorToFile(ME); 
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
                if strcmpi(ptrObject.ObjectType, 'voi')

                    for aa=1:numel(atVoiInput)

                        if strcmp(ptrObject.Tag, atVoiInput{aa}.Tag) %  Found the VOI

                            if ~isempty(atVoiInput{aa}.RoisTag)

                                dNumberOfLines = dNumberOfLines+1;

                                for cc=1:numel(atVoiInput{aa}.RoisTag)
                                    for bb=1:numel(atRoiInput)
                                       if isvalid(atRoiInput{bb}.Object)
                                            if strcmpi(atVoiInput{aa}.RoisTag{cc}, atRoiInput{bb}.Tag) % Found a VOI/ROI

                                                dNumberOfLines = dNumberOfLines+1;

                                            end
                                        end
                                    end
                                end

                                break;
                            end
                        end
                    end

                else

                    for bb=1:numel(atRoiInput)

                        if strcmp(ptrObject.Tag, atRoiInput{bb}.Tag) % Found the ROI

                            dNumberOfLines = dNumberOfLines+1;

                            break;
                        end
                    end
                end

                if bDoseKernel == true

                    if isfield(atMetaData{1}, 'DoseUnits')

                        if ~isempty(atMetaData{1}.DoseUnits)

                            sUnits = char(atMetaData{1}.DoseUnits);
                        else
                            sUnits = 'dose';
                        end
                    else
                        sUnits = 'dose';
                    end
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
                asVoiRoiHeader{7} = sprintf('Unit, %s'              , sUnits);
                asVoiRoiHeader{8} = (' ');

                if bSimplified == true

                    dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader)+6; % Add header and cell description and footer to number of needed lines

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
                    asCell{dLineOffset,2}  = 'Nb Cells';
                    asCell{dLineOffset,3}  = 'Total';
                    asCell{dLineOffset,4}  = 'Sum';
                    asCell{dLineOffset,5}  = 'Mean';
                    asCell{dLineOffset,6}  = 'Min';
                    asCell{dLineOffset,7}  = 'Max';
                    asCell{dLineOffset,8}  = 'Median';
                    asCell{dLineOffset,9}  = 'Deviation';
                    asCell{dLineOffset,10} = 'Peak';
                    asCell{dLineOffset,11} = 'Max Diagomal Coronal (mm)';
                    asCell{dLineOffset,12} = 'Max Diagomal Sagittal (mm)';
                    asCell{dLineOffset,13} = 'Max Diagomal Axial (mm)';
                    asCell{dLineOffset,14} = 'Volume (cm3)';

                    for tt=15:21
                        asCell{dLineOffset,tt}  = (' ');
                    end

                    dLineOffset = dLineOffset+1;

                    bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

                    dNbVois = numel(atVoiInput);

                    for aa=1:dNbVois

                        if strcmp(ptrObject.Tag, atVoiInput{aa}.Tag)

                            if ~isempty(atVoiInput{aa}.RoisTag)

                                if dNbVois > 10
                                    if mod(aa, 5)==1 || aa == dNbVois
                                        progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                                    end
                                end

                                tMaxDistances = computeVoiPlanesFarthestPoint(atVoiInput{aa}, atRoiInput, atMetaData, aDisplayBuffer, false);

                                [tVoiComputed, ~] = ...
                                    computeVoi(aInputBuffer, ...
                                               atInputMetaData, ...
                                               aDisplayBuffer, ...
                                               atMetaData, ...
                                               atVoiInput{aa}, ...
                                               atRoiInput, ...
                                               dSUVScale, ...
                                               bSUVUnit, ...
                                               bModifiedMatrix, ...
                                               bSegmented, ...
                                               bMovementApplied, ...
                                               transM);

                                if ~isempty(tVoiComputed)

                                    sVoiName = atVoiInput{aa}.Label;

                                    asCell{dLineOffset,1}  = (sVoiName);
                                    asCell{dLineOffset,2} = [tVoiComputed.cells];
                                    asCell{dLineOffset,3} = [tVoiComputed.total];
                                    asCell{dLineOffset,4} = [tVoiComputed.sum];
                                    asCell{dLineOffset,5} = [tVoiComputed.mean];
                                    asCell{dLineOffset,6} = [tVoiComputed.min];
                                    asCell{dLineOffset,7} = [tVoiComputed.max];
                                    asCell{dLineOffset,8} = [tVoiComputed.median];
                                    asCell{dLineOffset,9} = [tVoiComputed.std];
                                    asCell{dLineOffset,10} = [tVoiComputed.peak];

                                    if isempty(tMaxDistances.Coronal)
                                        asCell{dLineOffset,11} = ('NaN');
                                    else
                                        asCell{dLineOffset,11} = [tMaxDistances.Coronal.MaxLength];
                                    end

                                    if isempty(tMaxDistances.Sagittal)
                                        asCell{dLineOffset,12} = ('NaN');
                                    else
                                        asCell{dLineOffset,12} = [tMaxDistances.Sagittal.MaxLength];
                                    end

                                    if isempty(tMaxDistances.Axial)
                                        asCell{dLineOffset,13} = ('NaN');
                                    else
                                        asCell{dLineOffset,13} = [tMaxDistances.Axial.MaxLength];
                                    end

                                    asCell{dLineOffset,14} = [tVoiComputed.volume];

                                    for tt=15:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end

                                    dLineOffset = dLineOffset+1;

                                end
                            end
                        end
                    end
                else
                    dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader)+6; % Add header and cell description and footer to number of needed lines

                    asCell = cell(dNumberOfLines, 21); % Create an empty cell array

                    dLineOffset = 1;
                    for ll=1:numel(asVoiRoiHeader)

                        asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                        for tt=2:21
                            asCell{dLineOffset,tt}  = (' ');
                        end


                        dLineOffset = dLineOffset+1;
                    end

                    if bExpendedDisplay == true

                        asCell{dLineOffset,1}  = 'Name';
                        asCell{dLineOffset,2}  = 'Image number';
                        asCell{dLineOffset,3}  = 'Nb Cells';
                        asCell{dLineOffset,4}  = 'Total';
                        asCell{dLineOffset,5}  = 'Sum';
                        asCell{dLineOffset,6}  = 'Mean';
                        asCell{dLineOffset,7}  = 'Min';
                        asCell{dLineOffset,8}  = 'Max';
                        asCell{dLineOffset,9}  = 'Median';
                        asCell{dLineOffset,10} = 'Deviation';
                        asCell{dLineOffset,11} = 'Peak';
                        asCell{dLineOffset,12} = 'Max XY (mm)';
                        asCell{dLineOffset,13} = 'Max CY (mm)';
                        asCell{dLineOffset,14} = 'Area cm2';
                        asCell{dLineOffset,15} = 'Volume (cm3)';

                        for tt=16:21
                            asCell{dLineOffset,tt}  = (' ');
                        end
                    else
                        asCell{dLineOffset,1}  = 'Name';
                        asCell{dLineOffset,2}  = 'Nb Cells';
                        asCell{dLineOffset,3}  = 'Total';
                        asCell{dLineOffset,4}  = 'Sum';
                        asCell{dLineOffset,5}  = 'Mean';
                        asCell{dLineOffset,6}  = 'Min';
                        asCell{dLineOffset,7}  = 'Max';
                        asCell{dLineOffset,8}  = 'Median';
                        asCell{dLineOffset,9} = 'Deviation';
                        asCell{dLineOffset,10} = 'Peak';
                        asCell{dLineOffset,11} = 'Volume (cm3)';

                        for tt=12:21
                            asCell{dLineOffset,tt}  = (' ');
                        end
                    end

                    dLineOffset = dLineOffset+1;

                    bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

                    dNbVois = numel(atVoiInput);

                    if strcmpi(ptrObject.ObjectType, 'voi')

                        if bExpendedDisplay == true

                            dNbRois = numel(atRoiInput);

                            for ro=1:dNbRois

                                if strcmpi(atRoiInput{ro}.ObjectType, 'voi-roi')

                                    if ~isfield(atRoiInput{ro}, 'MaxDistances')

                                        tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{ro}, false, false);

                                        atRoiInput{ro}.MaxDistances = tMaxDistances;

                                        % roiTemplate('set', dSeriesOffset, atRoiInput);
                                   end
                                end
                            end
                        end

                        for aa=1:dNbVois

                            if strcmp(ptrObject.Tag, atVoiInput{aa}.Tag)

                                if ~isempty(atVoiInput{aa}.RoisTag)

                                    if dNbVois > 10
                                        if mod(aa, 5)==1 || aa == dNbVois
                                            progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                                        end
                                    end

                                    [tVoiComputed, atRoiComputed] = ...
                                        computeVoi(aInputBuffer, ...
                                                   atInputMetaData, ...
                                                   aDisplayBuffer, ...
                                                   atMetaData, ...
                                                   atVoiInput{aa}, ...
                                                   atRoiInput, ...
                                                   dSUVScale, ...
                                                   bSUVUnit, ...
                                                   bModifiedMatrix, ...
                                                   bSegmented, ...
                                                   bMovementApplied, ...
                                                   transM);

                                    if ~isempty(tVoiComputed)

                                        sVoiName = atVoiInput{aa}.Label;

                                        if bExpendedDisplay == true

                                            asCell{dLineOffset,1}  = (sVoiName);
                                            asCell{dLineOffset,2}  = (' ');
                                            asCell{dLineOffset,3}  = [tVoiComputed.cells];
                                            asCell{dLineOffset,4}  = [tVoiComputed.total];
                                            asCell{dLineOffset,5}  = [tVoiComputed.sum];
                                            asCell{dLineOffset,6}  = [tVoiComputed.mean];
                                            asCell{dLineOffset,7}  = [tVoiComputed.min];
                                            asCell{dLineOffset,8}  = [tVoiComputed.max];
                                            asCell{dLineOffset,9}  = [tVoiComputed.median];
                                            asCell{dLineOffset,10} = [tVoiComputed.std];
                                            asCell{dLineOffset,11} = [tVoiComputed.peak];
                                            asCell{dLineOffset,12} = (' ');
                                            asCell{dLineOffset,13} = (' ');
                                            asCell{dLineOffset,14} = (' ');
                                            asCell{dLineOffset,15} = [tVoiComputed.volume];

                                            for tt=16:21
                                                asCell{dLineOffset,tt}  = (' ');
                                            end
                                        else
                                            asCell{dLineOffset,1}  = (sVoiName);
                                            asCell{dLineOffset,2}  = [tVoiComputed.cells];
                                            asCell{dLineOffset,3}  = [tVoiComputed.total];
                                            asCell{dLineOffset,4}  = [tVoiComputed.sum];
                                            asCell{dLineOffset,5}  = [tVoiComputed.mean];
                                            asCell{dLineOffset,6}  = [tVoiComputed.min];
                                            asCell{dLineOffset,7}  = [tVoiComputed.max];
                                            asCell{dLineOffset,8}  = [tVoiComputed.median];
                                            asCell{dLineOffset,9}  = [tVoiComputed.std];
                                            asCell{dLineOffset,10} = [tVoiComputed.peak];
                                            asCell{dLineOffset,11} = [tVoiComputed.volume];

                                            for tt=12:21
                                                asCell{dLineOffset,tt}  = (' ');
                                            end
                                        end

                                        dLineOffset = dLineOffset+1;

                                        if bExpendedDisplay == true

                                            dNbTags = numel(atRoiComputed);

                                            for bb=1:dNbTags % Scan VOI/ROIs

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
                                                    asCell{dLineOffset,4}  = [atRoiComputed{bb}.total];
                                                    asCell{dLineOffset,5}  = [atRoiComputed{bb}.sum];
                                                    asCell{dLineOffset,6}  = [atRoiComputed{bb}.mean];
                                                    asCell{dLineOffset,7}  = [atRoiComputed{bb}.min];
                                                    asCell{dLineOffset,8}  = [atRoiComputed{bb}.max];
                                                    asCell{dLineOffset,9}  = [atRoiComputed{bb}.median];
                                                    asCell{dLineOffset,10}  = [atRoiComputed{bb}.std];
                                                    asCell{dLineOffset,11} = [atRoiComputed{bb}.peak];
                                                    if ~isempty(atRoiComputed{bb}.MaxDistances)
                                                        if atRoiComputed{bb}.MaxDistances.MaxXY.Length == 0
                                                            asCell{dLineOffset, 12} = ('NaN');
                                                        else
                                                            asCell{dLineOffset, 12} = [atRoiComputed{bb}.MaxDistances.MaxXY.Length];
                                                        end

                                                        if atRoiComputed{bb}.MaxDistances.MaxCY.Length == 0
                                                            asCell{dLineOffset, 13} = ('NaN');
                                                        else
                                                            asCell{dLineOffset, 13} = [atRoiComputed{bb}.MaxDistances.MaxCY.Length];
                                                        end
                                                    else
                                                        asCell{dLineOffset,12} = (' ');
                                                        asCell{dLineOffset,13} = (' ');
                                                    end
                                                    asCell{dLineOffset,14} = [atRoiComputed{bb}.area];
                                                    asCell{dLineOffset,15} = (' ');

                                                    for tt=16:21
                                                        asCell{dLineOffset,tt}  = (' ');
                                                    end

                                                    dLineOffset = dLineOffset+1;

                                                end

    %                                             break;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    else
                        if bExpendedDisplay == true

                            dNbRois = numel(atRoiInput);

                            for bb=1:dNbRois

                                if strcmp(ptrObject.Tag, atRoiInput{bb}.Tag)

                                    if dNbRois > 100
                                        if mod(bb, 10)==1 || bb == dNbRois
                                            progressBar( bb/dNbRois-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbRois) );
                                        end
                                    end

                                    if isvalid(atRoiInput{bb}.Object)

                                        if strcmpi(atRoiInput{bb}.ObjectType, 'roi')

                                            if ~isfield(atRoiInput{bb}, 'MaxDistances')

                                                tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{bb}, false, false);

                                                atRoiInput{bb}.MaxDistances = tMaxDistances;

                                                % roiTemplate('set', dSeriesOffset, atRoiInput);
                                           end
                                        end

                                        tRoiComputed = ...
                                            computeRoi(aInputBuffer, ...
                                                       atInputMetaData, ...
                                                       aDisplayBuffer, ...
                                                       atMetaData, ...
                                                       atRoiInput{bb}, ...
                                                       dSUVScale, ...
                                                       bSUVUnit, ...
                                                       bModifiedMatrix, ...
                                                       bSegmented, ...
                                                       bMovementApplied, ...
                                                       transM);

                                        sRoiName = atRoiInput{bb}.Label;

                                        if strcmpi(atRoiInput{bb}.Axe, 'Axe')
                                            sSliceNb = num2str(atRoiInput{bb}.SliceNb);
                                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes1')
                                            sSliceNb = ['C:' num2str(atRoiInput{bb}.SliceNb)];
                                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes2')
                                            sSliceNb = ['S:' num2str(atRoiInput{bb}.SliceNb)];
                                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes3')
                                            sSliceNb = ['A:' num2str(size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3)-atRoiInput{bb}.SliceNb+1)];
                                        end

                                        asCell{dLineOffset, 1}  = (sRoiName);
                                        asCell{dLineOffset, 2}  = (sSliceNb);
                                        asCell{dLineOffset, 3}  = [tRoiComputed.cells];
                                        asCell{dLineOffset, 4}  = [tRoiComputed.total];
                                        asCell{dLineOffset, 5}  = [tRoiComputed.sum];
                                        asCell{dLineOffset, 6}  = [tRoiComputed.mean];
                                        asCell{dLineOffset, 7}  = [tRoiComputed.min];
                                        asCell{dLineOffset, 8}  = [tRoiComputed.max];
                                        asCell{dLineOffset, 9}  = [tRoiComputed.median];
                                        asCell{dLineOffset, 10} = [tRoiComputed.std];
                                        asCell{dLineOffset, 11} = [tRoiComputed.peak];

                                        if ~isempty(tRoiComputed.MaxDistances)
                                            if tRoiComputed.MaxDistances.MaxXY.Length == 0
                                                asCell{dLineOffset, 12} = ('NaN');
                                            else
                                                asCell{dLineOffset, 12} = [tRoiComputed.MaxDistances.MaxXY.Length];
                                            end

                                            if tRoiComputed.MaxDistances.MaxCY.Length == 0
                                                asCell{dLineOffset, 13} = ('NaN');
                                            else
                                                asCell{dLineOffset, 13} = [tRoiComputed.MaxDistances.MaxCY.Length];
                                            end
                                        else
                                            asCell{dLineOffset, 12} = (' ');
                                            asCell{dLineOffset, 13} = (' ');
                                        end
                                        asCell{dLineOffset, 14} = tRoiComputed.area;
                                        asCell{dLineOffset, 15} = (' ');

                                        for tt=16:21
                                            asCell{dLineOffset,tt}  = (' ');
                                        end

                                        dLineOffset = dLineOffset+1;

                                        break;
                                    end
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

                if cummulativeMenuOption('get') == true && ...
                   ~isempty(ptrPlotCummulative)

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

                    cell2csv(sprintf('%s%s', path, file), asCell, ',');

%                    dLineOffset = dLineOffset+2;
%                    if bExcelInstance == true % Need excel to copy the figure
%                        xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', sprintf('A%d',dLineOffset+1));
%                    end

                elseif histogramMenuOption('get') == true && ...
                       ~isempty(ptrHist)

                    % XYData

                    asCell{dLineOffset,1}    = ('XData');
                    asCell{dLineOffset+1,1}  = ('YData');

                    sXData ='';
                    for ff=1:numel(ptrHist.Values)
                        sXData = sprintf('%s,%d', sXData, ff);
                    end

                    sYData ='';
                    for ff=1:numel(ptrHist.Values)
                        sYData = sprintf('%s,%d', sYData, ptrHist.Values(ff));
                    end

                    asCell{dLineOffset  ,2} = (sXData);
                    asCell{dLineOffset+1,2} = (sYData);
                    for xy=3:21
                        asCell{dLineOffset  ,xy} = (' ');
                        asCell{dLineOffset+1,xy} = (' ');
                    end
                    dLineOffset = dLineOffset+2;

                    % Blank line

                    for bl=1:21
                        asCell{dLineOffset,bl} = (' ');
                    end

                    dLineOffset = dLineOffset+1;

                    % XYLimits

                    asCell{dLineOffset  ,1}  = ('XLimits');
                    asCell{dLineOffset+1,1}  = ('YLimits');

                    asCell{dLineOffset,  2}  = (ptrHist.Parent.XLim(1));
                    asCell{dLineOffset+1,2}  = (ptrHist.Parent.YLim(1));
                    asCell{dLineOffset,  3}  = (ptrHist.Parent.XLim(2));
                    asCell{dLineOffset+1,3}  = (ptrHist.Parent.YLim(2));
                    for xy=4:21
                        asCell{dLineOffset  ,xy} = (' ');
                        asCell{dLineOffset+1,xy} = (' ');
                    end

                    cell2csv(sprintf('%s%s', path, file), asCell, ',');

%                    dLineOffset = dLineOffset+2;
%                    if bExcelInstance == true % Need excel to copy the figure
%                        xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', sprintf('A%d',dLineOffset+1));
%                    end

                else
                    if ~isempty(ptrPlotProfile)

                        asCell{dLineOffset,1}    = ('XData');
                        asCell{dLineOffset+1,1}  = ('XData');

                        sXData ='';
                        for ff=1:numel(ptrPlotProfile.XData)
                            sXData = sprintf('%s,%d', sXData, ptrPlotProfile.XData(ff));
                        end

                        sYData ='';
                        for ff=1:numel(ptrPlotProfile.YData)
                            sYData = sprintf('%s,%d', sYData, ptrPlotProfile.YData(ff));
                        end

                        asCell{dLineOffset  ,2} = (sXData);
                        asCell{dLineOffset+1,2} = (sYData);
                        for xy=3:21
                            asCell{dLineOffset  ,xy} = (' ');
                            asCell{dLineOffset+1,xy} = (' ');
                        end
                        dLineOffset = dLineOffset+2;

                        % Blank line

                        for bl=1:21
                            asCell{dLineOffset,bl} = (' ');
                        end

                        dLineOffset = dLineOffset+1;

                        % XYLimits

                        asCell{dLineOffset  ,1}  = ('XLimits');
                        asCell{dLineOffset+1,1}  = ('YLimits');

                        asCell{dLineOffset,  2}  = (ptrPlotProfile.Parent.XLim(1));
                        asCell{dLineOffset+1,2}  = (ptrPlotProfile.Parent.YLim(1));
                        asCell{dLineOffset,  3}  = (ptrPlotProfile.Parent.XLim(2));
                        asCell{dLineOffset+1,3}  = (ptrPlotProfile.Parent.YLim(2));
                        for xy=4:21
                            asCell{dLineOffset  ,xy} = (' ');
                            asCell{dLineOffset+1,xy} = (' ');
                        end

                        cell2csv(sprintf('%s%s', path, file), asCell, ',');

%                        dLineOffset = dLineOffset+2;
%                        if bExcelInstance == true % Need excel to copy the figure
%                           xlswritefig(figRoiHistogramWindow, sprintf('%s%s', path, file), 'Sheet1', sprintf('A%d',dLineOffset+1));
%                        end


                    end
                end

                if bExcelInstance == true
                    winopen(sprintf('%s%s', path, file));
                end

                progressBar(1, sprintf('Write %s%s completed', path, file));

                catch ME 
                    logErrorToFile(ME); 
                    progressBar(1, 'Error: exportCurrentHistogramCallback()');
                end

                clear aDisplayBuffer;
                clear aInput;

                set(figRoiHistogramWindow, 'Pointer', 'default');
                drawnow;

            end
        end

    end

end
