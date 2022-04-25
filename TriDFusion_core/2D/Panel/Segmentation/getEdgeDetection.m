function aBufferEdge = getEdgeDetection(aBuffer, sMethod, dFudgeFactor)      
%function aBuffer = getEdgeDetection(aBuffer, sMethod, dFudgeFactor)
%Get 2D/3D edge aBufferage from a method and factor.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple DaBufferention Fusion (TriDFusion).
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
% without even the aBufferplied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>. 

    aBufferInit = aBuffer;
    
    if isempty(aBuffer)
        return;
    end

    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    try  
            
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
    
    aSize = size(aBuffer);
    aBufferMask = zeros(aSize);

    if size(aBuffer, 3) == 1
        
        [~, dThreshold] = edge(aBuffer, sMethod);        
        aBufferEdge = double(edge(aBuffer, sMethod, dThreshold * dFudgeFactor));  
        
        aBufferMask(:,:) = aBufferEdge;            
    else
        for aa=1:aSize(3)
            progressBar(aa/aSize(3), sprintf('Processing %s Step %d/%d', sMethod, aa, aSize(3)));
            aBuffer2D = aBuffer(:,:,aa);
            
            [~, dThreshold] = edge(aBuffer2D, sMethod);        
            aBufferEdge = double(edge(aBuffer2D, sMethod, dThreshold * dFudgeFactor));  
        
            aBufferMask(:,:,aa) = aBufferEdge;
        end
        progressBar(1, 'Ready');
    end

    lMin = min(aBuffer, [], 'all');
    lMax = max(aBuffer, [], 'all');
        
    aBuffer(aBufferMask == 0) = lMin;
    aBuffer(aBufferMask ~= 0) = lMax;
    
    % Get constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value'));

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    aLogicalMask = roiConstraintToMask(aBufferInit, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        

    aBuffer(aLogicalMask==0) = aBufferInit(aLogicalMask==0); % Set the constraint
    
    aBufferEdge = aBuffer;
    
    catch
        progressBar(1, 'Error:getEdgeDetection()');           
    end
    
    if isMoveImageActivated('get') == true
        set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
    else
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
    end
    
    drawnow; 
end