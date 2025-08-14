function generatePETLiverDosimetryReportCallback(~, ~)
%function generatePETLiverDosimetryReportCallback()
%Generate a report, from PET Y90 liver dosimetry.
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

    gp3DObject = [];

    gasOrganList={'Liver'};

    gasMask = {'liver'};

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end

    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 880;

    if viewerUIFigure('get') == true

        figPETLiverDosimetryReport = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                   FIG_REPORT_X ...
                   FIG_REPORT_Y],...
                    'Resize', 'off', ...
                    'Color', 'white',...
                    'Name' , 'TriDFusion (3DF) PET Y90 Liver Dosimetry Report'...
                    );
    else
        figPETLiverDosimetryReport = ...
            figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
                   (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
                   FIG_REPORT_X ...
                   FIG_REPORT_Y],...
                   'Name', 'TriDFusion (3DF) PET Y90 Liver Dosimetry Report',...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'Color', 'white', ...
                   'Toolbar','none'...
                   );
    end
    
    setObjectIcon(figPETLiverDosimetryReport);

    if viewerUIFigure('get') == true
        set(figPETLiverDosimetryReport, 'Renderer', 'opengl'); 
        set(figPETLiverDosimetryReport, 'GraphicsSmoothing', 'off'); 
    else
        set(figPETLiverDosimetryReport, 'Renderer', 'opengl'); 
        set(figPETLiverDosimetryReport, 'doublebuffer', 'on');   
    end

    figPETLiverDosimetryReportPtr('set', figPETLiverDosimetryReport);

    axePETLiverDosimetryReport = ...
       axes(figPETLiverDosimetryReport, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
             'Color'   , 'white',...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
     axePETLiverDosimetryReport.Interactions = [];
     % axePETLiverDosimetryReport.Toolbar.Visible = 'off';
     deleteAxesToolbar(axePETLiverDosimetryReport);
     disableDefaultInteractivity(axePETLiverDosimetryReport);

     uiPETLiverDosimetryReport = ...
         uipanel(figPETLiverDosimetryReport,...
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

    aPETLiverDosimetryReportPosition = get(figPETLiverDosimetryReport, 'position');
    uiPETLiverDosimetryReportSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , figPETLiverDosimetryReport,...
                  'Units'   , 'pixels',...
                  'position', [aPETLiverDosimetryReportPosition(3)-15 ...
                               0 ...
                               15 ...
                               aPETLiverDosimetryReportPosition(4) ...
                               ],...
                  'Value', 1, ...
                  'Callback',@uiPETLiverDosimetryReportSliderCallback, ...
                  'BackgroundColor', 'white', ...
                  'ForegroundColor', 'black' ...
                  );
%     addlistener(uiPETLiverDosimetryReportSlider, 'Value', 'PreSet', @uiPETLiverDosimetryReportSliderCallback);
    addlistener(uiPETLiverDosimetryReportSlider, 'ContinuousValueChange', @uiPETLiverDosimetryReportSliderCallback);

        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , ' TriDFusion (3DF) PET Y90 Liver Dosimetry Report',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-30 FIG_REPORT_X 20]...
                  );

        uicontrol(uiPETLiverDosimetryReport,...
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

         uicontrol(uiPETLiverDosimetryReport,...
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
        uicontrol(uiPETLiverDosimetryReport,...
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

         uicontrol(uiPETLiverDosimetryReport,...
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
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportSeriesInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-570 FIG_REPORT_X/3-50 480]...
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

         uiReportPETLiverDosimetryInformation = ...
         uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Contour Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70 FIG_REPORT_Y-80 FIG_REPORT_X/3+100 20]...
                  );

         uiPETLiverDosimetryContoursInformationReport = ...
         uipanel(uiPETLiverDosimetryReport,...
                 'Units'   , 'pixels',...
                 'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70 ...
                              FIG_REPORT_Y-440 ...
                              450 ...
                              320 ...
                              ],...
                'Visible', 'on', ...
                    'BorderType','none', ...
                'HighlightColor' , 'white', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

         aContourInformationUiPosition = get(uiPETLiverDosimetryContoursInformationReport, 'position');

         uiPETLiverDosimetryScrollableContoursInformationReport = ...
         uipanel(uiPETLiverDosimetryContoursInformationReport,...
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

        gaContourInformationScrollableUiPosition = get(uiPETLiverDosimetryScrollableContoursInformationReport, 'position');

        uiPETLiverDosimetryScrollableContoursInformation = ...
        uicontrol(uiPETLiverDosimetryReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_REPORT_X-35 aContourInformationUiPosition(2) 15 aContourInformationUiPosition(4)], ...
                  'Value'   , 1, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Intensity', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @sliderScrollableContoursInformationCallback ...
                  );
%         addlistener(uiPETLiverDosimetryScrollableContoursInformation, 'Value', 'PreSet', @sliderScrollableContoursInformationCallback);
         addlistener(uiPETLiverDosimetryScrollableContoursInformation, 'ContinuousValueChange', @sliderScrollableContoursInformationCallback);

         % Contour Type

          uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Site',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70 FIG_REPORT_Y-110 130 20]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     uiReportLessionTypePETLiverDosimetry = ...
    %     uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
    %               'style'     , 'text',...
    %               'FontWeight', 'Normal',...
    %               'FontSize'  , 10,...
    %               'FontName'  , 'MS Sans Serif', ...
    %               'string'    , getPETLiverDosimetryReportLesionTypeInformation(),...
    %               'horizontalalignment', 'left',...
    %               'BackgroundColor', 'White', ...
    %               'ForegroundColor', 'Black', ...
    %               'position', [0 aContourInformationUiPosition(4)+290 130 gaContourInformationScrollableUiPosition(4)]...
    %               );
    % else
        uiReportLessionTypePETLiverDosimetry = ...
        uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 -10 130 gaContourInformationScrollableUiPosition(4)]...
                  );
    % end
    if viewerUIFigure('get') == true

        setUiExtendedPosition(uiReportLessionTypePETLiverDosimetry);
    end

    % Contour Mean

          uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Mean',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70+130 FIG_REPORT_Y-110 90 20]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     uiReportLesionMean = ...
    %     uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
    %               'style'     , 'text',...
    %               'FontWeight', 'Normal',...
    %               'FontSize'  , 10,...
    %               'FontName'  , 'MS Sans Serif', ...
    %               'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
    %               'horizontalalignment', 'left',...
    %               'BackgroundColor', 'White', ...
    %               'ForegroundColor', 'Black', ...
    %               'position', [130 aContourInformationUiPosition(4)+290 105 gaContourInformationScrollableUiPosition(4)]...
    %               );
    % else
        uiReportLesionMean = ...
        uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130 -10 105 gaContourInformationScrollableUiPosition(4)]...
                  );
    % end

    % Contour Max

          uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Max',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70+130+105 FIG_REPORT_Y-110 90 20]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     uiReportLesionMax = ...
    %     uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
    %               'style'     , 'text',...
    %               'FontWeight', 'Normal',...
    %               'FontSize'  , 10,...
    %               'FontName'  , 'MS Sans Serif', ...
    %               'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
    %               'horizontalalignment', 'left',...
    %               'BackgroundColor', 'White', ...
    %               'ForegroundColor', 'Black', ...
    %               'position', [130+105 aContourInformationUiPosition(4)+290 105 gaContourInformationScrollableUiPosition(4)]...
    %               );
    % else
        uiReportLesionMax = ...
        uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130+105 -10 105 gaContourInformationScrollableUiPosition(4)]...
                  );
    % end

    % Contour Volume

          uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Volume (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70+130+2*105 FIG_REPORT_Y-110 90 20]...
                  );

    % if viewerUIFigure('get') == true
    %
    %     uiReportLesionVolume = ...
    %     uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
    %               'style'     , 'text',...
    %               'FontWeight', 'Normal',...
    %               'FontSize'  , 10,...
    %               'FontName'  , 'MS Sans Serif', ...
    %               'string'    , getPETLiverDosimetryReportLesionVolumeInformation('init'),...
    %               'horizontalalignment', 'left',...
    %               'BackgroundColor', 'White', ...
    %               'ForegroundColor', 'Black', ...
    %               'position', [130+2*105 aContourInformationUiPosition(4)+290 105 gaContourInformationScrollableUiPosition(4)]...
    %               );
    % else
        uiReportLesionVolume = ...
        uicontrol(uiPETLiverDosimetryScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130+2*105 -10 105 gaContourInformationScrollableUiPosition(4)]...
                  );
    % end

    % Volume Histogram

       popVolumeHistogram = ...
       uicontrol(uiPETLiverDosimetryReport, ...
                 'Style'   , 'popup', ...
                 'Position', [760,390,465,20], ...
                 'String'  , gasOrganList, ...
                 'Value'   , 1 ,...
                 'Enable'  , 'on', ...
                 'BackgroundColor', 'white', ...
                 'ForegroundColor', 'black', ...
                 'Callback', @setVolumeHistogramCallback...
                 );

    axeReport = ...
        axes(uiPETLiverDosimetryReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-55 60 440 300], ...
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

    axeReport.Title.String  = 'Dose Volume Histogram (UVH)';
    axeReport.XLabel.String = 'Uptake';
    axeReport.YLabel.String = 'Liver Volume Fraction';

    % 3D Volume

    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    ui3DWindow = ...
    uipanel(uiPETLiverDosimetryReport,...
            'Units'   , 'pixels',...
            'BorderType', 'none',...
            'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
            'position', [20 15 FIG_REPORT_X/3-75-15 340]...
            );

    uiSlider3Dintensity = ...
    uicontrol(uiPETLiverDosimetryReport, ...
              'Style'   , 'Slider', ...
              'Position', [5 15 15 340], ...
              'Value'   , 0.75, ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Intensity', ...
              'BackgroundColor', 'White', ...
              'CallBack', @slider3DDosimetryintensityCallback ...
              );
%    addlistener(uiSlider3Dintensity, 'Value', 'PreSet', @slider3DDosimetryintensityCallback);

     uicontrol(uiPETLiverDosimetryReport,...
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

    % Notes

    uiEditWindow = ...
    uicontrol(uiPETLiverDosimetryReport,...
              'style'     , 'edit',...
              'FontWeight', 'Normal',...
              'FontSize'  , 11,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-75 250]...
             );
    set(uiEditWindow, 'Min', 0, 'Max', 2);

         uicontrol(uiPETLiverDosimetryReport,...
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

    mReportFile = uimenu(figPETLiverDosimetryReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export report to .pdf...'             , 'Callback', @exportCurrentPETLiverDosimetryReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export report to DICOM print...'      , 'Callback', @exportCurrentPETLiverDosimetryReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Export axial slices to .avi...'       , 'Callback', @exportCurrentPETLiverDosimetryAxialSlicesToAviCallback, 'Separator','on');
    uimenu(mReportFile,'Label', 'Export axial slices to DICOM movie...', 'Callback', @exportCurrentPETLiverDosimetryAxialSlicesToDicomMovieCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(figPETLiverDosimetryReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyPETLiverDosimetryReportDisplayCallback);

    setPETLiverDosimetryReportFigureName();

    gtReport = computePETLiverDosimetryReportLesionInformation(suvMenuUnitOption('get'), modifiedMatrixValueMenuOption('get'), modifiedMatrixValueMenuOption('get'));

    refreshReportLesionInformation();

    function refreshReportLesionInformation()

        if ~isempty(gtReport) % Fill information

            if ~isempty(gtReport.Other) % Add other VOIs to the global list

                cDummyList = cell(1, numel(gtReport.Other)+numel(gasOrganList));
                for jj=1:numel(gasOrganList)
                    cDummyList{jj}=gasOrganList{jj};
                end

                for jj=1:numel(gtReport.Other)
                    cDummyList{numel(gasOrganList)+jj}=gtReport.Other{jj}.Label;
                end

                gasOrganList = cDummyList;

                % Update VOIs name list

                set(uiReportLessionTypePETLiverDosimetry, 'String', getPETLiverDosimetryReportLesionTypeInformation());
                set(popVolumeHistogram, 'String', gasOrganList);

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLessionTypePETLiverDosimetry);
                end

                clear cDummyList;
            end

            if isvalid(uiReportPETLiverDosimetryInformation) % Make sure the figure is still open
                set(uiReportPETLiverDosimetryInformation, 'String', sprintf('Contour Information (%s)', getPETLiverDosimetryReportUnitValue()));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open

                set(uiReportLesionMean, 'String', getPETLiverDosimetryReportLesionMeanInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionMean);
                end
            end

            if isvalid(uiReportLesionMax) % Make sure the figure is still open

                set(uiReportLesionMax, 'String', getPETLiverDosimetryReportLesionMaxInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionMax);
                end
            end

            if isvalid(uiReportLesionVolume) % Make sure the figure is still open

                set(uiReportLesionVolume, 'String', getPETLiverDosimetryReportLesionVolumeInformation('get', gtReport));

                if viewerUIFigure('get') == true

                    setUiExtendedPosition(uiReportLesionVolume);
                end
            end

            if isvalid(axeReport) % Make sure the figure is still open

                aAxeReportPosition = get(axeReport, 'position');

                delete(axeReport);

                axeReport = ...
                axes(uiPETLiverDosimetryReport, ...
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

                    ptrPlotCummulative = plotCummulative(axeReport, gtReport.Liver.voiData, 'black');
                    
                    if ~isempty(ptrPlotCummulative)
    
                        axeReport.Title.String  = 'Liver - Dose Volume Histogram (DVH)';
                        axeReport.XLabel.String = sprintf('Uptake (%s)', getPETLiverDosimetryReportUnitValue());
                        axeReport.YLabel.String = 'Liver Volume Fraction';
    
                        cDataCursor = datacursormode(figPETLiverDosimetryReport);
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

        end

        if isvalid(ui3DWindow)
            
            display3DLiver();
        end
    end

    function txt = updateCursorCoordinates(~,info)

        dPopValue = get(popVolumeHistogram, 'value');

        if numel(gasOrganList{dPopValue}) > 18
            sName = gasOrganList{dPopValue}(1:18);
        else
            sName = gasOrganList{dPopValue};
        end

        x = info.Position(1);
        y = info.Position(2);
        txt = ['(' sprintf('%.0f', x) ', ' sprintf('%.2f', y) ')'];

        set( axeReport.XLabel, 'String', sprintf('Uptake (%s)', getPETLiverDosimetryReportUnitValue() ) );
        set( axeReport.YLabel, 'String', sprintf('%s Volume Fraction', sName) );

    end

    function setVolumeHistogramCallback(~, ~)

        dPopValue = get(popVolumeHistogram, 'value');

        aAxeReportPosition = get(axeReport, 'position');

        delete(axeReport);

        axeReport = ...
        axes(uiPETLiverDosimetryReport, ...
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

                if dPopValue == 1 % Liver
                    voiData = gtReport.Liver.voiData;
                else
                    voiData = gtReport.Other{dPopValue-1}.voiData; % - Liver
                end

                if numel(gasOrganList{dPopValue}) > 18
                    sName = gasOrganList{dPopValue}(1:18);
                else
                    sName = gasOrganList{dPopValue};
                end

                ptrPlotCummulative = plotCummulative(axeReport, voiData, 'black');
                axeReport.Title.String  = sprintf('%s - Dose Volume Histogram (DVH)', sName);
                axeReport.XLabel.String = sprintf('Uptake (%s)', getPETLiverDosimetryReportUnitValue());
                axeReport.YLabel.String = sprintf('%s Volume Fraction', sName);

                cDataCursor = datacursormode(figPETLiverDosimetryReport);
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

    function setPETLiverDosimetryReportFigureName()

        if ~isvalid(figPETLiverDosimetryReport)
            return;
        end

        sUnit = sprintf('Unit: %s', getPETLiverDosimetryReportUnitValue());

        figPETLiverDosimetryReport.Name = ['TriDFusion (3DF) PET Y90 Liver Dosimetry Report - ' atMetaData{1}.SeriesDescription ' - ' sUnit];

    end

    function sUnit = getPETLiverDosimetryReportUnitValue()

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
            sUnit =  'NaN';
        end
    end

    function sReport = getPETLiverDosimetryReportLesionTypeInformation()

%        sReport = sprintf('%s\n___________', char('Summary'));
        sReport = '';
        for ll=1:numel(gasOrganList)

            if numel(gasOrganList{ll}) > 18

                sName = gasOrganList{ll}(1:18);
            else
                sName = gasOrganList{ll};
            end

            sReport = sprintf('%s%s\n\n', sReport, sName);
        end


    end

    function sReport = getPETLiverDosimetryReportLesionMeanInformation(sAction, tReport)

        if strcmpi(sAction, 'init')
%            sReport = sprintf('%s\n___________', '-');
            sReport = '';
%             for ll=1:numel(gasOrganList)
%                 sReport = sprintf('%s%s\n\n', sReport, '-');
%             end
        else

%            if ~isempty(tReport.All.Mean)
%                sReport = sprintf('%-.2f\n___________', tReport.All.Mean);
%            else
%                sReport = sprintf('%s\n___________', '-');
%            end

            sReport = '';

            if ~isempty(tReport.Liver.Mean)
                sReport = sprintf('%s%-12s\n\n', sReport, num2str(tReport.Liver.Mean));
            else
                sReport = sprintf('%s\n\n%s', sReport, ' ');
            end

            for jj=1:numel(tReport.Other)

                if ~isempty(tReport.Other{jj}.Mean)

                    sReport = sprintf('%s%12s\n\n', sReport, num2str(tReport.Other{jj}.Mean));
                else
                    sReport = sprintf('%s\n\n%s', sReport, ' ');
                end
            end

        end
    end

    function sReport = getPETLiverDosimetryReportLesionMaxInformation(sAction, tReport)

        if strcmpi(sAction, 'init')
          %  sReport = sprintf('%s\n___________', '-');
           sReport = '';
%            for ll=1:numel(gasOrganList)
%                 sReport = sprintf('%s%s\n\n', sReport, '-');
%             end
        else

%            if ~isempty(tReport.All.Max)
%                sReport = sprintf('%-.2f\n___________', tReport.All.Max);
%            else
%                sReport = sprintf('%s\n___________', '-');
%            end

            sReport = '';

            if ~isempty(tReport.Liver.Max)

                sReport = sprintf('%s%-12s\n\n', sReport, num2str(tReport.Liver.Max));
            else
                sReport = sprintf('%s\n\n%s', sReport, ' ');
            end

            for jj=1:numel(tReport.Other)

                if ~isempty(tReport.Other{jj}.Max)

                    sReport = sprintf('%s%12s\n\n', sReport, num2str(tReport.Other{jj}.Max));
                else
                    sReport = sprintf('%s\n\n%s', sReport, ' ');
                end
            end

        end
    end

    function sReport = getPETLiverDosimetryReportLesionVolumeInformation(sAction, tReport)

        if strcmpi(sAction, 'init')
%            sReport = sprintf('%s\n___________', '-');
            sReport = '';
%             for ll=1:numel(gasOrganList)
%                 sReport = sprintf('%s%s\n\n', sReport, '-');
%             end
        else

%            if ~isempty(tReport.All.Volume)
%                sReport = sprintf('%-.3f\n___________', tReport.All.Volume);
%            else
%                sReport = sprintf('%s\n___________', '-');
%            end

            sReport = '';

            if ~isempty(tReport.Liver.Volume)

                sReport = sprintf('%s%12s\n\n', sReport, num2str(tReport.Liver.Volume));
             else
                 sReport = sprintf('%s\n\n%s', sReport, ' ');
            end

            for jj=1:numel(tReport.Other)

                if ~isempty(tReport.Other{jj}.Volume)

                    sReport = sprintf('%s%12s\n\n', sReport, num2str(tReport.Other{jj}.Volume));
                 else
                     sReport = sprintf('%s\n\n%s', sReport, ' ');
                end
            end

        end
    end

    function tReport = computePETLiverDosimetryReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented)

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

            atDicomMeta = dicomMetaData('get');
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
                    aImage = aImage(:,end:-1:1);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aImage = aImage(end:-1:1,:);
                end
            else
                if atInput(dSeriesOffset).bFlipLeftRight == true
                    aImage = aImage(:,end:-1:1,:);
                end

                if atInput(dSeriesOffset).bFlipAntPost == true
                    aImage = aImage(end:-1:1,:,:);
                end

                if atInput(dSeriesOffset).bFlipHeadFeet == true
                    aImage = aImage(:,:,end:-1:1);
                end
            end

        else
            atMetaData = dicomMetaData('get', [], dSeriesOffset);
            aImage     = dicomBuffer('get', [], dSeriesOffset);
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

        aDicomImage = dicomBuffer('get', [], dSeriesOffset);
    
        if bModifiedMatrix == false && ...
           bMovementApplied == false        % Can't use input buffer if movement have been applied
    
            if ~isequal(size(aImage), size(aDicomImage))
                [atRoiInput, atVoiInput] = resampleROIs(aDicomImage, atDicomMeta, aImage, atMetaData, atRoiInput, false, atVoiInput, dSeriesOffset);
            end
        end

        % Count contour Type number

        dLiverCount  = 0;
        dNbLiverRois = 0;

        acOtherCount  = cell(1, numel(atVoiInput));
        acNbOtherRois = cell(1, numel(atVoiInput));

        for jj=1:numel(atVoiInput) % initialize other than liver VOIs
            acOtherCount{jj}  = 0;
            acNbOtherRois{jj} = 0;
        end


        for vv=1:numel(atVoiInput)

            dNbRois = numel(atVoiInput{vv}.RoisTag);

            switch lower(atVoiInput{vv}.Label)

                case 'liver-liv'
                    dLiverCount  = dLiverCount+1;
                    dNbLiverRois = dNbLiverRois+dNbRois;

                    acOtherCount{vv}  = [];
                    acNbOtherRois{vv} = [];

                otherwise

                    acOtherCount{vv}  = acOtherCount{vv}+1;
                    acNbOtherRois{vv} = acNbOtherRois{vv}+dNbRois;

            end
        end


        % Set report type count

        if dLiverCount == 0
            tReport.Liver.Count = [];
        else
            tReport.Liver.Count = dLiverCount;
        end

        tReport.Other = cell(numel(atVoiInput), 1);

        for jj=1:numel(atVoiInput)
            switch lower(atVoiInput{jj}.Label)

                case 'liver-liv'
                    tReport.Other{jj}.Label = [];

                otherwise
                    tReport.Other{jj}.Label = atVoiInput{jj}.Label;

            end
        end

        for jj=1:numel(atVoiInput) % initialize other than liver VOIs

            if isempty(acOtherCount{jj})
                    tReport.Other{jj}.Count = [];
            else
                if acOtherCount{jj} == 0
                    tReport.Other{jj}.Count = [];
                else
                    tReport.Other{jj}.Count = acOtherCount{jj};
                end
            end
        end

        % Clasify ROIs by lession type

        tReport.Liver.RoisTag = cell(1, dNbLiverRois);

        dLiverRoisOffset = 1;

        for jj=1:numel(atVoiInput)

            if ~isempty(tReport.Other{jj}.Count)
                tReport.Other{jj}.RoisTag = cell(1, acNbOtherRois{jj});
            else
                tReport.Other{jj}.RoisTag = [];
            end
        end

        acOtherRoisOffset = cell(1, numel(atVoiInput));
        for jj=1:numel(atVoiInput)
            acOtherRoisOffset{jj} = 1;
        end

        for vv=1:numel(atVoiInput)

            dNbRois = numel(atVoiInput{vv}.RoisTag);

            switch lower(atVoiInput{vv}.Label)

                case 'liver-liv'

                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;

                    tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;

                otherwise
                    dFrom = acOtherRoisOffset{vv};
                    dTo   = acOtherRoisOffset{vv}+dNbRois-1;

                    tReport.Other{vv}.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;

                    acOtherRoisOffset{vv} = acOtherRoisOffset{vv}+dNbRois;
            end
        end

        % Remove the liver for the Other

        for jj=1:numel(atVoiInput)
            if isempty(tReport.Other{jj}.Count)
                tReport.Other{jj} = [];
            end
        end

        tReport.Other(cellfun(@isempty, tReport.Other)) = [];

        % Compute Liver lesion

        progressBar( 1/2, 'Computing liver segmentation, please wait' );

        if numel(tReport.Liver.RoisTag) ~= 0

            voiMask = cell(1, numel(tReport.Liver.RoisTag));
            voiData = cell(1, numel(tReport.Liver.RoisTag));

            dNbCells = 0;

            for uu=1:numel(tReport.Liver.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Liver.RoisTag{uu}]} );

                tRoi = atRoiInput{find(aTagOffset, 1)};

                % if bModifiedMatrix  == false && ...
                %    bMovementApplied == false        % Can't use input buffer if movement have been applied
                % 
                %     if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                %         pTemp{1} = tRoi;
                %         ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                %         tRoi = ptrRoiTemp{1};
                %     end
                % end

                switch lower(tRoi.Axe)
                    case 'axe'
                        voiData{uu} = aImage(:,:);
                        voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
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

            tReport.Liver.Cells  = dNbCells;
            tReport.Liver.Volume = dNbCells*dVoxVolume;
            tReport.Liver.voiData = voiData;

            if strcmpi(sUnitDisplay, 'SUV')

                if bSUVUnit == true
                    tReport.Liver.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                    tReport.Liver.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                else
                    tReport.Liver.Mean = mean(voiData, 'all');
                    tReport.Liver.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Liver.Mean = mean(voiData, 'all');
                tReport.Liver.Max  = max (voiData, [], 'all');
            end

            if isempty(tReport.Liver.Mean)
                tReport.Liver.Mean = nan;
            end

            if isempty(tReport.Liver.Max)
                tReport.Liver.Max = nan;
            end

            clear voiMask;
            clear voiData;
        else
            tReport.Liver.Cells  = [];
            tReport.Liver.Volume = [];
            tReport.Liver.Mean   = [];
            tReport.Liver.Max    = [];
        end

        % Computing other segmentation

        for jj=1:numel(tReport.Other)

            progressBar( (jj/numel(tReport.Other))/2 + 0.49999, sprintf('Computing %s segmentation, please wait', tReport.Other{jj}.Label) );

            if numel(tReport.Other{jj}.RoisTag) ~= 0

                voiMask = cell(1, numel(tReport.Other{jj}.RoisTag));
                voiData = cell(1, numel(tReport.Other{jj}.RoisTag));

                dNbCells = 0;

                for uu=1:numel(tReport.Other{jj}.RoisTag)

                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Other{jj}.RoisTag{uu}]} );

                    tRoi = atRoiInput{find(aTagOffset, 1)};

                    % if bModifiedMatrix  == false && ...
                    %    bMovementApplied == false        % Can't use input buffer if movement have been applied
                    % 
                    %     if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                    %         pTemp{1} = tRoi;
                    %         ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                    %         tRoi = ptrRoiTemp{1};
                    %     end
                    % end

                    switch lower(tRoi.Axe)
                        case 'axe'
                            voiData{uu} = aImage(:,:);
                            voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                        case 'axes1'
                            aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                            voiData{uu} = aSlice;
                            voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        case 'axes2'
                            aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                            voiData{uu} = aSlice;
                            voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                       case 'axes3'
                            aSlice = aImage(:,:,tRoi.SliceNb);
                            voiData{uu} = aSlice;
                            voiMask{uu} = roiTemplateToMask(tRoi, aSlice);
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

                tReport.Other{jj}.Cells  = dNbCells;
                tReport.Other{jj}.Volume = dNbCells*dVoxVolume;
                tReport.Other{jj}.voiData = voiData;

                if strcmpi(sUnitDisplay, 'SUV')

                    if bSUVUnit == true
                        tReport.Other{jj}.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;
                        tReport.Other{jj}.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;
                    else
                        tReport.Other{jj}.Mean = mean(voiData, 'all');
                        tReport.Other{jj}.Max  = max (voiData, [], 'all');
                    end
                else
                    tReport.Other{jj}.Mean = mean(voiData, 'all');
                    tReport.Other{jj}.Max  = max (voiData, [], 'all');
                end

                if isempty(tReport.Other{jj}.Mean)
                    tReport.Other{jj}.Mean = nan;
                end

                if isempty(tReport.Other{jj}.Max)
                    tReport.Other{jj}.Max = nan;
                end

                clear voiMask;
                clear voiData;
            else
                tReport.Other{jj}.Cells  = [];
                tReport.Other{jj}.Volume = [];
                tReport.Other{jj}.Mean   = [];
                tReport.Other{jj}.Max    = [];
            end
        end

        clear aImage;

        progressBar( 1 , 'Ready' );

    end

    function exportCurrentPETLiverDosimetryReportToPdfCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        try

        filter = {'*.pdf'};

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastReportDir.mat'];

        % load last data directory

        if exist(sMatFile, 'file') % lastDirMat mat file exists, load it

            load(sMatFile, 'saveReportLastUsedDir');

            if exist('saveReportLastUsedDir', 'var')

               sCurrentDir = saveReportLastUsedDir;
            end

            if sCurrentDir == 0

                sCurrentDir = pwd;
            end
        end

%        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        % Series Date

        sSeriesDate = atMetaData{1}.SeriesDate;

        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save PET Y90 liver dosimetry report', sprintf('%s/%s_%s_%s_%s_Y90_LIVER_DOSIMETRY_REPORT_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(figPETLiverDosimetryReport, 'Pointer', 'watch');
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

            exportContourReportToPdf(figPETLiverDosimetryReport, axePETLiverDosimetryReport, sFileName);

            progressBar( 1 , sprintf('Export %s completed.', sFileName));

            try
                winopen(sFileName);
            catch ME
                logErrorToFile(ME);
            end
        end

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: exportCurrentPETLiverDosimetryReportToPdfCallback() cant export report' );
        end

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentPETLiverDosimetryAxialSlicesToAviCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        % bMipPlayback = playback2DMipOnly('get');
        sPlaybackPlane = default2DPlaybackPlane('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

    %         figPETLiverDosimetryReport = figPETLiverDosimetryReportPtr('get');

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

        [file, path] = uiputfile(filter, 'Save PET Y90 liver dosimetry axial slices', sprintf('%s/%s_%s_%s_%s_LIVER_DOSIMETRY_AXIAL_SLICES_TriDFusion.avi' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(figPETLiverDosimetryReport, 'Pointer', 'watch');
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
            progressBar( 1 , 'Error: exportCurrentPETLiverDosimetryAxialSlicesToAviCallback() cant export report' );
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

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
        drawnow;
    end

    function exportCurrentPETLiverDosimetryAxialSlicesToDicomMovieCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % bMipPlayback = playback2DMipOnly('get');
        sPlaybackPlane = default2DPlaybackPlane('get');

        dAxialSliceNumber = sliceNumber('get', 'axial');

        try

%         figPETLiverDosimetryReport = figPETLiverDosimetryReportPtr('get');

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

            sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
            sWriteDir = char(sOutDir) + "TriDFusion_MFSC_" + char(sDate) + '/';
            if ~(exist(char(sWriteDir), 'dir'))
                mkdir(char(sWriteDir));
            end

            try
                exportDicomLastUsedDir = sOutDir;
                save(sMatFile, 'exportDicomLastUsedDir');

            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end
        end

        set(figPETLiverDosimetryReport, 'Pointer', 'watch');
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

%         objectToDicomJpg(sWriteDir, figPETLiverDosimetryReport, '3DF MFSC', get(uiSeriesPtr('get'), 'Value'))

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: exportCurrentPETLiverDosimetryAxialSlicesToDicomMovieCallback() cant export report' );
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

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
        drawnow;
    end

    function copyPETLiverDosimetryReportDisplayCallback(~, ~)

        try
            set(figPETLiverDosimetryReport, 'Pointer', 'watch');
            drawnow;

            copyFigureToClipboard(figPETLiverDosimetryReport);

        catch ME
            logErrorToFile(ME);
            progressBar( 1 , 'Error: copyPETLiverDosimetryReportDisplayCallback() cant copy report' );
        end

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
        drawnow;
    end

    function display3DLiver()

        atInput = inputTemplate('get');

        % Modality validation

        dCTSerieOffset = [];
        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
                dCTSerieOffset = tt;
                break;
            end
        end

        dPTSerieOffset = [];
        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
                dPTSerieOffset = tt;
                break;
            end
        end

        if isempty(dCTSerieOffset) || ...
           isempty(dPTSerieOffset)
            progressBar(1, 'Error: display3DLungLiver() require a CT and PT image!');
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
        end

        x = atCTMetaData{1}.PixelSpacing(1);
        y = atCTMetaData{1}.PixelSpacing(2);
        z = computeSliceSpacing(atCTMetaData);

        aScaleFactor = [y x z];
        dScaleMax = max(aScaleFactor);

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

        bUseViewer3d = shouldUseViewer3d();

        if bUseViewer3d == true

            [Mdti,~] = TransformMatrix(atCTMetaData{1}, computeSliceSpacing(atCTMetaData), true);

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

                set3DView(ptrViewer3d, 1, 1);
            else
                pObject.CameraPosition = aCameraPosition;
                pObject.CameraUpVector = aCameraUpVector;
            end

        end

        % Mask Volume rendering

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

    function slider3DDosimetryintensityCallback(~, ~)

        dSliderValue = get(uiSlider3Dintensity, 'Value');

        aAlphamap = linspace(0, dSliderValue, 256)';

        for jj=1:numel(gasMask)
            gp3DObject{jj}.Alphamap = aAlphamap;
        end

    end

    function uiPETLiverDosimetryReportSliderCallback(~, ~)

        val = get(uiPETLiverDosimetryReportSlider, 'Value');

        aPosition = get(uiPETLiverDosimetryReport, 'Position');

        dPanelOffset = -((1-val) * aPosition(4));

        set(uiPETLiverDosimetryReport, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function sliderScrollableContoursInformationCallback(~, ~)

        val = get(uiPETLiverDosimetryScrollableContoursInformation, 'Value');

        aPosition = get(uiPETLiverDosimetryScrollableContoursInformationReport, 'Position');

        dPanelOffset = -((1-val) * aPosition(4));

        set(uiPETLiverDosimetryScrollableContoursInformationReport, ...
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
        % aNewUiPosition = [aUiPosition(1), (aUiPosition(4) - aUiExtent(4)) /2, aUiPosition(3), aUiPosition(4)];
        aNewUiPosition = [aUiPosition(1), aUiPosition(2) + aUiPosition(4) - aUiExtent(4) - dNbElements, aUiPosition(3), aUiExtent(4) + dNbElements];


        set(uiControl, 'Position', aNewUiPosition);
    end
end
