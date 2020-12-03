function [aCameraPosition, aCameraUpVector] = compute3Dflip(objPosition, objUpVector, sOrientation)
%function [aCameraPosition, aCameraUpVector] = compute3Dflip(objPosition, objUpVector, sOrientation)
%Compute The Flip 3D Images Up, Down, Right and Left.
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

    switch lower(sOrientation)
        case 'left'

            aPosition{1,1} = [1 0 0];
            aPosition{1,2} = [0 1 0];                    
            aPosition{1,3} = [-1 0 0];
            aPosition{1,4} = [0 -1 0];

            aUpVector{1,1} = [0 0 1];
            aUpVector{1,2} = [0 0 1];
            aUpVector{1,3} = [0 0 1];
            aUpVector{1,4} = [0 0 1]; 

            aPosition{2,1} = [0 0 1];
            aPosition{2,2} = [0 1 0];                    
            aPosition{2,3} = [0 0 -1];
            aPosition{2,4} = [0 -1 0];                    

            aUpVector{2,1} = [-1 0 0];
            aUpVector{2,2} = [-1 0 0];
            aUpVector{2,3} = [-1 0 0];
            aUpVector{2,4} = [-1 0 0];    

            aPosition{3,1} = [-1 0 0];
            aPosition{3,2} = [0 1 0];                    
            aPosition{3,3} = [1 0 0];
            aPosition{3,4} = [0 -1 0];

            aUpVector{3,1} = [0 0 -1];
            aUpVector{3,2} = [0 0 -1];
            aUpVector{3,3} = [0 0 -1];
            aUpVector{3,4} = [0 0 -1];                    

            aPosition{4,1} = [0 0 -1];
            aPosition{4,2} = [0 1 0];                    
            aPosition{4,3} = [0 0 1];
            aPosition{4,4} = [0 -1 0];                    

            aUpVector{4,1} = [1 0 0];
            aUpVector{4,2} = [1 0 0];
            aUpVector{4,3} = [1 0 0];
            aUpVector{4,4} = [1 0 0];

            aPosition{5,1} = [1 0 0];
            aPosition{5,2} = [0 0 -1];                    
            aPosition{5,3} = [-1 0 0];
            aPosition{5,4} = [0 0 1];                    

            aUpVector{5,1} = [0 1 0];
            aUpVector{5,2} = [0 1 0];
            aUpVector{5,3} = [0 1 0];
            aUpVector{5,4} = [0 1 0];                      

            aPosition{6,1} = [0 0 -1];
            aPosition{6,2} = [1 0 0];                    
            aPosition{6,3} = [0 0 1];
            aPosition{6,4} = [-1 0 0];                    

            aUpVector{6,1} = [0 -1 0];
            aUpVector{6,2} = [0 -1 0];
            aUpVector{6,3} = [0 -1 0];
            aUpVector{6,4} = [0 -1 0];                     

        case 'right'
            aPosition{1,1} = [1 0 0];
            aPosition{1,4} = [0 1 0];                    
            aPosition{1,3} = [-1 0 0];
            aPosition{1,2} = [0 -1 0];

            aUpVector{1,1} = [0 0 1];
            aUpVector{1,4} = [0 0 1];
            aUpVector{1,3} = [0 0 1];
            aUpVector{1,2} = [0 0 1]; 

            aPosition{2,1} = [0 0 1];
            aPosition{2,4} = [0 1 0];                    
            aPosition{2,3} = [0 0 -1];
            aPosition{2,2} = [0 -1 0];                    

            aUpVector{2,1} = [-1 0 0];
            aUpVector{2,4} = [-1 0 0];
            aUpVector{2,3} = [-1 0 0];
            aUpVector{2,2} = [-1 0 0];    

            aPosition{3,1} = [-1 0 0];
            aPosition{3,4} = [0 1 0];                    
            aPosition{3,3} = [1 0 0];
            aPosition{3,2} = [0 -1 0];

            aUpVector{3,1} = [0 0 -1];
            aUpVector{3,4} = [0 0 -1];
            aUpVector{3,3} = [0 0 -1];
            aUpVector{3,2} = [0 0 -1];                    

            aPosition{4,1} = [0 0 -1];
            aPosition{4,4} = [0 1 0];                    
            aPosition{4,3} = [0 0 1];
            aPosition{4,2} = [0 -1 0];                    

            aUpVector{4,1} = [1 0 0];
            aUpVector{4,4} = [1 0 0];
            aUpVector{4,3} = [1 0 0];
            aUpVector{4,2} = [1 0 0]; 

            aPosition{5,1} = [1 0 0];
            aPosition{5,4} = [0 0 -1];                    
            aPosition{5,3} = [-1 0 0];
            aPosition{5,2} = [0 0 1];                    

            aUpVector{5,1} = [0 1 0];
            aUpVector{5,4} = [0 1 0];
            aUpVector{5,3} = [0 1 0];
            aUpVector{5,2} = [0 1 0];                     

            aPosition{6,1} = [0 0 -1];
            aPosition{6,4} = [1 0 0];                    
            aPosition{6,3} = [0 0 1];
            aPosition{6,2} = [-1 0 0];                    

            aUpVector{6,1} = [0 -1 0];
            aUpVector{6,4} = [0 -1 0];
            aUpVector{6,3} = [0 -1 0];
            aUpVector{6,2} = [0 -1 0];                      
        case 'up'

            aPosition{1,1} = [1 0 0];
            aPosition{1,2} = [0 0 -1];
            aPosition{1,3} = [-1 0 0];
            aPosition{1,4} = [0 0 1];

            aUpVector{1,1} = [0 0 1];
            aUpVector{1,2} = [1 0 0];
            aUpVector{1,3} = [0 0 -1];
            aUpVector{1,4} = [-1 0 0];

            aPosition{2,1} = [0 1 0];
            aPosition{2,2} = [0 0 -1];
            aPosition{2,3} = [0 -1 0];
            aPosition{2,4} = [0 0 1];

            aUpVector{2,1} = [0 0 1];
            aUpVector{2,2} = [0 1 0];
            aUpVector{2,3} = [0 0 -1];
            aUpVector{2,4} = [0 -1 0];

            aPosition{3,1} = [-1 0 0];
            aPosition{3,2} = [0 0 -1];
            aPosition{3,3} = [1 0 0];
            aPosition{3,4} = [0 0 1];

            aUpVector{3,1} = [0 0 1];
            aUpVector{3,2} = [-1 0 0];
            aUpVector{3,3} = [0 0 -1];
            aUpVector{3,4} = [1 0 0];

            aPosition{4,1} = [0 -1 0];
            aPosition{4,2} = [0 0 -1];
            aPosition{4,3} = [0 1 0];
            aPosition{4,4} = [0 0 1];

            aUpVector{4,1} = [0 0 1];
            aUpVector{4,2} = [0 -1 0];
            aUpVector{4,3} = [0 0 -1];
            aUpVector{4,4} = [0 1 0];                    

            aPosition{5,1} = [0 -1 0];
            aPosition{5,2} = [-1 0 0];
            aPosition{5,3} = [0 1 0];
            aPosition{5,4} = [1 0 0];

            aUpVector{5,1} = [1 0 0];
            aUpVector{5,2} = [0 -1 0];
            aUpVector{5,3} = [-1 0 0];
            aUpVector{5,4} = [0 1 0];     

            aPosition{6,1} = [0 1 0];
            aPosition{6,2} = [-1 0 0];
            aPosition{6,3} = [0 -1 0];
            aPosition{6,4} = [1 0 0];

            aUpVector{6,1} = [1 0 0];
            aUpVector{6,2} = [0 1 0];
            aUpVector{6,3} = [-1 0 0];
            aUpVector{6,4} = [0 -1 0];                      

        case 'down'

            aPosition{1,1} = [1 0 0];
            aPosition{1,4} = [0 0 -1];
            aPosition{1,3} = [-1 0 0];
            aPosition{1,2} = [0 0 1];

            aUpVector{1,1} = [0 0 1];
            aUpVector{1,4} = [1 0 0];
            aUpVector{1,3} = [0 0 -1];
            aUpVector{1,2} = [-1 0 0];

            aPosition{2,1} = [0 1 0];
            aPosition{2,4} = [0 0 -1];
            aPosition{2,3} = [0 -1 0];
            aPosition{2,2} = [0 0 1];

            aUpVector{2,1} = [0 0 1];
            aUpVector{2,4} = [0 1 0];
            aUpVector{2,3} = [0 0 -1];
            aUpVector{2,2} = [0 -1 0];

            aPosition{3,1} = [-1 0 0];
            aPosition{3,4} = [0 0 -1];
            aPosition{3,3} = [1 0 0];
            aPosition{3,2} = [0 0 1];

            aUpVector{3,1} = [0 0 1];
            aUpVector{3,4} = [-1 0 0];
            aUpVector{3,3} = [0 0 -1];
            aUpVector{3,2} = [1 0 0];

            aPosition{4,1} = [0 -1 0];
            aPosition{4,4} = [0 0 -1];
            aPosition{4,3} = [0 1 0];
            aPosition{4,2} = [0 0 1];

            aUpVector{4,1} = [0 0 1];
            aUpVector{4,4} = [0 -1 0];
            aUpVector{4,3} = [0 0 -1];
            aUpVector{4,2} = [0 1 0];   

            aPosition{5,1} = [0 -1 0];
            aPosition{5,4} = [-1 0 0];
            aPosition{5,3} = [0 1 0];
            aPosition{5,2} = [1 0 0];

            aUpVector{5,1} = [1 0 0];
            aUpVector{5,4} = [0 -1 0];
            aUpVector{5,3} = [-1 0 0];
            aUpVector{5,2} = [0 1 0];                        

            aPosition{6,1} = [0 1 0];
            aPosition{6,4} = [-1 0 0];
            aPosition{6,3} = [0 -1 0];
            aPosition{6,2} = [1 0 0];

            aUpVector{6,1} = [1 0 0];
            aUpVector{6,4} = [0 1 0];
            aUpVector{6,3} = [-1 0 0];
            aUpVector{6,2} = [0 -1 0];                     


        otherwise
    end                                                                

    % default position
    aCameraUpVector = [1 0 0];                
    aCameraPosition = [0 0 1];  

    % try to find next position
    for yy=1:size(aPosition,1)
        for xx=1:size(aPosition,2)

            if aPosition{yy,xx} == round(objPosition)
                if aUpVector{yy,xx} == round(objUpVector)

                    if xx == size(aPosition,2)                                
                        aCameraUpVector = aUpVector{yy,1};
                        aCameraPosition = aPosition{yy,1};                                             
                    else
                        aCameraUpVector = aUpVector{yy,xx+1};
                        aCameraPosition = aPosition{yy,xx+1};  
                    end
                end
            end
        end
    end                                                                     
end
