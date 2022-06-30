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

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    ROI_PANEL_X = 1550;
    ROI_PANEL_Y =  ySize*0.75;

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
    uimenu(mRoiFile,'Label', 'Export to .csv...','Callback', @exportCurrentSeriesResultCallback);
    uimenu(mRoiFile,'Label', 'Print Preview...','Callback', 'filemenufcn(gcbf,''FilePrintPreview'')', 'Separator','on');
    uimenu(mRoiFile,'Label', 'Print...','Callback', 'printdlg(gcbf)');
    uimenu(mRoiFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mRoiEdit = uimenu(figRoiWindow,'Label','Edit');
    uimenu(mRoiEdit,'Label', 'Copy Display', 'Callback', @copyRoiDialogDisplayCallback);

    mRoiOptions = uimenu(figRoiWindow,'Label','Options', 'Callback', @figRoiRefreshOption);

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
        sFigRoiInColorChecked = 'on';
    else
        sFigRoiInColorChecked = 'off';
    end

    if invertConstraint('get') == true
        sInvConstChecked = 'on';
    else
        sInvConstChecked = 'off';
    end

    mSUVUnit          = ...
        uimenu(mRoiOptions,'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @SUVUnitCallback);

    mSegmented        = ...
        uimenu(mRoiOptions,'Label', 'Modified Image Values' , 'Checked', sSegChecked, 'Callback', @segmentedCallback);

    mColorBackground  = ...
        uimenu(mRoiOptions,'Label', 'Display in Color' , 'Checked', sFigRoiInColorChecked, 'Callback', @figRoiColorCallback);

    mInvertConstraint = ...
        uimenu(mRoiOptions,'Label', 'Invert Constraint', 'Checked', sInvConstChecked, 'Callback', @figRoiInverConstraintCallback);

    mRoiReset = uimenu(figRoiWindow,'Label','Clear');
                uimenu(mRoiReset,'Label', 'Series Contours'   , 'Checked', 'off', 'Callback', @clearAllContoursCallback);
                uimenu(mRoiReset,'Label', 'Series Constraints', 'Checked', 'off', 'Callback', @clearAllMasksCallback);

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
               'String'  , 'Max Diameter cm'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Max SAD cm'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Area cm2'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1350 uiVoiRoiWindow.Position(4)-20 100 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Volume cm3'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1450 uiVoiRoiWindow.Position(4)-20 100 20],...
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

    function figRoiRefreshOption(~, ~)

        if suvMenuUnitOption('get') == true && ...
           tInput(dOffset).bDoseKernel == false
            sSuvChecked = 'on';
        else
            sSuvChecked = 'off';
        end

        if segMenuOption('get') == true 
            sSegChecked = 'on';
        else
            sSegChecked = 'off';
        end

        if isFigRoiInColor('get') == true
            sFigRoiInColorChecked = 'on';
        else
            sFigRoiInColorChecked = 'off';
        end

        if invertConstraint('get') == true
            sInvConstChecked = 'on';
        else
            sInvConstChecked = 'off';
        end

        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mSegmented       , 'Checked', sSegChecked);
        set(mColorBackground , 'Checked', sFigRoiInColorChecked);
        set(mInvertConstraint, 'Checked', sInvConstChecked);

    end

    function roiClickDown(~, ~)

        if strcmp(get(figRoiWindow,'selectiontype'),'alt')
            
            bDispayMenu = false;
            
            aVoiRoiTag = voiRoiTag('get', get(uiSeriesPtr('get'), 'Value'));
            tRoiInput  = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                

            adOffset = get(lbVoiRoiWindow, 'Value');
            asRoiWindow = cellstr(get(lbVoiRoiWindow, 'String'));
            if isempty(char(asRoiWindow(end)))
                asRoiWindow = asRoiWindow(1:end-1);
            end

            if numel(adOffset) < 2
                c = uicontextmenu(figRoiWindow);
                lbVoiRoiWindow.UIContextMenu = c;

                uimenu(c,'Label', 'Delete Contour', 'Callback',@figRoiDeleteObjectCallback);

                mCopyObject = uimenu(c,'Label', 'Copy Contour To');
                asSeriesDescription = seriesDescription('get');
                for sd=1:numel(asSeriesDescription)
                    uimenu(mCopyObject,'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyObjectCallback);
                end

if 0
                mCopyMirror = uimenu(c,'Label', 'Copy Mirror To');
                asSeriesDescription = seriesDescription('get');
                for sd=1:numel(asSeriesDescription)
                    uimenu(mCopyMirror,'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyMirrorCallback);
                end
end
                uimenu(c,'Label', 'Edit Label', 'Separator', 'on', 'Callback',@figRoiEditLabelCallback);

                mList = uimenu(c,'Label', 'Predefined Label');
                aList = getRoiLabelList();
                for pp=1:numel(aList)
                    uimenu(mList,'Text', aList{pp}, 'MenuSelectedFcn', @figRoiPredefinedLabelCallback);
                end

                uimenu(c,'Label', 'Edit Color', 'Callback',@figRoiEditColorCallback);
                uimenu(c,'Label', 'Hide/View Face Alpha', 'Callback', @figRoiHideViewFaceAlhaCallback);

                tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
                bIsVoiTag= false;
                for gg=1:numel(tVoiInput)                    
                    if strcmp(tVoiInput{gg}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag) % Tag is a VOI
                                                                       
                        bIsVoiTag = true;
                        break;
                    end
                end
                
                mFigRoiConstraint = ...
                    uimenu(c, ...
                           'Label'    , 'Constraint' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Callback' , @setFigRoiConstraintCheckedCallback, ...
                           'Separator', 'on' ...
                          ); 

                mFigRoiConstraintInsideObject = ...
                    uimenu(mFigRoiConstraint, ...
                           'Label'    , 'Inside This Contour' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Callback' , @constraintContourFromMenuCallback ...
                          ); 

                if size(dicomBuffer('get'), 3) ~= 1 % 2D Image
                    
                    if bIsVoiTag == false

                        mFigRoiConstraintInsideEverySlice = ...
                            uimenu(mFigRoiConstraint, ...
                                   'Label'    , 'Inside Every Slice' , ...
                                   'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                                   'Callback' , @constraintContourFromMenuCallback ...
                                  );
                    end
                end

                mFigRoiConstraintInvert = ...
                    uimenu(mFigRoiConstraint, ...
                           'Label'   , 'Invert Constraint' , ...
                           'Checked' , invertConstraint('get'), ...
                           'Callback', @invertConstraintFromMenuCallback ...
                          );                 
                      
                mFigRoiMask = ...
                    uimenu(c, ...
                           'Label'    , 'Mask' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Separator', 'on' ...
                          ); 

                    uimenu(mFigRoiMask, ...
                           'Label'    , 'Inside This Contour' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Callback' , @maskContourFromMenuCallback ...
                          ); 
                      
                    uimenu(mFigRoiMask, ...
                           'Label'    , 'Outside This Contour' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Callback' , @maskContourFromMenuCallback ...
                          ); 
                      
            
                if size(dicomBuffer('get'), 3) ~= 1 % 2D Image
                    
                    if bIsVoiTag == false
                        uimenu(mFigRoiMask, ...
                               'Label'    , 'Inside Every Slice' , ...
                               'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                               'Callback' , @maskContourFromMenuCallback ...
                              );
                          
                        uimenu(mFigRoiMask, ...
                               'Label'    , 'Outside Every Slice' , ...
                               'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                               'Callback' , @maskContourFromMenuCallback ...
                              );
                    end
                end
                
                uimenu(c,'Label', 'Bar Histogram'  , 'Separator', 'on' , 'Callback',@figRoiHistogramCallback);
                uimenu(c,'Label', 'Cummulative DVH', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);

                if ~isempty(tRoiInput)
                    for dd=1:numel(tRoiInput)
                        if isvalid(tRoiInput{dd}.Object)
                            if strcmpi(tRoiInput{dd}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                                if strcmpi(tRoiInput{dd}.Type, 'images.roi.line')
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

                uimenu(c,'Label', 'Create Volume-of-interest', 'Separator', 'off', 'Callback',@figRoiCreateVolumeCallback);
                uimenu(c,'Label', 'Cummulative DVH', 'Separator', 'on' , 'Callback',@figRoiMultiplePlotCallback);

            else
                lbVoiRoiWindow.UIContextMenu = [];
            end

        end
        
        function setFigRoiConstraintCheckedCallback(hObject, ~)

            bInvert = invertConstraint('get');

            if bInvert == true
                set(mFigRoiConstraintInvert, 'Checked', 'on');
            else
                set(mFigRoiConstraintInvert, 'Checked', 'off');
            end

            sConstraintTag = get(hObject, 'UserData'); 

            set(mFigRoiConstraintInsideObject , 'Checked', 'off');                    

            if size(dicomBuffer('get'), 3) ~= 1 % 2D Image   
                if exist('mFigRoiConstraintInsideEverySlice', 'var')
                    set(mFigRoiConstraintInsideEverySlice , 'Checked', 'off'); 
                end
            end

            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );

            for tt=1:numel(asConstraintTagList)
                if strcmp(asConstraintTagList{tt}, sConstraintTag)
                    if     strcmpi(asConstraintTypeList{tt}, 'Inside This Contour')
                        set(mFigRoiConstraintInsideObject, 'Checked', 'on');                                     
                    elseif strcmpi(asConstraintTypeList{tt}, 'Inside Every Slice')                        
                        set(mFigRoiConstraintInsideEverySlice, 'Checked', 'on');                                      
                    end
                end
            end 
        end
                
        function figRoiHistogramCallback(hObject, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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
                    if strcmp(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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
                        if strcmp(tRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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

            uiSeries = uiSeriesPtr('get');
            dSeriesOffset = get(uiSeries, 'Value');

            aVoiRoiTag = voiRoiTag('get');

            for hh=1:numel(aVoiRoiTag)
                asTag{hh}=aVoiRoiTag{hh}.Tag;
            end

            createVoiFromRois(dSeriesOffset, asTag(get(lbVoiRoiWindow, 'Value')));

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

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

                tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

                                    if ~isempty(tRoiInput{rr}.MaxDistances)
                                        delete(tRoiInput{rr}.MaxDistances.MaxXY.Line);
                                        delete(tRoiInput{rr}.MaxDistances.MaxCY.Line);
                                        delete(tRoiInput{rr}.MaxDistances.MaxXY.Text);
                                        delete(tRoiInput{rr}.MaxDistances.MaxCY.Text);
                                    end

                                    delete(tRoiInput{rr}.Object);
                                    tRoiInput{rr} = [];
                                    break;
                                end

                            end

                            tRoiInput(cellfun(@isempty, tRoiInput)) = [];
                        end

                        roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);

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
                        voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tVoiInput);

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

                                voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tVoiInput);
                                break;
                            end
                        end

                    end

                    for rr=1:numel(tRoiInput)

                        if strcmpi(ptrObject.Tag, tRoiInput{rr}.Tag)
                            if ~isempty(tRoiInput{rr}.MaxDistances)
                                delete(tRoiInput{rr}.MaxDistances.MaxXY.Line);
                                delete(tRoiInput{rr}.MaxDistances.MaxCY.Line);
                                delete(tRoiInput{rr}.MaxDistances.MaxXY.Text);
                                delete(tRoiInput{rr}.MaxDistances.MaxCY.Text);
                            end

                            delete(tRoiInput{rr}.Object);
                            tRoiInput{rr} = [];
                            tRoiInput(cellfun(@isempty, tRoiInput)) = [];

                            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);
                            break;
                        end
                    end

                end

                setVoiRoiSegPopup();

            end
        end

        function figRoiPredefinedLabelCallback(hObject, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            if strcmpi(ptrObject.ObjectType, 'voi')

                % Set voi Label
                for ff=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{ff}.Tag, ptrObject.Tag)

                        tVoiInput{ff}.Label = sLabel;
                        voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tVoiInput);
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

                                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);
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

                            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);
                            break;
                        end
                    end
                end
            end
        end

        function figRoiEditColorCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

                tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

                if strcmpi(ptrObject.ObjectType, 'voi')

                    % Set voi color

                    for ff=1:numel(tVoiInput)
                        if strcmpi(tVoiInput{ff}.Tag, ptrObject.Tag)

                            tVoiInput{ff}.Color = sColor;
                            voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tVoiInput);
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

                                    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);
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

                                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);
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

            tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

                tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

                        roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);

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

                    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), tRoiInput);

                end
            end
        end
    end

    function setRoiFigureName()

        if ~isvalid(lbVoiRoiWindow)
            return;
        end

        if tInput(dOffset).bDoseKernel == true
            sUnits =  'Unit: Dose';
        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnits = getSerieUnitValue(dOffset);
                if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(sUnits, 'SUV' )
                    sSUVtype = viewerSUVtype('get');
                    sUnits =  sprintf('Unit: SUV/%s', sSUVtype);
                else
                    if (strcmpi(tRoiMetaData{1}.Modality, 'ct'))
                       sUnits =  'Unit: HU';
                    else
                       sUnits =  'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(tRoiMetaData{1}.Modality, 'ct'))
                    sUnits =  'Unit: HU';
                 else
                    sUnits = getSerieUnitValue(dOffset);
                    if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(sUnits, 'SUV' )
                        sUnits =  'Unit: BQML';
                    else

                        sUnits =  'Unit: Counts';
                    end
                 end
            end
        end

        figRoiWindow.Name = ['ROI/VOI Result - ' tRoiMetaData{1}.SeriesDescription ' - ' sUnits];

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

 %       try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tQuant = quantificationTemplate('get');

        if isfield(tQuant, 'tSUV')
            dSUVScale = tQuant.tSUV.dScale;
        else
            dSUVScale = 0;
        end

        aInput = inputBuffer('get');
        if     strcmpi(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmpi(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{iOffset}, [3 1 2]);
        end
        
        if size(aInputBuffer, 3) ==1
            
            if tInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if tInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if tInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if tInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if tInput(iOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end   
        
        atInputMetaData = tInput(iOffset).atDicomInfo;

        aDisplayBuffer = dicomBuffer('get');
        
        bDoseKernel      = tInput(iOffset).bDoseKernel;
        bMovementApplied = tInput(iOffset).tMovement.bMovementApplied;

        dNbVois = numel(tVoiInput);
        if ~isempty(tVoiInput)
            for aa=1:dNbVois

                if ~isempty(tVoiInput{aa}.RoisTag)

                    if dNbVois > 10
                        if mod(aa, 5)==1 || aa == dNbVois
                            progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                        end
                    end

                    [tVoiComputed, atRoiComputed] = computeVoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atVoiMetaData, tVoiInput{aa}, tRoiInput, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);
                   
                    if ~isempty(tVoiComputed)
                        sVoiName = tVoiInput{aa}.Label;

                        sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
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
                            ' ', ...
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

                        dNbTags =numel(atRoiComputed);
                        for bb=1:numel(atRoiComputed)

                            if ~isempty(atRoiComputed{bb})

                                if dNbTags > 100
                                    if mod(bb, 10)==1 || bb == dNbTags
                                        progressBar( bb/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );
                                    end
                                end

                                if strcmpi(atRoiComputed{bb}.Axe, 'Axe')
                                    sSliceNb = num2str(atRoiComputed{bb}.SliceNb);
                                elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes1')
                                    sSliceNb = ['C:' num2str(atRoiComputed{bb}.SliceNb)];
                                elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes2')
                                    sSliceNb = ['S:' num2str(atRoiComputed{bb}.SliceNb)];
                                elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes3')
                                    sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-atRoiComputed{bb}.SliceNb+1)];
                                end

                                if isfield(atRoiComputed{bb}, 'subtraction')
                                    sSubtraction = num2str(atRoiComputed{bb}.subtraction);
                                else
                                    sSubtraction = 'N/A';
                                end

                                if ~isempty(atRoiComputed{bb}.MaxDistances)
                                    sMaxXY = num2str(atRoiComputed{bb}.MaxDistances.MaxXY.Length);
                                    sMaxCY = num2str(atRoiComputed{bb}.MaxDistances.MaxCY.Length);
                                else
                                    sMaxXY = ' ';
                                    sMaxCY = ' ';
                                end

                                sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                                    ' ', ...
                                    sSliceNb, ...
                                    num2str(atRoiComputed{bb}.cells), ...
                                    num2str(atRoiComputed{bb}.sum), ...
                                    num2str(atRoiComputed{bb}.mean), ...
                                    num2str(atRoiComputed{bb}.min), ...
                                    num2str(atRoiComputed{bb}.max), ...
                                    num2str(atRoiComputed{bb}.median), ...
                                    num2str(atRoiComputed{bb}.std), ...
                                    num2str(atRoiComputed{bb}.peak), ...
                                    sMaxXY, ...
                                    sMaxCY, ...
                                    num2str(atRoiComputed{bb}.area), ...
                                    ' ', ...
                                    sSubtraction);

                                 if isFigRoiInColor('get') == true
                                     sLine = strrep(sLine, ' ', '&nbsp;');

                                     aColor = atRoiComputed{bb}.Color;
                                     sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                                     sLine  = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                                 end

                                 sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                                 dResizeArray = numel(aVoiRoiTag)+1;

                                 aVoiRoiTag{dResizeArray}.Tag = atRoiComputed{bb}.Tag;
                                 if isfield(atRoiComputed{bb}, 'subtraction')
                                    aVoiRoiTag{dResizeArray}.Sub = atRoiComputed{bb}.subtraction;
                                 else
                                    aVoiRoiTag{dResizeArray}.Sub = 0;
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

                        tRoiComputed = computeRoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atVoiMetaData, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);

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

                        if ~isempty(tRoiComputed.MaxDistances)
                            sMaxXY = num2str(tRoiComputed.MaxDistances.MaxXY.Length);
                            sMaxCY = num2str(tRoiComputed.MaxDistances.MaxCY.Length);
                        else
                            sMaxXY = ' ';
                            sMaxCY = ' ';
                        end

                        sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
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
                            sMaxXY, ...
                            sMaxCY, ...
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

%        catch
%            progressBar(1, 'Error:setVoiRoiListbox()');
%        end

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
            bExcelInstance = true;
        catch exception %#ok<NASGU>
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
            bExcelInstance = false;
        end

        atMetaData = dicomMetaData('get');

        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aDisplayBuffer = dicomBuffer('get');

        aInput   = inputBuffer('get');
        if     strcmp(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{iOffset}, [3 1 2]);
        end
  
        if size(aDisplayBuffer, 3) ==1
            
            if aInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if aInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if aInput(iOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if aInput(iOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if aInput(iOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end
        
        atInputMetaData = tInput(iOffset).atDicomInfo;

        if ~isempty(tRoiInput) || ...
           ~isempty(tVoiInput)

            filter = {'*.csv'};
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
            
            sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
            [file, path] = uiputfile(filter, 'Save ROI/VOI result', sprintf('%s/%s_%s_%s_%s_roivoi_TriDFusion.csv' , ...
                sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sDate) );
            if file ~= 0

                try

                set(figRoiWindow, 'Pointer', 'watch');
                drawnow;

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

                % Count number of elements

                dNumberOfLines = 1;
                if ~isempty(tVoiInput) % Scan VOI
                    for aa=1:numel(tVoiInput)
                        if ~isempty(tVoiInput{aa}.RoisTag) % Found a VOI

                            dNumberOfLines = dNumberOfLines+1;

                            for cc=1:numel(tVoiInput{aa}.RoisTag)
                                for bb=1:numel(tRoiInput)
                                   if isvalid(tRoiInput{bb}.Object)
                                        if strcmpi(tVoiInput{aa}.RoisTag{cc}, tRoiInput{bb}.Tag) % Found a VOI/ROI

                                            dNumberOfLines = dNumberOfLines+1;

                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for bb=1:numel(tRoiInput) % Scan ROI
                    if isvalid(tRoiInput{bb}.Object)
                        if strcmpi(tRoiInput{bb}.ObjectType, 'roi') % Found a ROI

                            dNumberOfLines = dNumberOfLines+1;
                        end
                    end
                end

                bDoseKernel      = tInput(dOffset).bDoseKernel;
                bMovementApplied = tInput(dOffset).tMovement.bMovementApplied;
                
                if bDoseKernel == true
                    sUnits = 'Dose';
                else

                    if bSUVUnit == true

                        if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                            strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                            strcmpi(atMetaData{1}.Units, 'BQML' )

                            sSUVtype = viewerSUVtype('get');
                            sUnits   = sprintf('SUV/%s', sSUVtype);
                        else

                            if (strcmpi(atMetaData{1}.Modality, 'ct'))
                               sUnits = 'HU';
                            else
                               sUnits = 'Counts';
                            end
                        end
                    else
                         if (strcmpi(atMetaData{1}.Modality, 'ct'))
                            sUnits = 'HU';
                         else
                            if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                                strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                                strcmpi(atMetaData{1}.Units, 'BQML' )
                                sUnits = 'BQML';
                            else
                                sUnits = 'Counts';
                            end
                        end
                    end
                end

                asVoiRoiHeader{1} = sprintf('Patient Name, %s'      , cleanString(atMetaData{1}.PatientName, '_'));
                asVoiRoiHeader{2} = sprintf('Patient ID, %s'        , atMetaData{1}.PatientID);
                asVoiRoiHeader{3} = sprintf('Series Description, %s', cleanString(atMetaData{1}.SeriesDescription, '_'));
                asVoiRoiHeader{4} = sprintf('Accession Number, %s'  , atMetaData{1}.AccessionNumber);
                asVoiRoiHeader{5} = sprintf('Series Date, %s'       , atMetaData{1}.SeriesDate);
                asVoiRoiHeader{6} = sprintf('Series Time, %s'       , atMetaData{1}.SeriesTime);
                asVoiRoiHeader{7} = sprintf('Units, %s'             , sUnits);
                asVoiRoiHeader{8} = (' ');

                dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader); % Add header and cell description to number of needed lines

                asCell = cell(dNumberOfLines, 15); % Create an empty cell array

                dLineOffset = 1;
                for ll=1:numel(asVoiRoiHeader)

                    asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                    for tt=2:21
                        asCell{dLineOffset,tt}  = (' ');
                    end

                    dLineOffset = dLineOffset+1;
                end

                asCell{dLineOffset,1}  = 'Name';
                asCell{dLineOffset,2}  = 'Image number';
                asCell{dLineOffset,3}  = 'NB Pixels';
                asCell{dLineOffset,4}  = 'Total';
                asCell{dLineOffset,5}  = 'Mean';
                asCell{dLineOffset,6}  = 'Min';
                asCell{dLineOffset,7}  = 'Max';
                asCell{dLineOffset,8}  = 'Median';
                asCell{dLineOffset,9}  = 'Deviation';
                asCell{dLineOffset,10} = 'Peak';
                asCell{dLineOffset,11} = 'Max Diameter cm';
                asCell{dLineOffset,12} = 'Max SAD cm';
                asCell{dLineOffset,13} = 'Area cm2';
                asCell{dLineOffset,14} = 'Volume cm3';
                asCell{dLineOffset,15} = 'Subtraction';
                for tt=16:21
                    asCell{dLineOffset,tt}  = (' ');
                end

                dLineOffset = dLineOffset+1;

                dNbVois = numel(tVoiInput);
                if ~isempty(tVoiInput) % Scan VOIs
                    for aa=1:dNbVois
                        if ~isempty(tVoiInput{aa}.RoisTag) % Found a valid VOI

                            if dNbVois > 10
                                if mod(aa, 5)==1 || aa == dNbVois
                                    progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                                end
                            end

                            [tVoiComputed, atRoiComputed] = computeVoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, tVoiInput{aa}, tRoiInput, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);
                            
                            if ~isempty(tVoiComputed)

                                sVoiName = tVoiInput{aa}.Label;

                                asCell{dLineOffset,1}  = (sVoiName);
                                asCell{dLineOffset,2}  = (' ');
                                asCell{dLineOffset,3}  = [tVoiComputed.cells];
                                asCell{dLineOffset,4}  = [tVoiComputed.sum];
                                asCell{dLineOffset,5}  = [tVoiComputed.mean];
                                asCell{dLineOffset,6}  = [tVoiComputed.min];
                                asCell{dLineOffset,7}  = [tVoiComputed.max];
                                asCell{dLineOffset,8}  = [tVoiComputed.median];
                                asCell{dLineOffset,9}  = [tVoiComputed.std];
                                asCell{dLineOffset,10} = [tVoiComputed.peak];
                                asCell{dLineOffset,11} = (' ');
                                asCell{dLineOffset,12} = (' ');
                                asCell{dLineOffset,13} = (' ');
                                asCell{dLineOffset,14} = [tVoiComputed.volume];
                                for tt=15:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end

                                dLineOffset = dLineOffset+1;

                                dNbTags = numel(atRoiComputed);
                                for bb=1:dNbTags % Scan VOI/ROIs
                                    
                                    if ~isempty(atRoiComputed{bb})

                                        if dNbTags > 100
                                             if mod(bb, 10)==1 || bb == dNbTags
                                                progressBar( bb/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );
                                             end
                                        end

                                        if strcmpi(atRoiComputed{bb}.Axe, 'Axe')
                                            sSliceNb = num2str(atRoiComputed{bb}.SliceNb);
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes1')
                                            sSliceNb = ['C:' num2str(atRoiComputed{bb}.SliceNb)];
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes2')
                                            sSliceNb = ['S:' num2str(atRoiComputed{bb}.SliceNb)];
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes3')
                                            sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-atRoiComputed{bb}.SliceNb+1)];
                                        end

                                        asCell{dLineOffset,1}  = (' ');
                                        asCell{dLineOffset,2}  = (sSliceNb);
                                        asCell{dLineOffset,3}  = [atRoiComputed{bb}.cells];
                                        asCell{dLineOffset,4}  = [atRoiComputed{bb}.sum];
                                        asCell{dLineOffset,5}  = [atRoiComputed{bb}.mean];
                                        asCell{dLineOffset,6}  = [atRoiComputed{bb}.min];
                                        asCell{dLineOffset,7}  = [atRoiComputed{bb}.max];
                                        asCell{dLineOffset,8}  = [atRoiComputed{bb}.median];
                                        asCell{dLineOffset,9}  = [atRoiComputed{bb}.std];
                                        asCell{dLineOffset,10} = [atRoiComputed{bb}.peak];
                                        if ~isempty(atRoiComputed{bb}.MaxDistances)
                                            asCell{dLineOffset,11} = [atRoiComputed{bb}.MaxDistances.MaxXY.Length];
                                            asCell{dLineOffset,12} = [atRoiComputed{bb}.MaxDistances.MaxCY.Length];
                                        else
                                            asCell{dLineOffset,11} = (' ');
                                            asCell{dLineOffset,12} = (' ');
                                        end
                                        asCell{dLineOffset,13} = [atRoiComputed{bb}.area];
                                        asCell{dLineOffset,14} = (' ');
                                        if isfield(atRoiComputed{bb} ,'subtraction')
                                            asCell{dLineOffset,15} = [atRoiComputed{bb}.subtraction];
                                        else
                                            asCell{dLineOffset,15} = (' ');
                                        end
                                        for tt=16:21
                                            asCell{dLineOffset,tt}  = (' ');
                                        end

                                        dLineOffset = dLineOffset+1;
                                    end
                                end
                            end
                        end
                    end
                end

                dNbRois = numel(tRoiInput);
                for bb=1:dNbRois % Scan ROIs
                    if isvalid(tRoiInput{bb}.Object)
                        if strcmpi(tRoiInput{bb}.ObjectType, 'roi')

                            if dNbRois > 100
                                if mod(bb, 10)==1 || bb == dNbRois
                                    progressBar( bb/dNbRois-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbRois) );
                                end
                            end

                            tRoiComputed = computeRoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, tRoiInput{bb}, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);

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

                            asCell{dLineOffset, 1}  = (sRoiName);
                            asCell{dLineOffset, 2}  = (sSliceNb);
                            asCell{dLineOffset, 3}  = [tRoiComputed.cells];
                            asCell{dLineOffset, 4}  = [tRoiComputed.sum];
                            asCell{dLineOffset, 5}  = [tRoiComputed.mean];
                            asCell{dLineOffset, 6}  = [tRoiComputed.min];
                            asCell{dLineOffset, 7}  = [tRoiComputed.max];
                            asCell{dLineOffset, 8}  = [tRoiComputed.median];
                            asCell{dLineOffset, 9}  = [tRoiComputed.std];
                            asCell{dLineOffset, 10} = [tRoiComputed.peak];
                            if ~isempty(tRoiComputed.MaxDistances)
                                asCell{dLineOffset, 11} = [tRoiComputed.MaxDistances.MaxXY.Length];
                                asCell{dLineOffset, 12} = [tRoiComputed.MaxDistances.MaxCY.Length];
                            else
                                asCell{dLineOffset, 11} = (' ');
                                asCell{dLineOffset, 12} = (' ');
                            end
                            asCell{dLineOffset, 13} = tRoiComputed.area;
                            asCell{dLineOffset, 14} = (' ');
                            if isfield(tRoiComputed ,'subtraction')
                                asCell{dLineOffset, 15} = tRoiComputed.subtraction;
                            else
                                asCell{dLineOffset,15} = (' ');
                            end
                            for tt=16:21
                                asCell{dLineOffset,tt}  = (' ');
                            end

                            dLineOffset = dLineOffset+1;

                        end
                    end
                end
                
                progressBar( 0.99, sprintf('Writing file %s, please wait', file) );

                cell2csv(sprintf('%s%s', path, file), asCell, ',');

                if bExcelInstance == true
                    winopen(sprintf('%s%s', path, file));
                end

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

                catch
                    progressBar(1, 'Error: exportCurrentSeriesResultCallback()');
                end

                set(figRoiWindow, 'Pointer', 'default');
                drawnow;
            end
        end
    end

    function copyRoiDialogDisplayCallback(~, ~)

        try

            set(figRoiWindow, 'Pointer', 'watch');

%            rdr = get(hFig,'Renderer');
            inv = get(figRoiWindow,'InvertHardCopy');

%            set(hFig,'Renderer','Painters');
            set(figRoiWindow,'InvertHardCopy','Off');

            drawnow;
            hgexport(figRoiWindow,'-clipboard');

%            set(hFig,'Renderer',rdr);
            set(figRoiWindow,'InvertHardCopy',inv);
        catch
        end

        set(figRoiWindow, 'Pointer', 'default');
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
        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        bTagIsVoi = false;

        if ~isempty(tVoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(tVoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    if strcmpi(tVoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)

                        dRoiOffset = round(numel(tVoiInput{cc}.RoisTag)/2);

                        triangulateRoi(tVoiInput{cc}.RoisTag{dRoiOffset}, true);
                        bTagIsVoi = true;

                        break;
                    end
                end
            end
        end

        if ~isempty(tRoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           bTagIsVoi == false && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)
                         triangulateRoi(tRoiInput{cc}.Tag, true)
                         break;
                    end
                end
            end

        end
    end

    function clearAllMasksCallback(~, ~)

        roiConstraintList('reset', get(uiSeriesPtr('get'), 'Value'));
    end

    function clearAllContoursCallback(~, ~)

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

        sAnswer = questdlg('Pressing will delete all contours', 'Warning', 'Delete', 'Exit', 'Exit');

        atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if strcmpi(sAnswer, 'Delete')

            roiConstraintList('reset', iOffset); % Delete all masks

            if isfield(tDeleteInput(iOffset), 'tRoi')
                for rr=1:numel(atRoi)
                    if ~isempty(atRoi{rr}.MaxDistances)
                        delete(atRoi{rr}.MaxDistances.MaxXY.Line);
                        delete(atRoi{rr}.MaxDistances.MaxCY.Line);
                        delete(atRoi{rr}.MaxDistances.MaxXY.Text);
                        delete(atRoi{rr}.MaxDistances.MaxCY.Text);
                    end
                    delete(atRoi{rr}.Object);
                end

                tDeleteInput(iOffset).tRoi = [];
            end

            if isfield(tDeleteInput(iOffset), 'tVoi')
                tDeleteInput(iOffset).tVoi = [];
            end

            voiRoiTag('set', '');

            roiTemplate('reset', iOffset);
            voiTemplate('reset', iOffset);

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
            
%            clearDisplay();

%            if size(dicomBuffer('get'), 3) == 1
%                initDisplay(1);
%            else
%                initDisplay(3);
%            end

%            dicomViewerCore();           
            
        end

    end

    function figRoiInverConstraintCallback(hObject, ~)

        bInvert = invertConstraint('get');

        if bInvert == true
            invertConstraint('set', false);
            set(hObject, 'Checked', 'off');
        else
            invertConstraint('set', true);
            set(hObject, 'Checked', 'on');
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

    function figRoiCopyObjectCallback(hObject, ~)

        dToOffset = 0;
        tObject = [];

        dFromOffset = get(uiSeriesPtr('get'), 'Value');

        sCopyTo = get(hObject, 'Text');

        asSeriesDescription = seriesDescription('get');
        for sd=1:numel(asSeriesDescription)
            if strcmpi(sCopyTo, asSeriesDescription{sd})
                dToOffset = sd;
                break;
            end
        end

        aVoiRoiTag = voiRoiTag('get');

        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        bObjectIsVoi = false; 
        if ~isempty(tVoiInput) && ...
           ~isempty(aVoiRoiTag)
            for aa=1:numel(tVoiInput)
                if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                    % Object is a VOI
                    tObject = tVoiInput{aa};
                    bObjectIsVoi = true;
                    break;
                end

            end

        end

        if bObjectIsVoi == false
            if ~isempty(tRoiInput)

                for cc=1:numel(tRoiInput)
                    if isvalid(tRoiInput{cc}.Object)
                        if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value}.Tag)
                            % Object is a ROI
                            tObject = tRoiInput{cc};
                            break;
                        end
                    end
                end
            end
        end
        
        if dToOffset~=0 && ~isempty(tObject)
            
            % Copy the object
            copyRoiVoiToSerie(dToOffset, tObject, false);
            
            if dFromOffset == dToOffset % Refresh ROIs list
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

    end

    function figRoiCopyMirrorCallback(hObject, ~)

        dToOffset = 0;
        tObject = [];

        dFromOffset = get(uiSeriesPtr('get'), 'Value');

        sCopyTo = get(hObject, 'Text');

        asSeriesDescription = seriesDescription('get');
        for sd=1:numel(asSeriesDescription)
            if strcmpi(sCopyTo, asSeriesDescription{sd})
                dToOffset = sd;
                break;
            end
        end

        aVoiRoiTag = voiRoiTag('get');

        tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if ~isempty(tVoiInput) && ...
           ~isempty(aVoiRoiTag)
            for aa=1:numel(tVoiInput)
                if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                    % Object is a VOI
                    tObject = tVoiInput{aa};
                    break;
                end

            end

        end

        if ~isempty(tRoiInput) && ...
           ~isempty(aVoiRoiTag)

            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    if strcmpi(tRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value}.Tag)
                        % Object is a ROI
                        tObject = tRoiInput{cc};
                        break;
                    end
                end
            end
        end

        if dToOffset~=0 && ~isempty(tObject)
            % Copy the object
            copyRoiVoiToSerie(dToOffset, tObject, true);
            if dFromOffset == dToOffset % Refresh ROIs list
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

    end

    function sOutput = maxLength(sString, iMaxLength)

        if numel(sString) > iMaxLength
            sOutput = sString(1:iMaxLength);
        else
            sOutput = sString;
        end

    end

end
