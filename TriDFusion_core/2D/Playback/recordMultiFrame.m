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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        multiFrameRecord('set', false);
        mRecord.State = 'off';
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return;
    end

    atCoreMetaData = dicomMetaData('get');

    if (gca == axes1Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
       (isVsplash('get') == true && ...
        strcmpi(vSplahView('get'), 'coronal'))

        dLastSlice = size(dicomBuffer('get'), 1);
        dCurrentSlice = sliceNumber('get', 'coronal');
        aAxe = axes1Ptr('get', [], dSeriesOffset);

    elseif (gca == axes2Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
       (isVsplash('get') == true && ...
        strcmpi(vSplahView('get'), 'sagittal'))
    
        dLastSlice = size(dicomBuffer('get'), 2);
        dCurrentSlice = sliceNumber('get', 'sagittal');
        aAxe = axes2Ptr('get', [], dSeriesOffset);

    elseif (gca == axes3Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
       (isVsplash('get') == true && ...
        strcmpi(vSplahView('get'), 'axial'))
    
        dLastSlice = size(dicomBuffer('get'), 3);
        dCurrentSlice = sliceNumber('get', 'axial');
        aAxe = axes3Ptr('get', [], dSeriesOffset);
    else
        dLastSlice = 32;
        dCurrentSlice = mipAngle('get');
        aAxe = axesMipPtr('get', [], dSeriesOffset);       
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
        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)
            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)
                alAxes3Line{ii3}.Visible = 'off';
            end
        else
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

    iSavedCurrentSlice = dCurrentSlice;

    for idx = 1:dLastSlice

        if ~multiFrameRecord('get')
            break;
        end

        if     aAxe == axes1Ptr('get', [], dSeriesOffset)
            sliceNumber('set', 'coronal', dCurrentSlice);
            if isVsplash('get') == true
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'coronal', dCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));
            end

        elseif aAxe == axes2Ptr('get', [], dSeriesOffset)
            sliceNumber('set', 'sagittal', dCurrentSlice);

            if isVsplash('get') == true
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'sagittal', dCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));
            end
        elseif aAxe == axes3Ptr('get', [], dSeriesOffset)
            sliceNumber('set', 'axial', dCurrentSlice);
            if isVsplash('get') == true
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'axial', dLastSlice-dCurrentSlice+1);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(dLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(1+dLastSlice-dCurrentSlice), num2str(dLastSlice));
            end
        else
            mipAngle('set', dCurrentSlice);           
            sSliceNb = sprintf('\n%s/%s', num2str(dCurrentSlice), num2str(dLastSlice));
        end

        set(tOverlay, 'String', sSliceNb);

        refreshImages();

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

        I = getframe(aAxe);
        [indI,cm] = rgb2ind(I.cdata, 256);

        if idx == 1

            if strcmpi('*.gif', sExtention)
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)

                sDirName = sprintf('%s_%s_%s_JPG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention)
                sDirName = sprintf('%s_%s_%s_BMP_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');
            elseif strcmpi('*.png', sExtention)
                sDirName = sprintf('%s_%s_%s_PNG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
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

        progressBar(idx / dLastSlice, 'Recording', 'red');

    end

    if     aAxe == axes1Ptr('get', [], dSeriesOffset)
        sliceNumber('set', 'coronal', iSavedCurrentSlice);
    elseif aAxe == axes2Ptr('get', [], dSeriesOffset)
        sliceNumber('set', 'sagittal', iSavedCurrentSlice);
    elseif aAxe == axes3Ptr('get', [], dSeriesOffset)
        sliceNumber('set', 'axial', iSavedCurrentSlice);
    else
        mipAngle('set', iSavedCurrentSlice);           
    end

    set(uiSliderSagPtr('get'), 'Visible', 'on');
    set(uiSliderCorPtr('get'), 'Visible', 'on');
    set(uiSliderTraPtr('get'), 'Visible', 'on');
    set(uiSliderMipPtr('get'), 'Visible', 'on');

%    if aAxe == axes3Ptr('get', [], dSeriesOffset)
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

    if crossActivate('get') == true && ...
       isVsplash('get') == false
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
        else
        end
    end

    delete(tLogo);
    delete(tOverlay);
    
    if isVsplash('get') == false                       

        if aAxe == axes1Ptr('get', [], dSeriesOffset)
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
    
    refreshImages();

    if strcmpi('*.gif', sExtention)
        progressBar(1, sprintf('Write %s completed', sFileName));
    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('*.bmp', sExtention) || ...
           strcmpi('*.png', sExtention)
        progressBar(1, sprintf('Write %d files to %s completed', dLastSlice, sImgDirName));
    end
end
