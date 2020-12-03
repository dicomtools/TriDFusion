function setVsplashCallback(~, ~)    
%function setVsplashCallback(~, ~)   
%Set 2D vSplash.
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

    im = dicomBuffer('get');

    if isempty(im)
        return;
    end

    iCoronalSize  = size(im,1);
    iSagittalSize = size(im,2);
    iAxialSize    = size(im,3);   

    iCoronal  = sliceNumber('get', 'coronal');     
    iSagittal = sliceNumber('get', 'sagittal');                 
    iAxial    = sliceNumber('get', 'axial');     

    multiFramePlayback('set', false);
    multiFrameRecord  ('set', false); 

    mPlay = playIconMenuObject('get');
    if ~isempty(mPlay)
        mPlay.State = 'off';
%          playIconMenuObject('set', '');
    end

    mRecord = recordIconMenuObject('get');
    if ~isempty(mRecord)
        mRecord.State = 'off';
%          recordIconMenuObject('set', '');
    end    

    if isVsplash('get') == false                            

        releaseRoiWait();                

        isVsplash('set', true);                
        set(btnVsplashPtr('get'), 'BackgroundColor', 'white');

        clearDisplay();                    
        initDisplay(3);  

        dicomViewerCore();                      

    else
        isVsplash('set', false);                
        set(btnVsplashPtr('get'), 'BackgroundColor', 'default');                

        clearDisplay();                    
        initDisplay(3);  

        dicomViewerCore();                   

    end

    % restore position
    set(uiSliderCorPtr('get'), 'Value', iCoronal / iCoronalSize);
    sliceNumber('set', 'coronal', iCoronal);   

    set(uiSliderSagPtr('get'), 'Value', iSagittal / iSagittalSize);
    sliceNumber('set', 'sagittal', iSagittal);   

    set(uiSliderTraPtr('get'), 'Value', 1 - (iAxial / iAxialSize));
    sliceNumber('set', 'axial', iAxial);                             

    refreshImages();     
end