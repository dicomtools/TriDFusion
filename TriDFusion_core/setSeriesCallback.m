function setSeriesCallback(~,~)
%function setSeriesCallback(~, ~)
%Set Viewer Series From Popup menu.
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

    tInput  = inputTemplate('get');
    iOffset = get(uiSeriesPtr('get'), 'Value');

    if iOffset <= numel(tInput)

        copyRoiPtr('set', '');

        releaseRoiWait();

        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        zoomTool('set', false);
        zoom('off');

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        panTool('set', false);
        pan('off');

        rotate3DTool('set', false);
        rotate3d('off');

        isFusion('set', false);
        fusionBuffer('reset');
        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        initWindowLevel ('set', true);
        initFusionWindowLevel ('set', true);

        view3DPanel('set', false);
        init3DPanel('set', true);

        obj3DPanel = view3DPanelMenuObject('get');
        if ~isempty(obj3DPanel)
            obj3DPanel.Checked = 'off';
        end

        mPlay = playIconMenuObject('get');
        if ~isempty(mPlay)
            mPlay.State = 'off';
 %           playIconMenuObject('set', '');
        end

        mRecord = recordIconMenuObject('get');
        if ~isempty(mRecord)
            mRecord.State = 'off';
 %           recordIconMenuObject('set', '');
        end

        multiFrame3DPlayback('set', false);
        multiFrame3DRecord  ('set', false);
        multiFrame3DIndex   ('set', 1);
%                multiFrame3DZoom    ('set', 0);
%             setPlaybackToolbar('off');

        multiFramePlayback('set', false);
        multiFrameRecord  ('set', false);
        multiFrameZoom    ('set', 'in' , 1);
        multiFrameZoom    ('set', 'out', 1);
        multiFrameZoom    ('set', 'axe', []);

        rotate3d('off');

        switchTo3DMode('set', false);
        set(btn3DPtr('get'), 'Enable', 'on');
        set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        switchToMIPMode('set', false);
        set(btnIsoSurfacePtr('get'), 'Enable', 'on');
        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        switchToIsoSurface('set', false);
        set(btnMIPPtr('get'), 'Enable', 'on');
        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnTriangulatePtr('get'), 'Enable', 'on');
        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

        if isempty(dicomMetaData('get'))
            atMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set', atMetaData);
        end

        aInput  = inputBuffer('get');
        aBuffer = dicomBuffer('get');

        if isempty(aBuffer)
            if     strcmp(imageOrientation('get'), 'axial')
                aBuffer = permute(aInput{iOffset}, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal')
                aBuffer = permute(aInput{iOffset}, [3 2 1]);
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aBuffer = permute(aInput{iOffset}, [3 1 2]);
            end

            dicomBuffer('set', aBuffer);
        end

%        quantificationTemplate('set', tInput(iOffset).tQuant);
        setQuantification(iOffset);

%        cropValue('set', tInput(iOffset).tQuant.tCount.dMin);

        imageSegTreshValue('set', 'lower', 0);
        imageSegTreshValue('set', 'upper', 1);

%        imageSegEditValue('set', 'lower', tInput(iOffset).tQuant.tCount.dMin);
%        imageSegEditValue('set', 'upper', tInput(iOffset).tQuant.tCount.dMax);
    
        getMipAlphaMap('set', '', 'auto');
        getVolAlphaMap('set', '', 'auto');

        getMipFusionAlphaMap('set', '', 'auto');
        getVolFusionAlphaMap('set', '', 'auto');

        deleteAlphaCurve('vol');
        deleteAlphaCurve('volfusion');

        volColorObj = volColorObject('get');
        if ~isempty(volColorObj)
            delete(volColorObj);
            volColorObject('set', '');
        end

        deleteAlphaCurve('mip');
        deleteAlphaCurve('mipfusion');

        mipColorObj = mipColorObject('get');
        if ~isempty(mipColorObj)
            delete(mipColorObj);
            mipColorObject('set', '');
        end

        logoObj = logoObject('get');
        if ~isempty(logoObj)
            delete(logoObj);
            logoObject('set', '');
        end

        volObj = volObject('get');
        if ~isempty(volObj)
            delete(volObj);
            volObject('set', '');
        end

        volFuisonObj = volFusionObject('get');
        if ~isempty(volFuisonObj)
            delete(volFuisonObj);
            volFusionObject('set', '');
        end

        isoObj = isoObject('get');
        if ~isempty(isoObj)
            delete(isoObj);
            isoObject('set', '');
        end

        mipObj = mipObject('get');
        if ~isempty(mipObj)
            delete(mipObj);
            mipObject('set', '');
        end

        mipFusionObj = mipFusionObject('get');
        if ~isempty(mipFusionObj)
            delete(mipFusionObj);
            mipFusionObject('set', '');
        end

        voiObj = voiObject('get');
        if ~isempty(voiObj)
            for vv=1:numel(voiObj)
                delete(voiObj{vv})
            end
            voiObject('set', '');
        end

        if size(dicomBuffer('get'), 3) == 1 || ...
           ~numel(dicomBuffer('get'))

            isVsplash('set', false);
            set(btnVsplashPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnVsplashPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            set(btnVsplashPtr('get')   , 'Enable', 'off');
            set(uiEditVsplahXPtr('get'), 'Enable', 'off');
            set(uiEditVsplahYPtr('get'), 'Enable', 'off');
        end

        clearDisplay();
        initDisplay(3);

        dicomViewerCore();

        setViewerDefaultColor(true, dicomMetaData('get'));

        refreshImages();

    end
end
