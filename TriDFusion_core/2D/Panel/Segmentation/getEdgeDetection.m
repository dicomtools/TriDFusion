function imEdge = getEdgeDetection(im, sMethod, dFudgeFactor)      
%function imEdge = getEdgeDetection(im, sMethod, dFudgeFactor)
%Get 2D/3D edge image from a method and factor.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
               
    aSize = size(im);
    imMask = zeros(aSize);

    if size(im, 3) == 1
        im2D = im(:,:);
        
        [~, dThreshold] = edge(im2D, sMethod);        
        imEdge = double(edge(im2D, sMethod, dThreshold * dFudgeFactor));  
        
        imMask(:,:) = imEdge;            
    else
        for aa=1:aSize(3)
            progressBar(aa/aSize(3), sprintf('Processing %s Step %d/%d', sMethod, aa, aSize(3)));
            im2D = im(:,:,aa);
            
            [~, dThreshold] = edge(im2D, sMethod);        
            imEdge = double(edge(im2D, sMethod, dThreshold * dFudgeFactor));  
        
            imMask(:,:,aa) = imEdge;
        end
        progressBar(1, 'Ready');
    end

    lMin = min(im, [], 'all');
    lMax = max(im, [], 'all');
    
    imEdge = im;
    
    imEdge(imMask == 0) = lMin;
    imEdge(imMask ~= 0) = lMax;

end