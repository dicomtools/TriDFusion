function set3DCallback(hObject, ~)      
%function set3DCallback(hObject, ~)   
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
        
    if numel(dicomBuffer('get')) && ...
       size(dicomBuffer('get'), 3) ~= 1
   
        sMatlabVersion = version();
        sMatlabVersion = extractBefore(sMatlabVersion,' ');

        bLightingIsSupported = false;
        if length(sMatlabVersion) > 3
            dMatlabVersion = str2double(sMatlabVersion(1:3));
            if dMatlabVersion >= 9.8
                 bLightingIsSupported = true;
            end
        end
    
%                releaseRoiAxeWait();
        releaseRoiWait();

        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', 'default');
        set(btnZoomPtr('get'), 'Enable', 'off');
        zoomTool('set', false);
        zoom('off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', 'default'); 
        set(btnPanPtr('get'), 'Enable', 'off');
        panTool('set', false);
        pan('off');  

    %    set(rotate3DMenu('get'), 'Checked', 'off');                       
        set(btnRegisterPtr('get'), 'BackgroundColor', 'default');
        set(btnRegisterPtr('get'), 'Enable', 'off');
        rotate3DTool('set', false);
        rotate3d('off');          

        set(btnVsplashPtr('get')   , 'Enable', 'off');
        set(uiEditVsplahXPtr('get'), 'Enable', 'off');
        set(uiEditVsplahYPtr('get'), 'Enable', 'off');

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

        if switchTo3DMode('get') == true
            switchTo3DMode('set', false);       

            set(hObject, 'Enable', 'on');
            set(hObject, 'BackgroundColor', 'default');                                        

            if switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false

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

                set(uiSeriesPtr('get'), 'Enable', 'on');

                if numel(seriesDescription('get')) > 1               
                    set(btnFusionPtr('get')    , 'Enable', 'on');
                    set(uiFusedSeriesPtr('get'), 'Enable', 'on');
                end

                set(btnZoomPtr('get')    , 'Enable', 'on');
                set(btnPanPtr('get')     , 'Enable', 'on');
                set(btnRegisterPtr('get'), 'Enable', 'on');                        

                set(btnVsplashPtr('get')   , 'Enable', 'on');
                set(uiEditVsplahXPtr('get'), 'Enable', 'on');
                set(uiEditVsplahYPtr('get'), 'Enable', 'on');

                set(btnTriangulatePtr('get'), 'Enable', 'on');
                set(btnTriangulatePtr('get'), 'BackgroundColor', 'white');

                set(btnIsoSurfacePtr('get'), 'Enable', 'on');
                set(btnIsoSurfacePtr('get'), 'BackgroundColor', 'default');

                set(btnMIPPtr('get'), 'Enable', 'on');
                set(btnMIPPtr('get'), 'BackgroundColor', 'default');   

                mOptions = optionsPanelMenuObject('get');
                if ~isempty(mOptions)
                    mOptions.Enable = 'on';
                end

%                deleteAlphaCurve('vol');

                volColorObj = volColorObject('get');
                if ~isempty(volColorObj)
                    delete(volColorObj);
                    volColorObject('set', '');                       
                end                    

%                deleteAlphaCurve('mip');                        

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

                clearDisplay();                    
                initDisplay(3);  

                dicomViewerCore();
                
                if isFusion('get')                              
                    tFuseInput    = inputTemplate('get');
                    iFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');   
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    
                    setViewerDefaultColor(true, dicomMetaData('get'), atFuseMetaData);
                else                    
                    setViewerDefaultColor(true, dicomMetaData('get'));
                end

                refreshImages();

                setRoiToolbar('on');

%                        robotClick();                       
            else                        
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
            end
        else

            switchTo3DMode('set', true);

            set(hObject, 'Enable', 'on');
            set(hObject, 'BackgroundColor', 'White');
            
            set(uiSeriesPtr('get'), 'Enable', 'off');

%            set(btnFusionPtr('get')    , 'Enable', 'off');
            set(uiFusedSeriesPtr('get'), 'Enable', 'off');

            set(btnTriangulatePtr('get'), 'Enable', 'off');
            set(btnTriangulatePtr('get'), 'BackgroundColor', 'default');

            if switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false
           
                if isFusion('get') == false
                    set(btnFusionPtr('get'), 'Enable', 'off');
                end
                
                surface3DPriority('set', 'VolumeRendering', 1);  

                clearDisplay();                    
                initDisplay(1); 
                
%                getVolAlphaMap('set', dicomBuffer('get'), 'auto');
                
                setViewerDefaultColor(false, dicomMetaData('get'));

                volObj = initVolShow(dicomBuffer('get'), uiOneWindowPtr('get'), 'VolumeRendering', dicomMetaData('get'));                               
                set(volObj, 'InteractionsEnabled', true);
                
                volObject('set', volObj);
                
                if isFusion('get')          
                    
%                    getVolFusionAlphaMap('set', fusionBuffer('get'), 'auto');
                
                    tFuseInput  = inputTemplate('get');
                    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                    atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    
                    volFusionObj = initVolShow(fusionBuffer('get'), uiOneWindowPtr('get'), 'VolumeRendering', atFuseMetaData);
                    set(volFusionObj, 'InteractionsEnabled', false);
                    
                    [aAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);
                    set(volFusionObj, 'Alphamap', aAlphaMap );
                    set(volFusionObj, 'Colormap', get3DColorMap('get', colorMapVolFusionOffset('get') ));
                                            
                    if bLightingIsSupported == true
                        set(volFusionObj, 'Lighting', volFusionLighting('get') );                        
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
                    ic = volICObject('get');
                    if ~isempty(ic)
                        ic.surfObj = volObj;                      
                    end
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

                if displayVolColorMap('get') == true                       
                    uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')));
                    volColorObject('set', uivolColorbar);                               
                end                       

                oneFrame3D();
                uiLogo = displayLogo(uiOneWindowPtr('get'));
                logoObject('set', uiLogo);

            else

                volObj = volObject('get'); 

                if ~isempty(volObj)
                    [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get'), dicomMetaData('get'));
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
                            displayAlphaCurve(aMap, axe3DPanelMipAlphmapPtr('get'));                                                                           
                        end
                    end
                        
                    volFusionObj = volFusionObject('get'); 
                    if ~isempty(volFusionObj) && isFusion('get') == true
                        tFuseInput  = inputTemplate('get');
                        iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                        atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                        
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
                    if switchToIsoSurface('get') == true && ...
                       switchToMIPMode('get')    == true
                        surface3DPriority('set', 'VolumeRendering', 3);                         
                    else
                        surface3DPriority('set', 'VolumeRendering', 2);                         
                    end
                    
%                    getVolAlphaMap('set', dicomBuffer('get'), 'auto');
                    
                    volObj = initVolShow(dicomBuffer('get'), uiOneWindowPtr('get'), 'VolumeRendering', dicomMetaData('get'));
                    set(volObj, 'InteractionsEnabled', false);
                    
                    volObject('set', volObj);
                    
                    if isFusion('get')           
                        
%                        getVolFusionAlphaMap('set', fusionBuffer('get'), 'auto');
                      
                        tFuseInput  = inputTemplate('get');
                        iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                        atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
                    
                        volFusionObj = initVolShow(fusionBuffer('get'), uiOneWindowPtr('get'), 'VolumeRendering', atFuseMetaData);
                        set(volFusionObj, 'InteractionsEnabled', false);
                        
                        [aAlphaMap, ~] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);
                        
                        set(volFusionObj, 'Alphamap', aAlphaMap );
                        set(volFusionObj, 'Colormap', get3DColorMap('get', colorMapVolFusionOffset('get') ));
                        
                        if bLightingIsSupported == true
                            volFusionObj.Lighting = volFusionLighting('get');
                            set(volFusionObj, 'Lighting', volFusionLighting('get') );
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
                            
                            tFuseInput  = inputTemplate('get');
                            iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');   
                            atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                            [aMap, sType] = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);

                            [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atFuseMetaData);

                            set(ui3DVolAlphamapTypePtr('get')  , 'Value' , dVolAlphaOffset);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', sVolMapSliderEnable);               
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Value' , volLinearFusionAlphaValue('get'));

                            if strcmpi(sType, 'custom')
                                
                                ic = customAlphaCurve(axe3DPanelVolAlphmapPtr('get'), volFusionObj, 'volfusion');            
                                ic.surfObj = volFusionObj;  

                                volICFusionObject('set', ic);

                                alphaCurveMenu(axe3DPanelVolAlphmapPtr('get'), 'volfusion');
                            else
                                displayAlphaCurve(aMap, axe3DPanelVolAlphmapPtr('get'));                
                            end

                            set(ui3DVolColormapPtr('get') , 'Value', colorMapVolFusionOffset('get'));
                            if bLightingIsSupported == true
                                set(chk3DVolLightingPtr('get'), 'Value', volFusionLighting('get'));               
                            end
                        end                        
                    else
                        volObj = volObject('get');
                        if ~isempty(volObj)
                            
                            ic = volICObject('get');
                            if ~isempty(ic)                            
                                ic.surfObj = volObj;                
                            end
                            
                            atMetaData = dicomMetaData('get');

                            [aMap, sType] = getVolAlphaMap('get', dicomBuffer('get'), atMetaData);

                            [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atMetaData);

                            set(ui3DVolAlphamapTypePtr('get')  , 'Value' , dVolAlphaOffset);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Enable', sVolMapSliderEnable);
                            set(ui3DSliderMipLinAlphaPtr('get'), 'Value' , volLinearAlphaValue('get'));

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
            end

        end
    end

end             
