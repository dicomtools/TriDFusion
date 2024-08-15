function closestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask)
%function closestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask)
%From an annoted mask, get a VOI closest index.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Get the unique values in the annotated mask excluding 0
    uniqueValues = unique(aAnnotatedMask(aAnnotatedMask > 0));

    % Find non-zero indices in imVoiMask
    [rows, cols, slices] = ind2sub(size(imVoiMask), find(imVoiMask > 0));

    % Initialize the count array for the number of points closest to each mask
    countClosestPoints = zeros(length(uniqueValues), 1);
    
    % Create a cell array to store the coordinates for each unique zone
    maskCoordinates = cell(length(uniqueValues), 1);
    
    % Iterate over each unique zone in the annotated mask to gather coordinates
    for i = 1:length(uniqueValues)
        % Find indices of the current zone in aAnnotatedMask
        zoneIndices = find(aAnnotatedMask == uniqueValues(i));

        % Get coordinates of the points in the current zone
        [zoneRows, zoneCols, zoneSlices] = ind2sub(size(aAnnotatedMask), zoneIndices);

        % Store the coordinates in the cell array
        maskCoordinates{i} = [zoneRows, zoneCols, zoneSlices];
    end
    
    % Iterate over each point in imVoiMask
    for j = 1:length(rows)
        voiPoint = [rows(j), cols(j), slices(j)];
        
        % Initialize the minimum distance and index for the current point
        minDistance = inf;
        closestZoneIndex = -1;
        
        % Check the distance to each mask zone
        for i = 1:length(uniqueValues)
            % Get the coordinates of the current mask zone
            maskPoints = maskCoordinates{i};
            
            % Compute distances to all points in the current mask zone
            distances = sqrt(sum((maskPoints - voiPoint).^2, 2));
            
            % Find the minimum distance to the current mask zone
            [currentMinDistance, ~] = min(distances);
            
            % Update the closest zone if the current zone is closer
            if currentMinDistance < minDistance
                minDistance = currentMinDistance;
                closestZoneIndex = i;
            end
        end
        
        % Increment the count for the closest mask zone
        countClosestPoints(closestZoneIndex) = countClosestPoints(closestZoneIndex) + 1;
    end
    
    % Find the mask index with the maximum count of closest points
    [~, maxCountIndex] = max(countClosestPoints);
    closestMaskIndex = uniqueValues(maxCountIndex);
end