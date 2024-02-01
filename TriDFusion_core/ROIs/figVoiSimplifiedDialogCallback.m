function figVoiSimplifiedDialogCallback(~, ~)
%function figVoiSimplifiedDialogCallback(~,~)
%Figure ROI Result Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    FIG_ROI_X = 1400;
    FIG_ROI_Y =  ySize*0.75;

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end
            
    releaseRoiWait();

    figVoiSimplifiedWindow = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_ROI_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_ROI_Y/2) ...
               FIG_ROI_X ...
               FIG_ROI_Y],...
               'Name', 'TriDFusion (3DF) VOI Simplified Result',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Toolbar','none'...
               );

    set(figVoiSimplifiedWindow, 'WindowButtonDownFcn', @voiClickDown);

    mRoiFile = uimenu(figVoiSimplifiedWindow,'Label','File');
    uimenu(mRoiFile,'Label', 'Export to .csv...','Callback', @exportCurrentSeriesSimplifiedReportCallback);
    uimenu(mRoiFile,'Label', 'Print Preview...','Callback', 'filemenufcn(gcbf,''FilePrintPreview'')', 'Separator','on');
    uimenu(mRoiFile,'Label', 'Print...','Callback', 'printdlg(gcbf)');
    uimenu(mRoiFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mRoiEdit = uimenu(figVoiSimplifiedWindow,'Label','Edit');
    uimenu(mRoiEdit,'Label', 'Copy Display', 'Callback', @copyVoiDialogDisplayCallback);

    mRoiOptions = uimenu(figVoiSimplifiedWindow,'Label','Options', 'Callback', @figVoiSimplifiedRefreshOption);

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

    if isfigVoiSimplifiedInColor('get') == true
        sfigVoiSimplifiedInColorChecked = 'on';
    else
        sfigVoiSimplifiedInColorChecked = 'off';
    end


    mSUVUnit          = ...
        uimenu(mRoiOptions,'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @figVoiSimplifiedSUVUnitCallback);
    
    mModifiedMatrix   = ...
        uimenu(mRoiOptions,'Label', 'Display Image Cells Value' , 'Checked', sModifiedMatrixChecked, 'Callback', @figVoiSimplifiedModifiedMatrixCallback);
    
    mColorBackground  = ...
        uimenu(mRoiOptions,'Label', 'Display in Color' , 'Checked', sfigVoiSimplifiedInColorChecked, 'Callback', @figVoiSimplifiedColorCallback);

    uiVoiRoiWindow = ...
        uipanel(figVoiSimplifiedWindow,...
                'Units'   , 'pixels',...
                'BorderWidth', 0,...
                'HighlightColor', [0 1 1],...
                'position', [0 0 FIG_ROI_X FIG_ROI_Y]...
               );

    if isfigVoiSimplifiedInColor('get') == true
        aBackgroundColor = viewerAxesColor('get');
    else
        aBackgroundColor = [0.9800 0.9800 0.9800];
    end

    lbVoiRoiWindow =  ...
        uicontrol(uiVoiRoiWindow,...
                  'style'   , 'listbox',...
                  'position', [0 0 uiVoiRoiWindow.Position(3) uiVoiRoiWindow.Position(4)-20],...
                  'fontsize', 10.1,...
                  'BackgroundColor', aBackgroundColor,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , ' ',...
                  'Callback', @lbVoiSimplifiedMainWindowCallback...
                  );

     set(lbVoiRoiWindow, 'Max',2, 'Min',0);

     uicontrol(uiVoiRoiWindow,...
               'Position', [0 uiVoiRoiWindow.Position(4)-20 150 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Name'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Nb Cells'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Total'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Mean'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Min'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Max'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Median'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Deviation'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Peak'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Max Coronal (mm)'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1050 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Max Sagittal (mm)'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Max Axial (mm)'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1250 uiVoiRoiWindow.Position(4)-20 150 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Volume (cm3)'...
               );

    if strcmpi(mSUVUnit.Checked, 'on')
        bSUVUnit = true;
    else
        bSUVUnit = false;
    end


    if strcmpi(get(mModifiedMatrix, 'Checked'), 'on') 
        bModifiedMatrix = true;
    else
        bModifiedMatrix = false;
    end
                
    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);

    setVoiSimplifiedFigureName();

    function figVoiSimplifiedRefreshOption(~, ~)

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
      
        if isfigVoiSimplifiedInColor('get') == true
            sfigVoiSimplifiedInColorChecked = 'on';
        else
            sfigVoiSimplifiedInColorChecked = 'off';
        end

        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mModifiedMatrix  , 'Checked', sModifiedMatrixChecked);
        set(mColorBackground , 'Checked', sfigVoiSimplifiedInColorChecked);

    end

    function setVoiSimplifiedFigureName()

        if ~isvalid(lbVoiRoiWindow)
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atRoiMetaData = dicomMetaData('get', [], dSeriesOffset);
  
        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')            
            sModified = ' - Cells Value: Display Image';
        else
            sModified = ' - Cells Value: Unmodified Image';
        end       
        
        if atInput(dSeriesOffset).bDoseKernel == true

            if isfield(atRoiMetaData{1}, 'DoseUnits')

                if ~isempty(atRoiMetaData{1}.DoseUnits)
                    
                    sUnits = sprintf('Unit: %s', char(atRoiMetaData{1}.DoseUnits));
                else
                    sUnits = 'Unit: dose';
                end
            else
                sUnits = 'Unit: dose';
            end  

        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnits = getSerieUnitValue(dSeriesOffset);
                if (strcmpi(atRoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atRoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(sUnits, 'SUV' )
                    sSUVtype = viewerSUVtype('get');
                    sUnits =  sprintf('Unit: SUV/%s', sSUVtype);
                else
                    if (strcmpi(atRoiMetaData{1}.Modality, 'ct'))
                       sUnits =  'Unit: HU';
                    else
                       sUnits =  'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(atRoiMetaData{1}.Modality, 'ct'))
                    sUnits =  'Unit: HU';
                 else
                    sUnits = getSerieUnitValue(dSeriesOffset);
                    if (strcmpi(atRoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atRoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(sUnits, 'SUV' )
                        sUnits =  'Unit: BQML';
                    else

                        sUnits =  'Unit: Counts';
                    end
                 end
            end
        end

        figVoiSimplifiedWindow.Name = ['TriDFusion (3DF) VOI Simplified Result - ' atRoiMetaData{1}.SeriesDescription ' - ' sUnits sModified];

    end

    function sOutput = maxStringLength(sString, iMaxLength)

        if numel(sString) > iMaxLength
            sOutput = sString(1:iMaxLength);
        else
            sOutput = sString;
        end

    end

    function lbVoiSimplifiedMainWindowCallback(hObject, ~)

        aVoiRoiTag = voiTag('get');
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if ~isempty(atVoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(atVoiInput)
                
                if strcmp(atVoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)

                    dRoiOffset = round(numel(atVoiInput{cc}.RoisTag)/2);

                    triangulateRoi(atVoiInput{cc}.RoisTag{dRoiOffset});

                    break;
                end
            end
        end

    end

    function voiClickDown(~, ~)

        if strcmp(get(figVoiSimplifiedWindow,'selectiontype'),'alt')
                       
            aVoiRoiTag  = voiTag('get', get(uiSeriesPtr('get'), 'Value'));
            atRoiInput  = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                

            adOffset = get(lbVoiRoiWindow, 'Value');

            if numel(adOffset) < 2
                c = uicontextmenu(figVoiSimplifiedWindow);
                lbVoiRoiWindow.UIContextMenu = c;

                uimenu(c,'Label', 'Delete Contour', 'Callback',@figVoiSimplifiedDeleteObjectCallback);

                uimenu(c,'Label', 'Edit Label', 'Separator', 'on', 'Callback',@figVoiSimplifiedEditLabelCallback);

                mList = uimenu(c,'Label', 'Predefined Label');
                aList = getRoiLabelList();
                for pp=1:numel(aList)
                    uimenu(mList,'Text', aList{pp}, 'MenuSelectedFcn', @figVoiSimplifiedPredefinedLabelCallback);
                end

                uimenu(c,'Label', 'Edit Color', 'Callback',@figVoiSimplifiedEditColorCallback);
                uimenu(c,'Label', 'Hide/View Face Alpha', 'Callback', @figVoiSimplifiedHideViewFaceAlhaCallback);

                atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                                 
            end

        end
                
        function figVoiSimplifiedDeleteObjectCallback(~, ~)

            aVoiRoiTag = voiTag('get', get(uiSeriesPtr('get'), 'Value'));

            if ~isempty(aVoiRoiTag)

                figVoiSimplifiedDeleteObject(aVoiRoiTag{lbVoiRoiWindow.Value}.Tag, true);
            end
        end

        function figVoiSimplifiedPredefinedLabelCallback(hObject, ~)

            aVoiRoiTag = voiTag('get', get(uiSeriesPtr('get'), 'Value'));

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
            if ~isempty(aVoiRoiTag)
                
                % Search for a voi tag, if we don't find one, then the tag is            
                % roi
                
                if isempty(atVoiInput)
                    aTagOffset = 0;
                else
                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );
                end

                if aTagOffset(aTagOffset==1) % tag is a voi

                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)

                        figVoiSimplifiedSetLabel(atVoiInput{dTagOffset}, get(hObject, 'Text'))

                        % Refresh contour figure and contour popup

                        setVoiRoiSegPopup();

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

                        setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);
                    end

                else % Tag is a ROI
                    
                    if isempty(atRoiInput)
                        aTagOffset = 0;
                    else
                        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );            
                    end

                    if aTagOffset(aTagOffset==1) % tag is a roi

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)

                            if isvalid(atRoiInput{dTagOffset}.Object)

                                figVoiSimplifiedSetLabel(atRoiInput{dTagOffset}, get(hObject, 'Text'));

                                % Refresh contour figure and contour popup

                                setVoiRoiSegPopup();

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

                                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);

                            end
                        end                       
                    end
                end  
            end
        end

        function figVoiSimplifiedEditLabelCallback(~, ~)

            aVoiRoiTag = voiTag('get', get(uiSeriesPtr('get'), 'Value'));

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                      
            if ~isempty(aVoiRoiTag)
                
                % Search for a voi tag, if we don't find one, then the tag is            
                % roi
            
                if isempty(atVoiInput) 
                    aTagOffset = 0;
                else        
                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );
                end

                if aTagOffset(aTagOffset==1) % tag is a voi

                    if ~isempty(atVoiInput) 

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)

                            figVoiSimplifiedEditLabelDialog(atVoiInput{dTagOffset});
                        end
                    end

                else % Tag is a ROI
                    
                    if isempty(atRoiInput) 
                        aTagOffset = 0;
                    else
                        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );            
                    end

                    if aTagOffset(aTagOffset==1) % tag is a roi

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)

                            if isvalid(atRoiInput{dTagOffset}.Object)

                                figVoiSimplifiedEditLabelDialog(atRoiInput{dTagOffset});
                            end
                        end
                    end
                end
            end

            function figVoiSimplifiedEditLabelDialog(ptrObject)

                EDIT_DIALOG_X = 310;
                EDIT_DIALOG_Y = 100;

                figVoiPosX  = figVoiSimplifiedWindow.Position(1);
                figVoiPosY  = figVoiSimplifiedWindow.Position(2);
                figVoiSizeX = figVoiSimplifiedWindow.Position(3);
                figVoiSizeY = figVoiSimplifiedWindow.Position(4);

                figVoiEditLabelWindow = ...
                    dialog('Position', [(figVoiPosX+(figVoiSizeX/2)-EDIT_DIALOG_X/2) ...
                           (figVoiPosY+(figVoiSizeY/2)-EDIT_DIALOG_Y/2) ...
                           EDIT_DIALOG_X ...
                           EDIT_DIALOG_Y],...
                           'Color', viewerBackgroundColor('get'), ...
                           'Name', 'Edit Label'...
                           );

                uicontrol(figVoiEditLabelWindow,...
                          'style'   , 'text',...
                          'string'  , 'Label Name:',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'position', [20 52 80 25]...
                          );

                edtfigVoiLabelName = ...
                    uicontrol(figVoiEditLabelWindow,...
                          'style'     , 'edit',...
                          'horizontalalignment', 'left',...
                          'Background', 'white',...
                          'string'    , ptrObject.Label,...
                          'position'  , [100 55 150 25], ...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback', @acceptfigVoiSimplifiedEditLabelCallback...
                          );

                % Cancel or Proceed

                figVoiEditLabelCancelWindow = ...
                uicontrol(figVoiEditLabelWindow,...
                          'String','Cancel',...
                          'Position',[200 7 100 25],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback', @cancelfigVoiSimplifiedEditLabelCallback...
                          );

                figVoiEditLabelOkWindow = ...
                uicontrol(figVoiEditLabelWindow,...
                          'String','Ok',...
                          'Position',[95 7 100 25],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback', @acceptfigVoiSimplifiedEditLabelCallback...
                          );

                function cancelfigVoiSimplifiedEditLabelCallback(~, ~)
                    
                    delete(figVoiEditLabelWindow);
                end

                function acceptfigVoiSimplifiedEditLabelCallback(~, ~)

                    set(figVoiEditLabelCancelWindow, 'Enable', 'off');
                    set(figVoiEditLabelOkWindow    , 'Enable', 'off');
                    
                    figVoiSimplifiedSetLabel(ptrObject, get(edtfigVoiLabelName, 'String'))
                    
                    if strcmpi(ptrObject.ObjectType, 'voi') % Object is a voi
                        setVoiRoiSegPopup();
                    end

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
                            
                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);
                    
                    delete(figVoiEditLabelWindow);

                end
            end

        end

        function figVoiSimplifiedSetLabel(ptrObject, sLabel)
                        
            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            if strcmpi(ptrObject.ObjectType, 'voi') % Object is a voi
                
                aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {ptrObject.Tag} );

                if ~isempty(atVoiInput) && ~isempty(atRoiInput)

                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)

                        % Set voi template voi label 

                        atVoiInput{dTagOffset}.Label = sLabel;

                        voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atVoiInput);

                        % Set roi template voi\roi label 

                        aRoisTagOffset = zeros(1, numel(ptrObject.RoisTag));

                        if ~isempty(atRoiInput)

                            for ro=1:numel(ptrObject.RoisTag)
                                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrObject.RoisTag{ro}]} );
                                aRoisTagOffset(ro) = find(aTagOffset, 1);    
                            end

                            if numel(ptrObject.RoisTag)
                                for ro=1:numel(ptrObject.RoisTag)
                                    sRoiLabel =  sprintf('%s (roi %d/%d)', sLabel, ro, numel(ptrObject.RoisTag));
                                    atRoiInput{aRoisTagOffset(ro)}.Label = sRoiLabel;

                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)
                                        atRoiInput{aRoisTagOffset(ro)}.Object.Label = sRoiLabel;
                                    end

                                end

                                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);                                    
                            end

                        end                                                               
                    end
                end
            end
        end

        function figVoiSimplifiedEditColorCallback(~, ~)

            aVoiRoiTag = voiTag('get', get(uiSeriesPtr('get'), 'Value'));

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
            if ~isempty(aVoiRoiTag)
                
                if isempty(atVoiInput)
                    aTagOffset = 0;
                else
                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );
                end

                if aTagOffset(aTagOffset==1) % tag is a voi

                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)

                        sColor = uisetcolor([atVoiInput{dTagOffset}.Color], 'Select a color');

                        figVoiSimplifiedSetColor(atVoiInput{dTagOffset}, sColor)

                        % Refresh contour figure and contour popup

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

                        setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);
                    end
                end

            end                          

            function figVoiSimplifiedSetColor(ptrObject, sColor)

                atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

                if strcmpi(ptrObject.ObjectType, 'voi') % Object is a voi

                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {ptrObject.Tag} );

                    if ~isempty(atVoiInput) && ~isempty(atRoiInput)

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)

                            % Set voi template voi color 

                            atVoiInput{dTagOffset}.Color = sColor;

                            voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atVoiInput);

                            % Set roi template voi\roi color 

                            aRoisTagOffset = zeros(1, numel(ptrObject.RoisTag));

                            if ~isempty(atRoiInput)

                                for ro=1:numel(ptrObject.RoisTag)
                                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrObject.RoisTag{ro}]} );
                                    aRoisTagOffset(ro) = find(aTagOffset, 1);    
                                end

                                if numel(ptrObject.RoisTag)
                                    
                                    for ro=1:numel(ptrObject.RoisTag)

                                        atRoiInput{aRoisTagOffset(ro)}.Color = sColor;

                                        if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)
                                            atRoiInput{aRoisTagOffset(ro)}.Object.Color = sColor;
                                        end

                                    end
                                    
                                    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);                                    
                                end
                            end
                        end
                    end

                end
            end
        end
        
        function figVoiSimplifiedHideViewFaceAlhaCallback(~, ~)
            
            aVoiRoiTag = voiTag('get', get(uiSeriesPtr('get'), 'Value'));

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                      
            if ~isempty(aVoiRoiTag)
                
                % Search for a voi tag, if we don't find one, then the tag is            
                % roi
                
                if isempty(atVoiInput) 
                    aTagOffset = 0;
                else           
                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );
                end

                if aTagOffset(aTagOffset==1) % tag is a voi

                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)
                        figVoiSimplifiedSetRoiFaceAlpha(atVoiInput{dTagOffset});
                    end

                else % Tag is a ROI
                    
                    if isempty(atRoiInput)
                        aTagOffset = 0;
                    else
                        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag} );            
                    end

                    if aTagOffset(aTagOffset==1) % tag is a roi

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)

                            if isvalid(atRoiInput{dTagOffset}.Object)

                                figVoiSimplifiedSetRoiFaceAlpha(atRoiInput{dTagOffset});
                            end

                        end
                    end
                end
            end

            function figVoiSimplifiedSetRoiFaceAlpha(ptrObject)
                                
                atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                
                if strcmpi(ptrObject.ObjectType, 'voi') % Object is a voi

                    if ~isempty(atVoiInput) && ~isempty(atRoiInput)
                        
                        aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {ptrObject.Tag} );
                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)
                            
                            dFaceAlpha = 0;

                            % Set roi template voi\roi face alpha 

                            aRoisTagOffset = zeros(1, numel(ptrObject.RoisTag));

                            if ~isempty(atRoiInput)

                                for ro=1:numel(ptrObject.RoisTag)
                                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrObject.RoisTag{ro}]} );
                                    aRoisTagOffset(ro) = find(aTagOffset, 1);    
                                end

                                if numel(ptrObject.RoisTag)
                                    
                                    if atRoiInput{aRoisTagOffset(1)}.FaceAlpha == 0
                                        dFaceAlpha = roiFaceAlphaValue('get');
                                    end
                                    
                                    for ro=1:numel(ptrObject.RoisTag)
                                        
                                        if ~strcmpi(atRoiInput{aRoisTagOffset(ro)}.Type, 'images.roi.line')

                                            atRoiInput{aRoisTagOffset(ro)}.FaceAlpha = dFaceAlpha;

                                            if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)
                                                atRoiInput{aRoisTagOffset(ro)}.Object.FaceAlpha = dFaceAlpha;
                                            end
                                        end

                                    end
                                    
                                    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);                                    
                                end
                            end               

                        end
                    end
                end               
            end
        end

        function figVoiSimplifiedDeleteObject(pVoiRoiTag, bUpdateVoiRoiListbox)
        
            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
                    
            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                        
    
            if ~isempty(pVoiRoiTag)
                
                % Search for a voi tag, if we don't find one, then the tag is            
                % roi
    
                if isempty(atVoiInput)
                    aTagOffset = 0;
                else
                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), pVoiRoiTag );
                end
    
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
                                             roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                                        end
                                    end
    
                                    % Delete farthest distance objects
                        
                                    if ~isempty(atRoiInput{aRoisTagOffset(ro)}.MaxDistances)
                                        objectsToDelete = [atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Line, ...
                                                           atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Line, ...
                                                           atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxXY.Text, ...
                                                           atRoiInput{aRoisTagOffset(ro)}.MaxDistances.MaxCY.Text];
                                        delete(objectsToDelete(isvalid(objectsToDelete)));
                                    end                   
                                    
                                    % Delete ROI object 
                                    
                                    if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)
                                        delete(atRoiInput{aRoisTagOffset(ro)}.Object)
                                    end
    
                                    atRoiInput{aRoisTagOffset(ro)} = [];
                                end
    
                                atRoiInput(cellfun(@isempty, atRoiInput)) = [];
    
                                roiTemplate('set', dSeriesOffset, atRoiInput);  
                            end
                        end
    
                        % Clear voi from voi input template
    
                        atVoiInput(dTagOffset) = [];            
    %                        atVoiInput(cellfun(@isempty, atVoiInput)) = [];
    
                        voiTemplate('set', dSeriesOffset, atVoiInput);
    
    
                        % Refresh contour figure
    
                        setVoiRoiSegPopup();
    
                        if bUpdateVoiRoiListbox
    
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
    
                            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);
                        end
                    end 
                end
            end
        end           
    end

    function setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented)

        aVoiTag = [];

        sLbWindow = '';

        sFontName = get(lbVoiRoiWindow, 'FontName');

        atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

        atInput = inputTemplate('get');
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

%         try

        set(figVoiSimplifiedWindow, 'Pointer', 'watch');
        drawnow;

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        tQuant = quantificationTemplate('get');

        if isfield(tQuant, 'tSUV')
            dSUVScale = tQuant.tSUV.dScale;
        else
            dSUVScale = 0;
        end

        aInput = inputBuffer('get');

        if     strcmpi(imageOrientation('get'), 'axial')
            aInputBuffer = aInput{dSeriesOffset};
        elseif strcmpi(imageOrientation('get'), 'coronal')
            aInputBuffer = reorientBuffer(aInput{dSeriesOffset}, 'coronal');
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            aInputBuffer = reorientBuffer(aInput{dSeriesOffset}, 'sagittal');
        end
        
        if size(aInputBuffer, 3) ==1
            
            if atInput(dSeriesOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if atInput(dSeriesOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if atInput(dSeriesOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if atInput(dSeriesOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if atInput(dSeriesOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end   
        
        atInputMetaData = atInput(dSeriesOffset).atDicomInfo;

        aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        
        bDoseKernel      = atInput(dSeriesOffset).bDoseKernel;
        bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

        dNbVois = numel(atVoiInput);
        if ~isempty(atVoiInput)
            for aa=1:dNbVois

                if ~isempty(atVoiInput{aa}.RoisTag)

                    if dNbVois > 10
                        if mod(aa, 5)==1 || aa == dNbVois
                            progressBar(aa/dNbVois-0.0001, sprintf('Computing voi %d/%d', aa, dNbVois ) );
                        end
                    end

                    tMaxDistances = computeVoiPlanesFarthestPoint( atVoiInput{aa}, atRoiInput, atMetaData, aDisplayBuffer, false);

                    [tVoiComputed, ~] = ...
                        computeVoi(aInputBuffer, ...
                                   atInputMetaData, ...
                                   aDisplayBuffer, ...
                                   atMetaData, ...
                                   atVoiInput{aa}, ...
                                   atRoiInput, ...
                                   dSUVScale, ...
                                   bSUVUnit, ...
                                   bModifiedMatrix, ...
                                   bSegmented, ...
                                   bDoseKernel, ...
                                   bMovementApplied);
                   
                    if ~isempty(tVoiComputed)

                        sVoiName = atVoiInput{aa}.Label;

                        if isempty(tMaxDistances.Coronal)
                            sMaxCoronal = 'NaN';
                        else
                            sMaxCoronal = num2str(tMaxDistances.Coronal.MaxLength);
                        end

                        if isempty(tMaxDistances.Sagittal)
                            sMaxSagittal = 'NaN';
                        else
                            sMaxSagittal = num2str(tMaxDistances.Sagittal.MaxLength);
                        end

                        if isempty(tMaxDistances.Axial)
                            sMaxAxial = 'NaN';
                        else
                            sMaxAxial = num2str(tMaxDistances.Axial.MaxLength);
                        end

                        sLine = sprintf('%-18s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                            maxStringLength(sVoiName, 17), ...
                            num2str(tVoiComputed.cells), ...
                            num2str(tVoiComputed.sum), ...
                            num2str(tVoiComputed.mean), ...
                            num2str(tVoiComputed.min), ...
                            num2str(tVoiComputed.max), ...
                            num2str(tVoiComputed.median), ...
                            num2str(tVoiComputed.std), ...
                            num2str(tVoiComputed.peak), ...
                            sMaxCoronal, ...
                            sMaxSagittal, ...
                            sMaxAxial, ...
                            num2str(tVoiComputed.volume));

                        if isfigVoiSimplifiedInColor('get') == true
                            sLine = strrep(sLine, ' ', '&nbsp;');

                            aColor = atVoiInput{aa}.Color;
                            sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                            sLine  = sprintf('<HTML><FONT color="%s" face="%s"><b>%s</b>', sColor, sFontName, sLine);
                        end

                        sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                        if ~isempty(aVoiTag)

                            aVoiTag{numel(aVoiTag)+1}.Tag = atVoiInput{aa}.Tag;

                        else
                            aVoiTag{1}.Tag = atVoiInput{aa}.Tag;
                        end

                    end
                end
            end
        end

        if isvalid(lbVoiRoiWindow)

            dListboxTop   = get(lbVoiRoiWindow, 'ListboxTop');
            dListboxValue = get(lbVoiRoiWindow, 'Value');

            set(lbVoiRoiWindow, 'Value', 1);
            set(lbVoiRoiWindow, 'String', sLbWindow);
            if size(lbVoiRoiWindow.String, 1) > 0
                lbVoiRoiWindow.String(end,:) = [];
            end
            set(lbVoiRoiWindow, 'ListboxTop', dListboxTop);

            if dListboxValue < size(lbVoiRoiWindow.String, 1)
                set(lbVoiRoiWindow, 'Value', dListboxValue);
            else
                set(lbVoiRoiWindow, 'Value', size(lbVoiRoiWindow.String, 1));
            end
        end

        voiTag('set', aVoiTag);

        progressBar(1, 'Ready');

%         catch
%             progressBar(1, 'Error:setVoiSimplifiedListbox()');
%         end

        clear aInput;
        clear aInputBuffer;
        clear aDisplayBuffer;

        set(figVoiSimplifiedWindow, 'Pointer', 'default');
        drawnow;

    end

    function copyVoiDialogDisplayCallback(~, ~)

        try

            set(figVoiSimplifiedWindow, 'Pointer', 'watch');

%            rdr = get(hFig,'Renderer');
            inv = get(figVoiSimplifiedWindow,'InvertHardCopy');

%            set(hFig,'Renderer','Painters');
            set(figVoiSimplifiedWindow,'InvertHardCopy','Off');

            drawnow;
            hgexport(figVoiSimplifiedWindow,'-clipboard');

%            set(hFig,'Renderer',rdr);
            set(figVoiSimplifiedWindow,'InvertHardCopy',inv);
        catch
            progressBar(1, 'Error:copyVoiDialogDisplayCallback()');
        end

        set(figVoiSimplifiedWindow, 'Pointer', 'default');
    end

    function figVoiSimplifiedSUVUnitCallback(hObject, ~)
        
        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on') 
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end
                
        if strcmpi(hObject.Checked, 'on')

            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);
            
            setVoiSimplifiedListbox(false, bModifiedMatrix, false);           
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);
            
            setVoiSimplifiedListbox(true, bModifiedMatrix, false);
        end

        setVoiSimplifiedFigureName();
    end

    function figVoiSimplifiedModifiedMatrixCallback(hObject, ~)
        
        atInput = inputTemplate('get');

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        
        if strcmpi(get(mSUVUnit, 'Checked'), 'on')
            bSUVUnit = true;
        else
            bSUVUnit = false;
        end
        
        
        if strcmpi(hObject.Checked, 'on')
            
            if atInput(dSeriesOffset).tMovement.bMovementApplied == true
                modifiedMatrixValueMenuOption('set', true);                         
                hObject.Checked = 'on';
                
                setVoiSimplifiedListbox(bSUVUnit, true, false);           
            else
                modifiedMatrixValueMenuOption('set', false);                         
                hObject.Checked = 'off';      
                
                segMenuOption('set', false);
                
                setVoiSimplifiedListbox(bSUVUnit, false, false);           
            end
        else
            modifiedMatrixValueMenuOption('set', true);                               
            hObject.Checked = 'on';
            
            setVoiSimplifiedListbox(bSUVUnit, true, false);
       end

        setVoiSimplifiedFigureName();
    end

    function figVoiSimplifiedColorCallback(~, ~)

        if strcmpi(get(mColorBackground, 'Checked'), 'on')
            set(mColorBackground, 'Checked', 'off');
            isFigRoiInColor('set', false);
        else
            set(mColorBackground, 'Checked', 'on');
            isFigRoiInColor('set', true);
        end

        if isFigRoiInColor('get') == true
            aBackgroundColor = viewerAxesColor('get');
        else
            aBackgroundColor = [0.9800 0.9800 0.9800];
        end

        set(lbVoiRoiWindow, 'BackgroundColor', aBackgroundColor);

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
            
        setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);

    end

    function exportCurrentSeriesSimplifiedReportCallback(~, ~)

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

        exportSimplifiedContoursReport(bSUVUnit, bModifiedMatrix, false);

    end

end