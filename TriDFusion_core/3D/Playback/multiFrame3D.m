function multiFrame3D(mPlay)
%function multiFrame3D(mPlay)
%Play 3D Multi-Frame.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        
        progressBar(1, 'Error: Require a 3D Volume!');  
        multiFrame3DPlayback('set', false);
        mPlay.State = 'off';
        return;
    end 

    ptrViewer3d = viewer3dObject('get');

    if ~isempty(viewer3dObject('get'))

        idxOffset = multiFrame3DIndex('get');
         
        sz = size(dicomBuffer('get', [], dSeriesOffset));
        center = sz/2 + 0.5;

        % set(ptrViewer3d, 'CameraTarget', center);

        numberOfFrames = 120;
        vec = linspace(0,2*pi,numberOfFrames)';
        dist = sqrt(sz(1)^2 + sz(2)^2 + sz(3)^2);
        myPosition = center + ([cos(vec) sin(vec) ones(size(vec))]*dist);

        while multiFrame3DPlayback('get')           
           
            for idx = 1:120
    
                if ~multiFrame3DPlayback('get')
                    multiFrame3DIndex('set', idxOffset);
    
                    break;
                end

                aPosition = myPosition(idxOffset,:);

                set(ptrViewer3d, 'CameraPosition', aPosition);

                % drawnow;
                
                idxOffset = idxOffset+1;
    
                if idxOffset >= 120
                    idxOffset =1;
                end
    
                pause(multiFrame3DSpeed('get'));  

            end
        end
        
    else

        volObj = volObject('get');
        isoObj = isoObject('get');                        
        mipObj = mipObject('get');                
        
        voiObj = voiObject('get');
    
        volFusionObj = volFusionObject('get');
        isoFusionObj = isoFusionObject('get');                        
        mipFusionObj = mipFusionObject('get');       
            
        idxOffset = multiFrame3DIndex('get');
    
        vec = linspace(0,2*pi(),120)';
    
        while multiFrame3DPlayback('get')           
           
            for idx = 1:120
    
                if ~multiFrame3DPlayback('get')
                    multiFrame3DIndex('set', idxOffset);
    
                    break;
                end
                                        
                if ~isempty(mipObj)  
    
                    aCameraUpVector = mipObj.CameraUpVector;            
    
                elseif ~isempty(volObj) 
    
                    aCameraUpVector = volObj.CameraUpVector;            
    
                elseif ~isempty(isoObj) 
    
                    aCameraUpVector = isoObj.CameraUpVector;            
    
                elseif ~isempty(voiObj) 
    
                    aCameraUpVector = voiObj{1}.CameraUpVector;
                else
                    aCameraUpVector = [0 0 1];
               end
    
                if     abs(aCameraUpVector(1)) > abs(aCameraUpVector(2)) && ...
                       abs(aCameraUpVector(1)) > abs(aCameraUpVector(3))
    
                    aCameraUpVector = [round(aCameraUpVector(1)) 0 0];
    
                elseif abs(aCameraUpVector(2)) > abs(aCameraUpVector(1)) && ...
                       abs(aCameraUpVector(2)) > abs(aCameraUpVector(3))
    
                    aCameraUpVector = [0 round(aCameraUpVector(2)) 0];
                else
                    aCameraUpVector = [0 0 round(aCameraUpVector(3))];
                end
                
                if     abs(round(aCameraUpVector(1))) == 1
    
                    myPosition = [zeros(size(vec)) multiFrame3DZoom('get')*sin(vec) multiFrame3DZoom('get')*cos(vec)];
    
                elseif abs(round(aCameraUpVector(2))) == 1   
    
                    myPosition = [multiFrame3DZoom('get')*sin(vec) zeros(size(vec)) multiFrame3DZoom('get')*cos(vec)];           
                else
                    myPosition = [multiFrame3DZoom('get')*cos(vec) multiFrame3DZoom('get')*sin(vec) zeros(size(vec))];
                end
    
                aPosition = myPosition(idxOffset,:);
                
                if ~isempty(mipObj)                    
    
                    mipObj.CameraPosition = aPosition;  
                    mipObj.CameraUpVector = aCameraUpVector;
                end
    
                if ~isempty(isoObj)                        
    
                    isoObj.CameraPosition = aPosition;
                    isoObj.CameraUpVector = aCameraUpVector;
                end
    
                if ~isempty(volObj)
    
                    volObj.CameraPosition = aPosition;
                    volObj.CameraUpVector = aCameraUpVector;
                end
                
                if ~isempty(mipFusionObj)                    
    
                    mipFusionObj.CameraPosition = aPosition;  
                    mipFusionObj.CameraUpVector = aCameraUpVector;
                end
    
                if ~isempty(isoFusionObj)                        
    
                    isoFusionObj.CameraPosition = aPosition;
                    isoFusionObj.CameraUpVector = aCameraUpVector;
                end
    
                if ~isempty(volFusionObj)
    
                    volFusionObj.CameraPosition = aPosition;
                    volFusionObj.CameraUpVector = aCameraUpVector;
                end
                
                if ~isempty(voiObj)
    
                    for ff=1:numel(voiObj)
    
                        voiObj{ff}.CameraPosition = aPosition;
                        voiObj{ff}.CameraUpVector = aCameraUpVector;
                    end
                end  
    
                idxOffset = idxOffset+1;
    
                if idxOffset >= 120
                    idxOffset =1;
                end
    
                pause(multiFrame3DSpeed('get'));       
    
            end
    
        end
    end
end
