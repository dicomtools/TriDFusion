function sliderMipCallback(~, ~)
%function sliderMipCallback(~, ~)
%Set MIP Slider.
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

    if size(dicomBuffer('get'), 3) == 1
        return;
    end

    if isVsplash('get') == true
        return;
    end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

    if get(uiSliderMipPtr('get'), 'Value') >= 0 && ...
       get(uiSliderMipPtr('get'), 'Value') <= 1     
        
    
        if get(uiSliderMipPtr('get'), 'Value') == 1 
            iMipAngle = 32;
        elseif get(uiSliderMipPtr('get'), 'Value') == 0
            iMipAngle = 1;
        else
            iMipAngle = round(get(uiSliderMipPtr('get'), 'Value') * 32);
            if iMipAngle == 0
                iMipAngle = 1;
            end
        end        
     
        mipAngle('set', iMipAngle);
        
        imComputedMip = mipBuffer('get', [], dSeriesOffset);
        imMip = imMipPtr ('get', [], dSeriesOffset);        
        imMip.CData = permute(imComputedMip(iMipAngle,:,:), [3 2 1]);
        
        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

        imMipR      = [];
        imMipG      = [];
        imMipB      = [];

        for rr=1:dNbFusedSeries

           imMf = mipFusionBuffer('get', [], rr);

           if ~isempty(imMf)
                imMipF = imMipFPtr('get', [], rr);
                if ~isempty(imMipF)

                    imMipF.CData = permute(imMf(iMipAngle,:,:), [3 2 1]);

                    if isCombineMultipleFusion('get') == true

                        if invertColor('get')
                            aRedColorMap   = flipud(getRedColorMap());
                            aGreenColorMap = flipud(getGreenColorMap());
                            aBlueColorMap  = flipud(getBlueColorMap());
                        else
                            aRedColorMap   = getRedColorMap();
                            aGreenColorMap = getGreenColorMap();
                            aBlueColorMap  = getBlueColorMap();
                        end

                        if colormap(imMipF.Parent) == aRedColorMap
                            imMipR  = imMipF.CData;
                        end

                        if colormap(imMipF.Parent) == aGreenColorMap
                            imMipG  = imMipF.CData;
                        end

                        if colormap(imMipF.Parent) == aBlueColorMap
                            imMipB  = imMipF.CData;
                        end
                    end
                end
            end
        end

        if isCombineMultipleFusion('get') == true

            cData = combineRGB(imMipR, imMipG, imMipB, 'Mip');
            if ~isempty(cData)
                imMipF = imMipFPtr('get', [], dFusionSeriesOffset);
                if ~isempty(imMipF)
                    imMipF.CData = cData;
                end
            end
        end

        if isPlotContours('get') == true

           imf = squeeze(fusionBuffer('get', [], dFusionSeriesOffset));
           if ~isempty(imf)

                sUnitDisplay = getSerieUnitValue(dFusionSeriesOffset);
                if strcmpi(sUnitDisplay, 'SUV')
                    tQuantification = quantificationTemplate('get', [], dFusionSeriesOffset);
                    if atInputTemplate(dFusionSeriesOffset).bDoseKernel == false
                        if ~isempty(tQuantification)
                            imMf = imMf*tQuantification.tSUV.dScale;
                        end
                    end
                end

                imMipFc = imMipFcPtr('get', [], dFusionSeriesOffset);
 
                if ~isempty(imMipFc)
                    imMipFc.ZData  = permute(imMf(iMipAngle,:,:), [3 2 1]);
                end
            end
        end

        if overlayActivate('get') == true 
            
            sAxeMipText = sprintf('\n%d/32', iMipAngle);                  
 
            tAxesMipText = axesText('get', 'axesMip');                                      
            tAxesMipText.String = sAxeMipText;
            tAxesMipText.Color  = overlayColor('get');             

            if      iMipAngle < 5
                sMipAngleView = 'Left';
            elseif iMipAngle > 4 && iMipAngle < 13  
                sMipAngleView = 'Posterior';
            elseif iMipAngle > 12 && iMipAngle < 21  
                sMipAngleView = 'Right';
            elseif iMipAngle > 20 && iMipAngle < 29  
                sMipAngleView = 'Anterior';
            else
                sMipAngleView = 'Left';
            end 
            
            tAxesMipViewText = axesText('get', 'axesMipView');                                      
            tAxesMipViewText.String = sMipAngleView;
            tAxesMipViewText.Color  = overlayColor('get');              
        end  

        if crossActivate('get') == true

            iCoronal  = sliceNumber('get', 'coronal');
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            iCoronalSize  = size(dicomBuffer('get'),1);
            iSagittalSize = size(dicomBuffer('get'),2);
            iAxialSize    = size(dicomBuffer('get'),3);

            alAxesMipLine = axesLine('get', 'axesMip');
            
            angle = (iMipAngle - 1) * 11.25; % to rotate 90 counterclockwise

if 0
            if angle >= 0 && angle < 180
                ratio = (iMipAngle-1) * 0.102;

            else
                ratio = (17*0.102)-(iMipAngle-16)*0.102;
            end

            xOffset = (iSagittal * (1 - ratio)) + (iCoronal * ratio)
else
            if angle == 0
                xOffset = iSagittal;
            elseif angle == 90
                xOffset = iCoronal;
            elseif angle == 180
                xOffset = iSagittalSize - iSagittal;
            elseif angle == 270
                xOffset = iCoronalSize - iCoronal;
            else
                angleRad = deg2rad(angle);
                centerX = iSagittalSize / 2;
                centerY = iCoronalSize / 2;
                cosAngle = cos(angleRad);
                sinAngle = sin(angleRad);
                xOffset = (iSagittal - centerX) * cosAngle + (iCoronal - centerY) * sinAngle + centerX;
            end    
  
end

            % Set MIP Line 1-5 with found xOffset
            
            alAxesMipLine{1}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{1}.YData = [iAxial - 0.5, iAxial + 0.5];
            
            alAxesMipLine{2}.XData = [xOffset(1) - 0.5, xOffset(1) + 0.5];
            alAxesMipLine{2}.YData = [iAxial, iAxial];
            
            alAxesMipLine{3}.XData = [0, xOffset(1) - crossSize('get')];
            alAxesMipLine{3}.YData = [iAxial, iAxial];
            
            alAxesMipLine{4}.XData = [xOffset(1) + crossSize('get'), iCoronalSize];
            alAxesMipLine{4}.YData = [iAxial, iAxial];
            
            alAxesMipLine{5}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{5}.YData = [0, iAxial - crossSize('get')];
            
            alAxesMipLine{6}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{6}.YData = [iAxial + crossSize('get'), iAxialSize];
    
            if multiFrameRecord('get') == false
    
                if multiFramePlayback('get') == false && ...
                   crossActivate('get') == true

                    for ll=1:numel(alAxesMipLine)
                        set(alAxesMipLine{ll}, 'Visible', 'on');
                    end
                else
                    for ll=1:numel(alAxesMipLine)
                        set(alAxesMipLine{ll}, 'Visible', 'off');
                    end
                end
            end          
        end 
    end
end