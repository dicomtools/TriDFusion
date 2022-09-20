function refreshImages()
%function refreshImages()
%Refresh the 2D DICOM images and overlay base on position.
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

    im = squeeze(dicomBuffer('get'));

    tInput = inputTemplate('get');

    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(tInput)
        return;
    end

    if overlayActivate('get') == true

        atMetaData = dicomMetaData('get');

        if isfield(atMetaData{1}, 'PatientName')
            sPatientName = atMetaData{1}.PatientName;
            sPatientName = strrep(sPatientName,'^',' ');
            sPatientName = strtrim(sPatientName);
        else
            sPatientName = '';
        end

        if isfield(atMetaData{1}, 'PatientID')
            sPatientID = atMetaData{1}.PatientID;
            sPatientID = strtrim(sPatientID);
        else
            sPatientID = '';
        end

        if isfield(atMetaData{1}, 'SeriesDescription')
            sSeriesDescription = atMetaData{1}.SeriesDescription;
            sSeriesDescription = strrep(sSeriesDescription,'_',' ');
            sSeriesDescription = strrep(sSeriesDescription,'^',' ');
            sSeriesDescription = strtrim(sSeriesDescription);
        else
            sSeriesDescription = '';
        end

        if isfield(atMetaData{1}, 'RadiopharmaceuticalInformationSequence')
            sRadiopharmaceutical = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
        else
            sRadiopharmaceutical = '';
        end

        if isfield(atMetaData{1}, 'SeriesDate')

            if isempty(atMetaData{1}.SeriesDate)
                sSeriesDate = '';
            else
                sSeriesDate = atMetaData{1}.SeriesDate;
                if isempty(atMetaData{1}.SeriesTime)
                    sSeriesTime = '000000';
                else
                    sSeriesTime = atMetaData{1}.SeriesTime;
                end
                sSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
            end

            if ~isempty(sSeriesDate)
                if contains(sSeriesDate,'.')
                    sSeriesDate = extractBefore(sSeriesDate,'.');
                end
                sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMddHHmmss');
            end
        else
            sSeriesDate = '';
        end

    end

    if size(im, 3) == 1

        imAxeR = [];
        imAxeG = [];
        imAxeB = [];

        imAxe  = imAxePtr ('get', [], get(uiSeriesPtr('get'), 'Value'));

        vBoundAxePtr = visBoundAxePtr('get');
        if ~isempty(vBoundAxePtr)
            delete(vBoundAxePtr);
        end

%             lMin  = windowLevel('get', 'min');
%             lMax = windowLevel('get', 'max');

        im=im(:,:);

%               imshow(im, [lMin lMax], 'Parent', axe);
%           if exist('axe')
%               cla(axe,'reset');
%           end

%           set(axe, 'Units', 'normalized','Position', [0 0 1 1], 'Visible' , 'off', 'Ydir','reverse', 'XLim', [0 inf], 'YLim', [0 inf], 'CLim', [lMin lMax]);

%            if aspectRatio('get') == true
%                daspect(axe, [1 1 1]);
%            end

%            if gaussFilter('get') == true
%   %             imagesc(imgaussfilt(im, 1), 'Parent', axe);
%                surface(imgaussfilt(im), 'linestyle','none', 'Parent', axe);
%            else
         %   surface(im, 'linestyle','none', 'Parent', axe);
         imAxe.CData = im;
         if isFusion('get') == true
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries

                imf = squeeze(fusionBuffer('get', [], rr));

                if ~isempty(imf)
                    imAxeF = imAxeFPtr('get', [], rr);
                    if ~isempty(imAxeF)
                        imAxeF.CData  = imf;

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

                            if colormap(imAxeF.Parent) == aRedColorMap
                                imAxeR  = imAxeF.CData;
                            end

                            if colormap(imAxeF.Parent) == aGreenColorMap
                                imAxeG  = imAxeF.CData;
                            end

                            if colormap(imAxeF.Parent) == aBlueColorMap
                                imAxeB  = imAxeF.CData;
                            end
                        end
                    end
                end
            end

            if isCombineMultipleFusion('get') == true

                cData = combineRGB(imAxeR, imAxeG, imAxeB, 'Axe');
                if ~isempty(cData)
                    if ~isempty(imAxeF)
                        imAxeF.CData = cData;
                    end
                end
            end

         end

%   %             imagesc(im, 'Parent', axe);
%            end

%             if isShading('get') == true
%                 shading(axe, 'interp');
%             end
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        if ~isempty(atRoiInput)
            for bb=1:numel(atRoiInput)
                if isvalid(atRoiInput{bb}.Object)
                    atRoiInput{bb}.Object.Visible = 'on';
                    if viewFarthestDistances('get') == true
                        if ~isempty(atRoiInput{bb}.MaxDistances)
                            atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'on';
                        end
                    else
                        if ~isempty(atRoiInput{bb}.MaxDistances)
                            atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'off';
                        end
                    end
               end
            end
        end

        if overlayActivate('get') == true

            clickedPt = get(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CurrentPoint');

            aBufferSize = size(im);

            clickedPtX = round(clickedPt(1,1));
            if clickedPtX < 1
                clickedPtX = 1;
            end
            if clickedPtX > aBufferSize(2)
                clickedPtX =  aBufferSize(2);
            end

            clickedPtY = round(clickedPt(1,2));
            if clickedPtY < 1
                clickedPtY = 1;
            end
            if clickedPtY > aBufferSize(1)
                clickedPtY =  aBufferSize(1);
            end

            tQuant = quantificationTemplate('get');
            dCurrent = im(clickedPtY, clickedPtX);

            lMin = windowLevel('get', 'min');
            lMax = windowLevel('get', 'max');

            sAxeText = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nLookup Table: %s - %s\n[X,Y] %s,%s', ...
                sPatientName, ...
                sPatientID,  ...
                sSeriesDescription, ...
                sSeriesDate,...
                num2str(tQuant.tCount.dMin), ...
                num2str(tQuant.tCount.dMax), ...
                num2str(tQuant.tCount.dSum),...
                num2str(dCurrent),...
                num2str(lMin), ...
                num2str(lMax),...
                num2str(clickedPtX), ...
                num2str(clickedPtY));

            tAxeText = axesText('get', 'axe');
            tAxeText.String = sAxeText;
            tAxeText.Color  = overlayColor('get');

            if isFusion('get') == true

                sAxefText = '';

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imf = squeeze(fusionBuffer('get', [], rr));

                    if ~isempty(imf)
                        imAxeF = imAxeFPtr('get', [], rr);
                        if ~isempty(imAxeF)

                            atFuseMetaData = tInput(rr).atDicomInfo;

                            if isfield(atFuseMetaData{1}, 'SeriesDescription')
                                sFusedSeriesDescription = atFuseMetaData{1}.SeriesDescription;
                                sFusedSeriesDescription = strrep(sFusedSeriesDescription,'_',' ');
                                sFusedSeriesDescription = strrep(sFusedSeriesDescription,'^',' ');
                                sFusedSeriesDescription = strtrim(sFusedSeriesDescription);
                            else
                                sFusedSeriesDescription = '';
                            end

                            if isfield(atFuseMetaData{1}, 'SeriesDate')

                                if isempty(atFuseMetaData{1}.SeriesDate)
                                    sFusedSeriesDate = '';
                                else
                                    sFusedSeriesDate = atFuseMetaData{1}.SeriesDate;
                                    if isempty(atFuseMetaData{1}.SeriesTime)
                                        sFusedSeriesTime = '000000';
                                    else
                                        sFusedSeriesTime = atFuseMetaData{1}.SeriesTime;
                                    end
                                    sFusedSeriesDate = sprintf('%s%s', sFusedSeriesDate, sFusedSeriesTime);
                                end

                                if ~isempty(sFusedSeriesDate)
                                    if contains(sFusedSeriesDate,'.')
                                        sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
                                    end
                                    sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
                                end
                            else
                                sFusedSeriesDate = '';
                            end

                            sColorMap = getColorMap('name', [], colormap(imAxeF.Parent));

%                            imf = squeeze(fusionBuffer('get', [], rr));
                            dFusedCurrent = imf(clickedPtY, clickedPtX);

                            sAxefText = sprintf('%s\n%s\n%s\nColormap: %s\nCurrent: %s\n', ...
                                            sAxefText, ...
                                            sFusedSeriesDescription, ...
                                            sFusedSeriesDate, ...
                                            sColorMap, ...
                                            num2str(dFusedCurrent) ...
                                            );

                        end
                    end
                end

            else
                sAxefText = '';
            end

            tAxefText = axesText('get', 'axef');
            tAxefText.String = sAxefText;
            tAxefText.Color  = overlayColor('get');

        end

%         overlayText();

%         colormap(axe, getColorMap('one', colorMapOffset('get')));
%         colorbar(axe, 'EdgeColor', overlayColor('get'), 'ButtonDownFcn', @colorbarCallback);

    else

        imCoronalR  = [];
        imSagittalR = [];
        imAxialR    = [];
        imMipR      = [];

        imCoronalG  = [];
        imSagittalG = [];
        imAxialG    = [];
        imMipG      = [];

        imCoronalB  = [];
        imSagittalB = [];
        imAxialB    = [];
        imMipB      = [];

        imCoronal  = imCoronalPtr ('get', [], get(uiSeriesPtr('get'), 'Value'));
        imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
        imAxial    = imAxialPtr   ('get', [], get(uiSeriesPtr('get'), 'Value'));
        if isVsplash('get') == false
            imMip = imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
        end
          
        imCoronalFc  = imCoronalFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        imSagittalFc = imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        imAxialFc    = imAxialFcPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        if isVsplash('get') == false
            imMipFc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        end

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );
        iMipAngle = mipAngle('get');

        vBoundAxes1Ptr = visBoundAxes1Ptr('get');
        vBoundAxes2Ptr = visBoundAxes2Ptr('get');
        vBoundAxes3Ptr = visBoundAxes3Ptr('get');

        if ~isempty(vBoundAxes1Ptr)
            delete(vBoundAxes1Ptr);
        end

        if ~isempty(vBoundAxes2Ptr)
            delete(vBoundAxes2Ptr);
        end

        if ~isempty(vBoundAxes3Ptr)
            delete(vBoundAxes3Ptr);
        end

        if isVsplash('get') == true

            if strcmpi(vSplahView('get'), 'coronal') || ...
               strcmpi(vSplahView('get'), 'all')

                imComputed = computeMontage(im, 'coronal', iCoronal);

                imAxSize = size(imCoronal.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                imCoronal.CData = imComputed;
            end

            if strcmpi(vSplahView('get'), 'sagittal') || ...
               strcmpi(vSplahView('get'), 'all')

                imComputed = computeMontage(im, 'sagittal', iSagittal);

                imAxSize = size(imSagittal.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                imSagittal.CData = imComputed;
            end

            if strcmpi(vSplahView('get'), 'axial') || ...
               strcmpi(vSplahView('get'), 'all')

                imComputed = computeMontage(im(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                imAxSize = size(imAxial.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                imAxial.CData = imComputed;
         %       imAxial.CData = imAxial.CData(:,end:-1:1); % reverse order
            end

            if isFusion('get') == true

                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                drawnow;

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
                end

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imf = squeeze(fusionBuffer('get', [], rr));
                    if ~isempty(imf)

                        if strcmpi(vSplahView('get'), 'coronal') || ...
                           strcmpi(vSplahView('get'), 'all')

                            imCoronalF  = imCoronalFPtr('get', [], rr);
                            if ~isempty(imCoronalF)
                                imComputed = computeMontage(imf, 'coronal', iCoronal);

                                imAxSize = size(imCoronalF.CData);
                                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                                imCoronalF.CData = imComputed;

                                if isCombineMultipleFusion('get') == true

                                    if colormap(imCoronalF.Parent) == aRedColorMap
                                        imCoronalR  = imCoronalF.CData;
                                    end

                                    if colormap(imCoronalF.Parent) == aGreenColorMap
                                        imCoronalG  = imCoronalF.CData;
                                    end

                                    if colormap(imCoronalF.Parent) == aBlueColorMap
                                        imCoronalB  = imCoronalF.CData;
                                    end
                                end
                            end
                        end

                        if strcmpi(vSplahView('get'), 'sagittal') || ...
                           strcmpi(vSplahView('get'), 'all')

                            imSagittalF = imSagittalFPtr('get', [], rr);
                            if ~isempty(imSagittalF)

                                imComputed = computeMontage(imf, 'sagittal', iSagittal);

                                imAxSize = size(imSagittalF.CData);
                                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                                imSagittalF.CData = imComputed;

                                if isCombineMultipleFusion('get') == true

                                    if colormap(imSagittalF.Parent) == aRedColorMap
                                        imSagittalR = imSagittalF.CData;
                                    end

                                    if colormap(imSagittalF.Parent) == aGreenColorMap
                                        imSagittalG = imSagittalF.CData;
                                    end

                                    if colormap(imSagittalF.Parent) == aBlueColorMap
                                        imSagittalB = imSagittalF.CData;
                                    end
                                end
                            end
                        end

                        if strcmpi(vSplahView('get'), 'axial') || ...
                           strcmpi(vSplahView('get'), 'all')

                            imAxialF = imAxialFPtr('get', [], rr);
                            if ~isempty(imAxialF)

                                imComputed = computeMontage(imf(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                                imAxSize = size(imAxialF.CData);
                                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                                imAxialF.CData = imComputed;

                                if isCombineMultipleFusion('get') == true

                                    if colormap(imAxialF.Parent) == aRedColorMap
                                        imAxialR  = imAxialF.CData;
                                    end

                                    if colormap(imAxialF.Parent) == aGreenColorMap
                                        imAxialG  = imAxialF.CData;
                                    end

                                    if colormap(imAxialF.Parent) == aBlueColorMap
                                        imAxialB  = imAxialF.CData;
                                    end
                                end
                            end
                        end
                    end
                end

                if isCombineMultipleFusion('get') == true

                    if strcmpi(vSplahView('get'), 'coronal') || ...
                       strcmpi(vSplahView('get'), 'all')
                        cData = combineRGB(imCoronalR, imCoronalG, imCoronalB, 'Coronal');
                        if ~isempty(cData)
                            imCoronalF  = imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                            if ~isempty(imCoronalF)
                                imCoronalF.CData = cData;
                            end
                        end
                    end

                    if strcmpi(vSplahView('get'), 'sagittal') || ...
                       strcmpi(vSplahView('get'), 'all')
                        cData= combineRGB(imSagittalR, imSagittalG, imSagittalB, 'Sagittal');
                        if ~isempty(cData)
                            imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                            if ~isempty(imSagittalF)
                                imSagittalF.CData = cData;
                            end
                        end
                    end

                    if strcmpi(vSplahView('get'), 'axial') || ...
                       strcmpi(vSplahView('get'), 'all')
                        cData= combineRGB(imAxialR, imAxialG, imAxialB, 'Axial');
                        if ~isempty(cData)
                            imAxialF = imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                            if ~isempty(imAxialF)
                                imAxialF.CData = cData;
                            end
                        end
                    end
                end

                set(fiMainWindowPtr('get'), 'Pointer', 'default');
            end

            dVsplashLayoutX = vSplashLayout('get', 'x');
            dVsplashLayoutY = vSplashLayout('get', 'y');

            ptMontageAxes1 = montageText('get', 'axes1');
            for aa=1:numel(ptMontageAxes1)
                delete(ptMontageAxes1{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'coronal', iCoronal);

            xOffset = imCoronal.XData(2)/dVsplashLayoutX;
            yOffset = imCoronal.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes1{iPointerOffset} = text(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes1{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes1', ptMontageAxes1);

            ptMontageAxes2 = montageText('get', 'axes2');
            for aa=1:numel(ptMontageAxes2)
                delete(ptMontageAxes2{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'sagittal', iSagittal);

            xOffset = imSagittal.XData(2)/dVsplashLayoutX;
            yOffset = imSagittal.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes2{iPointerOffset} = text(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes2{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes2', ptMontageAxes2);

            ptMontageAxes3 = montageText('get', 'axes3');
            for aa=1:numel(ptMontageAxes3)
                delete(ptMontageAxes3{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'axial', size(dicomBuffer('get'), 3)-iAxial+1);

            xOffset = imAxial.XData(2)/dVsplashLayoutX;
            yOffset = imAxial.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes3{iPointerOffset} = text(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ((jj-1)*xOffset)+1 , ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes3{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes3', ptMontageAxes3);

        else
            imM  = mipBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

            imCoronal.CData  = permute(im(iCoronal,:,:), [3 2 1]);
            imSagittal.CData = permute(im(:,iSagittal,:), [3 1 2]) ;
            imAxial.CData    = im(:,:,iAxial);
            imMip.CData      = permute(imM(iMipAngle,:,:), [3 2 1]);

            if isFusion('get') == true

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
                end

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imf = squeeze(fusionBuffer('get', [], rr));

                    if ~isempty(imf)

                        imCoronalF  = imCoronalFPtr ('get', [], rr);
                        imSagittalF = imSagittalFPtr('get', [], rr);
                        imAxialF    = imAxialFPtr   ('get', [], rr);

                        if ~isempty(imCoronalF) && ...
                           ~isempty(imSagittalF) && ...
                           ~isempty(imAxialF)

                            imCoronalF.CData  = permute(imf(iCoronal,:,:) , [3 2 1]);
                            imSagittalF.CData = permute(imf(:,iSagittal,:), [3 1 2]) ;
                            imAxialF.CData    = imf(:,:,iAxial);

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

                                if colormap(imCoronalF.Parent) == aRedColorMap
                                    imCoronalR  = imCoronalF.CData;
                                    imSagittalR = imSagittalF.CData;
                                    imAxialR    = imAxialF.CData;
                                end

                                if colormap(imCoronalF.Parent) == aGreenColorMap
                                    imCoronalG  = imCoronalF.CData;
                                    imSagittalG = imSagittalF.CData;
                                    imAxialG    = imAxialF.CData;
                                end

                                if colormap(imCoronalF.Parent) == aBlueColorMap
                                    imCoronalB  = imCoronalF.CData;
                                    imSagittalB = imSagittalF.CData;
                                    imAxialB    = imAxialF.CData;
                                end
                            end
                        end

                       imMf = mipFusionBuffer('get', [], rr);

                       if ~isempty(imMf)
                            imMipF = imMipFPtr('get', [], rr);
                            if ~isempty(imMipF)

                                imMipF.CData = permute(imMf(iMipAngle,:,:), [3 2 1]);

                                if isCombineMultipleFusion('get') == true

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
                end

                if isCombineMultipleFusion('get') == true

                    cData = combineRGB(imCoronalR, imCoronalG, imCoronalB, 'Coronal');
                    if ~isempty(cData)
                        imCoronalF  = imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        if ~isempty(imCoronalF)
                            imCoronalF.CData = cData;
                        end
                    end

                    cData= combineRGB(imSagittalR, imSagittalG, imSagittalB, 'Sagittal');
                    if ~isempty(cData)
                        imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        if ~isempty(imCoronalF)
                            imSagittalF.CData = cData;
                        end
                    end

                    cData= combineRGB(imAxialR, imAxialG, imAxialB, 'Axial');
                    if ~isempty(cData)
                        imAxialF = imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        if ~isempty(imAxialF)
                            imAxialF.CData = cData;
                        end
                    end

                    cData = combineRGB(imMipR, imMipG, imMipB, 'Mip');
                    if ~isempty(cData)
                        imMipF = imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                        if ~isempty(imMipF)
                            imMipF.CData = cData;
                        end
                    end
                end

                if isPlotContours('get') == true

                   imf = squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                   if ~isempty(imf)

                        imCoronalFc.ZData  = permute(imf(iCoronal,:,:), [3 2 1]);
                        imSagittalFc.ZData = permute(imf(:,iSagittal,:), [3 1 2]);
                        imAxialFc.ZData    = imf(:,:,iAxial);
                        if ~isempty(imMipFc)
                            imMipFc.ZData  = permute(imMf(iMipAngle,:,:), [3 2 1]);
                        end
                    end
                end
            end
if 0
            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            for bb=1:numel(atRoiInput)

                if isvalid(atRoiInput{bb}.Object)

                    atRoiInput{bb}.Object.Visible = 'off';

                    if ~isempty(atRoiInput{bb}.MaxDistances)
                        atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'off';
                        atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'off';
                        atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'off';
                        atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'off';
                    end
                end
            end
end            
        end
        
        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

if 1 % Need to improve speed
%tic
        if ~isempty(atRoiInput) && isVsplash('get') == false

    %        H = findobj('Type', 'images.roi.freehand');
    %        set(H,'visible','off');

            for bb=1:numel(atRoiInput)
               if isvalid(atRoiInput{bb}.Object)
                   if (strcmpi(atRoiInput{bb}.Axe, 'Axes1') && ...
                        iCoronal == atRoiInput{bb}.SliceNb) || ...
                       (strcmpi(atRoiInput{bb}.Axe, 'Axes2')&& ...
                        iSagittal == atRoiInput{bb}.SliceNb)|| ...
                       (strcmpi(atRoiInput{bb}.Axe, 'Axes3') && ...
                        iAxial == atRoiInput{bb}.SliceNb)

                        atRoiInput{bb}.Object.Visible = 'on';
                        if viewFarthestDistances('get') == true
                            if ~isempty(atRoiInput{bb}.MaxDistances)
                                atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'on';
                            end
                        else
                            if ~isempty(atRoiInput{bb}.MaxDistances)
                                atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'off';
                            end
                        end

                    else
                        atRoiInput{bb}.Object.Visible = 'off';

                        if ~isempty(atRoiInput{bb}.MaxDistances)
                            atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'off';
                            atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'off';
                        end
                    end
               end
            end
        end
%toc        
else
    if ~isempty(atRoiInput)
tic        
        % Deactivate all valid ROIs
        
        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Object.Visible, atRoiInput, 'uni', false ), {'on'} );
        if aTagOffset(aTagOffset) 
            for rr=1:numel(aTagOffset)
                atRoiInput{rr}.Object.Visible = 'off';    
                if ~isempty(atRoiInput{rr}.MaxDistances)
                    atRoiInput{rr}.MaxDistances.MaxXY.Line.Visible = 'off';
                    atRoiInput{rr}.MaxDistances.MaxCY.Line.Visible = 'off';
                    atRoiInput{rr}.MaxDistances.MaxXY.Text.Visible = 'off';
                    atRoiInput{rr}.MaxDistances.MaxCY.Text.Visible = 'off'; 
                end
            end
        end
        
        for bb=1:numel(atRoiInput)
           if isvalid(atRoiInput{bb}.Object)
               if (strcmpi(atRoiInput{bb}.Axe, 'Axes1') && ...
                    iCoronal == atRoiInput{bb}.SliceNb) || ...
                   (strcmpi(atRoiInput{bb}.Axe, 'Axes2')&& ...
                    iSagittal == atRoiInput{bb}.SliceNb)|| ...
                   (strcmpi(atRoiInput{bb}.Axe, 'Axes3') && ...
                    iAxial == atRoiInput{bb}.SliceNb)

                    atRoiInput{bb}.Object.Visible = 'on';
                    if viewFarthestDistances('get') == true
                        if ~isempty(atRoiInput{bb}.MaxDistances)
                            atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'on';
                            atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'on';
                        end
                    end
               end
           end
        end
    end
toc    
end
        if crossActivate('get') == true && ...
           isVsplash('get') == false

            iSagittalSize = size(im,2);
            iCoronalSize  = size(im,1);
            iAxialSize    = size(im,3);

            alAxes1Line = axesLine('get', 'axes1');

            alAxes1Line{1}.XData = [iSagittal iSagittal];
            alAxes1Line{1}.YData = [iAxial-0.5 iAxial+0.5];

            alAxes1Line{2}.XData = [iSagittal-0.5 iSagittal+0.5];
            alAxes1Line{2}.YData = [iAxial iAxial];

            alAxes1Line{3}.XData = [0 iSagittal-crossSize('get')];
            alAxes1Line{3}.YData = [iAxial iAxial];

            alAxes1Line{4}.XData = [iSagittal+crossSize('get') iSagittalSize];
            alAxes1Line{4}.YData = [iAxial iAxial];

            alAxes1Line{5}.XData = [iSagittal iSagittal];
            alAxes1Line{5}.YData = [0 iAxial-crossSize('get')];

            alAxes1Line{6}.XData = [iSagittal iSagittal];
            alAxes1Line{6}.YData = [iAxial+crossSize('get') iAxialSize];


            alAxes2Line = axesLine('get', 'axes2');

            alAxes2Line{1}.XData = [iCoronal iCoronal];
            alAxes2Line{1}.YData = [iAxial-0.5 iAxial+0.5];

            alAxes2Line{2}.XData = [iCoronal-0.5 iCoronal+0.5];
            alAxes2Line{2}.YData = [iAxial iAxial];

            alAxes2Line{3}.XData = [0 iCoronal-crossSize('get')];
            alAxes2Line{3}.YData = [iAxial iAxial];

            alAxes2Line{4}.XData = [iCoronal+crossSize('get') iCoronalSize];
            alAxes2Line{4}.YData = [iAxial iAxial];

            alAxes2Line{5}.XData = [iCoronal iCoronal];
            alAxes2Line{5}.YData = [0 iAxial-crossSize('get')];

            alAxes2Line{6}.XData = [iCoronal iCoronal];
            alAxes2Line{6}.YData = [iAxial+crossSize('get') iAxialSize];


            alAxes3Line = axesLine('get', 'axes3');

            alAxes3Line{1}.XData = [iSagittal iSagittal];
            alAxes3Line{1}.YData = [iCoronal-0.5 iCoronal+0.5];

            alAxes3Line{2}.XData = [iSagittal-0.5 iSagittal+0.5];
            alAxes3Line{2}.YData = [iCoronal iCoronal];

            alAxes3Line{3}.XData = [0  iSagittal-crossSize('get')];
            alAxes3Line{3}.YData = [iCoronal iCoronal];

            alAxes3Line{4}.XData = [iSagittal+crossSize('get') iSagittalSize];
            alAxes3Line{4}.YData = [iCoronal iCoronal];

            alAxes3Line{5}.XData = [iSagittal iSagittal];
            alAxes3Line{5}.YData = [0 iCoronal-crossSize('get')];

            alAxes3Line{6}.XData = [iSagittal iSagittal];
            alAxes3Line{6}.YData = [iCoronal+crossSize('get') iCoronalSize];

            alAxesMipLine = axesLine('get', 'axesMip');

            angle = (iMipAngle-1)*11.25; % to rotate 90 counterclockwise

    %            alAxesMipLine{1}.XData = [iSagittal iSagittal];
    %            alAxesMipLine{1}.YData = [iAxial-0.5 iAxial+0.5];
    %            alAxesMipLine{1}.ZData = [];

    %            alAxesMipLine{2}.XData = [iSagittal-0.5 iSagittal+0.5];
    %            alAxesMipLine{2}.YData = [iAxial iAxial];
    %            alAxesMipLine{2}.ZData = [];

    %            alAxesMipLine{3}.XData = [0 iSagittal-crossSize('get')];
    %            alAxesMipLine{3}.YData = [iAxial iAxial];
    %            alAxesMipLine{3}.ZData = [];

    %            alAxesMipLine{4}.XData = [iSagittal+crossSize('get') iCoronalSize];
    %            alAxesMipLine{4}.YData = [iAxial iAxial];
    %            alAxesMipLine{4}.ZData = [];

    %            alAxesMipLine{5}.XData = [iSagittal iSagittal];
    %            alAxesMipLine{5}.YData = [0 iAxial-crossSize('get')];
    %            alAxesMipLine{5}.ZData = [];

    %            alAxesMipLine{6}.XData = [iSagittal iSagittal];
    %            alAxesMipLine{6}.YData = [iAxial+crossSize('get') iAxialSize];
    %            alAxesMipLine{6}.ZData =  [];

            % Compute\Set MIP Line 6 to find the xOffet

       %     xBackData = alAxes2Line{6}.XData;
       %     yBackData = alAxes2Line{6}.YData;
       %     zBackData = alAxes2Line{6}.ZData;

        %    rotate(alAxes2Line{6},[1 0 0], angle);
        %    xData = alAxes2Line{6}.XData;

        %    alAxes2Line{6}.XData = xBackData;
        %    alAxes2Line{6}.YData = yBackData;
        %    alAxes2Line{6}.ZData = zBackData;

    %            set(alAxesMipLine{6}, 'XData', [iSagittal iSagittal]);
    %            rotate(alAxesMipLine{6},[0 -1 0], angle);
    %            xSagOffset = get(alAxesMipLine{6}, 'XData');

    %            set(alAxesMipLine{6}, 'XData', [iCoronal iCoronal]);
    %            rotate(alAxesMipLine{6},[0 -1 0], angle-90);
    %            xCorOffset = get(alAxesMipLine{6}, 'XData');


            lSagLine = line(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                            'XData'  , [iCoronal iCoronal], ...
                            'YData'  , [1 1], ...
                            'ZData'  , [1 1], ...
                            'Color'  , crossColor('get'), ...
                            'Visible', 'off');
            rotate(lSagLine,[0 -1 0], angle-90);
            xSagOffset = get(lSagLine, 'XData');

            lCorLine = line(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), ...
                            'XData'  , [iSagittal iSagittal], ...
                            'YData'  , [1 1], ...
                            'ZData'  , [1 1], ...
                            'Color'  , crossColor('get'), ...
                            'Visible', 'off');
            rotate(lCorLine,[0 -1 0], angle);
            xCorOffset = get(lCorLine, 'XData');

    %            pCor=plot3(axesMipPtr('get'), [iSagittal iSagittal], [1 1], [1 1], 'Visible', 'off');

            delete(lSagLine);
            delete(lCorLine);

            if     angle >= 0   && angle <= 90
                ratio = angle / 90;
                xOffset = (xCorOffset * (1-ratio)) + (xSagOffset * ratio);

            elseif angle >= 91  && angle <= 180
                ratio = (angle-90)/90;
                xOffset = (xCorOffset * ratio) + (xSagOffset * (1-ratio));

           elseif angle >= 181 && angle <= 270
                ratio = (angle-180)/90;
                xOffset = (xCorOffset * (1-ratio)) + (xSagOffset * ratio);

            elseif angle >= 271 && angle <= 360
                ratio = (angle-270)/90;
                xOffset = (xCorOffset * ratio) + (xSagOffset * (1-ratio));
            else
                % Error
            end



    %          xDiff  = diff([xSagOffset(1) iSagittal])

    %        xOffset = xSagOffset
    %         if gca == axes1Ptr('get')
    %             xOffset = xSagOffset;
    %         else
    %             xOffset = xCorOffset;
    %         end

            % Set MIP Line 1-5 with found xOffet

            alAxesMipLine{1}.XData = [xOffset(1) xOffset(2)];
            alAxesMipLine{1}.YData = [iAxial-0.5 iAxial+0.5];
%            alAxesMipLine{1}.ZData = [];

            alAxesMipLine{2}.XData = [xOffset(1)-0.5 xOffset(2)+0.5];
            alAxesMipLine{2}.YData = [iAxial iAxial];
%            alAxesMipLine{2}.ZData = [];

            alAxesMipLine{3}.XData = [0 xOffset(2)-crossSize('get')];
            alAxesMipLine{3}.YData = [iAxial iAxial];
%            alAxesMipLine{3}.ZData = [];

            alAxesMipLine{4}.XData = [xOffset(1)+crossSize('get') iCoronalSize];
            alAxesMipLine{4}.YData = [iAxial iAxial];
%            alAxesMipLine{4}.ZData = [];

            alAxesMipLine{5}.XData = [xOffset(1) xOffset(2)];
            alAxesMipLine{5}.YData = [0 iAxial-crossSize('get')];
%            alAxesMipLine{5}.ZData = [];

            alAxesMipLine{6}.XData = [xOffset(1) xOffset(2)];
            alAxesMipLine{6}.YData = [iAxial+crossSize('get') iAxialSize];
%            alAxesMipLine{6}.ZData = [];

        if multiFrameRecord('get') == false

            if (angle == 0 || angle == 90 || angle == 180 || angle == 270) && ...
               multiFramePlayback('get') == false && ...
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

        if overlayActivate('get') == true

            tAxes1Text = axesText('get', 'axes1');

            clickedPt = get(gca,'CurrentPoint');
            clickedPtX = num2str(round(clickedPt(1,1)));
            clickedPtY = num2str(round(clickedPt(1,2)));

            if gca == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) || ...
               (isVsplash('get') == true && ...
                strcmpi(vSplahView('get'), 'coronal'))

                if strcmp(windowButton('get'), 'down')

                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'coronal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe1Text = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 1)));
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')
                       [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxe1Text = sprintf('C:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 1)));
                    else
                        sAxe1Text = sprintf('\nC:%s/%s\n[X,Y] %s,%s', num2str(sliceNumber('get', 'coronal' )), num2str(size(dicomBuffer('get'), 1)), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                        strcmpi(vSplahView('get'), 'coronal')
                            [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                            sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                            sAxe1Text = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 1)));
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'coronal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxe1Text = sprintf('C:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 1)));
                    else
                        sAxe1Text = sprintf('C:%s/%s', num2str(sliceNumber('get', 'coronal' )), num2str(size(dicomBuffer('get'), 1)));
                    end
                end
                tAxes1Text.String = sAxe1Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'coronal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        tAxes1Text.String = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 1)));
                elseif isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'all')
                    [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                    tAxes1Text.String = ['C:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 1))];
                else
                    tAxes1Text.String = ['C:' num2str(sliceNumber('get', 'coronal' )) '/' num2str(size(dicomBuffer('get'), 1))];
                end
            end
            tAxes1Text.Color = overlayColor('get');

            if isVsplash('get') == false
                tAxes1ViewText = axesText('get', 'axes1View');
                tAxes1ViewText.Color  = overlayColor('get');
            end

            tAxes2Text = axesText('get', 'axes2');

            if gca == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) || ...
               (isVsplash('get') == true && ...
                strcmpi(vSplahView('get'), 'sagittal'))

                if strcmp(windowButton('get'), 'down')
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'sagittal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe2Text = sprintf('\n\n\n%s\n%s\n%s\nS: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 2)));
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                        sAxe2Text = sprintf('S:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 2)));
                    else
                        sAxe2Text = sprintf('\nS:%s/%s\n[X,Y] %s,%s', num2str(sliceNumber('get', 'sagittal' )), num2str(size(dicomBuffer('get'), 2)), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'sagittal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe2Text = sprintf('\n\n\n%s\n%s\n%s\nS: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 2)));
                     elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')
                       [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                       sAxe2Text = sprintf('S:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 2)));
                    else
                        sAxe2Text = sprintf('S:%s/%s', num2str(sliceNumber('get', 'sagittal' )), num2str(size(dicomBuffer('get'), 2)));
                    end
                end
                tAxes2Text.String = sAxe2Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'sagittal')
                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                    sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    tAxes2Text.String = sprintf('\n%s\n%s\n%s\nS: %s/%s', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...
                        sAxialSliceNumber, ...
                        num2str(size(dicomBuffer('get'), 2)));
                 elseif isVsplash('get') == true && ...
                        strcmpi(vSplahView('get'), 'all')
                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                    tAxes2Text.String = ['S:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 2))];
                else
                    tAxes2Text.String = ['S:' num2str(sliceNumber('get', 'sagittal')) '/' num2str(size(dicomBuffer('get'), 2))];
                end
            end
            tAxes2Text.Color  = overlayColor('get');

            if isVsplash('get') == false
                tAxes2ViewText = axesText('get', 'axes2View');
                tAxes2ViewText.Color  = overlayColor('get');
            end

            tQuantification = quantificationTemplate('get');
            atMetaData = dicomMetaData('get');

            bDisplayAxe3 = true;
            mGate = gateIconMenuObject('get');
            if multiFramePlayback('get') == true && ...
               strcmpi(get(mGate, 'State'), 'on')
                bDisplayAxe3 = false;
            end

            if bDisplayAxe3 == true
                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'axial') || ...
                    strcmpi(vSplahView('get'), 'all'))
                    [lFirst, lLast] = computeVsplashLayout(im, 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);
                    sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    sAxe3Text = sprintf('\n\n\n%s\n%s\n%s\nA: %s/%s', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...
                        sAxialSliceNumber, ...
                        num2str(size(dicomBuffer('get'), 3)));
                else
                    sAxialSliceNumber = num2str(size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                    lMin = windowLevel('get', 'min');
                    lMax = windowLevel('get', 'max');

                    switch lower(atMetaData{1}.Modality)
                        case {'pt', 'nm'}

                            sUnit = getSerieUnitValue(dOffset);

                            if strcmpi(sUnit, 'SUV')
                                
                                switch lower(atMetaData{1}.DecayCorrection)
                                    case 'start'
                                        sDecayCorrection = '(SUV is decay-corrected to scan start time)';
                                        
                                    case 'admin'
                                        sDecayCorrection = '(SUV is decay-corrected to administration time)';

                                    case 'none'
                                        sDecayCorrection = '(No decay correction)';
                                        
                                    otherwise
                                    sDecayCorrection = '';
                                end
                                
                                sSUVtype = viewerSUVtype('get');
                                suvValue = double(im(iCoronal,iSagittal,iAxial)) * tQuantification.tSUV.dScale;
                                sAxe3Text = sprintf('\n\n\n\n\n\n\n\n\n%s\n%s\n%s\n%s\n%s\n%s\nMin SUV/%s: %s -- %s Bq/cc\nMax SUV/%s: %s -- %s Bq/cc\nTotal activity: %s MBq -- %s mCi\nCurrent SUV/%s: %s -- %s Bq/cc\nLookup Table SUV/%s: %s - %s\nA: %s/%s', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sRadiopharmaceutical, ...
                                    sSeriesDate,...
                                    sDecayCorrection, ...
                                    sSUVtype, ...
                                    num2str(tQuantification.tSUV.dMin), ...
                                    num2str(tQuantification.tCount.dMin), ...
                                    sSUVtype, ...
                                    num2str(tQuantification.tSUV.dMax), ...
                                    num2str(tQuantification.tCount.dMax), ...
                                    num2str(tQuantification.tSUV.dTot/10000000), ...
                                    num2str(tQuantification.tSUV.dmCi), ...
                                    sSUVtype, ...
                                    num2str(suvValue), ...
                                    num2str(double(im(iCoronal,iSagittal,iAxial))), ...
                                    sSUVtype, ...
                                    num2str(lMin*tQuantification.tSUV.dScale), ...
                                    num2str(lMax*tQuantification.tSUV.dScale), ...
                                    sAxialSliceNumber, ...
                                    num2str(size(dicomBuffer('get'), 3)));
                            else
                                sAxe3Text = sprintf('\n\n\n\n\n\n\n\n%s\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nLookup Table: %s - %s\nA: %s/%s', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sRadiopharmaceutical, ...
                                    sSeriesDate,...
                                    num2str(tQuantification.tCount.dMin), ...
                                    num2str(tQuantification.tCount.dMax), ...
                                    num2str(tQuantification.tCount.dSum), ...
                                    num2str(double(im(iCoronal,iSagittal,iAxial))), ...
                                    num2str(lMin), ...
                                    num2str(lMax), ...
                                    sAxialSliceNumber, ...
                                    num2str(size(dicomBuffer('get'), 3)));
                            end

                        case 'ct'

                            [dWindow, dLevel] = computeWindowMinMax(windowLevel('get', 'max'), windowLevel('get', 'min'));
                            sWindowName = getWindowName(dWindow, dLevel);
                            sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin HU: %s\nMax HU: %s\nCurrent HU: %s\nWindow/Level (%s): %s/%s\nA: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sSeriesDate,...
                                num2str(tQuantification.tHU.dMin), ...
                                num2str(tQuantification.tHU.dMax), ...
                                num2str(double(im(iCoronal,iSagittal,iAxial))), ...
                                sWindowName,...
                                num2str(round(dWindow)), ...
                                num2str(round(dLevel)), ...
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 3)));

                       otherwise
                            sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nLookup Table: %s - %s\nA: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sSeriesDate,...
                                num2str(tQuantification.tCount.dMin), ...
                                num2str(tQuantification.tCount.dMax), ...
                                num2str(tQuantification.tCount.dSum), ...
                                num2str(double(im(iCoronal,iSagittal,iAxial))), ...
                                num2str(lMin), ...
                                num2str(lMax), ...
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 3)));
                    end

       %         sAxe3Text = sprintf('%s\n%s\n%s\nCurrent SUV/W:%s -- %d Bq/cc\nA :%s/%s', sPatientName, sPatientID, sSeriesDescription, num2str(suvValue),im(iCoronal,iSagittal,iAxial),num2str(sliceNumber('get', 'axial')),num2str(size(dicomBuffer('get'), 3)));

                    if gca == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) && strcmp(windowButton('get'), 'down')
                        sAxe3Text = sprintf('\n%s\n[X,Y] %s,%s', sAxe3Text, clickedPtX, clickedPtY);
                    end
                end

                tAxes3Text = axesText('get', 'axes3');
                tAxes3Text.String = sAxe3Text;
                tAxes3Text.Color  = overlayColor('get');

                if isFusion('get') == true

                    sAxes3fText = '';

                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries

                        imf = squeeze(fusionBuffer('get', [], rr));

                        if ~isempty(imf)

                            imCoronalF  = imCoronalFPtr ('get', [], rr);
                            imSagittalF = imSagittalFPtr('get', [], rr);
                            imAxialF    = imAxialFPtr   ('get', [], rr);

                            if ~isempty(imCoronalF) && ...
                               ~isempty(imSagittalF) && ...
                               ~isempty(imAxialF)

                                atFuseMetaData = tInput(rr).atDicomInfo;

                                if isfield(atFuseMetaData{1}, 'SeriesDescription')
                                    sFusedSeriesDescription = atFuseMetaData{1}.SeriesDescription;
                                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'_',' ');
                                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'^',' ');
                                    sFusedSeriesDescription = strtrim(sFusedSeriesDescription);
                                else
                                    sFusedSeriesDescription = '';
                                end

                                if isfield(atFuseMetaData{1}, 'RadiopharmaceuticalInformationSequence')
                                    sFusedRadiopharmaceutical = atFuseMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
                                else
                                    sFusedRadiopharmaceutical = '';
                                end

                                if isfield(atFuseMetaData{1}, 'SeriesDate')

                                    if isempty(atFuseMetaData{1}.SeriesDate)
                                        sFusedSeriesDate = '';
                                    else
                                        sFusedSeriesDate = atFuseMetaData{1}.SeriesDate;
                                        if isempty(atFuseMetaData{1}.SeriesTime)
                                            sFusedSeriesTime = '000000';
                                        else
                                            sFusedSeriesTime = atFuseMetaData{1}.SeriesTime;
                                        end
                                        sFusedSeriesDate = sprintf('%s%s', sFusedSeriesDate, sFusedSeriesTime);
                                    end

                                    if ~isempty(sFusedSeriesDate)
                                        if contains(sFusedSeriesDate,'.')
                                            sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
                                        end
                                        sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
                                    end
                                else
                                    sFusedSeriesDate = '';
                                end

                                sColorMap = getColorMap('name', [], colormap(imAxialF.Parent));

%                                imf = squeeze(fusionBuffer('get', [], rr));
                                dFusedCurrent = double(imf(iCoronal,iSagittal,iAxial));

                                switch lower(atFuseMetaData{1}.Modality)

                                    case {'pt', 'nm'}

                                        sUnit = getSerieUnitValue(rr);

                                        if strcmpi(sUnit, 'SUV')

                                            sSUVtype = viewerSUVtype('get');
                                            suvValue = dFusedCurrent * tInput(rr).tQuant.tSUV.dScale;

                                            sAxes3fText = sprintf('%s\n%s\n%s\n%s\nColormap: %s\nCurrent SUV/%s: %s\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedRadiopharmaceutical, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            sSUVtype, ...
                                                            num2str(suvValue) ...
                                                            );

                                        else
                                            sAxes3fText = sprintf('%s\n%s\n%s\n%s\nColormap: %s\nCurrent: %s\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedRadiopharmaceutical, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            num2str(dFusedCurrent) ...
                                                            );
                                        end

                                    case 'ct'

                                            sAxes3fText = sprintf('%s\n%s\n%s\nColormap: %s\nCurrent HU: %s\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            num2str(dFusedCurrent) ...
                                                            );

                                   otherwise
                                            sAxes3fText = sprintf('%s\n%s\n%s\nColormap: %s\nCurrent: %s\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            num2str(dFusedCurrent) ...
                                                            );

                                end
                            end
                        end
                    end

                else
                    sAxes3fText = '';
                end

                tAxes3fText = axesText('get', 'axes3f');
                tAxes3fText.String = sAxes3fText;
                tAxes3fText.Color  = overlayColor('get');

                if isVsplash('get') == false
                    tAxes3ViewText = axesText('get', 'axes3View');
                    for tt=1:numel(tAxes3ViewText)
                        tAxes3ViewText{tt}.Color  = overlayColor('get');
                    end
                end
            end

            if overlayActivate('get') == true && ...
               isVsplash('get') == false
%               link2DMip('get') == true

                sAxeMipText = sprintf('\n%d/32', iMipAngle);

                tAxesMipText = axesText('get', 'axesMip');
                tAxesMipText.String = sAxeMipText;
                if link2DMip('get') == true
                    tAxesMipText.Color  = overlayColor('get');
                end

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
                if link2DMip('get') == true
                    tAxesMipViewText.Color  = overlayColor('get');
                end

            end

        end

    end

    setColorbarLabel();
    if isFusion('get') == true
        setFusionColorbarLabel();
    end

    refreshImageRotation();

%    drawnow limitrate;

end
