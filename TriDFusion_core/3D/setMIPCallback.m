function setMIPCallback(~, ~)
%function setMIPCallback(~, ~)
%Activate/Deactivate 3D MIP.
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

    dSeriesOffset      = get(uiSeriesPtr('get'), 'Value');
    dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

    if ~isempty(dicomBuffer('get', [], dSeriesOffset)) && ...
       size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        try
            
        sFusionBtnEnable = get(btnFusionPtr('get'), 'Enable');
           
        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');
            
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;
%                releaseRoiAxeWait();
        releaseRoiWait();

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        % set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
        set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));
            
        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnZoomPtr('get'), 'FontWeight', 'normal');
        set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_grey.png'));
        zoomTool('set', false);
        zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
        % set(btnPanPtr('get'), 'FontWeight', 'normal');
        set(btnPanPtr('get'), 'CData', resizeTopBarIcon('pan_grey.png'));
        panTool('set', false);
        panMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');     

        set(rotate3DMenu('get'), 'Checked', 'off');         
        rotate3DTool('set', false);
        rotate3d(fiMainWindowPtr('get'), 'off');

        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);              
        datacursormode(fiMainWindowPtr('get'), 'off');  

        setRoiToolbar('off');
        setPlotEditToolbar('off');

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

        if switchToMIPMode('get') == true

            % displayVoi('set', false);

            switchToMIPMode('set', false);
                
            set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            % set(btnMIPPtr('get'), 'FontWeight', 'normal');
            set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_grey.png'));
              
            if switchToIsoSurface('get') == false && ...
               switchTo3DMode('get')     == false           

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
          %          playIconMenuObject('set', '');
                end

                mRecord = recordIconMenuObject('get');
                if ~isempty(mRecord)
                    mRecord.State = 'off';
          %          recordIconMenuObject('set', '');
                end

                mOptions = optionsPanelMenuObject('get');
                if ~isempty(mOptions)
                    mOptions.Enable = 'on';
                end

                multiFrame3DPlayback('set', false);
                multiFrame3DRecord('set', false);
                multiFrame3DIndex('set', 1);
%                    setPlaybackToolbar('off');

 %               deleteAlphaCurve('vol');

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

                bFusion = isFusion('get');

                isFusion('set', false);

                link2DMip('set', true);

                set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
                set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
                % set(btnLinkMipPtr('get'), 'FontWeight', 'bold');
                set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_white.png'));

                clearDisplay();
                initDisplay(3);
               
                dicomViewerCore();


                % atMetaData = dicomMetaData('get');
                atMetaData = dicomMetaData('get', [], dSeriesOffset);

                if bFusion == true

                    atFuseMetaData = fusionMetaData('get', [], dFusedSeriesOffset);

                    setViewerDefaultColor(true, atMetaData, atFuseMetaData);

                    link2DMip('set', false);
        
                    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
                    % set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
                    set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_grey.png'));

                    setFusionCallback();
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
                setPlotEditToolbar('on');
                                
                % Reactivate main tool bar 
                set(uiSeriesPtr('get'), 'Enable', 'on');                        
                mainToolBarEnable('on');   
    
%                        robotClick();

            else

                if isempty(viewer3dObject('get'))

                    mipObj = mipObject('get');
                    mipObj.Alphamap = zeros(256, 1);
                    mipObject('set', mipObj);
    
                    mipFusionObj = mipFusionObject('get');
                    if ~isempty(mipFusionObj)
                        mipFusionObj.Alphamap = zeros(256,1);
                        mipFusionObject('set', mipFusionObj);
                    end
    
                    displayAlphaCurve(zeros(256,1), axe3DPanelMipAlphmapPtr('get'));
    
             %       deleteAlphaCurve('mip');
    
                    mipColorObj = mipColorObject('get');
                    if ~isempty(mipColorObj)
                        delete(mipColorObj);
                        mipColorObject('set', '');
                    end
    
                    if switchTo3DMode('get') == true
    
                     %   deleteAlphaCurve('vol');
    
                        volColorObj = volColorObject('get');
                        if ~isempty(volColorObj)
                            delete(volColorObj);
                            volColorObject('set', '');
    
                            if displayVolColorMap('get') == true
                                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
                                volColorObject('set', uivolColorbar);
                            end
                        end
                    end
                else

                    mipObj = mipObject('get');
                    set(mipObj, 'Visible', 'off');

                    mipFusionObj = mipFusionObject('get');
                    if ~isempty(mipFusionObj)
                        % if isFusion('get')
                            set(mipFusionObj, 'Visible', 'off');
                        % end
                    end            
                end

                set(btn3DPtr('get')        , 'Enable', 'on');                
                set(btnMIPPtr('get')       , 'Enable', 'on');
                set(btnIsoSurfacePtr('get'), 'Enable', 'on');

                set(btnFusionPtr('get'), 'Enable', sFusionBtnEnable);                  
            end
        else    

            switchToMIPMode('set', true);
               
            if switchToIsoSurface('get') == false && ...
                switchTo3DMode('get')    == false
            
                if isFusion('get') == true
                    init3DfusionBuffer();  
                end
            
                surface3DPriority('set', 'MaximumIntensityProjection', 1);
                
                isPlotContours('set', false);

                clearDisplay();
                initDisplay(1);

                setViewerDefaultColor(false, dicomMetaData('get'));

%                getMipAlphaMap('set', dicomBuffer('get'), 'auto');

      %          mipObject('set', '');

                % atMetaData = dicomMetaData('get');
                atMetaData = dicomMetaData('get', [], dSeriesOffset);

                if isFusion('get') == true

% if 1                    
                    % tFuseInput     = inputTemplate('get');
                    % iFuseOffset    = dFusedSeriesOffset;
                    atFuseMetaData = fusionMetaData('get', [], dFusedSeriesOffset);

                    if (strcmpi(atMetaData{1}.Modality, 'nm') || ...
                        strcmpi(atMetaData{1}.Modality, 'pt')) && ...
                       (strcmpi(atFuseMetaData{1}.Modality, 'nm') || ...
                        strcmpi(atFuseMetaData{1}.Modality, 'pt'))

%                        colorMapMipOffset('set', colorMapOffset('get')); %  % Set 3D Mip from 2D                        
                        background3DOffset('set', 7); % White
                    else
%                        colorMapMipOffset('set', colorMapOffset('get')); %  % Set 3D Mip from 2D                        
                        background3DOffset('set', 8); % Black
                    end
                else
          %          colorMapMipOffset('set', 10); % Gray
                    if (strcmpi(atMetaData{1}.Modality, 'nm') || ...
                        strcmpi(atMetaData{1}.Modality, 'pt'))
                    
%                        colorMapMipOffset('set', 11); % Invert Linear
                        background3DOffset('set', 7); % White
                    else
                        background3DOffset('set', 8); % Black
 %                       colorMapMipOffset('set', colorMapOffset('get')); %  % Set 3D Mip from 2D                        
                    end
% end
                end            
%                if (strcmpi(atMetaData{1}.Modality, 'nm') || ...
%                    strcmpi(atMetaData{1}.Modality, 'pt')) 
%                else        
                if  colorMapOffset('get') == 9 % Gray
                    colorMapMipOffset('set', 10); % Invert Linear
                else
                    colorMapMipOffset('set', colorMapOffset('get')); % Set 3D Mip from 2D
                end
%                end

                mipObj = initVolShow(squeeze(dicomBuffer('get', [], dSeriesOffset)), uiOneWindowPtr('get'), 'MaximumIntensityProjection', atMetaData);

                if isempty(viewer3dObject('get'))
                    set(mipObj, 'InteractionsEnabled', true);
                end

                mipObject('set', mipObj);

                if isFusion('get')
                    set(btnFusionPtr('get'), 'Enable', 'on');

%                    getMipFusionAlphaMap('set', fusionBuffer('get'), 'auto');

                    % tFuseInput     = inputTemplate('get');
                    % iFuseOffset    = dFusedSeriesOffset;
                    % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    % 
                    atFuseMetaData = fusionMetaData('get', [], dFusedSeriesOffset);

if 1

                    if (strcmpi(atFuseMetaData{1}.Modality, 'nm') || ...
                        strcmpi(atFuseMetaData{1}.Modality, 'pt')) && ...
                       (strcmpi(atMetaData{1}.Modality, 'nm') || ...
                        strcmpi(atMetaData{1}.Modality, 'pt'))

              %          colorMapMipFusionOffset('set', fusionColorMapOffset('get')); % Set 3D Mip from 2D
                        background3DOffset('set', 7); % White
                    else

                        background3DOffset('set', 8); % Black
                    end
                    
                    colorMapMipFusionOffset('set', fusionColorMapOffset('get')); % Set 3D Mip from 2D

                    set(ui3DBackgroundPtr('get'), 'Value', background3DOffset('get'));
end
                    
                 
                    mipFusionObj = initVolShow(squeeze(fusionBuffer('get', [], dFusedSeriesOffset)), uiOneWindowPtr('get'), 'MaximumIntensityProjection', atFuseMetaData);

                    if isempty(viewer3dObject('get'))
                        set(mipFusionObj, 'InteractionsEnabled', false);
                    end

                    [aAlphaMap, ~] = getMipFusionAlphaMap('get', fusionBuffer('get', [], dFusedSeriesOffset), atFuseMetaData);
                    mipFusionObj.Alphamap = aAlphaMap;

                    mipFusionObj.Colormap = get3DColorMap('one', colorMapMipFusionOffset('get'));
                    mipFusionObject('set', mipFusionObj);

                    if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                        ic = mipICFusionObject('get');
                        if ~isempty(ic)
                            ic.surfObj = mipFusionObj;
                        end
                    else
                        ic = mipICObject('get');
                        if ~isempty(ic)
                            ic.surfObj = mipObj;
                        end
                    end

                else
                    set(btnFusionPtr('get'), 'Enable', 'off');

                    ic = mipICObject('get');
                    if ~isempty(ic)
                        ic.surfObj = mipObj;
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

                if displayMIPColorMap('get') == true
                    uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
                    mipColorObject('set', uimipColorbar);
                end

     %           setPlaybackToolbar('on');
                oneFrame3D();
                flip3Dobject('right');                             
                uiLogo = displayLogo(uiOneWindowPtr('get'));
                logoObject('set', uiLogo);

            else
                    
                mipObj = mipObject('get');
                
                if ~isempty(mipObj)

                    if isempty(viewer3dObject('get'))
           
                        [aMap, sType] = getMipAlphaMap('get', dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset));
                        set(mipObj, 'Alphamap', aMap);
                        set(mipObj, 'Colormap', get3DColorMap('get', colorMapMipOffset('get') ));
    
                        mipObject('set', mipObj);
    
                        if get(ui3DVolumePtr('get'), 'Value') == 1
                            if strcmpi(sType, 'custom')
                                ic = customAlphaCurve(axe3DPanelMipAlphmapPtr('get'),  mipObj, 'mip');
                                ic.surfObj = mipObj;
    
                                mipICObject('set', ic);
                                alphaCurveMenu(axe3DPanelMipAlphmapPtr('get'), 'mip');
                            else
                                displayAlphaCurve(aMap, axe3DPanelMipAlphmapPtr('get'));
                            end
                        end
    
                        mipFusionObj = mipFusionObject('get');
                        if ~isempty(mipFusionObj) && isFusion('get') == true
    
                            % tFuseInput  = inputTemplate('get');
                            % iFuseOffset = dFusedSeriesOffset;
                            % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
    
                            atFuseMetaData = fusionMetaData('get', [], dFusedSeriesOffset);
    
                            [aFusionMap, sFusionType] = getMipFusionAlphaMap('get', fusionBuffer('get', [], dFusedSeriesOffset), atFuseMetaData);
    
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
    
                   %     deleteAlphaCurve('mip');
    
                        mipColorObj = mipColorObject('get');
                        if ~isempty(mipColorObj)
                            delete(mipColorObj);
                            mipColorObject('set', '');
                        end
    
                        if displayMIPColorMap('get') == true
    
                            if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipFusionOffset('get')));
                            else
                                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
                            end
    
                            mipColorObject('set', uimipColorbar);
                        end
                    else
                        mipObj = mipObject('get');
                        set(mipObj, 'Visible', 'on');
    
                        mipFusionObj = mipFusionObject('get');
                        if ~isempty(mipFusionObj)
                            if isFusion('get')
                                set(mipFusionObj, 'Visible', 'on');
                            end
                        end                     
                    end 

                else

                    if ~isempty(isoObject('get')) && ...
                       ~isempty(volObject('get'))

                        surface3DPriority('set', 'MaximumIntensityProjection', 3);
                    else
                        surface3DPriority('set', 'MaximumIntensityProjection', 2);
                    end
%                    getMipAlphaMap('set', dicomBuffer('get'), 'auto');
                    
                    atMetaData = dicomMetaData('get', [], dSeriesOffset);

                    mipObj = initVolShow(squeeze(dicomBuffer('get', [], dSeriesOffset)), uiOneWindowPtr('get'), 'MaximumIntensityProjection', atMetaData);

                    if isempty(viewer3dObject('get'))
                        set(mipObj, 'InteractionsEnabled', false);
                    end

                    mipObject('set', mipObj);

                    if isFusion('get')

%                        getMipFusionAlphaMap('set', fusionBuffer('get'), 'auto');

                        % tFuseInput     = inputTemplate('get');
                        % iFuseOffset    = dFusedSeriesOffset;
                        % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                        atFuseMetaData = fusionMetaData('get', [], dFusedSeriesOffset);

                        mipFusionObj = initVolShow(squeeze(fusionBuffer('get', [], dFusedSeriesOffset)), uiOneWindowPtr('get'), 'MaximumIntensityProjection', atFuseMetaData);

                        if isempty(viewer3dObject('get'))

                            set(mipFusionObj, 'InteractionsEnabled', false);
                        end

                        [aAlphaMap, ~] = getMipFusionAlphaMap('get', fusionBuffer('get', [], dFusedSeriesOffset), atFuseMetaData);

                        colorMapMipFusionOffset('set', fusionColorMapOffset('get')); % Set 3D Mip from 2D
                        mipFusionObj.Colormap = get3DColorMap('one', colorMapMipFusionOffset('get'));
                        mipFusionObj.Alphamap = aAlphaMap;

                        mipFusionObject('set', mipFusionObj);

                        if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                            ic = mipICFusionObject('get');
                            if ~isempty(ic)
                                ic.surfObj = mipFusionObj;
                            end
                        else
                            ic = mipICObject('get');
                            if ~isempty(ic)
                                ic.surfObj = mipObj;
                            end
                        end

                    else
                        ic = mipICObject('get');
                        if ~isempty(ic)
                            ic.surfObj = mipObj;
                        end
                    end

                    % Set 3D UI Panel

                    if get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion

                        mipFusionObj = mipFusionObject('get');
                        if ~isempty(mipFusionObj)

                            ic = mipICFusionObject('get');
                            if ~isempty(ic)
                                ic.surfObj = mipFusionObj;
                            end
                            % 
                            % tFuseInput     = inputTemplate('get');
                            % iFuseOffset    = dFusedSeriesOffset;
                            % atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                            atFuseMetaData = dicomMetaData('get', [], dFusedSeriesOffset);

                            [aMap, sType] = getMipFusionAlphaMap('get', fusionBuffer('get', [], dFusedSeriesOffset), atFuseMetaData);

                            [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, atFuseMetaData);

                            set(ui3DMipAlphamapTypePtr('get')  , 'Value' , dMipAlphaOffset);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', sMipMapSliderEnable);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Value' , mipLinearFuisonAlphaValue('get'));

                            if strcmpi(sType, 'custom')
                                ic = customAlphaCurve(axe3DPanelMipAlphmapPtr('get'),  mipFusionObj, 'mipfusion');
                                ic.surfObj = mipFusionObj;

                                mipICFusionObject('set', ic);

                                alphaCurveMenu(axe3DPanelMipAlphmapPtr('get'), 'mipfusion');
                            else
                                displayAlphaCurve(aMap, axe3DPanelMipAlphmapPtr('get'));
                            end

                            set(ui3DMipColormapPtr('get'), 'Value', colorMapMipFusionOffset('get'));

                        end
                    else
                        mipObj = mipObject('get');
                        if ~isempty(mipObj)
                            ic = mipICObject('get');
                            if ~isempty(ic)
                                ic.surfObj = mipObj;
                            end

                            % atMetaData = dicomMetaData('get');
                            atMetaData = dicomMetaData('get', [], dSeriesOffset);

                            [aMap, sType] = getMipAlphaMap('get', dicomBuffer('get', [], dSeriesOffset), atMetaData);

                            [dMipAlphaOffset, sMipMapSliderEnable] = ui3DPanelGetMipAlphaMapType(sType, atMetaData);

                            set(ui3DMipAlphamapTypePtr('get')  , 'Value' , dMipAlphaOffset);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', sMipMapSliderEnable);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Value' , mipLinearAlphaValue('get'));

                            if strcmpi(sType, 'custom')
                                ic = customAlphaCurve(axe3DPanelMipAlphmapPtr('get'),  mipObj, 'mip');
                                ic.surfObj = mipObj;

                                mipICObject('set', ic);

                                alphaCurveMenu(axe3DPanelMipAlphmapPtr('get'), 'mip');
                            else
                                displayAlphaCurve(aMap, axe3DPanelMipAlphmapPtr('get'));
                            end

                            set(ui3DMipColormapPtr('get'), 'Value', colorMapMipOffset('get'));

                        end
                    end

                    if displayMIPColorMap('get') == true
                        uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
                        mipColorObject('set', uimipColorbar);
                    end

                end

                set(btnFusionPtr('get'), 'Enable', sFusionBtnEnable);                                        
            end
            
            % Reactivate toolbar specific items 
            
            set(btnMIPPtr('get'), 'Enable', 'on');
            set(btnMIPPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnMIPPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            % set(btnMIPPtr('get'), 'FontWeight', 'bold');
            set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_white.png'));
           
            set(btn3DPtr('get'), 'Enable', 'on');
            set(btnIsoSurfacePtr('get'), 'Enable', 'on');          
        end

        if switchTo3DMode('get') == false && ...
           (switchToMIPMode('get') == true || ...
            switchToIsoSurface('get') == true)

            set(ui3DVolColormapPtr('get')      , 'Enable', 'off');
            set(ui3DVolAlphamapTypePtr('get')  , 'Enable', 'off');
            set(ui3DSliderVolLinAlphaPtr('get'), 'Enable', 'off');
        end

        if switchToMIPMode('get') == false && ...
           (switchTo3DMode('get') == true || ...
            switchToIsoSurface('get') == true)

            set(ui3DMipColormapPtr('get')      , 'Enable', 'off');
            set(ui3DMipAlphamapTypePtr('get')  , 'Enable', 'off');
            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', 'off');

            if isempty(viewer3dObject('get'))
                
                mipObj = mipObject('get');           
                set(mipObj, 'InteractionsEnabled', false);
                mipObject('set', mipObj);
            end


            if switchTo3DMode('get') == true && ...
               switchToIsoSurface('get') == true

                if surface3DPriority('get', 'VolumeRendering') < ...
                   surface3DPriority('get', 'Isosurface')

                    if isempty(viewer3dObject('get'))

                        volObj = volObject('get');
                        set(volObj, 'InteractionsEnabled', true);
                        volObject('set', volObj);
    
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', false);
                        isoObject('set', isoObj);
                    end
                else
                    if isempty(viewer3dObject('get'))

                        volObj = volObject('get');
                        set(volObj, 'InteractionsEnabled', false);
                        volObject('set', volObj);
    
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', true);
                        isoObject('set', isoObj);
                    end
                end
            else
                if isempty(viewer3dObject('get'))

                    if switchTo3DMode('get') == true
                        volObj = volObject('get');
                        set(volObj, 'InteractionsEnabled', true);
                        volObject('set', volObj);
                    end
    
                    if switchToIsoSurface('get') == true
                        isoObj = isoObject('get');
                        set(isoObj, 'InteractionsEnabled', true);
                        isoObject('set', isoObj);
                    end
                end
            end

        else
            if switchToMIPMode('get') == true

                set(ui3DMipColormapPtr('get')      , 'Enable', 'on');
                set(ui3DMipAlphamapTypePtr('get')  , 'Enable', 'on');

                uiMipAlphaMapType = ui3DMipAlphamapTypePtr('get');

                dAlphamapType  = get(uiMipAlphaMapType, 'Value');
                asAlphamapType = get(uiMipAlphaMapType, 'String');

                if strcmpi(asAlphamapType{dAlphamapType}, 'Linear')

                    set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', 'on');
                end
            end
        end

        catch ME   
            logErrorToFile(ME);
            progressBar(1, 'Error:setMIPCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end
end
