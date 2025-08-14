classdef interactiveText < handle
%classdef interactiveText < handle
%Click to place editable text, then click‐drag to move.
%   Usage:
%       arrowTool = interactiveText();
%
%  • Right-click menu on arrow: Delete / Edit Text / Change Color / Change Font Size.
%  • Click+drag arrow to move.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % INTERACTIVETEXT  Click to place editable text, then click‐drag to move
    %
    %   Usage:
    %       txtTool = interactiveText();
    %
    %  • Left-click in the axes: prompts for a string, then places it.
    %  • Click+drag the text to move it.
    %  • Right-click menu on text: Delete Text.

    properties (Access = private)
        Fig                 % Figure handle
        Ax                  % Axes handle

        Color = plotEditColor('get')     % Default text color
        FontSize   = plotEditFontSize('get');
        FontName   = plotEditFontName('get');
        FontAngle  = plotEditFontAngle('get');
        FontWeight = plotEditFontWeight('get');

        origWBDown          % Original WindowButtonDownFcn
        origWBMotion        % Original WindowButtonMotionFcn
        origWBUp            % Original WindowButtonUpFcn
        origPointer         % Original Pointer
        origPressFcn        % Original WindowKeyPressFcn

        hEdit               % Handle to the active edit box
        editPos             % [x y] coords where edit box was spawned
        Dialog
        DialogValue
    end
    properties (Access = public)

        hText               % Handle to label text
    end
    methods
        function obj = interactiveText(varargin)

            % If there’s already one in mid‐drag, delete it
            prev = textInstance();
            if ~isempty(prev) && isvalid(prev)
              deleteText(prev);
                return;
            end

            % Constructor: capture figure & switch into “click to add” mode
            obj.Fig = fiMainWindowPtr('get');  % your figure getter
            obj.Color = plotEditColor('get');
            obj.FontName   = plotEditFontName('get');
            obj.FontAngle  = plotEditFontAngle('get');
            obj.FontWeight = plotEditFontWeight('get');
            obj.FontSize   = plotEditFontSize('get');

            % Save original callbacks & pointer
            obj.origWBDown   = get(obj.Fig,'WindowButtonDownFcn');
            obj.origWBMotion = get(obj.Fig,'WindowButtonMotionFcn');
            obj.origWBUp     = get(obj.Fig,'WindowButtonUpFcn');
            obj.origPressFcn = get(obj.Fig,'WindowKeyPressFcn');
            obj.origPointer  = 'default';

            if ~isempty(varargin)

                dSeriesOffset = get(uiSeriesPtr('get'),'Value');

                atText = varargin{1};

                switch lower(atText.Axe)

                    case  'axe'
                        obj.Ax = axePtr('get', [], dSeriesOffset);


                    case 'axes1'
                        obj.Ax = axes1Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'coronal' );
                        sliceNumber('set', 'coronal', atText.SliceNb);

                    case 'axes2'
                        obj.Ax = axes2Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'sagittal');
                        sliceNumber('set', 'sagittal', atText.SliceNb);

                    case 'axes3'
                        obj.Ax = axes3Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'axial');
                        sliceNumber('set', 'axial', atText.SliceNb);

                    case 'axesmip'
                        obj.Ax = axesMipPtr('get', [], dSeriesOffset);

                        dSliceNb = mipAngle('get');
                        mipAngle('set', atText.SliceNb);

                    otherwise

                        return;
                end

                hold(obj.Ax,'on');

                obj.hText = text(obj.Ax, ...
                    atText.Position(1), atText.Position(2), atText.String, ...
                    'Tag'                , num2str(generateUniqueNumber(false)), ...
                    'FontName'           , atText.FontName, ...
                    'FontAngle'          , atText.FontAngle, ...
                    'FontWeight'         , atText.FontWeight, ...
                    'FontSize'           , atText.FontSize, ...
                    'Interpreter'        , atText.Interpreter, ...
                    'HorizontalAlignment', atText.HorizontalAlignment, ...
                    'VerticalAlignment'  , atText.VerticalAlignment, ...
                    'Color'              , atText.Color, ...
                    'PickableParts'      , atText.PickableParts,...
                    'HitTest'            , atText.HitTest);

                addPlotEdit(obj.hText, obj.Ax, dSeriesOffset, 'single');

                % Context menu: Delete Text
                c = uicontextmenu(obj.Fig);
                uimenu(c, 'Label','Delete Text', ...
                          'Callback', @(~,~) obj.deleteText(obj.hText));

               uimenu(c,'Label','Edit Text…'   , 'Callback',@(~,~) obj.createEditBox());
               uimenu(c,'Label','Change Color…', 'Callback',@(~,~) obj.changeColor());
               uimenu(c,'Label','Change Font Size…', 'Callback',@(~,~) obj.changeFontSize());

               set(obj.hText,'UIContextMenu',c);
               set(obj.hText,'ButtonDownFcn', @(~,~) obj.onTextClick(obj.hText));

               switch lower(atText.Axe)

                    case 'axes1'
                        sliceNumber('set', 'coronal', dSliceNb);

                    case 'axes2'
                        sliceNumber('set', 'sagittal', dSliceNb);

                    case 'axes3'
                        sliceNumber('set', 'axial',dSliceNb);

                    case 'axesmip'

                        mipAngle('set', dSliceNb);
                end

                hold(obj.Ax,'off');

                return;
            end


            textInstance(obj);

            % Switch pointer & wait for the click
            set(obj.Fig,'Pointer','crosshair');
            set(obj.Fig,'WindowButtonDownFcn',@(~,~) obj.onMouseDown());
        end

        function delete(obj)

            % Destructor: restore original figure state
            if ~isempty(obj.Fig) && isvalid(obj.Fig)

                set(obj.Fig,'WindowButtonDownFcn'  , obj.origWBDown);
                set(obj.Fig,'WindowButtonMotionFcn', obj.origWBMotion);
                set(obj.Fig,'WindowButtonUpFcn'    , obj.origWBUp);
                set(obj.Fig,'WindowKeyPressFcn'    , obj.origPressFcn);
                set(obj.Fig,'Pointer'              , obj.origPointer);
            end
        end
    end

    methods (Access = private)

        function onMouseDown(obj)

            if ~strcmpi(get(obj.Fig,'Pointer'), 'crosshair')
                return;
            end

            obj.Ax = gca(obj.Fig);
            cp = get(obj.Ax,'CurrentPoint');
            obj.editPos = cp(1,1:2);
            obj.createEditBox();
        end

        function deleteText(obj,hTxt)

            % Callback to delete arrow and update plot-edit
            dSeriesOffset = get(uiSeriesPtr('get'),'Value');
            atPlotEditInput = plotEditTemplate('get',dSeriesOffset);

            if exist('hTxt', 'var')

                sTag = hTxt.Tag;
                delete(hTxt);
                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput(idx) = [];
                    atPlotEditInput(cellfun(@isempty,atPlotEditInput)) = [];
                    plotEditTemplate('set',dSeriesOffset,atPlotEditInput);
                end
            end

            % destroy object
            delete(obj);
            ws = evalin('base','whos');
            for k = 1:numel(ws)
                if strcmp(ws(k).class, class(obj))
                    try
                        v = evalin('base', ws(k).name);
                        if isequal(v, obj)
                            evalin('base', ['clear ', ws(k).name]);
                        end
                    catch
                    end
                end
            end

            textInstance([]);

        end

        function onTextClick(obj,src)

            if ~strcmpi(get(obj.Fig,'Pointer'), 'arrow')
                return;
            end

            % Begin drag: store original pos & click
            set(obj.Fig,'Pointer','hand');
            cp = get(obj.Ax,'CurrentPoint');
            lastClick = [cp(1,1), cp(1,2)];
            origPos   = get(src,'Position');  % [x y z]
            src.UserData = struct('lastClick',lastClick, 'origPos',origPos);

            set(obj.Fig,'WindowButtonMotionFcn',{@obj.dragText,src});
            set(obj.Fig,'WindowButtonUpFcn',@(~,~) obj.finishTextDrag());
        end

        function dragText(obj,~,~,src)

            % Move text to follow mouse
            cp = get(obj.Ax,'CurrentPoint');
            newClick = [cp(1,1), cp(1,2)];
            ud = src.UserData;

            delta = newClick - ud.lastClick;
            newPos = ud.origPos(1:2) + delta;

            set(src,'Position',[newPos, ud.origPos(3)]);
        end

        function finishTextDrag(obj)

            % End drag, restore figure callbacks/pointer
            windowButton('set','up');
            obj.restoreFigureState();
            obj.updateTemplatePosition();
        end

        function createEditBox(obj)

            % Spawn an edit uicontrol at the click location
            set(obj.Fig,'WindowKeyPressFcn','');

            if ~isempty(obj.hEdit) && isvalid(obj.hEdit)
                delete(obj.hEdit);
            end

            cp = get(obj.Fig,'CurrentPoint');
            nx = cp(1,1) - 100;
            ny = cp(1,2) - 20;

            % Create edit box
            w = 200; h = 40;
            obj.hEdit = ...
                uicontrol(obj.Fig, ...
                          'Style','edit', ...
                          'Units','pixels', ...
                          'Position',[nx, ny, w, h], ...
                          'String','', ...
                          'Callback',@(src,~) obj.finishEdit(src), ...
                          'BackgroundColor','white', ...
                          'FontWeight','bold');
            uicontrol(obj.hEdit);
        end

        function finishEdit(obj,src)
            % Read text, delete edit box, create text label
            txt = get(src,'String');
            delete(src);

            if isempty(txt)

                togglePlotEditToolbarState(obj);

                delete(obj);

                textInstance([]);

                return;
            end

            obj.hEdit = [];

            if isempty(obj.hText) || ~isvalid(obj.hText)

                % Place the text at the stored click location
                x = obj.editPos(1);
                y = obj.editPos(2);
                hold(obj.Ax,'on');
                obj.hText = ...
                    text(obj.Ax, x, y, txt, ...
                         'Color'        , obj.Color, ...
                         'Tag'          , num2str(generateUniqueNumber(false)), ...
                         'Interpreter'  , 'none', ...
                         'PickableParts', 'all', ...
                         'HitTest'      , 'on', ...
                         'FontWeight'   , obj.FontWeight, ...
                         'FontAngle'    , obj.FontAngle, ...
                         'FontSize'     , obj.FontSize, ...
                         'FontName'     , obj.FontName, ...
                         'VerticalAlignment'  ,'middle', ...
                         'HorizontalAlignment','center');

                addPlotEdit(obj.hText, obj.Ax, get(uiSeriesPtr('get'),'Value'), 'single');

                % Context menu: Delete Text
                c = uicontextmenu(obj.Fig);
                uimenu(c, 'Label','Delete Text', ...
                          'Callback', @(~,~) obj.deleteText(obj.hText));

               uimenu(c,'Label','Edit Text…'   , 'Callback',@(~,~) obj.createEditBox());
               uimenu(c,'Label','Change Color…', 'Callback',@(~,~) obj.changeColor());
               uimenu(c,'Label','Change Font Size…', 'Callback',@(~,~) obj.changeFontSize());

                set(obj.hText,'UIContextMenu',c);

                % Enable drag
                set(obj.hText,'ButtonDownFcn', @(~,~) obj.onTextClick(obj.hText));
            else
                 set(obj.hText,'String',txt);
            end

            obj.restoreFigureState();
            obj.togglePlotEditToolbarState();
            textInstance([]);
        end

        function restoreFigureState(obj)

            set(obj.Fig,'WindowButtonDownFcn'  , obj.origWBDown);
            set(obj.Fig,'WindowKeyPressFcn'    , obj.origPressFcn);
            set(obj.Fig,'WindowButtonMotionFcn', obj.origWBMotion);
            set(obj.Fig,'WindowButtonUpFcn'    , obj.origWBUp);
            set(obj.Fig,'Pointer'              , obj.origPointer);
        end

        function changeColor(obj)

            aColor = uisetcolor([obj.Color],'Select a color');
            if isequal(aColor,0)
                return;
            end

            dSeriesOffset = get(uiSeriesPtr('get'),'Value');

            atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

            sTag = obj.hText.Tag;

            idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
            if ~isempty(idx)
                atPlotEditInput{idx}.Color = aColor;
            end

            set(obj.hText, 'Color', aColor);

            obj.Color = aColor;

            plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

        end

       function updateTemplatePosition(obj)

            dSeriesOffset = get(uiSeriesPtr('get'),'Value');

            atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

            sTag = obj.hText.Tag;

            idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
            if ~isempty(idx)
                atPlotEditInput{idx}.Position = obj.hText.Position;
            end

            plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

       end

       function changeFontSize(obj)

            obj.showDialog('Change Font Size', 'New Font Size', get(obj.hText, 'FontSize'));

            waitfor(obj.Dialog);

            dFontSize = obj.DialogValue;

            if ~isempty(dFontSize) && dFontSize > 0

                dSeriesOffset = get(uiSeriesPtr('get'),'Value');

                atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

                sTag = obj.hText.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.FontSize = dFontSize;
                end

                set(obj.hText, 'FontSize', dFontSize);

                obj.FontSize = dFontSize;

                plotEditTemplate('set', dSeriesOffset, atPlotEditInput);
            end
        end

        function showDialog(obj, sDialogName, sEditName, dInitialValue)

            DLG_SIZE_X = 300;
            DLG_SIZE_Y = 120;

            if viewerUIFigure('get') == true

                obj.Dialog = ...
                    uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_SIZE_X/2) ...
                                        (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_SIZE_Y/2) ...
                                        DLG_SIZE_X ...
                                        DLG_SIZE_Y ...
                                        ],...
                           'Resize', 'off', ...
                           'Color', viewerBackgroundColor('get'),...
                           'WindowStyle', 'modal', ...
                           'Name' , sDialogName...
                           );
            else
                obj.Dialog = ...
                    dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_SIZE_X/2) ...
                                        (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_SIZE_Y/2) ...
                                        DLG_SIZE_X ...
                                        DLG_SIZE_Y ...
                                        ],...
                           'MenuBar', 'none',...
                           'Resize', 'off', ...
                           'NumberTitle','off',...
                           'MenuBar', 'none',...
                           'Color', viewerBackgroundColor('get'), ...
                           'Name' , sDialogName, ...
                           'Toolbar','none'...
                           );
            end

            setObjectIcon(obj.Dialog);

            uicontrol(obj.Dialog,...
                      'style'   , 'text',...
                      'string'  , sEditName,...
                      'horizontalalignment', 'left',...
                      'position', [20 80 100 20],...
                      'Enable', 'On',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get') ...
                      );

           dlgDialogValue = ...
               uicontrol(obj.Dialog,...
                         'style'     , 'edit',...
                         'enable'    , 'on',...
                         'Background', 'white',...
                         'string'    , num2str(dInitialValue),...
                         'position'  , [120 80 160 20],...
                         'BackgroundColor', viewerBackgroundColor('get'), ...
                         'ForegroundColor', viewerForegroundColor('get'), ...
                          'CallBack'      , @okDialogCallback...
                        );

             % Cancel or Proceed

             uicontrol(obj.Dialog,...
                       'String','Cancel',...
                       'Position',[205 7 75 25],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'Callback', @cancelDialogCallback...
                       );

             uicontrol(obj.Dialog,...
                      'String','Ok',...
                      'Position',[120 7 75 25],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @okDialogCallback...
                      );

            function cancelDialogCallback(~, ~)

                delete(obj.Dialog);
            end

            function okDialogCallback(~, ~)

                obj.DialogValue = str2double(get(dlgDialogValue, 'String'));
                delete(obj.Dialog);
            end
        end

        function togglePlotEditToolbarState(obj)

            % % Get the plot-edit toolbar/menu object
            
            menObj = plotEditMenuObject('get');
            if isempty(menObj)
                 return;
            end

             
            % Loop through each menu item and switch based on its Label

            for jj=1: numel(menObj)

                if strcmpi(menObj{jj}.UserData.label, 'Text')

                    set(menObj{jj}, 'CData', menObj{jj}.UserData.default);
                end
            end

        end
    end
end
