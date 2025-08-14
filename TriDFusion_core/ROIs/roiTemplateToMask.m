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
    
    USE_VERTICES = false;

    aPosition = tRoi.Position;
    sType     = tRoi.Type;

    switch lower(sType)
        
        case 'images.roi.line'
                       
            % Create a mask with the same size as aSlice
            rectMask = zeros(size(aSlice));  
            
            % Assuming aPosition(:,1) is x (columns) and aPosition(:,2) is y (rows)
            xValues = int32(aPosition(:,1));  
            yValues = int32(aPosition(:,2));
            
            % Use the correct indexing order: (row, column) = (y, x)
            rectMask(yValues, xValues) = 1;  
            
            % Convert the mask to a logical array
            aLogicalMask = logical(rectMask);
            
        case 'images.roi.rectangle'

%            rectMask = zeros(size(aSlice, 1), size(aSlice, 2)); % generate grid of ones

%            top    = int32(aPosition(2));
%            bottom = int32(aPosition(2)+aPosition(4));
%            left   = int32(aPosition(1));
%            right  = int32(aPosition(1)+aPosition(3));

%            if bottom > size(aSlice, 1)
%                bottom = size(aSlice, 1);
%            end
            
%            if right > size(aSlice, 2)
%                right = size(aSlice, 2);
%            end
            
%            rectMask(top:bottom,left:right) = 1; % rectMask( Y values, X values)
            
%            aLogicalMask = logical(rectMask);



        if USE_VERTICES == true

            xy = tRoi.Vertices;
            aLogicalMask = poly2mask(xy(:, 1), xy(:, 2), size(aSlice,1), size(aSlice,2));
        else
            dRotation = tRoi.RotationAngle;  % Rotation angle in degrees
            
            % Step 1: Apply rotation (if any)
            
            if dRotation ~= 0 

                theta = deg2rad(dRotation); % Rotation in degrees
                
                % Rotation matrices 
                R = [cos(theta), -sin(theta);
                     sin(theta),  cos(theta)];
                
                aCoords = tRoi.Position(:, 1:2); % Extract X, Y coordinates
                
                aCenter = [size(aSlice, 1)/2, size(aSlice, 2)/2];     
        
                aTranslatedCoords = aCoords - aCenter; % Translate points to align image center with origin
                
                aRotatedCoords = (R * aTranslatedCoords')'; % Apply the rotation matrix
                
                atRoiInput{tt}.Position(:, 1:2) = aRotatedCoords + aCenter; % Translate points back to original position     
            end

            aCorner1 = [tRoi.Position(1), tRoi.Position(2)];  
            dWidth   = tRoi.Position(3);
            dHeight  = tRoi.Position(4);

            % Generate the coordinates of the four corners

            aCorner2 = [aCorner1(1), aCorner1(2) + dHeight];           % [x1, y2]
            aCorner3 = [aCorner1(1) + dWidth, aCorner1(2) + dHeight];  % [x2, y2]
            aCorner4 = [aCorner1(1) + dWidth, aCorner1(2)];            % [x2, y1]
            
            % Combine all corners into one variable
            xy = [aCorner1; aCorner2; aCorner3; aCorner4];
            
            aLogicalMask = poly2mask(xy(:,1), xy(:,2), size(aSlice, 1), size(aSlice, 2));    

        end

        case 'images.roi.ellipse'
            
%            dRotationAngle = tRoi.RotationAngle+270;
%            aSemiAxes      = tRoi.SemiAxes;
            
%            phi  = dRotationAngle;

%            xCenter = aPosition(1);
%            yCenter = aPosition(2);
%            xRadius = aSemiAxes(1);
%            yRadius = aSemiAxes(2);
%            theta = 0 : 0.01 : 2*pi;
%            X_cen = [xCenter;yCenter];
%            X = [xRadius * cos(theta);
%                 yRadius * sin(theta)];
%            R = [cos(phi) -sin(phi);
%                 sin(phi) cos(phi)];
%            Xr = R*X + X_cen;
%            x = Xr(1,:);
%            y = Xr(2,:);

        if USE_VERTICES == true

            xy = tRoi.Vertices;
            aLogicalMask = poly2mask(xy(:, 1), xy(:, 2), size(aSlice,1), size(aSlice,2));
        else

            aCenter  = tRoi.Position;      % [x, y]
            semiAxes = tRoi.SemiAxes;      % [a, b]
            rotation = tRoi.RotationAngle; % Angle in degrees
            
            aImgSize = [size(aSlice, 1), size(aSlice, 2)]; % [rows, cols]
            
            theta = linspace(0, 2*pi, 360); % 360 points around the ellipse
            x = semiAxes(1) * cos(theta);   % Semi-major axis scaling
            y = semiAxes(2) * sin(theta);   % Semi-minor axis scaling
            
            dRotationRad = deg2rad(-rotation); % Convert degrees to radians
            R = [cos(dRotationRad), -sin(dRotationRad); sin(dRotationRad), cos(dRotationRad)];
            aRotatedPoints = R * [x; y];      % Rotate points
            
            % Translate to the center position
            xEllipse = aRotatedPoints(1, :) + aCenter(1); % X-coordinates of the ellipse
            yEllipse = aRotatedPoints(2, :) + aCenter(2); % Y-coordinates of the ellipse
            
            % Generate the logical mask
            aLogicalMask = poly2mask(xEllipse, yEllipse, aImgSize(1), aImgSize(2));    
        end
%            aLogicalMask = poly2mask(x(:),y(:), size(aSlice,1), size(aSlice,2));
     
                       
        case 'images.roi.circle'
            
%            dRadius = tRoi.Radius;

%            xCenter = aPosition(1);
%            yCenter = aPosition(2);

%            theta = 0 : 0.01 : 2*pi;
%            radius = dRadius;
%            x = radius * cos(theta) + xCenter;
%            y = radius * sin(theta) + yCenter;

%            aLogicalMask = poly2mask(x(:),y(:), size(aSlice,1), size(aSlice,2));   



        if USE_VERTICES == true

            xy = tRoi.Vertices;
            aLogicalMask = poly2mask(xy(:, 1), xy(:, 2), size(aSlice,1), size(aSlice,2));
        else
            aCenter = tRoi.Position;        % [x, y]
            dRadius = tRoi.Radius;          % Radius of the circle
            
            aImgSize = [size(aSlice, 1), size(aSlice, 2)]; % [rows, cols]
            
            theta = linspace(0, 2*pi, 360); % 360 points around the circle
            xCircle = dRadius * cos(theta) + aCenter(1); % X-coordinates of the circle
            yCircle = dRadius * sin(theta) + aCenter(2); % Y-coordinates of the circle
            
            aLogicalMask = poly2mask(xCircle, yCircle, aImgSize(1), aImgSize(2));    
        end
                                                
        otherwise

            aLogicalMask = poly2mask(aPosition(:,1),aPosition(:,2), size(aSlice,1), size(aSlice,2));
   
    end
end

