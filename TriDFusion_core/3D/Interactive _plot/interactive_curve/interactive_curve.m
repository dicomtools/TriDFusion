classdef interactive_curve < handle
     properties (SetAccess = public)
         figureHandle
         axesHandle
         numberOfMarkers
         x % makers x-coordinates
         y  % makers y-coordinates
         lineHandle
         xMargin % margin to prevent too close to border of axes, marker can not be closer to horizontal border then xMargine
         yMargin % margin to prevent too close to border of axes, marker can not be closer to verticle border then yMargine
         gap % margin to prevent too close markers, makere can not be closer then gap to another marker in x direction
         xLine % x coordinaties of the line, line x cordinates is xLine, y coordinatioes is interpolation(xLine)
         userFunctionHandle % user defined function for interpolation, used when method='userdefined'
         markersHandles % array of handles to markers
         MarkersInLine % if MarkersInLine=true then in line draw extend xLine with makers x coordinaties
         mouseMode % mouseMode=1 then mode of move makrers, mouseMode=2 then mode of add maker, mouseMode=3 then mode of reamove maker
         motionFunctionHandle % this function will be called contiusly while a marker move, it will be placed in redraw() and button_motion() method, if isempty(motionFunctionHandle)=true, then no function execution (default case)
         motionFunctionArgument % argument for motion function, one argument, for many arguments use cell array
         boundary % if boundary=0 then no boundary (default), if boundary=1 then set boundary to boundaryYLeft and boundaryYRight, if boundary=2 then periodic boundary
         boundaryYLeft % left boundary point y-value, used if ic.boundary=1
         boundaryYRight % right boundary point y-value, used if ic.boundary=1
         additionalDeleteFunctionHandle % handle to function that will be run additionaly when delete interactive_curve, defult is empty, this function has no input argument
         surfObj
    end
     properties (SetAccess = protected)
         method % interpolation method: 'nearest' 'linear' 'spline' 'pchip' 'cubic' 'v5cubic' 'delta' 'userdefined'
     end
     methods (Access = private)
         % mouse functions:
         function button_down(ic,src,eventdata)          
             
             if strcmp(get(ic.figureHandle,'selectiontype'),'alt')
              %  alphaCurveMenu(ic);
             end
             
             % used when mouse button clicked
             makerHandle=src;
             switch ic.mouseMode
                 case 1 % mode of maker motion
                    set(ic.figureHandle,'WindowButtonMotionFcn',{@ic.button_motion,makerHandle});
                 case 3 % mode of delete marker
                     ic.deleteMarkerByHandle(makerHandle);
             end
             
             function alphaCurveMenu(ic)

                c = uicontextmenu(ic.figureHandle);                           

                ic.axesHandle.UIContextMenu = c;

                uimenu(c,'Label','Move Marker'  , 'Checked', 'on', 'Callback',@setAlphaCurveAction);
                uimenu(c,'Label','Insert Marker', 'Callback',@setAlphaCurveAction);
                uimenu(c,'Label','Delete Marker', 'Callback',@setAlphaCurveAction);

                function setAlphaCurveAction(hObject, ~)
                    switch hObject.Label
                        case 'Move Marker'   
   
                            ic.mouseMode = 1;

                        case 'Insert Marker'           
 
                            ic.mouseMode = 2;

                        case 'Delete Marker'           
                        
                            ic.mouseMode = 3;                        
                    end
                end

            end            
         end
         
         function button_motion(ic,src,eventdata,makerHandle)                         
            
            % used when mouse motion with mouse button clicked
            p=get(ic.axesHandle,'CurrentPoint');
            px=p(1,1);
            py=p(1,2);

            % axes limits:
            xx=get(ic.axesHandle,'XLim');
            yy=get(ic.axesHandle,'YLim');
            x1=xx(1)+ic.xMargin;
            x2=xx(2)-ic.xMargin;
            y1=yy(1)+ic.yMargin;
            y2=yy(2)-ic.yMargin;

            % limits from rest markers:
            f=find(ic.markersHandles==makerHandle); % find current maker in list of markers.
            L=length(ic.markersHandles);
            dx=x2-x1;
            %dxs=dx/(4*L); % margin, prevent too close markers
            dxs=ic.gap;
            switch L
                case 1
                    xx1=x1;
                    xx2=x2;
                case 2
                    if f==1
                        xx1=x1;
                        xx2=get(ic.markersHandles(2),'XData')-dxs;
                    else
                        % f==2
                        xx1=get(ic.markersHandles(1),'XData')+dxs;
                        xx2=x2;
                    end
                otherwise
                    switch f
                        case 1
                            xx1=x1;
                            xx2=get(ic.markersHandles(2),'XData')-dxs;
                        case L
                            xx1=get(ic.markersHandles(L-1),'XData')+dxs;
                            xx2=x2;
                        otherwise
                            xx1=get(ic.markersHandles(f-1),'XData')+dxs;
                            xx2=get(ic.markersHandles(f+1),'XData')-dxs;
                    end
            end

            if px<xx1
                px=xx1;
            end
            if px>xx2
                px=xx2;
            end
            if py<y1
                py=y1;
            end
            if py>y2
                py=y2;
            end

            % update markers:
            set(makerHandle,'XData',px,'YData',py);
            ic.x(f)=px;
            ic.y(f)=py;

            % update line:
            if ic.MarkersInLine
                xLineExtended=unique([ic.xLine ic.x]);
            else
                xLineExtended=ic.xLine;
            end
            yi=ic.interp1extended(ic.x,ic.y,xLineExtended,ic.method,ic.userFunctionHandle);
            set(ic.lineHandle,'XData',xLineExtended,'YData',yi);
            
            % motion function:
            if ~isempty(ic.motionFunctionHandle)
                mfn=ic.motionFunctionHandle;
                mfn(ic.motionFunctionArgument);
            end
            
            drawnow;

            aAlphamap = computeAlphaMap(ic);
            if ~isempty(aAlphamap)
                ic.surfObj.Alphamap = aAlphamap;
            end
         end
                  
         function button_up(ic,src,eventdata)
             % used when mouse button released
     %       figureHandle=src;
      %      set(figureHandle,'WindowButtonMotionFcn','');
             set(src,'WindowButtonMotionFcn', @mouseMove);
  %                 windowButton('set', 'up');           
    
            ic.mouseMode=1;           
         end
         
         function axes_button_down(ic,src,eventdata)
             % used when clicked in axes to create new makrer if ic.mouseMode=2
             
             if ~strcmp(ic.figureHandle.SelectionType,'alt')

                 if ic.mouseMode==2
                     p=get(ic.axesHandle,'CurrentPoint');
                     px=p(1,1);
                     py=p(1,2);
                     ic.addMarker(px,py,'auto');
                 else
                    ic.mouseMode=1;
                 end
             end
         end
         
         function close_figure_request(ic,src,eventdata)
         if 0    
             % used when figure close
             hf=ic.figureHandle;
             delete(ic); % delete interactive curve
             delete(hf); % delete figure
         end
         end
     end
     methods
         function ic=interactive_curve(varargin)
             % creates intreractive curve
             % ic=interactive_curve creates new figure and axes and creats interactive curve there
             % ic=interactive_curve(figureHandle,axesHandle) creates intreractive curve in axes with handle axesHandle in fugure with handle figureHandle
             % ic=interactive_curve(figureHandle,axesHandle,markersX,markersY) with specified markers positions
             % ic=interactive_curve(figureHandle,axesHandle,markersX,markersY,XLim,YLim)  with specified markers positions and axes limits
             if nargin==0
                figureHandle=figure;
                axesHandle=axes;
                axis(axesHandle,'manual');
             else
                figureHandle=varargin{1};
                axesHandle=varargin{2};
             end
             ic.figureHandle=figureHandle;
             ic.axesHandle=axesHandle;
             ic.mouseMode=1;
             ic.motionFunctionHandle=[]; % no function
             ic.motionFunctionArgument=[]; % no arguments
             ic.additionalDeleteFunctionHandle=[]; % no function
             ic.boundary=0; % no boundary
             ic.boundaryYLeft=0;
             ic.boundaryYRight=0;
             %xMargin=0.15;
             %yMargin=0.05;
             %gap=0.15;
                          
             
             set(figureHandle,'WindowButtonUpFcn',{@ic.button_up},...
                 'HitTest','off');
             ic.MarkersInLine=true;
             if nargin<=2
                 numberOfMarkers=10;
                 x=1:numberOfMarkers;
                 y=zeros(size(x));
             elseif nargin>=4
                 x=varargin{3};
                 y=varargin{4};
                 numberOfMarkers=length(x);
             end
             ic.x=x;
             ic.y=y; % makers coordinates
             xMargin=(max(x)-min(x))/70;
             yMargin=0.05;
             gap=(max(x)-min(x))/70;
             ic.xMargin=xMargin;
             ic.yMargin=yMargin;
             ic.gap=gap;
             markersHandles=zeros(1,numberOfMarkers);
             NextPlot=get(axesHandle,'NextPlot');
             set(axesHandle,'NextPlot','add','HitTest','on');
                              
             if nargin<=2
                set(axesHandle,'XLim',[min(x)-xMargin max(x)+xMargin],'YLim',[-1-yMargin 1+yMargin]);
             elseif nargin==4
                 set(axesHandle,'XLim',[min(x)-xMargin max(x)+xMargin],'YLim',[min(y)-yMargin max(y)+yMargin]);
             elseif nargin==6
                 set(axesHandle,'XLim',varargin{5},'YLim',varargin{6});
             end
                          
             method='linear';
             %method='nearest';
             %method='delta';
             ic.method=method;
             lineResolution=100;
             %xi=linspace(x(1),x(end),lineResolution);
             xlm=get(axesHandle,'XLim');
             xi=linspace(xlm(1),xlm(2),lineResolution);
             xLine=xi;
             if ic.MarkersInLine
                xLineExtended=unique([xLine ic.x]);
             else
                xLineExtended=xLine;
             end
             %yi=interp1(x,y,xi,method);
             yi=ic.interp1extended(x,y,xLineExtended,method,[]);
             lineHandle=plot(xLineExtended,yi,'c-','HitTest','off','parent',axesHandle);
             for c=1:numberOfMarkers
                markersHandles(c)=plot(x(c),y(c),'ko','MarkerFaceColor','c','markersize',8,...
                    'parent',axesHandle,'HitTest','on', 'visible', 'off');
             end
             
             ic.numberOfMarkers=numberOfMarkers;
             ic.markersHandles=markersHandles;
             ic.lineHandle=lineHandle;
             ic.xLine=xLine;
             ic.userFunctionHandle=[]; % empty
             for c=1:numberOfMarkers
                 set(markersHandles(c),'ButtonDownFc',{@ic.button_down});
             end
             
             ic.markersHandles=markersHandles;
             
             set(axesHandle,'NextPlot',NextPlot); % return back nextplot property
             
             set(axesHandle,'ButtonDownFcn',{@ic.axes_button_down});
             
             % to delete interactive_curve objecte befor close figure:
%             set(figureHandle,'CloseRequestFcn',{@ic.close_figure_request});
             
             
         end
         function setMethod(ic,method)
             % ic.setMethod(method) set new method of interpolation
             % interp1 methods: 'nearest' 'linear' 'spline' 'pchip' 'cubic' 'v5cubic', see help for interp1
             % aditional method: 'delta' - each marker makes delta function
             % 'userdefined'  to define some other method, use userFunctionHandle property
             
             % check input:
             if any(strcmpi(method,{'nearest','linear','spline','pchip','cubic','v5cubic','delta','userdefined'}))
                 
             else
                 error(['unknown method: '  method]);
             end
             
             ic.method=method;
             ic.redraw();
         end
         function redraw(ic)
             % ic.redraw() update line
             if ic.MarkersInLine
                xLineExtended=unique([ic.xLine ic.x]);
             else
                xLineExtended=ic.xLine;
             end
             yi=ic.interp1extended(ic.x,ic.y,xLineExtended,ic.method,ic.userFunctionHandle);
             set(ic.lineHandle,'XData',xLineExtended,'YData',yi);
             if ~isempty(ic.motionFunctionHandle)
                mfn=ic.motionFunctionHandle;
                mfn(ic.motionFunctionArgument);
             end
             
             drawnow;
         end
         function setMarkersColor(ic,color)
             % ic.setMarkersColor(color) change markers face color, color symbol or 3-elements vector
             for mc=1:length(ic.markersHandles)
                 hm=ic.markersHandles(mc);
                 set(hm,'MarkerFaceColor',color);
             end
         end
         function setMarkersSize(ic,sz)
             % ic.setMarkersSize(sz) change markers size, units: points
             for mc=1:length(ic.markersHandles)
                 hm=ic.markersHandles(mc);
                 set(hm,'markersize',sz);
             end
         end
         function setMarkersSymbol(ic,sb)
             % ic.setMarkersSymbol(sb) set marker symbol, 'o'  'x' '+' ect, see help for plot
             for mc=1:length(ic.markersHandles)
                 hm=ic.markersHandles(mc);
                 set(hm,'Marker',sb);
             end
         end
         
         function deleteMarkerByNumber(ic,markerNumber)
             % ic.deleteMarkerByNumber(markerNumber)  delete marker by order number
             L=length(ic.markersHandles);
             if (1<=markerNumber)&&(markerNumber<=L)
                delete(ic.markersHandles(markerNumber));
                ind=find((1:L)~=markerNumber);
                ic.markersHandles=ic.markersHandles(ind);
                ic.numberOfMarkers=length(ic.markersHandles);
                ic.x=ic.x(ind);
                ic.y=ic.y(ind);
                ic.redraw();
             end
         end
         
         function deleteMarkerByHandle(ic,makerHandle)
             % ic.deleteMarkerByHandle(makerHandle)  delete marker by marker handle
             L=length(ic.markersHandles);
             markerNumber=find(ic.markersHandles==makerHandle);
             if ~isempty(markerNumber)
                delete(ic.markersHandles(markerNumber));
                ind=find((1:L)~=markerNumber);
                ic.markersHandles=ic.markersHandles(ind);
                ic.numberOfMarkers=length(ic.markersHandles);
                ic.x=ic.x(ind);
                ic.y=ic.y(ind);
                ic.redraw();
             end
             
             aAlphamap = computeAlphaMap(ic);
             if ~isempty(aAlphamap)
                ic.surfObj.Alphamap = aAlphamap;
             end  
            
             ic.mouseMode=1;

         end
         
         function addMarker(ic,markerX,markerY,varargin)
             % add marker to specified position
             % ic.addMarker(markerX,markerY) - add marker, do not change xLine
             % ic.addMarker(markerX,markerY,xLineNew) - add marker and change xLine to xLineNew
             % ic.addMarker(markerX,markerY,'auto') - add marker and auto extend xLine if neccesary
             L=length(ic.markersHandles);
             NextPlot=get(ic.axesHandle,'NextPlot');
             set(ic.axesHandle,'NextPlot','add');
             if L==0
                markersHandle=plot(markerX,markerY,'ko','MarkerFaceColor','c','markersize',8,...
                        'parent',ic.axesHandle,'HitTest','on');
             else
                 h=ic.markersHandles(1);
                 c=get(h,'MarkerFaceColor');
                 m=get(h,'Marker');
                 ms=get(h,'markersize');
                 ec=get(h,'MarkerEdgeColor');
                 ls=get(h,'LineStyle');
                 cl=get(h,'Color');
                 markersHandle=plot(markerX,markerY,'MarkerFaceColor',c,'markersize',ms,'MarkerEdgeColor',ec,...
                     'LineStyle',ls,'marker',m,'Color',cl,...
                        'parent',ic.axesHandle,'HitTest','on');
             end
             set(markersHandle,'ButtonDownFc',{@ic.button_down});
             
             
             ff=find(ic.x<markerX);
             if isempty(ff)
                 % new marker is righter then all old markers
                 ic.markersHandles=[markersHandle ic.markersHandles];
                 ic.numberOfMarkers=length(ic.markersHandles);
                 ic.x=[markerX ic.x];
                 ic.y=[markerY ic.y];
             else
                fm=max(ff); % most right marker that on left side of new marker
                ic.markersHandles=[ic.markersHandles(1:fm) markersHandle ic.markersHandles(fm+1:end)];
                ic.numberOfMarkers=length(ic.markersHandles);
                ic.x=[ic.x(1:fm) markerX ic.x(fm+1:end)];
                ic.y=[ic.y(1:fm) markerY ic.y(fm+1:end)];
             end
             set(ic.axesHandle,'NextPlot',NextPlot); % return back nextplot property
             
             % extend limits if need:
             %set(ic.axesHandle,'XLim',[min(ic.x)-ic.xMargin max(ic.x)+ic.xMargin],'Ylim',[min(ic.y)-ic.yMargin max(ic.y)+ic.yMargin]);
             xl=get(ic.axesHandle,'XLim');
             if (min(ic.x)<xl(1))||(xl(2)<max(ic.x))
                set(ic.axesHandle,'XLim',[min(ic.x)-ic.xMargin max(ic.x)+ic.xMargin]);
             end
             yl=get(ic.axesHandle,'YLim');
             if (min(ic.y)<yl(1))||(yl(2)<max(ic.y))
                set(ic.axesHandle,'Ylim',[min(ic.y)-ic.yMargin max(ic.y)+ic.yMargin]);
             end
             
             if nargin>3
                 if ~ischar(varargin{1})
                     % addMarker(ic,markerX,markerY,xLineNew) - add marker and change xLine to xLineNew
         
                     ic.xLine=varargin{1};
                 else
                     if strcmpi(varargin{1},'auto')
                         % addMarker(ic,markerX,markerY,'auto') - add marker and auto extend xLine if neccesary
                         % extend xLine if need:
                         %if (xMarker<ic.xLine(1))||(xMarker>ic.xLine(end))
                         if (markerX<ic.xLine(1))
                            % update xLine:
                            dx=mean(diff(ic.xLine)); % define step as mean
                            extn=ic.xLine(1):-dx:markerX; % example: extn=[1 0.8 0.6] (markerX=0.5, dx=0.2, xLine(1)=1)
                            fextn=fliplr(extn); %=[0.6 0.8 1]
                            ic.xLine=[fextn(1:end-1) ic.xLine];
                           
                         end
                         if (markerX>ic.xLine(end))
                            % update xLine:
                            dx=mean(diff(ic.xLine)); % define step as mean
                            extn=ic.xLine(end):dx:markerX;
                            ic.xLine=[ic.xLine extn(2:end)];
                         end
                     end
                 end
             end

            ic.redraw();
            
            aAlphamap = computeAlphaMap(ic);
            if ~isempty(aAlphamap)
                ic.surfObj.Alphamap = aAlphamap;
            end
            
            ic.mouseMode=1;
          
         end
         
         function setMarkersInLine(ic,tf)
            % ic.setMarkersInLine(tf)  set MarkersInLine property and redraw line
            % if MarkersInLine=true then in line draw extend xLine with makers x coordinaties
            ic.MarkersInLine=tf;
            ic.redraw();
         end
         
         
         function yi=interp1extended(ic,x,y,xi,method,userFunctionHandle)
             % ic.interp1extended(x,y,xi,method,userFunctionHandle)  makes interpolation
             % used in redraw line and in interpData()
             if (length(x)<2)&&(ic.boundary~=1)
                 yi=NaN(size(xi));
             else
             
                if strcmpi(method,'userdefined')
                    if ic.boundary==0
                        yi=userFunctionHandle(x,y,xi);
                    elseif ic.boundary==1 % user defined boundaryYLeft and boundaryYRight
                        xlm=get(ic.axesHandle,'XLim'); 
                        yi=userFunctionHandle([xlm(1) x xlm(2)],[ic.boundaryYLeft y ic.boundaryYRight],xi);
                    elseif ic.boundary==2 % periodic boundary
                        xlm=get(ic.axesHandle,'XLim');
                        T=xlm(2)-xlm(1);
                        x5=[x-2*T  x-T  x  x+T  x+2*T];
                        yi=userFunctionHandle(x5,[y y y y y],xi);
                    end
                    return;
                end

                if strcmpi(method,'delta')
                    % in delta interpolation give same result indepedtently
                    % from boundary



                    ind=interp1(xi,1:length(xi),x,'nearest'); % index of xi, length(x)=length(ind)=number of markers
                    yi=zeros(size(xi));
                    yi(ind(~isnan(ind)))=y(~isnan(ind));
                    return;
                end

                % otherwise interp1:
                if ic.boundary==0
                    yi=interp1(x,y,xi,method);
                elseif ic.boundary==1 % user defined boundaryYLeft and boundaryYRight
                    xlm=get(ic.axesHandle,'XLim');
                    yi=interp1([xlm(1) x xlm(2)],[ic.boundaryYLeft y ic.boundaryYRight],xi,method); 
                elseif ic.boundary==2 % periodic boundary
                    xlm=get(ic.axesHandle,'XLim');
                    T=xlm(2)-xlm(1);
                    x5=[x-2*T  x-T  x  x+T  x+2*T];
                    yi=interp1(x5,[y y y y y],xi,method);
                end
             end
         end
         
         
         function yi=interpData(ic,xi,isXPeriodic)
             % ic.interpData(xi,isXPeriodic) interpolate specified data with current method and markers postion
             % if isXPeriodic=true then xi can be out of x axis limits and
             % will be move to x limits as periodic function before
             % interpolation
             xlm=get(ic.axesHandle,'XLim');
             T=xlm(2)-xlm(1);
             if strcmpi(ic.method,'delta')&&isXPeriodic
                mn=min(xi);
                mx=max(xi);
                Nmn=floor(mn/T);
                Nmx=floor(mx/T);
                N=Nmn:Nmx; % periods numbers
                n=Nmx-Nmn+1;
                xea=bsxfun(@plus,repmat(ic.x',1,n),T*N);
                xe=(xea(:))';
                ye=repmat(ic.y,1,n);
                yi=interp1extended(ic,xe,ye,xi,ic.method,ic.userFunctionHandle); 
             else
                if isXPeriodic
                    xi=mod(xi-xlm(1),T);
                end
                yi=interp1extended(ic,ic.x,ic.y,xi,ic.method,ic.userFunctionHandle);
             end
         end
         
         function setXLim(ic,XLim)
             % ic.setXLim(XLim) set new x limits in axes, XLim=[x_min  x_max]
             set(ic.axesHandle,'XLim',XLim);
         end
         
         function setYLim(ic,YLim)
             % ic.setYLim(YLim) set new y limits in axes, YLim=[y_min  y_max]
             set(ic.axesHandle,'YLim',YLim);
         end
         
         function setBoundary(ic,boundary)
             % ic.setBoundary(ic,boundary) 
             % if boundary=0 then no boundary (default)
             % if boundary=1 then set boundary to boundaryYLeft and boundaryYRight, if boundary=2 then periodic boundary
             ic.boundary=boundary;
             ic.redraw();
         end
         
         function MCode=generateMCode(ic,functionName,isXPeriodic)
             % MCode=ic.generateMCode(functionName,isXPeriodic) generates m-code for current settings for interpolation function
             % MCode is the text of the code as cell array of strings
             % if isXPeriodic=true then interpolation point xi fill be
             % shifted to x-axis limits as periodic function
             
%              xlm=get(ic.axesHandle,'XLim');
%              T=xlm(2)-xlm(1);
%              if strcmpi(ic.method,'delta')&&isXPeriodic
%                 mn=min(xi);
%                 mx=max(xi);
%                 Nmn=floor(mn/T);
%                 Nmx=floor(mx/T);
%                 N=Nmn:Nmx; % periods numbers
%                 n=Nmx-Nmn+1;
%                 xea=bsxfun(@plus,repmat(ic.x',1,n),T*N);
%                 xe=(xea(:))';
%                 ye=repmat(ic.y,1,n);
%                 yi=interp1extended(ic,xe,ye,xi,ic.method,ic.userFunctionHandle); 
%              else
%                 if isXPeriodic
%                     xi=mod(xi-xlm(1),T);
%                 end
%                 yi=interp1extended(ic,ic.x,ic.y,xi,ic.method,ic.userFunctionHandle);
%              end
             
             
             MCode=cell(0,1);
             MCode1=['function yi=' functionName '(xi)'];
             MCode=vertcat(MCode,MCode1);
             MCode1=['% autogenerated interpolation function ' datestr(now)];
             MCode=vertcat(MCode,MCode1);
             MCode1=['% by interactive_curve object'];
             MCode=vertcat(MCode,MCode1);
             if isXPeriodic&&(~strcmpi(ic.method,'delta'))
                 xlm=get(ic.axesHandle,'XLim');
                 T=xlm(2)-xlm(1);
                 MCode1=['xi=mod(xi-(' num2str(xlm(1),'%10.7e') '),' num2str(T,'%10.7e') ');'];
                 MCode=vertcat(MCode,MCode1);
             end
             
             if length(ic.x)<2
                 % yi=NaN(size(xi));
                 MCode1=['yi=NaN(size(xi));'];
                 MCode=vertcat(MCode,MCode1);
             else
                 if strcmpi(ic.method,'userdefined')
                     if ic.boundary==0
                         %yi=userFunctionHandle(x,y,xi);
                         MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         
                         fst=func2str(ic.userFunctionHandle); % to string
                         % example:
                         % fst='@(x,y,xi)(0.8*interp1(x,y,xi,'nearest')+0.2*interp1(x,y,xi,'spline'))'
                         if fst(1)=='@'
                             % anonymouse function
                             MCode1=['userFunctionHandle=' fst ';'];
                             MCode=vertcat(MCode,MCode1);
                             MCode1=['yi=userFunctionHandle(x,y,xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         else
                             % link to real function
                             % example:
                             % fst='my_interp' and there are my_interp.m file
                             MCode1=['yi=' fst '(x,y,xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         end
                     elseif ic.boundary==1 % zero boundary
                         %xlm=get(ic.axesHandle,'XLim'); 
                         %yi=userFunctionHandle([xlm(1) x xlm(2)],[ic.boundaryYLeft y ic.boundaryYRight],xi);
                         
                         xlm=get(ic.axesHandle,'XLim');
                         MCode1=['x=[' num2str(xlm(1),'%10.7e ') ' ' num2str(ic.x,'%10.7e ') ' ' num2str(xlm(2),'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         MCode1=['y=[' num2str(ic.boundaryYLeft,'%10.7e ') ' ' num2str(ic.y,'%10.7e ') ' ' num2str(ic.boundaryYRight,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         fst=func2str(ic.userFunctionHandle); % to string
                         if fst(1)=='@'
                             % anonymouse function
                             MCode1=['userFunctionHandle=' fst ';'];
                             MCode=vertcat(MCode,MCode1);
                             MCode1=['yi=userFunctionHandle(x,y,xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         else
                             % link to real function
                             MCode1=['yi=' fst '(x,y,xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         end
                     elseif ic.boundary==2 % periodic boundary
                         %xlm=get(ic.axesHandle,'XLim');
                         %T=xlm(2)-xlm(1);
                         %x5=[x-2*T  x-T  x  x+T  x+2*T];
                         %yi=userFunctionHandle(x5,[y y y y y],xi);
                         
                         xlm=get(ic.axesHandle,'XLim');
                         T=xlm(2)-xlm(1);
                         %x5=[x-2*T  x-T  x  x+T  x+2*T];
                         %yi=interp1(x5,[y y y y y],xi,method);
                         MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         MCode1=['x5=[' num2str(ic.x-2*T,'%10.7e ') ' ' num2str(ic.x-T,'%10.7e ') ' ' num2str(ic.x,'%10.7e ') ' ' num2str(ic.x+T,'%10.7e ') ' ' num2str(ic.x+2*T,'%10.7e ') '];'];
                         MCode=vertcat(MCode,MCode1);
                         %MCode1=['yi=interp1(x5,[y y y y y],xi,''' ic.method ''');']; 
                         %MCode=vertcat(MCode,MCode1);
                         fst=func2str(ic.userFunctionHandle); % to string
                         if fst(1)=='@'
                             % anonymouse function
                             MCode1=['userFunctionHandle=' fst ';'];
                             MCode=vertcat(MCode,MCode1);
                             MCode1=['yi=userFunctionHandle(x5,[y y y y y],xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         else
                             % link to real function
                             MCode1=['yi=' fst '(x5,[y y y y y],xi);']; 
                             MCode=vertcat(MCode,MCode1);
                         end
                     end
                     return;
                 end
                 
                if strcmpi(ic.method,'delta')
                    if isXPeriodic
                        % special case: periodic and delta
                        %                 mn=min(xi);
                        %                 mx=max(xi);
                        %                 Nmn=floor(mn/T);
                        %                 Nmx=floor(mx/T);
                        %                 N=Nmn:Nmx; % periods numbers
                        %                 n=Nmx-Nmn+1;
                        %                 xea=bsxfun(@plus,repmat(ic.x',1,n),T*N);
                        %                 xe=(xea(:))';
                        %                 ye=repmat(ic.y,1,n);
                        %                 yi=interp1extended(ic,xe,ye,xi,ic.method,ic.userFunctionHandle);
                        
                        MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                        MCode=vertcat(MCode,MCode1);

                        MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                        MCode=vertcat(MCode,MCode1);
                        
                        xlm=get(ic.axesHandle,'XLim');
                        T=xlm(2)-xlm(1);
                        MCode1=['T=' num2str(T,'%10.10e ') ';'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['mn=min(xi);'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['mx=max(xi);'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['Nmn=floor(mn/T);'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['Nmx=floor(mx/T);'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['N=Nmn:Nmx; % periods numbers'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['n=Nmx-Nmn+1;'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['xea=bsxfun(@plus,repmat(x'',1,n),T*N);'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['xe=(xea(:))'';'];
                        MCode=vertcat(MCode,MCode1);
                        MCode1=['ye=repmat(y,1,n);'];
                        MCode=vertcat(MCode,MCode1);
                        
                        MCode1=['ind=interp1(xi,1:length(xi),xe,''nearest'');'];
                        MCode=vertcat(MCode,MCode1);
                        %yi=zeros(size(xi));
                        MCode1=['yi=zeros(size(xi));'];
                        MCode=vertcat(MCode,MCode1);
                        %yi(ind(~isnan(ind)))=y(~isnan(ind));
                        MCode1=['yi(ind(~isnan(ind)))=ye(~isnan(ind));'];
                        MCode=vertcat(MCode,MCode1);
                        return;
                        
                    else
                        % in delta interpolation give same result indepedtently
                        % from boundary


                        MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                        MCode=vertcat(MCode,MCode1);

                        MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                        MCode=vertcat(MCode,MCode1);

                        %ind=interp1(xi,1:length(xi),x,'nearest'); % index of xi, length(x)=length(ind)=number of markers
                        MCode1=['ind=interp1(xi,1:length(xi),x,''nearest'');'];
                        MCode=vertcat(MCode,MCode1);
                        %yi=zeros(size(xi));
                        MCode1=['yi=zeros(size(xi));'];
                        MCode=vertcat(MCode,MCode1);
                        %yi(ind(~isnan(ind)))=y(~isnan(ind));
                        MCode1=['yi(ind(~isnan(ind)))=y(~isnan(ind));'];
                        MCode=vertcat(MCode,MCode1);
                        return;
                    end
                end

                % otherwise interp1:
                if ic.boundary==0
                    %yi=interp1(x,y,xi,method);
                    MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['yi=interp1(x,y,xi,''' ic.method ''');']; 
                    MCode=vertcat(MCode,MCode1);
                elseif ic.boundary==1 % zero boundary
                    xlm=get(ic.axesHandle,'XLim');
                    %yi=interp1([xlm(1) x xlm(2)],[ic.boundaryYLeft y ic.boundaryYRight],xi,method); 
                    MCode1=['x=[' num2str(xlm(1),'%10.7e ') ' ' num2str(ic.x,'%10.7e ') ' ' num2str(xlm(2),'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['y=[' num2str(ic.boundaryYLeft,'%10.7e ') ' ' num2str(ic.y,'%10.7e ') ' ' num2str(ic.boundaryYRight,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['yi=interp1(x,y,xi,''' ic.method ''');']; 
                    MCode=vertcat(MCode,MCode1);
                elseif ic.boundary==2 % periodic boundary
                    xlm=get(ic.axesHandle,'XLim');
                    T=xlm(2)-xlm(1);
                    %x5=[x-2*T  x-T  x  x+T  x+2*T];
                    %yi=interp1(x5,[y y y y y],xi,method);
                    MCode1=['x=[' num2str(ic.x,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['y=[' num2str(ic.y,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['x5=[' num2str(ic.x-2*T,'%10.7e ') ' ' num2str(ic.x-T,'%10.7e ') ' ' num2str(ic.x,'%10.7e ') ' ' num2str(ic.x+T,'%10.7e ') ' ' num2str(ic.x+2*T,'%10.7e ') '];'];
                    MCode=vertcat(MCode,MCode1);
                    MCode1=['yi=interp1(x5,[y y y y y],xi,''' ic.method ''');']; 
                    MCode=vertcat(MCode,MCode1);
                end
             end
         end
         
         function generateMFile(ic,filename,isXPeriodic)
             % MCode=ic.generateMFile(filename,isXPeriodic) generates m-file for current settings for interpolation function
             % if isXPeriodic=true then interpolation point xi fill be
             % shifted to x-axis limits as periodic function
             [pathstr, name, ext] = fileparts(filename);
             MCode=ic.generateMCode(name,isXPeriodic);
             fid = fopen(filename, 'w');
             for c=1:length(MCode)
                 fprintf(fid, '%s\n', MCode{c});
             end
             fclose(fid);
         end
         
         
         function setMarkersPositions(ic,markersX,markersY)
             % ic.setMarkersPositions(markersX,markersY)
             % set new positions for markers
             % if length(ic.markersHandles)~=length(markersX) then number
             % of markers will be changed
             
             NextPlot=get(ic.axesHandle,'NextPlot');
             set(ic.axesHandle,'NextPlot','add');
             
             if length(ic.markersHandles)==length(markersX)
                 % same number of markers
                 for mc=1:length(ic.markersHandles)
                     set(ic.markersHandles(mc),'XData',markersX(mc),'YData',markersY(mc));
                 end
                 ic.x=markersX;
                 ic.y=markersY;
             else
                 % different
                 
                 L0=length(ic.markersHandles);
                 
                 % plot new markers:
                 L=length(markersX);
                 
                     
                 
                 if L0==0
                      ic.markersHandles=zeros(1,L);
                      % plot new:
                      for mc=1:L
                        ic.markersHandles(mc)=plot(markersX(mc),markersY(mc),'ko','MarkerFaceColor','c','markersize',8,...
                            'parent',ic.axesHandle,'HitTest','on');
                        set(ic.markersHandles(mc),'ButtonDownFc',{@ic.button_down});
                      end
                 else
                     h=ic.markersHandles(1);
                     c=get(h,'MarkerFaceColor');
                     m=get(h,'Marker');
                     ms=get(h,'markersize');
                     ec=get(h,'MarkerEdgeColor');
                     ls=get(h,'LineStyle');
                     cl=get(h,'Color');
                     % delete all graphic markers from axes:
                     for mc=1:L0
                         delete(ic.markersHandles(mc));
                     end
                     ic.markersHandles=zeros(1,L);
                     % plot new:
                     for mc=1:L
                         
                         ic.markersHandles(mc)=plot(markersX(mc),markersY(mc),'MarkerFaceColor',c,'markersize',ms,'MarkerEdgeColor',ec,...
                             'LineStyle',ls,'marker',m,'Color',cl, 'parent',ic.axesHandle,'HitTest','on');                                
                         set(ic.markersHandles(mc),'ButtonDownFc',{@ic.button_down});
                     end
                 end
                 
                 ic.x=markersX;
                 ic.y=markersY;
                 ic.numberOfMarkers=length(ic.markersHandles);
                 
             end
             set(ic.axesHandle,'NextPlot',NextPlot);
             ic.redraw();
         end
                        
         function delete(ic)
         if 0    
             % ic.delete() delete interactive curve
             % delete interactive curve object makrers and line and empty callbacks in axes and figure
             
             % first run additionalDeleteFunctionHandle if exist:
             if ~isempty(ic.additionalDeleteFunctionHandle)
                 af=ic.additionalDeleteFunctionHandle;
                 af();
             end
             set(ic.figureHandle,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
             set(ic.axesHandle,'ButtonDownFcn','');
             % delete instance of class
             for c=1:length(ic.markersHandles)
                 delete(ic.markersHandles(c));
             end
             delete(ic.lineHandle);
         end
         end
        
     end
end