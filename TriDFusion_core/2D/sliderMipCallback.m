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

    if size(dicomBuffer('get'), 3) == 1 || isVsplash('get')
        return;
    end

    hSlider = uiSliderMipPtr('get');
    if isempty(hSlider)
        return;
    end

    iMipAngle = round(get(hSlider, 'Value'));
    if iMipAngle < 0 || iMipAngle > 32
        return;
    end
    % 
    % % Determine the MIP angle
    % if sliderVal == 1
    %     iMipAngle = 32;
    % elseif sliderVal == 0
    %     iMipAngle = 1;
    % else
    %     iMipAngle = max(1, round(sliderVal * 32));
    % end

    % Update angle
    mipAngle('set', iMipAngle);

    dSeriesOffset       = get(uiSeriesPtr('get'), 'Value');
    dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

    % Update base MIP image
    imComputedMip = mipBuffer('get', [], dSeriesOffset);
    imMip         = imMipPtr('get', [], dSeriesOffset);
    imMip.CData   = permute(imComputedMip(iMipAngle, :, :), [3 2 1]);

    % Handle fusion images
    if isCombineMultipleFusion('get')
        imMipR = []; imMipG = []; imMipB = [];
    end

    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
    for rr = 1:dNbFusedSeries
        imMf = mipFusionBuffer('get', [], rr);
        if isempty(imMf)
            continue;
        end

        imMipF = imMipFPtr('get', [], rr);
        if isempty(imMipF)
            continue;
        end

        imMipF.CData = permute(imMf(iMipAngle, :, :), [3 2 1]);

        if isCombineMultipleFusion('get')
            if invertColor('get')
                redMap   = flipud(getRedColorMap());
                greenMap = flipud(getGreenColorMap());
                blueMap  = flipud(getBlueColorMap());
            else
                redMap   = getRedColorMap();
                greenMap = getGreenColorMap();
                blueMap  = getBlueColorMap();
            end

            cmap = colormap(imMipF.Parent);
            if isequal(cmap, redMap)
                imMipR = imMipF.CData;
            elseif isequal(cmap, greenMap)
                imMipG = imMipF.CData;
            elseif isequal(cmap, blueMap)
                imMipB = imMipF.CData;
            end
        end
    end

    % Combine channels if needed
    if isCombineMultipleFusion('get')
        cData = combineRGB(imMipR, imMipG, imMipB, 'Mip');
        if ~isempty(cData)
            imMipF = imMipFPtr('get', [], dFusionSeriesOffset);
            if ~isempty(imMipF)
                imMipF.CData = cData;
            end
        end
    end

    % Overlay contours if active

    if isPlotContours('get')
        imMf = squeeze(mipFusionBuffer('get', [], dFusionSeriesOffset));
        if ~isempty(imMf)
            unit = getSerieUnitValue(dFusionSeriesOffset);
            if strcmpi(unit, 'SUV')
                inputTmpl = inputTemplate('get');
                quantTmpl = quantificationTemplate('get', [], dFusionSeriesOffset);
                if ~inputTmpl(dFusionSeriesOffset).bDoseKernel && ~isempty(quantTmpl)
                    imMf = imMf * quantTmpl.tSUV.dScale;
                end
            end

            imMipFc = imMipFcPtr('get', [], dFusionSeriesOffset);
            if ~isempty(imMipFc)
                imMipFc.ZData = permute(imMf(iMipAngle, :, :), [3 2 1]);
            end
        end
    end

    % Update crosshairs if active

    if crossActivate('get')

        iCoronal  = sliceNumber('get', 'coronal');
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial');

        dims = size(dicomBuffer('get'));
        alAxesMipLine = axesLine('get', 'axesMip');

        angle = (iMipAngle - 1) * 11.25;
        switch angle
            case 0
                xOffset = iSagittal;
            case 90
                xOffset = iCoronal;
            case 180
                xOffset = dims(2) - iSagittal;
            case 270
                xOffset = dims(1) - iCoronal;
            otherwise
                theta = deg2rad(angle);
                xOffset = (iSagittal - dims(2)/2) * cos(theta) + ...
                          (iCoronal - dims(1)/2) * sin(theta) + dims(2)/2;
        end

        cSize = crossSize('get');
        iCorSize = dims(1);
        iAxiSize = dims(3);

        alAxesMipLine{1}.XData = [xOffset, xOffset];
        alAxesMipLine{1}.YData = [iAxial - 0.5, iAxial + 0.5];

        alAxesMipLine{2}.XData = [xOffset - 0.5, xOffset + 0.5];
        alAxesMipLine{2}.YData = [iAxial, iAxial];

        alAxesMipLine{3}.XData = [0, xOffset - cSize];
        alAxesMipLine{3}.YData = [iAxial, iAxial];

        alAxesMipLine{4}.XData = [xOffset + cSize, iCorSize];
        alAxesMipLine{4}.YData = [iAxial, iAxial];

        alAxesMipLine{5}.XData = [xOffset, xOffset];
        alAxesMipLine{5}.YData = [0, iAxial - cSize];

        alAxesMipLine{6}.XData = [xOffset, xOffset];
        alAxesMipLine{6}.YData = [iAxial + cSize, iAxiSize];
    end

    % Overlay text
    if overlayActivate('get')

        sText = sprintf('\n%d/32', iMipAngle);
        txt   = axesText('get', 'axesMip');
        txt.String = sText;
        txt.Color  = overlayColor('get');

        if      iMipAngle < 5
            sView = 'Left';
        elseif iMipAngle < 13
            sView = 'Posterior';
        elseif iMipAngle < 21
            sView = 'Right';
        elseif iMipAngle < 29
            sView = 'Anterior';
        else
            sView = 'Left';
        end

        viewTxt = axesText('get', 'axesMipView');
        viewTxt.String = sView;
        viewTxt.Color  = overlayColor('get');
    end

    % Plot rotated ROI
    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), ...
                        dicomBuffer('get', [], dSeriesOffset), iMipAngle);
    refreshImages();
end