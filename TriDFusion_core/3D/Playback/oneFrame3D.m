function oneFrame3D()
%function oneFrame3D()
%Display 3D DICOM Image Next Frame.
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

    volObj = volObject('get');
    isoObj = isoObject('get');                        
    mipObj = mipObject('get');  
    voiObj = voiObject('get');

    idxOffset = multiFrame3DIndex('get');

    vec = linspace(0,2*pi(),120)';

    myPosition = [multiFrame3DZoom('get')*cos(vec) multiFrame3DZoom('get')*sin(vec) zeros(size(vec))];

    if ~isempty(mipObj)

        mipObj.CameraPosition = myPosition(idxOffset,:);
        mipObj.CameraUpVector = [0 0 1];   
        
        if isFusion('get')

            mipFusionObj = mipFusionObject('get');  
            if ~isempty(mipFusionObj)

                mipFusionObj.CameraPosition = myPosition(idxOffset,:);
                mipFusionObj.CameraUpVector = [0 0 1];                   
            end
        end
        
    end

    if ~isempty(isoObj)

        isoObj.CameraPosition = myPosition(idxOffset,:);
        isoObj.CameraUpVector = [0 0 1];   
        
        if isFusion('get')

            isoFusionObj = isoFusionObject('get');  
            if ~isempty(isoFusionObj)

                isoFusionObj.CameraPosition = myPosition(idxOffset,:);
                isoFusionObj.CameraUpVector = [0 0 1];                   
            end
        end        
    end

    if ~isempty(volObj)

        volObj.CameraPosition = myPosition(idxOffset,:);
        volObj.CameraUpVector = [0 0 1];  
        
        if isFusion('get')

            volFusionObj = volFusionObject('get');  
            if ~isempty(volFusionObj)

                volFusionObj.CameraPosition = myPosition(idxOffset,:);
                volFusionObj.CameraUpVector = [0 0 1];                   
            end
        end        
    end   

    if ~isempty(voiObj)

        for ff=1:numel(voiObj)
            
            voiObj{ff}.CameraPosition = myPosition(idxOffset,:);
            voiObj{ff}.CameraUpVector =  [0 0 1];
        end
    end    

end   