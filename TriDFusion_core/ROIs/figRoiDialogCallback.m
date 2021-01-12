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
               'Name', 'ROI/VOI result',...
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Resize', 'off', ...
               'Toolbar','none'...
               );

    set(figRoiWindow, 'WindowButtonDownFcn', @roiClickDown);

    mRoiFile = uimenu(figRoiWindow,'Label','File');
    uimenu(mRoiFile,'Label', 'Export to Excel...','Callback', @exportCurrentSeriesResultCallback);
    uimenu(mRoiFile,'Label', 'Close' ,'Callback', 'close', 'Separator','on');

    mRoiOptions = uimenu(figRoiWindow,'Label','Options');

    if suvMenuUnitOption('get') == true && ...
       isDoseKernel('get') == false
        sSuvChecked = 'on';
    else
        sSuvChecked = 'off';
    end

    if segMenuOption('get') == true && ...
        isDoseKernel('get') == false

        sSegChecked = 'on';
    else
        sSegChecked = 'off';
    end

    if isDoseKernel('get') == true
        sSuvEnable = 'off';
    else
        sSuvEnable = 'on';
    end

    mSUVUnit   = uimenu(mRoiOptions,'Label', 'SUV Unit', 'Checked', sSuvChecked, 'Enable', sSuvEnable, 'Callback', @SUVUnitCallback);
    mSegmented = uimenu(mRoiOptions,'Label', 'Segmented Values', 'Checked', sSegChecked, 'Callback', @segmentedCallback);

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

    lbVoiRoiWindow =  ...
        uicontrol(uiVoiRoiWindow,...
                  'style'   , 'listbox',...
                  'position', [0 0 uiVoiRoiWindow.Position(3) uiVoiRoiWindow.Position(4)-20],...
                  'fontsize', 10.1,...
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
               'String'  , 'Name'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Image Number'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Cells'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [350 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Total'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [450 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Mean'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [550 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Min'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [650 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Max'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [750 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Median'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [850 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Deviation'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [950 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Peak'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1050 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Area cm2'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1150 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Volume cm3'...
               );

     uicontrol(uiVoiRoiWindow,...
               'Position', [1250 uiVoiRoiWindow.Position(4)-20 100 20],...
               'String'  , 'Subtraction'...
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

                uimenu(c,'Label', 'Histogram'  , 'Separator', 'on' , 'Callback',@figRoiHistogramCallback);
                uimenu(c,'Label', 'Cummulative', 'Separator', 'off', 'Callback',@figRoiHistogramCallback);

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

            imMenu = dicomBuffer('get');
            if bDispayMenu == true && size(imMenu, 3) ~= 1
                c = uicontextmenu(figRoiWindow);
                lbVoiRoiWindow.UIContextMenu = c;

                uimenu(c,'Label', 'Create Volume', 'Callback',@figRoiCreateVolumeCallback);
            else
                lbVoiRoiWindow.UIContextMenu = [];
            end
        end

        function figRoiHistogramCallback(hObject, ~)
            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if     strcmpi(get(hObject, 'Label'), 'Histogram')

                histogramMenuOption('set', true);
                cummulativeMenuOption('set', false);
                profileMenuOption('set', false);
            elseif strcmpi(get(hObject, 'Label'), 'Cummulative')

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


                        figRoiHistogram(tVoiInput{aa}, bSUVUnit, bSegmented, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Sub);
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

                            figRoiHistogram(tRoiInput{cc}, bSUVUnit, bSegmented, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Sub);
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

        function figRoiDeleteObjectCallback(~, ~)
            aVoiRoiTag = voiRoiTag('get');

            tRoiInput = roiTemplate('get');
            tVoiInput = voiTemplate('get');

            if ~isempty(tVoiInput) && ...
               ~isempty(aVoiRoiTag)
                for aa=1:numel(tVoiInput)
                    if strcmpi(tVoiInput{aa}.Tag, aVoiRoiTag{get(lbVoiRoiWindow, 'Value')}.Tag)

                        figRoiDeleteObject(tVoiInput{aa})

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

                            figRoiDeleteObject(tRoiInput{cc});

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

            function figRoiDeleteObject(ptrObject)

                tDeleteInput = inputTemplate('get');
                iOffset = get(uiSeriesPtr('get'), 'Value');
                if iOffset > numel(tDeleteInput)
                    return;
                end

                for bb=1:numel(tDeleteInput(iOffset).tRoi)
                    if strcmpi(ptrObject.Tag, tDeleteInput(iOffset).tRoi{bb}.Tag)

                        if isfield(tDeleteInput(iOffset), 'tVoi')
                            for vv=1:numel(tDeleteInput(iOffset).tVoi)
                                for tt=1:numel(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                                    if strcmpi(tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt}, ptrObject.Tag)
                                        tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt} = [];
                                        tDeleteInput(iOffset).tVoi{vv}.RoisTag(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.RoisTag)) = [];

                                        tDeleteInput(iOffset).tVoi{vv}.tMask{tt} = [];
                                        tDeleteInput(iOffset).tVoi{vv}.tMask(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.tMask)) = [];

                                        if isempty(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                                            tDeleteInput(iOffset).tVoi{vv} = [];
                                            tDeleteInput(iOffset).tVoi(cellfun(@isempty, tDeleteInput(iOffset).tVoi)) = [];
                                        end

                                        if isempty(tDeleteInput(iOffset).tVoi)
                                           voiTemplate('set', '');
                                        else
                                           voiTemplate('set', tDeleteInput(iOffset).tVoi);
                                        end

                                        break;
                                    end
                                end
                            end
                        end

                        tDeleteInput(iOffset).tRoi{bb} = [];
                        tDeleteInput(iOffset).tRoi(cellfun(@isempty, tDeleteInput(iOffset).tRoi)) = [];

                        if isempty(tDeleteInput(iOffset).tRoi)
                            roiTemplate('set', '');
                        else
                            roiTemplate('set', tDeleteInput(iOffset).tRoi);
                        end

                        inputTemplate('set', tDeleteInput);
                        delete(ptrObject.Object);
                        break;
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
                          'position', [20 52 80 25]...
                          );

                edtFigRoiLabelName = ...
                    uicontrol(figRoiEditLabelWindow,...
                          'style'     , 'edit',...
                          'horizontalalignment', 'left',...
                          'Background', 'white',...
                          'string'    , ptrObject.Label,...
                          'position'  , [100 55 150 25], ...
                          'Callback', @acceptFigRoiEditLabelCallback...
                          );

                % Cancel or Proceed

                uicontrol(figRoiEditLabelWindow,...
                         'String','Cancel',...
                         'Position',[200 7 100 25],...
                         'Callback', @cancelFigRoiEditLabelCallback...
                         );

                uicontrol(figRoiEditLabelWindow,...
                         'String','Ok',...
                         'Position',[95 7 100 25],...
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

                    if strcmpi(get(mSegmented, 'Checked'), 'on')
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

            tEditLabelInput = inputTemplate('get');

            iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            if iSeriesOffset > numel(tEditLabelInput)
                return;
            end

            if strcmpi(ptrObject.ObjectType, 'voi')

                % Set voi Label
                for ff=1:numel(tEditLabelInput(iSeriesOffset).tVoi)
                    if strcmpi(tEditLabelInput(iSeriesOffset).tVoi{ff}.Tag, ptrObject.Tag)

                        tEditLabelInput(iSeriesOffset).tVoi{ff}.Label = sLabel;
                        voiTemplate('set', tEditLabelInput(iSeriesOffset).tVoi);
                    end
                end

                % Set rois label
                dRoiNb = 0;
                for bb=1:numel(ptrObject.RoisTag)

                    for vv=1:numel(tEditLabelInput(iSeriesOffset).tRoi)
                        if isvalid(tEditLabelInput(iSeriesOffset).tRoi{vv}.Object)
                            if strcmpi(tEditLabelInput(iSeriesOffset).tRoi{vv}.Tag, ptrObject.RoisTag{bb})

                                dRoiNb = dRoiNb+1;
                                sRoiLabel =  sprintf('%s (roi %d/%d)', sLabel, dRoiNb, numel(ptrObject.RoisTag));
                                tEditLabelInput(iSeriesOffset).tRoi{vv}.Label = sRoiLabel;
                                tEditLabelInput(iSeriesOffset).tRoi{vv}.Object.Label = sRoiLabel;

                                roiTemplate('set', tEditLabelInput(iSeriesOffset).tRoi);

                            end
                        end
                    end
                end
            else
                for vv=1:numel(tEditLabelInput(iSeriesOffset).tRoi)
                    if isvalid(tEditLabelInput(iSeriesOffset).tRoi{vv}.Object)
                        if strcmpi(tEditLabelInput(iSeriesOffset).tRoi{vv}.Tag, ptrObject.Tag)

                            tEditLabelInput(iSeriesOffset).tRoi{vv}.Label = sLabel;
                            tEditLabelInput(iSeriesOffset).tRoi{vv}.Object.Label = sLabel;

                            roiTemplate('set', tEditLabelInput(iSeriesOffset).tRoi);

                        end
                    end
                end
            end

            inputTemplate('set', tEditLabelInput);
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

                tEditLabelInput = inputTemplate('get');

                iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
                if iSeriesOffset > numel(tEditLabelInput)
                    return;
                end

                if strcmpi(ptrObject.ObjectType, 'voi')

                    % Set voi color
                    for ff=1:numel(tEditLabelInput(iSeriesOffset).tVoi)
                        if strcmpi(tEditLabelInput(iSeriesOffset).tVoi{ff}.Tag, ptrObject.Tag)

                            tEditLabelInput(iSeriesOffset).tVoi{ff}.Color = sColor;
                            voiTemplate('set', tEditLabelInput(iSeriesOffset).tVoi);
                        end
                    end

                    % Set rois color

                    for bb=1:numel(ptrObject.RoisTag)

                        for vv=1:numel(tEditLabelInput(iSeriesOffset).tRoi)
                            if isvalid(tEditLabelInput(iSeriesOffset).tRoi{vv}.Object)
                                if strcmpi(tEditLabelInput(iSeriesOffset).tRoi{vv}.Tag, ptrObject.RoisTag{bb})

                                    tEditLabelInput(iSeriesOffset).tRoi{vv}.Color = sColor;
                                    tEditLabelInput(iSeriesOffset).tRoi{vv}.Object.Color = sColor;

                                    roiTemplate('set', tEditLabelInput(iSeriesOffset).tRoi);

                                end
                            end
                        end
                    end
                else
                    for vv=1:numel(tEditLabelInput(iSeriesOffset).tRoi)
                        if isvalid(tEditLabelInput(iSeriesOffset).tRoi{vv}.Object)
                            if strcmpi(tEditLabelInput(iSeriesOffset).tRoi{vv}.Tag, ptrObject.Tag)

                                tEditLabelInput(iSeriesOffset).tRoi{vv}.Color = sColor;
                                tEditLabelInput(iSeriesOffset).tRoi{vv}.Object.Color = sColor;

                                roiTemplate('set', tEditLabelInput(iSeriesOffset).tRoi);

                            end
                        end
                    end
                end

                inputTemplate('set', tEditLabelInput);
            end
        end

    end

    function setRoiFigureName()
        
        if ~isvalid(lbVoiRoiWindow)
            return;
        end

        if isDoseKernel('get') == true
            sUnit =  'Unit: Dose';
        else
            if strcmpi(get(mSUVUnit, 'Checked'), 'on')

                if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                    strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                    strcmpi(tRoiMetaData{1}.Units, 'BQML' )
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
                    if (strcmpi(tRoiMetaData{1}.Modality, 'pt') || ...
                        strcmpi(tRoiMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(tRoiMetaData{1}.Units, 'BQML' )
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

        atVoiMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInput)
            return;
        end

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
if 0
        if numel(tInput(iOffset).asFilesList) ~= 1

            if ~isempty(atVoiMetaData{1}.ImagePositionPatient)

                if atVoiMetaData{2}.ImagePositionPatient(3) - ...
                   atVoiMetaData{1}.ImagePositionPatient(3) > 0
                    aInputBuffer = aInputBuffer(:,:,end:-1:1);

                end
            end
        else
            if strcmpi(atVoiMetaData{1}.PatientPosition, 'FFS')
                aInputBuffer = aInputBuffer(:,:,end:-1:1);
            end
        end
end
        aDisplayBuffer = dicomBuffer('get');

        if ~isempty(tVoiInput)
            for aa=1:numel(tVoiInput)
                
                progressBar(aa/numel(tVoiInput)-0.0001, sprintf('Computing VOI %d/%d', aa, numel(tVoiInput) ) );      
                
                if ~isempty(tVoiInput{aa}.RoisTag)
                    [tVoiComputed, ~] = computeVoi(aInputBuffer, aDisplayBuffer, atVoiMetaData, tVoiInput{aa}, tRoiInput, dSUVScale, bSUVUnit, bSegmented);

                    sVoiName = tVoiInput{aa}.Label;

                    sLbWindow = sprintf('%s%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n', sLbWindow, ...
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

                    for cc=1:numel(tVoiInput{aa}.RoisTag)
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
                                    sLbWindow = sprintf('%s%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n', sLbWindow, ...
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

                                     dResizeArray = numel(aVoiRoiTag)+1;

                                     aVoiRoiTag{dResizeArray}.Tag = tRoiInput{bb}.Tag;
                                     if isfield(tRoiComputed, 'subtraction')
                                        aVoiRoiTag{dResizeArray}.Sub = tRoiComputed.subtraction;
                                     else
                                        aVoiRoiTag{dResizeArray}.Sub = 0;
                                     end

                                end
                            end
                        end
                    end
                end
            end
        end

        if ~isempty(tRoiInput)
            for bb=1:numel(tRoiInput)
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
                        sLbWindow = sprintf('%s%-18s %-11s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n', sLbWindow, ...
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
            if get(lbVoiRoiWindow, 'Value') > 1
                set(lbVoiRoiWindow, 'Value', get(lbVoiRoiWindow, 'Value')-1);
            else
                set(lbVoiRoiWindow, 'Value', 1);
            end

            set(lbVoiRoiWindow, 'String', sLbWindow);
        end
        
        if exist('aVoiRoiTag', 'var')
            voiRoiTag('set', aVoiRoiTag);
        else
            voiRoiTag('set', '');
        end
        
        progressBar(1, 'Ready');

    end

    function exportCurrentSeriesResultCallback(~, ~)

        tInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInput)
            return;
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
if 0
        if numel(tInput(iOffset).asFilesList) ~= 1

            if ~isempty(atMetaData{1}.ImagePositionPatient)

                if atMetaData{2}.ImagePositionPatient(3) - ...
                   atMetaData{1}.ImagePositionPatient(3) > 0
                    aInputBuffer = aInputBuffer(:,:,end:-1:1);

                end
            end
        else
            if strcmpi(atMetaData{1}.PatientPosition, 'FFS')
                aInputBuffer = aInputBuffer(:,:,end:-1:1);
            end
        end
end
        if ~isempty(tRoiInput) || ...
           ~isempty(tVoiInput)

            filter = {'*.xlsx'};
     %       info = dicomMetaData('get');

            sCurrentDir = pwd;
            if integrateToBrowser('get') == true
                sCurrentDir = [sCurrentDir '/TriDFusion'];
            end

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

                writecell(asVoiRoiHeader(:),sprintf('%s%s', path, file), 'Sheet', 1, 'Range', 'A1');

                asVoiRoiTable{1,1}  = 'Name';
                asVoiRoiTable{1,2}  = 'Image number';
                asVoiRoiTable{1,3}  = 'Cells';
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

                writecell(asVoiRoiTable(1,:),sprintf('%s%s', path, file), 'Sheet',1, 'Range', 'A8');

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
                            writecell([asVoiCell{:,aa}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
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
                                            writecell([asRoiCell{:,bb}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
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
                            writecell([asRoiCell{:,bb}],sprintf('%s%s', path, file), 'Sheet',1, 'Range', sCell);
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

    function sOutput = maxLength(sString, iMaxLength)

        if numel(sString) > iMaxLength
            sOutput = sString(1:iMaxLength);
        else
            sOutput = sString;
        end

    end
end
