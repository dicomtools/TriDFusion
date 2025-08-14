function multiFrame(mPlay)
%function multiFrame(mPlay)
%Play 2D Frames.
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
               
    persistent t

    % Get selected DICOM series offset
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    % Check if data is 3D (must have more than 1 slice)
    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume');
        multiFramePlayback('set', false);

        icon = get(mPlay, 'UserData');
        set(mPlay, 'CData', icon.default);
        
        set(uiSeriesPtr('get'), 'Enable', 'on');

        % Cleanup existing timer if it exists
        if ~isempty(t) && isvalid(t)
            stop(t); delete(t);
            t = [];
        end
        return;
    end

    % Toggle playback behavior
    if multiFramePlayback('get')

        % Kill old timer if valid
        if ~isempty(t) && isvalid(t)
            stop(t); delete(t);
        end

        % Create a new timer
        t = timer(...
            'Name', 'multiFramePlayer', ...
            'ExecutionMode', 'fixedSpacing', ...
            'Period', multiFrameSpeed('get'), ...
            'TimerFcn', @timerCallback);

        start(t);
    else
        % If flag turned off, stop and delete existing timer
        if ~isempty(t) && isvalid(t)
            stop(t); delete(t);
            t = [];
        end
    end

    % Nested timer callback (has access to persistent `t`)
    function timerCallback(~, ~)


    % Check for playback off

        if ~multiFramePlayback('get')
            if ~isempty(t) && isvalid(t)
                stop(t); delete(t); t = [];
            end
            return;
        end
    
        % Dynamic speed check 
        currentPeriod = t.Period;
        newPeriod = multiFrameSpeed('get');
    
        if abs(currentPeriod - newPeriod) > eps
            % Timer speed changed, so restart timer with new period
            stop(t);
            t.Period = newPeriod;
            start(t);
            return;  % Avoid double-frame advance in the same tick
        end

        % Check active view
        chkCor = chkUiCorWindowSelectedPtr('get');
        chkSag = chkUiSagWindowSelectedPtr('get');
        chkTra = chkUiTraWindowSelectedPtr('get');

        vsplashOn   = isVsplash('get');
        vsplashView = vSplahView('get');

        % Coronal
        if (vsplashOn && strcmpi(vsplashView, 'coronal')) || ...
           (~isempty(chkCor) && get(chkCor, 'Value'))

            dLast = size(dicomBuffer('get'), 1);
            dCur = sliceNumber('get', 'coronal');
            dCur = mod(dCur, dLast) + 1;

            set(uiSliderCorPtr('get'), 'Value', dCur);
            sliderCorCallback();

        % Sagittal
        elseif (vsplashOn && strcmpi(vsplashView, 'sagittal')) || ...
               (~isempty(chkSag) && get(chkSag, 'Value'))

            dLast = size(dicomBuffer('get'), 2);
            dCur = sliceNumber('get', 'sagittal');
            dCur = mod(dCur, dLast) + 1;

            set(uiSliderSagPtr('get'), 'Value', dCur);
            sliderSagCallback();

        % Axial
        elseif (vsplashOn && strcmpi(vsplashView, 'axial')) || ...
               (~isempty(chkTra) && get(chkTra, 'Value'))

            dLast = size(dicomBuffer('get'), 3);
            dCur = sliceNumber('get', 'axial') - 1;

            if dCur < 1
                dCur = dLast;
            end

            set(uiSliderTraPtr('get'), 'Value', dLast - dCur + 1);
            sliderTraCallback();

        % MIP
        else
            if ~vsplashOn
                iVal = mipAngle('get') + 1;
                if iVal > 32, iVal = 1; end
                set(uiSliderMipPtr('get'), 'Value', iVal);
                sliderMipCallback();
            end
        end
    end
end