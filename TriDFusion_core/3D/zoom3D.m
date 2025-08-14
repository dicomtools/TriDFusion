function zoom3D(sZoomInOut, lStep)
%function zoom3D(sZoomInOut, lStep)
%Zoom 3D Images From Playback menu.
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

    ptrViewer3d = viewer3dObject('get');

    if ~isempty(ptrViewer3d)

        if strcmpi(sZoomInOut, 'out')
            ptrViewer3d.CameraZoom = ptrViewer3d.CameraZoom/lStep;
        else
            ptrViewer3d.CameraZoom = ptrViewer3d.CameraZoom*lStep;
        end
    else
        volObj = volObject('get');
        isoObj = isoObject('get');                        
        mipObj = mipObject('get');  
        
        voiObj = voiObject('get');                                                       
        
        volFusionObj = volFusionObject('get');
        isoFusionObj = isoFusionObject('get');                        
        mipFusionObj = mipFusionObject('get');  
        
        if ~isempty(mipObj)
            if strcmpi(sZoomInOut, 'out')
                mipObj.CameraPosition = mipObj.CameraPosition*lStep;
            else
                mipObj.CameraPosition = mipObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];                
        end
    
        if ~isempty(isoObj)
            if strcmpi(sZoomInOut, 'out')
                isoObj.CameraPosition = isoObj.CameraPosition*lStep;
            else
                isoObj.CameraPosition = isoObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];               
        end
    
        if ~isempty(volObj)
            if strcmpi(sZoomInOut, 'out')
                volObj.CameraPosition = volObj.CameraPosition*lStep;
            else
                volObj.CameraPosition = volObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];               
        end   
        
        if ~isempty(mipFusionObj)
            if strcmpi(sZoomInOut, 'out')
                mipFusionObj.CameraPosition = mipFusionObj.CameraPosition*lStep;
            else
                mipFusionObj.CameraPosition = mipFusionObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];                
        end
    
        if ~isempty(isoFusionObj)
            if strcmpi(sZoomInOut, 'out')
                isoFusionObj.CameraPosition = isoFusionObj.CameraPosition*lStep;
            else
                isoFusionObj.CameraPosition = isoFusionObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];               
        end
    
        if ~isempty(volFusionObj)
            if strcmpi(sZoomInOut, 'out')
                volFusionObj.CameraPosition = volFusionObj.CameraPosition*lStep;
            else
                volFusionObj.CameraPosition = volFusionObj.CameraPosition/lStep;
            end
    %        mipObj.CameraUpVector = [0 0 1];               
        end 
        
        if ~isempty(voiObj)
            for ff=1:numel(voiObj)
                if strcmpi(sZoomInOut, 'out')
                    voiObj{ff}.CameraPosition = voiObj{ff}.CameraPosition*lStep;
                else
                    voiObj{ff}.CameraPosition = voiObj{ff}.CameraPosition/lStep;
                end
      %          voiObj{ff}.CameraUpVector =  [0 0 1];
            end
        end               
    end
end