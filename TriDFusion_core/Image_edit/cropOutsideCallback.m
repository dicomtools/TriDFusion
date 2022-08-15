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
    
    if size(im, 3) == 1
        axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
        if ~isempty(axe)
            if gca == axe
                
                aMask = createMask(hObject.UserData, im(:,:));
                
                b = im(:,:);
                c = aMask;
                b(c == 0) = cropValue('get')-c(c == 0); % crop inside
                im = b;  
                
%                im = cropOutside(hObject.UserData, ...
%                                 im, ...
%                                 [], ...
%                                 'Axe' ...
%                                 ); 
            end
        end
    else
        if ~isempty(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')))

            if gca == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                iCoronal = sliceNumber('get', 'coronal');
                
                aMask = createMask(hObject.UserData, permute(im(iCoronal,:,:), [3 2 1]));
                
                b = permute(im(iCoronal,:,:), [3 2 1]);
                c = aMask;
                b(c == 0) = cropValue('get')-c(c == 0); % crop inside 

                im(iCoronal,:,:) = permute(reshape(b, [1 size(b)]), [1 3 2]);  
                    
%                im = cropOutside(aMask, ...
%                                 im, ...
%                                 iCoronal, ...
%                                 'Axes1' ...
%                                 );   
            end

            if gca == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                iSagittal = sliceNumber('get', 'sagittal');
                
                aMask = createMask(hObject.UserData, permute(im(:,iSagittal,:), [3 1 2]));
                
                b = permute(im(:,iSagittal,:), [3 1 2]);
                c = aMask;
                b(c == 0) = cropValue('get')-c(c == 0); % crop inside 
                im(:,iSagittal,:) =  permute(reshape(b, [1 size(b)]), [3 1 2]);  
                    
%                im = cropOutside(aMask, ...
%                                 im, ...
%                                 iSagittal, ...
%                                 'Axes2' ...
%                                 );   
            end

            if gca == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                 iAxial = sliceNumber('get', 'axial');
                 
                 aMask = createMask(hObject.UserData, im(:,:,iAxial));
                 
                 b = im(:,:,iAxial);       
                 c = aMask;
                 b(c == 0) = cropValue('get')-c(c == 0); % crop inside             
                 im(:,:,iAxial) = b; 
                    
%                 im = cropOutside(aMask, ...
%                                  im, ...
%                                  iAxial, ...
%                                  'Axes3' ...
%                                  );  
            end
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
