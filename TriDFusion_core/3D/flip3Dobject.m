function flip3Dobject(sOrientation)
%function flip3Dobject(sOrientation)
%Flip 3D Images Up, Down, Right and Left.
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

    if multiFrame3DRecord('get') == true
        return;
    end
    
    if  strcmpi(get(gateIconMenuObject('get'), 'State'), 'off') || ...
        ( strcmpi(get(gateIconMenuObject('get'), 'State'), 'on') && ...     
          multiFrame3DPlayback('get') == false ) 

        if ~isempty(viewer3dObject('get'))

        else
            volObj = volObject('get');
            isoObj = isoObject('get');                        
            mipObj = mipObject('get');
            
            volFusionObj  = volFusionObject('get');                      
            isoFusionObj  = isoFusionObject('get');                                       
            mipFusionObj  = mipFusionObject('get');  
        
            voiObj = voiObject('get');
            
            if ~isempty(mipObj)
                aCameraPosition = mipObj.CameraPosition;
                aCameraUpVector = mipObj.CameraUpVector;
    
                for cc=1:numel(aCameraPosition) % Normalize to 1
                    aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                end            
    
                [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                for cc=1:numel(aCameraPosition) % Add the zoom
                    aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                end
    
                mipObj.CameraPosition = aCameraPosition;
                mipObj.CameraUpVector = aCameraUpVector;
            end
    
            if ~isempty(mipFusionObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    mipFusionObj.CameraPosition = aCameraPosition;
                    mipFusionObj.CameraUpVector = aCameraUpVector;                
                else            
                    aCameraPosition = mipFusionObj.CameraPosition;
                    aCameraUpVector = mipFusionObj.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end
    
                    mipFusionObj.CameraPosition = aCameraPosition;
                    mipFusionObj.CameraUpVector = aCameraUpVector;
                end
            end
            
            if ~isempty(volObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    volObj.CameraPosition = aCameraPosition;
                    volObj.CameraUpVector = aCameraUpVector;                
                else
                    aCameraPosition = volObj.CameraPosition;
                    aCameraUpVector = volObj.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end
    
                    volObj.CameraPosition = aCameraPosition;
                    volObj.CameraUpVector = aCameraUpVector;                     
                end
            end
             
            if ~isempty(volFusionObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    volFusionObj.CameraPosition = aCameraPosition;
                    volFusionObj.CameraUpVector = aCameraUpVector;                
                else
                    aCameraPosition = volFusionObj.CameraPosition;
                    aCameraUpVector = volFusionObj.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end
    
                    volFusionObj.CameraPosition = aCameraPosition;
                    volFusionObj.CameraUpVector = aCameraUpVector;                     
                end
            end
             
            if ~isempty(isoObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    isoObj.CameraPosition = aCameraPosition;
                    isoObj.CameraUpVector = aCameraUpVector;                
                else
                    aCameraPosition = isoObj.CameraPosition;
                    aCameraUpVector = isoObj.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end
    
                    isoObj.CameraPosition = aCameraPosition;
                    isoObj.CameraUpVector = aCameraUpVector;                     
                end
            end            
            
            if ~isempty(isoFusionObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    isoFusionObj.CameraPosition = aCameraPosition;
                    isoFusionObj.CameraUpVector = aCameraUpVector;                
                else
                    aCameraPosition = isoFusionObj.CameraPosition;
                    aCameraUpVector = isoFusionObj.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end
    
                    isoFusionObj.CameraPosition = aCameraPosition;
                    isoFusionObj.CameraUpVector = aCameraUpVector;                     
                end
            end    
            
            if ~isempty(voiObj)
                if exist('aCameraPosition','var') && ...
                   exist('aCameraUpVector','var') 
                    for ff=1:numel(voiObj)
                        voiObj{ff}.CameraPosition = aCameraPosition;
                        voiObj{ff}.CameraUpVector = aCameraUpVector;
                    end
                else
                    aCameraPosition = voiObj{1}.CameraPosition;
                    aCameraUpVector = voiObj{1}.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end     
    
                    for ff=1:numel(voiObj)
                        voiObj{ff}.CameraPosition = aCameraPosition;
                        voiObj{ff}.CameraUpVector = aCameraUpVector;
                    end
                end
            end
        end
    else % playback
        
        if multiFrame3DPlayback('get') == true 

            if ~isempty(viewer3dObject('get'))
                
            else
                volGateObj = volGateObject('get');                                
                isoGateObj = isoGateObject('get');                
                mipGateObj = mipGateObject('get');
    
                volGateFusionObj = volGateFusionObject('get');                                
                isoGateFusionObj = isoGateFusionObject('get');                
                mipGateFusionObj = mipGateFusionObject('get');
    
                voiGateObj = voiGateObject('get');        
    
                if ~isempty(volGateObj)            
                    aCameraPosition = volGateObj{1}.CameraPosition;
                    aCameraUpVector = volGateObj{1}.CameraUpVector;
    
                    for cc=1:numel(aCameraPosition) % Normalize to 1
                        aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                    end            
    
                    [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                    for cc=1:numel(aCameraPosition) % Add the zoom
                        aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                    end     
    
                    for ff=1:numel(volGateObj)
                        volGateObj{ff}.CameraPosition = aCameraPosition;
                        volGateObj{ff}.CameraUpVector = aCameraUpVector;
                    end           
                end
    
                if ~isempty(volGateFusionObj)     
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var') 
                        for ff=1:numel(volGateFusionObj)
                            volGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            volGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end
                    else            
                        aCameraPosition = volGateFusionObj{1}.CameraPosition;
                        aCameraUpVector = volGateFusionObj{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end     
    
                        for ff=1:numel(volGateFusionObj)
                            volGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            volGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end   
                    end
                end  
    
                if ~isempty(mipGateObj)     
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var') 
                        for ff=1:numel(mipGateObj)
                            mipGateObj{ff}.CameraPosition = aCameraPosition;
                            mipGateObj{ff}.CameraUpVector = aCameraUpVector;
                        end
                    else            
                        aCameraPosition = mipGateObj{1}.CameraPosition;
                        aCameraUpVector = mipGateObj{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end     
    
                        for ff=1:numel(mipGateObj)
                            mipGateObj{ff}.CameraPosition = aCameraPosition;
                            mipGateObj{ff}.CameraUpVector = aCameraUpVector;
                        end   
                    end
                end 
    
                if ~isempty(mipGateFusionObj)     
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var') 
                        for ff=1:numel(mipGateFusionObj)
                            mipGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            mipGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end
                    else            
                        aCameraPosition = mipGateFusionObj{1}.CameraPosition;
                        aCameraUpVector = mipGateFusionObj{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end     
    
                        for ff=1:numel(mipGateFusionObj)
                            mipGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            mipGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end   
                    end
                end          
    
                if ~isempty(isoGateObj)     
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var') 
                        for ff=1:numel(isoGateObj)
                            isoGateObj{ff}.CameraPosition = aCameraPosition;
                            isoGateObj{ff}.CameraUpVector = aCameraUpVector;
                        end
                    else            
                        aCameraPosition = isoGateObj{1}.CameraPosition;
                        aCameraUpVector = isoGateObj{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end     
    
                        for ff=1:numel(isoGateObj)
                            isoGateObj{ff}.CameraPosition = aCameraPosition;
                            isoGateObj{ff}.CameraUpVector = aCameraUpVector;
                        end   
                    end
                end 
    
                if ~isempty(isoGateFusionObj)     
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var') 
                        for ff=1:numel(mipGateFusionObj)
                            isoGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            isoGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end
                    else            
                        aCameraPosition = isoGateFusionObj{1}.CameraPosition;
                        aCameraUpVector = isoGateFusionObj{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end     
    
                        for ff=1:numel(isoGateFusionObj)
                            isoGateFusionObj{ff}.CameraPosition = aCameraPosition;
                            isoGateFusionObj{ff}.CameraUpVector = aCameraUpVector;
                        end   
                    end
                end   
    
                if ~isempty(voiGateObj)
                    if exist('aCameraPosition','var') && ...
                       exist('aCameraUpVector','var')             
                         for tt=1:numel(voiGateObj)   
                            if ~isempty(voiGateObj{tt})
                                for ll=1:numel(voiGateObj{tt})      
                                    voiGateObj{tt}{ll}.CameraPosition = aCameraPosition;        
                                    voiGateObj{tt}{ll}.CameraUpVector = aCameraUpVector ;        
                                end
                             end
                         end
                    else
                        aCameraPosition = voiGateObj{1}{1}.CameraPosition;
                        aCameraUpVector = voiGateObj{1}{1}.CameraUpVector;
    
                        for cc=1:numel(aCameraPosition) % Normalize to 1
                            aCameraPosition(cc) = aCameraPosition(cc) / multiFrame3DZoom('get');
                        end            
    
                        [aCameraPosition, aCameraUpVector] = compute3Dflip(aCameraPosition, aCameraUpVector, sOrientation);
    
                        for cc=1:numel(aCameraPosition) % Add the zoom
                            aCameraPosition(cc) = aCameraPosition(cc) * multiFrame3DZoom('get');
                        end   
    
                         for tt=1:numel(voiGateObj)   
                            if ~isempty(voiGateObj{tt})
                                for ll=1:numel(voiGateObj{tt})      
                                    voiGateObj{tt}{ll}.CameraPosition = aCameraPosition;        
                                    voiGateObj{tt}{ll}.CameraUpVector = aCameraUpVector ;        
                                end
                             end
                         end                    
    
    
                    end
                end
            end
        end
    end
%           initGate3DObject('set', true);

end
