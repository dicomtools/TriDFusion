function tMaxDistances = computeVoiPlanesFarthestPoint(pVoi, atRoi, atMetaData, imSeries, bShowLine)
%function  tMaxDistances = computeVoiPlanesFarthestPoint(pVoi, atRoi, atMetaData, imSeries, bShowLine)
%Compute VOI farthest Coronal, Sagittal and Axial values from ROI object.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if isempty(pVoi) || isempty(atRoi)
        return;
    end

    PIXEL_EDGE_RATIO = 3;

    tMaxDistances.Coronal = [];
    tMaxDistances.Sagittal = [];
    tMaxDistances.Axial = [];

    lXY1 = [];
    lXY2 = [];
    lXY3 = [];

    a3DMmask = false(size(imSeries));
   
    imCDataAxes1 = false([size(imSeries, 2), size(imSeries, 3)]);
    imCDataAxes2 = false([size(imSeries, 1), size(imSeries, 3)]) ;
    imCDataAxes3 = false([size(imSeries, 1), size(imSeries, 2)]);  

    for rr=1:numel(pVoi.RoisTag)

        aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), pVoi.RoisTag{rr} );

        if ~isempty(aTagOffset)

            dOffset = find(aTagOffset,1);
            
            pRoi = atRoi{dOffset};

            if ~strcmpi(pRoi.Type, 'images.roi.line')

                switch(lower(pRoi.Axe))

                    case lower( 'Axes1')

                        imCData = roiTemplateToMask(pRoi, imCDataAxes1);
                        a3DMmask(pRoi.SliceNb,:,:) = a3DMmask(pRoi.SliceNb,:,:) | permute(imCData, [3 2 1]);

                    case lower( 'Axes2')          

                        imCData = roiTemplateToMask(pRoi, imCDataAxes2);
                        a3DMmask(pRoi.SliceNb,:,:) = a3DMmask(:,pRoi.SliceNb,:) | permute(imCData, [3 1 2]);

                    case lower( 'Axes3')                   
                        imCData = roiTemplateToMask(pRoi, imCDataAxes3);
                        a3DMmask(:,:,pRoi.SliceNb) = a3DMmask(:,:,pRoi.SliceNb) | imCData;  
                end                             
            end
        end
    end

    % Coronal

    slicesWithOnes = any(any(a3DMmask, 2), 3);%     coronalPlanesWithOnes = any(any(a3DMmask, 2), 1);

    % Find the indices of slices with at least one value equal to 1
    aIndicesCoronal = find(slicesWithOnes);

    dMaxDistance = -inf;

    if ~isempty(aIndicesCoronal)

        for jj=1:numel(aIndicesCoronal)

            imCData = permute(a3DMmask(aIndicesCoronal(jj),:,:), [3 2 1]);
            imCData = imresize(imCData , PIXEL_EDGE_RATIO, 'nearest');

            boundaries = bwboundaries(imCData, 8, 'noholes');

            if ~isempty(boundaries)

                thisBoundary = (boundaries{1}+1)/PIXEL_EDGE_RATIO;

                x = thisBoundary(:, 2); % x = columns.
                y = thisBoundary(:, 1); % y = rows.

                for k = 1 : length(x)

                    distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
                    [thisMaxDistance, indexOfMaxDistance] = max(distances);

                    if thisMaxDistance > dMaxDistance                   

                        dMaxDistance = thisMaxDistance;

                        longestIndex1 = k;
                        longestIndex2 = indexOfMaxDistance;  

                        x1XY = x(longestIndex1);
                        x2XY = x(longestIndex2);
                        y1XY = y(longestIndex1);
                        y2XY = y(longestIndex2);
                
                        % Compute XY distance in mm
                
                        roiObject.Position(1,1) = x1XY;
                        roiObject.Position(1,2) = y1XY;
                
                        roiObject.Position(2,1) = x2XY;
                        roiObject.Position(2,2) = y2XY;
                
                        tMaxDistances.Coronal.SliceNumber = aIndicesCoronal(jj);
                        tMaxDistances.Coronal.MaxLength = computeLineLength(atMetaData, 'Axes1', roiObject);

                        if bShowLine == true

                            delete(lXY1);
                            lXY1 = line(axes1Ptr('get', [], 1), [x1XY, x2XY], [y1XY, y2XY], 'Color', 'r', 'LineWidth', 1, 'Visible', 'on');	
                        end

                    end
                end
            end

        end
    end

    % Sagittal

    dMaxDistance = -inf;

    slicesWithOnes = any(any(a3DMmask, 1), 3);%     coronalPlanesWithOnes = any(any(a3DMmask, 2), 1);

    % Find the indices of slices with at least one value equal to 1
    aIndicesSagittal = find(slicesWithOnes);

    if ~isempty(aIndicesSagittal)

        for jj=1:numel(aIndicesSagittal)

            imCData = permute(a3DMmask(:,aIndicesSagittal(jj),:), [3 1 2]);
            imCData = imresize(imCData , PIXEL_EDGE_RATIO, 'nearest');

            boundaries = bwboundaries(imCData, 8, 'noholes');

            if ~isempty(boundaries)

                thisBoundary = (boundaries{1}+1)/PIXEL_EDGE_RATIO;

                x = thisBoundary(:, 2); % x = columns.
                y = thisBoundary(:, 1); % y = rows.

                for k = 1 : length(x)

                    distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
                    [thisMaxDistance, indexOfMaxDistance] = max(distances);

                    if thisMaxDistance > dMaxDistance                   

                        dMaxDistance = thisMaxDistance;

                        longestIndex1 = k;
                        longestIndex2 = indexOfMaxDistance;  

                        x1XY = x(longestIndex1);
                        x2XY = x(longestIndex2);
                        y1XY = y(longestIndex1);
                        y2XY = y(longestIndex2);
                
                        % Compute XY distance in mm
                
                        roiObject.Position(1,1) = x1XY;
                        roiObject.Position(1,2) = y1XY;
                
                        roiObject.Position(2,1) = x2XY;
                        roiObject.Position(2,2) = y2XY;
                
                        tMaxDistances.Sagittal.SliceNumber = aIndicesSagittal(jj);
                        tMaxDistances.Sagittal.MaxLength = computeLineLength(atMetaData, 'Axes2', roiObject);

                        if bShowLine == true 

                            delete(lXY2);
                            lXY2 = line(axes2Ptr('get', [], 1), [x1XY, x2XY], [y1XY, y2XY], 'Color', 'r', 'LineWidth', 1, 'Visible', 'on');	
                        end
                   end
                end
            end

        end
    end

    % Axial

    dMaxDistance = -inf;

    % Check which slices have at least one value equal to 1
    slicesWithOnes = any(any(a3DMmask, 1), 2);
    
    % Find the indices of slices with at least one value equal to 1
    aIndicesAxial = find(slicesWithOnes);

    if ~isempty(aIndicesAxial)

        for jj=1:numel(aIndicesAxial)

            imCData = a3DMmask(:,:,aIndicesAxial(jj));
            imCData = imresize(imCData , PIXEL_EDGE_RATIO, 'nearest');

            boundaries = bwboundaries(imCData, 8, 'noholes');

            if ~isempty(boundaries)
                
                thisBoundary = (boundaries{1}+1)/PIXEL_EDGE_RATIO;

                x = thisBoundary(:, 2); % x = columns.
                y = thisBoundary(:, 1); % y = rows.

                for k = 1 : length(x)

                    distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
                    [thisMaxDistance, indexOfMaxDistance] = max(distances);

                    if thisMaxDistance > dMaxDistance                   

                        dMaxDistance = thisMaxDistance;

                        longestIndex1 = k;
                        longestIndex2 = indexOfMaxDistance;  

                        x1XY = x(longestIndex1);
                        x2XY = x(longestIndex2);
                        y1XY = y(longestIndex1);
                        y2XY = y(longestIndex2);
                
                        % Compute XY distance in mm
                
                        roiObject.Position(1,1) = x1XY;
                        roiObject.Position(1,2) = y1XY;
                
                        roiObject.Position(2,1) = x2XY;
                        roiObject.Position(2,2) = y2XY;
                
                        tMaxDistances.Axial.SliceNumber = aIndicesAxial(jj);
                        tMaxDistances.Axial.MaxLength   = computeLineLength(atMetaData, 'Axes3', roiObject);

                        if bShowLine == true   
                            
                            delete(lXY3);
                            lXY3 = line(axes3Ptr('get', [], 1), [x1XY, x2XY], [y1XY, y2XY], 'Color', 'r', 'LineWidth', 1, 'Visible', 'on');	
                        end
                    end
                end
            end

        end
    end
   
    clear a3DMmask;

end