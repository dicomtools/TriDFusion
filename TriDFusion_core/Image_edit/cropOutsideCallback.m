function cropOutsideCallback(hObject,~)
%function cropOutsideCallback(hObject,~)
%Crop Outside One Slice.
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
    
    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    try  
            
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
    
    axe = axePtr('get');
    if ~isempty(axe)
       imAxe = imAxePtr('get');
       if gca == axe                        
            b = imAxe.CData;
            c = createMask(hObject.UserData, b);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside
            imAxe.CData = b;                
            im = b;                           
        end
    end

    if ~isempty(axes1Ptr('get')) && ...
       ~isempty(axes2Ptr('get')) && ...
       ~isempty(axes3Ptr('get'))

        imCoronal  = imCoronalPtr ('get');
        imSagittal = imSagittalPtr('get');
        imAxial    = imAxialPtr   ('get');

        if gca == axes1Ptr('get')
            iCoronal  = sliceNumber('get', 'coronal');

            b = imCoronal.CData;
            c = createMask(hObject.UserData, b);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside
            imCoronal.CData = b;                
            im(iCoronal,:,:) = permuteBuffer(b, 'coronal');               
        end

        if gca == axes2Ptr('get')        
            iSagittal = sliceNumber('get', 'sagittal');

            b = imSagittal.CData;
            c = createMask(hObject.UserData,b);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside
            imSagittal.CData = b;          

            im(:,iSagittal,:) = permuteBuffer(b, 'sagittal');  
        end

        if gca == axes3Ptr('get')      
            iAxial = sliceNumber('get', 'axial');

            b = imAxial.CData;       
            c = createMask(hObject.UserData,b);
            b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
            imAxial.CData = b;                
            im(:,:,iAxial) = b;                
        end
    end     

    dicomBuffer('set', im); 

    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();   
    
    catch
        progressBar(1, 'Error:cropOutsideAllSlicesCallback()');           
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end   
