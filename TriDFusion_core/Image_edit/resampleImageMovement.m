function aResampledImage = resampleImageMovement(aImage, aAxe, aPosition)
%function  resampleImageRotation(aImage, aAxe, aPosition)
%Resample the Movement of an Image. 
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

    xMoveOffset = aPosition(1);
    yMoveOffset = aPosition(2);
        
    if size(aImage, 3) == 1 
        aResampledImage = imtranslate(aImage,[-xMoveOffset,-yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    
    else        
        
        switch aAxe
            case axes1Ptr('get') % Coronal    
                aResampledImage = imtranslate(aImage,[-xMoveOffset,0,-yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    

            case axes2Ptr('get') % Sagittal  
                aResampledImage = imtranslate(aImage,[0,-xMoveOffset,-yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    

            case axes3Ptr('get') % Axial                  
    
                aResampledImage = imtranslate(aImage,[-xMoveOffset,-yMoveOffset,0], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all') );    

            otherwise
                aResampledImage = [];
                return;
        end
                
    end    
    
end