function showRGBColormapImage(bShowImage)
%function  showRGBColormapImage(bShowImage)
%Activate\Deactivate RGB fusion colormap image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if size(dicomBuffer('get'), 3) == 1 || ...
       isVsplash('get') == true
        return;
    end
       
    if bShowImage == true
        
        if size(dicomBuffer('get'), 3) ~= 1 && ...
           isVsplash('get') == false
       
            pAxesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
            if ~isempty(pAxesMip)
                set(pAxesMip, 'Position', [0 0.5 1 0.47]);
            end

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                
                pAxesMipF  = axesMipfPtr ('get', [], rr);
                if ~isempty(pAxesMipF)
                    set(pAxesMipF, 'Position', [0 0.5 1 0.47]);
                end
                
                pAxesMipFC = axesMipfcPtr('get', [], rr);
                if ~isempty(pAxesMipFC)
                    set(pAxesMipFC, 'Position', [0 0.5 1 0.47]);
                end
                
            end
        end
        
        tAxesMipText = axesText('get', 'axesMipView');
        if ~isempty(tAxesMipText)
            set(tAxesMipText, 'Position', [0.9700 0.7600 0]);
        end
        
        axeRGBImage = axeRGBImagePtr('get');    
        if ~isempty(axeRGBImage)
            delete(axeRGBImage);
        end
        
        axeRGBImage = ...
           axes(uiMipWindowPtr('get'), ...
                'Units'   , 'normalized', ...
                'xlimmode', 'manual',...
                'ylimmode', 'manual',...
                'zlimmode', 'manual',...
                'climmode', 'manual',...
                'alimmode', 'manual',...
                'Position', [0 0 1 0.5], ...
                'Visible' , 'off'...
               );
        axeRGBImagePtr('set', axeRGBImage);            

        sRootPath = viewerRootPath('get');
        if isempty(sRootPath)
            imRGBColors = zeros([852 845 3]);
        else       
            sImageFile = sprintf('%simages//%s', sRootPath, getRGBColormapImage('get'));
            [imRGBColors, ~, alphaRGBColors] = imread(sImageFile);
        end    

        pRGBColors = imshow(imRGBColors, 'Parent', axeRGBImage);
        set(pRGBColors, 'AlphaData', alphaRGBColors);
              
        daspect(axeRGBImage, [1 1 1]); 

        set(axeRGBImage, 'Visible', 'off');
            
    else
        if size(dicomBuffer('get'), 3) ~= 1 && ...
           isVsplash('get') == false
       
            pAxesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
            if ~isempty(pAxesMip)
                set(pAxesMip, 'Position', [0 0 1 1]);
            end

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                
                pAxesMipF  = axesMipfPtr ('get', [], rr);
                if ~isempty(pAxesMipF)
                    set(pAxesMipF, 'Position', [0 0 1 1]);
                end
                
                pAxesMipFC = axesMipfcPtr('get', [], rr);
                if ~isempty(pAxesMipFC)
                    set(pAxesMipFC, 'Position', [0 0 1 1]);
                end
                
            end
        end 
        
        tAxesMipText = axesText('get', 'axesMipView');
        if ~isempty(tAxesMipText)
            set(tAxesMipText, 'Position', [0.9700 0.4600 0]);
        end
        
        axeRGBImage = axeRGBImagePtr('get');    
        if ~isempty(axeRGBImage)
            delete(axeRGBImage);
            axeRGBImagePtr('set', []);
        end

    end
    
end