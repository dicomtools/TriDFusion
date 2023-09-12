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
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-80 FIG_REPORT_X/3-50 20]...
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
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-570 FIG_REPORT_X/3-50 480]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-80 FIG_REPORT_X/3+100 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-110 FIG_REPORT_X/3+100 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-135 FIG_REPORT_X/3+100 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-160 FIG_REPORT_X/3+100 20]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-200 FIG_REPORT_X/3+100 20]...
                  ); 

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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-230 115 20]...
                  ); 
              
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-560 115 320]...
                  );  
              
         % Nb Contour
              
          uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Nb Contours',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-230 90 20]...
                  ); 

        uiReportLesionNbContour = ...       
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionNbContourInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-560 90 320]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-230 90 20]...
                  ); 
              
        uiReportLesionMean = ...       
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-560 90 320]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-230 90 20]...
                  ); 
              
        uiReportLesionMax = ...       
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-560 90 320]...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-230 90 20]...
                  ); 
              
        uiReportLesionVolume = ...       
        uicontrol(uiContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-560 90 320]...
                  );               

        % Volume Histogram

       [~, asLesionList, ~] = getLesionType('');
       gasLesionType = [{'All Contours'}, asLesionList(:)'];

       popReportVolumeHistogram = ...
       uicontrol(uiContourReport, ...
                 'Style'   , 'popup', ...
                 'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 280 485 20], ...
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
             'Position', [FIG_REPORT_X-(FIG_REPORT_X/3)-55 50 440 200], ...
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
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-55 250]...
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
                  'position', [FIG_REPORT_X/3-50 uiEditWindow.Position(4)+30 FIG_REPORT_X/3-75 20]...
                  );

    mReportFile = uimenu(figContourReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export to .pdf...','Callback', @exportCurrentReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export to DICOM print...','Callback', @exportCurrentReportToDicomCallback);
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
    
    mSUVUnit          = ...
        uimenu(mReportOptions, 'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @reportSUVUnitCallback);
    
    mModifiedMatrix   = ...
        uimenu(mReportOptions, 'Label', 'Display Image Cells Value' , 'Checked', sModifiedMatrixChecked, 'Callback', @reportModifiedMatrixCallback);
    
    mSegmented        = ...
        uimenu(mReportOptions, 'Label', 'Subtract Masked Cells' , 'Checked', sSegChecked, 'Callback', @reportSegmentedCallback);
    
    setReportFigureName();
    
    refreshReportLesionInformation(suvMenuUnitOption('get'), modifiedMatrixValueMenuOption('get'), modifiedMatrixValueMenuOption('get'));
  
    function refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented)
        
        set(btnContourReport3DRenderingFullScreen, 'Enable', 'off');

        set(chkContourReportViewContours, 'Enable', 'off');
        set(txtContourReportViewContours, 'Enable', 'off');

        set(chkContourReportViewFarthestDistance, 'Enable', 'off');
        set(txtContourReportViewFarthestDistance, 'Enable', 'off');

        gtReport = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented);

        if ~isempty(gtReport) % Fill information

            if isvalid(uiReportContourTitle)
                set(uiReportContourTitle, 'String', sprintf('Contours Information (%s)', getReportUnitValue()));                            
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
            sUnit =  'Dose';
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
      
        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mModifiedMatrix  , 'Checked', sModifiedMatrixChecked);
        set(mSegmented       , 'Checked', sSegChecked);

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
                
        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);
            
            refreshReportLesionInformation(false, bModifiedMatrix, bSegmented);            
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);
            
            refreshReportLesionInformation(true, bModifiedMatrix, bSegmented);            
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
        
        if strcmpi(hObject.Checked, 'on')
            
            if atInput(dSeriesOffset).tMovement.bMovementApplied == true
                modifiedMatrixValueMenuOption('set', true);                         
                hObject.Checked = 'on';
                
                refreshReportLesionInformation(bSUVUnit, true, bSegmented);           
            else
                modifiedMatrixValueMenuOption('set', false);                         
                hObject.Checked = 'off';      
                
                segMenuOption('set', false);
                set(mSegmented, 'Checked', 'off');                
                
                refreshReportLesionInformation(bSUVUnit, false, false);           
            end
        else
            modifiedMatrixValueMenuOption('set', true);                               
            hObject.Checked = 'on';
            
            refreshReportLesionInformation(bSUVUnit, true, bSegmented);
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
        
        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            segMenuOption('set', false);
            
            refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, false);
        else
            if bModifiedMatrix == true
                hObject.Checked = 'on';
                segMenuOption('set', true);
                
                refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, true);
            else
                hObject.Checked = 'off';
                segMenuOption('set', false);                
            end
       end

        setReportFigureName();
    end

    function sReport = getReportLesionTypeInformation()
                
        sReport = sprintf('%s\n___________', char('Summary'));      
      
        [~, asLesionList, ~] = getLesionType('');
        
        for ll=1:numel(asLesionList)
            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
        end       
    end

    function sReport = getReportLesionNbContourInformation(sAction, tReport)
                      
        [~, asLesionList, ~] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s\n___________', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Count)
                sReport = sprintf('%-12s\n___________', num2str(tReport.All.Count));      
            else
                sReport = sprintf('%s\n___________', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Unspecified.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Bone.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.SoftTissue.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end     
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Lung.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Liver.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Parotid.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.BloodPool.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'lymph nodes'
                        if ~isempty(tReport.LymphNodes.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.LymphNodes.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'primary disease'
                        if ~isempty(tReport.PrimaryDisease.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.PrimaryDisease.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      

                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end
    end

    function sReport = getReportLesionMeanInformation(sAction, tReport)
                
        [~, asLesionList, ~] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s\n___________', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Mean)
                sReport = sprintf('%-.2f\n___________', tReport.All.Mean);      
            else
                sReport = sprintf('%s\n___________', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Unspecified.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Bone.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.SoftTissue.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Lung.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Parotid.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.BloodPool.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'lymph nodes'
                        if ~isempty(tReport.LymphNodes.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LymphNodes.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'primary disease'
                        if ~isempty(tReport.PrimaryDisease.Mean)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.PrimaryDisease.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end                         

                    otherwise                        
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end      
    end

    function sReport = getReportLesionMaxInformation(sAction, tReport)
                
        [~, asLesionList, ~] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s\n___________', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Max)
                sReport = sprintf('%-.2f\n___________', tReport.All.Max);      
            else
                sReport = sprintf('%s\n___________', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Unspecified.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Bone.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.SoftTissue.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end    
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Lung.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Liver.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.Parotid.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.BloodPool.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'lymph nodes'
                        if ~isempty(tReport.LymphNodes.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.LymphNodes.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'primary disease'
                        if ~isempty(tReport.PrimaryDisease.Max)
                            sReport = sprintf('%s\n\n%-.2f', sReport, tReport.PrimaryDisease.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end      
    end

    function sReport = getReportLesionVolumeInformation(sAction, tReport)
                
        [~, asLesionList, ~] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s\n___________', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Volume)
                sReport = sprintf('%-.3f\n___________', tReport.All.Volume);      
            else
                sReport = sprintf('%s\n___________', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Unspecified.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Count)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Bone.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.SoftTissue.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end   
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Lung.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Liver.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.Parotid.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.BloodPool.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'lymph nodes'
                        if ~isempty(tReport.LymphNodes.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.LymphNodes.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    case 'primary disease'
                        if ~isempty(tReport.PrimaryDisease.Volume)
                            sReport = sprintf('%s\n\n%-.3f', sReport, tReport.PrimaryDisease.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 

                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end         
    end

    function tReport = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented)
        
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
        end
        
        dVoxVolume = xPixel * yPixel * zPixel;            
        
        % Count Lesion Type number of contour
       
        dUnspecifiedCount  = 0;
        dBoneCount         = 0;
        dSoftTissueCount   = 0;
        dUnknowCount       = 0;
        dLungCount         = 0;
        dLiverCount        = 0;
        dParotidCount      = 0;
        dBloodPoolCount    = 0;
        dLymphNodesCount   = 0;
        dPrimaryDiseaseCount = 0;
       
        dNbUnspecifiedRois  = 0;
        dNbBoneRois         = 0;
        dNbSoftTissueRois   = 0;
        dNbUnknowRois       = 0;
        dNbLungRois         = 0;
        dNbLiverRois        = 0;
        dNbParotidRois      = 0;
        dNbBloodPoolRois    = 0;
        dNbLymphNodesRois   = 0;
        dNbPrimaryDiseaseRois = 0;

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

        if dUnspecifiedCount+dBoneCount+dSoftTissueCount+dLungCount+dLiverCount+dParotidCount+dBloodPoolCount+dLymphNodesCount+dPrimaryDiseaseCount+dUnknowCount == 0
            tReport.All.Count = [];
        else
            tReport.All.Count = dUnspecifiedCount+dBoneCount+dSoftTissueCount+dLungCount+dLiverCount+dParotidCount+dBloodPoolCount+dLymphNodesCount+dPrimaryDiseaseCount+dUnknowCount;
        end
        
        % Clasify ROIs by lession type      

        tReport.Unspecified.RoisTag  = cell(1, dNbUnspecifiedRois);
        tReport.Bone.RoisTag         = cell(1, dNbBoneRois);
        tReport.SoftTissue.RoisTag   = cell(1, dNbSoftTissueRois);      
        tReport.Lung.RoisTag         = cell(1, dNbLungRois);
        tReport.Liver.RoisTag        = cell(1, dNbLiverRois);
        tReport.Parotid.RoisTag      = cell(1, dNbParotidRois);
        tReport.BloodPool.RoisTag    = cell(1, dNbBloodPoolRois); 
        tReport.LymphNodes.RoisTag   = cell(1, dNbLymphNodesRois); 
        tReport.PrimaryDisease.RoisTag = cell(1, dNbPrimaryDiseaseRois); 
        tReport.All.RoisTag          = cell(1, dUnspecifiedCount+dBoneCount+dSoftTissueCount+dLungCount+dLiverCount+dParotidCount+dBloodPoolCount+dLymphNodesCount+dPrimaryDiseaseCount+dUnknowCount);        
        
        dUnspecifiedRoisOffset  = 1;
        dBoneRoisOffset         = 1;
        dSoftTissueRoisOffset   = 1;    
        dLungRoisOffset         = 1;
        dLiverRoisOffset        = 1;
        dParotidRoisOffset      = 1;
        dBloodPoolRoisOffset    = 1;        
        dLymphNodesRoisOffset   = 1;        
        dPrimaryDiseaseRoisOffset = 1;        
        dAllRoisOffset          = 1;
        
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
            end
        end    
        
        
        % Compute lesion type
        
        % Compute Unspecified lesion
        
        progressBar( 1/10, 'Computing unspecified lesion, please wait');
        
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
                    tReport.Unspecified.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Unspecified.Mean = mean(voiData, 'all');
                    tReport.Unspecified.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Unspecified.Mean = mean(voiData, 'all');             
                tReport.Unspecified.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;    
        else
            tReport.Unspecified.Cells  = [];
            tReport.Unspecified.Volume = [];
            tReport.Unspecified.Mean   = [];            
            tReport.Unspecified.Max    = [];            
        end
        
        % Compute bone lesion
        
        progressBar( 2/10, 'Computing bone lesion, please wait') ;
         
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
                    tReport.Bone.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Bone.Mean = mean(voiData, 'all');
                    tReport.Bone.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Bone.Mean = mean(voiData, 'all');             
                tReport.Bone.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;  
        else
            tReport.Bone.Cells  = [];
            tReport.Bone.Volume = [];
            tReport.Bone.Mean   = [];
            tReport.Bone.Max    = [];
        end
        
        % Compute SoftTissue lesion
        
        progressBar( 3/10, 'Computing soft tissue lesion, please wait' );
       
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
                    tReport.SoftTissue.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.SoftTissue.Mean = mean(voiData, 'all');
                    tReport.SoftTissue.Max  = max (voiData, [], 'all');
                end
            else
                tReport.SoftTissue.Mean = mean(voiData, 'all');             
                tReport.SoftTissue.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.SoftTissue.Cells  = [];
            tReport.SoftTissue.Volume = [];
            tReport.SoftTissue.Mean   = [];            
            tReport.SoftTissue.Max    = [];            
        end
        
        % Compute Lung lesion
        
        progressBar( 4/10, 'Computing lung lesion, please wait' );
       
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
                    tReport.Lung.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Lung.Mean = mean(voiData, 'all');
                    tReport.Lung.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Lung.Mean = mean(voiData, 'all');             
                tReport.Lung.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.Lung.Cells  = [];
            tReport.Lung.Volume = [];
            tReport.Lung.Mean   = [];            
            tReport.Lung.Max    = [];            
        end
        
        % Compute Liver lesion
        
        progressBar( 5/10, 'Computing liver lesion, please wait' );
       
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
                    tReport.Liver.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.Liver.Mean = mean(voiData, 'all');
                    tReport.Liver.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Liver.Mean = mean(voiData, 'all');             
                tReport.Liver.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.Liver.Cells  = [];
            tReport.Liver.Volume = [];
            tReport.Liver.Mean   = [];            
            tReport.Liver.Max    = [];            
        end
        
        % Compute Parotid lesion
        
        progressBar( 6/10, 'Computing parotid lesion, please wait' );
       
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
                    tReport.Parotid.voiData = voiData *tQuantification.tSUV.dScale;                    
                else
                    tReport.Parotid.Mean = mean(voiData, 'all');
                    tReport.Parotid.Max  = max (voiData, [], 'all');
                end
            else
                tReport.Parotid.Mean = mean(voiData, 'all');             
                tReport.Parotid.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.Parotid.Cells  = [];
            tReport.Parotid.Volume = [];
            tReport.Parotid.Mean   = [];            
            tReport.Parotid.Max    = [];            
        end
        
        % Compute BloodPool lesion
        
        progressBar( 7/10, 'Computing blood pool lesion, please wait' );
       
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
                    tReport.BloodPool.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.BloodPool.Mean = mean(voiData, 'all');
                    tReport.BloodPool.Max  = max (voiData, [], 'all');
                end
            else
                tReport.BloodPool.Mean = mean(voiData, 'all');             
                tReport.BloodPool.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.BloodPool.Cells  = [];
            tReport.BloodPool.Volume = [];
            tReport.BloodPool.Mean   = [];            
            tReport.BloodPool.Max    = [];            
        end

        % Compute LymphNodes lesion
        
        progressBar( 8/10, 'Computing blood lymph nodes, please wait' );
       
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
                    tReport.LymphNodes.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.LymphNodes.Mean = mean(voiData, 'all');
                    tReport.LymphNodes.Max  = max (voiData, [], 'all');
                end
            else
                tReport.LymphNodes.Mean = mean(voiData, 'all');             
                tReport.LymphNodes.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.LymphNodes.Cells  = [];
            tReport.LymphNodes.Volume = [];
            tReport.LymphNodes.Mean   = [];            
            tReport.LymphNodes.Max    = [];            
        end

        % Compute PrimaryDisease lesion
        
        progressBar( 9/10, 'Computing blood primary disease, please wait' );
       
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
                    tReport.PrimaryDisease.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.PrimaryDisease.Mean = mean(voiData, 'all');
                    tReport.PrimaryDisease.Max  = max (voiData, [], 'all');
                end
            else
                tReport.PrimaryDisease.Mean = mean(voiData, 'all');             
                tReport.PrimaryDisease.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;     
        else
            tReport.PrimaryDisease.Cells  = [];
            tReport.PrimaryDisease.Volume = [];
            tReport.PrimaryDisease.Mean   = [];            
            tReport.PrimaryDisease.Max    = [];            
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
                    tReport.All.voiData = voiData *tQuantification.tSUV.dScale;
                else
                    tReport.All.Mean = mean(voiData, 'all');
                    tReport.All.Max  = max (voiData, [], 'all');
                end
            else
                tReport.All.Mean = mean(voiData, 'all');             
                tReport.All.Max  = max (voiData, [], 'all');             
            end
         
            clear voiMask;
            clear voiData;
        else
            tReport.All.Cells  = [];
            tReport.All.Volume = [];
            tReport.All.Mean   = [];               
            tReport.All.Max    = [];               
        end

        if ~isempty(glVoiAllContoursMask)
            [gdFarthestDistance, gadFarthestXYZ1, gadFarthestXYZ2] = computeMaskFarthestPoint(glVoiAllContoursMask(:,:,end:-1:1), atMetaData);     
        end

        clear aImage;
        
        progressBar( 1 , 'Ready' );
       
    end

    function exportCurrentReportToPdfCallback(~, ~)
        
        atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));
       
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
            
            try
                open(sFileName);
            catch
            end
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentReportToPdfCallback() cant export report' );
        end

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

        if bModifiedMatrix == false && ... 
           bMovementApplied == false        % Can't use input buffer if movement have been applied
        
            atMetaData  = atInput(dSeriesOffset).atDicomInfo;
            aBuffer      = inputBuffer('get');

            aBuffer = aBuffer{dSeriesOffset};

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
                    gp3DLine = images.compatibility.volshow.R2022a.volshow(squeeze(aTest), aInputArguments{:});                   
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

end