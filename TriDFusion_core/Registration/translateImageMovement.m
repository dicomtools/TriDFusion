function aTranslatedImage = translateImageMovement(aImage, aPosition)
%function  translateImageMovement(aImage, aAxe, aPosition)
%Translate Movement of an Image. 
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
        
    if size(aImage, 3) == 1 
        
        xMoveOffset = aPosition(1);
        yMoveOffset = aPosition(2);    
        
        aTranslatedImage = imtranslate(aImage,[xMoveOffset, yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    
    else        
        
        xMoveOffset = aPosition(1);
        yMoveOffset = aPosition(2);
        zMoveOffset = aPosition(3);
    
        aTranslatedImage = imtranslate(aImage,[xMoveOffset, yMoveOffset, zMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all') );    
      
%        switch aAxe
%            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Coronal    
%                aTranslatedImage = imtranslate(aImage,[-xMoveOffset,0,-yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    

%            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Sagittal  
%                aTranslatedImage = imtranslate(aImage,[0,-xMoveOffset,-yMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all'));    

%            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Axial                      
%                aTranslatedImage = imtranslate(aImage,[-xMoveOffset,-yMoveOffset,0], 'nearest', 'OutputView', 'same', 'FillValues', min(aImage, [], 'all') );    

%            otherwise
%                aTranslatedImage = aImage;
%                return;
%        end
                
    end    
    
end