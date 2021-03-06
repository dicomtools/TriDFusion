function figRoiDialogCallback(hObject, ~)
%function figRoiDialogCallback(hObject,~)
%Figure ROI Result Main Function.
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

    ROI_PANEL_X = 1350;
    ROI_PANEL_Y = 600;
    
    tInput = inputTemplate('get');

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(tInput)
        return;
    end
        
    releaseRoiWait();

    if strcmpi(get(hObject, 'Tag'), 'toolbar')
       set(hObject, 'State', 'off');
    end

    cummulativeMenuOption('set', false);
    histogramMenuOption('set', false);
    profileMenuOption('set', false);

    figRoiWindow = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-ROI_PANEL_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-ROI_PANEL_Y/2) ...
               ROI_PANEL_X ...
               ROI_PANEL_Y],...
               'Name', 'ROIs/VOIs result',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Toolbar','none'...
               );
    figRoiWindowPtr('set', figRoiWindow);       

    set(figRoiWindow, 'WindowButtonDownFcn', @roiClickDown);

    mRoiFile = uimenu(figRoiWindow,'Label','File');
    uimenu(mRoiFile,'Label', 'Export to Excel...','Callback', @exportCurrentSeriesResultCallback);
    uimenu(mRoiFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mRoiOptions = uimenu(figRoiWindow,'Label','Options');

    if suvMenuUnitOption('get') == true && ...
       tInput(dOffset).bDoseKernel == false
        sSuvChecked = 'on';
    else
        sSuvChecked = 'off';
    end

    if segMenuOption('get') == true && ...
        tInput(dOffset).bDoseKernel == false

        sSegChecked = 'on';
    else
        sSegChecked = 'off';
    end

    if tInput(dOffset).bDoseKernel == true
        sSuvEnable = 'off';
    else
        sSuvEnable = 'on';
    end
    
    if isFigRoiInColor('get') == true
        sFigRoiInColor = 'on';
    else
        sFigRoiInColor = 'off';
    end
    
    mSUVUnit         = uimenu(mRoiOptions,'Label', 'SUV Unit', 'Checked', sSuvChecked, 'Enable', sSuvEnable, 'Callback', @SUVUnitCallback);
    mSegmented       = uimenu(mRoiOptions,'Label', 'Segmented Values', 'Checked', sSegChecked, 'Callback', @segmentedCallback);
    mColorBackground = uimenu(mRoiOptions,'Label', 'Display in Color', 'Checked', sFigRoiInColor, 'Callback', @figRoiColorCallback);
   
    mRoiReset    = uimenu(figRoiWindow,'Label','Reset');
    mRoiResetAll = uimenu(mRoiReset,'Label', 'Clear All ROIs', 'Checked', 'off', 'Callback', @clearAllRoisCallback);

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(figRoiWindow,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

%             uiRoiWindow = ...
%                 uipanel(figRoiWindow,...
%                         'Units'   , 'pixels',...
%                         'position', figRoiWindow.Position,...
%                         'title'   , 'DICOM Database List'...
%                         );

    uiVoiRoiWindow = ...
        uipanel(figRoiWindow,...
                'Units'   , 'pixels',...
                'BorderWidth', 0,...
                'HighlightColor', [0 1 1],...
                'position', [0 0 ROI_PANEL_X ROI_PANEL_Y]...
               );
           
    if isFigRoiInColor('get') == true
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
                  'Callback', @lbMainWindowCallback...
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
               'String'  , 'Image Number'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'NB Pixels'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Total'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Mean'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Min'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Max'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Median'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                   
               'String'  , 'Deviation'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Peak'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1050 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Area cm2'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Volume cm3'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                    
               'String'  , 'Subtraction'...
               );

    tRoiMetaData = dicomMetaData('get');

    if strcmpi(mSUVUnit.Checked, 'on')
        bSUVUnit = true;
    else
        bSUVUnit = false;
    end

    if strcmpi(mSegmented.Checked, 'on') && ...
       tInput(dOffset).bDoseKernel == false     
        bSegmented = true;
    else
        bSegmented = false;
    end

    setVoiRoiListbox(bSUVUnit, bSegmented);

    setRoiFigureName();


    function roiClickDown(~, ~)
        
        if strcmp(get(figRoiWindow,'selectiontype'),'alt')

            bDispayMenu = false;

            adOffset = get(lbVoiRoiWindow, 'Value');
            asRoiWindow = cellstr(get(lbVoiRoiWindow, 'String'));
            if isempty(char(asRoiWindow(end)))
                asRoiWindow = asRoiWindow(1:end-1);
            end

            if numel(adOffset) < 2
                c = uicontextmenu(figRoiWindow);
                lbVoiRoiWindow.UIContextMenu = c;

                uimenu(c,'Label', 'Delete Object', 'Callback',@figRoiDeleteObjectCallback);

                uimenu(c,'Label', 'Edit Label', 'Separator', 'on', 'Callback',@figRoiEditLabelCallback);

                mList = uimenu(c,'Label', 'Predefined Label');
                aList = getRoiLabelList();
                for pp=1:numel(aList)
                    uimenu(mList,'Text', aList{pp}, 'MenuSelectedFcn', @figRoiPredefinedLabelCallback);
                end

                uimenu(c,'Label', 'Edit Color', 'Callback',@figRoiEditColorCallback);
                uimenu(c,'Label', 'Hide/View Face Alpha', 'Callback', @figRoiHideViewFaceAlhaCallback); 

                uimenu(c,'Label', 'Bar Histogram'  , 'Separator', 'on' , 'Callback',@figRoiHistogramCallback);
                uimenu(c,'Label', 'Cummulative DVH', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);

                aVoiRoiTag = voiRoiTag('get');
                tRoiInput = roiTemplate('get');
                if ~isempty(tRoiInput)
                    for cc=1:numel(tRoiInput)
                        if isvalid(tRoiInput{cc}.Object)
                            if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                                if strcmpi(tRoiInput{cc}.Type, 'images.roi.line')
                                    uimenu(c,'Label', 'Profile', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);
                                end
                            end
                        end
                    end
                end

 %       switch lower(tInitInput(iOffset).tRoi{bb}.Type)
 %           case lower('images.roi.line')

                return;
            end

            for i=1: numel(adOffset)
                if numel(asRoiWindow) > adOffset(i)
                    sLine = asRoiWindow(adOffset(i));
                    if strlength(sLine)
                        bDispayMenu = true;
                        break;
                    end
                end
            end

            if bDispayMenu == true && size(dicomBuffer('get'), 3) ~= 1
                c = uicontextmenu(figRoiWindow);
                lbVoiRoiWindow.UIContextMenu = c;

                uimenu(c,'Label', 'Create Volume', 'Separator', 'off', 'Callback',@figRoiCreateVolumeCallback);
                uimenu(c,'Label', 'Cummulative DVH', 'Separator', 'on' , 'Callback',@figRoiMultiplePlotCallback);
                
            else
                lbVoiRoiWindow.UIContextMenu = [];
            end
                        
        end

        function figRoiHistogramCallback(hObject, ~)            
                        
            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if     strcmpi(get(hObject, 'Label'), 'Bar Histogram')

                histogramMenuOption('set', true);
                cummulativeMenuOption('set', false);
                profileMenuOption('set', false);
            elseif strcmpi(get(hObject, 'Label'), 'Cummulative DVH')

                histogramMenuOption('set', false);
                cummulativeMenuOption('set', true);
                profileMenuOption('set', false);
            else

                histogramMenuOption('set', false);
                cummulativeMenuOption('set', false);
                profileMenuOption('set', true);
            end

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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


                        figRoiHistogram(tVoiInput{aa}, bSUVUnit, tInput(dOffset).bDoseKernel, bSegmented, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Sub);
                        return;
                    end

                 end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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

                            figRoiHistogram(tRoiInput{cc}, bSUVUnit, tInput(dOffset).bDoseKernel, bSegmented, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Sub);
                            return;
                       end
                    end
                end
            end
        end

        function figRoiCreateVolumeCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            for hh=1:numel(aVoiRoiTag)
                asTag{hh}=aVoiRoiTag{hh}.Tag;
            end

            createVoiFromRois(asTag(get(lbVoiRoiWindow, 'Value')));

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

            setVoiRoiListbox(bSUVUnit, bSegmented);

            setVoiRoiSegPopup();

        end
        
        function figRoiMultiplePlotCallback(hObject, ~)
            
            aVoiRoiTag = voiRoiTag('get');
            
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
            
            sType = get(hObject, 'Label');
            atVoiRoiTag = aVoiRoiTag(get(lbVoiRoiWindow, 'Value'));
         
            figRoiMultiplePlot(sType, ...
                               atVoiRoiTag, ...
                               bSUVUnit, ...
                               tInput(dOffset).bDoseKernel, ...
                               bSegmented ...
                               );

        end

        function figRoiDeleteObjectCallback(~, ~)
            
            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        figRoiDeleteObject(tVoiInput{aa}, 'voi');

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

                        setVoiRoiListbox(bSUVUnit, bSegmented);
                        return;
                    end

                end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value}.Tag)

                            figRoiDeleteObject(tRoiInput{cc}, 'roi');

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

                            setVoiRoiListbox(bSUVUnit, bSegmented);

                            return;
                        end
                    end
                end
            end

            function figRoiDeleteObject(ptrObject, sType)

                iOffset = get(uiSeriesPtr('get'), 'Value');    
                tDeleteInput = inputTemplate('get');
    
                tRoiInput = roiTemplate('get');
                tVoiInput = voiTemplate('get');
            
                if strcmpi(sType, 'voi')
                    if isfield(tDeleteInput(iOffset), 'tVoi')
                        for vv=1:numel(ptrObject.RoisTag)
                            for rr=1:numel(tDeleteInput(iOffset).tRoi)    
                                if strcmpi(ptrObject.RoisTag{vv}, tDeleteInput(iOffset).tRoi{rr}.Tag)
                                    
                                    tDeleteInput(iOffset).tRoi{rr} = []; 
                                    break;
                                end
                               
                            end    
                            
                            tDeleteInput(iOffset).tRoi(cellfun(@isempty, tDeleteInput(iOffset).tRoi)) = [];                           
                        end
                        
                        inputTemplate('set', tDeleteInput);
                                                
                        for vv=1:numel(ptrObject.RoisTag)
                            for rr=1:numel(tRoiInput)    
                                if strcmpi(ptrObject.RoisTag{vv}, tRoiInput{rr}.Tag)
                                    
                                    delete(tRoiInput{rr}.Object);                                                                                   
                                    tRoiInput{rr} = []; 
                                    break;
                                end
                               
                            end    
                            
                            tRoiInput(cellfun(@isempty, tRoiInput)) = [];                           
                        end                        
                        
                        roiTemplate('set', tRoiInput);
                        
                        for vv=1:numel(tDeleteInput(iOffset).tVoi)
                            if strcmpi(ptrObject.Tag, tDeleteInput(iOffset).tVoi{vv}.Tag)
                                tDeleteInput(iOffset).tVoi{vv} = [];
                                break;
                            end                            
                        end
                        
                        tDeleteInput(iOffset).tVoi(cellfun(@isempty, tDeleteInput(iOffset).tVoi)) = [];                                                        
                        inputTemplate('set', tDeleteInput);

                        for vv=1:numel(tVoiInput)
                            if strcmpi(ptrObject.Tag, tVoiInput{vv}.Tag)
                                tVoiInput{vv} = [];
                                break;
                            end                            
                        end
                        
                        tVoiInput(cellfun(@isempty, tVoiInput)) = [];                                
                        voiTemplate('set', tVoiInput);
                        
                    end                    
                else
                    if isfield(tDeleteInput(iOffset), 'tVoi')
                        for vv=1:numel(tDeleteInput(iOffset).tVoi)
                            for tt=1: numel(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                                if strcmpi(tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt}, ptrObject.Tag)

                                    tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt} = [];
                                    tDeleteInput(iOffset).tVoi{vv}.RoisTag(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.RoisTag)) = [];

                                    tDeleteInput(iOffset).tVoi{vv}.tMask{tt} = [];
                                    tDeleteInput(iOffset).tVoi{vv}.tMask(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.tMask)) = [];

                                    if isempty(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                                        tDeleteInput(iOffset).tVoi{vv} = [];
                                        tDeleteInput(iOffset).tVoi(cellfun(@isempty, tDeleteInput(iOffset).tVoi)) = [];
                                    end

                                    inputTemplate('set', tDeleteInput);
                                    break;
                                end
                            end
                        end 
                    end
                    
                    if isfield(tDeleteInput(iOffset), 'tRoi')                   
                        for rr=1:numel(tDeleteInput(iOffset).tRoi)    
                            if strcmpi(ptrObject.Tag, tDeleteInput(iOffset).tRoi{rr}.Tag)

                                tDeleteInput(iOffset).tRoi{rr} = []; 
                                tDeleteInput(iOffset).tRoi(cellfun(@isempty, tDeleteInput(iOffset).tRoi)) = [];                           

                                inputTemplate('set', tDeleteInput);
                                break;
                            end
                        end
                    end
                    
                    for vv=1:numel(tVoiInput)
                        for tt=1:numel(tVoiInput{vv}.RoisTag)
                            if strcmpi(tVoiInput{vv}.RoisTag{tt}, ptrObject.Tag)

                                tVoiInput{vv}.RoisTag{tt} = [];
                                tVoiInput{vv}.RoisTag(cellfun(@isempty, tVoiInput{vv}.RoisTag)) = [];

                                tVoiInput{vv}.tMask{tt} = [];
                                tVoiInput{vv}.tMask(cellfun(@isempty, tVoiInput{vv}.tMask)) = [];

                                if isempty(tVoiInput{vv}.RoisTag)
                                    tVoiInput{vv} = [];
                                    tVoiInput(cellfun(@isempty, tVoiInput)) = [];
                                end
                                
                                voiTemplate('set', tVoiInput);
                                break;
                            end
                        end
                      
                    end                    
                    
                    for rr=1:numel(tRoiInput)    
                        if strcmpi(ptrObject.Tag, tRoiInput{rr}.Tag)

                            delete(tRoiInput{rr}.Object);                                                                                   
                            tRoiInput{rr} = []; 
                            tRoiInput(cellfun(@isempty, tRoiInput)) = [];                           

                            roiTemplate('set', tRoiInput);
                            break;
                        end
                    end 
                                        
                end
                
                setVoiRoiSegPopup();

            end
        end

        function figRoiPredefinedLabelCallback(hObject, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        figRoiSetLabel(tVoiInput{aa}, hObject.Text)

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

                        setVoiRoiListbox(bSUVUnit, bSegmented);
                        return;
                    end

                end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                            figRoiSetLabel(tRoiInput{cc}, hObject.Text);

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

                            setVoiRoiListbox(bSUVUnit, bSegmented);

                            return;
                        end
                    end
                end
            end

            setVoiRoiSegPopup();

        end

        function figRoiEditLabelCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        figRoiEditLabelDialog(tVoiInput{aa});

                        return;
                    end

                end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                            figRoiEditLabelDialog(tRoiInput{cc});

                            return;
                        end
                    end
                end
            end

            function figRoiEditLabelDialog(ptrObject)

                EDIT_DIALOG_X = 310;
                EDIT_DIALOG_Y = 100;

                figRoiPosX = figRoiWindow.Position(1);
                figRoiPosY = figRoiWindow.Position(2);
                figRoiSizeX = figRoiWindow.Position(3);
                figRoiSizeY = figRoiWindow.Position(4);

                figRoiEditLabelWindow = ...
                    dialog('Position', [(figRoiPosX+(figRoiSizeX/2)-EDIT_DIALOG_X/2) ...
                           (figRoiPosY+(figRoiSizeY/2)-EDIT_DIALOG_Y/2) ...
                           EDIT_DIALOG_X ...
                           EDIT_DIALOG_Y],...
                          'Color', viewerBackgroundColor('get'), ...
                           'Name', 'Edit Label'...
                           );

%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(figRoiEditLabelWindow, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

                uicontrol(figRoiEditLabelWindow,...
                          'style'   , 'text',...
                          'string'  , 'Label Name:',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'position', [20 52 80 25]...
                          );

                edtFigRoiLabelName = ...
                    uicontrol(figRoiEditLabelWindow,...
                          'style'     , 'edit',...
                          'horizontalalignment', 'left',...
                          'Background', 'white',...
                          'string'    , ptrObject.Label,...
                          'position'  , [100 55 150 25], ...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                          
                          'Callback', @acceptFigRoiEditLabelCallback...
                          );

                % Cancel or Proceed

                uicontrol(figRoiEditLabelWindow,...
                          'String','Cancel',...
                          'Position',[200 7 100 25],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                         
                          'Callback', @cancelFigRoiEditLabelCallback...
                          );

                uicontrol(figRoiEditLabelWindow,...
                          'String','Ok',...
                          'Position',[95 7 100 25],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                         
                          'Callback', @acceptFigRoiEditLabelCallback...
                          );

                function cancelFigRoiEditLabelCallback(~, ~)
                    delete(figRoiEditLabelWindow);
                end

                function acceptFigRoiEditLabelCallback(~, ~)

                    figRoiSetLabel(ptrObject, get(edtFigRoiLabelName, 'String'))

                    delete(figRoiEditLabelWindow);

                    if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                        bSUVUnit = true;
                    else
                        bSUVUnit = false;
                    end

                    if strcmpi(get(mSegmented, 'Checked'), 'on') && ...
                       tInput(dOffset).bDoseKernel == false     
                        bSegmented = true;
                    else
                        bSegmented = false;
                    end

                    setVoiRoiListbox(bSUVUnit, bSegmented);
                end
            end

            setVoiRoiSegPopup();

        end

        function figRoiSetLabel(ptrObject, sLabel)
                                        
            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if strcmpi(ptrObject.ObjectType, 'voi')

                % Set voi Label
                for ff=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{ff}.Tag, ptrObject.Tag)

                        tVoiInput{ff}.Label = sLabel;
                        voiTemplate('set', tVoiInput);
                        break
                    end
                end
                
                % Set rois label
                dRoiNb = 0;
                for bb=1:numel(ptrObject.RoisTag)

                    for vv=1:numel(tRoiInput)
                        if isvalid(tRoiInput{vv}.Object)
                            if strcmpi(tRoiInput{vv}.Tag, ptrObject.RoisTag{bb})

                                dRoiNb = dRoiNb+1;
                                sRoiLabel =  sprintf('%s (roi %d/%d)', sLabel, dRoiNb, numel(ptrObject.RoisTag));
                                tRoiInput{vv}.Label = sRoiLabel;
                                tRoiInput{vv}.Object.Label = sRoiLabel;

                                roiTemplate('set', tRoiInput);
                                break;
                            end
                        end
                    end                                                           
                end
            else
                for vv=1:numel(tRoiInput)
                    if isvalid(tRoiInput{vv}.Object)
                        if strcmpi(tRoiInput{vv}.Tag, ptrObject.Tag)

                            tRoiInput{vv}.Label = sLabel;
                            tRoiInput{vv}.Object.Label = sLabel;

                            roiTemplate('set', tRoiInput);
                            break;
                        end
                    end
                end                  
            end
        end

        function figRoiEditColorCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        sColor = uisetcolor([tVoiInput{aa}.Color], 'Select a color');

                        figRoiSetColor(tVoiInput{aa}, sColor)
                        return;
                    end

                end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                            sColor = uisetcolor([tRoiInput{cc}.Color], 'Select a color');

                            figRoiSetColor(tRoiInput{cc}, sColor);
                            return;
                        end
                    end
                end
            end

            function figRoiSetColor(ptrObject, sColor)
                                                
                tRoiInput = roiTemplate('get');
                tVoiInput = voiTemplate('get');
            
                if strcmpi(ptrObject.ObjectType, 'voi')

                    % Set voi color
                    
                    for ff=1:numel(tVoiInput)
                        if strcmpi(tVoiInput{ff}.Tag, ptrObject.Tag)

                            tVoiInput{ff}.Color = sColor;
                            voiTemplate('set', tVoiInput);
                            break;
                        end
                    end                  

                    % Set rois color

                    for bb=1:numel(ptrObject.RoisTag)

                        for vv=1:numel(tRoiInput)
                            if isvalid(tRoiInput{vv}.Object)
                                if strcmpi(tRoiInput{vv}.Tag, ptrObject.RoisTag{bb})

                                    tRoiInput{vv}.Color = sColor;
                                    tRoiInput{vv}.Object.Color = sColor;

                                    roiTemplate('set', tRoiInput);
                                    break;
                                end
                            end
                        end
                       
                    end
                else
                    for vv=1:numel(tRoiInput)
                        if isvalid(tRoiInput{vv}.Object)
                            if strcmpi(tRoiInput{vv}.Tag, ptrObject.Tag)

                                tRoiInput{vv}.Color = sColor;
                                tRoiInput{vv}.Object.Color = sColor;

                                roiTemplate('set', tRoiInput);
                                break;
                            end
                        end
                    end                                      
                    
                end
                
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

                setVoiRoiListbox(bSUVUnit, bSegmented); 
                
            end
        end

        function figRoiHideViewFaceAlhaCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        figRoiSetRoiFaceAlpha(tVoiInput{aa})
                        return;
                    end

                end

            end

            if ~isempty(tRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
        
                            figRoiSetRoiFaceAlpha(tRoiInput{cc});                            
                            return;
                        end
                    end
                end
            end

            function figRoiSetRoiFaceAlpha(ptrObject)                                

                tRoiInput = roiTemplate('get');
                tVoiInput = voiTemplate('get');
                
                if strcmpi(ptrObject.ObjectType, 'voi')

                    % Set rois alpha
                    bSetAlpha = true;    
                    dAlpha = 0;
                    for bb=1:numel(ptrObject.RoisTag)

                        for vv=1:numel(tRoiInput)
                            if strcmpi(tRoiInput{vv}.Tag, ptrObject.RoisTag{bb})
                                if ~strcmpi(tRoiInput{vv}.Object.Type, 'images.roi.line')
                                    if bSetAlpha == true
                                        bSetAlpha = false;
                                        if tRoiInput{vv}.FaceAlpha == 0 
                                            dAlpha = 0.2;
                                        else
                                            dAlpha = 0;
                                        end
                                    end   
                                    
                                    tRoiInput{vv}.FaceAlpha = dAlpha;
                                    tRoiInput{vv}.Object.FaceAlpha = dAlpha;                                    
                                end
                            end  
                            
                        end
                        
                        roiTemplate('set', tRoiInput);                                                                                    

                    end
                else
                                                            
                    bSetAlpha = true;    
                    dAlpha = 0;
                    for vv=1:numel(tRoiInput)
                        if strcmpi(tRoiInput{vv}.Tag, ptrObject.Tag)
                            if ~strcmpi(tRoiInput{vv}.Object.Type, 'images.roi.line')
                                if bSetAlpha == true
                                    bSetAlpha = false;
                                    if tRoiInput{vv}.FaceAlpha == 0 
                                        dAlpha = 0.2;
                                    else
                                        dAlpha = 0;
                                    end
                                end   

                                tRoiInput{vv}.FaceAlpha = dAlpha;
                                tRoiInput{vv}.Object.FaceAlpha = dAlpha;     
                                break;
                            end
                        end  
                    end                    
                    
                    roiTemplate('set', tRoiInput);                                                                                                                      
                    
                end
            end
        end        
    end

    function setRoiFigureName()

        if ~isvalid(lbVoiRoiWindow)
            return;
        end       

        if tInput(dOffset).bDoseKernel == true
            sUnit =  'Unit: Dose';
        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnit = getSerieUnitValue(dOffset);
                if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(sUnit, 'SUV' )
                    sUnit =  'Unit: SUV Weight';
                else
                    if (strcmpi(tRoiMetaData{1}.Modality, 'ct'))
                       sUnit =  'Unit: HU';
                    else
                       sUnit =  'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(tRoiMetaData{1}.Modality, 'ct'))
                    sUnit =  'Unit: HU';
                 else
                    sUnit = getSerieUnitValue(dOffset);                     
                    if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(sUnit, 'SUV' )
                        sUnit =  'Unit: BQML';
                    else

                        sUnit =  'Unit: Counts';
                    end
                 end
            end
        end

        figRoiWindow.Name = ['ROI/VOI Result - ' tRoiMetaData{1}.SeriesDescription ' - ' sUnit];

    end

    function setVoiRoiListbox(bSUVUnit, bSegmented)
        
        sLbWindow = '';
        aVoiRoiTag = [];
        
        sFontName = get(lbVoiRoiWindow, 'FontName');

        atVoiMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInput)
            return;
        end

        try  

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;        
        
        tVoiInput = voiTemplate('get');
        tRoiInput = roiTemplate('get');
        tQuant = quantificationTemplate('get');

        if isfield(tQuant, 'tSUV')
            dSUVScale = tQuant.tSUV.dScale;
        else
            dSUVScale = 0;
        end

        aInput   = inputBuffer('get');
        if     strcmp(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{iOffset}, [3 1 2]);
        end

        aDisplayBuffer = dicomBuffer('get');
        
        if ~isempty(tVoiInput)
            for aa=1:numel(tVoiInput)

                progressBar(aa/numel(tVoiInput)-0.0001, sprintf('Computing VOI %d/%d', aa, numel(tVoiInput) ) );

                if ~isempty(tVoiInput{aa}.RoisTag)
                    [tVoiComputed, ~] = computeVoi(aInputBuffer, aDisplayBuffer, atVoiMetaData, tVoiInput{aa}, tRoiInput, dSUVScale, bSUVUnit, bSegmented);

                    sVoiName = tVoiInput{aa}.Label;

                    sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                        maxLength(sVoiName, 17), ...
                        ' ', ...
                        num2str(tVoiComputed.cells), ...
                        num2str(tVoiComputed.sum), ...
                        num2str(tVoiComputed.mean), ...
                        num2str(tVoiComputed.min), ...
                        num2str(tVoiComputed.max), ...
                        num2str(tVoiComputed.median), ...
                        num2str(tVoiComputed.std), ...
                        num2str(tVoiComputed.peak), ...
                        ' ', ...
                        num2str(tVoiComputed.volume));
                    
                    if isFigRoiInColor('get') == true                    
                        sLine = strrep(sLine, ' ', '&nbsp;');   

                        aColor = tVoiInput{aa}.Color;
                        sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                        sLine  = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                    end
                    
                    sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);
                                     
                    if exist('aVoiRoiTag', 'var')

                        dResizeArray = numel(aVoiRoiTag)+1;

                        aVoiRoiTag{dResizeArray}.Tag = tVoiInput{aa}.Tag;
                        if isfield(tVoiComputed, 'subtraction')
                            aVoiRoiTag{dResizeArray}.Sub = tVoiComputed.subtraction;
                        else
                            aVoiRoiTag{dResizeArray}.Sub = 0;
                        end

                    else
                         aVoiRoiTag{1}.Tag = tVoiInput{aa}.Tag;
                         if isfield(tVoiComputed, 'subtraction')
                            aVoiRoiTag{1}.Sub = tVoiComputed.subtraction;
                         else
                            aVoiRoiTag{1}.Sub =0;
                         end
                    end

                    dNbTags = numel(tVoiInput{aa}.RoisTag);
                    for cc=1:dNbTags
                        if dNbTags > 100
                            if mod(cc, 10)==1 || cc == dNbTags         
                                progressBar( cc/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', cc, dNbTags) );  
                            end             
                        end
                        for bb=1:numel(tRoiInput)
                           if isvalid(tRoiInput{bb}.Object)
                                if strcmpi(tVoiInput{aa}.RoisTag{cc}, tRoiInput{bb}.Tag)
                                                                        
                                    if tRoiInput{bb}.SliceNb <= numel(atVoiMetaData)
                                        tSliceMeta = atVoiMetaData{tRoiInput{bb}.SliceNb};
                                    else
                                        tSliceMeta = atVoiMetaData{1};
                                    end

                                    tRoiComputed = computeRoi(aInputBuffer, aDisplayBuffer, atVoiMetaData, tSliceMeta, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented);

                                    if strcmpi(tRoiInput{bb}.Axe, 'Axe')
                                        sSliceNb = num2str(tRoiInput{bb}.SliceNb);
                                    elseif strcmpi(tRoiInput{bb}.Axe, 'Axes1')
                                        sSliceNb = ['C:' num2str(tRoiInput{bb}.SliceNb)];
                                    elseif strcmpi(tRoiInput{bb}.Axe, 'Axes2')
                                        sSliceNb = ['S:' num2str(tRoiInput{bb}.SliceNb)];
                                    elseif strcmpi(tRoiInput{bb}.Axe, 'Axes3')
                                        sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-tRoiInput{bb}.SliceNb+1)];
                                    end

                                    if isfield(tRoiComputed, 'subtraction')
                                        sSubtraction = num2str(tRoiComputed.subtraction);
                                    else
                                        sSubtraction = 'N/A';
                                    end
                                    
                                    sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                                        ' ', ...
                                        sSliceNb, ...
                                        num2str(tRoiComputed.cells), ...
                                        num2str(tRoiComputed.sum), ...
                                        num2str(tRoiComputed.mean), ...
                                        num2str(tRoiComputed.min), ...
                                        num2str(tRoiComputed.max), ...
                                        num2str(tRoiComputed.median), ...
                                        num2str(tRoiComputed.std), ...
                                        num2str(tRoiComputed.peak), ...
                                        num2str(tRoiComputed.area), ...
                                        ' ', ...
                                        sSubtraction);
                                    
                                     if isFigRoiInColor('get') == true                                                       
                                         sLine = strrep(sLine, ' ', '&nbsp;');   

                                         aColor = tRoiInput{bb}.Color;
                                         sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                                         sLine  = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                                     end
                                     
                                     sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);
                        
                                     dResizeArray = numel(aVoiRoiTag)+1;

                                     aVoiRoiTag{dResizeArray}.Tag = tRoiInput{bb}.Tag;
                                     if isfield(tRoiComputed, 'subtraction')
                                        aVoiRoiTag{dResizeArray}.Sub = tRoiComputed.subtraction;
                                     else
                                        aVoiRoiTag{dResizeArray}.Sub = 0;
                                     end
                                     
                                     break;
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if ~isempty(tRoiInput) 
            dNbTags = numel(tRoiInput);
            for bb=1:dNbTags
               if dNbTags > 100
                   if mod(bb, 10)==1 || bb == dNbTags         
                       progressBar( bb/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );  
                   end         
               end
               if isvalid(tRoiInput{bb}.Object)
                    if strcmpi(tRoiInput{bb}.ObjectType, 'roi')

                        if tRoiInput{bb}.SliceNb <= numel(atVoiMetaData)
                            tSliceMeta = atVoiMetaData{tRoiInput{bb}.SliceNb};
                        else
                            tSliceMeta = atVoiMetaData{1};
                        end

                        tRoiComputed = computeRoi(aInputBuffer, aDisplayBuffer, atVoiMetaData, tSliceMeta, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented);

                        sRoiName = tRoiInput{bb}.Label;

                        if strcmpi(tRoiInput{bb}.Axe, 'Axe')
                            sSliceNb = num2str(tRoiInput{bb}.SliceNb);
                        elseif strcmpi(tRoiInput{bb}.Axe, 'Axes1')
                            sSliceNb = ['C:' num2str(tRoiInput{bb}.SliceNb)];
                        elseif strcmpi(tRoiInput{bb}.Axe, 'Axes2')
                            sSliceNb = ['S:' num2str(tRoiInput{bb}.SliceNb)];
                        elseif strcmpi(tRoiInput{bb}.Axe, 'Axes3')
                            sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-tRoiInput{bb}.SliceNb+1)];
                        end

                        if isfield(tRoiComputed ,'subtraction')
                            sSubtraction = num2str(tRoiComputed.subtraction);
                        else
                            sSubtraction = 'N/A';
                        end

                        sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                            maxLength(sRoiName, 17), ...
                            sSliceNb, ...
                            num2str(tRoiComputed.cells), ...
                            num2str(tRoiComputed.sum), ...
                            num2str(tRoiComputed.mean), ...
                            num2str(tRoiComputed.min), ...
                            num2str(tRoiComputed.max), ...
                            num2str(tRoiComputed.median), ...
                            num2str(tRoiComputed.std), ...
                            num2str(tRoiComputed.peak), ...
                            num2str(tRoiComputed.area), ...
                            ' ', ...
                            sSubtraction);                        

                        if isFigRoiInColor('get') == true                                            
                            sLine = strrep(sLine, ' ', '&nbsp;');   

                            aColor = tRoiInput{bb}.Color;
                            sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                            sLine = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                        end

                        sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                        if exist('aVoiRoiTag', 'var')
                            dResizeArray = numel(aVoiRoiTag)+1;
                            aVoiRoiTag{dResizeArray}.Tag = tRoiInput{bb}.Tag;
                            if isfield(tRoiComputed ,'subtraction')
                                aVoiRoiTag{dResizeArray}.Sub = tRoiComputed.subtraction;
                            else
                                aVoiRoiTag{dResizeArray}.Sub = 0;
                            end
                        else
                            aVoiRoiTag{1}.Tag = tRoiInput{bb}.Tag;
                            if isfield(tRoiComputed ,'subtraction')
                                aVoiRoiTag{1}.Sub = tRoiComputed.subtraction;
                            else
                                aVoiRoiTag{1}.Sub = 0;
                            end
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

        if exist('aVoiRoiTag', 'var')
            voiRoiTag('set', aVoiRoiTag);
        else
            voiRoiTag('set', '');
        end

        progressBar(1, 'Ready');
        
        catch
            progressBar(1, 'Error:setVoiRoiListbox()');           
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;        

    end

    function exportCurrentSeriesResultCallback(~, ~)

        tInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInput)
            return;
        end
        
        try            
            matlab.io.internal.getExcelInstance;
            bUseWritecell = false; 
        catch exception %#ok<NASGU>
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
            bUseWritecell = true; 
        end    

        atMetaData = dicomMetaData('get');

        tVoiInput = voiTemplate('get');
        tRoiInput = roiTemplate('get');

        aDisplayBuffer = dicomBuffer('get');

        aInput   = inputBuffer('get');
        if     strcmp(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{iOffset}, [3 1 2]);
        end

        if ~isempty(tRoiInput) || ...
           ~isempty(tVoiInput)

            filter = {'*.xlsx'};
     %       info = dicomMetaData('get');

            sCurrentDir  = viewerRootPath('get');

            sMatFile = [sCurrentDir '/' 'lastRoiDir.mat'];
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

            [file, path] = uiputfile(filter, 'Save ROI/VOI result', sprintf('%s/%s_%s_%s_roivoi_TriDFusion.xlsx' , ...
                sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription)) );
            if file ~= 0

                try
                    saveRoiLastUsedDir = [path '/'];
                    save(sMatFile, 'saveRoiLastUsedDir');
                catch
                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                    if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                    else
%                        sLogo = './logo.png';
%                    end

%                    javaFrame = get(h, 'JavaFrame');
%                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                end

                if exist(sprintf('%s%s', path, file), 'file')
                    delete(sprintf('%s%s', path, file));
                end

                tRoiQuant = quantificationTemplate('get');

                if isfield(tRoiQuant, 'tSUV')
                    dSUVScale = tRoiQuant.tSUV.dScale;
                else
                    dSUVScale = 0;
                end

                if strcmpi(mSUVUnit.Checked, 'on')
                    bSUVUnit = true;
                else
                    bSUVUnit = false;
                end
      %          sTabName = regexprep(figRoiWindow.Name, {' ','[',',','<','>','{','}','/','\',',^','%','!','$','*','(',')','@','#',']',':'}, '_');

                asVoiRoiHeader{1,1} = sprintf('Patient Name: %s', atMetaData{1}.PatientName);
                asVoiRoiHeader{2,1} = sprintf('Patient ID: %s', atMetaData{1}.PatientID);
                asVoiRoiHeader{3,1} = sprintf('Series Description: %s', atMetaData{1}.SeriesDescription);
                asVoiRoiHeader{4,1} = sprintf('Accession Number: %s', atMetaData{1}.AccessionNumber);
                asVoiRoiHeader{5,1} = sprintf('Series Date: %s', atMetaData{1}.SeriesDate);
                asVoiRoiHeader{6,1} = sprintf('Series Time: %s', atMetaData{1}.SeriesTime);
                
                if bUseWritecell == true
                    writecell(asVoiRoiHeader(:),sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A1');
                else
                    xlswrite(sprintf('%s%s', path, file), asVoiRoiHeader, 1, 'A1');
                end

                asVoiRoiTable{1,1}  = 'Name';
                asVoiRoiTable{1,2}  = 'Image number';
                asVoiRoiTable{1,3}  = 'NB Pixels';
                asVoiRoiTable{1,4}  = 'Total';
                asVoiRoiTable{1,5}  = 'Mean';
                asVoiRoiTable{1,6}  = 'Min';
                asVoiRoiTable{1,7}  = 'Max';
                asVoiRoiTable{1,8}  = 'Median';
                asVoiRoiTable{1,9}  = 'Deviation';
                asVoiRoiTable{1,10} = 'Peak';
                asVoiRoiTable{1,11} = 'Area cm2';
                asVoiRoiTable{1,12} = 'Volume cm3';
                asVoiRoiTable{1,13} = 'Subtraction';

                if bUseWritecell == true
                    writecell(asVoiRoiTable(1,:),sprintf('%s%s', path, file), 'Sheet',1, 'Range', 'A8');
                else
                    xlswrite(sprintf('%s%s', path, file), asVoiRoiTable, 1, 'A8');
                end

                dLineOffset = 9;
                if ~isempty(tVoiInput)
                    for aa=1:numel(tVoiInput)
                        if ~isempty(tVoiInput{aa}.RoisTag)
                            [tVoiComputed, ~] = computeVoi(aInputBuffer, aDisplayBuffer, atMetaData, tVoiInput{aa}, tRoiInput, dSUVScale, bSUVUnit, bSegmented);

                            sVoiName = tVoiInput{aa}.Label;

                            asVoiCell{1,aa}  = cellstr(sVoiName);
                            asVoiCell{2,aa}  = cellstr(' ');
                            asVoiCell{3,aa}  = tVoiComputed.cells;
                            asVoiCell{4,aa}  = tVoiComputed.sum;
                            asVoiCell{5,aa}  = tVoiComputed.mean;
                            asVoiCell{6,aa}  = tVoiComputed.min;
                            asVoiCell{7,aa}  = tVoiComputed.max;
                            asVoiCell{8,aa}  = tVoiComputed.median;
                            asVoiCell{9,aa}  = tVoiComputed.std;
                            asVoiCell{10,aa} = tVoiComputed.peak;
                            asVoiCell{11,aa} = cellstr(' ');
                            asVoiCell{12,aa} = tVoiComputed.volume;

                            sCell = sprintf('A%d', dLineOffset);
                            if bUseWritecell == true                            
                                writecell([asVoiCell{:,aa}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
                            else
                                xlswrite(sprintf('%s%s', path, file), [asVoiCell{:,aa}], 1, sCell);
                            end
                            
                            dLineOffset = dLineOffset+1;

                            for cc=1:numel(tVoiInput{aa}.RoisTag)
                                for bb=1:numel(tRoiInput)
                                   if isvalid(tRoiInput{bb}.Object)
                                        if strcmpi(tVoiInput{aa}.RoisTag{cc}, tRoiInput{bb}.Tag)

                                             if tRoiInput{bb}.SliceNb <= numel(atMetaData)
                                                tSliceMeta = atMetaData{tRoiInput{bb}.SliceNb};
                                             else
                                                tSliceMeta = atMetaData{1};
                                             end

                                            tRoiComputed = computeRoi(aInputBuffer, aDisplayBuffer, atMetaData, tSliceMeta, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented);

                                            if strcmpi(tRoiInput{bb}.Axe, 'Axe')
                                                sSliceNb = num2str(tRoiInput{bb}.SliceNb);
                                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes1')
                                                sSliceNb = ['C:' num2str(tRoiInput{bb}.SliceNb)];
                                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes2')
                                                sSliceNb = ['S:' num2str(tRoiInput{bb}.SliceNb)];
                                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes3')
                                                sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-tRoiInput{bb}.SliceNb+1)];
                                            end


                                            asRoiCell{1,bb}  = cellstr( ' ');
                                            asRoiCell{2,bb}  = cellstr(sSliceNb);
                                            asRoiCell{3,bb}  = tRoiComputed.cells;
                                            asRoiCell{4,bb}  = tRoiComputed.sum;
                                            asRoiCell{5,bb}  = tRoiComputed.mean;
                                            asRoiCell{6,bb}  = tRoiComputed.min;
                                            asRoiCell{7,bb}  = tRoiComputed.max;
                                            asRoiCell{8,bb}  = tRoiComputed.median;
                                            asRoiCell{9,bb}  = tRoiComputed.std;
                                            asRoiCell{10,bb} = tRoiComputed.peak;
                                            asRoiCell{11,bb} = tRoiComputed.area;
                                            asRoiCell{12,bb} = cellstr(' ');
                                            if isfield(tRoiComputed ,'subtraction')
                                                asRoiCell{13,bb} = tRoiComputed.subtraction;
                                            end

                                            sCell = sprintf('A%d', dLineOffset);
                                            if bUseWritecell == true                            
                                                writecell([asRoiCell{:,bb}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
                                            else
                                                xlswrite(sprintf('%s%s', path, file), [asRoiCell{:,bb}], 1, sCell);
                                            end
                                            
                                            dLineOffset = dLineOffset+1;

                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for bb=1:numel(tRoiInput)
                    if isvalid(tRoiInput{bb}.Object)
                        if strcmpi(tRoiInput{bb}.ObjectType, 'roi')

                            if tRoiInput{bb}.SliceNb <= numel(atMetaData)
                                tSliceMeta = atMetaData{tRoiInput{bb}.SliceNb};
                            else
                                tSliceMeta = atMetaData{1};
                            end

                            tRoiComputed = computeRoi(aInputBuffer, aDisplayBuffer, atMetaData, tSliceMeta, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented);

                            sRoiName = tRoiInput{bb}.Label;

                            if strcmpi(tRoiInput{bb}.Axe, 'Axe')
                                sSliceNb = num2str(tRoiInput{bb}.SliceNb);
                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes1')
                                sSliceNb = ['C:' num2str(tRoiInput{bb}.SliceNb)];
                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes2')
                                sSliceNb = ['S:' num2str(tRoiInput{bb}.SliceNb)];
                            elseif strcmpi(tRoiInput{bb}.Axe, 'Axes3')
                                sSliceNb = ['A:' num2str(size(dicomBuffer('get'), 3)-tRoiInput{bb}.SliceNb+1)];
                            end

                            asRoiCell{1,bb}  = cellstr(sRoiName);
                            asRoiCell{2,bb}  = cellstr(sSliceNb);
                            asRoiCell{3,bb}  = tRoiComputed.cells;
                            asRoiCell{4,bb}  = tRoiComputed.sum;
                            asRoiCell{5,bb}  = tRoiComputed.mean;
                            asRoiCell{6,bb}  = tRoiComputed.min;
                            asRoiCell{7,bb}  = tRoiComputed.max;
                            asRoiCell{8,bb}  = tRoiComputed.median;
                            asRoiCell{9,bb}  = tRoiComputed.std;
                            asRoiCell{10,bb} = tRoiComputed.peak;
                            asRoiCell{11,bb} = tRoiComputed.area;
                            asRoiCell{12,bb} = cellstr(' ');
                            if isfield(tRoiComputed ,'subtraction')
                                asRoiCell{13,bb} = tRoiComputed.subtraction;
                            end

                            sCell = sprintf('A%d', dLineOffset);
                            if bUseWritecell == true                            
                                writecell([asRoiCell{:,bb}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
                            else
                                xlswrite(sprintf('%s%s', path, file), [asRoiCell{:,bb}], 1, sCell);
                            end
                            dLineOffset = dLineOffset+1;

                        end
                    end
                end

                winopen(sprintf('%s%s', path, file));

                try
                    saveRoiLastUsedDir = path;
                    save(sMatFile, 'saveRoiLastUsedDir');
                catch
                        progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                        h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                        if integrateToBrowser('get') == true
%                            sLogo = './TriDFusion/logo.png';
%                        else
%                            sLogo = './logo.png';
%                        end

%                        javaFrame = get(h, 'JavaFrame');
%                        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                end

                progressBar(1, sprintf('Write %s%s completed', path, file));

            end
        end


    end

    function SUVUnitCallback(hObject, ~)

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            bSegmented = true;
        else
            bSegmented = false;
        end

        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            setVoiRoiListbox(false, bSegmented);
            suvMenuUnitOption('set', false);
        else
            hObject.Checked = 'on';
            setVoiRoiListbox(true, bSegmented);
            suvMenuUnitOption('set', true);
        end

        setRoiFigureName();
    end

    function segmentedCallback(hObject, ~)

        if strcmpi(get(mSUVUnit, 'Checked'), 'on')
            bSUVUnit = true;
        else
            bSUVUnit = false;
        end

        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            setVoiRoiListbox(bSUVUnit, false);
            segMenuOption('set', false);
        else
            hObject.Checked = 'on';
            setVoiRoiListbox(bSUVUnit, true);
            segMenuOption('set', true);
       end

        setRoiFigureName();
    end

    function lbMainWindowCallback(hObject, ~)

        aVoiRoiTag = voiRoiTag('get');
        tRoiInput = roiTemplate('get');

        if ~isempty(tRoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)
                        if size(dicomBuffer('get'), 3) == 1
                            if strcmpi(tRoiInput{cc}.Axe, 'Axe')
                            end
                        else
                            if strcmpi(tRoiInput{cc}.Axe, 'Axes1')

                                sliceNumber('set', 'coronal', tRoiInput{cc}.SliceNb);
                                refreshImages();

                                set( uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / size(dicomBuffer('get'), 1) );
                            end

                            if strcmpi(tRoiInput{cc}.Axe, 'Axes2')

                                sliceNumber('set', 'sagittal', tRoiInput{cc}.SliceNb);
                                refreshImages();

                                set( uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / size(dicomBuffer('get'), 2) );
                            end

                            if strcmpi(tRoiInput{cc}.Axe, 'Axes3')

                                sliceNumber('set', 'axial', tRoiInput{cc}.SliceNb);
                                refreshImages();

                                set( uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / size(dicomBuffer('get'), 3)) );
                            end
                        end
                    end
                end
            end
        end
    end

    function clearAllRoisCallback(~, ~)
        
        tDeleteInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tDeleteInput)
            return;
        end
        
        if ~isfield(tDeleteInput(iOffset), 'tRoi')
            return;
        end
        
        if isempty(tDeleteInput(iOffset).tRoi)
            return;
        end
                
        sAnswer = questdlg('Pressing will delete all ROIs', 'Warning', 'Delete', 'Exit', 'Exit');
        
        atRoi = roiTemplate('get');

        if strcmpi(sAnswer, 'Delete')
                                   
            if isfield(tDeleteInput(iOffset), 'tRoi')
                for rr=1:numel(atRoi)
                    delete(atRoi{rr}.Object);                                                                                   
                end
                                     
                tDeleteInput(iOffset).tRoi = [];
            end
            
            if isfield(tDeleteInput(iOffset), 'tVoi')
                tDeleteInput(iOffset).tVoi = [];
            end
            
            voiRoiTag('set', '');
                
            roiTemplate('reset');
            voiTemplate('reset');
            
            inputTemplate('set', tDeleteInput);  
            
            setVoiRoiSegPopup();            

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

            setVoiRoiListbox(bSUVUnit, bSegmented);            
                                   
        end
        
    end

    function figRoiColorCallback(~, ~)

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

        if strcmpi(get(mSegmented, 'Checked'), 'on')
            bSegmented = true;
        else
            bSegmented = false;
        end

        setVoiRoiListbox(bSUVUnit, bSegmented);          
                
    end

    function sOutput = maxLength(sString, iMaxLength)

        if numel(sString) > iMaxLength
            sOutput = sString(1:iMaxLength);
        else
            sOutput = sString;
        end

    end
end
