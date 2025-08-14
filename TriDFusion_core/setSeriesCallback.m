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
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if dSeriesOffset <= numel(tInput)
        
        try
        isColorbarDefaultUnit('reset');
        isFusionColorbarDefaultUnit('reset');

        set(uiSeriesPtr('get'), 'Enable', 'off');                

        % Deactivate main tool bar 
        
        mainToolBarEnable('off');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        % suvMenuUnitOption('set', true);

        % Restore ISOsurface default value. Those value will be use in
        % setIsoSurfaceCallback(~, ~). 

        isoColorOffset        ('set', defaultIsoColorOffset('get') ); 
        isoSurfaceValue       ('set', defaultIsoSurfaceValue('get')); 
        isoColorFusionOffset  ('set', defaultIsoColorFusionOffset('get')); 
        isoSurfaceFusionValue ('set', defaultIsoSurfaceFusionValue('get'));        
    
        if isFusion('get') == true % Deactivate fusion
            
            isFusion('set', false);
            
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            % set(btnFusionPtr('get'), 'FontWeight', 'normal');
            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));
         
%             delete(uiFusionSliderWindowPtr('get'));
%             delete(uiFusionSliderLevelPtr('get'));

            delete(lineFusionColorbarIntensityMaxPtr('get'));
            delete(lineFusionColorbarIntensityMinPtr('get'));
    
            delete(textFusionColorbarIntensityMaxPtr('get'));
            delete(textFusionColorbarIntensityMinPtr('get'));

            delete(axeFusionColorbarPtr('get'));

            delete(uiFusionColorbarPtr('get'));
            delete(uiAlphaSliderPtr('get'));

            uiFusionColorbarPtr    ('set', '');
%             uiFusionSliderWindowPtr('set', '');
%             uiFusionSliderLevelPtr ('set', '');
            uiAlphaSliderPtr       ('set', '');                  
            
            if size(dicomBuffer('get'), 3) == 1
                
                imAxeFcPtr('reset');                                
                imAxeFPtr ('reset');                                
                axefPtr   ('reset');
                axefcPtr  ('reset');
                
                axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                if ~isempty(axe)                        
                    alpha( axe, 1);                
                end
            else
                imCoronalFcPtr ('reset');                
                imSagittalFcPtr('reset');                
                imAxialFcPtr   ('reset');
                
                imCoronalFPtr ('reset');                
                imSagittalFPtr('reset');                
                imAxialFPtr   ('reset');                
               
                axes1fPtr('reset');
                axes2fPtr('reset');
                axes3fPtr('reset');
                
                axes1fcPtr('reset');
                axes2fcPtr('reset');
                axes3fcPtr('reset');
                
                if link2DMip('get') == true && isVsplash('get') == false          
                    imMipFcPtr  ('reset');                                    
                    imMipFPtr   ('reset');                                    
                    axesMipfPtr ('reset');
                    axesMipfcPtr('reset');
                end
                
                axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                
                if ~isempty(axes1) && ...
                   ~isempty(axes2) && ...
                   ~isempty(axes3)
                    alpha( axes1, 1 );
                    alpha( axes2, 1 );
                    alpha( axes3, 1 );
                end
                
                if link2DMip('get') == true && isVsplash('get') == false      
                    axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    if ~isempty(axesMip)
                        alpha(axesMip, 1 );                                
                    end
                end                 
            end  
            
            fusionBuffer('reset');            
            
        end
        
%         set(uiSliderWindowPtr('get'), 'Visible', 'off');
%         set(uiSliderLevelPtr('get'), 'Visible', 'off'); 

        set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(lineColorbarIntensityMinPtr('get'), 'Visible', 'off');

        set(textColorbarIntensityMaxPtr('get'), 'Visible', 'off');
        set(textColorbarIntensityMinPtr('get'), 'Visible', 'off');

        set(uiColorbarPtr('get'), 'Visible', 'off');

        if isFusion('get')

            set(lineFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
            set(lineFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');
    
            set(textFusionColorbarIntensityMaxPtr('get'), 'Visible', 'off');
            set(textFusionColorbarIntensityMinPtr('get'), 'Visible', 'off');

            set(uiAlphaSliderPtr('get'), 'Visible', 'off');
            set(uiFusionColorbarPtr('get'), 'Visible', 'off');
%             set(uiFusionSliderWindowPtr('get'), 'Visible', 'off');
%             set(uiFusionSliderLevelPtr('get'), 'Visible', 'off');             

        end
               
        if size(dicomBuffer('get'), 3) == 1
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
    
        copyRoiPtr('set', '');

        releaseRoiWait();
            
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
        
        
%        isFusion('set', false);
%        fusionBuffer('reset');
%       set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

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

        switchTo3DMode('set', false);
        set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btn3DPtr('get'), 'FontWeight', 'normal');
        set(btn3DPtr('get'), 'CData', resizeTopBarIcon('3d_volume_grey.png'));
      
        switchToIsoSurface('set', false);
        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');
        set(btnIsoSurfacePtr('get'), 'CData', resizeTopBarIcon('3d_iso_grey.png'));

        switchToMIPMode('set', false);
        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnMIPPtr('get'), 'FontWeight', 'normal');
        set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_grey.png'));

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        % set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
        set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));

        if isempty(dicomMetaData('get', [], dSeriesOffset))
            atMetaData = tInput(dSeriesOffset).atDicomInfo;
            dicomMetaData('set', atMetaData, dSeriesOffset);
        end
        
        imageOrientation('set', tInput(dSeriesOffset).sOrientationView);       

        aInput  = inputBuffer('get');
        aBuffer = dicomBuffer('get', [], dSeriesOffset);

        if isempty(aBuffer)
            aBuffer = aInput{dSeriesOffset};
%            if     strcmp(imageOrientation('get'), 'axial')
%                aBuffer = permute(aInput{dSeriesOffset}, [1 2 3]);
%            elseif strcmp(imageOrientation('get'), 'coronal')
%                aBuffer = permute(aInput{dSeriesOffset}, [3 2 1]);
%            elseif strcmp(imageOrientation('get'), 'sagittal')
%                aBuffer = permute(aInput{dSeriesOffset}, [3 1 2]);
%            end

            dicomBuffer('set', aBuffer, dSeriesOffset);
        end

%        quantificationTemplate('set', tInput(dSeriesOffset).tQuant);
        setQuantification(dSeriesOffset);
        
        cropValue('set', min(dicomBuffer('get', [], dSeriesOffset), [], 'all'));

        imageSegTreshValue('set', 'lower', 0);
        imageSegTreshValue('set', 'upper', 1);

%        imageSegEditValue('set', 'lower', tInput(dSeriesOffset).tQuant.tCount.dMin);
%        imageSegEditValue('set', 'upper', tInput(dSeriesOffset).tQuant.tCount.dMax);
    
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
            % set(btnVsplashPtr('get'), 'FontWeight', 'normal');
            set(btnVsplashPtr('get'), 'CData', resizeTopBarIcon('splash_grey.png'));

            set(btnVsplashPtr('get')   , 'Enable', 'off');
            set(uiEditVsplahXPtr('get'), 'Enable', 'off');
            set(uiEditVsplahYPtr('get'), 'Enable', 'off');
        end         
        
%        isPlotContours('set', false);
        
        clearDisplay();
        initDisplay(3);

        bLinkMip = link2DMip('get');
        
        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        
        dicomViewerCore();                  
            
        setViewerDefaultColor(true, dicomMetaData('get'));
        
        refreshImages();

        % drawnow;
        % drawnow;
        % 
        % hideAllAxesToolbars(fiMainWindowPtr('get'));

        if bLinkMip == true
            link2DMip('set', true);
            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));            
        else
            link2DMip('set', false);
            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));              
        end

        catch ME
            logErrorToFile(ME);  
            progressBar(1, 'Error:setSeriesCallback()');
        end
        
        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');                
        
        mainToolBarEnable('on');

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

%        atMetaData = dicomMetaData('get');
        
%        if strcmpi(atMetaData{1}.Modality, 'ct')
%            link2DMip('set', false);

%            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
%        end         
    end

end
