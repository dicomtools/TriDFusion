function toolbarIconHover()
%function toolbarIconHover()
%Hover effect for toolbar buttons. 
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

    persistent btns lastIdx lastCp lastIcon hoverTimer wasDown

    % Detect the instant the button goes down and cancel the timer once 
    isDown = strcmpi(windowButton('get'), 'down');
    if isDown
        if ~wasDown
            cancelTimer();
            wasDown = true;
        end
        return;
    end
    wasDown = false;   % reset once the button is up

    figH = fiMainWindowPtr('get');
    cp   = get(figH, 'CurrentPoint');

    % Only respond when the pointer actually moves 
    if ~isempty(lastCp) && all(cp == lastCp)
        return;
    end
    lastCp = cp;

    % (Re)discover toolbar icons if needed

    if isempty(btns) || ~all(ishandle(btns))

        btns     = findall(figH, 'Tag', 'toolbarIconBtn');
        lastIdx  = [];
        lastIcon = cell(1, numel(btns));

        if isempty(btns)
            return; 
        end
    end

    % Compute on-screen rectangles for each icon 
    posCell      = arrayfun(@(b)getpixelposition(b.Parent,true), btns, 'Uni', false);
    btnPositions = vertcat(posCell{:});

    % Hit-test current cursor position 
    currentIdx = find( ...
        cp(1) >= btnPositions(:,1) & cp(1) <= btnPositions(:,1)+btnPositions(:,3) & ...
        cp(2) >= btnPositions(:,2) & cp(2) <= btnPositions(:,2)+btnPositions(:,4), ...
    1);

    % If we entered a new icon (or moved off)

    if ~isequal(currentIdx, lastIdx)

        % Restore old icon & hide old tooltip

        if ~isempty(lastIdx) && ishandle(btns(lastIdx))

            udOld = btns(lastIdx).UserData;
            if ~udOld.isSelected && ~isempty(lastIcon{lastIdx})

                % Don't update a pressed or disabled bouton

                if ~isequal(btns(lastIdx).CData, btns(lastIdx).UserData.pressed) && ...
                   ~isequal(btns(lastIdx).CData, btns(lastIdx).UserData.disable)     

                    set(btns(lastIdx), 'CData', lastIcon{lastIdx});
                    udOld.tooltip.Visible = 'off';
                end
            end
        end

        % Cancel any pending tooltip-timer
        cancelTimer();

        % If over a new icon, swap in hover-icon & start fresh timer

        if ~isempty(currentIdx) && ishandle(btns(currentIdx))

            udNew = btns(currentIdx).UserData;
            if ~udNew.isSelected

                % Don't update a pressed or disabled bouton

                if ~isequal(btns(currentIdx).CData, btns(currentIdx).UserData.pressed) && ...
                   ~isequal(btns(currentIdx).CData, btns(currentIdx).UserData.disable)     
                    lastIcon{currentIdx} = get(btns(currentIdx), 'CData');
                    set(btns(currentIdx), 'CData', udNew.hover);
                end
            end

            % Schedule tooltip to appear in 1 s if still hovered

            tt = udNew.tooltip;
            hoverTimer = timer( ...
                'StartDelay'   , 1, ...
                'ExecutionMode', 'singleShot', ...
                'TimerFcn'     , {@showIfStillHovered, figH, btns(currentIdx), tt} ...
            );
            start(hoverTimer);
        end

        lastIdx = currentIdx;
    end

    % Nested helper to cancel the timer & hide last tooltip 

    function cancelTimer()

        if ~isempty(hoverTimer) && isvalid(hoverTimer)

            stop(hoverTimer);
            delete(hoverTimer);
        end

        if ~isempty(lastIdx) && ishandle(btns(lastIdx))
 
            ud = btns(lastIdx).UserData;
            ud.tooltip.Visible = 'off';
        end
    end
end

function showIfStillHovered(~,~, figH, hBtn, tt)

    % Timer callback: only show tooltip if still hovered & mouse is up
    if strcmpi(windowButton('get'), 'up')
        cp  = get(figH, 'CurrentPoint');
        pos = getpixelposition(hBtn.Parent, true);
        if cp(1) >= pos(1) && cp(1) <= pos(1)+pos(3) && ...
           cp(2) >= pos(2) && cp(2) <= pos(2)+pos(4)
            set(tt, 'Visible', 'on');
        end
    end
end