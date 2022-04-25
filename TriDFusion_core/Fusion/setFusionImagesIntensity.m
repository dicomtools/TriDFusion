function setFusionImagesIntensity(~, ~)
%function setFusionImagesIntensity(~, ~)
%Set Fusion Images Intensity.
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

    if isFusion('get') == true
        
        tInput = inputTemplate('get');
        
        gdRedOffset   = false;
        gdGreenOffset = false;
        gdBlueOffset  = false;
    
        gdNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
        
        % Find RGB Combination
        
         if invertColor('get')
            aRedColorMap   = flipud(getRedColorMap());
            aGreenColorMap = flipud(getGreenColorMap());
            aBlueColorMap  = flipud(getBlueColorMap());
        else
            aRedColorMap   = getRedColorMap();
            aGreenColorMap = getGreenColorMap();
            aBlueColorMap  = getBlueColorMap();               
         end
                
        if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 % 2D Images     
            
            for rr=1:gdNbFusedSeries

                imAxeF  = imAxeFPtr ('get', [], rr);

                if ~isempty(imAxeF) 
                    

                    if colormap(imAxeF.Parent) == aRedColorMap
                        gdRedOffset = rr;
                    end

                    if colormap(imAxeF.Parent) == aGreenColorMap
                        gdGreenOffset = rr;
                    end

                    if colormap(imAxeF.Parent) == aBlueColorMap
                        gdBlueOffset  = rr;                                      
                    end 

                end
            end 
        else            
            for rr=1:gdNbFusedSeries

                imCoronalF  = imCoronalFPtr ('get', [], rr);
                imSagittalF = imSagittalFPtr('get', [], rr);
                imAxialF    = imAxialFPtr   ('get', [], rr);

                if ~isempty(imCoronalF) && ...
                   ~isempty(imSagittalF) && ...
                   ~isempty(imAxialF) 

                    if colormap(imCoronalF.Parent) == aRedColorMap
                        gdRedOffset   = rr;
                    end

                    if colormap(imCoronalF.Parent) == aGreenColorMap
                        gdGreenOffset = rr;
                    end

                    if colormap(imCoronalF.Parent) == aBlueColorMap
                        gdBlueOffset  = rr;                                      
                    end 

                end

            end            
        end
        
        % Find RGB Combination
        
        if gdRedOffset ~= 0 && gdGreenOffset ~= 0 && gdBlueOffset ~= 0
           gsCombination = 'RGB';             

        elseif gdRedOffset == 0 && gdGreenOffset ~= 0 && gdBlueOffset ~= 0
           gsCombination = 'GB';

        elseif gdRedOffset ~= 0 && gdGreenOffset == 0 && gdBlueOffset ~= 0
           gsCombination = 'RB';

        elseif gdRedOffset ~= 0 && gdGreenOffset ~= 0 && gdBlueOffset == 0
           gsCombination = 'RG';

        elseif gdRedOffset ~= 0 && gdGreenOffset == 0 && gdBlueOffset == 0
           gsCombination = 'R';

        elseif gdRedOffset == 0 && gdGreenOffset ~= 0 && gdBlueOffset == 0
           gsCombination = 'G';

        elseif gdRedOffset == 0 && gdGreenOffset ~= 0 && gdBlueOffset == 0
           gsCombination = 'B';

        else
            gsCombination = '';                   
        end
               
        if isCombineMultipleFusion('get') == true

            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 % 2D Images
                               
                if strcmpi(gsCombination, 'RGB')
                    
                    [~, dRedAxe]   = scaledRGBColorIntensity('get', [], 'red'  , 'axe');
                    [~, dGreenAxe] = scaledRGBColorIntensity('get', [], 'green', 'axe');
                    [~, dBlueAxe]  = scaledRGBColorIntensity('get', [], 'blue' , 'axe');   
                    
                elseif strcmpi(gsCombination, 'GB')
                    
                    [~, dGreenAxe] = scaledRGBColorIntensity('get', [], 'green', 'axe');
                    [~, dBlueAxe]  = scaledRGBColorIntensity('get', [], 'blue' , 'axe');   
                    
                elseif strcmpi(gsCombination, 'RB')
                    
                    [~, dRedAxe]   = scaledRGBColorIntensity('get', [], 'red'  , 'axe');
                    [~, dBlueAxe]  = scaledRGBColorIntensity('get', [], 'blue' , 'axe');   
                    
                elseif strcmpi(gsCombination, 'RG')
                    
                    [~, dRedAxe]   = scaledRGBColorIntensity('get', [], 'red'  , 'axe');
                    [~, dGreenAxe] = scaledRGBColorIntensity('get', [], 'green', 'axe');
                
                elseif strcmpi(gsCombination, 'R')
                    
                    [~, dRedAxe]   = scaledRGBColorIntensity('get', [], 'red'  , 'axe');  
                
                elseif strcmpi(gsCombination, 'G')
                    
                    [~, dGreenAxe] = scaledRGBColorIntensity('get', [], 'green', 'axe');
                
                elseif strcmpi(gsCombination, 'B')
                    
                    [~, dBlueAxe]  = scaledRGBColorIntensity('get', [], 'blue' , 'axe');                     
                end                
                
                
            else % 3D Images
                
                if strcmpi(gsCombination, 'RGB')
                    
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
                    
                elseif strcmpi(gsCombination, 'GB')
                    
                    [~, dGreenCoronal] = scaledRGBColorIntensity('get', [], 'green', 'coronal');
                    [~, dBlueCoronal]  = scaledRGBColorIntensity('get', [], 'blue' , 'coronal');

                    [~, dGreenSagittal] = scaledRGBColorIntensity('get', [], 'green', 'sagittal');
                    [~, dBlueSagittal]  = scaledRGBColorIntensity('get', [], 'blue' , 'sagittal');

                    [~, dGreenAxial] = scaledRGBColorIntensity('get', [], 'green', 'axial');
                    [~, dBlueAxial]  = scaledRGBColorIntensity('get', [], 'blue' , 'axial'); 

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dGreenMip] = scaledRGBColorIntensity('get', [], 'green', 'mip');
                        [~, dBlueMip]  = scaledRGBColorIntensity('get', [], 'blue' , 'mip');                  
                    end 
                    
                elseif strcmpi(gsCombination, 'RB')
                    
                    [~, dRedCoronal]   = scaledRGBColorIntensity('get', [], 'red'  , 'coronal');
                    [~, dBlueCoronal]  = scaledRGBColorIntensity('get', [], 'blue' , 'coronal');

                    [~, dRedSagittal]   = scaledRGBColorIntensity('get', [], 'red'  , 'sagittal');
                    [~, dBlueSagittal]  = scaledRGBColorIntensity('get', [], 'blue' , 'sagittal');

                    [~, dRedAxial]   = scaledRGBColorIntensity('get', [], 'red'  , 'axial');
                    [~, dBlueAxial]  = scaledRGBColorIntensity('get', [], 'blue' , 'axial'); 

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dRedMip]   = scaledRGBColorIntensity('get', [], 'red'  , 'mip');
                        [~, dBlueMip]  = scaledRGBColorIntensity('get', [], 'blue' , 'mip');                  
                    end  
                    
                elseif strcmpi(gsCombination, 'RG')
                    
                    [~, dRedCoronal]   = scaledRGBColorIntensity('get', [], 'red'  , 'coronal');
                    [~, dGreenCoronal] = scaledRGBColorIntensity('get', [], 'green', 'coronal');

                    [~, dRedSagittal]   = scaledRGBColorIntensity('get', [], 'red'  , 'sagittal');
                    [~, dGreenSagittal] = scaledRGBColorIntensity('get', [], 'green', 'sagittal');

                    [~, dRedAxial]   = scaledRGBColorIntensity('get', [], 'red'  , 'axial');
                    [~, dGreenAxial] = scaledRGBColorIntensity('get', [], 'green', 'axial');

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dRedMip]   = scaledRGBColorIntensity('get', [], 'red'  , 'mip');
                        [~, dGreenMip] = scaledRGBColorIntensity('get', [], 'green', 'mip');
                    end                    
                elseif strcmpi(gsCombination, 'R')
                    
                    [~, dRedCoronal]   = scaledRGBColorIntensity('get', [], 'red'  , 'coronal');
                    [~, dRedSagittal]  = scaledRGBColorIntensity('get', [], 'red'  , 'sagittal');
                    [~, dRedAxial]     = scaledRGBColorIntensity('get', [], 'red'  , 'axial');

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dRedMip] = scaledRGBColorIntensity('get', [], 'red'  , 'mip');
                    end                    
                    
                elseif strcmpi(gsCombination, 'G')
                    [~, dGreenCoronal]  = scaledRGBColorIntensity('get', [], 'green', 'coronal');
                    [~, dGreenSagittal] = scaledRGBColorIntensity('get', [], 'green', 'sagittal');
                    [~, dGreenAxial]    = scaledRGBColorIntensity('get', [], 'green', 'axial');

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dGreenMip] = scaledRGBColorIntensity('get', [], 'green', 'mip');
                    end                    
                elseif strcmpi(gsCombination, 'B')
                    [~, dBlueCoronal]  = scaledRGBColorIntensity('get', [], 'blue' , 'coronal');
                    [~, dBlueSagittal] = scaledRGBColorIntensity('get', [], 'blue' , 'sagittal');
                    [~, dBlueAxial]    = scaledRGBColorIntensity('get', [], 'blue' , 'axial'); 

                    if link2DMip('get') == true && isVsplash('get') == false 
                        [~, dBlueMip]  = scaledRGBColorIntensity('get', [], 'blue' , 'mip');                  
                    end                    
                end
                
            end
        else
            for jj=1:gdNbFusedSeries
                aFusionBuffer{jj} = fusionBuffer('get', [], jj);
                if link2DMip('get') == true && isVsplash('get') == false
                    aMipFusionBuffer{jj} = mipFusionBuffer('get', [], jj);
                end                
            end
        end
                           
        dlgImagesIntensity = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-465/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-445/2) ...
                                465 ...
                                445 ...
                                ],...
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Multi-Fusion RGB Intensity & Min\Max'...
                   ); 

            axes(dlgImagesIntensity, ...
                 'Units'   , 'pixels', ...
                 'Position', get(dlgImagesIntensity, 'Position'), ...
                 'Color'   , viewerBackgroundColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...             
                 'Visible' , 'off'...             
                 ); 
             
         uicontrol(dlgImagesIntensity,...
                  'String','Reset',...
                  'Position',[20 390 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resetFusionIntensityCallback...
                  );
              
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Intensity', ...
                      'FontWeight', 'Bold',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 340 70 20]...
                      ); 
                  
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Min\Max', ...
                      'FontWeight', 'Bold',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [285 340 70 20]...
                      );                                    
        % Red   
          
        if strcmpi(gsCombination, 'RGB') || ...
           strcmpi(gsCombination, 'RB')  || ...
           strcmpi(gsCombination, 'RG')  || ...
           strcmpi(gsCombination, 'R')   
            sRedEnable = 'on';
        else
            sRedEnable = 'off';            
        end 
        
        [bIsRedEnable, dRedMinBackup] = isRGBFusionRedEnable('get');
                
        if strcmpi(sRedEnable, 'on')
            
            if isCombineMultipleFusion('get') == true
                                        
                if size(fusionBuffer('get', [], gdRedOffset), 3) == 1
                    [~, dRedMin, dRedMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'red', 'Axe');
                else                        
                    [~, dRedMin, dRedMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'red', 'Coronal');
                end
                                
                if bIsRedEnable == false
                    dRedMin = dRedMinBackup;
                end
            else
                dRedMin = min(fusionBuffer('get', [], gdRedOffset), [], 'all');
                dRedMax = max(fusionBuffer('get', [], gdRedOffset), [], 'all');
            end

            sRedUnitDisplay = getSerieUnitValue(gdRedOffset);                        
            if strcmpi(sRedUnitDisplay, 'SUV') ||  strcmpi(sRedUnitDisplay, 'HU') 
                
                sChkRedChkEnable = 'on';
                sChkRedTxtEnable = 'Inactive';
                
                if strcmpi(sRedUnitDisplay, 'HU') 
                    sRedUnitDisplay = 'Window Level';            

                    [dRedWindow, dRedLevel] = computeWindowMinMax(dRedMax, dRedMin);
                else
                    dRedMax = dRedMax*tInput(gdRedOffset).tQuant.tSUV.dScale;
                    dRedMin = dRedMin*tInput(gdRedOffset).tQuant.tSUV.dScale;
                end
            else
                sChkRedChkEnable = 'off';                
                sChkRedTxtEnable = 'on';
            end

            if contains(sRedUnitDisplay, 'SUV')
                sSUVtype = viewerSUVtype('get');
                gsRedUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                gsRedUnitType = sprintf('Unit in %s', sRedUnitDisplay);
            end
            
            if contains(gsRedUnitType, 'Window Level')
                sRedMinValue = num2str(dRedLevel);
                sRedMaxValue = num2str(dRedWindow);
            else
                sRedMinValue = num2str(dRedMin);
                sRedMaxValue = num2str(dRedMax);
            end
            
        else
            gsRedUnitType = 'N/A';
            
            sRedMinValue = '0';
            sRedMaxValue = '0'; 
            
            sChkRedChkEnable = 'off';                
            sChkRedTxtEnable = 'on';            
        end
        
        uiChkFusionRedEnable = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkRedChkEnable,...
                      'value'   , bIsRedEnable,...
                      'position', [20 295 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionRedEnableCallback...
                      );

             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Enable',...
                      'horizontalalignment', 'left',...
                      'position', [40 292 140 20],...
                      'Enable', sChkRedTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionRedEnableCallback...
                      );  
                              
        if bIsRedEnable == false
            sChkRedChkEnable = 'off';                
            sChkRedTxtEnable = 'on'; 
            sRedEnable = 'off';
        end
                              
        uiChkFusionRedUnitType = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkRedChkEnable,...
                      'value'   , 1,...
                      'position', [285 295 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionRedUnitTypeCallback...
                      );

        uiTxtFusionRedUnitType = ...
             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , gsRedUnitType,...
                      'horizontalalignment', 'left',...
                      'position', [305 292 140 20],...
                      'Enable', sChkRedTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionRedUnitTypeCallback...
                      );         
         
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Min', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [285 275 75 20]...
                      );
                   
        uiEdtFusionRedMinWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sRedEnable,...
                     'Background', 'white',...
                     'string'    , sRedMinValue,...
                     'position'  , [285 255 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionRedWindowCallback...
                     );
                 
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Max', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [370 275 75 20]...
                      );
                  
         uiEdtFusionRedMaxWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sRedEnable,...
                     'Background', 'white',...
                     'string'    , sRedMaxValue,...
                     'position'  , [370 255 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionRedWindowCallback...
                     );         
         
         dDefaultRMultiplier = 0.5;
         
         dRMultiplier = sliderToImagesMultipler(dDefaultRMultiplier);
         
         uiTxtFusionRedIntensity = ...
             uicontrol(dlgImagesIntensity,...
                       'style'   , 'text',...
                       'string'  , sprintf('Red (x %d)', dRMultiplier), ...
                       'horizontalalignment', 'left',...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...                   
                       'position', [20 275 160 20]...
                       );
                      
         uiSliderFusionRedIntensity = ...
             uicontrol(dlgImagesIntensity, ...
                      'Style'   , 'Slider', ...
                      'Position', [20 255 160 14], ...
                      'Value'   , dDefaultRMultiplier, ...
                      'Enable'  , sRedEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                     
                      'CallBack', @sliderFusionRedIntensityCallback ...
                      );
         addlistener(uiSliderFusionRedIntensity, 'Value', 'PreSet', @sliderFusionRedIntensityCallback); 
         
         uiEditFusionRedIntensity = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sRedEnable,...
                     'Background', 'white',...
                     'string'    , num2str(dRMultiplier),...
                     'position'  , [190 255 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionRedIntensityCallback...
                     );  
                 
         % Green   
          
        if strcmpi(gsCombination, 'RGB') || ...
            strcmpi(gsCombination, 'GB')  || ...
            strcmpi(gsCombination, 'RG')  || ...
            strcmpi(gsCombination, 'G')   
            sGreenEnable = 'on';
        else
            sGreenEnable = 'off';            
        end 
        
        [bIsGreenEnable, dGreenMinBackup] = isRGBFusionGreenEnable('get');
        
        if strcmpi(sGreenEnable, 'on')
            
            if isCombineMultipleFusion('get') == true
                
                if size(fusionBuffer('get', [], gdGreenOffset), 3) == 1
                    [~, dGreenMin, dGreenMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'green', 'Axe');
                else                        
                    [~, dGreenMin, dGreenMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'green', 'Coronal');
                end
                
                if bIsGreenEnable == false
                    dGreenMin = dGreenMinBackup;
                end                
                
            else
                dGreenMin = min(fusionBuffer('get', [], gdGreenOffset), [], 'all');
                dGreenMax = max(fusionBuffer('get', [], gdGreenOffset), [], 'all');
            end

            sGreenUnitDisplay = getSerieUnitValue(gdGreenOffset);                        
            if strcmpi(sGreenUnitDisplay, 'SUV') ||  strcmpi(sGreenUnitDisplay, 'HU') 
                
                sChkGreenChkEnable = 'on';
                sChkGreenTxtEnable = 'Inactive';

                if strcmpi(sGreenUnitDisplay, 'HU') 
                    sGreenUnitDisplay = 'Window Level';            

                    [dGreenWindow, dGreenLevel] = computeWindowMinMax(dGreenMax, dGreenMin);
                else
                    dGreenMax = dGreenMax*tInput(gdGreenOffset).tQuant.tSUV.dScale;
                    dGreenMin = dGreenMin*tInput(gdGreenOffset).tQuant.tSUV.dScale;
                end
            else
                sChkGreenChkEnable = 'off';
                sChkGreenTxtEnable = 'on';
            end

            if contains(sGreenUnitDisplay, 'SUV')
                sSUVtype = viewerSUVtype('get');
                gsGreenUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                gsGreenUnitType = sprintf('Unit in %s', sGreenUnitDisplay);
            end
            
            if contains(gsGreenUnitType, 'Window Level')
                sGreenMinValue = num2str(dGreenLevel);
                sGreenMaxValue = num2str(dGreenWindow);
            else
                sGreenMinValue = num2str(dGreenMin);
                sGreenMaxValue = num2str(dGreenMax);
            end
            
        else
            gsGreenUnitType = 'N/A';
            
            sGreenMinValue = '0';
            sGreenMaxValue = '0'; 
            
            sChkGreenChkEnable = 'off';
            sChkGreenTxtEnable = 'on';            
        end
        
        uiChkFusionGreenEnable = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkGreenChkEnable,...
                      'value'   , bIsGreenEnable,...
                      'position', [20 220 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionGreenEnableCallback...
                      );

             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Enable',...
                      'horizontalalignment', 'left',...
                      'position', [40 217 140 20],...
                      'Enable', sChkGreenTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionGreenEnableCallback...
                      ); 
                  
        if bIsGreenEnable == false
            
            sChkGreenChkEnable = 'off';                
            sChkGreenTxtEnable = 'on'; 
            sGreenEnable = 'off';
        end
        
        uiChkFusionGreenUnitType = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkGreenChkEnable,...
                      'value'   , 1,...
                      'position', [285 220 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionGreenUnitTypeCallback...
                      );

        uiTxtFusionGreenUnitType = ...
             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , gsGreenUnitType,...
                      'horizontalalignment', 'left',...
                      'position', [305 217 140 20],...
                      'Enable', sChkGreenTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionGreenUnitTypeCallback...
                      ); 
                  
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Min', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [285 200 75 20]...
                      );
                   
         uiEdtFusionGreenMinWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sGreenEnable,...
                     'Background', 'white',...
                     'string'    , sGreenMinValue,...
                     'position'  , [285 180 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionGreenWindowCallback...
                     );
                 
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Max', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [370 200 75 20]...
                      );
                  
         uiEdtFusionGreenMaxWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sGreenEnable,...
                     'Background', 'white',...
                     'string'    , sGreenMaxValue,...
                     'position'  , [370 180 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionGreenWindowCallback...
                     );
                 
         dDefaultGMultiplier = 0.5;
         
         dGMultiplier = sliderToImagesMultipler(dDefaultGMultiplier);
         
         uiTxtFusionGreenIntensity = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , sprintf('Green (x %d)', dGMultiplier), ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 200 160 20]...
                      );
                      
         uiSliderFusionGreenIntensity = ...
             uicontrol(dlgImagesIntensity, ...
                      'Style'   , 'Slider', ...
                      'Position', [20 180 160 14], ...
                      'Value'   , dDefaultGMultiplier, ...
                      'Enable'  , sGreenEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                     
                      'CallBack', @sliderFusionGreenIntensityCallback ...
                      );
         addlistener(uiSliderFusionGreenIntensity, 'Value', 'PreSet', @sliderFusionGreenIntensityCallback); 
         
         uiEditFusionGreenIntensity = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sGreenEnable,...
                     'Background', 'white',...
                     'string'    , num2str(dGMultiplier),...
                     'position'  , [190 180 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionGreenIntensityCallback...
                     );
                 
        % Blue   
        
        if strcmpi(gsCombination, 'RGB') || ...
           strcmpi(gsCombination, 'GB')  || ...
           strcmpi(gsCombination, 'RB')  || ...
           strcmpi(gsCombination, 'B') 
            sBlueEnable = 'on';
        else
            sBlueEnable = 'off';             
        end
        
        [bIsBlueEnable, dBlueMinBackup] = isRGBFusionBlueEnable('get');
        
        if strcmpi(sBlueEnable, 'on')
            
            if isCombineMultipleFusion('get') == true
                
                if size(fusionBuffer('get', [], gdBlueOffset), 3) == 1
                    [~, dBlueMin, dBlueMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'blue', 'Axe');
                else                        
                    [~, dBlueMin, dBlueMax, gdBufferMin] = scaledRGBColorWindow('get', [], 'blue', 'Coronal');
                end
                
                if bIsBlueEnable == false
                    dBlueMin = dBlueMinBackup;
                end  
                
            else
                dBlueMin = min(fusionBuffer('get', [], gdBlueOffset), [], 'all');
                dBlueMax = max(fusionBuffer('get', [], gdBlueOffset), [], 'all');
            end

            sBlueUnitDisplay = getSerieUnitValue(gdBlueOffset);                        
            if strcmpi(sBlueUnitDisplay, 'SUV') ||  strcmpi(sBlueUnitDisplay, 'HU') 
                
                sChkBlueChkEnable = 'on';
                sChkBlueTxtEnable = 'Inactive';

                if strcmpi(sBlueUnitDisplay, 'HU') 
                    sBlueUnitDisplay = 'Window Level';            

                    [dBlueWindow, dBlueLevel] = computeWindowMinMax(dBlueMax, dBlueMin);
                else
                    dBlueMax = dBlueMax*tInput(gdBlueOffset).tQuant.tSUV.dScale;
                    dBlueMin = dBlueMin*tInput(gdBlueOffset).tQuant.tSUV.dScale;
                end
            else
                sChkBlueChkEnable = 'off';                
                sChkBlueTxtEnable = 'on';
            end

            if contains(sBlueUnitDisplay, 'SUV')
                sSUVtype = viewerSUVtype('get');
                gsBlueUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                gsBlueUnitType = sprintf('Unit in %s', sBlueUnitDisplay);
            end
            
            if contains(gsBlueUnitType, 'Window Level')
                sBlueMinValue = num2str(dBlueLevel);
                sBlueMaxValue = num2str(dBlueWindow);
            else
                sBlueMinValue = num2str(dBlueMin);
                sBlueMaxValue = num2str(dBlueMax);
            end
            
        else
            gsBlueUnitType = 'N/A';
            
            sBlueMinValue = '0';
            sBlueMaxValue = '0'; 
            
            sChkBlueChkEnable = 'off';                
            sChkBlueTxtEnable = 'On';            
        end
        
        uiChkFusionBlueEnable = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkBlueChkEnable,...
                      'value'   , bIsBlueEnable,...
                      'position', [20 145 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionBlueEnableCallback...
                      );

             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Enable',...
                      'horizontalalignment', 'left',...
                      'position', [40 142 140 20],...
                      'Enable', sChkBlueTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionBlueEnableCallback...
                      );
                  
        if bIsBlueEnable == false
            
            sChkBlueChkEnable = 'off';                
            sChkBlueTxtEnable = 'on'; 
            sBlueEnable = 'off';
        end
        
        uiChkFusionBlueUnitType = ...
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'checkbox',...
                      'enable'  , sChkBlueChkEnable,...
                      'value'   , 1,...
                      'position', [285 145 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Callback', @chkFusionBlueUnitTypeCallback...
                      );

        uiTxtFusionBlueUnitType = ...
             uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , gsBlueUnitType,...
                      'horizontalalignment', 'left',...
                      'position', [305 142 140 20],...
                      'Enable', sChkBlueTxtEnable,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'ButtonDownFcn', @chkFusionBlueUnitTypeCallback...
                      );
                  
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Min', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [285 125 75 20]...
                      );
                   
         uiEdtFusionBlueMinWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sBlueEnable,...
                     'Background', 'white',...
                     'string'    , sBlueMinValue,...
                     'position'  , [285 105 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionBlueWindowCallback...
                     );
                 
            uicontrol(dlgImagesIntensity,...
                      'style'   , 'text',...
                      'string'  , 'Max', ...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [370 125 75 20]...
                      );
                  
         uiEdtFusionBlueMaxWindow = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sBlueEnable,...
                     'Background', 'white',...
                     'string'    , sBlueMaxValue,...
                     'position'  , [370 105 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionBlueWindowCallback...
                     );
                 
         dDefaultBMultiplier = 0.5;
         
         dBMultiplier = sliderToImagesMultipler(dDefaultBMultiplier);
         
         uiTxtFusionBlueIntensity = ...
                uicontrol(dlgImagesIntensity,...
                          'style'   , 'text',...
                          'string'  , sprintf('Blue (x %d)', dBMultiplier), ...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'position', [20 125 160 20]...
                          );
                      
         uiSliderFusionBlueIntensity = ...
             uicontrol(dlgImagesIntensity, ...
                      'Style'   , 'Slider', ...
                      'Position', [20 105 160 14], ...
                      'Value'   , dDefaultBMultiplier, ...
                      'Enable'  , sBlueEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                     
                      'CallBack', @sliderFusionBlueIntensityCallback ...
                      );
         addlistener(uiSliderFusionBlueIntensity, 'Value', 'PreSet', @sliderFusionBlueIntensityCallback);     
         
         uiEditFusionBlueIntensity = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'enable'    , sBlueEnable,...
                     'Background', 'white',...
                     'string'    , num2str(dBMultiplier),...
                     'position'  , [190 105 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionBlueIntensityCallback...
                     );        
         % RGB    
             
         dDefaultRGBMultiplier = 0.5;
         
         dRGBMultiplier = sliderToImagesMultipler(dDefaultRGBMultiplier);
         
         uiTxtFusionRGBIntensity = ...
                uicontrol(dlgImagesIntensity,...
                          'style'   , 'text',...
                          'string'  , sprintf('All Channels (x %d)', dRGBMultiplier), ...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'position', [20 60 340 20]...
                          );
                      
        uiSliderFusionRGBIntensity = ...
             uicontrol(dlgImagesIntensity, ...
                      'Style'   , 'Slider', ...
                      'Position', [20 40 340 14], ...
                      'Value'   , dDefaultRGBMultiplier, ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                     
                      'CallBack', @sliderFusionRGBIntensityCallback ...
                      );
        addlistener(uiSliderFusionRGBIntensity, 'Value', 'PreSet', @sliderFusionRGBIntensityCallback);              
        
         uiEditFusionRGBIntensity = ...
           uicontrol(dlgImagesIntensity,...
                     'style'     , 'edit',...
                     'Background', 'white',...
                     'string'    , num2str(dRGBMultiplier),...
                     'position'  , [370 40 75 20],...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'Callback'  , @editFusionRGBIntensityCallback...
                     );                   
                  
%        fusionBuffer('set', [], get(uiFusedSeriesPtr('get'), 'Value'));     
%        if link2DMip('get') == true
%            mipFusionBuffer('set', [], get(uiFusedSeriesPtr('get'), 'Value')); 
%        end
        
%        if isPlotContours('get') == true % Deactivate contours
%            setPlotContoursCallback();
%        end
       
    end
    
    function resetFusionIntensityCallback(~, ~)
                   
        if isCombineMultipleFusion('get') == true
            
            try
            set(dlgImagesIntensity, 'Pointer', 'watch');
            drawnow;  

            initCombineRGB();

            catch
                progressBar(1, 'Error:resetFusionIntensityCallback()');           
            end

            set(dlgImagesIntensity, 'Pointer', 'default');
            drawnow;  

            delete(dlgImagesIntensity);

            refreshImages();
        end
    end
        
    function dMultiplier = sliderToImagesMultipler(dSliderMultiplier)
        
        MAX_RATIO = 2;

        dSliderValue = dSliderMultiplier - 0.5;

        dMultiplier = 1+(dSliderValue *MAX_RATIO /0.5);
   
    end

    function chkFusionRedEnableCallback(hObject, ~) % Red
        
        bChkRedEnable = get(uiChkFusionRedEnable, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkRedEnable == false
                bChkRedEnable = true;
            else
                bChkRedEnable = false;
            end
            
            set(uiChkFusionRedEnable, 'Value', bChkRedEnable);
        end
        
        if bChkRedEnable == true
            
            set(uiChkFusionRedUnitType    , 'Enable', 'on'); 
            set(uiTxtFusionRedUnitType    , 'Enable', 'Inactive'); 
            set(uiEdtFusionRedMinWindow   , 'Enable', 'on'); 
            set(uiEdtFusionRedMaxWindow   , 'Enable', 'on'); 
            set(uiSliderFusionRedIntensity, 'Enable', 'on'); 
            set(uiEditFusionRedIntensity  , 'Enable', 'on');  
            
            dNewRedMin = str2double(get(uiEdtFusionRedMinWindow, 'String'));
            dNewRedMax = str2double(get(uiEdtFusionRedMaxWindow, 'String')); 
                        
            if contains(gsRedUnitType, 'SUV') ||  contains(gsRedUnitType, 'Window Level') 

                if contains(gsRedUnitType, 'Window Level') 

                    [dNewRedMax, dNewRedMin] = computeWindowLevel(dNewRedMax, dNewRedMin);
                else
                    dNewRedMax = dNewRedMax/tInput(gdRedOffset).tQuant.tSUV.dScale;
                    dNewRedMin = dNewRedMin/tInput(gdRedOffset).tQuant.tSUV.dScale;
                end
            end            
            
            isRGBFusionRedEnable('set', true);            
            
        else
            set(uiChkFusionRedUnitType    , 'Enable', 'off'); 
            set(uiTxtFusionRedUnitType    , 'Enable', 'on'); 
            set(uiEdtFusionRedMinWindow   , 'Enable', 'off'); 
            set(uiEdtFusionRedMaxWindow   , 'Enable', 'off'); 
            set(uiSliderFusionRedIntensity, 'Enable', 'off'); 
            set(uiEditFusionRedIntensity  , 'Enable', 'off'); 
             
            dNewRedMin = max(fusionBuffer('get', [], gdRedOffset), [], 'all');
            dNewRedMax = max(fusionBuffer('get', [], gdRedOffset), [], 'all'); 
            
            isRGBFusionRedEnable('set', false, str2double(get(uiEdtFusionRedMinWindow, 'String')) );        
            
        end
        
        if isCombineMultipleFusion('get') == true
        
            if size(fusionBuffer('get', [], gdRedOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Coronal' , dNewRedMin, dNewRedMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Sagittal', dNewRedMin, dNewRedMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Axial'   , dNewRedMin, dNewRedMax, gdBufferMin);
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'MIP' , dNewRedMin, dNewRedMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages();        
    end

    function chkFusionRedUnitTypeCallback(hObject, ~) % Red
                        
        bChkRedUnitType = get(uiChkFusionRedUnitType, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkRedUnitType == false
                bChkRedUnitType = true;
            else
                bChkRedUnitType = false;
            end
            
            set(uiChkFusionRedUnitType, 'Value', bChkRedUnitType);
 
        end
        
        sRedUnitDisplay = getSerieUnitValue(gdRedOffset);                        
        if strcmpi(sRedUnitDisplay, 'SUV') ||  strcmpi(sRedUnitDisplay, 'HU') 

            if strcmpi(sRedUnitDisplay, 'HU') 
                
                if bChkRedUnitType == true
                    gsRedUnitType = 'Unit in Window Level';
                else
                    gsRedUnitType = 'Unit in HU';
                end
            end    
                
            if strcmpi(sRedUnitDisplay, 'SUV')
                
                if bChkRedUnitType == true
                    sSUVtype = viewerSUVtype('get');
                    gsRedUnitType = sprintf('Unit in SUV/%s', sSUVtype);
                else
                    gsRedUnitType = 'Unit in BQML';
                end
            end           
            
            set(uiTxtFusionRedUnitType, 'String', gsRedUnitType);
            
        end              
            
        dNewRedMin = str2double(get(uiEdtFusionRedMinWindow, 'String'));
        dNewRedMax = str2double(get(uiEdtFusionRedMaxWindow, 'String'));       
        
        if contains(gsRedUnitType, 'SUV') 
            dNewRedMax = dNewRedMax*tInput(gdRedOffset).tQuant.tSUV.dScale;
            dNewRedMin = dNewRedMin*tInput(gdRedOffset).tQuant.tSUV.dScale; 
            
        elseif contains(gsRedUnitType, 'BQML')
            dNewRedMax = dNewRedMax/tInput(gdRedOffset).tQuant.tSUV.dScale;
            dNewRedMin = dNewRedMin/tInput(gdRedOffset).tQuant.tSUV.dScale;            
            
        elseif contains(gsRedUnitType, 'Window Level') 
            [dNewRedMax, dNewRedMin] = computeWindowMinMax(dNewRedMax, dNewRedMin);
            
        elseif contains(gsRedUnitType, 'HU') 
            [dNewRedMax, dNewRedMin] = computeWindowLevel(dNewRedMax, dNewRedMin);
        end
        
        set(uiEdtFusionRedMinWindow, 'String', num2str(dNewRedMin));
        set(uiEdtFusionRedMaxWindow, 'String', num2str(dNewRedMax));
                        
    end

    function editFusionRedWindowCallback(~, ~) % Red
                    
        dNewRedMin = str2double(get(uiEdtFusionRedMinWindow, 'String'));
        dNewRedMax = str2double(get(uiEdtFusionRedMaxWindow, 'String'));
                
        if contains(gsRedUnitType, 'SUV') ||  contains(gsRedUnitType, 'Window Level') 

            if contains(gsRedUnitType, 'Window Level') 

                [dNewRedMax, dNewRedMin] = computeWindowLevel(dNewRedMax, dNewRedMin);
            else
                dNewRedMax = dNewRedMax/tInput(gdRedOffset).tQuant.tSUV.dScale;
                dNewRedMin = dNewRedMin/tInput(gdRedOffset).tQuant.tSUV.dScale;
            end
        end

        if isCombineMultipleFusion('get') == true
            if size(fusionBuffer('get', [], gdRedOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Coronal' , dNewRedMin, dNewRedMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Sagittal', dNewRedMin, dNewRedMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'Axial'   , dNewRedMin, dNewRedMax, gdBufferMin);
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdRedOffset), 'red', 'MIP' , dNewRedMin, dNewRedMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages();
    end

    function sliderFusionRedIntensityCallback(~, ~) % Red
        
        dSliderMultiplier = get(uiSliderFusionRedIntensity, 'Value');
        dRMultiplier = double(sliderToImagesMultipler(dSliderMultiplier));

        set( uiTxtFusionRedIntensity, 'String', sprintf('Red (x %d)', dRMultiplier) );  
        
        set( uiEditFusionRedIntensity, 'String', num2str(dRMultiplier) );  
         
        editFusionRedIntensity();             
    end

    function editFusionRedIntensityCallback(~, ~) % Red
        
        dEditMultiplier = str2double(get(uiEditFusionRedIntensity, 'String'));
        if ~isnan(dEditMultiplier)
            dRMultiplier = dEditMultiplier;
        end
        
        set( uiEditFusionRedIntensity, 'String', num2str(dRMultiplier) );  
       
        set( uiTxtFusionRedIntensity, 'String', sprintf('Red (x %d)', dRMultiplier) );  
        
        editFusionRedIntensity();         
    end

    function editFusionRedIntensity()
    
        if isCombineMultipleFusion('get') == true
            
            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images
  
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'RB')  || ...
                   strcmpi(gsCombination, 'RG')  || ...
                   strcmpi(gsCombination, 'R')   

                    scaledRGBColorIntensity('set', [], 'red', 'axe', dRedAxe*dRMultiplier);                    
                end 
                
            else  %3D Images          
            
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'RB')  || ...
                   strcmpi(gsCombination, 'RG')  || ...
                   strcmpi(gsCombination, 'R') 
                    
                    scaledRGBColorIntensity('set', [], 'red', 'coronal' , dRedCoronal*dRMultiplier);
                    scaledRGBColorIntensity('set', [], 'red', 'sagittal', dRedSagittal*dRMultiplier);
                    scaledRGBColorIntensity('set', [], 'red', 'axial'   , dRedAxial*dRMultiplier);

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'red', 'mip' , dRedMip*dRMultiplier);
                    end
                end
            end
            
        else
            if gdRedOffset ~= 0
                
                if ~isempty(aFusionBuffer{gdRedOffset})                
                    fusionBuffer('set', aFusionBuffer{gdRedOffset} * dRMultiplier, gdRedOffset);            
                end
                
                if link2DMip('get') == true && isVsplash('get') == false
                    if ~isempty(aMipFusionBuffer{gdRedOffset})
                        mipFusionBuffer('set', aMipFusionBuffer{gdRedOffset} * dRMultiplier, gdRedOffset);
                    end
                end                  
            end
        end
        
        refreshImages();  
    end

    function chkFusionGreenEnableCallback(hObject, ~) % Green
        
        bChkGreenEnable = get(uiChkFusionGreenEnable, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkGreenEnable == false
                bChkGreenEnable = true;
            else
                bChkGreenEnable = false;
            end
            
            set(uiChkFusionGreenEnable, 'Value', bChkGreenEnable);
        end
        
        if bChkGreenEnable == true
            
            set(uiChkFusionGreenUnitType    , 'Enable', 'on'); 
            set(uiTxtFusionGreenUnitType    , 'Enable', 'Inactive'); 
            set(uiEdtFusionGreenMinWindow   , 'Enable', 'on'); 
            set(uiEdtFusionGreenMaxWindow   , 'Enable', 'on'); 
            set(uiSliderFusionGreenIntensity, 'Enable', 'on'); 
            set(uiEditFusionGreenIntensity  , 'Enable', 'on');  
            
            dNewGreenMin = str2double(get(uiEdtFusionGreenMinWindow, 'String'));
            dNewGreenMax = str2double(get(uiEdtFusionGreenMaxWindow, 'String')); 
            
            if contains(gsGreenUnitType, 'SUV') ||  contains(gsGreenUnitType, 'Window Level') 

                if contains(gsGreenUnitType, 'Window Level') 

                    [dNewGreenMax, dNewGreenMin] = computeWindowLevel(dNewGreenMax, dNewGreenMin);
                else
                    dNewGreenMax = dNewGreenMax/tInput(gdGreenOffset).tQuant.tSUV.dScale;
                    dNewGreenMin = dNewGreenMin/tInput(gdGreenOffset).tQuant.tSUV.dScale;
                end
            end            
            
            isRGBFusionGreenEnable('set', true);  
            
        else
            set(uiChkFusionGreenUnitType    , 'Enable', 'off'); 
            set(uiTxtFusionGreenUnitType    , 'Enable', 'on'); 
            set(uiEdtFusionGreenMinWindow   , 'Enable', 'off'); 
            set(uiEdtFusionGreenMaxWindow   , 'Enable', 'off'); 
            set(uiSliderFusionGreenIntensity, 'Enable', 'off'); 
            set(uiEditFusionGreenIntensity  , 'Enable', 'off'); 
            
            dNewGreenMin = max(fusionBuffer('get', [], gdGreenOffset), [], 'all');
            dNewGreenMax = max(fusionBuffer('get', [], gdGreenOffset), [], 'all'); 
            
            isRGBFusionGreenEnable('set', false, str2double(get(uiEdtFusionGreenMinWindow, 'String')) );            
            
        end
        
        if isCombineMultipleFusion('get') == true
        
            if size(fusionBuffer('get', [], gdGreenOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'green', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'green', 'Coronal' , dNewGreenMin, dNewGreenMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'green', 'Sagittal', dNewGreenMin, dNewGreenMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'green', 'Axial'   , dNewGreenMin, dNewGreenMax, gdBufferMin);
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'green', 'MIP' , dNewGreenMin, dNewGreenMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages(); 
        
    end

    function chkFusionGreenUnitTypeCallback(hObject, ~) % Green
                        
        bChkGreenUnitType = get(uiChkFusionGreenUnitType, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkGreenUnitType == false
                bChkGreenUnitType = true;
            else
                bChkGreenUnitType = false;
            end
            
            set(uiChkFusionGreenUnitType, 'Value', bChkGreenUnitType);
 
        end
        
        sGreenUnitDisplay = getSerieUnitValue(gdGreenOffset);                        
        if strcmpi(sGreenUnitDisplay, 'SUV') ||  strcmpi(sGreenUnitDisplay, 'HU') 

            if strcmpi(sGreenUnitDisplay, 'HU') 
                
                if bChkGreenUnitType == true
                    gsGreenUnitType = 'Unit in Window Level';
                else
                    gsGreenUnitType = 'Unit in HU';
                end
            end    
                
            if strcmpi(sGreenUnitDisplay, 'SUV')
                
                if bChkGreenUnitType == true
                    sSUVtype = viewerSUVtype('get');
                    gsGreenUnitType = sprintf('Unit in SUV/%s', sSUVtype);
                else
                    gsGreenUnitType = 'Unit in BQML';
                end
            end           
            
            set(uiTxtFusionGreenUnitType, 'String', gsGreenUnitType);
            
        end              
            
        dNewGreenMin = str2double(get(uiEdtFusionGreenMinWindow, 'String'));
        dNewGreenMax = str2double(get(uiEdtFusionGreenMaxWindow, 'String'));       
        
        if contains(gsGreenUnitType, 'SUV') 
            dNewGreenMax = dNewGreenMax*tInput(gdGreenOffset).tQuant.tSUV.dScale;
            dNewGreenMin = dNewGreenMin*tInput(gdGreenOffset).tQuant.tSUV.dScale;   
            
        elseif contains(gsGreenUnitType, 'BQML')
            dNewGreenMax = dNewGreenMax/tInput(gdGreenOffset).tQuant.tSUV.dScale;
            dNewGreenMin = dNewGreenMin/tInput(gdGreenOffset).tQuant.tSUV.dScale;            
            
        elseif contains(gsGreenUnitType, 'Window Level') 
            [dNewGreenMax, dNewGreenMin] = computeWindowMinMax(dNewGreenMax, dNewGreenMin);
            
        elseif contains(gsGreenUnitType, 'HU') 
            [dNewGreenMax, dNewGreenMin] = computeWindowLevel(dNewGreenMax, dNewGreenMin);
        end
        
        set(uiEdtFusionGreenMinWindow, 'String', num2str(dNewGreenMin));
        set(uiEdtFusionGreenMaxWindow, 'String', num2str(dNewGreenMax));
                        
    end

    function editFusionGreenWindowCallback(~, ~) % Green
                    
        dNewGreenMin = str2double(get(uiEdtFusionGreenMinWindow, 'String'));
        dNewGreenMax = str2double(get(uiEdtFusionGreenMaxWindow, 'String'));
                
        if contains(gsGreenUnitType, 'SUV') ||  contains(gsGreenUnitType, 'Window Level') 

            if contains(gsGreenUnitType, 'Window Level') 

                [dNewGreenMax, dNewGreenMin] = computeWindowLevel(dNewGreenMax, dNewGreenMin);
            else
                dNewGreenMax = dNewGreenMax/tInput(gdGreenOffset).tQuant.tSUV.dScale;
                dNewGreenMin = dNewGreenMin/tInput(gdGreenOffset).tQuant.tSUV.dScale;
            end
        end

        if isCombineMultipleFusion('get') == true
            if size(fusionBuffer('get', [], gdGreenOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'Green', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'Green', 'Coronal' , dNewGreenMin, dNewGreenMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'Green', 'Sagittal', dNewGreenMin, dNewGreenMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'Green', 'Axial'   , dNewGreenMin, dNewGreenMax, gdBufferMin);
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdGreenOffset), 'Green', 'MIP' , dNewGreenMin, dNewGreenMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages();
    end

    function sliderFusionGreenIntensityCallback(~, ~) %Green
        
        dSliderMultiplier = get(uiSliderFusionGreenIntensity, 'Value');
        dGMultiplier = double(sliderToImagesMultipler(dSliderMultiplier));

        set( uiTxtFusionGreenIntensity, 'String', sprintf('Green (x %d)', dGMultiplier) ); 
        
        set( uiEditFusionGreenIntensity, 'String', num2str(dGMultiplier) );  
        
        editFusionGreenIntensity();           
    end

    function editFusionGreenIntensityCallback(~, ~) % Green
        
        dEditMultiplier = str2double(get(uiEditFusionGreenIntensity, 'String'));
        if ~isnan(dEditMultiplier)
            dGMultiplier = dEditMultiplier;
        end
        
        set( uiEditFusionGreenIntensity, 'String', num2str(dGMultiplier) );  
       
        set( uiTxtFusionGreenIntensity, 'String', sprintf('Green (x %d)', dGMultiplier) ); 
        
        editFusionGreenIntensity();     
    end

    function editFusionGreenIntensity() % Green
        
        if isCombineMultipleFusion('get') == true
            
            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images
  
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'GB')  || ...
                   strcmpi(gsCombination, 'RG')  || ...
                   strcmpi(gsCombination, 'G')   

                    scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dGMultiplier);                    
                end 
                
            else  %3D Images          
            
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'GB')  || ...
                   strcmpi(gsCombination, 'RG')  || ...
                   strcmpi(gsCombination, 'G') 
                    
                    scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal*dGMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'sagittal', dGreenSagittal*dGMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'axial'   , dGreenAxial*dGMultiplier);

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dGMultiplier);
                    end
                end
            end
            
        else
            if gdGreenOffset ~= 0
                
                if ~isempty(aFusionBuffer{gdGreenOffset})
                    fusionBuffer('set', aFusionBuffer{gdGreenOffset} * dGMultiplier, gdGreenOffset); 
                end
                
                if link2DMip('get') == true && isVsplash('get') == false
                    if ~isempty(aMipFusionBuffer{gdGreenOffset})
                        mipFusionBuffer('set', aMipFusionBuffer{gdGreenOffset} * dGMultiplier, gdGreenOffset);
                    end
                end                  
            end
        end
        
        refreshImages();  
    end

    function chkFusionBlueEnableCallback(hObject, ~) % Blue
        
        bChkBlueEnable = get(uiChkFusionBlueEnable, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkBlueEnable == false
                bChkBlueEnable = true;
            else
                bChkBlueEnable = false;
            end
            
            set(uiChkFusionBlueEnable, 'Value', bChkBlueEnable);
        end
        
        if bChkBlueEnable == true
            
            set(uiChkFusionBlueUnitType    , 'Enable', 'on'); 
            set(uiTxtFusionBlueUnitType    , 'Enable', 'Inactive'); 
            set(uiEdtFusionBlueMinWindow   , 'Enable', 'on'); 
            set(uiEdtFusionBlueMaxWindow   , 'Enable', 'on'); 
            set(uiSliderFusionBlueIntensity, 'Enable', 'on'); 
            set(uiEditFusionBlueIntensity  , 'Enable', 'on');  
            
            dNewBlueMin = str2double(get(uiEdtFusionBlueMinWindow, 'String'));
            dNewBlueMax = str2double(get(uiEdtFusionBlueMaxWindow, 'String')); 
            
            if contains(gsBlueUnitType, 'SUV') ||  contains(gsBlueUnitType, 'Window Level') 

                if contains(gsBlueUnitType, 'Window Level') 

                    [dNewBlueMax, dNewBlueMin] = computeWindowLevel(dNewBlueMax, dNewBlueMin);
                else
                    dNewBlueMax = dNewBlueMax/tInput(gdBlueOffset).tQuant.tSUV.dScale;
                    dNewBlueMin = dNewBlueMin/tInput(gdBlueOffset).tQuant.tSUV.dScale;
                end
            end            
            
            isRGBFusionBlueEnable('set', true);            
            
        else
            set(uiChkFusionBlueUnitType    , 'Enable', 'off'); 
            set(uiTxtFusionBlueUnitType    , 'Enable', 'on'); 
            set(uiEdtFusionBlueMinWindow   , 'Enable', 'off'); 
            set(uiEdtFusionBlueMaxWindow   , 'Enable', 'off'); 
            set(uiSliderFusionBlueIntensity, 'Enable', 'off'); 
            set(uiEditFusionBlueIntensity  , 'Enable', 'off'); 
            
            dNewBlueMin = max(fusionBuffer('get', [], gdBlueOffset), [], 'all');
            dNewBlueMax = max(fusionBuffer('get', [], gdBlueOffset), [], 'all'); 
            
            isRGBFusionBlueEnable('set', false, str2double(get(uiEdtFusionBlueMinWindow, 'String')) );            
            
        end
        
        if isCombineMultipleFusion('get') == true
        
            if size(fusionBuffer('get', [], gdBlueOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Coronal' , dNewBlueMin, dNewBlueMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Sagittal', dNewBlueMin, dNewBlueMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Axial'   , dNewBlueMin, dNewBlueMax, gdBufferMin);
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'MIP' , dNewBlueMin, dNewBlueMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages();        
        
    end

    function chkFusionBlueUnitTypeCallback(hObject, ~) % Blue
                        
        bChkBlueUnitType = get(uiChkFusionBlueUnitType, 'Value');        
        if strcmpi(get(hObject, 'style'), 'text')
            
            if bChkBlueUnitType == false
                bChkBlueUnitType = true;
            else
                bChkBlueUnitType = false;
            end
            
            set(uiChkFusionBlueUnitType, 'Value', bChkBlueUnitType);
 
        end
        
        sBlueUnitDisplay = getSerieUnitValue(gdBlueOffset);                        
        if strcmpi(sBlueUnitDisplay, 'SUV') ||  strcmpi(sBlueUnitDisplay, 'HU') 

            if strcmpi(sBlueUnitDisplay, 'HU') 
                
                if bChkBlueUnitType == true
                    gsBlueUnitType = 'Unit in Window Level';
                else
                    gsBlueUnitType = 'Unit in HU';
                end
            end    
                
            if strcmpi(sBlueUnitDisplay, 'SUV')
                
                if bChkBlueUnitType == true
                    sSUVtype = viewerSUVtype('get');
                    gsBlueUnitType = sprintf('Unit in SUV/%s', sSUVtype);
                else
                    gsBlueUnitType = 'Unit in BQML';
                end
            end           
            
            set(uiTxtFusionBlueUnitType, 'String', gsBlueUnitType);
            
        end              
            
        dNewBlueMin = str2double(get(uiEdtFusionBlueMinWindow, 'String'));
        dNewBlueMax = str2double(get(uiEdtFusionBlueMaxWindow, 'String'));       
        
        if contains(gsBlueUnitType, 'SUV') 
            dNewBlueMax = dNewBlueMax*tInput(gdBlueOffset).tQuant.tSUV.dScale;
            dNewBlueMin = dNewBlueMin*tInput(gdBlueOffset).tQuant.tSUV.dScale;      
            
        elseif contains(gsBlueUnitType, 'BQML')
            dNewBlueMax = dNewBlueMax/tInput(gdBlueOffset).tQuant.tSUV.dScale;
            dNewBlueMin = dNewBlueMin/tInput(gdBlueOffset).tQuant.tSUV.dScale;            
            
        elseif contains(gsBlueUnitType, 'Window Level') 
            [dNewBlueMax, dNewBlueMin] = computeWindowMinMax(dNewBlueMax, dNewBlueMin);
            
        elseif contains(gsBlueUnitType, 'HU') 
            [dNewBlueMax, dNewBlueMin] = computeWindowLevel(dNewBlueMax, dNewBlueMin);
        end
        
        set(uiEdtFusionBlueMinWindow, 'String', num2str(dNewBlueMin));
        set(uiEdtFusionBlueMaxWindow, 'String', num2str(dNewBlueMax));
                        
    end

    function editFusionBlueWindowCallback(~, ~) % Blue
                    
        dNewBlueMin = str2double(get(uiEdtFusionBlueMinWindow, 'String'));
        dNewBlueMax = str2double(get(uiEdtFusionBlueMaxWindow, 'String'));
                
        if contains(gsBlueUnitType, 'SUV') ||  contains(gsBlueUnitType, 'Window Level') 

            if contains(gsBlueUnitType, 'Window Level') 

                [dNewBlueMax, dNewBlueMin] = computeWindowLevel(dNewBlueMax, dNewBlueMin);
            else
                dNewBlueMax = dNewBlueMax/tInput(gdBlueOffset).tQuant.tSUV.dScale;
                dNewBlueMin = dNewBlueMin/tInput(gdBlueOffset).tQuant.tSUV.dScale;
            end
        end

        if isCombineMultipleFusion('get') == true
            if size(fusionBuffer('get', [], gdBlueOffset), 3) == 1
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Axe');
            else                        
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Coronal' ,dNewBlueMin, dNewBlueMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Sagittal',dNewBlueMin, dNewBlueMax, gdBufferMin);
                scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'Axial'   ,dNewBlueMin, dNewBlueMax, gdBufferMin);
                
                if link2DMip('get') == true && isVsplash('get') == false
                    scaledRGBColorWindow('set', fusionBuffer('get', [], gdBlueOffset), 'blue', 'MIP'   ,dNewBlueMin, dNewBlueMax, gdBufferMin);                    
                end
            end
        end   
        
        refreshImages();
    end

    function sliderFusionBlueIntensityCallback(~, ~) %Blue
        
        dSliderMultiplier = get(uiSliderFusionBlueIntensity, 'Value');
        dBMultiplier = double(sliderToImagesMultipler(dSliderMultiplier));

        set( uiTxtFusionBlueIntensity, 'String', sprintf('Blue (x %d)', dBMultiplier) ); 
        
        set( uiEditFusionBlueIntensity, 'String', num2str(dBMultiplier) );  
              
        editFusionBlueIntensity();     
    end

    function editFusionBlueIntensityCallback(~, ~) % Blue
        
        dEditMultiplier = str2double(get(uiEditFusionBlueIntensity, 'String'));
        if ~isnan(dEditMultiplier)
            dBMultiplier = dEditMultiplier;
        end
        
        set( uiEditFusionBlueIntensity, 'String', num2str(dBMultiplier) );  
       
        set( uiTxtFusionBlueIntensity, 'String', sprintf('Blue (x %d)', dBMultiplier) );  
        
        editFusionBlueIntensity();     
    end

    function editFusionBlueIntensity()
        
         if isCombineMultipleFusion('get') == true
            
            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images
                
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'GB')  || ...
                   strcmpi(gsCombination, 'RB')  || ...
                   strcmpi(gsCombination, 'B') 

                    scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe*dBMultiplier);              
                end 
                
            else  %3D Images          
            
                if strcmpi(gsCombination, 'RGB') || ...
                   strcmpi(gsCombination, 'GB')  || ...
                   strcmpi(gsCombination, 'RB')  || ...
                   strcmpi(gsCombination, 'B') 
                    
                    scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal*dBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'sagittal', dBlueSagittal*dBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axial'   , dBlueAxial*dBMultiplier);   

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip*dBMultiplier);                      
                    end                                      
                end                
            end
            
        else

            if gdBlueOffset ~= 0
                
                if ~isempty(aFusionBuffer{gdBlueOffset})
                    fusionBuffer('set', aFusionBuffer{gdBlueOffset} * dBMultiplier, gdBlueOffset);   
                end
                
                if link2DMip('get') == true && isVsplash('get') == false
                    if ~isempty(aMipFusionBuffer{gdBlueOffset})
                        mipFusionBuffer('set', aMipFusionBuffer{gdBlueOffset} * dBMultiplier, gdBlueOffset);
                    end
                end                 
            end
        end
        
        refreshImages();   
    end

    function sliderFusionRGBIntensityCallback(~, ~) %RGB
        
        dSliderMultiplier = get(uiSliderFusionRGBIntensity, 'Value');
        dRGBMultiplier = double(sliderToImagesMultipler(dSliderMultiplier));

        set( uiTxtFusionRGBIntensity, 'String', sprintf('All Channels (x %d)', dRGBMultiplier) ); 
        
        set( uiEditFusionRGBIntensity, 'String', num2str(dRGBMultiplier) );  
            
        editFusionRGBIntensity();        
    end

    function editFusionRGBIntensityCallback(~, ~) % Blue
        
        dEditMultiplier = str2double(get(uiEditFusionRGBIntensity, 'String'));
        if ~isnan(dEditMultiplier)
            dRGBMultiplier = dEditMultiplier;
        end
        
        set( uiEditFusionRGBIntensity, 'String', num2str(dRGBMultiplier) );  
       
        set( uiTxtFusionRGBIntensity, 'String', sprintf('All Channels (x %d)', dRGBMultiplier) ); 
        
        editFusionRGBIntensity();
    end

    function editFusionRGBIntensity()
        
        if isCombineMultipleFusion('get') == true
            
            if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 %2D Images
  
                if strcmpi(gsCombination, 'RGB')

                    scaledRGBColorIntensity('set', [], 'red'  , 'axe', dRedAxe*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe*dRGBMultiplier);  
                    
                elseif strcmpi(gsCombination, 'GB')
                    
                    scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe*dRGBMultiplier);   
                    
                elseif strcmpi(gsCombination, 'RB')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'axe', dRedAxe*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe*dRGBMultiplier);     
                    
                elseif strcmpi(gsCombination, 'RG')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'axe', dRedAxe*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dRGBMultiplier);
                
                elseif strcmpi(gsCombination, 'R')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'axe', dRedAxe*dRGBMultiplier);
                
                elseif strcmpi(gsCombination, 'G')
                    
                    scaledRGBColorIntensity('set', [], 'green', 'axe', dGreenAxe*dRGBMultiplier);
                
                elseif strcmpi(gsCombination, 'B')

                    scaledRGBColorIntensity('set', [], 'blue' , 'axe', dBlueAxe*dRGBMultiplier);              
                end 
                
            else  %3D Images          
            
                if strcmpi(gsCombination, 'RGB')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'coronal' , dRedCoronal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'sagittal' , dRedSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'sagittal' , dGreenSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'sagittal' , dBlueSagittal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'axial' , dRedAxial*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'axial' , dGreenAxial*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axial' , dBlueAxial*dRGBMultiplier);   

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'red'  , 'mip' , dRedMip*dRGBMultiplier);
                        scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dRGBMultiplier);
                        scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip*dRGBMultiplier);                      
                    end
                    
                elseif strcmpi(gsCombination, 'GB')
                    
                    scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'green', 'sagittal' , dGreenSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'sagittal' , dBlueSagittal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'green', 'axial' , dGreenAxial*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axial' , dBlueAxial*dRGBMultiplier);   

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dRGBMultiplier);
                        scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip*dRGBMultiplier);                      
                    end

                elseif strcmpi(gsCombination, 'RB')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'coronal' , dRedCoronal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'sagittal' , dRedSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'sagittal' , dBlueSagittal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'axial' , dRedAxial*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axial' , dBlueAxial*dRGBMultiplier);   

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'red'  , 'mip' , dRedMip*dRGBMultiplier);
                        scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip*dRGBMultiplier);                      
                    end
                    
                elseif strcmpi(gsCombination, 'RG')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'coronal' , dRedCoronal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'sagittal' , dRedSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'sagittal' , dGreenSagittal*dRGBMultiplier);

                    scaledRGBColorIntensity('set', [], 'red'  , 'axial' , dRedAxial*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'green', 'axial' , dGreenAxial*dRGBMultiplier);

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'red'  , 'mip' , dRedMip*dRGBMultiplier);
                        scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dRGBMultiplier);
                    end
                
                elseif strcmpi(gsCombination, 'R')
                    
                    scaledRGBColorIntensity('set', [], 'red'  , 'coronal' , dRedCoronal*dRGBMultiplier);                
                    scaledRGBColorIntensity('set', [], 'red'  , 'sagittal', dRedSagittal*dRGBMultiplier); 
                    scaledRGBColorIntensity('set', [], 'red'  , 'axial'   , dRedAxial*dRGBMultiplier);

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'red'  , 'mip' , dRedMip*dRGBMultiplier);                  
                    end                  
                    
                elseif strcmpi(gsCombination, 'G')
                    
                    scaledRGBColorIntensity('set', [], 'green', 'coronal' , dGreenCoronal*dRGBMultiplier);                
                    scaledRGBColorIntensity('set', [], 'green', 'sagittal', dGreenSagittal*dRGBMultiplier);               
                    scaledRGBColorIntensity('set', [], 'green', 'axial'   , dGreenAxial*dRGBMultiplier);

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'green', 'mip' , dGreenMip*dRGBMultiplier);
                    end                  
                    
                elseif strcmpi(gsCombination, 'B')

                    scaledRGBColorIntensity('set', [], 'blue' , 'coronal' , dBlueCoronal*dRGBMultiplier);               
                    scaledRGBColorIntensity('set', [], 'blue' , 'sagittal' , dBlueSagittal*dRGBMultiplier);
                    scaledRGBColorIntensity('set', [], 'blue' , 'axial' , dBlueAxial*dRGBMultiplier);   

                    if link2DMip('get') == true && isVsplash('get') == false
                        scaledRGBColorIntensity('set', [], 'blue' , 'mip' , dBlueMip*dRGBMultiplier);                      
                    end                   
                end                
            end
            
        else

            for kk=1:gdNbFusedSeries
                
                if ~isempty(aFusionBuffer{kk})
                    fusionBuffer('set', aFusionBuffer{kk} * dRGBMultiplier, kk);            
                end
                
                if link2DMip('get') == true && isVsplash('get') == false
                    if ~isempty(aMipFusionBuffer{kk})
                        mipFusionBuffer('set', aMipFusionBuffer{kk} * dRGBMultiplier, kk);
                    end
                end                
            end
        end
        
        refreshImages();
    end    
end