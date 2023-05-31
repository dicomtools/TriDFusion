function aMask = lungLobesMasks(sAction, sOrgan, aValue)
%function aMask = lungLobesMasks(sAction, sOrgan, aValue)
%Get/Set 3D Lung Lobes init masks value.
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

    persistent paMask; 

    if strcmpi('set', sAction)
        if strcmpi('liver', sOrgan)
           paMask{1}=aValue;
        elseif strcmpi('lungs', sOrgan)
           paMask{2}=aValue;
        elseif strcmpi('lungLeft', sOrgan)
           paMask{3}=aValue;
        elseif strcmpi('lungRight', sOrgan)
           paMask{4}=aValue;
        elseif strcmpi('lungUpperLobeLeft', sOrgan)
           paMask{5}=aValue;
        elseif strcmpi('lungLowerLobeLeft', sOrgan)
           paMask{6}=aValue;           
        elseif strcmpi('lungUpperLobeRight', sOrgan)
           paMask{7}=aValue;     
        elseif strcmpi('lungMiddleLobeRight', sOrgan)
           paMask{8}=aValue;             
        else
           paMask{9}=aValue;
        end
    else
        if strcmpi('liver', sOrgan)
           aMask = paMask{1};
        elseif strcmpi('lungs', sOrgan)
           aMask = paMask{2};
        elseif strcmpi('lungLeft', sOrgan)
           aMask = paMask{3};
        elseif strcmpi('lungRight', sOrgan)
           aMask = paMask{4};
        elseif strcmpi('lungUpperLobeLeft', sOrgan)
           aMask = paMask{5};
        elseif strcmpi('lungLowerLobeLeft', sOrgan)
           aMask = paMask{6};           
        elseif strcmpi('lungUpperLobeRight', sOrgan)
           aMask = paMask{7};     
        elseif strcmpi('lungMiddleLobeRight', sOrgan)
           aMask = paMask{8};             
        else
           aMask = paMask{9};
        end
    end
    
end