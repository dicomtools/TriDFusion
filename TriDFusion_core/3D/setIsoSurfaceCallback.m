function setIsoSurfaceCallback(~, ~)
%function setIsoSurfaceCallback(~, ~)
%Activate/Deactivate 3D ISO Surface.
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

    if numel(dicomBuffer('get')) && ...
       size(dicomBuffer('get'), 3) ~= 1

%             releaseRoiAxeWait();
        releaseRoiWait();

        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnZoomPtr('get'), 'Enable', 'off');
        zoomTool('set', false);
        zoom('off');

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnPanPtr('get'), 'Enable', 'off');
        panTool('set', false);
        pan('off');

        set(btnVsplashPtr('get')   , 'Enable', 'off');
        set(uiEditVsplahXPtr('get'), 'Enable', 'off');
        set(uiEditVsplahYPtr('get'), 'Enable', 'off');

        set(btnRegisterPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnRegisterPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));        
        set(btnRegisterPtr('get'), 'Enable', 'off');
        
   %     set(rotate3DMenu('get'), 'Checked', 'off');
        rotate3DTool('set', false);
        rotate3d('off');

        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);
        datacursormode('off');

        setRoiToolbar('off');

        if multiFramePlayback('get') == true
            multiFramePlayback('set', false);
            mPlay = playIconMenuObject('get');
            if ~isempty(mPlay)
                mPlay.State = 'off';
            end
        end

        if multiFrameRecord('get') == true
            multiFrameRecord('set', false);
            mRecord = recordIconMenuObject('get');
            if ~isempty(mRecord)
                mRecord.State = 'off';
            end
        end

        multiFramePlayback('set', false);
        multiFrameRecord  ('set', false);
        multiFrameZoom    ('set', 'in' , 1);
        multiFrameZoom    ('set', 'out', 1);
        multiFrameZoom    ('set', 'axe', []);

        uiSegMainPanel = uiSegMainPanelPtr('get');
        if ~isempty(uiSegMainPanel)
            set(uiSegMainPanel, 'Visible', 'off');
        end

        mOptions = optionsPanelMenuObject('get');
        if ~isempty(mOptions)
            mOptions.Enable = 'off';
        end

        viewSegPanel('set', false);
        objSegPanel = viewSegPanelMenuObject('get');
        if ~isempty(objSegPanel)
            objSegPanel.Checked = 'off';
        end

        uiKernelMainPanel = uiKernelMainPanelPtr('get');
        if ~isempty(uiKernelMainPanel)
            set(uiKernelMainPanel, 'Visible', 'off');
        end

        viewKernelPanel('set', false);
        objKernelPanel = viewKernelPanelMenuObject('get');
        if ~isempty(objKernelPanel)
            objKernelPanel.Checked = 'off';
        end

        if switchToIsoSurface('get') == true

            switchToIsoSurface('set', false);

            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));  
        
            if switchTo3DMode('get')  == false && ...
               switchToMIPMode('get') == false

                view3DPanel('set', false);
                init3DPanel('set', true);

                obj3DPanel = view3DPanelMenuObject('get');
                if ~isempty(obj3DPanel)
                    obj3DPanel.Checked = 'off';
                end

                mPlay = playIconMenuObject('get');
                if ~isempty(mPlay)
                    mPlay.State = 'off';
       %             playIconMenuObject('set', '');
                end

                mRecord = recordIconMenuObject('get');
                if ~isempty(mRecord)
                    mRecord.State = 'off';
        %            recordIconMenuObject('set', '');
                end

                multiFrame3DPlayback('set', false);
                multiFrame3DRecord('set', false);
                multiFrame3DIndex('set', 1);
       %         setPlaybackToolbar('off');

                set(uiSeriesPtr('get'), 'Enable', 'on');

%                if numel(seriesDescription('get')) > 1
                    set(btnFusionPtr('get')    , 'Enable', 'on');
                    set(uiFusedSeriesPtr('get'), 'Enable', 'on');
%                end

                set(btnTriangulatePtr('get'), 'Enable', 'on');  
                set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
                set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            
                set(btnZoomPtr('get')    , 'Enable', 'on');
                set(btnPanPtr('get')     , 'Enable', 'on');                
                if numel(inputTemplate('get')) >1
                    set(btnRegisterPtr('get'), 'Enable', 'on');
                end

                set(btnVsplashPtr('get')   , 'Enable', 'on');
                set(uiEditVsplahXPtr('get'), 'Enable', 'on');
                set(uiEditVsplahYPtr('get'), 'Enable', 'on');

                set(btn3DPtr('get'), 'Enable', 'on');
                set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 

                set(btnMIPPtr('get'), 'Enable', 'on');
                set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 
                
                mOptions = optionsPanelMenuObject('get');
                if ~isempty(mOptions)
                    mOptions.Enable = 'on';
                end

%%%                deleteAlphaCurve('vol');

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', '');
                end

%%%                deleteAlphaCurve('mip');

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

                voiObj = voiObject('get');
                if ~isempty(voiObj)
                    for vv=1:numel(voiObj)
                        delete(voiObj{vv})
                    end
                    voiObject('set', '');
                end

                volFusionObj = volFusionObject('get');
                if ~isempty(volFusionObj)
                    delete(volFusionObj);
                    volFusionObject('set', '');
                end

                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    delete(isoFusionObj);
                    isoFusionObject('set', '');
                end

                mipFusionObj = mipFusionObject('get');
                if ~isempty(mipFusionObj)
                    delete(mipFusionObj);
                    mipFusionObject('set', '');
                end

                isoGateObj = isoGateObject('get');
                if ~isempty(isoGateObj)
                    for vv=1:numel(isoGateObj)
                        delete(isoGateObj{vv});
                    end
                    isoGateObject('set', '');
                end

                isoGateFusionObj = isoGateFusionObject('get');
                if ~isempty(isoGateFusionObj)
                    for vv=1:numel(isoGateFusionObj)
                        delete(isoGateFusionObj{vv});
                    end
                    isoGateFusionObject('set', '');
                end

                mipGateObj = mipGateObject('get');
                if ~isempty(mipGateObj)
                    for vv=1:numel(mipGateObj)
                        delete(mipGateObj{vv});
                    end
                    mipGateObject('set', '');
                end

                mipGateFusionObj = mipGateFusionObject('get');
                if ~isempty(mipGateFusionObj)
                    for vv=1:numel(mipGateFusionObj)
                        delete(mipGateFusionObj{vv});
                    end
                    mipGateFusionObject('set', '');
                end

                volGateObj = volGateObject('get');
                if ~isempty(volGateObj)
                    for vv=1:numel(volGateObj)
                        delete(volGateObj{vv})
                    end
                    volGateObject('set', '');
                end

                volGateFusionObj = volGateFusionObject('get');
                if ~isempty(volGateFusionObj)
                    for vv=1:numel(volGateFusionObj)
                        delete(volGateFusionObj{vv})
                    end
                    volGateFusionObject('set', '');
                end

                voiGateObj = voiGateObject('get');
                if ~isempty(voiGateObj)
                    for tt=1:numel(voiGateObj)
                        for ll=1:numel(voiGateObj{tt})
                            delete(voiGateObj{tt}{ll});
                        end
                    end
                    voiGateObject('set', '');
                end

                ui3DGateWindowObj = ui3DGateWindowObject('get');
                if ~isempty(ui3DGateWindowObj)
                    for vv=1:numel(ui3DGateWindowObj)
                        delete(ui3DGateWindowObj{vv})
                    end
                    ui3DGateWindowObject('set', '');
                end

                voi3DEnableList('set', '');
                voi3DTransparencyList('set', '');

                clearDisplay();
                initDisplay(3);

                dicomViewerCore();

                if isFusion('get')
                    tFuseInput    = inputTemplate('get');
                    iFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');
                    tFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                    setViewerDefaultColor(true, dicomMetaData('get'), tFuseMetaData);
                else
                    setViewerDefaultColor(true, dicomMetaData('get'));
                end

                refreshImages();

                setRoiToolbar('on');

%                       robotClick();

            else
                isoObj = isoObject('get');
                isoObj.Isovalue = 1;
                isoObject('set', isoObj);

                set(ui3DCreateIsoMaskPtr('get'), 'Enable', 'off');

                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    isoFusionObj.Isovalue = 1;
                    isoFusionObject('set', isoFusionObj);
                end
            end
        else

            switchToIsoSurface('set', true);

            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            
            set(uiSeriesPtr('get'), 'Enable', 'off');

            set(uiFusedSeriesPtr('get'), 'Enable', 'off');

            set(btnTriangulatePtr('get'), 'Enable', 'off');
            set(btnTriangulatePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnTriangulatePtr('get'), 'ForegroundColor', viewerForegroundColor('get')); 

            if switchTo3DMode('get')  == false && ...
               switchToMIPMode('get') == false

                if isFusion('get') == false
                    set(btnFusionPtr('get'), 'Enable', 'off');
                end

                surface3DPriority('set', 'Isosurface', 1);

                clearDisplay();
                initDisplay(1);

                setViewerDefaultColor(false, dicomMetaData('get'));

                isoObj = initVolShow(dicomBuffer('get'), uiOneWindowPtr('get'), 'Isosurface');
                set(isoObj, 'InteractionsEnabled', true);

                isoObject('set', isoObj);

                set(ui3DCreateIsoMaskPtr('get'), 'Enable', 'on');

                if isFusion('get')
                    isoFusionObj = initVolShow(fusionBuffer('get'), uiOneWindowPtr('get'), 'Isosurface');
                    set(isoFusionObj, 'InteractionsEnabled', false);

                    isoFusionObj.IsosurfaceColor  = surfaceColor('one', isoColorFusionOffset('get') );
                    isoFusionObj.Isovalue         = isoSurfaceFusionValue('get');

                    isoFusionObject('set', isoFusionObj);
                end

                if displayVoi('get') == true
                    voiObj = voiObject('get');
                    if isempty(voiObj)
                        voiObj = initVoiIsoSurface(uiOneWindowPtr('get'));
                        voiObject('set', voiObj);

                    else
                        for ll=1:numel(voiObj)
                            if displayVoi('get') == true
                                set(voiObj{ll}, 'Renderer', 'Isosurface');
                            else
                                set(voiObj{ll}, 'Renderer', 'LabelOverlayRendering');
                           end
                        end
                    end
                end

            %    setPlaybackToolbar('on');
                oneFrame3D();
                uiLogo = displayLogo(uiOneWindowPtr('get'));
                logoObject('set', uiLogo);
            else

                isoObj = isoObject('get');
                if ~isempty(isoObj)

                    set(isoObj, 'Isovalue', isoSurfaceValue('get') );
                    set(isoObj, 'IsosurfaceColor', surfaceColor('get', isoColorOffset('get')) );

                    isoObject('set', isoObj);
                    if get(ui3DVolumePtr('get'), 'Value') == 1 % Not Fusion
                        set(ui3DCreateIsoMaskPtr('get'), 'Enable', 'on');
                    end

                    isoFusionObj = isoFusionObject('get');
                    if ~isempty(isoFusionObj)&& isFusion('get') == true

                        set(isoFusionObj, 'Isovalue', isoSurfaceFusionValue('get'));
                        set(isoFusionObj, 'IsosurfaceColor', surfaceColor('get', isoColorFusionOffset('get')) );

                        isoFusionObject('set', isoFusionObj);
                    end
                else

                    if ~isempty(volObject('get')) && ...
                       ~isempty(mipObject('get'))
                        surface3DPriority('set', 'Isosurface', 3);
                    else
                        surface3DPriority('set', 'Isosurface', 2);
                    end

                    isoObj = initVolShow(dicomBuffer('get'), uiOneWindowPtr('get'), 'Isosurface');
                    set(isoObj, 'InteractionsEnabled', false);

                    isoObject('set', isoObj);

                    set(ui3DCreateIsoMaskPtr('get'), 'Enable', 'on');

                    if isFusion('get')
                        isoFusionObj = initVolShow(fusionBuffer('get'), uiOneWindowPtr('get'), 'Isosurface');
                        set(isoFusionObj, 'InteractionsEnabled', false);

                        isoFusionObj.IsosurfaceColor  = surfaceColor('one', isoColorFusionOffset('get') );
                        isoFusionObj.Isovalue         = isoSurfaceFusionValue('get');

                        isoFusionObject('set', isoFusionObj);
                    end
if 0
                    % Set 3D UI Panel

                    if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                        set(ui3DIsoSurfaceColorPtr('get') , 'Value' , isoColorFusionOffset('get') );
                        set(ui3DSliderIsoSurfacePtr('get'), 'Value' , isoSurfaceFusionValue('get'));
                        set(ui3DEditIsoSurfacePtr('get')  , 'String', num2str(isoSurfaceFusionValue('get')));
                    else
                        set(ui3DIsoSurfaceColorPtr('get') , 'Value' , isoColorOffset('get') );
                        set(ui3DSliderIsoSurfacePtr('get'), 'Value' , isoSurfaceValue('get'));
                        set(ui3DEditIsoSurfacePtr('get')  , 'String', num2str(isoSurfaceValue('get')));
                    end
end
                end

            end

        end
    end
end
