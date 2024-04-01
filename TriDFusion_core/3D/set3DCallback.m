function set3DCallback(~, ~)
%function set3DCallback(~, ~)
%Activate/Deactivate 3D Volume.
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

    if numel(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
       size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

        % try
            
        sFusionBtnEnable = get(btnFusionPtr('get'), 'Enable');
            
        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');
            
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        bLightingIsSupported = true;
        if verLessThan('matlab','9.8')
            bLightingIsSupported = false;                    
        end

%                releaseRoiAxeWait();
        releaseRoiWait();

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
            
        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnZoomPtr('get'), 'FontWeight', 'normal');
        zoomTool('set', false);
        zoom(fiMainWindowPtr('get'), 'off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
        set(btnPanPtr('get'), 'FontWeight', 'normal');
        panTool('set', false);
        pan(fiMainWindowPtr('get'), 'off');     

        set(rotate3DMenu('get'), 'Checked', 'off');         
        rotate3DTool('set', false);
        rotate3d(fiMainWindowPtr('get'), 'off');

        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);              
        datacursormode(fiMainWindowPtr('get'), 'off');  

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

        mOptions = optionsPanelMenuObject('get');
        if ~isempty(mOptions)
            mOptions.Enable = 'off';
        end

        uiSegMainPanel = uiSegMainPanelPtr('get');
        if ~isempty(uiSegMainPanel)
            set(uiSegMainPanel, 'Visible', 'off');
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

        uiRoiMainPanel = uiRoiMainPanelPtr('get');
        if ~isempty(uiRoiMainPanel)
            set(uiRoiMainPanel, 'Visible', 'off');
        end

        viewRoiPanel('set', false);
        objRoiPanel = viewRoiPanelMenuObject('get');
        if ~isempty(objRoiPanel)
            objRoiPanel.Checked = 'off';
        end

        if switchTo3DMode('get') == true

            switchTo3DMode('set', false);
            
            set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));   
            set(btn3DPtr('get'), 'FontWeight', 'normal');
                
            if switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false

                displayVoi('set', false);
                        
                view3DPanel('set', false);
                init3DPanel('set', true);

                obj3DPanel = view3DPanelMenuObject('get');
                if ~isempty(obj3DPanel)
                    obj3DPanel.Checked = 'off';
                end

                mPlay = playIconMenuObject('get');
                if ~isempty(mPlay)
                    mPlay.State = 'off';
        %            playIconMenuObject('set', '');
                end

                mRecord = recordIconMenuObject('get');
                if ~isempty(mRecord)
                    mRecord.State = 'off';
      %              recordIconMenuObject('set', '');
                end

                multiFrame3DPlayback('set', false);
                multiFrame3DRecord  ('set', false);
                multiFrame3DIndex   ('set', 1);
%                     setPlaybackToolbar('off');

                mOptions = optionsPanelMenuObject('get');
                if ~isempty(mOptions)
                    mOptions.Enable = 'on';
                end

%                deleteAlphaCurve('vol');

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', []);
                end

%                deleteAlphaCurve('mip');

                mipColorObj = mipColorObject('get');
                if ~isempty(mipColorObj)
                    delete(mipColorObj);
                    mipColorObject('set', []);
                end

                logoObj = logoObject('get');
                if ~isempty(logoObj)
                    delete(logoObj);
                    logoObject('set', []);
                end

                volObj = volObject('get');
                if ~isempty(volObj)
                    delete(volObj);
                    volObject('set', []);
                end

                isoObj = isoObject('get');
                if ~isempty(isoObj)
                    delete(isoObj);
                    isoObject('set', []);
                end

                mipObj = mipObject('get');
                if ~isempty(mipObj)
                    delete(mipObj);
                    mipObject('set', []);
                end

                voiObj = voiObject('get');
                if ~isempty(voiObj)
                    for vv=1:numel(voiObj)
                        delete(voiObj{vv})
                    end
                    voiObject('set', []);
                end

                volFusionObj = volFusionObject('get');
                if ~isempty(volFusionObj)
                    delete(volFusionObj);
                    volFusionObject('set', []);
                end

                isoFusionObj = isoFusionObject('get');
                if ~isempty(isoFusionObj)
                    delete(isoFusionObj);
                    isoFusionObject('set', []);
                end

                mipFusionObj = mipFusionObject('get');
                if ~isempty(mipFusionObj)
                    delete(mipFusionObj);
                    mipFusionObject('set', []);
                end

                isoGateObj = isoGateObject('get');
                if ~isempty(isoGateObj)
                    for vv=1:numel(isoGateObj)
                        delete(isoGateObj{vv});
                    end
                    isoGateObject('set', []);
                end

                isoGateFusionObj = isoGateFusionObject('get');
                if ~isempty(isoGateFusionObj)
                    for vv=1:numel(isoGateFusionObj)
                        delete(isoGateFusionObj{vv});
                    end
                    isoGateFusionObject('set', []);
                end

                mipGateObj = mipGateObject('get');
                if ~isempty(mipGateObj)
                    for vv=1:numel(mipGateObj)
                        delete(mipGateObj{vv});
                    end
                    mipGateObject('set', []);
                end

                mipGateFusionObj = mipGateFusionObject('get');
                if ~isempty(mipGateFusionObj)
                    for vv=1:numel(mipGateFusionObj)
                        delete(mipGateFusionObj{vv});
                    end
                    mipGateFusionObject('set', []);
                end

                volGateObj = volGateObject('get');
                if ~isempty(volGateObj)
                    for vv=1:numel(volGateObj)
                        delete(volGateObj{vv})
                    end
                    volGateObject('set', []);
                end

                volGateFusionObj = volGateFusionObject('get');
                if ~isempty(volGateFusionObj)
                    for vv=1:numel(volGateFusionObj)
                        delete(volGateFusionObj{vv})
                    end
                    volGateFusionObject('set', []);
                end

                voiGateObj = voiGateObject('get');
                if ~isempty(voiGateObj)
                    for tt=1:numel(voiGateObj)
                        for ll=1:numel(voiGateObj{tt})
                            delete(voiGateObj{tt}{ll});
                        end
                    end
                    voiGateObject('set', []);
                end

                ui3DGateWindowObj = ui3DGateWindowObject('get');
                if ~isempty(ui3DGateWindowObj)
                    for vv=1:numel(ui3DGateWindowObj)
                        delete(ui3DGateWindowObj{vv})
                    end
                    ui3DGateWindowObject('set', []);
                end

                ptrViewer3d = viewer3dObject('get');
                if ~isempty(ptrViewer3d)
                    delete(ptrViewer3d);
                    viewer3dObject('set', []);

                    set(uiOneWindowPtr('get'), 'AutoResizeChildren', 'off');
                end
                
                voi3DEnableList('set', '');
                voi3DTransparencyList('set', '');

                clearDisplay();
                initDisplay(3);
                
                link2DMip('set', true);

                set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
                set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
                set(btnLinkMipPtr('get'), 'FontWeight', 'bold');
               
                dicomViewerCore();
                
                % atMetaData = dicomMetaData('get');
                atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

                if isFusion('get')

                    % tFuseInput    = inputTemplate('get');
                    % iFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');
                    % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                    atFuseMetaData = fusionMetaData('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                    setViewerDefaultColor(true, atMetaData, atFuseMetaData);
                else
                    setViewerDefaultColor(true, atMetaData);
                end
                
                triangulateCallback();
                
                refreshImages();
                
%                if strcmpi(atMetaData{1}.Modality, 'ct')
%                    link2DMip('set', false);

%                    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%                    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));         
%                end 
    
                setRoiToolbar('on');
                
                % Reactivate main tool bar 
                set(uiSeriesPtr('get'), 'Enable', 'on');                        
                mainToolBarEnable('on');  
                
%                        robotClick();
            else

                if isempty(viewer3dObject('get'))

                    volObj = volObject('get');
                    volObj.Alphamap = zeros(256,1);
                    volObject('set', volObj);
    
                    volFusionObj = volFusionObject('get');
                    if ~isempty(volFusionObj)
                        volFusionObj.Alphamap = zeros(256,1);
                        volFusionObject('set', volFusionObj);
                    end
    
                    displayAlphaCurve(zeros(256,1), axe3DPanelVolAlphmapPtr('get'));
    
               %     deleteAlphaCurve('vol');
    
                    volColorObj = volColorObject('get');
                    if ~isempty(volColorObj)
    
                        delete(volColorObj);
                        volColorObject('set', '');
                    end
    
                    if switchToMIPMode('get') == true
    
                 %       deleteAlphaCurve('mip');
    
                        mipColorObj = mipColorObject('get');
                        if ~isempty(mipColorObj)
                            delete(mipColorObj);
                            mipColorObject('set', '');
    
                            if displayMIPColorMap('get') == true
                                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
                                mipColorObject('set', uimipColorbar);
                            end
                        end
                    end
                else
                    volObj = volObject('get');
                    set(volObj, 'Visible', 'off');

                    volFusionObj = volFusionObject('get');
                    if ~isempty(volFusionObj)
                        % if isFusion('get')
                            set(volFusionObj, 'Visible', 'off');
                        % end
                    end                         
                end    

                set(btn3DPtr('get')        , 'Enable', 'on');                
                set(btnMIPPtr('get')       , 'Enable', 'on');
                set(btnIsoSurfacePtr('get'), 'Enable', 'on');

                set(btnFusionPtr('get'), 'Enable', sFusionBtnEnable);   
            
            end
        else                
            switchTo3DMode('set', true);
            
            if switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false
           
                if isFusion('get') == true
                    init3DfusionBuffer();  
                end
            
                if isFusion('get') == false
                    set(btnFusionPtr('get')    , 'Enable', 'off');
                end

                surface3DPriority('set', 'VolumeRendering', 1);

                isPlotContours('set', false);
        
                clearDisplay();
                initDisplay(1);

%                getVolAlphaMap('set', dicomBuffer('get'), 'auto');

                setViewerDefaultColor(false, dicomMetaData('get'));

                atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

                volObj = initVolShow(squeeze(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))), uiOneWindowPtr('get'), 'VolumeRendering', atMetaData);

                if isempty(viewer3dObject('get'))
                    set(volObj, 'InteractionsEnabled', true);
                end

                volObject('set', volObj);

                if isFusion('get')
                    
                    set(btnFusionPtr('get'), 'Enable', 'on');

%                    getVolFusionAlphaMap('set', fusionBuffer('get'), 'auto');

                    % tFuseInput  = inputTemplate('get');
                    % iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                    % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                    atFuseMetaData = fusionMetaData('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                    volFusionObj = initVolShow(squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'))), uiOneWindowPtr('get'), 'VolumeRendering', atFuseMetaData);

                    if isempty(viewer3dObject('get'))
                        set(volFusionObj, 'InteractionsEnabled', false);
                    end

                    [aAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);
                    set(volFusionObj, 'Alphamap', aAlphaMap );
                    set(volFusionObj, 'Colormap', get3DColorMap('get', colorMapVolFusionOffset('get') ));

                    if isempty(viewer3dObject('get'))

                        if bLightingIsSupported == true

                            set(volFusionObj, 'Lighting', volFusionLighting('get') );
                        end
                    end

                    volFusionObject('set', volFusionObj);

                    if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                        ic = volICFuisonObject('get');
                        if ~isempty(ic)
                            ic.surfObj = volFusionObj;
                        end
                    else
                        ic = volICObject('get');
                        if ~isempty(ic)
                            ic.surfObj = volObj;
                        end
                    end
                else
                    set(btnFusionPtr('get'), 'Enable', 'off');
                    
                    ic = volICObject('get');
                    if ~isempty(ic)
                        ic.surfObj = volObj;
                    end
                end

                if displayVoi('get') == true
                    voiObj = voiObject('get');
                    if isempty(voiObj)

                        voiObj = initVoiIsoSurface(uiOneWindowPtr('get'), voi3DSmooth('get'));
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

                if displayVolColorMap('get') == true
                    uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')));
                    volColorObject('set', uivolColorbar);
                end

                oneFrame3D();
                flip3Dobject('right');                             
                uiLogo = displayLogo(uiOneWindowPtr('get'));
                logoObject('set', uiLogo);

            else

                volObj = volObject('get');

                if ~isempty(volObj)

                    if isempty(viewer3dObject('get'))

                        [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value')));
                        set(volObj, 'Alphamap', aMap);
                        set(volObj, 'Colormap', get3DColorMap('get', colorMapVolOffset('get') ));
    
                        volObject('set', volObj);
    
                        if get(ui3DVolumePtr('get'), 'Value') == 1
                            if strcmpi(sType, 'custom')
                                ic = customAlphaCurve(axe3DPanelVolAlphmapPtr('get'),  volObj, 'vol');
                                ic.surfObj = volObj;
    
                                volICObject('set', ic);
                                alphaCurveMenu(axe3DPanelVolAlphmapPtr('get'), 'vol');
                            else
                                displayAlphaCurve(aMap, axe3DPanelVolAlphmapPtr('get'));
                            end
                        end
    
                        volFusionObj = volFusionObject('get');
                        if ~isempty(volFusionObj) && isFusion('get') == true
    
                            % tFuseInput  = inputTemplate('get');
                            % iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                            % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
    
                            atFuseMetaData = fusionMetaData('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
    
                            [aFusionMap, sFusionType] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);
    
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
                                    displayAlphaCurve(aFusionMap, axe3DPanelVolAlphmapPtr('get'));
                                end
                            end
    
                        end
    
    
                  %      deleteAlphaCurve('vol');
    
                        volColorObj = volColorObject('get');
                        if ~isempty(volColorObj)
                            delete(volColorObj);
                            volColorObject('set', '');
                        end
    
                        if displayVolColorMap('get') == true
    
                            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolFusionOffset('get')) );
                            else
                                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
                            end
    
                            volColorObject('set', uivolColorbar);
                        end
                    else
                        volObj = volObject('get');
                        set(volObj, 'Visible', 'on');
    
                        volFusionObj = volFusionObject('get');
                        if ~isempty(volFusionObj)
                            if isFusion('get')
                                set(volFusionObj, 'Visible', 'on');
                            end
                        end                         
                    end
                else
                    if ~isempty(isoObject('get')) && ...
                       ~isempty(mipObject('get'))
                        surface3DPriority('set', 'VolumeRendering', 3);
                    else
                        surface3DPriority('set', 'VolumeRendering', 2);
                    end

%                    getVolAlphaMap('set', dicomBuffer('get'), 'auto');

                    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

                    volObj = initVolShow(squeeze(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'))), uiOneWindowPtr('get'), 'VolumeRendering', atMetaData);

                    if isempty(viewer3dObject('get'))
                        set(volObj, 'InteractionsEnabled', false);
                    end

                    volObject('set', volObj);

                    if isFusion('get')

%                        getVolFusionAlphaMap('set', fusionBuffer('get'), 'auto');

                        % tFuseInput  = inputTemplate('get');
                        % iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                        % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                        atFuseMetaData = fusionMetaData('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                        volFusionObj = initVolShow(squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'))), uiOneWindowPtr('get'), 'VolumeRendering', atFuseMetaData);

                        if isempty(viewer3dObject('get'))
                            set(volFusionObj, 'InteractionsEnabled', false);
                        end

                        [aAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                        set(volFusionObj, 'Alphamap', aAlphaMap );
                        set(volFusionObj, 'Colormap', get3DColorMap('get', colorMapVolFusionOffset('get') ));

                        if isempty(viewer3dObject('get'))
    
                            if bLightingIsSupported == true
    
                                % volFusionObj.Lighting = volFusionLighting('get');
                                set(volFusionObj, 'Lighting', volFusionLighting('get') );
                            end
                        end
                        
                        volFusionObject('set', volFusionObj);

                        if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                            ic = volICFusionObject('get');
                            if ~isempty(ic)
                                ic.surfObj = volFusionObj;
                            end
                        else
                            ic = volICObject('get');
                            if ~isempty(ic)
                                ic.surfObj = volObj;
                            end
                        end

                    else
                        ic = volICObject('get');
                        if ~isempty(ic)
                            ic.surfObj = volObj;
                        end
                    end

                    % Set 3D UI Panel

                    if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion

                        volFusionObj = volFusionObject('get');
                        if ~isempty(volFusionObj)

                            ic = volICFusionObject('get');
                            if ~isempty(ic)
                                ic.surfObj = volFusionObj;
                            end

                            % tFuseInput  = inputTemplate('get');
                            % iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
                            % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                            atFuseMetaData = fusionMetaData('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                            [aMap, sType] = getVolFusionAlphaMap('get', fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), atFuseMetaData);

                            [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atFuseMetaData);

                            set(ui3DVolAlphamapTypePtr('get')  , 'Value' , dVolAlphaOffset);
                            set(ui3DSliderVolLinAlphaPtr('get'), 'Enable', sVolMapSliderEnable);
                            set(ui3DSliderVolLinAlphaPtr('get'), 'Value' , volLinearFusionAlphaValue('get'));

                            if strcmpi(sType, 'custom')

                                ic = customAlphaCurve(axe3DPanelVolAlphmapPtr('get'), volFusionObj, 'volfusion');
                                ic.surfObj = volFusionObj;

                                volICFusionObject('set', ic);

                                alphaCurveMenu(axe3DPanelVolAlphmapPtr('get'), 'volfusion');
                            else
                                displayAlphaCurve(aMap, axe3DPanelVolAlphmapPtr('get'));
                            end

                            set(ui3DVolColormapPtr('get') , 'Value', colorMapVolFusionOffset('get'));

                            if isempty(viewer3dObject('get'))
   
                                if bLightingIsSupported == true

                                    set(chk3DVolLightingPtr('get'), 'Value', volFusionLighting('get'));
                                end
                            end
                        end
                    else
                        volObj = volObject('get');
                        if ~isempty(volObj)

                            ic = volICObject('get');
                            if ~isempty(ic)
                                ic.surfObj = volObj;
                            end

                            atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

                            [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), atMetaData);

                            [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atMetaData);

                            set(ui3DVolAlphamapTypePtr('get')  , 'Value' , dVolAlphaOffset);
                            set(ui3DSliderVolLinAlphaPtr('get'), 'Enable', sVolMapSliderEnable);
                            set(ui3DSliderVolLinAlphaPtr('get'), 'Value' , volLinearAlphaValue('get'));

                            if strcmpi(sType, 'custom')

                                ic = customAlphaCurve(axe3DPanelVolAlphmapPtr('get'),  volObj, 'vol');
                                ic.surfObj = volObj;

                                volICObject('set', ic);

                                alphaCurveMenu(axe3DPanelVolAlphmapPtr('get'), 'vol');
                            else
                                displayAlphaCurve(aMap, axe3DPanelVolAlphmapPtr('get'));
                            end

                            set(ui3DVolColormapPtr('get') , 'Value', colorMapVolOffset('get'));
                            if bLightingIsSupported == true
                                set(chk3DVolLightingPtr('get'), 'Value', volLighting('get'));
                            end
                        end
                    end

                    if displayVolColorMap('get') == true
                        uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
                        volColorObject('set', uivolColorbar);
                    end
                end
                
                set(btnFusionPtr('get'), 'Enable', sFusionBtnEnable);                                        
            end
            
            % Reactivate toolbar specific items 
            
            set(btn3DPtr('get'), 'Enable', 'on');
            set(btn3DPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btn3DPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            set(btn3DPtr('get'), 'FontWeight', 'bold');

            set(btnMIPPtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'Enable', 'on');
                 
        end

        if switchToMIPMode('get') == false && ...
           (switchTo3DMode('get') == true || ...
            switchToIsoSurface('get') == true)

            set(ui3DMipColormapPtr('get')      , 'Enable', 'off');
            set(ui3DMipAlphamapTypePtr('get')  , 'Enable', 'off');
            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', 'off');
        end

        if switchTo3DMode('get') == false && ...
           (switchToMIPMode('get') == true || ...
            switchToIsoSurface('get') == true)

            set(ui3DVolColormapPtr('get')      , 'Enable', 'off');
            set(ui3DVolAlphamapTypePtr('get')  , 'Enable', 'off');
            set(ui3DSliderVolLinAlphaPtr('get'), 'Enable', 'off');

            if isempty(viewer3dObject('get'))

                volObj = volObject('get');
                set(volObj, 'InteractionsEnabled', false);
                volObject('set', volObj);
            end

            if switchToMIPMode('get') == true && ...
               switchToIsoSurface('get') == true
                if surface3DPriority('get', 'MaximumIntensityProjection') < ...
                   surface3DPriority('get', 'Isosurface')

                    if isempty(viewer3dObject('get'))
    
                        mipObj = mipObject('get');
                        set(mipObj, 'InteractionsEnabled', true);
                        mipObject('set', mipObj);
    
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', false);
                        isoObject('set', isoObj);
                    end
                else
                    if isempty(viewer3dObject('get'))

                        mipObj = mipObject('get');
                        set(mipObj, 'InteractionsEnabled', false);
                        mipObject('set', mipObj);
    
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', true);
                        isoObject('set', isoObj);
                    end
                end
            else
                if isempty(viewer3dObject('get'))
                    if switchToMIPMode('get') == true
                        mipObj = mipObject('get');
                        set(mipObj, 'InteractionsEnabled', true);
                        mipObject('set', mipObj);
                    end
    
                    if switchToIsoSurface('get') == true
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', true);
                        isoObject('set', isoObj);
                    end
                end
            end

        else
            if switchTo3DMode('get') == true
                set(ui3DVolColormapPtr('get')      , 'Enable', 'on');
                set(ui3DVolAlphamapTypePtr('get')  , 'Enable', 'on');

                uiVolumeAlphaMapType = ui3DVolAlphamapTypePtr('get');

                dAlphamapType  = get(uiVolumeAlphaMapType, 'Value');
                asAlphamapType = get(uiVolumeAlphaMapType, 'String');

                if strcmpi(asAlphamapType{dAlphamapType}, 'Linear')

                    set(ui3DSliderVolLinAlphaPtr('get'), 'Enable', 'on');
                end

            end
        end
        % 
        % catch
        %     progressBar(1, 'Error:set3DCallback()');
        % end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end
end
