function figRoiTimeActivity(sType, atVoiRoiTag, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied, bSimplified)
%function figRoiTimeActivity(sType, atVoiRoiTag, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied, bSimplified)
%Display a time activity figure.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    gaAcquisitionDate = [];
    gaAcquisitionTime = [];
    gtxtRoiList = [];

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atMetaData = dicomMetaData('get', [],  get(uiSeriesPtr('get'), 'Value'));

    tQuant = quantificationTemplate('get');
    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    FIG_MPLOT_Y = ySize*0.75;
    FIG_MPLOT_X = FIG_MPLOT_Y;

    if viewerUIFigure('get') == true

        figRoiTimeActivity = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_MPLOT_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_MPLOT_Y/2) ...
                   FIG_MPLOT_X ...
                   FIG_MPLOT_Y],...
                   'Resize', 'on', ...
                   'AutoResizeChildren', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'Name' , ' ',...
                   'SizeChangedFcn',@resizefigRoiTimeActivityCallback...
                  );
    else
        figRoiTimeActivity = ...
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
                   'SizeChangedFcn',@resizefigRoiTimeActivityCallback...
                   );
    end

    setObjectIcon(figRoiTimeActivity);

    setTimeActivityFigureName();

    mTimeActivityFile = uimenu(figRoiTimeActivity,'Label','File');
    uimenu(mTimeActivityFile,'Label', 'Export to .csv...','Callback', @exportCurrentTimeActivityCallback);
    uimenu(mTimeActivityFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');


    mTimeActivityEdit = uimenu(figRoiTimeActivity,'Label','Edit');
    uimenu(mTimeActivityEdit,'Label', 'Copy Display', 'Callback', @copyTimeActivityDisplayCallback);

    mTimeActivityOptions = uimenu(figRoiTimeActivity,'Label','Options','Callback', @refreshTimeActivityAggregate);
    uimenu(mTimeActivityOptions,'Label', 'Total', 'Callback',@figRoiSetTimeActivityAggregate);
    uimenu(mTimeActivityOptions,'Label', 'Sum'  , 'Callback',@figRoiSetTimeActivityAggregate);
    uimenu(mTimeActivityOptions,'Label', 'Mean' , 'Callback',@figRoiSetTimeActivityAggregate);
    uimenu(mTimeActivityOptions,'Label', 'Max'  , 'Callback',@figRoiSetTimeActivityAggregate);
    uimenu(mTimeActivityOptions,'Label', 'Peak' , 'Callback',@figRoiSetTimeActivityAggregate);

    aFigurePosition = get(figRoiTimeActivity, 'Position');

    axeTimeActivity = ...
        axes(figRoiTimeActivity, ...
             'Units'   , 'pixels', ...
             'Position', [60 60 aFigurePosition(3)-360 aFigurePosition(4)-90], ...
             'Color'   , viewerAxesColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'on'...
             );
    axeTimeActivity.Interactions = [];
    % axeTimeActivity.Toolbar.Visible = 'off';
    deleteAxesToolbar(axeTimeActivity);
    disableDefaultInteractivity(axeTimeActivity);

    axeTimeActivity.Title.String = sType;
    axeTimeActivity.Title.Color  = viewerForegroundColor('get');

    aAxePosition = get(axeTimeActivity, 'Position');

    uiRoiListMainPanel = ...
        uipanel(figRoiTimeActivity,...
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
%     addlistener(uiRoiListPanelSlider, 'Value', 'PreSet', @uiRoiListPanelSliderCallback);
    addlistener(uiRoiListPanelSlider, 'ContinuousValueChange', @uiRoiListPanelSliderCallback);

    if isscalar(atVoiRoiTag)
        set(uiRoiListPanelSlider, 'Visible', 'off');
        set(uiRoiListPanel, 'Visible', 'off');
        set(uiRoiListMainPanel, 'Visible', 'off');

        set(axeTimeActivity, 'Position', [60 60 aFigurePosition(3)-90 aFigurePosition(4)-90]);
    end

    setTimeActivityRoiVoi(atVoiRoiTag);

    function refreshTimeActivityAggregate(hObject, ~)

        for jj=1: numel(hObject.Children)
            if strcmpi(hObject.Children(jj).Text, sType)
                hObject.Children(jj).Checked = 'on';
            else
                hObject.Children(jj).Checked = 'off';
            end
        end

    end

    function figRoiSetTimeActivityAggregate(hObject, ~)

        sType = hObject.Text;

        cla(axeTimeActivity);

        axeTimeActivity.Title.String = sType;

        setTimeActivityRoiVoi(atVoiRoiTag);

    end

    function resizefigRoiTimeActivityCallback(~, ~)

        if ~exist('figRoiTimeActivity', 'var')
            return;
        end

        aFigurePosition  = get(figRoiTimeActivity, 'Position');

        if isscalar(atVoiRoiTag)
            set(axeTimeActivity, ...
                'Position', ...
                [60 ...
                 60 ...
                 aFigurePosition(3)-90 ...
                 aFigurePosition(4)-90 ...
                ] ...
                );
        else
            set(axeTimeActivity, ...
                'Position', ...
                [60 ...
                 60 ...
                 aFigurePosition(3)-360 ...
                 aFigurePosition(4)-90 ...
                ] ...
                );
        end

        aAxePosition = get(axeTimeActivity   , 'Position');

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

    function setTimeActivityFigureName()

        sTitle = sprintf('Time Activity Curve %s', sType);

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

             if isfield(atMetaData{1}, 'DoseUnits')

                if ~isempty(atMetaData{1}.DoseUnits)

                    sUnits = sprintf('Unit: %s', char(atMetaData{1}.DoseUnits));
                else
                    sUnits = 'Unit: dose';
                end
            else
                sUnits = 'Unit: dose';
            end

        else

            if bSUVUnit == true

                if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(atMetaData{1}.Units, 'BQML' )

                    sSUVtype = viewerSUVtype('get');
                    sUnits =  sprintf('Unit: SUV/%s', sSUVtype);
                else

                    if (strcmpi(atMetaData{1}.Modality, 'ct'))
                       sUnits = 'Unit: HU';
                    else
                       sUnits = 'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(atMetaData{1}.Modality, 'ct'))
                    sUnits =  'Unit: HU';
                 else
                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atMetaData{1}.Units, 'BQML' )
                        sUnits =  'Unit: BQML';
                    else
                        sUnits =  'Unit: Counts';
                    end
                end
            end
        end

        set(figRoiTimeActivity, 'Name', [sTitle ' - ' atMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented]);

    end

    function setTimeActivityRoiVoi(atVoiRoiTag)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atInputTemplate = inputTemplate('get');

        if gateUseSeriesUID('get') == false

            % Extract the number of elements in atInputTemplate
            nElements = numel(atInputTemplate);

            % Initialize arrays to store datetime values for sorting
            aDatetimeArray = datetime.empty(nElements, 0);

            % Loop through each element to extract and convert SeriesDate and SeriesTime
            for i = 1:nElements
                % Extract SeriesDate and SeriesTime
                sSeriesDate = atInputTemplate(i).atDicomInfo{1}.SeriesDate; % 'YYYYMMDD' format
                sSeriesTime = atInputTemplate(i).atDicomInfo{1}.SeriesTime; % 'HHMMSS' format

                if contains(sSeriesDate,'.')
                    sSeriesDate = extractBefore(sSeriesDate,'.');
                end

                if contains(sSeriesTime,'.')
                    sSeriesTime = extractBefore(sSeriesTime,'.');
                end

                % Combine SeriesDate and SeriesTime into a single datetime object
                aDatetimeArray(i) = datetime([sSeriesDate sSeriesTime], 'InputFormat', 'yyyyMMddHHmmss');
            end

            % Sort datetimeArray and get sorting indices
            [~, aSortIdx] = sort(aDatetimeArray);

            % Sort atInputTemplate based on sorted indices
            atInputTemplate = atInputTemplate(aSortIdx);

            sSeriesInstanceUID = atInputTemplate(1).atDicomInfo{1}.SeriesInstanceUID;
        else
            sSeriesInstanceUID = atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID;
        end


        try

        txtRoiList = [];

        set(figRoiTimeActivity, 'Pointer', 'watch');
        drawnow;

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        tQuant = quantificationTemplate('get');
        if isfield(tQuant, 'tSUV')
            dSUVScale = tQuant.tSUV.dScale;
        else
            dSUVScale = 1;
        end

        aRoiListPosition = get(uiRoiListPanel, 'Position');

        dOffset=1;

        dYMin = [];
        dYMax = [];

        for aa=1:numel(atVoiRoiTag)

            gaAcquisitionDate = [];
            gaAcquisitionTime = [];

            aAggregate = [];
            aTime = [];

            bFoundTag = false;


            for bb=1:numel(atVoiInput)

                if strcmp(atVoiRoiTag{aa}.Tag, atVoiInput{bb}.Tag)

                    try

                    for sr=1:numel(atInputTemplate)

                        if strcmpi(sSeriesInstanceUID, atInputTemplate(sr).atDicomInfo{1}.SeriesInstanceUID) || ... % Same series
                           gateUseSeriesUID('get') == false

                            if gateUseSeriesUID('get') == false
                                dCurrentSeriesOffset = aSortIdx(sr);
                            else
                                dCurrentSeriesOffset = sr;
                            end

                            aInputBuffer = dicomBuffer('get', [], dCurrentSeriesOffset);

                            if isempty(aInputBuffer)

                                aInputBuffer = inputBuffer('get');

                                switch lower(imageOrientation('get'))

                                    case'axial'
                                        aInputBuffer = aInputBuffer{dCurrentSeriesOffset};

                                    case 'coronal'
                                        aInputBuffer = reorientBuffer(aInputBuffer{dCurrentSeriesOffset}, 'coronal');

                                    case'sagittal'
                                        aInputBuffer = reorientBuffer(aInputBuffer{dCurrentSeriesOffset}, 'sagittal');
                                end

                                if size(aInputBuffer, 3) ==1

                                    if atInputTemplate(dCurrentSeriesOffset).bFlipLeftRight == true
                                        aInputBuffer=aInputBuffer(:,end:-1:1);
                                    end

                                    if atInputTemplate(dCurrentSeriesOffset).bFlipAntPost == true
                                        aInputBuffer=aInputBuffer(end:-1:1,:);
                                    end
                                else
                                    if atInputTemplate(dCurrentSeriesOffset).bFlipLeftRight == true
                                        aInputBuffer=aInputBuffer(:,end:-1:1,:);
                                    end

                                    if atInputTemplate(dCurrentSeriesOffset).bFlipAntPost == true
                                        aInputBuffer=aInputBuffer(end:-1:1,:,:);
                                    end

                                    if atInputTemplate(dCurrentSeriesOffset).bFlipHeadFeet == true
                                        aInputBuffer=aInputBuffer(:,:,end:-1:1);
                                    end
                                end

                                dicomBuffer('set', aInputBuffer, dCurrentSeriesOffset);

                            end

                            atInputMetaData = dicomMetaData('get', [], dCurrentSeriesOffset);

                            if isempty(atInputMetaData)
                                atInputMetaData = atInputTemplate(dCurrentSeriesOffset).atDicomInfo;
                                dicomMetaData('set', atInputMetaData, dCurrentSeriesOffset)
                            end

                            tQuant = quantificationTemplate('get', [], dCurrentSeriesOffset);
                            if isfield(tQuant, 'tSUV')
                                dSUVScale = tQuant.tSUV.dScale;
                            else
                                dSUVScale = 1;
                            end

                            tVoiComputed = computeVoi(aInputBuffer, ...
                                                       atInputMetaData, ...
                                                       dicomBuffer('get', [], dCurrentSeriesOffset), ...
                                                       dicomMetaData('get', [], dCurrentSeriesOffset), ...
                                                       atVoiInput{bb}, ...
                                                       atRoiInput, ...
                                                       dSUVScale, ...
                                                       bSUVUnit, ...
                                                       bModifiedMatrix, ...
                                                       bSegmented, ...
                                                       bDoseKernel, ...
                                                       bMovementApplied);

                            switch lower(sType)

                                case 'total'
                                    aAggregate{numel(aAggregate)+1} = tVoiComputed.total;

                                case 'sum'
                                    aAggregate{numel(aAggregate)+1} = tVoiComputed.sum;

                                case 'mean'
                                    aAggregate{numel(aAggregate)+1} = tVoiComputed.mean;

                                case 'max'
                                    aAggregate{numel(aAggregate)+1} = tVoiComputed.max;

                                case 'peak'
                                    aAggregate{numel(aAggregate)+1} = tVoiComputed.peak;
                            end

                            if isempty(aTime)
                                aTime{1} = atInputMetaData{1}.ActualFrameDuration/1000/60/2;
                                dPreviousActualTime = atInputMetaData{1}.ActualFrameDuration/1000/60;

                                if gateUseSeriesUID('get') == false
                                    sSeriesInstanceUID = atInputMetaData{1}.SeriesInstanceUID;

                                    sLastSeriesDate = atInputMetaData{1}.SeriesDate;
                                    sLastSeriesTime = atInputMetaData{1}.SeriesTime;

                                    if contains(sLastSeriesDate,'.')
                                        sLastSeriesDate = extractBefore(sLastSeriesDate,'.');
                                    end

                                    if contains(sLastSeriesTime,'.')
                                        sLastSeriesTime = extractBefore(sLastSeriesTime,'.');
                                    end
                               end

                            else
                                aTime{numel(aTime)+1} = dPreviousActualTime + atInputMetaData{1}.ActualFrameDuration/1000/60/2;

                                if gateUseSeriesUID('get') == false

                                    if ~strcmpi(sSeriesInstanceUID, atInputTemplate(dCurrentSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)

                                        sCurrentDate = atInputMetaData{1}.SeriesDate;
                                        sCurrentTime = atInputMetaData{1}.SeriesTime;

                                        if contains(sCurrentDate,'.')
                                            sCurrentDate = extractBefore(sCurrentDate,'.');
                                        end

                                        if contains(sCurrentTime,'.')
                                            sCurrentTime = extractBefore(sCurrentTime,'.');
                                        end

                                        % Convert date and time strings to datetime objects
                                        tCurrentDatetime = datetime([sCurrentDate sCurrentTime], 'InputFormat', 'yyyyMMddHHmmss');
                                        tLastSeriesDatetime = datetime([sLastSeriesDate sLastSeriesTime], 'InputFormat', 'yyyyMMddHHmmss');

                                        % Calculate the difference in time
                                        tTimeDifference = tCurrentDatetime - tLastSeriesDatetime;

                                        dPreviousActualTime = dPreviousActualTime+ minutes(tTimeDifference);
                                    else
                                        dPreviousActualTime = dPreviousActualTime+atInputMetaData{1}.ActualFrameDuration/1000/60;
                                    end

                                    sSeriesInstanceUID = atInputMetaData{1}.SeriesInstanceUID;

                                    sLastSeriesDate = atInputMetaData{1}.SeriesDate;
                                    sLastSeriesTime = atInputMetaData{1}.SeriesTime;

                                    if contains(sLastSeriesDate,'.')
                                        sLastSeriesDate = extractBefore(sLastSeriesDate,'.');
                                    end

                                    if contains(sLastSeriesTime,'.')
                                        sLastSeriesTime = extractBefore(sLastSeriesTime,'.');
                                    end
                                else
                                    dPreviousActualTime = dPreviousActualTime+atInputMetaData{1}.ActualFrameDuration/1000/60;
                                end
                            end

                            gaAcquisitionDate{numel(gaAcquisitionDate)+1} =  atInputMetaData{1}.AcquisitionDate;
                            gaAcquisitionTime{numel(gaAcquisitionTime)+1} =  atInputMetaData{1}.AcquisitionTime;

                        end
                    end

                    if ~isempty(aAggregate)

                        dMinIntensity = min(cell2mat(aAggregate), [], 'all');
                        dMaxIntensity = max(cell2mat(aAggregate), [], 'all');

                        if isempty(dYMin)
                            dYMin = dMinIntensity;
                        else
                            if dMinIntensity < dYMin
                                dYMin = dMinIntensity;
                            end
                        end

                        if isempty(dYMax)
                            dYMax = dMaxIntensity;
                        else
                            if dMaxIntensity > dYMax
                                dYMax = dMaxIntensity;
                            end
                        end

                        set(axeTimeActivity, 'YLim', [dYMin dYMax]);
                        set(axeTimeActivity, 'XLim', [min(cell2mat(aTime), [], 'all') max(cell2mat(aTime), [], 'all')]);

                        hold(axeTimeActivity, 'on');
                        ptrPlot = plot(axeTimeActivity, cell2mat(aTime), cell2mat(aAggregate), '-o');
                        ptrPlot.Color  = atVoiInput{bb}.Color;
                        ptrPlot.LineWidth  = 1;
                        hold(axeTimeActivity, 'off');

                        axeTimeActivity.XColor = viewerForegroundColor('get');
                        axeTimeActivity.YColor = viewerForegroundColor('get');
                        axeTimeActivity.ZColor = viewerForegroundColor('get');

                        if bDoseKernel == true
                            axeTimeActivity.YLabel.String = 'Intensity (Gy)';
                        else
                            if  (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                                 strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                                 strcmpi(atMetaData{1}.Units, 'BQML' )

                                if bSUVUnit == true
                                    axeTimeActivity.YLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                                else
                                    axeTimeActivity.YLabel.String = 'Intensity (BQML)';
                                end
                            else
                                if  strcmpi(atMetaData{1}.Modality, 'ct')

                                    axeTimeActivity.YLabel.String = 'Intensity (HU)';
                                else

                                    axeTimeActivity.XLabel.String = 'Intensity (Count)';
                                end
                            end
                        end

                        axeTimeActivity.XLabel.String = 'Time (min)';

                        axeTimeActivity.Title.Color = viewerForegroundColor('get');
                        axeTimeActivity.Color = viewerAxesColor('get');

                        txtRoiList{dOffset} = ...
                            uicontrol(uiRoiListPanel,...
                                      'style'   , 'text',...
                                      'string'  , atVoiInput{bb}.Label,...
                                      'horizontalalignment', 'left',...
                                      'position', [5 (dOffset-1)*25 aRoiListPosition(3)-35 20],...
                                      'Enable', 'Inactive',...
                                      'UserData', ptrPlot, ...
                                      'ForegroundColor', atVoiInput{bb}.Color, ...
                                      'BackgroundColor', viewerBackgroundColor('get'), ...
                                      'ButtonDownFcn', @highlightPlotCallback...
                                      );
                        dOffset = dOffset+1;
                        bFoundTag = true;
                    end

                    catch ME
                        logErrorToFile(ME); 
                    end
                    break;
                end
            end

            if bFoundTag == false
                for bb=1:numel(atRoiInput)
                    if strcmp(atVoiRoiTag{aa}.Tag, atRoiInput{bb}.Tag)
                        try

                        for sr=1:numel(atInputTemplate)

                            if strcmpi(sSeriesInstanceUID, atInputTemplate(sr).atDicomInfo{1}.SeriesInstanceUID) || ... % Same series
                               gateUseSeriesUID('get') == false

                                if gateUseSeriesUID('get') == false
                                    dCurrentSeriesOffset = aSortIdx(sr);
                                else
                                    dCurrentSeriesOffset = sr;
                                end

                                aInputBuffer = dicomBuffer('get', [], dCurrentSeriesOffset);

                                if isempty(aInputBuffer)

                                    aInputBuffer = inputBuffer('get');

                                    switch lower(imageOrientation('get'))

                                        case'axial'
                                            aInputBuffer = aInputBuffer{dCurrentSeriesOffset};

                                        case 'coronal'
                                            aInputBuffer = reorientBuffer(aInputBuffer{dCurrentSeriesOffset}, 'coronal');

                                        case'sagittal'
                                            aInputBuffer = reorientBuffer(aInputBuffer{dCurrentSeriesOffset}, 'sagittal');
                                    end

                                    if size(aInputBuffer, 3) ==1

                                        if atInputTemplate(dCurrentSeriesOffset).bFlipLeftRight == true
                                            aInputBuffer=aInputBuffer(:,end:-1:1);
                                        end

                                        if atInputTemplate(dCurrentSeriesOffset).bFlipAntPost == true
                                            aInputBuffer=aInputBuffer(end:-1:1,:);
                                        end
                                    else
                                        if atInputTemplate(dCurrentSeriesOffset).bFlipLeftRight == true
                                            aInputBuffer=aInputBuffer(:,end:-1:1,:);
                                        end

                                        if atInputTemplate(dCurrentSeriesOffset).bFlipAntPost == true
                                            aInputBuffer=aInputBuffer(end:-1:1,:,:);
                                        end

                                        if atInputTemplate(dCurrentSeriesOffset).bFlipHeadFeet == true
                                            aInputBuffer=aInputBuffer(:,:,end:-1:1);
                                        end
                                    end

                                    dicomBuffer('set', aInputBuffer, dCurrentSeriesOffset);
                                end

                                atInputMetaData = dicomMetaData('get', [], dCurrentSeriesOffset);

                                if isempty(atInputMetaData)

                                    atInputMetaData = atInputTemplate(dCurrentSeriesOffset).atDicomInfo;
                                    dicomMetaData('set', atInputMetaData, dCurrentSeriesOffset)
                                end

                                tQuant = quantificationTemplate('get', [], dCurrentSeriesOffset);
                                if isfield(tQuant, 'tSUV')
                                    dSUVScale = tQuant.tSUV.dScale;
                                else
                                    dSUVScale = 1;
                                end

                                tRoiComputed = computeRoi(aInputBuffer, ...
                                                           atInputMetaData, ...
                                                           dicomBuffer('get', [], dCurrentSeriesOffset), ...
                                                           dicomMetaData('get', [], dCurrentSeriesOffset), ...
                                                           atRoiInput{bb}, ...
                                                           dSUVScale, ...
                                                           bSUVUnit, ...
                                                           bModifiedMatrix, ...
                                                           bSegmented, ...
                                                           bDoseKernel, ...
                                                           bMovementApplied);

                                switch lower(sType)

                                    case 'total'
                                        aAggregate{numel(aAggregate)+1} = tRoiComputed.total;

                                    case 'sum'
                                        aAggregate{numel(aAggregate)+1} = tRoiComputed.sum;

                                    case 'mean'
                                        aAggregate{numel(aAggregate)+1} = tRoiComputed.mean;

                                    case 'max'
                                        aAggregate{numel(aAggregate)+1} = tRoiComputed.max;

                                    case 'peak'
                                        aAggregate{numel(aAggregate)+1} = tRoiComputed.peak;
                                end

                                if isempty(aTime)
                                    aTime{1} = atInputMetaData{1}.ActualFrameDuration/1000/60/2;
                                    dPreviousActualTime = atInputMetaData{1}.ActualFrameDuration/1000/60;

                                    if gateUseSeriesUID('get') == false
                                        sSeriesInstanceUID = atInputMetaData{1}.SeriesInstanceUID;

                                        sLastSeriesDate = atInputMetaData{1}.SeriesDate;
                                        sLastSeriesTime = atInputMetaData{1}.SeriesTime;

                                        if contains(sLastSeriesDate,'.')
                                            sLastSeriesDate = extractBefore(sLastSeriesDate,'.');
                                        end

                                        if contains(sLastSeriesTime,'.')
                                            sLastSeriesTime = extractBefore(sLastSeriesTime,'.');
                                        end
                                   end

                                else
                                    aTime{numel(aTime)+1} = dPreviousActualTime + atInputMetaData{1}.ActualFrameDuration/1000/60/2;

                                    if gateUseSeriesUID('get') == false

                                        if ~strcmpi(sSeriesInstanceUID, atInputTemplate(dCurrentSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)

                                            sCurrentDate = atInputMetaData{1}.SeriesDate;
                                            sCurrentTime = atInputMetaData{1}.SeriesTime;

                                            if contains(sCurrentDate,'.')
                                                sCurrentDate = extractBefore(sCurrentDate,'.');
                                            end

                                            if contains(sCurrentTime,'.')
                                                sCurrentTime = extractBefore(sCurrentTime,'.');
                                            end

                                            % Convert date and time strings to datetime objects
                                            tCurrentDatetime = datetime([sCurrentDate sCurrentTime], 'InputFormat', 'yyyyMMddHHmmss');
                                            tLastSeriesDatetime = datetime([sLastSeriesDate sLastSeriesTime], 'InputFormat', 'yyyyMMddHHmmss');

                                            % Calculate the difference in time
                                            tTimeDifference = tCurrentDatetime - tLastSeriesDatetime;

                                            dPreviousActualTime = dPreviousActualTime+ minutes(tTimeDifference);
                                        else
                                            dPreviousActualTime = dPreviousActualTime+atInputMetaData{1}.ActualFrameDuration/1000/60;
                                        end

                                        sSeriesInstanceUID = atInputMetaData{1}.SeriesInstanceUID;

                                        sLastSeriesDate = atInputMetaData{1}.SeriesDate;
                                        sLastSeriesTime = atInputMetaData{1}.SeriesTime;

                                        if contains(sLastSeriesDate,'.')
                                            sLastSeriesDate = extractBefore(sLastSeriesDate,'.');
                                        end

                                        if contains(sLastSeriesTime,'.')
                                            sLastSeriesTime = extractBefore(sLastSeriesTime,'.');
                                        end
                                    else
                                        dPreviousActualTime = dPreviousActualTime+atInputMetaData{1}.ActualFrameDuration/1000/60;
                                    end
                                end

                                gaAcquisitionDate{numel(gaAcquisitionDate)+1} =  atInputMetaData{1}.AcquisitionDate;
                                gaAcquisitionTime{numel(gaAcquisitionTime)+1} =  atInputMetaData{1}.AcquisitionTime;

                            end
                        end

                        if ~isempty(aAggregate)

                            dMinIntensity = min(cell2mat(aAggregate), [], 'all');
                            dMaxIntensity = max(cell2mat(aAggregate), [], 'all');

                            if isempty(dYMin)
                                dYMin = dMinIntensity;
                            else
                                if dMinIntensity < dYMin
                                    dYMin = dMinIntensity;
                                end
                            end

                            if isempty(dYMax)
                                dYMax = dMaxIntensity;
                            else
                                if dMaxIntensity > dYMax
                                    dYMax = dMaxIntensity;
                                end
                            end

                            set(axeTimeActivity, 'YLim', [dYMin dYMax]);
                            set(axeTimeActivity, 'XLim', [min(cell2mat(aTime), [], 'all') max(cell2mat(aTime), [], 'all')]);

                            hold(axeTimeActivity, 'on');
                            ptrPlot = plot(axeTimeActivity, cell2mat(aTime), cell2mat(aAggregate), '-o');
                            ptrPlot.Color  = atRoiInput{bb}.Color;
                            ptrPlot.LineWidth  = 1;
                            hold(axeTimeActivity, 'off');

                            axeTimeActivity.XColor = viewerForegroundColor('get');
                            axeTimeActivity.YColor = viewerForegroundColor('get');
                            axeTimeActivity.ZColor = viewerForegroundColor('get');

                            if bDoseKernel == true
                                axeTimeActivity.YLabel.String = 'Intensity (Gy)';
                            else
                                if  (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                                     strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                                     strcmpi(atMetaData{1}.Units, 'BQML' )

                                    if bSUVUnit == true
                                        axeTimeActivity.YLabel.String = sprintf('Intensity (SUV/%s)', viewerSUVtype('get'));
                                    else
                                        axeTimeActivity.YLabel.String = 'Intensity (BQML)';
                                    end
                                else
                                    if  strcmpi(atMetaData{1}.Modality, 'ct')

                                        axeTimeActivity.YLabel.String = 'Intensity (HU)';
                                    else
                                        axeTimeActivity.YLabel.String = 'Intensity (Count)';
                                    end
                                end
                            end
                            axeTimeActivity.XLabel.String = 'Time (min)';

                            axeTimeActivity.Title.Color = viewerForegroundColor('get');
                            axeTimeActivity.Color = viewerAxesColor('get');

                            txtRoiList{dOffset} = ...
                                uicontrol(uiRoiListPanel,...
                                          'style'   , 'text',...
                                          'string'  , atRoiInput{bb}.Label,...
                                          'horizontalalignment', 'left',...
                                          'position', [5 (dOffset-1)*25 aRoiListPosition(3)-35 20],...
                                          'Enable', 'Inactive',...
                                          'UserData', ptrPlot, ...
                                          'ForegroundColor', atRoiInput{bb}.Color, ...
                                          'BackgroundColor', viewerBackgroundColor('get'), ...
                                          'ButtonDownFcn', @highlightPlotCallback...
                                          );

                            dOffset = dOffset+1;
                            bFoundTag = true;
                        end

                        catch ME
                            logErrorToFile(ME); 
                        end
                        break;

                    end
                end
            end
        end

        if bFoundTag == true
            pCursor = datacursormode(figRoiTimeActivity);
            pCursor.Enable = 'on';
        end

        catch ME
            logErrorToFile(ME); 
            progressBar(1, 'Error:figRoiHistogram()');
        end

        set(figRoiTimeActivity, 'Pointer', 'default');
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

    function copyTimeActivityDisplayCallback(~, ~)

        try       
            set(figRoiTimeActivity, 'Pointer', 'watch');

            copyFigureToClipboard(figRoiTimeActivity);

        catch ME
            logErrorToFile(ME);  
            progressBar(1, 'Error:copyTimeActivityDisplayCallback()');
        end

        set(figRoiTimeActivity, 'Pointer', 'default');
    end

    function exportCurrentTimeActivityCallback(~, ~)

        atInputTemplate = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(atInputTemplate)
            return;
        end

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

            if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if atInputTemplate(dSeriesOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end
        else
            if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if atInputTemplate(dSeriesOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if atInputTemplate(dSeriesOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end
        end

        atInputMetaData = atInputTemplate(dSeriesOffset).atDicomInfo;
       
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
        info = dicomMetaData('get', [], dSeriesOffset);

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

        [file, path] = uiputfile(filter, 'Save Histogram Result', sprintf('%s/%s_%s_%s_%s_TIME_ACTIVITY_TriDFusion.csv' , ...
            sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription), sSeriesDate) );

        if file ~= 0

            try

            set(figRoiTimeActivity, 'Pointer', 'watch');
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
            for tt=1:numel(atVoiRoiTag)

                for vv=1:numel(atVoiInput)

                    if strcmp(atVoiRoiTag{tt}.Tag, atVoiInput{vv}.Tag) % Found a VOI
                       if strcmpi(atVoiInput{vv}.ObjectType, 'voi')

                           if ~isempty(atVoiInput{vv}.RoisTag)

                               dNumberOfLines = dNumberOfLines+1;

                                for cc=1:numel(atVoiInput{vv}.RoisTag)
                                    for bb=1:numel(atRoiInput)
                                       if isvalid(atRoiInput{bb}.Object)
                                            if strcmpi(atVoiInput{vv}.RoisTag{cc}, atRoiInput{bb}.Tag) % Found a VOI/ROI
                                                dNumberOfLines = dNumberOfLines+1;
                                            end
                                        end
                                    end
                                end
                           end
                       end
                    end
                end

                for rr=1:numel(atRoiInput)

                    if strcmp(atVoiRoiTag{tt}.Tag, atRoiInput{rr}.Tag)  % Found a ROI
                        if ~strcmpi(atRoiInput{rr}.ObjectType, 'voi')
                            dNumberOfLines = dNumberOfLines+1;
                        end
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
            asVoiRoiHeader{8} = sprintf('Aggregate, %s'         , sType);
            asVoiRoiHeader{9} = (' ');

            if bSimplified == true

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

                bMovementApplied = atInputTemplate(dSeriesOffset).tMovement.bMovementApplied;

                for rt=1:numel(atVoiRoiTag)

                    dNbVois = numel(atVoiInput);

                    for aa=1:dNbVois

                        if strcmp(atVoiRoiTag{rt}.Tag, atVoiInput{aa}.Tag) % Found a VOI

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

                            break;

                        end
                    end
                end
            else
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
                    asCell{dLineOffset,14} = 'Area (cm2)';
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
                    asCell{dLineOffset,9}  = 'Deviation';
                    asCell{dLineOffset,10} = 'Peak';
                    asCell{dLineOffset,11} = 'Volume (cm3)';

                    for tt=12:21
                        asCell{dLineOffset,tt}  = (' ');
                    end
                end

                bMovementApplied = atInputTemplate(dSeriesOffset).tMovement.bMovementApplied;

                dLineOffset = dLineOffset+1;

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

                for rt=1:numel(atVoiRoiTag)

                    dNbVois = numel(atVoiInput);

                    for vv=1:dNbVois

                        if strcmp(atVoiRoiTag{rt}.Tag, atVoiInput{vv}.Tag) % Found a VOI

                           if strcmpi(atVoiInput{vv}.ObjectType, 'voi')

                                if ~isempty(atVoiInput{vv}.RoisTag)

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
                                                   atVoiInput{vv}, ...
                                                   atRoiInput, ...
                                                   dSUVScale, ...
                                                   bSUVUnit, ...
                                                   bModifiedMatrix, ...
                                                   bSegmented, ...
                                                   bMovementApplied, ...
                                                   transM);

                                    if ~isempty(tVoiComputed)

                                        sVoiName = atVoiInput{vv}.Label;

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
                                            end
                                        end
                                    end
                                end

                                break;
                           end

                        end
                    end

                    if bExpendedDisplay == true

                        dNbRois = numel(atRoiInput);

                        for bb=1:dNbRois

                            if strcmp(atVoiRoiTag{rt}.Tag, atRoiInput{bb}.Tag)  % Found a ROI

                                if ~strcmpi(atRoiInput{bb}.ObjectType, 'voi')

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
                                                       bModifiedMatrix, ...
                                                       bSUVUnit, ...
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
                                            sSliceNb = ['A:' num2str(size(dicomBuffer('get', [], dSeriesOffset), 3)-atRoiInput{bb}.SliceNb+1)];
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
                                    end
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

            for pp=1:numel(gtxtRoiList)

                ptrPlotCummulative = gtxtRoiList{pp}.UserData;

                % Object name

                asCell{dLineOffset,1}  = (gtxtRoiList{pp}.String);

                dLineOffset = dLineOffset+1;

                asCell{dLineOffset,1} = ('Acquisition Date');
                for dd=1:numel(gaAcquisitionDate)
                    try
                    if contains(gaAcquisitionDate{dd},'.')
                        sAcquisitionTime = extractBefore(gaAcquisitionDate{dd},'.');
                    else
                        sAcquisitionTime = gaAcquisitionDate{dd};
                    end
                    asCell{dLineOffset  ,dd+1} = (char(datetime(sAcquisitionTime, 'InputFormat', 'yyyyMMdd', 'Format', 'MMM-d-y')));
                    catch ME
                        logErrorToFile(ME);  
                    end
                end

                dLineOffset = dLineOffset+1;

                asCell{dLineOffset,1} = ('Acquisition Time');
                for tt=1:numel(gaAcquisitionTime)
                    try
                    if contains(gaAcquisitionTime{tt},'.')
                        sAcquisitionTime = extractBefore(gaAcquisitionTime{tt},'.');
                    else
                        sAcquisitionTime = gaAcquisitionTime{tt};
                    end
                    asCell{dLineOffset  ,tt+1} =  (char(datetime(sAcquisitionTime, 'InputFormat', 'HHmmss', 'Format', 'HH:mm:ss')));
                    catch ME
                        logErrorToFile(ME);  
                    end
                end

                dLineOffset = dLineOffset+1;

                % XYData

                asCell{dLineOffset,1}    = ('XData (Time)');
                asCell{dLineOffset+1,1}  = ('YData (Intensity)');

                dNbElements = numel(ptrPlotCummulative.XData);

                for kk=1:dNbElements
                    asCell{dLineOffset  ,kk+1} =  (ptrPlotCummulative.XData(kk));
                    asCell{dLineOffset+1,kk+1} =  (ptrPlotCummulative.YData(kk));
                end

%                 for bb=dNbElements:21
%                     asCell{dLineOffset  , bb+1} =  (' ');
%                     asCell{dLineOffset+1, bb+1} =  (' ');
%                 end

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

                asCell{dLineOffset  ,1}  = ('XLimits (Time)');
                asCell{dLineOffset+1,1}  = ('YLimits (Intensity)');

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

            catch ME
               logErrorToFile(ME);  
               progressBar(1, 'Error: exportCurrentTimeActivityCallback()');
            end

            clear aDisplayBuffer;
            clear aInput;

            set(figRoiTimeActivity, 'Pointer', 'default');
            drawnow;
        end

    end

end
