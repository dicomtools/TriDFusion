function C = makeIcon(iconFile, d, bg, dimFactor)
%function C = makeIcon(iconFile, d, bg, dimFactor))
% Reads an image file (indexed, grayscale, or RGB), applies alpha blending
% over the panel background, resizes to [d d], clamps and fills NaNs.
%
%   hBtn = addToolbarIcon(panelH, iconFile, pressedIconFile, tooltip, callbackFcn)
%   auto–detects indexed/grayscale/truecolor, reads alpha if any,
%   composites transparent areas onto the panel background color,
%   and lays out buttons left-to-right.
%
%   hBtn = addToolbarIcon(...,'Separator',true) adds a 1px separator.
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

    if nargin < 4
        dimFactor = 1; % default: no dimming
    end

    [A, map, alpha] = imread(iconFile);

    % Convert to RGB
    if ~isempty(map)
        rgb = ind2rgb(A, map);
    elseif ismatrix(A)
        g = im2double(A);
        rgb = repmat(g, [1 1 3]);
    elseif ndims(A) == 3
        rgb = im2double(A);
    else
        warning('Unsupported image format: %s', iconFile);
        C = [];
        return;
    end

    % Alpha mask
    if exist('alpha', 'var') && ~isempty(alpha)
        a = im2double(alpha);
    else
        a = ones(size(rgb,1), size(rgb,2));  % fully opaque
    end

    % Resize
    rgb = imresize(rgb, d);
    a   = imresize(a,   d);

    % Dimming only the visible (non-transparent) parts
    % dimFactor = 0.5 dims visible parts by 50%, leaves transparent unchanged
    for c = 1:3
        rgb(:,:,c) = rgb(:,:,c) .* (dimFactor + (1 - dimFactor) * (1 - a));
    end

    % Composite over background
    C = a .* rgb + (1 - a) .* reshape(bg, 1, 1, 3);

    % Fill NaNs
    nanMask = isnan(C(:,:,1));
    for c = 1:3
        plane = C(:,:,c);
        plane(nanMask) = bg(c);
        C(:,:,c) = plane;
    end

    % Clamp to [0,1]
    C = min(max(C, 0), 1);

    % Check size
    assert(ndims(C)==3 && size(C,3)==3, ...
        'CData must be M×N×3—check your input image.');

end