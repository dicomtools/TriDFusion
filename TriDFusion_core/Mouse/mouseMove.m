function mouseMove(~, ~)
%function  mouseMove(~, ~)
%Mouse Move Action.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if isLineColorbarIntensityMaxClicked('get') == true

        axeColorbar = axeColorbarPtr('get');

        setColorbarIntensityMaxScaleValue(axeColorbar.CurrentPoint(1,2), ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get', dSeriesOffset), ...
                                          dSeriesOffset...
                                          );

        setAxesIntensity(dSeriesOffset);
      
    end

    if isLineColorbarIntensityMinClicked('get') == true
        
        axeColorbar = axeColorbarPtr('get');

        setColorbarIntensityMinScaleValue(axeColorbar.CurrentPoint(1,2), ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get', dSeriesOffset), ...
                                          dSeriesOffset...
                                          );

        setAxesIntensity(dSeriesOffset);
    end

    if isLineFusionColorbarIntensityMaxClicked('get') == true

        axeFusionColorbar = axeFusionColorbarPtr('get');

        setFusionColorbarIntensityMaxScaleValue(axeFusionColorbar.CurrentPoint(1,2), ...
                                                fusionColorbarScale('get'), ...
                                                isFusionColorbarDefaultUnit('get', get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                get(uiFusedSeriesPtr('get'), 'Value')...
                                                );        

        setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));
   end

    if isLineFusionColorbarIntensityMinClicked('get') == true
        
        axeFusionColorbar = axeFusionColorbarPtr('get');

        setFusionColorbarIntensityMinScaleValue(axeFusionColorbar.CurrentPoint(1,2), ...
                                                fusionColorbarScale('get'), ...
                                                isFusionColorbarDefaultUnit('get', get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                get(uiFusedSeriesPtr('get'), 'Value')...
                                                );        

        setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));
    end

    if is2DBrush('get') == false
    
        if strcmpi(windowButton('get'), 'down')

            if switchTo3DMode('get')     == false && ...
               switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false
    
                if strcmp(get(fiMainWindowPtr('get'),'selectiontype'),'alt')

                    if isMoveImageActivated('get') == true

                        rotateFusedImage(false);                    
                    else
                    %     if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier'))
                    % 
                    %         % if strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')
                    %         % 
                    %         %     adjWL();
                    %         % end
                    %     else
                    %         if strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')
                    % 
                    %             adjPan();
                    %         end    
                         if ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                            ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...  
                            strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow') 

                             adjPan();
                         end
                    end                 
                else
                    if isMoveImageActivated('get') == true
                        
                        moveFusedImage(false);
                    else
                        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                            if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                               strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom') 

                                adjScroll();

                            else
                                if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend') && ...
                                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow') 
     
                                    adjZoom();          
                                else                        
                                    triangulateImages();  
                                end
                            end
                        else

                            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend')
                                if ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                                   ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow') 

                                    adjZoom();     
                                end
                            else                               
                                refreshImages();
                            end
                        end
                    end
                end
                
            else            
                updateObjet3DPosition();      
            end
                
        end    
    else

        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1 && ...
           strcmpi(windowButton('get'), 'down') 

            if isMoveImageActivated('get') == false   

                % rightClickMenu('off');

                if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')

                    adjScroll();
    
                elseif ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                       strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow') 

                    if is2DBrush('get') == true
              
                        pRoiPtr = brush2Dptr('get');
            
                        if ~isempty(pRoiPtr) 
    
                            if strcmpi(windowButton('get'), 'down')
    
                                adjBrush2D(pRoiPtr);
                            end
                        end
                    end
                    
                elseif strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend') && ...
                       strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')                    

                        adjZoom();          
                end
            end
        else
            if strcmpi(windowButton('get'), 'down')

                if isMoveImageActivated('get') == false   

                    if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend') && ...
                       ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...    
                       ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                       strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')                    

                        adjZoom();   
    
                    elseif ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                           strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')                    

                        if is2DBrush('get') == true

                            pRoiPtr = brush2Dptr('get');
                
                            if ~isempty(pRoiPtr)
                      
                                adjBrush2D(pRoiPtr);
                            end
                        end           
                    end  
                end
            end

        end

        if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt') && ...
           strcmpi(windowButton('get'), 'down') 
             
            if isMoveImageActivated('get') == false   

                % rightClickMenu('off');

                if ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')       

                    adjPan();          
                end

            end
        else

            pRoiPtr = brush2Dptr('get');

            if ~isempty(pRoiPtr) 
    
                % pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                pRoiPtr.Position = pRoiPtr.Parent.CurrentPoint(1, 1:2);
        
                if strcmpi(windowButton('get'), 'down')  
                    
                    if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend')

                        if ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier'))

                            adjBrush2D(pRoiPtr);
                        end
                        
                    else
                        if ~isempty(roiTemplate('get', dSeriesOffset))
    
                            acPtrList = currentRoiPointer('get');
    
                            for jj=1:numel(acPtrList)
    
                                if isvalid(acPtrList{jj}.Object)
    
                                    brushRoi2D(pRoiPtr, acPtrList{jj}.Object, acPtrList{jj}.xSize, acPtrList{jj}.ySize, acPtrList{jj}.VoiOffset, acPtrList{jj}.LesionType, dSeriesOffset);
                                end
                            end
                        else
                            releaseRoiWait();
    
                            roiSetAxeBorder(false);
    
                            setCrossVisibility(true);
                        end
                    end
          %          brushRoi2D(a{3}.Object, a{2}.Object);
                end
            end
        end
    end
    
    toolbarIconHover();
end  