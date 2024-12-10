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

    gUicontrolFigRoi = [];

    dScreenSize  = get(groot, 'Screensize');

    ySize = dScreenSize(4);

    FIG_ROI_DEFAULT_X = 1600;
    FIG_ROI_SIMPLIFIED_X = 1500;
    FIG_ROI_REDUCED_X = 1200;

    if isfigVoiSimplified('get') == true

        FIG_ROI_X = FIG_ROI_SIMPLIFIED_X;
        FIG_ROI_Y =  ySize*0.50;
    else
        FIG_ROI_X = FIG_ROI_DEFAULT_X;
        FIG_ROI_Y =  ySize*0.50;
    end

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end

    releaseRoiWait();

    if exist('hObject', 'var')
        if strcmpi(get(hObject, 'Tag'), 'toolbar')
           set(hObject, 'State', 'off');
        end
    end

    cummulativeMenuOption('set', false);
    histogramMenuOption('set', false);
    profileMenuOption('set', false);

    figRoiWindow = ...
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_ROI_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_ROI_Y/2) ...
               FIG_ROI_X ...
               FIG_ROI_Y],...
               'Name', 'TriDFusion (3DF) VOI/ROI Result',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Toolbar','none'...
               );
    figRoiWindowPtr('set', figRoiWindow);

    set(figRoiWindow, 'WindowButtonDownFcn', @roiClickDown);
    set(figRoiWindow, 'WindowKeyPressFcn', @catchKeyPress);

    mRoiFile = uimenu(figRoiWindow,'Label','File');
    uimenu(mRoiFile,'Label', 'Export to .csv...','Callback', @exportCurrentSeriesResultCallback);
    uimenu(mRoiFile,'Label', 'Print Preview...','Callback', 'filemenufcn(gcbf,''FilePrintPreview'')', 'Separator','on');
    uimenu(mRoiFile,'Label', 'Print...','Callback', 'printdlg(gcbf)');
    uimenu(mRoiFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mRoiEdit = uimenu(figRoiWindow,'Label','Edit');
    uimenu(mRoiEdit,'Label', 'Copy Display', 'Callback', @copyRoiDialogDisplayCallback);
%     uimenu(mRoiEdit,'Label', 'Copy Display', 'Callback', @copyAllContoursToSeriesCallback);
    mCopyAllObjects = uimenu(mRoiEdit,'Label', 'Copy All Contours To');
    asSeriesDescription = seriesDescription('get');
    for yy=1:numel(asSeriesDescription)
        if yy ~= dSeriesOffset
            uimenu(mCopyAllObjects,'Text', asSeriesDescription{yy}, 'MenuSelectedFcn', @figRoiCopyAllObjectsCallback);
        end
    end

    mRoiOptions = uimenu(figRoiWindow,'Label','Options', 'Callback', @figRoiRefreshOption);

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

    if isfigVoiSimplified('get') == true
        sSimplifiedChecked = 'on';
        sExpendVoiEnable = 'off';
    else
        sSimplifiedChecked = 'off';
        sExpendVoiEnable = 'on';
    end


    if isfigVoiExpendVoi('get') == true

        sExpendVoiChecked = 'on';
    else
        sExpendVoiChecked = 'off';
    end

    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1 % 2D Image

        isfigVoiSimplified('set', false);
        isfigVoiExpendVoi('set', false);

        sExpendVoiEnable = 'off';
        sSimplifiedEnable = 'off';
    else
        sSimplifiedEnable = 'on';
    end

    mSimplified       = ...
        uimenu(mRoiOptions,'Label', 'TCS Farthest Distance Menu', 'Checked', sSimplifiedChecked, 'Enable', sSimplifiedEnable, 'Callback', @simplifiedDisplayCallback);
    
    mExpendVoi        = ...
        uimenu(mRoiOptions,'Label', 'Expend VOI', 'Checked', sExpendVoiChecked, 'Enable', sExpendVoiEnable, 'Callback', @expendVoiCallback, 'Separator','on');

    mColorBackground  = ...
        uimenu(mRoiOptions,'Label', 'Display in Color' , 'Checked', sFigRoiInColorChecked, 'Callback', @figRoiColorCallback);

    mSUVUnit          = ...
        uimenu(mRoiOptions,'Label', 'SUV Unit', 'Checked', sSuvChecked , 'Enable', sSuvEnable, 'Callback', @SUVUnitCallback, 'Separator','on');

    mModifiedMatrix   = ...
        uimenu(mRoiOptions,'Label', 'Display Image Cells Value' , 'Checked', sModifiedMatrixChecked, 'Callback', @modifiedMatrixCallback);

    mSegmented        = ...
        uimenu(mRoiOptions,'Label', 'Subtract Masked Cells' , 'Checked', sSegChecked, 'Callback', @segmentedCallback);

    mInvertConstraint = ...
        uimenu(mRoiOptions,'Label', 'Invert Constraint', 'Checked', sInvConstChecked, 'Callback', @figRoiInverConstraintCallback, 'Separator','on');

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
                'BorderType', 'none', ...
                'position', [0 0 FIG_ROI_X FIG_ROI_Y]...
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

    setRoiFigureUiContorl();

    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    if strcmpi(mSUVUnit.Checked, 'on')
        bSUVUnit = true;
    else
        bSUVUnit = false;
    end

    if strcmpi(mSegmented.Checked, 'on')
        bSegmented = true;
    else
        bSegmented = false;
    end

    if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
        bModifiedMatrix = true;
    else
        bModifiedMatrix = false;
    end

    if strcmpi(get(mSimplified, 'Checked'), 'on')

        setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
    else

        if strcmpi(get(mExpendVoi, 'Checked'), 'on')
            bExpendVoi = true;
        else
            bExpendVoi = false;
        end

        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
    end

    setRoiFigureName();

    function setRoiFigureUiContorl()

        if ~isempty(gUicontrolFigRoi)
            for uu=1:numel(gUicontrolFigRoi)
                delete(gUicontrolFigRoi{uu});
            end
            gUicontrolFigRoi = [];
        end

        aFigRoiPosition = get(figRoiWindow, 'Position');

        if strcmpi(get(mSimplified, 'Checked'), 'on')

             aFigRoiPosition(3) = FIG_ROI_SIMPLIFIED_X;

             set(figRoiWindow, 'Position', aFigRoiPosition);

             set(uiVoiRoiWindow, 'Position', [0 0 FIG_ROI_SIMPLIFIED_X FIG_ROI_Y]);
             set(lbVoiRoiWindow, 'Position', [0 0 uiVoiRoiWindow.Position(3) uiVoiRoiWindow.Position(4)-20]);

             gUicontrolFigRoi{1}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [0 uiVoiRoiWindow.Position(4)-20 150 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Name'...
                       );

             gUicontrolFigRoi{2}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [150 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Nb Cells'...
                       );

             gUicontrolFigRoi{3}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Total'...
                       );

             gUicontrolFigRoi{4}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Sum'...
                       );

             gUicontrolFigRoi{5}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Mean'...
                       );

             gUicontrolFigRoi{6}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Min'...
                       );

             gUicontrolFigRoi{7}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Max'...
                       );

             gUicontrolFigRoi{8}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Median'...
                       );

             gUicontrolFigRoi{9}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Deviation'...
                       );

             gUicontrolFigRoi{10}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Peak'...
                       );

             gUicontrolFigRoi{11}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [1050 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Max Coronal (mm)'...
                       );

              gUicontrolFigRoi{12}= ...
              uicontrol(uiVoiRoiWindow,...
                       'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Max Sagittal (mm)'...
                       );

              gUicontrolFigRoi{13}= ...
              uicontrol(uiVoiRoiWindow,...
                       'Position', [1250 uiVoiRoiWindow.Position(4)-20 100 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Max Axial (mm)'...
                       );

             gUicontrolFigRoi{14}= ...
             uicontrol(uiVoiRoiWindow,...
                       'Position', [1350 uiVoiRoiWindow.Position(4)-20 150 20],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'String'  , 'Volume (cm3)'...
                       );

        else

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));        

            if strcmpi(get(mExpendVoi, 'Checked'), 'on')

                bExpendVoi = true;
            else
                bExpendVoi = false;
            end         
        
            if bExpendVoi == true
        
                bExpendedDisplay = true;
            else
                bExpendedDisplay = false;
        
                if any(cellfun(@(roi) strcmpi(roi.ObjectType, 'roi'), atRoiInput))

                    bExpendedDisplay = true;
                end
            end

            if bExpendedDisplay == true

                aFigRoiPosition(3)=FIG_ROI_DEFAULT_X;
    
                set(figRoiWindow, 'Position', aFigRoiPosition);
    
                set(uiVoiRoiWindow, 'Position', [0 0 FIG_ROI_DEFAULT_X FIG_ROI_Y]);
                set(lbVoiRoiWindow, 'Position', [0 0 uiVoiRoiWindow.Position(3) uiVoiRoiWindow.Position(4)-20]);
    
                gUicontrolFigRoi{1}= ...
                uicontrol(uiVoiRoiWindow,...
                           'Position', [0 uiVoiRoiWindow.Position(4)-20 150 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Name'...
                           );
    
                gUicontrolFigRoi{2}= ...
                uicontrol(uiVoiRoiWindow,...
                           'Position', [150 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Image Number'...
                           );
    
                 gUicontrolFigRoi{3}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Nb Cells'...
                           );
    
                 gUicontrolFigRoi{4}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Total'...
                           );
    
                  gUicontrolFigRoi{5}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Sum'...
                           );
    
                 gUicontrolFigRoi{6}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Mean'...
                           );
    
                 gUicontrolFigRoi{7}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Min'...
                           );
    
                 gUicontrolFigRoi{8}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Max'...
                           );
    
                 gUicontrolFigRoi{9}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Median'...
                           );
    
                 gUicontrolFigRoi{10}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Deviation'...
                           );
    
                 gUicontrolFigRoi{11}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1050 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Peak'...
                           );
    
                 gUicontrolFigRoi{12}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Max Diameter (mm)'...
                           );
    
                 gUicontrolFigRoi{13}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1250 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Max SAD (mm)'...
                           );
    
                 gUicontrolFigRoi{14}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1350 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Area (cm2)'...
                           );
    
                 gUicontrolFigRoi{15}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1450 uiVoiRoiWindow.Position(4)-20 150 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Volume (cm3)'...
                           );
            else
                aFigRoiPosition(3)=FIG_ROI_REDUCED_X;
    
                set(figRoiWindow, 'Position', aFigRoiPosition);
    
                set(uiVoiRoiWindow, 'Position', [0 0 FIG_ROI_REDUCED_X FIG_ROI_Y]);
                set(lbVoiRoiWindow, 'Position', [0 0 uiVoiRoiWindow.Position(3) uiVoiRoiWindow.Position(4)-20]);
    
                gUicontrolFigRoi{1}= ...
                uicontrol(uiVoiRoiWindow,...
                           'Position', [0 uiVoiRoiWindow.Position(4)-20 150 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Name'...
                           );
    
                 gUicontrolFigRoi{2}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [150 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Nb Cells'...
                           );
    
                 gUicontrolFigRoi{3}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Total'...
                           );
    
                  gUicontrolFigRoi{4}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Sum'...
                           );
    
                 gUicontrolFigRoi{5}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Mean'...
                           );
    
                 gUicontrolFigRoi{6}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Min'...
                           );
    
                 gUicontrolFigRoi{7}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Max'...
                           );
    
                 gUicontrolFigRoi{8}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Median'...
                           );
    
                 gUicontrolFigRoi{9}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Deviation'...
                           );
    
                 gUicontrolFigRoi{10}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Peak'...
                           );
        
                 gUicontrolFigRoi{11}= ...
                 uicontrol(uiVoiRoiWindow,...
                           'Position', [1050 uiVoiRoiWindow.Position(4)-20 150 20],...
                           'BackgroundColor', viewerBackgroundColor('get'), ...
                           'ForegroundColor', viewerForegroundColor('get'), ...
                           'String'  , 'Volume (cm3)'...
                           );
            end
        end
    end

    function figRoiRefreshOption(~, ~)

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

        if isfigVoiSimplified('get') == true
            sSimplifiedChecked = 'on';
            sExpendVoiEnable = 'off';
        else
            sSimplifiedChecked = 'off';
            sExpendVoiEnable = 'on';
        end

        if isfigVoiExpendVoi('get') == true
            sExpendVoiChecked = 'on';
        else
            sExpendVoiChecked = 'off';
        end

        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1 % 2D Image

            sExpendVoiEnable  = 'off';
        end

        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mModifiedMatrix  , 'Checked', sModifiedMatrixChecked);
        set(mSegmented       , 'Checked', sSegChecked);
        set(mColorBackground , 'Checked', sFigRoiInColorChecked);
        set(mInvertConstraint, 'Checked', sInvConstChecked);
        set(mSimplified      , 'Checked', sSimplifiedChecked);
        set(mExpendVoi       , 'Checked', sExpendVoiChecked);
        set(mExpendVoi       , 'Enable' , sExpendVoiEnable);

    end

    function roiClickDown(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        atRoiInput = roiTemplate('get', dSeriesOffset);
        atVoiInput = voiTemplate('get', dSeriesOffset);

        if strcmp(get(figRoiWindow,'selectiontype'),'alt')

            bDispayMenu = false;

            aVoiRoiTag = voiRoiTag('get', dSeriesOffset);

            if ~isempty(aVoiRoiTag) || ~isempty(atRoiInput)

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
                        if sd ~= dSeriesOffset
                            uimenu(mCopyObject, 'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyObjectCallback);
                        end
                    end

    if 1
                    mCopyMirror = uimenu(c,'Label', 'Copy Mirror To');
                    asSeriesDescription = seriesDescription('get');
                    for sd=1:numel(asSeriesDescription)
%                         if sd ~= dSeriesOffset
                            uimenu(mCopyMirror,'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyMultipleMirrorCallback);
%                         end
                    end

    end
                    uimenu(c,'Label', 'Edit Label', 'Separator', 'on', 'Callback',@figRoiEditLabelCallback);

                    mList = uimenu(c,'Label', 'Predefined Label');
                    aList = getRoiLabelList();
                    for pp=1:numel(aList)
                        uimenu(mList,'Text', aList{pp}, 'MenuSelectedFcn', @figRoiPredefinedLabelCallback);
                    end

                    if ~isempty(atVoiInput)

                        dTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{adOffset}.Tag} ), 1);

                        sLesionType = '';
                        if ~isempty(dTagOffset) % Tag is a VOI
                            sLesionType = atVoiInput{dTagOffset}.LesionType;
                        else
                            dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {aVoiRoiTag{adOffset}.Tag} ), 1);
                            if ~isempty(dTagOffset) % Tag is a ROI
                                sLesionType = atRoiInput{dTagOffset}.LesionType;
                            end
                        end
                    else
                        dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {aVoiRoiTag{adOffset}.Tag} ), 1);
                        if ~isempty(dTagOffset) % Tag is a ROI
                            sLesionType = atRoiInput{dTagOffset}.LesionType;
                        end
                    end

                    [~, asLesionList] = getLesionType(sLesionType);

                    if ~isempty(asLesionList)

                        mEditLocation = uimenu(c,'Label', 'Edit Site');

                        for ll = 1: numel(asLesionList)

                            uimenu(mEditLocation, 'Text', asLesionList{ll}, 'MenuSelectedFcn', @figRoiEditMultipleLesionTypeCallback);
                        end

                        for ch=1:numel(mEditLocation.Children)

                            if strcmpi(mEditLocation.Children(ch).Text, sLesionType)
                                set(mEditLocation.Children(ch), 'Checked', 'on');
                            end
                        end

                    end

                    uimenu(c,'Label', 'Edit Color', 'Callback',@figRoiEditColorCallback);
                    uimenu(c,'Label', 'Hide/View Face Alpha', 'Callback', @figRoiHideViewFaceAlhaCallback);

                    bIsVoiTag= false;
                    if ~isempty(atVoiInput)
                        aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag} );
                        if aTagOffset(aTagOffset==1) % tag is a voi
                            bIsVoiTag = true;
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

                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 % 2D Image

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

                    if bIsVoiTag == true

                        mFigRoiIncrement = ...
                            uimenu(c, ...
                                   'Label'    , 'Increment' , ...
                                   'Separator', 'on' ...
                                  );

                        uimenu(mFigRoiIncrement, ...
                               'Label'    , 'Adjust increment ratio' , ...
                               'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                               'Separator', 'on', ...
                               'Callback' , @figRoiEditIncrementRatioVoiPositionCallback ...
                              );

                        uimenu(mFigRoiIncrement, ...
                               'Label'    , 'Increase Contours (Ctrl + +)' , ...
                               'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                               'Visible'  , 'on', ...
                               'Callback' , @figRoiIncreaseVoiPositionCallback ...
                               );

                        uimenu(mFigRoiIncrement, ...
                               'Label'    , 'Decrease Contours (Ctrl + -)' , ...
                               'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                               'Visible'  , 'on', ...
                               'Callback' , @figRoiDecreaseVoiPositionCallback ...
                               );

                    end
                
                     mFigRoiMargin = ...
                        uimenu(c, ...
                               'Label'    , 'Margin' , ...
                               'Separator', 'on' ...
                              );  

                    uimenu(mFigRoiMargin, ...
                           'Label'    , 'Margin Adjustments' , ...
                           'Visible'  , 'on', ...
                           'Callback' , @editContourMarginCallback ...
                           );

                    uimenu(mFigRoiMargin, ...
                           'Label'    , 'Create Margin Contour(s)' , ...
                           'UserData' , aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, ...
                           'Visible'  , 'on', ...
                           'Callback' , @figRoiCreateMarginContoursCallback ...
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


                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 % 3D Image

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



                    uimenu(c,'Label', 'Bar Histogram' , 'Separator', 'on' , 'Callback',@figRoiHistogramCallback);
                    uimenu(c,'Label', 'Cumulative DVH', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);

                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 % 3D Image

                        if contains(lower(atMetaData{1}.SeriesType), 'dynamic') || gateUseSeriesUID('get') == false

                            timeActivity = uimenu(c,'Label', 'Time Activity');

                            uimenu(timeActivity,'Label', 'Total', 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Sum'  , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Mean' , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Max'  , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Peak' , 'Callback',@figRoiTimeActivityCallback);
                        end
                    end

                    if ~isempty(atRoiInput)
                        for dd=1:numel(atRoiInput)
                            if isvalid(atRoiInput{dd}.Object)
                                if strcmpi(atRoiInput{dd}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                                     if strcmpi(atRoiInput{dd}.Type, 'images.roi.line') || ...
                                         strcmpi(atRoiInput{dd}.Type, 'images.roi.rectangle')

                                        uimenu(c,'Label', 'Profile', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);
                                     end
                                end
                            end
                        end
                    end

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

                if bDispayMenu == true

                    c = uicontextmenu(figRoiWindow);
                    lbVoiRoiWindow.UIContextMenu = c;

                    if numel(adOffset) > 1

                        uimenu(c,'Label', 'Delete Contours', 'Separator', 'off', 'Callback',@figRoiDeleteMultipleObjectsCallback);

                        mCopyObject = uimenu(c,'Label', 'Copy Contours To');
                        asSeriesDescription = seriesDescription('get');
                        for sd=1:numel(asSeriesDescription)
                            if sd ~= dSeriesOffset
                                uimenu(mCopyObject, 'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyMultipleObjectsCallback);
                            end
                        end

                        mCopyMirror = uimenu(c,'Label', 'Copy Mirror To');
                        asSeriesDescription = seriesDescription('get');
                        for sd=1:numel(asSeriesDescription)
                            uimenu(mCopyMirror,'Text', asSeriesDescription{sd}, 'MenuSelectedFcn', @figRoiCopyMultipleMirrorCallback);
                        end

                    end

                end

                if bDispayMenu == true

                    [~, asLesionList] = getLesionType('');

                    if ~isempty(asLesionList)

                        mEditLocation = uimenu(c,'Label', 'Edit Site', 'Separator', 'on');

                        for ll = 1: numel(asLesionList)

                            uimenu(mEditLocation, 'Text', asLesionList{ll}, 'MenuSelectedFcn', @figRoiEditMultipleLesionTypeCallback);
                        end
                    end
                end

                if bDispayMenu == true && size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                    uimenu(c,'Label', 'Create Volume-of-interest', 'Separator', 'on', 'Callback',@figRoiCreateVolumeCallback);

                    if numel(adOffset) == 2
                        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

                        bIsVoiTag= false;
                        if ~isempty(atVoiInput)
                            for ll=1:numel(adOffset)
                                aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {aVoiRoiTag{adOffset(ll)}.Tag} );
                                if aTagOffset(aTagOffset==1) % tag is a voi
                                    bIsVoiTag = true;
                                    break
                                end
                            end
                        end

                        if bIsVoiTag == false
                            uimenu(c,'Label', 'Insert Region-of-interest between', 'Separator', 'off', 'Callback',@figRoiInsertBetweenRoisCallback);
                        end

                    end

                    uimenu(c,'Label', 'Cumulative DVH', 'Separator', 'on' , 'Callback',@figRoiMultiplePlotCallback);

                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 % 3D Image

                        if contains(lower(atMetaData{1}.SeriesType), 'dynamic') ||  gateUseSeriesUID('get') == false

                            timeActivity = uimenu(c,'Label', 'Time Activity');

                            uimenu(timeActivity,'Label', 'Total', 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Sum'  , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Mean' , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Max'  , 'Callback',@figRoiTimeActivityCallback);
                            uimenu(timeActivity,'Label', 'Peak' , 'Callback',@figRoiTimeActivityCallback);
                        end
                    end

                else
    %                 lbVoiRoiWindow.UIContextMenu = [];
                end
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

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 % 2D Image

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

        function figRoiEditIncrementRatioVoiPositionCallback(~, ~)

            DLG_INCREAMENT_X = 380;
            DLG_INCREAMENT_Y = 100;

            dlgIncrement = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_INCREAMENT_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_INCREAMENT_Y/2) ...
                                    DLG_INCREAMENT_X ...
                                    DLG_INCREAMENT_Y ...
                                    ],...
                       'MenuBar', 'none',...
                       'Resize', 'off', ...
                       'NumberTitle','off',...
                       'MenuBar', 'none',...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'Adjust increment ratio',...
                       'Toolbar','none'...
                       );

            edtIncrementRatio = ...
               uicontrol(dlgIncrement,...
                         'style'     , 'edit',...
                         'enable'    , 'on',...
                         'Background', 'white',...
                         'string'    , num2str(voiIncrementRatio('get')),...
                         'position'  , [200 50 100 20],...
                         'BackgroundColor', viewerBackgroundColor('get'), ...
                         'ForegroundColor', viewerForegroundColor('get'), ...
                         'Callback'  , @editIncrementRatioCallback...
                         );
            set(edtIncrementRatio, 'KeyPressFcn', @checkEditRatioKeyPress);

                uicontrol(dlgIncrement,...
                          'style'   , 'text',...
                          'string'  , 'Increment ratio',...
                          'horizontalalignment', 'left',...
                          'position', [20 47 180 20],...
                          'Enable', 'On',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get') ...
                          );

             % Cancel or Proceed

             uicontrol(dlgIncrement,...
                       'String','Cancel',...
                       'Position',[285 7 75 25],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'Callback', @cancelEditIncrementRatioCallback...
                       );

             uicontrol(dlgIncrement,...
                      'String','Change',...
                      'Position',[200 7 75 25],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @changeEditIncrementRatioCallback...
                      );

                function checkEditRatioKeyPress(~, event)
                    if strcmp(event.Key, 'return')
                        drawnow;
                        changeEditIncrementRatioCallback();
                    end
                end

                function editIncrementRatioCallback(~, ~)

                    dIncrement = str2double(get(edtIncrementRatio, 'String'));

                    if dIncrement < 0
                        set(edtIncrementRatio, 'String', '1');
                    end
                end

                function changeEditIncrementRatioCallback(~, ~)

                    dIncrement = str2double(get(edtIncrementRatio, 'String'));

                    if dIncrement < 0

                        set(edtIncrementRatio, 'String', '1');
                    else
                        voiIncrementRatio('set', dIncrement);

                        delete(dlgIncrement);
                    end
                end

                function cancelEditIncrementRatioCallback(~, ~)

                    delete(dlgIncrement);
                end

        end

        function figRoiIncreaseVoiPositionCallback(hObject, ~)

            increaseVoiPosition(get(hObject, 'UserData'), voiIncrementRatio('get'));

            plotRotatedRoiOnMip(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), mipAngle('get'))

        end

        function figRoiDecreaseVoiPositionCallback(hObject, ~)

            decreaseVoiPosition(get(hObject, 'UserData'), voiIncrementRatio('get'));

            plotRotatedRoiOnMip(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), mipAngle('get'))

        end

        function figRoiCreateMarginContoursCallback(hObject, ~)

            sTag = get(hObject, 'UserData');

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), sTag ), 1);

            if isempty(dRoiTagOffset)
                
                dVoiTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), sTag ), 1);

                if ~isempty(dVoiTagOffset)

                    createVoiMarginContours(contourMarginDistanceValue('get'), contourMarginJointType('get'), atVoiInput(dVoiTagOffset));
                end

            else
                createRoiMarginContour(contourMarginDistanceValue('get'), contourMarginJointType('get'), atRoiInput(dRoiTagOffset)); 
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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
            end
        end

        function figRoiHistogramCallback(hObject, ~)

            atInput = inputTemplate('get');
            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            if dSeriesOffset > numel(atInput)
                return;
            end

            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

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

            if     strcmpi(get(hObject, 'Label'), 'Bar Histogram')

                histogramMenuOption('set', true);
                cummulativeMenuOption('set', false);
                profileMenuOption('set', false);
            elseif strcmpi(get(hObject, 'Label'), 'Cumulative DVH')

                histogramMenuOption('set', false);
                cummulativeMenuOption('set', true);
                profileMenuOption('set', false);
            else

                histogramMenuOption('set', false);
                cummulativeMenuOption('set', false);
                profileMenuOption('set', true);
            end

            if ~isempty(atVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(atVoiInput)
                    if strcmp(atVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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

                        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                            bModifiedMatrix = true;
                        else
                            bModifiedMatrix = false;
                        end

                        if strcmpi(get(mSimplified, 'Checked'), 'on')
                            bSimplified = true;
                        else
                            bSimplified = false;
                        end

                        bDoseKernel      = atInput(dSeriesOffset).bDoseKernel;
                        bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

                        figRoiHistogram(aInputBuffer, ...
                                        atInputMetaData, ...
                                        atVoiInput{aa}, ...
                                        bSUVUnit, ...
                                        bModifiedMatrix, ...
                                        bSegmented, ...
                                        bDoseKernel, ...
                                        bMovementApplied, ...
                                        bSimplified);
                        return;
                    end

                 end

            end

            if ~isempty(atRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(atRoiInput)
                    if isvalid(atRoiInput{cc}.Object)
                        if strcmp(atRoiInput{cc}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

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

                            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                                bModifiedMatrix = true;
                            else
                                bModifiedMatrix = false;
                            end

                            if strcmpi(get(mSimplified, 'Checked'), 'on')
                                bSimplified = true;
                            else
                                bSimplified = false;
                            end

                            bDoseKernel      = atInput(dSeriesOffset).bDoseKernel;
                            bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

                            figRoiHistogram(aInputBuffer, ...
                                            atInputMetaData, ...
                                            atRoiInput{cc}, ...
                                            bSUVUnit, ...
                                            bModifiedMatrix, ...
                                            bSegmented, ...
                                            bDoseKernel, ...
                                            bMovementApplied, ...
                                            bSimplified);
                            return;
                       end
                    end
                end
            end

            clear aInputBuffer
            clear aInput;
        end

        function figRoiEditMultipleLesionTypeCallback(hObject, ~)

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            sSelectedType = get(hObject, 'Text');

            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', dSeriesOffset);
            atVoiInput = voiTemplate('get', dSeriesOffset);

            asTag = cell(1, numel(aVoiRoiTag));

            for hh=1:numel(aVoiRoiTag)
                asTag{hh} = aVoiRoiTag{hh}.Tag;
            end

            asRoiTags = [];

            asTag = asTag(get(lbVoiRoiWindow, 'Value'));

            dNbTags = numel(asTag);

            for jj=1:dNbTags

                dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag(jj) ), 1);

                if isempty(dRoiTagOffset) % Tag is a VOI

                    dVoiTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), asTag(jj) ), 1);

                    if ~isempty(dVoiTagOffset) % Tag is a VOI

                        bTagIsUpdated = false;

                        [bLesionOffset, ~, asLesionShortName] = getLesionType(sSelectedType);

                        for nn=1:numel(asLesionShortName)

                            if contains(atVoiInput{dVoiTagOffset}.Label, asLesionShortName{nn})

                                bTagIsUpdated = true;
                                atVoiInput{dVoiTagOffset}.Label = replace(atVoiInput{dVoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});
                                break;
                            end
                        end

                        if bTagIsUpdated == false

                            atVoiInput{dVoiTagOffset}.Label = sprintf('%s-%s', atVoiInput{dVoiTagOffset}.Label, asLesionShortName{bLesionOffset});
                        end

                        atVoiInput{dVoiTagOffset}.LesionType = sSelectedType;

                        dNbRois = numel(atVoiInput{dVoiTagOffset}.RoisTag);

                        for vv=1: dNbRois

                            dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{dVoiTagOffset}.RoisTag{vv} ), 1);

                            if ~isempty(dRoiTagOffset) % Found the Tag

                                bTagIsUpdated = false;

                                [bLesionOffset, ~, asLesionShortName] = getLesionType(sSelectedType);

                                for nn=1:numel(asLesionShortName)

                                    if contains(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn})

                                        bTagIsUpdated = true;

                                        atRoiInput{dRoiTagOffset}.Label = replace(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});

                                        if isvalid(atRoiInput{dRoiTagOffset}.Object)

                                            atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                                        end
                                        break;
                                    end
                                end

                                 if bTagIsUpdated == false

                                    atRoiInput{dRoiTagOffset}.Label = sprintf('%s-%s', atRoiInput{dRoiTagOffset}.Label, asLesionShortName{bLesionOffset});
                                 end

                                atRoiInput{dRoiTagOffset}.LesionType = sSelectedType;
                            end

                        end
                    end
                else

                    if isempty(find(ismember(asRoiTags, asTag{jj}), 1)) % The tag is not already added

                        dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag{jj} ), 1);

                        if ~isempty(dRoiTagOffset) % Found the Tag

                            bTagIsUpdated = false;

                            [bLesionOffset, ~, asLesionShortName] = getLesionType(sSelectedType);

                            for nn=1:numel(asLesionShortName)

                                if contains(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn})

                                    bTagIsUpdated = true;

                                    atRoiInput{dRoiTagOffset}.Label = replace(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});

                                    if isvalid(atRoiInput{dRoiTagOffset}.Object)

                                        atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                                    end
                                    break;
                                end
                            end

                            if bTagIsUpdated == false

                                atRoiInput{dRoiTagOffset}.Label = sprintf('%s-%s', atRoiInput{dRoiTagOffset}.Label, asLesionShortName{bLesionOffset});

                                if isvalid(atRoiInput{dRoiTagOffset}.Object)

                                    atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                                end
                            end

                            atRoiInput{dRoiTagOffset}.LesionType = sSelectedType;
                        end

                    end
                end
            end

            roiTemplate('set', dSeriesOffset, atRoiInput);
            voiTemplate('set', dSeriesOffset, atVoiInput);

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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
            end

            setVoiRoiSegPopup();
        end

        function figRoiCreateVolumeCallback(~, ~)

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', dSeriesOffset);
            atVoiInput = voiTemplate('get', dSeriesOffset);

            asTag = cell(1, numel(aVoiRoiTag));

            for hh=1:numel(aVoiRoiTag)
                asTag{hh} = aVoiRoiTag{hh}.Tag;
            end

            asRoiTags = [];

            asTag = asTag(get(lbVoiRoiWindow, 'Value'));

            dNbTags = numel(asTag);
            for jj=1:dNbTags

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag(jj) );
                dRoiTagOffset = find(aTagOffset, 1);

                if isempty(dRoiTagOffset) % Tag is a VOI

                    aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), asTag(jj) );
                    dVoiTagOffset = find(aTagOffset, 1);

                    if ~isempty(dVoiTagOffset) % Tag is a VOI

                        dNbRois = numel(atVoiInput{dVoiTagOffset}.RoisTag);

                        for vv=1: dNbRois

                            asRoiTags{numel(asRoiTags)+1} = atVoiInput{dVoiTagOffset}.RoisTag{vv};
                        end
                    end
                else

                    if isempty(find(ismember(asRoiTags, asTag{jj}), 1)) % The tag is not already added

                        asRoiTags{numel(asRoiTags)+1} =  asTag{jj};
                    end
                end
            end

            createVoiFromRois(dSeriesOffset, asRoiTags, [], [0 1 1], 'Unspecified');

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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
            end

            setVoiRoiSegPopup();

            uiDeleteVoiRoiPanel = uiDeleteVoiRoiPanelObject('get');
            uiLesionTypeVoiRoiPanel = uiLesionTypeVoiRoiPanelObject('get');

            if ~isempty(uiDeleteVoiRoiPanel) && ...
               ~isempty(uiLesionTypeVoiRoiPanel)

                atVoiInput = voiTemplate('get', dSeriesOffset);
                dVoiOffset = numel(atVoiInput);

                set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

                sLesionType = atVoiInput{dVoiOffset}.LesionType;
                [bLesionOffset, ~, ~] = getLesionType(sLesionType);
                set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
            end

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end

        end

        function figRoiMultiplePlotCallback(hObject, ~)

            atInput = inputTemplate('get');
            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            if dSeriesOffset > numel(atInput)
                return;
            end

            aVoiRoiTag = voiRoiTag('get');

            aInput = inputBuffer('get');

            switch lower(imageOrientation('get'))

                case'axial'
                    aInputBuffer = aInput{dSeriesOffset};

                case 'coronal'
                    aInputBuffer = reorientBuffer(aInput{dSeriesOffset}, 'coronal');

                case'sagittal'
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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')
                bSimplified = true;
            else
                bSimplified = false;
            end

            bDoseKernel      = atInput(dSeriesOffset).bDoseKernel;
            bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

            sType = get(hObject, 'Label');
            atVoiRoiTag = aVoiRoiTag(get(lbVoiRoiWindow, 'Value'));

            figRoiMultiplePlot(sType, ...
                               aInputBuffer, ...
                               atInputMetaData, ...
                               atVoiRoiTag, ...
                               bSUVUnit, ...
                               bModifiedMatrix, ...
                               bSegmented, ...
                               bDoseKernel, ...
                               bMovementApplied, ...
                               bSimplified);

            clear aInputBuffer;
            clear aInput;

        end

        function figRoiTimeActivityCallback(hObject, ~)

            atInput = inputTemplate('get');

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            if dSeriesOffset > numel(atInput)
                return;
            end

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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')
                bSimplified = true;
            else
                bSimplified = false;
            end

            bDoseKernel      = atInput(dSeriesOffset).bDoseKernel;
            bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

            sType = get(hObject, 'Label');
            atVoiRoiTag = aVoiRoiTag(get(lbVoiRoiWindow, 'Value'));

            figRoiTimeActivity(sType, ...
                               atVoiRoiTag, ...
                               bSUVUnit, ...
                               bModifiedMatrix, ...
                               bSegmented, ...
                               bDoseKernel, ...
                               bMovementApplied, ...
                               bSimplified);

            clear aInputBuffer;
            clear aInput;
        end

        function figRoiDeleteObjectCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

            if ~isempty(aVoiRoiTag)

                figRoiDeleteObject(aVoiRoiTag{lbVoiRoiWindow.Value}.Tag, true);
            end
        end

        function figRoiPredefinedLabelCallback(hObject, ~)

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', dSeriesOffset);
            atVoiInput = voiTemplate('get', dSeriesOffset);

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

                        figRoiSetLabel(atVoiInput{dTagOffset}, get(hObject, 'Text'))

                        % Refresh contour figure and contour popup

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

                        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                            bModifiedMatrix = true;
                        else
                            bModifiedMatrix = false;
                        end

                        if strcmpi(get(mSimplified, 'Checked'), 'on')

                            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                        else
                            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                bExpendVoi = true;
                            else
                                bExpendVoi = false;
                            end

                            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
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

                                figRoiSetLabel(atRoiInput{dTagOffset}, get(hObject, 'Text'));

                                % Refresh contour figure and contour popup

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

                                if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                                    bModifiedMatrix = true;
                                else
                                    bModifiedMatrix = false;
                                end

                                if strcmpi(get(mSimplified, 'Checked'), 'on')

                                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                                else
                                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                        bExpendVoi = true;
                                    else
                                        bExpendVoi = false;
                                    end

                                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                                end

                            end
                        end
                    end
                end
            end
        end

        function figRoiEditLabelCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

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

                            figRoiEditLabelDialog(atVoiInput{dTagOffset});
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

                                figRoiEditLabelDialog(atRoiInput{dTagOffset});
                            end
                        end
                    end
                end
            end

            function figRoiEditLabelDialog(ptrObject)

                EDIT_DIALOG_X = 310;
                EDIT_DIALOG_Y = 100;

                figRoiPosX  = figRoiWindow.Position(1);
                figRoiPosY  = figRoiWindow.Position(2);
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

                figRoiEditLabelCancelWindow = ...
                uicontrol(figRoiEditLabelWindow,...
                          'String','Cancel',...
                          'Position',[200 7 100 25],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback', @cancelFigRoiEditLabelCallback...
                          );

                figRoiEditLabelOkWindow = ...
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

                    set(figRoiEditLabelCancelWindow, 'Enable', 'off');
                    set(figRoiEditLabelOkWindow    , 'Enable', 'off');

                    figRoiSetLabel(ptrObject, get(edtFigRoiLabelName, 'String'))

                    if strcmpi(ptrObject.ObjectType, 'voi') % Object is a voi
                        setVoiRoiSegPopup();
                    end

                    if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                        bSUVUnit = true;
                    else
                        bSUVUnit = false;
                    end

                    if strcmpi(get(mSegmented, 'Checked'), 'on') && ...
                       atInput(dSeriesOffset).bDoseKernel == false
                        bSegmented = true;
                    else
                        bSegmented = false;
                    end

                    if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                        bModifiedMatrix = true;
                    else
                        bModifiedMatrix = false;
                    end

                    if strcmpi(get(mSimplified, 'Checked'), 'on')

                        setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                    else

                        if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                            bExpendVoi = true;
                        else
                            bExpendVoi = false;
                        end

                        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                    end

                    delete(figRoiEditLabelWindow);

                end
            end

        end

        function figRoiSetLabel(ptrObject, sLabel)

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

            else % Tag is a ROI

                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {ptrObject.Tag} );

                if aTagOffset(aTagOffset==1) % tag is a roi

                    if ~isempty(atRoiInput)

                        dTagOffset = find(aTagOffset, 1);

                        if ~isempty(dTagOffset)
                            atRoiInput{dTagOffset}.Label = sLabel;
                            if isvalid(atRoiInput{dTagOffset}.Object)
                                atRoiInput{dTagOffset}.Object.Label = sLabel;
                            end

                            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
                        end

                    end
                end

            end
        end

        function figRoiEditColorCallback(~, ~)

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', dSeriesOffset);
            atVoiInput = voiTemplate('get', dSeriesOffset);

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

                        figRoiSetColor(atVoiInput{dTagOffset}, sColor)

                        % Refresh contour figure and contour popup

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

                        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                            bModifiedMatrix = true;
                        else
                            bModifiedMatrix = false;
                        end

                        if strcmpi(get(mSimplified, 'Checked'), 'on')

                            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                        else
                            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                bExpendVoi = true;
                            else
                                bExpendVoi = false;
                            end

                            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
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

                                sColor = uisetcolor([atRoiInput{dTagOffset}.Color], 'Select a color');

                                figRoiSetColor(atRoiInput{dTagOffset}, sColor);

                                % Refresh contour figure and contour popup

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

                                if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                                    bModifiedMatrix = true;
                                else
                                    bModifiedMatrix = false;
                                end

                                if strcmpi(get(mSimplified, 'Checked'), 'on')

                                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                                else
                                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                        bExpendVoi = true;
                                    else
                                        bExpendVoi = false;
                                    end

                                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                                end

                            end
                        end
                    end
                end

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end

            end

            function figRoiSetColor(ptrObject, sColor)

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

                else % Tag is a ROI

                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {ptrObject.Tag} );

                    if aTagOffset(aTagOffset==1) % tag is a roi

                        if ~isempty(atRoiInput)

                            dTagOffset = find(aTagOffset, 1);

                            if ~isempty(dTagOffset)
                                atRoiInput{dTagOffset}.Color = sColor;
                                if isvalid(atRoiInput{dTagOffset}.Object)
                                    atRoiInput{dTagOffset}.Object.Color = sColor;
                                end

                                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
                            end
                        end
                    end
                end
            end
        end

        function figRoiHideViewFaceAlhaCallback(~, ~)

            aVoiRoiTag = voiRoiTag('get');

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
                        figRoiSetRoiFaceAlpha(atVoiInput{dTagOffset});
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

                                figRoiSetRoiFaceAlpha(atRoiInput{dTagOffset});
                            end

                        end
                    end
                end
            end

            function figRoiSetRoiFaceAlpha(ptrObject)

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

                else % Tag is a ROI

                    if ~strcmpi(ptrObject.Type, 'images.roi.line')

                        if isempty(atRoiInput)
                            aTagOffset =0;
                        else
                            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {ptrObject.Tag} );
                        end

                        if aTagOffset(aTagOffset==1) % tag is a roi

                            dFaceAlpha = 0;

                            dTagOffset = find(aTagOffset, 1);

                            if ~isempty(dTagOffset)

                                if atRoiInput{dTagOffset}.FaceAlpha == 0

                                    dFaceAlpha = roiFaceAlphaValue('get');
                                end

                                atRoiInput{dTagOffset}.FaceAlpha = dFaceAlpha;

                                if isvalid(atRoiInput{dTagOffset}.Object)

                                    atRoiInput{dTagOffset}.Object.FaceAlpha = dFaceAlpha;
                                end

                                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
                            end
                        end
                    end
                end
            end
        end
    end

    function setRoiFigureName()

        if ~isvalid(lbVoiRoiWindow)
            return;
        end

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

        if atInput(dSeriesOffset).bDoseKernel == true

            if isfield(atMetaData{1}, 'DoseUnits')

                if ~isempty(atMetaData{1}.DoseUnits)

                    sUnits = sprintf('Unit: %s', char(atMetaData{1}.DoseUnits));
                else
                    sUnits = 'Unit: dose';
                end
            else
                sUnits = 'Unit: dose';
            end

        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                sUnits = getSerieUnitValue(dSeriesOffset);
                if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                    strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(sUnits, 'SUV' )
                    sSUVtype = viewerSUVtype('get');
                    sUnits =  sprintf('Unit: SUV/%s', sSUVtype);
                else
                    if (strcmpi(atMetaData{1}.Modality, 'ct'))
                       sUnits =  'Unit: HU';
                    else
                       sUnits =  'Unit: Counts';
                    end
                end
            else
                 if (strcmpi(atMetaData{1}.Modality, 'ct'))
                    sUnits =  'Unit: HU';
                 else
                    sUnits = getSerieUnitValue(dSeriesOffset);
                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(sUnits, 'SUV' )
                        sUnits =  'Unit: BQML';
                    else

                        sUnits =  'Unit: Counts';
                    end
                 end
            end
        end

        if strcmpi(get(mSimplified, 'Checked'), 'on')

            set(figRoiWindow, 'Name', ['TriDFusion (3DF) VOI Simplified Result - ' atMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented]);
        else
            set(figRoiWindow, 'Name', ['TriDFusion (3DF) ROI/VOI Result - ' atMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented]);
        end

    end

    function setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi)

        sLbWindow = '';
        aVoiRoiTag = [];

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        sFontName = get(lbVoiRoiWindow, 'FontName');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        atInput = inputTemplate('get');

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        atVoiInput = voiTemplate('get', dSeriesOffset);
        atRoiInput = roiTemplate('get', dSeriesOffset);

        if bExpendVoi == true
    
            bExpendedDisplay = true;
        else
            bExpendedDisplay = false;
    
            if any(cellfun(@(roi) strcmpi(roi.ObjectType, 'roi'), atRoiInput))

                bExpendedDisplay = true;
            end
        end

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

        if bExpendVoi == true
    
            dNbRois = numel(atRoiInput); 
    
            for ro=1:dNbRois
    
                if strcmpi(atRoiInput{ro}.ObjectType, 'voi-roi')
                    
                    if ~isfield(atRoiInput{ro}, 'MaxDistances')
                        
                        tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{ro}, false, false);
        
                        atRoiInput{ro}.MaxDistances = tMaxDistances;        
    
                        roiTemplate('set', dSeriesOffset, atRoiInput);
                   end 
                end
            end        
        end

        dNbVois = numel(atVoiInput);

        if ~isempty(atVoiInput)

            for aa=1:dNbVois

                if ~isempty(atVoiInput{aa}.RoisTag)

                    if dNbVois > 10

                        if mod(aa, 5)==1 || aa == dNbVois

                            progressBar(aa/dNbVois-0.0001, sprintf('Computing voi %d/%d', aa, dNbVois ) );
                        end
                    end

                    [tVoiComputed, atRoiComputed] = ...
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

%                         if tVoiComputed.maxDistance == 0
%                             sMaxDistance = 'NaN';
%                         else
%                             sMaxDistance = num2str(tVoiComputed.maxDistance);
%                         end
                        if bExpendedDisplay == true

                            sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                                maxLength(sVoiName, 17), ...
                                ' ', ...
                                num2str(tVoiComputed.cells), ...
                                num2str(tVoiComputed.total), ...
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
                        else
                            sLine = sprintf('%-18s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                                maxLength(sVoiName, 17), ...
                                num2str(tVoiComputed.cells), ...
                                num2str(tVoiComputed.total), ...
                                num2str(tVoiComputed.sum), ...
                                num2str(tVoiComputed.mean), ...
                                num2str(tVoiComputed.min), ...
                                num2str(tVoiComputed.max), ...
                                num2str(tVoiComputed.median), ...
                                num2str(tVoiComputed.std), ...
                                num2str(tVoiComputed.peak), ...
                                num2str(tVoiComputed.volume));                            
                        end

                        if isFigRoiInColor('get') == true

                            sLine = strrep(sLine, ' ', '&nbsp;');

                            aColor = atVoiInput{aa}.Color;
                            sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                            sLine  = sprintf('<HTML><FONT color="%s" face="%s"><b>%s</b>', sColor, sFontName, sLine);
                        end

                        sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                        if ~isempty(aVoiRoiTag)

                            dResizeArray = numel(aVoiRoiTag)+1;

                            aVoiRoiTag{dResizeArray}.Tag = atVoiInput{aa}.Tag;

                        else
                             aVoiRoiTag{1}.Tag = atVoiInput{aa}.Tag;
                        end

                        if bExpendVoi == true

                            dNbTags =numel(atRoiComputed);
                            for bb=1:numel(atRoiComputed)

                                if ~isempty(atRoiComputed{bb})

                                    if dNbTags > 100
                                        if mod(bb, 10)==1 || bb == dNbTags
                                            progressBar( bb/dNbTags-0.0001, sprintf('Computing roi %d/%d, please wait.', bb, dNbTags) );
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

    %                                 if isfield(atRoiComputed{bb}, 'subtraction')
    %                                     sSubtraction = num2str(atRoiComputed{bb}.subtraction);
    %                                 else
    %                                     sSubtraction = 'NaN';
    %                                 end            

                                    if ~isempty(atRoiComputed{bb}.MaxDistances)

                                        if atRoiComputed{bb}.MaxDistances.MaxXY.Length == 0
                                            sMaxXY = 'NaN';
                                        else
                                            sMaxXY = num2str(atRoiComputed{bb}.MaxDistances.MaxXY.Length);
                                        end

                                        if atRoiComputed{bb}.MaxDistances.MaxCY.Length == 0
                                            sMaxCY = 'NaN';
                                        else
                                            sMaxCY = num2str(atRoiComputed{bb}.MaxDistances.MaxCY.Length);
                                        end
                                    else
                                        sMaxXY = ' ';
                                        sMaxCY = ' ';
                                    end

                                    sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                                        ' ', ...
                                        sSliceNb, ...
                                        num2str(atRoiComputed{bb}.cells), ...
                                        num2str(atRoiComputed{bb}.total), ...
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
                                        ' ');

                                     if isFigRoiInColor('get') == true
                                         sLine = strrep(sLine, ' ', '&nbsp;');

                                         aColor = atRoiComputed{bb}.Color;
                                         sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                                         sLine  = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                                     end

                                     sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                                     dResizeArray = numel(aVoiRoiTag)+1;

                                     aVoiRoiTag{dResizeArray}.Tag = atRoiComputed{bb}.Tag;

                                end
                            end
                        end
                    end
                end
            end
        end

        if ~isempty(atRoiInput)

            dNbTags = numel(atRoiInput);
            for bb=1:dNbTags

               if dNbTags > 100
                   if mod(bb, 10)==1 || bb == dNbTags
                       progressBar( bb/dNbTags-0.0001, sprintf('Computing roi %d/%d, please wait.', bb, dNbTags) );
                   end
               end

%               if isvalid(atRoiInput{bb}.Object)
                    if strcmpi(atRoiInput{bb}.ObjectType, 'roi')

                        if ~isfield(atRoiInput{bb}, 'MaxDistances')
                            
                            tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{bb}, false, false);

                            atRoiInput{bb}.MaxDistances = tMaxDistances;

                            roiTemplate('set', dSeriesOffset, atRoiInput);
                        end

                        tRoiComputed = ...
                            computeRoi(aInputBuffer, ...
                                       atInputMetaData, ...
                                       aDisplayBuffer, ...
                                       atMetaData, ...
                                       atRoiInput{bb}, ...
                                       dSUVScale, ...
                                       bSUVUnit, ...
                                       bModifiedMatrix, ...
                                       bSegmented, ...
                                       bDoseKernel, ...
                                       bMovementApplied);

                        sRoiName = atRoiInput{bb}.Label;

                        if strcmpi(atRoiInput{bb}.Axe, 'Axe')
                            sSliceNb = num2str(atRoiInput{bb}.SliceNb);
                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes1')
                            sSliceNb = ['C:' num2str(atRoiInput{bb}.SliceNb)];
                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes2')
                            sSliceNb = ['S:' num2str(atRoiInput{bb}.SliceNb)];
                        elseif strcmpi(atRoiInput{bb}.Axe, 'Axes3')
                            sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-atRoiInput{bb}.SliceNb+1)];
                        end

                        if ~isempty(tRoiComputed.MaxDistances)

                            if tRoiComputed.MaxDistances.MaxXY.Length == 0
                                sMaxXY = 'NaN';
                            else
                                sMaxXY = num2str(tRoiComputed.MaxDistances.MaxXY.Length);
                            end

                            if tRoiComputed.MaxDistances.MaxCY.Length == 0
                                sMaxCY = 'NaN';
                            else
                                sMaxCY = num2str(tRoiComputed.MaxDistances.MaxCY.Length);
                            end
                        else
                            sMaxXY = ' ';
                            sMaxCY = ' ';
                        end

                        sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                            maxLength(sRoiName, 17), ...
                            sSliceNb, ...
                            num2str(tRoiComputed.cells), ...
                            num2str(tRoiComputed.total), ...
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
                            ' ');

                        if isFigRoiInColor('get') == true
                            sLine = strrep(sLine, ' ', '&nbsp;');

                            aColor = atRoiInput{bb}.Color;
                            sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                            sLine = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                        end

                        sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                        if exist('aVoiRoiTag', 'var')
                            dResizeArray = numel(aVoiRoiTag)+1;
                            aVoiRoiTag{dResizeArray}.Tag = atRoiInput{bb}.Tag;
                        else
                            aVoiRoiTag{1}.Tag = atRoiInput{bb}.Tag;
                        end
                    end
%               end
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

            if dListboxValue < size(lbVoiRoiWindow.String, 1)
                set(lbVoiRoiWindow, 'Value', dListboxValue);
                set(lbVoiRoiWindow, 'ListboxTop', dListboxTop);

            else
                set(lbVoiRoiWindow, 'Value', size(lbVoiRoiWindow.String, 1));
                set(lbVoiRoiWindow, 'ListboxTop', size(lbVoiRoiWindow.String, 1));
            end
        end

        voiRoiTag('set', aVoiRoiTag);

        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error:setVoiRoiListbox()');
        end

        clear aInput;
        clear aInputBuffer;
        clear aDisplayBuffer;

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;

    end

    function setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented)

        aVoiTag = [];

        sLbWindow = '';

        sFontName = get(lbVoiRoiWindow, 'FontName');
        
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        atInput = inputTemplate('get');

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        atVoiInput = voiTemplate('get', dSeriesOffset);
        atRoiInput = roiTemplate('get', dSeriesOffset);

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

                    tMaxDistances = computeVoiPlanesFarthestPoint(atVoiInput{aa}, atRoiInput, atMetaData, aDisplayBuffer, false);

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

                        sLine = sprintf('%-18s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
                            maxLength(sVoiName, 17), ...
                            num2str(tVoiComputed.cells), ...
                            num2str(tVoiComputed.total), ...
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

                        if isFigRoiInColor('get') == true
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

            if dListboxValue < size(lbVoiRoiWindow.String, 1)
                set(lbVoiRoiWindow, 'Value', dListboxValue);
                set(lbVoiRoiWindow, 'ListboxTop', dListboxTop);
            else
                set(lbVoiRoiWindow, 'Value', size(lbVoiRoiWindow.String, 1));
                set(lbVoiRoiWindow, 'ListboxTop', size(lbVoiRoiWindow.String, 1));
            end
        end


        voiRoiTag('set', aVoiTag);

        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error:setVoiSimplifiedListbox()');
        end

        clear aInput;
        clear aInputBuffer;
        clear aDisplayBuffer;

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;

    end

    function exportCurrentSeriesResultCallback(~, ~)

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

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

        if strcmpi(get(mExpendVoi, 'Checked'), 'on')
            bExpendVoi = true;
        else
            bExpendVoi = false;
        end

        if strcmpi(get(mSimplified, 'Checked'), 'on')

            exportSimplifiedContoursReport(bSUVUnit, bSegmented, bModifiedMatrix);
        else

            exportContoursReport(bSUVUnit, bSegmented, bModifiedMatrix, bExpendVoi);
        end

        catch
            progressBar(1, 'Error: exportCurrentSeriesResultCallback()');
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;

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
            progressBar(1, 'Error:copyRoiDialogDisplayCallback()');
        end

        set(figRoiWindow, 'Pointer', 'default');
    end

    function simplifiedDisplayCallback(hObject, ~)

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

        if strcmpi(get(hObject, 'Checked'), 'on')

            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                bExpendVoi = true;
            else
                bExpendVoi = false;
            end

            set(hObject, 'Checked', 'off');

            isfigVoiSimplified('set', false);

            setRoiFigureUiContorl();

            setRoiFigureName();

            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
       else
            set(hObject, 'Checked', 'on');

            isfigVoiSimplified('set', true);

            setRoiFigureUiContorl();

            setRoiFigureName();

            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
        end

    end

    function expendVoiCallback(hObject, ~)

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

        if strcmpi(get(hObject, 'Checked'), 'on')

            set(hObject, 'Checked', 'off');

            isfigVoiExpendVoi('set', false);

            setRoiFigureUiContorl();

            setRoiFigureName();

            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, false);
       else
            set(hObject, 'Checked', 'on');

            isfigVoiExpendVoi('set', true);

            setRoiFigureUiContorl();

            setRoiFigureName();

            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, true);
        end
    end

    function SUVUnitCallback(hObject, ~)

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

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(false, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(false, bModifiedMatrix, bSegmented, bExpendVoi);
            end

        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(true, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(true, bModifiedMatrix, bSegmented, bExpendVoi);
            end
        end

        setRoiFigureName();
    end

    function modifiedMatrixCallback(hObject, ~)

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

                if strcmpi(get(mSimplified, 'Checked'), 'on')

                    setVoiSimplifiedListbox(bSUVUnit, true, bSegmented);
                else
                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                        bExpendVoi = true;
                    else
                        bExpendVoi = false;
                    end

                    setVoiRoiListbox(bSUVUnit, true, bSegmented, bExpendVoi);
                end
            else
                modifiedMatrixValueMenuOption('set', false);
                hObject.Checked = 'off';

                segMenuOption('set', false);
                set(mSegmented, 'Checked', 'off');

                if strcmpi(get(mSimplified, 'Checked'), 'on')

                    setVoiSimplifiedListbox(bSUVUnit, false, false);
                else
                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                        bExpendVoi = true;
                    else
                        bExpendVoi = false;
                    end

                    setVoiRoiListbox(bSUVUnit, false, false, bExpendVoi);
                end
            end
        else
            modifiedMatrixValueMenuOption('set', true);
            hObject.Checked = 'on';

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, true, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, true, bSegmented, bExpendVoi);
            end
       end

        setRoiFigureName();
    end

    function segmentedCallback(hObject, ~)

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

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, false);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, false, bExpendVoi);
            end
        else
            if bModifiedMatrix == true

                hObject.Checked = 'on';
                segMenuOption('set', true);

                if strcmpi(get(mSimplified, 'Checked'), 'on')

                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, true);
                else
                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                        bExpendVoi = true;
                    else
                        bExpendVoi = false;
                    end

                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, true, bExpendVoi);
                end
            else
                hObject.Checked = 'off';
                segMenuOption('set', false);
            end
       end

        setRoiFigureName();
    end

    function lbMainWindowCallback(hObject, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        aVoiRoiTag = voiRoiTag('get');
        atRoiInput = roiTemplate('get', dSeriesOffset);
        atVoiInput = voiTemplate('get', dSeriesOffset);

        bTagIsVoi = false;

        if ~isempty(atVoiInput) && ...
           ~isempty(aVoiRoiTag) && ...
           isscalar(hObject.Value)

            if numel(aVoiRoiTag) <  hObject.Value
                return;
            end

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            dTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{hObject.Value}.Tag ), 1);

            if ~isempty(dTagOffset)

                dRoiOffset = round(numel(atVoiInput{dTagOffset}.RoisTag)/2);

                triangulateRoi(atVoiInput{dTagOffset}.RoisTag{dRoiOffset});

                changeVoiRoiSegPopupValue(atVoiInput{dTagOffset}, dTagOffset);

                bTagIsVoi = true;
            end

%
%             for cc=1:numel(atVoiInput)
% %                if isvalid(atRoiInput{cc}.Object)
%                     if strcmp(atVoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)
%
%                         dRoiOffset = round(numel(atVoiInput{cc}.RoisTag)/2);
%
%                         triangulateRoi(atVoiInput{cc}.RoisTag{dRoiOffset});
%                         bTagIsVoi = true;
%
%                         break;
%                     end
% %                end
%             end
        end

        if ~isempty(atRoiInput) && ...
           ~isempty(aVoiRoiTag) && ...
           bTagIsVoi == false && ...
           isscalar(hObject.Value)

            if numel(aVoiRoiTag) <  hObject.Value
                return;
            end

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), aVoiRoiTag{hObject.Value}.Tag ), 1);

            if ~isempty(dTagOffset)

                if ~strcmpi(atRoiInput{dTagOffset}.Type, 'images.roi.line')

                    triangulateRoi(atRoiInput{dTagOffset}.Tag);

                    if strcmpi(atRoiInput{dTagOffset}.ObjectType, 'voi-roi')

                        if ~isempty(atVoiInput)

                            for vv=1:numel(atVoiInput)

                                 dVoiTagOffset = find(contains(atVoiInput{vv}.RoisTag, atRoiInput{dTagOffset}.Tag), 1);

                                if ~isempty(dVoiTagOffset)

                                    changeVoiRoiSegPopupValue(atVoiInput{vv}, vv);
                                    break;
                                end
                            end

                        end
                    end
                end
            end

%             for cc=1:numel(atRoiInput)
% %                if isvalid(atRoiInput{cc}.Object)
%                     if strcmp(atRoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)
%                         if ~strcmpi(atRoiInput{cc}.Type, 'images.roi.line')
%                             triangulateRoi(atRoiInput{cc}.Tag)
%                         end
%                         break;
%                     end
% %                end
%             end

        end
    end

    function clearAllMasksCallback(~, ~)

        roiConstraintList('reset', get(uiSeriesPtr('get'), 'Value'));
    end

    function clearAllContoursCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        sAnswer = questdlg('Pressing will delete all contours', 'Warning', 'Delete', 'Exit', 'Exit');

        if strcmpi(sAnswer, 'Delete')

            try
            set(figRoiWindow, 'Pointer', 'watch');
            drawnow;

            roiConstraintList('reset', dSeriesOffset); % Delete all masks

            voiRoiTag('set', '');

            % Delete object

            atRoi = roiTemplate('get', dSeriesOffset);

            for rr=1:numel(atRoi)

                % Delete farthest distance objects
                
                if roiHasMaxDistances(atRoi{rr}) == true

                    maxDistances = atRoi{rr}.MaxDistances; % Cache the field to avoid repeated lookups
                    if ~isempty(maxDistances)

                        objectsToDelete = [maxDistances.MaxXY.Line, ...
                                           maxDistances.MaxCY.Line, ...
                                           maxDistances.MaxXY.Text, ...
                                           maxDistances.MaxCY.Text];
                        % Delete only valid objects
                        delete(objectsToDelete(isvalid(objectsToDelete)));
                    end
                end

                % Delete ROI object

                if isvalid(atRoi{rr}.Object)

                    delete(atRoi{rr}.Object)
                end
            end

            % Reset template

            roiTemplate('reset', dSeriesOffset);
            voiTemplate('reset', dSeriesOffset);

            setVoiRoiSegPopup();

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end
                if strcmpi(get(mSimplified, 'Checked'), 'on')

                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                else
                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                        bExpendVoi = true;
                    else
                        bExpendVoi = false;
                    end

                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                end

            catch
                progressBar(1, 'Error: clearAllContoursCallback()' );
            end

            set(figRoiWindow, 'Pointer', 'default');
            drawnow;
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

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end

        if strcmpi(get(mSimplified, 'Checked'), 'on')

            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
        else
            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                bExpendVoi = true;
            else
                bExpendVoi = false;
            end

            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
        end

    end

    function figRoiCopyAllObjectsCallback(hObject, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        sCopyTo = get(hObject, 'Text');

        dToSeriesOffset = 0;

        asSeriesDescription = seriesDescription('get');
        for sd=1:numel(asSeriesDescription)
            if strcmpi(sCopyTo, asSeriesDescription{sd}) && dSeriesOffset ~= sd
                dToSeriesOffset = sd;
                break;
            end
        end

        if dSeriesOffset == dToSeriesOffset
            return;
        end

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        atRoiInput = roiTemplate('get', dSeriesOffset);
        atVoiInput = voiTemplate('get', dSeriesOffset);

        % Copy all VOIs

        if ~isempty(atVoiInput)

            dNbVois = numel(atVoiInput);

            for aa=1:dNbVois

                progressBar(aa/dNbVois-0.01, sprintf('Processing voi %d/%d, please wait.', aa, dNbVois));

                copyRoiVoiToSerie(dSeriesOffset, dToSeriesOffset, atVoiInput{aa}, false);
            end
        end

        % Copy all ROIs

        if ~isempty(atRoiInput)

            dNbRois = numel(atRoiInput);

            for cc=1:numel(atRoiInput)

                if isvalid(atRoiInput{cc}.Object)

                    if ~strcmpi(atRoiInput{cc}.ObjectType, 'voi-roi')

                        if mod(cc, 5)==1 || cc == dNbRois

                            progressBar(cc/dNbRois-0.01, sprintf('Processing voi-roi %d/%d, please wait.', cc, dNbRois));
                        end

                        copyRoiVoiToSerie(dSeriesOffset, dToSeriesOffset, atRoiInput{cc}, false);
                    end
                end
            end
        end

        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error: figRoiCopyObjectCallback()' );
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;
    end

    function figRoiCopyObjectCallback(hObject, ~)

        sCopyTo = get(hObject, 'Text');

        aVoiRoiTag = voiRoiTag('get');

        if ~isempty(aVoiRoiTag)

            figRoiCopyObject(aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag, sCopyTo);
        end
    end

    function figRoiCopyObject(pVoiRoiTag, sCopyTo)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        dToSeriesOffset = 0;

        asSeriesDescription = seriesDescription('get');
        for sd=1:numel(asSeriesDescription)
            if strcmpi(sCopyTo, asSeriesDescription{sd}) && dSeriesOffset ~= sd
                dToSeriesOffset = sd;
                break;
            end
        end

        if dSeriesOffset == dToSeriesOffset
            return;
        end

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        bObjectIsVoi = false;

        if ~isempty(atVoiInput)

            dNbVois = numel(atVoiInput);

            for aa=1:numel(atVoiInput)

                if strcmpi(atVoiInput{aa}.Tag, pVoiRoiTag)

                    % Object is a VOI

                    progressBar(aa/dNbVois-0.01, sprintf('Processing voi %d/%d, please wait.', aa, dNbVois));

                    copyRoiVoiToSerie(dSeriesOffset, dToSeriesOffset, atVoiInput{aa}, false);
                    bObjectIsVoi = true;
                    break;
                end

            end

        end

        if bObjectIsVoi == false

            if ~isempty(atRoiInput)

                dNbRois = numel(atRoiInput);

                for cc=1:numel(atRoiInput)
                    if isvalid(atRoiInput{cc}.Object)
                        if strcmpi(atRoiInput{cc}.Tag, pVoiRoiTag)

                            if strcmpi(atRoiInput{cc}.ObjectType, 'voi-roi')
                                atRoiInput{cc}.ObjectType = 'roi';
                            end

                            if mod(cc, 5)==1 || cc == dNbRois

                                progressBar(cc/dNbRois-0.01, sprintf('Processing roi %d/%d, please wait.', cc, dNbRois));
                            end

                            % Object is a ROI
                            copyRoiVoiToSerie(dSeriesOffset, dToSeriesOffset, atRoiInput{cc}, false);
                            break;
                        end
                    end
                end
            end
        end

        progressBar(1, 'Ready');

        catch
            progressBar(1, 'Error: figRoiCopyObjectCallback()' );
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;
    end

    function figRoiInsertBetweenRoisCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atRoiInput = roiTemplate('get', dSeriesOffset);
        % atVoiInput = voiTemplate('get', dSeriesOffset);

        aVoiRoiTag = voiRoiTag('get');

        asTag = cell(1, numel(aVoiRoiTag));

        for hh=1:numel(aVoiRoiTag)
            asTag{hh} = aVoiRoiTag{hh}.Tag;
        end


        asTag = asTag(get(lbVoiRoiWindow, 'Value'));

        if numel(asTag) == 2

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag(1) );
            aRoiTagOffset1 = find(aTagOffset, 1);

            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag(2) );
            aRoiTagOffset2 = find(aTagOffset, 1);

            if isempty(aRoiTagOffset1) || ...
               isempty(aRoiTagOffset2)
                return;
            end

            if ~strcmpi(atRoiInput{aRoiTagOffset1}.Axe, atRoiInput{aRoiTagOffset2}.Axe) % Not same plane
                return;
            end

            if strcmpi(atRoiInput{aRoiTagOffset1}.Type, 'images.roi.line') || ... % Cant interpolate a line
               strcmpi(atRoiInput{aRoiTagOffset2}.Type, 'images.roi.line')
                return;
            end

            if atRoiInput{aRoiTagOffset1}.SliceNb == ... % Need to be on a different slice
               atRoiInput{aRoiTagOffset2}.SliceNb
                return;
            end

            try

            set(figRoiWindow, 'Pointer', 'watch');
            drawnow;

            interpolateBetweenROIs(atRoiInput{aRoiTagOffset1},  atRoiInput{aRoiTagOffset2}, dSeriesOffset, false); 

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

            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                bModifiedMatrix = true;
            else
                bModifiedMatrix = false;
            end

            if strcmpi(get(mSimplified, 'Checked'), 'on')

                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
            else
                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                    bExpendVoi = true;
                else
                    bExpendVoi = false;
                end

                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
            end

            catch
                progressBar(1, 'Error:figRoiInsertBetweenRoisCallback()');
            end

            set(figRoiWindow, 'Pointer', 'default');
            drawnow;

        end

    end

    function figRoiDeleteObject(pVoiRoiTag, bUpdateVoiRoiListbox)

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

                                if roiHasMaxDistances(atRoiInput{aRoisTagOffset(ro)}) == true

                                    maxDistances = atRoiInput{aRoisTagOffset(ro)}.MaxDistances; % Cache the MaxDistances field
                                    objectsToDelete = [maxDistances.MaxXY.Line, ...
                                                       maxDistances.MaxCY.Line, ...
                                                       maxDistances.MaxXY.Text, ...
                                                       maxDistances.MaxCY.Text];
                                    % Delete only valid objects
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

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                    if bUpdateVoiRoiListbox

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

                        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                            bModifiedMatrix = true;
                        else
                            bModifiedMatrix = false;
                        end

                        if strcmpi(get(mSimplified, 'Checked'), 'on')

                            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                        else
                            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                bExpendVoi = true;
                            else
                                bExpendVoi = false;
                            end

                            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                        end
                    end
                end

            else % Tag is a ROI

                if isempty(atRoiInput)
                    aTagOffset = 0;
                else
                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), pVoiRoiTag );
                end

                if aTagOffset(aTagOffset==1) % tag is a roi

                    dTagOffset = find(aTagOffset, 1);

                    if ~isempty(dTagOffset)

                        % Clear it constraint

                        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

                        if ~isempty(asConstraintTagList)

                            dConstraintOffset = find(contains(asConstraintTagList, {pVoiRoiTag}));
                            if ~isempty(dConstraintOffset) % tag exist
                                 roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                            end
                        end

                        % Delete farthest distance objects

                        if roiHasMaxDistances(atRoiInput{dTagOffset}) == true
      
                            maxDistances = atRoiInput{dTagOffset}.MaxDistances; % Cache the field to avoid repeated lookups
                            objectsToDelete = [maxDistances.MaxXY.Line, ...
                                               maxDistances.MaxCY.Line, ...
                                               maxDistances.MaxXY.Text, ...
                                               maxDistances.MaxCY.Text];
                            % Delete only valid objects
                            delete(objectsToDelete(isvalid(objectsToDelete)));
                        end
                        
                        % Delete ROI object

                        if isvalid(atRoiInput{dTagOffset}.Object)

                            delete(atRoiInput{dTagOffset}.Object)
                        end

                        atRoiInput(dTagOffset) = [];

%                            atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                        roiTemplate('set', dSeriesOffset, atRoiInput);


                        % Clear roi from voi input template (if exist)

                        if ~isempty(atVoiInput)

                            for vo=1:numel(atVoiInput)

                                dTagOffset = find(contains(atVoiInput{vo}.RoisTag, pVoiRoiTag));

                                if ~isempty(dTagOffset) % tag exist
                                    atVoiInput{vo}.RoisTag{dTagOffset} = [];
                                    atVoiInput{vo}.RoisTag(cellfun(@isempty, atVoiInput{vo}.RoisTag)) = [];

                                    if isempty(atVoiInput{vo}.RoisTag)
                                        atVoiInput{vo} = [];
                                    else
                                        % Rename voi-roi label
                                        atRoiInput = roiTemplate('get', dSeriesOffset);

                                        dNbTags = numel(atVoiInput{vo}.RoisTag);

                                        for dRoiNb=1:dNbTags

                                            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{vo}.RoisTag{dRoiNb} );

                                            if ~isempty(aTagOffset)

                                                dTagOffset = find(aTagOffset, 1);

                                                if~isempty(dTagOffset)

                                                    sLabel = sprintf('%s (roi %d/%d)', atVoiInput{vo}.Label, dRoiNb, dNbTags);

                                                    atRoiInput{dTagOffset}.Label = sLabel;
                                                    atRoiInput{dTagOffset}.Object.Label = sLabel;
                                               end
                                            end
                                        end

                                        roiTemplate('set', dSeriesOffset, atRoiInput);
                                   end

                                end
                            end

                           atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                           voiTemplate('set', dSeriesOffset, atVoiInput);

                        end

                        setVoiRoiSegPopup();

                        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                            plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                        end

                        if bUpdateVoiRoiListbox

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

                            if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                                bModifiedMatrix = true;
                            else
                                bModifiedMatrix = false;
                            end

                            if strcmpi(get(mSimplified, 'Checked'), 'on')

                                setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                            else
                                if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                                    bExpendVoi = true;
                                else
                                    bExpendVoi = false;
                                end

                                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                            end
                        end
                    end
                end
            end
        end
    end

    function figRoiDeleteMultipleObjectsCallback(~, ~)

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atRoiInput = roiTemplate('get', dSeriesOffset);
        atVoiInput = voiTemplate('get', dSeriesOffset);

        aVoiRoiTag = voiRoiTag('get');

        % Delete all ROIs

        for ii=1:numel(lbVoiRoiWindow.Value)

            if ~isempty(atVoiInput)

                if isempty(find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % Tag is not a VOI

                    if ~isempty(find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % ROI tag exist

                        figRoiDeleteObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, false);
                    end
                end
            else
                if ~isempty(atRoiInput)

                    if ~isempty(find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % ROI tag exist

                        figRoiDeleteObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, false);
                    end
                end

            end
        end

        % Delete all VOIs

        atVoiInput = voiTemplate('get', dSeriesOffset);

        for ii=1:numel(lbVoiRoiWindow.Value) % Delete all VOI
            if ~isempty(atVoiInput)

                if ~isempty(find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % Tag is not a VOI

                    figRoiDeleteObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, false);

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

        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end

        if strcmpi(get(mSimplified, 'Checked'), 'on')

            setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
        else
            if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                bExpendVoi = true;
            else
                bExpendVoi = false;
            end

            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
        end
    end

    function figRoiCopyMultipleObjectsCallback(hObject, ~)

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        sCopyTo = get(hObject, 'Text');

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        atRoiInput = roiTemplate('get', dSeriesOffset);
        atVoiInput = voiTemplate('get', dSeriesOffset);

        aVoiRoiTag = voiRoiTag('get');

        % Copy all ROIs

        for ii=1:numel(lbVoiRoiWindow.Value)

            if ~isempty(atVoiInput)

                if isempty(find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % Tag is not a VOI

                    if ~isempty(find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % ROI tag exist

                        bObjectIsPartOfACopiedVOI = false;

                        for ll=1:numel(lbVoiRoiWindow.Value)

                            dVoiOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ll)}.Tag ), 1);

                            if ~isempty(dVoiOffset) % VOI exist

                                if ~isempty(find(contains(atVoiInput{dVoiOffset}.RoisTag, aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag), 1))
                                    bObjectIsPartOfACopiedVOI = true;
                                    break;
                                end

                            end

                        end

                        if bObjectIsPartOfACopiedVOI == false

                            figRoiCopyObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, sCopyTo);
                        end
                    end
                end
            else
                if ~isempty(atRoiInput)

                    if ~isempty(find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % ROI tag exist

                        figRoiCopyObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, sCopyTo);
                    end
                end

            end
        end

        % Copy all VOIs

        atVoiInput = voiTemplate('get', dSeriesOffset);

        for ii=1:numel(lbVoiRoiWindow.Value) % Delete all VOI
            if ~isempty(atVoiInput)

                if ~isempty(find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag ), 1)) % Tag is not a VOI

                    figRoiCopyObject(aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag, sCopyTo);

                end
            end
        end

        catch
             progressBar(1, 'Error:figRoiCopyMultipleObjectsCallback()');
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;
    end

    function figRoiCopyMultipleMirrorCallback(hObject, ~)

        try

        set(figRoiWindow, 'Pointer', 'watch');
        drawnow;

        dToSeriesOffset = 0;

        bRefreshListbox = false;

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        sCopyTo = get(hObject, 'Text');

        asSeriesDescription = seriesDescription('get');
        for sd=1:numel(asSeriesDescription)
            if strcmpi(sCopyTo, asSeriesDescription{sd})
                dToSeriesOffset = sd;
                break;
            end
        end

        aVoiRoiTag = voiRoiTag('get');

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        for ii=1:numel(lbVoiRoiWindow.Value)

            tObject = [];

            if ~isempty(atVoiInput) && ...
               ~isempty(aVoiRoiTag)

                for aa=1:numel(atVoiInput)
                    if strcmpi(atVoiInput{aa}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag)
                        % Object is a VOI
                        tObject = atVoiInput{aa};
                        break;
                    end

                end

            end

            if ~isempty(atRoiInput) && ...
               ~isempty(aVoiRoiTag)

                for cc=1:numel(atRoiInput)
                    if isvalid(atRoiInput{cc}.Object)
                        if strcmpi(atRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value(ii)}.Tag)
                            % Object is a ROI
                            tObject = atRoiInput{cc};
                            break;
                        end
                    end
                end
            end

            if dToSeriesOffset~=0 && ~isempty(tObject)
                % Copy the object
                copyRoiVoiToSerie(dSeriesOffset, dToSeriesOffset, tObject, true);
                bRefreshListbox = true;
            end
        end

        if bRefreshListbox == true

            if dSeriesOffset == dToSeriesOffset % Refresh ROIs list
                if strcmpi(get(mSUVUnit, 'Checked'), 'on')
                    bSUVUnit = true;
                else
                    bSUVUnit = false;
                end

                if strcmpi(get(mSegmented, 'Checked'), 'on') && ...
                   atInput(dSeriesOffset).bDoseKernel == false
                    bSegmented = true;
                else
                    bSegmented = false;
                end

                if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                    bModifiedMatrix = true;
                else
                    bModifiedMatrix = false;
                end

                if strcmpi(get(mSimplified, 'Checked'), 'on')

                    setVoiSimplifiedListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                else
                    if strcmpi(get(mExpendVoi, 'Checked'), 'on')
                        bExpendVoi = true;
                    else
                        bExpendVoi = false;
                    end

                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented, bExpendVoi);
                end
            end
        end

        catch
             progressBar(1, 'Error:figRoiCopyMultipleMirrorCallback()');
        end

        set(figRoiWindow, 'Pointer', 'default');
        drawnow;
    end

    function sOutput = maxLength(sString, iMaxLength)

        if numel(sString) > iMaxLength
            sOutput = sString(1:iMaxLength);
        else
            sOutput = sString;
        end

    end
%     function largestBoundary = getLargestboundary(cBoundaries)
%
%         % Initialize variables to keep track of the largest boundary and its size
%         largestBoundary = 1;
%         largestSize = 0;
%
%         % Determine the number of boundaries outside the loop for efficiency
%         numBoundaries = length(cBoundaries);
%
%         % Loop through each boundary in 'B'
%         for k = 1:numBoundaries
%             % Get the current boundary
%             boundary = cBoundaries{k};
%
%             % Calculate the size of the current boundary
%             boundarySize = size(boundary, 1);
%
%             % Check if the current boundary is larger than the previous largest
%             if boundarySize > largestSize
%                 largestSize = boundarySize;
%                 largestBoundary = k;
%             end
%         end
%     end
end
