function  initCombineRGB()
%function initCombineRGB()
%Init 2D combined RGB fusion color intensity & Window.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by: Daniel Lafontaine
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

    dRedOffset   = false;
    dGreenOffset = false;
    dBlueOffset  = false;
    
    scaledRGBColorIntensity('reset');
    scaledRGBColorWindow('reset');
    
    isRGBFusionNormalizeToLiver('set', false);
    
    isRGBFusionRedEnable  ('set', true, []);
    isRGBFusionGreenEnable('set', true, []);
    isRGBFusionBlueEnable ('set', true, []);

    if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1
        
        getRGBmipCombinedBufferMinMax('set', [], []);                 
        
        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
        for rr=1:dNbFusedSeries
         
            imAxeF  = imAxeFPtr ('get', [], rr);

            if ~isempty(imAxeF) 
                
                if invertColor('get')
                    aRedColorMap   = flipud(getRedColorMap());
                    aGreenColorMap = flipud(getGreenColorMap());
                    aBlueColorMap  = flipud(getBlueColorMap());
                else
                    aRedColorMap   = getRedColorMap();
                    aGreenColorMap = getGreenColorMap();
                    aBlueColorMap  = getBlueColorMap();               
                end
        
                if colormap(imAxeF.Parent) == aRedColorMap
                    dRedOffset = rr;
                end

                if colormap(imAxeF.Parent) == aGreenColorMap
                    dGreenOffset = rr;
                end

                if colormap(imAxeF.Parent) == aBlueColorMap
                    dBlueOffset  = rr;                                      
                end 

            end
         end  
            
        % Init RGB colors series offset

        if dRedOffset ~= 0 && dGreenOffset ~= 0 && dBlueOffset ~= 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset  ));  
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset ));                 
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
            
            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');                

            dIntensity = (1/dBufferMax)*9;

            getRGBcombinedColor('set', 'RGB', dRedOffset, dGreenOffset, dBlueOffset);                

        elseif dRedOffset == 0 && dGreenOffset ~= 0 && dBlueOffset ~= 0

            aRedBuffer   = zeros(size(fusionBuffer('get', [], dGreenOffset)));  
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset )); 

            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 

            if dGreenMin < dBlueMin
                aRedBuffer(aRedBuffer==0) = dGreenMin;
            else
                aRedBuffer(aRedBuffer==0) = dBlueMin;
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');                

            dIntensity = (1/dBufferMax)*4;

            getRGBcombinedColor('set', 'GB', 0, dGreenOffset, dBlueOffset);

        elseif dRedOffset ~= 0 && dGreenOffset == 0 && dBlueOffset ~= 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset ));   
            aGreenBuffer = zeros(size(fusionBuffer('get', [], dRedOffset)));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset )); 

            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 

            if dRedMin < dBlueMin
                aGreenBuffer(aGreenBuffer==0) = dRedMin;
            else
                aGreenBuffer(aGreenBuffer==0) = dBlueMin;
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');

            dIntensity = (1/dBufferMax)*4;

            getRGBcombinedColor('set', 'RB', dRedOffset, 0, dBlueOffset); 

        elseif dRedOffset ~= 0 && dGreenOffset ~= 0 && dBlueOffset == 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset ));   
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset ));  
            aBlueBuffer  = zeros(size(fusionBuffer('get', [], dRedOffset))); 

            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 

            if dRedMin < dGreenMin
                aBlueBuffer(aBlueBuffer==0) = dRedMin;
            else
                aBlueBuffer(aBlueBuffer==0) = dGreenMin;
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');

            dIntensity = (1/dBufferMax)*4;

            getRGBcombinedColor('set', 'RG', dRedOffset, dGreenOffset, 0);

        elseif dRedOffset ~= 0 && dGreenOffset == 0 && dBlueOffset == 0

            aRedBuffer    = squeeze(fusionBuffer('get', [], dRedOffset ));    
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = 0;
            dGreenMax = 0;            
            
            dBlueMin = 0;
            dBlueMax = 0; 
            
            dBufferMin = min( aRedBuffer, [], 'all');
            dBufferMax = max( aRedBuffer, [], 'all');

            dIntensity = (1/dBufferMax);

            getRGBcombinedColor('set', 'R', dRedOffset, 0, 0);

        elseif dRedOffset == 0 && dGreenOffset ~= 0 && dBlueOffset == 0

            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset ));                                  
            
            dRedMin = 0;
            dRedMax = 0; 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = 0;
            dBlueMax = 0; 
            
            dBufferMin = min( aGreenBuffer, [], 'all');
            dBufferMax = max( aGreenBuffer, [], 'all');

            dIntensity = (1/dBufferMax);

            getRGBcombinedColor('set', 'G', 0, dGreenOffset, 0);

        elseif dRedOffset == 0 && dGreenOffset == 0 && dBlueOffset ~= 0

            aBlueBuffer = squeeze(fusionBuffer('get', [], dBlueOffset )); 
            
            dRedMin = 0;
            dRedMax = 0; 
            
            dGreenMin = 0;
            dGreenMax = 0;            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
            
            dBufferMin = min( aBlueBuffer, [], 'all');
            dBufferMax = max( aBlueBuffer, [], 'all');

            dIntensity = (1/dBufferMax);

            getRGBcombinedColor('set', 'B', 0, 0, dBlueOffset);

        else
            getRGBcombinedColor('set', '', [], [], []);  
            getRGBcombinedBufferMinMax('set', [], []);
            getRGBmipCombinedBufferMinMax('set', [], []);                 
        end

        if ~isempty(getRGBcombinedColor('get'))

            getRGBcombinedBufferMinMax('set', dBufferMin, dBufferMax);

            scaledRGBColorIntensity('set', [], 'red'  , 'Axe' , dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'green', 'Axe' , dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'blue' , 'Axe' , dIntensity, dBufferMin);

            scaledRGBColorWindow('set', [], 'red'  , 'Coronal' , dRedMin  , dRedMax  , dBufferMin);
            scaledRGBColorWindow('set', [], 'Green', 'Sagittal', dGreenMin, dGreenMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'blue' , 'Axial'   , dBlueMin , dBlueMax , dBufferMin);                
        end        
        
    else % 3D
        
        % Find RGB colors series offset
        
        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
        for rr=1:dNbFusedSeries
     
            imCoronalF  = imCoronalFPtr ('get', [], rr);
            imSagittalF = imSagittalFPtr('get', [], rr);
            imAxialF    = imAxialFPtr   ('get', [], rr);

            if ~isempty(imCoronalF) && ...
               ~isempty(imSagittalF) && ...
               ~isempty(imAxialF) 
           
                if invertColor('get')
                    aRedColorMap   = flipud(getRedColorMap());
                    aGreenColorMap = flipud(getGreenColorMap());
                    aBlueColorMap  = flipud(getBlueColorMap());
                else
                    aRedColorMap   = getRedColorMap();
                    aGreenColorMap = getGreenColorMap();
                    aBlueColorMap  = getBlueColorMap();               
                end
                
                if colormap(imCoronalF.Parent) == aRedColorMap
                    dRedOffset   = rr;
                end

                if colormap(imCoronalF.Parent) == aGreenColorMap
                    dGreenOffset = rr;
                end

                if colormap(imCoronalF.Parent) == aBlueColorMap
                    dBlueOffset  = rr;                                      
                end 

            end
        
        end
        
        % Init RGB colors series offset
               
        if dRedOffset ~= 0 && dGreenOffset ~= 0 && dBlueOffset ~= 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset  ));  
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset )); 
            
            if isVsplash('get') == false
                aRedMipBuffer   = squeeze(mipFusionBuffer('get', [], dRedOffset  ));  
                aGreenMipBuffer = squeeze(mipFusionBuffer('get', [], dGreenOffset));  
                aBlueMipBuffer  = squeeze(mipFusionBuffer('get', [], dBlueOffset )); 
            end
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
            
            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            
            dIntensity = (1/dBufferMax)*9;
%            dIntensity = 1/255;
        
            if isVsplash('get') == false
                
                if ~isempty(aRedMipBuffer) && ~isempty(aGreenMipBuffer) && ~isempty(aGreenMipBuffer)
                    dMipMin = dBufferMin;
                    dMipMax = max( cat(3, aRedMipBuffer, aGreenMipBuffer, aBlueMipBuffer), [], 'all');
                    dMipIntensity = (1/dMipMax)*9;
                else
                    dMipMin = dBufferMin;
                    dMipMax = dBufferMax;
                    dMipIntensity = dIntensity;                    
                end
            end
            
            getRGBcombinedColor('set', 'RGB', dRedOffset, dGreenOffset, dBlueOffset);                

        elseif dRedOffset == 0 && dGreenOffset ~= 0 && dBlueOffset ~= 0

            aRedBuffer   = zeros(size(fusionBuffer('get', [], dGreenOffset)));  
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset )); 
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
                        
            if isVsplash('get') == false
                aRedMipBuffer   = zeros(size(mipFusionBuffer('get', [], dGreenOffset)));
                aGreenMipBuffer = squeeze(mipFusionBuffer('get', [], dGreenOffset));  
                aBlueMipBuffer  = squeeze(mipFusionBuffer('get', [], dBlueOffset )); 
            end

            if dGreenMin < dBlueMin
                aRedBuffer(aRedBuffer==0) = dGreenMin;
                if isVsplash('get') == false
                    aRedMipBuffer(aRedMipBuffer==0) = dGreenMin;
                end
            else
                aRedBuffer(aRedBuffer==0) = dBlueMin;
                if isVsplash('get') == false
                    aRedMipBuffer(aRedMipBuffer==0) = dBlueMin;
                end
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            
            dIntensity = (1/dBufferMax)*4;
            
            if isVsplash('get') == false
                if ~isempty(aRedMipBuffer) && ~isempty(aGreenMipBuffer) && ~isempty(aGreenMipBuffer)
               
                    dMipMin = dBufferMin;
                    dMipMax = max( cat(3, aRedMipBuffer, aGreenMipBuffer, aBlueMipBuffer), [], 'all');
                    dMipIntensity = (1/dMipMax)*4;        
                else
                    dMipMin = dBufferMin;
                    dMipMax = dBufferMax;
                    dMipIntensity = dIntensity;                      
                end
            end
            
            getRGBcombinedColor('set', 'GB', 0, dGreenOffset, dBlueOffset);

        elseif dRedOffset ~= 0 && dGreenOffset == 0 && dBlueOffset ~= 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset ));   
            aGreenBuffer = zeros(size(fusionBuffer('get', [], dRedOffset)));  
            aBlueBuffer  = squeeze(fusionBuffer('get', [], dBlueOffset )); 

            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
            
            if isVsplash('get') == false
                aRedMipBuffer   = squeeze(mipFusionBuffer('get', [], dRedOffset )); 
                aGreenMipBuffer = zeros(size(mipFusionBuffer('get', [], dRedOffset)));
                aBlueMipBuffer  = squeeze(mipFusionBuffer('get', [], dBlueOffset )); 
            end

            if dRedMin < dBlueMin
                aGreenBuffer(aGreenBuffer==0) = dRedMin;
                if isVsplash('get') == false
                    aGreenMipBuffer(aGreenMipBuffer==0) = dRedMin;
                end
            else
                aGreenBuffer(aGreenBuffer==0) = dBlueMin;
                if isVsplash('get') == false
                    aGreenMipBuffer(aGreenMipBuffer==0) = dBlueMin;
                end
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            
            dIntensity = (1/dBufferMax)*4;
            
            if isVsplash('get') == false
                if ~isempty(aRedMipBuffer) && ~isempty(aGreenMipBuffer) && ~isempty(aGreenMipBuffer)
                    dMipMin = dBufferMin;
                    dMipMax = max( cat(3, aRedMipBuffer, aGreenMipBuffer, aBlueMipBuffer), [], 'all');
                    dMipIntensity = (1/dMipMax)*4;  
                else
                    dMipMin = dBufferMin;
                    dMipMax = dBufferMax;
                    dMipIntensity = dIntensity;                      
                end
            end

            getRGBcombinedColor('set', 'RB', dRedOffset, 0, dBlueOffset); 

        elseif dRedOffset ~= 0 && dGreenOffset ~= 0 && dBlueOffset == 0

            aRedBuffer   = squeeze(fusionBuffer('get', [], dRedOffset ));   
            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset ));  
            aBlueBuffer  = zeros(size(fusionBuffer('get', [], dRedOffset))); 
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 

            if isVsplash('get') == false
                aRedMipBuffer   = squeeze(mipFusionBuffer('get', [], dRedOffset )); 
                aGreenMipBuffer = squeeze(mipFusionBuffer('get', [], dGreenOffset )); 
                aBlueMipBuffer  = zeros(size(mipFusionBuffer('get', [], dRedOffset)));
            end

            if dRedMin < dGreenMin
                aBlueBuffer(aBlueBuffer==0) = dRedMin;
                if isVsplash('get') == false
                    aBlueMipBuffer(aBlueMipBuffer==0) = dRedMin;
                end
            else
                aBlueBuffer(aBlueBuffer==0) = dGreenMin;
                if isVsplash('get') == false
                    aBlueMipBuffer(aBlueMipBuffer==0) = dGreenMin;
                end
            end                

            dBufferMin = min( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            dBufferMax = max( cat(3, aRedBuffer, aGreenBuffer, aBlueBuffer), [], 'all');
            
            dIntensity = (1/dBufferMax)*4;
            
            if isVsplash('get') == false
                if ~isempty(aRedMipBuffer) && ~isempty(aGreenMipBuffer) && ~isempty(aGreenMipBuffer)
                    dMipMin = dBufferMin;
                    dMipMax = max( cat(3, aRedMipBuffer, aGreenMipBuffer, aBlueMipBuffer), [], 'all');
                    dMipIntensity = (1/dMipMax)*4;
                else
                    dMipMin = dBufferMin;
                    dMipMax = dBufferMax;
                    dMipIntensity = dIntensity;                      
                end                
            end
            
            getRGBcombinedColor('set', 'RG', dRedOffset, dGreenOffset, 0);

        elseif dRedOffset ~= 0 && dGreenOffset == 0 && dBlueOffset == 0

            aRedBuffer = squeeze(fusionBuffer('get', [], dRedOffset ));    
            if isVsplash('get') == false
                aRedMipBuffer = squeeze(mipFusionBuffer('get', [], dRedOffset )); 
            end
            
            dRedMin = min(aRedBuffer, [], 'all');
            dRedMax = max(aRedBuffer, [], 'all'); 
            
            dGreenMin = 0;
            dGreenMax = 0;            
            
            dBlueMin = 0;
            dBlueMax = 0; 
            
            dBufferMin = min( aRedBuffer, [], 'all');
            dBufferMax = max( aRedBuffer, [], 'all');
            
            dIntensity = (1/dBufferMax);
            
            if isVsplash('get') == false
                dMipMin = dBufferMin;
                dMipMax = max( aRedMipBuffer, [], 'all');
                dMipIntensity = (1/dMipMax);
            end
            
            getRGBcombinedColor('set', 'R', dRedOffset, 0, 0);

        elseif dRedOffset == 0 && dGreenOffset ~= 0 && dBlueOffset == 0

            aGreenBuffer = squeeze(fusionBuffer('get', [], dGreenOffset ));                                  
            if isVsplash('get') == false
                aGreenMipBuffer = squeeze(mipFusionBuffer('get', [], dGreenOffset )); 
            end
            
            dRedMin = 0;
            dRedMax = 0; 
            
            dGreenMin = min(aGreenBuffer, [], 'all');
            dGreenMax = max(aGreenBuffer, [], 'all');            
            
            dBlueMin = 0;
            dBlueMax = 0; 
            
            dBufferMin = min( aGreenBuffer, [], 'all');
            dBufferMax = max( aGreenBuffer, [], 'all');
            
            dIntensity = (1/dBufferMax);
            
            if isVsplash('get') == false
                dMipMin = dBufferMin;
                dMipMax = max( aGreenMipBuffer, [], 'all');
                dMipIntensity = (1/dMipMax);                    
            end
            
            getRGBcombinedColor('set', 'G', 0, dGreenOffset, 0);

        elseif dRedOffset == 0 && dGreenOffset == 0 && dBlueOffset ~= 0

            aBlueBuffer     = squeeze(fusionBuffer('get', [], dBlueOffset )); 
            if isVsplash('get') == false
                aBlueMipBuffer  = squeeze(mipFusionBuffer('get', [], dBlueOffset )); 
            end
            
            dRedMin = 0;
            dRedMax = 0; 
            
            dGreenMin = 0;
            dGreenMax = 0;            
            
            dBlueMin = min(aBlueBuffer, [], 'all');
            dBlueMax = max(aBlueBuffer, [], 'all'); 
            
            dBufferMin = min( aBlueBuffer, [], 'all');
            dBufferMax = max( aBlueBuffer, [], 'all');
            
            dIntensity = (1/dBufferMax);
            
            if isVsplash('get') == false
                dMipMin = dBufferMin;
                dMipMax = max( aBlueMipBuffer, [], 'all');
                dMipIntensity = (1/dMipMax);
            end
            
            getRGBcombinedColor('set', 'B', 0, 0, dBlueOffset);

        else
            getRGBcombinedColor('set', '', [], [], []);  
            getRGBcombinedBufferMinMax('set', [], []);
            getRGBmipCombinedBufferMinMax('set', [], []);                 
        end

        if ~isempty(getRGBcombinedColor('get'))

            getRGBcombinedBufferMinMax('set', dBufferMin, dBufferMax);
            if isVsplash('get') == false
                getRGBmipCombinedBufferMinMax('set', dMipMin, dMipMax); 
            else
                getRGBmipCombinedBufferMinMax('set', [], []); 
            end

            scaledRGBColorIntensity('set', [], 'red', 'Coronal' , dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'red', 'Sagittal', dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'red', 'Axial'   , dIntensity, dBufferMin);
            if isVsplash('get') == false
                scaledRGBColorIntensity('set', [], 'red', 'Mip'     , dMipIntensity, dBufferMin);
            end

            scaledRGBColorIntensity('set', [], 'green', 'Coronal' , dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'green', 'Sagittal', dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'green', 'Axial'   , dIntensity, dBufferMin);
            if isVsplash('get') == false
                scaledRGBColorIntensity('set', [], 'green', 'Mip'     , dMipIntensity, dBufferMin);
            end

            scaledRGBColorIntensity('set', [], 'blue', 'Coronal' , dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'blue', 'Sagittal', dIntensity, dBufferMin);
            scaledRGBColorIntensity('set', [], 'blue', 'Axial'   , dIntensity, dBufferMin);                
            if isVsplash('get') == false
                scaledRGBColorIntensity('set', [], 'blue', 'Mip'     , dMipIntensity, dBufferMin);
            end

            scaledRGBColorWindow('set', [], 'red', 'Coronal' , dRedMin, dRedMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'red', 'Sagittal', dRedMin, dRedMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'red', 'Axial'   , dRedMin, dRedMax, dBufferMin);
            if isVsplash('get') == false
                scaledRGBColorWindow('set', [], 'red', 'Mip' , dMipMin, dMipMax, dBufferMin);
            end

            scaledRGBColorWindow('set', [], 'green', 'Coronal' , dGreenMin, dGreenMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'green', 'Sagittal', dGreenMin, dGreenMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'green', 'Axial'   , dGreenMin, dGreenMax, dBufferMin);
            if isVsplash('get') == false
                scaledRGBColorWindow('set', [], 'green', 'Mip' , dMipMin, dMipMax, dBufferMin);
            end

            scaledRGBColorWindow('set', [], 'blue', 'Coronal' , dBlueMin, dBlueMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'blue', 'Sagittal', dBlueMin, dBlueMax, dBufferMin);
            scaledRGBColorWindow('set', [], 'blue', 'Axial'   , dBlueMin, dBlueMax, dBufferMin);                
            if isVsplash('get') == false
                scaledRGBColorWindow('set', [], 'blue', 'Mip' , dMipMin, dMipMax, dBufferMin);                
            end            
        end
    end
end