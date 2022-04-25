function setFusionNormalizeToLiverCallback(~, ~)
%function setFusionNormalizeToLiverCallback(~, ~)
%Normalize 2D combined RGB fusion intensity to liver.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
    
    releaseRoiWait();
    
    setCrossVisibility(false);
    
    gpRoi = images.roi.Rectangle(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
    
    set(gpRoi, 'Color', [0 1 1]);
    
    if size(dicomBuffer('get'), 3) == 1
        roiSetAxeBorder(true, axePtr('get', [], get(uiSeriesPtr('get'), 'Value')));
        
        set(gpRoi, 'Position', [180 140 25 8]);         
    else
        roiSetAxeBorder(true, axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));    
        
        set(gpRoi, 'Position', [180 140 25 8]);         
    end
        
    hMenuItems = get(gpRoi.UIContextMenu, 'Children');  % Get the menu item handles
    
    for mm=1:numel(hMenuItems)
        delete(hMenuItems(mm));
    end
    
    uimenu(gpRoi.UIContextMenu, 'Label', 'Apply Normalization', 'Callback', @setFusionNormalizeToLiver);    
    
    function setFusionNormalizeToLiver(~, ~)
        
        dRedMean   = [];
        dGreenMean = [];
        dBlueMean  = [];

        tInput = inputTemplate('get');        
        
        if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries

                imf = squeeze(fusionBuffer('get', [], rr));    

                if ~isempty(imf)             
                    imAxeF = imAxeFPtr('get', [], rr);
                    if ~isempty(imAxeF)                     
                        atFuseMetaData = tInput(rr).atDicomInfo;

                        imCData = imf(:,:);
                        imMask = createMask(gpRoi, imCData);         
                        imCDataMasked = imCData(imMask);
                        
                        dScale = 1;

                        switch lower(atFuseMetaData{1}.Modality)

                            case {'pt', 'nm'}

                                sUnit = getSerieUnitValue(rr);   

                                if strcmpi(sUnit, 'SUV') 
                                    dScale = tInput(rr).tQuant.tSUV.dScale;
                                end
                        end
                                                
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
                            dRedMean = mean(double(imCDataMasked), 'all') * dScale;

                        end

                        if colormap(imAxeF.Parent) == aGreenColorMap
                            dGreenMean = mean(double(imCDataMasked), 'all') * dScale;
                                   
                        end

                        if colormap(imAxeF.Parent) == aBlueColorMap
                            dBlueMean = mean(double(imCDataMasked), 'all') * dScale;                                      
                        end  
                    end
                end
            end
        else % 3D 
            iCoronal  = sliceNumber('get', 'coronal' );
            
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                
                imf = squeeze(fusionBuffer('get', [], rr));    

                if ~isempty(imf)   
                    imCoronalF  = imCoronalFPtr ('get', [], rr);
                    imSagittalF = imSagittalFPtr('get', [], rr);
                    imAxialF    = imAxialFPtr   ('get', [], rr);

                    if ~isempty(imCoronalF)  && ...
                       ~isempty(imSagittalF) && ...
                       ~isempty(imAxialF) 

                        atFuseMetaData = tInput(rr).atDicomInfo;

                        imCData = permute(imf(iCoronal,:,:), [3 2 1]);
                        imMask = createMask(gpRoi, imCData);         
                        imCDataMasked{1} = imCData(imMask);

                        if iCoronal > 1 
                            imCData = permute(imf(iCoronal-1,:,:), [3 2 1]);
                            imMask = createMask(gpRoi, imCData);         
                            imCDataMasked{2} = imCData(imMask);
                        end
                        
                        if iCoronal+1 < size(imf, 1)
                            imCData = permute(imf(iCoronal+1,:,:), [3 2 1]);
                            imMask = createMask(gpRoi, imCData);         
                            imCDataMasked{3} = imCData(imMask);                        
                        end
                        
                        dScale = 1;

                        switch lower(atFuseMetaData{1}.Modality)

                            case {'pt', 'nm'}

                                sUnit = getSerieUnitValue(rr);   

                                if strcmpi(sUnit, 'SUV') 
                                    dScale = tInput(rr).tQuant.tSUV.dScale;
                                end
                        end
                                                
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
                            dRedMean = mean(double(cat(1,imCDataMasked{:})), 'all') * dScale;

                        end

                        if colormap(imCoronalF.Parent) == aGreenColorMap
                            dGreenMean = mean(double(cat(1,imCDataMasked{:})), 'all') * dScale;
                                   
                        end

                        if colormap(imCoronalF.Parent) == aBlueColorMap
                            dBlueMean = mean(double(cat(1,imCDataMasked{:})), 'all') * dScale;                                      
                        end                                                

                    end
                end
            end                
        end    
        
        if ~isempty(dRedMean)   && ...
           ~isempty(dGreenMean) && ...               
           ~isempty(dBlueMean)
          
            dRMultiplier = 1;
            dGMultiplier = 1;
            dBMultiplier = 1;
            
            if dRedMean > dGreenMean && ... % Red has a higher uptake
               dRedMean > dBlueMean 
                dGMultiplier = dRedMean/dGreenMean;
                dBMultiplier = dRedMean/dBlueMean;
            end            
            
            if dGreenMean > dRedMean && ... % Green has a higher uptake
               dGreenMean > dBlueMean 
                dRMultiplier = dGreenMean/dRedMean;
                dBMultiplier = dGreenMean/dBlueMean;           
            end            
            
            if dBlueMean > dRedMean && ... % Blue has a higher uptake
               dBlueMean > dGreenMean 
                dRMultiplier = dBlueMean/dRedMean;
                dGMultiplier = dBlueMean/dGreenMean;             
            end
            
            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images
                
                [~, dRedAxe]   = scaledRGBColorIntensity('get', [], 'red'  , 'axe');
                [~, dGreenAxe] = scaledRGBColorIntensity('get', [], 'green', 'axe');
                [~, dBlueAxe]  = scaledRGBColorIntensity('get', [], 'blue' , 'axe'); 
                    
                scaledRGBColorIntensity('set', [], 'red'  , 'axe', dRedAxe  *dRMultiplier);
                scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dGMultiplier);
                scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe *dBMultiplier);  
                    
            else  %3D Images
 
                [~, dRedCoronal]   = scaledRGBColorIntensity('get', [], 'red'  , 'coronal');
                [~, dGreenCoronal] = scaledRGBColorIntensity('get', [], 'green', 'coronal');
                [~, dBlueCoronal]  = scaledRGBColorIntensity('get', [], 'blue' , 'coronal');

                [~, dRedSagittal]   = scaledRGBColorIntensity('get', [], 'red'  , 'sagittal');
                [~, dGreenSagittal] = scaledRGBColorIntensity('get', [], 'green', 'sagittal');
                [~, dBlueSagittal]  = scaledRGBColorIntensity('get', [], 'blue' , 'sagittal');

                [~, dRedAxial]   = scaledRGBColorIntensity('get', [], 'red'  , 'axial');
                [~, dGreenAxial] = scaledRGBColorIntensity('get', [], 'green', 'axial');
                [~, dBlueAxial]  = scaledRGBColorIntensity('get', [], 'blue' , 'axial'); 

                if link2DMip('get') == true && isVsplash('get') == false 
                    [~, dRedMip]   = scaledRGBColorIntensity('get', [], 'red'  , 'mip');
                    [~, dGreenMip] = scaledRGBColorIntensity('get', [], 'green', 'mip');
                    [~, dBlueMip]  = scaledRGBColorIntensity('get', [], 'blue' , 'mip');                  
                end

                scaledRGBColorIntensity('set', [], 'red'  , 'coronal' , dRedCoronal *dRMultiplier);
                scaledRGBColorIntensity('set', [], 'red'  , 'sagittal', dRedSagittal*dRMultiplier);
                scaledRGBColorIntensity('set', [], 'red'  , 'axial'   , dRedAxial   *dRMultiplier);

                scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal *dGMultiplier);
                scaledRGBColorIntensity('set', [], 'green', 'sagittal', dGreenSagittal*dGMultiplier);
                scaledRGBColorIntensity('set', [], 'green', 'axial'   , dGreenAxial   *dGMultiplier);

                scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal *dBMultiplier);
                scaledRGBColorIntensity('set', [], 'blue' , 'sagittal', dBlueSagittal*dBMultiplier);
                scaledRGBColorIntensity('set', [], 'blue' , 'axial'   , dBlueAxial   *dBMultiplier);

                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorIntensity('set', [], 'red'  , 'mip' , dRedMip  *dRMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dGMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip *dBMultiplier);
                end
                
                refreshImages();
                
                isRGBFusionNormalizeToLiver('set', true);
            end       
        
        end
        
        if crossActivate('get') == true
            setCrossVisibility(true);
        end
            
        roiSetAxeBorder(false);    
        
        delete(gpRoi);
    end
        
end