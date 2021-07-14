function setFusionCallback(~, ~)
%function setFusionCallback(~, ~)
%Activate/Deactivate Fusion Main Function.
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
    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

       volFusionObj = volFusionObject('get');
       mipFusionObj = mipFusionObject('get');
       isoFusionObj = isoFusionObject('get');

       if isFusion('get') == false

            isFusion('set', true);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

            tFuseInput  = inputTemplate('get');
            iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
            atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

            if ~isempty(volFusionObj) && switchTo3DMode('get') == true
                [aFusionMap, sFusionType] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                set(volFusionObj, 'Alphamap', aFusionMap);
                set(volFusionObj, 'Colormap', get3DColorMap('get', colorMapVolFusionOffset('get') ));

                volFusionObject('set', volFusionObj);

                if get(ui3DVolumePtr('get'), 'Value') == 2
                    if strcmpi(sFusionType, 'custom')
                        ic = customAlphaCurve(axe3DPanelVolAlphmapPtr('get'),  volFusionObj, 'volfusion');
                        ic.surfObj = volFusionObj;

                        volICFusionObject('set', ic);

                        alphaCurveMenu(axe3DPanelVolAlphmapPtr('get'), 'volfusion');
                    else
                        displayAlphaCurve(aFusionMap, axe3DPanelMipAlphmapPtr('get'));
                    end
                end

            end

            if ~isempty(mipFusionObj) && switchToMIPMode('get') == true

                [aFusionMap, sFusionType] = getMipFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                set(mipFusionObj, 'Alphamap', aFusionMap);
                set(mipFusionObj, 'Colormap', get3DColorMap('get', colorMapMipFusionOffset('get') ));

                mipFusionObject('set', mipFusionObj);

                if get(ui3DVolumePtr('get'), 'Value') == 2
                    if strcmpi(sFusionType, 'custom')
                        ic = customAlphaCurve(axe3DPanelMipAlphmapPtr('get'),  mipFusionObj, 'mipfusion');
                        ic.surfObj = mipFusionObj;

                        mipICFusionObject('set', ic);

                        alphaCurveMenu(axe3DPanelMipAlphmapPtr('get'), 'mipfusion');
                    else
                        displayAlphaCurve(aFusionMap, axe3DPanelMipAlphmapPtr('get'));
                    end
                end

            end

            if ~isempty(isoFusionObj) && switchToIsoSurface('get')

                set(isoFusionObj, 'Isovalue', isoSurfaceFusionValue('get'));
                set(isoFusionObj, 'IsosurfaceColor', surfaceColor('get', isoColorFusionOffset('get')) );

                isoFusionObject('set', isoFusionObj);
            end

       else
            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            if ~isempty(volFusionObj)
                volFusionObj.Alphamap = zeros(256,1);
                volFusionObject('set', volFusionObj);
                if get(ui3DVolumePtr('get'), 'Value') == 2
                    displayAlphaCurve(zeros(256,1), axe3DPanelVolAlphmapPtr('get'));
                end
            end

            if ~isempty(mipFusionObj)
                mipFusionObj.Alphamap = zeros(256,1);
                mipFusionObject('set', mipFusionObj);
                if get(ui3DVolumePtr('get'), 'Value') == 2
                    displayAlphaCurve(zeros(256,1), axe3DPanelMipAlphmapPtr('get'));
                end
            end

            if ~isempty(isoFusionObj)
                isoFusionObj.Isovalue = 1;
                isoFusionObject('set', isoFusionObj);
            end
       end
    else

        tFuseInput = inputTemplate('get');
        if numel(tFuseInput) == 0
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return
        end

        iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if iSeriesOffset > numel(tFuseInput)
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return;
        end

        iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
        if iFuseOffset > numel(tFuseInput)
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return;
        end

        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
        tMetaData  = dicomMetaData('get');
        if isempty(tMetaData)
            tMetaData = tFuseInput(iSeriesOffset).atDicomInfo;
        end

        set(uiSeriesPtr('get'), 'Value', iFuseOffset);
        tFuseMetaData = dicomMetaData('get');
        if isempty(tFuseMetaData)
            tFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
        end
        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

        if isFusion('get') == false

            aInput = inputBuffer('get');

            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
            A = dicomBuffer('get');

            set(uiSeriesPtr('get'), 'Value', iFuseOffset);
            B = dicomBuffer('get');
            if isempty(B)
                B = aInput{iFuseOffset};
            end
            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

            if numel(size(A))~=numel(size(B)) %Fuse 2D with 3D
if 1
                isFusion('set', false);
                set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
                fusionBuffer('reset');
                return;

else
                if numel(size(A))>numel(size(B))
                    [x1,y1,z1]=size(A);
                    [x2,y2,~]=size(B);
                    aTemp = zeros(x2,y2,z1);
                    for nn=1:z1
                        aTemp(:,:,nn)=B(:,:);
                    end
                    B = imresize(aTemp, [x1 y1]);

                    refSliceThickness = computeSliceSpacing(tMetaData);
                    tFuseMetaData{1}.SpacingBetweenSlices = refSliceThickness;



                else

                end
end
            end

            initFusionWindowLevel('set', true); % Need to be fix

            set(btnFusionPtr('get')    , 'Enable', 'off');
            set(uiFusedSeriesPtr('get'), 'Enable', 'off');

            if size(B, 3) == 1

                progressBar(0.999, 'Processing fusion, please wait');

                [x1,y1,~] = size(A);
                [x2,y2,~] = size(B);

                B = imresize(B, [x1 y1]);

                if iSeriesOffset ~= iFuseOffset
                    if tFuseInput(iSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1);
                    end

                    if tFuseInput(iSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:);
                    end
                end

 %               tFuseInput(iFuseOffset).bEdgeDetection = false;

 %               inputTemplate('set', tFuseInput);

             %   B = resampleImage(A, B);

                fusionBuffer('set', B);

                if aspectRatio('get') == true

                    xf = computeAspectRatio('x', tFuseMetaData);
                    yf = computeAspectRatio('y', tFuseMetaData);

                    daspect(axefPtr('get'), [xf yf 1]);

                else
                    xf =1;
                    yf =1;

                    daspect(axefPtr('get'), [1 1 1]);
                    axis(axefPtr('get'), 'normal');
                end

                fusionAspectRatioValue('set', 'x', xf);
                fusionAspectRatioValue('set', 'y', yf);

            else

                progressBar(0.999, 'Processing fusion, please wait');

                set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                if strcmp(imageOrientation('get'), 'coronal')
                    B = permute(B, [3 2 1]);
                elseif strcmp(imageOrientation('get'), 'sagittal')
                    B = permute(B, [2 3 1]);
                else
                    B = permute(B, [1 2 3]);
                end

                if iSeriesOffset ~= iFuseOffset

                    if tFuseInput(iSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1,:);
                    end

                    if tFuseInput(iSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:,:);
                    end

                    if tFuseInput(iSeriesOffset).bFlipHeadFeet == true
                        B=B(:,:,end:-1:1);
                    end
                end

%                tFuseInput(iFuseOffset).bEdgeDetection = false;
%                inputTemplate('set', tFuseInput);

                [x1,y1,z1] = size(A);
                [x2,y2,z2] = size(B);

                if (z1 ~= z2 && strcmpi(imageOrientation('get'), 'axial'))  ||...
                   (x1 ~= x2 && strcmpi(imageOrientation('get'), 'coronal'))||...
                   (y1 ~= y2 && strcmpi(imageOrientation('get'), 'sagittal'))

    %                 msgbox('Warning: Reslice is not yet supported, the fusion may be wrong!');
                    if ( ( tMetaData{1}.ReconstructionDiameter ~= 700 && ...
                           strcmpi(tMetaData{1}.Modality, 'ct') ) || ...
                       ( tFuseMetaData{1}.ReconstructionDiameter ~= 700 && ...
                         strcmpi(tFuseMetaData{1}.Modality, 'ct') ) ) && ...
                       numel(tMetaData) ~= 1 && ...
                       numel(tFuseMetaData) ~= 1
                        [B, tFuseMetaData] = ...
                            resampleImageTransformMatrix(B, ...
                                                         tFuseMetaData, ...
                                                         A, ...
                                                         tMetaData, ...
                                                         'linear', ...
                                                         false ...
                                                         );
                   else
                        [B, tFuseMetaData] = ...
                            resampleImage(B, ...
                                          tFuseMetaData, ...
                                          A, ...
                                          tMetaData, ...
                                          'linear', ...
                                          false ...
                                          );
                    end

                else
                %    B = imresize3(B, [x1 y1 z1]); % path z should be z2
                    if ( ( tMetaData{1}.ReconstructionDiameter ~= 700 && ...
                           strcmpi(tMetaData{1}.Modality, 'ct') ) || ...
                       ( tFuseMetaData{1}.ReconstructionDiameter ~= 700 && ...
                          strcmpi(tFuseMetaData{1}.Modality, 'ct') ) ) && ...
                       numel(tMetaData) ~= 1 && ...
                       numel(tFuseMetaData) ~= 1
                        [B, tFuseMetaData] = ...
                            resampleImageTransformMatrix(B, ...
                                                         tFuseMetaData, ...
                                                         A, ...
                                                         tMetaData, ...
                                                         'linear', ...
                                                         false ...
                                                         );
                    else
                        [B, tFuseMetaData] = ...
                            resampleImage(B, ...
                                          tFuseMetaData, ...
                                          A, ...
                                          tMetaData, ...
                                          'linear', ...
                                          false ...
                                          );
                    end
                end

                fusionBuffer('set', B);

                if aspectRatio('get') == true

                    if ~isempty(tFuseMetaData{1}.PixelSpacing)
                        xf = tFuseMetaData{1}.PixelSpacing(1);
                        yf = tFuseMetaData{1}.PixelSpacing(2);
                        zf = computeSliceSpacing(tFuseMetaData);

                        if xf == 0
                            xf = 1;
                        end

                        if yf == 0
                            yf = 1;
                        end

                        if zf == 0
                            zf = xf;
                        end
                    else

                        xf = computeAspectRatio('x', tFuseMetaData) ;
                        yf = computeAspectRatio('y', tFuseMetaData) ;
                        zf = 1;
                    end

                   if strcmp(imageOrientation('get'), 'axial')
                        daspect(axes1fPtr('get'), [zf xf yf]);
                        daspect(axes2fPtr('get'), [zf yf xf]);
                        daspect(axes3fPtr('get'), [xf yf zf]);
                   elseif strcmp(imageOrientation('get'), 'coronal')
                        daspect(axes1fPtr('get'), [xf yf zf]);
                        daspect(axes2fPtr('get'), [yf zf xf]);
                        daspect(axes3fPtr('get'), [zf xf yf]);
                    elseif strcmp(imageOrientation('get'), 'sagittal')
                        daspect(axes1fPtr('get'), [yf xf zf]);
                        daspect(axes2fPtr('get'), [xf zf yf]);
                        daspect(axes3fPtr('get'), [zf xf yf]);
                    end
                else
                    xf =1;
                    yf =1;
                    zf =1;

                    daspect(axes1fPtr('get'), [1 1 1]);
                    daspect(axes2fPtr('get'), [1 1 1]);
                    daspect(axes3fPtr('get'), [1 1 1]);

                    axis(axes1fPtr('get'), 'normal');
                    axis(axes2fPtr('get'), 'normal');
                    axis(axes3fPtr('get'), 'normal');
                end

                fusionAspectRatioValue('set', 'x', xf);
                fusionAspectRatioValue('set', 'y', yf);
                fusionAspectRatioValue('set', 'z', zf);
            end

            progressBar(1, 'Ready');

            set(btnFusionPtr('get')    , 'Enable', 'on');
            set(uiFusedSeriesPtr('get'), 'Enable', 'on');

            isFusion('set', true);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        else
            if numel(tFuseInput) == 1
                if tFuseInput(iFuseOffset).bEdgeDetection == false
                    tFuseInput(iFuseOffset).bFusedEdgeDetection = false;
                end
            else
                tFuseInput(iFuseOffset).bEdgeDetection = false;
            end

%           tFuseInput(iFuseOffset).bEdgeDetection = false;
           inputTemplate('set', tFuseInput);

           isFusion('set', false);

           initFusionWindowLevel('set', false); % Need to be fix

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

    %         fusionBuffer('set', '');
        end

        if initFusionWindowLevel('get') == true
            initFusionWindowLevel('set', false);

            if strcmpi(tFuseMetaData{1}.Modality, 'ct')
                if min(B, [], 'all') >= 0
                    dMax = max(B, [], 'all');
                    dMin = min(B, [], 'all');
                else
                    [dMax, dMin] = computeWindowLevel(2000, 0);
                end
            else
                sUnitDisplay = getSerieUnitValue(iFuseOffset);
                if strcmpi(sUnitDisplay, 'SUV')
                    if tFuseInput(iFuseOffset).tQuant.tSUV.dScale
                        dMin = suvWindowLevel('get', 'min')/tFuseInput(iFuseOffset).tQuant.tSUV.dScale;
                        dMax = suvWindowLevel('get', 'max')/tFuseInput(iFuseOffset).tQuant.tSUV.dScale;
                    else
                        dMin = min(B, [], 'all');
                        dMax = max(B, [], 'all');
                    end
                else
                    dMin = min(B, [], 'all');
                    dMax = max(B, [], 'all');
                end
            end

            fusionWindowLevel('set', 'max', dMax);
            fusionWindowLevel('set', 'min', dMin);

            sliderFusionWindowLevelValue('set', 'min', 0.5);
            sliderFusionWindowLevelValue('set', 'max', 0.5);

            set(uiFusionSliderWindowPtr('get'), 'Value', 0.5);
            set(uiFusionSliderLevelPtr('get' ), 'Value', 0.5);

            getFusionInitWindowMinMax('set', dMax, dMin);

            sliderAlphaValue('set', 0.5);
            set(uiAlphaSliderPtr('get') , 'Value', 0.5);

            if size(fusionBuffer('get'), 3) == 1
                set(axefPtr('get'), 'CLim', [dMin dMax]);
            else
                set(axes1fPtr('get'), 'CLim', [dMin dMax]);
                set(axes2fPtr('get'), 'CLim', [dMin dMax]);
                set(axes3fPtr('get'), 'CLim', [dMin dMax]);
            end

        else
            lFusionMin = fusionWindowLevel('get', 'min');
            lFusionMax = fusionWindowLevel('get', 'max');
            if size(dicomBuffer('get'), 3) == 1
                set(axefPtr('get'), 'CLim', [lFusionMin lFusionMax]);
            else
                set(axes1fPtr('get'), 'CLim', [lFusionMin lFusionMax]);
                set(axes2fPtr('get'), 'CLim', [lFusionMin lFusionMax]);
                set(axes3fPtr('get'), 'CLim', [lFusionMin lFusionMax]);
            end
        end

        uiAlphaSlider = uiAlphaSliderPtr('get');
        aAxePosition  = uiAlphaSlider.Parent.Position;

        uiSegMainPanel    = uiSegMainPanelPtr('get');
        uiKernelMainPanel = uiKernelMainPanelPtr('get');
        uiRoiMainPanel    = uiRoiMainPanelPtr('get');

        if size(dicomBuffer('get'), 3) == 1

            if viewSegPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiSegMainPanel.Position(3)+10 ...
                                 35 ...
                                 aAxePosition(3)-uiSegMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            elseif viewKernelPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiKernelMainPanel.Position(3)+10 ...
                                 35 ...
                                 aAxePosition(3)-uiKernelMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            elseif viewRoiPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiRoiMainPanel.Position(3)+10 ...
                                 35 ...
                                 aAxePosition(3)-uiRoiMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            else
                set(uiAlphaSlider, ...
                    'Position', [10 ...
                                 35 ...
                                 aAxePosition(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            end
        else
           if isVsplash('get') == true && ...
               ~strcmpi(vSplahView('get'), 'all')
                if viewSegPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiSegMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aAxePosition(3)-uiSegMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                elseif viewKernelPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiKernelMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aAxePosition(3)-uiKernelMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                elseif viewRoiPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiRoiMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aAxePosition(3)-uiRoiMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                else
                    set(uiAlphaSlider, ...
                        'Position', [10 ...
                                     addOnWidth('get')+50 ...
                                     aAxePosition(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                end
           else
                set(uiAlphaSlider, ...
                    'Position', [aAxePosition(3)/2+10 ...
                                 addOnWidth('get')+50 ...
                                 aAxePosition(3)/2-20 ...
                                 15 ...
                                 ] ...
                    );
            end
        end
        set(uiAlphaSlider, 'BackgroundColor', backgroundColor('get'));

        ptrFusionColorbar = uiFusionColorbarPtr('get');
        aAxePosition = ptrFusionColorbar.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1
            set(ptrFusionColorbar, ...
                'Position', [aAxePosition(3)-49 ...
                             27 ...
                             40 ...
                             ((aAxePosition(4))/2)-41-20 ...
                             ] ...
                );
        else
            if isVsplash('get') == true && ...
              ~strcmpi(vSplahView('get'), 'all')
                if viewSegPanel('get')

                    set(ptrFusionColorbar, ...
                        'Position', [aAxePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aAxePosition(4))/2)-35-20 ...
                                     ] ...
                        );
                elseif viewKernelPanel('get') == true

                    set(ptrFusionColorbar, ...
                        'Position', [aAxePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aAxePosition(4))/2)-35-20 ...
                                     ] ...
                        );
                elseif viewRoiPanel('get') == true

                    set(ptrFusionColorbar, ...
                        'Position', [aAxePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aAxePosition(4))/2)-35-20 ...
                                     ] ...
                        );
                else
                    set(ptrFusionColorbar, ...
                        'Position', [aAxePosition(3)-49 ...
                                     29 ...
                                     40 ...
                                     ((aAxePosition(4))/2)-35-20 ...
                                     ] ...
                        );
                end
            else
                set(ptrFusionColorbar, ...
                    'Position', [aAxePosition(3)-49 ...
                                 29 ...
                                 40 ...
                                 ((aAxePosition(4))/2)-35-20 ...
                                 ] ...
                    );
            end
        end

        uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
        aAxePosition = uiFusionSliderWindow.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1

            set(uiFusionSliderWindow, ...
                'Position', [aAxePosition(3)-50 ...
                             55 ...
                             12 ...
                             (aAxePosition(4)/2)-75-20 ...
                             ] ...
                );
        else
            set(uiFusionSliderWindow, ...
                'Position', [aAxePosition(3)-50 ...
                             70 ...
                             12 ...
                             (aAxePosition(4)/2)-75-20 ...
                             ] ...
                );
        end
        set(uiFusionSliderWindow, ...
            'BackgroundColor', backgroundColor('get') ...
            );

        uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
        aAxePosition = uiFusionSliderLevel.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1
            set(uiFusionSliderLevel, ...
                'Position', [aAxePosition(3)-21 ...
                             55 ...
                             12 ...
                             (aAxePosition(4)/2)-75-20 ...
                             ] ...
                );
        else
            set(uiFusionSliderLevel, ...
                'Position', [aAxePosition(3)-21 ...
                             70 ...
                             12 ...
                             (aAxePosition(4)/2)-75-20 ...
                             ] ...
                );
        end
        set(uiFusionSliderLevel, ...
            'BackgroundColor', backgroundColor('get') ...
            );

        if isFusion('get') == true

            uiSliderWindow = uiSliderWindowPtr('get');
            aAxePosition = uiSliderWindow.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1
                set(uiSliderWindow, ...
                    'Position', [aAxePosition(3)-50 ...
                                 (aAxePosition(4)/2)-15 ...
                                 12 ...
                                 (aAxePosition(4)/2)-30-20 ...
                                 ] ...
                    );
            else
                set(uiSliderWindow, ...
                    'Position', [aAxePosition(3)-50 ...
                                 aAxePosition(4)/2 ...
                                 12 ...
                                 (aAxePosition(4)/2)-45-20 ...
                                 ] ...
                    );
            end
            set(uiSliderWindow, ...
                'BackgroundColor', backgroundColor('get') ...
                );

            uiSliderLevel = uiSliderLevelPtr('get');
            aAxePosition = uiSliderLevel.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderLevel, ...
                    'Position', [aAxePosition(3)-21 ...
                                 (aAxePosition(4)/2)-15 ...
                                 12 ...
                                 (aAxePosition(4)/2)-30-20 ...
                                 ] ...
                    );
            else
                set(uiSliderLevel, ...
                    'Position', [aAxePosition(3)-21 ...
                                 aAxePosition(4)/2 ...
                                 12 ...
                                 (aAxePosition(4)/2)-45-20 ...
                                 ] ...
                    );
            end
            set(uiSliderLevel, ...
                'BackgroundColor', backgroundColor('get') ...
                );

            ptrColorbar = uiColorbarPtr('get');
            aAxePosition = ptrColorbar.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(ptrColorbar, ...
                    'Position', [aAxePosition(3)-49 ...
                                 (aAxePosition(4)/2)-9 ...
                                 40 ...
                                 (aAxePosition(4)/2)+5-20 ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true && ...
                  ~strcmpi(vSplahView('get'), 'all')

                    if viewSegPanel('get')

                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                         (aAxePosition(4)/2) ...
                                         40 ...
                                         (aAxePosition(4)/2)-4-20 ...
                                         ] ...
                            );
                    elseif viewKernelPanel('get') == true

                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                         (aAxePosition(4)/2) ...
                                         40 ...
                                         (aAxePosition(4)/2)-4-20 ...
                                         ] ...
                            );
                    elseif viewRoiPanel('get') == true

                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                         (aAxePosition(4)/2) ...
                                         40 ...
                                         (aAxePosition(4)/2)-4-20 ...
                                         ] ...
                            );
                    else
                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-49 ...
                                         (aAxePosition(4)/2) ...
                                         40 ...
                                         (aAxePosition(4)/2)-4-20 ...
                                         ] ...
                            );
                    end
                else
                    set(ptrColorbar, ...
                        'Position', [aAxePosition(3)-49 ...
                                     (aAxePosition(4)/2) ...
                                     40 ...
                                     (aAxePosition(4)/2)-4-20 ...
                                     ] ...
                        );
                end
            end
        else

            uiSliderWindow = uiSliderWindowPtr('get');
            aAxePosition = uiSliderWindow.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderWindow, ...
                    'Position', [aAxePosition(3)-50 ...
                                 35 ...
                                 12 ...
                                 aAxePosition(4)-80-20 ...
                                 ] ...
                    );
            else
                set(uiSliderWindow, ...
                    'Position', [aAxePosition(3)-50 ...
                                 50 ...
                                 12 ...
                                 aAxePosition(4)-95-20 ...
                                 ] ...
                    );
            end

            uiSliderLevel = uiSliderLevelPtr('get');
            aAxePosition = uiSliderLevel.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderLevel, ...
                    'Position', [aAxePosition(3)-21 ...
                                 35 ...
                                 12 ...
                                 aAxePosition(4)-80-20 ...
                                 ] ...
                    );
            else
                set(uiSliderLevel, ...
                    'Position', [aAxePosition(3)-21 ...
                                 50 ...
                                 12 ...
                                 aAxePosition(4)-95-20 ...
                                 ] ...
                   );
            end

            ptrColorbar = uiColorbarPtr('get');
            aAxePosition = ptrColorbar.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(ptrColorbar, ...
                    'Position', [aAxePosition(3)-49 ...
                                 7 ...
                                 40 ...
                                 aAxePosition(4)-11-20 ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true && ...
                  ~strcmpi(vSplahView('get'), 'all')
                    if viewSegPanel('get')

                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aAxePosition(4)-11-20 ...
                                         ] ...
                            );
                    elseif viewKernelPanel('get') == true
                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aAxePosition(4)-11-20 ...
                                         ] ...
                            );
                    elseif viewRoiPanel('get') == true
                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aAxePosition(4)-11-20 ...
                                         ] ...
                            );
                    else
                        set(ptrColorbar, ...
                            'Position', [aAxePosition(3)-49 ...
                                         7 ...
                                         40 ...
                                         aAxePosition(4)-11-20 ...
                                         ] ...
                            );
                    end
                else
                    set(ptrColorbar, ...
                        'Position', [aAxePosition(3)-49 ...
                                     7 ...
                                     40 ...
                                     aAxePosition(4)-11-20 ...
                                     ] ...
                        );
                end
            end
        end

        if isFusion('get') == true

            set(uiFusionColorbarPtr('get')    , 'Visible', 'on');
            set(uiFusionSliderWindowPtr('get'), 'Visible', 'on');
            set(uiFusionSliderLevelPtr('get') , 'Visible', 'on');
            set(uiAlphaSliderPtr('get')       , 'Visible', 'on');
        else

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            isMoveImageActivated('set', false);

            set(uiFusionColorbarPtr('get')    , 'Visible', 'off');
            set(uiFusionSliderWindowPtr('get'), 'Visible', 'off');
            set(uiFusionSliderLevelPtr('get') , 'Visible', 'off');
            set(uiAlphaSliderPtr('get')       , 'Visible', 'off');
        end

        if size(dicomBuffer('get'), 3) == 1

            if isFusion('get') == true

                set(imAxeFPtr('get') , 'Visible', 'on');
                alpha(axePtr('get'), 0.5);
            else
                set(imAxeFPtr('get') , 'Visible', 'off');
                alpha(axePtr('get'), 1);
            end
        else
            if isFusion('get') == true

                set(imCoronalFPtr('get') , 'Visible', 'on');
                set(imSagittalFPtr('get'), 'Visible', 'on');
                set(imAxialFPtr('get')   , 'Visible', 'on');

                alpha(axes1Ptr('get'), 0.5);
                alpha(axes2Ptr('get'), 0.5);
                alpha(axes3Ptr('get'), 0.5);
            else
                set(imCoronalFPtr('get') , 'Visible', 'off');
                set(imSagittalFPtr('get'), 'Visible', 'off');
                set(imAxialFPtr('get')   , 'Visible', 'off');

                alpha(axes1Ptr('get'), 1);
                alpha(axes2Ptr('get'), 1);
                alpha(axes3Ptr('get'), 1);
            end
        end

        uiLogo = logoObject('get');
        if (size(dicomBuffer('get'), 3) == 1 && ...
            isFusion('get') == true) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'axial')) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'coronal')) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'sagittal'))

            set(uiLogo, 'Position', [5 35 70 30]);
        else
            set(uiLogo, 'Position', [5 15 70 30]);
        end

        setViewerDefaultColor(true, tMetaData, tFuseMetaData);

        refreshImages();
    end
    catch
        progressBar(1, 'Error:setFusionCallback()');
    end
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
