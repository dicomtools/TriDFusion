function updateObjet3DPosition()
%function  updateObjet3DPosition()
%Update all 3D object position.
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

    if ~isempty(viewer3dObject('get'))
        
    else
        volObj = volObject('get');
        isoObj = isoObject('get');                        
        mipObj = mipObject('get');            
    
        voiObj = voiObject('get');
    
        volFusionObj = volFusionObject('get');
        isoFusionObj = isoFusionObject('get');                        
        mipFusionObj = mipFusionObject('get');             
            
        if ~isempty(mipObj) 
            if get(mipObj, 'InteractionsEnabled') == true
                aCameraPosition = mipObj.CameraPosition;
                aCameraUpVector = mipObj.CameraUpVector; 
            end
        end      
        
        if ~isempty(volObj)                     
            if get(volObj, 'InteractionsEnabled') == true
                aCameraPosition = volObj.CameraPosition;
                aCameraUpVector = volObj.CameraUpVector;
            end
        end
        
        if ~isempty(isoObj)                     
            if get(isoObj, 'InteractionsEnabled') == true
                aCameraPosition = isoObj.CameraPosition;
                aCameraUpVector = isoObj.CameraUpVector; 
            end                
        end
    
        if ~isempty(mipObj) 
            mipObj.CameraPosition = aCameraPosition;
            mipObj.CameraUpVector = aCameraUpVector;                   
        end
    
        if ~isempty(isoObj) 
            isoObj.CameraPosition = aCameraPosition;
            isoObj.CameraUpVector = aCameraUpVector;
        end
    
        if ~isempty(volObj)
            volObj.CameraPosition = aCameraPosition;
            volObj.CameraUpVector = aCameraUpVector;
        end
    
        if ~isempty(mipFusionObj)               
            mipFusionObj.CameraPosition = aCameraPosition;  
            mipFusionObj.CameraUpVector = aCameraUpVector;
        end
    
        if ~isempty(isoFusionObj)                       
            isoFusionObj.CameraPosition = aCameraPosition;
            isoFusionObj.CameraUpVector = aCameraUpVector;
        end
    
        if ~isempty(volFusionObj) 
            volFusionObj.CameraPosition = aCameraPosition;
            volFusionObj.CameraUpVector = aCameraUpVector;
        end
    
        if ~isempty(voiObj) 
           % aAlphamap = voiObj{1}.Alphamap;
            for ff=1:numel(voiObj)
                voiObj{ff}.CameraPosition = aCameraPosition;
                voiObj{ff}.CameraUpVector = aCameraUpVector;
    %            if strcmpi(voi3DRenderer('get'), 'VolumeRendering')
    %                voiObj{ff}.Alphamap = aAlphamap;
    %            end
            end
        end 
    end
end