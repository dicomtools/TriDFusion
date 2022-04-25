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
    
    dBufferSize = size(im);   

    if dBufferSize(3) == 1
        
        axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
        if ~isempty(axe)
            if gca == axe        
                
                im = cropOutside(hObject.UserData, ...
                                im, ...
                                [], ...
                                'Axe' ...
                                );                          
            end
        end
    else
        if ~isempty(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')))

            if gca == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))         

                for iCoronal=1:dBufferSize(1)
                    
                    im = cropOutside(hObject.UserData, ...
                                    im, ...
                                    iCoronal, ...
                                    'Axes1' ...
                                    );     

                    progressBar(iCoronal / dBufferSize(1), 'Mask outside in progress');
                end
            end

            if gca == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))        

                for iSagittal=1:dBufferSize(2)
                    
                    im = cropOutside(hObject.UserData, ...
                                    im, ...
                                    iSagittal, ...
                                    'Axes2' ...
                                    );  

                    progressBar(iSagittal / dBufferSize(2), 'Mask outside in progress');
                end
            end

            if gca == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))      

                for iAxial=1:dBufferSize(3)
                    
                    im = cropOutside(hObject.UserData, ...
                                    im, ...
                                    iAxial, ...
                                    'Axes3' ...
                                    );    

                    progressBar(iAxial / dBufferSize(3), 'Mask outside in progress');
                end
            end
        end
    end

    progressBar(1, 'Ready');

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
