function [dFarthestDistance, adFarthestXYZ1, adFarthestXYZ2] = computeMaskFarthestPoint(imMask, atMetaData)
%function  [dFarthestDistance, adFarthestXYZ1, adFarthestXYZ2] = computeMaskFarthestPoint(imMask, atMetaData)
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
end
