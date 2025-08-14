function [dFarthestDistance, adFarthestXYZ1, adFarthestXYZ2] = computeMaskFarthestPoint(imMask, atMetaData, bCentroid)
%function  [dFarthestDistance, adFarthestXYZ1, adFarthestXYZ2] = computeMaskFarthestPoint(imMask, atMetaData, bCentroid)
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

    dFarthestDistance = 0;
    adFarthestXYZ1    = [];
    adFarthestXYZ2    = []; 

    xPixelSize = atMetaData{1}.PixelSpacing(1);
    yPixelSize = atMetaData{1}.PixelSpacing(2);
    zPixelSize = computeSliceSpacing(atMetaData);
    
    if bCentroid == true

        stats = regionprops(bwlabeln(imMask));
    
        if ~isempty(stats) % Found some stats 
            for jj = numel(stats) % Compare all stats one to the other
                
                for kk=1:numel(stats)
    
                    if jj==kk
                        continue;
                    end
    
                    yxz1 = stats(jj).Centroid;
                    yxz2 = stats(kk).Centroid;
                              
                    yxz1Resized(1) = yxz1(1)*xPixelSize;
                    yxz1Resized(2) = yxz1(2)*yPixelSize;
                    yxz1Resized(3) = yxz1(3)*zPixelSize;
                                   
                    yxz2Resized(1) = yxz2(1)*xPixelSize;
                    yxz2Resized(2) = yxz2(2)*yPixelSize;
                    yxz2Resized(3) = yxz2(3)*zPixelSize;
                    
                    % Euclidean distance
        
                    dCurentDistance = sqrt((yxz1Resized(1)-yxz2Resized(1))^2 + (yxz1Resized(2)-yxz2Resized(2))^2 + (yxz1Resized(3)-yxz2Resized(3))^2);
        
                    if dCurentDistance > dFarthestDistance
                        dFarthestDistance = dCurentDistance;
            
                        adFarthestXYZ1 = yxz1;
                        adFarthestXYZ2 = yxz2;
                    end
                end
            end
        end
    else
        % % Find connected components in the binary mask
        % 
        % connComp = bwconncomp(imMask);
        % 
        % if connComp.NumObjects > 1 % Check if there are multiple regions
        %     dFarthestDistance = 0; % Initialize the farthest distance
        % 
        %     for jj = 1:connComp.NumObjects
        %         for kk = jj+1:connComp.NumObjects
        % 
        %             % Get the coordinates of all voxels in the regions
        %             [x1, y1, z1] = ind2sub(size(imMask), connComp.PixelIdxList{jj});
        %             [x2, y2, z2] = ind2sub(size(imMask), connComp.PixelIdxList{kk});
        % 
        %             % Calculate pairwise distances between all voxel pairs
        %             distances = sqrt((x1 - x2').^2 * xPixelSize^2 + (y1 - y2').^2 * yPixelSize^2 + (z1 - z2').^2 * zPixelSize^2);
        % 
        %             % Find the maximum distance within the regions
        %             maxDistance = max(distances(:));
        % 
        %             if maxDistance > dFarthestDistance
        %                 dFarthestDistance = maxDistance;
        %                 % Update the coordinates of the two farthest voxels
        %                 [maxRow, maxCol] = find(distances == maxDistance); % Find the indices of the farthest points
        %                 adFarthestXYZ1 = [y1(maxRow(1)), x1(maxRow(1)), z1(maxRow(1))];
        %                 adFarthestXYZ2 = [y2(maxCol(1)), x2(maxCol(1)), z2(maxCol(1))];
        %             end
        %         end
        %     end
        % end  
        
        % Find connected components in the binary mask
        connComp = bwconncomp(imMask);
        
        if connComp.NumObjects > 1
            dFarthestDistance = 0;  % Initialize the farthest distance
            
            % Precompute convex hull data for each connected component
            % (Store both the scaled coordinates and the original indices)
            regionData = struct('P',{},'P_hull',{},'orig_x',{},'orig_y',{},'orig_z',{},'hullIdx',{});
            for jj = 1:connComp.NumObjects
                % Get the voxel indices for the jth component
                [x_tmp, y_tmp, z_tmp] = ind2sub(size(imMask), connComp.PixelIdxList{jj});
                % Convert voxel coordinates to physical coordinates
                % Note: P is arranged as [x, y, z]
                P = [x_tmp * xPixelSize, y_tmp * yPixelSize, z_tmp * zPixelSize];
                % Compute convex hull if there are at least 4 points (needed for 3D)
                if size(P,1) >= 4
                    try
                        hullIdx = unique(convhulln(P));
                    catch
                        % If convex hull computation fails, use all points
                        hullIdx = 1:size(P,1);
                    end
                else
                    hullIdx = 1:size(P,1);
                end
                % Save data for this region
                regionData(jj).P = P;
                regionData(jj).P_hull = P(hullIdx,:);
                regionData(jj).orig_x = x_tmp;
                regionData(jj).orig_y = y_tmp;
                regionData(jj).orig_z = z_tmp;
                regionData(jj).hullIdx = hullIdx;
            end
            
            % Now, for each unique pair of connected components, compute the farthest distance
            for jj = 1:connComp.NumObjects
                for kk = jj+1:connComp.NumObjects
                    % Get convex hull points for the two regions
                    P1 = regionData(jj).P_hull;
                    P2 = regionData(kk).P_hull;
                    
                    % Compute pairwise distances between the hull vertices
                    D = pdist2(P1, P2);
                    
                    % Find the maximum distance and its indices in the distance matrix
                    [localMax, idx] = max(D(:));
                    if localMax > dFarthestDistance
                        dFarthestDistance = localMax;
                        [i1, i2] = ind2sub(size(D), idx);
                        
                        % Map back to the original voxel indices in the respective regions
                        origIdx1 = regionData(jj).hullIdx(i1);
                        origIdx2 = regionData(kk).hullIdx(i2);
                        
                        % Return the coordinates in the order [y, x, z]
                        adFarthestXYZ1 = [regionData(jj).orig_y(origIdx1), regionData(jj).orig_x(origIdx1), regionData(jj).orig_z(origIdx1)];
                        adFarthestXYZ2 = [regionData(kk).orig_y(origIdx2), regionData(kk).orig_x(origIdx2), regionData(kk).orig_z(origIdx2)];
                    end
                end
            end
        end

    end
end
