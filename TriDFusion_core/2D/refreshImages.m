function refreshImages(clickedPtX, clickedPtY)
%function refreshImages(clickedPtX, clickedPtY)
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

    if exist('clickedPtX', 'var') && ...
       exist('clickedPtY', 'var')    
        
        bAxeClicked = true;
    else
        bAxeClicked = false;       
    end

    atInputTemplate = inputTemplate('get');

    dSeriesOffset       = get(uiSeriesPtr('get'), 'Value');
    dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
%     if dSeriesOffset > numel(atInputTemplate)
%         return;
%     end

    im = dicomBuffer('get', [], dSeriesOffset);

    tQuantification = quantificationTemplate('get', [], dSeriesOffset);
    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    aBufferSize = size(im);

    if overlayActivate('get') == true

        [sPatientName,sPatientID,sSeriesDescription,sRadiopharmaceutical,sSeriesDate] = overlayPatientInformation('get');
    end

    if size(im, 3) == 1

        imAxeR = [];
        imAxeG = [];
        imAxeB = [];

        imAxe  = imAxePtr ('get', [], dSeriesOffset);

        vBoundAxePtr = visBoundAxePtr('get');
        if ~isempty(vBoundAxePtr)
            delete(vBoundAxePtr);
        end

%             lMin  = windowLevel('get', 'min');
%             lMax = windowLevel('get', 'max');

        im = squeeze(im);

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
        if contourVisibilityRoiPanelValue('get') == true

            atRoiInput = roiTemplate('get', dSeriesOffset);
            
            if ~isempty(atRoiInput)

                for bb=1:numel(atRoiInput)

                    if isvalid(atRoiInput{bb}.Object)

                        atRoiInput{bb}.Object.Visible = 'on';

                        bRoiHasMaxDistances = roiHasMaxDistances(atRoiInput{bb}); 

                        if viewFarthestDistances('get') == true

                            if bRoiHasMaxDistances == true 
                                          
                                atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'on';
                                atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'on';

                            else % Object need to be initialize

                                tMaxDistances = computeRoiFarthestPoint(im, atMetaData, atRoiInput{bb}, true, true);
                                atRoiInput{bb}.MaxDistances = tMaxDistances;

                                roiTemplate('set', dSeriesOffset, atRoiInput);
                            end
                         
                        else
                            if bRoiHasMaxDistances == true

                                atRoiInput{bb}.MaxDistances.MaxXY.Line.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxCY.Line.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxXY.Text.Visible = 'off';
                                atRoiInput{bb}.MaxDistances.MaxCY.Text.Visible = 'off';                                
                            end
                        end
                   end
                end
            end
        end

        if overlayActivate('get') == true

            if bAxeClicked == false

                clickedPt = get(axePtr('get', [], dSeriesOffset), 'CurrentPoint');
    
    %             aBufferSize = size(im);
    
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
            end

            tQuant = quantificationTemplate('get');
            dCurrent = im(clickedPtY, clickedPtX);

            lMin = windowLevel('get', 'min');
            lMax = windowLevel('get', 'max');

            sAxeText = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nLookup Table: %s - %s\n[X,Y] %d,%d', ...
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
                clickedPtX, ...
                clickedPtY);

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

                            atFuseMetaData = atInputTemplate(rr).atDicomInfo;

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
                                    sFusedSeriesDate = sprintf('%s-%s', sFusedSeriesDate, sFusedSeriesTime);
                                end

%                                 if ~isempty(sFusedSeriesDate)
%                                     if contains(sFusedSeriesDate,'.')
%                                         sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
%                                     end
%                                         try
%                                             sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
%                                         catch
%                                             sFusedSeriesDate = ''; 
%                                         end
%                                 end
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
        im = squeeze(im);

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

        imCoronal  = imCoronalPtr ('get', [], dSeriesOffset);
        imSagittal = imSagittalPtr('get', [], dSeriesOffset);
        imAxial    = imAxialPtr   ('get', [], dSeriesOffset);

        if isVsplash('get') == false && bAxeClicked == false
            imMip = imMipPtr('get', [], dSeriesOffset);
        end
          
        imCoronalFc  = imCoronalFcPtr ('get', [], dFusionSeriesOffset);
        imSagittalFc = imSagittalFcPtr('get', [], dFusionSeriesOffset);
        imAxialFc    = imAxialFcPtr   ('get', [], dFusionSeriesOffset);
        
        if isVsplash('get') == false && bAxeClicked == false
            imMipFc = imMipFcPtr('get', [], dFusionSeriesOffset);
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

                imComputed = computeMontage(im(:,:,end:-1:1), 'axial', aBufferSize(3)-sliceNumber('get', 'axial')+1);

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

                                imComputed = computeMontage(imf(:,:,end:-1:1), 'axial', aBufferSize(3)-sliceNumber('get', 'axial')+1);

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
                            imCoronalF  = imCoronalFPtr('get', [], dFusionSeriesOffset);
                            if ~isempty(imCoronalF)
                                imCoronalF.CData = cData;
                            end
                        end
                    end

                    if strcmpi(vSplahView('get'), 'sagittal') || ...
                       strcmpi(vSplahView('get'), 'all')
                        cData= combineRGB(imSagittalR, imSagittalG, imSagittalB, 'Sagittal');
                        if ~isempty(cData)
                            imSagittalF = imSagittalFPtr('get', [], dFusionSeriesOffset);
                            if ~isempty(imSagittalF)
                                imSagittalF.CData = cData;
                            end
                        end
                    end

                    if strcmpi(vSplahView('get'), 'axial') || ...
                       strcmpi(vSplahView('get'), 'all')
                        cData= combineRGB(imAxialR, imAxialG, imAxialB, 'Axial');
                        if ~isempty(cData)
                            imAxialF = imAxialFPtr('get', [], dFusionSeriesOffset);
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
            
%             if is3DEngine('get') == true
% 
%                 xOffset = size(imCoronal.CData,2)/dVsplashLayoutX;
%                 yOffset = size(imCoronal.CData,1)/dVsplashLayoutY;
%             else
                xOffset = imCoronal.XData(2)/dVsplashLayoutX;
                yOffset = imCoronal.YData(2)/dVsplashLayoutY;
%             end

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes1{iPointerOffset} = text(axes1Ptr('get', [], dSeriesOffset), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
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

%             if is3DEngine('get') == true
% 
%                 xOffset = size(imSagittal.CData,2)/dVsplashLayoutX;
%                 yOffset = size(imSagittal.CData,1)/dVsplashLayoutY;
%             else
                xOffset = imSagittal.XData(2)/dVsplashLayoutX;
                yOffset = imSagittal.YData(2)/dVsplashLayoutY;
%             end

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes2{iPointerOffset} = text(axes2Ptr('get', [], dSeriesOffset), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
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

            [lFirst, ~] = computeVsplashLayout(im, 'axial', aBufferSize(3)-iAxial+1);

%             if is3DEngine('get') == true
% 
%                 xOffset = size(imAxial.CData,2)/dVsplashLayoutX;
%                 yOffset = size(imAxial.CData,1)/dVsplashLayoutY;
%             else
                xOffset = imAxial.XData(2)/dVsplashLayoutX;
                yOffset = imAxial.YData(2)/dVsplashLayoutY;
%             end

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes3{iPointerOffset} = text(axes3Ptr('get', [], dSeriesOffset), ((jj-1)*xOffset)+1 , ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes3{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes3', ptMontageAxes3);

        else


%               pAxe = gca(fiMainWindowPtr('get'));
             pAxe = getAxeFromMousePosition(dSeriesOffset);

            % clickedPt = get(gca,'CurrentPoint');
            % clickedPtX = num2str(round(clickedPt(1,1)));
            % clickedPtY = num2str(round(clickedPt(1,2)));

               if pAxe ~= axes1Ptr('get', [], dSeriesOffset) || bAxeClicked == false  
         %       imCoronal.CData  = permute(im(iCoronal,:,:), [3 2 1]);
                imCoronal.CData  = reshape(im(iCoronal,:,:), aBufferSize(2), aBufferSize(3))';     
               end

                
                 
%             end
            
             if pAxe ~= axes2Ptr('get', [], dSeriesOffset) || bAxeClicked == false             
                % imSagittal.CData = permute(im(:,iSagittal,:), [3 1 2]) ;
                imSagittal.CData  = reshape(im(:,iSagittal,:), aBufferSize(1), aBufferSize(3))';     
             end

             if pAxe ~= axes3Ptr('get', [], dSeriesOffset) || bAxeClicked == false           
                imAxial.CData  = im(:,:,iAxial);
             end
            
             if bAxeClicked == false || isCombineMultipleFusion('get') == true
            
                 imM = mipBuffer('get', [], dSeriesOffset);
                
                 % imMip.CData = permute(imM(iMipAngle,:,:), [3 2 1]);
                 imMip.CData = reshape(imM(iMipAngle,:,:), aBufferSize(2), aBufferSize(3))';     
             end

             if isFusion('get') == true

                % if isCombineMultipleFusion('get') == true
                % 
                %     if invertColor('get')
                %         aRedColorMap   = flipud(getRedColorMap());
                %         aGreenColorMap = flipud(getGreenColorMap());
                %         aBlueColorMap  = flipud(getBlueColorMap());
                %     else
                %         aRedColorMap   = getRedColorMap();
                %         aGreenColorMap = getGreenColorMap();
                %         aBlueColorMap  = getBlueColorMap();
                %     end
                % end

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imf = squeeze(fusionBuffer('get', [], rr));
                    aFusionBufferSize = size(imf);

                    if ~isempty(imf)

                        imCoronalF  = imCoronalFPtr ('get', [], rr);
                        imSagittalF = imSagittalFPtr('get', [], rr);
                        imAxialF    = imAxialFPtr   ('get', [], rr);

                        if ~isempty(imCoronalF) && ...
                           ~isempty(imSagittalF) && ...
                           ~isempty(imAxialF)
                            
                            if aFusionBufferSize(1) > iCoronal

                                if pAxe ~= axes1Ptr('get', [], dSeriesOffset) || bAxeClicked == false || isCombineMultipleFusion('get') == true          
                                    % imCoronalF.CData  = permute(imf(iCoronal,:,:) , [3 2 1]);
                                    imCoronalF.CData  = reshape(imf(iCoronal,:,:), aFusionBufferSize(2), aFusionBufferSize(3))';     
                                end
                            end

                            if aFusionBufferSize(2) > iSagittal                         

                                if pAxe ~= axes2Ptr('get', [], dSeriesOffset) || bAxeClicked == false || isCombineMultipleFusion('get') == true            
                                    % imSagittalF.CData = permute(imf(:,iSagittal,:), [3 1 2]) ;
                                    imSagittalF.CData = reshape(imf(:,iSagittal,:), aFusionBufferSize(1), aFusionBufferSize(3))';     
                                end
                            end

                            if aFusionBufferSize(3) > iAxial                         
                                if pAxe ~= axes3Ptr('get', [], dSeriesOffset) || bAxeClicked == false || isCombineMultipleFusion('get') == true            
                                    imAxialF.CData = imf(:,:,iAxial);
                                end
                            end

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

                        % if bAxeClicked == false
    
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
                        % end
                    end
                end

                if isCombineMultipleFusion('get') == true

                    cData = combineRGB(imCoronalR, imCoronalG, imCoronalB, 'Coronal');
                    if ~isempty(cData)
                        imCoronalF  = imCoronalFPtr('get', [], dFusionSeriesOffset);
                        if ~isempty(imCoronalF)
                            imCoronalF.CData = cData;
                        end
                    end

                    cData= combineRGB(imSagittalR, imSagittalG, imSagittalB, 'Sagittal');
                    if ~isempty(cData)
                        imSagittalF = imSagittalFPtr('get', [], dFusionSeriesOffset);
                        if ~isempty(imCoronalF)
                            imSagittalF.CData = cData;
                        end
                    end

                    cData= combineRGB(imAxialR, imAxialG, imAxialB, 'Axial');
                    if ~isempty(cData)
                        imAxialF = imAxialFPtr('get', [], dFusionSeriesOffset);
                        if ~isempty(imAxialF)
                            imAxialF.CData = cData;
                        end
                    end

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
                       
                        aFusionBufferSize = size(imf);

                        sUnitDisplay = getSerieUnitValue(dFusionSeriesOffset);
                        if strcmpi(sUnitDisplay, 'SUV')
                            tQuantification = quantificationTemplate('get', [], dFusionSeriesOffset);
                            if atInputTemplate(dFusionSeriesOffset).bDoseKernel == false
                                if ~isempty(tQuantification)
                                    imf = imf*tQuantification.tSUV.dScale;
                                    % imMf = imMf*tQuantification.tSUV.dScale;
                                end
                            end
                        end
                       
                        if pAxe ~= axes1Ptr('get', [], dSeriesOffset) || bAxeClicked == false             
%                         if pAxe ~= axes1Ptr('get', [], dSeriesOffset)         
                            % imCoronalFc.ZData  = permute(imf(iCoronal,:,:), [3 2 1]);
                            imCoronalFc.ZData  = reshape(imf(iCoronal,:,:), aFusionBufferSize(2), aFusionBufferSize(3))';     
                       end

%                         if pAxe ~= axes2Ptr('get', [], dSeriesOffset)         
                        if pAxe ~= axes2Ptr('get', [], dSeriesOffset) || bAxeClicked == false             
                            % imSagittalFc.ZData = permute(imf(:,iSagittal,:), [3 1 2]);
                            imSagittalFc.ZData = reshape(imf(:,iSagittal,:), aFusionBufferSize(1), aFusionBufferSize(3))';     
                        end
%                         end
                        if pAxe ~= axes3Ptr('get', [], dSeriesOffset) || bAxeClicked == false             

%                         if pAxe ~= axes3Ptr('get', [], dSeriesOffset)         
                            imAxialFc.ZData = imf(:,:,iAxial);
%                         end
                        end

                        if bAxeClicked == false
    
                            if ~isempty(imMipFc)
                                % imMipFc.ZData  = permute(imMf(iMipAngle,:,:), [3 2 1]);
                                imMipFc.ZData  = reshape(imMf(iMipAngle,:,:), aFusionBufferSize(2), aFusionBufferSize(3))';     
                            end
                        end
                    end
                end
            end
           
        end

        % Contours

        if contourVisibilityRoiPanelValue('get') == true
             
            atRoiInput = roiTemplate('get', dSeriesOffset);
            
            if ~isempty(atRoiInput) && isVsplash('get') == false
                
                dNumRoiInputs = numel(atRoiInput);
                bViewFarthest = viewFarthestDistances('get');
                
                % Precompute axis and slice conditions 

                axesConditions = {'Axes1', 'Axes2', 'Axes3'};

                for bb = 1:dNumRoiInputs
                    % try
                    currentRoi = atRoiInput{bb};
                    
                    % if isvalid(currentRoi.Object)

                        % Check matching axis and slice condition
                        isCoronal  = strcmpi(currentRoi.Axe, axesConditions{1}) && iCoronal  == currentRoi.SliceNb;
                        isSagittal = strcmpi(currentRoi.Axe, axesConditions{2}) && iSagittal == currentRoi.SliceNb;
                        isAxial    = strcmpi(currentRoi.Axe, axesConditions{3}) && iAxial    == currentRoi.SliceNb;                         
        
                        % If the ROI matches one of the axis/slice conditions, make it visible

                        if isCoronal || isSagittal || isAxial

                            currentRoi.Object.Visible = 'on';

                            if bViewFarthest
                            
                                if roiHasMaxDistances(currentRoi) == true
                                                  
                                    currentRoi.MaxDistances.MaxXY.Line.Visible = 'on';
                                    currentRoi.MaxDistances.MaxCY.Line.Visible = 'on';
                                    currentRoi.MaxDistances.MaxXY.Text.Visible = 'on';
                                    currentRoi.MaxDistances.MaxCY.Text.Visible = 'on';

                                else %Object need to be initialize

                                    tMaxDistances = computeRoiFarthestPoint(im, atMetaData, currentRoi, true, true);
                                    atRoiInput{bb}.MaxDistances = tMaxDistances;

                                    roiTemplate('set', dSeriesOffset, atRoiInput);
                                end
                            end
                        else

                            currentRoi.Object.Visible = 'off';
    
                            % if ~isempty(currentDistances) && bViewFarthest
                            if bViewFarthest
    
                                if roiHasMaxDistances(currentRoi) == true
                                                  
                                    currentRoi.MaxDistances.MaxXY.Line.Visible = 'off';
                                    currentRoi.MaxDistances.MaxCY.Line.Visible = 'off';
                                    currentRoi.MaxDistances.MaxXY.Text.Visible = 'off';
                                    currentRoi.MaxDistances.MaxCY.Text.Visible = 'off';

                                end
                            end                            
                        end
                    % catch
                    % end
                    % end
                end
            end
        end

        if crossActivate('get') == true && isVsplash('get') == false
           
            iSagittalSize = aBufferSize(2);
            iCoronalSize  = aBufferSize(1);
            iAxialSize    = aBufferSize(3);

            iCrossSize = crossSize('get');

            alAxes1Line = axesLine('get', 'axes1');

            alAxes1Line{1}.XData = [iSagittal iSagittal];
            alAxes1Line{1}.YData = [iAxial-0.5 iAxial+0.5];

            alAxes1Line{2}.XData = [iSagittal-0.5 iSagittal+0.5];
            alAxes1Line{2}.YData = [iAxial iAxial];

            alAxes1Line{3}.XData = [0 iSagittal-iCrossSize];
            alAxes1Line{3}.YData = [iAxial iAxial];

            alAxes1Line{4}.XData = [iSagittal+iCrossSize iSagittalSize];
            alAxes1Line{4}.YData = [iAxial iAxial];

            alAxes1Line{5}.XData = [iSagittal iSagittal];
            alAxes1Line{5}.YData = [0 iAxial-iCrossSize];

            alAxes1Line{6}.XData = [iSagittal iSagittal];
            alAxes1Line{6}.YData = [iAxial+iCrossSize iAxialSize];


            alAxes2Line = axesLine('get', 'axes2');

            alAxes2Line{1}.XData = [iCoronal iCoronal];
            alAxes2Line{1}.YData = [iAxial-0.5 iAxial+0.5];

            alAxes2Line{2}.XData = [iCoronal-0.5 iCoronal+0.5];
            alAxes2Line{2}.YData = [iAxial iAxial];

            alAxes2Line{3}.XData = [0 iCoronal-iCrossSize];
            alAxes2Line{3}.YData = [iAxial iAxial];

            alAxes2Line{4}.XData = [iCoronal+iCrossSize iCoronalSize];
            alAxes2Line{4}.YData = [iAxial iAxial];

            alAxes2Line{5}.XData = [iCoronal iCoronal];
            alAxes2Line{5}.YData = [0 iAxial-iCrossSize];

            alAxes2Line{6}.XData = [iCoronal iCoronal];
            alAxes2Line{6}.YData = [iAxial+iCrossSize iAxialSize];


            alAxes3Line = axesLine('get', 'axes3');

            alAxes3Line{1}.XData = [iSagittal iSagittal];
            alAxes3Line{1}.YData = [iCoronal-0.5 iCoronal+0.5];

            alAxes3Line{2}.XData = [iSagittal-0.5 iSagittal+0.5];
            alAxes3Line{2}.YData = [iCoronal iCoronal];

            alAxes3Line{3}.XData = [0  iSagittal-iCrossSize];
            alAxes3Line{3}.YData = [iCoronal iCoronal];

            alAxes3Line{4}.XData = [iSagittal+iCrossSize iSagittalSize];
            alAxes3Line{4}.YData = [iCoronal iCoronal];

            alAxes3Line{5}.XData = [iSagittal iSagittal];
            alAxes3Line{5}.YData = [0 iCoronal-iCrossSize];

            alAxes3Line{6}.XData = [iSagittal iSagittal];
            alAxes3Line{6}.YData = [iCoronal+iCrossSize iCoronalSize];

            alAxesMipLine = axesLine('get', 'axesMip');
            
            angle = (iMipAngle - 1) * 11.25; % to rotate 90 counterclockwise

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


            % Set MIP Line 1-5 with found xOffset
            
            alAxesMipLine{1}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{1}.YData = [iAxial - 0.5, iAxial + 0.5];
            
            alAxesMipLine{2}.XData = [xOffset(1) - 0.5, xOffset(1) + 0.5];
            alAxesMipLine{2}.YData = [iAxial, iAxial];
            
            alAxesMipLine{3}.XData = [0, xOffset(1) - iCrossSize];
            alAxesMipLine{3}.YData = [iAxial, iAxial];
            
            alAxesMipLine{4}.XData = [xOffset(1) + iCrossSize, iSagittalSize];
            alAxesMipLine{4}.YData = [iAxial, iAxial];
            
            alAxesMipLine{5}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{5}.YData = [0, iAxial - iCrossSize];
            
            alAxesMipLine{6}.XData = [xOffset(1), xOffset(1)];
            alAxesMipLine{6}.YData = [iAxial + iCrossSize, iAxialSize];      

        end

        if overlayActivate('get') == true

            tAxes1Text = axesText('get', 'axes1');

            pAxe = gca(fiMainWindowPtr('get'));
      
            if bAxeClicked == false

                clickedPt = pAxe.CurrentPoint;
    
                clickedPtX = round(clickedPt(1,1));
                clickedPtY = round(clickedPt(1,2));              
            end

            % clickedPt = get(gca,'CurrentPoint');
            % clickedPtX = num2str(round(clickedPt(1,1)));
            % clickedPtY = num2str(round(clickedPt(1,2)));

            if pAxe == axes1Ptr('get', [], dSeriesOffset) || ...
               (isVsplash('get') == true && strcmpi(vSplahView('get'), 'coronal'))
                
                if strcmpi(windowButton('get'), 'down')

                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'coronal')

                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                        sAxe1Text = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            aBufferSize(1));

                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')

                       [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxe1Text = sprintf('C:%d-%d/%d', lFirst, lLast, aBufferSize(1));
                    else
                        sAxe1Text = sprintf('\nC:%d/%d\n[X,Y] %d,%d', sliceNumber('get', 'coronal'), aBufferSize(1), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'coronal')

                            [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                            % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                            sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                            sAxe1Text = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%d', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sAxialSliceNumber, ...
                                aBufferSize(1));

                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')

                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        % sAxe1Text = sprintf('C:%s-%s/%d', num2str(lFirst), num2str(lLast), aBufferSize(1));
                        sAxe1Text = sprintf('C:%d-%d/%d', lFirst, lLast, aBufferSize(1));
                    else
                        sAxe1Text = sprintf('C:%d/%d', sliceNumber('get', 'coronal'), aBufferSize(1));
                    end
                end

                tAxes1Text.String = sAxe1Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'coronal')

                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                        tAxes1Text.String = sprintf('\n\n\n%s\n%s\n%s\nC: %s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            aBufferSize(1));

                elseif isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'all')

                    [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                    % tAxes1Text.String = ['C:' num2str(lFirst) '-' num2str(lLast) '/' num2str(aBufferSize(1))];
                    tAxes1Text.String = sprintf('C:%d-%d/%d', lFirst, lLast, aBufferSize(1));
                else
                    % tAxes1Text.String = ['C:' num2str(sliceNumber('get', 'coronal' )) '/' num2str(aBufferSize(1))];
                    tAxes1Text.String = sprintf('C:%d/%d', sliceNumber('get', 'coronal' ), aBufferSize(1));
                end
            end
            tAxes1Text.Color = overlayColor('get');

            if isVsplash('get') == false
                tAxes1ViewText = axesText('get', 'axes1View');
                tAxes1ViewText.Color  = overlayColor('get');
            end

            tAxes2Text = axesText('get', 'axes2');

            if pAxe == axes2Ptr('get', [], dSeriesOffset) || ...
               (isVsplash('get') == true && strcmpi(vSplahView('get'), 'sagittal'))
                
                if strcmp(windowButton('get'), 'down')
                    if isVsplash('get') == true && strcmpi(vSplahView('get'), 'sagittal')
                       
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
%                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                        sAxe2Text = sprintf('\n\n\n%s\n%s\n%s\nS: %s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                            aBufferSize(2));

                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')

                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                        sAxe2Text = sprintf('S:%d-%d/%d', lFirst, lLast, aBufferSize(2));
                    else
                        sAxe2Text = sprintf('\nS:%d/%d\n[X,Y] %d,%d', sliceNumber('get', 'sagittal' ), aBufferSize(2), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'sagittal')

                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                        % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                        sAxe2Text = sprintf('\n\n\n%s\n%s\n%s\nS: %s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sAxialSliceNumber, ...
                             aBufferSize(2));

                     elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')

                       [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                       sAxe2Text = sprintf('S:%d-%d/%d', lFirst, lLast, aBufferSize(2));
                    else
                        sAxe2Text = sprintf('S:%d/%d', sliceNumber('get', 'sagittal'), aBufferSize(2));
                    end
                end
                tAxes2Text.String = sAxe2Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'sagittal')

                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                    % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                    tAxes2Text.String = sprintf('\n%s\n%s\n%s\nS: %s/%d', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...
                        sAxialSliceNumber, ...
                        aBufferSize(2));

                 elseif isVsplash('get') == true && ...
                        strcmpi(vSplahView('get'), 'all')

                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                    % tAxes2Text.String = ['S:' num2str(lFirst) '-' num2str(lLast) '/' num2str(aBufferSize(2))];
                    tAxes2Text.String = sprintf('S:%d-%d/%d', lFirst, lLast, aBufferSize(2));
                else
                    % tAxes2Text.String = ['S:' num2str(sliceNumber('get', 'sagittal')) '/' num2str(aBufferSize(2))];
                    tAxes2Text.String = sprintf('S:%d/%d', sliceNumber('get', 'sagittal'), aBufferSize(2));
                end
            end
            tAxes2Text.Color  = overlayColor('get');

            if isVsplash('get') == false
                tAxes2ViewText = axesText('get', 'axes2View');
                tAxes2ViewText.Color  = overlayColor('get');
            end

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

                    [lFirst, lLast] = computeVsplashLayout(im, 'axial', aBufferSize(3)-sliceNumber('get', 'axial')+1);
                    % sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    sAxialSliceNumber = sprintf('%d-%d', lFirst, lLast);
                    sAxe3Text = sprintf('\n\n\n%s\n%s\n%s\nA: %s/%d', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...
                        sAxialSliceNumber, ...
                        aBufferSize(3));
                else
                    dAxialSliceNumber = aBufferSize(3)-sliceNumber('get', 'axial')+1;

                    lMin = windowLevel('get', 'min');
                    lMax = windowLevel('get', 'max');

                    if isfield(atMetaData{1}, 'DoseUnits')

                        if ~isempty(atMetaData{1}.DoseUnits)
                            
                            sDoseUnits = char(atMetaData{1}.DoseUnits);
                        else
                            sDoseUnits = 'dose';
                        end
                    else
                        sDoseUnits = 'dose';
                    end
                    
                    if atInputTemplate(dSeriesOffset).bDoseKernel == true
                        sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin (%s): %2.f\nMax (%s): %.2f\nTotal (%s): %.2f\nCurrent (%s): %.2f\nLookup Table: %.2f - %.2f\nA: %d/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sSeriesDate,...
                            sDoseUnits, ...
                            tQuantification.tCount.dMin, ...
                            sDoseUnits, ...
                            tQuantification.tCount.dMax, ...
                            sDoseUnits, ...
                            tQuantification.tCount.dSum, ...
                            sDoseUnits, ...
                            im(iCoronal,iSagittal,iAxial), ...
                            lMin, ...
                            lMax, ...
                            dAxialSliceNumber, ...
                            aBufferSize(3));                                              
                    else
                        
                        switch lower(atMetaData{1}.Modality)
    
                            case {'pt', 'nm'}
    
                                sUnit = getSerieUnitValue(dSeriesOffset);

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

                                    if isempty(sRadiopharmaceutical)
                                        sAxe3Text = sprintf('\n\n\n\n\n\n\n\n%s\n%s\n%s\n%s\n%s\nMin SUV/%s: %.2f -- %.2f Bq/cc\nMax SUV/%s: %.2f -- %.2f Bq/cc\nTotal activity: %.2f MBq -- %.2f mCi\nCurrent SUV/%s: %.2f -- %.2f Bq/cc\nLookup Table SUV/%s: %.2f - %.2f\nA: %d/%d', ...
                                            sPatientName, ...
                                            sPatientID, ...
                                            sSeriesDescription, ...
                                            sSeriesDate,...
                                            sDecayCorrection, ...
                                            sSUVtype, ...
                                            tQuantification.tSUV.dMin, ...
                                            tQuantification.tCount.dMin, ...
                                            sSUVtype, ...
                                            tQuantification.tSUV.dMax, ...
                                            tQuantification.tCount.dMax, ...
                                            tQuantification.tSUV.dTot/10000000, ...
                                            tQuantification.tSUV.dmCi, ...
                                            sSUVtype, ...
                                            suvValue, ...
                                            im(iCoronal,iSagittal,iAxial), ...
                                            sSUVtype, ...
                                            lMin*tQuantification.tSUV.dScale, ...
                                            lMax*tQuantification.tSUV.dScale, ...
                                            dAxialSliceNumber, ...
                                            aBufferSize(3));                                        
                                    else  

                                        sAxe3Text = sprintf('\n\n\n\n\n\n\n\n\n%s\n%s\n%s\n%s\n%s\n%s\nMin SUV/%s: %.2f -- %.2f Bq/cc\nMax SUV/%s: %.2f -- %.2f Bq/cc\nTotal activity: %.2f MBq -- %.2f mCi\nCurrent SUV/%s: %.2f -- %.2f Bq/cc\nLookup Table SUV/%s: %.2f - %.2f\nA: %d/%d', ...
                                            sPatientName, ...
                                            sPatientID, ...
                                            sSeriesDescription, ...
                                            sRadiopharmaceutical, ...
                                            sSeriesDate,...
                                            sDecayCorrection, ...
                                            sSUVtype, ...
                                            tQuantification.tSUV.dMin, ...
                                            tQuantification.tCount.dMin, ...
                                            sSUVtype, ...
                                            tQuantification.tSUV.dMax, ...
                                            tQuantification.tCount.dMax, ...
                                            tQuantification.tSUV.dTot/10000000, ...
                                            tQuantification.tSUV.dmCi, ...
                                            sSUVtype, ...
                                            suvValue, ...
                                            im(iCoronal,iSagittal,iAxial), ...
                                            sSUVtype, ...
                                            lMin*tQuantification.tSUV.dScale, ...
                                            lMax*tQuantification.tSUV.dScale, ...
                                            dAxialSliceNumber, ...
                                            aBufferSize(3));

                                    end

                                else
                                    if isempty(sRadiopharmaceutical)

                                        sAxe3Text = sprintf('\n\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %.2f\nMax: %.2f\nTotal: %.2f\nCurrent: %.2f\nLookup Table: %.2f - %.2f\nA: %d/%d', ...
                                            sPatientName, ...
                                            sPatientID, ...
                                            sSeriesDescription, ...
                                            sSeriesDate,...
                                            tQuantification.tCount.dMin, ...
                                            tQuantification.tCount.dMax, ...
                                            tQuantification.tCount.dSum, ...
                                            im(iCoronal,iSagittal,iAxial), ...
                                            lMin, ...
                                            lMax, ...
                                            dAxialSliceNumber, ...
                                            aBufferSize(3));                                        
                                    else
                                        sAxe3Text = sprintf('\n\n\n\n\n\n\n\n%s\n%s\n%s\n%s\n%s\nMin: %.2f\nMax: %.2f\nTotal: %.2f\nCurrent: %.2f\nLookup Table: %.2f - %.2f\nA: %d/%d', ...
                                            sPatientName, ...
                                            sPatientID, ...
                                            sSeriesDescription, ...
                                            sRadiopharmaceutical, ...
                                            sSeriesDate,...
                                            tQuantification.tCount.dMin, ...
                                            tQuantification.tCount.dMax, ...
                                            tQuantification.tCount.dSum, ...
                                            im(iCoronal,iSagittal,iAxial), ...
                                            lMin, ...
                                            lMax, ...
                                            dAxialSliceNumber, ...
                                            aBufferSize(3));
                                    end
                                end
    
                            case 'ct'
    
                                [dWindow, dLevel] = computeWindowMinMax(windowLevel('get', 'max'), windowLevel('get', 'min'));
                                sWindowName = getWindowName(dWindow, dLevel);
                                sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin HU: %d\nMax HU: %d\nCurrent HU: %d\nWindow/Level (%s): %.2f/%.2f\nA: %d/%d', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sSeriesDate,...
                                    tQuantification.tHU.dMin, ...
                                    tQuantification.tHU.dMax, ...
                                    im(iCoronal,iSagittal,iAxial), ...
                                    sWindowName,...
                                    dWindow, ...
                                    dLevel, ...
                                    dAxialSliceNumber, ...
                                    aBufferSize(3));



    
                           otherwise
                                sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %.2f\nMax: %.2f\nTotal: %.2f\nCurrent: %.2f\nLookup Table: %.2f - %.2f\nA: %d/%d', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sSeriesDate,...
                                    tQuantification.tCount.dMin, ...
                                    tQuantification.tCount.dMax, ...
                                    tQuantification.tCount.dSum, ...
                                    im(iCoronal,iSagittal,iAxial), ...
                                    lMin, ...
                                    lMax, ...
                                    dAxialSliceNumber, ...
                                    aBufferSize(3));
                        end
                    end
       %         sAxe3Text = sprintf('%s\n%s\n%s\nCurrent SUV/W:%s -- %d Bq/cc\nA :%s/%s', sPatientName, sPatientID, sSeriesDescription, num2str(suvValue),im(iCoronal,iSagittal,iAxial),num2str(sliceNumber('get', 'axial')),num2str(size(dicomBuffer('get'), 3)));

                    if pAxe == axes3Ptr('get', [], dSeriesOffset) && strcmp(windowButton('get'), 'down')
                        sAxe3Text = sprintf('\n%s\n[X,Y] %d,%d', sAxe3Text, clickedPtX, clickedPtY);
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
                        aFusionBufferSize = size(imf);

                        if ~isempty(imf)

                            imCoronalF  = imCoronalFPtr ('get', [], rr);
                            imSagittalF = imSagittalFPtr('get', [], rr);
                            imAxialF    = imAxialFPtr   ('get', [], rr);

                            if ~isempty(imCoronalF)  && ...
                               ~isempty(imSagittalF) && ...
                               ~isempty(imAxialF)

                                atFuseMetaData = atInputTemplate(rr).atDicomInfo;

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
                                        sFusedSeriesDate = sprintf('%s-%s', sFusedSeriesDate, sFusedSeriesTime);
                                    end

%                                      if ~isempty(sFusedSeriesDate)
%                                         if contains(sFusedSeriesDate,'.')
%                                             sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
%                                         end
%                                         try
%                                             
% %                                             sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
%                                             sFusedSeriesDate = datetime([str2double(sFusedSeriesDate(1:4)), ...
%                                                                          str2double(sFusedSeriesDate(5:6)), ...
%                                                                          str2double(sFusedSeriesDate(7:8)), ...
%                                                                          str2double(sFusedSeriesDate(9:10)), ...
%                                                                          str2double(sFusedSeriesDate(11:12)), ...
%                                                                          str2double(sFusedSeriesDate(13:14))]);
%                                             
%                                         catch
%                                             sFusedSeriesDate = ''; 
%                                         end
%                                     end
                                else
                                    sFusedSeriesDate = '';
                                end

                                sColorMap = getColorMap('name', [], colormap(imAxialF.Parent));

%                                imf = squeeze(fusionBuffer('get', [], rr));
                                if aFusionBufferSize(1) > iCoronal  && ...
                                   aFusionBufferSize(2) > iSagittal && ...                        
                                   aFusionBufferSize(3) > iAxial                         
                                    dFusedCurrent = imf(iCoronal,iSagittal,iAxial);
                                else
                                    dFusedCurrent = [];
                                end


                                switch lower(atFuseMetaData{1}.Modality)

                                    case {'pt', 'nm'}

                                        sUnit = getSerieUnitValue(rr);

                                        if strcmpi(sUnit, 'SUV') 

                                            sSUVtype = viewerSUVtype('get');
                                            suvValue = dFusedCurrent * atInputTemplate(rr).tQuant.tSUV.dScale;

                                            sAxes3fText = sprintf('%s\n%s\n%s\n%s\nColormap: %s\nCurrent SUV/%s: %.2f\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedRadiopharmaceutical, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            sSUVtype, ...
                                                            suvValue ...
                                                            );

                                        else
                                            sAxes3fText = sprintf('%s\n%s\n%s\n%s\nColormap: %s\nCurrent: %.2f\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedRadiopharmaceutical, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            dFusedCurrent ...
                                                            );
                                        end

                                    case 'ct'

                                            sAxes3fText = sprintf('%s\n%s\n%s\nColormap: %s\nCurrent HU: %.2f\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            dFusedCurrent ...
                                                            );

                                   otherwise
                                            sAxes3fText = sprintf('%s\n%s\n%s\nColormap: %s\nCurrent: %.2f\n', ...
                                                            sAxes3fText, ...
                                                            sFusedSeriesDescription, ...
                                                            sFusedSeriesDate, ...
                                                            sColorMap, ...
                                                            dFusedCurrent ...
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
                % if link2DMip('get') == true
                %     tAxesMipText.Color  = overlayColor('get');
                % end

                if  any(get(uiMipWindowPtr('get'), 'BackgroundColor'))
                    tAxesMipText.Color = [0 0 0];
                else
                    tAxesMipText.Color = [1 1 1];
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
                % if link2DMip('get') == true
                %     tAxesMipViewText.Color  = overlayColor('get');
                % end
                if  any(get(uiMipWindowPtr('get'), 'BackgroundColor'))
                    tAxesMipViewText.Color = [0 0 0];
                else
                    tAxesMipViewText.Color = [1 1 1];
                end
            end

        end

    end

%     setColorbarLabel();
% 
%     if isFusion('get') == true
%         setFusionColorbarLabel();
%     end

    refreshImageRotation();

     % if viewerUIFigure('get') == true
     %       drawnow limitrate;
     % end

    % plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), im, iMipAngle);
     % drawnow nocallbacks;
    drawnow limitrate nocallbacks;
end
