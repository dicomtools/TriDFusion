function catchKeyPress(~,evnt)
%function catchKeyPress(~,evnt)
%Catch\Execute Keyboard Key Press.
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

    if isempty(dicomBuffer('get'))
        return;
    end

    if strcmpi(evnt.Key,'add')
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
       
            if multiFrame3DZoom('get') > 1.2
                multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);
            end

            if multiFrame3DPlayback('get') == false && ...
                multiFrame3DRecord('get')  == false
            
                zoom3D('in', 1.2);
            end         
            
            initGate3DObject('set', true);
        else
            if size(dicomBuffer('get'), 3) ~=1

                multiFrameZoom('set', 'out', 1);

                if multiFrameZoom('get', 'axe') ~= gca
                    multiFrameZoom('set', 'in', 1);
                end

                dZFactor = multiFrameZoom('get', 'in');
                dZFactor = dZFactor+0.025;
                multiFrameZoom('set', 'in', dZFactor);

                switch gca
                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    case axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    otherwise
                        zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                end

            end            

        end
    end
    
    if strcmpi(evnt.Key,'subtract')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
       
            multiFrame3DZoom('set', multiFrame3DZoom('get')*1.2);

             if multiFrame3DPlayback('get') == false && ...
                multiFrame3DRecord('get')   == false
            
                zoom3D('out', 1.2);
             end

             initGate3DObject('set', true);     
        else
            if size(dicomBuffer('get'), 3) ~=1

                multiFrameZoom('set', 'in', 1);

                if multiFrameZoom('get', 'axe') ~= gca
                    multiFrameZoom('set', 'out', 1);
                end

                dZFactor = multiFrameZoom('get', 'out');
                if dZFactor > 0.025
                    dZFactor = dZFactor-0.025;
                    multiFrameZoom('set', 'out', dZFactor);
                end

                switch gca
                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    case axesMIpPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        zoom(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        
                    otherwise
                        zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                end            
            end
        end
    end    
    
    if strcmpi(evnt.Key,'uparrow')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

            flip3Dobject('up');    
        else               
            if size(dicomBuffer('get'), 3) ~= 1
                
                windowButton('set', 'down');  
                switch gca
                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        if sliceNumber('get', 'coronal') == size(dicomBuffer('get'), 1)
                            iSliceNumber = 1;
                        else
                            iSliceNumber = sliceNumber('get', 'coronal')+1;
                        end

                        sliceNumber('set', 'coronal', iSliceNumber);    

                        set(uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / size(dicomBuffer('get'), 1));
                        
                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        if sliceNumber('get', 'sagittal') == size(dicomBuffer('get'), 2)
                            iSliceNumber = 1;
                        else
                            iSliceNumber = sliceNumber('get', 'sagittal')+1;
                        end

                        sliceNumber('set', 'sagittal', iSliceNumber);    

                        set(uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / size(dicomBuffer('get'), 2));
                        
                    otherwise  
                        if sliceNumber('get', 'axial') == 1
                            iSliceNumber = size(dicomBuffer('get'), 3);
                        else
                            iSliceNumber = sliceNumber('get', 'axial')-1;
                        end

                        sliceNumber('set', 'axial', iSliceNumber);    
                end
                set(uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / size(dicomBuffer('get'), 3)));
                
                refreshImages();                
                
                windowButton('set', 'up');  

            end
            
if 0                    
            im = dicomBuffer('get');

            B = imrotate3(im,45,[0 1 0],'nearest','loose','FillValues',0);

            dicomBuffer('set', B);
            refreshImages();
end                    
        end
    end   
    
    if strcmpi(evnt.Key,'downarrow')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

            flip3Dobject('down');   
        else
            if size(dicomBuffer('get'), 3) ~= 1
                
                windowButton('set', 'down');  
                switch gca
                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        if sliceNumber('get', 'coronal') == 1
                            iSliceNumber = size(dicomBuffer('get'), 1);
                        else
                            iSliceNumber = sliceNumber('get', 'coronal')-1;
                        end

                        sliceNumber('set', 'coronal', iSliceNumber);    

                        set(uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / size(dicomBuffer('get'), 1));
                        
                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        if sliceNumber('get', 'sagittal') == 1
                            iSliceNumber = size(dicomBuffer('get'), 2);
                        else
                            iSliceNumber = sliceNumber('get', 'sagittal')-1;
                        end

                        sliceNumber('set', 'sagittal', iSliceNumber);    

                        set(uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / size(dicomBuffer('get'), 2));
                        
                    otherwise                
                        if sliceNumber('get', 'axial') == size(dicomBuffer('get'), 3)
                            iSliceNumber = 1;
                        else
                            iSliceNumber = sliceNumber('get', 'axial')+1;
                        end

                        sliceNumber('set', 'axial', iSliceNumber);    

                        set(uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / size(dicomBuffer('get'), 3)));                       
                end
                
                refreshImages();
                
                windowButton('set', 'up'); 
            end            
        end
    end     
    
    if strcmpi(evnt.Key,'leftarrow')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

             flip3Dobject('left');                             
        else
            if size(dicomBuffer('get'), 3) ~= 1 && isVsplash('get') == false    
                
                windowButton('set', 'down');  

                iMipAngleValue = mipAngle('get');

                iMipAngleValue = iMipAngleValue-1;

                if iMipAngleValue <=0
                    iMipAngleValue = 32;
                end    

                mipAngle('set', iMipAngleValue);                    

                if iMipAngleValue == 1
                    dMipSliderValue = 0;
                else
                    dMipSliderValue = mipAngle('get')/32;
                end

                set(uiSliderMipPtr('get'), 'Value', dMipSliderValue);                
                
                refreshImages();
                
                windowButton('set', 'up'); 
                
            end  
        end
    end
    
    if strcmpi(evnt.Key,'rightarrow')
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

              flip3Dobject('right');                             
        else
            if size(dicomBuffer('get'), 3) ~= 1 && isVsplash('get') == false    
                
                windowButton('set', 'down');  
                
                iMipAngleValue = mipAngle('get');

                iMipAngleValue = iMipAngleValue+1;

                if iMipAngleValue > 32
                    iMipAngleValue = 1;
                end    

                mipAngle('set', iMipAngleValue);                    

                if iMipAngleValue == 1
                    dMipSliderValue = 0;
                else
                    dMipSliderValue = mipAngle('get')/32;
                end

                set(uiSliderMipPtr('get'), 'Value', dMipSliderValue);
                
                refreshImages();
                
                windowButton('set', 'up');                
            end            
        end
    end 

    if strcmpi(evnt.Key,'space')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isempty(dicomBuffer('get'))
            return;
        end

%        atMetaData = dicomMetaData('get');                
        sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));                        
        if strcmpi(sUnitDisplay, 'SUV')
%            tQuant = quantificationTemplate('get');   
%            lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;  
%            lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;   
            lMin = min(dicomBuffer('get'), [], 'all');
            lMax = max(dicomBuffer('get'), [], 'all');
        else
            lMin = min(dicomBuffer('get'), [], 'all');
            lMax = max(dicomBuffer('get'), [], 'all');
        end

        setWindowMinMax(lMax, lMin);                    
    end

    if strcmpi(evnt.Key,'c')
        
       if switchTo3DMode('get')     == true || ...
          switchToIsoSurface('get') == true || ...
          switchToMIPMode('get')    == true || ...
          isVsplash('get') == true        
            return;
        end

        if ismember('shift', get(fiMainWindowPtr('get'),'CurrentModifier'))
            if crossSize('get') > 30
                crossSize('set', 0);
            else    
                crossSize('set', crossSize('get')+10);
            end
            % redrawCross('all');
        else
            if crossActivate('get')
                crossActivate('set', false);
            else
                crossActivate('set', true);                       
            end

        end 

        if size(dicomBuffer('get'), 3) == 1
        %    delete(findobj(axe, 'Type', 'line'))
        else
            alAxes1Line   = axesLine('get', 'axes1');
            alAxes2Line   = axesLine('get', 'axes2');
            alAxes3Line   = axesLine('get', 'axes3');
            alAxesMipLine = axesLine('get', 'axesMip');

            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = crossActivate('get');
            end

            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = crossActivate('get');
            end

            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = crossActivate('get');
            end 
            
            for iiMip=1:numel(alAxesMipLine)    
                alAxesMipLine{iiMip}.Visible = crossActivate('get');
            end             
        %    delete(findobj(axes1, 'Type', 'line'))
        %    delete(findobj(axes2, 'Type', 'line'))
        %    delete(findobj(axes3, 'Type', 'line'))
        end                

        refreshImages();
    end

    if strcmpi(evnt.Key,'d')  

 %       setDataCursorCallback();   
    end

    persistent pdColorOffset;
    persistent pdFusionColorOffset;
    persistent pdInvertColor;
    persistent pdBackgroundColor;
    persistent pdOverlayColor;
    persistent pdAlphaSlider;

    if strcmpi(evnt.Key,'f')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end
        

        dNbFusedSeries = 0;
        
        if size(dicomBuffer('get'), 3) == 1
            dNbSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbSeries
                imAxeF = imAxeFPtr('get', [], rr);
                if ~isempty(imAxeF)               
                    dNbFusedSeries = dNbFusedSeries+1; % Multiple fusion
                end
            end
        else
            dNbSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbSeries
                    
                imCoronalF  = imCoronalFPtr ('get', [], rr);
                imSagittalF = imSagittalFPtr('get', [], rr);
                imAxialF    = imAxialFPtr   ('get', [], rr);

                if ~isempty(imCoronalF) && ...
                   ~isempty(imSagittalF) && ...
                   ~isempty(imAxialF)
                    dNbFusedSeries = dNbFusedSeries+1;  % Multiple fusion
                end
            end
        end             
        
        if isFusion('get')== true
                                
            if keyPressFusionStatus('get') ~= 0 && ...
               keyPressFusionStatus('get') ~= 1     

                pdColorOffset       = colorMapOffset('get');
                pdFusionColorOffset = fusionColorMapOffset('get');

                pdInvertColor     = invertColor    ('get');
                pdBackgroundColor = backgroundColor('get');
                pdOverlayColor    = overlayColor   ('get');

                pdAlphaSlider = sliderAlphaValue('get');   
                
                keyPressFusionStatus('set', 1);

%                set(uiAlphaSliderPtr('get') , 'Value', 1);
%                sliderAlphaValue('set', 1);   

                if size(dicomBuffer('get'), 3) == 1
                    alpha( axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    if dNbFusedSeries == 1
                        alpha( axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                    end                    
                else
                    alpha( axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    alpha( axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    alpha( axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    if link2DMip('get') == true  && isVsplash('get') == false                                        
                        set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                        alpha( axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    end  
                    
                    if dNbFusedSeries == 1
                        alpha( axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        alpha( axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        alpha( axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        if link2DMip('get') == true  && isVsplash('get') == false                                        
                           set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                           alpha( axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        end                        
                    end
                end

                iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');

                tFuseInput  = inputTemplate('get');
                atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                setViewerDefaultColor(true, dicomMetaData('get'), atFuseMetaData);                        

            else
                if keyPressFusionStatus('get') == 1

                    keyPressFusionStatus('set', 0);
                
%                    set(uiAlphaSliderPtr('get') , 'Value', 0);
%                    sliderAlphaValue('set', 0);   

                    if size(dicomBuffer('get'), 3) == 1
                        alpha( axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                    else
                        alpha( axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        alpha( axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        alpha( axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        if link2DMip('get') == true  && isVsplash('get') == false                                        
                            set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                            alpha( axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        end 
                                                
                    end

                    setViewerDefaultColor(true, dicomMetaData('get'));                           
                else
                    keyPressFusionStatus('set', 2);

%                    set(uiAlphaSliderPtr('get') , 'Value', pdAlphaSlider);     
%                    sliderAlphaValue('set', pdAlphaSlider);

                    if size(dicomBuffer('get'), 3) == 1
                        alpha( axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                    else
                        alpha( axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        alpha( axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        alpha( axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        if link2DMip('get') == true && isVsplash('get') == false                       
                            alpha( axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        end
                        
                        if dNbFusedSeries == 1
                            alpha( axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            alpha( axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            alpha( axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            if link2DMip('get') == true  && isVsplash('get') == false                                        
                            set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                            alpha( axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            end                        
                        end                        
                   end   

                    colorMapOffset('set', pdColorOffset);
                    fusionColorMapOffset('set', pdFusionColorOffset);

                    invertColor('set', pdInvertColor);

                    backgroundColor ('set', pdBackgroundColor);
                    overlayColor    ('set', pdOverlayColor);

                    setViewerDefaultColor(false, dicomMetaData('get'));
                end
            end
            
%            sliderAlphaCallback();

            setFusionColorbarLabel();

                
            refreshImages();   

        end
    end

    if strcmpi(evnt.Key,'i')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end

        uiLogo = logoObject('get');

        if(invertColor('get'))               
            
            invertColor('set', false);

            if size(dicomBuffer('get'), 3) == 1
                
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'black');
                
               cmap = flipud(colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
               colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap);
                
                if isFusion('get') == true 
                
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries   
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)     
                           cmapf = flipud(colormap(axef));
                           colormap(axef, cmapf);                        
                        end
                    end
                end
                
                if isPlotContours('get') == true 
                   cmapfc = flipud(colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                   colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapfc);
                end
                
            else
                if switchTo3DMode('get')     == true || ...
                   switchToIsoSurface('get') == true || ...
                   switchToMIPMode('get')    == true

                else
                    set(uiCorWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiSagWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiTraWindowPtr('get'), 'BackgroundColor', 'black');
                    
                    if link2DMip('get') == true && isVsplash('get') == false
                        set(uiMipWindowPtr('get'), 'BackgroundColor', 'black');
                    end
                    
                    cmap1 = flipud(colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                    cmap2 = flipud(colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                    cmap3 = flipud(colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                
                    colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap1);
                    colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap2);
                    colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap3); 
                
                    if link2DMip('get') == true && isVsplash('get') == false
                        cmapMip = flipud(colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                        colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), cmapMip); 
                    end

                    if isFusion('get') == true 
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries
                            
                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);
                            
                            if ~isempty(axes1f) && ...
                               ~isempty(axes2f) && ...
                               ~isempty(axes3f) 
                       
                                cmap1f = flipud(colormap(axes1f));
                                cmap2f = flipud(colormap(axes2f));
                                cmap3f = flipud(colormap(axes3f));
                                
                                colormap(axes1f, cmap1f);
                                colormap(axes2f, cmap2f);
                                colormap(axes3f, cmap3f);  
                            end
                            
                            if link2DMip('get') == true && isVsplash('get') == false
                                
                                axesMipf = axesMipfPtr('get', [], rr);                                
                                if ~isempty(axesMipf)
                                    cmapMipf = flipud(colormap(axesMipf));
                                    colormap(axesMipf, cmapMipf);  
                                end
                            end
                        end
                    end
                    
                    if isPlotContours('get') == true && isVsplash('get') == false
                        
                        cmap1fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        cmap2fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        cmap3fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    
                        colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap1fc);
                        colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap2fc);
                        colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap3fc);   
                        
                        if link2DMip('get') == true && isVsplash('get') == false
                            cmapMipfc = flipud(colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                            colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapMipfc);                                                       
                        end
                    end
                end
            end
            
            set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]); 

            set(fiMainWindowPtr('get'), 'Color', 'black');
       
            set(uiSliderLevelPtr('get') , 'BackgroundColor',  'black');
            set(uiSliderWindowPtr('get'), 'BackgroundColor',  'black');

            set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'black');
            set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'black');                   
            set(uiAlphaSliderPtr('get')       , 'BackgroundColor',  'black');                   
            set(uiColorbarPtr('get')          , 'Color',  'white');                   
            set(uiFusionColorbarPtr('get')    , 'Color',  'white');                   

            backgroundColor('set', 'black');
            if strcmp(getColorMap('one', colorMapOffset('get')), 'white')
                overlayColor ('set', 'black' );
            else    
                overlayColor ('set', 'white' );
            end    
        else   
             
            invertColor('set', true);

            if size(dicomBuffer('get'), 3) == 1 
                
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'white');
                
                cmap = flipud(colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                colormap(axePtr('get' , [], get(uiSeriesPtr('get'), 'Value')), cmap);
                
                if isFusion('get') == true 
                
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            cmapf = flipud(colormap(axef));
                            colormap(axef, cmapf);                                                
                        end
                    end
                end
                
                if isPlotContours('get') == true 
                    cmapfc = flipud(colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapfc);
                end
                
            else

                set(uiCorWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiSagWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiTraWindowPtr('get'), 'BackgroundColor', 'white');
                
                if link2DMip('get') == true && isVsplash('get') == false
                    set(uiMipWindowPtr('get'), 'BackgroundColor', 'white');
                end         
                
                cmap1 = flipud(colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                cmap2 = flipud(colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                cmap3 = flipud(colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                            
                colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap1);
                colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap2);
                colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap3);        
                
                if link2DMip('get') == true && isVsplash('get') == false             
                   cmapMip = flipud(colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                   colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')),cmapMip);        
                end
                
                if isFusion('get') == true 
                    
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries

                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f) 
                       
                            cmap1f = flipud(colormap(axes1f));
                            cmap2f = flipud(colormap(axes2f));
                            cmap3f = flipud(colormap(axes3f));
                                
                            colormap(axes1f, cmap1f);
                            colormap(axes2f, cmap2f);
                            colormap(axes3f, cmap3f);                               
                        end
                        
                        if link2DMip('get') == true && isVsplash('get') == false
                            
                            axesMipf = axesMipfPtr('get', [], rr);
                            if ~isempty(axesMipf)
                                cmapMipf = flipud(colormap(axesMipf));
                                colormap(axesMipf, cmapMipf);                               
                            end
                        end
                    end
                end
                
                if isPlotContours('get') == true && isVsplash('get') == false
                    
                    cmap1fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    cmap2fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    cmap3fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        
                    colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap1fc);
                    colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap2fc);
                    colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap3fc);    
                    
                    if link2DMip('get') == true && isVsplash('get') == false
                        cmapMipfc = flipud(colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapMipfc);                               
                    end                    
                end

            end
            
            set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]); 

            set(fiMainWindowPtr('get'), 'Color', 'white');

            set(uiSliderLevelPtr('get') , 'BackgroundColor',  'white');
            set(uiSliderWindowPtr('get'), 'BackgroundColor',  'white');  

            set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'white');
            set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'white');                   
            set(uiAlphaSliderPtr('get')       , 'BackgroundColor',  'white'); 
            set(uiColorbarPtr('get')          , 'Color',  'black');                   
            set(uiFusionColorbarPtr('get')    , 'Color',  'black');  

            backgroundColor('set', 'white');
            if strcmpi(getColorMap('one', colorMapOffset('get')), 'black')
                overlayColor ('set', 'white' );
            else
                overlayColor ('set', 'black' ); 
            end
         end

%                bInitSegPanel = false;                
%                if  viewSegPanel('get')
%                    bInitSegPanel = true;
%                    viewSegPanel('set', false);
%                    objSegPanel = viewSegPanelMenuObject('get');
%                    if ~isempty(objSegPanel)
%                       objSegPanel.Checked = 'off';
%                    end
%                end

%                bInitKernelPanel = false;                
%                if  viewKernelPanel('get')
%                    bInitKernelPanel = true;
%                    viewKernelPanel('set', false);
%                    objKernelPanel = viewKernelPanelMenuObject('get');
%                    if ~isempty(objKernelPanel)
%                       objKernelPanel.Checked = 'off';
%                    end
%                end

%         triangulateCallback();

%         clearDisplay();                        
%         initDisplay(3);     

%         dicomViewerCore();
%          if isVsplash('get') == false        
            refreshImages();   
%          else
%             tAxes1Text = axesText('get', 'axes1');
%             tAxes1Text.Color  = overlayColor('get');  

%             tAxes2Text = axesText('get', 'axes2');
%             tAxes2Text.Color  = overlayColor('get'); 

%             tAxes3Text = axesText('get', 'axes3');
%             tAxes3Text.Color  = overlayColor('get');                     
%          end

%                 if bInitSegPanel == true
%                    setViewSegPanel();
%                 end

%                 if bInitKernelPanel == true
%                    setViewKernelPanel();
%                 end                 
    end

    if strcmpi(evnt.Key,'o')

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end

        if overlayActivate('get')
            overlayActivate('set', false);

            if size(dicomBuffer('get'), 3) == 1
                pAxeText = axesText('get', 'axe');
                pAxeText.Visible = 'off';
                
                if isFusion('get') == true
                    pAxefText = axesText('get', 'axef');
                    pAxefText.Visible = 'off';                    
                end
            else
                pAxes1Text   = axesText('get', 'axes1'  );
                pAxes2Text   = axesText('get', 'axes2'  );
                pAxes3Text   = axesText('get', 'axes3'  );
                pAxesMipText = axesText('get', 'axesMip');

                pAxes1Text.Visible   = 'off';
                pAxes2Text.Visible   = 'off';
                pAxes3Text.Visible   = 'off';
                pAxesMipText.Visible = 'off';
               
                if isVsplash('get') == false
                    pAxes1ViewText   = axesText('get', 'axes1View'  );
                    pAxes2ViewText   = axesText('get', 'axes2View'  );
                    pAxes3ViewText   = axesText('get', 'axes3View'  );
                    pAxesMipViewText = axesText('get', 'axesMipView');

                    pAxes1ViewText.Visible   = 'off';
                    pAxes2ViewText.Visible   = 'off';
                    for tt=1:numel(pAxes3ViewText)
                        pAxes3ViewText{tt}.Visible   = 'off';
                    end
                    pAxesMipViewText.Visible = 'off';                    
                end
                
                if isFusion('get') == true
                    pAxes3fText = axesText('get', 'axes3f');
                    pAxes3fText.Visible = 'off';                    
                end
                
            end

            if isVsplash('get') == true
                ptMontageAxes1 = montageText('get', 'axes1');                 
                for aa=1:numel(ptMontageAxes1)
                    ptMontageAxes1{aa}.Visible = 'off';
                end                           

                ptMontageAxes2 = montageText('get', 'axes2');                 
                for aa=1:numel(ptMontageAxes2)
                    ptMontageAxes2{aa}.Visible = 'off';
                end 

                ptMontageAxes3 = montageText('get', 'axes3');                 
                for aa=1:numel(ptMontageAxes3)
                    ptMontageAxes3{aa}.Visible = 'off';
                end                          
            end                    
        else
            overlayActivate('set', true);  

            if size(dicomBuffer('get'), 3) == 1
                pAxeText = axesText('get', 'axe');
                pAxeText.Visible = 'on';
                
                if isFusion('get') == true
                    pAxefText = axesText('get', 'axef');
                    pAxefText.Visible = 'on';                    
                end                                
            else
                pAxes1Text   = axesText('get', 'axes1'  );
                pAxes2Text   = axesText('get', 'axes2'  );
                pAxes3Text   = axesText('get', 'axes3'  );
                pAxesMipText = axesText('get', 'axesMip');

                pAxes1Text.Visible   = 'on';
                pAxes2Text.Visible   = 'on';
                pAxes3Text.Visible   = 'on';
                pAxesMipText.Visible = 'on';
                
                if isVsplash('get') == false
                    pAxes1ViewText   = axesText('get', 'axes1View'  );
                    pAxes2ViewText   = axesText('get', 'axes2View'  );
                    pAxes3ViewText   = axesText('get', 'axes3View'  );
                    pAxesMipViewText = axesText('get', 'axesMipView');

                    pAxes1ViewText.Visible   = 'on';
                    pAxes2ViewText.Visible   = 'on';
                    for tt=1:numel(pAxes3ViewText)
                        pAxes3ViewText{tt}.Visible   = 'on';
                    end
                    pAxesMipViewText.Visible = 'on';                    
                end 
                
                if isFusion('get') == true
                    pAxes3fText = axesText('get', 'axes3f');
                    pAxes3fText.Visible = 'on';                    
                end                
            end

            if isVsplash('get') == true
                ptMontageAxes1 = montageText('get', 'axes1');                 
                for aa=1:numel(ptMontageAxes1)
                    ptMontageAxes1{aa}.Visible = 'on';
                end                           

                ptMontageAxes2 = montageText('get', 'axes2');                 
                for aa=1:numel(ptMontageAxes2)
                    ptMontageAxes2{aa}.Visible = 'on';
                end 

                ptMontageAxes3 = montageText('get', 'axes3');                 
                for aa=1:numel(ptMontageAxes3)
                    ptMontageAxes3{aa}.Visible = 'on';
                end                          
            end

            refreshImages();

        end

    end

    if strcmpi(evnt.Key,'r')   

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
           return;
        end
        
        if size(dicomBuffer('get'), 3) == 1            
            return;
        end   
        
        tInput = inputTemplate('get');
        
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(tInput)
            return;
        end                      
        
        if tInput(dOffset).bFlipHeadFeet == true
            tInput(dOffset).bFlipHeadFeet = false;
        else
            tInput(dOffset).bFlipHeadFeet = true;
        end

        inputTemplate('set', tInput);  
                
        im = dicomBuffer('get');   
        im=im(:,:,end:-1:1);
        dicomBuffer('set', im);     
        
        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)

                    axes1f = axes1fPtr('get', [], rr);
                    axes2f = axes2fPtr('get', [], rr);
                    axes3f = axes3fPtr('get', [], rr);

                    if ~isempty(axes1f) && ...
                       ~isempty(axes2f) && ...
                       ~isempty(axes3f)                       
                        imf=imf(:,:,end:-1:1);
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end 
        
        refreshImages();
    end

    if strcmpi(evnt.Key,'l') 

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
            return;
        end
        
        tInput = inputTemplate('get');
        
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(tInput)
            return;
        end                      
        
        if tInput(dOffset).bFlipLeftRight == true
            tInput(dOffset).bFlipLeftRight = false;
        else
            tInput(dOffset).bFlipLeftRight = true;
        end     
        
        inputTemplate('set', tInput);        
        
        im = dicomBuffer('get');                   

        if size(dicomBuffer('get'), 3) == 1                              
            im=im(:,end:-1:1);     
        else
            im=im(:,end:-1:1,:);     
            if isVsplash('get') == false           
                tAxes1ViewText = axesText('get', 'axes1View'); 
                if strcmpi(tAxes1ViewText.String, 'Right')
                    tAxes1ViewText.String  = 'Left';  
                else
                    tAxes1ViewText.String  = 'Right';  
                end
                
                tAxes3ViewText = axesText('get', 'axes3View'); 
                if strcmpi(tAxes3ViewText{2}.String, 'Right')
                    tAxes3ViewText{2}.String  = 'Left';  
                else
                    tAxes3ViewText{2}.String  = 'Right';  
                end                
            end            
        end
        
        dicomBuffer('set', im);

        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)
                    if size(imf, 3) == 1    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            imf=imf(:,end:-1:1);
                        end
                    else
                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f)                       
                            imf=imf(:,end:-1:1,:);
                        end
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end        

        refreshImages();
    end   

    if strcmpi(evnt.Key,'a')   

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
            return;
        end
        
        tInput = inputTemplate('get');
        
        dOffset = get(uiSeriesPtr('get'), 'Value');
        if dOffset > numel(tInput)
            return;
        end                      
        
        if tInput(dOffset).bFlipAntPost == true
            tInput(dOffset).bFlipAntPost = false;
        else
            tInput(dOffset).bFlipAntPost = true;
        end      
        
        inputTemplate('set', tInput);
        
        im = dicomBuffer('get');   
        if size(dicomBuffer('get'), 3) == 1                              
            im=im(end:-1:1,:);
        else
            im=im(end:-1:1,:,:);
            if isVsplash('get') == false           
                tAxes2ViewText = axesText('get', 'axes2View'); 
                if strcmpi(tAxes2ViewText.String, 'Anterior')
                    tAxes2ViewText.String  = 'Posterior';  
                else
                    tAxes2ViewText.String  = 'Anterior';  
                end
                
                tAxes3ViewText = axesText('get', 'axes3View'); 
                if strcmpi(tAxes3ViewText{1}.String, 'Anterior')
                    tAxes3ViewText{1}.String  = 'Posterior';  
                else
                    tAxes3ViewText{1}.String  = 'Anterior';  
                end                
            end             
        end
        
        dicomBuffer('set', im);
  
        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)
                    if size(imf, 3) == 1    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            imf=imf(end:-1:1,:);
                        end
                    else
                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f)                       
                            imf=imf(end:-1:1,:,:);
                        end
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end 
        
        refreshImages();
    end  

    if strcmpi(evnt.Key,'z')

        setZoomCallback();
    end

    if strcmpi(evnt.Key,'n')

        setPanCallback();
    end                

    if strcmpi(evnt.Key,'f1')
        [dMax, dMin] = computeWindowLevel(1200, -500);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f2')
        [dMax, dMin] = computeWindowLevel(500, 50);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f3')
        [dMax, dMin] = computeWindowLevel(500, 200);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f4')
        [dMax, dMin] = computeWindowLevel(240, 40);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f5')
        [dMax, dMin] = computeWindowLevel(80, 40);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f6')
        [dMax, dMin] = computeWindowLevel(350, 90);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f7')
        [dMax, dMin] = computeWindowLevel(2000, -600);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f8')
        [dMax, dMin] = computeWindowLevel(350, 50);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f9')

         persistent pdToggle;

         if  pdToggle == 0

            [dMax, dMin] = computeWindowLevel(2000, 0);
            setFkeyWindowMinMax(dMax, dMin);  
            pdToggle =1;
        elseif pdToggle == 1

            [dMax, dMin] = computeWindowLevel(2500, 415);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =2;

        else
            [dMax, dMin] = computeWindowLevel(1000, 350);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =0;
        end               
    end                             

end
