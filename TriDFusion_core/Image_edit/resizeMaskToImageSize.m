function aNewMask = resizeMaskToImageSize(aMask, aImage) 
%function aNewMask = resizeMaskToImageSize(aMask, aImage) 
%Create a new mask   
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
% TriDFusion development has been led by: Daniel Lafontaine
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

%function maskToVoi(aMask, sLabel, sLesionType, aColor, sPlane, dSeriesOffset, bPixelEdge)
%Create a VOI from a 3D mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by: Daniel Lafontaine
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

    aMaskSize  = size(aMask);
    aImageSize = size(aImage);

    aNewMask = false(aImageSize);

    xSize = aImageSize(1);
    ySize = aImageSize(2);

    if numel(aMaskSize) ~= 3 % 2D image

        aSlice = aMask(:,:);
           
        if any(aSlice, 'all') 
                                           
            [aBoundaries, ~,nbBoundaries,~] = bwboundaries(aSlice, 'noholes', 4); 

            if ~isempty(aBoundaries)
     
                for jj=1:nbBoundaries
                    
                    cCurentBoundary = aBoundaries(jj);
                    
                    aPosition = flip(cCurentBoundary{1}, 2);

                    hfMask = poly2mask(aPosition(:,1), aPosition(:,2), xSize, ySize);
                    aNewMask(:,:) = aNewMask(:,:)|hfMask;
                end
            end            
        end

    else % 3D image
        
        for mm=1: aMaskSize(3)
            
            if mm > aImageSize(3)
                break;
            end

            aSlice = aMask(:,:,mm);
               
            if any(aSlice, 'all') 
                                               
                [aBoundaries, ~,nbBoundaries,~] = bwboundaries(aSlice, 'noholes', 4); 
    
                if ~isempty(aBoundaries)
         
                    for jj=1:nbBoundaries
                        
                        cCurentBoundary = aBoundaries(jj);
                        
                        aPosition = flip(cCurentBoundary{1}, 2);
    
                        hfMask = poly2mask(aPosition(:,1), aPosition(:,2), xSize, ySize);
                        aNewMask(:,:,mm) = aNewMask(:,:,mm)|hfMask;
                    end
                end            
            end
        end  
    end
end