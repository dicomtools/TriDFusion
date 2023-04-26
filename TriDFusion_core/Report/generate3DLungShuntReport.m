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

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(atInput)
        return;
    end

    gtReport = [];

    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 840;

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
    addlistener(ui3DLungShuntReportSlider, 'Value', 'PreSet', @ui3DLungShuntReportSliderCallback);

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
                  'position', [0 FIG_REPORT_Y-100 FIG_REPORT_X/3-50 20]...
                  ); 
              
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportPatientInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-485 FIG_REPORT_X/3-50 375]...
                  );    
              
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
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-100 FIG_REPORT_X/3-50 20]...
                  ); 
              
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportSeriesInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-590 FIG_REPORT_X/3-50 480]...
                  );    
              
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-100 FIG_REPORT_X/3+100 20]...
                  ); 
              
         % Contour Type
              
          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Location',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-130 115 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-240 115 100]...
                  );  
              
         % Nb 3DLungShunt
              
          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Nb Contours',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-130 90 20]...
                  ); 

        uiReportLesionNb3DLungShunt = ...       
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportNbContourstInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-240 90 100]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-130 90 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-240 90 100]...
                  );  
              
         % 3DLungShunt Max
              
          uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Total',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionMax = ...       
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLungLiverReportMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-240 90 100]...
                  ); 
              
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-130 90 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-240 90 100]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 550 FIG_REPORT_X/3 20]...
                  ); 

     axe3DLungShuntRectangle = ...
       axes(ui3DLungShuntReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 540 FIG_REPORT_X/3+40 40], ...
             'Color'   , 'white',...          
             'Visible' , 'off'...             
             );  
     rectangle(axe3DLungShuntRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);

    % 3D Volume

    ui3DWindow = ...
    uipanel(ui3DLungShuntReport,...
            'Units'   , 'pixels',...
            'BorderWidth', showBorder('get'),...
            'HighlightColor', [0 1 1],...
            'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
            'position', [20 15 FIG_REPORT_X/3-75-15 340]...
            );  

    uiSlider3Dintensity = ...
    uicontrol(ui3DLungShuntReport, ...
              'Style'   , 'Slider', ...
              'Position', [5 15 15 340], ...
              'Value'   , 0.9, ...
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
              'position', [5 ui3DWindow.Position(4)+20 FIG_REPORT_X/3-75 20]...
              );
    % Notes

    uiEditWindow = ...
    uicontrol(ui3DLungShuntReport,...       
              'style'     , 'edit',...
              'FontWeight', 'Normal',...
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...              
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-75 200]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 470 400 20]...
                  ); 

        uiSliderLungsVolumeRatio = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 450 400 15], ...
                  'Value'   , 1, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Estimate lungs Volume', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @uiSliderLungsVolumeRatioCallback ...
                  );
        addlistener(uiSliderLungsVolumeRatio, 'Value', 'PreSet', @uiSliderLungsVolumeRatioCallback);

        aSliderLungVolumeRatioPosition = get(uiSliderLungsVolumeRatio, 'position');

        uiTextLungVolumeRatio = ...
         uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , sprintf('%2.2f%%', get(uiSliderLungsVolumeRatio, 'Value')*100),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [aSliderLungVolumeRatioPosition(1)+aSliderLungVolumeRatioPosition(3)+5 aSliderLungVolumeRatioPosition(2)-3 100 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 410 400 20]...
                  ); 

        uiSliderLiverVolumeRatio = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 390 400 15], ...
                  'Value'   , 1, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Estimate liver Volume', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @uiSliderLiverVolumeRatioCallback ...
                  );
        addlistener(uiSliderLiverVolumeRatio, 'Value', 'PreSet', @uiSliderLiverVolumeRatioCallback);

        aSliderLiverVolumeRatioPosition = get(uiSliderLiverVolumeRatio, 'position');

        uiTextLiverVolumeRatio = ...
         uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , sprintf('%2.2f%%', get(uiSliderLiverVolumeRatio, 'Value')*100),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [aSliderLiverVolumeRatioPosition(1)+aSliderLiverVolumeRatioPosition(3)+5 aSliderLiverVolumeRatioPosition(2) 100 20]...
                  ); 

    % Liver volume-of-interest oversized
         
        uicontrol(ui3DLungShuntReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Liver volume-of-interest oversized',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 330 400 20]...
                  ); 

        uiEditLiverVolumeOversized = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 300 60 25], ...
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
                  'string'    , 'Cutoff for the extra slice(s) above the top of the liver volume-of-interest',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 270 400 20]...
                  ); 

        uiEditLiverTopOfVolumeExtraSlices = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 240 60 25], ...
                  'String'   , num2str(lungShuntLiverTopOfVolumeExtraSlices('get')), ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Cutoff for the extra slice(s) above the top of the liver volume-of-interest', ...
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
                  'string'    , 'Cutoff for the extra slice(s) under the bottom of the liver volume-of-interest',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 210 400 20]...
                  ); 

        uiEditLiverBottomOfVolumeExtraSlices = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 180 60 25], ...
                  'String'   , num2str(lungShuntLiverBottomOfVolumeExtraSlices('get')), ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Cutoff for the extra slice(s) under the bottom of the liver volume-of-interest', ...
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
                  'FontWeight', 'normal',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Lungs volume-of-interest oversized',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 130 400 20]...
                  ); 

        uiEditLungsVolumeOversized = ...
        uicontrol(ui3DLungShuntReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 100 60 25], ...
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
                  'Position',[FIG_REPORT_X-(FIG_REPORT_X/3)-90 50 90 30],...
                  'Enable'  , 'On', ...
                  'BackgroundColor', [0.75 0.75 0.75], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @proceedLiverVolumeOversize...
                  );

    mReportFile = uimenu(fig3DLungShuntReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export to .pdf...','Callback', @exportCurrentLungLiverReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export to DICOM print...','Callback', @exportCurrentLungLiverReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(fig3DLungShuntReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyLungLiverReportDisplayCallback);

    mReportOptions = uimenu(fig3DLungShuntReport,'Label','Options', 'Callback', @figLungLiverRatioReportRefreshOption);    
    
    if suvMenuUnitOption('get') == true && ...
       atInput(dOffset).bDoseKernel == false    
        sSuvChecked = 'on';
    else
        if suvMenuUnitOption('get') == true
            suvMenuUnitOption('set', false);
        end
        sSuvChecked = 'off';
    end
    
    if atInput(dOffset).bDoseKernel == true
        sSuvEnable = 'off';
    else
        sSuvEnable = 'on';
    end
    
    mSUVUnit = uimenu(mReportOptions, 'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @lungLiverReportSUVUnitCallback);
       
    
    setLungLiverRatioReportFigureName();
    
    if bInitReport == false % Reopen the report
        refreshReportLesionInformation(suvMenuUnitOption('get'));
    else % First run
        gtReport = computeLungLiverReportContoursInformation(suvMenuUnitOption('get'), false, false, true);

        if lungShuntLiverVolumeOversized('get') ~= 0 || ...
           lungShuntLungsVolumeOversized('get') ~= 0     

            proceedLiverVolumeOversize();
        end

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
           
            if isvalid(uiReportLesionNb3DLungShunt) % Make sure the figure is still open        
                set(uiReportLesionNb3DLungShunt, 'String', getLungLiverReportNbContourstInformation('get', gtReport));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getLungLiverReportMeanInformation('get', gtReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getLungLiverReportTotalInformation('get', gtReport));
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
        dOffset = get(uiSeriesPtr('get'), 'Value');
    
        if atInput(dOffset).bDoseKernel == true
            sUnit =  'Dose';
        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnit = getSerieUnitValue(dOffset);
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
                    sUnit = getSerieUnitValue(dOffset);
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
                sReport = sprintf('%s%s', sReport, char(gasOrganList{ll}));
            else
                sReport = sprintf('%s\n\n%s', sReport, char(gasOrganList{ll}));
            end
        end       
    end

    function sReport = getLungLiverReportNbContourstInformation(sAction, tReport)
                      
        if strcmpi(sAction, 'init')
      %      sReport = sprintf('%s\n___________', '-');      
            sReport = '';
            for ll=1:numel(gasOrganList)
                if isempty(sReport)
                    sReport = '-';
                else
                    sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end       
        else
            
%            if ~isempty(tReport.All.Count)
%                sReport = sprintf('%-12s\n___________', num2str(tReport.All.Count));      
%            else
%                sReport = sprintf('%s\n___________', '-');      
%            end
            sReport = '';    

            for ll=1:numel(gasOrganList)      
                
                switch lower(gasOrganList{ll})
                    
                    case 'lungs'
                        if ~isempty(tReport.Lungs.Count)
                            sReport = sprintf('%s%-12s', sReport, num2str(tReport.Lungs.Count));
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Liver.Count));
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
        end
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
                        if ~isempty(tReport.Lungs.Mean)
                            sReport = sprintf('%s%-.2f', sReport, tReport.Lungs.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Mean);
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
                        if ~isempty(tReport.Lungs.Total)
                            sReport = sprintf('%s%-.2f', sReport, tReport.Lungs.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Total);
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
                        if ~isempty(tReport.Lungs.Volume)
                            sReport = sprintf('%s%-.3f', sReport, tReport.Lungs.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Liver.Volume);
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
        end         
    end

    function sLungsShuntFraction = getLungLiverReportRatioInformation(tReport)

            dLungsTotal = tReport.Lungs.Total*100;
            dLiverTotal = tReport.Liver.Total*100;

            % 𝑆ℎ𝑢𝑛𝑡 = ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            %        ____________________________
            %        ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 ) × 100

            sLungsShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungsTotal/(dLiverTotal+dLungsTotal)*100);
              
    end


    function tReport = computeLungLiverReportContoursInformation(bSUVUnit, bModifiedMatrix, bSegmented, bUpdateMasks)
        
        tReport = [];
        
        atInput = inputTemplate('get');
        dOffset = get(uiSeriesPtr('get'), 'Value');
        
        bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;
               
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
            atMetaData  = atInput(dOffset).atDicomInfo;
            aImage      = inputBuffer('get');
            
%            if     strcmpi(imageOrientation('get'), 'axial')
%                aImage = permute(aImage{dOffset}, [1 2 3]);
%            elseif strcmpi(imageOrientation('get'), 'coronal')
%                aImage = permute(aImage{dOffset}, [3 2 1]);
%            elseif strcmpi(imageOrientation('get'), 'sagittal')
%                aImage = permute(aImage{dOffset}, [3 1 2]);
%            end

            aImage = aImage{dOffset};

            if size(aImage, 3) ==1

                if atInput(dOffset).bFlipLeftRight == true
                    aImage=aImage(:,end:-1:1);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aImage=aImage(end:-1:1,:);
                end            
            else
                if atInput(dOffset).bFlipLeftRight == true
                    aImage=aImage(:,end:-1:1,:);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aImage=aImage(end:-1:1,:,:);
                end

                if atInput(dOffset).bFlipHeadFeet == true
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
            tReport.Lungs.Count = [];
        else
            tReport.Lungs.Count = dLungsCount;
        end
        
        if dLiverCount == 0
            tReport.Liver.Count = [];
        else
            tReport.Liver.Count = dLiverCount;
        end
                                    
        % Clasify ROIs by lession type      
  
        tReport.Lungs.RoisTag = cell(1, dNbLungsRois);
        tReport.Liver.RoisTag = cell(1, dNbLiverRois);    
           
        dLungsRoisOffset = 1;
        dLiverRoisOffset = 1;
        
        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
           
            switch lower(atVoiInput{vv}.Label)
                                    
                case 'lungs-lun'
                    dFrom = dLungsRoisOffset;
                    dTo   = dLungsRoisOffset+dNbRois-1;
                    
                    tReport.Lungs.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungsRoisOffset = dLungsRoisOffset+dNbRois;

                    tReport.Lungs.Color = atVoiInput{vv}.Color;
                
                case 'liver-liv'
                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;
                    
                    tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;               

                    tReport.Liver.Color = atVoiInput{vv}.Color;
           end
        end    
        
                
        % Compute Lungs segmentation
        
        progressBar( 1/2, 'Computing lungs segmentation, please wait' );
       
        if numel(tReport.Lungs.RoisTag) ~= 0  
       
            voiMask = cell(1, numel(tReport.Lungs.RoisTag));
            voiData = cell(1, numel(tReport.Lungs.RoisTag));
            
            dNbCells = 0;

            lungsMask = zeros(size(aImage));
         
            for uu=1:numel(tReport.Lungs.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Lungs.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

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
            
            tReport.Lungs.Cells  = dNbCells;
            tReport.Lungs.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.Lungs.Mask = lungsMask;

                lungShuntMasks('set', 'Lungs', lungsMask);
                clear lungsMask;
            else
                tReport.Lungs.Mask = lungShuntMasks('get', 'Lungs');
            end
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Lungs.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Lungs.Total = sum (voiData, 'all')*tQuantification.tSUV.dScale;             
%                    tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.Lungs.Mean  = mean(voiData, 'all');
                    tReport.Lungs.Total = sum (voiData, 'all');
%                    tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume;
                end
            else
                tReport.Lungs.Mean  = mean(voiData, 'all');             
                tReport.Lungs.Total = sum (voiData, 'all');             
%                tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume;             
            end
         
            clear voiMask;
            clear voiData;    
        else
            tReport.Lungs.Cells  = [];
            tReport.Lungs.Volume = [];
            tReport.Lungs.Mean   = [];            
            tReport.Lungs.Total  = [];            
        end
        
        % Compute Liver lesion
        
        progressBar( 1.9/2, 'Computing liver segmentation, please wait' );
       
        if numel(tReport.Liver.RoisTag) ~= 0  

            voiMask = cell(1, numel(tReport.Liver.RoisTag));
            voiData = cell(1, numel(tReport.Liver.RoisTag));
            
            dNbCells = 0;

            liverMask = zeros(size(aImage));
         
            for uu=1:numel(tReport.Liver.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Liver.RoisTag{uu}]} );                
                
                tRoi = atRoiInput{find(aTagOffset, 1)};
                
                if bModifiedMatrix  == false && ... 
                   bMovementApplied == false        % Can't use input buffer if movement have been applied

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
                            liverMask(:,:) = voiMask{uu}|liverMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            liverMask(tRoi.SliceNb,:,:) = voiMask{uu}|liverMask(tRoi.SliceNb,:,:);   
                        end

                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            liverMask(:,tRoi.SliceNb,:) = voiMask{uu}|liverMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            liverMask(:,:,tRoi.SliceNb) = voiMask{uu}|liverMask(:,:,tRoi.SliceNb);  
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
            
            tReport.Liver.Cells  = dNbCells;
            tReport.Liver.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.Liver.Mask = liverMask;

                lungShuntMasks('set', 'Liver', liverMask);
                clear liverMask;
            else
                tReport.Liver.Mask = lungShuntMasks('get', 'Liver');                
            end
        
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Liver.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Liver.Total = sum (voiData, 'all')*tQuantification.tSUV.dScale;             
%                    tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.Liver.Mean  = mean(voiData, 'all');
                    tReport.Liver.Total = sum (voiData, 'all');
%                    tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume;
                end
            else
                tReport.Liver.Mean  = mean(voiData, 'all');             
                tReport.Liver.Total = sum (voiData, 'all');             
%                tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume;             
            end
         
            clear voiMask;
            clear voiData;  

        else
            tReport.Liver.Cells  = [];
            tReport.Liver.Volume = [];
            tReport.Liver.Mean   = [];            
            tReport.Liver.Total  = [];            
        end
                  
        clear aImage;
        
        progressBar( 1 , 'Ready' );
       
    end

    function exportCurrentLungLiverReportToPdfCallback(~, ~)
        
        atMetaData = dicomMetaData('get');
       
        try
       
        filter = {'*.pdf'};

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastReportDir.mat'];
        
        % load last data directory
        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
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

        [file, path] = uiputfile(filter, 'Save 3D SPECT lung shunt report', sprintf('%s/%s_%s_%s_%s_LUNG_SHUNT_REPORT_TriDFusion.pdf' , ...
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
                
            set(axe3DLungShuntReport,'LooseInset', get(axe3DLungShuntReport,'TightInset'));
            set(fig3DLungShuntReport,'Units','inches');
            pos = get(fig3DLungShuntReport,'Position');

            set(fig3DLungShuntReport,'PaperPositionMode','auto',...
                'PaperUnits','inches',...
                'PaperPosition',[0,0,pos(3),pos(4)],...
                'PaperSize',[pos(3), pos(4)])

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            print(fig3DLungShuntReport, sFileName, '-image', '-dpdf', '-r0');

            try
                open(sFileName);
            catch
            end
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentLungLiverReportToPdfCallback() cant export report' );
        end

        set(fig3DLungShuntReport, 'Pointer', 'default');
        drawnow;        
    end
    
    function copyLungLiverReportDisplayCallback(~, ~)

        try

            set(fig3DLungShuntReport, 'Pointer', 'watch');

            inv = get(fig3DLungShuntReport,'InvertHardCopy');

            set(fig3DLungShuntReport,'InvertHardCopy','Off');

            drawnow;
            hgexport(fig3DLungShuntReport,'-clipboard');

            set(fig3DLungShuntReport,'InvertHardCopy',inv);
        catch
            progressBar( 1 , 'Error: copyLungLiverReportDisplayCallback() cant copy report' );
        end

        set(fig3DLungShuntReport, 'Pointer', 'default');
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
    
        if isempty(dCTSerieOffset) || ...
           isempty(dNMSerieOffset)  
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
        
%            if verLessThan('matlab','9.13')
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
        
            if verLessThan('matlab','9.13')
                pObject = volshow(squeeze(aCTBuffer),  aInputArguments{:});
            else
                pObject = images.compatibility.volshow.R2022a.volshow(squeeze(aCTBuffer), aInputArguments{:});                   
            end
        
            pObject.CameraPosition = aCameraPosition;
            pObject.CameraUpVector = aCameraUpVector;  

        end

        % Mask Volume Rendering 

        for jj=1:numel(gasMask)
    
            [aMask, aColor] = machineLearning3DMask('get', gasMask{jj});

            aMask = smooth3(aMask, 'box');
    
            if ~isempty(aMask)

                aColormap = zeros(256,3);

                aColormap(:,1) = aColor(1);
                aColormap(:,2) = aColor(2);
                aColormap(:,3) = aColor(3);

                dTransparencyValue = get(uiSlider3Dintensity, 'Value');

                aAlphamap = linspace(0, dTransparencyValue, 256)';

                aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'VolumeRendering', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};
        
                aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];
          
                if verLessThan('matlab','9.13')
                    gp3DObject{jj} = volshow(squeeze(aMask),  aInputArguments{:});
                else
                    gp3DObject{jj} = images.compatibility.volshow.R2022a.volshow(squeeze(aMask), aInputArguments{:});                   
                end
    
                gp3DObject{jj}.CameraPosition = aCameraPosition;
                gp3DObject{jj}.CameraUpVector = aCameraUpVector;
            end
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

        lungShuntLiverVolumeOversized('set', dNbPixels);
    end

    function uiEditLiverTopOfVolumeExtraSlicesCallback(~, ~)

        dNbExtraSlices = round(str2double(get(uiEditLiverTopOfVolumeExtraSlices, 'String')));

        if dNbExtraSlices < 0
            dNbExtraSlices = 0;
        end

        set(uiEditLiverTopOfVolumeExtraSlices, 'String', num2str(dNbExtraSlices));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbExtraSlices));
        set(uiTextLiverTopOfVolumeExtraSlices, 'String', sExtraSlicesSize);

        lungShuntLiverTopOfVolumeExtraSlices('set', dNbExtraSlices);

    end

    
    function uiEditLiverBottomOfVolumeExtraSlicesCallback(~, ~)

        dNbExtraSlices = round(str2double(get(uiEditLiverBottomOfVolumeExtraSlices, 'String')));

        if dNbExtraSlices < 0
            dNbExtraSlices = 0;
        end

        set(uiEditLiverBottomOfVolumeExtraSlices, 'String', num2str(dNbExtraSlices));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbExtraSlices));
        set(uiTextLiverBottomOfVolumeExtraSlices, 'String', sExtraSlicesSize);

        lungShuntLiverBottomOfVolumeExtraSlices('set', dNbExtraSlices);

    end

    function uiEditLungsVolumeOversizedCallback(~, ~)

        dNbPixels = round(str2double(get(uiEditLungsVolumeOversized, 'String')));

        if dNbPixels < 0
            dNbPixels = 0;
        end

        set(uiEditLungsVolumeOversized, 'String', num2str(dNbPixels));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getVolumeExtraSlicesSize(dNbPixels));
        set(uiTextLungsVolumeOversized, 'String', sExtraSlicesSize);
        
        lungShuntLungsVolumeOversized('set', dNbPixels);

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

        if isempty(dCTSerieOffset) || ...
           isempty(dNMSerieOffset)  
            progressBar(1, 'Error: uiSliderLiverVolumeSizeCallback() 3D Lung Liver Ratio require a CT and NM image!');
            errordlg('Error: uiSliderLiverVolumeSizeCallback() 3D Lung Liver Ratio require a CT and NM image!', 'Modality Validation');  
            return;               
        end

        dNbExtraSlicesAtTop    = round(str2double(get(uiEditLiverTopOfVolumeExtraSlices, 'String')));
        dNbExtraSlicesAtBottom = round(str2double(get(uiEditLiverBottomOfVolumeExtraSlices, 'String')));

        dLiverMaskOffset = round(str2double(get(uiEditLiverVolumeOversized, 'String')));
        dLungsMaskOffset = round(str2double(get(uiEditLungsVolumeOversized, 'String')));

        if ~isempty(gtReport) 
            try

            set(fig3DLungShuntReport, 'Pointer', 'watch');
            drawnow;

            set(uiSliderLiverVolumeRatio, 'Enable', 'off');
            set(uiSliderLungsVolumeRatio, 'Enable', 'off');

            set(uiEditLiverTopOfVolumeExtraSlices   , 'Enable', 'off');
            set(uiEditLiverBottomOfVolumeExtraSlices, 'Enable', 'off');
            set(uiEditLiverVolumeOversized          , 'Enable', 'off');
            set(uiEditLungsVolumeOversized          , 'Enable', 'off');
            set(uiProceedLiverVolumeOversize        , 'Enable', 'off');
 
            progressBar(1/4, 'Computing oversized liver mask, please wait.');

            dFirstSlice = [];
            dLastSlice = [];

            aLiverMask = gtReport.Liver.Mask;

            for jj=1:size(aLiverMask, 3)
                dOffset = find(aLiverMask(:,:,jj), 1);
                if ~isempty(dOffset)
                    if isempty(dFirstSlice)
                        dFirstSlice = jj;
                    end
                    dLastSlice = jj;
                end
            end

            aLiverMask = imdilate(aLiverMask, strel('sphere', dLiverMaskOffset)); % Increse mask by x pixels

            
            aLiverMask(:,:,1:dFirstSlice-1-dNbExtraSlicesAtTop) = 0;
            aLiverMask(:,:,dLastSlice+1+dNbExtraSlicesAtBottom:end) = 0;
            
            
            deleteLungShuntVoiContours('Liver-LIV', dNMSerieOffset);
         
            maskToVoi(aLiverMask, 'Liver', 'Liver', gtReport.Liver.Color, 'axial', dNMSerieOffset, pixelEdgeMachineLearningDialog('get'));
            
            % Clean Lungs Mask

            progressBar(2/4, 'Computing oversized lungs mask, please wait.');

            aLungsMask = gtReport.Lungs.Mask;

            aLungsMask = imdilate(aLungsMask, strel('sphere', dLungsMaskOffset)); % Increse mask by x pixels

            aLungsMask(aLiverMask~=0)=0;

            deleteLungShuntVoiContours('Lungs-LUN', dNMSerieOffset);

            maskToVoi(aLungsMask, 'Lungs', 'Lung', gtReport.Lungs.Color, 'axial', dNMSerieOffset, pixelEdgeMachineLearningDialog('get'));

            clear aLiverMask;
            clear aLungsMask;

            progressBar(3/4, 'Reprocessing contours information, please wait.');

            gtReport = computeLungLiverReportContoursInformation(suvMenuUnitOption('get'), false, false, false);

            if isvalid(uiReport3DLungShuntInformation) % Make sure the figure is still open     
                set(uiReport3DLungShuntInformation, 'String', sprintf('Contours Information (%s)', getLungLiverReportUnitValue()));                                             
            end
           
            if isvalid(uiReportLesionNb3DLungShunt) % Make sure the figure is still open        
                set(uiReportLesionNb3DLungShunt, 'String', getLungLiverReportNbContourstInformation('get', gtReport));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getLungLiverReportMeanInformation('get', gtReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getLungLiverReportTotalInformation('get', gtReport));
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
        
                    dLungsTotal = gtReport.Lungs.Total*100/dLungsPercent;
                    dLiverTotal = gtReport.Liver.Total*100/dLiverPercent;
        
                    % 𝑆ℎ𝑢𝑛𝑡 = ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
                    %        _________________________________
                    %        ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 ) × 100
        
                    sLungsShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungsTotal/(dLiverTotal+dLungsTotal)*100);
        
                    set(uiReport3DLungShuntLungRatio , 'string', sLungsShuntFraction);
        
                    set(uiEditWindow, 'string', sprintf('Updated lungs total: %.2f\nUpdated liver total  : %.2f', dLungsTotal, dLiverTotal));
        
                end
            end

            refreshImages();

            catch
                progressBar(1, 'Error: proceedLiverVolumeOversize()');
            end

            set(uiSliderLiverVolumeRatio, 'Enable', 'on');
            set(uiSliderLungsVolumeRatio, 'Enable', 'on');

            set(uiEditLiverTopOfVolumeExtraSlices   , 'Enable', 'on');
            set(uiEditLiverBottomOfVolumeExtraSlices, 'Enable', 'on');
            set(uiEditLiverVolumeOversized          , 'Enable', 'on');
            set(uiEditLungsVolumeOversized          , 'Enable', 'on');
            set(uiProceedLiverVolumeOversize        , 'Enable', 'on');

            set(fig3DLungShuntReport, 'Pointer', 'default');
            drawnow;

            progressBar(1, 'Ready');

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

                                % Delete ROI object

                                if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)
                                    delete(atRoiInput{aRoisTagOffset(ro)}.Object);
                                end

                                % Delete farthest distance object

                                if ~isempty(atRoiInput{aRoisTagOffset(ro)}.MaxDistances)

                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Line)
                                        delete(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Line);
                                    end

                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Line)
                                        delete(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Line);
                                    end

                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Text)
                                        delete(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Text);
                                    end

                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Text)
                                        delete(atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Text);
                                    end
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
        dLungsPercent = get(uiSliderLungsVolumeRatio, 'Value')*100;

        set(uiTextLiverVolumeRatio, 'string',  ...
            sprintf('%2.2f%%', dLiverPercent));
        
        if ~isempty(gtReport)

            dLungsTotal = gtReport.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.Liver.Total*100/dLiverPercent;

            % 𝑆ℎ𝑢𝑛𝑡 = ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            %        _________________________________
            %        ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 ) × 100

            sLungsShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungsTotal/(dLiverTotal+dLungsTotal)*100);

            set(uiReport3DLungShuntLungRatio , 'string', sLungsShuntFraction);      

            set(uiEditWindow, 'string', sprintf('Updated lungs total: %.2f\nUpdated liver total  : %.2f', dLungsTotal, dLiverTotal));
        end

    end

    function uiSliderLungsVolumeRatioCallback(~,~)

        dLiverPercent = get(uiSliderLiverVolumeRatio, 'Value')*100;
        dLungsPercent = get(uiSliderLungsVolumeRatio, 'Value')*100;

        set(uiTextLungVolumeRatio, 'string',  ...
            sprintf('%2.2f%%', dLungsPercent));

        if ~isempty(gtReport)

            dLungsTotal = gtReport.Lungs.Total*100/dLungsPercent;
            dLiverTotal = gtReport.Liver.Total*100/dLiverPercent;

            % 𝑆ℎ𝑢𝑛𝑡 = ( 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 )
            %        _________________________________
            %        ( L𝑣𝑒𝑟 𝐶𝑜𝑢𝑛𝑡𝑠 + 𝐿𝑢𝑛𝑔 𝐶𝑜𝑢𝑛𝑡𝑠 ) × 100

            sLungsShuntFraction = sprintf('Lung Shunt: %2.2f%%',  dLungsTotal/(dLiverTotal+dLungsTotal)*100);

            set(uiReport3DLungShuntLungRatio , 'string', sLungsShuntFraction);

            set(uiEditWindow, 'string', sprintf('Updated lungs total: %.2f\nUpdated liver total  : %.2f', dLungsTotal, dLiverTotal));

        end
    end

end