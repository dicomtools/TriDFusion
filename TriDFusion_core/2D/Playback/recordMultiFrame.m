function recordMultiFrame(mRecord, sPath, sFileName, sExtention)
%function recordMultiFrame(mRecord, sPath, sFileName, sExtention)
%Record 2D Frames.
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

    bWriteSucceed = true;

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        progressBar(1, 'Error: Require a 3D Volume!');

        multiFrameRecord('set', false);

        icon = get(mRecord, 'UserData');
        set(mRecord, 'CData', icon.default);

        set(uiSeriesPtr('get'), 'Enable', 'on');

        return;
    end
    
    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    if strcmpi('*.dcm', sExtention) || ...
       strcmpi('dcm'  , sExtention)

        if isfield(atMetaData{1}, 'SeriesDescription')
            sSeriesDescription = atMetaData{1}.SeriesDescription;
        else
            sSeriesDescription = '';
        end

        sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MFSC-%s', sSeriesDescription));

        if isempty(sSeriesDescription)
            return;
        end
    end

    % if viewerUIFigure('get') == true
    %     setFigureToobarsVisible('off');
    % 
    %     setFigureTopMenuVisible('off');
    % end

    chkUiCorWindowSelected = chkUiCorWindowSelectedPtr('get');
    chkUiSagWindowSelected = chkUiSagWindowSelectedPtr('get');
    chkUiTraWindowSelected = chkUiTraWindowSelectedPtr('get');
    chkUiMipWindowSelected = chkUiMipWindowSelectedPtr('get');

    if get(chkUiCorWindowSelected, 'Value') == true || ...
       (isVsplash('get') == true && strcmpi(vSplahView('get'), 'coronal'))
        
        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);
        dCurrentSlice = sliceNumber('get', 'coronal');
        aAxe = axes1Ptr('get', [], dSeriesOffset);

    elseif get(chkUiSagWindowSelected, 'Value') == true || ...
           (isVsplash('get') == true && strcmpi(vSplahView('get'), 'sagittal'))
            
        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 2);
        dCurrentSlice = sliceNumber('get', 'sagittal');
        aAxe = axes2Ptr('get', [], dSeriesOffset);

    elseif get(chkUiTraWindowSelected, 'Value') == true || ...
           (isVsplash('get') == true && strcmpi(vSplahView('get'), 'axial'))
        
        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);
        dCurrentSlice = sliceNumber('get', 'axial');
        aAxe = axes3Ptr('get', [], dSeriesOffset);
    else

        dLastSlice = 32;
        dCurrentSlice = mipAngle('get');
        aAxe = axesMipPtr('get', [], dSeriesOffset);       
    end

    set(chkUiCorWindowSelected, 'Visible', 'off');
    set(chkUiSagWindowSelected, 'Visible', 'off');
    set(chkUiTraWindowSelected, 'Visible', 'off');
    set(chkUiMipWindowSelected, 'Visible', 'off');

    set(uiSliderSagPtr('get'), 'Visible', 'off');
    set(uiSliderCorPtr('get'), 'Visible', 'off');
    set(uiSliderTraPtr('get'), 'Visible', 'off');
    set(uiSliderMipPtr('get'), 'Visible', 'off');
    
    % Check if Vsplash is inactive

    if ~isVsplash('get')

        logoObj = logoObject('get');

        % If the logo object exists, delete it and reset the reference

        if ~isempty(logoObj)

            delete(logoObj);
            logoObject('set', '');
        end
    end

    % Colorbar 

    sLineColorbarIntensityMaxPtrVisible = get(lineColorbarIntensityMaxPtr('get'), 'Visible');
    sLineColorbarIntensityMinPtrVisible = get(lineColorbarIntensityMinPtr('get'), 'Visible');

    sTextColorbarIntensityMaxPtrVisible = get(textColorbarIntensityMaxPtr('get'), 'Visible');
    sTextColorbarIntensityMinPtrVisible = get(textColorbarIntensityMinPtr('get'), 'Visible');

    sUiColorbarPtrVisible = get(uiColorbarPtr('get'), 'Visible');

    set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'off');
    set(lineColorbarIntensityMinPtr('get'), 'Visible', 'off');

    set(textColorbarIntensityMaxPtr('get'), 'Visible', 'off');
    set(textColorbarIntensityMinPtr('get'), 'Visible', 'off');

    set(uiColorbarPtr('get'), 'Visible', 'off');
    set(uiColorbarPtr('get').Parent, 'Visible', 'off');

    if isFusion('get')

        sLineFusionColorbarIntensityMaxPtrVisible = get(lineFusionColorbarIntensityMaxPtr('get'), 'Visible');
        sLineFusionColorbarIntensityMinPtrVisible = get(lineFusionColorbarIntensityMaxPtr('get'), 'Visible');

        set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');

        sTextFusionColorbarIntensityMaxPtrVisible = get(textFusionColorbarIntensityMaxPtr('get'), 'Visible');
        sTextFusionColorbarIntensityMinPtrVisible = get(textFusionColorbarIntensityMinPtr('get'), 'Visible');

        set(textFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(textFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');

        sAlphaSliderPtrVisible    =  get(uiAlphaSliderPtr('get')   , 'Visible');
        sFusionColorbarPtrVisible =  get(uiFusionColorbarPtr('get'), 'Visible');

        set(uiAlphaSliderPtr('get')   , 'Visible', 'off');
        set(uiFusionColorbarPtr('get'), 'Visible', 'off');
        set(uiFusionColorbarPtr('get').Parent, 'Visible', 'off');
    end

   % Overlay text

    if overlayActivate('get') == true

        if aAxe == axes1Ptr('get', [], dSeriesOffset)
            
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

    % Triangulation cross

    if crossActivate('get') == true && isVsplash('get') == false
          
        if aAxe == axes1Ptr('get', [], dSeriesOffset)

            alAxes1Line = axesLine('get', 'axes1');

            for ii1=1:numel(alAxes1Line)
                alAxes1Line{ii1}.Visible = 'off';
            end

        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)

            alAxes2Line = axesLine('get', 'axes2');

            for ii2=1:numel(alAxes2Line)
                alAxes2Line{ii2}.Visible = 'off';
            end

        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)

            alAxes3Line = axesLine('get', 'axes3');

            for ii3=1:numel(alAxes3Line)
                alAxes3Line{ii3}.Visible = 'off';
            end

         elseif aAxe == axesMipPtr('get', [], dSeriesOffset)

            alAxesMipLine = axesLine('get', 'axesMip');

            for ii4=1:numel(alAxesMipLine)
                alAxesMipLine{ii4}.Visible = 'off';
            end            
        end
    end

    if isVsplash('get') == false

        btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');
        if ~isempty(btnUiCorWindowFullScreen)

            btnUiCorWindowFullScreen.Visible = 'off';
        end

        btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');
        if ~isempty(btnUiSagWindowFullScreen)
        
            btnUiSagWindowFullScreen.Visible = 'off';
        end

        btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
        if ~isempty(btnUiTraWindowFullScreen)
     
            btnUiTraWindowFullScreen.Visible = 'off';
        end

        btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');
        if ~isempty(btnUiMipWindowFullScreen)
    
            btnUiMipWindowFullScreen.Visible = 'off';
        end

    end

    if isVsplash('get') == false

        btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');
        if ~isempty(btnUiCorWindowFullScreen)

            btnUiCorWindowFullScreen.Visible = 'off';
        end

        btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');
        if ~isempty(btnUiSagWindowFullScreen)
        
            btnUiSagWindowFullScreen.Visible = 'off';
        end

        btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
        if ~isempty(btnUiTraWindowFullScreen)
     
            btnUiTraWindowFullScreen.Visible = 'off';
        end

        btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');
        if ~isempty(btnUiMipWindowFullScreen)
    
            btnUiMipWindowFullScreen.Visible = 'off';
        end

    end

    % sLogo = sprintf('%s\n', 'TriDFusion (3DF)');  
    % 
    % pLogo    = text(aAxe, 0.02, 0.03, sLogo, 'Units','normalized');

    pLogo = displayLogo(aAxe);

    txtOverlay = text(aAxe, 0.02, 0.97, ''   , 'Units','normalized');

    if any(aAxe.Parent.BackgroundColor) % Not black
        % set(pLogo   , 'Color', [0.1500 0.1500 0.1500]);
        setLogoColor(pLogo, [0.1500 0.1500 0.1500]);
        set(txtOverlay, 'Color', [0.1500 0.1500 0.1500]);
    else
        % set(pLogo   , 'Color', [0.8500 0.8500 0.8500]);
        setLogoColor(pLogo, [0.8500 0.8500 0.8500]);
        set(txtOverlay, 'Color', [0.8500 0.8500 0.8500]);        
    end

    if overlayActivate('get') == false

        set(txtOverlay, 'Visible', 'off');
    end

    % iSavedCurrentSlice = dCurrentSlice;

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)
        
        if strcmpi('*.avi', sExtention) || ...
           strcmpi('avi'  , sExtention)

            tClassVideoWriter = VideoWriter([sPath sFileName], 'Motion JPEG AVI');
        else
            tClassVideoWriter = VideoWriter([sPath sFileName],  'MPEG-4');
        end

        set(tClassVideoWriter, 'FrameRate', 1/multiFrameSpeed('get'));
        set(tClassVideoWriter, 'Quality', 100);

        open(tClassVideoWriter);
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    for idx = 1:dLastSlice

        if ~multiFrameRecord('get')

            break;
        end

        if aAxe == axes1Ptr('get', [], dSeriesOffset)

            % sliceNumber('set', 'coronal', dCurrentSlice);

            if isVsplash('get') == true

                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get', [], dSeriesOffset), 'coronal', dCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));
            end

            set(uiSliderCorPtr('get'), 'Value', dCurrentSlice);

            sliderCorCallback();

        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)

            % sliceNumber('set', 'sagittal', dCurrentSlice);

            if isVsplash('get') == true

                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get', [], dSeriesOffset), 'sagittal', dCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));
            end

            set(uiSliderSagPtr('get'), 'Value', dCurrentSlice);

            sliderSagCallback();

        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)

            % sliceNumber('set', 'axial', dCurrentSlice);

            if isVsplash('get') == true

                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get', [], dSeriesOffset), 'axial', dLastSlice-dCurrentSlice+1);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(1+dLastSlice-dCurrentSlice), num2str(dLastSlice));
            end

            set(uiSliderTraPtr('get'), 'Value', dLastSlice-dCurrentSlice+1);

            sliderTraCallback();

        else
            % mipAngle('set', dCurrentSlice);           
            sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));

            set(uiSliderMipPtr('get'), 'Value', dCurrentSlice);

            sliderMipCallback();

            % plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), dCurrentSlice);       
        end

        set(txtOverlay, 'String', sSliceNb);

        % windowButton('set', 'scrool');
        % 
        % refreshImages();

        if aAxe == axes3Ptr('get', [], dSeriesOffset)

            dCurrentSlice = dCurrentSlice-1;
            if dCurrentSlice <1
                dCurrentSlice =dLastSlice;
            end
        else
            dCurrentSlice = dCurrentSlice+1;
            if dCurrentSlice > dLastSlice
                dCurrentSlice =1;
            end
        end

        if viewerUIFigure('get') == true || ...
           ~isMATLABReleaseOlderThan('R2025a')

            I = getObjectFrame(aAxe);
        else

            I = getframe(aAxe);
            I = I.cdata;
        end

        if strcmpi('*.avi', sExtention) || ...
           strcmpi('avi'  , sExtention) || ...
           strcmpi('*.mp4', sExtention) || ...
           strcmpi('mp4'  , sExtention) || ...   
           strcmpi('*.gif', sExtention) || ...
           strcmpi('gif'  , sExtention) 

            if idx == 1 % We can't write different image size.
                
                aFirstImageSize = size(I);
            else
                if ~isequal(size(I), aFirstImageSize)
    
                    I = imresize3(I, aFirstImageSize);
                end
            end
        end

        [indI, cm] = rgb2ind(I, 256); % Convert to indexed image   

        if idx == 1

            if strcmpi('*.avi', sExtention) || ...
               strcmpi('avi'  , sExtention) || ...
               strcmpi('*.mp4', sExtention) || ...
               strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

            elseif strcmpi('*.gif', sExtention) || ...
                   strcmpi('gif'  , sExtention) 

                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrameSpeed('get'));

            elseif strcmpi('*.jpg', sExtention) || ...
                   strcmpi('jpg', sExtention)

                sDirName = sprintf('%s_%s_%s_JPG_2D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))
                    
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention)

                sDirName = sprintf('%s_%s_%s_BMP_2D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention)

                sDirName = sprintf('%s_%s_%s_PNG_2D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png');                

            elseif strcmpi('*.dcm', sExtention) || ...
                   strcmpi('dcm'  , sExtention)

                sDcmDirName = outputDir('get');

                if isempty(sDcmDirName)

                    sDirName = sprintf('%s_%s_%s_DCM_2D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sDirName = cleanString(sDirName);
                    sDcmDirName = [sPath sDirName '//'];
    
                    if~(exist(char(sDcmDirName), 'dir'))

                        mkdir(char(sDcmDirName));
                    end
                end

                cSeriesInstanceUID = dicomuid;

                sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', idx));

                objectToDicomMultiFrame(sOutFile, aAxe, sSeriesDescription, cSeriesInstanceUID, idx, dLastSlice, dSeriesOffset);

            end
        else
             if strcmpi('*.avi', sExtention) || ...
                strcmpi('avi'  , sExtention) || ...
                strcmpi('*.mp4', sExtention) || ...
                strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

             elseif strcmpi('*.gif', sExtention) || ...
                    strcmpi('gif'  , sExtention)    

                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrameSpeed('get'));

            elseif strcmpi('*.jpg', sExtention) || ...  
                   strcmpi('jpg'  , sExtention) 

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention)

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention)

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png');                

            elseif strcmpi('*.dcm', sExtention) || ...
                   strcmpi('dcm'  , sExtention)

                 sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', idx));

                 objectToDicomMultiFrame(sOutFile, aAxe, sSeriesDescription, cSeriesInstanceUID, idx, dLastSlice, dSeriesOffset); 
            end

        end

        progressBar(idx / dLastSlice, 'Recording', 'red');

    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...     
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)

        close(tClassVideoWriter);
    end

    catch ME   
        logErrorToFile(ME);
        bWriteSucceed = false;
        progressBar(1, sprintf('Error: recordMultiFrame()'));
    end

    set(uiSliderSagPtr('get'), 'Visible', 'on');
    set(uiSliderCorPtr('get'), 'Visible', 'on');
    set(uiSliderTraPtr('get'), 'Visible', 'on');
    set(uiSliderMipPtr('get'), 'Visible', 'on');

    set(chkUiCorWindowSelected, 'Visible', 'on');
    set(chkUiSagWindowSelected, 'Visible', 'on');
    set(chkUiTraWindowSelected, 'Visible', 'on');
    set(chkUiMipWindowSelected, 'Visible', 'on');

    % Colorbar
    
    set(lineColorbarIntensityMaxPtr('get'), 'Visible', sLineColorbarIntensityMaxPtrVisible);
    set(lineColorbarIntensityMinPtr('get'), 'Visible', sLineColorbarIntensityMinPtrVisible);

    set(textColorbarIntensityMaxPtr('get'), 'Visible', sTextColorbarIntensityMaxPtrVisible);
    set(textColorbarIntensityMinPtr('get'), 'Visible', sTextColorbarIntensityMinPtrVisible);

    set(uiColorbarPtr('get'), 'Visible', sUiColorbarPtrVisible);
    set(uiColorbarPtr('get').Parent, 'Visible', sUiColorbarPtrVisible);

    if isFusion('get')

        set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');

        set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', sLineFusionColorbarIntensityMaxPtrVisible);
        set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', sLineFusionColorbarIntensityMinPtrVisible);

        set(textFusionColorbarIntensityMaxPtr('get'), 'Visible', sTextFusionColorbarIntensityMaxPtrVisible);
        set(textFusionColorbarIntensityMinPtr('get'), 'Visible', sTextFusionColorbarIntensityMinPtrVisible);

        set(uiAlphaSliderPtr('get')   , 'Visible', sAlphaSliderPtrVisible);
        set(uiFusionColorbarPtr('get'), 'Visible', sFusionColorbarPtrVisible);
        set(uiFusionColorbarPtr('get').Parent, 'Visible', sFusionColorbarPtrVisible);
   end

    if overlayActivate('get')
        
        if     aAxe == axes1Ptr('get', [], dSeriesOffset)

            pAxes1Text = axesText('get', 'axes1');
            pAxes1Text.Visible = 'on';
            
            pAxes1View = axesText('get', 'axes1View');
            pAxes1View.Visible = 'on';           
            
        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)

            pAxes2Text = axesText('get', 'axes2');
            pAxes2Text.Visible = 'on';
            
            pAxes2View = axesText('get', 'axes2View');
            pAxes2View.Visible = 'on';             
            
        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)

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

    if crossActivate('get') == true && isVsplash('get') == false
       
        if     aAxe == axes1Ptr('get', [], dSeriesOffset)

            alAxes1Line = axesLine('get', 'axes1');
            for ii1=1:numel(alAxes1Line)
                alAxes1Line{ii1}.Visible = 'on';
            end

        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)

            alAxes2Line = axesLine('get', 'axes2');
            for ii2=1:numel(alAxes2Line)
                alAxes2Line{ii2}.Visible = 'on';
            end

        elseif aAxe == axesMipPtr('get', [], dSeriesOffset)

            alAxesMipLine = axesLine('get', 'axesMip');
            for ii4=1:numel(alAxesMipLine)
                alAxesMipLine{ii4}.Visible = 'on';
            end            
            
        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)

            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)
                alAxes3Line{ii3}.Visible = 'on';
            end
        end
    end

    if isVsplash('get') == false

        btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');
        if ~isempty(btnUiCorWindowFullScreen)

            btnUiCorWindowFullScreen.Visible = 'on';
        end

        btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');
        if ~isempty(btnUiSagWindowFullScreen)
        
            btnUiSagWindowFullScreen.Visible = 'on';
        end

        btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
        if ~isempty(btnUiTraWindowFullScreen)
     
            btnUiTraWindowFullScreen.Visible = 'on';
        end

        btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');
        if ~isempty(btnUiMipWindowFullScreen)
    
            btnUiMipWindowFullScreen.Visible = 'on';
        end
    end

    delete(pLogo);
    
    delete(txtOverlay);
    
    if isVsplash('get') == false         
        
        uiLogo = displayLogo(uiCorWindowPtr('get'));        
        
        logoObject('set', uiLogo);
    end
   
    % refreshImages();

    % windowButton('set', 'up');

    if bWriteSucceed == true

        if strcmpi('*.avi', sExtention) || ...
           strcmpi('avi'  , sExtention) || ...
           strcmpi('*.mp4', sExtention) || ...
           strcmpi('mp4'  , sExtention) || ...
           strcmpi('*.gif', sExtention) || ...
           strcmpi('gif'  , sExtention)
    
            progressBar(1, sprintf('Write %s completed', [sPath sFileName]));
    
        elseif strcmpi('*.jpg', sExtention) || ...
               strcmpi('jpg'  , sExtention) || ...
               strcmpi('*.bmp', sExtention) || ...
               strcmpi('bmp'  , sExtention) || ...
               strcmpi('*.png', sExtention) || ...
               strcmpi('png'  , sExtention) 
    
            progressBar(1, sprintf('Write %d files to %s completed', dLastSlice, sImgDirName));
    
    elseif strcmpi('*.dcm', sExtention) || ...
           strcmpi('dcm'  , sExtention)

            progressBar(1, sprintf('Write %d files to %s completed', dLastSlice, sDcmDirName));
            
        end
    end
end
