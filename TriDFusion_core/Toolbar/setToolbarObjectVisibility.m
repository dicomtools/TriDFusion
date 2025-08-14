function setToolbarObjectVisibility(panelH, acMenu, sVisible)
%function setToolbarObjectVisibility(panelH, acMenu, sVisible)
%Set toolbar icon on\off and moved the remaining objects if needed.
%
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


    acHandlesToToggle = {};
    aOriginalSize = [];

    % Collect icons & separators

    for i = 1:numel(acMenu)

        hBtn = acMenu{i};

        if ishghandle(hBtn)

            acHandlesToToggle{end+1} = hBtn;
            aOriginalSize(end+1,:) = get(hBtn.Parent,'Position');

            ud = get(hBtn,'UserData');
            if isfield(ud,'separator')

                sepH = ud.separator;

                if ~isempty(sepH) && isscalar(sepH) && ishghandle(sepH)

                    acHandlesToToggle{end+1} = sepH;
                    aOriginalSize(end+1,:) = get(sepH,'Position');
                end
            end
        end
    end

    % Find all toolbar icons under the panel
    icons = findobj(panelH, 'Tag', 'toolbarIconBtn');
    
    axesWithIcons = unique( arrayfun(@(h) ancestor(h,'axes'), icons) );
    
    isVisibleAxes = arrayfun(@(ax) any(strcmpi({ax.Children.Visible}, 'on')), axesWithIcons);
    
    acCurrentObject = axesWithIcons(isVisibleAxes);

    % Toggle visibility

    for k = 1:numel(acHandlesToToggle)

        set(acHandlesToToggle{k}, 'Visible', sVisible);
    end

    % Shift right objects to the left

    if strcmpi(sVisible,'off')

        xMin  = min(aOriginalSize(:,1));
        xMax  = max(aOriginalSize(:,1) + aOriginalSize(:,3));
        spanW = xMax - xMin;

        % Disable separator at position 0;

        if xMin == 5
            spanW = spanW+10;
        end

        hArr = [ acHandlesToToggle{:} ];   
        
        % Detect which of those are images
        isImg = isgraphics(hArr, 'image');  % 1×10 logical
        
        % For images, skip their parent; for non-images, skip the handle itself
        imgParents    = arrayfun(@(h) h.Parent, hArr(isImg));
        nonImgHandles = hArr(~isImg);
        
        % Build one unique "skip" list
        skipList = unique([imgParents, nonImgHandles]);

        for c = panelH.Children(:)'
            
            if ismember(c, skipList)
                continue;
            end
        
            % only shift things with a Position
            if isprop(c,'Position')

                pOld = c.Position;

                % only shift children whose x is to the right of xMax
                if pOld(1) > xMax

                    xNew = pOld(1)-spanW;

                    % Disable separator at position 0;
                    if strcmpi(get(c,'Type'), 'uicontrol') && xNew == 0 
                        set(c, 'Visible', 'off');
                    end

                    c.Position = [xNew, pOld(2), pOld(3), pOld(4)];
                    % setappdata(c, 'OriginalSize',[pOld(1)-spanW, pOld(2), pOld(3), pOld(4)]);    
           
                    % Move it tooltip

                    if strcmp(get(c,'Type'),'axes')

                        hIcon = findobj(c,'Tag','toolbarIconBtn');

                        if ~isempty(hIcon)

                            setToolbarObjectTooltipPosition(panelH, hIcon);
                        end
                    end
                end
            end
        end
    else

        % Find all axes under the panel
        axesHandles = findobj(acCurrentObject, 'Type', 'axes');
        
        % Compute the right-most edge of each axes
        if isempty(axesHandles)
            rightMost = -inf;
        else
            % vertcat all Position vectors into an N×4 array
            allPos = vertcat(axesHandles.Position);  
            % position(:,1) is the x-origin, position(:,3) is the width
            rightMost = max(allPos(:,1) + allPos(:,3));
        end

        if isinf(rightMost)
            rightMost = 0;   % toolbar empty, start at margin
        end

        % Start X just 5px past that edge
        gap  = 5;
        xNext = rightMost + gap;

        % Place each objects menu handle in order, like addToolbarIcon

        for k = 1:numel(acHandlesToToggle)

            h = acHandlesToToggle{k};
            ud = get(h,'UserData');
            
            % Reposition the separator, if one was created
            if ~isempty(ud) 

                if isfield(ud,'separator') 

                    if ~isempty(ud.separator)

                        sep     = ud.separator;
                        origSep = getappdata(sep,'OriginalSize');  % [origX, origY, w, h]
                        if isprop(sep,'Position')

                            set(sep, 'Position', [xNext, origSep(2), origSep(3), origSep(4)]);
                            if xNext == 5 % Deactivate first separator
                                set(sep, 'Visible', 'off');
                            % else
                            %     set(sep, 'Visible', 'on');
                                xNext = 5;
                            else
                                xNext = xNext + origSep(3) + gap;
                            end
                            % setappdata(sep, 'OriginalSize',[xNext, origSep(2), origSep(3), origSep(4)]);    
                        end
                    end
                end
            end
            
            % Reposition the image button axes

            if strcmp(get(h,'Type'),'image')

                ax   = h.Parent;                
                orig = aOriginalSize(k,:);        

                if isprop(ax,'Position')

                    ax.Position = [ xNext, orig(2), orig(3), orig(4) ];
                    % setappdata(ax.Children, 'OriginalSize',[ xNext, orig(2), orig(3), orig(4)]);                       

                    xNext = xNext + orig(3) + gap;

                    if strcmp(get(ax,'Type'),'axes') % Set the tooltip

                        hIcon = findobj(ax,'Tag','toolbarIconBtn');

                        if ~isempty(hIcon)

                            setToolbarObjectTooltipPosition(panelH, hIcon);
                        end
                    end
                end
            end
        end
    end

    drawnow;
end