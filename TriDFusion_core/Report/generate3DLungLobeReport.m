function generate3DLungLobeReport(bInitReport)
%function generate3DLungLobeReport(bInitReport)
%Generate a report, from 3D Lobe Lung Ratio.
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

%    dScreenSize  = get(groot, 'Screensize');

%    xSize = dScreenSize(3);
%    ySize = dScreenSize(4);

    gp3DObject = [];

    gasOrganList={'Lungs','Lung Left', 'Lung Right', 'Upper Lobe Left', 'Lower Lobe Left', 'Upper Lobe Right', 'Middle Lobe Right', 'Lower Lobe Right'};

    gasMask = {'lung_lower_lobe_right', 'lung_lower_lobe_left','lung_middle_lobe_right','lung_upper_lobe_right','lung_upper_lobe_left'};
   
    atInput = inputTemplate('get');

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(atInput)
        return;
    end
    
    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 840;

    fig3DLobeLungReport = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REPORT_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REPORT_Y/2) ...
               FIG_REPORT_X ...
               FIG_REPORT_Y],...
               'Name', 'TriDFusion (3DF) 3D SPECT Lung Lobe Ratio Report',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Color', 'white', ...
               'Toolbar','none'...
               );
     fig3DLobeLungReportPtr('set', fig3DLobeLungReport);

     axe3DLobeLungReport = ...
       axes(fig3DLobeLungReport, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 FIG_REPORT_X FIG_REPORT_Y], ...
             'Color'   , 'white',...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             );  

     ui3DLobeLungReport = ...
     uipanel(fig3DLobeLungReport,...
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

    a3DLobeLungReportPosition = get(fig3DLobeLungReport, 'position');
    ui3DLobeLungReportSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , fig3DLobeLungReport,...
                  'Units'   , 'pixels',...
                  'position', [a3DLobeLungReportPosition(3)-15 ...
                               0 ...
                               15 ...
                               a3DLobeLungReportPosition(4) ...
                               ],...
                  'Value', 1, ...
                  'Callback',@ui3DLobeLungReportSliderCallback, ...
                  'BackgroundColor', 'white', ...
                  'ForegroundColor', 'black' ...
                  );
    addlistener(ui3DLobeLungReportSlider, 'Value', 'PreSet', @ui3DLobeLungReportSliderCallback);

        uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , ' TriDFusion (3DF) 3D SPECT Lung Lobe Ratio Report',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-30 FIG_REPORT_X 20]...
                  ); 
              
        uicontrol(ui3DLobeLungReport,...
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
         
         uicontrol(ui3DLobeLungReport,...
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
              
        uicontrol(ui3DLobeLungReport,...
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
              
         uicontrol(ui3DLobeLungReport,...
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
              
        uicontrol(ui3DLobeLungReport,...
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
         
         uiReport3DLobeLungInformation = ...       
         uicontrol(ui3DLobeLungReport,...
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

         ui3DLobeContoursInformationReport = ...
         uipanel(ui3DLobeLungReport,...
                 'Units'   , 'pixels',...
                 'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 ...
                              FIG_REPORT_Y-360 ...
                              465 ...
                              230 ...
                              ],...
                'Visible', 'on', ...
                'HighlightColor' , 'white', ...
                'BackgroundColor', 'white', ...
                'ForegroundColor', 'black' ...
                );

         aContourInformationUiPosition = get(ui3DLobeContoursInformationReport, 'position');

         ui3DLobeScrollableContoursInformationReport = ...
         uipanel(ui3DLobeContoursInformationReport,...
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

        gaContourInformationScrollableUiPosition = get(ui3DLobeScrollableContoursInformationReport, 'position');

        ui3DLobeScrollableContoursInformation = ...
        uicontrol(ui3DLobeLungReport, ...
                  'Style'   , 'Slider', ...
                  'Position', [FIG_REPORT_X-35 aContourInformationUiPosition(2) 15 aContourInformationUiPosition(4)], ...
                  'Value'   , 1, ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Intensity', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @sliderScrollableContoursInformationCallback ...
                  );
        addlistener(ui3DLobeScrollableContoursInformation, 'Value', 'PreSet', @sliderScrollableContoursInformationCallback);

         % Contour Type
              
          uicontrol(ui3DLobeLungReport,...
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
              
        uicontrol(ui3DLobeScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLobeLungReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 -100 130 gaContourInformationScrollableUiPosition(4)]...
                  );  
              
         % 3D LobeLung Mean
              
          uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Mean',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-70+110 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionMean = ...       
        uicontrol(ui3DLobeScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLobeLungReportMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130 -100 130 gaContourInformationScrollableUiPosition(4)]...
                  );  
              
         % 3DLobeLung Total
              
          uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Total',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15+130 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionMax = ...       
        uicontrol(ui3DLobeScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLobeLungReportMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130+105 -100 105 gaContourInformationScrollableUiPosition(4)]...
                  ); 
              
          % Contour Volume
              
          uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Volume (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15+240 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionVolume = ...       
        uicontrol(ui3DLobeScrollableContoursInformationReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getLobeLungReportVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [130+2*105 -100 105 gaContourInformationScrollableUiPosition(4)]...
                  );               
              
         uiReport3DLobeLeftLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 370+60 FIG_REPORT_X/3 20]...
                  ); 

         uiReport3DLobeRightLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 340+60 FIG_REPORT_X/3 20]...
                  ); 

     axe3DLungRectangle = ...
       axes(ui3DLobeLungReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 330+60 FIG_REPORT_X/3+45 70], ...
             'Color'   , 'white',...          
             'Visible' , 'off'...             
             );  
     rectangle(axe3DLungRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);

         uiReport3DLobeUpperLobeLeftLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 290+60 FIG_REPORT_X/3 20]...
                  ); 

         uiReport3DLobeLowerLobeLeftLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 260+60 FIG_REPORT_X/3 20]...
                  ); 

         uiReport3DLobeUpperLobeRightLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 230+60 FIG_REPORT_X/3 20]...
                  ); 

         uiReport3DLobeMiddleLobeRightLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 200+60 FIG_REPORT_X/3 20]...
                  ); 

         uiReport3DLobeLowerLobeRightLungRatio = ...       
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , '',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-80 170+60 FIG_REPORT_X/3 20]...
                  ); 

     axe3DLobesRectangle = ...
       axes(ui3DLobeLungReport, ...
             'Units'   , 'pixels', ...
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 160+60 FIG_REPORT_X/3+45 160], ...
             'Color'   , 'white',...          
             'Visible' , 'off'...             
             );  
    rectangle(axe3DLobesRectangle, 'position', [0 0 1 1], 'EdgeColor', [1 0.33 0.16]);     

    % Liver volume-of-interest oversized
         
        uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Liver volume-of-interest oversized',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 160 400 20]...
                  ); 

        uiEdit3DLobesLiverVolumeOversized = ...
        uicontrol(ui3DLobeLungReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 130 60 25], ...
                  'String'   , num2str(lungLobesLiverVolumeOversized('get')), ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Liver volume-of-interest oversized', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @uiEdit3DLobesLiverVolumeOversizedCallback ...
                  );

        aEdit3DLobesLiverVolumeSizePosition = get(uiEdit3DLobesLiverVolumeOversized, 'position');

        uiText3DLobesLiverVolumeOversized = ...
         uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , sprintf('pixel(s) (%2.2f mm)', getLobesLungVolumeOversizedSize(str2double(get(uiEdit3DLobesLiverVolumeOversized, 'String')))),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [aEdit3DLobesLiverVolumeSizePosition(1)+aEdit3DLobesLiverVolumeSizePosition(3)+5 aEdit3DLobesLiverVolumeSizePosition(2)-3 200 20]...
                  ); 
    
    % Cutoff for the extra slices above the top of the liver volume-of-interest
         
        uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Cutoff for the extra slice(s) above or bellow the top of the liver',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 100 500 20]...
                  ); 

        uiEdit3DLobesLiverTopOfVolumeExtraSlices = ...
        uicontrol(ui3DLobeLungReport, ...
                  'Style'   , 'edit', ...
                  'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 70 60 25], ...
                  'String'   , num2str(lungLobesLiverTopOfVolumeExtraSlices('get')), ...
                  'Enable'  , 'on', ...
                  'Tooltip' , 'Cutoff for the extra slice(s) above or bellow the top of the liver', ...
                  'BackgroundColor', 'White', ...
                  'CallBack', @uiEdit3DLobesLiverTopOfVolumeExtraSlicesCallback ...
                  );

        aEditLiverTopOfVolumeExtraSlicesPosition = get(uiEdit3DLobesLiverTopOfVolumeExtraSlices, 'position');

        uiText3DLobesLiverTopOfVolumeExtraSlices = ...
        uicontrol(ui3DLobeLungReport,...
                  'style'     , 'text',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , sprintf('slice(s) (%2.2f mm)', getLobesLungVolumeOversizedSize(str2double(get(uiEdit3DLobesLiverTopOfVolumeExtraSlices, 'String')))),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [aEditLiverTopOfVolumeExtraSlicesPosition(1)+aEditLiverTopOfVolumeExtraSlicesPosition(3)+5 aEditLiverTopOfVolumeExtraSlicesPosition(2)-3 200 20]...
                  ); 


        uiProceed3DLobesLiverVolumeOversize = ...
         uicontrol(ui3DLobeLungReport,...
                  'String'  ,'Reprocess',...
                  'FontWeight', 'bold',...
                  'Position',[FIG_REPORT_X-(FIG_REPORT_X/3)-90 20 90 30],...
                  'Enable'  , 'On', ...
                  'BackgroundColor', [0.75 0.75 0.75], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @proceed3DLobesLiverVolumeOversize...
                  );

    % 3D Volume

    ui3DWindow = ...
    uipanel(ui3DLobeLungReport,...
            'Units'   , 'pixels',...
            'BorderWidth', showBorder('get'),...
            'HighlightColor', [0 1 1],...
            'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
            'position', [20 15 FIG_REPORT_X/3-75-15 340]...
            );  

    uiSlider3Dintensity = ...
    uicontrol(ui3DLobeLungReport, ...
              'Style'   , 'Slider', ...
              'Position', [5 15 15 340], ...
              'Value'   , 0.9, ...
              'Enable'  , 'on', ...
              'Tooltip' , 'Intensity', ...
              'BackgroundColor', 'White', ...
              'CallBack', @slider3DLungLobesintensityCallback ...
              );
%    addlistener(uiSlider3Dintensity, 'Value', 'PreSet', @slider3DLungLobesintensityCallback);

     uicontrol(ui3DLobeLungReport,...
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
    uicontrol(ui3DLobeLungReport,...       
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

         uicontrol(ui3DLobeLungReport,...
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

    mReportFile = uimenu(fig3DLobeLungReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export to .pdf...','Callback', @exportCurrentLobeLungReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export to DICOM print...','Callback', @exportCurrentLobeLungReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(fig3DLobeLungReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyLobeLungReportDisplayCallback);

    mReportOptions = uimenu(fig3DLobeLungReport,'Label','Options', 'Callback', @figLobeLungRatioReportRefreshOption);    
    
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
    
    mSUVUnit = ...
        uimenu(mReportOptions, 'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @lobeLungReportSUVUnitCallback);
    
    setLobeLungRatioReportFigureName();
    
    if bInitReport == false % Reopen the report
        refreshReportLesionInformation(suvMenuUnitOption('get'));
    else % First run
        gtReport = computeLobeLungReportContoursInformation(suvMenuUnitOption('get'), false, false, true);  

        proceed3DLobesLiverVolumeOversize();
        
        if isvalid(ui3DWindow)
            display3DLobeLung();
        end
    end

    function refreshReportLesionInformation(bSUVUnit)
      
        gtReport = computeLobeLungReportContoursInformation(bSUVUnit, false, false, false);

        if ~isempty(gtReport) % Fill information

            if isvalid(uiReport3DLobeLungInformation) % Make sure the figure is still open     
                set(uiReport3DLobeLungInformation, 'String', sprintf('Contours Information (%s)', getLobeLungReportUnitValue()));                                             
            end
           
            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getLobeLungReportMeanInformation('get', gtReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getLobeLungReportTotalInformation('get', gtReport));
            end    
            
            if isvalid(uiReportLesionVolume) % Make sure the figure is still open        
                set(uiReportLesionVolume, 'String', getLobeLungReportVolumeInformation('get', gtReport));
            end  

            if isvalid(uiReport3DLobeLeftLungRatio)
                set(uiReport3DLobeLeftLungRatio, 'String', getReportLungLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeRightLungRatio)
                set(uiReport3DLobeRightLungRatio, 'String', getReportLungRightRatioInformation(gtReport));
            end    

            if isvalid(uiReport3DLobeUpperLobeLeftLungRatio)
                set(uiReport3DLobeUpperLobeLeftLungRatio, 'String', getReportUpperLobeLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeLowerLobeLeftLungRatio)
                set(uiReport3DLobeLowerLobeLeftLungRatio, 'String', getReportLowerLobeLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeUpperLobeRightLungRatio)
                set(uiReport3DLobeUpperLobeRightLungRatio, 'String', getReportUpperLobeRightRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeMiddleLobeRightLungRatio)
                set(uiReport3DLobeMiddleLobeRightLungRatio, 'String', getReportMiddleLobeRightRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeLowerLobeRightLungRatio)
                set(uiReport3DLobeLowerLobeRightLungRatio, 'String', getReportLowerLobeRightRatioInformation(gtReport));
            end  

            if isvalid(ui3DWindow)
                display3DLobeLung();
            end

        end
    end

    function uiEdit3DLobesLiverVolumeOversizedCallback(~, ~)

        dNbPixels = round(str2double(get(uiEdit3DLobesLiverVolumeOversized, 'String')));

        if dNbPixels < 0
            dNbPixels = 0;
        end

        set(uiEdit3DLobesLiverVolumeOversized, 'String', num2str(dNbPixels));

        sExtraPixelsSize = sprintf('pixel(s) (%2.2f mm)', getLobesLungVolumeOversizedSize(dNbPixels));
        set(uiText3DLobesLiverVolumeOversized, 'String', sExtraPixelsSize);

        lungLobesLiverVolumeOversized('set', dNbPixels);        

    end

    function uiEdit3DLobesLiverTopOfVolumeExtraSlicesCallback(~, ~)

        dNbExtraSlices = round(str2double(get(uiEdit3DLobesLiverTopOfVolumeExtraSlices, 'String')));

%        if dNbExtraSlices < 0
%            dNbExtraSlices = 0;
%        end

        set(uiEdit3DLobesLiverTopOfVolumeExtraSlices, 'String', num2str(dNbExtraSlices));

        sExtraSlicesSize = sprintf('slice(s) (%2.2f mm)', getLobesLungVolumeOversizedSize(dNbExtraSlices));
        set(uiText3DLobesLiverTopOfVolumeExtraSlices, 'String', sExtraSlicesSize);

        lungLobesLiverTopOfVolumeExtraSlices('set', dNbExtraSlices);
    end

    function proceed3DLobesLiverVolumeOversize(~, ~)

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
            progressBar(1, 'Error: proceed3DLobesLiverVolumeOversize() 3D Lung Liver Ratio require a CT and NM image!');
            errordlg('Error: proceed3DLobesLiverVolumeOversize() 3D Lung Liver Ratio require a CT and NM image!', 'Modality Validation');  
            return;               
        end

        dNbExtraSlicesAtTop    = round(str2double(get(uiEdit3DLobesLiverTopOfVolumeExtraSlices, 'String')));

        dLiverMaskOffset = round(str2double(get(uiEdit3DLobesLiverVolumeOversized, 'String')));

        if ~isempty(gtReport) 

            try

            set(fig3DLobeLungReport, 'Pointer', 'watch');
            drawnow;

            set(uiEdit3DLobesLiverTopOfVolumeExtraSlices   , 'Enable', 'off');
            set(uiEdit3DLobesLiverVolumeOversized          , 'Enable', 'off');
            set(uiProceed3DLobesLiverVolumeOversize        , 'Enable', 'off');

            progressBar(1/9, 'Computing oversized liver mask, please wait.');

            dFirstSlice = [];

            aLiverMask = gtReport.Liver.Mask;

            for jj=1:size(aLiverMask, 3)
                dOffset = find(aLiverMask(:,:,jj), 1);
                if ~isempty(dOffset)
                    if isempty(dFirstSlice)
                        dFirstSlice = jj;
                    end
                end
            end

            if dLiverMaskOffset ~= 0
                if dNbExtraSlicesAtTop < 0 

                    aLiverMaskTemp = imdilate(aLiverMask, strel('sphere', dLiverMaskOffset)); % Increse mask by x pixels
    
                    aLiverMaskTemp(:,:,1:dFirstSlice-1-dNbExtraSlicesAtTop) = 0;

                    if dNbExtraSlicesAtTop < 0
                        aLiverMaskTemp(:,:,dFirstSlice:dFirstSlice-1-dNbExtraSlicesAtTop) = aLiverMask(:,:,dFirstSlice:dFirstSlice-1-dNbExtraSlicesAtTop);
                    end

                    aLiverMask = aLiverMaskTemp;

                    clear aLiverMaskTemp;
                else
                    aLiverMask = imdilate(aLiverMask, strel('sphere', dLiverMaskOffset)); % Increse mask by x pixels
    
                    aLiverMask(:,:,1:dFirstSlice-1-dNbExtraSlicesAtTop) = 0;
                end
            end
                      
            delete3DLobesVoiContours('Liver-LIV', dNMSerieOffset);
         
            maskToVoi(aLiverMask, 'Liver', 'Liver', gtReport.Liver.Color, 'axial', dNMSerieOffset, pixelEdge('get'));
            
            % Clean Lungs Mask

            progressBar(2/9, 'Computing oversized liver, lungs mask, please wait.');

            aLungsMask = gtReport.Lungs.Mask;

            aLungsMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lungs-LUN', dNMSerieOffset);

            maskToVoi(aLungsMask, 'Lungs', 'Lung', gtReport.Lungs.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungsMask;

            % Clean Lung Left Mask

            progressBar(3/9, 'Computing oversized liver, lung left mask, please wait.');

            aLungLeftMask = gtReport.LungLeft.Mask;

            aLungLeftMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lung Left-LUN', dNMSerieOffset);

            maskToVoi(aLungLeftMask, 'Lung Left', 'Lung', gtReport.LungLeft.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungLeftMask;
            
            % Clean Lung Right Mask

            progressBar(4/9, 'Computing oversized liver, lung right mask, please wait.');

            aLungRightMask = gtReport.LungRight.Mask;

            aLungRightMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lung Right-LUN', dNMSerieOffset);

            maskToVoi(aLungRightMask, 'Lung Right', 'Lung', gtReport.LungRight.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungRightMask;

            % Clean Lung Lower Lobe Left Mask

            progressBar(5/9, 'Computing oversized liver, lung lower left lobe mask, please wait.');

            aLungLowerLobeLeftMask = gtReport.LungLowerLobeLeft.Mask;

            aLungLowerLobeLeftMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lung Lower Lobe Left-LUN', dNMSerieOffset);

            maskToVoi(aLungLowerLobeLeftMask, 'Lung Lower Lobe Left', 'Lung', gtReport.LungLowerLobeLeft.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungLowerLobeLeftMask;

            % Clean Lung Lower Lobe Left Mask

            progressBar(6/9, 'Computing oversized liver, lung lower right lobe mask, please wait.');

            aLungLowerLobeRightMask = gtReport.LungLowerLobeRight.Mask;

            aLungLowerLobeRightMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lung Lower Lobe Right-LUN', dNMSerieOffset);

            maskToVoi(aLungLowerLobeRightMask, 'Lung Lower Lobe Right', 'Lung', gtReport.LungLowerLobeRight.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungLowerLobeRightMask;

            % Clean Lung Lower Lobe Left Mask

            progressBar(7/9, 'Computing oversized liver, lung middle right lobe mask, please wait.');

            aLungMiddleLobeRightMask = gtReport.LungMiddleLobeRight.Mask;

            aLungMiddleLobeRightMask(aLiverMask~=0)=0;
            
            delete3DLobesVoiContours('Lung Middle Lobe Right-LUN', dNMSerieOffset);

            maskToVoi(aLungMiddleLobeRightMask, 'Lung Middle Lobe Right', 'Lung', gtReport.LungMiddleLobeRight.Color, 'axial', dNMSerieOffset, pixelEdge('get'));

            clear aLungMiddleLobeRightMask;

            clear aLiverMask;


            progressBar(8/9, 'Reprocessing contours information, please wait.');

            gtReport = computeLobeLungReportContoursInformation(suvMenuUnitOption('get'), false, false, false);

            if isvalid(uiReport3DLobeLungInformation) % Make sure the figure is still open     
                set(uiReport3DLobeLungInformation, 'String', sprintf('Contours Information (%s)', getLobeLungReportUnitValue()));                                             
            end
           
            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getLobeLungReportMeanInformation('get', gtReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getLobeLungReportTotalInformation('get', gtReport));
            end    
            
            if isvalid(uiReportLesionVolume) % Make sure the figure is still open        
                set(uiReportLesionVolume, 'String', getLobeLungReportVolumeInformation('get', gtReport));
            end  

            if isvalid(uiReport3DLobeLeftLungRatio)
                set(uiReport3DLobeLeftLungRatio, 'String', getReportLungLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeRightLungRatio)
                set(uiReport3DLobeRightLungRatio, 'String', getReportLungRightRatioInformation(gtReport));
            end    

            if isvalid(uiReport3DLobeUpperLobeLeftLungRatio)
                set(uiReport3DLobeUpperLobeLeftLungRatio, 'String', getReportUpperLobeLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeLowerLobeLeftLungRatio)
                set(uiReport3DLobeLowerLobeLeftLungRatio, 'String', getReportLowerLobeLeftRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeUpperLobeRightLungRatio)
                set(uiReport3DLobeUpperLobeRightLungRatio, 'String', getReportUpperLobeRightRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeMiddleLobeRightLungRatio)
                set(uiReport3DLobeMiddleLobeRightLungRatio, 'String', getReportMiddleLobeRightRatioInformation(gtReport));
            end  

            if isvalid(uiReport3DLobeLowerLobeRightLungRatio)
                set(uiReport3DLobeLowerLobeRightLungRatio, 'String', getReportLowerLobeRightRatioInformation(gtReport));
            end 
            

            refreshImages();

            progressBar(1, 'Ready');

            catch
                progressBar(1, 'Error: proceed3DLobesLiverVolumeOversize()');
            end

            set(uiEdit3DLobesLiverTopOfVolumeExtraSlices   , 'Enable', 'on');
            set(uiEdit3DLobesLiverVolumeOversized          , 'Enable', 'on');
            set(uiProceed3DLobesLiverVolumeOversize        , 'Enable', 'on');

            set(fig3DLobeLungReport, 'Pointer', 'default');
            drawnow;
        end

    end

    function delete3DLobesVoiContours(sVoiLabel, dSerieOffset)

                
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

    function dVolumeOversizedSize = getLobesLungVolumeOversizedSize(dNbPixels)

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

    function setLobeLungRatioReportFigureName()

        if ~isvalid(fig3DLobeLungReport)
            return;
        end        
    
        atMetaData = dicomMetaData('get');
       
        sUnit = sprintf('Unit: %s', getLobeLungReportUnitValue());
        
        fig3DLobeLungReport.Name = ['TriDFusion (3DF) 3D SPECT Lung Lobe Ratio Report - ' atMetaData{1}.SeriesDescription ' - ' sUnit];

    end
    
    function figLobeLungRatioReportRefreshOption(~, ~)

        if suvMenuUnitOption('get') == true 
            sSuvChecked = 'on';
        else
            sSuvChecked = 'off';
        end
              
        set(mSUVUnit         , 'Checked', sSuvChecked);

    end

    function sUnit = getLobeLungReportUnitValue()
        
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

    function lobeLungReportSUVUnitCallback(hObject, ~)
   
        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);
            
            refreshReportLesionInformation(false);            
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);
            
            refreshReportLesionInformation(true);            
        end

        setLobeLungRatioReportFigureName();
    end

    function sReport = getLobeLungReportLesionTypeInformation()
                
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

    function sReport = getLobeLungReportMeanInformation(sAction, tReport)
                
%        [~, gasOrganList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = '';    
            for ll=1:numel(gasOrganList)
                if isempty(sReport)
                    sReport = '-';
                else
                    if isempty(sReport)
                        sReport = '-';
                    else
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                    end
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
                        
                    case 'lung left'
                        if ~isempty(tReport.LungLeft.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLeft.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lung right'
                        if ~isempty(tReport.LungRight.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungRight.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end 

                    case 'upper lobe left'
                        if ~isempty(tReport.LungUpperLobeLeft.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungUpperLobeLeft.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'lower lobe left'
                        if ~isempty(tReport.LungLowerLobeLeft.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLowerLobeLeft.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'upper lobe right'
                        if ~isempty(tReport.LungUpperLobeRight.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungUpperLobeRight.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'middle lobe right'
                        if ~isempty(tReport.LungMiddleLobeRight.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungMiddleLobeRight.Mean);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lower lobe right'
                        if ~isempty(tReport.LungLowerLobeRight.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLowerLobeRight.Mean);
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

    function sReport = getLobeLungReportTotalInformation(sAction, tReport)
                
%        [~, gasOrganList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = '';      
            for ll=1:numel(gasOrganList)
                if isempty(sReport)
                    sReport = '-';
                else
                    if isempty(sReport)
                        sReport = '-';
                    else
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                    end
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
                        
                    case 'lung left'
                        if ~isempty(tReport.LungLeft.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLeft.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lung right'
                        if ~isempty(tReport.LungRight.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungRight.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end 

                    case 'upper lobe left'
                        if ~isempty(tReport.LungUpperLobeLeft.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungUpperLobeLeft.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'lower lobe left'
                        if ~isempty(tReport.LungLowerLobeLeft.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLowerLobeLeft.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'upper lobe right'
                        if ~isempty(tReport.LungUpperLobeRight.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungUpperLobeRight.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'middle lobe right'
                        if ~isempty(tReport.LungMiddleLobeRight.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungMiddleLobeRight.Total);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lower lobe right'
                        if ~isempty(tReport.LungLowerLobeRight.Total)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LungLowerLobeRight.Total);
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

    function sReport = getLobeLungReportVolumeInformation(sAction, tReport)
                
 %       [~, gasOrganList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = '';      
            for ll=1:numel(gasOrganList)
                if isempty(sReport)
                    sReport = '-';
                else
                    if isempty(sReport)
                        sReport = '-';
                    else
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                    end
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
                        
                    case 'lung left'
                        if ~isempty(tReport.LungLeft.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungLeft.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lung right'
                        if ~isempty(tReport.LungRight.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungRight.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end 

                    case 'upper lobe left'
                        if ~isempty(tReport.LungUpperLobeLeft.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungUpperLobeLeft.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'lower lobe left'
                        if ~isempty(tReport.LungLowerLobeLeft.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungLowerLobeLeft.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'upper lobe right'
                        if ~isempty(tReport.LungUpperLobeRight.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungUpperLobeRight.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end    

                    case 'middle lobe right'
                        if ~isempty(tReport.LungMiddleLobeRight.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungMiddleLobeRight.Volume);
                        else
                            if isempty(sReport)
                                sReport = '-';
                            else
                                sReport = sprintf('%s\n\n%s', sReport, '-');
                            end
                        end  

                    case 'lower lobe right'
                        if ~isempty(tReport.LungLowerLobeRight.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LungLowerLobeRight.Volume);
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


    function sReport = getReportLungLeftRatioInformation(tReport)

         sReport = sprintf('Lung Left Total Ratio   : %2.2f%%', tReport.LungLeft.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportLungRightRatioInformation(tReport)

         sReport = sprintf('Lung Right Total Ratio: %2.2f%%', tReport.LungRight.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportUpperLobeLeftRatioInformation(tReport)

         sReport = sprintf('Upper Lobe Left Total Ratio    : %2.2f%%', tReport.LungUpperLobeLeft.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportLowerLobeLeftRatioInformation(tReport)

         sReport = sprintf('Lower Lobe Left Total Ratio    : %2.2f%%', tReport.LungLowerLobeLeft.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportUpperLobeRightRatioInformation(tReport)

         sReport = sprintf('Upper Lobe Right Total Ratio : %2.2f%%', tReport.LungUpperLobeRight.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportMiddleLobeRightRatioInformation(tReport)

         sReport = sprintf('Middle Lobe Right Total Ratio: %2.2f%%', tReport.LungMiddleLobeRight.Total/tReport.Lungs.Total*100);
                    
    end

    function sReport = getReportLowerLobeRightRatioInformation(tReport)

         sReport = sprintf('Lower Lobe Right Total Ratio: %2.2f%%', tReport.LungLowerLobeRight.Total/tReport.Lungs.Total*100);
                    
    end

    function tReport = computeLobeLungReportContoursInformation(bSUVUnit, bModifiedMatrix, bSegmented, bUpdateMasks)
        
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

        dLiverCount               = 0;
        dLungsCount               = 0;
        dLungLeftCount            = 0;
        dLungRightCount           = 0;
        dLungUpperLobeLeftCount   = 0;
        dLungLowerLobeLeftCount   = 0;
        dLungUpperLobeRightCount  = 0;
        dLungMiddleLobeRightCount = 0;
        dLungLowerLobeRightCount  = 0;

        dNbLiverRois               = 0;
        dNbLungsRois               = 0;
        dNbLungLeftRois            = 0;
        dNbLungRightRois           = 0;
        dNbLungUpperLobeLeftRois   = 0;
        dNbLungLowerLobeLeftRois   = 0;
        dNbLungUpperLobeRightRois  = 0;
        dNbLungMiddleLobeRightRois = 0;
        dNbLungLowerLobeRightRois  = 0;

        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
            switch lower(atVoiInput{vv}.Label)

                case 'liver-liv'
                    dLiverCount  = dLiverCount+1;                    
                    dNbLiverRois = dNbLiverRois+dNbRois;

                case 'lungs-lun'
                    dLungsCount  = dLungsCount+1;                    
                    dNbLungsRois = dNbLungsRois+dNbRois;
                    
                case 'lung left-lun'
                    dLungLeftCount  = dLungLeftCount+1;                    
                    dNbLungLeftRois = dNbLungLeftRois+dNbRois;

                case 'lung right-lun'
                    dLungRightCount  = dLungRightCount+1;                    
                    dNbLungRightRois = dNbLungRightRois+dNbRois;   

                case 'lung upper lobe left-lun'
                    dLungUpperLobeLeftCount  = dLungUpperLobeLeftCount+1;                    
                    dNbLungUpperLobeLeftRois = dNbLungUpperLobeLeftRois+dNbRois;  

                case 'lung lower lobe left-lun'
                    dLungLowerLobeLeftCount  = dLungLowerLobeLeftCount+1;                    
                    dNbLungLowerLobeLeftRois = dNbLungLowerLobeLeftRois+dNbRois; 

                case 'lung upper lobe right-lun'
                    dLungUpperLobeRightCount  = dLungUpperLobeRightCount+1;                    
                    dNbLungUpperLobeRightRois = dNbLungUpperLobeRightRois+dNbRois;  

                case 'lung middle lobe right-lun'
                    dLungMiddleLobeRightCount  = dLungMiddleLobeRightCount+1;                    
                    dNbLungMiddleLobeRightRois = dNbLungMiddleLobeRightRois+dNbRois;  

                case 'lung lower lobe right-lun'
                    dLungLowerLobeRightCount  = dLungLowerLobeRightCount+1;                    
                    dNbLungLowerLobeRightRois = dNbLungLowerLobeRightRois+dNbRois; 
            end
        end
        
        % Set report type count

        if dLiverCount == 0
            tReport.Liver.Count = [];
        else
            tReport.Liver.Count = dLiverCount;
        end

        if dLungsCount == 0
            tReport.Lungs.Count = [];
        else
            tReport.Lungs.Count = dLungsCount;
        end
        
        if dLungLeftCount == 0
            tReport.LungLeft.Count = [];
        else
            tReport.LungLeft.Count = dLungLeftCount;
        end
                  
        if dLungRightCount == 0
            tReport.LungRight.Count = [];
        else
            tReport.LungRight.Count = dLungRightCount;
        end

        if dLungUpperLobeLeftCount == 0
            tReport.LungUpperLobeLeft.Count = [];
        else
            tReport.LungUpperLobeLeft.Count = dLungUpperLobeLeftCount;
        end

        if dLungLowerLobeLeftCount == 0
            tReport.LungLowerLobeLeft.Count = [];
        else
            tReport.LungLowerLobeLeft.Count = dLungLowerLobeLeftCount;
        end

        if dLungUpperLobeRightCount == 0
            tReport.LungUpperLobeRight.Count = [];
        else
            tReport.LungUpperLobeRight.Count = dLungUpperLobeRightCount;
        end

        if dLungMiddleLobeRightCount == 0
            tReport.LungMiddleLobeRight.Count = [];
        else
            tReport.LungMiddleLobeRight.Count = dLungMiddleLobeRightCount;
        end

        if dLungLowerLobeRightCount == 0
            tReport.LungLowerLobeRight.Count = [];
        else
            tReport.LungLowerLobeRight.Count = dLungLowerLobeRightCount;
        end
        
        % Clasify ROIs by lession type      
  
        tReport.Liver.RoisTag               = cell(1, dNbLiverRois);
        tReport.Lungs.RoisTag               = cell(1, dNbLungsRois);
        tReport.LungLeft.RoisTag            = cell(1, dNbLungLeftRois);    
        tReport.LungRight.RoisTag           = cell(1, dNbLungRightRois);               
        tReport.LungUpperLobeLeft.RoisTag   = cell(1, dNbLungUpperLobeLeftRois);    
        tReport.LungLowerLobeLeft.RoisTag   = cell(1, dNbLungLowerLobeLeftRois);    
        tReport.LungUpperLobeRight.RoisTag  = cell(1, dNbLungUpperLobeRightRois);    
        tReport.LungMiddleLobeRight.RoisTag = cell(1, dNbLungMiddleLobeRightRois);    
        tReport.LungLowerLobeRight.RoisTag  = cell(1, dNbLungLowerLobeRightRois);   

        dLiverRoisOffset               = 1;
        dLungsRoisOffset               = 1;
        dLungLeftRoisOffset            = 1;
        dLungRightRoisOffset           = 1;
        dLungUpperLobeLeftRoisOffset   = 1;
        dLungLowerLobeLeftRoisOffset   = 1;
        dLungUpperLobeRightRoisOffset  = 1;
        dLungMiddleLobeRightRoisOffset = 1;
        dLungLowerLobeRightRoisOffset  = 1;

        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
           
            switch lower(atVoiInput{vv}.Label)

                case 'liver-liv'
                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;
                    
                    tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;

                    tReport.Liver.Color = atVoiInput{vv}.Color;

                case 'lungs-lun'
                    dFrom = dLungsRoisOffset;
                    dTo   = dLungsRoisOffset+dNbRois-1;
                    
                    tReport.Lungs.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungsRoisOffset = dLungsRoisOffset+dNbRois;

                    tReport.Lungs.Color = atVoiInput{vv}.Color;
                   
                case 'lung left-lun'
                    dFrom = dLungLeftRoisOffset;
                    dTo   = dLungLeftRoisOffset+dNbRois-1;
                    
                    tReport.LungLeft.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungLeftRoisOffset = dLungLeftRoisOffset+dNbRois;      

                    tReport.LungLeft.Color = atVoiInput{vv}.Color;

                case 'lung right-lun'
                    dFrom = dLungRightRoisOffset;
                    dTo   = dLungRightRoisOffset+dNbRois-1;
                    
                    tReport.LungRight.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungRightRoisOffset = dLungRightRoisOffset+dNbRois; 

                    tReport.LungRight.Color = atVoiInput{vv}.Color;

                case 'lung upper lobe left-lun'
                    dFrom = dLungUpperLobeLeftRoisOffset;
                    dTo   = dLungUpperLobeLeftRoisOffset+dNbRois-1;
                    
                    tReport.LungUpperLobeLeft.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungUpperLobeLeftRoisOffset = dLungUpperLobeLeftRoisOffset+dNbRois; 

                    tReport.LungUpperLobeLeft.Color = atVoiInput{vv}.Color;

                case 'lung lower lobe left-lun'
                    dFrom = dLungLowerLobeLeftRoisOffset;
                    dTo   = dLungLowerLobeLeftRoisOffset+dNbRois-1;
                    
                    tReport.LungLowerLobeLeft.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungLowerLobeLeftRoisOffset = dLungLowerLobeLeftRoisOffset+dNbRois; 

                    tReport.LungLowerLobeLeft.Color = atVoiInput{vv}.Color;

                case 'lung upper lobe right-lun'
                    dFrom = dLungUpperLobeRightRoisOffset;
                    dTo   = dLungUpperLobeRightRoisOffset+dNbRois-1;
                    
                    tReport.LungUpperLobeRight.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungUpperLobeRightRoisOffset = dLungUpperLobeRightRoisOffset+dNbRois; 

                    tReport.LungUpperLobeRight.Color = atVoiInput{vv}.Color;

                case 'lung middle lobe right-lun'
                    dFrom = dLungMiddleLobeRightRoisOffset;
                    dTo   = dLungMiddleLobeRightRoisOffset+dNbRois-1;
                    
                    tReport.LungMiddleLobeRight.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungMiddleLobeRightRoisOffset = dLungMiddleLobeRightRoisOffset+dNbRois; 

                    tReport.LungMiddleLobeRight.Color = atVoiInput{vv}.Color;

                case 'lung lower lobe right-lun'
                    dFrom = dLungLowerLobeRightRoisOffset;
                    dTo   = dLungLowerLobeRightRoisOffset+dNbRois-1;
                    
                    tReport.LungLowerLobeRight.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLungLowerLobeRightRoisOffset = dLungLowerLobeRightRoisOffset+dNbRois; 

                    tReport.LungLowerLobeRight.Color = atVoiInput{vv}.Color;

            end
        end    
        
                
        % Compute Lung segmentation
        
        progressBar( 1/10, 'Computing lungs segmentation, please wait' );
       
        if numel(tReport.Lungs.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Lungs.RoisTag));
            voiData = cell(1, numel(tReport.Lungs.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));
            
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
                tReport.Lungs.Mask = aMask;

                lungLobesMasks('set', 'lungs', aMask);
                clear aMask;
            else
                tReport.Lungs.Mask = lungLobesMasks('get', 'lungs');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Lungs.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.Lungs.Mean  = mean(voiData, 'all');
                    tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume;
                end
            else
                tReport.Lungs.Mean  = mean(voiData, 'all');             
                tReport.Lungs.Total = tReport.Lungs.Mean*tReport.Lungs.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.Lungs.Cells  = [];
            tReport.Lungs.Volume = [];
            tReport.Lungs.Mean   = [];            
            tReport.Lungs.Total  = [];            
        end
        
        % Compute Lung Left segmentation
        
        progressBar( 2/10, 'Computing lung left segmentation, please wait' );
       
        if numel(tReport.LungLeft.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungLeft.RoisTag));
            voiData = cell(1, numel(tReport.LungLeft.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));
            
            for uu=1:numel(tReport.LungLeft.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungLeft.RoisTag{uu}]} );                
                
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
            
            tReport.LungLeft.Cells  = dNbCells;
            tReport.LungLeft.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.LungLeft.Mask = aMask;

                lungLobesMasks('set', 'lungLeft', aMask);
                clear aMask;
            else
                tReport.LungLeft.Mask = lungLobesMasks('get', 'lungLeft');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungLeft.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungLeft.Total = tReport.LungLeft.Mean*tReport.LungLeft.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungLeft.Mean  = mean(voiData, 'all');
                    tReport.LungLeft.Total = tReport.LungLeft.Mean*tReport.LungLeft.Volume;
                end
            else
                tReport.LungLeft.Mean  = mean(voiData, 'all');             
                tReport.LungLeft.Total = tReport.LungLeft.Mean*tReport.LungLeft.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungLeft.Cells  = [];
            tReport.LungLeft.Volume = [];
            tReport.LungLeft.Mean   = [];            
            tReport.LungLeft.Total  = [];            
        end
          
        % Compute Lung Right segmentation
        
        progressBar( 3/10, 'Computing lung right segmentation, please wait' );
       
        if numel(tReport.LungRight.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungRight.RoisTag));
            voiData = cell(1, numel(tReport.LungRight.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));
            
            for uu=1:numel(tReport.LungRight.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungRight.RoisTag{uu}]} );                
                
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
            
            tReport.LungRight.Cells  = dNbCells;
            tReport.LungRight.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.LungRight.Mask = aMask;

                lungLobesMasks('set', 'lungRight', aMask);
                clear aMask;
            else
                tReport.LungRight.Mask = lungLobesMasks('get', 'lungRight');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungRight.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungRight.Total = tReport.LungRight.Mean*tReport.LungRight.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungRight.Mean  = mean(voiData, 'all');
                    tReport.LungRight.Total = tReport.LungRight.Mean*tReport.LungRight.Volume;
                end
            else
                tReport.LungRight.Mean  = mean(voiData, 'all');             
                tReport.LungRight.Total = tReport.LungRight.Mean*tReport.LungRight.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungRight.Cells  = [];
            tReport.LungRight.Volume = [];
            tReport.LungRight.Mean   = [];            
            tReport.LungRight.Total  = [];            
        end

        % Compute upper Lobe Left segmentation
        
        progressBar( 4/10, 'Computing lung upper lobe left segmentation, please wait' );
       
        if numel(tReport.LungUpperLobeLeft.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungUpperLobeLeft.RoisTag));
            voiData = cell(1, numel(tReport.LungUpperLobeLeft.RoisTag));
            
            dNbCells = 0;

%            aMask = zeros(size(aImage));
            
            for uu=1:numel(tReport.LungUpperLobeLeft.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungUpperLobeLeft.RoisTag{uu}]} );                
                
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

%                        if bUpdateMasks == true
%                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
%                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                        if bUpdateMasks == true
%                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
%                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                        if bUpdateMasks == true
%                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
%                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                        if bUpdateMasks == true
%                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
%                        end
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
            
            tReport.LungUpperLobeLeft.Cells  = dNbCells;
            tReport.LungUpperLobeLeft.Volume = dNbCells*dVoxVolume;

%            if bUpdateMasks == true
%                tReport.LungUpperLobeLeft.Mask = aMask;

%                lungLobesMasks('set', 'lungUpperLobeLeft', aMask);
%                clear aMask;
%            else
%                tReport.LungUpperLobeLeft.Mask = lungLobesMasks('get', 'lungUpperLobeLeft');                
%            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungUpperLobeLeft.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungUpperLobeLeft.Total = tReport.LungUpperLobeLeft.Mean*tReport.LungUpperLobeLeft.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungUpperLobeLeft.Mean  = mean(voiData, 'all');
                    tReport.LungUpperLobeLeft.Total = tReport.LungUpperLobeLeft.Mean*tReport.LungUpperLobeLeft.Volume;
                end
            else
                tReport.LungUpperLobeLeft.Mean  = mean(voiData, 'all');             
                tReport.LungUpperLobeLeft.Total = tReport.LungUpperLobeLeft.Mean*tReport.LungUpperLobeLeft.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungUpperLobeLeft.Cells  = [];
            tReport.LungUpperLobeLeft.Volume = [];
            tReport.LungUpperLobeLeft.Mean   = [];            
            tReport.LungUpperLobeLeft.Total  = [];            
        end

        % Compute Lung Lower Lobe Left segmentation
        
        progressBar( 5/10, 'Computing lung lower lobe left segmentation, please wait' );
       
        if numel(tReport.LungLowerLobeLeft.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungLowerLobeLeft.RoisTag));
            voiData = cell(1, numel(tReport.LungLowerLobeLeft.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));
            
            for uu=1:numel(tReport.LungLowerLobeLeft.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungLowerLobeLeft.RoisTag{uu}]} );                
                
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
            
            tReport.LungLowerLobeLeft.Cells  = dNbCells;
            tReport.LungLowerLobeLeft.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.LungLowerLobeLeft.Mask = aMask;

                lungLobesMasks('set', 'lungLowerLobeLeft', aMask);
                clear aMask;
            else
                tReport.LungLowerLobeLeft.Mask = lungLobesMasks('get', 'lungLowerLobeLeft');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungLowerLobeLeft.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungLowerLobeLeft.Total = tReport.LungLowerLobeLeft.Mean*tReport.LungLowerLobeLeft.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungLowerLobeLeft.Mean  = mean(voiData, 'all');
                    tReport.LungLowerLobeLeft.Total = tReport.LungLowerLobeLeft.Mean*tReport.LungLowerLobeLeft.Volume;
                end
            else
                tReport.LungLowerLobeLeft.Mean  = mean(voiData, 'all');             
                tReport.LungLowerLobeLeft.Total = tReport.LungLowerLobeLeft.Mean*tReport.LungLowerLobeLeft.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungLowerLobeLeft.Cells  = [];
            tReport.LungLowerLobeLeft.Volume = [];
            tReport.LungLowerLobeLeft.Mean   = [];            
            tReport.LungLowerLobeLeft.Total  = [];            
        end

        % Compute Lung Upper Lobe right segmentation
        
        progressBar( 6/10, 'Computing lung upper lobe right segmentation, please wait' );
       
        if numel(tReport.LungUpperLobeRight.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungUpperLobeRight.RoisTag));
            voiData = cell(1, numel(tReport.LungUpperLobeRight.RoisTag));
            
            dNbCells = 0;

%            aMask = zeros(size(aImage));
            
            for uu=1:numel(tReport.LungUpperLobeRight.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungUpperLobeRight.RoisTag{uu}]} );                
                
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

%                        if bUpdateMasks == true
%                           aMask(:,:) = voiMask{uu}|aMask(:,:);   
%                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                        if bUpdateMasks == true
%                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
%                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

%                        if bUpdateMasks == true
%                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
%                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

 %                       if bUpdateMasks == true
 %                           aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
 %                       end
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
            
            tReport.LungUpperLobeRight.Cells  = dNbCells;
            tReport.LungUpperLobeRight.Volume = dNbCells*dVoxVolume;

%            if bUpdateMasks == true
%                tReport.LungUpperLobeRight.Mask = aMask;
%
%                lungLobesMasks('set', 'lungUpperLobeRight', aMask);
%                clear aMask;
%            else
%                tReport.LungUpperLobeRight.Mask = lungLobesMasks('get', 'lungUpperLobeRight');                
%            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungUpperLobeRight.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungUpperLobeRight.Total = tReport.LungUpperLobeRight.Mean*tReport.LungUpperLobeRight.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungUpperLobeRight.Mean  = mean(voiData, 'all');
                    tReport.LungUpperLobeRight.Total = tReport.LungUpperLobeRight.Mean*tReport.LungUpperLobeRight.Volume;
                end
            else
                tReport.LungUpperLobeRight.Mean  = mean(voiData, 'all');             
                tReport.LungUpperLobeRight.Total = tReport.LungUpperLobeRight.Mean*tReport.LungUpperLobeRight.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungUpperLobeRight.Cells  = [];
            tReport.LungUpperLobeRight.Volume = [];
            tReport.LungUpperLobeRight.Mean   = [];            
            tReport.LungUpperLobeRight.Total  = [];            
        end

        % Compute Lung middle Lobe right segmentation
        
        progressBar( 7/10, 'Computing lung middle lobe left segmentation, please wait' );
       
        if numel(tReport.LungMiddleLobeRight.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungMiddleLobeRight.RoisTag));
            voiData = cell(1, numel(tReport.LungMiddleLobeRight.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));
           
            for uu=1:numel(tReport.LungMiddleLobeRight.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungMiddleLobeRight.RoisTag{uu}]} );                
                
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
            
            tReport.LungMiddleLobeRight.Cells  = dNbCells;
            tReport.LungMiddleLobeRight.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.LungMiddleLobeRight.Mask = aMask;

                lungLobesMasks('set', 'lungMiddleLobeRight', aMask);
                clear aMask;
            else
                tReport.LungMiddleLobeRight.Mask = lungLobesMasks('get', 'lungMiddleLobeRight');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungMiddleLobeRight.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungMiddleLobeRight.Total = tReport.LungMiddleLobeRight.Mean*tReport.LungMiddleLobeRight.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungMiddleLobeRight.Mean  = mean(voiData, 'all');
                    tReport.LungMiddleLobeRight.Total = tReport.LungMiddleLobeRight.Mean*tReport.LungMiddleLobeRight.Volume;
                end
            else
                tReport.LungMiddleLobeRight.Mean  = mean(voiData, 'all');             
                tReport.LungMiddleLobeRight.Total = tReport.LungMiddleLobeRight.Mean*tReport.LungMiddleLobeRight.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungMiddleLobeRight.Cells  = [];
            tReport.LungMiddleLobeRight.Volume = [];
            tReport.LungMiddleLobeRight.Mean   = [];            
            tReport.LungMiddleLobeRight.Total  = [];            
        end

        % Compute Lung Lower Lobe right segmentation
        
        progressBar( 8/10, 'Computing Lower lobe left segmentation, please wait' );
       
        if numel(tReport.LungLowerLobeRight.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.LungLowerLobeRight.RoisTag));
            voiData = cell(1, numel(tReport.LungLowerLobeRight.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));

            for uu=1:numel(tReport.LungLowerLobeRight.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.LungLowerLobeRight.RoisTag{uu}]} );                
                
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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
            
            tReport.LungLowerLobeRight.Cells  = dNbCells;
            tReport.LungLowerLobeRight.Volume = dNbCells*dVoxVolume;

            if bUpdateMasks == true
                tReport.LungLowerLobeRight.Mask = aMask;

                lungLobesMasks('set', 'LungLowerLobeRight', aMask);
                clear aMask;
            else
                tReport.LungLowerLobeRight.Mask = lungLobesMasks('get', 'lungLowerLobeRight');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.LungLowerLobeRight.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.LungLowerLobeRight.Total = tReport.LungLowerLobeRight.Mean*tReport.LungLowerLobeRight.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.LungLowerLobeRight.Mean  = mean(voiData, 'all');
                    tReport.LungLowerLobeRight.Total = tReport.LungLowerLobeRight.Mean*tReport.LungLowerLobeRight.Volume;
                end
            else
                tReport.LungLowerLobeRight.Mean  = mean(voiData, 'all');             
                tReport.LungLowerLobeRight.Total = tReport.LungLowerLobeRight.Mean*tReport.LungLowerLobeRight.Volume;             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LungLowerLobeRight.Cells  = [];
            tReport.LungLowerLobeRight.Volume = [];
            tReport.LungLowerLobeRight.Mean   = [];            
            tReport.LungLowerLobeRight.Total  = [];            
        end

        progressBar( 9/10, 'Computing Liver segmentation, please wait' );
       
        if numel(tReport.LungLowerLobeRight.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Liver.RoisTag));
            voiData = cell(1, numel(tReport.Liver.RoisTag));
            
            dNbCells = 0;

            aMask = zeros(size(aImage));

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
                            aMask(:,:) = voiMask{uu}|aMask(:,:);   
                        end

                    case 'axes1'
                        aSlice = permute(aImage(tRoi.SliceNb,:,:), [3 2 1]);
                        voiData{uu} = aSlice;
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(tRoi.SliceNb,:,:) = voiMask{uu}|aMask(tRoi.SliceNb,:,:);   
                        end                        
                        
                    case 'axes2'
                        aSlice = permute(aImage(:,tRoi.SliceNb,:), [3 1 2]);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,tRoi.SliceNb,:) = voiMask{uu}|aMask(:,tRoi.SliceNb,:);   
                        end

                   case 'axes3'
                        aSlice = aImage(:,:,tRoi.SliceNb);
                        voiData{uu} = aSlice;                        
                        voiMask{uu} = roiTemplateToMask(tRoi, aSlice);

                        if bUpdateMasks == true
                            aMask(:,:,tRoi.SliceNb) = voiMask{uu}|aMask(:,:,tRoi.SliceNb);  
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
                tReport.Liver.Mask = aMask;

                lungLobesMasks('set', 'Liver', aMask);
                clear aMask;
            else
                tReport.Liver.Mask = lungLobesMasks('get', 'Liver');                
            end

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Liver.Mean  = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume*tQuantification.tSUV.dScale;             
                else
                    tReport.Liver.Mean  = mean(voiData, 'all');
                    tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume;
                end
            else
                tReport.Liver.Mean  = mean(voiData, 'all');             
                tReport.Liver.Total = tReport.Liver.Mean*tReport.Liver.Volume;             
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

    function exportCurrentLobeLungReportToPdfCallback(~, ~)
        
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
            
%        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        % Series Date 
        
        sSeriesDate = atMetaData{1}.SeriesDate;
        
        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save 3D SPECT lung lobe report', sprintf('%s/%s_%s_%s_%s_LUNG_LOBE_REPORT_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        set(fig3DLobeLungReport, 'Pointer', 'watch');
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
                
            set(axe3DLobeLungReport,'LooseInset', get(axe3DLobeLungReport,'TightInset'));
            set(fig3DLobeLungReport,'Units','inches');
            pos = get(fig3DLobeLungReport,'Position');

            set(fig3DLobeLungReport,'PaperPositionMode','auto',...
                'PaperUnits','inches',...
                'PaperPosition',[0,0,pos(3),pos(4)],...
                'PaperSize',[pos(3), pos(4)])

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            print(fig3DLobeLungReport, sFileName, '-image', '-dpdf', '-r0');

            try
                open(sFileName);
            catch
            end
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentLobeLungReportToPdfCallback() cant export report' );
        end

        set(fig3DLobeLungReport, 'Pointer', 'default');
        drawnow;        
    end
    
    function copyLobeLungReportDisplayCallback(~, ~)

        try

            set(fig3DLobeLungReport, 'Pointer', 'watch');

            inv = get(fig3DLobeLungReport,'InvertHardCopy');

            set(fig3DLobeLungReport,'InvertHardCopy','Off');

            drawnow;
            hgexport(fig3DLobeLungReport,'-clipboard');

            set(fig3DLobeLungReport,'InvertHardCopy',inv);
        catch
            progressBar( 1 , 'Error: copyLobeLungReportDisplayCallback() cant copy report' );
        end

        set(fig3DLobeLungReport, 'Pointer', 'default');
    end

    function display3DLobeLung()

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
            progressBar(1, 'Error: display3DLobeLung() require a CT and NM image!');
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

        % MIP display image 

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

            aMask = smooth3(aMask, 'box', 3);

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

    function slider3DLungLobesintensityCallback(~, ~)

        dSliderValue = get(uiSlider3Dintensity, 'Value');

        aAlphamap = linspace(0, dSliderValue, 256)';

        for jj=1:numel(gasMask)
            set(gp3DObject{jj}, 'Alphamap', aAlphamap);
        end

    end

    function ui3DLobeLungReportSliderCallback(~, ~)

        val = get(ui3DLobeLungReportSlider, 'Value');
    
        aPosition = get(ui3DLobeLungReport, 'Position');
    
        dPanelOffset = -((1-val) * aPosition(4));
    
        set(ui3DLobeLungReport, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end

    function sliderScrollableContoursInformationCallback(~, ~)

        val = get(ui3DLobeScrollableContoursInformation, 'Value');
    
        aPosition = get(ui3DLobeScrollableContoursInformationReport, 'Position');
    
        dPanelOffset = -((1-val) * aPosition(4));
    
        set(ui3DLobeScrollableContoursInformationReport, ...
            'Position', [aPosition(1) ...
                         gaContourInformationScrollableUiPosition(2)-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );        
    end
end