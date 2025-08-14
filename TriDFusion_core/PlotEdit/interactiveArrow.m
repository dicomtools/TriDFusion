classdef interactiveArrow < handle
%classdef interactiveArrow < handle
%Click‐and‐drag to draw a single‐headed or double‐headed arrow.
%   Usage:
%       arrowTool = interactiveArrow('showText',true, 'doubleArrow',true);
%
%  • Left-click in the axes to set the tail.
%  • Drag + release to set the head.
%  • Right-click menu on arrow: Delete / Edit Text / Change Color /  Change Font Size / Change Line Width.
%  • Click+drag arrow to move or resize (label follows).
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

    properties (Access = private)
        Fig                 % Figure handle
        Ax                  % Axes handle
        Color = plotEditColor('get')     % Default arrow color
        LineWidth = 2
        LineStyle = '-'
        MaxHeadSize = 0.5
        FontSize   = plotEditFontSize('get');
        FontName   = plotEditFontName('get')
        FontAngle  = plotEditFontAngle('get')
        FontWeight = plotEditFontWeight('get')

        origWBDown          % Original WindowButtonDownFcn
        origWBMotion        % Original WindowButtonMotionFcn
        origWBUp            % Original WindowButtonUpFcn
        origPressFcn        % Original WindowKeyPressFcn
        origPointer         % Original Pointer

        hTemp               % Handle to temporary line during draw
        hEdit               % Handle to temporary edit box uicontrol

        x1                  % Tail X
        y1                  % Tail Y

        showText = false    % Pop up edit box after drawing if true
        doubleArrow = false % Draw heads at both ends

        Dialog
        DialogValue
    end

    properties (Access = public)
        hArrow              % Handle to drawn quiver arrow
        hArrow2             % Handle to second (reversed) quiver when doubleArrow=true**
        hText               % Handle to label text (if any)
    end

    methods
        function obj = interactiveArrow(varargin)

            % If there’s already one in mid‐drag, delete it
            prev = arrowInstance();
            if ~isempty(prev) && isvalid(prev)
                deleteArrow(prev);
                return;
            end

            % Constructor: initialize drawing callbacks
            obj.Fig = fiMainWindowPtr('get');
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

            % Parse showText option
            params = struct('showText',false,'doubleArrow',false);

            i = 1;
            while i<=numel(varargin) && ischar(varargin{i})
                switch lower(varargin{i})
                    case 'showtext'
                        params.showText   = varargin{i+1};
                    case 'doublearrow'
                        params.doubleArrow = varargin{i+1};
                    otherwise
                        break;
                end
                i = i+2;
            end
            obj.showText   = params.showText;
            obj.doubleArrow = params.doubleArrow;

            extra = varargin(i:end);
            if ~isempty(extra)

                dSeriesOffset = get(uiSeriesPtr('get'),'Value');

                % FIRST ARROW
                at1 = extra{1};      % struct with fields XData, YData, etc

                switch lower(at1.Axe)

                    case  'axe'
                        obj.Ax = axePtr('get', [], dSeriesOffset);


                    case 'axes1'
                        obj.Ax = axes1Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'coronal' );
                        sliceNumber('set', 'coronal', at1.SliceNb);

                    case 'axes2'
                        obj.Ax = axes2Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'sagittal');
                        sliceNumber('set', 'sagittal', at1.SliceNb);

                    case 'axes3'
                        obj.Ax = axes3Ptr('get', [], dSeriesOffset);

                        dSliceNb = sliceNumber('get', 'axial');
                        sliceNumber('set', 'axial', at1.SliceNb);

                    case 'axesmip'
                        obj.Ax = axesMipPtr('get', [], dSeriesOffset);

                        dSliceNb = mipAngle('get');
                        mipAngle('set', at1.SliceNb);

                    otherwise

                        return;
                end

                hold(obj.Ax,'on');

                is3D = ~isempty(at1.ZData) && ~isempty(at1.WData);

                if is3D
                    % 3D arrow: quiver3(tailX,tailY,tailZ, u,v,w, 0=no autoscale)
                    obj.hArrow = quiver3( ...
                        obj.Ax, ...
                        at1.XData(1), at1.YData(1), at1.ZData(1), ...
                        at1.UData   , at1.VData   , at1.WData   , 0, ...
                        'Tag'          , num2str(generateUniqueNumber(false)), ...
                        'Color'        , at1.Color, ...
                        'LineWidth'    , at1.LineWidth, ...
                        'LineStyle'    , at1.LineStyle, ...
                        'MaxHeadSize'  , at1.MaxHeadSize, ...
                        'PickableParts', at1.PickableParts, ...
                        'HitTest'      , at1.HitTest );
                else
                    % 2D arrow: quiver(tailX,tailY, u,v, 0=no autoscale)
                    obj.hArrow = quiver( ...
                        obj.Ax, ...
                        at1.XData(1), at1.YData(1), ...
                        at1.UData   , at1.VData   , 0, ...
                        'Tag'          , num2str(generateUniqueNumber(false)), ...
                        'Color'        , at1.Color, ...
                        'LineWidth'    , at1.LineWidth, ...
                        'LineStyle'    , at1.LineStyle, ...
                        'MaxHeadSize'  , at1.MaxHeadSize, ...
                        'PickableParts', at1.PickableParts, ...
                        'HitTest'      , at1.HitTest );
                end

                if numel(extra)>=2
                    addPlotEdit(obj.hArrow, obj.Ax, dSeriesOffset, 'multiple', obj.hArrow.Tag);
                else
                    addPlotEdit(obj.hArrow, obj.Ax, dSeriesOffset, 'single');
                end

                % SECOND ARROW
                if obj.doubleArrow && numel(extra)>=2
                    at2 = extra{2};

                    is3D = ~isempty(at2.ZData) && ~isempty(at2.WData);

                    if is3D
                        % 3D arrow: quiver3(tailX,tailY,tailZ, u,v,w, 0=no autoscale)
                        obj.hArrow2 = quiver3( ...
                            obj.Ax, ...
                            at2.XData(1), at2.YData(1), at2.ZData(1), ...
                            at2.UData   , at2.VData   , at2.WData   , 0, ...
                            'Tag'          , num2str(generateUniqueNumber(false)), ...
                            'Color'        , at2.Color, ...
                            'LineWidth'    , at2.LineWidth, ...
                            'LineStyle'    , at2.LineStyle, ...
                            'MaxHeadSize'  , at2.MaxHeadSize, ...
                            'PickableParts', at2.PickableParts, ...
                            'HitTest'      , at2.HitTest );
                    else
                        % 2D arrow: quiver(tailX,tailY, u,v, 0=no autoscale)
                        obj.hArrow2 = quiver( ...
                            obj.Ax, ...
                            at2.XData(1), at2.YData(1), ...
                            at2.UData   , at2.VData   , 0, ...
                            'Tag'          , num2str(generateUniqueNumber(false)), ...
                            'Color'        , at2.Color, ...
                            'LineWidth'    , at2.LineWidth, ...
                            'LineStyle'    , at2.LineStyle, ...
                            'MaxHeadSize'  , at2.MaxHeadSize, ...
                            'PickableParts', at2.PickableParts, ...
                            'HitTest'      , at2.HitTest );
                    end

                  addPlotEdit(obj.hArrow2, obj.Ax, dSeriesOffset, 'multiple', obj.hArrow.Tag);

                end

                % TEXT LABEL
                if obj.showText
                    if numel(extra)>=3
                        atText = extra{3};
                    else
                        atText = extra{2};
                    end

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

                   addPlotEdit(obj.hText, obj.Ax, dSeriesOffset, 'multiple', obj.hArrow.Tag);

                end

                c = uicontextmenu(obj.Fig);
                uimenu(c,'Label','Delete Arrow'      , 'Callback',@(~,~) obj.deleteArrow());
                uimenu(c,'Label','Change Color…'     , 'Callback',@(~,~) obj.changeColor());
                uimenu(c,'Label','Change Line Width…', 'Callback',@(~,~) obj.changeLineWidth());

                set(obj.hArrow,  'UIContextMenu',c,'ButtonDownFcn',@(~,~) obj.onArrowClick(obj.hArrow));

                if obj.doubleArrow
                    set(obj.hArrow2,'UIContextMenu',c,'ButtonDownFcn',@(~,~) obj.onArrowClick(obj.hArrow2));
                end

                if obj.showText  % give your text the edit‐on‐right‐click menu too
                    tc = uicontextmenu(obj.Fig);
                    uimenu(tc,'Label','Edit Text…'      , 'Callback',@(~,~) obj.createEditBox());
                    uimenu(tc,'Label','Change Font Size…', 'Callback',@(~,~) obj.changeFontSize());
                    set(obj.hText,'UIContextMenu',tc,'ButtonDownFcn',@(src,~) obj.onLabelClick(src));
                end

                switch lower(at1.Axe)

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

            arrowInstance(obj);

            % Switch to crosshair and start first-click listener
            set(obj.Fig,'Pointer','crosshair');
            set(obj.Fig,'WindowButtonDownFcn',@(~,~) obj.onMouseDown());
        end

        function delete(obj)

            % Destructor: restore original figure state
            if ~isempty(obj.Fig) && isvalid(obj.Fig)
                set(obj.Fig,'WindowButtonDownFcn',obj.origWBDown);
                set(obj.Fig,'WindowButtonMotionFcn',obj.origWBMotion);
                set(obj.Fig,'WindowButtonUpFcn',obj.origWBUp);
                set(obj.Fig,'WindowKeyPressFcn',obj.origPressFcn);
                set(obj.Fig,'Pointer',obj.origPointer);
            end
        end
    end

    methods (Access = private)

        function onMouseDown(obj)

            if ~strcmpi(get(obj.Fig,'Pointer'), 'crosshair')
                return;
            end

            % Record tail and start drawing temp line
            obj.Ax  = gca(obj.Fig);
            cp = get(obj.Ax,'CurrentPoint');
            obj.x1 = cp(1,1);
            obj.y1 = cp(1,2);

            obj.hTemp = ...
                line(obj.Ax, ...
                     [obj.x1 obj.x1], ...
                     [obj.y1 obj.y1], ...
                     'Color'    , obj.Color, ...
                     'LineWidth', obj.LineWidth, ...
                     'LineStyle', obj.LineStyle);

            set(obj.Fig,'WindowButtonMotionFcn',@(~,~) obj.onMouseMove());
            set(obj.Fig,'WindowButtonUpFcn',@(~,~) obj.onMouseUp());
        end

        function onMouseMove(obj)
            % Update temp line during drag
            cp = get(obj.Ax,'CurrentPoint');
            x2 = cp(1,1); y2 = cp(1,2);
            set(obj.hTemp,'XData',[obj.x1 x2],'YData',[obj.y1 y2]);
        end

        function onMouseUp(obj)

            % Finalize arrow drawing
            windowButton('set','up');

            cp = get(obj.Ax,'CurrentPoint');
            x2 = cp(1,1); y2 = cp(1,2);
            dx = x2 - obj.x1;
            dy = y2 - obj.y1;

            delete(obj.hTemp);

            if dx == 0 || dy == 0

                togglePlotEditToolbarState(obj);

                delete(obj);

                textInstance([]);

                return;
            end

            hold(obj.Ax,'on');

            if ~obj.doubleArrow
                % single‐headed arrow
                obj.hArrow = ...
                    quiver(obj.Ax, ...
                           obj.x1, obj.y1, dx, dy, 0, ...
                          'Tag'          , num2str(generateUniqueNumber(false)), ...
                          'Color'        , obj.Color, ...
                          'LineStyle'    , obj.LineStyle, ...
                          'LineWidth'    , obj.LineWidth, ...
                          'MaxHeadSize'  , obj.MaxHeadSize, ...
                          'PickableParts', 'all', ...
                          'HitTest','on');

               if obj.showText
                    addPlotEdit(obj.hArrow, obj.Ax, get(uiSeriesPtr('get'),'Value'), 'multiple', obj.hArrow.Tag);
               else
                    addPlotEdit(obj.hArrow, obj.Ax, get(uiSeriesPtr('get'),'Value'), 'single');
               end

            else
                % double‐headed: draw two quivers with reversed vectors
                obj.hArrow = ...
                    quiver(obj.Ax, ...
                           obj.x1, obj.y1, dx, dy, 0, ...
                           'Tag'          , num2str(generateUniqueNumber(false)), ...
                           'Color'        , obj.Color, ...
                           'LineStyle'    , obj.LineStyle, ...
                           'LineWidth'    , obj.LineWidth, ...
                           'MaxHeadSize'  , obj.MaxHeadSize, ...
                           'PickableParts', 'all', ...
                           'HitTest','off');

                addPlotEdit(obj.hArrow, obj.Ax, get(uiSeriesPtr('get'),'Value'), 'multiple', obj.hArrow.Tag);

                obj.hArrow2 = ...
                    quiver(obj.Ax, ...
                           x2, y2, -dx, -dy, 0, ...
                           'Tag'          , num2str(generateUniqueNumber(false)), ...
                           'Color'        ,obj.Color, ...
                           'LineWidth'    ,2, ...
                           'LineStyle'    , obj.LineStyle, ...
                           'LineWidth'    , obj.LineWidth, ...
                           'MaxHeadSize'  , obj.MaxHeadSize, ...
                           'PickableParts','all', ...
                           'HitTest','on');
                addPlotEdit(obj.hArrow2, obj.Ax, get(uiSeriesPtr('get'),'Value'), 'multiple', obj.hArrow.Tag);

            end

            % Context menu
            c = uicontextmenu(obj.Fig);
            uimenu(c,'Label','Delete Arrow'      , 'Callback',@(~,~) obj.deleteArrow());
            uimenu(c,'Label','Change Color…'     , 'Callback',@(~,~) obj.changeColor());
            uimenu(c,'Label','Change Line Width…', 'Callback',@(~,~) obj.changeLineWidth());

            set(obj.hArrow,'UIContextMenu',c);

            % Drag/resize behavior
            set(obj.hArrow,'ButtonDownFcn',@(~,~) obj.onArrowClick(obj.hArrow));

            if obj.doubleArrow
                set(obj.hArrow2,'UIContextMenu',c);

                % Drag/resize behavior
                set(obj.hArrow2,'ButtonDownFcn',@(~,~) obj.onArrowClick(obj.hArrow2));
            end

            % Restore original figure state
            set(obj.Fig,'WindowButtonMotionFcn',obj.origWBMotion);
            set(obj.Fig,'WindowButtonUpFcn'    ,obj.origWBUp);
            set(obj.Fig,'WindowButtonDownFcn'  ,obj.origWBDown);
            set(obj.Fig,'Pointer'              ,obj.origPointer);

            % Pop up edit box if requested
            if obj.showText

                obj.createEditBox();
            end

            obj.togglePlotEditToolbarState();
            arrowInstance([]);

        end

        function createEditBox(obj)

            set(obj.Fig,'WindowKeyPressFcn', '');

            % Spawn an edit uicontrol at the arrow midpoint
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
                          'Style'   ,'edit', ...
                          'Units'   ,'pixels', ...
                          'Position',[nx, ny, w, h], ...
                          'String'  ,'', ...
                          'Callback',@(src,~) obj.finishEdit(src), ...
                          'BackgroundColor','white', ...
                          'FontWeight'     ,'bold');
            uicontrol(obj.hEdit);
        end

        function finishEdit(obj,src)
            % Read text, delete edit box, create/update label
            txt = get(src,'String'); delete(src); obj.hEdit = [];

            if isempty(obj.hText) || ~isvalid(obj.hText)

                % Place the text at the tail of the arrow
                x = get(obj.hArrow,'XData');
                y = get(obj.hArrow,'YData');
                xm = x;
                ym = y;

                obj.hText = text(obj.Ax,xm,ym,txt, ...
                                 'Tag',num2str(generateUniqueNumber(false)), ...
                                 'HorizontalAlignment', 'center', ...
                                 'VerticalAlignment'  , 'bottom', ...
                                 'FontWeight'         , obj.FontWeight, ...
                                 'FontAngle'          , obj.FontAngle, ...
                                 'FontName'           , obj.FontName, ...
                                 'FontSize'           , obj.FontSize, ...
                                 'Interpreter'        , 'none', ...
                                 'Color'              , obj.Color, ...
                                 'PickableParts','none');

                set(obj.hText, ...
                    'PickableParts','all', ...
                    'HitTest','on', ...
                    'ButtonDownFcn',@(src,~) obj.onLabelClick(src));

                c = uicontextmenu(obj.Fig);
                uimenu(c,'Label','Edit Text…'       , 'Callback',@(~,~) obj.createEditBox());
                uimenu(c,'Label','Change Font Size…', 'Callback',@(~,~) obj.changeFontSize());
                set(obj.hText,'UIContextMenu',c);

               addPlotEdit(obj.hText, obj.Ax, get(uiSeriesPtr('get'),'Value'),  'multiple', obj.hArrow.Tag);

            else
                set(obj.hText,'String',txt);
            end

            set(obj.Fig,'WindowKeyPressFcn',obj.origPressFcn);
        end

        function deleteArrow(obj)

            % Delete arrow, label, edit box, update plot‑edit, clear object

            if ~isempty(obj.hArrow)

                dSeriesOffset = get(uiSeriesPtr('get'),'Value');
                atPlotEditInput = plotEditTemplate('get',dSeriesOffset);

                sTag = obj.hArrow.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput(idx) = [];
                    atPlotEditInput(cellfun(@isempty,atPlotEditInput)) = [];
                end
                delete(obj.hArrow);

                if obj.doubleArrow

                    sTag = obj.hArrow2.Tag;

                    idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                    if ~isempty(idx)
                        atPlotEditInput(idx) = [];
                        atPlotEditInput(cellfun(@isempty,atPlotEditInput)) = [];
                    end
                    delete(obj.hArrow2);
                end

                if obj.showText
                    sTextTag = obj.hText.Tag;
                    delete(obj.hText);

                    idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTextTag}),1);
                    if ~isempty(idx)
                        atPlotEditInput(idx) = [];
                        atPlotEditInput(cellfun(@isempty,atPlotEditInput)) = [];
                    end
                end

                plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

            end

            delete(obj);
            ws = evalin('base','whos');
            for k = 1:numel(ws)
                if strcmp(ws(k).class, class(obj))
                    try
                        v = evalin('base', ws(k).name);
                        if isequal(v, obj)
                            evalin('base',['clear ',ws(k).name]);
                        end
                    catch
                    end
                end
            end

            arrowInstance([]);
        end

        function onArrowClick(obj,src)

            if ~strcmpi(get(obj.Fig,'Pointer'), 'arrow')
                return;
            end

            % Determine click region and set up move/resize
            vec  = [get(src,'UData'),get(src,'VData')];
            cp   = get(obj.Ax,'CurrentPoint'); click = cp(1,1:2);

            len = norm(vec);
            tol = max(0.1*len,0.05);

            tail = [get(src,'XData'), get(src,'YData')];
            head = tail + [get(src,'UData'), get(src,'VData')];

            if obj.isNearPoint(click,tail,tol)
                % clicked near the _tail_ → fix head
                mode     = 'headFixed';
                refPoint = head;
                set(obj.Fig,'Pointer','bottom');
            elseif obj.isNearPoint(click,head,tol)
                % clicked near the _head_ → fix tail
                mode     = 'tailFixed';
                refPoint = tail;
                set(obj.Fig,'Pointer','top');
            else
                mode     = 'move';
                refPoint = [];
                set(obj.Fig,'Pointer','hand');
            end

            if strcmp(mode,'move')
                src.UserData = click;
                set(obj.Fig,'WindowButtonMotionFcn',{@obj.dragArrow,src});
                set(obj.Fig,'WindowButtonUpFcn',@(~,~) obj.finishArrowDrag());
            else
                src.UserData = struct('mode',mode,'refPoint',refPoint);
                set(obj.Fig,'WindowButtonMotionFcn',{@obj.dragResizeArrow,src});
                set(obj.Fig,'WindowButtonUpFcn',@(~,~) obj.finishResizeArrow());
            end
        end

        function dragArrow(obj,~,~,src)

            % Move entire arrow (and label)

            cp      = get(obj.Ax, 'CurrentPoint');
            newPos  = cp(1,1:2);
            lastPos = get(src, 'UserData');
            delta   = newPos - lastPos;

            %  Build list of arrows to move
            if obj.doubleArrow
                arrows = [obj.hArrow, obj.hArrow2];
            else
                arrows = src;
            end

            % Shift each arrow’s XData/YData by delta, and update its UserData
            for h = arrows
                x = get(h, 'XData') + delta(1);
                y = get(h, 'YData') + delta(2);
                set(h, ...
                    'XData',    x, ...
                    'YData',    y, ...
                    'UserData', newPos);
            end

            if ~isempty(obj.hText) && isvalid(obj.hText)
                pos = get(obj.hText, 'Position');
                pos(1:2) = pos(1:2) + delta;
                set(obj.hText, 'Position', pos);
            end

        end

        function finishArrowDrag(obj)

            windowButton('set','up');
            set(obj.Fig,'WindowButtonDownFcn'  , obj.origWBDown);
            set(obj.Fig,'WindowButtonMotionFcn', obj.origWBMotion);
            set(obj.Fig,'WindowButtonUpFcn'    , obj.origWBUp);
            set(obj.Fig,'Pointer'              , obj.origPointer);

            obj.updateTemplatePosition();
        end

        function dragResizeArrow(obj,~,~,src)
            % Get the click location
            cp    = get(obj.Ax,'CurrentPoint');
            click = cp(1,1:2);

            % Grab the mode & refPoint we stored in onArrowClick
            ud    = src.UserData;
            ref   = ud.refPoint;    % either the original tail or original head

            if strcmp(ud.mode,'tailFixed')
                % user clicked near the tail → keep tail fixed, move head
                newTail = ref;
                newVec  = click - ref;
            else
                % mode == 'headFixed'
                % user clicked near the head → keep head fixed, move tail
                newTail = click;
                newVec  = ref   - click;  % vector from new tail back to head
            end

            % Apply to this arrow
            set(src, ...
                'XData', newTail(1), ...
                'YData', newTail(2), ...
                'UData', newVec(1), ...
                'VData', newVec(2));

            % If you’re in “doubleArrow” mode, remember to update the partner
            if obj.doubleArrow
                if isequal(src,obj.hArrow)
                    partner = obj.hArrow2;
                else
                    partner = obj.hArrow;
                end
                % partner’s vector is just the negative of yours
                set(partner, ...
                    'XData', newTail(1)+newVec(1), ...
                    'YData', newTail(2)+newVec(2), ...
                    'UData', -newVec(1), ...
                    'VData', -newVec(2));
            end
        end
        function finishResizeArrow(obj)

            windowButton('set','up');

            obj.restoreFigureState();
            obj.updateLabelPosition();
            obj.updateTemplatePosition();
        end

        function onLabelClick(obj,src)
            % Begin drag: store original pos & click
            set(obj.Fig,'Pointer','hand');
            cp = get(obj.Ax,'CurrentPoint');
            lastClick = [cp(1,1), cp(1,2)];
            origPos   = get(src,'Position');  % [x y z]
            src.UserData = struct('lastClick',lastClick, 'origPos',origPos);

            set(obj.Fig,'WindowButtonMotionFcn',{@obj.dragLabel,src});
            set(obj.Fig,'WindowButtonUpFcn',@(~,~) obj.finishLabelDrag());
        end

        function dragLabel(obj,~,~,src)
            % Move Label to follow mouse
            cp = get(obj.Ax,'CurrentPoint');
            newClick = [cp(1,1), cp(1,2)];
            ud = src.UserData;

            delta = newClick - ud.lastClick;
            newPos = ud.origPos(1:2) + delta;

            set(src,'Position',[newPos, ud.origPos(3)]);
        end

        function finishLabelDrag(obj)
            % End drag, restore figure callbacks/pointer
            windowButton('set','up');
            obj.restoreFigureState();
            obj.updateTemplatePosition();
        end

        function updateLabelPosition(obj)

            % Keep Label at arrow tail
            if isempty(obj.hText) || ~isvalid(obj.hText) 
                return; 
            end
            x = get(obj.hArrow,'XData');
            y = get(obj.hArrow,'YData');
            set(obj.hText,'Position',[x, y, 0]);

        end

        function restoreFigureState(obj)

            set(obj.Fig,'WindowKeyPressFcn'    , obj.origPressFcn);
            set(obj.Fig,'WindowButtonDownFcn'  , obj.origWBDown);
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

            sTag = obj.hArrow.Tag;

            idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
            if ~isempty(idx)
                atPlotEditInput{idx}.Color = aColor;
            end

            set(obj.hArrow, 'Color', aColor);

            if obj.doubleArrow
                sTag = obj.hArrow2.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.Color = aColor;
                end

                set(obj.hArrow2, 'Color', aColor);
            end

            if obj.showText
                sTag = obj.hText.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.Color = aColor;
                end
                set(obj.hText, 'Color', aColor);
            end

            obj.Color = aColor;

            plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

        end

        function changeLineWidth(obj)

            obj.showDialog('Change Line Width', 'New Line Width', get(obj.hArrow, 'LineWidth'));

            waitfor(obj.Dialog);

            dLineWidth = obj.DialogValue;

            if ~isempty(dLineWidth) && dLineWidth > 0

                dSeriesOffset = get(uiSeriesPtr('get'),'Value');

                atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

                sTag = obj.hArrow.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.LineWidth = dLineWidth;
                end

                set(obj.hArrow, 'LineWidth', dLineWidth);

                if obj.doubleArrow
                    sTag = obj.hArrow2.Tag;

                    idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                    if ~isempty(idx)
                        atPlotEditInput{idx}.LineWidth = dLineWidth;
                    end

                    set(obj.hArrow2, 'LineWidth', dLineWidth);
                end

                obj.LineWidth = dLineWidth;

                plotEditTemplate('set', dSeriesOffset, atPlotEditInput);
            end
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


        function updateTemplatePosition(obj)

            dSeriesOffset = get(uiSeriesPtr('get'),'Value');

            atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

            sTag = obj.hArrow.Tag;

            idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
            if ~isempty(idx)

                atPlotEditInput{idx}.XData = obj.hArrow.XData;
                atPlotEditInput{idx}.YData = obj.hArrow.YData;
                atPlotEditInput{idx}.ZData = obj.hArrow.ZData;
                atPlotEditInput{idx}.UData = obj.hArrow.UData;
                atPlotEditInput{idx}.VData = obj.hArrow.VData;
                atPlotEditInput{idx}.WData = obj.hArrow.WData;
            end

            if obj.doubleArrow
                sTag = obj.hArrow2.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.XData = obj.hArrow2.XData;
                    atPlotEditInput{idx}.YData = obj.hArrow2.YData;
                    atPlotEditInput{idx}.ZData = obj.hArrow2.ZData;
                    atPlotEditInput{idx}.UData = obj.hArrow2.UData;
                    atPlotEditInput{idx}.VData = obj.hArrow2.VData;
                    atPlotEditInput{idx}.WData = obj.hArrow2.WData;
                end
            end

            if obj.showText

                sTag = obj.hText.Tag;

                idx = find(strcmp(cellfun(@(x)x.Tag,atPlotEditInput,'uni',false),{sTag}),1);
                if ~isempty(idx)
                    atPlotEditInput{idx}.Position = obj.hText.Position;
                end
            end

            plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

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
                         'CallBack'  , @okDialogCallback...
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

            % Get the plot-edit toolbar/menu object
            menObj = plotEditMenuObject('get');
            if isempty(menObj)
                return;
            end

            % Loop through each menu item and switch based on its Label

            for jj=1:numel(menObj)
                
                hItem = menObj{jj};
                switch hItem.UserData.label

                    case 'Single-Arrow'

                        % single arrow, no text
                        if ~obj.doubleArrow && ~obj.showText

                            set(hItem, 'CData', hItem.UserData.default);
                        end

                    case 'Double-Arrow'
                        if obj.doubleArrow && ~obj.showText
                            set(hItem, 'CData', hItem.UserData.default);
                        end


                    case 'Text-Single-Arrow'
                        % single arrow with text
                        if ~obj.doubleArrow &&  obj.showText
                            set(hItem, 'CData', hItem.UserData.default);
                        end

                    case 'Text-Double-Arrow'
                        % double arrow with text
                        if  obj.doubleArrow &&  obj.showText
                            set(hItem, 'CData', hItem.UserData.default);
                        end                    
                end

            end
 
        end

    end

    methods (Static, Access = private)

        function tf = isNearPoint(pt,refpt,tol)
            tf = norm(pt-refpt) <= tol;
        end

    end
end
