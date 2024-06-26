function dMaxDistance = computeVoiFarthestPoint(imMask, atMetaData)
%function  dMaxDistance = computeVoiFarthestPoint(imMask, atMetaData)
%Compute ROI farthest values from ROI object.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dMaxDistance = 0;

    xPixelSize = atMetaData{1}.PixelSpacing(1);
    yPixelSize = atMetaData{1}.PixelSpacing(2);
    zPixelSize = computeSliceSpacing(atMetaData);
        
    if xPixelSize == 0 || yPixelSize == 0 || zPixelSize == 0
        return;
    end

if 0
    [x, y, z] = ind2sub(size(imMask), find(imMask));

    dNumVoxels = numel(x);

    % If there is more than 10,000 voxels, don't execute the loop
    if dNumVoxels > 10000
        return;
    end

    % Iterate through all pairs of voxels to find the farthest distance

    for i = 1:dNumVoxels
        for j = i+1:dNumVoxels
            % Calculate the distance between the two voxels
            dCurrentdistance = sqrt((x(i) - x(j))^2 * xPixelSize^2 + ...
                                    (y(i) - y(j))^2 * yPixelSize^2 + ...
                                    (z(i) - z(j))^2 * zPixelSize^2);
            
            % Update maxDistance if this distance is greater
            if dCurrentdistance > dMaxDistance
                dMaxDistance = dCurrentdistance;
            end
        end
    end       
else
    % Find the coordinates of all non-zero voxels
    [nonZeroX, nonZeroY, nonZeroZ] = ind2sub(size(imMask), find(imMask));

    numNonZeroVoxels = numel(nonZeroX);
    if numNonZeroVoxels > 10000
        return;
    end

    % Iterate through the non-zero voxel coordinates
    for i = 1:numNonZeroVoxels
        x1 = nonZeroX(i);
        y1 = nonZeroY(i);
        z1 = nonZeroZ(i);

        % Calculate the Euclidean distance from voxel (x1, y1, z1) to all other non-zero voxels
        distances  = sqrt((x1 - nonZeroX).^2 * xPixelSize^2 + ...
                          (y1 - nonZeroY).^2 * yPixelSize^2 + ...
                          (z1 - nonZeroZ).^2 * zPixelSize^2);

        % Find the maximum distance in the current iteration
        maxDistance  = max(distances);
        dMaxDistance = max(dMaxDistance, maxDistance);

    end    
end
 
end
