function deleteAlphaCurve(sObject)
%function deleteAlphaCurve(sObject)
%Delete Interactive Plot 3D alpha curve.
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

    volICObj = volICObject('get');                
    mipICObj = mipICObject('get');
    volICFusionObj = volICFusionObject('get');                
    mipICFusionObj = mipICFusionObject('get');
    
    if strcmp(sObject, 'vol') && ~isempty(volICObj)
        if isempty(mipICObj)       && ...
           isempty(volICFusionObj) && ...
           isempty(mipICFusionObj)
            set(fiMainWindowPtr('get'), 'WindowButtonUpFcn', @clickUp);
        end

        delete(volICObj); 
        volICObject('set', '');
    end
    
    if strcmp(sObject, 'volfusion') && ~isempty(volICFusionObj)
         if isempty(mipICObj) && ...
            isempty(volICObj) && ...
            isempty(mipICFusionObj)
            set(fiMainWindowPtr('get'), 'WindowButtonUpFcn', @clickUp);
         end

        delete(volICFusionObj); 
        volICFusionObject('set', '');
    end
    
    if strcmp(sObject, 'mip') && ~isempty(mipICObj)
         if isempty(mipICFusionObj) && ...
            isempty(volICObj)       && ...
            isempty(mipICFusionObj)
            set(fiMainWindowPtr('get'), 'WindowButtonUpFcn', @clickUp);
         end
        
        delete(mipICObj);    
        mipICObject('set', '');
    end
    
    if strcmp(sObject, 'mipfusion') && ~isempty(mipICFusionObj)
         if isempty(mipICObj) && ...
            isempty(volICObj)       && ...
            isempty(volICFusionObj)
            set(fiMainWindowPtr('get'), 'WindowButtonUpFcn', @clickUp);
         end
        
        delete(mipICFusionObj);    
        mipICFusionObject('set', '');
    end    
        
end 