function brushRoi2D(he, hf, xSize, ySize, dVoiOffset, sLesionType)
%function  brushRoi2D(he, hf, xSize, ySize)
%Edit an ROI position from another ROI position.
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

%     try 

    hfMask = poly2mask(hf.Position(:,1), hf.Position(:,2), xSize, ySize);
    hfPos = round(hf.Position);
    hfMask(sub2ind([xSize, ySize], hfPos(:, 2), hfPos(:, 1))) = true;
    
    heMask = poly2mask(he.Vertices(:, 1), he.Vertices(:, 2), xSize, ySize);
    hePos = round(he.Position);
    heMask(sub2ind([xSize, ySize], hePos(:, 2), hePos(:, 1))) = true;
    
    center = he.Center;
    
    if hf.inROI(center(1), center(2))
        newMask = hfMask | heMask;
    else
        newMask = hfMask & ~heMask;
    end
    
    if pixelEdge('get')          
        hfMask  = kron(hfMask, ones(3));
        newMask = kron(newMask, ones(3));
    end
    
    if any(hfMask(:) ~= newMask(:))

        B = bwboundaries(newMask, 'noholes', 8);

        if isempty(B)
            deleteRoiEvents(hf);
        else
            if ~isempty(dVoiOffset)

                if get(uiDeleteVoiRoiPanelObject('get'), 'Value') ~= dVoiOffset

                    set(uiDeleteVoiRoiPanelObject('get'), 'Value', dVoiOffset);
                    
                    if ~isempty(sLesionType)
                        set(uiLesionTypeVoiRoiPanelObject('get'), 'Value', getLesionType(sLesionType));
                    end
                end
            end

            dBoundaryOffset = getLargestboundary(B);

            if pixelEdge('get')
                B{dBoundaryOffset} = (B{dBoundaryOffset} + 1) / 3;
                B{dBoundaryOffset} = reducepoly(B{dBoundaryOffset});
            else                                      
                B{dBoundaryOffset} = smoothRoi(B{dBoundaryOffset}, [xSize, ySize]);
            end
    
            hf.Position = [B{dBoundaryOffset}(:, 2), B{dBoundaryOffset}(:, 1)];

        end
    end
%     catch
%     end

    function largestBoundary = getLargestboundary(cBoundaries)

        % Initialize variables to keep track of the largest boundary and its size
        largestBoundary = 1;
        largestSize = 0;
    
        % Determine the number of boundaries outside the loop for efficiency
        numBoundaries = length(cBoundaries);
    
        % Loop through each boundary in 'B'
        for k = 1:numBoundaries
            % Get the current boundary
            boundary = cBoundaries{k};
    
            % Calculate the size of the current boundary
            boundarySize = size(boundary, 1);
    
            % Check if the current boundary is larger than the previous largest
            if boundarySize > largestSize
                largestSize = boundarySize;
                largestBoundary = k;
            end
        end
    end
end