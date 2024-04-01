function GenerateSystemMatrixCallback(~, ~)
%function GenerateSystemMatrixCallback(~, ~)
%Set Options Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    asSeries = get(uiSeriesPtr('get'), 'String');
    dNbSeries = numel(asSeries);

    if dNbSeries < 1
        return;
    end

    DLG_SYSTEM_MATRIX_X = 460;
    DLG_SYSTEM_MATRIX_Y = 535;

    if viewerUIFigure('get') == true

        dlgSystemMatrix = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_SYSTEM_MATRIX_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_SYSTEM_MATRIX_Y/2) ...
                                DLG_SYSTEM_MATRIX_X ...
                                DLG_SYSTEM_MATRIX_Y ...
                                ],...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'WindowStyle', 'modal', ...
                   'Name' , 'SPECT Reconstruction'...
                   );
    else    
        dlgSystemMatrix = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_SYSTEM_MATRIX_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_SYSTEM_MATRIX_Y/2) ...
                                DLG_SYSTEM_MATRIX_X ...
                                DLG_SYSTEM_MATRIX_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'SPECT Reconstruction',...
                   'Toolbar','none'...               
                   );   
    end

    axeSystemMatrix = ...       
        axes(dlgSystemMatrix, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 DLG_SYSTEM_MATRIX_X DLG_SYSTEM_MATRIX_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             ); 
    axeSystemMatrix.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeSystemMatrix.Toolbar = []; 

    % Bed 1

    if dNbSeries > 0
        sChkVolumeBed1Enable = 'on';
        bChkVolumeBed1Value  = true;
    else
        sChkVolumeBed1Enable = 'off';
        bChkVolumeBed1Value  = false;
   end

    chk3DVolumeBed1Enable = ...
        uicontrol(dlgSystemMatrix,...
                  'style'   , 'checkbox',...
                  'enable'  , sChkVolumeBed1Enable,...
                  'value'   , bChkVolumeBed1Value,...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-30 20 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chk3DVolumeBed1EnableCallback...
                  );
    
    if strcmpi(sChkVolumeBed1Enable, 'on')
        sTxtVolumeBed1Enable = 'inactive';
    else
        sTxtVolumeBed1Enable = 'on';
    end

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 1',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-30 250 20], ...
                  'Enable'  , sTxtVolumeBed1Enable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chk3DVolumeBed1EnableCallback...
                  );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 1 volume selection',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-60 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );


    pop3DVolumeBed1Selection = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-60 250 25], ...
                 'String'  , asSeries, ...
                 'Value'   , 1 ,...
                 'Enable'  , getBed1SelectionEnable(), ...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...
                 'Callback', @pop3DVolumeBed1SelectionCallback...
                 );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 1 energy window',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed1Selection, 'Value'));
    if isempty(atMetaData)
        atInputTemplate = inputTemplate('get');
        atMetaData = atInputTemplate(get(pop3DVolumeBed1Selection, 'Value')).atDicomInfo; 
    end    

    asEnergyWindowTags = getEnergyWindowTags(atMetaData);
    if isempty(asEnergyWindowTags)
        asEnergyWindowTags = ' ';
    end
    
    dMatrixSize = getMatrixSize(atMetaData);

    pop3DVolumeBed1EnergyWindow = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-90 250 25], ...
                 'String'  , asEnergyWindowTags, ...
                 'Value'   , 1 ,...
                 'Enable'  , getBed1SelectionEnable(), ...
                 'BackgroundColor', [0.941 0.941 0.941], ...
                 'ForegroundColor', [0.427 0.427 0.427]  ...
                 );        
    % Bed 2

    if dNbSeries > 1
        sChkVolumeBed2Enable = 'on';
        bChkVolumeBed2Value  = true;
    else
        sChkVolumeBed2Enable = 'off';
        bChkVolumeBed2Value  = false;
    end

    chk3DVolumeBed2Enable = ...
        uicontrol(dlgSystemMatrix,...
                  'style'   , 'checkbox',...
                  'enable'  , sChkVolumeBed2Enable,...
                  'value'   , bChkVolumeBed2Value,...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-30-100 20 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chk3DVolumeBed2EnableCallback...
                  );
    
    if strcmpi(sChkVolumeBed2Enable, 'on')
        sTxtVolumeBed2Enable = 'inactive';
    else
        sTxtVolumeBed2Enable = 'on';
    end

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 2',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-30-100 250 20], ...
                  'Enable'  , sTxtVolumeBed2Enable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chk3DVolumeBed2EnableCallback...
                  );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 2 volume selection',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-60-100 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    if dNbSeries > 1
        dVol2Series = 2;
    else
        dVol2Series = 1;
    end

    pop3DVolumeBed2Selection = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-60-100 250 25], ...
                 'String'  , asSeries, ...
                 'Value'   , dVol2Series ,...
                 'Enable'  , getBed2SelectionEnable(), ...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...
                 'Callback', @pop3DVolumeBed2SelectionCallback...
                 );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 2 energy window',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90-100 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed2Selection, 'Value'));
    if isempty(atMetaData)
        atInputTemplate = inputTemplate('get');
        atMetaData = atInputTemplate(get(pop3DVolumeBed2Selection, 'Value')).atDicomInfo; 
    end    

    asEnergyWindowTags = getEnergyWindowTags(atMetaData);
    if isempty(asEnergyWindowTags)
        asEnergyWindowTags = ' ';
    end

    pop3DVolumeBed2EnergyWindow = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-90-100 250 25], ...
                 'String'  , asEnergyWindowTags, ...
                 'Value'   , 1 ,...
                 'Enable'  , getBed2SelectionEnable(), ...
                 'BackgroundColor', [0.941 0.941 0.941], ...
                 'ForegroundColor', [0.427 0.427 0.427]  ...
                 );      

    % Bed 3

%    if dNbSeries > 2
%        sChkVolumeBed3Enable = 'on';
%        bChkVolumeBed3Value  = true;
%    else
%        sChkVolumeBed3Enable = 'off';
%        bChkVolumeBed3Value  = false;
%    end

    sChkVolumeBed3Enable = 'off';
    bChkVolumeBed3Value  = false;

    chk3DVolumeBed3Enable = ...
        uicontrol(dlgSystemMatrix,...
                  'style'   , 'checkbox',...
                  'enable'  , sChkVolumeBed3Enable,...
                  'value'   , bChkVolumeBed3Value,...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-30-200 20 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chk3DVolumeBed3EnableCallback...
                  );
    
    if strcmpi(sChkVolumeBed3Enable, 'on')
        sTxtVolumeBed3Enable = 'inactive';
    else
        sTxtVolumeBed3Enable = 'on';
    end

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 3',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-30-200 250 20], ...
                  'Enable'  , sTxtVolumeBed3Enable,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chk3DVolumeBed3EnableCallback...
                  );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 3 volume selection',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-60-200 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    if dNbSeries > 2
        dVol3Series = 3;
    else
        dVol3Series = 1;
    end

    pop3DVolumeBed3Selection = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-60-200 250 25], ...
                 'String'  , asSeries, ...
                 'Value'   , dVol3Series ,...
                 'Enable'  , getBed3SelectionEnable(), ...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get'), ...
                 'Callback', @pop3DVolumeBed3SelectionCallback...
                 );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Bed 3 energy window',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90-200 250 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

    atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed3Selection, 'Value'));
    if isempty(atMetaData)
        atInputTemplate = inputTemplate('get');
        atMetaData = atInputTemplate(get(pop3DVolumeBed3Selection, 'Value')).atDicomInfo; 
    end    

    asEnergyWindowTags = getEnergyWindowTags(atMetaData);
    if isempty(asEnergyWindowTags)
        asEnergyWindowTags = ' ';
    end

    pop3DVolumeBed3EnergyWindow = ...
       uicontrol(dlgSystemMatrix, ...
                 'Style'   , 'popup', ...
                 'Position', [200 DLG_SYSTEM_MATRIX_Y-90-200 250 25], ...
                 'String'  , asEnergyWindowTags, ...
                 'Value'   , 1 ,...
                 'Enable'  , getBed3SelectionEnable(), ...
                 'BackgroundColor', [0.941 0.941 0.941], ...
                 'ForegroundColor', [0.427 0.427 0.427]  ...
                 );     

    % options

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Matrix size',...
                  'horizontalalignment', 'left',...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-90-250 150 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

  edtMatrixSize = ...
      uicontrol(dlgSystemMatrix,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , num2str(dMatrixSize),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'Position', [200 DLG_SYSTEM_MATRIX_Y-90-250 100 20], ...
                'Callback', @edtMatrixSizeCallback...
                );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Number of itteration',...
                  'horizontalalignment', 'left',...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-90-280 150 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

  edtNumberOfItteration = ...
      uicontrol(dlgSystemMatrix,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , num2str(20),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'Position', [200 DLG_SYSTEM_MATRIX_Y-90-280 100 20], ...
                'Callback', @edtNumberOfItterationCallback...
               );

    % Scatter Correction 

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Scatter Correction',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90-310 150 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkScatterCorrectionCallback...
                  );

  chkScatterCorrection = ...
        uicontrol(dlgSystemMatrix,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , 1,...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-90-310 20 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkScatterCorrectionCallback...
                  );

    % Gauss filter

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Gauss filter',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90-340 250 20], ...
                  'Enable'  , 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkGaussFilterEnableCallback...
                  );

  chkGaussFilterEnable = ...
        uicontrol(dlgSystemMatrix,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , 1,...
                  'Position', [20 DLG_SYSTEM_MATRIX_Y-90-340 20 20], ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkGaussFilterEnableCallback...
                  );

        uicontrol(dlgSystemMatrix,...
                  'style'   , 'text',...
                  'string'  , 'Filter cutoff',...
                  'horizontalalignment', 'left',...
                  'Position', [40 DLG_SYSTEM_MATRIX_Y-90-370 150 20], ...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...                    
                  );

  if get(chkGaussFilterEnable, 'value') == true
      sFilterCutoffEnable = 'on';
  else
      sFilterCutoffEnable = 'off';
  end

  edtGaussFilterCutoff = ...
      uicontrol(dlgSystemMatrix,...
                'style'     , 'edit',...
                'Background', 'white',...
                'Enable'    , sFilterCutoffEnable, ... 
                'string'    , num2str(1.2),...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'Position', [200 DLG_SYSTEM_MATRIX_Y-90-370 100 20], ...
                'Callback', @edtGaussFilterCutoffCallback...
               );


     % Cancel or Proceed

     uicontrol(dlgSystemMatrix,...
               'String','Cancel',...
               'Position',[DLG_SYSTEM_MATRIX_X-85 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelSystemMatrixCallback...
               );

     uicontrol(dlgSystemMatrix,...
              'String','Proceed',...
              'Position',[DLG_SYSTEM_MATRIX_X-170 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @proceedSystemMatrixCallback...
              );  

    function asEnergyWindowTags = getEnergyWindowTags(atMetaData)

        atEnergyWindow = getEnergyWindowsName(atMetaData);
    
        if ~isempty(atEnergyWindow)
            asEnergyWindowTags = cell(numel(atEnergyWindow), 1);
            for jj=1:numel(atEnergyWindow)
                asEnergyWindowTags{jj} = atEnergyWindow{jj}.sEnergyWindowTag;
            end
        else
            asEnergyWindowTags = [];
        end
    end

    % Bed 1

    function chk3DVolumeBed1EnableCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chk3DVolumeBed1Enable, 'value') == true
                set(chk3DVolumeBed1Enable, 'value', false);
            else
                set(chk3DVolumeBed1Enable, 'value', true);
            end
        end

        if get(chk3DVolumeBed1Enable, 'value') == true
            set(pop3DVolumeBed1Selection   , 'Enable', 'on');
            set(pop3DVolumeBed1EnergyWindow, 'Enable', 'on');
        else
            set(pop3DVolumeBed1Selection   , 'Enable', 'off');
            set(pop3DVolumeBed1EnergyWindow, 'Enable', 'off');            
        end
    end
    
    function pop3DVolumeBed1SelectionCallback(~, ~)

        atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed1Selection, 'Value'));
        if isempty(atMetaData)
            atInputTemplate = inputTemplate('get');
            atMetaData = atInputTemplate(get(pop3DVolumeBed1Selection, 'Value')).atDicomInfo; 
        end

        asEnergyWindowTags = getEnergyWindowTags(atMetaData);

        if ~isempty(asEnergyWindowTags)
            set(pop3DVolumeBed1EnergyWindow, 'String', asEnergyWindowTags);
            set(pop3DVolumeBed1EnergyWindow, 'Value', 1);
        end     

        set(edtMatrixSize, 'String', num2str(getMatrixSize(atMetaData)));

    end

    function sEnable = getBed1SelectionEnable()
        
        if strcmpi(get(chk3DVolumeBed1Enable, 'Enable'),'on')

            if get(chk3DVolumeBed1Enable, 'Value') == true
                sEnable = 'on';
            else
                sEnable = 'off';
            end
        else
            sEnable = 'off';
        end
    end

    % Bed 2
    
    function chk3DVolumeBed2EnableCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chk3DVolumeBed2Enable, 'value') == true
                set(chk3DVolumeBed2Enable, 'value', false);
            else
                set(chk3DVolumeBed2Enable, 'value', true);
            end
        end

        if get(chk3DVolumeBed2Enable, 'value') == true
            set(pop3DVolumeBed2Selection   , 'Enable', 'on');
            set(pop3DVolumeBed2EnergyWindow, 'Enable', 'on');
        else
            set(pop3DVolumeBed2Selection   , 'Enable', 'off');
            set(pop3DVolumeBed2EnergyWindow, 'Enable', 'off');            
        end
    end
    
    function pop3DVolumeBed2SelectionCallback(~, ~)

        atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed2Selection, 'Value'));
        if isempty(atMetaData)
            atInputTemplate = inputTemplate('get');
            atMetaData = atInputTemplate(get(pop3DVolumeBed2Selection, 'Value')).atDicomInfo; 
        end

        asEnergyWindowTags = getEnergyWindowTags(atMetaData);

        if ~isempty(asEnergyWindowTags)
            set(pop3DVolumeBed2EnergyWindow, 'String', asEnergyWindowTags);
            set(pop3DVolumeBed2EnergyWindow, 'Value', 1);
        end          

        set(edtMatrixSize, 'String', num2str(getMatrixSize(atMetaData)));
    end

    function sEnable = getBed2SelectionEnable()
        
        if strcmpi(get(chk3DVolumeBed2Enable, 'Enable'),'on')

            if get(chk3DVolumeBed2Enable, 'Value') == true
                sEnable = 'on';
            else
                sEnable = 'off';
            end
        else
            sEnable = 'off';
        end
    end

    % Bed 3
    
    function chk3DVolumeBed3EnableCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chk3DVolumeBed3Enable, 'value') == true
                set(chk3DVolumeBed3Enable, 'value', false);
            else
                set(chk3DVolumeBed3Enable, 'value', true);
            end
        end

        if get(chk3DVolumeBed3Enable, 'value') == true
            set(pop3DVolumeBed3Selection   , 'Enable', 'on');
            set(pop3DVolumeBed3EnergyWindow, 'Enable', 'on');
        else
            set(pop3DVolumeBed3Selection   , 'Enable', 'off');
            set(pop3DVolumeBed3EnergyWindow, 'Enable', 'off');            
        end
    end
    
    function pop3DVolumeBed3SelectionCallback(~, ~)

        atMetaData = dicomMetaData('get', [], get(pop3DVolumeBed3Selection, 'Value'));
        if isempty(atMetaData)
            atInputTemplate = inputTemplate('get');
            atMetaData = atInputTemplate(get(pop3DVolumeBed3Selection, 'Value')).atDicomInfo; 
        end

        asEnergyWindowTags = getEnergyWindowTags(atMetaData);

        if ~isempty(asEnergyWindowTags)
            set(pop3DVolumeBed3EnergyWindow, 'String', asEnergyWindowTags);
            set(pop3DVolumeBed3EnergyWindow, 'Value', 1);
        end     

        set(edtMatrixSize, 'String', num2str(getMatrixSize(atMetaData)));

    end

    function sEnable = getBed3SelectionEnable()
        
        if strcmpi(get(chk3DVolumeBed3Enable, 'Enable'),'on')

            if get(chk3DVolumeBed3Enable, 'Value') == true
                sEnable = 'on';
            else
                sEnable = 'off';
            end
        else
            sEnable = 'off';
        end
    end

    function chkScatterCorrectionCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkScatterCorrection, 'value') == true
                set(chkScatterCorrection, 'value', false);
            else
                set(chkScatterCorrection, 'value', true);
            end
        end       
    end

    function chkGaussFilterEnableCallback(hObject, ~)

        if strcmpi(get(hObject, 'Style'), 'text')
            if get(chkGaussFilterEnable, 'value') == true
                set(chkGaussFilterEnable, 'value', false);
            else
                set(chkGaussFilterEnable, 'value', true);
            end
        end

        if get(chkGaussFilterEnable, 'value') == true
            set(edtGaussFilterCutoff   , 'Enable', 'on');
        else
            set(edtGaussFilterCutoff   , 'Enable', 'off');
        end        
    end

    function edtMatrixSizeCallback(~, ~)

        if str2double(get(edtMatrixSize, 'String')) < 0
            set(edtMatrixSize, 'String', '128');
        end

    end

    function edtNumberOfItterationCallback(~, ~)

        if str2double(get(edtNumberOfItteration, 'String')) <0
            set(edtNumberOfItteration, 'String', '20');
        end

    end

    function edtGaussFilterCutoffCallback(~, ~)

        if str2double(get(edtGaussFilterCutoff, 'String')) < 0
            set(edtGaussFilterCutoff, 'String', '1.2');
        end

    end

    function dSize = getMatrixSize(atMetaData)

        dSize = atMetaData{1}.Rows;
    end

    function cancelSystemMatrixCallback(~, ~)

        delete(dlgSystemMatrix);
    end

    function proceedSystemMatrixCallback(~, ~)

        atInputTemplate = inputTemplate('get');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');

%         try

        atcBedMetaData{1} = [];
        atcBedMetaData{2} = [];
        atcBedMetaData{3} = [];

        dBed1EnergyWindowLowerLimit = [];
        dBed2EnergyWindowLowerLimit = [];
        dBed3EnergyWindowLowerLimit = [];

        dBed1EnergyWindowUpperLimit = [];
        dBed2EnergyWindowUpperLimit = [];
        dBed3EnergyWindowUpperLimit = [];

        acBedImage{1} = [];
        acBedImage{2} = [];
        acBedImage{3} = [];

        dMatrixSize         = str2double(get(edtMatrixSize, 'String'));
        dNumberOfItteration = str2double(get(edtNumberOfItteration, 'String'));
        bScatterCorrection  = get(chkScatterCorrection, 'value');
        bGaussFilterEnable  = get(chkGaussFilterEnable, 'value');
        dGaussFilterCutoff  = str2double(get(edtGaussFilterCutoff, 'String'));

        bReconstrucBed1 = false;      

        if get(chk3DVolumeBed1Enable, 'value') == true && ...
           strcmpi(get(chk3DVolumeBed1Enable, 'Enable'), 'on') == true

            bReconstrucBed1 = true;

            dBed1SeriesOffset = get(pop3DVolumeBed1Selection, 'Value');

            acBedImage{1} = dicomBuffer('get', [], dBed1SeriesOffset);

            if isempty(acBedImage{1})

                aInputBuffer = inputBuffer('get');
                
                acBedImage{1} = aInputBuffer{dBed1SeriesOffset};
                                                    
%                 if     strcmpi(imageOrientation('get'), 'axial')
%                 %    acBedImage{1} = acBedImage{1};
%                 elseif strcmpi(imageOrientation('get'), 'coronal')
%                     acBedImage{1} = reorientBuffer(acBedImage{1}, 'coronal');
%                 elseif strcmpi(imageOrientation('get'), 'sagittal')
%                     acBedImage{1} = reorientBuffer(acBedImage{1}, 'sagittal');
%                 end

                if atInputTemplate(dBed1SeriesOffset).bFlipLeftRight == true
                    acBedImage{1}=acBedImage{1}(:,end:-1:1,:);
                end

                if atInputTemplate(dBed1SeriesOffset).bFlipAntPost == true
                    acBedImage{1}=acBedImage{1}(end:-1:1,:,:);
                end

                if atInputTemplate(dBed1SeriesOffset).bFlipHeadFeet == true
                    acBedImage{1}=acBedImage{1}(:,:,end:-1:1);
                end  
            end

            atcBedMetaData{1} = dicomMetaData('get', [], dBed1SeriesOffset);
            if isempty(atcBedMetaData{1})
                atcBedMetaData{1} = atInputTemplate(dBed1SeriesOffset).atDicomInfo; 
            end  

            atEnergyWindowName = getEnergyWindowsName(atcBedMetaData{1});

            if ~isempty(atEnergyWindowName)
                dBed1EnergyWindowLowerLimit = atEnergyWindowName{get(pop3DVolumeBed1EnergyWindow, 'Value')}.dLowerLimit;
                dBed1EnergyWindowUpperLimit = atEnergyWindowName{get(pop3DVolumeBed1EnergyWindow, 'Value')}.dUpperLimit;                
            end
        end

        bReconstrucBed2 = false;      

        if get(chk3DVolumeBed2Enable, 'value') == true && ...
           strcmpi(get(chk3DVolumeBed2Enable, 'Enable'), 'on') == true

            bReconstrucBed2 = true;

            dBed2SeriesOffset = get(pop3DVolumeBed2Selection, 'Value');

            acBedImage{2} = dicomBuffer('get', [], dBed2SeriesOffset);

            if isempty(acBedImage{2})

                aInputBuffer = inputBuffer('get');
                
                acBedImage{2} = aInputBuffer{dBed2SeriesOffset};
                                                    
%                 if     strcmpi(imageOrientation('get'), 'axial')
%                 %    acBedImage{2} = acBedImage{2};
%                 elseif strcmpi(imageOrientation('get'), 'coronal')
%                     acBedImage{2} = reorientBuffer(acBedImage{2}, 'coronal');
%                 elseif strcmpi(imageOrientation('get'), 'sagittal')
%                     acBedImage{2} = reorientBuffer(acBedImage{2}, 'sagittal');
%                 end

                if atInputTemplate(dBed2SeriesOffset).bFlipLeftRight == true
                    acBedImage{2}=acBedImage{2}(:,end:-1:1,:);
                end

                if atInputTemplate(dBed2SeriesOffset).bFlipAntPost == true
                    acBedImage{2}=acBedImage{2}(end:-1:1,:,:);
                end

                if atInputTemplate(dBed2SeriesOffset).bFlipHeadFeet == true
                    acBedImage{2}=acBedImage{2}(:,:,end:-1:1);
                end  
            end

            atcBedMetaData{2} = dicomMetaData('get', [], dBed2SeriesOffset);
            if isempty(atcBedMetaData{2})
                atcBedMetaData{2} = atInputTemplate(dBed2SeriesOffset).atDicomInfo; 
            end  

            atEnergyWindowName = getEnergyWindowsName(atcBedMetaData{2});

            if ~isempty(atEnergyWindowName)
                dBed2EnergyWindowLowerLimit = atEnergyWindowName{get(pop3DVolumeBed2EnergyWindow, 'Value')}.dLowerLimit;
                dBed2EnergyWindowUpperLimit = atEnergyWindowName{get(pop3DVolumeBed2EnergyWindow, 'Value')}.dUpperLimit;                   
            end
        end

        bReconstrucBed3 = false;        
        
        if get(chk3DVolumeBed3Enable, 'value') == true && ...
           strcmpi(get(chk3DVolumeBed3Enable, 'Enable'), 'on') == true

            bReconstrucBed3 = true;

            dBed3SeriesOffset = get(pop3DVolumeBed3Selection, 'Value');
            acBedImage{3} = dicomBuffer('get', [], dBed3SeriesOffset);

            if isempty(acBedImage{3})

                aInputBuffer = inputBuffer('get');
                
                acBedImage{3} = aInputBuffer{dBed3SeriesOffset};
                                                    
%                 if     strcmpi(imageOrientation('get'), 'axial')
%                 %    acBedImage{3} = acBedImage{3};
%                 elseif strcmpi(imageOrientation('get'), 'coronal')
%                     acBedImage{3} = reorientBuffer(acBedImage{3}, 'coronal');
%                 elseif strcmpi(imageOrientation('get'), 'sagittal')
%                     acBedImage{3} = reorientBuffer(acBedImage{3}, 'sagittal');
%                 end

                if atInputTemplate(dBed3SeriesOffset).bFlipLeftRight == true
                    acBedImage{3}=acBedImage{3}(:,end:-1:1,:);
                end

                if atInputTemplate(dBed3SeriesOffset).bFlipAntPost == true
                    acBedImage{3}=acBedImage{3}(end:-1:1,:,:);
                end

                if atInputTemplate(dBed3SeriesOffset).bFlipHeadFeet == true
                    acBedImage{3}=acBedImage{3}(:,:,end:-1:1);
                end  
            end

            atcBedMetaData{3} = dicomMetaData('get', [], dBed3SeriesOffset);
            if isempty(atcBedMetaData{3})
                atcBedMetaData{3} = atInputTemplate(dBed3SeriesOffset).atDicomInfo; 
            end  

            atEnergyWindowName = getEnergyWindowsName(atcBedMetaData{3});

            if ~isempty(atEnergyWindowName)
                dBed3EnergyWindowLowerLimit = atEnergyWindowName{get(pop3DVolumeBed3EnergyWindow, 'Value')}.dLowerLimit;
                dBed3EnergyWindowUpperLimit = atEnergyWindowName{get(pop3DVolumeBed3EnergyWindow, 'Value')}.dUpperLimit;                    
            end
        end

        delete(dlgSystemMatrix);
      
        if bReconstrucBed1 == true || ...
           bReconstrucBed2 == true || ...
           bReconstrucBed3 == true 

            % Set beds option

            atcOption{1}.bReconstrucBed           = bReconstrucBed1;
            atcOption{1}.Matrix                   = dMatrixSize;
            atcOption{1}.EnergyWindowLowerLimit   = dBed1EnergyWindowLowerLimit;
            atcOption{1}.EnergyWindowUpperLimit   = dBed1EnergyWindowUpperLimit;
            atcOption{1}.NbItteration             = dNumberOfItteration;
            atcOption{1}.Scatter.CorrectionEnable = bScatterCorrection;
            atcOption{1}.Filter.GaussEnable       = bGaussFilterEnable;
            atcOption{1}.Filter.GaussCuttoff      = dGaussFilterCutoff;
   
            atcOption{2}.bReconstrucBed           = bReconstrucBed2;
            atcOption{2}.Matrix                   = dMatrixSize;
            atcOption{2}.EnergyWindowLowerLimit   = dBed2EnergyWindowLowerLimit;
            atcOption{2}.EnergyWindowUpperLimit   = dBed2EnergyWindowUpperLimit;
            atcOption{2}.NbItteration             = dNumberOfItteration;
            atcOption{2}.Scatter.CorrectionEnable = bScatterCorrection;
            atcOption{2}.Filter.GaussEnable       = bGaussFilterEnable;
            atcOption{2}.Filter.GaussCuttoff      = dGaussFilterCutoff;

            atcOption{3}.bReconstrucBed           = bReconstrucBed3;
            atcOption{3}.Matrix                   = dMatrixSize;
            atcOption{3}.EnergyWindowLowerLimit   = dBed3EnergyWindowLowerLimit;
            atcOption{3}.EnergyWindowUpperLimit   = dBed3EnergyWindowUpperLimit;
            atcOption{3}.NbItteration             = dNumberOfItteration;
            atcOption{3}.Scatter.CorrectionEnable = bScatterCorrection;
            atcOption{3}.Filter.GaussEnable       = bGaussFilterEnable;
            atcOption{3}.Filter.GaussCuttoff      = dGaussFilterCutoff;

            % Reconstruct the beds

            [aReconstructedImage, atReconstructedMetaData] = GenerateSystemMatrix(acBedImage, atcBedMetaData, atcOption);

            % Add the recinstructed image as a new series
  
            atInput = inputTemplate('get');

            atInput(numel(atInput)+1) = atInput(dBed1SeriesOffset);

            atInput(numel(atInput)).bEdgeDetection = false;
            atInput(numel(atInput)).bDoseKernel    = false;    
            atInput(numel(atInput)).bFlipLeftRight = false;
            atInput(numel(atInput)).bFlipAntPost   = false;
            atInput(numel(atInput)).bFlipHeadFeet  = false;
            atInput(numel(atInput)).bMathApplied   = false;
            atInput(numel(atInput)).bFusedDoseKernel    = false;
            atInput(numel(atInput)).bFusedEdgeDetection = false;
            atInput(numel(atInput)).tMovement = [];
            atInput(numel(atInput)).tMovement.bMovementApplied = false;
            atInput(numel(atInput)).tMovement.aGeomtform = [];                
            atInput(numel(atInput)).tMovement.atSeq{1}.sAxe = [];
            atInput(numel(atInput)).tMovement.atSeq{1}.aTranslation = [];
            atInput(numel(atInput)).tMovement.atSeq{1}.dRotation = [];            

            atInput(numel(atInput)).atDicomInfo = atReconstructedMetaData;

            asSeriesDescription = seriesDescription('get');
            asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('%s', 'System Matrix Reconstruction');
            seriesDescription('set', asSeriesDescription);

            dSeriesInstanceUID = dicomuid;

            for hh=1:numel(atInput(numel(atInput)).atDicomInfo)
                atInput(numel(atInput)).atDicomInfo{hh}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
                atInput(numel(atInput)).atDicomInfo{hh}.SeriesInstanceUID = dSeriesInstanceUID;
            end

% To reduce memory usage                
%             atInput(numel(atInput)).aDicomBuffer = aReconstructedImage;
% To reduce memory usage                

            inputTemplate('set', atInput);

            aInputBuffer = inputBuffer('get');
            aInputBuffer{numel(aInputBuffer)+1} = aReconstructedImage;
            inputBuffer('set', aInputBuffer);

            asSeries = get(uiSeriesPtr('get'), 'String');
            asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};
            set(uiSeriesPtr('get'), 'String', asSeries);
            set(uiFusedSeriesPtr('get'), 'String', asSeries);

            set(uiSeriesPtr('get'), 'Value', numel(atInput));
            dicomMetaData('set', atInput(numel(atInput)).atDicomInfo);
            dicomBuffer('set', aReconstructedImage);
            setQuantification(numel(atInput));

            tQuant = quantificationTemplate('get');
            atInput(numel(atInput)).tQuant = tQuant;

            aReconstructedImageMip = computeMIP(aReconstructedImage);
            mipBuffer('set', aReconstructedImageMip, numel(atInput));
            atInput(numel(atInput)).aMip = aReconstructedImageMip;

            inputTemplate('set', atInput);   

            set(uiSeriesPtr('get'), 'Value', numel(atInput));

            lMin = min(aReconstructedImage, [], 'all');
            lMax = max(aReconstructedImage, [], 'all');

            clear aReconstructedImage;
            clear aReconstructedImageMip;

            setWindowMinMax(lMax, lMin);  

            clearDisplay();

            initDisplay(3);                

            dicomViewerCore();

            refreshImages();                

        end
               
        clear acBedImage{1};
        clear acBedImage{2};
        clear acBedImage{3};
         
%         catch
%             progressBar(1, 'Error:proceedSystemMatrixCallback()');
%         end
        
        set(fiMainWindowPtr('get'), 'Pointer', 'default');

    end

end