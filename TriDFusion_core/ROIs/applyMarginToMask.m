function a3DLogicalMaskMargin = applyMarginToMask(a3DLogicalMask, xVoxelSize, yVoxelSize, zVoxelSize, dMarginSizeX, dMarginSizeY, dMarginSizeZ)
% function a3DLogicalMaskMargin = applyMarginToMask(a3DLogicalMask, xVoxelSize, yVoxelSize, zVoxelSize, dMarginSizeX, dMarginSizeY, dMarginSizeZ)
% applyMarginToMask dilates a 3D mask using an ellipsoidal structuring element.
%
%   Inputs:
%       a3DLogicalMask - A 3D logical array representing the original mask.
%       xVoxelSize     - The voxel size along the x-dimension (physical units).
%       yVoxelSize     - The voxel size along the y-dimension (physical units).
%       zVoxelSize     - The voxel size along the z-dimension (physical units).
%       dMarginSizeX    - The desired margin size (in the same physical units as the voxel sizes).
%       dMarginSizeY    - The desired margin size (in the same physical units as the voxel sizes).
%       dMarginSizeZ    - The desired margin size (in the same physical units as the voxel sizes).
%
%   Output:
%       a3DLogicalMaskMargin - The dilated 3D mask with the margin applied.
%
%   The function computes the required margin in voxel units, creates a 3D ellipsoidal
%   structuring element based on the physical dimensions, and dilates the mask using imdilate.
%
%   Note: imdilate requires the Image Processing Toolbox.
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

    % Compute physical radii in voxels
    rx = dMarginSizeX / xVoxelSize;
    ry = dMarginSizeY / yVoxelSize;
    rz = dMarginSizeZ / zVoxelSize;

    % Structuring element half‐sizes
    bx = ceil(rx);
    by = ceil(ry);
    bz = ceil(rz);

    % Build ellipsoid SE
    [gY,gX,gZ] = ndgrid(-by:by, -bx:bx, -bz:bz);
    se = (gX./rx).^2 + (gY./ry).^2 + (gZ./rz).^2 <= 1;

    % Pad amount
    padAmt = [by, bx, bz];

    % Find connected components once
    cc = bwconncomp(a3DLogicalMask, 26);

    % Dilate each component in its own padded world
    a3DLogicalMaskMargin = false(size(a3DLogicalMask));
    for k = 1:cc.NumObjects
        tmp = false(size(a3DLogicalMask));
        tmp(cc.PixelIdxList{k}) = true;

        % pad → dilate → crop
        p = padarray(tmp, padAmt, false, 'both');
        d = imdilate(p, se);
        c = d( padAmt(1)+1 : end-padAmt(1), ...
               padAmt(2)+1 : end-padAmt(2), ...
               padAmt(3)+1 : end-padAmt(3) );

        a3DLogicalMaskMargin = a3DLogicalMaskMargin | c;
    end

    % % Compute centroids of original vs. dilated masks
    % statsOrig = regionprops3(a3DLogicalMask,       'Centroid');
    % statsDil  = regionprops3(a3DLogicalMaskMargin, 'Centroid');
    % 
    % % Average of 1 object
    % cOrig = statsOrig.Centroid(1,:);  
    % cDil  = statsDil.Centroid(1,:);
    % 
    % shiftVox  = round(cDil - cOrig);    % [Y X Z] shift
    % 
    % % Shift it back the opposite way
    % %  circshift takes [rows,cols,pages] = [dY, dX, dZ]
    % a3DLogicalMaskMargin = circshift( ...
    %     a3DLogicalMaskMargin, -shiftVox );

end