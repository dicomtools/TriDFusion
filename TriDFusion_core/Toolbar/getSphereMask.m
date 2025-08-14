function aSphereMask = getSphereMask(aDicomBuffer, xPixelOffset, yPixelOffset, zPixelOffset, dRadius,xPixel, yPixel, zPixel)
%function aSphereMask = getSphereMask(aDicomBuffer, xPixelOffset, yPixelOffset, zPixelOffset, dRadius,xPixel, yPixel, zPixel)
%Create a 3D shere mask.
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
    % 
    % % Generate the meshgrid 
    % 
    % [px, py, pz] = meshgrid(1:size(aDicomBuffer,2), 1:size(aDicomBuffer,1), 1:size(aDicomBuffer,3));
    % 
    % px = px * xPixel; % Scale by x pixel size
    % py = py * yPixel; % Scale by y pixel size
    % pz = pz * zPixel; % Scale by z pixel size
    % 
    % % Define the center of the sphere 
    % 
    % xc = xPixelOffset * xPixel; 
    % yc = yPixelOffset * yPixel; 
    % zc = zPixelOffset * zPixel;
    % 
    % % Create the sphere mask
    % 
    % aSphereMask = (px - xc).^2 + (py - yc).^2 + (pz - zc).^2 <= (dRadius)^2;
    % Volume dimensions
    % Volume dimensions
 % Volume dimensions
    % Volume dimensions
    [H, W, D] = size(aDicomBuffer);
    aSphereMask = false(H, W, D);

    % Convert voxel radius to physical radius (mm)
    radius_mm = dRadius * xPixel;
    radius2 = radius_mm^2;

    % Physical coordinates of voxel centers (mm)
    [X, Y] = meshgrid(((1:W) - 0.5) * xPixel, ((1:H) - 0.5) * yPixel);
    xc = (xPixelOffset - 0.5) * xPixel;
    yc = (yPixelOffset - 0.5) * yPixel;

    % Slice center positions (mm)
    z_centers = ((1:D) - 0.5) * zPixel;
    zc = (zPixelOffset - 0.5) * zPixel;

    % Loop over slices
    for k = 1:D
        % squared distance along Z between slice center and sphere center
        dz2 = (z_centers(k) - zc)^2;
        if dz2 > radius2
            continue;
        end
        % squared in-plane radius for this slice
        r_xy2 = radius2 - dz2;
        % build mask for this slice
        aSphereMask(:,:,k) = ((X - xc).^2 + (Y - yc).^2 <= r_xy2);
    end
end
