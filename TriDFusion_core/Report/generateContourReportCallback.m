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

    atInput = inputTemplate('get');

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(atInput)
        return;
    end
    
    FIG_REPORT_X = 1245;
    FIG_REPORT_Y = 660;

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
         
        uicontrol(figContourReport,...
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
              
        uicontrol(figContourReport,...
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
         
         uicontrol(figContourReport,...
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
              
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportPatientInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [0 FIG_REPORT_Y-640 FIG_REPORT_X/3-50 530]...
                  );    
              
         % Series Information     
              
         uicontrol(figContourReport,...
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
              
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportSeriesInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X/3-50 FIG_REPORT_Y-640 FIG_REPORT_X/3-50 530]...
                  );    
              
         % Contour Information              
         
         uiReportContourInformation = ...       
         uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 11,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Contour Information',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-100 FIG_REPORT_Y-100 FIG_REPORT_X/3+100 20]...
                  ); 
              
         % Contour Type
              
          uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Lesion Type',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-100 FIG_REPORT_Y-130 125 20]...
                  ); 
              
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionTypeInformation(),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)-100 FIG_REPORT_Y-560 125 420]...
                  );  
              
         % Nb Contour
              
          uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Nb Contours',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+25 FIG_REPORT_Y-130 100 20]...
                  ); 

        uiReportLesionNbContour = ...       
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionNbContourInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+25 FIG_REPORT_Y-560 100 420]...
                  );  
              
         % Contour Mean
              
          uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Mean',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+125 FIG_REPORT_Y-130 100 20]...
                  ); 
              
        uiReportLesionMean = ...       
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+125 FIG_REPORT_Y-560 100 420]...
                  );  
              
         % Contour Max
              
          uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Max',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+225 FIG_REPORT_Y-130 100 20]...
                  ); 
              
        uiReportLesionMax = ...       
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionMeanInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+225 FIG_REPORT_Y-560 100 420]...
                  ); 
              
          % Contour Volume
              
          uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'Volume (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+325 FIG_REPORT_Y-130 100 20]...
                  ); 
              
        uiReportLesionVolume = ...       
        uicontrol(figContourReport,...
                  'style'     , 'text',...
                  'FontWeight', 'Normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , getReportLesionVolumeInformation('init'),...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', 'White', ...
                  'ForegroundColor', 'Black', ...
                  'position', [FIG_REPORT_X-(FIG_REPORT_X/3)+325 FIG_REPORT_Y-560 100 420]...
                  );               
         
    mReportFile = uimenu(figContourReport,'Label','File');
    uimenu(mReportFile,'Label', 'Export to .pdf...','Callback', @exportCurrentReportCallback);
    uimenu(mReportFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mReportEdit = uimenu(figContourReport,'Label','Edit');
    uimenu(mReportEdit,'Label', 'Copy Display', 'Callback', @copyReportDisplayCallback);

    mReportOptions = uimenu(figContourReport,'Label','Options', 'Callback', @figReportRefreshOption);    
    
    if suvMenuUnitOption('get') == true && ...
       atInput(dOffset).bDoseKernel == false    
        sSuvChecked = 'on';
    else
        if suvMenuUnitOption('get') == true
            suvMenuUnitOption('set', false);
        end
        sSuvChecked = 'off';
    end
           
    if modifiedMatrixValueMenuOption('get') == true 
       sModifiedMatrixChecked = 'on';
    else
        if atInput(dOffset).tMovement.bMovementApplied == true
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
    
    if atInput(dOffset).bDoseKernel == true
        sSuvEnable = 'off';
    else
        sSuvEnable = 'on';
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
      
        tReport = computeReportLesionInformation(bSUVUnit, bModifiedMatrix, bSegmented);

        if ~isempty(tReport) % Fill information

            if isvalid(uiReportContourInformation) % Make sure the figure is still open     
                
                 if contains(getReportUnitValue(), 'SUV')
                     set(uiReportContourInformation, 'String', sprintf('MTV: %s (ml), TLG: %s (%s)', ...
                         num2str(tReport.All.Volume), num2str(tReport.All.Volume*tReport.All.Mean), getReportUnitValue() ) );               
                 else
                    set(uiReportContourInformation, 'String', sprintf('Contour Information (%s)', getReportUnitValue()));                            
                 end
            end
           
            if isvalid(uiReportLesionNbContour) % Make sure the figure is still open        
                set(uiReportLesionNbContour, 'String', getReportLesionNbContourInformation('get', tReport));
            end

            if isvalid(uiReportLesionMean) % Make sure the figure is still open        
                set(uiReportLesionMean, 'String', getReportLesionMeanInformation('get', tReport));
            end        
            
            if isvalid(uiReportLesionMax) % Make sure the figure is still open        
                set(uiReportLesionMax, 'String', getReportLesionMaxInformation('get', tReport));
            end    
            
            if isvalid(uiReportLesionVolume) % Make sure the figure is still open        
                set(uiReportLesionVolume, 'String', getReportLesionVolumeInformation('get', tReport));
            end        
        end
    end

    function setReportFigureName()

        if ~isvalid(figContourReport)
            return;
        end        
    
        atMetaData = dicomMetaData('get');
       
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

    end
    
    function sUnit = getReportUnitValue()
        
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
        dOffset = get(uiSeriesPtr('get'), 'Value');
        
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
            
            if atInput(dOffset).tMovement.bMovementApplied == true
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

    function sReport = getReportPatientInformation()
        
        atMetaData = dicomMetaData('get');
        
        % Patient Name
       
        if isempty(atMetaData{1}.PatientName)
            sPatientName = '-';
        else
            sPatientName = atMetaData{1}.PatientName;
            sPatientName = strrep(sPatientName,'^',' ');
            sPatientName = strtrim(sPatientName);            
        end
        
        % Patient ID

        if isempty(atMetaData{1}.PatientID)
            sPatientID = '-';
        else
            sPatientID = atMetaData{1}.PatientID;
            sPatientID = strtrim(sPatientID);
        end
        
        % Patient Sex
        
        if isempty(atMetaData{1}.PatientSex)
            sPatientSex = '-';
        else
            sPatientSex = atMetaData{1}.PatientSex;
            if strcmpi(sPatientSex, 'M')
                sPatientSex = 'Male';
            elseif strcmpi(sPatientSex, 'F')
                 sPatientSex = 'Female';
           elseif strcmpi(sPatientSex, 'O')
                  sPatientSex = 'Other';
           end
                
        end       
        
        % Patient Age
       
        if isempty(atMetaData{1}.PatientAge)
            sPatientAge = '-';
        else
            sPatientAge = atMetaData{1}.PatientAge;
        end
        
        % Patient Birth Date
        
        if isempty(atMetaData{1}.PatientBirthDate)
            sPatientBirthDate = '-';
        else
            if numel(atMetaData{1}.PatientBirthDate) == 8
                sPatientBirthDate = char(datetime(atMetaData{1}.PatientBirthDate,'InputFormat','yyyyMMdd'));
            else
                sPatientBirthDate = atMetaData{1}.PatientBirthDate;
            end
        end
        
        sReport = sprintf(' Patient name:\n %s'     , char(sPatientName));      
        sReport = sprintf('%s\n\n Patient ID:\n %s' , sReport, char(sPatientID));
        sReport = sprintf('%s\n\n Gender:\n %s'     , sReport, char(sPatientSex));
        sReport = sprintf('%s\n\n Age:\n %s'        , sReport, char(sPatientAge));
        sReport = sprintf('%s\n\n Birth date:\n %s' , sReport, char(sPatientBirthDate));
        
        % Patient Birth Weight
        
        if isempty(atMetaData{1}.PatientWeight)
            sReport = sprintf('%s\n\n Weight:\n -', sReport);
        else
            sPatientWeight = atMetaData{1}.PatientWeight; % In float 
            sPatientWeightLbs = num2str(sPatientWeight * 2.20462262185);
            
            sPatientWeight = num2str(sPatientWeight); % In string
            
            sReport = sprintf('%s\n\n Weight:\n %s Kg -- %s lbs', sReport, char(sPatientWeight), sPatientWeightLbs);
        end
        
        % Patient Birth Size
       
        if isempty(atMetaData{1}.PatientSize)
            sReport = sprintf('%s\n\n Height:\n -' , sReport);
        else
            sPatientSize = atMetaData{1}.PatientSize; % In float 
            sPatientSizeFeet =  num2str(atMetaData{1}.PatientSize * 3.28084);
            
            sPatientSize = num2str(sPatientSize); % In string
            
            sReport = sprintf('%s\n\n Height:\n %s m -- %s foot' , sReport, char(sPatientSize), char(sPatientSizeFeet));
        end       
          
    end

    function sReport = getReportSeriesInformation()
        
        atMetaData = dicomMetaData('get');
                
        if isempty(atMetaData{1}.SeriesDescription)
            sSeriesDescription = '-';
        else
            sSeriesDescription = atMetaData{1}.SeriesDescription;
        end
        
        % Series Date Time
        
        sSeriesTime = atMetaData{1}.SeriesTime;
        sSeriesDate = atMetaData{1}.SeriesDate;
        
        if isempty(sSeriesTime)
            sSeriesDateTime = '-';
        else
            if numel(sSeriesTime) == 6
                sSeriesTime = sprintf('%s.00', sSeriesTime);
            end

            sSeriesDateTime = datetime([sSeriesDate sSeriesTime],'InputFormat','yyyyMMddHHmmss.SS');
        end
        
        % Acquisition Date Time
                
        sAcquisitionTime = atMetaData{1}.AcquisitionTime;
        aAcquisitionDate = atMetaData{1}.AcquisitionDate;
        
        if isempty(sAcquisitionTime)
            sAcquisitionDateTime = '-';
        else
            if numel(sAcquisitionTime) == 6
                sAcquisitionTime = sprintf('%s.00', sAcquisitionTime);
            end

            sAcquisitionDateTime = datetime([aAcquisitionDate sAcquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
        end
        
        sReport = sprintf('Series description:\n%s'         , char(sSeriesDescription));      
        sReport = sprintf('%s\n\nSeries date time:\n%s'     , sReport, char(sSeriesDateTime));
        sReport = sprintf('%s\n\nAcquisition date Time:\n%s', sReport, char(sAcquisitionDateTime));        
             
        if isfield(atMetaData{1}, 'RadiopharmaceuticalInformationSequence') 

            if ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
                 ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) ) || ...
               ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
                 ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime) )      
             
                 % Radiopharmaceutical Date Time

                if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) 
                    sInjDateTime = sprintf('%s%s', atMetaData{1}.StudyDate, atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
                else
                    sInjDateTime = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;      
                end
                
                if isempty(sInjDateTime)
                    sInjDateTime = '-';
                else
                    if numel(sInjDateTime) == 14
                        sInjDateTime = sprintf('%s.00', sInjDateTime);
                    end

                    sInjDateTime = datetime(sInjDateTime,'InputFormat','yyyyMMddHHmmss.SS');
                end
                
                % Radionuclide Total Dose
                
                if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose)
                    sInjDose = '-';
                    sInjDoseMCi = '-';
                else
                    sInjDose = str2double(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose);
                    sInjDoseMCi = sInjDose / 3.7E7;
                    
                    sInjDose = num2str(sInjDose/1000000); % Convert to MBq
                    
                    sInjDoseMCi = num2str(sInjDoseMCi);
                end
                
                % Radiopharmaceutical 
                
                if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical)
                    sRadiopharmaceutical = '-';
                else
                    sRadiopharmaceutical = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
                    sRadiopharmaceutical = strrep(sRadiopharmaceutical,'^',' ');
                    sRadiopharmaceutical = strtrim(sRadiopharmaceutical);
                end   
                
                % Radiopharmaceutical 
                
                if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning)
                    sRadionuclide = '-';
                else
                    sRadionuclide = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning;
                    sRadionuclide = strrep(sRadionuclide,'^',' ');
                    sRadionuclide = strtrim(sRadionuclide);
                end   
                
                % Radionuclide Half Life
                
                if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife)
                    sHalfLife = '-';
                else
                    sHalfLife = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
                end                
                 
                
                % Decay Correction
                
                sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));
                if strcmpi(sUnitDisplay, 'SUV')
            
                    if isempty(atMetaData{1}.DecayCorrection)
                        sDecayCorrection = '-';
                        sDecayTime = '';
                    else
                        switch lower(atMetaData{1}.DecayCorrection)

                            case 'start'

                            daySeriesDate = datenum(sSeriesDateTime);
                            dateInjDate   = datenum(sInjDateTime);

                            relT = seconds((daySeriesDate - dateInjDate)*(24*60*60)); 
                            relT.Format = 'dd:hh:mm:ss';
                            sDecayTime = char(relT);

                            sDecayCorrection = 'Scan start time';

                            case 'admin'

                            dateInjDate = datenum(sInjDateTime);

                            relT = seconds((dateInjDate - dateInjDate)*(24*60*60)); 
                            relT.Format = 'dd:hh:mm:ss';
                            sDecayTime = char(relT);

                            sDecayCorrection = 'Administration time';

                            case 'none'

                            dayAcquisitionDate = datenum(sAcquisitionDateTime);
                            dateInjDate        = datenum(sInjDateTime);

                            relT = seconds((dayAcquisitionDate - dateInjDate)*(24*60*60)); 
                            relT.Format = 'dd:hh:mm:ss';
                            sDecayTime = char(relT);

                            sDecayCorrection = 'No decay correction';

                            otherwise
                                sDecayCorrection = '-';
                                sDecayTime = '';
                        end                    
                    end                   
                
                    tQuantification = quantificationTemplate('get');
                    sTotal = num2str(tQuantification.tSUV.dTot/10000000); % In MBq
                    sDmCi  = num2str(tQuantification.tSUV.dmCi);
                    
                    sReport = sprintf('%s\n\nInjection date time:\n%s'       , sReport, char(sInjDateTime));
                    sReport = sprintf('%s\n\nRadiopharmaceutical:\n%s'       , sReport, char(sRadiopharmaceutical));
                    sReport = sprintf('%s\n\nRadionuclide:\n%s'              , sReport, char(sRadionuclide));
                    sReport = sprintf('%s\n\nHalf life:\n%s sec'             , sReport, char(sHalfLife));
                    sReport = sprintf('%s\n\nSUV additional decay-correction:\n%s -- %s', sReport, char(sDecayCorrection), char(sDecayTime));
                    sReport = sprintf('%s\n\nAdministrated activity:\n%s MBq -- %s mCi'   , sReport, char(sInjDose), char(sInjDoseMCi));
                    sReport = sprintf('%s\n\nTotal calculated activity:\n%s MBq -- %s mCi', sReport, char(sTotal), char(sDmCi));
                
                else
                    sReport = sprintf('%s\n\nInjection date time:\n%s'       , sReport, char(sInjDateTime));
                    sReport = sprintf('%s\n\nRadiopharmaceutical:\n%s'       , sReport, char(sRadiopharmaceutical));
                    sReport = sprintf('%s\n\nRadionuclide:\n%s'              , sReport, char(sRadionuclide));
                    sReport = sprintf('%s\n\nHalf life:\n%s sec'             , sReport, char(sHalfLife));
                    sReport = sprintf('%s\n\nAdministrated activity:\n%s MBq -- %s mCi'   , sReport, char(sInjDose), char(sInjDoseMCi));
                end
                                               
            end
        end                  
    end    

    function sReport = getReportLesionTypeInformation()
                
        sReport = sprintf('%s', char('All Contours'));      
      
        [~, asLesionList] = getLesionType('');
        
        for ll=1:numel(asLesionList)
            sReport = sprintf('%s\n\n%s', sReport, char(asLesionList{ll}));
        end       
    end

    function sReport = getReportLesionNbContourInformation(sAction, tReport)
                      
        [~, asLesionList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Count)
                sReport = sprintf('%-12s', num2str(tReport.All.Count));      
            else
                sReport = sprintf('%s', '-');      
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
                        
                    otherwise    
                        sReport = sprintf('%s\n\n%s', sReport, '-');
                end
            end             
        end
    end

    function sReport = getReportLesionMeanInformation(sAction, tReport)
                
        [~, asLesionList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Mean)
                sReport = sprintf('%-12s', num2str(tReport.All.Mean));      
            else
                sReport = sprintf('%s', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Unspecified.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Bone.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.SoftTissue.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Lung.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Liver.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Parotid.Mean));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Mean)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.BloodPool.Mean));
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
                
        [~, asLesionList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Max)
                sReport = sprintf('%-12s', num2str(tReport.All.Max));      
            else
                sReport = sprintf('%s', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Unspecified.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Bone.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.SoftTissue.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end    
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Lung.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Liver.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Parotid.Max));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Max)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.BloodPool.Max));
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
                
        [~, asLesionList] = getLesionType('');
        
        if strcmpi(sAction, 'init')
            sReport = sprintf('%s', '-');      
            for ll=1:numel(asLesionList)
                sReport = sprintf('%s\n\n%s', sReport, '-');
            end       
        else
            
            if ~isempty(tReport.All.Volume)
                sReport = sprintf('%-12s', num2str(tReport.All.Volume));      
            else
                sReport = sprintf('%s', '-');      
            end
                
            for ll=1:numel(asLesionList)      
                
                switch lower(asLesionList{ll})
                    
                    case 'unspecified'
                        if ~isempty(tReport.Unspecified.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Unspecified.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end      
                        
                    case 'bone'
                        if ~isempty(tReport.Bone.Count)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Bone.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end          
                        
                    case 'soft tissue'
                        if ~isempty(tReport.SoftTissue.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.SoftTissue.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end   
                        
                    case 'lung'
                        if ~isempty(tReport.Lung.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Lung.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'liver'
                        if ~isempty(tReport.Liver.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Liver.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end  
                        
                    case 'parotid'
                        if ~isempty(tReport.Parotid.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.Parotid.Volume));
                        else
                            sReport = sprintf('%s\n\n%s', sReport, '-');
                        end 
                        
                    case 'blood pool'
                        if ~isempty(tReport.BloodPool.Volume)
                            sReport = sprintf('%s\n\n%-12s', sReport, num2str(tReport.BloodPool.Volume));
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
            
            if     strcmpi(imageOrientation('get'), 'axial')
                aImage = permute(aImage{dOffset}, [1 2 3]);
            elseif strcmpi(imageOrientation('get'), 'coronal')
                aImage = permute(aImage{dOffset}, [3 2 1]);
            elseif strcmpi(imageOrientation('get'), 'sagittal')
                aImage = permute(aImage{dOffset}, [3 1 2]);
            end

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
        
        % Count Lesion Type number of contour
       
        dUnspecifiedCount  = 0;
        dBoneCount         = 0;
        dSoftTissueCount   = 0;
        dUnknowCount       = 0;
        dLungCount         = 0;
        dLiverCount        = 0;
        dParotidCount      = 0;
        dBloodPoolCount    = 0;
        
        dNbUnspecifiedRois = 0;
        dNbBoneRois        = 0;
        dNbSoftTissueRois  = 0;
        dNbUnknowRois      = 0;
        dNbLungRois        = 0;
        dNbLiverRois       = 0;
        dNbParotidRois     = 0;
        dNbBloodPoolRois   = 0;
        
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
                
        if dUnspecifiedCount+dBoneCount+dSoftTissueCount+dUnknowCount == 0
            tReport.All.Count = [];
        else
            tReport.All.Count = dUnspecifiedCount+dBoneCount+dSoftTissueCount+dLungCount+dLiverCount+dParotidCount+dBloodPoolCount+dUnknowCount;
        end
        
        % Clasify ROIs by lession type      

        tReport.Unspecified.RoisTag = cell(1, dNbUnspecifiedRois);
        tReport.Bone.RoisTag        = cell(1, dNbBoneRois);
        tReport.SoftTissue.RoisTag  = cell(1, dNbSoftTissueRois);      
        tReport.Lung.RoisTag        = cell(1, dNbLungRois);
        tReport.Liver.RoisTag       = cell(1, dNbLiverRois);
        tReport.Parotid.RoisTag     = cell(1, dNbParotidRois);
        tReport.BloodPool.RoisTag   = cell(1, dNbBloodPoolRois); 
        tReport.All.RoisTag         = cell(1, dUnspecifiedCount+dBoneCount+dSoftTissueCount+dLungCount+dLiverCount+dParotidCount+dBloodPoolCount+dUnknowCount);        
        
        dUnspecifiedRoisOffset = 1;
        dBoneRoisOffset = 1;
        dSoftTissueRoisOffset = 1;    
        dLungRoisOffset = 1;
        dLiverRoisOffset = 1;
        dParotidRoisOffset = 1;
        dBloodPoolRoisOffset = 1;        
        dAllRoisOffset = 1;
        
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
            end
        end    
        
        
        % Compute lesion type
        
        % Compute Unspecified lesion
        
        progressBar( 1/8, 'Computing unspecified lesion, please wait');
        
        if numel(tReport.Unspecified.RoisTag) ~= 0
            
            voiMask = cell(1, numel(tReport.Unspecified.RoisTag));
            voiData = cell(1, numel(tReport.Unspecified.RoisTag));
            
            dNbCells = 0;

            for uu=1:numel(tReport.Unspecified.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Unspecified.RoisTag{uu}]} );
                
                tRoi = atRoiInput{find(aTagOffset, 1)};                
                
                if bModifiedMatrix == false && ... 
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Unspecified.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Unspecified.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        progressBar( 2/8, 'Computing bone lesion, please wait') ;
         
        if numel(tReport.Bone.RoisTag) ~= 0
            
            voiMask = cell(1, numel(tReport.Bone.RoisTag));
            voiData = cell(1, numel(tReport.Bone.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Bone.RoisTag)
                
                aTagOffset  = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Bone.RoisTag{uu}]} );
                
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Bone.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Bone.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        progressBar( 3/8, 'Computing soft tissue lesion, please wait' );
       
        if numel(tReport.SoftTissue.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.SoftTissue.RoisTag));
            voiData = cell(1, numel(tReport.SoftTissue.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.SoftTissue.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.SoftTissue.RoisTag{uu}]} );                
                
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.SoftTissue.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.SoftTissue.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        progressBar( 4/8, 'Computing lung lesion, please wait' );
       
        if numel(tReport.Lung.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Lung.RoisTag));
            voiData = cell(1, numel(tReport.Lung.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Lung.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Lung.RoisTag{uu}]} );                
                
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Lung.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Lung.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        progressBar( 5/8, 'Computing liver lesion, please wait' );
       
        if numel(tReport.Liver.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Liver.RoisTag));
            voiData = cell(1, numel(tReport.Liver.RoisTag));
            
            dNbCells = 0;
            
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
        
        % Compute Parotid lesion
        
        progressBar( 6/8, 'Computing parotid lesion, please wait' );
       
        if numel(tReport.Parotid.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.Parotid.RoisTag));
            voiData = cell(1, numel(tReport.Parotid.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.Parotid.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.Parotid.RoisTag{uu}]} );                
                
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.Parotid.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.Parotid.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        progressBar( 7/8, 'Computing blood pool lesion, please wait' );
       
        if numel(tReport.BloodPool.RoisTag) ~= 0  
        
            voiMask = cell(1, numel(tReport.BloodPool.RoisTag));
            voiData = cell(1, numel(tReport.BloodPool.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.BloodPool.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.BloodPool.RoisTag{uu}]} );                
                
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
            
            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.BloodPool.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.BloodPool.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        % Compute All lesion
        
        progressBar( 0.99999 , 'Computing all lesion, please wait' );
        
        if numel(tReport.All.RoisTag) ~= 0
            
            voiMask = cell(1, numel(tReport.All.RoisTag));
            voiData = cell(1, numel(tReport.All.RoisTag));
            
            dNbCells = 0;
            
            for uu=1:numel(tReport.All.RoisTag)

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[tReport.All.RoisTag{uu}]} );
                
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
    
            tReport.All.Cells  = dNbCells;
            tReport.All.Volume = dNbCells*dVoxVolume;

            if strcmpi(sUnitDisplay, 'SUV')
                
                if bSUVUnit == true
                    tReport.All.Mean = mean(voiData, 'all')*tQuantification.tSUV.dScale;             
                    tReport.All.Max  = max (voiData, [], 'all')*tQuantification.tSUV.dScale;             
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
        
        clear aImage;
        
        progressBar( 1 , 'Ready' );
       
    end

    function exportCurrentReportCallback(~, ~)
        
        atMetaData = dicomMetaData('get');
       
        try
       
        filter = {'*.pdf'};

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastReportDir.mat'];
        
        % load last data directory
        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('saveRoiLastUsedDir', 'var')
               sCurrentDir = saveRoiLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end
            
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        [file, path] = uiputfile(filter, 'Save contour report', sprintf('%s/%s_%s_%s_%s_report_TriDFusion.pdf' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sDate) );
        
        if file ~= 0
            
            sFileName = sprintf('%s%s', path, file);
            
            if exist(sFileName, 'file')
                delete(sFileName);
            end
                
            set(axeContourReport,'LooseInset', get(axeContourReport,'TightInset'));
            set(figContourReport,'Units','inches');
            pos = get(figContourReport,'Position');

            set(figContourReport,'PaperPositionMode','auto',...
                'PaperUnits','inches',...
                'PaperPosition',[0,0,pos(3),pos(4)],...
                'PaperSize',[pos(3), pos(4)])

            if ~contains(sFileName, '.pdf')
                sFileName = [sFileName, '.pdf'];
            end

            print(figContourReport, sFileName, '-painters', '-dpdf', '-r0');

            open(sFileName);
        end
        
        catch
            progressBar( 1 , 'Error: exportCurrentReportCallback() cant export report' );
        end
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

end