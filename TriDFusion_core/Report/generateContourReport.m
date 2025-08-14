function generateContourReport(bExportToPdf, sPdfFileName)
%function generateContourReport(bExportToPdf, sPdfFileName)
%Generate a report, from contour lesion type.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

%    dScreenSize  = get(groot, 'Screensize');

%    xSize = dScreenSize(3);
%    ySize = dScreenSize(4);
    
    ptrViewer3d = [];

    glVoiAllContoursMask = [];
    gp3DObject = [];
    gp3DContours = [];
    gp3DLine = [];
    gtReport = [];

    gdFarthestDistance = 0;

    gadFarthestXYZ1 = [];
    gadFarthestXYZ2 = [];

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end

    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 880;

    if viewerUIFigure('get') == true

        figContourReport = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                    FIG_REPORT_X ...
                    FIG_REPORT_Y],...
                    'Resize', 'off', ...
                    'Color', 'white',...
                    'Name' , 'TriDFusion (3DF) Contour Report'...
                    );
    else
        figContourReport = ...
            figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                   FIG_REPORT_X ...
                   FIG_REPORT_Y],...
                   'Name', 'TriDFusion (3DF) Contour Report',...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'Color', 'white', ...
                   'Toolbar','none'...
                   );
    end

    setObjectIcon(figContourReport);
    
    if viewerUIFigure('get') == true
        set(figContourReport, 'Renderer', 'opengl'); 
        set(figContourReport, 'GraphicsSmoothing', 'off'); 
    else
        set(figContourReport, 'Renderer', 'opengl'); 
        set(figContourReport, 'doublebuffer', 'on');   
    end

    figContourReportPtr('set', figContourReport);

    axeContourReport = ...
       axes(figContourReport, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
             'Color'   , 'white',...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
    axeContourReport.Interactions = [];
    % axeContourReport.Toolbar.Visible = 'off';
    deleteAxesToolbar(axeContourReport);
    disableDefaultInteractivity(axeContourReport);

%       uiContourReport = ...
%          uipanel(figContourReport,...
%                  'Units'   , 'pixels',...
%                  'position', [0 ...
%                               0 ...
%                               FIG_REPORT_X ...
%                               FIG_REPORT_Y*4 ...
%                               ],...
%                 'Visible', 'on', ...
%                 'BackgroundColor', 'white', ...
%                 'ForegroundColor', 'black' ...
%                 );
%
%     aContourReportPosition = get(figContourReport, 'position');
%     uiContourReportSlider = ...
%         uicontrol('Style'   , 'Slider', ...
%                   'Parent'  , figContourReport,...
%                   'Units'   , 'pixels',...
%                   'position', [aContourReportPosition(3)-15 ...
%                                0 ...
%                                15 ...
%                                aContourReportPosition(4) ...
%                                ],...
%                   'Value', 1, ...
%                   'Callback',@uiContourReportSliderCallback, ...
%                   'BackgroundColor', 'white', ...
%                   'ForegroundColor', 'black' ...
%                   );
%     addlistener(uiContourReportSlider, 'Value', 'PreSet', @uiContourReportSliderCallback);
%
%         uicontrol(uiContourReport,...
%                   'style'     , 'text',...
%                   'FontWeight', 'bold',...
%                   'FontSize'  , 12,...
%                   'FontName'  , 'MS Sans Serif', ...
%                   'string'    , ' TriDFusion (3DF) Contour Report',...
%                   'horizontalalignment', 'left',...
%                   'BackgroundColor', 'White', ...
%                   'ForegroundColor', 'Black', ...
%                   'position', [0 FIG_REPORT_Y-30 FIG_REPORT_X 20]...
%                   );
%
%         uicontrol(uiContourReport,...
%                   'style'     , 'text',...
%                   'FontWeight', 'Normal',...
%                   'FontSize'  , 10,...
%                   'FontName'  , 'MS Sans Serif', ...
%                   'string'    , sprintf(' Report Date: %s', char(datetime)),...
%                   'horizontalalignment', 'left',...
%                   'BackgroundColor', 'White', ...
%                   'ForegroundColor', 'Black', ...
%                   'position', [0 FIG_REPORT_Y-50 FIG_REPORT_X 20]...
%                   );


     uiContourReport = ...
         uipanel(figContourReport,...
                 'Units'   , 'pixels',...
                 'position', [0 ...
                              0 ...
                              FIG_REPORT_X ...
                              FIG_REPORT_Y*4 ...
                              ],...
                'Visible', 'on', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

    aContourReportPosition = get(figContourReport, 'position');
    uiContourReportSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , figContourReport,...
                  'Units'   , 'pixels',...
                  'position', [aContourReportPosition(3)-15 ...
                               0 ...
                               15 ...
                               aContourReportPosition(4) ...
                               ],...
                  'Value', 1, ...
                  'Callback',@uiContourReportSliderCallback, ...
                  'BackgroundColor', 'white', ...
                  'ForegroundColor', 'black' ...
                  );
%     addlistener(uiContourReportSlider, 'Value', 'PreSet', @uiContourReportSliderCallback);
    addlistener(uiContourReportSlider, 'ContinuousValueChange', @uiContourReportSliderCallback);

        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , ' TriDFusion (3DF) Contour Report',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-30 FIG_REPORT_X 20]...
                  );

        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , sprintf(' Report Date: %s', char(datetime)),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-50 FIG_REPORT_X 20]...
                  );


     % Patient Information

         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , ' Patient Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-80 FIG_REPORT_X/3-50 20]...
                  );

    uiReportPatientInformation = ...
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportPatientInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-465 FIG_REPORT_X/3-50 375]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     aUiExtent = get(uiReportPatientInformation, 'Extent');
    %     aUiPosition = get(uiReportPatientInformation, 'Position');
    %
    %     % Adjust the position to align the text at the top
    %     aNewUiPosition = [aUiPosition(1), aUiPosition(2) + aUiPosition(4) - aUiExtent(4) - 20, aUiPosition(3), aUiExtent(4) + 20];
    %
    %     set(uiReportPatientInformation, 'Position', aNewUiPosition);
    % end

    if viewerUIFigure('get') == true

        setUiExtendedPosition(uiReportPatientInformation);
    end

    % Series Information

         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Series Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-80 FIG_REPORT_X/3-90 20]...
                  );

   uiReportSeriesInformation = ...
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportSeriesInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-570 FIG_REPORT_X/3-90 480]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     aUiExtent = get(uiReportSeriesInformation, 'Extent');
    %     aUiPosition = get(uiReportSeriesInformation, 'Position');
    %
    %     % Adjust the position to align the text at the top
    %     aNewUiPosition = [aUiPosition(1), aUiPosition(2) + aUiPosition(4) - aUiExtent(4) - 20, aUiPosition(3), aUiExtent(4) + 20];
    %
    %     set(uiReportSeriesInformation, 'Position', aNewUiPosition);
    % end

    if viewerUIFigure('get') == true

        setUiExtendedPosition(uiReportSeriesInformation);
    end

    % Contours Information

         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Metabolic Metrics in Tumor Analysis',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-80 FIG_REPORT_X/3+100 20]...
                  );

         uiReportMTVContourInformation = ...
         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-110 FIG_REPORT_X/3+100 20]...
                  );

         uiReportTLGContourInformation = ...
         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-135 FIG_REPORT_X/3+100 20]...
                  );

         uiReportFDContourInformation = ...
         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-160 FIG_REPORT_X/3+100 20]...
                  );

         uiReportContourTitle = ...
         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Contours Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-200 FIG_REPORT_X/3+100 20]...
                  );

         uiContoursInformationReport = ...
         uipanel(uiContourReport,...
                 'Units'   , 'pixels',...
                 'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 ...
                              FIG_REPORT_Y-560 ...
                              510 ...
                              320 ...
                              ],...
                'Visible', 'on', ...
                'BorderType','none', ...
                'HighlightColor' , 'white', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

         aContourInformationUiPosition = get(uiContoursInformationReport, 'position');

         % if viewerUIFigure('get') == true
         %
         %     uiScrollableContoursInformationReport = ...
         %     uipanel(uiContoursInformationReport,...
         %             'Units'   , 'pixels',...
         %             'position', [0 ...
         %                          -((aContourInformationUiPosition(4)*4)-920) ...
         %                          aContourInformationUiPosition(3) ...
         %                          aContourInformationUiPosition(4)*4 ...
         %                          ],...
         %            'Visible', 'on', ...
         %            'HighlightColor' , 'white', ...
         %            'BackgroundColor', 'white', ...
         %            'ForegroundColor', 'black' ...
         %            );
         % else
             uiScrollableContoursInformationReport = ...
             uipanel(uiContoursInformationReport,...
                     'Units'   , 'pixels',...
                     'position', [0 ...
                                  -((aContourInformationUiPosition(4)*4)-320) ...
                                  aContourInformationUiPosition(3) ...
                                  aContourInformationUiPosition(4)*4 ...
                                  ],...
                    'Visible', 'on', ...
                    'BorderType','none', ...
                    'HighlightColor' , 'white', ...
                    'BackgroundColor', 'white', ...
                    'ForegroundColor', 'black' ...
                    );
        % end

        gaContourInformationScrollableUiPosition = get(uiScrollableContoursInformationReport, 'position');

        uiContoursInformation = ...
        uicontrol(uiContourReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_REPORT_X-35 aContourInformationUiPosition(2) 15 aContourInformationUiPosition(4)], ...
                  'Value'   , 1, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Intensity', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @sliderScrollableContoursInformationCallback ...
                  );
%         addlistener(uiContoursInformation, 'Value', 'PreSet', @sliderScrollableContoursInformationCallback);
        addlistener(uiContoursInformation, 'ContinuousValueChange', @sliderScrollableContoursInformationCallback);

         % Contour Type

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Site',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 FIG_REPORT_Y-230 115 20]...
                  );

        uiReportContourType = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionTypeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 -10 115 gaContourInformationScrollableUiPosition(4)]...
                  );

         % Nb Contour

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Nb VOI',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-30 FIG_REPORT_Y-230 60 20]...
                  );

        uiReportLesionNbContour = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionNbContourInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [100 -10 60 gaContourInformationScrollableUiPosition(4)]...
                  );

         % Contour Mean

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Mean',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+45 FIG_REPORT_Y-230 75 20]...
                  );

        uiReportLesionMean = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [170 -10 75 gaContourInformationScrollableUiPosition(4)]...
                  );

         % Contour Max

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Max',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+125 FIG_REPORT_Y-230 75 20]...
                  );

        uiReportLesionMax = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMaxInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [255 -10 80 gaContourInformationScrollableUiPosition(4)]...
                  );

         % Contour Peak

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Peak',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-230 75 20]...
                  );

        uiReportLesionPeak = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionPeakInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [340 -10 75 gaContourInformationScrollableUiPosition(4)]...
                  );

          % Contour Volume

          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Volume (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+300 FIG_REPORT_Y-230 80 20]...
                  );

        uiReportLesionVolume = ...
        uicontrol(uiScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [425 -10 80 gaContourInformationScrollableUiPosition(4)]...
                  );

        % Volume Histogram

       [~, asLesionList, ~] = getLesionType('');
       gasLesionType = [{'All Contours'}, asLesionList(:)'];

       popReportVolumeHistogram = ...
       uicontrol(uiContourReport, ...
                 'Style'   , 'popup', ...
                 'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-130 280 525 20], ...
                 'String'  , gasLesionType, ...
                 'Value'   , 1 ,...
                 'Enable'  , 'on', ...
                 'BackgroundColor', 'white', ...
                 'ForegroundColor', 'black', ...
                 'Callback', @setReportVolumeHistogramCallback...
                 );

        axeReport = ...
        axes(uiContourReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-95 50 480 200], ...
             'Color'   , 'White',...
             'XColor'  , 'Black',...
             'YColor'  , 'Black',...
             'ZColor'  , 'Black',...
             'Visible' , 'on'...
             );
    axeReport.Interactions = [];
    % axeReport.Toolbar.Visible = 'off';
    deleteAxesToolbar(axeReport);
    disableDefaultInteractivity(axeReport);

    axeReport.Title.String  = 'Uptake Volume Histogram (UVH)';
    axeReport.XLabel.String = 'Uptake';
    axeReport.YLabel.String = 'Total Volume Fraction (TVF)';

    % 3D Volume

     atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

     if ~strcmpi(atMetaData{1}.Modality, 'CT') && ...
        ~strcmpi(atMetaData{1}.Modality, 'MR')

        ui3DWindow = ...
        uipanel(uiContourReport,...
                'Units'   , 'pixels',...
                'BorderType', 'none',...
                'BackgroundColor', 'white',...
                'position', [21 15 FIG_REPORT_X/3-75-15 340]...
                );

        if viewerUIFigure('get') == true
            dIntensity = 0.9;
        else
            dIntensity = 0.8;
        end

        uiSlider3Dintensity = ...
        uicontrol(uiContourReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [5 15 15 340], ...
                  'Value'   , dIntensity, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Intensity', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @slider3DintensityCallback ...
                  );
%         addlistener(uiSlider3Dintensity, 'Value', 'PreSet', @slider3DintensityCallback);
        addlistener(uiSlider3Dintensity, 'ContinuousValueChange', @slider3DintensityCallback);

     else
        ui3DWindow = ...
        uipanel(uiContourReport,...
                'Units'   , 'pixels',...
                'BorderType', 'none',...
                'BackgroundColor', 'white',...
                'position', [5 15 FIG_REPORT_X/3-75 340]...
                );
     end

     % 3D Rendering

      uicontrol(uiContourReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , '3D Rendering',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [5 ui3DWindow.Position(4)+70 FIG_REPORT_X/3-75 20]...
              );

    if exist(sprintf('%s/icons/full-screen-black.png', viewerRootPath('get')), 'file')
        [imgFullScreenIcon,~] = imread(sprintf('%s/icons/full-screen-black.png', viewerRootPath('get')));
        imgFullScreenIcon = double(imgFullScreenIcon)/255;
    else
        imgFullScreenIcon = zeros([16 16 3]);
    end

    btnContourReport3DRenderingFullScreen = ...
        uicontrol(uiContourReport, ...
                 'Position'       , [FIG_REPORT_X/3-75-20 ui3DWindow.Position(4)+20 20 20], ...
                 'Enable'         , 'off', ...
                 'String'         , '',...
                 'BackgroundColor', 'White', ...
                 'ForegroundColor', 'Black', ...
                 'TooltipString'  , 'Full Screen', ...
                 'CData'          , imgFullScreenIcon, ...
                 'UserData'       , false, ...
                 'CallBack'       , @btnContourReport3DRenderingFullScreenCallback ...
                 );

    chkContourReportViewContours = ...
        uicontrol(uiContourReport,...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , 1,...
                  'position', [5 ui3DWindow.Position(4)+40 20 20],...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'Callback', @chkContourReportViewContoursCallback...
                  );

  txtContourReportViewContours = ...
     uicontrol(uiContourReport,...
              'style'     , 'text',...
              'Enable'    , 'off',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'View contours',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'ButtonDownFcn', @chkContourReportViewContoursCallback, ...
              'position', [25 ui3DWindow.Position(4)+37 FIG_REPORT_X/3-75-60 20]...
              );

    chkContourReportViewFarthestDistance = ...
        uicontrol(uiContourReport,...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , 1,...
                  'position', [5 ui3DWindow.Position(4)+20 20 20],...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'Callback', @chkContourReportViewFarthestDistanceCallback...
                  );

  txtContourReportViewFarthestDistance = ...
     uicontrol(uiContourReport,...
              'style'     , 'text',...
              'Enable'    , 'off',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'View maximal distance',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'ButtonDownFcn', @chkContourReportViewFarthestDistanceCallback, ...
              'position', [25 ui3DWindow.Position(4)+17 FIG_REPORT_X/3-75-60 20]...
              );

    % Notes

    uiEditWindow = ...
    uicontrol(uiContourReport,...
              'style'     , 'edit',...
              'FontWeight', 'Normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-95 250]...
             );
    set(uiEditWindow, 'Min', 0, 'Max', 2);

         uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Notes',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 uiEditWindow.Position(4)+30 FIG_REPORT_X/3-115 20]...
                  );

    mReportFile = uimenu(figContourReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export report to .pdf...'             , 'Callback', @exportCurrentReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export report to DICOM print...'      , 'Callback', @exportCurrentReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Export axial slices to .avi...'       , 'Callback', @exportCurrentReportAxialSlicesToAviCallback, 'Separator','on');
    uimenu(mReportFile,'Label', 'Export axial slices to DICOM movie...', 'Callback', @exportCurrentReportAxialSlicesToDicomMovieCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(figContourReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyReportDisplayCallback);

    mReportOptions = uimenu(figContourReport,'Label','Options', 'Callback', @figReportRefreshOption);

    if suvMenuUnitOption('get') == true && ...
       atInput(dSeriesOffset).bDoseKernel == false

        sUnitDisplay = getSerieUnitValue(dSeriesOffset);
        if strcmpi(sUnitDisplay, 'SUV')
            sSuvChecked = 'on';
        else
            % if suvMenuUnitOption('get') == true
            %     suvMenuUnitOption('set', false);
            % end
            sSuvChecked = 'off';
        end
    else
        % if suvMenuUnitOption('get') == true
        %     suvMenuUnitOption('set', false);
        % end
        sSuvChecked = 'off';
    end

    if modifiedMatrixValueMenuOption('get') == true
       sModifiedMatrixChecked = 'on';
    else
        if atInput(dSeriesOffset).tMovement.bMovementApplied == true
            sModifiedMatrixChecked = 'on';
            modifiedMatrixValueMenuOption('set', true);
        else
            sModifiedMatrixChecked = 'off';
            modifiedMatrixValueMenuOption('set', false);
        end
    end

    if segMenuOption('get') == true
        if modifiedMatrixValueMenuOption('get') == false
            segMenuOption('set', 'off');
            sSegChecked = 'off';
        else
            sSegChecked = 'on';
        end
    else
        sSegChecked = 'off';
    end

    if atInput(dSeriesOffset).bDoseKernel == true
        sSuvEnable = 'off';
    else
        sUnitDisplay = getSerieUnitValue(dSeriesOffset);
        if strcmpi(sUnitDisplay, 'SUV')
            sSuvEnable = 'on';
        else
            sSuvEnable = 'off';
        end
    end

    if centroidMenuOption('get') == true
        sCentroidChecked = 'on';
    else
        sCentroidChecked = 'off';
    end

    mSUVUnit        = ...
        uimenu(mReportOptions, 'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @reportSUVUnitCallback);

    mModifiedMatrix = ...
        uimenu(mReportOptions, 'Label', 'Display Image Cells Value' , 'Checked', sModifiedMatrixChecked, 'Callback', @reportModifiedMatrixCallback);

    mSegmented      = ...
        uimenu(mReportOptions, 'Label', 'Subtract Masked Cells' , 'Checked', sSegChecked, 'Callback', @reportSegmentedCallback);

    mCentroid      = ...
        uimenu(mReportOptions, 'Label', 'Maximal distance from the centroid' , 'Checked', sCentroidChecked, 'Callback', @reportCentroidCallback);

    setReportFigureName();

    refreshReportLesionInformation(suvMenuUnitOption('get'), modifiedMatrixValueMenuOption('get'), modifiedMatrixValueMenuOption('get'), centroidMenuOption('get'));

    if bExportToPdf == true

        exportContourReportToPdf(figContourReport, axeContourReport, sPdfFileName);

        close(figContourReport);       
    end

    function refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid)

        if isvalid(figContourReport)
            set(figContourReport, 'Pointer', 'watch');
            drawnow;
        end

        set(btnContourReport3DRenderingFullScreen, 'Enable', 'off');

        set(chkContourReportViewContours, 'Enable', 'off');
        set(txtContourReportViewContours, 'Enable', 'off');

        set(chkContourReportViewFarthestDistance, 'Enable', 'off');
        set(txtContourReportViewFarthestDistance, 'Enable', 'off');

        [gtReport, glVoiAllContoursMask, gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid);

        if ~isempty(gtReport) % Fill information

            if isvalid(uiReportContourTitle)
                set(uiReportContourTitle, 'String', sprintf('Contours Information (%s)', getReportUnitValue()));
            end

             if isvalid(uiReportContourType) % Make sure the figure is still open

                set(uiReportContourType, 'String', getReportLesionTypeInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportContourType);
                end
             end

            if isvalid(uiReportMTVContourInformation) % Make sure the figure is still open
                set(uiReportMTVContourInformation, 'String', sprintf('Metabolic Tumor Volume (MTV): %s (ml)',  num2str(gtReport.All.Volume)));
            end

            if isvalid(uiReportTLGContourInformation) % Make sure the figure is still open
                set(uiReportTLGContourInformation, 'String', sprintf('Total Lesion Glycolysis    (TLG): %s (%s)', num2str(gtReport.All.Volume*gtReport.All.Mean), getReportUnitValue()));
            end

            if isvalid(uiReportFDContourInformation) % Make sure the figure is still open
                set(uiReportFDContourInformation, 'String', sprintf('Maximal distance between contours (Dmax): %s (mm)',  num2str(gdFarthestDistance)));
            end

            if isvalid(uiReportLesionNbContour) % Make sure the figure is still open

                set(uiReportLesionNbContour, 'String', getReportLesionNbContourInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionNbContour);
                end
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open

                set(uiReportLesionMean, 'String', getReportLesionMeanInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionMean);
                end
            end

            if isvalid(uiReportLesionMax) % Make sure the figure is still open

                set(uiReportLesionMax, 'String', getReportLesionMaxInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionMax);
                end
            end

            if isvalid(uiReportLesionPeak) % Make sure the figure is still open

                set(uiReportLesionPeak, 'String', getReportLesionPeakInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionPeak);
                end
            end

            if isvalid(uiReportLesionVolume) % Make sure the figure is still open

                set(uiReportLesionVolume, 'String', getReportLesionVolumeInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionVolume);
                end
            end

            if isvalid(axeReport) % Make sure the figure is still open

                aAxeReportPosition = get(axeReport, 'position');

                delete(axeReport);

                axeReport = ...
                axes(uiContourReport, ...
                     'Units'   , 'pixels', ...
                     'Position', aAxeReportPosition, ...
                     'Color'   , 'White',...
                     'XColor'  , 'Black',...
                     'YColor'  , 'Black',...
                     'ZColor'  , 'Black',...
                     'Visible' , 'on'...
                     );
                axeReport.Interactions = [];
                % axeReport.Toolbar.Visible = 'off';
                deleteAxesToolbar(axeReport);
                disableDefaultInteractivity(axeReport);

                try

                    ptrPlotCummulative = plotCummulative(axeReport, gtReport.All.voiData, 'black');
                    
                    if ~isempty(ptrPlotCummulative)
                        axeReport.Title.String  = ' All Contours - Uptake Volume Histogram (UVH)';
                        axeReport.XLabel.String = sprintf('Uptake (%s)', getReportUnitValue());
                        axeReport.YLabel.String = 'Total Volume Fraction (TVF)';
    
                        cDataCursor = datacursormode(figContourReport);
                        cDataCursor.UpdateFcn = @updateCursorCoordinates;
                        set(cDataCursor, 'Enable', 'off');
    
    
                        dTip = createDatatip(cDataCursor, ptrPlotCummulative);
                        dTip.Position(2) = 0.90;
    
                        aXData = get(ptrPlotCummulative, 'XData');
                        aYData = get(ptrPlotCummulative, 'YData');
    
                        [aYData,idx] = unique(aYData) ;
                        aXData = aXData(idx) ;
    
                        if numel(aYData) >= 2
    
                            dD90 = interp1(aYData, aXData, .9);
                            dD50 = interp1(aYData, aXData, .5);
                            dD10 = interp1(aYData, aXData, .1);
        
                            text(axeReport, max(aXData)*0.8, max(aYData)*0.95, sprintf('90%%: %.0f', dD90));
                            text(axeReport, max(aXData)*0.8, max(aYData)*0.87, sprintf('50%%: %.0f', dD50));
                            text(axeReport, max(aXData)*0.8, max(aYData)*0.79, sprintf('10%%: %.0f', dD10));
                        end
                    end

                catch ME
                    logErrorToFile(ME);
                end
            end

        end

        if isvalid(ui3DWindow)
            
            display3Dobject(bModifiedMatrix);
        end

        set(btnContourReport3DRenderingFullScreen, 'Enable', 'on');

        if ~isempty(glVoiAllContoursMask)

            set(chkContourReportViewContours, 'Enable', 'on');
            set(txtContourReportViewContours, 'Enable', 'inactive');
        end

        if gdFarthestDistance ~= 0

            set(chkContourReportViewFarthestDistance, 'Enable', 'on');
            set(txtContourReportViewFarthestDistance, 'Enable', 'inactive');
        end

        if isvalid(figContourReport)
            set(figContourReport, 'Pointer', 'default');
            drawnow;
        end
    end

    function txt = updateCursorCoordinates(~,info)

        x = info.Position(1);
        y = info.Position(2);
        txt = ['(' sprintf('%.0f', x) ', ' sprintf('%.2f', y) ')'];

        set( axeReport.XLabel, 'String', sprintf('Uptake (%s)', getReportUnitValue() ) );
        set( axeReport.YLabel, 'String', sprintf('Total Volume Fraction (TVF)') );

    end

    function setReportFigureName()

        if ~isvalid(figContourReport)
            return;
        end

        atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            sSegmented = ' - Masked Cells Subtracted';
        else
            sSegmented = '';
        end

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            sModified = ' - Cells Value: Display Image';
        else
            sModified = ' - Cells Value: Unmodified Image';
        end

        sUnit = sprintf('Unit: %s', getReportUnitValue());

        figContourReport.Name = ['TriDFusion (3DF) Contour Report - ' atMetaData{1}.SeriesDescription ' - ' sUnit sModified sSegmented];

        if isvalid(uiReportContourTitle)
            set(uiReportContourTitle, 'String', sprintf('Contours Information (%s)', getReportUnitValue()));
        end
    end

    function sUnit = getReportUnitValue()

        atInput = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        if atInput(dSeriesOffset).bDoseKernel == true

            if isfield(atMetaData{1}, 'DoseUnits')

                if ~isempty(atMetaData{1}.DoseUnits)

                    sUnit = char(atMetaData{1}.DoseUnits);
                else
                    sUnit = 'dose';
                end
            else
                sUnit = 'dose';
            end
        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnit = getSerieUnitValue(dSeriesOffset);
                if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(sUnit, 'SUV' )
                    sSUVtype = viewerSUVtype('get');
                    sUnit =  sprintf('SUV/%s', sSUVtype);
                else
                    if (strcmpi(atMetaData{1}.Modality, 'ct'))
                       sUnit =  'HU';
                    else
                       sUnit =  'Counts';
                    end
                end
            else
                 if (strcmpi(atMetaData{1}.Modality, 'ct'))
                    sUnit =  'HU';
                 else
                    sUnit = getSerieUnitValue(dSeriesOffset);
                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(sUnit, 'SUV' )
                        sUnit =  'BQML';
                    else

                        sUnit =  'Counts';
                    end
                 end
            end
         end
    end

    function figReportRefreshOption(~, ~)

        if suvMenuUnitOption('get') == true
            sSuvChecked = 'on';
        else
            sSuvChecked = 'off';
        end

        if modifiedMatrixValueMenuOption('get') == true
            sModifiedMatrixChecked = 'on';
        else
            sModifiedMatrixChecked = 'off';
        end

        if segMenuOption('get') == true
            sSegChecked = 'on';
        else
            sSegChecked = 'off';
        end

        if centroidMenuOption('get') == true
            sCentroidChecked = 'on';
        else
            sCentroidChecked = 'off';
        end

        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mModifiedMatrix  , 'Checked', sModifiedMatrixChecked);
        set(mSegmented       , 'Checked', sSegChecked);
        set(mCentroid        , 'Checked', sCentroidChecked);

    end

    function reportSUVUnitCallback(hObject, ~)

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            bSegmented = true;
        else
            bSegmented = false;
        end

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end

        if strcmpi(get(mCentroid, 'Checked'), 'on')
            bCentroid = true;
        else
            bCentroid = false;
        end

        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);

            refreshReportLesionInformation(false, bModifiedMatrix, bSegmented, bCentroid);
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);

            refreshReportLesionInformation(true, bModifiedMatrix, bSegmented, bCentroid);
        end

        setReportFigureName();
    end

    function reportModifiedMatrixCallback(hObject, ~)

        atInput = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if strcmpi(get(mSUVUnit, 'Checked'), 'on')
            bSUVUnit = true;
        else
            bSUVUnit = false;
        end

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            bSegmented = true;
        else
            bSegmented = false;
        end

        if strcmpi(get(mCentroid, 'Checked'), 'on')
            bCentroid = true;
        else
            bCentroid = false;
        end

        if strcmpi(hObject.Checked, 'on')

            if atInput(dSeriesOffset).tMovement.bMovementApplied == true
                modifiedMatrixValueMenuOption('set', true);
                hObject.Checked = 'on';

                refreshReportLesionInformation(bSUVUnit, true, bSegmented, bCentroid);
            else
                modifiedMatrixValueMenuOption('set', false);
                hObject.Checked = 'off';

                segMenuOption('set', false);
                set(mSegmented, 'Checked', 'off');

                refreshReportLesionInformation(bSUVUnit, false, false, bCentroid);
            end
        else
            modifiedMatrixValueMenuOption('set', true);
            hObject.Checked = 'on';

            refreshReportLesionInformation(bSUVUnit, true, bSegmented, bCentroid);
       end

        setReportFigureName();
    end

    function reportSegmentedCallback(hObject, ~)

        if strcmpi(get(mSUVUnit, 'Checked'), 'on')
            bSUVUnit = true;
        else
            bSUVUnit = false;
        end

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end

        if strcmpi(get(mCentroid, 'Checked'), 'on')
            bCentroid = true;
        else
            bCentroid = false;
        end

        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            segMenuOption('set', false);

            refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, false, bCentroid);
        else
            if bModifiedMatrix == true
                hObject.Checked = 'on';
                segMenuOption('set', true);

                refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, true, bCentroid);
            else
                hObject.Checked = 'off';
                segMenuOption('set', false);
            end
       end

        setReportFigureName();
    end

    function reportCentroidCallback(hObject, ~)

        if strcmpi(get(mSUVUnit, 'Checked'), 'on')
            bSUVUnit = true;
        else
            bSUVUnit = false;
        end

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            bSegmented = true;
        else
            bSegmented = false;
        end

        if strcmpi(hObject.Checked, 'on')

            hObject.Checked = 'off';
            centroidMenuOption('set', false);

            refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, false);
        else
            centroidMenuOption('set', true);

            refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, true);
       end

        setReportFigureName();
    end

    function sReport = getReportLesionTypeInformation(sAction, tReport)

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n_________', char('Summary'));
        else

            sReport = sprintf('%s\n_________', char('Summary'));

            [~, asLesionList, ~] = getLesionType('');

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Count)
                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Count)

                            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
                        end

                end
            end
        end
    end

    function sReport = getReportLesionNbContourInformation(sAction, tReport)

        [~, asLesionList, ~] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n_______', '-');
        else

            if ~isempty(tReport.All.Count)
                sReport = sprintf('%-8s\n_______', num2str(tReport.All.Count));
            else
                sReport = sprintf('%s\n_______', '-');
            end

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Unspecified.Count));
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Bone.Count));
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.SoftTissue.Count));
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Lung.Count));
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Liver.Count));
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Parotid.Count));
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.BloodPool.Count));
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.LymphNodes.Count));
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.PrimaryDisease.Count));
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Cervical.Count));
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Supraclavicular.Count));
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Mediastinal.Count));
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Paraspinal.Count));
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Axillary.Count));
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Abdominal.Count));
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Count)

                            sReport = sprintf('%s\n\n%-8s', sReport, num2str(tReport.Necrotic.Count));
                        end

                    otherwise

                end
            end
        end
    end

    function sReport = getReportLesionMeanInformation(sAction, tReport)

        [~, asLesionList, ~] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n________', '-');
        else

            if ~isempty(tReport.All.Mean)

                sReport = sprintf('%-.2f\n________', tReport.All.Mean);
            else
                sReport = sprintf('%s\n________', '-');
            end

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Unspecified.Mean);
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Bone.Mean);
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.SoftTissue.Mean);
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Lung.Mean);
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Mean);
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Parotid.Mean);
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.BloodPool.Mean);
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LymphNodes.Mean);
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.PrimaryDisease.Mean);
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Cervical.Mean);
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Supraclavicular.Mean);
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Mediastinal.Mean);
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Paraspinal.Mean);
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Axillary.Mean);
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Abdominal.Mean);
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Mean)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Necrotic.Mean);
                        end                        

                    otherwise
                end
            end
        end
    end

    function sReport = getReportLesionMaxInformation(sAction, tReport)

        [~, asLesionList, ~] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n________', '-');
        else

            if ~isempty(tReport.All.Max)

                sReport = sprintf('%-.2f\n________', tReport.All.Max);
            else
                sReport = sprintf('%s\n________', '-');
            end

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Unspecified.Max);
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Bone.Max);
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.SoftTissue.Max);
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Lung.Max);
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Max);
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Parotid.Max);
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.BloodPool.Max);
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LymphNodes.Max);
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Max)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.PrimaryDisease.Max);
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Cervical.Max);
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Supraclavicular.Max);
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Mediastinal.Max);
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Paraspinal.Max);
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Axillary.Max);
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Abdominal.Max);
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Max)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Necrotic.Max);
                        end                        

                    otherwise

                end
            end
        end
    end

    function sReport = getReportLesionPeakInformation(sAction, tReport)

        [~, asLesionList, ~] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n________', '-');
        else

            if ~isempty(tReport.All.Peak)

                sReport = sprintf('%-.2f\n________', tReport.All.Peak);
            else
                sReport = sprintf('%s\n________', '-');
            end

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Unspecified.Peak);
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Bone.Peak);
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.SoftTissue.Peak);
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Lung.Peak);
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Peak);
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Parotid.Peak);
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.BloodPool.Peak);
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LymphNodes.Peak);
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Peak)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.PrimaryDisease.Peak);
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Cervical.Peak);
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Supraclavicular.Peak);
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Mediastinal.Peak);
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Paraspinal.Peak);
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Axillary.Peak);
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Abdominal.Peak);
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Peak)

                            sReport = sprintf('%s\n\n%.2f', sReport, tReport.Necrotic.Peak);
                        end                        

                    otherwise

                end
            end
        end
    end

    function sReport = getReportLesionVolumeInformation(sAction, tReport)

        [~, asLesionList, ~] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = sprintf('%s\n________', '-');
        else

            if ~isempty(tReport.All.Volume)

                sReport = sprintf('%-.3f\n________', tReport.All.Volume);
            else
                sReport = sprintf('%s\n________', '-');
            end

            for ll=1:numel(asLesionList)

                switch lower(asLesionList{ll})

                    case 'unspecified'

                        if ~isempty(tReport.Unspecified.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Unspecified.Volume);
                        end

                    case 'bone'

                        if ~isempty(tReport.Bone.Count)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Bone.Volume);
                        end

                    case 'soft tissue'

                        if ~isempty(tReport.SoftTissue.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.SoftTissue.Volume);
                        end

                    case 'lung'

                        if ~isempty(tReport.Lung.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Lung.Volume);
                        end

                    case 'liver'

                        if ~isempty(tReport.Liver.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Liver.Volume);
                        end

                    case 'parotid'

                        if ~isempty(tReport.Parotid.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Parotid.Volume);
                        end

                    case 'blood pool'

                        if ~isempty(tReport.BloodPool.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.BloodPool.Volume);
                        end

                    case 'lymph nodes'

                        if ~isempty(tReport.LymphNodes.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LymphNodes.Volume);
                        end

                    case 'primary disease'

                        if ~isempty(tReport.PrimaryDisease.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.PrimaryDisease.Volume);
                        end

                    case 'cervical'

                        if ~isempty(tReport.Cervical.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Cervical.Volume);
                        end

                     case 'supraclavicular'

                        if ~isempty(tReport.Supraclavicular.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Supraclavicular.Volume);
                        end

                     case 'mediastinal'

                        if ~isempty(tReport.Mediastinal.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Mediastinal.Volume);
                        end

                    case 'paraspinal'

                        if ~isempty(tReport.Paraspinal.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Paraspinal.Volume);
                        end

                    case 'axillary'

                        if ~isempty(tReport.Axillary.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Axillary.Volume);
                        end

                    case 'abdominal'

                        if ~isempty(tReport.Abdominal.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Abdominal.Volume);
                        end

                    case 'necrotic'

                        if ~isempty(tReport.Necrotic.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Necrotic.Volume);
                        end                        

                    otherwise

                end
            end
        end
    end

    function exportCurrentReportToPdfCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        try

        filter = {'*.pdf'};

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastReportDir.mat'];

        % load last data directory

        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load(sMatFile, 'saveReportLastUsedDir');

            if exist('saveReportLastUsedDir', 'var')
               sCurrentDir = saveReportLastUsedDir;
            end

            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
         end

  %      sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        % Series Date

        sSeriesDate = atMetaData{1}.SeriesDate;

        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save contour report', sprintf('%s/%s_%s_%s_%s_CONTOUR_REPORT_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(figContourReport, 'Pointer', 'watch');
        drawnow;

        if file ~= 0

            try
                saveReportLastUsedDir = path;
                save(sMatFile, 'saveReportLastUsedDir');
                
            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end

            sFileName = sprintf('%s%s', path, file);

            if exist(sFileName, 'file')
                delete(sFileName);
            end

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            exportContourReportToPdf(figContourReport, axeContourReport, sFileName);

            progressBar( 1 , sprintf('Export %s completed.', sFileName));

            try
                winopen(sFileName);
            catch ME
                logErrorToFile(ME);
            end
        end

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: exportCurrentReportToPdfCallback() cant export report' );
        end

        set(figContourReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentReportAxialSlicesToAviCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        % bMipPlayback = playback2DMipOnly('get');
        sPlaybackPlane = default2DPlaybackPlane('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

    %         figContourReport = figContourReportPtr('get');

        filter = {'*.avi'};

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastReportDir.mat'];

        % load last data directory
        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load(sMatFile, 'saveReportLastUsedDir');

            if exist('saveReportLastUsedDir', 'var')
               sCurrentDir = saveReportLastUsedDir;
            end

            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end

     %   sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        % Series Date

        sSeriesDate = atMetaData{1}.SeriesDate;

        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save contour report axial slices', sprintf('%s/%s_%s_%s_%s_CONTOUR_REPORT_AXIAL_SLICES_TriDFusion.avi' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(figContourReport, 'Pointer', 'watch');
        drawnow;

        if file ~= 0

            try
                saveReportLastUsedDir = path;
                save(sMatFile, 'saveReportLastUsedDir');

            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end

            sFileName = sprintf('%s%s', path, file);

            if exist(sFileName, 'file')
                delete(sFileName);
            end

            if ~contains(file, '.avi')
                file = [file, '.avi'];
            end

            % playback2DMipOnly('set', false);

            set(chkUiCorWindowSelectedPtr('get'), 'Value', false);
            set(chkUiSagWindowSelectedPtr('get'), 'Value', false);
            set(chkUiTraWindowSelectedPtr('get'), 'Value', true);
            set(chkUiMipWindowSelectedPtr('get'), 'Value', false);

            default2DPlaybackPlane('set', 'axial');

            sliceNumber('set', 'axial', size(dicomBuffer('get', [], dSeriesOffset), 3));

            multiFrameRecord('set', true);

            set(recordIconMenuObject('get'), 'State', 'on');

            recordMultiFrame(recordIconMenuObject('get'), path, file, 'avi');

        end

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: exportCurrentReportAxialSlicesToAviCallback() cant export report' );
        end

        % playback2DMipOnly('set', bMipPlayback);

        set(chkUiCorWindowSelectedPtr('get'), 'Value', false);
        set(chkUiSagWindowSelectedPtr('get'), 'Value', false);
        set(chkUiTraWindowSelectedPtr('get'), 'Value', false);
        set(chkUiMipWindowSelectedPtr('get'), 'Value', false);

        switch lower(sPlaybackPlane)
            case 'coronal'
                set(chkUiCorWindowSelectedPtr('get'), 'Value', true);
            case 'sagittal'
                set(chkUiSagWindowSelectedPtr('get'), 'Value', true);
            case 'axial'
                set(chkUiTraWindowSelectedPtr('get'), 'Value', true);
            otherwise
                set(chkUiMipWindowSelectedPtr('get'), 'Value', true);
        end

        default2DPlaybackPlane('set', sPlaybackPlane);

        multiFrameRecord('set', false);

        set(recordIconMenuObject('get'), 'State', 'off');

        sliceNumber('set', 'axial', dAxialSliceNumber);

        sliderTraCallback();

        set(figContourReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentReportAxialSlicesToDicomMovieCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % bMipPlayback = playback2DMipOnly('get');
        sPlaybackPlane = default2DPlaybackPlane('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

%         figContourReport = figContourReportPtr('get');

        sOutDir = outputDir('get');

        if isempty(sOutDir)

            sCurrentDir  = viewerRootPath('get');

            sMatFile = [sCurrentDir '/' 'lastWriteDicomDir.mat'];

            % load last data directory

            if exist(sMatFile, 'file') % lastDirMat mat file exists, load it

               load(sMatFile, 'exportDicomLastUsedDir');

               if exist('exportDicomLastUsedDir', 'var')

                   sCurrentDir = exportDicomLastUsedDir;
               end

               if sCurrentDir == 0

                   sCurrentDir = pwd;
               end
            end

            sOutDir = uigetdir(sCurrentDir);

            if sOutDir == 0

                return;
            end
            sOutDir = [sOutDir '/'];

%             sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
%             sWriteDir = char(sOutDir) + "TriDFusion_MFSC_" + char(sDate) + '/';
%             if ~(exist(char(sWriteDir), 'dir'))
%                 mkdir(char(sWriteDir));
%             end

            try
                exportDicomLastUsedDir = sOutDir;
                save(sMatFile, 'exportDicomLastUsedDir');

            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end
        end

        set(figContourReport, 'Pointer', 'watch');
        drawnow;

        % playback2DMipOnly('set', false);

        set(chkUiCorWindowSelectedPtr('get'), 'Value', false);
        set(chkUiSagWindowSelectedPtr('get'), 'Value', false);
        set(chkUiTraWindowSelectedPtr('get'), 'Value', true);
        set(chkUiMipWindowSelectedPtr('get'), 'Value', false);

        default2DPlaybackPlane('set', 'axial');

        sliceNumber('set', 'axial', size(dicomBuffer('get', [], dSeriesOffset), 3));

        multiFrameRecord('set', true);

        set(recordIconMenuObject('get'), 'State', 'on');

        recordMultiFrame(recordIconMenuObject('get'), sOutDir, [], 'dcm');

%         objectToDicomJpg(sWriteDir, figContourReport, '3DF MFSC', get(uiSeriesPtr('get'), 'Value'))

        catch ME
            logErrorToFile(ME);   
            progressBar( 1 , 'Error: exportCurrentReportAxialSlicesToDicomMovieCallback() cant export report' );
        end

        % playback2DMipOnly('set', bMipPlayback);

        set(chkUiCorWindowSelectedPtr('get'), 'Value', false);
        set(chkUiSagWindowSelectedPtr('get'), 'Value', false);
        set(chkUiTraWindowSelectedPtr('get'), 'Value', false);
        set(chkUiMipWindowSelectedPtr('get'), 'Value', false);

        switch lower(sPlaybackPlane)
            case 'coronal'
                set(chkUiCorWindowSelectedPtr('get'), 'Value', true);
            case 'sagittal'
                set(chkUiSagWindowSelectedPtr('get'), 'Value', true);
            case 'axial'
                set(chkUiTraWindowSelectedPtr('get'), 'Value', true);
            otherwise
                set(chkUiMipWindowSelectedPtr('get'), 'Value', true);
        end

        default2DPlaybackPlane('set', sPlaybackPlane);

        multiFrameRecord('set', false);

        set(recordIconMenuObject('get'), 'State', 'off');

        sliceNumber('set', 'axial', dAxialSliceNumber);

        sliderTraCallback();

        set(figContourReport, 'Pointer', 'default');
        drawnow;
    end

    function copyReportDisplayCallback(~, ~)

        try

            set(figContourReport, 'Pointer', 'watch');
            drawnow;

            copyFigureToClipboard(figContourReport);

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: copyReportDisplayCallback() cant copy report' );
        end

        set(figContourReport, 'Pointer', 'default');
        drawnow;

    end

    function display3Dobject(bModifiedMatrix)

        a3DWindowPosition = get(ui3DWindow, 'position');

        delete(ui3DWindow);

        ui3DWindow = ...
        uipanel(uiContourReport,...
                'Units'          , 'pixels',...
                'BorderType'     , 'none',...
                'BackgroundColor', 'white',...
                'position'       , a3DWindowPosition...
                );

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

         % Can't use input buffer if movement have been applied

        if bModifiedMatrix == false && bMovementApplied == false

            atMetaData = atInput(dSeriesOffset).atDicomInfo;
            aBuffer    = inputBuffer('get');

            aBuffer = aBuffer{dSeriesOffset};

            if     strcmpi(imageOrientation('get'), 'axial')
%                 aBuffer = aBuffer;
            elseif strcmpi(imageOrientation('get'), 'coronal')
                aBuffer = reorientBuffer(aBuffer, 'coronal');
            elseif strcmpi(imageOrientation('get'), 'sagittal')
                aBuffer = reorientBuffer(aBuffer, 'sagittal');
            end

            if size(aBuffer, 3) ==1

                if atInput(dSeriesOffset).bFlipLeftRight == true
                    aBuffer=aBuffer(:,end:-1:1);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aBuffer=aBuffer(end:-1:1,:);
                end
            else
                if atInput(dSeriesOffset).bFlipLeftRight == true
                    aBuffer=aBuffer(:,end:-1:1,:);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aBuffer=aBuffer(end:-1:1,:,:);
                end

                if atInput(dSeriesOffset).bFlipHeadFeet == true
                    aBuffer=aBuffer(:,:,end:-1:1);
                end
            end

            x = atMetaData{1}.PixelSpacing(1);
            y = atMetaData{1}.PixelSpacing(2);
            z = computeSliceSpacing(atMetaData);
        else
            atMetaData = dicomMetaData('get', [], dSeriesOffset);
            aBuffer    = dicomBuffer  ('get', [], dSeriesOffset);

            x = aspectRatioValue('get', 'x');
            y = aspectRatioValue('get', 'y');
            z = aspectRatioValue('get', 'z');

        end

        if x == 0
            x=1;
        end

        if y == 0
            y=1;
        end

        if z == 0
            z=1;
        end

        aBuffer = aBuffer(:,:,end:-1:1);
%        aBuffer = aBuffer(:,:,end:-1:1);

        aScaleFactor = [y x z];
        dScaleMax = max(aScaleFactor)*2.5;

        vec = linspace(0,2*pi(),120)';

        myPosition = [dScaleMax*cos(vec) dScaleMax*sin(vec) zeros(size(vec))];

        aCameraPosition = myPosition(1,:);
        aCameraUpVector =  [0 0 1];

        for cc=1:numel(aCameraPosition) % Normalize to 1
            aCameraPosition(cc) = aCameraPosition(cc) / dScaleMax;
        end

        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, 'right');

        for cc=1:numel(aCameraPosition) % Add the zoom
            aCameraPosition(cc) = aCameraPosition(cc) *dScaleMax;
        end

        % MIP display image

        bUseViewer3d = shouldUseViewer3d();

        ptrViewer3d = [];

        if bUseViewer3d == true

            [Mdti,~] = TransformMatrix(atMetaData{1}, computeSliceSpacing(atMetaData), true);

            % if volume3DZOffset('get') == false

                Mdti(1,4) = 0;
                Mdti(2,4) = 0;
                Mdti(3,4) = 0;
                Mdti(4,4) = 1;
            % end

            tform = affinetform3d(Mdti);

            ptrViewer3d = viewer3d('Parent'         , ui3DWindow, ...
                                   'BackgroundColor', 'white', ...
                                   'GradientColor'  , [0.98 0.98 0.98], ...
                                   'CameraZoom'     , 1.5000, ...
                                   'Lighting'       ,'off');

        end

        if ~isempty(aBuffer)

            aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'MaximumIntensityProjection', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};

            if strcmpi(atMetaData{1}.Modality, 'CT')
                aColormap = gray(256);
                aAlphamap = defaultMipAlphaMap(aBuffer, 'CT');
            elseif strcmpi(atMetaData{1}.Modality, 'MR')
                aAlphamap = defaultMipAlphaMap(aBuffer, 'MR');
                aColormap = getAngioColorMap();
            else
                aAlphamap = compute3DLinearAlphaMap(get(uiSlider3Dintensity,'value'));
                aColormap = gray(256);
            end

            aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

            if isMATLABReleaseOlderThan('R2022b')

                gp3DObject = volshow(squeeze(aBuffer),  aInputArguments{:});
            else
                if ~isempty(ptrViewer3d)

                    gp3DObject = volshow(squeeze(aBuffer), ...
                                         'Parent'        , ptrViewer3d, ...
                                         'RenderingStyle', 'MaximumIntensityProjection',...
                                         'Alphamap'      , aAlphamap, ...
                                         'Colormap'      , aColormap, ...
                                         'Transformation', tform);
                else
                    gp3DObject = images.compatibility.volshow.R2022a.volshow(squeeze(aBuffer), aInputArguments{:});
                end
            end

            if ~isempty(ptrViewer3d)

                set3DView(ptrViewer3d, 1, 1);
            else
                gp3DObject.CameraPosition = aCameraPosition;
                gp3DObject.CameraUpVector = aCameraUpVector;
            end
        end

        % Volume redering all contours

        if ~isempty(glVoiAllContoursMask)

     %       glVoiAllContoursMask = smooth3(glVoiAllContoursMask(:,:,end:-1:1), 'box', 3);
            glVoiAllContoursMask = glVoiAllContoursMask(:,:,end:-1:1);

            aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};

            aAlphamap = linspace(0, 1, 256)';
            aColormap = getRedColorMap();

            aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

            if isMATLABReleaseOlderThan('R2022b')

                gp3DContours = volshow(squeeze(glVoiAllContoursMask),  aInputArguments{:});
            else
                if ~isempty(ptrViewer3d)

                    gp3DContours = volshow(squeeze(glVoiAllContoursMask), ...
                                          'Parent'        , ptrViewer3d, ...
                                          'RenderingStyle', 'VolumeRendering',...
                                          'Alphamap'      , aAlphamap, ...
                                          'Colormap'      , aColormap, ...
                                          'Transformation', tform);
                else
                    gp3DContours = images.compatibility.volshow.R2022a.volshow(squeeze(glVoiAllContoursMask), aInputArguments{:});
                end
            end

            if isempty(ptrViewer3d)

                gp3DContours.CameraPosition = aCameraPosition;
                gp3DContours.CameraUpVector = aCameraUpVector;
            end


            % Volume redering all the farthest distances
            if gdFarthestDistance ~= 0

                aLineBuffer = zeros(size(aBuffer));

                aLineBufferSize = size(aLineBuffer);

                dLineWidth = round(aLineBufferSize(1)/256);
                if dLineWidth < 1
                    dLineWidth = 1;
                end

                aLineBuffer = addLineIn3DImage(aLineBuffer, gadFarthestXYZ1, gadFarthestXYZ2, dLineWidth);

          %      aTest(round(C(:,2)), round(C(:,1)), round(C(:,3)))=9999999;

                aAlphamap = linspace(0, 1, 256)';
                aColormap = getCyanColorMap();

                aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

                if isMATLABReleaseOlderThan('R2022b')

                    gp3DLine = volshow(squeeze(aLineBuffer),  aInputArguments{:});
                else
                    if ~isempty(ptrViewer3d)

                        gp3DLine = volshow(squeeze(aLineBuffer), ...
                                             'Parent'        , ptrViewer3d, ...
                                             'RenderingStyle', 'VolumeRendering',...
                                             'Alphamap'      , aAlphamap, ...
                                             'Colormap'      , aColormap, ...
                                             'Transformation', tform);
                    else
                        gp3DLine = images.compatibility.volshow.R2022a.volshow(squeeze(aLineBuffer), aInputArguments{:});
                    end
                end

                if isempty(ptrViewer3d)

                    gp3DLine.CameraPosition = aCameraPosition;
                    gp3DLine.CameraUpVector = aCameraUpVector;
                end
            end
      %      gadFarthestXYZ1
      %      gadFarthestXYZ1

        end

        if ~isempty(ptrViewer3d)

            set(ptrViewer3d, 'Lighting', 'on');
        end

    end

    function slider3DintensityCallback(~, ~)

        aAlphamap = compute3DLinearAlphaMap(get(uiSlider3Dintensity,'value'));

        set(gp3DObject, 'Alphamap', aAlphamap);
    end

    function uiContourReportSliderCallback(~, ~)

        val = get(uiContourReportSlider, 'Value');

        aPosition = get(uiContourReport, 'Position');

        dPanelOffset = -((1-val) * aPosition(4));

        set(uiContourReport, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function btnContourReport3DRenderingFullScreenCallback(~, ~)

        bFullScreen = get(btnContourReport3DRenderingFullScreen, 'UserData');

        if bFullScreen == false % Toggle to full screen

            bFullScreen = true;

            sTooltipString = 'Exit Full Screen';

            if exist(sprintf('%s/icons/exit-full-screen-black.png', viewerRootPath('get')), 'file')
                [imgFullScreenIcon,~] = imread(sprintf('%s/icons/exit-full-screen-black.png', viewerRootPath('get')));
                imgFullScreenIcon = double(imgFullScreenIcon)/255;
            else
                imgFullScreenIcon = zeros([16 16 3]);
            end

            aFigPosition = get(figContourReport, 'Position');
            aBtnPosition = [aFigPosition(3)-40 aFigPosition(4)-25 20 20];

            a3DWWindowPosition = [0 0 aFigPosition(3)-20 aFigPosition(4)-60];

            aChkViewContoursPosition = [aFigPosition(3)-275 aFigPosition(4)-25 20 20];
            aTxtViewContoursPosition = [aFigPosition(3)-250 aFigPosition(4)-28 200 20];

            aChkViewFarthestDistancePosition = [aFigPosition(3)-275 aFigPosition(4)-45 20 20];
            aTxtViewFarthestDistancePosition = [aFigPosition(3)-250 aFigPosition(4)-48 200 20];
        else
            bFullScreen = false;

            sTooltipString = 'Full Screen';

            if exist(sprintf('%s/icons/full-screen-black.png', viewerRootPath('get')), 'file')
                [imgFullScreenIcon,~] = imread(sprintf('%s/icons/full-screen-black.png', viewerRootPath('get')));
                imgFullScreenIcon = double(imgFullScreenIcon)/255;
            else
                imgFullScreenIcon = zeros([16 16 3]);
            end

            atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));
        
            if ~strcmpi(atMetaData{1}.Modality, 'CT') && ...
               ~strcmpi(atMetaData{1}.Modality, 'MR')

                a3DWWindowPosition = [20 15 FIG_REPORT_X/3-75-15 340];
            else
                a3DWWindowPosition = [5 15 FIG_REPORT_X/3-75 340];
            end

            aBtnPosition = [FIG_REPORT_X/3-75-20 a3DWWindowPosition(4)+20 20 20];

            aChkViewContoursPosition = [5 a3DWWindowPosition(4)+40 20 20];
            aTxtViewContoursPosition = [25 a3DWWindowPosition(4)+37 FIG_REPORT_X/3-75-60 20];

            aChkViewFarthestDistancePosition = [5 a3DWWindowPosition(4)+20 20 20];
            aTxtViewFarthestDistancePosition = [25 a3DWWindowPosition(4)+17 FIG_REPORT_X/3-75-60 20];
        end

        set(btnContourReport3DRenderingFullScreen, 'TooltipString', sTooltipString);
        set(btnContourReport3DRenderingFullScreen, 'UserData'     , bFullScreen);
        set(btnContourReport3DRenderingFullScreen, 'CData'        , imgFullScreenIcon);
        set(btnContourReport3DRenderingFullScreen, 'Position'     , aBtnPosition);

        set(chkContourReportViewContours, 'Position', aChkViewContoursPosition);
        set(txtContourReportViewContours, 'Position', aTxtViewContoursPosition);

        set(chkContourReportViewFarthestDistance, 'Position', aChkViewFarthestDistancePosition);
        set(txtContourReportViewFarthestDistance, 'Position', aTxtViewFarthestDistancePosition);

        set(ui3DWindow, 'Position', a3DWWindowPosition);

        if viewerUIFigure('get') == true || ...
           ~isMATLABReleaseOlderThan('R2025a')

            if ~isempty(ptrViewer3d)
                set(ptrViewer3d, 'Position', [0 0 a3DWWindowPosition(3), a3DWWindowPosition(4)]);
            end
        end
    end


    function chkContourReportViewContoursCallback(hObject, ~)

        bViewContours = get(chkContourReportViewContours, 'Value');

        if strcmpi(get(hObject, 'Style'), 'Text')

            bViewContours = ~bViewContours;
            set(chkContourReportViewContours, 'Value', bViewContours);
        end

        if bViewContours == 0
             aAlphamap = linspace(0, 0, 256)';
        else
             aAlphamap = linspace(0, 1, 256)';
       end

       if ~ isempty(gp3DContours)
           gp3DContours.Alphamap = aAlphamap;
       end

    end

    function chkContourReportViewFarthestDistanceCallback(hObject, ~)

        bViewFarthestDistance = get(chkContourReportViewFarthestDistance, 'Value');

        if strcmpi(get(hObject, 'Style'), 'Text')

            bViewFarthestDistance = ~bViewFarthestDistance;
            set(chkContourReportViewFarthestDistance, 'Value', bViewFarthestDistance);
        end

        if bViewFarthestDistance == 0
             aAlphamap = linspace(0, 0, 256)';
        else
             aAlphamap = linspace(0, 1, 256)';
       end

       if ~ isempty(gp3DLine)
           gp3DLine.Alphamap = aAlphamap;
       end

    end

    function setReportVolumeHistogramCallback(~, ~)

        dPopValue   = get(popReportVolumeHistogram, 'value');
        asPopString = get(popReportVolumeHistogram, 'string');

        aAxeReportPosition = get(axeReport, 'position');

        delete(axeReport);

        axeReport = ...
        axes(uiContourReport, ...
             'Units'   , 'pixels', ...
             'Position', aAxeReportPosition, ...
             'Color'   , 'White',...
             'XColor'  , 'Black',...
             'YColor'  , 'Black',...
             'ZColor'  , 'Black',...
             'Visible' , 'on'...
             );
        axeReport.Interactions = [];
        % axeReport.Toolbar.Visible = 'off';
        deleteAxesToolbar(axeReport);
        disableDefaultInteractivity(axeReport);

        try
            if ~isempty(gtReport) % Fill information

                for jj=1: numel(asPopString)

                    switch lower(asPopString{dPopValue})

                        case 'all contours'
                            voiData = gtReport.All.voiData;
                            break;

                        case 'unspecified'
                            voiData = gtReport.Unspecified.voiData;
                            break;

                        case 'bone'
                            voiData = gtReport.Bone.voiData;
                            break;

                        case 'soft tissue'
                            voiData = gtReport.SoftTissue.voiData;
                            break;

                        case 'lung'
                            voiData = gtReport.Lung.voiData;
                            break;

                        case 'liver'
                            voiData = gtReport.Liver.voiData;
                            break;

                        case 'parotid'
                            voiData = gtReport.Parotid.voiData;
                            break;

                        case 'blood pool'
                            voiData = gtReport.BloodPool.voiData;
                            break;

                        case 'lymph nodes'
                            voiData = gtReport.LymphNodes.voiData;
                            break;

                        case 'primary disease'
                            voiData = gtReport.PrimaryDisease.voiData;
                            break;

                        case 'cervical'
                            voiData = gtReport.Cervical.voiData;
                            break;

                        case 'supraclavicular'
                            voiData = gtReport.Supraclavicular.voiData;
                            break;

                        case 'mediastinal'
                            voiData = gtReport.Mediastinal.voiData;
                            break;

                        case 'paraspinal'
                            voiData = gtReport.Paraspinal.voiData;
                            break;

                        case 'axillary'
                            voiData = gtReport.Axillary.voiData;
                            break;

                        case 'abdominal'
                            voiData = gtReport.Abdominal.voiData;
                            break;

                        case 'necrotic'
                            voiData = gtReport.Necrotic.voiData;
                            break;                            

                    end

                end

                if numel(gasLesionType{dPopValue}) > 18
                    sName = gasLesionType{dPopValue}(1:18);
                else
                    sName = gasLesionType{dPopValue};
                end

                ptrPlotCummulative = plotCummulative(axeReport, voiData, 'black');
                axeReport.Title.String  = sprintf('%s - Uptake Volume Histogram (UVH)', sName);
                axeReport.XLabel.String = sprintf('Uptake (%s)', getReportUnitValue());
                axeReport.YLabel.String = 'Total Volume Fraction (TVF)';

                cDataCursor = datacursormode(figContourReport);
                cDataCursor.UpdateFcn = @updateCursorCoordinates;
                set(cDataCursor, 'Enable', 'off');


                dTip = createDatatip(cDataCursor, ptrPlotCummulative);
                dTip.Position(2) = 0.90;

                aXData = get(ptrPlotCummulative, 'XData');
                aYData = get(ptrPlotCummulative, 'YData');

                [aYData,idx] = unique(aYData) ;
                aXData = aXData(idx) ;
                dD90 = interp1(aYData, aXData, .9);
                dD50 = interp1(aYData, aXData, .5);
                dD10 = interp1(aYData, aXData, .1);

                text(axeReport, max(aXData)*0.8, max(aYData)*0.95, sprintf('90%%: %.0f', dD90));
                text(axeReport, max(aXData)*0.8, max(aYData)*0.87, sprintf('50%%: %.0f', dD50));
                text(axeReport, max(aXData)*0.8, max(aYData)*0.79, sprintf('10%%: %.0f', dD10));
            end

        catch ME
            logErrorToFile(ME);
        end
    end

    function sliderScrollableContoursInformationCallback(~, ~)

        val = get(uiContoursInformation, 'Value');

        aPosition = get(uiScrollableContoursInformationReport, 'Position');

        dPanelOffset = -((1-val) * aPosition(4));

        set(uiScrollableContoursInformationReport, ...
            'Position', [aPosition(1) ...
                         gaContourInformationScrollableUiPosition(2)-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function setUiExtendedPosition(uiControl)

        aUiExtent = get(uiControl, 'Extent');
        aUiPosition = get(uiControl, 'Position');

        dNbElements = size(uiControl.String, 1);

        % Adjust the position to align the text at the top
        % aNewUiPosition = [aUiPosition(1), (aUiPosition(4) - aUiExtent(4)) /2 - 10, aUiPosition(3), aUiPosition(4)];
        aNewUiPosition = [aUiPosition(1), aUiPosition(2) + aUiPosition(4) - aUiExtent(4) - dNbElements, aUiPosition(3), aUiExtent(4) + dNbElements];

        set(uiControl, 'Position', aNewUiPosition);
    end
end
