function clickDown(~, ~)
%function  clickDown(~, ~)
%Mouse Click Down Action.
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

%    fusedImageRotationValues('set', false);
%    fusedImageMovementValues('set', false);

    % Callback function to detect a double-click on the figure

    persistent lastClickTime;
    persistent isDoubleClick;
    
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if isempty(lastClickTime)  % First click
        lastClickTime = now;
        isDoubleClick = false;
    else
        timeNow = now;
        timeDiff = timeNow - lastClickTime;
        
        if timeDiff * 24 * 60 * 60 < 0.3  % Define the time threshold for a double-click (0.3 seconds)
            isDoubleClick = true;
            lastClickTime = [];
        else
            lastClickTime = timeNow;
            isDoubleClick = false;
        end
    end

    if isDoubleClick && ...
       isVsplash('get')          == false && ...
       switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false 
       

        % Perform full screen action on double-click

        gca = getAxeFromMousePosition(dSeriesOffset);

        isCoronal  = gca == axes1Ptr('get', [], dSeriesOffset); 
        isSagittal = gca == axes2Ptr('get', [], dSeriesOffset);
        isAxial    = gca == axes3Ptr('get', [], dSeriesOffset);
        isMip      = gca == axesMipPtr('get', [], dSeriesOffset);

        if isCoronal
            btnUiCorWindowFullScreenCallback();
        elseif isSagittal 
            btnUiSagWindowFullScreenCallback();
        elseif isAxial
            btnUiTraWindowFullScreenCallback();
        elseif isMip
            btnUiMipWindowFullScreenCallback();
        end
    else
        set(fiMainWindowPtr('get'), 'UserData', 'down');

        if is2DBrush('get') == true
    
            setCrossVisibility(false);                    
    
            windowButton('set', 'down');                      

            gca = getAxeFromMousePosition(dSeriesOffset);
    
            isAxe      = gca == axePtr  ('get', [], dSeriesOffset); 
            isCoronal  = gca == axes1Ptr('get', [], dSeriesOffset); 
            isSagittal = gca == axes2Ptr('get', [], dSeriesOffset);
            isAxial    = gca == axes3Ptr('get', [], dSeriesOffset);
    
            if isAxe
                set(uiOneWindowPtr('get'), 'HighlightColor', [1 0 0]);
            elseif isCoronal
                set(uiCorWindowPtr('get'), 'HighlightColor', [1 0 0]);                    
            elseif isSagittal 
                set(uiSagWindowPtr('get'), 'HighlightColor', [1 0 0]);                    
            elseif isAxial
                set(uiTraWindowPtr('get'), 'HighlightColor', [1 0 0]); 
            else
                set(uiMipWindowPtr('get'), 'HighlightColor', [1 0 0]); 
            end  
    
            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')
    
                pRoiPtr = brush2Dptr('get'); % Adjust brush size
                if ~isempty(pRoiPtr)    
                   adjBrush2D(pRoiPtr, get(0, 'PointerLocation'));
                end            
            else
    
                atRoiInput = roiTemplate('get', dSeriesOffset);
                atVoiInput = voiTemplate('get', dSeriesOffset);
         
                if ~isempty(atRoiInput)
    
                    acPtrList=[];
    
%                     aImageSize = size(dicomBuffer('get', [], dSeriesOffset));
              
                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ==1
                         for jj=1:numel(atRoiInput)
    
                            currentRoi = atRoiInput{jj};
                            
                            if isvalid(currentRoi.Object)
    
                                isAxe = strcmpi(currentRoi.Axe, 'Axe') && gca == axePtr('get', [], dSeriesOffset); 
                                
                                if isAxe
                                   if strcmpi(currentRoi.Object.Type, 'images.roi.freehand') || ...
                                      strcmpi(currentRoi.Object.Type, 'images.roi.polygon')   
    
                                        dVoiOffset  = [];
                                        sLesionType = [];
    
                                        if strcmpi(currentRoi.ObjectType, 'voi-roi')
    
                                            for vo=1:numel(atVoiInput)
                                                dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{currentRoi.Tag}), 1);
                                                if ~isempty(dTagOffset) % tag exist
                                                    dVoiOffset=vo;
                                                    sLesionType = atVoiInput{vo}.LesionType;
                                                    break;
                                                end
                                            end
    
                                        end
    
                                        t.VoiOffset = dVoiOffset;
                                        t.LesionType = sLesionType;
                                        
                                        imAxe = imAxePtr('get', [], dSeriesOffset);

                                        aImageSize = size(imAxe.CData);

                                        t.xSize = aImageSize(1);
                                        t.ySize = aImageSize(2);                                 
    
                                        t.Object = currentRoi.Object;
                                        t.Tag = currentRoi.Tag;
                                        acPtrList{numel(acPtrList)+1} = t;
                                   end
                                end
                            end
                         end
                    else
                                
                        for jj=1:numel(atRoiInput)
    
                            currentRoi = atRoiInput{jj};
                            
                            if isvalid(currentRoi.Object)
        
                                iCoronal  = sliceNumber('get', 'coronal' );
                                iSagittal = sliceNumber('get', 'sagittal');
                                iAxial    = sliceNumber('get', 'axial'   );
        
                                isCoronal  = strcmpi(currentRoi.Axe, 'Axes1') && iCoronal  == currentRoi.SliceNb && gca == axes1Ptr('get', [], dSeriesOffset); 
                                isSagittal = strcmpi(currentRoi.Axe, 'Axes2') && iSagittal == currentRoi.SliceNb && gca == axes2Ptr('get', [], dSeriesOffset);
                                isAxial    = strcmpi(currentRoi.Axe, 'Axes3') && iAxial    == currentRoi.SliceNb && gca == axes3Ptr('get', [], dSeriesOffset);
        
                                if isCoronal || isSagittal || isAxial
                                    if strcmpi(currentRoi.Object.Type, 'images.roi.freehand') || ...
                                       strcmpi(currentRoi.Object.Type, 'images.roi.polygon')  
    
                                        sLesionType = [];
                                        dVoiOffset  = [];
    
                                        if strcmpi(currentRoi.ObjectType, 'voi-roi')
    
                                            for vo=1:numel(atVoiInput)
                                                dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{ currentRoi.Tag}), 1);
                                                if ~isempty(dTagOffset) % tag exist
                                                    dVoiOffset=vo;
                                                    sLesionType = atVoiInput{vo}.LesionType;
                                                    break;
                                                end
                                            end
    
                                        end
    
                                        t.VoiOffset = dVoiOffset;
                                        t.LesionType = sLesionType;
    
                                        if isCoronal
                                            imPrt = imCoronalPtr('get', [], dSeriesOffset);
%                                             t.xSize = aImageSize(1);
%                                             t.ySize = aImageSize(3);
                                        elseif isSagittal 
                                            imPrt = imSagittalPtr('get', [], dSeriesOffset);
%                                             t.xSize = aImageSize(2);
%                                             t.ySize = aImageSize(3);                                        
                                        elseif isAxial
                                            imPrt = imAxialPtr('get', [], dSeriesOffset);
%                                             t.xSize = aImageSize(1);
%                                             t.ySize = aImageSize(2);   
                                        else
                                            imPrt = imMipPtr('get', [], dSeriesOffset);                                            
                                        end

                                        aImageSize = size(imPrt.CData);

                                        t.xSize = aImageSize(1);
                                        t.ySize = aImageSize(2);

                                        t.Object = currentRoi.Object;
                                        t.Tag = currentRoi.Tag;
                                        acPtrList{numel(acPtrList)+1} = t;
                                    end
                                end
        
                            end                    
                        end
                    end
                    currentRoiPointer('set', acPtrList);
                end
    
                triangulateImages();  
            end
            
        else
    
            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')
        
                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false          
        
                    windowButton('set', 'down');                         
                    if isMoveImageActivated('get') == true
                        
                        set(fiMainWindowPtr('get'), 'Pointer', 'circle');
                        
                        rotateFusedImage(true);
                    else
                        adjWL(get(0, 'PointerLocation'));
                    end
        
                else
                    windowButton('set', 'down');                      
                end
        
            else
        
                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1
        
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false
        
                        windowButton('set', 'down');
                        if isMoveImageActivated('get') == true
                            
                            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
             
                            moveFusedImage(true);
                        else
                            triangulateImages();
                        end
                    else
                        windowButton('set', 'down');  
                    end
                else
                    if switchTo3DMode('get')     == false && ...
                       switchToIsoSurface('get') == false && ...
                       switchToMIPMode('get')    == false
        
                        windowButton('set', 'down');
                        if isMoveImageActivated('get') == true
                            
                            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
             
                            moveFusedImage(true);
                        else
                            triangulateImages();
                        end
                        
                        gca = getAxeFromMousePosition(dSeriesOffset);
                   
                        clickedPt = get(gca, 'CurrentPoint');
        
                        clickedPtX = round(clickedPt(1  ));
                        clickedPtY = round(clickedPt(1,2));
        
                        if clickedPtX > 0 && ...
                           clickedPtY > 0 && ...
                            gca == axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))

                            axeClicked('set', true);
                            uiresume(fiMainWindowPtr('get'));                      
                        end
        
                        refreshImages();
        
                    end
                end
            end      
        end
    end
end 

