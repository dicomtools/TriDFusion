function aLogicalMask = roiTemplateToMask(tRoi, aSlice)
%function  aLogicalMask = roiTemplateToMask(tRoi, aSlice)
%Compute ROI logical mask from ROI template.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    aPosition = tRoi.Position;
    sType     = tRoi.Type;

    switch sType
        
        case lower('images.roi.line')
                       
            xValues = int32(aPosition(:,1));
            yValues = int32(aPosition(:,2));
            
            rectMask(xValues, yValues)= 1;
            aLogicalMask = logical(rectMask);
            
        case lower('images.roi.rectangle')

            rectMask = zeros(size(aSlice, 1), size(aSlice, 2)); % generate grid of ones

            top    = int32(aPosition(2));
            bottom = int32(aPosition(2)+aPosition(4));
            left   = int32(aPosition(1));
            right  = int32(aPosition(1)+aPosition(3));

            if bottom > size(aSlice, 1)
                bottom = size(aSlice, 1);
            end
            
            if right > size(aSlice, 2)
                right = size(aSlice, 2);
            end
            
            rectMask(top:bottom,left:right) = 1; % rectMask( Y values, X values)
            
            aLogicalMask = logical(rectMask);

        case lower('images.roi.ellipse')
            
            dRotationAngle = tRoi.RotationAngle;
            aSemiAxes      = tRoi.SemiAxes;
            
            phi  = dRotationAngle;

            xCenter = aPosition(1);
            yCenter = aPosition(2);
            xRadius = aSemiAxes(1);
            yRadius = aSemiAxes(2);
            theta = 0 : 0.01 : 2*pi;
            X_cen = [xCenter;yCenter];
            X = [xRadius * cos(theta);
                 yRadius * sin(theta)];
            R = [cos(phi) -sin(phi);
                 sin(phi) cos(phi)];
            Xr = R*X + X_cen;
            x = Xr(1,:);
            y = Xr(2,:);

            aLogicalMask = poly2mask(x(:),y(:), size(aSlice,1), size(aSlice,2));

        case lower('images.roi.circle')
            
            dRadius = tRoi.Radius;

            xCenter = aPosition(1);
            yCenter = aPosition(2);

            theta = 0 : 0.01 : 2*pi;
            radius = dRadius;
            x = radius * cos(theta) + xCenter;
            y = radius * sin(theta) + yCenter;

            aLogicalMask = poly2mask(x(:),y(:), size(aSlice,1), size(aSlice,2));

        otherwise

            aLogicalMask = poly2mask(aPosition(:,1),aPosition(:,2), size(aSlice,1), size(aSlice,2));
    end

end

