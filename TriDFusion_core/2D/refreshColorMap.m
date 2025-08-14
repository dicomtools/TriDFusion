function refreshColorMap()
%function refreshColorMap()
%Refresh 2D Zoom Colormap.
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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false

        ptrColorbar = uiColorbarPtr('get');
        setColorbarColormap(ptrColorbar, getColorMap('one', colorMapOffset('get')));

        if size(dicomBuffer('get'), 3) == 1
            colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
            if isFusion('get')
                colormap(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
            end
        else
            colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
            colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
            colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
            
            if link2DMip('get') == true && isVsplash('get') == false
                colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));              
            end
            
            if isFusion('get')  == true
                
                ptrFusionColorbar = uiFusionColorbarPtr('get');
                setColorbarColormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));

                colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                
                if link2DMip('get') == true && isVsplash('get') == false               
                    
                    colormap(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));                        
                end
                
                if isPlotContours('get') == true && isVsplash('get') == false
                    colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));  
                    
                    if link2DMip('get') == true && isVsplash('get') == false

                        colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));                        
                    end                    
                end                 
            end                    
        end
        
        refreshImages();
    end

end