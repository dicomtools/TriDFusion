function imBuffer = cropInside(aMask, imBuffer, dSliceNumber, sAxe)
%function cropInside(aMask, imBuffer, dSliceNumber, sAxe)
%Crop inside a buffer.
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

    if size(imBuffer, 3) == 1
        if strcmpi(sAxe, 'Axe')
            b = imBuffer(:,:);
%            c = createMask(pObject, b);
            c = aMask;
            c = ~c;    
            b(c == 0) = cropValue('get')-c(c == 0); % crop inside
            imBuffer = b;                           
        end
    else

        if strcmpi(sAxe, 'Axes1')
                
            b = permute(imBuffer(dSliceNumber,:,:), [3 2 1]);
%            c = createMask(pObject, b);
            c = aMask;
            c = ~c;    
            b(c == 0) = cropValue('get')-c(c == 0); % crop inside 
            
            imBuffer(dSliceNumber,:,:) = permute(reshape(b, [1 size(b)]), [1 3 2]);               
        end

        if strcmpi(sAxe, 'Axes2')

            b = permute(imBuffer(:,dSliceNumber,:), [3 1 2]);
%            c = createMask(pObject,b);
            c = aMask;
            c = ~c;      
            b(c == 0) = cropValue('get')-c(c == 0); % crop inside 
            imBuffer(:,dSliceNumber,:) =  permute(reshape(b, [1 size(b)]), [3 1 2]);  
        end

        if strcmpi(sAxe, 'Axes3')

            b = imBuffer(:,:,dSliceNumber);       
%            c = createMask(pObject,b);
            c = aMask;
            c = ~c;           
            b(c == 0) = cropValue('get')-c(c == 0); % crop inside             
            imBuffer(:,:,dSliceNumber) = b;                
        end
    end
end