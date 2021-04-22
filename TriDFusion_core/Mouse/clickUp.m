function clickUp(~, ~)
%function clickUp(~, ~)
%Set the status of the Viewer progress bar.
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

    windowButton('set', 'up'); 
    set(fiMainWindowPtr('get'), 'UserData', 'up');
    
    if switchTo3DMode('get')      == true || ...
       switchToIsoSurface('get')  == true || ...
       switchToMIPMode('get')     == true
      
        mipICObj = mipICObject('get');
        if ~isempty(mipICObj)
            mipICObj.mouseMode = 1;
            set(mipICObj.figureHandle, 'WindowButtonMotionFcn', '');
        end

        volICObj = volICObject('get');                
        if ~isempty(volICObj)
            volICObj.mouseMode = 1;
            set(volICObj.figureHandle, 'WindowButtonMotionFcn', '');                
        end

        mipICFusionObj = mipICFusionObject('get');
        if ~isempty(mipICFusionObj)
            mipICFusionObj.mouseMode = 1;
            set(mipICFusionObj.figureHandle, 'WindowButtonMotionFcn', '');
        end       

        volICFusionObj = volICFusionObject('get');
        if ~isempty(volICFusionObj)
            volICFusionObj.mouseMode = 1;
            set(volICFusionObj.figureHandle, 'WindowButtonMotionFcn', '');
        end
        
        updateObjet3DPosition();      
    else
        if isMoveImageActivated('get') == true
if 0            
            [bApplyMovement, aAxe, aPosition] =  fusedImageMovementValues('get');
            if bApplyMovement == true
                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                progressBar(0.999, 'Resampling Image, please wait');
                
                moveFusedImage(false, true);
     
                aResampledImage = resampleImageMovement(fusionBuffer('get'), aAxe, aPosition);
                fusionBuffer('set', aResampledImage);                
                
                refreshImages();
                
                progressBar(1, 'Ready');               
            end
end            
            [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get');            
            if bApplyRotation == true
                
                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                progressBar(0.999, 'Resampling Image, please wait');
                
                aResampledImage = resampleImageRotation(fusionBuffer('get'), aAxe, dRotation);
                fusionBuffer('set', aResampledImage);
                
                refreshImages();
                
                progressBar(1, 'Ready');
                
            end
            
            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');

        end
        
    end
    
end