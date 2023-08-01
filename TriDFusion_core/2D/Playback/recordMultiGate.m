function recordMultiGate(mRecord, sPath, sFileName, sExtention)
%function oneFrame(sDirection)
%Record 2D DICOM 4D Images.
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

    atInputTemplate = inputTemplate('get');
    dSeriesOffset   = get(uiSeriesPtr('get'), 'Value');

    aCurrentBuffer = dicomBuffer('get', [], dSeriesOffset);
    if size(aCurrentBuffer, 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        multiFrameRecord('set', false);
        mRecord.State = 'off';
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return;
    end

    if dSeriesOffset > numel(atInputTemplate) || ...
       numel(atInputTemplate) < 2 % Need a least 2 series
        progressBar(1, 'Error: Require at least two 3D Volume!');
        multiFrameRecord('set', false);
        mRecord.State = 'off';
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return;
    end

    if ~isfield(atInputTemplate(dSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        progressBar(1, 'Error: Require a 4D series!');
        multiFrameRecord('set', false);
        mRecord.State = 'off';
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return
    end

    lMinBak = windowLevel('get', 'min');
    lMaxBak = windowLevel('get', 'max');

    set(uiSeriesPtr('get'), 'Enable', 'off');

    switch gca
        case axes1Ptr('get', [], dSeriesOffset)
            iLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);
            iCurrentSlice = sliceNumber('get', 'coronal');
             aAxe = axes1Ptr('get', [], dSeriesOffset);

        case axes2Ptr('get', [], dSeriesOffset)
            iLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 2);
            iCurrentSlice = sliceNumber('get', 'sagittal');
            aAxe = axes2Ptr('get', [], dSeriesOffset);

        case axes3Ptr('get', [], dSeriesOffset)
            iLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);
            iCurrentSlice = sliceNumber('get', 'axial');
            aAxe = axes3Ptr('get', [], dSeriesOffset);

        case axesMipPtr('get', [], dSeriesOffset)
            iLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);
            iCurrentSlice = sliceNumber('get', 'coronal');
            aAxe = axesMipPtr('get', [], dSeriesOffset);

        otherwise
            iLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);
            iCurrentSlice = sliceNumber('get', 'axial');
            aAxe = axes3Ptr('get', [], dSeriesOffset);
    end

    set(uiSliderSagPtr('get'), 'Visible', 'off');
    set(uiSliderCorPtr('get'), 'Visible', 'off');
    set(uiSliderTraPtr('get'), 'Visible', 'off');
    set(uiSliderMipPtr('get'), 'Visible', 'off');

    if isVsplash('get') == false

        if aAxe == axes1Ptr('get', [], dSeriesOffset)
            logoObj = logoObject('get');
            if ~isempty(logoObj)
                delete(logoObj);
                logoObject('set', '');
            end
        end
    else
        logoObj = logoObject('get');
        if ~isempty(logoObj)
            delete(logoObj);
            logoObject('set', '');
        end
    end

%    if aAxe == axes3Ptr('get', [], dSeriesOffset)
%         set(uiSliderWindowPtr('get'), 'Visible', 'off');
%         set(uiSliderLevelPtr('get') , 'Visible', 'off');

        set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(lineColorbarIntensityMinPtr('get'), 'Visible', 'off');

        set(textColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(textColorbarIntensityMinPtr('get'), 'Visible', 'off');

        set(uiColorbarPtr('get'), 'Visible', 'off');

        if isFusion('get')
%             set(uiFusionSliderWindowPtr('get'), 'Visible', 'off');
%             set(uiFusionSliderLevelPtr('get') , 'Visible', 'off');

            set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
            set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');
    
            set(textFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
            set(textFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');

            set(uiAlphaSliderPtr('get')   , 'Visible', 'off');
            set(uiFusionColorbarPtr('get'), 'Visible', 'off');
        end
%    end

    if overlayActivate('get') == true
        if     aAxe == axes1Ptr('get', [], dSeriesOffset)
            pAxes1Text = axesText('get', 'axes1');
            pAxes1Text.Visible = 'off';

            pAxes1View = axesText('get', 'axes1View');
            pAxes1View.Visible = 'off';

        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)
            pAxes2Text = axesText('get', 'axes2');
            pAxes2Text.Visible = 'off';

            pAxes2View = axesText('get', 'axes2View');
            pAxes2View.Visible = 'off';

        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)
            pAxes3Text = axesText('get', 'axes3');
            pAxes3Text.Visible = 'off';

            pAxes3View = axesText('get', 'axes3View');
            for tt=1:numel(pAxes3View)
                pAxes3View{tt}.Visible = 'off';
            end

            if isFusion('get') == true
                pAxes3fText = axesText('get', 'axes3f');
                pAxes3fText.Visible = 'off';
            end

        else
            if isVsplash('get') == false
                pAxesMipText = axesText('get', 'axesMip');
                pAxesMipText.Visible = 'off';

                pAxesMipView = axesText('get', 'axesMipView');
                pAxesMipView.Visible = 'off';
            end
        end
    end

    if crossActivate('get') == true && ...
       isVsplash('get') == false

        if     aAxe == axes1Ptr('get', [], dSeriesOffset)
            alAxes1Line = axesLine('get', 'axes1');
            for ii1=1:numel(alAxes1Line)
                alAxes1Line{ii1}.Visible = 'off';
            end
        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)
            alAxes2Line = axesLine('get', 'axes2');
            for ii2=1:numel(alAxes2Line)
                alAxes2Line{ii2}.Visible = 'off';
            end
        elseif aAxe == axesMipPtr('get', [], dSeriesOffset)
            alAxesMipLine = axesLine('get', 'axesMip');
            for ii4=1:numel(alAxesMipLine)
                alAxesMipLine{ii4}.Visible = 'off';
            end
        else
            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)
                alAxes3Line{ii3}.Visible = 'off';
            end
        end
    end

    sLogo = sprintf('%s\n', 'TriDFusion (3DF)');
    tLogo = text(aAxe, 0.02, 0.03, sLogo, 'Units','normalized');
    if strcmp(backgroundColor('get'), 'black')
        tLogo.Color = [0.8500 0.8500 0.8500];
    else
        tLogo.Color = [0.1500 0.1500 0.1500];
    end

    tOverlay = text(aAxe, 0.02, 0.97, '', 'Units','normalized');
    if strcmp(backgroundColor('get'), 'black')
        tOverlay.Color = [0.8500 0.8500 0.8500];
    else
        tOverlay.Color = [0.1500 0.1500 0.1500];
    end

    if overlayActivate('get') == false
        set(tOverlay, 'Visible', 'off');
    end

    if gateUseSeriesUID('get') == true
        dOffset = dSeriesOffset;

        for idx=1: numel(atInputTemplate)

            dOffset = dOffset+1;

            if dOffset > numel(atInputTemplate) || ... % End of list
               ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(atInputTemplate)
                    if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                        dOffset = bb;
                        break;
                    end

                end
            end
            if dOffset == dSeriesOffset
                iNbSeries = idx;
                break
            end
        end
    else
        iNbSeries = numel(atInputTemplate);
    end

    aInput  = inputBuffer('get');
    dOffset = dSeriesOffset;

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get') == true && ...
       strcmpi(gateLookupType('get'), 'Absolute')

        for jj=1:numel(atInputTemplate)
%            set(uiSeriesPtr('get'), 'Value', jj);
            aBuffer = dicomBuffer('get', [], jj);
            if isempty(aBuffer)
                aBuffer = aInput{jj};
%                if     strcmp(imageOrientation('get'), 'axial')
%                    aBuffer = permute(aInput{jj}, [1 2 3]);
%                elseif strcmp(imageOrientation('get'), 'coronal')
%                    aBuffer = permute(aInput{jj}, [3 2 1]);
%                elseif strcmp(imageOrientation('get'), 'sagittal')
%                    aBuffer = permute(aInput{jj}, [3 1 2]);
%                end
                dicomBuffer('set', aBuffer, jj);
            end

            if jj == 1
                lAbsoluteMin = min(aBuffer, [], 'all');
                lAbsoluteMax = max(aBuffer, [], 'all');
            else
                lBufferMin = min(aBuffer, [], 'all');
                lBufferMax = max(aBuffer, [], 'all');
                if lBufferMin < lAbsoluteMin
                    lAbsoluteMin = lBufferMin;
                end
                if lBufferMax > lAbsoluteMax
                    lAbsoluteMax = lBufferMax;
                end
            end
        end
    end

    bWriteSucessfull = true;
    for idx=1: iNbSeries

        if ~multiFrameRecord('get')
            break;
        end

        % Get current Axes

        axes1 = axes1Ptr('get', [], dSeriesOffset);
        axes2 = axes2Ptr('get', [], dSeriesOffset);
        axes3 = axes3Ptr('get', [], dSeriesOffset);
        if isVsplash('get') == false
            axesMip = axesMipPtr('get', [], dSeriesOffset);
        end

        % Get current CData

        imCoronal  = imCoronalPtr ('get', [], dSeriesOffset);
        imSagittal = imSagittalPtr('get', [], dSeriesOffset);
        imAxial    = imAxialPtr   ('get', [], dSeriesOffset);
        if isVsplash('get') == false
            imMip = imMipPtr('get', [], dSeriesOffset);
        end

        % Set new serie offset

        set(uiSeriesPtr('get'), 'Value', dOffset);

        % Set new Axes

        if isempty(axes1Ptr('get', [], dOffset))
            axes1Ptr('set', axes1, dOffset);
        end

        if isempty(axes2Ptr('get', [], dOffset))
            axes2Ptr('set', axes2, dOffset);
        end

        if isempty(axes3Ptr('get', [], dOffset))
            axes3Ptr('set', axes3, dOffset);
        end

        if isVsplash('get') == false
            if isempty(axesMipPtr('get', [], dOffset))
                axesMipPtr('set', axesMip, dOffset);
            end
        end

        % Set new CData

        if isempty(imCoronalPtr('get', [], dOffset))
            imCoronalPtr('set', imCoronal, dOffset);
        end

        if isempty(imSagittalPtr('get', [], dOffset))
            imSagittalPtr('set', imSagittal, dOffset);
        end

        if isempty(imAxialPtr('get', [], dOffset))
            imAxialPtr('set', imAxial, dOffset);
        end

        if isVsplash('get') == false
            if isempty(imMipPtr('get', [], dOffset))
                imMipPtr('set', imMip, dOffset);
            end
        end

        set(uiSeriesPtr('get'), 'Value', dOffset);
        
        atCoreMetaData = dicomMetaData('get', [], dOffset);
        if isempty(atCoreMetaData)
            atCoreMetaData = atInputTemplate(dOffset).atDicomInfo;
            dicomMetaData('set', atCoreMetaData, dOffset);
        end

        aBuffer = dicomBuffer('get', [], dOffset);
        if isempty(aBuffer)
            aBuffer = aInput{dOffset};
%            if     strcmpi(imageOrientation('get'), 'axial')
%                aBuffer = permute(aInput{dOffset}, [1 2 3]);
%            elseif strcmpi(imageOrientation('get'), 'coronal')
%                aBuffer = permute(aInput{dOffset}, [3 2 1]);
%            elseif strcmpi(imageOrientation('get'), 'sagittal')
%                aBuffer = permute(aInput{dOffset}, [3 1 2]);
%            end

            dicomBuffer('set', aBuffer, dOffset);
        end

        if size(aCurrentBuffer) ~= size(aBuffer)
            progressBar(1, 'Error: Resample or Register the series!');
            multiFrameRecord('set', false);
            bWriteSucessfull = false;
            mRecord.State = 'off';
            break;
        end

        if gateUseSeriesUID('get') == false && ...
           gateLookupTable('get') == true
            if strcmpi(atCoreMetaData{1}.Modality, 'ct')
                if min(aBuffer, [], 'all') >= 0
                    lMin = min(aBuffer, [], 'all');
                    lMax = max(aBuffer, [], 'all');
                else
                    [lMax, lMin] = computeWindowLevel(500, 50);
                end
            else
                if strcmpi(gateLookupType('get'), 'Relative')

                    sUnitDisplay = getSerieUnitValue(dOffset);

                    if strcmpi(sUnitDisplay, 'SUV')
                        tQuant = quantificationTemplate('get');
                        if tQuant.tSUV.dScale
                            lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;
                            lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;
                        else
                            lMin = min(aBuffer, [], 'all');
                            lMax = max(aBuffer, [], 'all');
                        end
                    else
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');
                    end
                else
                    lMin = lAbsoluteMin;
                    lMax = lAbsoluteMax;
                end
            end
            setWindowMinMax(lMax, lMin);
        end

if 1

        if gateUseSeriesUID('get') == false

            if aspectRatio('get') == true

                if ~isempty(atCoreMetaData{1}.PixelSpacing)
                    x = atCoreMetaData{1}.PixelSpacing(1);
                    y = atCoreMetaData{1}.PixelSpacing(2);
                    z = computeSliceSpacing(atCoreMetaData);

                    if x == 0
                        x = 1;
                    end

                    if y == 0
                        y = 1;
                    end

                    if z == 0
                        z = x;
                    end
                else

                    x = computeAspectRatio('x', atCoreMetaData);
                    y = computeAspectRatio('y', atCoreMetaData);
                    z = 1;
                end
                
                daspect(axes1Ptr('get', [], dOffset), [z y x]);
                daspect(axes2Ptr('get', [], dOffset), [z x y]);
                daspect(axes3Ptr('get', [], dOffset), [x y z]);

                if isVsplash('get') == false                                    
                    daspect(axesMipPtr('get', [], dOffset), [z y x]);
                end
            
%               if strcmp(imageOrientation('get'), 'axial')
%                    daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                    daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
%                    daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                    end

%               elseif strcmp(imageOrientation('get'), 'coronal')
%                    daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                    daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y z x]);
%                    daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                    end

%                elseif strcmp(imageOrientation('get'), 'sagittal')
%                    daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                    daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]);
%                    daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                    end
%               end

            else
                x =1;
                y =1;
                z =1;

                daspect(axes1Ptr('get', [], dOffset)  , [z x y]);
                daspect(axes2Ptr('get', [], dOffset)  , [z y x]);
                daspect(axes3Ptr('get', [], dOffset)  , [x y z]);
                if isVsplash('get') == false
                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                end

                axis(axes1Ptr('get', [], dOffset), 'normal');
                axis(axes2Ptr('get', [], dOffset), 'normal');
                axis(axes3Ptr('get', [], dOffset), 'normal');
                if isVsplash('get') == false
                    axis(axesMipPtr('get', [], dOffset), 'normal');
                end

            end

            aspectRatioValue('set', 'x', x);
            aspectRatioValue('set', 'y', y);
            aspectRatioValue('set', 'z', z);
        end
end
%        if numel(atInputTemplate(dOffset).asFilesList) ~= 1
%            if str2double(atInputTemplate(dOffset).atDicomInfo{2}.ImagePositionPatient(3)) - ...
%               str2double(atInputTemplate(dOffset).atDicomInfo{1}.ImagePositionPatient(3)) > 0

%                 aBuffer = aBuffer(:,:,end:-1:1);
%            end
%        end

        if overlayActivate('get') == true

            if     aAxe == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                if isVsplash('get') == true
                    [lFirst, lLast] = computeVsplashLayout(aBuffer, 'coronal', iCurrentSlice);
                    sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));
                else
                    sSliceNb = sprintf('%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));
                end

            elseif aAxe == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))

               if isVsplash('get') == true
                   [lFirst, lLast] = computeVsplashLayout(aBuffer, 'sagittal', iCurrentSlice);
                   sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));
               else
                    sSliceNb = sprintf('%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));
               end
            elseif aAxe == axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))

               if isVsplash('get') == false
                    sSliceNb = sprintf('%s/%s', num2str(mipAngle('get')), num2str(32));
               end
            else

                if isVsplash('get') == true
                    [lFirst, lLast] = computeVsplashLayout(aBuffer, 'axial', 1+iLastSlice-iCurrentSlice);
                    sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));
                else
                    sSliceNb = sprintf('%s/%s', num2str(1+iLastSlice-iCurrentSlice), num2str(iLastSlice));
                end
            end

            sAxeText = sprintf('\nFrame %d\n%s', ...
                dOffset, ...
                sSliceNb);

            set(tOverlay, 'String', sAxeText);
        end

        dOffset = dOffset+1;

        if gateUseSeriesUID('get') == true

            if dOffset > numel(atInputTemplate) || ... % End of list
               ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(atInputTemplate)
                    if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                        dOffset = bb;
                        break;
                    end

                end
            end
        else
            if dOffset > numel(atInputTemplate)
                dOffset = 1;
            end
        end

        refreshImages();

        I = getframe(aAxe);
        [indI,cm] = rgb2ind(I.cdata, 256);

        if idx == 1

            if strcmpi('*.gif', sExtention)
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)

                sDirName = sprintf('%s_%s_%s_JPG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention)
                sDirName = sprintf('%s_%s_%s_BMP_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');
            elseif strcmpi('*.png', sExtention)
                sDirName = sprintf('%s_%s_%s_PNG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png');                
            end
        else
            if strcmpi('*.gif', sExtention)
                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)
                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');
            elseif strcmpi('*.bmp', sExtention)
                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');
            elseif strcmpi('*.png', sExtention)
                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png');                
            end
        end

        try
            tRefreshRoi = roiTemplate('get', dOffset);
            if ~isempty(tRefreshRoi)
                for bb=1:numel(tRefreshRoi)
                    if isvalid(tRefreshRoi{bb}.Object)
                        tRefreshRoi{bb}.Object.Visible = 'off';
                    end
                end
            end
        catch
        end
        progressBar(idx / iNbSeries, 'Recording', 'red');


%           if gateUseSeriesUID('get') == true
%               if dOffset == dSeriesOffset
%                   break
%               end
%           end

    end


    set(uiSliderSagPtr('get'), 'Visible', 'on');
    set(uiSliderCorPtr('get'), 'Visible', 'on');
    set(uiSliderTraPtr('get'), 'Visible', 'on');
    set(uiSliderMipPtr('get'), 'Visible', 'on');

%    if aAxe == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
%         set(uiSliderWindowPtr('get'), 'Visible', 'on');
%         set(uiSliderLevelPtr('get') , 'Visible', 'on');

        set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'on');
        set(lineColorbarIntensityMinPtr('get'), 'Visible', 'on');

        set(textColorbarIntensityMaxPtr('get'), 'Visible', 'on');
        set(textColorbarIntensityMinPtr('get'), 'Visible', 'on');

        set(uiColorbarPtr('get'), 'Visible', 'on');

        if isFusion('get')
%             set(uiFusionSliderWindowPtr('get'), 'Visible', 'on');
%             set(uiFusionSliderLevelPtr('get') , 'Visible', 'on');

            set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', 'on');
    
            set(textFusionColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(textFusionColorbarIntensityMinPtr('get'), 'Visible', 'on');

            set(uiAlphaSliderPtr('get')   , 'Visible', 'on');
            set(uiFusionColorbarPtr('get'), 'Visible', 'on');
        end
%    end

    if overlayActivate('get')
        if     aAxe == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            pAxes1Text = axesText('get', 'axes1');
            pAxes1Text.Visible = 'on';

            pAxes1View = axesText('get', 'axes1View');
            pAxes1View.Visible = 'on';

        elseif aAxe == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            pAxes2Text = axesText('get', 'axes2');
            pAxes2Text.Visible = 'on';

            pAxes2View = axesText('get', 'axes2View');
            pAxes2View.Visible = 'on';

        elseif aAxe == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            pAxes3Text = axesText('get', 'axes3');
            pAxes3Text.Visible = 'on';

            pAxes3View = axesText('get', 'axes3View');
            for tt=1:numel(pAxes3View)
                pAxes3View{tt}.Visible = 'on';
            end

            if isFusion('get') == true
                pAxes3fText = axesText('get', 'axes3f');
                pAxes3fText.Visible = 'on';
            end
        else
            if isVsplash('get') == false
                pAxesMipText = axesText('get', 'axesMip');
                pAxesMipText.Visible = 'on';

                pAxesMipView = axesText('get', 'axesMipView');
                pAxesMipView.Visible = 'on';
            end
        end
    end

    if crossActivate('get') == true  && ...
       isVsplash('get') == false

        if     aAxe == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            alAxes1Line = axesLine('get', 'axes1');
            for ii1=1:numel(alAxes1Line)
                alAxes1Line{ii1}.Visible = 'on';
            end
        elseif aAxe == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            alAxes2Line = axesLine('get', 'axes2');
            for ii2=1:numel(alAxes2Line)
                alAxes2Line{ii2}.Visible = 'on';
            end
        elseif aAxe == axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
            alAxesMipLine = axesLine('get', 'axesMip');
            angle = mipAngle('get');
            if (angle == 0 || angle == 90 || angle == 180 || angle == 270)
                for ii4=1:numel(alAxesMipLine)
                    alAxesMipLine{ii4}.Visible = 'on';
                end
            end
        else
            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)
                alAxes3Line{ii3}.Visible = 'on';
            end
        end
    end

    delete(tLogo);
    delete(tOverlay);

    if isVsplash('get') == false

        if aAxe == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
            uiLogo = displayLogo(uiCorWindowPtr('get'));
            logoObject('set', uiLogo);
        end
    else

        if strcmpi(vSplahView('get'), 'coronal')
            uiLogo = displayLogo(uiCorWindowPtr('get'));

        elseif strcmpi(vSplahView('get'), 'sagittal')
            uiLogo = displayLogo(uiSagWindowPtr('get'));

        elseif  strcmpi(vSplahView('get'), 'axial')
            uiLogo = displayLogo(uiTraWindowPtr('get'));

        elseif strcmpi(vSplahView('get'), 'all')
            uiLogo = displayLogo(uiCorWindowPtr('get'));

        else
            uiLogo = displayLogo(uiCorWindowPtr('get'));
        end

        logoObject('set', uiLogo);
    end

    if bWriteSucessfull == true
        if strcmpi('*.gif', sExtention)
            progressBar(1, sprintf('Write %s completed', sFileName));
        elseif strcmpi('*.jpg', sExtention) || ...
               strcmpi('*.bmp', sExtention) || ...
               strcmpi('*.png', sExtention)
            progressBar(1, sprintf('Write %d files to %s completed', iNbSeries, sImgDirName));
        end
    end
%          dicomBuffer('set', aBackup);
    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
    
    cropValue('set', min(dicomBuffer('get', [], dSeriesOffset), [], 'all'));

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get') == true
        setWindowMinMax(lMaxBak, lMinBak);
    end

    set(uiSeriesPtr('get'), 'Enable', 'on');

    refreshImages();
end
