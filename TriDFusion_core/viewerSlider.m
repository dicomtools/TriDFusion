classdef viewerSlider < handle
%function obj = viewerSlider(parent, pos, bgColor, minVal, maxVal, initVal, callbackFcn, trackAlpha, thumbAlpha, thumbFracWidth, thumbFracHeight)                                     
%Create a custom slider class
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
% 
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.

    events
        ValueChanged
        ContinuousValueChange
    end

    properties (Dependent)
        Parent
        Position
        Visible
        Enable
    end

    properties
        Panel
        Axes
        Thumb
        TrackPatch
    end

    properties (Dependent)
        Value
        Min
        Max
        SliderStep
        BackgroundColor
        UserData
    end

    properties (Access=private)
        CVal
        CMin
        CMax
        CStep
        TrackBg
        ThumbFace
        ThumbEdge
        CBackgroundColor
        CallbackFcn      
        InMotionCallback
        TrackAlpha       
        ThumbAlpha       
        TFw              % thumb-fraction-of-track-length
        TFh              % thumb-fraction-of-thickness
        OldMotionFcn
        OldUpFcn
        CEnable = 'on'
        IsDragging = false
        Orientation      % 'horizontal' or 'vertical'
        CUserData
    end

    methods
        function obj = viewerSlider(parent, pos, bgColor, trackBg, thumbFace, thumbEdge, minVal, maxVal, initVal, callbackFcn, ...
                                     inMotionCallback, trackAlpha, thumbAlpha, thumbFracWidth, thumbFracHeight, userData)
            if nargin<12 || isempty(trackAlpha),     trackAlpha = 0.3; end
            if nargin<13 || isempty(thumbAlpha),     thumbAlpha = 0.8; end
            if nargin<14 || isempty(thumbFracWidth),  thumbFracWidth = 0.02; end
            if nargin<15 || isempty(thumbFracHeight), thumbFracHeight = 0.8; end
            if nargin<16 || isempty(userData), userData = []; end

            obj.CallbackFcn      = callbackFcn;
            obj.InMotionCallback = inMotionCallback;
            obj.TrackAlpha       = trackAlpha;
            obj.ThumbAlpha       = thumbAlpha;
            obj.TFw              = thumbFracWidth;
            obj.TFh              = thumbFracHeight;
            obj.TrackBg          = trackBg;
            obj.ThumbFace        = thumbFace;
            obj.ThumbEdge        = thumbEdge;
            obj.CBackgroundColor = bgColor;
            obj.CMin             = minVal;
            obj.CMax             = maxVal;
            obj.CVal             = min(max(initVal, minVal), maxVal);
            span                 = obj.CMax - obj.CMin;
            obj.CStep            = [1/span, 1/span];
            obj.CUserData        = userData;

            %–– detect orientation
            if pos(3) < pos(4)
                obj.Orientation = 'vertical';
            else
                obj.Orientation = 'horizontal';
            end

            %–– build panel
            obj.Panel = uipanel( ...
                'Parent', parent, ...
                'Units', 'pixels', ...
                'Position', pos, ...
                'BorderType', 'none', ...
                'BackgroundColor', bgColor, ...
                'ForegroundColor', bgColor, ...
                'HighlightColor' , bgColor);

            %–– set axis limits
            if strcmp(obj.Orientation,'horizontal')
                axXLim = [obj.CMin, obj.CMax];
                axYLim = [0,1];
            else
                axXLim = [0,1];
                axYLim = [obj.CMin, obj.CMax];
            end

            %–– create axes
            obj.Axes = axes( ...
                'Parent',    obj.Panel, ...
                'Units',     'pixels', ...
                'Position',  [0 0 pos(3) pos(4)], ...
                'XLim',      axXLim, ...
                'YLim',      axYLim, ...
                'Color',     'none', ...
                'Visible',   'off', ...
                'Box',       'off', ...
                'XTick',     [], ...
                'YTick',     []);
            deleteAxesToolbar(obj.Axes);
            disableDefaultInteractivity(obj.Axes);

            %–– draw track
            if strcmp(obj.Orientation,'horizontal')
                trH = obj.TFh;                      % thickness fraction of height
                y0  = 0.5 - trH/2;
                Xd  = [obj.CMin obj.CMax obj.CMax obj.CMin];
                Yd  = [y0        y0      y0+trH   y0+trH];
            else
                trW = obj.TFh;                      % thickness fraction of width
                x0  = 0.5 - trW/2;
                Xd  = [x0      x0+trW  x0+trW   x0];
                Yd  = [obj.CMin obj.CMin obj.CMax obj.CMax];
            end
            obj.TrackPatch = patch( ...
                'Parent',    obj.Axes, ...
                'XData',     Xd, ...
                'YData',     Yd, ...
                'FaceColor', obj.TrackBg, ...
                'FaceAlpha', obj.TrackAlpha, ...
                'EdgeColor', 'none', ...
                'HitTest',   'off');

            %–– draw thumb
            obj.Thumb = obj.makeThumb(obj.CVal);

            %–– respond to resize
            obj.Panel.SizeChangedFcn = @(~,~) set( ...
                obj.Axes, 'Position', [0 0 obj.Panel.Position(3) obj.Panel.Position(4)]);
        end

        function delete(obj)
            if isvalid(obj.Panel)
                delete(obj.Panel);
            end
        end

        %— simple pass-throughs
        function p = get.Parent(obj),   p = obj.Panel.Parent;         end
        function v = get.Visible(obj),  v = obj.Panel.Visible;        end
        function set.Visible(obj,v),    obj.Panel.Visible = v;        end
        function e = get.Enable(obj),   e = obj.CEnable;             end
        function set.Enable(obj,val)
            val = validatestring(val, {'on','off'});
            obj.CEnable = val;
            set(obj.Thumb, 'Visible', val, 'HitTest', val);
        end
        function pos = get.Position(obj), pos = obj.Panel.Position;  end
        function set.Position(obj,pos)
            if ~isempty(pos)
                obj.Panel.Position = pos;
                obj.Axes.Position  = [0 0 pos(3) pos(4)];
            end
        end

        %— Value, Min, Max, SliderStep, BackgroundColor
        function val = get.Value(obj), val = obj.CVal;              end
        function set.Value(obj,val)
            val = min(max(val, obj.CMin), obj.CMax);
            obj.CVal = val;
            obj.updateThumb();
            notify(obj,'ValueChanged');
        end
        function m = get.Min(obj), m = obj.CMin;                    end
        function set.Min(obj,m)
            obj.CMin = m;
            if obj.CMax > m
                set(obj.Axes,'XLim',[m obj.CMax]);
                obj.TrackPatch.XData = [m obj.CMax obj.CMax m];
            end
            obj.Value = obj.CVal;
        end
        function M = get.Max(obj), M = obj.CMax;                    end
        function set.Max(obj,M)
            obj.CMax = M;
            if M > obj.CMin
                set(obj.Axes,'XLim',[obj.CMin M]);
                obj.TrackPatch.XData = [obj.CMin M M obj.CMin];
            end
            obj.Value = obj.CVal;
        end
        function st = get.SliderStep(obj),   st = obj.CStep;       end
        function set.SliderStep(obj,st)
            if numel(st)==2, obj.CStep = st; end
        end
        function c = get.BackgroundColor(obj), c = obj.CBackgroundColor; end
        function set.BackgroundColor(obj,c)
            if strcmpi(char(c),'white'), c=[1 1 1]; end
            if strcmpi(char(c),'black'), c=[0 0 0]; end
            if numel(c)==3
                obj.CBackgroundColor = c;
                set(obj.Panel, ...
                    'BackgroundColor',c, ...
                    'ForegroundColor',c, ...
                    'HighlightColor',c);
            end
        end

        function c = get.UserData(obj), c = obj.CUserData; end
        function set.UserData(obj,c), obj.CUserData = c; end
    
        %— generic GET/SET
        function varargout = get(obj, prop)
            switch prop
                case 'Value',          varargout{1}=obj.Value;
                case 'Min',            varargout{1}=obj.Min;
                case 'Max',            varargout{1}=obj.Max;
                case 'SliderStep',     varargout{1}=obj.SliderStep;
                case 'BackgroundColor',varargout{1}=obj.BackgroundColor;
                case 'Parent',         varargout{1}=obj.Parent;
                case 'Position',       varargout{1}=obj.Position;
                case 'Visible',        varargout{1}=obj.Visible;
                case 'Enable',         varargout{1}=obj.Enable;
                case 'UserData',       varargout{1}=obj.UserData;
               otherwise, error('viewerSlider:get:InvalidProp','Unknown property "%s".',prop);
            end
        end
        function set(obj, varargin)
            for k=1:2:numel(varargin)
                switch varargin{k}
                    case 'Value',          obj.Value=varargin{k+1};
                    case 'Min',            obj.Min=varargin{k+1};
                    case 'Max',            obj.Max=varargin{k+1};
                    case 'SliderStep',     obj.SliderStep=varargin{k+1};
                    case 'BackgroundColor',obj.BackgroundColor=varargin{k+1};
                    case 'Visible',        obj.Visible=varargin{k+1};
                    case 'Enable',         obj.Enable=varargin{k+1};
                    case 'Position',       obj.Position=varargin{k+1};
                    case 'UserData',       obj.UserData=varargin{k+1};
                    otherwise, error('viewerSlider:set:InvalidProp','Unknown property "%s".',varargin{k});
                end
            end
        end
    end

    methods (Access=private)

        function thumb = makeThumb(obj, v)
            % Compute half‐width (in data units) of the thumb
            span = obj.CMax - obj.CMin;
            tw   = span * obj.TFw;

            if strcmp(obj.Orientation,'horizontal')
                % vertical extent of thumb
                y0 = 0.5 - obj.TFh/2;
                y1 = y0 + obj.TFh;
                % desired left/right before clamping
                left  = v - tw;
                right = v + tw;
                % clamp so entire thumb stays inside [CMin, CMax]
                if left < obj.CMin
                    left  = obj.CMin;
                    right = left + 2*tw;
                elseif right > obj.CMax
                    right = obj.CMax;
                    left  = right - 2*tw;
                end
                Xd = [left right right left];
                Yd = [y0    y0    y1    y1];
            else
                % horizontal extent of thumb
                wid = obj.TFh;
                x0  = 0.5 - wid/2;
                x1  = x0 + wid;
                % desired bottom/top before clamping
                bottom = v - tw;
                top    = v + tw;
                if bottom < obj.CMin
                    bottom = obj.CMin;
                    top    = bottom  + 2*tw;
                elseif top > obj.CMax
                    top    = obj.CMax;
                    bottom = top - 2*tw;
                end
                Xd = [x0 x1 x1 x0];
                Yd = [bottom bottom top top];
            end
             thumb = patch( ...
                 'Parent',       obj.Axes, ...
                 'XData',        Xd, ...
                 'YData',        Yd, ...
                 'FaceColor',    obj.ThumbFace, ...
                 'FaceAlpha',    obj.ThumbAlpha, ...
                 'EdgeColor',    obj.ThumbEdge, ...
                 'HitTest',      'on', ...
                 'ButtonDownFcn',@(~,~) obj.startDrag());
        end

        function updateThumb(obj)
            if isgraphics(obj.Thumb), delete(obj.Thumb); end
            obj.Thumb = obj.makeThumb(obj.CVal);
        end

        function startDrag(obj)
            fig = ancestor(obj.Axes,'figure');
            obj.OldMotionFcn = fig.WindowButtonMotionFcn;
            obj.OldUpFcn     = fig.WindowButtonUpFcn;
            obj.IsDragging   = true;
            set(fig,'Interruptible','on','BusyAction','queue');
            fig.WindowButtonMotionFcn = @(~,~) obj.onMotion();
            fig.WindowButtonUpFcn     = @(~,~) obj.onRelease();
        end

        function onMotion(obj)
            % Get the mouse position in data units, clamp to [CMin,CMax]
            cp  = get(obj.Axes,'CurrentPoint');
            if strcmp(obj.Orientation,'horizontal')
                new = min(max(cp(1,1), obj.CMin), obj.CMax);
            else
                new = min(max(cp(1,2), obj.CMin), obj.CMax);
            end
            % Update value and redraw the thumb (using clamped makeThumb logic)
            obj.CVal = new;
            obj.updateThumb();

            if obj.InMotionCallback
                obj.CallbackFcn(new);
            end
            notify(obj,'ContinuousValueChange');
            drawnow limitrate;
        end

        function onRelease(obj)
            fig = ancestor(obj.Axes,'figure');
            % restore original callbacks
            fig.WindowButtonMotionFcn = obj.OldMotionFcn;
            fig.WindowButtonUpFcn     = obj.OldUpFcn;

            % use the already‐clamped value from onMotion
            newVal = obj.CVal;

            % redraw thumb and fire callbacks
            obj.updateThumb();
            obj.CallbackFcn(newVal);
            notify(obj,'ValueChanged');

            obj.IsDragging = false;
            windowButton('set','up');
       end       
    end
end