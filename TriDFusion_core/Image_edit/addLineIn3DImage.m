function aImage = addLineIn3DImage(aImage, xyz1, xyz2, dLineWidth)
%function aImage = addLineIn3DImage(aImage, xyz1, xyz2, dLineWidth)
%Add a line, in a 3D image, from xyz start and coordinates.
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

    x1 = xyz1(1);
    y1 = xyz1(2);
    z1 = xyz1(3);
    
    x2 = xyz2(1);
    y2 = xyz2(2);
    z2 = xyz2(3);
    
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    dz = abs(z2 - z1);
    
    % Determine the direction of the line
    
    sx = sign(x2 - x1);
    sy = sign(y2 - y1);
    sz = sign(z2 - z1);
    
    % Determine the increments for each axis
    
    if dx >= max(dy, dz)
        yi = dy / dx;
        zi = dz / dx;
        xi = 1;
    elseif dy >= max(dx, dz)
        xi = dx / dy;
        zi = dz / dy;
        yi = 1;
    else
        xi = dx / dz;
        yi = dy / dz;
        zi = 1;
    end
    
    x = x1;
    y = y1;
    z = z1;

    % Add line
  
    while (sx > 0 && x <= x2) || (sx < 0 && x >= x2) || ...
          (sy > 0 && y <= y2) || (sy < 0 && y >= y2) || ...
          (sz > 0 && z <= z2) || (sz < 0 && z >= z2)
    
        for i = -floor(dLineWidth/2) : floor(dLineWidth/2)
            for j = -floor(dLineWidth/2) : floor(dLineWidth/2)
                for k = -floor(dLineWidth/2) : floor(dLineWidth/2)
                    aImage(max(1, round(y)+i), max(1, round(x)+j), max(1, round(z)+k)) = 1;
                end
            end
        end
    
        x = x + sx * xi;
        y = y + sy * yi;
        z = z + sz * zi;
    end
end