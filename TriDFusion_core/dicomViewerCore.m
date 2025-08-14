function dicomViewerCore()
%function dicomViewerCore()
%DICOM Viewer 2D & 3D Core.
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

    isCombineMultipleFusion('set', false);

    keyPressFusionStatus('set', 2);

    isMoveImageActivated('set', false);

    showRightClickMenu(false);

    rightClickMenu('reset');

%    im  = gpuArray(dicomBuffer('get'));
%    dicomBuffer('set', im);
%    imf  = gpuArray(fusionBuffer('get'));
%    dicomBuffer('set', imf);

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    im = dicomBuffer('get', [], dSeriesOffset);

    atMetaData = dicomMetaData('get');

    if size(im, 3) == 1
        set(uiOneWindowPtr('get'), 'Visible', 'off');
    else
        set(uiCorWindowPtr('get'), 'Visible', 'off');
        set(uiSagWindowPtr('get'), 'Visible', 'off');
        set(uiTraWindowPtr('get'), 'Visible', 'off');
        set(uiMipWindowPtr('get'), 'Visible', 'off');

        set(uiSliderCorPtr('get'), 'Visible', 'off');
        set(uiSliderSagPtr('get'), 'Visible', 'off');
        set(uiSliderTraPtr('get'), 'Visible', 'off');
        set(uiSliderMipPtr('get'), 'Visible', 'off');
    end

    if initWindowLevel('get') == true

        [lMin, lMax] = setWindowLevel(im, atMetaData);

    else
        lMin = windowLevel('get', 'min');
        lMax = windowLevel('get', 'max');
    end

    if lMin == lMax
        lMax = lMin+1;
    end

    atInput = inputTemplate('get');

    if     strcmpi(atInput(dSeriesOffset).sOrientationView, 'Axial')
        imageOrientation('set', 'axial');
    elseif strcmpi(atInput(dSeriesOffset).sOrientationView, 'Coronal')
        imageOrientation('set', 'coronal');
    elseif strcmpi(atInput(dSeriesOffset).sOrientationView, 'Sagittal')
        imageOrientation('set', 'sagittal');
    end

    if isfield(atMetaData{1}, 'PatientName')

        if  isstruct(atMetaData{1}.PatientName)

            if isfield(atMetaData{1}.PatientName, 'GivenName')

                sGivenName = atMetaData{1}.PatientName.GivenName;
            else
                sGivenName = '';
            end

            if isfield(atMetaData{1}.PatientName, 'MiddleName')

                sMiddleName = atMetaData{1}.PatientName.MiddleName;
            else
                sMiddleName = '';
            end

            if isfield(atMetaData{1}.PatientName, 'FamilyName')
                sFamilyName = atMetaData{1}.PatientName.FamilyName;
            else
                sFamilyName = '';
            end

            sPatientName = sprintf('%s %s %s', sGivenName, sMiddleName, sFamilyName);
            sPatientName = strrep(sPatientName,'^',' ');
            sPatientName = strtrim(sPatientName);
        else
            sPatientName = atMetaData{1}.PatientName;
            sPatientName = strrep(sPatientName,'^',' ');
            sPatientName = strtrim(sPatientName);
        end
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
            try
                sSeriesDate = datetime(sSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
            catch
                sSeriesDate = '';
            end
        end
    else
        sSeriesDate = '';
    end

%     uiSliderWindow = uiSliderWindowPtr('get');
%     if isempty(uiSliderWindow)
%         uiSliderWindow = ...
%             uicontrol(fiMainWindowPtr('get'), ...
%                       'Style'   , 'Slider', ...
%                       'Value'   , sliderWindowLevelValue('get', 'max'), ...
%                       'Enable'  , 'on', ...
%                       'BackgroundColor', backgroundColor('get'), ...
%                       'CallBack', @sliderWindowCallback ...
%                       );
%         uiSliderWindowPtr('set', uiSliderWindow);
%
%         addlistener(uiSliderWindow, 'Value', 'PreSet', @sliderWindowCallback);
%
%         set(uiSliderWindow, 'Visible', 'off');
%
%     end
%
%     uiSliderLevel = uiSliderLevelPtr('get');
%     if isempty(uiSliderLevel)
%         uiSliderLevel = ...
%             uicontrol(fiMainWindowPtr('get'), ...
%                       'Style'   , 'Slider', ...
%                       'Value'   , sliderWindowLevelValue('get', 'min'), ...
%                       'Enable'  , 'on', ...
%                       'BackgroundColor', backgroundColor('get'), ...
%                       'CallBack', @sliderLevelCallback ...
%                       );
%         uiSliderLevelPtr('set', uiSliderLevel);
%
%         addlistener(uiSliderLevel,'Value','PreSet',@sliderLevelCallback);
%
%         set(uiSliderLevel, 'Visible', 'off');
%     end

%     uiSliderWindow = uiSliderWindowPtr('get');
%     if ~isempty(uiSliderWindow)
%         aFigurePosition = uiSliderWindow.Parent.Position;
%         if size(dicomBuffer('get'), 3) == 1
%             set(uiSliderWindow, ...
%                 'Position', [aFigurePosition(3)-50 ...
%                              35 ...
%                              12 ...
%                              aFigurePosition(4)-80  ...
%                              ] ...
%                 );
%         else
%             if isVsplash('get') == true
%                 set(uiSliderWindow, ...
%                     'Position', [aFigurePosition(3)-50 ...
%                                  50 ...
%                                  12 ...
%                                  aFigurePosition(4)-95  ...
%                                  ] ...
%                     );
%             else
%                 uiTraWindow = uiTraWindowPtr('get');
%                 aAxePosition = uiTraWindow.Position;
%
%                 set(uiSliderWindow, ...
%                     'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
%                                  50 ...
%                                  12 ...
%                                  aFigurePosition(4)-95  ...
%                                  ] ...
%                     );
%             end
%         end
%     end
%
%     uiSliderLevel = uiSliderLevelPtr('get');
%     if ~isempty(uiSliderLevel)
%         aFigurePosition = uiSliderLevel.Parent.Position;
%         if size(dicomBuffer('get'), 3) == 1
%             set(uiSliderLevel, ...
%                 'Position', [aFigurePosition(3)-21 ...
%                              35 ...
%                              12 ...
%                              aFigurePosition(4)-80  ...
%                              ] ...
%                 );
%         else
%             if isVsplash('get') == true
%                 set(uiSliderLevel, ...
%                     'Position', [aFigurePosition(3)-21 ...
%                                  50 ...
%                                  12 ...
%                                  aFigurePosition(4)-95  ...
%                                  ] ...
%                     );
%             else
%                 uiTraWindow = uiTraWindowPtr('get');
%                 aAxePosition = uiTraWindow.Position;
%
%                 set(uiSliderLevel, ...
%                     'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
%                                  50 ...
%                                  12 ...
%                                  aFigurePosition(4)-95  ...
%                                  ] ...
%                     );
%             end
%         end
%     end

    bInitSegPanel = false;
    if viewSegPanel('get')

        if isVsplash('get') == false
            bInitSegPanel = true;
        end

        viewSegPanel('set', false);

        objSegPanel = viewSegPanelMenuObject('get');
        if ~isempty(objSegPanel)
            objSegPanel.Checked = 'off';
        end
    end

    bInitKernelPanel = false;
    if  viewKernelPanel('get')

        if isVsplash('get') == false
            bInitKernelPanel = true;
        end

        viewKernelPanel('set', false);

        objKernelPanel = viewKernelPanelMenuObject('get');
        if ~isempty(objKernelPanel)
            objKernelPanel.Checked = 'off';
        end
    end

    bInitRoiPanel = false;
    if  viewRoiPanel('get')

        if isVsplash('get') == false
            bInitRoiPanel = true;
        end

        viewRoiPanel('set', false);

        objRoiPanel = viewRoiPanelMenuObject('get');
        if ~isempty(objRoiPanel)
            objRoiPanel.Checked = 'off';
        end
    end

    if size(im, 3) == 1

        set(btn3DPtr('get')        , 'Enable', 'off');
        set(btnIsoSurfacePtr('get'), 'Enable', 'off');
        set(btnMIPPtr('get')       , 'Enable', 'off');

%         im  = im(:,:);
        im = squeeze(im);
        axesText('set', 'axe', '');

        cla(axePtr('get', [], dSeriesOffset),'reset');

        set(axePtr('get', [], dSeriesOffset) , ...
            'Units'   , 'normalized', ...
            'Position', [0 0 1 1]   , ...
            'Visible' , 'off'       , ...
            'Ydir'    ,'reverse'    , ...
            'XLim'    , [0 inf]     , ...
            'YLim'    , [0 inf]     , ...
            'CLim'    , [lMin lMax] ...
            );
        disableDefaultInteractivity(axePtr('get', [], dSeriesOffset));

        set(axePtr('get', [], dSeriesOffset), 'HitTest', 'off');  % Disable hit testing for axes
        set(axePtr('get', [], dSeriesOffset), 'XLimMode', 'manual', 'YLimMode', 'manual');
        set(axePtr('get', [], dSeriesOffset), 'XMinorTick', 'off', 'YMinorTick', 'off');

        grid(axePtr('get', [], dSeriesOffset), 'off');

        if aspectRatio('get') == true

            x = atMetaData{1}.PixelSpacing(1);
            y = atMetaData{1}.PixelSpacing(2);

            if x == 0
                x=1;
            end

            if y == 0
                y=1;
            end

            daspect(axePtr('get', [], dSeriesOffset) , [x y 1]);
        end

        % Retrieve the current settings
        applyGaussFilter = gaussFilter('get');
        useInterpolation = isInterpolated('get');
        
        % Select the appropriate interpolation method
        interpMethod = 'nearest';
        if useInterpolation
            interpMethod = 'bilinear';
        end
        
        % Apply Gaussian filter if needed
        imData = im;
        if applyGaussFilter
            imData = imgaussfilt(imData);
        end
        
        % Display the image
        imAxe = imshow(imData, ...
                       'Parent', axePtr('get', [], dSeriesOffset), ...
                       'Interpolation', interpMethod);

        % adjAxeCameraViewAngle(axePtr('get', [], dSeriesOffset));
        disableAxesToolbar(axePtr('get', [], dSeriesOffset));

        rightClickMenu('add', imAxe);

        imAxePtr ('set', imAxe , dSeriesOffset);

        set(axePtr('get', [], dSeriesOffset) , 'Visible', 'off');

%               set(axe, 'CLim', [aCLim(1) aCLim(2)]);

 %       getColorMap('init');

        colormap(axePtr('get', [], dSeriesOffset), ...
                 getColorMap('one', colorMapOffset('get')) ...
                );

        % ptrColorbar = ...
        %     colorbar(axesColorbarPtr('get', [], dSeriesOffset)  , ...
        %             'AxisLocation' , 'in', ...
        %             'Tag'          , 'Colorbar', ...
        %             'EdgeColor'    , overlayColor('get'), ...
        %             'Units'        , 'pixels', ...
        %             'Box'          , 'off', ...
        %             'Location'     , 'east', ...
        %             'ButtonDownFcn', @colorbarCallback ...
        %             );
        % 
        % ptrColorbar.TickLabels = [];
        % ptrColorbar.Ticks = [];
        % ptrColorbar.TickLength = 0;
        % ptrColorbar.Interruptible = 'off'; % Prevent interruptions

        ptrColorbar = viewerColorbar(axesColorbarPtr('get', [], dSeriesOffset),  ...
                                    'Colorbar', ...
                                    getColorMap('one', colorMapOffset('get')));

        uiColorbarPtr('set', ptrColorbar);
        colorbarCallback(ptrColorbar); % Fix for Linux
        
        aFigurePosition = ptrColorbar.Parent.Parent.Position;
        if isFusion('get') == true
            set(axesColorbarPtr('get', [], dSeriesOffset), ...
                'Position', [aFigurePosition(3)-48 ...
                             (aFigurePosition(4)/2)-9 ...
                             45 ...
                             (aFigurePosition(4)/2)+5  ...
                             ] ...
                );
        else
            set(axesColorbarPtr('get', [], dSeriesOffset), ...
                'Position', [aFigurePosition(3)-48 ...
                             7 ...
                             45 ...
                             aFigurePosition(4)-11  ...
                             ] ...
                );
        end

        ptrColorbar.Parent.YLabel.Position = [ptrColorbar.Parent.YLabel.Position(1) - 10, ptrColorbar.Parent.YLabel.Position(2), ptrColorbar.Parent.YLabel.Position(3)];       

        tQuant = quantificationTemplate('get');

        sAxeText = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s', ...
            sPatientName, ...
            sPatientID,  ...
            sSeriesDescription, ...
            sSeriesDate, ...
            num2str(tQuant.tCount.dMin), ...
            num2str(tQuant.tCount.dMax), ...
            num2str(tQuant.tCount.dSum));

        uiOneWindow = uiOneWindowPtr('get');

        axAxeText = ...
            uiaxes(uiOneWindow, ...
                 'Units'    , 'pixels', ...
                 'Position' , [5 ...
                               uiOneWindow.Position(4)-getTopWindowSize('ysize')-55-10 ...
                               100 ...
                               200 ...
                               ], ...
                 'Tag'      , 'axAxeText', ...
                 'Box'      , 'off', ...
                 'visible'  , 'off' ...
                 );
        axAxeText.Interactions = [];
        % axAxeText.Toolbar.Visible = 'off';
        disableDefaultInteractivity(axAxeText);
        deleteAxesToolbar(axAxeText);

        tAxeText = ...
            text(axAxeText, ...
                 0, ...
                 0, ...
                 sAxeText, ...
                 'Color' , overlayColor('get') ...
                 );

        if overlayActivate('get') == false
            set(tAxeText, 'Visible', 'off');
        end

        disableAxesToolbar(axAxeText);

        axesText('set', 'axe', tAxeText);

        if aspectRatio('get') == true

            x = atMetaData{1}.PixelSpacing(1);
            y = atMetaData{1}.PixelSpacing(2);
            z = 1;

            if x==0
                x=1;
            end

            if y == 0
                y =1;
            end

            daspect(axePtr('get', [], dSeriesOffset) , [x y z]);
        else
            x =1;
            y =1;
            z =1;

            daspect(axePtr('get', [], dSeriesOffset) , [x y z]);

            axis(axePtr('get', [], dSeriesOffset) , 'normal');
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z);

        if isFusion('get') == true
            alpha(axePtr('get', [], dSeriesOffset), 1-sliderAlphaValue('get'));
        end

        set(axePtr('get', [], dSeriesOffset), 'CLim', [lMin lMax]);

    else

%        set(btn3DPtr('get')        , 'Enable', 'on');
%        set(btnIsoSurfacePtr('get'), 'Enable', 'on');
%        set(btnMIPPtr('get')       , 'Enable', 'on');

        im = squeeze(im);

        sliceNumber('set', 'coronal' , floor(size(im,1)/2));
        sliceNumber('set', 'sagittal', floor(size(im,2)/2));
        sliceNumber('set', 'axial'   , floor(size(im,3)/2));

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );

        iCoronalSize  = size(im,1);
        iSagittalSize = size(im,2);
        iAxialSize    = size(im,3);

        axesText('set', 'axes1', '');
        axesText('set', 'axes1View', '');

        cla(axes1Ptr('get', [], dSeriesOffset) ,'reset');

        set(axes1Ptr('get', [], dSeriesOffset) , ...
            'Units'   , 'normalized', ...
            'Position', [0 0 1 1], ...
            'Visible' , 'off', ...
            'Ydir'    , 'reverse', ...
            'Tag'     , 'axes1', ...
            'XLim'    , [0 inf], ...
            'YLim'    , [0 inf], ...
            'CLim'    , [0 inf] ...
            );
        disableDefaultInteractivity(axes1Ptr('get', [], dSeriesOffset));

        set(axes1Ptr('get', [], dSeriesOffset), 'HitTest', 'off');  % Disable hit testing for axes
        set(axes1Ptr('get', [], dSeriesOffset), 'XLimMode', 'manual', 'YLimMode', 'manual');
        set(axes1Ptr('get', [], dSeriesOffset), 'XMinorTick', 'off', 'YMinorTick', 'off');

        grid(axes1Ptr('get', [], dSeriesOffset), 'off');

        axis(axes1Ptr('get', [], dSeriesOffset) , 'tight');

        if isVsplash('get') == true && ...
           (strcmpi(vSplahView('get'), 'coronal') || ...
            strcmpi(vSplahView('get'), 'all'))

            if strcmpi(vSplahView('get'), 'coronal')
                set(uiCorWindowPtr('get'),  ...
                    'Position', [0 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize') ...
                                 getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                 ] ...
                    );

                 set(uiSliderCorPtr('get'), ...
                     'Position', [0 ...
                                  addOnWidth('get')+30 ...
                                  getMainWindowSize('xsize') ...
                                  20 ...
                                  ] ...
                    );

            else
                set(uiCorWindowPtr('get'),  ...
                    'Position', [0 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/4 ...
                                 getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                 ]...
                   );

                 set(uiSliderCorPtr('get'),  ...
                     'Position', [0 ...
                                  addOnWidth('get')+30 ...
                                  getMainWindowSize('xsize')/4 ...
                                  20 ...
                                  ] ...
                     );
            end

            dVsplashLayoutX = vSplashLayout('get', 'x');
            dVsplashLayoutY = vSplashLayout('get', 'y');

            [lFirst, lLast] = computeVsplashLayout(im, 'coronal', iCoronal);

            imComputed = computeMontage(im, 'coronal', iCoronal);

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the coronal image slice and permute dimensions
            imData = permute(im(iCoronal, :, :), [3, 2, 1]);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData);
            end
            
            % Display the image
            imCoronal = imshow(imData, ...
                               'Parent', axes1Ptr('get', [], dSeriesOffset), ...
                               'Interpolation', interpMethod);


            imCoronalPtr ('set', imCoronal , dSeriesOffset);

%             imComputed = computeMontage(im, 'coronal', iCoronal);

%            imAxSize = size(imCoronal.CData);
%            imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

            imCoronal.CData = imComputed;

            if is3DEngine('get') == true

                xOffset = size(imCoronal.CData,2)/dVsplashLayoutX;
                yOffset = size(imCoronal.CData,1)/dVsplashLayoutY;

                imCoronal.Parent.XLim = [1 size(imCoronal.CData,2)];
                imCoronal.Parent.YLim = [1 size(imCoronal.CData,1)];
            else
                xOffset = imCoronal.XData(2)/dVsplashLayoutX;
                yOffset = imCoronal.YData(2)/dVsplashLayoutY;
            end

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX

                    ptMontageAxes1{iPointerOffset} = ...
                        text(axes1Ptr('get', [], dSeriesOffset), ...
                             ((jj-1)*xOffset)+1, ...
                             ((hh-1)*yOffset)+1, ...
                             sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), ...
                             'Color'       , overlayColor('get') ...
                             );

                    if overlayActivate('get') == false
                        set(ptMontageAxes1{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes1', ptMontageAxes1);

        else
            set(uiCorWindowPtr('get'), ...
                'Position', [0 ...
                             addOnWidth('get')+30+15 ...
                             getMainWindowSize('xsize')/5 ...
                             getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                             ] ...
                );

            set(uiSliderCorPtr('get'), 'Position', ...
                [0 ...
                 addOnWidth('get')+30 ...
                 getMainWindowSize('xsize')/5 ...
                 20] ...
                );

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the coronal image slice and permute dimensions
            imData = permute(im(iCoronal, :, :), [3, 2, 1]);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData);
            end
            
            % Display the image
            imCoronal = imshow(imData, ...
                               'Parent', axes1Ptr('get', [], dSeriesOffset), ...
                               'Interpolation', interpMethod);

%            imCoronal.EraseMode = 'none';
%            imCoronalF.EraseMode = 'none';

            imCoronalPtr ('set', imCoronal , dSeriesOffset);

        end

        % adjAxeCameraViewAngle(axes1Ptr('get', [], dSeriesOffset));

        disableAxesToolbar(axes1Ptr('get', [], dSeriesOffset));

        rightClickMenu('add', imCoronal);

        % linkaxes([axes1Ptr('get', [], dSeriesOffset) axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
        set(axes1Ptr('get', [], dSeriesOffset) , 'Visible', 'off');


%                set(axes1Ptr('get'), 'CLim', [aCLim(1) aCLim(2)]);

%            if crossActivate('get')
%                    hold on
        if isVsplash('get') == false

            alAxes1Line{1} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2 iSagittalSize/2], ...
                 [iAxial+0.5 iAxial-0.5], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{1});

            alAxes1Line{2} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2+0.5 iSagittalSize/2-0.5], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{2});

            alAxes1Line{3} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [0 iSagittalSize/2-crossSize('get')], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{3});

            alAxes1Line{4} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize  /2+crossSize('get') iSagittalSize], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{4});

            alAxes1Line{5} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [0 iAxialSize/2-crossSize('get')], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{5});

            alAxes1Line{6} = line(axes1Ptr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [iAxialSize/2+crossSize('get') iAxialSize], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes1Line{6});

%                    hold off
             axesLine('set', 'axes1', alAxes1Line);
%            end

             for ii1=1:numel(alAxes1Line)
%                  if is3DEngine('get') == true
%                     alAxes1Line{ii1}.ZData = [max(max(get(imCoronal,'Zdata'))) max(max(get(imCoronal,'Zdata')))];
%                  end
                 alAxes1Line{ii1}.Visible = crossActivate('get');
             end
        end

        uiCorWindow = uiCorWindowPtr('get');

        if isVsplash('get') == true

            if strcmpi(vSplahView('get'), 'all')
                
                dExtraYOffset = 0;   
            else                
                dExtraYOffset = -20; 
            end
        else
            dExtraYOffset = 0;                                
        end

        axAxes1Text = ...
            uiaxes(uiCorWindow, ...
                 'Units'    , 'pixels', ...
                 'Position' , [5 ...
                             uiCorWindow.Position(4)-15-20+dExtraYOffset ...
                             70 ...
                             30 ...
                             ], ...
                 'Tag'      , 'axAxes1Text', ...
                 'Box'      , 'off', ...
                 'visible'  , 'off' ...
                 );
        axAxes1Text.Interactions = [];
        delete(axAxes1Text.Toolbar);    
        axAxes1Text.Toolbar = [];
        disableDefaultInteractivity(axAxes1Text);

        if isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'coronal')
            sAxe1Text = sprintf('\n%s\n%s\n%s\n%s\nC:%s-%s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sSeriesDate, ...
                            num2str(lFirst), ...
                            num2str(lLast), ...
                            size(dicomBuffer('get'), 1) ...
                            );

            tAxes1Text = text(axAxes1Text, ...
                              0, ...
                              0, ...
                              sAxe1Text, ...
                              'Color', overlayColor('get') ...
                              );

        elseif isVsplash('get') == true && ...
               strcmpi(vSplahView('get'), 'all')
            tAxes1Text  = text(axAxes1Text, ...
                               0, ...
                               0, ...
                               ['C:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 1))], ...
                               'Color', overlayColor('get') ...
                               );
        else
            tAxes1Text  = text(axAxes1Text, ...
                               0, ...
                               0, ...
                               ['C:' num2str(sliceNumber('get', 'coronal' )) '/' num2str(size(dicomBuffer('get'), 1))] , ...
                               'Color', overlayColor('get') ...
                               );

             axAxes1View = ...
                axes(uiCorWindow, ...
                       'Units'   , 'normalized', ...
                       'xlimmode', 'manual',...
                       'ylimmode', 'manual',...
                       'zlimmode', 'manual',...
                       'climmode', 'manual',...
                       'alimmode', 'manual',...
                       'Position', [0 0 1 1], ...
                       'Visible' , 'off',...
                       'Tag'     , 'axAxes1View', ...
                       'Box'     , 'off', ...
                       'HandleVisibility', 'off' ...
                       );
            axAxes1View.Interactions = [];
            % axAxes1View.Toolbar.Visible = 'off';
            deleteAxesToolbar(axAxes1View);
            disableDefaultInteractivity(axAxes1View);

            tAxes1View = text(axAxes1View, 0.03, 0.46, 'Right', 'Color', overlayColor('get'), 'Rotation', 270);
            if overlayActivate('get') == false
                set(tAxes1View, 'Visible', 'off');
            end

            disableAxesToolbar(axAxes1View); % Protection in case th toobar is automatically recreated. 

            axesText('set', 'axes1View', tAxes1View);
        end

        if overlayActivate('get') == false
            set(tAxes1Text, 'Visible', 'off');
        end

        disableAxesToolbar(axAxes1Text); % Protection in case th toobar is automatically recreated.

        axesText('set', 'axes1', tAxes1Text);

        axesText('set', 'axes2', '');
        axesText('set', 'axes2View', '');

        cla(axes2Ptr('get', [], dSeriesOffset) ,'reset');

        set(axes2Ptr('get', [], dSeriesOffset) , ...
            'Units'   , 'normalized', ...
            'Position', [0 0 1 1], ...
            'Visible' , 'off', ...
            'Ydir'    , 'reverse', ...
            'Tag'     , 'axes2', ...
            'XLim'    , [0 inf], ...
            'YLim'    , [0 inf], ...
            'CLim'    , [0 inf] ...
            );
        disableDefaultInteractivity(axes2Ptr('get', [], dSeriesOffset));

        set(axes2Ptr('get', [], dSeriesOffset), 'HitTest', 'off');  % Disable hit testing for axes
        set(axes2Ptr('get', [], dSeriesOffset), 'XLimMode', 'manual', 'YLimMode', 'manual');
        set(axes2Ptr('get', [], dSeriesOffset), 'XMinorTick', 'off', 'YMinorTick', 'off');

        grid(axes2Ptr('get', [], dSeriesOffset), 'off');

        axis(axes2Ptr('get', [], dSeriesOffset) , 'tight');

        if isVsplash('get') == true && ...
           (strcmpi(vSplahView('get'), 'sagittal') || ...
            strcmpi(vSplahView('get'), 'all'))

            if strcmpi(vSplahView('get'), 'sagittal')
                set(uiSagWindowPtr('get'),  ...
                    'Position',[0 ...
                                addOnWidth('get')+30+15 ...
                                getMainWindowSize('xsize') ...
                                getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                ] ...
                    );

                 set(uiSliderSagPtr('get'), ...
                     'Position', [0 ...
                                  addOnWidth('get')+30 ...
                                  getMainWindowSize('xsize') ...
                                  20 ...
                                  ] ...
                     );

            else
                set(uiSagWindowPtr('get'), ...
                    'Position', [getMainWindowSize('xsize')/4 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/4 ...
                                 getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                 ]...
                   );

                 set(uiSliderSagPtr('get'), 'Position', ...
                     [getMainWindowSize('xsize')/4 ...
                      addOnWidth('get')+30 ...
                      getMainWindowSize('xsize')/4 ...
                      20] ...
                    );
            end

            dVsplashLayoutX = vSplashLayout('get', 'x');
            dVsplashLayoutY = vSplashLayout('get', 'y');

            [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', iSagittal);

            imComputed = computeMontage(im, 'sagittal', iSagittal);

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the sagittal image slice and permute dimensions
            imData = permute(im(:, iSagittal, :), [3, 1, 2]);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData);
            end
            
            % Display the image
            imSagittal = imshow(imData, ...
                                'Parent', axes2Ptr('get', [], dSeriesOffset), ...
                                'Interpolation', interpMethod);

            
            imSagittalPtr ('set', imSagittal , dSeriesOffset);

%             imComputed = computeMontage(im, 'sagittal', iSagittal);

%            imAxSize = size(imSagittal.CData);
%            imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

            imSagittal.CData = imComputed;

            if is3DEngine('get') == true

                xOffset = size(imSagittal.CData,2)/dVsplashLayoutX;
                yOffset = size(imSagittal.CData,1)/dVsplashLayoutY;

                imSagittal.Parent.XLim = [1 size(imSagittal.CData,2)];
                imSagittal.Parent.YLim = [1 size(imSagittal.CData,1)];
            else
                xOffset = imSagittal.XData(2)/dVsplashLayoutX;
                yOffset = imSagittal.YData(2)/dVsplashLayoutY;
            end


            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX

                    ptMontageAxes2{iPointerOffset} = ...
                        text(axes2Ptr('get', [], dSeriesOffset), ...
                             ((jj-1)*xOffset)+1 , ...
                             ((hh-1)*yOffset)+1 , ...
                             sprintf('\n%s' , ...
                             num2str(lFirst+iPointerOffset-1)), ...
                             'Color', overlayColor('get') ...
                             );

                    if overlayActivate('get') == false
                        set(ptMontageAxes2{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes2', ptMontageAxes2);

        else
            set(uiSagWindowPtr('get'),  ...
                'Position', [getMainWindowSize('xsize')/5 ...
                             addOnWidth('get')+30+15 ...
                             getMainWindowSize('xsize')/5 ...
                             getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                             ]...
                );

             set(uiSliderSagPtr('get'), ...
                 'Position', [getMainWindowSize('xsize')/5 ...
                              addOnWidth('get')+30 ...
                              getMainWindowSize('xsize')/5 ...
                              20 ...
                              ] ...
                 );


            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the sagittal image slice and permute dimensions
            imData = permute(im(:, iSagittal, :), [3, 1, 2]);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData, 1);
            end
            
            % Display the image
            imSagittal = imshow(imData, ...
                                'Parent', axes2Ptr('get', [], dSeriesOffset), ...
                                'Interpolation', interpMethod);

            imSagittalPtr ('set', imSagittal , dSeriesOffset);
        end

        % adjAxeCameraViewAngle(axes2Ptr('get', [], dSeriesOffset));
       
        disableAxesToolbar(axes2Ptr('get', [], dSeriesOffset));

        rightClickMenu('add', imSagittal);

        set(axes2Ptr('get', [], dSeriesOffset) , 'Visible', 'off');
%              if crossActivate('get')
%                    hold on
        if isVsplash('get') == false

            alAxes2Line{1} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [iCoronalSize/2 iCoronalSize/2], ...
                 [iAxial+0.5 iAxial-0.5], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{1});

            alAxes2Line{2} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [iCoronalSize/2+0.5 iCoronalSize/2-0.5], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{2});

            alAxes2Line{3} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [0 iCoronalSize/2-crossSize('get')], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{3});

            alAxes2Line{4} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [iCoronalSize/2+crossSize('get') iCoronalSize], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{4});

            alAxes2Line{5} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [iCoronal iCoronal], ...
                 [0 iAxialSize/2-crossSize('get')], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{5});

            alAxes2Line{6} = line(axes2Ptr('get', [], dSeriesOffset), ...
                 [iCoronal iCoronal], ...
                 [iAxialSize/2+crossSize('get') iAxialSize], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes2Line{6});

            axesLine('set', 'axes2', alAxes2Line);

             for ii2=1:numel(alAxes2Line)
%                 if is3DEngine('get') == true
%                     alAxes2Line{ii2}.ZData = [max(max(get(imSagittal,'Zdata'))) max(max(get(imSagittal,'Zdata')))];
%                 end
                alAxes2Line{ii2}.Visible = crossActivate('get');
             end
        end
%                    hold off
%              end

        uiSagWindow = uiSagWindowPtr('get');

        if isVsplash('get') == true

            if strcmpi(vSplahView('get'), 'all')
                
                dExtraYOffset = 0;   
            else                
                dExtraYOffset = -20; 
            end
        else
            dExtraYOffset = 0;                                
        end

        axAxes2Text = ...
            uiaxes(uiSagWindow, ...
                 'Units'   , 'pixels', ...
                 'Position', [5 ...
                             uiSagWindow.Position(4)-15-20+dExtraYOffset ... 
                             70 ...
                             30], ...
                 'Tag'     , 'axAxes2Text', ...
                 'Box'     , 'off', ...
                 'visible' , 'off' ...
                 );
        axAxes2Text.Interactions = [];
        % axAxes2Text.Toolbar.Visible = 'off';
        disableDefaultInteractivity(axAxes2Text);
        delete(axAxes2Text.Toolbar);
        axAxes2Text.Toolbar = [];

        if isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'sagittal')
            sAxe2Text  = sprintf('\n%s\n%s\n%s\n%s\nS:%s-%s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sSeriesDate, ...
                            num2str(lFirst), ...
                            num2str(lLast), ...
                            size(dicomBuffer('get'), 2) ...
                            );
            ptAxes2Text = text(axAxes2Text, 0, 0, sAxe2Text, 'Color', overlayColor('get'));
        elseif isVsplash('get') == true && ...
               strcmpi(vSplahView('get'), 'all')
            ptAxes2Text = text(axAxes2Text, ...
                               0, ...
                               0, ...
                               ['S:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 2))], ...
                               'Color', overlayColor('get') ...
                               );
        else
            ptAxes2Text = text(axAxes2Text, ...
                               0, ...
                               0, ...
                               ['S:' num2str(sliceNumber('get', 'sagittal')) '/' num2str(size(dicomBuffer('get'), 2))], ...
                               'Color', overlayColor('get') ...
                               );
             axAxes2View = ...
                axes(uiSagWindow, ...
                     'Units'   ,'normalized', ...
                     'xlimmode','manual',...
                     'ylimmode','manual',...
                     'zlimmode','manual',...
                     'climmode','manual',...
                     'alimmode','manual',...
                     'Position', [0 0 1 1], ...
                     'Visible' , 'off',...
                     'Tag'     , 'axAxes2View', ...
                     'Box'     , 'off', ...
                     'HandleVisibility', 'off' ...
                     );
            axAxes2View.Interactions = [];
            % axAxes2View.Toolbar.Visible = 'off';
            disableDefaultInteractivity(axAxes2View);
            deleteAxesToolbar(axAxes2View);                            

            tAxes2View = text(axAxes2View, 0.03, 0.46, 'Anterior', 'Color', overlayColor('get'), 'Rotation', 270);
            if overlayActivate('get') == false
                set(tAxes2View, 'Visible', 'off');
            end

            disableAxesToolbar(axAxes2View); % Protection in case th toobar is automatically recreated. 

            axesText('set', 'axes2View', tAxes2View);
        end

        if overlayActivate('get') == false
            set(ptAxes2Text, 'Visible', 'off');
        end
               
        disableAxesToolbar(axAxes2Text); % Protection in case th toobar is automatically recreated.

        axesText('set', 'axes2', ptAxes2Text);

        % Axe 3

        axesText('set', 'axes3', '');
        axesText('set', 'axes3View', '');

        cla(axes3Ptr('get', [], dSeriesOffset) ,'reset');
        
        % Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);            

        set(axes3Ptr('get', [], dSeriesOffset) , ...
            'Units'   , 'normalized', ...
            'Position', [0 0 1 1], ...
            'Visible' , 'off', ...
            'Ydir'    , 'reverse', ...
            'Tag'     , 'axes3', ...
            'XLim'    , [0 inf], ...
            'YLim'    , [0 inf], ...
            'CLim'    , [0 inf] ...
            );
        set(axes3Ptr('get', [], dSeriesOffset), 'HitTest', 'off');  % Disable hit testing for axes
        set(axes3Ptr('get', [], dSeriesOffset), 'XLimMode', 'manual', 'YLimMode', 'manual');
        set(axes3Ptr('get', [], dSeriesOffset), 'XMinorTick', 'off', 'YMinorTick', 'off');

        grid(axes3Ptr('get', [], dSeriesOffset), 'off');

        axis(axes3Ptr('get', [], dSeriesOffset) , 'tight');

        if isVsplash('get') == true && ...
           (strcmpi(vSplahView('get'), 'axial') || ...
            strcmpi(vSplahView('get'), 'all'))

            if strcmpi(vSplahView('get'), 'axial')
                set(uiTraWindowPtr('get'), ...
                    'Position', [0 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize') ...
                                 getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                 ]...
                    );

                 set(uiSliderTraPtr('get'), ...
                     'Position', [0 ...
                                  addOnWidth('get')+30 ...
                                  getMainWindowSize('xsize') ...
                                  20 ...
                                  ] ...
                     );

            else
                set(uiTraWindowPtr('get'), ...
                    'Position', [(getMainWindowSize('xsize')/2) ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/2 ...
                                 getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15 ...
                                 ]...
                    );

                 set(uiSliderTraPtr('get'), ...
                     'Position', [(getMainWindowSize('xsize')/2) ...
                                  addOnWidth('get')+30 ...
                                  getMainWindowSize('xsize')/2 ...
                                  20 ...
                                  ] ...
                     );
            end

            dVsplashLayoutX = vSplashLayout('get', 'x');
            dVsplashLayoutY = vSplashLayout('get', 'y');

            imComputed = computeMontage(im(:,:,end:-1:1), ...
                                        'axial', ...
                                        size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1 ...
                                        );

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the image slice
            imData = im(:, :, iAxial);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData, 1);
            end
            
            % Display the image
            imAxial = imshow(imData, ...
                             'Parent', axes3Ptr('get', [], dSeriesOffset), ...
                             'Interpolation', interpMethod);


            imAxialPtr ('set', imAxial , dSeriesOffset);

%             imComputed = computeMontage(im(:,:,end:-1:1), ...
%                                         'axial', ...
%                                         size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1 ...
%                                         );

%            imAxSize = size(imAxial.CData);
%            imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

            imAxial.CData = imComputed;

            [lFirst, ~] = computeVsplashLayout(im, ...
                                               'axial', ...
                                               size(dicomBuffer('get'), 3)-iAxial+1 ...
                                               );
            if is3DEngine('get') == true

                xOffset = size(imAxial.CData,2)/dVsplashLayoutX;
                yOffset = size(imAxial.CData,1)/dVsplashLayoutY;

                imAxial.Parent.XLim = [1 size(imAxial.CData,2)];
                imAxial.Parent.YLim = [1 size(imAxial.CData,1)];
            else
                xOffset = imAxial.XData(2)/dVsplashLayoutX;
                yOffset = imAxial.YData(2)/dVsplashLayoutY;
            end

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes3{iPointerOffset} = ...
                        text(axes3Ptr('get', [], dSeriesOffset), ...
                             ((jj-1)*xOffset)+1 , ...
                             ((hh-1)*yOffset)+1 , ...
                             sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), ...
                             'Color', overlayColor('get') ...
                             );

                    if overlayActivate('get') == false
                        set(ptMontageAxes3{iPointerOffset}, 'Visible', 'off');
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes3', ptMontageAxes3);

        else

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation
                interpMethod = 'bilinear';
            end
            
            % Extract the image slice
            imData = im(:, :, iAxial);
            
            % Apply Gaussian filter if needed
            if applyGaussFilter
                imData = imgaussfilt(imData);
            end
            
            % Display the image
            imAxial = imshow(imData, ...
                             'Parent', axes3Ptr('get', [], dSeriesOffset), ...
                             'Interpolation', interpMethod);


            imAxialPtr ('set', imAxial , dSeriesOffset);

        end

        % adjAxeCameraViewAngle(axes3Ptr('get', [], dSeriesOffset));
        
        disableAxesToolbar(axes3Ptr('get', [], dSeriesOffset));

        rightClickMenu('add', imAxial );

        set(axes3Ptr('get', [], dSeriesOffset), 'Visible', 'off');

        if isVsplash('get') == false
%                if crossActivate('get')
%                    hold on
            alAxes3Line{1} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2 iSagittalSize/2], ...
                 [iCoronal+0.5 iCoronal-0.5], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{1});

            alAxes3Line{2} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2+0.5 iSagittalSize/2-0.5], ...
                 [iCoronal iCoronal], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{2});

            alAxes3Line{3} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [0 iSagittalSize/2-crossSize('get')], ...
                 [iCoronal iCoronal], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{3});

            alAxes3Line{4} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2+crossSize('get') iSagittalSize], ...
                 [iCoronal iCoronal], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{4});

            alAxes3Line{5} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [0 iCoronalSize/2-crossSize('get')], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{5});

            alAxes3Line{6} = line(axes3Ptr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [iCoronalSize/2+crossSize('get') iCoronalSize], ...
                 'Color', crossColor('get'));

            rightClickMenu('add', alAxes3Line{6});

            axesLine('set', 'axes3', alAxes3Line);

%                    hold off
%                end

             for ii3=1:numel(alAxes3Line)
%                 if is3DEngine('get') == true
%                     alAxes3Line{ii3}.ZData = [max(max(get(imAxial,'Zdata'))) max(max(get(imAxial,'Zdata')))];
%                 end
                alAxes3Line{ii3}.Visible = crossActivate('get');
             end
        end

        atInputTemplate = inputTemplate('get');

        if atInputTemplate(dSeriesOffset).bDoseKernel == true

            dExtraYOffset = 10;                                  
        else
            
            switch lower(atMetaData{1}.Modality)

                case {'pt', 'nm'}

                    sUnit = getSerieUnitValue(dSeriesOffset);

                    if strcmpi(sUnit, 'SUV')
                        
                        dExtraYOffset = 20;


                    else
                        dExtraYOffset = 15;

                    end

                case 'ct'

                    dExtraYOffset = 0;

                case 'mr'
                     dExtraYOffset = 5;

                otherwise

                    dExtraYOffset = 0;                    
            end

            if viewerUIFigure('get') == false && ... 
               isMATLABReleaseOlderThan('R2025a')

                dExtraYOffset = dExtraYOffset + 5;
            end            
        end
        
        if isVsplash('get') == true

            if strcmpi(vSplahView('get'), 'all')

                 dExtraYOffset = -40; 
            else
                dExtraYOffset = -20; 
           end
        end

        uiTraWindow = uiTraWindowPtr('get');

        axAxes3Text = ...
            uiaxes(uiTraWindow, ...
                 'Units'   , 'pixels', ...
                 'Position', [25 ...
                              uiTraWindow.Position(4)-getTopWindowSize('ysize')-55-dExtraYOffset ...
                              100 ...
                              200 ...
                              ], ...
                 'Tag'     , 'axAxes3Text', ...
                 'Box'     , 'off', ...
                 'visible' , 'off' ...
                 );
        axAxes3Text.Interactions = [];
        % axAxes3Text.Toolbar.Visible = 'off';
        disableDefaultInteractivity(axAxes3Text);
        deleteAxesToolbar(axAxes3Text);                

        if isVsplash('get') == true && ...
           (strcmpi(vSplahView('get'), 'axial') || ...
            strcmpi(vSplahView('get'), 'all'))
            [lFirst, lLast] = computeVsplashLayout(im, ...
                                                   'axial', ...
                                                   size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1 ...
                                                   );

            sAxe3Text = sprintf('\n%s\n%s\n%s\n%s\nA:%s-%s/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sSeriesDate, ...
                            num2str(lFirst), ...
                            num2str(lLast), ...
                            size(dicomBuffer('get'), 3) ...
                            );
        else
            sAxe3Text = sprintf('\n%s\n%s\n%s\n%s\nA:%d/%d', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...
                            sSeriesDate, ...
                            sliceNumber('get', 'axial'), ...
                            size(dicomBuffer('get'), 3) ...
                            );

            axAxes3View = ...
                axes(uiTraWindow, ...
                     'Units'   , 'normalized', ...
                     'xlimmode', 'manual',...
                     'ylimmode', 'manual',...
                     'zlimmode', 'manual',...
                     'climmode', 'manual',...
                     'alimmode', 'manual',...
                     'Position', [0 0 0.90 1], ...
                     'Visible' , 'off',...
                     'Tag'     , 'axAxes3View', ...
                     'Box'     , 'off', ...
                     'HandleVisibility', 'off' ...
                     );
            axAxes3View.Interactions = [];
            % axAxes3View.Toolbar.Visible = 'off';
            disableDefaultInteractivity(axAxes3View);
            deleteAxesToolbar(axAxes3View);                

            tAxes3View{1} = text(axAxes3View, 0.46, 0.08, 'Posterior', 'Color', overlayColor('get'));
            tAxes3View{2} = text(axAxes3View, 0.03, 0.46, 'Right', 'Color', overlayColor('get'),'Rotation', 270);

            if overlayActivate('get') == false

                for tt=1:numel(tAxes3View)

                    set(tAxes3View{tt}, 'Visible', 'off');
                end
            end

            axesText('set', 'axes3View', tAxes3View);

            disableAxesToolbar(axAxes3View); % Protection in case th toobar is automatically recreated. 

        end

        tAxes3Text  = text(axAxes3Text, 0, 0, sAxe3Text, 'Color', overlayColor('get'));
        if overlayActivate('get') == false
            set(tAxes3Text, 'Visible', 'off');
        end

        disableAxesToolbar(axAxes3Text); % Protection in case th toobar is automatically recreated.

        axesText('set', 'axes3', tAxes3Text);

        axesText('set', 'axesMip', ''); % Set 2D MIP

        cla(axesMipPtr ('get', [], dSeriesOffset),'reset');

        set(axesMipPtr('get', [], dSeriesOffset) , ...
            'Units'   , 'normalized', ...
            'Position', [0 0 1 1], ...
            'Visible' , 'off', ...
            'Ydir'    , 'reverse', ...
            'Tag'     , 'axesMip', ...
            'XLim'    , [0 inf], ...
            'YLim'    , [0 inf], ...
            'CLim'    , [0 inf] ...
            );
        disableDefaultInteractivity(axesMipPtr ('get', [], dSeriesOffset));

        set(axesMipPtr('get', [], dSeriesOffset), 'HitTest', 'off');  % Disable hit testing for axes
        set(axesMipPtr('get', [], dSeriesOffset), 'XLimMode', 'manual', 'YLimMode', 'manual');
        set(axesMipPtr('get', [], dSeriesOffset), 'XMinorTick', 'off', 'YMinorTick', 'off');

        grid(axesMipPtr('get', [], dSeriesOffset), 'off');

        axis(axesMipPtr('get', [], dSeriesOffset) , 'tight');

        if isVsplash('get') == false

            iMipAngle = mipAngle('get');

            imComputedMip  = mipBuffer('get', [], dSeriesOffset);

            applyGaussFilter = gaussFilter('get');
            useInterpolation = isInterpolated('get');
            
            % Select the appropriate interpolation method
            interpMethod = 'nearest';
            if useInterpolation

                interpMethod = 'bilinear';
            end
            
            % Extract and optionally filter the image
            imData = permute(imComputedMip(iMipAngle, :, :), [3, 2, 1]);
            if applyGaussFilter

                imData = imgaussfilt(imData);
            end
            
            % Display the image
            imMip = imshow(imData, ...
                           'Parent', axesMipPtr('get', [], dSeriesOffset), ...
                           'Interpolation', interpMethod);


            % adjAxeCameraViewAngle(axesMipPtr('get', [], dSeriesOffset));
            disableAxesToolbar(axesMipPtr('get', [], dSeriesOffset));
        
            imMipPtr ('set', imMip , dSeriesOffset);

            % linkaxes([axesMipPtr('get', [], dSeriesOffset) axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
            set(axesMipPtr('get', [], dSeriesOffset) , 'Visible', 'off');

            alAxesMipLine{1} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2 iSagittalSize/2], ...
                 [iAxial+0.5 iAxial-0.5], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{1});

            alAxesMipLine{2} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [iSagittalSize/2+0.5 iSagittalSize/2-0.5], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{2});

            alAxesMipLine{3} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [0 iSagittalSize/2-crossSize('get')], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{3});

            alAxesMipLine{4} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [iSagittalSize  /2+crossSize('get') iSagittalSize], ...
                 [iAxial iAxial], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{4});

            alAxesMipLine{5} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [0 iAxialSize/2-crossSize('get')], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{5});

            alAxesMipLine{6} = line(axesMipPtr('get', [], dSeriesOffset), ...
                 [iSagittal iSagittal], ...
                 [iAxialSize/2+crossSize('get') iAxialSize], ...
                 'Color', crossColor('get'));

            % rightClickMenu('add', alAxesMipLine{6});

            axesLine('set', 'axesMip', alAxesMipLine);

            for iiMip=1:numel(alAxesMipLine)
%                 if is3DEngine('get') == true
%                     alAxesMipLine{iiMip}.ZData = [max(max(get(imSagittal,'Zdata'))) max(max(get(imSagittal,'Zdata')))];
%                 end
                alAxesMipLine{iiMip}.Visible = crossActivate('get');
            end

            uiMipWindow = uiMipWindowPtr('get');

            axAxesMipText = ...
                uiaxes(uiMipWindow, ...
                     'Units'   , 'pixels', ...
                     'Position', [5 ...
                                  uiMipWindow.Position(4)-5-30 ...
                                  70 ...
                                  30 ...
                                  ], ...
                     'Tag'     , 'axAxesMipText', ...
                     'Box'     , 'off', ...
                     'visible' , 'off' ...
                     );
            axAxesMipText.Interactions = [];
            % axAxesMipText.Toolbar.Visible = 'off';
            disableDefaultInteractivity(axAxesMipText);
            deleteAxesToolbar(axAxesMipText);

            sAxeMipText = sprintf('\n%d/32', iMipAngle);

            tAxesMipText  = text(axAxesMipText, 0, 0, sAxeMipText, 'Color', overlayColor('get'));
            if overlayActivate('get') == false
                set(tAxesMipText, 'Visible', 'off');
            end

            axesText('set', 'axesMip', tAxesMipText);

            axAxesMipView = ...
                axes(uiMipWindow, ...
                     'Units'   ,'normalized', ...
                     'xlimmode','manual',...
                     'ylimmode','manual',...
                     'zlimmode','manual',...
                     'climmode','manual',...
                     'alimmode','manual',...
                     'Position', [0 0 1 1], ...
                     'Visible' , 'off',...
                     'Tag'     , 'axAxesMipView', ...
                     'Box'     , 'off', ...
                     'HandleVisibility', 'off' ...
                     );
            axAxesMipView.Interactions = [];
            %axAxesMipView.Toolbar.Visible = 'off';
            disableDefaultInteractivity(axAxesMipView);
            deleteAxesToolbar(axAxesMipView);

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

            tAxesMipView = text(axAxesMipView, 0.97, 0.46, sMipAngleView, 'Color', overlayColor('get'), 'Rotation', 270);
            if overlayActivate('get') == false
                set(tAxesMipView, 'Visible', 'off');
            end
            
            axesText('set', 'axesMipView', tAxesMipView);

            disableAxesToolbar(axAxesMipText);
            disableAxesToolbar(axAxesMipView);
        end

        if isVsplash('get') == true

            if is3DEngine('get') == false

                aAxeXLim = get(axes1Ptr('get', [], dSeriesOffset), 'XLim');
                aAxeYLim = get(axes1Ptr('get', [], dSeriesOffset), 'YLim');
                set(axes1Ptr('get', [], dSeriesOffset), 'XLim', [aAxeXLim(1) aAxeXLim(2)*dVsplashLayoutX]);
                set(axes1Ptr('get', [], dSeriesOffset), 'YLim', [aAxeYLim(1) aAxeYLim(2)*dVsplashLayoutY]);

                aAxeXLim = get(axes2Ptr('get', [], dSeriesOffset), 'XLim');
                aAxeYLim = get(axes2Ptr('get', [], dSeriesOffset), 'YLim');
                set(axes2Ptr('get', [], dSeriesOffset), 'XLim', [aAxeXLim(1) aAxeXLim(2)*dVsplashLayoutX]);
                set(axes2Ptr('get', [], dSeriesOffset), 'YLim', [aAxeYLim(1) aAxeYLim(2)*dVsplashLayoutY]);

                aAxeXLim = get(axes3Ptr('get', [], dSeriesOffset), 'XLim');
                aAxeYLim = get(axes3Ptr('get', [], dSeriesOffset), 'YLim');
                set(axes3Ptr('get', [], dSeriesOffset), 'XLim', [aAxeXLim(1) aAxeXLim(2)*dVsplashLayoutX]);
                set(axes3Ptr('get', [], dSeriesOffset), 'YLim', [aAxeYLim(1) aAxeYLim(2)*dVsplashLayoutY]);
            end
        end

        if aspectRatio('get') == true

            atCoreMetaData = dicomMetaData('get');

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


 %          if strcmp(imageOrientation('get'), 'axial')

            daspect(axes1Ptr('get', [], dSeriesOffset), [z y x]);
            daspect(axes2Ptr('get', [], dSeriesOffset), [z x y]);
            daspect(axes3Ptr('get', [], dSeriesOffset), [x y z]);

            if isVsplash('get') == false
                daspect(axesMipPtr('get', [], dSeriesOffset), [z y x]);
            end

%            elseif strcmp(imageOrientation('get'), 'coronal')

%                daspect(axes1Ptr  ('get', [], dSeriesOffset), [x y z]);
%                daspect(axes2Ptr  ('get', [], dSeriesOffset), [y z x]);
%                daspect(axes3Ptr  ('get', [], dSeriesOffset), [z x y]);
%                daspect(axesMipPtr('get', [], dSeriesOffset), [x y z]);

%            elseif strcmp(imageOrientation('get'), 'sagittal')

%                daspect(axes1Ptr  ('get', [], dSeriesOffset), [y x z]);
%                daspect(axes2Ptr  ('get', [], dSeriesOffset), [x z y]);
%                daspect(axes3Ptr  ('get', [], dSeriesOffset), [z x y]);
%                daspect(axesMipPtr('get', [], dSeriesOffset), [x z y]);
%           end
        else
            x =1;
            y =1;
            z =1;

            daspect(axes1Ptr('get', [], dSeriesOffset), [z x y]);
            daspect(axes2Ptr('get', [], dSeriesOffset), [z y x]);
            daspect(axes3Ptr('get', [], dSeriesOffset), [x y z]);
            if isVsplash('get') == false
                daspect(axesMipPtr('get', [], dSeriesOffset), [z y x]);
            end

            axis(axes1Ptr('get', [], dSeriesOffset), 'normal');
            axis(axes2Ptr('get', [], dSeriesOffset), 'normal');
            axis(axes3Ptr('get', [], dSeriesOffset), 'normal');

            if isVsplash('get') == false

                axis(axesMipPtr('get', [], dSeriesOffset), 'normal');
            end
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z);

        % Need to clear some space for the colorbar
        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')

            if strcmpi(vSplahView('get'), 'coronal')
                set(axes1Ptr( 'get', [], dSeriesOffset)     , 'Position', [0 0 0.9000 1]);
            elseif strcmpi(vSplahView('get'), 'sagittal')
                set(axes2Ptr('get', [], dSeriesOffset)     , 'Position', [0 0 0.9000 1]);
            else
                set(axes3Ptr('get', [], dSeriesOffset)     , 'Position', [0 0 0.9000 1]);
            end
        else
            set(axes3Ptr('get', [], dSeriesOffset)      , 'Position', [0 0 0.9000 1]);
        end

%        set(axes3Ptr('get') , 'XLim', [(axes3.XLim(2)*0.15) inf]);
%        set(axes3fPtr('get'), 'XLim', [(axes3f.XLim(2)*0.15) inf]);

   %     getColorMap('init');

        colormap(axes1Ptr('get', [], dSeriesOffset)  , getColorMap('one', colorMapOffset('get')));
        colormap(axes2Ptr('get', [], dSeriesOffset)  , getColorMap('one', colorMapOffset('get')));
        colormap(axes3Ptr('get', [], dSeriesOffset)  , getColorMap('one', colorMapOffset('get')));

        if isVsplash('get') == false

            colormap(axesMipPtr('get', [], dSeriesOffset), getColorMap('one', colorMapOffset('get')));
        end

         % if isVsplash('get') == true && ...
         %    ~strcmpi(vSplahView('get'), 'all')
         %    if strcmpi(vSplahView('get'), 'coronal')
         %        ptrColorbar = ...
         %            colorbar(axesColorbarPtr('get', [], dSeriesOffset), ...
         %                     'AxisLocation' , 'in', ...
         %                     'Tag'          , 'Colorbar', ...
         %                     'EdgeColor'    , overlayColor('get'), ...
         %                     'Units'        , 'pixels', ...
         %                     'Box'          , 'off', ...
         %                     'Location'     , 'east', ...
         %                     'ButtonDownFcn', @colorbarCallback ...
         %                     );
         %    elseif strcmpi(vSplahView('get'), 'sagittal')
         %        ptrColorbar = ...
         %            colorbar(axesColorbarPtr('get', [], dSeriesOffset), ...
         %                     'AxisLocation' , 'in', ...
         %                     'Tag'          , 'Colorbar', ...
         %                     'EdgeColor'    , overlayColor('get'), ...
         %                     'Units'        , 'pixels', ...
         %                     'Box'          , 'off', ...
         %                     'Location'     , 'east', ...
         %                     'ButtonDownFcn', @colorbarCallback ...
         %                     );
         %    else
         %        ptrColorbar = ...
         %            colorbar(axesColorbarPtr('get', [], dSeriesOffset), ...
         %                     'AxisLocation' , 'in', ...
         %                     'Tag'          , 'Colorbar', ...
         %                     'EdgeColor'    , overlayColor('get'), ...
         %                     'Units'        , 'pixels', ...
         %                     'Box'          , 'off', ...
         %                     'Location'     , 'east', ...
         %                     'ButtonDownFcn', @colorbarCallback ...
         %                     );
         %    end
         % else
         %    % axesColorbar = ...
         %    %     axes(uiTraWindowPtr('get'), ...
         %    %            'Units'   , 'normalized', ...
         %    %            'Position', [0 0 1 1], ...
         %    %            'Visible' , 'off', ...
         %    %            'Ydir'    , 'reverse', ...
         %    %            'Tag'     , 'axesColorbar', ...
         %    %            'XLim'    , [0 inf], ...
         %    %            'YLim'    , [0 inf], ...
         %    %            'CLim'    , [0 inf] ...
         %    %          );
         %    % axesColorbar.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
         %    % axesColorbar.Toolbar.Visible = 'off';
         %    % % axes3Ptr('set', axes3, get(uiSeriesPtr('get'), 'Value'));
         %    % disableDefaultInteractivity(axesColorbar);
         % 
         %    ptrColorbar = ...
         %        colorbar(axesColorbarPtr('get', [], dSeriesOffset), ...
         %                 'AxisLocation' , 'in', ...
         %                 'Tag'          , 'Colorbar', ...
         %                 'EdgeColor'    , overlayColor('get'), ...
         %                 'Units'        , 'pixels', ...
         %                 'Box'          , 'off', ...
         %                 'Location'     , 'east', ...
         %                 'ButtonDownFcn', @colorbarCallback ...
         %                 );
         % end


         % ptrColorbar.TickLabels = [];
         % ptrColorbar.Ticks = [];
         % ptrColorbar.TickLength = 0;
         % ptrColorbar.Interruptible = 'off';
         
        ptrColorbar = viewerColorbar(axesColorbarPtr('get', [], dSeriesOffset),  ...
                                     'Colorbar', ...
                                     getColorMap('one', colorMapOffset('get')));

         uiColorbarPtr('set', ptrColorbar);
         colorbarCallback(ptrColorbar); % Fix for Linux

         aAxePosition = ptrColorbar.Parent.Parent.Position;
         if isFusion('get') == true
            set(axesColorbarPtr('get', [], dSeriesOffset), ...
                'Position', [aAxePosition(3)-48 ...
                             (aAxePosition(4)/2) ...
                             45 ...
                             (aAxePosition(4)/2)-4 ...
                             ] ...
                );
         else
            set(axesColorbarPtr('get', [], dSeriesOffset), ...
                'Position', [aAxePosition(3)-48 ...
                             7 ...
                             45 ...
                             aAxePosition(4)-11 ...
                             ] ...
               );
         end
       
         ptrColorbar.Parent.YLabel.Position = [ptrColorbar.Parent.YLabel.Position(1) - 10, ptrColorbar.Parent.YLabel.Position(2), ptrColorbar.Parent.YLabel.Position(3)];       
      
%
%          set(axes1Ptr('get', [], dSeriesOffset), 'CLim', [lMin lMax]);
%          set(axes2Ptr('get', [], dSeriesOffset), 'CLim', [lMin lMax]);
%          set(axes3Ptr('get', [], dSeriesOffset), 'CLim', [lMin lMax]);

         if strcmpi(atMetaData{1}.Modality, 'ct')
            [lMax, lMin] = computeWindowLevel(500, 50);

            windowLevel('set', 'max', lMax);
            windowLevel('set', 'min', lMin);

           % lMin = min(im, [], 'all');
           % lMax = max(im, [], 'all');
         end

%          set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [lMin lMax]);


        %// add the listener to the "Colormap" property
%                h.lh = addlistener(axes3Ptr('get') , 'Colormap' , 'PostSet' , @colorbarCallback )

   %      col = colorbar(axes3Ptr('get'), 'EdgeColor', overlayColor('get'), 'Location', 'east');
    end


%            setWindowMinMax(lMax, lMin);
%           overlayText();
    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        uiLogo = displayLogo(uiOneWindowPtr('get'));
    else
        if isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'coronal')

            uiLogo = displayLogo(uiCorWindowPtr('get'));
        elseif isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'sagittal')

            uiLogo = displayLogo(uiSagWindowPtr('get'));
        elseif isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'axial')

            uiLogo = displayLogo(uiTraWindowPtr('get'));
        elseif isVsplash('get') == true && ...
           strcmpi(vSplahView('get'), 'all')

            uiLogo = displayLogo(uiCorWindowPtr('get'));
        else
            uiLogo = displayLogo(uiCorWindowPtr('get'));
        end
    end

    logoObject('set', uiLogo);

    mouseFcn('set');

    if isVsplash('get') == false

        initRoi();
        initPlotEdit();
    end

    setColorbarLabel();

    if size(dicomBuffer('get'), 3) == 1

        axe = axePtr('get', [], dSeriesOffset);
        if ~isempty(axe)
            alpha( axe, 1);
        end

        initAxePlotView(axe);
    else

        axes1 = axes1Ptr('get', [], dSeriesOffset);
        axes2 = axes2Ptr('get', [], dSeriesOffset);
        axes3 = axes3Ptr('get', [], dSeriesOffset);

        if ~isempty(axes1) && ...
           ~isempty(axes2) && ...
           ~isempty(axes3)

            alpha( axes1, 1 );
            alpha( axes2, 1 );
            alpha( axes3, 1 );

            initAxePlotView(axes1);
            initAxePlotView(axes2);
            initAxePlotView(axes3);
        end

        if link2DMip('get') == true && isVsplash('get') == false

            axesMip = axesMipPtr('get', [], dSeriesOffset);

            if ~isempty(axesMip)

                alpha(axesMip, 1 );

                initAxePlotView(axesMip);
            end
        end


    end

    % Deactivate slider
%
%     set(uiSliderWindowPtr('get'), 'Visible', 'off');
%     set(uiSliderLevelPtr('get') , 'Visible', 'off');

    % Use line on colorbar instead of slider in the side

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        axeColorbar = axes(uiOneWindowPtr('get'), ...
                          'Units'   , 'pixel', ...
                          'Ydir'    , 'reverse', ...
                          'xlimmode', 'manual',...
                          'ylimmode', 'manual',...
                          'zlimmode', 'manual',...
                          'climmode', 'manual',...
                          'alimmode', 'manual',...
                          'Position', [get(axesColorbarPtr('get', [], dSeriesOffset), 'Position')], ...
                          'Box'     , 'off', ...
                          'Visible' , 'off'...
                          );
    else

        axeColorbar = axes(uiTraWindowPtr('get'), ...
                          'Units'   , 'pixel', ...
                          'Ydir'    , 'reverse', ...
                          'xlimmode', 'manual',...
                          'ylimmode', 'manual',...
                          'zlimmode', 'manual',...
                          'climmode', 'manual',...
                          'alimmode', 'manual',...
                          'Position', [get(axesColorbarPtr('get', [], dSeriesOffset), 'Position')], ...
                          'Box'     , 'off', ...
                          'Visible' , 'off'...
                          );
    end

    axeColorbar.Interactions = [];
    % axeColorbar.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axeColorbar);
    deleteAxesToolbar(axeColorbar);

    axeColorbarPtr('set', axeColorbar);

    % Compute colorbar line y offset

    dYOffsetMax = computeLineColorbarIntensityMaxYOffset(dSeriesOffset);
    dYOffsetMin = computeLineColorbarIntensityMinYOffset(dSeriesOffset);

    % Line on colorbar

    lineColorbarIntensityMax = line(axeColorbar, [0.1, 0.9], [dYOffsetMax, dYOffsetMax], 'Color', viewerColorbarIntensityMaxLineColor('get'), 'LineWidth', 15);
    lineColorbarIntensityMin = line(axeColorbar, [0.1, 0.9], [dYOffsetMin, dYOffsetMin], 'Color', viewerColorbarIntensityMinLineColor('get'), 'LineWidth', 15);

    lineColorbarIntensityMaxPtr('set', lineColorbarIntensityMax);
    lineColorbarIntensityMinPtr('set', lineColorbarIntensityMin);

 %   set(axeColorbar, 'Visible' , 'off')

    set(lineColorbarIntensityMax,'ButtonDownFcn',@lineColorbarIntensityMaxClick);
    set(lineColorbarIntensityMin,'ButtonDownFcn',@lineColorbarIntensityMinClick);

    iptSetPointerBehavior(lineColorbarIntensityMax,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
    iptSetPointerBehavior(lineColorbarIntensityMin,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));

    % Text on colorbar line

    textColorbarIntensityMax = text(axeColorbar, 0.1,lineColorbarIntensityMax.YData(1), ' ','Color', viewerColorbarIntensityMaxTextColor('get'),'FontName', 'Arial', 'FontSize',7); %Helvetica
    textColorbarIntensityMin = text(axeColorbar, 0.1,lineColorbarIntensityMin.YData(1), ' ','Color', viewerColorbarIntensityMinTextColor('get'),'FontName', 'Arial', 'FontSize',7); %Helvetica

    textColorbarIntensityMaxPtr('set', textColorbarIntensityMax);
    textColorbarIntensityMinPtr('set', textColorbarIntensityMin);

    iptSetPointerBehavior(textColorbarIntensityMax,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
    iptSetPointerBehavior(textColorbarIntensityMin,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));

    set(textColorbarIntensityMax,'ButtonDownFcn',@lineColorbarIntensityMaxClick);
    set(textColorbarIntensityMin,'ButtonDownFcn',@lineColorbarIntensityMinClick);

    if isempty(isColorbarDefaultUnit('get'))

        isColorbarDefaultUnit('set', true);
    end

    % Ajust the intensity

    setColorbarIntensityMaxScaleValue(lineColorbarIntensityMax.YData(1), colorbarScale('get'), isColorbarDefaultUnit('get'), dSeriesOffset);
    setColorbarIntensityMinScaleValue(lineColorbarIntensityMin.YData(1), colorbarScale('get'), isColorbarDefaultUnit('get'), dSeriesOffset);

    setAxesIntensity(dSeriesOffset);

    disableAxesToolbar(axeColorbar);

    if strcmpi(atMetaData{1}.Modality, 'ct')

        if link2DMip('get') == true && isVsplash('get') == false

            [dLevelMax, dLevelMin] = computeWindowLevel(2500, 415);
            set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
        end
    end

    if isVsplash('get') == true

        if strcmpi(vSplahView('get'), 'Coronal') || ...
           strcmpi(vSplahView('get'), 'Sagittal')

            setColorbarVisible('off');
        end
    end

    setColorbarLabel();

%                     setFusionColorbarVisible('off');
%    sUnitDisplay = getSerieUnitValue(dSeriesOffset);

%     if strcmpi(sUnitDisplay, 'SUV')
%         tQuant = quantificationTemplate('get');
%         for tt=1:numel(ptrColorbar.TickLabels)
%
%             ptrColorbar.TickLabels{tt} = num2str(str2double(ptrColorbar.TickLabels{tt})*tQuant.tSUV.dScale);
%         end
%     end

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        set(uiOneWindowPtr('get'), 'Visible', 'on');

        % axe = axePtr('get', [], dSeriesOffset);
        % axe.Toolbar.Visible = 'off';
       
        % disableAxesToolbar(axe);
        % delete(axe.Toolbar);
    else

        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')
            if strcmpi(vSplahView('get'), 'coronal')

                set(uiCorWindowPtr('get'), 'Visible', 'on' );
                set(uiSagWindowPtr('get'), 'Visible', 'off');
                set(uiTraWindowPtr('get'), 'Visible', 'off');
                set(uiMipWindowPtr('get'), 'Visible', 'off');

                set(uiSliderCorPtr('get'), 'Visible', 'on' );
                set(uiSliderSagPtr('get'), 'Visible', 'off');
                set(uiSliderTraPtr('get'), 'Visible', 'off');
                set(uiSliderMipPtr('get'), 'Visible', 'off');

           elseif strcmpi(vSplahView('get'), 'sagittal')

                set(uiCorWindowPtr('get'), 'Visible', 'off');
                set(uiSagWindowPtr('get'), 'Visible', 'on' );
                set(uiTraWindowPtr('get'), 'Visible', 'off');
                set(uiMipWindowPtr('get'), 'Visible', 'off');

                set(uiSliderCorPtr('get'), 'Visible', 'off');
                set(uiSliderSagPtr('get'), 'Visible', 'on' );
                set(uiSliderTraPtr('get'), 'Visible', 'off');
                set(uiSliderMipPtr('get'), 'Visible', 'off');

            else
                set(uiCorWindowPtr('get'), 'Visible', 'off');
                set(uiSagWindowPtr('get'), 'Visible', 'off');
                set(uiTraWindowPtr('get'), 'Visible', 'on' );
                set(uiMipWindowPtr('get'), 'Visible', 'off');

                set(uiSliderCorPtr('get'), 'Visible', 'off');
                set(uiSliderSagPtr('get'), 'Visible', 'off');
                set(uiSliderTraPtr('get'), 'Visible', 'on' );
                set(uiSliderMipPtr('get'), 'Visible', 'off');
            end

            % axe1 = axes1Ptr('get', [], dSeriesOffset);
            % axe2 = axes2Ptr('get', [], dSeriesOffset);
            % axe3 = axes3Ptr('get', [], dSeriesOffset);
            % 
            % disableAxesToolbar(axe1);
            % disableAxesToolbar(axe2);
            % disableAxesToolbar(axe3);

            % delete(axe1.Toolbar);
            % delete(axe2.Toolbar);
            % delete(axe3.Toolbar);

            % axe1.Toolbar.Visible = 'off';
            % axe2.Toolbar.Visible = 'off';
            % axe3.Toolbar.Visible = 'off';

        else

            if isVsplash('get') == false

                set(uiMipWindowPtr('get'), 'Visible', 'on');
                set(uiSliderMipPtr('get'), 'Visible', 'on');

                axeMip = axesMipPtr('get', [], dSeriesOffset);
                % axeMip.Toolbar.Visible = 'off';
                disableAxesToolbar(axeMip);
                % delete(axeMip.Toolbar);
            end

            set(uiCorWindowPtr('get'), 'Visible', 'on');
            set(uiSagWindowPtr('get'), 'Visible', 'on');
            set(uiTraWindowPtr('get'), 'Visible', 'on');
            % 
            % axe1 = axes1Ptr('get', [], dSeriesOffset);
            % axe2 = axes2Ptr('get', [], dSeriesOffset);
            % axe3 = axes3Ptr('get', [], dSeriesOffset);

            % axe1.Toolbar.Visible = 'off';
            % axe2.Toolbar.Visible = 'off';
            % axe3.Toolbar.Visible = 'off';

            % disableAxesToolbar(axe1);
            % disableAxesToolbar(axe2);
            % disableAxesToolbar(axe3);

            % delete(axe1.Toolbar);
            % delete(axe2.Toolbar);
            % delete(axe3.Toolbar);

            set(uiSliderCorPtr('get'), 'Visible', 'on');
            set(uiSliderSagPtr('get'), 'Visible', 'on');
            set(uiSliderTraPtr('get'), 'Visible', 'on');

            % adjAxeCameraViewAngle(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
            % adjAxeCameraViewAngle(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
            % adjAxeCameraViewAngle(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
            % adjAxeCameraViewAngle(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));


        end
    end

    if isFusion('get') == true

        isFusion('set', false);
        setFusionCallback();
    end

    if bInitSegPanel == true

       setViewSegPanel();
    end

    if bInitKernelPanel == true

       setViewKernelPanel();
    end

    if bInitRoiPanel == true

       setViewRoiPanel();
    end

    setOverlayPatientInformation(dSeriesOffset);

    clear im;

    catch ME
        logErrorToFile(ME)
        progressBar(1, 'Error: dicomViewerCore()');
    end
    
    refreshImages();

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
end
