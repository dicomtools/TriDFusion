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

    try 

    hfMask = poly2mask(hf.Position(:,1), hf.Position(:,2), ySize, xSize);
    [m, n] = size(hfMask);
    hfPos = round(hf.Position);
    hfMask(sub2ind([m, n], hfPos(:, 2), hfPos(:, 1))) = true;
    
    heMask = poly2mask(he.Vertices(:, 1), he.Vertices(:, 2), ySize, xSize);
    hePos = round(he.Position);
    heMask(sub2ind([m, n], hePos(:, 2), hePos(:, 1))) = true;
    
    center = he.Center;
    
    if hf.inROI(center(1), center(2))
        newMask = hfMask | heMask;
    else
        newMask = hfMask & ~heMask;
    end
    
    if pixelEdge('get')
        hfMask  = imresize(hfMask , 3, 'nearest');
        newMask = imresize(newMask, 3, 'nearest');
    end
    
    if any(hfMask(:) ~= newMask(:))

        B = bwboundaries(newMask, 'noholes', 4);
    
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
    
            if pixelEdge('get')
                B{1} = (B{1} + 1) / 3;
                B{1} = reducepoly(B{1});
            else                        
                aSize(1)=xSize;
                aSize(2)=ySize;
              
                B{1} = smoothRoi(B{1}, aSize);
            end
    
            hf.Position = [B{1}(:, 2), B{1}(:, 1)];

        end
    end
    catch
    end
end