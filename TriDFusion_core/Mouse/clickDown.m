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

    % persistent lastClickTime;
    % persistent isDoubleClick;

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        windowButton('set', 'down');  
     
        return;
    end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    % if isempty(lastClickTime)  % First click
    %     lastClickTime = datetime('now');
    %     isDoubleClick = false;
    % else
    %     timeNow = datetime('now');
    %     timeDiff = timeNow - lastClickTime;
    % 
    %     if timeDiff * 24 * 60 * 60 < 0.3  % Define the time threshold for a double-click (0.3 seconds)
    %         isDoubleClick = true;
    %         lastClickTime = [];
    %     else
    %         lastClickTime = timeNow;
    %         isDoubleClick = false;
    %     end
    % end

    % if isDoubleClick && ...
    %    isVsplash('get')          == false && ...
    %    switchTo3DMode('get')     == false && ...
    %    switchToIsoSurface('get') == false && ...
    %    switchToMIPMode('get')    == false && ...
    %   ~strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'custom')
    % 
    %     % Perform full screen action on double-click
    % 
    %     pAxe = getAxeFromMousePosition(dSeriesOffset);
    % 
    %     isCoronal  = pAxe == axes1Ptr('get', [], dSeriesOffset); 
    %     isSagittal = pAxe == axes2Ptr('get', [], dSeriesOffset);
    %     isAxial    = pAxe == axes3Ptr('get', [], dSeriesOffset);
    %     isMip      = pAxe == axesMipPtr('get', [], dSeriesOffset);
    % 
    %     if isCoronal
    %         btnUiCorWindowFullScreenCallback();
    % 
    %     elseif isSagittal 
    %         btnUiSagWindowFullScreenCallback();
    % 
    %     elseif isAxial
    %         btnUiTraWindowFullScreenCallback();
    % 
    %     elseif isMip
    %         btnUiMipWindowFullScreenCallback();
    %     end
    % else

        set(fiMainWindowPtr('get'), 'UserData', 'down');
      
        pAxe = getAxeFromMousePosition(dSeriesOffset);

        bBrush2DSameAxe = false;

        if is2DBrush('get') == true

            pRoiPtr = brush2Dptr('get'); % Adjust brush size

            if ~isempty(pRoiPtr)    

                if pAxe == pRoiPtr.Parent

                    bBrush2DSameAxe = true;
                end
            end
        end

        if is2DBrush('get') == true && bBrush2DSameAxe == true

            windowButton('set', 'down');                      

            rightClickMenu('off'); 

            % pRoiPtr = brush2Dptr('get'); % Adjust brush size
            if ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier'))

                if ~isempty(pRoiPtr)    

                    if isMoveImageActivated('get') == false
               
                        adjBrush2D(pRoiPtr, pRoiPtr.Parent.CurrentPoint(1, 1:2));
                    end
                end                
            end

            if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
               strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')

                if isMoveImageActivated('get') == false

                    pFigure = fiMainWindowPtr('get');
    
                    % set(pFigure, 'Pointer', 'bottom');
    
                    adjScroll(pFigure.CurrentPoint(1, 1:2));  
                end
            end
            
            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')
                
                if ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...                        
                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')

                    if isMoveImageActivated('get') == false

                        pFigure = fiMainWindowPtr('get');
                                
                        adjPan(pFigure.CurrentPoint(1, 1:2)); 
                    end
                end

            elseif strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend')

                if ~ismember('control', get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   ~ismember('shift'  , get(fiMainWindowPtr('get'), 'CurrentModifier')) && ...
                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')

                    if isMoveImageActivated('get') == false

                        pFigure = fiMainWindowPtr('get');
                                
                        adjZoom(pFigure.CurrentPoint(1, 1:2)); 
                    end
                end            
            else
 
                setCrossVisibility(false);                    
            
                pAxe = getAxeFromMousePosition(dSeriesOffset);
        
                isAxe      = pAxe == axePtr  ('get', [], dSeriesOffset); 
                isCoronal  = pAxe == axes1Ptr('get', [], dSeriesOffset); 
                isSagittal = pAxe == axes2Ptr('get', [], dSeriesOffset);
    %             isAxial    = pAxe == axes3Ptr('get', [], dSeriesOffset);
                if isempty(pRoiPtr)    
      
                    if isAxe
                        set(uiOneWindowPtr('get'), 'HighlightColor', [1 0 0]);
                        set(uiOneWindowPtr('get'), 'BorderType', 'line');
        
                    elseif isCoronal
                        set(uiCorWindowPtr('get'), 'HighlightColor', [1 0 0]);                    
                        set(uiCorWindowPtr('get'), 'BorderType', 'line');                    
        
                    elseif isSagittal 
                        set(uiSagWindowPtr('get'), 'HighlightColor', [1 0 0]);                    
                        set(uiSagWindowPtr('get'), 'BorderType', 'line');                    
        
                    else
                        set(uiTraWindowPtr('get'), 'HighlightColor', [1 0 0]); 
                        set(uiTraWindowPtr('get'), 'BorderType', 'line'); 
        %             else
        %                 set(uiMipWindowPtr('get'), 'HighlightColor', [1 0 0]); 
                    end 
                end

                atRoiInput = roiTemplate('get', dSeriesOffset);
                atVoiInput = voiTemplate('get', dSeriesOffset);
         
                if ~isempty(atRoiInput)
    
                    % acPtrList=[];
    
%                     aImageSize = size(dicomBuffer('get', [], dSeriesOffset));
              
                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ==1

                        acPtrList = cell(1, numel(atRoiInput));

                         for jj=1:numel(atRoiInput)
    
                            currentRoi = atRoiInput{jj};
                            
                            if isvalid(currentRoi.Object)
    
                                isAxe = strcmpi(currentRoi.Axe, 'Axe') && pAxe == axePtr('get', [], dSeriesOffset); 
                                
                                if isAxe
                                   if strcmpi(currentRoi.Object.Type, 'images.roi.freehand') || ...
                                      strcmpi(currentRoi.Object.Type, 'images.roi.polygon')   
    
                                        dVoiOffset  = [];
                                        sLesionType = [];
    
                                        if strcmpi(currentRoi.ObjectType, 'voi-roi')
    
                                            for vo=1:numel(atVoiInput)

%                                                 dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{currentRoi.Tag}), 1);

                                                if ~isempty(find(contains(atVoiInput{vo}.RoisTag,{currentRoi.Tag}), 1)) % tag exist

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
                                        acPtrList{jj} = t;
                                   end
                                end
                            end
                         end

                         acPtrList = acPtrList(~cellfun(@isempty, acPtrList));
                       
                    else
                        acPtrList = cell(1, numel(atRoiInput));
        
                        for jj=1:numel(atRoiInput)
    
                            currentRoi = atRoiInput{jj};

                            if isvalid(currentRoi.Object)
        
                                iCoronal  = sliceNumber('get', 'coronal' );
                                iSagittal = sliceNumber('get', 'sagittal');
                                iAxial    = sliceNumber('get', 'axial'   );
        
                                isCoronal  = strcmpi(currentRoi.Axe, 'Axes1') && iCoronal  == currentRoi.SliceNb && pAxe == axes1Ptr('get', [], dSeriesOffset); 
                                isSagittal = strcmpi(currentRoi.Axe, 'Axes2') && iSagittal == currentRoi.SliceNb && pAxe == axes2Ptr('get', [], dSeriesOffset);
                                isAxial    = strcmpi(currentRoi.Axe, 'Axes3') && iAxial    == currentRoi.SliceNb && pAxe == axes3Ptr('get', [], dSeriesOffset);
        
                                if isCoronal || isSagittal || isAxial

                                    if strcmpi(currentRoi.Object.Type, 'images.roi.freehand') || ...
                                       strcmpi(currentRoi.Object.Type, 'images.roi.polygon')  
    
                                        sLesionType = [];
                                        dVoiOffset  = [];
    
                                        if strcmpi(currentRoi.ObjectType, 'voi-roi')
    
                                            for vo=1:numel(atVoiInput)

%                                                 dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{ currentRoi.Tag}), 1);

                                                if ~isempty(find(contains(atVoiInput{vo}.RoisTag,{ currentRoi.Tag}), 1)) % tag exist

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
                                        else
                                            imPrt = imAxialPtr('get', [], dSeriesOffset);
%                                             t.xSize = aImageSize(1);
%                                             t.ySize = aImageSize(2);   
%                                         else
%                                             imPrt = imMipPtr('get', [], dSeriesOffset);                                            
                                        end

                                        aImageSize = size(imPrt.CData);

                                        t.xSize = aImageSize(1);
                                        t.ySize = aImageSize(2);

                                        t.Object = currentRoi.Object;
                                        t.Tag = currentRoi.Tag;
                                        acPtrList{jj} = t;
                                    end
                                end
        
                            end                    
                        end

                        acPtrList = acPtrList(~cellfun(@isempty, acPtrList));
                    end

                    currentRoiPointer('set', acPtrList);

                end
    
                uiresume(fiMainWindowPtr('get'));
            end
            
        else

            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')
        
                % if switchTo3DMode('get')     == false && ...
                %    switchToIsoSurface('get') == false && ...
                %    switchToMIPMode('get')    == false          
        
                    windowButton('set', 'down');                         

                    if isMoveImageActivated('get') == true
                        
                        set(fiMainWindowPtr('get'), 'Pointer', 'circle');
                        
                        rotateFusedImage(true);
                    else
                        % if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier'))
                        % 
                        %     if strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')
                        % 
                        %         pFigure = fiMainWindowPtr('get');
                        % 
                        %         adjWL(pFigure.CurrentPoint(1, 1:2));
                        % 
                        %     end
                        % else
                            if strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')
                            
                                pFigure = fiMainWindowPtr('get');
                                        
                                adjPan(pFigure.CurrentPoint(1, 1:2));                            
                            end
                        % end
                    end
        
                % else
                %     windowButton('set', 'down');                      
                % end
%             elseif strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend')
                
      
            else
                
                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1
        
                    % if switchTo3DMode('get')     == false && ...
                    %    switchToIsoSurface('get') == false && ...
                    %    switchToMIPMode('get')    == false
        
                        windowButton('set', 'down');
                        
                        if isMoveImageActivated('get') == true
                            
                            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
             
                            moveFusedImage(true);
                        else

                            if ismember('shift', get(fiMainWindowPtr('get'), 'CurrentModifier')) 

                                if strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')
    
                                    pFigure = fiMainWindowPtr('get');
         
                                    adjScroll(pFigure.CurrentPoint(1, 1:2));  
                                end

                            else
                                if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend') && ...
                                   strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')

                                    pFigure = fiMainWindowPtr('get');
     
                                    adjZoom(pFigure.CurrentPoint(1, 1:2));

                                else
                                    setOverlayPatientInformation(dSeriesOffset);
                   
                                    triangulateImages();
                                end

                            end
                        end
                    % else
                    %     windowButton('set', 'down');  
                    % end
                else
                    % if switchTo3DMode('get')     == false && ...
                    %    switchToIsoSurface('get') == false && ...
                    %    switchToMIPMode('get')    == false
        
                        windowButton('set', 'down');

                        if isMoveImageActivated('get') == true
                            
                            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
             
                            moveFusedImage(true);
                        else

                            if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'extend') && ...
                               strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'arrow')

                                pFigure = fiMainWindowPtr('get');
 
                                adjZoom(pFigure.CurrentPoint(1, 1:2));

                            else

                                setOverlayPatientInformation(dSeriesOffset);

                                triangulateImages();
                            end
                        end
                        
                        pAxe = getAxeFromMousePosition(dSeriesOffset);
                   
                        clickedPt = get(pAxe, 'CurrentPoint');
        
                        clickedPtX = round(clickedPt(1  ));
                        clickedPtY = round(clickedPt(1,2));
        
                        if clickedPtX > 0 && ...
                           clickedPtY > 0 && ...
                           pAxe == axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))

                            axeClicked('set', true);
                            uiresume(fiMainWindowPtr('get'));                      
                        end
        
                        refreshImages();
        
                    % end
                end
            end      
        end
    % end
end 

