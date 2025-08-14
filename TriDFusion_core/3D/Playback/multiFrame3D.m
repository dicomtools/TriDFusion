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
    persistent t

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        
        progressBar(1, 'Error: Require a 3D Volume!');  
        multiFrame3DPlayback('set', false);

        icon = get(mPlay, 'UserData');
        set(mPlay, 'CData', icon.default);

        % Cleanup existing timer if it exists
        if ~isempty(t) && isvalid(t)
            stop(t); delete(t);
            t = [];
        end
        return;
    end 

    % ptrViewer3d = viewer3dObject('get');

    if ~isempty(viewer3dObject('get'))

        if multiFrame3DPlayback('get')
            
            % If timer exists but speed changed, restart it
            if ~isempty(t) && isvalid(t)
                if t.Period ~= multiFrame3DSpeed('get')
                    stop(t); delete(t);
                    t = createViewerTimer();
                    start(t);
                end
            else
                t = createViewerTimer();
                start(t);
            end
        else
            cleanupTimer();
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

    function cleanupTimer()
        if ~isempty(t) && isvalid(t)
            stop(t); delete(t);
            t = [];
        end
    end

    function t = createViewerTimer()
        % Initialize index
        idxOffset = multiFrame3DIndex('get');
        t = timer( ...
            'Name',          'multiFrame3DViewer', ...
            'ExecutionMode', 'fixedRate', ...
            'Period',        multiFrame3DSpeed('get'), ...
            'TimerFcn',      @onViewerTick);
    end

    function onViewerTick(~, ~)
        % Stop if turned off
        if ~multiFrame3DPlayback('get')
            multiFrame3DIndex('set', idxOffset);
            cleanupTimer();
            return;
        end

        % Advance index (wrap at 120)
        idxOffset = idxOffset + 1;
        if idxOffset > 120
            idxOffset = 1;
        end
        multiFrame3DIndex('set', idxOffset);

        % Compute the view angle
        degreeAngle = ((idxOffset - 1) / (119)) * 359 + 1;

        % Update the 3D viewer
        set3DView(viewer3dObject('get'), degreeAngle, 1);
    end

end
