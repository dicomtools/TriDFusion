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
%tic    
    tmask = poly2mask(hf.Position(:,1), hf.Position(:,2), ySize, xSize);
 %   tmask = imresize(tmask , 3, 'nearest'); % do not go directly through pixel centers

    % Create a binary mask for the target freehand.
%    tmask = hf.createMask();
    [m, n] = size(tmask);
    
    % Round the positions of the target freehand ROI
    hfPos = round(hf.Position);
    
    % Include the boundary pixels of the target freehand ROI
    hfBoundaryInd = sub2ind([m, n], hfPos(:, 2), hfPos(:, 1));
    tmask(hfBoundaryInd) = true;
    
    % Create a binary mask from the editor ROI
    emask = poly2mask(he.Vertices(:, 1), he.Vertices(:, 2), ySize, xSize);   
%    emask = imresize(emask , 3, 'nearest'); % do not go directly through pixel centers
%    emask = he.createMask();
    hePos = round(he.Position);
    
    % Include the boundary pixels of the editor ROI
    heBoundaryInd = sub2ind([m, n], hePos(:, 2), hePos(:, 1));
    emask(heBoundaryInd) = true;
    
    % Check if the center of the editor ROI is inside the target freehand.
    center = he.Center;
    
    if hf.inROI(center(1), center(2)) % Add
        newMask = tmask | emask;
    else
        newMask = tmask & ~emask;
    end 
    
    if any(tmask(:) ~= newMask(:))

        B = bwboundaries(newMask, 'noholes', 8);
        
        if isempty(B)

            deleteRoiEvents(hf);
        else
            if ~isempty(dVoiOffset) % Set Contour Panel, Contour review
                if get(uiDeleteVoiRoiPanelObject('get'), 'Value') ~= dVoiOffset 

                    set(uiDeleteVoiRoiPanelObject('get'), 'Value', dVoiOffset);         
                    
                    if ~isempty(sLesionType)
                        set(uiLesionTypeVoiRoiPanelObject('get'), 'Value', getLesionType(sLesionType));
                    end
                end
            end

           % hf.Position = [perimPos{end}(:, 2), perimPos{end}(:, 1)];
            hf.Position = [B{1}(:, 2), B{1}(:, 1)]; 
        end
    end
%toc    
end