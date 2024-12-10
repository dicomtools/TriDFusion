function generate3DLungShuntReport(bInitReport)
%function generate3DLungShuntReport(bInitReport)
%Generate a report, from 3D SPECT Lung Shunt.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    gp3DObject = [];

    gasOrganList={'Lungs','Liver'};

    gasMask = {'lungs', 'liver'};

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end

    gtReport = [];

    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 840;

    if viewerUIFigure('get') == true

        fig3DLungShuntReport = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                    FIG_REPORT_X ...
                    FIG_REPORT_Y],...
                    'Resize', 'off', ...
                    'Color', 'white',...
                    'Name' , 'TriDFusion (3DF) 3D SPECT Lung Shunt Report'...
                    );
    else

        fig3DLungShuntReport = ...
            figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                   FIG_REPORT_X ...
                   FIG_REPORT_Y],...
                   'Name', 'TriDFusion (3DF) 3D SPECT Lung Shunt Report',...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'Color', 'white', ...
                   'Toolbar','none'...
                   );
    end

    if viewerUIFigure('get') == true
        set(fig3DLungShuntReport, 'Renderer', 'opengl'); 
        set(fig3DLungShuntReport, 'GraphicsSmoothing', 'off'); 
    else
        set(fig3DLungShuntReport, 'Renderer', 'opengl'); 
        set(fig3DLungShuntReport, 'doublebuffer', 'on');   
    end

    fig3DLungShuntReportPtr('set', fig3DLungShuntReport);

    axe3DLungShuntReport = ...
       axes(fig3DLungShuntReport, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
             'Color'   , 'white',...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
      axe3DLungShuntReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
      axe3DLungShuntReport.Toolbar.Visible = 'off';
      disableDefaultInteractivity(axe3DLungShuntReport);

      ui3DLungShuntReport = ...
         uipanel(fig3DLungShuntReport,...
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

    a3DLungShuntReportPosition = get(fig3DLungShuntReport, 'position');
    ui3DLungShuntReportSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , fig3DLungShuntReport,...
                  'Units'   , 'pixels',...
                  'position', [a3DLungShuntReportPosition(3)-15 ...
                               0 ...
                               15 ...
                               a3DLungShuntReportPosition(4) ...
                               ],...
                  'Value', 1, ...
                  'Callback',@ui3DLungShuntReportSliderCallback, ...
                  'BackgroundColor', 'white', ...
                  'ForegroundColor', 'black' ...
                  );
%     addlistener(ui3DLungShuntReportSlider, 'Value', 'PreSet', @ui3DLungShuntReportSliderCallback);
    addlistener(ui3DLungShuntReportSlider, 'ContinuousValueChange', @ui3DLungShuntReportSliderCallback);

        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , ' TriDFusion (3DF) 3D SPECT Lung Shunt Report',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-30 FIG_REPORT_X 20]...
                  );

        uicontrol(ui3DLungShuntReport,...
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

         uicontrol(ui3DLungShuntReport,...
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
        uicontrol(ui3DLungShuntReport,...
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

         uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Series Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-80 FIG_REPORT_X/3-50 20]...
                  );

    uiReportSeriesInformation = ...
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportSeriesInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-490 FIG_REPORT_X/3-50 400]...
                  );

    %  if viewerUIFigure('get') == true
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

         uiReport3DLungShuntInformation = ...
         uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Contours Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-80 FIG_REPORT_X/3+100 20]...
                  );

         % Contour Type

          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Site',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-110 115 20]...
                  );

        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-210 115 90]...
                  );


         % 3DLungShunt Mean

          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Mean',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-110 100 20]...
                  );

        uiReportLesionMean = ...
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-210 100 90]...
                  );

         % 3DLungShunt Total

          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Counts',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+125 FIG_REPORT_Y-110 100 20]...
                  );

        uiReportLesionTotal = ...
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportTotalInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+125 FIG_REPORT_Y-210 100 90]...
                  );

%         axe3DLungShuntLungsTotalRectangle = ...
%         axes(ui3DLungShuntReport, ...
%              'Units'   , 'pixels', ...
%              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-240 60 40], ...
%              'Color'   , 'white',...
%              'Visible' , 'off'...
%              );
%         axe3DLungShuntLungsTotalRectangle.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
%         axe3DLungShuntLungsTotalRectangle.Toolbar = [];
%         rectangle(axe3DLungShuntLungsTotalRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);

          % Contour Volume

          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Volume (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+235 FIG_REPORT_Y-110 100 20]...
                  );

        uiReportLesionVolume = ...
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+235 FIG_REPORT_Y-210 100 90]...
                  );

         % Lung Shunt

         uiReport3DLungShuntLungRatio = ...
         uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 580 300 20]...
                  );

    axe3DLungShuntRectangle = ...
       axes(ui3DLungShuntReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 570 FIG_REPORT_X/3+60 40], ...
             'Color'   , 'white',...
             'Visible' , 'off'...
             );
    axe3DLungShuntRectangle.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axe3DLungShuntRectangle.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axe3DLungShuntRectangle);

    rectangle(axe3DLungShuntRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);

    % 3D Volume

    ui3DWindow = ...
    uipanel(ui3DLungShuntReport,...
            'Units'   , 'pixels',...
            'BorderType', 'none',...
            'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
            'position', [20 15 FIG_REPORT_X/3-75-15 340]...
            );

    uiSlider3Dintensity = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'Slider', ...
              'Position', [5 15 15 340], ...
              'Value'   , 0.75, ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Intensity', ...
              'BackgroundColor', 'White', ...
              'CallBack', @slider3DLungLiverintensityCallback ...
              );
%    addlistener(uiSlider3Dintensity, 'Value', 'PreSet', @slider3DLungLiverintensityCallback);

     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , '3D Rendering',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [5 ui3DWindow.Position(4)+30 FIG_REPORT_X/3-75 20]...
              );

    % Estimated dose

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Total amount of injected activity (MBq)',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-40 255 320 20]...
              );

    uiEditInjectedActivity = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'edit', ...
              'Position', [FIG_REPORT_X/3-40 220 60 25], ...
              'String'   , ' ', ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Injected Activity', ...
              'BackgroundColor', 'White', ...
              'CallBack', @calculateLungDoseCallback ...
              );

    aEditInjectedActivityPosition = get(uiEditInjectedActivity, 'Position');

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'MBq',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [aEditInjectedActivityPosition(1)+aEditInjectedActivityPosition(3)+5 aEditInjectedActivityPosition(2)-3 100 20]...
              );

    uicalculateLungDose = ...
    uicontrol(ui3DLungShuntReport,...
              'String'  ,'Calculate',...
              'FontWeight', 'bold',...
              'Position',[FIG_REPORT_X/3+190 220 90 30],...
              'Enable'  , 'On', ...
              'BackgroundColor', [0.75 0.75 0.75], ...
              'ForegroundColor', [0.1 0.1 0.1], ...
              'Callback', @calculateLungDoseCallback...
              );

    axe3DLungShuntEstimatedDoseRectangle = ...
       axes(ui3DLungShuntReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X/3-50 210 FIG_REPORT_X/3-75 75], ...
             'Color'   , 'white',...
             'Visible' , 'off'...
             );
    axe3DLungShuntEstimatedDoseRectangle.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axe3DLungShuntEstimatedDoseRectangle.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axe3DLungShuntEstimatedDoseRectangle);

    rectangle(axe3DLungShuntEstimatedDoseRectangle, 'position', [0 0 1 1], 'EdgeColor', [0.75 0.75 0.75]);

     uiReport3DLungShuntCalculatedDose = ...
     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 12,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , ' ',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-40 170 300 20]...
              );

    axe3DLungShuntEstimatedDoseRectangle = ...
       axes(ui3DLungShuntReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X/3-50 160 FIG_REPORT_X/3-75 40], ...
             'Color'   , 'white',...
             'Visible' , 'off'...
             );
    axe3DLungShuntEstimatedDoseRectangle.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axe3DLungShuntEstimatedDoseRectangle.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axe3DLungShuntEstimatedDoseRectangle);

    rectangle(axe3DLungShuntEstimatedDoseRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Dosimetry',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-50 300 FIG_REPORT_X/3-75 20]...
              );
    % Notes

    uiEditWindow = ...
    uicontrol(ui3DLungShuntReport,...
              'style'     , 'edit',...
              'FontWeight', 'Normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-75 90]...
             );
    set(uiEditWindow, 'Min', 0, 'Max', 2);

     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Notes',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-50 uiEditWindow.Position(4)+30 FIG_REPORT_X/3-75 20]...
              );

     % Lungs estimate volume

     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Estimate percentage of the lungs volume in the image',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 510 390 20]...
              );

    uiSliderLungsVolumeRatio = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'Slider', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 485 390 20], ...
              'Value'   , 1, ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Estimate lungs Volume', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiSliderLungsVolumeRatioCallback ...
              );
%     uiSliderLungsVolumeRatioListener = addlistener(uiSliderLungsVolumeRatio, 'Value', 'PreSet', @uiSliderLungsVolumeRatioCallback);
    uiSliderLungsVolumeRatioListener = addlistener(uiSliderLungsVolumeRatio, 'ContinuousValueChange', @uiSliderLungsVolumeRatioCallback);

    aSliderLungVolumeRatioPosition = get(uiSliderLungsVolumeRatio, 'position');

    uiEditLungsVolumeRatio = ...
    uicontrol(ui3DLungShuntReport,...
              'style'     , 'edit',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('%2.2f', get(uiSliderLungsVolumeRatio, 'Value')*100),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'CallBack', @uiEditLungsVolumeRatioCallback, ...
              'position', [aSliderLungVolumeRatioPosition(1)+aSliderLungVolumeRatioPosition(3)+5 aSliderLungVolumeRatioPosition(2)-3 60 30]...
              );

    % Liver estimate volume

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Estimate percentage of the liver volume in the image',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 455 390 20]...
              );

    uiSliderLiverVolumeRatio = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'Slider', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 430 390 20], ...
              'Value'   , 1, ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Estimate liver Volume', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiSliderLiverVolumeRatioCallback ...
              );
%     uiSliderLiverVolumeRatioListener = addlistener(uiSliderLiverVolumeRatio, 'Value', 'PreSet', @uiSliderLiverVolumeRatioCallback);
    uiSliderLiverVolumeRatioListener = addlistener(uiSliderLiverVolumeRatio, 'ContinuousValueChange', @uiSliderLiverVolumeRatioCallback);

    aSliderLiverVolumeRatioPosition = get(uiSliderLiverVolumeRatio, 'position');

    uiEditLiverVolumeRatio = ...
    uicontrol(ui3DLungShuntReport,...
              'style'     , 'edit',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('%2.2f', get(uiSliderLiverVolumeRatio, 'Value')*100),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'CallBack', @uiEditLiverVolumeRatioCallback, ...
              'position', [aSliderLiverVolumeRatioPosition(1)+aSliderLiverVolumeRatioPosition(3)+5 aSliderLiverVolumeRatioPosition(2) 60 30]...
              );

    axeVolumeRatio = ...
    axes(ui3DLungShuntReport, ...
         'Units'   , 'pixels', ...
         'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 415 FIG_REPORT_X/3+60 120], ...
         'Color'   , 'white',...
         'Visible' , 'off'...
         );
    axeVolumeRatio.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeVolumeRatio.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axeVolumeRatio);

    rectangle(axeVolumeRatio, 'position', [0 0 1 1], 'EdgeColor', [0.75 0.75 0.75]);

    % Liver volume-of-interest oversized

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Liver volume-of-interest oversized',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 380 400 20]...
              );

    uiEditLiverVolumeOversized = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'edit', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 350 60 25], ...
              'String'   , num2str(lungShuntLiverVolumeOversized('get')), ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Liver volume-of-interest oversized', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiEditLiverVolumeOversizedCallback ...
              );

    aEditLiverVolumeSizePosition = get(uiEditLiverVolumeOversized, 'position');

    uiTextLiverVolumeOversized = ...
     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('pixel(s) (%2.2f mm)', getVolumeOversizedSize(str2double(get(uiEditLiverVolumeOversized, 'String')))),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [aEditLiverVolumeSizePosition(1)+aEditLiverVolumeSizePosition(3)+5 aEditLiverVolumeSizePosition(2)-3 200 20]...
              );

    % Cutoff for the extra slices above the top of the liver volume-of-interest

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Cutoff for the extra slice(s) above or bellow the top of the liver',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 315 460 20]...
              );

    uiEditLiverTopOfVolumeExtraSlices = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'edit', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 285 60 25], ...
              'String'   , num2str(lungShuntLiverTopOfVolumeExtraSlices('get')), ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Cutoff for the extra slice(s) above or bellow the top of the liver', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiEditLiverTopOfVolumeExtraSlicesCallback ...
              );

    aEditLiverTopOfVolumeExtraSlicesPosition = get(uiEditLiverTopOfVolumeExtraSlices, 'position');

    uiTextLiverTopOfVolumeExtraSlices = ...
     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(str2double(get(uiEditLiverTopOfVolumeExtraSlices, 'String')))),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [aEditLiverTopOfVolumeExtraSlicesPosition(1)+aEditLiverTopOfVolumeExtraSlicesPosition(3)+5 aEditLiverTopOfVolumeExtraSlicesPosition(2)-3 200 20]...
              );

    % Cutoff for the extra slices under the bottom of the liver volume-of-interest

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Cutoff for the extra slice(s) bellow or above the bottom of the liver',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 255 460 20]...
              );

    uiEditLiverBottomOfVolumeExtraSlices = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'edit', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 225 60 25], ...
              'String'   , num2str(lungShuntLiverBottomOfVolumeExtraSlices('get')), ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Cutoff for the extra slice(s) bellow or above the bottom of the liver', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiEditLiverBottomOfVolumeExtraSlicesCallback ...
              );

    auiEditLiverBottomOfVolumeExtraSlicesPosition = get(uiEditLiverBottomOfVolumeExtraSlices, 'position');

    uiTextLiverBottomOfVolumeExtraSlices = ...
     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(str2double(get(uiEditLiverBottomOfVolumeExtraSlices, 'String')))),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [auiEditLiverBottomOfVolumeExtraSlicesPosition(1)+auiEditLiverBottomOfVolumeExtraSlicesPosition(3)+5 auiEditLiverBottomOfVolumeExtraSlicesPosition(2)-3 200 20]...
              );

    % Lungs volume-of-interest oversized

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Lungs volume-of-interest oversized',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 175 400 20]...
              );

    % Overlap the liver

    uiCheckLungsVolumeOverlap = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'checkbox', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 145 25 25], ...
              'Value'   , lungShuntLungsVolumeOverlap('get'), ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Overlap liver', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiCheckLungsVolumeOverlapCallback ...
              );

     uiTextLungsVolumeOverlap = ...
     uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'Enable'    , 'Inactive',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Overlap the liver',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80+21 142 200 25], ...
              'ButtonDownFcn', @uiCheckLungsVolumeOverlapCallback ...
              );

    uiEditLungsVolumeOversized = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'edit', ...
              'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 115 60 25], ...
              'String'   , num2str(lungShuntLungsVolumeOversized('get')), ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Lungs volume-of-interest oversized', ...
              'BackgroundColor', 'White', ...
              'CallBack', @uiEditLungsVolumeOversizedCallback ...
              );

    aEditLungsVolumeSizePosition = get(uiEditLungsVolumeOversized, 'position');

    uiTextLungsVolumeOversized = ...
    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , sprintf('pixel(s) (%2.2f mm)', getVolumeOversizedSize(str2double(get(uiEditLungsVolumeOversized, 'String')))),...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [aEditLungsVolumeSizePosition(1)+aEditLungsVolumeSizePosition(3)+5 aEditLungsVolumeSizePosition(2)-3 200 20]...
              );

    uiProceedLiverVolumeOversize = ...
    uicontrol(ui3DLungShuntReport,...
              'String'  ,'Reprocess',...
              'FontWeight', 'bold',...
              'Position',[FIG_REPORT_X-130 75 90 30],...
              'Enable'  , 'On', ...
              'BackgroundColor', [0.75 0.75 0.75], ...
              'ForegroundColor', [0.1 0.1 0.1], ...
              'Callback', @proceedLiverVolumeOversize...
              );

     axeProceedLiverVolumeOversize = ...
     axes(ui3DLungShuntReport, ...
          'Units'   , 'pixels', ...
          'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 65 FIG_REPORT_X/3+60 340], ...
          'Color'   , 'white',...
          'Visible' , 'off'...
         );
    axeProceedLiverVolumeOversize.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeProceedLiverVolumeOversize.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axeProceedLiverVolumeOversize);

    rectangle(axeProceedLiverVolumeOversize, 'position', [0 0 1 1], 'EdgeColor', [0.75 0.75 0.75]);


    % Liver volume-of-interest oversized

    uicontrol(ui3DLungShuntReport,...
              'style'     , 'text',...
              'FontWeight', 'bold',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'string'    , 'Signature:',...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 15 100 20]...
              );

%     uiEditSignatireWindow = ...
    uicontrol(ui3DLungShuntReport,...
              'style'     , 'edit',...
              'FontWeight', 'Normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X-(FIG_REPORT_X/3) 15 385 40]...
             );

    mReportFile = uimenu(fig3DLungShuntReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export report to .pdf...'             ,'Callback', @exportCurrentLungLiverReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export report to DICOM print...'      ,'Callback', @exportCurrentLungLiverReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Export axial slices to .avi...'       ,'Callback', @exportCurrentLungLiverAxialSlicesToAviCallback, 'Separator','on');
    uimenu(mReportFile,'Label', 'Export axial slices to DICOM movie...','Callback', @exportCurrentLungLiverAxialSlicesToDicomMovieCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(fig3DLungShuntReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyLungLiverReportDisplayCallback);

    mReportOptions = uimenu(fig3DLungShuntReport,'Label','Options', 'Callback', @figLungLiverRatioReportRefreshOption);

     if suvMenuUnitOption('get') == true && ...
       atInput(dSeriesOffset).bDoseKernel == false

        sUnitDisplay = getSerieUnitValue(dSeriesOffset);
        if strcmpi(sUnitDisplay, 'SUV')
            sSuvChecked = 'on';
        else
            if suvMenuUnitOption('get') == true
                suvMenuUnitOption('set', false);
            end
            sSuvChecked = 'off';
        end
    else
        if suvMenuUnitOption('get') == true
            suvMenuUnitOption('set', false);
        end
        sSuvChecked = 'off';
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

    mSUVUnit = uimenu(mReportOptions, 'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @lungLiverReportSUVUnitCallback);

    setLungLiverRatioReportFigureName();

    if bInitReport == false % Reopen the report
        refreshReportLesionInformation(suvMenuUnitOption('get'));
    else % First run
        gtReport = computeLungLiverReportContoursInformation(suvMenuUnitOption('get'), false, false, true);

%        if lungShuntLiverVolumeOversized('get') ~= 0 || ...
%           lungShuntLungsVolumeOversized('get') ~= 0

            proceedLiverVolumeOversize();
            bInitReport = false;
%        end

        if isvalid(ui3DWindow)
            display3DLungLiver();
        end
    end

    function refreshReportLesionInformation(bSUVUnit)

        gtReport = computeLungLiverReportContoursInformation(bSUVUnit, false, false, false);

        if ~isempty(gtReport) % Fill information

            if isvalid(uiReport3DLungShuntInformation) % Make sure the figure is still open
                set(uiReport3DLungShuntInformation, 'String', sprintf('Contours Information (%s)', getLungLiverReportUnitValue()));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open
                set(uiReportLesionMean, 'String', getLungLiverReportMeanInformation('get', gtReport));
            end

            if isvalid(uiReportLesionTotal) % Make sure the figure is still open

                set(uiReportLesionTotal, 'String', getLungLiverReportTotalInformation('get', gtReport));
%                 set(uiReportLesionTotal, 'FontWeight', 'Bold');
            end

            if isvalid(uiReportLesionVolume) % Make sure the figure is still open
                set(uiReportLesionVolume, 'String', getLungLiverReportVolumeInformation('get', gtReport));
            end

            if isvalid(uiReport3DLungShuntLungRatio)
                set(uiReport3DLungShuntLungRatio, 'String', getLungLiverReportRatioInformation(gtReport));
            end

            if isvalid(ui3DWindow)
                display3DLungLiver();
            end

        end
    end

    function setLungLiverRatioReportFigureName()

        if ~isvalid(fig3DLungShuntReport)
            return;
        end

        atMetaData = dicomMetaData('get');

        sUnit = sprintf('Unit: %s', getLungLiverReportUnitValue());

        fig3DLungShuntReport.Name = ['TriDFusion (3DF) 3D SPECT Lung Shunt Report - ' atMetaData{1}.SeriesDescription ' - ' sUnit];

    end

    function figLungLiverRatioReportRefreshOption(~, ~)

        if suvMenuUnitOption('get') == true
            sSuvChecked = 'on';
        else
            sSuvChecked = 'off';
        end

        set(mSUVUnit, 'Checked', sSuvChecked);

    end

    function sUnit = getLungLiverReportUnitValue()

        atMetaData = dicomMetaData('get');

        atInput = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

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

    function lungLiverReportSUVUnitCallback(hObject, ~)

        if strcmpi(hObject.Checked, 'on')

            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);

            refreshReportLesionInformation(false);
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);

            refreshReportLesionInformation(true);
        end

        setLungLiverRatioReportFigureName();
    end

    function sReport = getLungLiverReportLesionTypeInformation()

        sReport = '';

  %      [~, gasOrganList] = getLesionType('');

        for ll=1:numel(gasOrganList)

            if  ll==1

                sReport = sprintf( '%s%s', sReport, ['NM ' char(gasOrganList{ll})] );
            else
                sReport = sprintf( '%s\n\n%s', sReport, ['NM ' char(gasOrganList{ll})] );
            end
        end

        sReport = sprintf( '%s\n\n%s', sReport, 'CT Lungs' );

    end

    function sReport = getLungLiverReportMeanInformation(sAction, tReport)

%        [~, gasOrganList] = getLesionType('');

        if strcmpi(sAction, 'init')
            sReport = '';
            for ll=1:numel(gasOrganList)

                if isempty(sReport)

                    sReport = '-';
                else
                    sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            sReport = sprintf('%s\n\n%s', sReport, '-');

        else

  %          if ~isempty(tReport.All.Mean)
  %              sReport = sprintf('%-12s\n___________', num2str(tReport.All.Mean));
  %          else
  %              sReport = sprintf('%s\n___________', '-');
  %          end
            sReport = '';

            for ll=1:numel(gasOrganList)

                switch lower(gasOrganList{ll})

                    case 'lungs'

                        if ~isempty(tReport.NM.Lungs.Mean)

                            sReport = sprintf('%s%-.2f', sReport, tReport.NM.Lungs.Mean);
                        else
                            if isempty(sReport)

                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end

                    case 'liver'

                        if ~isempty(tReport.NM.Liver.Mean)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.NM.Liver.Mean);
                        else
                            if isempty(sReport)

                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end

                    otherwise
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            if ~isempty(tReport.CT.Lungs.Volume)

                sReport = sprintf('%s\n\n%s', sReport, 'NaN');
            else
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end

        end
    end

    function sReport = getLungLiverReportTotalInformation(sAction, tReport)

%        [~, gasOrganList] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = '';

            for ll=1:numel(gasOrganList)

                if isempty(sReport)

                    sReport = '-';
                else
                    sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            sReport = sprintf('%s\n\n%s', sReport, '-');

        else

 %           if ~isempty(tReport.All.Total)
 %               sReport = sprintf('%-12s\n___________', num2str(tReport.All.Total));
 %           else
 %               sReport = sprintf('%s\n___________', '-');
 %           end
            sReport = '';

            for ll=1:numel(gasOrganList)

                switch lower(gasOrganList{ll})

                    case 'lungs'

                        if ~isempty(tReport.NM.Lungs.Total)

                            sReport = sprintf('%s%-.2f', sReport, tReport.NM.Lungs.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end

                    case 'liver'

                        if ~isempty(tReport.NM.Liver.Total)

                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.NM.Liver.Total);
                        else
                            if isempty(sReport)

                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end

                    otherwise
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            if ~isempty(tReport.CT.Lungs.Volume)

                sReport = sprintf('%s\n\n%s', sReport, 'NaN');
            else
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end
        end
    end

    function sReport = getLungLiverReportVolumeInformation(sAction, tReport)

 %       [~, gasOrganList] = getLesionType('');

        if strcmpi(sAction, 'init')

            sReport = '';

            for ll=1:numel(gasOrganList)

                if isempty(sReport)

                    sReport = '-';
                else
                    sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            sReport = sprintf('%s\n\n%s', sReport, '-');

        else

   %         if ~isempty(tReport.All.Volume)
   %             sReport = sprintf('%-12s\n___________', num2str(tReport.All.Volume));
   %         else
   %             sReport = sprintf('%s\n___________', '-');
   %         end
            sReport = '';

            for ll=1:numel(gasOrganList)

                switch lower(gasOrganList{ll})

                    case 'lungs'

                        if ~isempty(tReport.NM.Lungs.Volume)

                            sReport = sprintf('%s%-.3f', sReport, tReport.NM.Lungs.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end

                    case 'liver'

                        if ~isempty(tReport.NM.Liver.Volume)

                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.NM.Liver.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end


                    otherwise
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end

            if ~isempty(tReport.CT.Lungs.Volume)

                sReport = sprintf('%s\n\n%-.3f', sReport, tReport.CT.Lungs.Volume);
            else
                if isempty(sReport)

                    sReport = '-';
                else
                    sReport = sprintf('%s\n\n%s', sReport, 'NaN');
                end
            end

        end
    end

    function sLungShuntFraction = getLungLiverReportRatioInformation(tReport)

            dLungsTotal = tReport.NM.Lungs.Total*100;
            dLiverTotal = tReport.NM.Liver.Total*100;

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
            %

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%', dLungShuntFraction);


            dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

            if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                %                          Total amount of injected activity (GBq)
                % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
                %                                   Lung mass (Kg)

                dLungsVolume = gtReport.NM.Lungs.Volume;

                dInjectedActivity = dInjectedActivity/1000; % In GBq

                dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
            end

    end


    function tReport = computeLungLiverReportContoursInformation(bSUVUnit, bModifiedMatrix, bSegmented, bUpdateMasks)

        tReport = [];

        atInput = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

        sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));
        tQuantification = quantificationTemplate('get');

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if isempty(atVoiInput)
            return;
        end

        if bModifiedMatrix == false && ...
           bMovementApplied == false        % Can't use input buffer if movement have been applied

            atDicomMeta = dicomMetaData('get', [], dSeriesOffset);
            atMetaData  = atInput(dSeriesOffset).atDicomInfo;
            aImage      = inputBuffer('get');

%            if     strcmpi(imageOrientation('get'), 'axial')
%                aImage = permute(aImage{dSeriesOffset}, [1 2 3]);
%            elseif strcmpi(imageOrientation('get'), 'coronal')
%                aImage = permute(aImage{dSeriesOffset}, [3 2 1]);
%            elseif strcmpi(imageOrientation('get'), 'sagittal')
%                aImage = permute(aImage{dSeriesOffset}, [3 1 2]);
%            end

            aImage = aImage{dSeriesOffset};

            if     strcmpi(imageOrientation('get'), 'axial')
%                 aImage = aImage;
            elseif strcmpi(imageOrientation('get'), 'coronal')

                aImage = reorientBuffer(aImage, 'coronal');

            elseif strcmpi(imageOrientation('get'), 'sagittal')

                aImage = reorientBuffer(aImage, 'sagittal');
            end

            if size(aImage, 3) ==1

                if atInput(dSeriesOffset).bFlipLeftRight == true

                    aImage=aImage(:,end:-1:1);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true

                    aImage=aImage(end:-1:1,:);
                end
            else
                if atInput(dSeriesOffset).bFlipLeftRight == true

                    aImage=aImage(:,end:-1:1,:);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true

                    aImage=aImage(end:-1:1,:,:);
                end

                if atInput(dSeriesOffset).bFlipHeadFeet == true

                    aImage=aImage(:,:,end:-1:1);
                end
            end

        else
            atMetaData = dicomMetaData('get');
            aImage     = dicomBuffer('get');
        end

        % Set Voxel Size

        xPixel = atMetaData{1}.PixelSpacing(1)/10;
        yPixel = atMetaData{1}.PixelSpacing(2)/10;

        if size(aImage, 3) == 1

            zPixel = 1;
        else
            zPixel = computeSliceSpacing(atMetaData)/10;

            if zPixel == 0 % We can't determine the z size of a pixel, we will presume the pixel is square.

                zPixel = xPixel;
            end
        end

        dVoxVolume = xPixel * yPixel * zPixel;

        % Count contour Type number

        dLungsCount  = 0;
        dLiverCount  = 0;

        dNbLungsRois = 0;
        dNbLiverRois = 0;

        for vv=1:numel(atVoiInput)

            dNbRois = numel(atVoiInput{vv}.RoisTag);

            switch lower(atVoiInput{vv}.Label)

                case 'lungs-lun'

                    dLungsCount  = dLungsCount+1;
                    dNbLungsRois = dNbLungsRois+dNbRois;

                case 'liver-liv'

                    dLiverCount  = dLiverCount+1;
                    dNbLiverRois = dNbLiverRois+dNbRois;
            end
        end

        % Set report type count

        if dLungsCount == 0

            tReport.NM.Lungs.Count = [];
        else
            tReport.NM.Lungs.Count = dLungsCount;
        end

        if dLiverCount == 0

            tReport.NM.Liver.Count = [];
        else
            tReport.NM.Liver.Count = dLiverCount;
        end

        % Clasify ROIs by lession type

        tReport.NM.Lungs.RoisTag = cell(1, dNbLungsRois);
        tReport.NM.Liver.RoisTag = cell(1, dNbLiverRois);

        dLungsRoisOffset = 1;
        dLiverRoisOffset = 1;

        for vv=1:numel(atVoiInput)

            dNbRois = numel(atVoiInput{vv}.RoisTag);


            switch lower(atVoiInput{vv}.Label)

                case 'lungs-lun'

                    dFrom = dLungsRoisOffset;
                    dTo   = dLungsRoisOffset+dNbRois-1;

                    tReport.NM.Lungs.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                    dLungsRoisOffset = dLungsRoisOffset+dNbRois;

                    tReport.NM.Lungs.Color = atVoiInput{vv}.Color;

                case 'liver-liv'

                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;

                    tReport.NM.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;

                    tReport.NM.Liver.Color = atVoiInput{vv}.Color;
           end
        end

        % Compute Liver lesion

        progressBar( 1/3, 'Computing liver segmentation, please wait' );

        if numel(tReport.NM.Liver.RoisTag) ~= 0

            voiMask = cell(1, numel(tReport.NM.Liver.RoisTag));
            voiData = cell(1, numel(tReport.NM.Liver.RoisTag));

            dNbCells = 0;

            liverMask = logical(false(size(aImage)));

            for uu=1:numel(tReport.NM.Liver.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.NM.Liver.RoisTag{uu}]} );

                tRoi = atRoiInput{find(aTagOffset, 1)};

                if bModifiedMatrix  == false && bMovementApplied == false % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get'))

                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get'), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end
                end

                switch lower(tRoi.Axe)

                    case 'axe'

                        voiData{uu} = aImage(:,:);
                        voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

%                         if bUpdateMasks == true
                            liverMask(:,:) = voiMask{uu}|liverMask(:,:);
%                         end

                    case 'axes1'

                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                         if bUpdateMasks == true
                            liverMask(tRoi.SliceNb,:,:) = voiMask{uu}|liverMask(tRoi.SliceNb,:,:);
%                         end

                    case 'axes2'

                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                         if bUpdateMasks == true
                            liverMask(:,tRoi.SliceNb,:) = voiMask{uu}|liverMask(:,tRoi.SliceNb,:);
%                         end

                   case 'axes3'

                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                         if bUpdateMasks == true
                            liverMask(:,:,tRoi.SliceNb) = voiMask{uu}|liverMask(:,:,tRoi.SliceNb);
%                         end

                end

                if bSegmented  == true && bModifiedMatrix == true % Can't use original buffer

                    voiDataTemp = voiData{uu}(voiMask{uu});
                    voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                    dNbCells = dNbCells+numel(voiDataTemp);
                else
                    dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
                end
            end

            voiMask = cat(1, voiMask{:});
            voiData = cat(1, voiData{:});

            voiData(voiMask~=1) = [];

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiData = voiData(voiData>cropValue('get'));
            end

            tReport.NM.Liver.Cells  = dNbCells;
            tReport.NM.Liver.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true

                tReport.NM.Liver.Mask = liverMask;

                lungShuntMasks('set', 'Liver', liverMask);
            else
                tReport.NM.Liver.Mask = lungShuntMasks('get', 'Liver');
            end

            aImage(liverMask) = min(aImage, [], 'all');

            clear liverMask;

            if strcmpi(sUnitDisplay, 'SUV')

                if bSUVUnit == true
                    tReport.NM.Liver.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                    tReport.NM.Liver.Total = sum (voiData, 'all')*tQuantification.tSUV.dScale;
%                    tReport.NM.Liver.Total = tReport.NM.Liver.Mean*tReport.NM.Liver.Volume*tQuantification.tSUV.dScale;
                else
                    tReport.NM.Liver.Mean  = mean(voiData, 'all');
                    tReport.NM.Liver.Total = sum (voiData, 'all');
%                    tReport.NM.Liver.Total = tReport.NM.Liver.Mean*tReport.NM.Liver.Volume;
                end
            else
                tReport.NM.Liver.Mean  = mean(voiData, 'all');
                tReport.NM.Liver.Total = sum (voiData, 'all');
%                tReport.NM.Liver.Total = tReport.NM.Liver.Mean*tReport.NM.Liver.Volume;
            end

            clear voiMask;
            clear voiData;

        else
            tReport.NM.Liver.Cells  = [];
            tReport.NM.Liver.Volume = [];
            tReport.NM.Liver.Mean   = [];
            tReport.NM.Liver.Total  = [];
        end

        % Compute Lungs segmentation

        progressBar( 1/3, 'Computing lungs segmentation, please wait' );

        if numel(tReport.NM.Lungs.RoisTag) ~= 0

            voiMask = cell(1, numel(tReport.NM.Lungs.RoisTag));
            voiData = cell(1, numel(tReport.NM.Lungs.RoisTag));

            dNbCells = 0;

            lungsMask = logical(false(size(aImage)));

            for uu=1:numel(tReport.NM.Lungs.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.NM.Lungs.RoisTag{uu}]} );

                tRoi = atRoiInput{find(aTagOffset, 1)};

                if bModifiedMatrix  == false && bMovementApplied == false % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get'))

                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get'), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end
                end

                switch lower(tRoi.Axe)

                    case 'axe'

                        voiData{uu} = aImage(:,:);
                        voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                        if bUpdateMasks == true

                            lungsMask(:,:) = voiMask{uu}|lungsMask(:,:);
                        end

                    case 'axes1'

                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true

                            lungsMask(tRoi.SliceNb,:,:) = voiMask{uu}|lungsMask(tRoi.SliceNb,:,:);
                        end

                    case 'axes2'

                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true

                            lungsMask(:,tRoi.SliceNb,:) = voiMask{uu}|lungsMask(:,tRoi.SliceNb,:);
                        end

                   case 'axes3'

                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true

                            lungsMask(:,:,tRoi.SliceNb) = voiMask{uu}|lungsMask(:,:,tRoi.SliceNb);
                        end
                end

                if bSegmented  == true && ...
                   bModifiedMatrix == true % Can't use original buffer

                    voiDataTemp = voiData{uu}(voiMask{uu});
                    voiDataTemp = voiDataTemp(voiDataTemp>cropValue('get'));
                    dNbCells = dNbCells+numel(voiDataTemp);
                else
                    dNbCells = dNbCells+numel(voiData{uu}(voiMask{uu}==1));
                end
            end

            voiMask = cat(1, voiMask{:});
            voiData = cat(1, voiData{:});

            voiData(voiMask~=1) = [];

            if bSegmented  == true && ...
               bModifiedMatrix == true % Can't use original buffer

                voiData = voiData(voiData>cropValue('get'));
            end

            tReport.NM.Lungs.Cells  = dNbCells;
            tReport.NM.Lungs.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.NM.Lungs.Mask = lungsMask;

                lungShuntMasks('set', 'Lungs', lungsMask);

            else
                tReport.NM.Lungs.Mask = lungShuntMasks('get', 'Lungs');
            end

            clear lungsMask;

            if strcmpi(sUnitDisplay, 'SUV')

                if bSUVUnit == true
                    tReport.NM.Lungs.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                    tReport.NM.Lungs.Total = sum (voiData, 'all')*tQuantification.tSUV.dScale;
%                    tReport.NM.Lungs.Total = tReport.NM.Lungs.Mean*tReport.NM.Lungs.Volume*tQuantification.tSUV.dScale;
                else
                    tReport.NM.Lungs.Mean  = mean(voiData, 'all');
                    tReport.NM.Lungs.Total = sum (voiData, 'all');
%                    tReport.NM.Lungs.Total = tReport.NM.Lungs.Mean*tReport.NM.Lungs.Volume;
                end
            else
                tReport.NM.Lungs.Mean  = mean(voiData, 'all');
                tReport.NM.Lungs.Total = sum (voiData, 'all');
%                tReport.NM.Lungs.Total = tReport.NM.Lungs.Mean*tReport.NM.Lungs.Volume;
            end

            clear voiMask;
            clear voiData;
        else
            tReport.NM.Lungs.Cells  = [];
            tReport.NM.Lungs.Volume = [];
            tReport.NM.Lungs.Mean   = [];
            tReport.NM.Lungs.Total  = [];
        end

        [~, ~, dCTVolume] = machineLearning3DMask('get', 'Lungs');

        if isempty(dCTVolume) % Acquire CT volume

            if numel(atInput) > 1 % Look for a CT

                aInputBuffer = inputBuffer('get');

                for tt=1:numel(atInput)

                    if tt == dSeriesOffset
                        continue;
                    end

                    if tt > numel(atInput)+1
                        break;
                    end

                    if strcmpi(atInput(tt).atDicomInfo{1}.StudyInstanceUID, ... % Try to find the first series
                        atInput(dSeriesOffset).atDicomInfo{1}.StudyInstanceUID)

                        % Found an associated CT

                        atCTVoi = voiTemplate('get', tt);
                        atCTRoi = roiTemplate('get', tt);

                        if ~isempty(atCTVoi) && ~isempty(atCTRoi)

                            for vv=1:numel(atCTVoi)

                                if strcmpi(atCTVoi{vv}.Label, 'Liver-LIV') % Found the Liver VOI on the CT

                                    aLiverCTMask = zeros(size(aInputBuffer{tt}));

                                    for rr=1:numel(atCTVoi{vv}.RoisTag)

                                        aTagOffset = strcmp( cellfun( @(atCTRoi) atCTRoi.Tag, atCTRoi, 'uni', false ), atCTVoi{vv}.RoisTag{rr} );
                                        dTagOffset = find(aTagOffset, 1);

                                        if ~isempty(dTagOffset)

                                            tRoi = atCTRoi{dTagOffset};

                                            switch lower(tRoi.Axe)

                                                case 'axes1'

                                                    aSlice = permute(aInputBuffer{tt}(tRoi.SliceNb,:,:), [3 2 1]);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLiverCTMask(tRoi.SliceNb,:,:) = voiMask|aLiverCTMask(tRoi.SliceNb,:,:);


                                                case 'axes2'

                                                    aSlice = permute(aInputBuffer{tt}(:,tRoi.SliceNb,:), [3 1 2]);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLiverCTMask(:,tRoi.SliceNb,:) = voiMask|aLiverCTMask(:,tRoi.SliceNb,:);

                                               case 'axes3'

                                                    aSlice = aInputBuffer{tt}(:,:,tRoi.SliceNb);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLiverCTMask(:,:,tRoi.SliceNb) = voiMask|aLiverCTMask(:,:,tRoi.SliceNb);

                                            end
                                        end
                                    end

                                    aLiverCTMask = aLiverCTMask(:,:,end:-1:1);

                                    machineLearning3DMask('set', 'Liver', aLiverCTMask, atCTVoi{vv}.Color, computeMaskVolume(aLiverCTMask, atInput(tt).atDicomInfo));
                                    clear aLiverCTMask;
                                end

                                if strcmpi(atCTVoi{vv}.Label, 'Lungs-LUN') % Found the Lungs VOI on the CT

                                    aLungsCTMask = zeros(size(aInputBuffer{tt}));

                                    for rr=1:numel(atCTVoi{vv}.RoisTag)

                                        aTagOffset = strcmp( cellfun( @(atCTRoi) atCTRoi.Tag, atCTRoi, 'uni', false ), atCTVoi{vv}.RoisTag{rr} );
                                        dTagOffset = find(aTagOffset, 1);

                                        if ~isempty(dTagOffset)

                                            tRoi = atCTRoi{dTagOffset};

                                            switch lower(tRoi.Axe)

                                                case 'axes1'

                                                    aSlice = permute(aInputBuffer{tt}(tRoi.SliceNb,:,:), [3 2 1]);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLungsCTMask(tRoi.SliceNb,:,:) = voiMask|aLungsCTMask(tRoi.SliceNb,:,:);


                                                case 'axes2'

                                                    aSlice = permute(aInputBuffer{tt}(:,tRoi.SliceNb,:), [3 1 2]);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLungsCTMask(:,tRoi.SliceNb,:) = voiMask|aLungsCTMask(:,tRoi.SliceNb,:);

                                               case 'axes3'

                                                    aSlice = aInputBuffer{tt}(:,:,tRoi.SliceNb);
                                                    voiMask = roiTemplateToMask(tRoi, aSlice);

                                                    aLungsCTMask(:,:,tRoi.SliceNb) = voiMask|aLungsCTMask(:,:,tRoi.SliceNb);
                                            end
                                        end
                                    end

                                    aLungsCTMask = aLungsCTMask(:,:,end:-1:1);

                                    machineLearning3DMask('set', 'Lungs', aLungsCTMask, atCTVoi{vv}.Color, computeMaskVolume(aLungsCTMask, atInput(tt).atDicomInfo));
                                    clear aLungsCTMask;
                                end
                            end
                        end

                        break;

                    end
                end

                clear aInputBuffer;
            end

            [~, ~, dCTVolume] = machineLearning3DMask('get', 'Lungs');

            if isempty(dCTVolume) % Acquire CT volume

                tReport.CT.Lungs.Volume  = [];
            else
                tReport.CT.Lungs.Volume  = dCTVolume;
            end
        else
            tReport.CT.Lungs.Volume  = dCTVolume;
        end

        clear aImage;

        progressBar( 1 , 'Ready' );

    end

    function exportCurrentLungLiverReportToPdfCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        try

 %         fig3DLungShuntReport = fig3DLungShuntReportPtr('get');

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

     %   sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        % Series Date

        sSeriesDate = atMetaData{1}.SeriesDate;

        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save 3D SPECT lung shunt report', sprintf('%s/3D LSF %s_%s_%s_%s_LUNG_SHUNT_REPORT_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(fig3DLungShuntReport, 'Pointer', 'watch');
        drawnow;

        if file ~= 0

            try
                saveReportLastUsedDir = path;
                save(sMatFile, 'saveReportLastUsedDir');
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end

            sFileName = sprintf('%s%s', path, file);

            if exist(sFileName, 'file')
                delete(sFileName);
            end

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            if viewerUIFigure('get') == true

                aRGBImage = frame2im(getframe(fig3DLungShuntReport));

                axePdfReport = ...
                   axes(fig3DLungShuntReport, ...
                         'Units'   , 'pixels', ...
                         'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
                         'Color'   , 'none',...
                         'Visible' , 'off'...
                         );
                axePdfReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                axePdfReport.Toolbar.Visible = 'off';
                disableDefaultInteractivity(axePdfReport);

                image(axePdfReport, aRGBImage);
                axePdfReport.Visible = 'off';

                exportgraphics(axePdfReport, sFileName);

                delete(axePdfReport);
            else
                set(axe3DLungShuntReport,'LooseInset', get(axe3DLungShuntReport,'TightInset'));
                unit = get(fig3DLungShuntReport,'Units');
                set(fig3DLungShuntReport,'Units','inches');
                pos = get(fig3DLungShuntReport,'Position');

                set(fig3DLungShuntReport, ...
                    'PaperPositionMode' , 'auto',...
                    'PaperUnits'        , 'inches',...
                    'PaperPosition'     , [0,0,pos(3),pos(4)],...
                    'PaperSize'         , [pos(3), pos(4)]);

                print(fig3DLungShuntReport, sFileName, '-image', '-dpdf', '-r0');

                set(fig3DLungShuntReport,'Units', unit);
            end

            progressBar( 1 , sprintf('Export %s completed.', sFileName));

            try
                winopen(sFileName);
            catch
            end
        end

        catch
            progressBar( 1 , 'Error: exportCurrentLungLiverReportToPdfCallback() cant export report' );
        end

        set(fig3DLungShuntReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentLungLiverAxialSlicesToAviCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        bMipPlayback = playback2DMipOnly('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

 %         fig3DLungShuntReport = fig3DLungShuntReportPtr('get');

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

        [file, path] = uiputfile(filter, 'Save 3D SPECT lung shunt axial slices', sprintf('%s/3D LSF %s_%s_%s_%s_LUNG_SHUNT_AXIAL_SLICES_TriDFusion.avi' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(fig3DLungShuntReport, 'Pointer', 'watch');
        drawnow;

        if file ~= 0

            try
                saveReportLastUsedDir = path;
                save(sMatFile, 'saveReportLastUsedDir');
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end

            sFileName = sprintf('%s%s', path, file);

            if exist(sFileName, 'file')
                delete(sFileName);
            end

            if ~contains(file, '.avi')
                file = [file, '.avi'];
            end

            playback2DMipOnly('set', false);

            sliceNumber('set', 'axial', size(dicomBuffer('get', [], dSeriesOffset), 3));

            multiFrameRecord('set', true);

            set(recordIconMenuObject('get'), 'State', 'on');

            recordMultiFrame(recordIconMenuObject('get'), path, file, 'avi', axes3Ptr('get', [], dSeriesOffset));

        end

        catch
            progressBar( 1 , 'Error: exportCurrentLungLiverAxialSlicesToAviCallback() cant export report' );
        end

        playback2DMipOnly('set', bMipPlayback);

        multiFrameRecord('set', false);

        set(recordIconMenuObject('get'), 'State', 'off');

        sliceNumber('set', 'axial', dAxialSliceNumber);

        sliderTraCallback();

        set(fig3DLungShuntReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentLungLiverAxialSlicesToDicomMovieCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        bMipPlayback = playback2DMipOnly('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

%         fig3DLungShuntReport = fig3DLungShuntReportPtr('get');

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
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end
        end

        set(fig3DLungShuntReport, 'Pointer', 'watch');
        drawnow;

        playback2DMipOnly('set', false);

        sliceNumber('set', 'axial', size(dicomBuffer('get', [], dSeriesOffset), 3));

        multiFrameRecord('set', true);

        set(recordIconMenuObject('get'), 'State', 'on');

        recordMultiFrame(recordIconMenuObject('get'), sOutDir, [], 'dcm', axes3Ptr('get', [], dSeriesOffset));

%         objectToDicomJpg(sWriteDir, fig3DLungShuntReport, '3DF MFSC', get(uiSeriesPtr('get'), 'Value'))

        catch
            progressBar( 1 , 'Error: exportCurrentLungLiverAxialSlicesToDicomMovieCallback() cant export report' );
        end

        playback2DMipOnly('set', bMipPlayback);

        multiFrameRecord('set', false);

        set(recordIconMenuObject('get'), 'State', 'off');

        sliceNumber('set', 'axial', dAxialSliceNumber);

        sliderTraCallback();

        set(fig3DLungShuntReport, 'Pointer', 'default');
        drawnow;
    end

    function copyLungLiverReportDisplayCallback(~, ~)

        try

            set(fig3DLungShuntReport, 'Pointer', 'watch');
            drawnow;

            if viewerUIFigure('get') == true

                aRGBImage = frame2im(getframe(fig3DLungShuntReport));

                axePdfReport = ...
                   axes(fig3DLungShuntReport, ...
                         'Units'   , 'pixels', ...
                         'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
                         'Color'   , 'none',...
                         'Visible' , 'off'...
                         );
                axePdfReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                axePdfReport.Toolbar.Visible = 'off';
                disableDefaultInteractivity(axePdfReport);

                image(axePdfReport, aRGBImage);
                axePdfReport.Visible = 'off';

                copygraphics(axePdfReport);

                delete(axePdfReport);
            else
                inv = get(fig3DLungShuntReport,'InvertHardCopy');

                set(fig3DLungShuntReport,'InvertHardCopy','Off');

                hgexport(fig3DLungShuntReport,'-clipboard');

                set(fig3DLungShuntReport,'InvertHardCopy',inv);
            end
        catch
            progressBar( 1 , 'Error: copyLungLiverReportDisplayCallback() cant copy report' );
        end

        set(fig3DLungShuntReport, 'Pointer', 'default');
        drawnow;
    end

    function display3DLungLiver()

        atInput = inputTemplate('get');

        % Modality validation

        dCTSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')

                dCTSerieOffset = tt;
                break;
            end
        end

        dNMSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')

                dNMSerieOffset = tt;
                break;
            end
        end

        if isempty(dCTSerieOffset) || isempty(dNMSerieOffset)

            progressBar(1, 'Error: display3DLungLiver() require a CT and NM image!');
            return;
        end

        atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);
        if isempty(atCTMetaData)

            atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
        end

        aCTBuffer = dicomBuffer('get', [], dCTSerieOffset);
        if isempty(aCTBuffer)

            aInputBuffer = inputBuffer('get');
            aCTBuffer = aInputBuffer{dCTSerieOffset};

            clear aInputBuffer;
        end

        x = atCTMetaData{1}.PixelSpacing(1);
        y = atCTMetaData{1}.PixelSpacing(2);
        z = computeSliceSpacing(atCTMetaData);

        aScaleFactor = [y x z];
        dScaleMax = max(aScaleFactor);

        if size(aCTBuffer, 3) > 200 % Two beds position

            dScaleMax = dScaleMax*1.5;
        end

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


        % MIP display

        ptrViewer3d = [];

        if ~isMATLABReleaseOlderThan('R2022b')

            if viewerUIFigure('get') == true

                [Mdti,~] = TransformMatrix(atCTMetaData{1}, computeSliceSpacing(atCTMetaData));

                % if volume3DZOffset('get') == false

                    Mdti(1,4) = 0;
                    Mdti(2,4) = 0;
                    Mdti(3,4) = 0;
                    Mdti(4,4) = 1;
                % end

                tform = affinetform3d(Mdti);

                ptrViewer3d = viewer3d('Parent'         , ui3DWindow, ...
                                       'BackgroundColor', 'white', ...
                                       'Lighting'       , 'off', ...
                                       'GradientColor'  , [0.98 0.98 0.98], ...
                                       'CameraZoom'     , 1.5, ...
                                       'Lighting'       ,'off');
                % sz = size(aCTBuffer);
                % center = sz/2 + 0.5;
                %
                % numberOfFrames = 360;
                % vec = linspace(0,2*pi,numberOfFrames)';
                % dist = sqrt(sz(1)^2 + sz(2)^2 + sz(3)^2);
                % myPosition = center + ([cos(vec) sin(vec) ones(size(vec))]*dist);
                %
                % aPosition = myPosition(250, :);
                %
                % aCameraPosition = [aPosition(1) -aPosition(3) abs(aPosition(2))];
                % aCameraUpVector = [0 0 1];
            end
        end

        if ~isempty(aCTBuffer)

            aCTBuffer = aCTBuffer(:,:,end:-1:1);

            if strcmpi(atCTMetaData{1}.Modality, 'CT')

                aColormap = gray(256);
                aAlphamap = defaultMipAlphaMap(aCTBuffer, 'CT');

            elseif strcmpi(atCTMetaData{1}.Modality, 'MR')

                aAlphamap   = defaultMipAlphaMap(aCTBuffer, 'MR');
                aColormap = getAngioColorMap();
            else
                aAlphamap = defaultMipAlphaMap(aCTBuffer, 'PET');
                aColormap = gray(256);
            end

            % Isosurface display image

%            aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'Isosurface', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};

%            aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

%            if isMATLABReleaseOlderThan('R2022b')
%                pObject = volshow(squeeze(aCTBuffer),  aInputArguments{:});
%            else
%                pObject = images.compatibility.volshow.R2022a.volshow(squeeze(aCTBuffer), aInputArguments{:});
%            end
%            pObject.IsosurfaceColor = 'white';
%            pObject.Isovalue = ctHUToScalarValue(aCTBuffer, 150)/100;

%            pObject.CameraPosition = aCameraPosition;
%            pObject.CameraUpVector = aCameraUpVector;

            % MaximumIntensityProjection display image

            aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'MaximumIntensityProjection', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};

            aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

            if isMATLABReleaseOlderThan('R2022b')

                pObject = volshow(squeeze(aCTBuffer),  aInputArguments{:});
            else
                if ~isempty(ptrViewer3d)

                    pObject = volshow(squeeze(aCTBuffer), ...
                                      'Parent'        , ptrViewer3d, ...
                                      'RenderingStyle', 'MaximumIntensityProjection',...
                                      'Alphamap'      , aAlphamap, ...
                                      'Colormap'      , aColormap, ...
                                      'Transformation', tform);
                else
                    pObject = images.compatibility.volshow.R2022a.volshow(squeeze(aCTBuffer), aInputArguments{:});
                end
            end

            if ~isempty(ptrViewer3d)
                %
                % idxOffset = 270;
                %
                % sz = size(aCTBuffer);
                % center = sz/2 + 0.5;
                %
                % % set(ptrViewer3d, 'CameraTarget', center);
                %
                % numberOfFrames = 360;
                % vec = linspace(0,2*pi,numberOfFrames)';
                % dist = sqrt(sz(1)^2 + sz(2)^2 + sz(3)^2);
                % myPosition = center + ([cos(vec) sin(vec) ones(size(vec))]*dist);
                %
                %
                % aPosition = myPosition(idxOffset,:);
                %
                % set(ptrViewer3d, 'CameraPosition', aPosition);



                 % ptrViewer3d.CameraTarget   = aCameraTarget;
                 % ptrViewer3d.CameraPosition = aCameraPosition;
                 % ptrViewer3d.CameraUpVector = aCameraUpVector;
            else
                pObject.CameraPosition = aCameraPosition;
                pObject.CameraUpVector = aCameraUpVector;
            end

        end

        % Mask Volume Rendering

        if ~isempty(ptrViewer3d)

            for jj=1:numel(gasMask)

                [aMask, aColor] = machineLearning3DMask('get', gasMask{jj});

                if ~isempty(aMask)

                    aMask = smooth3(aMask, 'box', 3);

                    aColormap = zeros(256,3);

                    aColormap(:,1) = aColor(1);
                    aColormap(:,2) = aColor(2);
                    aColormap(:,3) = aColor(3);

                    dTransparencyValue = get(uiSlider3Dintensity, 'Value');

                    aAlphamap = linspace(0, dTransparencyValue, 256)';

                    gp3DObject{jj} = volshow(squeeze(aMask), ...
                                             'Parent'        , ptrViewer3d, ...
                                             'RenderingStyle', 'VolumeRendering',...
                                             'Alphamap'      , aAlphamap, ...
                                             'Colormap'      , aColormap, ...
                                             'Transformation', tform);

                    clear aMask;
                end
            end

        else

            aMasksColor = zeros(numel(gasMask), 3);
            aMask = zeros(size(aCTBuffer));

            dNbMasks = numel(gasMask);

            for jj=1:dNbMasks

                [aCurrentMask, aColor] = machineLearning3DMask('get', gasMask{jj});

                if jj == 1
                    aMask(aCurrentMask==1) = 1;
                else
                    aMask(aCurrentMask==1) = jj+1;
                end

                aMasksColor(jj, :) = aColor;
            end

            if any(aMask(:) ~= 0)

                aMask = smooth3(aMask, 'box', 3);

                numColors = 256;
                aColormap = zeros(numColors, 3);
                for ii = 1:dNbMasks
                    startIdx = round((ii-1)*(numColors/dNbMasks))+1;
                    endIdx = round(ii*(numColors/dNbMasks));
                    aColormap(startIdx:endIdx, :) = repmat(aMasksColor(ii, :), endIdx-startIdx+1, 1);
                end

                dTransparencyValue = get(uiSlider3Dintensity, 'Value');

                aAlphamap = linspace(0, dTransparencyValue, 256)';

                aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};

                aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

                if isMATLABReleaseOlderThan('R2022b')

                    gp3DObject{1} = volshow(squeeze(aMask), aInputArguments{:});

                else

                    gp3DObject{1} = images.compatibility.volshow.R2022a.volshow(squeeze(aMask), aInputArguments{:});

                end

                gp3DObject{1}.CameraPosition = aCameraPosition;
                gp3DObject{1}.CameraUpVector = aCameraUpVector;

                clear aMask;
            end
        end

        if ~isempty(ptrViewer3d)

            set(ptrViewer3d, 'Lighting', 'on');
        end
    end

    function slider3DLungLiverintensityCallback(~, ~)

        dSliderValue = get(uiSlider3Dintensity, 'Value');

        aAlphamap = linspace(0, dSliderValue, 256)';

        for jj=1:numel(gasMask)

            gp3DObject{jj}.Alphamap = aAlphamap;
        end

    end

    function ui3DLungShuntReportSliderCallback(~, ~)

        val = get(ui3DLungShuntReportSlider, 'Value');

        aPosition = get(ui3DLungShuntReport, 'Position');

        dPanelOffset = -((1-val) * aPosition(4));

        set(ui3DLungShuntReport, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function dVolumeOversizedSize = getVolumeOversizedSize(dNbPixels)

        atInput = inputTemplate('get');

        % Modality validation

        dNMSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')

                dNMSerieOffset = tt;
                break;
            end
        end

        if ~isempty(dNMSerieOffset)

            dVolumeOversizedSize = atInput(dNMSerieOffset).atDicomInfo{1}.PixelSpacing(1)*dNbPixels;
        else
            dVolumeOversizedSize =0;
        end

    end

    function dVolumeExtraSlicesSize = getVolumeExtraSlicesSize(dNbSlices)

        atInput = inputTemplate('get');

        % Modality validation

        dNMSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')

                dNMSerieOffset = tt;
                break;
            end
        end

        if ~isempty(dNMSerieOffset)

            dSliceThickness = computeSliceSpacing(atInput(dNMSerieOffset).atDicomInfo);

            dVolumeExtraSlicesSize = dSliceThickness*dNbSlices;
        else
            dVolumeExtraSlicesSize =0;
        end

    end

    function uiEditLiverVolumeOversizedCallback(~, ~)

        dNbPixels = round(str2double(get(uiEditLiverVolumeOversized, 'String')));

        if dNbPixels < 0
            dNbPixels = 0;
        end

        set(uiEditLiverVolumeOversized, 'String', num2str(dNbPixels));

        sExtraPixelsSize = sprintf('pixel(s) (%2.2f mm)', getVolumeOversizedSize(dNbPixels));
        set(uiTextLiverVolumeOversized, 'String', sExtraPixelsSize);
    end

    function uiEditLiverTopOfVolumeExtraSlicesCallback(~, ~)

        dNbExtraSlices = round(str2double(get(uiEditLiverTopOfVolumeExtraSlices, 'String')));

%        if dNbExtraSlices < 0
%            dNbExtraSlices = 0;
%        end

        set(uiEditLiverTopOfVolumeExtraSlices, 'String', num2str(dNbExtraSlices));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbExtraSlices));
        set(uiTextLiverTopOfVolumeExtraSlices, 'String', sExtraSlicesSize);

    end


    function uiEditLiverBottomOfVolumeExtraSlicesCallback(~, ~)

        dNbExtraSlices = round(str2double(get(uiEditLiverBottomOfVolumeExtraSlices, 'String')));

 %       if dNbExtraSlices < 0
 %           dNbExtraSlices = 0;
 %       end

        set(uiEditLiverBottomOfVolumeExtraSlices, 'String', num2str(dNbExtraSlices));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbExtraSlices));
        set(uiTextLiverBottomOfVolumeExtraSlices, 'String', sExtraSlicesSize);

    end

    function uiCheckLungsVolumeOverlapCallback(hObject, ~)

        bOverlap = get(uiCheckLungsVolumeOverlap, 'value');

        if strcmpi(get(hObject, 'Style'), 'text')
            if bOverlap == true
                bOverlap = false;
            else
                 bOverlap = true;
            end

            set(uiCheckLungsVolumeOverlap, 'value', bOverlap);

        end

        lungShuntLungsVolumeOverlap('set', bOverlap);

    end

    function uiEditLungsVolumeOversizedCallback(~, ~)

        dNbPixels = round(str2double(get(uiEditLungsVolumeOversized, 'String')));

        if dNbPixels < 0
            dNbPixels = 0;
        end

        set(uiEditLungsVolumeOversized, 'String', num2str(dNbPixels));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbPixels));
        set(uiTextLungsVolumeOversized, 'String', sExtraSlicesSize);

    end

    function proceedLiverVolumeOversize(~, ~)

        atInput = inputTemplate('get');

        % Modality validation

        dNMSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')

                dNMSerieOffset = tt;
                break;
            end
        end

        dCTSerieOffset = [];
        for tt=1:numel(atInput)

            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')

                dCTSerieOffset = tt;
                break;
            end
        end

        aNMImage = dicomBuffer('get', [], dNMSerieOffset);

        aCTImage = dicomBuffer('get', [], dCTSerieOffset);
        if isempty(aCTImage)

            aInputBuffer = inputBuffer('get');
            aCTImage = aInputBuffer{dCTSerieOffset};

            clear aInputBuffer;
        end

        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;

        if isempty(dCTSerieOffset) || isempty(dNMSerieOffset)

            progressBar(1, 'Error: proceedLiverVolumeOversize() 3D Lung Liver Ratio require a CT and NM image!');
            errordlg('Error: proceedLiverVolumeOversize() 3D Lung Liver Ratio require a CT and NM image!', 'Modality Validation');
            return;
        end

        dNbExtraSlicesAtTop    = round(str2double(get(uiEditLiverTopOfVolumeExtraSlices, 'String')));
        dNbExtraSlicesAtBottom = round(str2double(get(uiEditLiverBottomOfVolumeExtraSlices, 'String')));

        dLiverMaskOffset = round(str2double(get(uiEditLiverVolumeOversized, 'String')));
        dLungsMaskOffset = round(str2double(get(uiEditLungsVolumeOversized, 'String')));

        bLungsCanOverlapTheLiver = get(uiCheckLungsVolumeOverlap, 'value');

        if ~isempty(gtReport)

             try

            set(fig3DLungShuntReport, 'Pointer', 'watch');
            drawnow;

            set(uiSliderLiverVolumeRatio, 'Enable', 'off');
            set(uiSliderLungsVolumeRatio, 'Enable', 'off');

            set(uiEditLiverVolumeRatio, 'Enable', 'off');
            set(uiEditLungsVolumeRatio, 'Enable', 'off');

            set(uiEditLiverTopOfVolumeExtraSlices   , 'Enable', 'off');
            set(uiEditLiverBottomOfVolumeExtraSlices, 'Enable', 'off');
            set(uiEditLiverVolumeOversized          , 'Enable', 'off');
            set(uiEditLungsVolumeOversized          , 'Enable', 'off');
            set(uiProceedLiverVolumeOversize        , 'Enable', 'off');
            set(uiCheckLungsVolumeOverlap           , 'Enable', 'off');
            set(uiTextLungsVolumeOverlap            , 'Enable', 'on');

            set(uiEditInjectedActivity, 'Enable', 'off');
            set(uicalculateLungDose   , 'Enable', 'off');

            set(uiReport3DLungShuntLungRatio     , 'string', ' ');
            set(uiReport3DLungShuntCalculatedDose, 'String', ' ');
            set(uiEditWindow, 'string', ' ');

            progressBar(1/4, 'Computing oversized liver mask, please wait.');

            if dNbExtraSlicesAtTop    ~= lungShuntLiverTopOfVolumeExtraSlices('get')    || ...
               dNbExtraSlicesAtBottom ~= lungShuntLiverBottomOfVolumeExtraSlices('get') || ...
               dLiverMaskOffset       ~= lungShuntLiverVolumeOversized('get')           || ...
               dLungsMaskOffset       ~= lungShuntLungsVolumeOversized('get')           || ...
               bInitReport            == true % First run

                dFirstSlice = [];
                dLastSlice = [];

                aLiverMask = gtReport.NM.Liver.Mask;

                for jj=1:size(aLiverMask, 3)

                    dOffset = find(aLiverMask(:,:,jj), 1);
                    if ~isempty(dOffset)

                        if isempty(dFirstSlice)

                            dFirstSlice = jj;
                        end

                        dLastSlice = jj;
                    end
                end

                if dLiverMaskOffset ~= 0

                    if dNbExtraSlicesAtTop < 0 || dNbExtraSlicesAtBottom < 0

                        aLiverMaskTemp = imdilate(aLiverMask, strel('sphere', dLiverMaskOffset)); % Increse mask by x pixels

                        aLiverMaskTemp(:,:,1:dFirstSlice-1-dNbExtraSlicesAtTop) = 0;
                        aLiverMaskTemp(:,:,dLastSlice+1+dNbExtraSlicesAtBottom:end) = 0;

                        if dNbExtraSlicesAtTop < 0

                            aLiverMaskTemp(:,:,dFirstSlice:dFirstSlice-1-dNbExtraSlicesAtTop) = ...
                                aLiverMask(:,:,dFirstSlice:dFirstSlice-1-dNbExtraSlicesAtTop);
                        end

                        if dNbExtraSlicesAtBottom < 0

                            aLiverMaskTemp(:,:,dLastSlice+1+dNbExtraSlicesAtBottom:dLastSlice) = ...
                                aLiverMask(:,:,dLastSlice+1+dNbExtraSlicesAtBottom:dLastSlice);
                        end

                        aLiverMask = aLiverMaskTemp;

                        clear aLiverMaskTemp;
                    else
                        aLiverMask = imdilate(aLiverMask, strel('sphere', dLiverMaskOffset)); % Increse mask by x pixels

                        aLiverMask(:,:,1:dFirstSlice-1-dNbExtraSlicesAtTop) = 0;
                        aLiverMask(:,:,dLastSlice+1+dNbExtraSlicesAtBottom:end) = 0;
                    end
                end

                deleteLungShuntVoiContours('Liver-LIV', dNMSerieOffset);

%                 if pixelEdge('get') == false
%                     aLiverMask = smooth3DMask(aLiverMask, 1.0, 5 ,0.1);
%                 end

                if numel(aLiverMask) ~= numel(aNMImage)

                    [aLiverMask, ~] = resampleImage(aLiverMask, atNMMetaData, aCTImage, atCTMetaData, 'Nearest', false, false);
                end

%                 if pixelEdge('get') == false
%
%                     % Smooth the 3D mask using smooth3
%                     aLiverMask = smooth3(aLiverMask, 'box', 3);
%                 end

                maskToVoi(aLiverMask, 'Liver', 'Liver', gtReport.NM.Liver.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

                % Clean Lungs Mask

                progressBar(2/4, 'Computing oversized lungs mask, please wait.');

                aLungsMask = gtReport.NM.Lungs.Mask;

                if dLungsMaskOffset ~= 0

                    aLungsMask = imdilate(aLungsMask, strel('sphere', dLungsMaskOffset)); % Increse mask by x pixels
                end

%                 if pixelEdge('get') == false
%                     aLungsMask = smooth3DMask(aLungsMask, 1.0, 5 ,0.1);
%                 end

                if numel(aLungsMask) ~= numel(aNMImage)

                    [aLungsMask, ~] = resampleImage(aLungsMask, atNMMetaData, aCTImage, atCTMetaData, 'Nearest', false, false);
                end

%                 if pixelEdge('get') == false
%
%                     % Smooth the 3D mask using smooth3
%                     aLungsMask = smooth3(aLungsMask, 'box', 3);
%                 end

                if bLungsCanOverlapTheLiver == false

                    aLungsMask(aLiverMask~=0)=0;
                end

                deleteLungShuntVoiContours('Lungs-LUN', dNMSerieOffset);

                maskToVoi(aLungsMask, 'Lungs', 'Lung', gtReport.NM.Lungs.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

                lungShuntLiverTopOfVolumeExtraSlices   ('set', dNbExtraSlicesAtTop);
                lungShuntLiverBottomOfVolumeExtraSlices('set', dNbExtraSlicesAtBottom);

                lungShuntLiverVolumeOversized('set', dLiverMaskOffset);
                lungShuntLungsVolumeOversized('set', dLungsMaskOffset);

%                 if numel(aLiverMask) ~= numel(aNMImage)
%
%                     atRoi = roiTemplate('get', dNMSerieOffset);
%
%                     atResampledRoi = resampleROIs(aLiverMask, atNMMetaData, dicomBuffer('get'), dicomMetaData('get'), atRoi, true);
%
%                     roiTemplate('set', dNMSerieOffset, atResampledRoi);
%                 end

                clear aLiverMask;
                clear aLungsMask;
            end

            clear aNMImage;
            clear aCTImage;

            progressBar(3/4, 'Reprocessing contours information, please wait.');

            gtReport = computeLungLiverReportContoursInformation(suvMenuUnitOption('get'), false, false, false);

            if isvalid(uiReport3DLungShuntInformation) % Make sure the figure is still open

                set(uiReport3DLungShuntInformation, 'String', sprintf('Contours Information (%s)', getLungLiverReportUnitValue()));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open

                set(uiReportLesionMean, 'String', getLungLiverReportMeanInformation('get', gtReport));
            end

            if isvalid(uiReportLesionTotal) % Make sure the figure is still open

                set(uiReportLesionTotal, 'String', getLungLiverReportTotalInformation('get', gtReport));
            end

            if isvalid(uiReportLesionVolume) % Make sure the figure is still open

                set(uiReportLesionVolume, 'String', getLungLiverReportVolumeInformation('get', gtReport));
            end

            if isvalid(uiReport3DLungShuntLungRatio)

                set(uiReport3DLungShuntLungRatio, 'String', getLungLiverReportRatioInformation(gtReport));
            end

            if get(uiSliderLiverVolumeRatio, 'Value') ~=1 || ...
               get(uiSliderLungsVolumeRatio, 'Value') ~=1

                dLiverPercent = get(uiSliderLiverVolumeRatio, 'Value')*100;
                dLungsPercent = get(uiSliderLungsVolumeRatio, 'Value')*100;

                if ~isempty(gtReport)

                    dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
                    dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

                    if ~isempty(gtReport.CT.Lungs.Volume)

                        dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent;
                    else
                        dLungsVolume = [];
                    end

                    %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
                    % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
                    %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

                    dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

                    sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungShuntFraction);

                    set(uiReport3DLungShuntLungRatio , 'string', sLungShuntFraction);

                    if dLiverPercent == 100 && dLungsPercent == 100

                        set(uiEditWindow, 'string', '');
                    else

                        if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('Updated NM lungs counts: %.2f\n', dLungsTotal);
                        else
                            sUpdatedValues = '';
                        end


                        if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('%sUpdated NM liver counts  : %.2f', sUpdatedValues, dLiverTotal);
                        end

                        if ~isempty(dLungsVolume)

                            if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                                if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                                    sUpdatedValues = sprintf('%s\n\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                                else
                                    sUpdatedValues = sprintf('%s\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                                end
                            end
                        end

                        set(uiEditWindow, 'string', sUpdatedValues);
                    end

                    %                          Total amount of injected activity (GBq)
                    % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
                    %                                   Lung mass (Kg)

                    if ~isempty(dLungsVolume)

                        dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

                        if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                            dInjectedActivity = dInjectedActivity/1000; % In GBq

                            dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                            sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                            set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
                        end
                    end
                end
            end

            refreshImages();

            progressBar(1, 'Ready');

            catch
                progressBar(1, 'Error: proceedLiverVolumeOversize()');
            end

            set(uiSliderLiverVolumeRatio, 'Enable', 'on');
            set(uiSliderLungsVolumeRatio, 'Enable', 'on');

            set(uiEditLiverVolumeRatio, 'Enable', 'on');
            set(uiEditLungsVolumeRatio, 'Enable', 'on');

            set(uiEditLiverTopOfVolumeExtraSlices   , 'Enable', 'on');
            set(uiEditLiverBottomOfVolumeExtraSlices, 'Enable', 'on');
            set(uiEditLiverVolumeOversized          , 'Enable', 'on');
            set(uiEditLungsVolumeOversized          , 'Enable', 'on');
            set(uiProceedLiverVolumeOversize        , 'Enable', 'on');
            set(uiCheckLungsVolumeOverlap           , 'Enable', 'on');
            set(uiTextLungsVolumeOverlap            , 'Enable', 'inactive');

            set(uiEditInjectedActivity, 'Enable', 'on');
            set(uicalculateLungDose   , 'Enable', 'on');

            set(fig3DLungShuntReport, 'Pointer', 'default');
            drawnow;

        end

    end

    function deleteLungShuntVoiContours(sVoiLabel, dSerieOffset)

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if ~isempty(atVoiInput)

            % Search for a voi tag, if we don't find one, then the tag is
            % roi

            aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Label, atVoiInput, 'uni', false ), sVoiLabel );

            if aTagOffset(aTagOffset==1) % tag is a voi

                dTagOffset = find(aTagOffset, 1);

                if ~isempty(dTagOffset)

                    % Clear roi from roi input template

                    aRoisTagOffset = zeros(1, numel(atVoiInput{dTagOffset}.RoisTag));
                    if ~isempty(atRoiInput)

                        for ro=1:numel(atVoiInput{dTagOffset}.RoisTag)

                            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[atVoiInput{dTagOffset}.RoisTag{ro}]} );
                            aRoisTagOffset(ro) = find(aTagOffset, 1);
                        end

                        if numel(atVoiInput{dTagOffset}.RoisTag)

                            for ro=1:numel(atVoiInput{dTagOffset}.RoisTag)

                                % Clear it constraint

                                [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );

                                if ~isempty(asConstraintTagList)

                                    dConstraintOffset = find(contains(asConstraintTagList, atVoiInput{dTagOffset}.RoisTag(ro)));
                                    if ~isempty(dConstraintOffset) % tag exist

                                         roiConstraintList('set', dSerieOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                                    end
                                end

                                % Delete farthest distance object

                                if roiHasMaxDistances(atRoiInput{aRoisTagOffset(ro)}) == true
                    
                                    maxDistances = atRoiInput{aRoisTagOffset(ro)}.MaxDistances; % Cache the field to avoid repeated lookups
                    
                                    objectsToDelete = [maxDistances.MaxXY.Line, ...
                                                       maxDistances.MaxCY.Line, ...
                                                       maxDistances.MaxXY.Text, ...
                                                       maxDistances.MaxCY.Text];
                                    % Delete only valid objects
                                    delete(objectsToDelete(isvalid(objectsToDelete)));  

                                    atRoiInput{aRoisTagOffset(ro)} = rmfield(atRoiInput{aRoisTagOffset(ro)}, 'MaxDistances');                                   
                                end

                                % Delete ROI object

                                if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)

                                    delete(atRoiInput{aRoisTagOffset(ro)}.Object);
                                end

                                atRoiInput{aRoisTagOffset(ro)} = [];
                            end

                            atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                            roiTemplate('set', dSerieOffset, atRoiInput);
                        end
                    end

                    % Clear voi from voi input template

                    atVoiInput{dTagOffset} = [];
                    atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                    voiTemplate('set', dSerieOffset, atVoiInput);

                end
            end
        end
    end

    function uiSliderLiverVolumeRatioCallback(~,~)

        dLiverPercent = get(uiSliderLiverVolumeRatio, 'Value')*100;
        dLungsPercent = str2double(get(uiEditLungsVolumeRatio, 'String'));

        set(uiEditLiverVolumeRatio, 'string',  sprintf('%2.2f', dLiverPercent));

        if ~isempty(gtReport)

            dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

            if ~isempty(gtReport.CT.Lungs.Volume)

                dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent;
            else
                dLungsVolume = [];
            end

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
            %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungShuntFraction);

            set(uiReport3DLungShuntLungRatio , 'string', sLungShuntFraction);

            if dLiverPercent == 100 && dLungsPercent == 100

                set(uiEditWindow, 'string', '');
            else

                if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('Updated NM lungs counts: %.2f\n', dLungsTotal);
                else
                    sUpdatedValues = '';
                end


                if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('%sUpdated NM liver counts  : %.2f', sUpdatedValues, dLiverTotal);
                end

                if ~isempty(dLungsVolume)

                    if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                        if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('%s\n\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        else
                            sUpdatedValues = sprintf('%s\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        end
                    end
                end

                set(uiEditWindow, 'string', sUpdatedValues);
            end

            %                          Total amount of injected activity (GBq)
            % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
            %                                   Lung mass (Kg)

            if ~isempty(dLungsVolume)

                dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

                if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                    dInjectedActivity = dInjectedActivity/1000; % In GBq

                    dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                    sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                    set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
                end
            end
        end

    end

    function uiEditLungsVolumeRatioCallback(~, ~)

        delete(uiSliderLungsVolumeRatioListener);

        dLiverPercent = str2double(get(uiEditLiverVolumeRatio, 'String'));
        dLungsPercent = str2double(get(uiEditLungsVolumeRatio, 'String'));

        if dLungsPercent < 0
            dLungsPercent = 0;
        end

        if dLungsPercent > 100
            dLungsPercent = 100;
        end

        if ~isempty(gtReport)

            dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

            if ~isempty(gtReport.CT.Lungs.Volume)

                dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent;
            else
                dLungsVolume = [];
            end

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
            %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%', dLungShuntFraction);

            set(uiReport3DLungShuntLungRatio , 'string', sLungShuntFraction);

            set(uiSliderLungsVolumeRatio, 'Value', dLungsPercent/100);

            if dLiverPercent == 100 && dLungsPercent == 100

                set(uiEditWindow, 'string', '');
            else

                if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('Updated NM lungs counts: %.2f\n', dLungsTotal);
                else
                    sUpdatedValues = '';
                end


                if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('%sUpdated NM liver counts  : %.2f', sUpdatedValues, dLiverTotal);
                end

                if ~isempty(dLungsVolume)

                    if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                        if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('%s\n\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        else
                            sUpdatedValues = sprintf('%s\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        end
                    end
                end

                set(uiEditWindow, 'string', sUpdatedValues);
            end

            %                          Total amount of injected activity (GBq)
            % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
            %                                   Lung mass (Kg)

            if ~isempty(dLungsVolume)

                dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

                if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                    dInjectedActivity = dInjectedActivity/1000; % In GBq

                    dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                    sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                    set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
                end
            end
        end

%         uiSliderLungsVolumeRatioListener = addlistener(uiSliderLungsVolumeRatio, 'Value', 'PreSet', @uiSliderLungsVolumeRatioCallback);
        uiSliderLungsVolumeRatioListener = addlistener(uiSliderLungsVolumeRatio, 'ContinuousValueChange', @uiSliderLungsVolumeRatioCallback);

    end

    function uiSliderLungsVolumeRatioCallback(~, ~)

        dLiverPercent = str2double(get(uiEditLiverVolumeRatio, 'String'));
        dLungsPercent = get(uiSliderLungsVolumeRatio, 'Value')*100;

        set(uiEditLungsVolumeRatio, 'string',  sprintf('%2.2f', dLungsPercent));

        if ~isempty(gtReport)

            dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

            if ~isempty(gtReport.CT.Lungs.Volume)

                dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent;
            else
                dLungsVolume = [];
            end

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
            %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%', dLungShuntFraction);

            set(uiReport3DLungShuntLungRatio , 'string', sLungShuntFraction);

            if dLiverPercent == 100 && dLungsPercent == 100

                set(uiEditWindow, 'string', '');
            else

                if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('Updated NM lungs counts: %.2f\n', dLungsTotal);
                else
                    sUpdatedValues = '';
                end


                if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('%sUpdated NM liver counts  : %.2f', sUpdatedValues, dLiverTotal);
                end

                if ~isempty(dLungsVolume)

                    if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                        if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('%s\n\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        else
                            sUpdatedValues = sprintf('%s\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        end
                    end
                end

                set(uiEditWindow, 'string', sUpdatedValues);
            end

            %                          Total amount of injected activity (GBq)
            % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
            %                                   Lung mass (Kg)

            if ~isempty(dLungsVolume)

                dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

                if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                    dInjectedActivity = dInjectedActivity/1000; % In GBq

                    dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                    sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                    set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
                end
            end
        end
    end

    function uiEditLiverVolumeRatioCallback(~, ~)

        delete(uiSliderLiverVolumeRatioListener);

        dLiverPercent = str2double(get(uiEditLiverVolumeRatio, 'String'));
        dLungsPercent = str2double(get(uiEditLungsVolumeRatio, 'String'));

        if dLiverPercent < 0
            dLiverPercent = 0;
        end

        if dLiverPercent > 100
            dLiverPercent = 100;
        end

        if ~isempty(gtReport)

            dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

            if ~isempty(gtReport.CT.Lungs.Volume)

                dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent;
            else
                dLungsVolume = [];
            end

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆h𝑢𝑛𝑡 = ____________________________ × 100
            %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            sLungShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungShuntFraction);

            set(uiReport3DLungShuntLungRatio , 'string', sLungShuntFraction);

            set(uiSliderLiverVolumeRatio, 'Value', dLiverPercent/100);

            if dLiverPercent == 100 && dLungsPercent == 100

                set(uiEditWindow, 'string', '');
            else

                if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('Updated NM lungs counts: %.2f\n', dLungsTotal);
                else
                    sUpdatedValues = '';
                end


                if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                    sUpdatedValues = sprintf('%sUpdated NM liver counts  : %.2f', sUpdatedValues, dLiverTotal);
                end

                if ~isempty(dLungsVolume)

                    if get(uiSliderLungsVolumeRatio, 'Value') ~= 1

                        if get(uiSliderLiverVolumeRatio, 'Value') ~= 1

                            sUpdatedValues = sprintf('%s\n\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        else
                            sUpdatedValues = sprintf('%s\nUpdated CT lungs volume: %.2f ml', sUpdatedValues, dLungsVolume);
                        end
                    end
                end

                set(uiEditWindow, 'string', sUpdatedValues);
            end

            %                          Total amount of injected activity (GBq)
            % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
            %                                   Lung mass (Kg)

            if ~isempty(dLungsVolume)

                dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

                if dInjectedActivity > 0 && ~isnan(dInjectedActivity)

                    dInjectedActivity = dInjectedActivity/1000; % In GBq

                    dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                    sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                    set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
                end
            end

        end

%         uiSliderLiverVolumeRatioListener = addlistener(uiSliderLiverVolumeRatio, 'Value', 'PreSet', @uiSliderLiverVolumeRatioCallback);
        uiSliderLiverVolumeRatioListener = addlistener(uiSliderLiverVolumeRatio, 'ContinuousValueChange', @uiSliderLiverVolumeRatioCallback);

    end

    function calculateLungDoseCallback(~, ~)

        dLiverPercent = str2double(get(uiEditLiverVolumeRatio, 'String'));
        dLungsPercent = str2double(get(uiEditLungsVolumeRatio, 'String'));

        if dLiverPercent < 0 || dLiverPercent > 100

            set(uiReport3DLungShuntCalculatedDose, 'String', ' ');
            return;
        end

        if dLungsPercent < 0 || dLungsPercent > 100

            set(uiReport3DLungShuntCalculatedDose, 'String', ' ');
            return;
        end

        dInjectedActivity = str2double(get(uiEditInjectedActivity, 'String')); % In MBq

        if dInjectedActivity <= 0 || isnan(dInjectedActivity)

            set(uiReport3DLungShuntCalculatedDose, 'String', ' ');
            return;
        end

        if ~isempty(gtReport)

            dLungsTotal = gtReport.NM.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.NM.Liver.Total*100/dLiverPercent;

            if ~isempty(gtReport.CT.Lungs.Volume)

                dLungsVolume = gtReport.CT.Lungs.Volume*100/dLungsPercent; % in ml
            else
                dLungsVolume = [];
            end

            %                    ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            % Lung 𝑆ℎ𝑢𝑛𝑡 = ____________________________ × 100
            %              ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )

            dLungShuntFraction = dLungsTotal/(dLiverTotal+dLungsTotal)*100;

            %                          Total amount of injected activity (GBq)
            % Lung Dose (Gy) = 49.67 x _______________________________________ x LSF
            %                                   Lung mass (Kg)

            if ~isempty(dLungsVolume)

                dInjectedActivity = dInjectedActivity/1000; % In GBq

                dLungMass = dLungsVolume*0.00024; % Lung density of healthy subjects obtained via x-ray was reported to be 0.24 g/cm3

                sCalculateDose = sprintf('Lung Absorbed Dose: %.2f Gy', 49.67*(dInjectedActivity/dLungMass) * (dLungShuntFraction/100));
                set(uiReport3DLungShuntCalculatedDose, 'String', sCalculateDose);
            end
        end
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
