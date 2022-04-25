function tPointsComputed = computeRoiFarthestPoint(imRoi, atSliceMeta, atRoi, bPlotLine, bPlotText)
%function  tPointsComputed = computeRoiFarthestPoint(imRoi, atSliceMeta, atRoi, bPlotLine, bPlotText)
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

    tPointsComputed = []; 
    isRoiValid = true;

    bFoundMaxDistance = false;

    if ~strcmpi(atRoi.Type, 'images.roi.line')
        try
            if size(imRoi, 3) == 1 
                if strcmpi(atRoi.Axe, 'Axe')
                    imCData = imRoi(:,:);
               end
            else
                switch(lower(atRoi.Axe))
                    case lower( 'Axes1')
                    imCData = permute(imRoi(atRoi.SliceNb,:,:), [3 2 1]);

                    case lower( 'Axes2')                   
                    imCData = permute(imRoi(:,atRoi.SliceNb,:), [3 1 2]) ;

                    case lower( 'Axes3')                   
                    imCData  = imRoi(:,:,atRoi.SliceNb);  
                end
            end       

            % Binary Image
%            aBinaryImage = createMask(atRoi.Object, imCData);                                
            aBinaryImage = roiTemplateToMask(atRoi, imCData);

            % Dimensions of the image.          
            [~, columns, ~] = size(aBinaryImage);                

            if strcmpi(atRoi.Type, 'images.roi.freehand') || ...
               strcmpi(atRoi.Type, 'images.roi.assistedfreehand') || ...
               strcmpi(atRoi.Type, 'images.roi.polygon')

                % Plot the borders of all the coins on the original grayscale image using ROI coordinates.
                x = atRoi.Position(:, 1); % x = columns.
                y = atRoi.Position(:, 2); % y = rows.
            else
                boundaries = bwboundaries(aBinaryImage, 'noholes', 8);
                if ~isempty(boundaries)
                    thisBoundary = boundaries{1};

                    x = thisBoundary(:, 2); % x = columns.
                    y = thisBoundary(:, 1); % y = rows.
                else
                    isRoiValid = false;
                end
            end

            if isRoiValid == true

                % Find which two boundary points are farthest from each other.
                maxDistance = -inf;
                for k = 1 : length(x)
                    distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
                    [thisMaxDistance, indexOfMaxDistance] = max(distances);
                    if thisMaxDistance > maxDistance
                        maxDistance = thisMaxDistance;
                        longestIndex1 = k;
                        longestIndex2 = indexOfMaxDistance;

                        bFoundMaxDistance = true;
                    end
                end

                if bFoundMaxDistance == true

                    % Find the midpoint of the line.
                    xMidPoint = mean([x(longestIndex1), x(longestIndex2)]);
                    yMidPoint = mean([y(longestIndex1), y(longestIndex2)]);
                    longSlope = (y(longestIndex1) - y(longestIndex2)) / (x(longestIndex1) - x(longestIndex2));
                    perpendicularSlope = -1/longSlope;

                    % Use point slope formula (y-ym) = slope * (x - xm) to get points
                    y1 = perpendicularSlope * (1 - xMidPoint) + yMidPoint;
                    y2 = perpendicularSlope * (columns - xMidPoint) + yMidPoint;

                    if ~isnan(y1) && ~isnan(y2) % ROI is valid

                        % Get the profile perpendicular to the midpoint so we can find out when if first enters and last leaves the object.
                        [cxMax, cyMax, cMax] = improfile(aBinaryImage, [1, columns], [y1, y2]);

                        % Get rid of NAN's that occur when the line's endpoints go above or below the image.
                        cMax(isnan(cMax)) = 0;
                        perpendicularIndex1 = find(cMax, 1, 'first');
                        perpendicularIndex2 = find(cMax, 1, 'last');

                        if ~isempty(perpendicularIndex1) && ... % Find a perpendicular
                           ~isempty(perpendicularIndex2)

                            if bPlotLine == true 
                                sLineVisible = 'on';
                            else
                                sLineVisible = 'off';
                            end

                            lXY = line(atRoi.Object.Parent, [x(longestIndex1), x(longestIndex2)], [y(longestIndex1), y(longestIndex2)], 'Color', 'r', 'LineWidth', 1, 'Visible', sLineVisible);	
                            lCY = line(atRoi.Object.Parent, [cxMax(perpendicularIndex1), cxMax(perpendicularIndex2)], [cyMax(perpendicularIndex1), cyMax(perpendicularIndex2)], 'Color', 'm', 'LineWidth', 1, 'Visible', sLineVisible);

                            tPointsComputed.MaxXY.Line = lXY;
                            tPointsComputed.MaxCY.Line = lCY;

                            if is3DEngine('get') == true

                                if size(imRoi, 3) == 1 
                                    if strcmpi(atRoi.Axe, 'Axe')
                                        imPtr  = imAxePtr ('get', [], get(uiSeriesPtr('get'), 'Value') );
                                   end
                                else
                                    switch(lower(atRoi.Axe))
                                        case lower( 'Axes1')                        
                                            imPtr  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value') );

                                        case lower( 'Axes2')                   
                                            imPtr = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value') );

                                        case lower( 'Axes3')                   
                                            imPtr = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value') ); 
                                    end
                                end

                                lXY.ZData = [max(max(get(imPtr,'Zdata'))) max(max(get(imPtr,'Zdata')))];
                                lCY.ZData = [max(max(get(imPtr,'Zdata'))) max(max(get(imPtr,'Zdata')))];
                            end    

                            % Compute XY distance in mm

                            roiObject.Position(1,1) = x(longestIndex1);
                            roiObject.Position(1,2) = y(longestIndex1);

                            roiObject.Position(2,1) = x(longestIndex2);
                            roiObject.Position(2,2) = y(longestIndex2);

                            dXYLength = computeLineLength(atSliceMeta, atRoi.Axe, roiObject);
                            tPointsComputed.MaxXY.Length = dXYLength;                    

                            % Compute CY distance in mm

                            roiObject.Position(1,1) = cxMax(perpendicularIndex1);
                            roiObject.Position(1,2) = cyMax(perpendicularIndex1);

                            roiObject.Position(2,1) = cxMax(perpendicularIndex2);
                            roiObject.Position(2,2) = cyMax(perpendicularIndex2);

                            dCYLength = computeLineLength(atSliceMeta, atRoi.Axe, roiObject);
                            tPointsComputed.MaxCY.Length = dCYLength;                    

                            if bPlotText == true  
                                sTextVisible = 'on';
                            else
                                sTextVisible = 'off';
                            end

                            tXY = text(atRoi.Object.Parent, x(longestIndex1), y(longestIndex1), sprintf('%s mm', num2str(dXYLength)), 'Color', 'r', 'Visible', sTextVisible);
                            tCY = text(atRoi.Object.Parent, cxMax(perpendicularIndex2), cyMax(perpendicularIndex2), sprintf('%s mm', num2str(dCYLength)), 'Color','m', 'Visible', sTextVisible);

                            tPointsComputed.MaxXY.Text = tXY;
                            tPointsComputed.MaxCY.Text = tCY;                    
                        end
                    end
                end
            end
        catch
            tPointsComputed = []; 
        end
    end
end
