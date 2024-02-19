function generateContourReportCallback(~, ~)
%function generateContourReportCallback()
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
    axeContourReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeContourReport.Toolbar = [];

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
    addlistener(uiContourReportSlider, 'Value', 'PreSet', @uiContourReportSliderCallback);

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
                'HighlightColor' , 'white', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

         aContourInformationUiPosition = get(uiContoursInformationReport, 'position');

         uiScrollableContoursInformationReport = ...
         uipanel(uiContoursInformationReport,...
                 'Units'   , 'pixels',...
                 'position', [0 ...
                              -((aContourInformationUiPosition(4)*4)-320) ...
                              aContourInformationUiPosition(3) ...
                              aContourInformationUiPosition(4)*4 ...
                              ],...
                'Visible', 'on', ...
                'HighlightColor' , 'white', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

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
        addlistener(uiContoursInformation, 'Value', 'PreSet', @sliderScrollableContoursInformationCallback);

         % Contour Type
              
          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Classification',...
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
    axeReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeReport.Toolbar = [];

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
                'BorderWidth', showBorder('get'),...
                'HighlightColor', [0 1 1],...
                'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                'position', [20 15 FIG_REPORT_X/3-75-15 340]...
                );  

        uiSlider3Dintensity = ...
        uicontrol(uiContourReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [5 15 15 340], ...
                  'Value'   , 0.8, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Intensity', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @slider3DintensityCallback ...
                  );
        addlistener(uiSlider3Dintensity, 'Value', 'PreSet', @slider3DintensityCallback);
     else
        ui3DWindow = ...
        uipanel(uiContourReport,...
                'Units'   , 'pixels',...
                'BorderWidth', showBorder('get'),...
                'HighlightColor', [0 1 1],...
                'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
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

        gtReport = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid);

        if ~isempty(gtReport) % Fill information

            if isvalid(uiReportContourTitle)
                set(uiReportContourTitle, 'String', sprintf('Contours Information (%s)', getReportUnitValue()));                            
            end

             if isvalid(uiReportContourType) % Make sure the figure is still open    
                 set(uiReportContourType, 'String', getReportLesionTypeInformation('get', gtReport)); 
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
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getReportLesionMeanInformation('get', gtReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getReportLesionMaxInformation('get', gtReport));
            end    

            if isvalid(uiReportLesionPeak) % Make sure the figure is still open        
                set(uiReportLesionPeak, 'String', getReportLesionPeakInformation('get', gtReport));
            end  

            if isvalid(uiReportLesionVolume) % Make sure the figure is still open        
                set(uiReportLesionVolume, 'String', getReportLesionVolumeInformation('get', gtReport));
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
                axeReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                axeReport.Toolbar = [];

                try
                    
                    ptrPlotCummulative = plotCummulative(axeReport, gtReport.All.voiData, 'black');
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
                    dD90 = interp1(aYData, aXData, .9);
                    dD50 = interp1(aYData, aXData, .5);
                    dD10 = interp1(aYData, aXData, .1);
                    
                    text(axeReport, max(aXData)*0.8, max(aYData)*0.95, sprintf('90%%: %.0f', dD90));
                    text(axeReport, max(aXData)*0.8, max(aYData)*0.87, sprintf('50%%: %.0f', dD50));
                    text(axeReport, max(aXData)*0.8, max(aYData)*0.79, sprintf('10%%: %.0f', dD10));

                catch
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

                    otherwise    

                end
            end             
        end         
    end

    function tReport = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented, bCentroid)
        
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
        
        % Count Lesion Type number of contour
       
        dUnspecifiedCount     = 0;
        dBoneCount            = 0;
        dSoftTissueCount      = 0;
        dUnknowCount          = 0;
        dLungCount            = 0;
        dLiverCount           = 0;
        dParotidCount         = 0;
        dBloodPoolCount       = 0;
        dLymphNodesCount      = 0;
        dPrimaryDiseaseCount  = 0;
        dCervicalCount        = 0;
        dSupraclavicularCount = 0; 
        dMediastinalCount     = 0; 
        dParaspinalCount      = 0; 
        dAxillaryCount        = 0;
        dAbdominalCount       = 0;

        dNbUnspecifiedRois     = 0;
        dNbBoneRois            = 0;
        dNbSoftTissueRois      = 0;
        dNbUnknowRois          = 0;
        dNbLungRois            = 0;
        dNbLiverRois           = 0;
        dNbParotidRois         = 0;
        dNbBloodPoolRois       = 0;
        dNbLymphNodesRois      = 0;
        dNbPrimaryDiseaseRois  = 0;
        dNbCervicalRois        = 0;
        dNbSupraclavicularRois = 0; 
        dNbMediastinalRois     = 0; 
        dNbParaspinalRois      = 0; 
        dNbAxillaryRois        = 0;
        dNbAbdominalRois       = 0;

        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
            switch lower(atVoiInput{vv}.LesionType)
                
                case 'unspecified'
                    dUnspecifiedCount = dUnspecifiedCount+1;
                    dNbUnspecifiedRois = dNbUnspecifiedRois+dNbRois;
                    
                case 'bone'
                    dBoneCount  = dBoneCount+1;
                    dNbBoneRois = dNbBoneRois+dNbRois;
                    
                case 'soft tissue'
                    dSoftTissueCount  = dSoftTissueCount+1;                    
                    dNbSoftTissueRois = dNbSoftTissueRois+dNbRois;
                    
                case 'lung'
                    dLungCount  = dLungCount+1;                    
                    dNbLungRois = dNbLungRois+dNbRois;
                    
                case 'liver'
                    dLiverCount  = dLiverCount+1;                    
                    dNbLiverRois = dNbLiverRois+dNbRois;
                    
                case 'parotid'
                    dParotidCount  = dParotidCount+1;                    
                    dNbParotidRois = dNbParotidRois+dNbRois;
                    
                case 'blood pool'
                    dBloodPoolCount  = dBloodPoolCount+1;                    
                    dNbBloodPoolRois = dNbBloodPoolRois+dNbRois;

                 case 'lymph nodes'
                    dLymphNodesCount  = dLymphNodesCount+1;                    
                    dNbLymphNodesRois = dNbLymphNodesRois+dNbRois;

                case 'primary disease'
                    dPrimaryDiseaseCount  = dPrimaryDiseaseCount+1;                    
                    dNbPrimaryDiseaseRois = dNbPrimaryDiseaseRois+dNbRois;   

                case 'cervical'
                    dCervicalCount  = dCervicalCount+1;                    
                    dNbCervicalRois = dNbCervicalRois+dNbRois;

                case 'supraclavicular'
                    dSupraclavicularCount  = dSupraclavicularCount+1;                    
                    dNbSupraclavicularRois = dNbSupraclavicularRois+dNbRois;   

                case 'mediastinal'
                    dMediastinalCount  = dMediastinalCount+1;                    
                    dNbMediastinalRois = dNbMediastinalRois+dNbRois; 

                case 'paraspinal'
                    dParaspinalCount  = dParaspinalCount+1;                    
                    dNbParaspinalRois = dNbParaspinalRois+dNbRois; 

                case 'axillary'
                    dAxillaryCount  = dAxillaryCount+1;                    
                    dNbAxillaryRois = dNbAxillaryRois+dNbRois;     

                case 'abdominal'
                    dAbdominalCount  = dAbdominalCount+1;                    
                    dNbAbdominalRois = dNbAbdominalRois+dNbRois; 

                otherwise
                    dUnknowCount  = dUnknowCount+1;
                    dNbUnknowRois = dNbUnknowRois+dNbRois;
            end
        end
        
        % Set report type count
        
        if dUnspecifiedCount == 0
            tReport.Unspecified.Count = [];
        else        
            tReport.Unspecified.Count = dUnspecifiedCount;
        end
        
        if dBoneCount == 0
            tReport.Bone.Count = [];
        else
            tReport.Bone.Count = dBoneCount;
        end
        
        if dSoftTissueCount == 0
            tReport.SoftTissue.Count = [];
        else
            tReport.SoftTissue.Count = dSoftTissueCount;
        end
                
        if dLungCount == 0
            tReport.Lung.Count = [];
        else
            tReport.Lung.Count = dLungCount;
        end
        
        if dLiverCount == 0
            tReport.Liver.Count = [];
        else
            tReport.Liver.Count = dLiverCount;
        end
        
        if dParotidCount == 0
            tReport.Parotid.Count = [];
        else
            tReport.Parotid.Count = dParotidCount;
        end        
        
        if dBloodPoolCount == 0
            tReport.BloodPool.Count = [];
        else
            tReport.BloodPool.Count = dBloodPoolCount;
        end        

        if dLymphNodesCount == 0
            tReport.LymphNodes.Count = [];
        else
            tReport.LymphNodes.Count = dLymphNodesCount;
        end    

        if dPrimaryDiseaseCount == 0
            tReport.PrimaryDisease.Count = [];
        else
            tReport.PrimaryDisease.Count = dPrimaryDiseaseCount;
        end    

        if dCervicalCount == 0
            tReport.Cervical.Count = [];
        else
            tReport.Cervical.Count = dCervicalCount;
        end    

        if dSupraclavicularCount == 0
            tReport.Supraclavicular.Count = [];
        else
            tReport.Supraclavicular.Count = dSupraclavicularCount;
        end    

        if dMediastinalCount == 0
            tReport.Mediastinal.Count = [];
        else
            tReport.Mediastinal.Count = dMediastinalCount;
        end    

        if dParaspinalCount == 0
            tReport.Paraspinal.Count = [];
        else
            tReport.Paraspinal.Count = dParaspinalCount;
        end    

        if dAxillaryCount == 0
            tReport.Axillary.Count = [];
        else
            tReport.Axillary.Count = dAxillaryCount;
        end    

        if dAbdominalCount == 0
            tReport.Abdominal.Count = [];
        else
            tReport.Abdominal.Count = dAbdominalCount;
        end    

        if dUnspecifiedCount    + ...
           dBoneCount           + ...
           dSoftTissueCount     + ...
           dLungCount           + ...
           dLiverCount          + ... 
           dParotidCount        + ...
           dBloodPoolCount      + ...
           dLymphNodesCount     + ...
           dPrimaryDiseaseCount + ...
           dCervicalCount       + ...
           dSupraclavicularCount+ ...
           dMediastinalCount    + ...
           dParaspinalCount     + ...
           dAxillaryCount       + ...
           dAbdominalCount      + ...
           dUnknowCount         == 0

            tReport.All.Count = [];
        else
            tReport.All.Count = dUnspecifiedCount    + ...
                                dBoneCount           + ...
                                dSoftTissueCount     + ...
                                dLungCount           + ...
                                dLiverCount          + ... 
                                dParotidCount        + ...
                                dBloodPoolCount      + ...
                                dLymphNodesCount     + ...
                                dPrimaryDiseaseCount + ...
                                dCervicalCount       + ...
                                dSupraclavicularCount+ ...
                                dMediastinalCount    + ...
                                dParaspinalCount     + ...
                                dAxillaryCount       + ...
                                dAbdominalCount      + ...
                                dUnknowCount;         
        end
        
        % Clasify ROIs by lession type      

        tReport.Unspecified.RoisTag     = cell(1, dNbUnspecifiedRois);
        tReport.Bone.RoisTag            = cell(1, dNbBoneRois);
        tReport.SoftTissue.RoisTag      = cell(1, dNbSoftTissueRois);      
        tReport.Lung.RoisTag            = cell(1, dNbLungRois);
        tReport.Liver.RoisTag           = cell(1, dNbLiverRois);
        tReport.Parotid.RoisTag         = cell(1, dNbParotidRois);
        tReport.BloodPool.RoisTag       = cell(1, dNbBloodPoolRois); 
        tReport.LymphNodes.RoisTag      = cell(1, dNbLymphNodesRois); 
        tReport.PrimaryDisease.RoisTag  = cell(1, dNbPrimaryDiseaseRois); 
        tReport.Cervical.RoisTag        = cell(1, dNbCervicalRois); 
        tReport.Supraclavicular.RoisTag = cell(1, dNbSupraclavicularRois); 
        tReport.Mediastinal.RoisTag     = cell(1, dNbMediastinalRois); 
        tReport.Paraspinal.RoisTag      = cell(1, dNbParaspinalRois); 
        tReport.Axillary.RoisTag        = cell(1, dNbAxillaryRois); 
        tReport.Abdominal.RoisTag       = cell(1, dNbAbdominalRois); 
        
        tReport.All.RoisTag             = cell(1, dUnspecifiedCount    + ...
                                                  dBoneCount           + ...
                                                  dSoftTissueCount     + ...
                                                  dLungCount           + ...
                                                  dLiverCount          + ... 
                                                  dParotidCount        + ...
                                                  dBloodPoolCount      + ...
                                                  dLymphNodesCount     + ...
                                                  dPrimaryDiseaseCount + ...
                                                  dCervicalCount       + ...
                                                  dSupraclavicularCount+ ...
                                                  dMediastinalCount    + ...
                                                  dParaspinalCount     + ...
                                                  dAxillaryCount       + ...
                                                  dAbdominalCount      + ...
                                                  dUnknowCount);        
        
        dUnspecifiedRoisOffset     = 1;
        dBoneRoisOffset            = 1;
        dSoftTissueRoisOffset      = 1;    
        dLungRoisOffset            = 1;
        dLiverRoisOffset           = 1;
        dParotidRoisOffset         = 1;
        dBloodPoolRoisOffset       = 1;        
        dLymphNodesRoisOffset      = 1;        
        dPrimaryDiseaseRoisOffset  = 1;     
        dCervicalRoisOffset        = 1;
        dSupraclavicularRoisOffset = 1;
        dMediastinalRoisOffset     = 1;
        dParaspinalRoisOffset      = 1;
        dAxillaryRoisOffset        = 1;
        dAbdominalRoisOffset       = 1;
        dAllRoisOffset             = 1;
        
        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
            dFrom = dAllRoisOffset;
            dTo   = dAllRoisOffset+dNbRois-1;
                    
            tReport.All.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;          
            
            dAllRoisOffset = dAllRoisOffset+dNbRois;
           
            switch lower(atVoiInput{vv}.LesionType)
                
                case 'unspecified'                    
                    dFrom = dUnspecifiedRoisOffset;
                    dTo   = dUnspecifiedRoisOffset+dNbRois-1;
                    
                    tReport.Unspecified.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;          
                    
                    dUnspecifiedRoisOffset = dUnspecifiedRoisOffset+dNbRois;
                   
                case 'bone'                    
                    dFrom = dBoneRoisOffset;
                    dTo   = dBoneRoisOffset+dNbRois-1;
                    
                    tReport.Bone.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dBoneRoisOffset = dBoneRoisOffset+dNbRois;
                    
                case 'soft tissue'                    
                    dFrom = dSoftTissueRoisOffset;
                    dTo   = dSoftTissueRoisOffset+dNbRois-1;
                    
                    tReport.SoftTissue.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dSoftTissueRoisOffset = dSoftTissueRoisOffset+dNbRois;    
                    
                case 'lung'
                    dFrom = dLungRoisOffset;
                    dTo   = dLungRoisOffset+dNbRois-1;
                    
                    tReport.Lung.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungRoisOffset = dLungRoisOffset+dNbRois;
                    
                case 'liver'
                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;
                    
                    tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;
                    
                case 'parotid'
                    dFrom = dParotidRoisOffset;
                    dTo   = dParotidRoisOffset+dNbRois-1;
                    
                    tReport.Parotid.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dParotidRoisOffset = dParotidRoisOffset+dNbRois;
                    
                case 'blood pool'
                    dFrom = dBloodPoolRoisOffset;
                    dTo   = dBloodPoolRoisOffset+dNbRois-1;
                    
                    tReport.BloodPool.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dBloodPoolRoisOffset = dBloodPoolRoisOffset+dNbRois;       

                case 'lymph nodes'
                    dFrom = dLymphNodesRoisOffset;
                    dTo   = dLymphNodesRoisOffset+dNbRois-1;
                    
                    tReport.LymphNodes.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLymphNodesRoisOffset = dLymphNodesRoisOffset+dNbRois;  

                case 'primary disease'
                    dFrom = dPrimaryDiseaseRoisOffset;
                    dTo   = dPrimaryDiseaseRoisOffset+dNbRois-1;
                    
                    tReport.PrimaryDisease.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dPrimaryDiseaseRoisOffset = dPrimaryDiseaseRoisOffset+dNbRois;                      

                case 'cervical'
                    dFrom = dCervicalRoisOffset;
                    dTo   = dCervicalRoisOffset+dNbRois-1;
                    
                    tReport.Cervical.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dCervicalRoisOffset = dCervicalRoisOffset+dNbRois;

                case 'supraclavicular'
                    dFrom = dSupraclavicularRoisOffset;
                    dTo   = dSupraclavicularRoisOffset+dNbRois-1;
                    
                    tReport.Supraclavicular.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dSupraclavicularRoisOffset = dSupraclavicularRoisOffset+dNbRois;

                case 'mediastinal'
                    dFrom = dMediastinalRoisOffset;
                    dTo   = dMediastinalRoisOffset+dNbRois-1;
                    
                    tReport.Mediastinal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dMediastinalRoisOffset = dMediastinalRoisOffset+dNbRois;

                case 'paraspinal'
                    dFrom = dParaspinalRoisOffset;
                    dTo   = dParaspinalRoisOffset+dNbRois-1;
                    
                    tReport.Paraspinal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dParaspinalRoisOffset = dParaspinalRoisOffset+dNbRois;

                case 'axillary'
                    dFrom = dAxillaryRoisOffset;
                    dTo   = dAxillaryRoisOffset+dNbRois-1;
                    
                    tReport.Axillary.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dAxillaryRoisOffset = dAxillaryRoisOffset+dNbRois;

                case 'abdominal'
                    dFrom = dAbdominalRoisOffset;
                    dTo   = dAbdominalRoisOffset+dNbRois-1;
                    
                    tReport.Abdominal.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dAbdominalRoisOffset = dAbdominalRoisOffset+dNbRois;
            end
        end    
        
        
        % Compute lesion type
        
        % Compute Unspecified lesion
        
        progressBar( 1/16, 'Computing unspecified lesion, please wait');
        
        if numel(tReport.Unspecified.RoisTag) ~= 0
            
            voiMask = cell(1, numel(tReport.Unspecified.RoisTag));
            voiData = cell(1, numel(tReport.Unspecified.RoisTag));
            
            dNbCells = 0;

            for uu=1:numel(tReport.Unspecified.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Unspecified.RoisTag{uu}]} );
                
                tRoi = atRoiInput{find(aTagOffset, 1)};                
                
                if bModifiedMatrix == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Unspecified.Cells  = dNbCells;
            tReport.Unspecified.Volume = dNbCells*dVoxVolume;
            tReport.Unspecified.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Unspecified.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Unspecified.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;     
                    tReport.Unspecified.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Unspecified.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Unspecified.Mean = mean(voiData, 'all');
                    tReport.Unspecified.Max  = max (voiData, [], 'all');
                    tReport.Unspecified.Peak = computePeak(voiData);
               end
            else
                tReport.Unspecified.Mean = mean(voiData, 'all');             
                tReport.Unspecified.Max  = max (voiData, [], 'all');             
                tReport.Unspecified.Peak = computePeak(voiData);
            end

            if isempty(tReport.Unspecified.Mean)
                tReport.Unspecified.Mean = nan;
            end

            if isempty(tReport.Unspecified.Max)
                tReport.Unspecified.Max = nan;
            end

            if isempty(tReport.Unspecified.Peak)
                tReport.Unspecified.Peak = nan;
            end

            clear voiMask;
            clear voiData;    
        else
            tReport.Unspecified.Cells  = [];
            tReport.Unspecified.Volume = [];
            tReport.Unspecified.Mean   = [];            
            tReport.Unspecified.Max    = []; 
            tReport.Unspecified.Peak   = [];
        end
        
        % Compute bone lesion
        
        progressBar( 2/16, 'Computing bone lesion, please wait') ;
         
        if numel(tReport.Bone.RoisTag) ~= 0
            
            voiMask = cell(1, numel(tReport.Bone.RoisTag));
            voiData = cell(1, numel(tReport.Bone.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Bone.RoisTag)
                
                aTagOffset  = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Bone.RoisTag{uu}]} );
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Bone.Cells  = dNbCells;
            tReport.Bone.Volume = dNbCells*dVoxVolume;
            tReport.Bone.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Bone.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Bone.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;   
                    tReport.Bone.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Bone.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Bone.Mean = mean(voiData, 'all');
                    tReport.Bone.Max  = max (voiData, [], 'all');
                    tReport.Bone.Peak = computePeak(voiData);
                end
            else
                tReport.Bone.Mean = mean(voiData, 'all');             
                tReport.Bone.Max  = max (voiData, [], 'all');             
                tReport.Bone.Peak = computePeak(voiData);
            end

            if isempty(tReport.Bone.Mean)
                tReport.Bone.Mean = nan;
            end

            if isempty(tReport.Bone.Max)
                tReport.Bone.Max = nan;
            end

            if isempty(tReport.Bone.Peak)
                tReport.Bone.Peak = nan;
            end

            clear voiMask;
            clear voiData;  
        else
            tReport.Bone.Cells  = [];
            tReport.Bone.Volume = [];
            tReport.Bone.Mean   = [];
            tReport.Bone.Max    = [];
            tReport.Bone.Peak   = [];
        end
        
        % Compute SoftTissue lesion
        
        progressBar( 3/16, 'Computing soft tissue lesion, please wait' );
       
        if numel(tReport.SoftTissue.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.SoftTissue.RoisTag));
            voiData = cell(1, numel(tReport.SoftTissue.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.SoftTissue.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.SoftTissue.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.SoftTissue.Cells  = dNbCells;
            tReport.SoftTissue.Volume = dNbCells*dVoxVolume;
            tReport.SoftTissue.voiData = voiData;
           
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.SoftTissue.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.SoftTissue.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;   
                    tReport.SoftTissue.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.SoftTissue.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.SoftTissue.Mean = mean(voiData, 'all');
                    tReport.SoftTissue.Max  = max (voiData, [], 'all');
                    tReport.SoftTissue.Peak = computePeak(voiData);
                end
            else
                tReport.SoftTissue.Mean = mean(voiData, 'all');             
                tReport.SoftTissue.Max  = max (voiData, [], 'all');             
                tReport.SoftTissue.Peak = computePeak(voiData);
            end

            if isempty(tReport.SoftTissue.Mean)
                tReport.SoftTissue.Mean = nan;
            end

            if isempty(tReport.SoftTissue.Max)
                tReport.SoftTissue.Max = nan;
            end

            if isempty(tReport.SoftTissue.Peak)
                tReport.SoftTissue.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.SoftTissue.Cells  = [];
            tReport.SoftTissue.Volume = [];
            tReport.SoftTissue.Mean   = [];            
            tReport.SoftTissue.Max    = [];            
            tReport.SoftTissue.Peak   = [];
        end
        
        % Compute Lung lesion
        
        progressBar( 4/16, 'Computing lung lesion, please wait' );
       
        if numel(tReport.Lung.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Lung.RoisTag));
            voiData = cell(1, numel(tReport.Lung.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Lung.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Lung.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get'), [], dSeriesOffset)
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Lung.Cells  = dNbCells;
            tReport.Lung.Volume = dNbCells*dVoxVolume;
            tReport.Lung.voiData = voiData;
          
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Lung.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Lung.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;     
                    tReport.Lung.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Lung.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Lung.Mean = mean(voiData, 'all');
                    tReport.Lung.Max  = max (voiData, [], 'all');
                    tReport.Lung.Peak = computePeak(voiData);
                end
            else
                tReport.Lung.Mean = mean(voiData, 'all');             
                tReport.Lung.Max  = max (voiData, [], 'all');             
                tReport.Lung.Peak = computePeak(voiData);
            end

            if isempty(tReport.Lung.Mean)
                tReport.Lung.Mean = nan;
            end

            if isempty(tReport.Lung.Max)
                tReport.Lung.Max = nan;
            end

            if isempty(tReport.Lung.Peak)
                tReport.Lung.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Lung.Cells  = [];
            tReport.Lung.Volume = [];
            tReport.Lung.Mean   = [];            
            tReport.Lung.Max    = [];            
            tReport.Lung.Peak   = [];
        end
        
        % Compute Liver lesion
        
        progressBar( 5/16, 'Computing liver lesion, please wait' );
       
        if numel(tReport.Liver.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Liver.RoisTag));
            voiData = cell(1, numel(tReport.Liver.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Liver.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Liver.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
                    tReport.Liver.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Liver.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Liver.Mean = mean(voiData, 'all');
                    tReport.Liver.Max  = max (voiData, [], 'all');
                    tReport.Liver.Peak = computePeak(voiData);
                end
            else
                tReport.Liver.Mean = mean(voiData, 'all');             
                tReport.Liver.Max  = max (voiData, [], 'all');             
                tReport.Liver.Peak = computePeak(voiData);
            end

            if isempty(tReport.Liver.Mean)
                tReport.Liver.Mean = nan;
            end

            if isempty(tReport.Liver.Max)
                tReport.Liver.Max = nan;
            end

            if isempty(tReport.Liver.Peak)
                tReport.Liver.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Liver.Cells  = [];
            tReport.Liver.Volume = [];
            tReport.Liver.Mean   = [];            
            tReport.Liver.Max    = [];            
            tReport.Liver.Peak   = [];
        end
        
        % Compute Parotid lesion
        
        progressBar( 6/16, 'Computing parotid lesion, please wait' );
       
        if numel(tReport.Parotid.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Parotid.RoisTag));
            voiData = cell(1, numel(tReport.Parotid.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Parotid.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Parotid.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Parotid.Cells  = dNbCells;
            tReport.Parotid.Volume = dNbCells*dVoxVolume;
            tReport.Parotid.voiData = voiData;

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Parotid.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Parotid.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;        
                    tReport.Parotid.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Parotid.voiData = voiData *tQuantification.tSUV.dScale;                    
                else
                    tReport.Parotid.Mean = mean(voiData, 'all');
                    tReport.Parotid.Max  = max (voiData, [], 'all');
                    tReport.Parotid.Peak = computePeak(voiData);
                end
            else
                tReport.Parotid.Mean = mean(voiData, 'all');             
                tReport.Parotid.Max  = max (voiData, [], 'all');             
                tReport.Parotid.Peak = computePeak(voiData);
            end

            if isempty(tReport.Parotid.Mean)
                tReport.Parotid.Mean = nan;
            end

            if isempty(tReport.Parotid.Max)
                tReport.Parotid.Max = nan;
            end

            if isempty(tReport.Parotid.Peak)
                tReport.Parotid.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Parotid.Cells  = [];
            tReport.Parotid.Volume = [];
            tReport.Parotid.Mean   = [];            
            tReport.Parotid.Max    = [];            
            tReport.Parotid.Peak   = [];
        end
        
        % Compute BloodPool lesion
        
        progressBar( 7/16, 'Computing blood pool lesion, please wait' );
       
        if numel(tReport.BloodPool.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.BloodPool.RoisTag));
            voiData = cell(1, numel(tReport.BloodPool.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.BloodPool.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.BloodPool.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.BloodPool.Cells  = dNbCells;
            tReport.BloodPool.Volume = dNbCells*dVoxVolume;
            tReport.BloodPool.voiData = voiData;
           
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.BloodPool.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.BloodPool.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;    
                    tReport.BloodPool.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.BloodPool.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.BloodPool.Mean = mean(voiData, 'all');
                    tReport.BloodPool.Max  = max (voiData, [], 'all');
                    tReport.BloodPool.Peak = computePeak(voiData);
                end
            else
                tReport.BloodPool.Mean = mean(voiData, 'all');             
                tReport.BloodPool.Max  = max (voiData, [], 'all');             
                tReport.BloodPool.Peak = computePeak(voiData);
            end

            if isempty(tReport.BloodPool.Mean)
                tReport.BloodPool.Mean = nan;
            end

            if isempty(tReport.BloodPool.Max)
                tReport.BloodPool.Max = nan;
            end

            if isempty(tReport.BloodPool.Peak)
                tReport.BloodPool.Peak = nan;
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.BloodPool.Cells  = [];
            tReport.BloodPool.Volume = [];
            tReport.BloodPool.Mean   = [];            
            tReport.BloodPool.Max    = [];            
            tReport.BloodPool.Peak   = [];
        end

        % Compute LymphNodes lesion
        
        progressBar( 8/16, 'Computing lymph nodes lesion, please wait' );
       
        if numel(tReport.LymphNodes.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LymphNodes.RoisTag));
            voiData = cell(1, numel(tReport.LymphNodes.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.LymphNodes.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LymphNodes.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.LymphNodes.Cells  = dNbCells;
            tReport.LymphNodes.Volume = dNbCells*dVoxVolume;
            tReport.LymphNodes.voiData = voiData;

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LymphNodes.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LymphNodes.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.LymphNodes.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.LymphNodes.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.LymphNodes.Mean = mean(voiData, 'all');
                    tReport.LymphNodes.Max  = max (voiData, [], 'all');
                    tReport.LymphNodes.Peak = computePeak(voiData);
                end
            else
                tReport.LymphNodes.Mean = mean(voiData, 'all');             
                tReport.LymphNodes.Max  = max (voiData, [], 'all');             
                tReport.LymphNodes.Peak = computePeak(voiData);
            end

            if isempty(tReport.LymphNodes.Mean)
                tReport.LymphNodes.Mean = nan;
            end

            if isempty(tReport.LymphNodes.Max)
                tReport.LymphNodes.Max = nan;
            end

            if isempty(tReport.LymphNodes.Peak)
                tReport.LymphNodes.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.LymphNodes.Cells  = [];
            tReport.LymphNodes.Volume = [];
            tReport.LymphNodes.Mean   = [];            
            tReport.LymphNodes.Max    = [];            
            tReport.LymphNodes.Peak   = [];
        end

        % Compute Primary Disease lesion
        
        progressBar( 9/16, 'Computing primary disease lesion, please wait' );
       
        if numel(tReport.PrimaryDisease.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.PrimaryDisease.RoisTag));
            voiData = cell(1, numel(tReport.PrimaryDisease.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.PrimaryDisease.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.PrimaryDisease.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.PrimaryDisease.Cells  = dNbCells;
            tReport.PrimaryDisease.Volume = dNbCells*dVoxVolume;
            tReport.PrimaryDisease.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.PrimaryDisease.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.PrimaryDisease.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.PrimaryDisease.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.PrimaryDisease.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.PrimaryDisease.Mean = mean(voiData, 'all');
                    tReport.PrimaryDisease.Max  = max (voiData, [], 'all');
                    tReport.PrimaryDisease.Peak = computePeak(voiData);
                end
            else
                tReport.PrimaryDisease.Mean = mean(voiData, 'all');             
                tReport.PrimaryDisease.Max  = max (voiData, [], 'all');             
                tReport.PrimaryDisease.Peak = computePeak(voiData);
            end

            if isempty(tReport.PrimaryDisease.Mean)
                tReport.PrimaryDisease.Mean = nan;
            end

            if isempty(tReport.PrimaryDisease.Max)
                tReport.PrimaryDisease.Max = nan;
            end

            if isempty(tReport.PrimaryDisease.Peak)
                tReport.PrimaryDisease.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.PrimaryDisease.Cells  = [];
            tReport.PrimaryDisease.Volume = [];
            tReport.PrimaryDisease.Mean   = [];            
            tReport.PrimaryDisease.Max    = [];            
            tReport.PrimaryDisease.Peak   = [];
        end

        % Compute Cervical 
        
        progressBar( 10/16, 'Computing cervical, please wait' );
       
        if numel(tReport.Cervical.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Cervical.RoisTag));
            voiData = cell(1, numel(tReport.Cervical.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Cervical.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Cervical.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Cervical.Cells  = dNbCells;
            tReport.Cervical.Volume = dNbCells*dVoxVolume;
            tReport.Cervical.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Cervical.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Cervical.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Cervical.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Cervical.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Cervical.Mean = mean(voiData, 'all');
                    tReport.Cervical.Max  = max (voiData, [], 'all');
                    tReport.Cervical.Peak = computePeak(voiData);
                end
            else
                tReport.Cervical.Mean = mean(voiData, 'all');             
                tReport.Cervical.Max  = max (voiData, [], 'all');             
                tReport.Cervical.Peak = computePeak(voiData);
            end

            if isempty(tReport.Cervical.Mean)
                tReport.Cervical.Mean = nan;
            end

            if isempty(tReport.Cervical.Max)
                tReport.Cervical.Max = nan;
            end

            if isempty(tReport.Cervical.Peak)
                tReport.Cervical.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Cervical.Cells  = [];
            tReport.Cervical.Volume = [];
            tReport.Cervical.Mean   = [];            
            tReport.Cervical.Max    = [];            
            tReport.Cervical.Peak   = [];
        end

        % Compute Supraclavicular 
        
        progressBar( 11/16, 'Computing supraclavicular, please wait' );
       
        if numel(tReport.Supraclavicular.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Supraclavicular.RoisTag));
            voiData = cell(1, numel(tReport.Supraclavicular.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Supraclavicular.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Supraclavicular.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Supraclavicular.Cells  = dNbCells;
            tReport.Supraclavicular.Volume = dNbCells*dVoxVolume;
            tReport.Supraclavicular.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Supraclavicular.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Supraclavicular.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Supraclavicular.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Supraclavicular.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Supraclavicular.Mean = mean(voiData, 'all');
                    tReport.Supraclavicular.Max  = max (voiData, [], 'all');
                    tReport.Supraclavicular.Peak = computePeak(voiData);
                end
            else
                tReport.Supraclavicular.Mean = mean(voiData, 'all');             
                tReport.Supraclavicular.Max  = max (voiData, [], 'all');             
                tReport.Supraclavicular.Peak = computePeak(voiData);
            end

            if isempty(tReport.Supraclavicular.Mean)
                tReport.Supraclavicular.Mean = nan;
            end

            if isempty(tReport.Supraclavicular.Max)
                tReport.Supraclavicular.Max = nan;
            end

            if isempty(tReport.Supraclavicular.Peak)
                tReport.Supraclavicular.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Supraclavicular.Cells  = [];
            tReport.Supraclavicular.Volume = [];
            tReport.Supraclavicular.Mean   = [];            
            tReport.Supraclavicular.Max    = [];            
            tReport.Supraclavicular.Peak   = [];
        end

        % Compute Mediastinal 
        
        progressBar( 12/16, 'Computing mediastinal, please wait' );
       
        if numel(tReport.Mediastinal.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Mediastinal.RoisTag));
            voiData = cell(1, numel(tReport.Mediastinal.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Mediastinal.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Mediastinal.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Mediastinal.Cells  = dNbCells;
            tReport.Mediastinal.Volume = dNbCells*dVoxVolume;
            tReport.Mediastinal.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Mediastinal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Mediastinal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Mediastinal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Mediastinal.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Mediastinal.Mean = mean(voiData, 'all');
                    tReport.Mediastinal.Max  = max (voiData, [], 'all');
                    tReport.Mediastinal.Peak = computePeak(voiData);
                end
            else
                tReport.Mediastinal.Mean = mean(voiData, 'all');             
                tReport.Mediastinal.Max  = max (voiData, [], 'all');             
                tReport.Mediastinal.Peak = computePeak(voiData);
            end

            if isempty(tReport.Mediastinal.Mean)
                tReport.Mediastinal.Mean = nan;
            end

            if isempty(tReport.Mediastinal.Max)
                tReport.Mediastinal.Max = nan;
            end

            if isempty(tReport.Mediastinal.Peak)
                tReport.Mediastinal.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Mediastinal.Cells  = [];
            tReport.Mediastinal.Volume = [];
            tReport.Mediastinal.Mean   = [];            
            tReport.Mediastinal.Max    = [];            
            tReport.Mediastinal.Peak   = [];
        end

        % Compute Paraspinal 
        
        progressBar( 13/16, 'Computing paraspinal, please wait' );
       
        if numel(tReport.Paraspinal.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Paraspinal.RoisTag));
            voiData = cell(1, numel(tReport.Paraspinal.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Paraspinal.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Paraspinal.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Paraspinal.Cells  = dNbCells;
            tReport.Paraspinal.Volume = dNbCells*dVoxVolume;
            tReport.Paraspinal.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Paraspinal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Paraspinal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Paraspinal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Paraspinal.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Paraspinal.Mean = mean(voiData, 'all');
                    tReport.Paraspinal.Max  = max (voiData, [], 'all');
                    tReport.Paraspinal.Peak = computePeak(voiData);
                end
            else
                tReport.Paraspinal.Mean = mean(voiData, 'all');             
                tReport.Paraspinal.Max  = max (voiData, [], 'all');             
                tReport.Paraspinal.Peak = computePeak(voiData);
            end

            if isempty(tReport.Paraspinal.Mean)
                tReport.Paraspinal.Mean = nan;
            end

            if isempty(tReport.Paraspinal.Max)
                tReport.Paraspinal.Max = nan;
            end

            if isempty(tReport.Paraspinal.Peak)
                tReport.Paraspinal.Peak = nan;
            end
            
            clear voiMask;
            clear voiData;     
        else
            tReport.Paraspinal.Cells  = [];
            tReport.Paraspinal.Volume = [];
            tReport.Paraspinal.Mean   = [];            
            tReport.Paraspinal.Max    = [];            
            tReport.Paraspinal.Peak   = [];
        end

        % Compute Paraspinal 
        
        progressBar( 14/16, 'Computing axillary, please wait' );
       
        if numel(tReport.Axillary.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Axillary.RoisTag));
            voiData = cell(1, numel(tReport.Axillary.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Axillary.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Axillary.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Axillary.Cells  = dNbCells;
            tReport.Axillary.Volume = dNbCells*dVoxVolume;
            tReport.Axillary.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Axillary.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Axillary.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Axillary.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Axillary.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Axillary.Mean = mean(voiData, 'all');
                    tReport.Axillary.Max  = max (voiData, [], 'all');
                    tReport.Axillary.Peak = computePeak(voiData);
                end
            else
                tReport.Axillary.Mean = mean(voiData, 'all');             
                tReport.Axillary.Max  = max (voiData, [], 'all');             
                tReport.Axillary.Peak = computePeak(voiData);
            end
            
            if isempty(tReport.Axillary.Mean)
                tReport.Axillary.Mean = nan;
            end

            if isempty(tReport.Axillary.Max)
                tReport.Axillary.Max = nan;
            end

            if isempty(tReport.Axillary.Peak)
                tReport.Axillary.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Axillary.Cells  = [];
            tReport.Axillary.Volume = [];
            tReport.Axillary.Mean   = [];            
            tReport.Axillary.Max    = [];            
            tReport.Axillary.Peak   = [];
        end

        % Compute Abdominal 
        
        progressBar( 15/16, 'Computing abdominal, please wait' );
       
        if numel(tReport.Abdominal.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Abdominal.RoisTag));
            voiData = cell(1, numel(tReport.Abdominal.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Abdominal.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Abdominal.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
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
            
            tReport.Abdominal.Cells  = dNbCells;
            tReport.Abdominal.Volume = dNbCells*dVoxVolume;
            tReport.Abdominal.voiData = voiData;
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Abdominal.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Abdominal.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
                    tReport.Abdominal.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.Abdominal.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Abdominal.Mean = mean(voiData, 'all');
                    tReport.Abdominal.Max  = max (voiData, [], 'all');
                    tReport.Abdominal.Peak = computePeak(voiData);
                end
            else
                tReport.Abdominal.Mean = mean(voiData, 'all');             
                tReport.Abdominal.Max  = max (voiData, [], 'all');             
                tReport.Abdominal.Peak = computePeak(voiData);
            end
            
            if isempty(tReport.Abdominal.Mean)
                tReport.Abdominal.Mean = nan;
            end

            if isempty(tReport.Abdominal.Max)
                tReport.Abdominal.Max = nan;
            end

            if isempty(tReport.Abdominal.Peak)
                tReport.Abdominal.Peak = nan;
            end

            clear voiMask;
            clear voiData;     
        else
            tReport.Abdominal.Cells  = [];
            tReport.Abdominal.Volume = [];
            tReport.Abdominal.Mean   = [];            
            tReport.Abdominal.Max    = [];            
            tReport.Abdominal.Peak   = [];
        end

        % Compute All lesion
        
        progressBar( 0.99999 , 'Computing all lesion, please wait' );
        
        if numel(tReport.All.RoisTag) ~= 0

            glVoiAllContoursMask = false(size(aImage));

            voiMask = cell(1, numel(tReport.All.RoisTag));
            voiData = cell(1, numel(tReport.All.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.All.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.All.RoisTag{uu}]} );
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

                    if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                        pTemp{1} = tRoi;
                        ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImage, atMetaData, pTemp, false);
                        tRoi = ptrRoiTemp{1};
                    end   
                end
                
                switch lower(tRoi.Axe)       
                    
                    case 'axe'
                        voiData{uu} = aImage(:,:);
                        voiMask{uu} = roiTemplateToMask(tRoi, aImage(:,:));

                        glVoiAllContoursMask(:,:) = glVoiAllContoursMask(:,:)|voiMask{uu};
                      
                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        glVoiAllContoursMask(tRoi.SliceNb,:,:) = glVoiAllContoursMask(tRoi.SliceNb,:,:)| permute(voiMask{uu}, [3 2 1]);
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        glVoiAllContoursMask(:,tRoi.SliceNb,:) = glVoiAllContoursMask(:,tRoi.SliceNb,:)| permute(voiMask{uu}, [2 3 1]);
                        
                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        glVoiAllContoursMask(:,:,tRoi.SliceNb) = glVoiAllContoursMask(:,:,tRoi.SliceNb)|voiMask{uu};

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

            if bModifiedMatrix  == true && ... 
               bMovementApplied == true        % Can't use input buffer if movement have been applied

                if numel(aImage) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                    if size(aImage, 3) ~= size(dicomBuffer('get', [], dSeriesOffset), 3)
                        [glVoiAllContoursMask, ~] = resampleImage(glVoiAllContoursMask, atMetaData, dicomBuffer('get', [], dSeriesOffset),  atDicomMeta, 'Nearest', false, true);   
                    else
                        [glVoiAllContoursMask, ~] = resampleImage(glVoiAllContoursMask, atMetaData, dicomBuffer('get', [], dSeriesOffset),  atDicomMeta, 'Nearest', true, true);   
                    end                
                end
            end

            voiMask = cat(1, voiMask{:});
            voiData = cat(1, voiData{:});
            
            voiData(voiMask~=1) = [];
            
            if bSegmented  == true && ...      
               bModifiedMatrix == true % Can't use original buffer   

                voiData = voiData(voiData>cropValue('get'));                            
            end
    
            tReport.All.Cells  = dNbCells;
            tReport.All.Volume = dNbCells*dVoxVolume;
            tReport.All.voiData = voiData;

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.All.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.All.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;     
                    tReport.All.Peak = computePeak(voiData, tQuantification.tSUV.dScale);
                    tReport.All.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.All.Mean = mean(voiData, 'all');
                    tReport.All.Max  = max (voiData, [], 'all');
                    tReport.All.Peak = computePeak(voiData);
                end
            else
                tReport.All.Mean = mean(voiData, 'all');             
                tReport.All.Max  = max (voiData, [], 'all');             
                tReport.All.Peak = computePeak(voiData);
            end

            if isempty(tReport.All.Mean)
                tReport.All.Mean = nan;
            end

            if isempty(tReport.All.Max)
                tReport.All.Max = nan;
            end

            if isempty(tReport.All.Peak)
                tReport.All.Peak = nan;
            end

            clear voiMask;
            clear voiData;
        else
            tReport.All.Cells  = [];
            tReport.All.Volume = [];
            tReport.All.Mean   = [];               
            tReport.All.Max    = [];               
            tReport.All.Peak   = [];
        end

        if ~isempty(glVoiAllContoursMask)
            [gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeMaskFarthestPoint(glVoiAllContoursMask(:,:,end:-1:1), atMetaData, bCentroid);     
        end

        clear aImage;
        
        progressBar( 1 , 'Ready' );
       
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
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end 

            sFileName = sprintf('%s%s', path, file);
            
            if exist(sFileName, 'file')
                delete(sFileName);
            end
                
            set(axeContourReport,'LooseInset', get(axeContourReport,'TightInset'));
            unit = get(figContourReport,'Units');
            set(figContourReport,'Units','inches');
            pos = get(figContourReport,'Position');

            set(figContourReport, ...
                'PaperPositionMode', 'auto',...
                'PaperUnits'       , 'inches',...
                'PaperPosition'    , [0,0,pos(3),pos(4)],...
                'PaperSize'        , [pos(3), pos(4)]);

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            print(figContourReport, sFileName, '-image', '-dpdf', '-r0');
         
            set(figContourReport,'Units', unit);

            progressBar( 1 , sprintf('Export %s completed.', sFileName)); 
        
            try
                winopen(sFileName);
            catch
            end
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentReportToPdfCallback() cant export report' );
        end

        set(figContourReport, 'Pointer', 'default');
        drawnow;        
    end

    function exportCurrentReportAxialSlicesToAviCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        bMipPlayback = playback2DMipOnly('get');

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
            progressBar( 1 , 'Error: exportCurrentReportAxialSlicesToAviCallback() cant export report' );
        end

        playback2DMipOnly('set', bMipPlayback);
        
        multiFrameRecord('set', false);

        set(recordIconMenuObject('get'), 'State', 'off');

        sliceNumber('set', 'axial', dAxialSliceNumber);

        sliderTraCallback();

        set(figContourReport, 'Pointer', 'default');
        drawnow;          
    end

    function exportCurrentReportAxialSlicesToDicomMovieCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        bMipPlayback = playback2DMipOnly('get');

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
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end   
        end    
    
        set(figContourReport, 'Pointer', 'watch');
        drawnow;

        playback2DMipOnly('set', false);

        sliceNumber('set', 'axial', size(dicomBuffer('get', [], dSeriesOffset), 3));

        multiFrameRecord('set', true);

        set(recordIconMenuObject('get'), 'State', 'on');

        recordMultiFrame(recordIconMenuObject('get'), sOutDir, [], 'dcm', axes3Ptr('get', [], dSeriesOffset));

%         objectToDicomJpg(sWriteDir, figContourReport, '3DF MFSC', get(uiSeriesPtr('get'), 'Value'))
   
        catch
            progressBar( 1 , 'Error: exportCurrentReportAxialSlicesToDicomMovieCallback() cant export report' );
        end

        playback2DMipOnly('set', bMipPlayback);
        
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

            inv = get(figContourReport,'InvertHardCopy');

            set(figContourReport,'InvertHardCopy','Off');

            drawnow;
            hgexport(figContourReport,'-clipboard');

            set(figContourReport,'InvertHardCopy',inv);
        catch
            progressBar( 1 , 'Error: copyReportDisplayCallback() cant copy report' );
        end

        set(figContourReport, 'Pointer', 'default');
    end

    function display3Dobject(bModifiedMatrix)

        a3DWindowPosition = get(ui3DWindow, 'position'); 

        delete(ui3DWindow);

        ui3DWindow = ...
        uipanel(uiContourReport,...
                'Units'          , 'pixels',...
                'BorderWidth'    , showBorder('get'),...
                'HighlightColor' , [0 1 1],...
                'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
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
        
            if verLessThan('matlab','9.13')
                gp3DObject = volshow(squeeze(aBuffer),  aInputArguments{:});
            else
                gp3DObject = images.compatibility.volshow.R2022a.volshow(squeeze(aBuffer), aInputArguments{:});                   
            end
        
            gp3DObject.CameraPosition = aCameraPosition;
            gp3DObject.CameraUpVector = aCameraUpVector;  
        end

        % Volume redering all contours 

        if ~isempty(glVoiAllContoursMask)

     %       glVoiAllContoursMask = smooth3(glVoiAllContoursMask(:,:,end:-1:1), 'box', 3);
            glVoiAllContoursMask = glVoiAllContoursMask(:,:,end:-1:1);
   
            aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};
    
            aAlphamap = linspace(0, 1, 256)';
            aColormap = getRedColorMap();
    
            aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];

            if verLessThan('matlab','9.13')
                gp3DContours = volshow(squeeze(glVoiAllContoursMask),  aInputArguments{:});
            else
                gp3DContours = images.compatibility.volshow.R2022a.volshow(squeeze(glVoiAllContoursMask), aInputArguments{:});                   
            end
    
            gp3DContours.CameraPosition = aCameraPosition;
            gp3DContours.CameraUpVector = aCameraUpVector;


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
          
                if verLessThan('matlab','9.13')
                    gp3DLine = volshow(squeeze(aLineBuffer),  aInputArguments{:});
                else
                    gp3DLine = images.compatibility.volshow.R2022a.volshow(squeeze(aLineBuffer), aInputArguments{:});                   
                end
        
                gp3DLine.CameraPosition = aCameraPosition;
                gp3DLine.CameraUpVector = aCameraUpVector;
            end
      %      gadFarthestXYZ1
      %      gadFarthestXYZ1

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

            a3DWWindowPosition = [20 15 FIG_REPORT_X/3-75-15 340];

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
        axeReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
        axeReport.Toolbar = [];
        
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
        catch
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
end