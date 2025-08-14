function plotRotatedRoiOnMip(axesPtr, im, iMipAngle)
%function plotRotatedRoiOnMip(axesPtr, im, iMipAngle)
%Processes and plots various types of regions of interest (ROIs) on maximum intensity projection (MIP) images by dynamically handling ROI shapes, extracting relevant image slices, rotating coordinates based on the viewing angle, and rendering the ROIs on the display axes with specific visual attributes.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

 
    % Only for 3D volumes
    if size(im,3) == 1
        return;
    end

    % Fetch current ROIs *and* any stored patch‐handles
    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    ptrPlot     = plotMipPtr('get');

    % If there are no ROIs, delete *all* existing patches and clear the pointer
    if isempty(atRoiInput)
        if ~isempty(ptrPlot)
            for k = 1:numel(ptrPlot)
                if isgraphics(ptrPlot{k})
                    delete(ptrPlot{k});
                end
            end
            plotMipPtr('set', {});    % clear out the stored handles
        end
        return;
    end

    % Number of ROIs now
    N = numel(atRoiInput);

    % --- synchronize the patch‐handle list to exactly N entries ---
    if isempty(ptrPlot)
        ptrPlot = cell(N,1);
    elseif numel(ptrPlot) < N
        ptrPlot(end+1:N) = {[]};
    elseif numel(ptrPlot) > N
        % delete any extras
        for k = N+1:numel(ptrPlot)
            if isgraphics(ptrPlot{k})
                delete(ptrPlot{k});
            end
        end
        ptrPlot = ptrPlot(1:N);
    end

    % Make sure there’s a valid patch object for each ROI
    for rr = 1:N
        if isempty(ptrPlot{rr}) || ~isgraphics(ptrPlot{rr})
            ptrPlot{rr} = patch(axesPtr, ...
                                'XData',     NaN, ...
                                'YData',     NaN, ...
                                'EdgeColor', 'none', ...
                                'FaceColor', 'none', ...
                                'Visible',   'off');
        end
    end

    % Show or hide based on UI setting
    if contourVisibilityRoiPanelValue('get')
        sVisible = 'on';
    else
        sVisible = 'off';
    end

    % Prepare axes for batch update
    wasHeld = ishold(axesPtr);
    set(axesPtr, 'NextPlot', 'add');

    % Precompute rotation about image center
    rotationAngle = 360 - ((iMipAngle - 1) * 11.25);
    theta         = deg2rad(rotationAngle);
    Rz            = [cos(theta), -sin(theta); sin(theta), cos(theta)];
    centerXY      = [size(im,2), size(im,1)]/2;
    alph          = mipFaceAlphaValue('get');

    % Loop over each ROI and update its patch
    for rr = 1:N
        currentRoi = atRoiInput{rr};

        % --- get 2D boundary vertices in its native view ---
        switch lower(currentRoi.Type)
            case {'images.roi.rectangle','images.roi.circle','images.roi.ellipse'}
                roiCoords2d = currentRoi.Vertices;
            otherwise
                roiCoords2d = currentRoi.Position;
        end

        % Map those 2D coords into 3D (X,Y,Z) based on which plane
        switch lower(currentRoi.Axe)
            case 'axes1'
                X = roiCoords2d(:,1);
                Y = currentRoi.SliceNb * ones(size(X));
                Z = roiCoords2d(:,2);
            case 'axes2'
                X = currentRoi.SliceNb * ones(size(roiCoords2d,1),1);
                Y = roiCoords2d(:,1);
                Z = roiCoords2d(:,2);
            case 'axes3'
                X = roiCoords2d(:,1);
                Y = roiCoords2d(:,2);
                Z = currentRoi.SliceNb * ones(size(X));
            otherwise
                continue;
        end

        % Rotate around the center
        ptsXY     = [X - centerXY(1), Y - centerXY(2)];
        fc        = (Rz * ptsXY')';
        rotX      = fc(:,1) + centerXY(1);
        rotY      = Z;

        % Apply to the patch‐object
        h = ptrPlot{rr};
        set(h, ...
            'XData',     rotX, ...
            'YData',     rotY, ...
            'EdgeColor', currentRoi.Color, ...
            'FaceColor', currentRoi.Color, ...
            'LineWidth', currentRoi.LineWidth, ...
            'EdgeAlpha', alph, ...
            'FaceAlpha', alph, ...
            'Visible',   sVisible);
    end

    % Restore axes state
    set(axesPtr, 'NextPlot', 'replacechildren');
    if ~wasHeld
        hold(axesPtr, 'off');
    end

    % Force a single redraw
    % drawnow limitrate;

    % Save back the updated list of handles
    plotMipPtr('set', ptrPlot);
end