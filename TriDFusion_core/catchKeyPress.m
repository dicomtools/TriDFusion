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
                    case axes1Ptr('get')
                        zoom(axes1Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes1Ptr('get'));

                    case axes2Ptr('get')
                        zoom(axes2Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes2Ptr('get'));
                    case axes3Ptr('get')
                        zoom(axes3Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get'));
                    otherwise
                        zoom(axes3Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get'));
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
                    case axes1Ptr('get')
                        zoom(axes1Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes1Ptr('get'));

                    case axes2Ptr('get')
                        zoom(axes2Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes2Ptr('get'));
                    case axes3Ptr('get')
                        zoom(axes3Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get'));
                    otherwise
                        zoom(axes3Ptr('get'), dZFactor);
                        multiFrameZoom('set', 'axe', axes3Ptr('get'));
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
        end
    end            
    if strcmpi(evnt.Key,'leftarrow')
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

             flip3Dobject('left');                             
        end
    end
    if strcmpi(evnt.Key,'rightarrow')
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

              flip3Dobject('right');                             
        end
    end 

    if strcmpi(evnt.Key,'space')
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isempty(dicomBuffer('get'))
            return;
        end

        atMetaData = dicomMetaData('get');                
        if strcmpi(atMetaData{1}.Modality, 'pt')
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
            alAxes1Line = axesLine('get', 'axes1');
            alAxes2Line = axesLine('get', 'axes2');
            alAxes3Line = axesLine('get', 'axes3');

            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = crossActivate('get');
            end

            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = crossActivate('get');
            end

            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = crossActivate('get');
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

    if strcmpi(evnt.Key,'f')
        if isFusion('get')== true
            if get(uiAlphaSliderPtr('get') , 'Value') ~= 0
                set(uiAlphaSliderPtr('get') , 'Value', 0);
                if size(dicomBuffer('get'), 3) == 1
                    alpha( axePtr('get'), 1 );
                else
                    alpha( axes1Ptr('get'), 1 );
                    alpha( axes2Ptr('get'), 1 );
                    alpha( axes3Ptr('get'), 1 );
                end       

                pdColorOffset       = colorMapOffset('get');
                pdFusionColorOffset = fusionColorMapOffset('get');

                pdInvertColor     = invertColor    ('get');
                pdBackgroundColor = backgroundColor('get');
                pdOverlayColor    = overlayColor   ('get');

                setViewerDefaultColor(true, dicomMetaData('get'));
            else
                dAlphaSlider = sliderAlphaValue('get');   
                set(uiAlphaSliderPtr('get') , 'Value', dAlphaSlider);     

                if size(dicomBuffer('get'), 3) == 1
                    alpha( axePtr('get'), 1-dAlphaSlider );
                else
                    alpha( axes1Ptr('get'), 1-dAlphaSlider );
                    alpha( axes2Ptr('get'), 1-dAlphaSlider );
                    alpha( axes3Ptr('get'), 1-dAlphaSlider );
                end   

                colorMapOffset('set', pdColorOffset);
                fusionColorMapOffset('set', pdFusionColorOffset);

                invertColor('set', pdInvertColor);

                backgroundColor ('set', pdBackgroundColor);
                overlayColor    ('set', pdOverlayColor);

                setViewerDefaultColor(false, dicomMetaData('get'));

            end                     

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

            set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]); 

            set(fiMainWindowPtr('get'), 'Color', 'black');
       %     background3DOffset('set', 8); % black

            if size(dicomBuffer('get'), 3) == 1
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'black');
                colormap(axePtr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axefPtr('get'), getColorMap('one', fusionColorMapOffset('get')));                        
            else
                if switchTo3DMode('get')     == true || ...
                   switchToIsoSurface('get') == true || ...
                   switchToMIPMode('get')    == true

                % to do
                else
                    set(uiCorWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiSagWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiTraWindowPtr('get'), 'BackgroundColor', 'black');

                    colormap(axes1Ptr('get'), getColorMap('one', colorMapOffset('get')));
                    colormap(axes2Ptr('get'), getColorMap('one', colorMapOffset('get')));
                    colormap(axes3Ptr('get'), getColorMap('one', colorMapOffset('get'))); 

                    colormap(axes1fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes2fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes3fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));                                                       

                end
            end

            set(uiSliderLevelPtr('get') , 'BackgroundColor',  'black');
            set(uiSliderWindowPtr('get'), 'BackgroundColor',  'black');

            set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'black');
            set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'black');                   
            set(uiAlphaSliderPtr('get')       , 'BackgroundColor',  'black');                   
            set(uiColorbarPtr('get')         , 'Color',  'white');                   
            set(uiFusionColorbarPtr('get')   , 'Color',  'white');                   

            backgroundColor('set', 'black');
            if strcmp(getColorMap('one', colorMapOffset('get')), 'white')
                overlayColor ('set', 'black' );
            else    
                overlayColor ('set', 'white' );
            end    
         else   
            invertColor('set', true);

            set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]); 

            set(fiMainWindowPtr('get'), 'Color', 'white');
%            background3DOffset('set', 7); % white

            if size(dicomBuffer('get'), 3) == 1 
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'white');
                colormap(axePtr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axefPtr('get'), getColorMap('one', fusionColorMapOffset('get')));                                                
            else

                set(uiCorWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiSagWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiTraWindowPtr('get'), 'BackgroundColor', 'white');

                colormap(axes1Ptr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axes2Ptr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axes3Ptr('get'), getColorMap('one', colorMapOffset('get')));        

               colormap(axes1fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
               colormap(axes2fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
               colormap(axes3fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));                               
            end

            set(uiSliderLevelPtr('get') , 'BackgroundColor',  'white');
            set(uiSliderWindowPtr('get'), 'BackgroundColor',  'white');  

            set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'white');
            set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'white');                   
            set(uiAlphaSliderPtr('get')       , 'BackgroundColor',  'white'); 
            set(uiColorbarPtr('get')         , 'Color',  'black');                   
            set(uiFusionColorbarPtr('get')   , 'Color',  'black');  

            backgroundColor('set', 'white');
            if strcmp(getColorMap('one', colorMapOffset('get')), 'black')
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
            else
                pAxes1Text = axesText('get', 'axes1');
                pAxes2Text = axesText('get', 'axes2');
                pAxes3Text = axesText('get', 'axes3');

                pAxes1Text.Visible = 'off';
                pAxes2Text.Visible = 'off';
                pAxes3Text.Visible = 'off';
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
            else
                pAxes1Text = axesText('get', 'axes1');
                pAxes2Text = axesText('get', 'axes2');
                pAxes3Text = axesText('get', 'axes3');

                pAxes1Text.Visible = 'on';
                pAxes2Text.Visible = 'on';
                pAxes3Text.Visible = 'on';
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
            imf = fusionBuffer('get');   
            imf=imf(:,:,end:-1:1);
            fusionBuffer('set', imf);                    
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
        end
        
        dicomBuffer('set', im);

        if isFusion('get')
            imf = fusionBuffer('get');   
            if size(fusionBuffer('get'), 3) == 1                              
                imf=imf(:,end:-1:1);
            else
                imf=imf(:,end:-1:1,:);
            end
            fusionBuffer('set', imf);                    
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
        end
        dicomBuffer('set', im);

        if isFusion('get')
            imf = fusionBuffer('get'); 
            if size(fusionBuffer('get'), 3) == 1                              
                imf=imf(end:-1:1,:);
            else
                imf=imf(end:-1:1,:,:);
            end
            
            fusionBuffer('set', imf);                    
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
        elseif pdToggle == 2

            [dMax, dMin] = computeWindowLevel(350, 50);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =3;
        else
            [dMax, dMin] = computeWindowLevel(1000, 350);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =0;
        end               
    end                             

end
