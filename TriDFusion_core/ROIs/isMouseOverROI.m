function bMouseIsOver = isMouseOverROI(pRoi, dSeriesOffset)
%function bMouseIsOver = isMouseOverROI(pRoi, dSeriesOffset)
%Determine if the mouse over a pecific ROI. 
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

    bMouseIsOver = false;

    % pAxe = getAxeFromMousePosition(dSeriesOffset);

    % if pAxe == pRoi.Parent % Same axe
    % 
    %     mousePoint = pAxe.CurrentPoint;
    % else

        mousePoint = zeros(2, 1); % X and Y of mouse
    
        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );
    
        switch pRoi.Parent
    
            case axes1Ptr('get', [], dSeriesOffset)  
                mousePoint(1) = iSagittal;
                mousePoint(2) = iAxial;
    
            case axes2Ptr('get', [], dSeriesOffset)  
                mousePoint(1) = iCoronal;
                mousePoint(2) = iAxial;
    
            case axes3Ptr('get', [], dSeriesOffset)  
                mousePoint(1) = iSagittal;
                mousePoint(2) = iCoronal;
    
            otherwise
                return;
        end
    % end

    % Check the type of ROI and use an appropriate containment check

    if isa(pRoi, 'images.roi.Rectangle')
        % Rectangle ROI
        pos = pRoi.Position;
        if mousePoint(1) >= pos(1) && mousePoint(1) <= pos(1) + pos(3) && ...
           mousePoint(2) >= pos(2) && mousePoint(2) <= pos(2) + pos(4)

            bMouseIsOver = true;
            return;
        end
        
    elseif isa(pRoi, 'images.roi.Ellipse')
        % Ellipse ROI
        center = pRoi.Center;
        semiAxes = pRoi.SemiAxes;
        % Ellipse containment formula
        if (((mousePoint(1) - center(1)) / semiAxes(1))^2 + ...
            ((mousePoint(2) - center(2)) / semiAxes(2))^2) <= 1

            bMouseIsOver = true;
            return;
        end
        
    elseif isa(pRoi, 'images.roi.Circle')
        % Circle ROI
        center = pRoi.Center;
        radius = pRoi.Radius;
        % Circle containment check (distance formula)
        if (mousePoint(1) - center(1))^2 + (mousePoint(2) - center(2))^2 <= radius^2

            bMouseIsOver = true;
            return;
        end
        
    elseif isa(pRoi, 'images.roi.Polygon') || isa(pRoi, 'images.roi.Freehand')
        % Polygon or Freehand ROI
        pos = pRoi.Position; % Get the vertices of the ROI
        if inpolygon(mousePoint(1), mousePoint(2), pos(:,1), pos(:,2))

            bMouseIsOver = true;
            return;
        end
    end
end
