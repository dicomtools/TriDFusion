function aRGB = combineRGB(aRed, aGreen, aBlue, sPlane)    
%function sCombinaison = combineRGB(aRed, aGreen, aBlue, sPlane)
%Combine a gray scale images to RGB.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by:  Daniel Lafontaine
% 
% TriDFusion is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of TriDFusion is free software: you can Blueistribute it and/or modify
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

    if     ~isempty(aRed) && ~isempty(aGreen) && ~isempty(aBlue) % RGB        
        
        aRedSize   = size(aRed);
        aGreenSize = size(aGreen);
        aBlueSize  = size(aBlue);
        
        if aRedSize(1) ~= aGreenSize(1) || ... % Resize green image to red size
           aRedSize(2) ~= aGreenSize(2)     
            aGreen = imresize(aGreen, aRedSize);
        end
        
        if aRedSize(1) ~= aBlueSize(1) || ... % Resize blue image to red size
           aRedSize(2) ~= aBlueSize(2) 
            aBlue = imresize(aBlue, aRedSize);
        end
        
        aRGB = cat(3, scaleCombinedRGB(aRed, 'red', sPlane), scaleCombinedRGB(aGreen, 'green', sPlane), scaleCombinedRGB(aBlue, 'blue', sPlane));
        
    elseif  isempty(aRed) && ~isempty(aGreen) && ~isempty(aBlue) % GB
        
        aGreenSize = size(aGreen);
        aBlueSize  = size(aBlue);        
        
        if aGreenSize(1) ~= aBlueSize(1) || ... % Resize blue image to green size
           aGreenSize(2) ~= aBlueSize(2)    
            aBlue = imresize(aBlue, aGreenSize);
        end
                        
        aRGB = cat(3, scaleCombinedRGB(zeros(aGreenSize), 'zeros', sPlane), scaleCombinedRGB(aGreen, 'green', sPlane), scaleCombinedRGB(aBlue, 'blue', sPlane));
        
    elseif ~isempty(aRed) &&  isempty(aGreen) && ~isempty(aBlue) % RB
        
        aRedSize  = size(aRed);
        aBlueSize = size(aBlue);
                
        if aRedSize(1) ~= aBlueSize(1) || ... % Resize blue image to red size
           aRedSize(2) ~= aBlueSize(2)     
            aBlue = imresize(aBlue, aRedSize);
        end        
        
        aRGB = cat(3, scaleCombinedRGB(aRed, 'red', sPlane), scaleCombinedRGB(zeros(aRedSize), 'zeros', sPlane), scaleCombinedRGB(aBlue, 'blue', sPlane));
        
    elseif ~isempty(aRed) && ~isempty(aGreen) &&  isempty(aBlue) % RG
        
        aRedSize   = size(aRed);
        aGreenSize = size(aGreen);
        
        if aRedSize(1) ~= aGreenSize(1) || ... % Resize green image to red size
           aRedSize(2) ~= aGreenSize(2)     
            aGreen = imresize(aGreen, aRedSize);
        end              
        
        aRGB = cat(3, scaleCombinedRGB(aRed, 'red', sPlane), scaleCombinedRGB(aGreen, 'green', sPlane), scaleCombinedRGB(zeros(aRedSize), 'zeros', sPlane));
        
    elseif ~isempty(aRed) &&  isempty(aGreen) &&  isempty(aBlue) % R
        
        aRedSize = size(aRed);

        aRGB = cat(3, scaleCombinedRGB(aRed, 'red', sPlane), scaleCombinedRGB(zeros(aRedSize), 'zeros', sPlane), scaleCombinedRGB(zeros(aRedSize), 'zeros', sPlane));
        
    elseif  isempty(aRed) && ~isempty(aGreen) &&  isempty(aBlue) % G
        
        aGreenSize = size(aGreen);
        
        aRGB = cat(3, zeros(scaleCombinedRGB(aGreenSize), 'zeros', sPlane), scaleCombinedRGB(aGreen, 'green'), sPlane, scaleCombinedRGB(zeros(aGreenSize), 'zeros', sPlane));
        
    elseif  isempty(aRed) &&  isempty(aGreen) && ~isempty(aBlue) % B
        
        aBlueSize = size(aBlue);
        
        aRGB = cat(3, scaleCombinedRGB(zeros(aBlueSize), 'zeros', sPlane), scaleCombinedRGB(zeros(aBlueSize), 'zeros', sPlane), scaleCombinedRGB(aBlue, 'blue', sPlane));
        
    else
        aRGB = [];
    end
    
end

