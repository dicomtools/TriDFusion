function cropOutsideAllSlicesCallback(hObject,~)
%function cropOutsideAllSlicesCallback(hObject,~)
%Crop Outside All Slices.
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

    dBufferSize = size(im);   

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

        if gca == axes1Ptr('get')         

            for iCoronal=1:dBufferSize(1)
                b = permute(im(iCoronal,:,:), [3 2 1]);
                c = createMask(hObject.UserData, b);
                b(c == 0) = cropValue('get')-c(c == 0); % crop outside
                im(iCoronal,:,:) = permuteBuffer(b, 'coronal');     

                progressBar(iCoronal / dBufferSize(1), 'Croping outside progress');
            end
        end

        if gca == axes2Ptr('get')        

            for iSagittal=1:dBufferSize(2)
                b = permute(im(:,iSagittal,:), [3 1 2]);
                c = createMask(hObject.UserData,b);
                b(c == 0) = cropValue('get')-c(c == 0); % crop outside
                im(:,iSagittal,:) = permuteBuffer(b, 'sagittal');  

                progressBar(iSagittal / dBufferSize(2), 'Croping outside progress');
            end
        end

        if gca == axes3Ptr('get')      

            for iAxial=1:dBufferSize(3)
                b = im(:,:,iAxial);       
                c = createMask(hObject.UserData,b);
                b(c == 0) = cropValue('get')-c(c == 0); % crop outside                
                im(:,:,iAxial) = b;     

                progressBar(iAxial / dBufferSize(3), 'Croping outside progress');
            end
        end
    end

    progressBar(1, 'Ready');

    dicomBuffer('set', im); 

    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();          

end                        
