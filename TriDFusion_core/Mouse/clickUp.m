function clickUp(~, ~)
%function clickUp(~, ~)
%Set the status of the Viewer progress bar.
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

    windowButton('set', 'up'); 

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    bRefreshImage = false;

    if isLineColorbarIntensityMaxClicked('get') == true

        isLineColorbarIntensityMaxClicked('set', false);
        bRefreshImage = true;
    end

    if isLineColorbarIntensityMinClicked('get') == true   

        isLineColorbarIntensityMinClicked('set', false);
        bRefreshImage = true;
    end
    
    if isLineFusionColorbarIntensityMaxClicked('get') == true

        isLineFusionColorbarIntensityMaxClicked('set', false);
        bRefreshImage = true;
    end

    if isLineFusionColorbarIntensityMinClicked('get') == true

        isLineFusionColorbarIntensityMinClicked('set', false);
        bRefreshImage = true;
    end

    if bRefreshImage == true

       set(fiMainWindowPtr('get'), 'Pointer', 'default');            
       refreshImages();
    end

    set(fiMainWindowPtr('get'), 'UserData', 'up');

    if switchTo3DMode('get')      == true || ...
       switchToIsoSurface('get')  == true || ...
       switchToMIPMode('get')     == true
      
        mipICObj = mipICObject('get');
        if ~isempty(mipICObj)
            mipICObj.mouseMode = 1;
            set(mipICObj.figureHandle, 'WindowButtonMotionFcn', '');
        end

        volICObj = volICObject('get');                
        if ~isempty(volICObj)
            volICObj.mouseMode = 1;
            set(volICObj.figureHandle, 'WindowButtonMotionFcn', '');                
        end

        mipICFusionObj = mipICFusionObject('get');
        if ~isempty(mipICFusionObj)
            mipICFusionObj.mouseMode = 1;
            set(mipICFusionObj.figureHandle, 'WindowButtonMotionFcn', '');
        end       

        volICFusionObj = volICFusionObject('get');
        if ~isempty(volICFusionObj)
            volICFusionObj.mouseMode = 1;
            set(volICFusionObj.figureHandle, 'WindowButtonMotionFcn', '');
        end
        
        updateObjet3DPosition();      
    else
        if isMoveImageActivated('get') == true
            
            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');
        else

            if is2DBrush('get') == true

                atRoiInput = roiTemplate('get', dSeriesOffset);

                acPtrList = currentRoiPointer('get'); 

                for jj=1:numel(acPtrList) % Need to set ROI template new position

                    if isvalid(acPtrList{jj}.Object)

                        dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), acPtrList{jj}.Tag ), 1);

                        if ~isempty(dTagOffset)

                            atRoiInput{dTagOffset}.Position = acPtrList{jj}.Object.Position;

                            tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [],  dSeriesOffset), dicomMetaData('get', [],  dSeriesOffset), atRoiInput{dTagOffset}, false, false);

                            atRoiInput{dTagOffset}.MaxDistances = tMaxDistances;   
                        end
             %           editorRoiMoving(pRoiPtr, acPtrList{jj}.Object);
                    end
                end                

                roiTemplate('set', dSeriesOffset, atRoiInput);

                pRoiPtr = brush2Dptr('get');
                
                if ~isempty(pRoiPtr)

                    pRoiPtr.Position = pRoiPtr.Parent.CurrentPoint(1, 1:2);
                end
                
                if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')

                    set(fiMainWindowPtr('get'), 'selectiontype', 'normal');
                end

            else
                if strcmpi(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')
                   
                    if showRightClickMenu() == true
                        
                        if ~isempty(copyRoiPtr('get')) 
            
                            rightClickMenu('on');
                        end                     
                    end

                    % pFigure = fiMainWindowPtr('get');
                    % 
                    % adjWL(pFigure.CurrentPoint(1, 1:2));   

        % refreshImages();
                    
                end

            end

        end
        
    end

end