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
        
        try

        set(uiSeriesPtr('get'), 'Enable', 'off');                

        % Deactivate main tool bar 
        
        mainToolBarEnable('off');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        
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
            set(btnFusionPtr('get'), 'FontWeight', 'normal');
           
            delete(uiFusionSliderWindowPtr('get'));
            delete(uiFusionSliderLevelPtr('get'));
            delete(uiFusionColorbarPtr('get'));
            delete(uiAlphaSliderPtr('get'));

            uiFusionColorbarPtr    ('set', '');
            uiFusionSliderWindowPtr('set', '');
            uiFusionSliderLevelPtr ('set', '');
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
        
        set(uiColorbarPtr('get'), 'Visible', 'off');
        set(uiSliderWindowPtr('get'), 'Visible', 'off');
        set(uiSliderLevelPtr('get'), 'Visible', 'off'); 
        
        if isFusion('get')
            set(uiAlphaSliderPtr('get'), 'Visible', 'off');
            set(uiFusionColorbarPtr('get'), 'Visible', 'off');
            set(uiFusionSliderWindowPtr('get'), 'Visible', 'off');
            set(uiFusionSliderLevelPtr('get'), 'Visible', 'off');             
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
        set(btnZoomPtr('get'), 'FontWeight', 'normal');
        zoomTool('set', false);
        zoom('off');           

        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
        set(btnPanPtr('get'), 'FontWeight', 'normal');
        panTool('set', false);
        pan('off');     

        set(rotate3DMenu('get'), 'Checked', 'off');         
        rotate3DTool('set', false);
        rotate3d off;

        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);              
        datacursormode('off');  
        
        
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
        set(btn3DPtr('get'), 'FontWeight', 'normal');
        
        switchToIsoSurface('set', false);
        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');

        switchToMIPMode('set', false);
        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnMIPPtr('get'), 'FontWeight', 'normal');

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnTriangulatePtr('get'), 'FontWeight', 'bold');

        if isempty(dicomMetaData('get'))
            atMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set', atMetaData);
        end
        
        imageOrientation('set', tInput(iOffset).sOrientationView);       

        aInput  = inputBuffer('get');
        aBuffer = dicomBuffer('get', [], iOffset);

        if isempty(aBuffer)
            aBuffer = aInput{iOffset};
%            if     strcmp(imageOrientation('get'), 'axial')
%                aBuffer = permute(aInput{iOffset}, [1 2 3]);
%            elseif strcmp(imageOrientation('get'), 'coronal')
%                aBuffer = permute(aInput{iOffset}, [3 2 1]);
%            elseif strcmp(imageOrientation('get'), 'sagittal')
%                aBuffer = permute(aInput{iOffset}, [3 1 2]);
%            end

            dicomBuffer('set', aBuffer, iOffset);
        end

%        quantificationTemplate('set', tInput(iOffset).tQuant);
        setQuantification(iOffset);
        
        cropValue('set', min(dicomBuffer('get', [], iOffset), [], 'all'));

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
            set(btnVsplashPtr('get'), 'FontWeight', 'normal');

            set(btnVsplashPtr('get')   , 'Enable', 'off');
            set(uiEditVsplahXPtr('get'), 'Enable', 'off');
            set(uiEditVsplahYPtr('get'), 'Enable', 'off');
        end         
        
%        isPlotContours('set', false);
        
        clearDisplay();
        initDisplay(3);
        
%        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        
        dicomViewerCore();                  
            
        setViewerDefaultColor(true, dicomMetaData('get'));
        
        refreshImages();

        catch
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
