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

    gasOrganList={'Liver'};


    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end
    
    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 880;

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
    addlistener(uiPETLiverDosimetryReportSlider, 'Value', 'PreSet', @uiPETLiverDosimetryReportSliderCallback);

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
                  'position', [0 FIG_REPORT_Y-100 FIG_REPORT_X/3-50 20]...
                  ); 
              
        uicontrol(uiPETLiverDosimetryReport,...
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
              
         uicontrol(uiPETLiverDosimetryReport,...
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
              
        uicontrol(uiPETLiverDosimetryReport,...
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-100 FIG_REPORT_X/3+100 20]...
                  ); 
              
         % Contour Type
              
          uicontrol(uiPETLiverDosimetryReport,...
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
              
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-90 FIG_REPORT_Y-460 115 320]...
                  );  
              
         % Nb Contour
              
          uicontrol(uiPETLiverDosimetryReport,...
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

        uiReportLesionNbPETLiverDosimetry = ...       
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionNbContoursInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+15 FIG_REPORT_Y-460 90 320]...
                  );  
              
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionMean = ...       
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+115 FIG_REPORT_Y-460 90 320]...
                  );  
              
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionMax = ...       
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+215 FIG_REPORT_Y-460 90 320]...
                  ); 
              
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
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-130 90 20]...
                  ); 
              
        uiReportLesionVolume = ...       
        uicontrol(uiPETLiverDosimetryReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getPETLiverDosimetryReportLesionVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+315 FIG_REPORT_Y-460 90 320]...
                  );               

        % Volume Histogram
            
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
         
    axeReport.Title.String  = 'Dose Volume Histogram (UVH)';
    axeReport.XLabel.String = 'Uptake';
    axeReport.YLabel.String = 'Liver Volume Fraction';

    % 3D Volume  

     atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    ui3DWindow = ...
    uipanel(uiPETLiverDosimetryReport,...
            'Units'   , 'pixels',...
            'BorderWidth', showBorder('get'),...
            'HighlightColor', [0 1 1],...
            'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
            'position', [5 15 FIG_REPORT_X/3-75 340]...
            );           
     

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
              'FontSize'  , 10,...
              'FontName'  , 'MS Sans Serif', ...
              'horizontalalignment', 'left',...
              'BackgroundColor', 'White', ...
              'ForegroundColor', 'Black', ...              
              'position', [FIG_REPORT_X/3-50 15 FIG_REPORT_X/3-75 225]...
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
    uimenu(mReportFile,'Label', 'Export to .pdf...','Callback', @exportCurrentPETLiverDosimetryReportToPdfCallback);
    uimenu(mReportFile,'Label', 'Export to DICOM print...','Callback', @exportCurrentPETLiverDosimetryReportToDicomCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(figPETLiverDosimetryReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyPETLiverDosimetryReportDisplayCallback);
    
    setPETLiverDosimetryReportFigureName();
    
    refreshReportLesionInformation(suvMenuUnitOption('get'), modifiedMatrixValueMenuOption('get'), modifiedMatrixValueMenuOption('get'));
    
    function refreshReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented)
      
        tReport = computePETLiverDosimetryReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented);

        if ~isempty(tReport) % Fill information

            if isvalid(uiReportPETLiverDosimetryInformation) % Make sure the figure is still open                     
                set(uiReportPETLiverDosimetryInformation, 'String', sprintf('Contour Information (%s)', getPETLiverDosimetryReportUnitValue()));                                             
            end
           
            if isvalid(uiReportLesionNbPETLiverDosimetry) % Make sure the figure is still open        
                set(uiReportLesionNbPETLiverDosimetry, 'String', getPETLiverDosimetryReportLesionNbContoursInformation('get', tReport));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getPETLiverDosimetryReportLesionMeanInformation('get', tReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getPETLiverDosimetryReportLesionMaxInformation('get', tReport));
            end    
            
            if isvalid(uiReportLesionVolume) % Make sure the figure is still open        
                set(uiReportLesionVolume, 'String', getPETLiverDosimetryReportLesionVolumeInformation('get', tReport));
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

                try
                    
                    ptrPlotCummulative = plotCummulative(axeReport, tReport.Liver.voiData, 'black');
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

                catch
                end
            end
            
        end

        if isvalid(ui3DWindow)
            display3DLiver();
        end
    end

    function txt = updateCursorCoordinates(~,info)
        
        x = info.Position(1);
        y = info.Position(2);
        txt = ['(' sprintf('%.0f', x) ', ' sprintf('%.2f', y) ')'];

        set( axeReport.XLabel, 'String', sprintf('Uptake (%s)', getPETLiverDosimetryReportUnitValue() ) );
        set( axeReport.YLabel, 'String', sprintf('Liver Volume Fraction') );

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
            sUnit =  'Dose';
        else
            sUnit =  '';
        end 
    end

    function sReport = getPETLiverDosimetryReportLesionTypeInformation()
                
%        sReport = sprintf('%s\n___________', char('Summary'));      
        sReport = ''; 
        for ll=1:numel(gasOrganList)
            sReport = sprintf('%s%s', sReport, char(gasOrganList{ll}));
        end       
    end

    function sReport = getPETLiverDosimetryReportLesionNbContoursInformation(sAction, tReport)
                              
        if strcmpi(sAction, 'init')
%            sReport = sprintf('%s\n___________', '-');      
            sReport = ''; 
            for ll=1:numel(gasOrganList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
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
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Count)
                            sReport = sprintf('%s%-12s', sReport, num2str(tReport.Liver.Count));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                       
                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end
    end

    function sReport = getPETLiverDosimetryReportLesionMeanInformation(sAction, tReport)
                        
        if strcmpi(sAction, 'init')
%            sReport = sprintf('%s\n___________', '-');      
            sReport = ''; 
            for ll=1:numel(gasOrganList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
%            if ~isempty(tReport.All.Mean)
%                sReport = sprintf('%-.2f\n___________', tReport.All.Mean);      
%            else
%                sReport = sprintf('%s\n___________', '-');      
%            end

            sReport = ''; 
                
            for ll=1:numel(gasOrganList)      
                
                switch lower(gasOrganList{ll})
                                            
                    case 'liver'
                        if ~isempty(tReport.Liver.Mean)
                            sReport = sprintf('%s%-.2f', sReport, tReport.Liver.Mean);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    otherwise                        
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end      
    end

    function sReport = getPETLiverDosimetryReportLesionMaxInformation(sAction, tReport)
                        
        if strcmpi(sAction, 'init')
          %  sReport = sprintf('%s\n___________', '-');      
           sReport = ''; 
           for ll=1:numel(gasOrganList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
%            if ~isempty(tReport.All.Max)
%                sReport = sprintf('%-.2f\n___________', tReport.All.Max);      
%            else
%                sReport = sprintf('%s\n___________', '-');      
%            end

            sReport = ''; 
               
            for ll=1:numel(gasOrganList)      
                
                switch lower(gasOrganList{ll})
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Max)
                            sReport = sprintf('%s%-.2f', sReport, tReport.Liver.Max);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end      
    end

    function sReport = getPETLiverDosimetryReportLesionVolumeInformation(sAction, tReport)
                        
        if strcmpi(sAction, 'init')
%            sReport = sprintf('%s\n___________', '-');      
            sReport = ''; 
            for ll=1:numel(gasOrganList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
%            if ~isempty(tReport.All.Volume)
%                sReport = sprintf('%-.3f\n___________', tReport.All.Volume);      
%            else
%                sReport = sprintf('%s\n___________', '-');      
%            end

            sReport = ''; 
              
            for ll=1:numel(gasOrganList)      
                
                switch lower(gasOrganList{ll}) 
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Volume)
                            sReport = sprintf('%s%-.3f', sReport, tReport.Liver.Volume);
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  

                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end         
    end

    function tReport = computePETLiverDosimetryReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented)
        
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
       
        dLiverCount  = 0;

        dNbLiverRois = 0;
        
        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
            switch lower(atVoiInput{vv}.Label)
                                    
                case 'liver'
                    dLiverCount  = dLiverCount+1;                    
                    dNbLiverRois = dNbLiverRois+dNbRois;
            end
        end
        
        % Set report type count
        
        if dLiverCount == 0
            tReport.Liver.Count = [];
        else
            tReport.Liver.Count = dLiverCount;
        end
                                    
        % Clasify ROIs by lession type      
  
        tReport.Liver.RoisTag = cell(1, dNbLiverRois);    
           
        dLiverRoisOffset = 1;
        
        for vv=1:numel(atVoiInput)
            
            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
           
            switch lower(atVoiInput{vv}.Label)
                                                      
                case 'liver'
                    dFrom = dLiverRoisOffset;
                    dTo   = dLiverRoisOffset+dNbRois-1;
                    
                    tReport.Liver.RoisTag(dFrom:dTo) = atVoiInput{vv}.RoisTag;
                    
                    dLiverRoisOffset = dLiverRoisOffset+dNbRois;               
            end
        end    
        
                        
        % Compute Liver lesion
        
        progressBar( 1/2, 'Computing liver segmentation, please wait' );
               
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
                  
        clear aImage;
        
        progressBar( 1 , 'Ready' );

    end

    function exportCurrentPETLiverDosimetryReportToPdfCallback(~, ~)
        
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
            
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        [file, path] = uiputfile(filter, 'Save PET Y90 liver dosimetry report', sprintf('%s/%s_%s_%s_%s_Y90_LIVER_REPORT_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sDate) );

        set(figPETLiverDosimetryReport, 'Pointer', 'watch');
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
                
            set(axePETLiverDosimetryReport,'LooseInset', get(axePETLiverDosimetryReport,'TightInset'));
            set(figPETLiverDosimetryReport,'Units','inches');
            pos = get(figPETLiverDosimetryReport,'Position');

            set(figPETLiverDosimetryReport,'PaperPositionMode','auto',...
                'PaperUnits','inches',...
                'PaperPosition',[0,0,pos(3),pos(4)],...
                'PaperSize',[pos(3), pos(4)])

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            print(figPETLiverDosimetryReport, sFileName, '-image', '-dpdf', '-r0');

            open(sFileName);
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentPETLiverDosimetryReportToPdfCallback() cant export report' );
        end

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
        drawnow;        
    end
    
    function copyPETLiverDosimetryReportDisplayCallback(~, ~)

        try

            set(figPETLiverDosimetryReport, 'Pointer', 'watch');

            inv = get(figPETLiverDosimetryReport,'InvertHardCopy');

            set(figPETLiverDosimetryReport,'InvertHardCopy','Off');

            drawnow;
            hgexport(figPETLiverDosimetryReport,'-clipboard');

            set(figPETLiverDosimetryReport,'InvertHardCopy',inv);
        catch
            progressBar( 1 , 'Error: copyPETLiverDosimetryReportDisplayCallback() cant copy report' );
        end

        set(figPETLiverDosimetryReport, 'Pointer', 'default');
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
        
            if verLessThan('matlab','9.13')
                pObject = volshow(squeeze(aCTBuffer),  aInputArguments{:});
            else
                pObject = images.compatibility.volshow.R2022a.volshow(squeeze(aCTBuffer), aInputArguments{:});                   
            end
        
            pObject.CameraPosition = aCameraPosition;
            pObject.CameraUpVector = aCameraUpVector;  

        end

        % Mask Isosurface 

        asMask = {'liver'};
        for jj=1:numel(asMask)
    
            [aMask, aColor] = machineLearning3DMask('get', asMask{jj});
    
            if ~isempty(aMask)
        
                aInputArguments = {'Parent', ui3DWindow, 'Renderer', 'Isosurface', 'BackgroundColor', 'white', 'ScaleFactors', aScaleFactor};
        
                aInputArguments = [aInputArguments(:)', {'Alphamap'}, {aAlphamap}, {'Colormap'}, {aColormap}];
          
                if verLessThan('matlab','9.13')
                    pObject = volshow(squeeze(aMask),  aInputArguments{:});
                else
                    pObject = images.compatibility.volshow.R2022a.volshow(squeeze(aMask), aInputArguments{:});                   
                end
    
                pObject.IsosurfaceColor = aColor;
                pObject.Isovalue = 1;
    
                pObject.CameraPosition = aCameraPosition;
                pObject.CameraUpVector = aCameraUpVector;
            end
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
end