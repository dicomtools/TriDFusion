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

    FIG_ROI_X = 1500;
    FIG_ROI_Y =  ySize*0.75;

    atInput = inputTemplate('get');

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(atInput)
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
        figure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_ROI_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_ROI_Y/2) ...
               FIG_ROI_X ...
               FIG_ROI_Y],...
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
    
    mModifiedMatrix   = ...
        uimenu(mRoiOptions,'Label', 'Display Image Cells Value' , 'Checked', sModifiedMatrixChecked, 'Callback', @modifiedMatrixCallback);
    
    mSegmented        = ...
        uimenu(mRoiOptions,'Label', 'Subtract Masked Cells' , 'Checked', sSegChecked, 'Callback', @segmentedCallback);

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
               'String'  , 'Cells'...
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
               'Position', [1350 uiVoiRoiWindow.Position(4)-20 150 20],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'String'  , 'Volume cm3'...
               );

    tRoiMetaData = dicomMetaData('get');

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
                
    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);

    setRoiFigureName();

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

        set(mSUVUnit         , 'Checked', sSuvChecked);
        set(mModifiedMatrix  , 'Checked', sModifiedMatrixChecked);
        set(mSegmented       , 'Checked', sSegChecked);
        set(mColorBackground , 'Checked', sFigRoiInColorChecked);
        set(mInvertConstraint, 'Checked', sInvConstChecked);

    end

    function roiClickDown(~, ~)

        if strcmp(get(figRoiWindow,'selectiontype'),'alt')
            
            bDispayMenu = false;
            
            aVoiRoiTag = voiRoiTag('get', get(uiSeriesPtr('get'), 'Value'));
            atRoiInput  = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                

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

                atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
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

                if ~isempty(atRoiInput)
                    for dd=1:numel(atRoiInput)
                        if isvalid(atRoiInput{dd}.Object)
                            if strcmpi(atRoiInput{dd}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                                if strcmpi(atRoiInput{dd}.Type, 'images.roi.line')
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
            
            atInput = inputTemplate('get');
            dOffset = get(uiSeriesPtr('get'), 'Value');
            if dOffset > numel(atInput)
                return;
            end
        
            aVoiRoiTag = voiRoiTag('get');

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
            aInput = inputBuffer('get');
            if     strcmpi(imageOrientation('get'), 'axial')
                aInputBuffer = permute(aInput{dOffset}, [1 2 3]);
            elseif strcmpi(imageOrientation('get'), 'coronal')
                aInputBuffer = permute(aInput{dOffset}, [3 2 1]);
            elseif strcmpi(imageOrientation('get'), 'sagittal')
                aInputBuffer = permute(aInput{dOffset}, [3 1 2]);
            end

            if size(aInputBuffer, 3) ==1

                if atInput(dOffset).bFlipLeftRight == true
                    aInputBuffer=aInputBuffer(:,end:-1:1);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aInputBuffer=aInputBuffer(end:-1:1,:);
                end            
            else
                if atInput(dOffset).bFlipLeftRight == true
                    aInputBuffer=aInputBuffer(:,end:-1:1,:);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aInputBuffer=aInputBuffer(end:-1:1,:,:);
                end

                if atInput(dOffset).bFlipHeadFeet == true
                    aInputBuffer=aInputBuffer(:,:,end:-1:1);
                end 
            end   

            atInputMetaData = atInput(dOffset).atDicomInfo;
        
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
                        
                        bDoseKernel      = atInput(dOffset).bDoseKernel;
                        bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;
        
                        figRoiHistogram(aInputBuffer, atInputMetaData, atVoiInput{aa}, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)
 
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
                            
                            bDoseKernel      = atInput(dOffset).bDoseKernel;
                            bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;
                        
                            figRoiHistogram(aInputBuffer, atInputMetaData, atRoiInput{cc}, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied);
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
            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
            asTag = cell(1, numel(aVoiRoiTag));

            for hh=1:numel(aVoiRoiTag)
                asTag{hh}=aVoiRoiTag{hh}.Tag;
            end
            
            
            asTag = asTag(get(lbVoiRoiWindow, 'Value'));
            
            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), asTag(1) );
            aRoiTagOffset = find(aTagOffset, 1);   
                                
            createVoiFromRois(dSeriesOffset, asTag, [], atRoiInput{aRoiTagOffset}.Color, 'Unspecified');

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
    
            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);

            setVoiRoiSegPopup();

        end

        function figRoiMultiplePlotCallback(hObject, ~)
            
            atInput = inputTemplate('get');
            dOffset = get(uiSeriesPtr('get'), 'Value');
            if dOffset > numel(atInput)
                return;
            end
        
            aVoiRoiTag = voiRoiTag('get');
            
            aInput = inputBuffer('get');
            
            switch lower(imageOrientation('get'))
                
                case'axial'
                    aInputBuffer = permute(aInput{dOffset}, [1 2 3]);
                    
                case 'coronal'
                    aInputBuffer = permute(aInput{dOffset}, [3 2 1]);
                    
                case'sagittal'
                    aInputBuffer = permute(aInput{dOffset}, [3 1 2]);
            end

            if size(aInputBuffer, 3) ==1

                if atInput(dOffset).bFlipLeftRight == true
                    aInputBuffer=aInputBuffer(:,end:-1:1);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aInputBuffer=aInputBuffer(end:-1:1,:);
                end            
            else
                if atInput(dOffset).bFlipLeftRight == true
                    aInputBuffer=aInputBuffer(:,end:-1:1,:);
                end

                if atInput(dOffset).bFlipAntPost == true
                    aInputBuffer=aInputBuffer(end:-1:1,:,:);
                end

                if atInput(dOffset).bFlipHeadFeet == true
                    aInputBuffer=aInputBuffer(:,:,end:-1:1);
                end 
            end   

            atInputMetaData = atInput(dOffset).atDicomInfo;
            
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
            
            bDoseKernel      = atInput(dOffset).bDoseKernel;
            bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;  
            
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
                               bMovementApplied ...
                               );

        end

        function figRoiDeleteObjectCallback(~, ~)
            
            dSerieOffset = get(uiSeriesPtr('get'), 'Value');
                    
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

                        % Refresh contour figure

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

                        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
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

                            % Clear it constraint

                            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSerieOffset);

                            if ~isempty(asConstraintTagList)

                                dConstraintOffset = find(contains(asConstraintTagList, {aVoiRoiTag{lbVoiRoiWindow.Value}.Tag}));
                                if ~isempty(dConstraintOffset) % tag exist
                                     roiConstraintList('set', dSerieOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                                end
                            end        

                            % Delete ROI object 

                            if isvalid(atRoiInput{dTagOffset}.Object)
                                delete(atRoiInput{dTagOffset}.Object)
                            end

                            % Delete farthest distance object

                            if ~isempty(atRoiInput{dTagOffset}.MaxDistances)
                                if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line)
                                    delete(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line);
                                end

                                if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line)
                                    delete(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line);
                                end

                                if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text)
                                    delete(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text);
                                end

                                if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text)
                                    delete(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text);
                                end
                            end                        

                            atRoiInput{dTagOffset} = [];

                            atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                            roiTemplate('set', dSerieOffset, atRoiInput);  


                            % Clear roi from voi input template (if exist)

                            if ~isempty(atVoiInput)                        

                                for vo=1:numel(atVoiInput)     

                                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{aVoiRoiTag{lbVoiRoiWindow.Value}.Tag}));

                                    if ~isempty(dTagOffset) % tag exist
                                        atVoiInput{vo}.RoisTag{dTagOffset} = [];
                                        atVoiInput{vo}.RoisTag(cellfun(@isempty, atVoiInput{vo}.RoisTag)) = [];     

                                        if isempty(atVoiInput{vo}.RoisTag)
                                            atVoiInput{vo} = [];
                                       end

                                    end
                                end

                               atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                               voiTemplate('set', dSerieOffset, atVoiInput);                                        
                            end

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

                            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                        end
                    end
                end
            end
        end

        function figRoiPredefinedLabelCallback(hObject, ~)

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

                        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
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

                                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);

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
                       atInput(dOffset).bDoseKernel == false
                        bSegmented = true;
                    else
                        bSegmented = false;
                    end
                    
                    if strcmpi(get(mModifiedMatrix, 'Checked'), 'on') 
                        bModifiedMatrix = true;
                    else
                        bModifiedMatrix = false;
                    end
                            
                    setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
                    
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

            aVoiRoiTag = voiRoiTag('get');

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

                        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
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

                                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);

                            end
                        end
                    end
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
        
        if atInput(dOffset).bDoseKernel == true
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

        figRoiWindow.Name = ['TriDFusion (3DF) ROI/VOI Result - ' tRoiMetaData{1}.SeriesDescription ' - ' sUnits sModified sSegmented];

    end

    function setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented)

        sLbWindow = '';
        aVoiRoiTag = [];

        sFontName = get(lbVoiRoiWindow, 'FontName');

        atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

        atInput = inputTemplate('get');
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(atInput)
            return;
        end

 %       try

        set(figRoiWindow, 'Pointer', 'watch');
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
            aInputBuffer = permute(aInput{dOffset}, [1 2 3]);
        elseif strcmpi(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{dOffset}, [3 2 1]);
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{dOffset}, [3 1 2]);
        end
        
        if size(aInputBuffer, 3) ==1
            
            if atInput(dOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if atInput(dOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if atInput(dOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if atInput(dOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if atInput(dOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end   
        
        atInputMetaData = atInput(dOffset).atDicomInfo;

        aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        
        bDoseKernel      = atInput(dOffset).bDoseKernel;
        bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;

        dNbVois = numel(atVoiInput);
        if ~isempty(atVoiInput)
            for aa=1:dNbVois

                if ~isempty(atVoiInput{aa}.RoisTag)

                    if dNbVois > 10
                        if mod(aa, 5)==1 || aa == dNbVois
                            progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                        end
                    end

                    [tVoiComputed, atRoiComputed] = computeVoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, atVoiInput{aa}, atRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied);
                   
                    if ~isempty(tVoiComputed)
                        sVoiName = atVoiInput{aa}.Label;

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

                            aColor = atVoiInput{aa}.Color;
                            sColor = reshape(dec2hex([int32(aColor(1)*255) int32(aColor(2)*255) int32(aColor(3)*255)], 2)',1, 6);
                            sLine  = sprintf('<HTML><FONT color="%s" face="%s">%s', sColor, sFontName, sLine);
                        end

                        sLbWindow = sprintf('%s%s\n', sLbWindow, sLine);

                        if exist('aVoiRoiTag', 'var')

                            dResizeArray = numel(aVoiRoiTag)+1;

                            aVoiRoiTag{dResizeArray}.Tag = atVoiInput{aa}.Tag;

                        else
                             aVoiRoiTag{1}.Tag = atVoiInput{aa}.Tag;
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

                                sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
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

        if ~isempty(atRoiInput)
            dNbTags = numel(atRoiInput);
            for bb=1:dNbTags

               if dNbTags > 100
                   if mod(bb, 10)==1 || bb == dNbTags
                       progressBar( bb/dNbTags-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );
                   end
               end

%               if isvalid(atRoiInput{bb}.Object)
                    if strcmpi(atRoiInput{bb}.ObjectType, 'roi')

                        tRoiComputed = computeRoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, atRoiInput{bb}, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied);

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
                            sMaxXY = num2str(tRoiComputed.MaxDistances.MaxXY.Length);
                            sMaxCY = num2str(tRoiComputed.MaxDistances.MaxCY.Length);
                        else
                            sMaxXY = ' ';
                            sMaxCY = ' ';
                        end

                        sLine = sprintf('%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s', ...
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

        atInput = inputTemplate('get');
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(atInput)
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

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        aDisplayBuffer = dicomBuffer('get');

        aInput   = inputBuffer('get');
        if     strcmp(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{dOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aInputBuffer = permute(aInput{dOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{dOffset}, [3 1 2]);
        end
  
        if size(aDisplayBuffer, 3) ==1
            
            if atInput(dOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1);
            end

            if atInput(dOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:);
            end            
        else
            if atInput(dOffset).bFlipLeftRight == true
                aInputBuffer=aInputBuffer(:,end:-1:1,:);
            end

            if atInput(dOffset).bFlipAntPost == true
                aInputBuffer=aInputBuffer(end:-1:1,:,:);
            end

            if atInput(dOffset).bFlipHeadFeet == true
                aInputBuffer=aInputBuffer(:,:,end:-1:1);
            end 
        end
        
        atInputMetaData = atInput(dOffset).atDicomInfo;

        if ~isempty(atRoiInput) || ...
           ~isempty(atVoiInput)

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
            
                % Count number of elements

                dNumberOfLines = 1;
                if ~isempty(atVoiInput) % Scan VOI
                    for aa=1:numel(atVoiInput)
                        if ~isempty(atVoiInput{aa}.RoisTag) % Found a VOI

                            dNumberOfLines = dNumberOfLines+1;

                            for cc=1:numel(atVoiInput{aa}.RoisTag)
                                for bb=1:numel(atRoiInput)
                                   if isvalid(atRoiInput{bb}.Object)
                                        if strcmpi(atVoiInput{aa}.RoisTag{cc}, atRoiInput{bb}.Tag) % Found a VOI/ROI

                                            dNumberOfLines = dNumberOfLines+1;

                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for bb=1:numel(atRoiInput) % Scan ROI
                    if isvalid(atRoiInput{bb}.Object)
                        if strcmpi(atRoiInput{bb}.ObjectType, 'roi') % Found a ROI

                            dNumberOfLines = dNumberOfLines+1;
                        end
                    end
                end

                bDoseKernel      = atInput(dOffset).bDoseKernel;
                bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;
                
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
                asCell{dLineOffset,3}  = 'Cells';
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
                for tt=15:21
                    asCell{dLineOffset,tt}  = (' ');
                end

                dLineOffset = dLineOffset+1;

                dNbVois = numel(atVoiInput);
                if ~isempty(atVoiInput) % Scan VOIs
                    for aa=1:dNbVois
                        if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                            if dNbVois > 10
                                if mod(aa, 5)==1 || aa == dNbVois
                                    progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                                end
                            end

                            [tVoiComputed, atRoiComputed] = computeVoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, atVoiInput{aa}, atRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied);
                            
                            if ~isempty(tVoiComputed)

                                sVoiName = atVoiInput{aa}.Label;

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
                                        asCell{dLineOffset,15} = (' ');
                                        
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

                dNbRois = numel(atRoiInput);
                for bb=1:dNbRois % Scan ROIs
                    if isvalid(atRoiInput{bb}.Object)
                        if strcmpi(atRoiInput{bb}.ObjectType, 'roi')

                            if dNbRois > 100
                                if mod(bb, 10)==1 || bb == dNbRois
                                    progressBar( bb/dNbRois-0.0001, sprintf('Computing ROI %d/%d, please wait', bb, dNbRois) );
                                end
                            end

                            tRoiComputed = computeRoi(aInputBuffer, atInputMetaData, aDisplayBuffer, atMetaData, atRoiInput{bb}, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied);

                            sRoiName = atRoiInput{bb}.Label;

                            if strcmpi(atRoiInput{bb}.Axe, 'Axe')
                                sSliceNb = num2str(atRoiInput{bb}.SliceNb);
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes1')
                                sSliceNb = ['C:' num2str(atRoiInput{bb}.SliceNb)];
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes2')
                                sSliceNb = ['S:' num2str(atRoiInput{bb}.SliceNb)];
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes3')
                                sSliceNb = ['A:' num2str(size(dicomBuffer('get'), 3)-atRoiInput{bb}.SliceNb+1)];
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
                            asCell{dLineOffset,15} = (' ');
                            
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
        
        if strcmpi(get(mModifiedMatrix, 'Checked'), 'on') 
            bModifiedMatrix = true;
        else
            bModifiedMatrix = false;
        end
                
        if strcmpi(hObject.Checked, 'on')
            hObject.Checked = 'off';
            suvMenuUnitOption('set', false);
            
            setVoiRoiListbox(false, bModifiedMatrix, bSegmented);           
        else
            hObject.Checked = 'on';
            suvMenuUnitOption('set', true);
            
            setVoiRoiListbox(true, bModifiedMatrix, bSegmented);
        end

        setRoiFigureName();
    end

    function modifiedMatrixCallback(hObject, ~)
        
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
                
                setVoiRoiListbox(bSUVUnit, true, bSegmented);           
            else
                modifiedMatrixValueMenuOption('set', false);                         
                hObject.Checked = 'off';      
                
                segMenuOption('set', false);
                set(mSegmented, 'Checked', 'off');                
                
                setVoiRoiListbox(bSUVUnit, false, false);           
            end
        else
            modifiedMatrixValueMenuOption('set', true);                               
            hObject.Checked = 'on';
            
            setVoiRoiListbox(bSUVUnit, true, bSegmented);
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
            
            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, false);
        else
            if bModifiedMatrix == true
                hObject.Checked = 'on';
                segMenuOption('set', true);
                
                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, true);
            else
                hObject.Checked = 'off';
                segMenuOption('set', false);                
            end
       end

        setRoiFigureName();
    end

    function lbMainWindowCallback(hObject, ~)

        aVoiRoiTag = voiRoiTag('get');
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        bTagIsVoi = false;

        if ~isempty(atVoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(atVoiInput)
%                if isvalid(atRoiInput{cc}.Object)
                    if strcmp(atVoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)

                        dRoiOffset = round(numel(atVoiInput{cc}.RoisTag)/2);

                        triangulateRoi(atVoiInput{cc}.RoisTag{dRoiOffset});
                        bTagIsVoi = true;

                        break;
                    end
%                end
            end
        end

        if ~isempty(atRoiInput)  && ...
           ~isempty(aVoiRoiTag) && ...
           bTagIsVoi == false && ...
           numel(hObject.Value) == 1

            if numel(aVoiRoiTag) <  hObject.Value
                return
            end

            for cc=1:numel(atRoiInput)
%                if isvalid(atRoiInput{cc}.Object)
                    if strcmp(atRoiInput{cc}.Tag, aVoiRoiTag{hObject.Value}.Tag)
                        if ~strcmpi(atRoiInput{cc}.Type, 'images.roi.line')
                            triangulateRoi(atRoiInput{cc}.Tag)
                        end
                        break;
                    end
%                end
            end

        end
    end

    function clearAllMasksCallback(~, ~)

        roiConstraintList('reset', get(uiSeriesPtr('get'), 'Value'));
    end

    function clearAllContoursCallback(~, ~)

        dOffset = get(uiSeriesPtr('get'), 'Value');

        sAnswer = questdlg('Pressing will delete all contours', 'Warning', 'Delete', 'Exit', 'Exit');

        if strcmpi(sAnswer, 'Delete')
            
            try            
            set(figRoiWindow, 'Pointer', 'watch');
            drawnow; 
    
            roiConstraintList('reset', dOffset); % Delete all masks

            voiRoiTag('set', '');

            % Delete object
            
            atRoi = roiTemplate('get', dOffset);
            for rr=1:numel(atRoi)
                
                 % Delete ROI object
               
                if isvalid(atRoi{rr}.Object)                                                             
                    delete(atRoi{rr}.Object);
                end
                
                % Delete ROI farthest distance object

                if ~isempty(atRoi{rr}.MaxDistances)

                    if isvalid(atRoi{rr}.MaxDistances.MaxXY.Line)
                        delete(atRoi{rr}.MaxDistances.MaxXY.Line);
                    end

                    if isvalid(atRoi{rr}.MaxDistances.MaxCY.Line)
                        delete(atRoi{rr}.MaxDistances.MaxCY.Line);
                    end

                    if isvalid(atRoi{rr}.MaxDistances.MaxXY.Text)
                        delete(atRoi{rr}.MaxDistances.MaxXY.Text);
                    end

                    if isvalid(atRoi{rr}.MaxDistances.MaxCY.Text)
                        delete(atRoi{rr}.MaxDistances.MaxCY.Text);
                    end
                end                
            end
            
            % Reset template
                
            roiTemplate('reset', dOffset);
            voiTemplate('reset', dOffset);

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
        
            setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
            
            set(figRoiWindow, 'Pointer', 'default');            
            drawnow;  
            
            catch
                progressBar(1, 'Error: clearAllContoursCallback()' );                
            end
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
            
        setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);

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

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        bObjectIsVoi = false; 
        if ~isempty(atVoiInput) && ...
           ~isempty(aVoiRoiTag)
            for aa=1:numel(atVoiInput)
                if strcmpi(atVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
                    % Object is a VOI
                    tObject = atVoiInput{aa};
                    bObjectIsVoi = true;
                    break;
                end

            end

        end

        if bObjectIsVoi == false
            if ~isempty(atRoiInput)

                for cc=1:numel(atRoiInput)
                    if isvalid(atRoiInput{cc}.Object)
                        if strcmpi(atRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value}.Tag)
                            % Object is a ROI
                            tObject = atRoiInput{cc};
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
                   atInput(dOffset).bDoseKernel == false
                    bSegmented = true;
                else
                    bSegmented = false;
                end
                
                if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                    bModifiedMatrix = true;
                else
                    bModifiedMatrix = false;
                end
        
                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
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

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        if ~isempty(atVoiInput) && ...
           ~isempty(aVoiRoiTag)
            for aa=1:numel(atVoiInput)
                if strcmpi(atVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)
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
                    if strcmpi(atRoiInput{cc}.Tag, aVoiRoiTag{lbVoiRoiWindow.Value}.Tag)
                        % Object is a ROI
                        tObject = atRoiInput{cc};
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
                   atInput(dOffset).bDoseKernel == false
                    bSegmented = true;
                else
                    bSegmented = false;
                end
                
                if strcmpi(get(mModifiedMatrix, 'Checked'), 'on')
                    bModifiedMatrix = true;
                else
                    bModifiedMatrix = false;
                end
                
                setVoiRoiListbox(bSUVUnit, bModifiedMatrix, bSegmented);
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
