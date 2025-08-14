function setFusionCallback(~, ~)
%function setFusionCallback(~, ~)
%Activate/Deactivate Fusion Main Function.
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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false        
        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

       volFusionObj = volFusionObject('get');
       mipFusionObj = mipFusionObject('get');
       isoFusionObj = isoFusionObject('get');

       if isFusion('get') == false

            isFusion('set', true);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_white.png'));           

            atInputTemplate  = inputTemplate('get');
            dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
            atFusionMetaData = atInputTemplate(dFusionSeriesOffset).atDicomInfo;

            if ~isempty(volFusionObj) && ...
               switchTo3DMode('get') == true

                if isempty(viewer3dObject('get'))

                    [aFusionMap, sFusionType] = getVolFusionAlphaMap('get', fusionBuffer('get', [], dFusionSeriesOffset), atFusionMetaData);
    
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
                else
                    set(volFusionObj, 'Visible', 'on');
                end

            end

            if ~isempty(mipFusionObj) && ...
               switchToMIPMode('get') == true

                if isempty(viewer3dObject('get'))

                    [aFusionMap, sFusionType] = getMipFusionAlphaMap('get', fusionBuffer('get', [], dFusionSeriesOffset), atFusionMetaData);
    
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
                else
                    set(mipFusionObj, 'Visible', 'on');
                end

            end

            if ~isempty(isoFusionObj) && ...
                switchToIsoSurface('get')

                if isempty(viewer3dObject('get'))
    
                    set(isoFusionObj, 'Isovalue', isoSurfaceFusionValue('get'));
                    set(isoFusionObj, 'IsosurfaceColor', surfaceColor('get', isoColorFusionOffset('get')) );
    
                    isoFusionObject('set', isoFusionObj);
                else
                    set(isoFusionObj, 'Visible', 'on');
                end

            end

       else
            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           

            if isempty(viewer3dObject('get'))

                if ~isempty(volFusionObj)
                    volFusionObj.Alphamap = zeros(256,1);
                    volFusionObject('set', volFusionObj);
                    if get(ui3DVolumePtr('get'), 'Value') == 2
                        displayAlphaCurve(zeros(256,1), axe3DPanelVolAlphmapPtr('get'));
                    end
                end
    
                if ~isempty(mipFusionObj)
                    mipFusionObj.Alphamap = zeros(256,1);
                    mipFusionObject('set', mipFusionObj);
                    if get(ui3DVolumePtr('get'), 'Value') == 2
                        displayAlphaCurve(zeros(256,1), axe3DPanelMipAlphmapPtr('get'));
                    end
                end
    
                if ~isempty(isoFusionObj)
                    isoFusionObj.Isovalue = 1;
                    isoFusionObject('set', isoFusionObj);
                end
            else
                if ~isempty(isoFusionObj)

                    set(isoFusionObj, 'Visible', 'off');
                end

                if ~isempty(mipFusionObj)

                    set(mipFusionObj, 'Visible', 'off');
                end

                if ~isempty(volFusionObj)

                    set(volFusionObj, 'Visible', 'off');
                end               
            end
       end
    else
        
        atInputTemplate = inputTemplate('get');
        if numel(atInputTemplate) == 0

            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           

            fusionBuffer('reset');
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(atInputTemplate)

            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           

            fusionBuffer('reset');
            return;
        end

        dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
        if dFusionSeriesOffset > numel(atInputTemplate)

            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           

            fusionBuffer('reset');
            return;
        end

        set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
        atMetaData = dicomMetaData('get');
        if isempty(atMetaData)
            atMetaData = atInputTemplate(dSeriesOffset).atDicomInfo;
        end

        atFusionMetaData = dicomMetaData('get', [], dFusionSeriesOffset);
        if isempty(atFusionMetaData)
            atFusionMetaData = atInputTemplate(dFusionSeriesOffset).atDicomInfo;
        end

        if isFusion('get') == false
            
            % Set slider

%             uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
%             if isempty(uiFusionSliderWindow) 
% 
%                 uiFusionSliderWindow = ...
%                     uicontrol(fiMainWindowPtr('get'), ...
%                               'Style'   , 'Slider', ...
%                               'Value'   , sliderFusionWindowLevelValue('get', 'max'), ...
%                               'Enable'  , 'on', ...
%                               'BackgroundColor', backgroundColor('get'), ...
%                               'CallBack', @sliderFusionWindowCallback ...
%                               ); 
%                 uiFusionSliderWindowPtr('set', uiFusionSliderWindow);                          
% 
%                 addlistener(uiFusionSliderWindow, 'Value', 'PreSet',@sliderFusionWindowCallback);     
% 
%                 set(uiFusionSliderWindow, 'Visible', 'off');                
%             end
% 
%             uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
%             if isempty(uiFusionSliderLevel) 
% 
%                 uiFusionSliderLevel = ...
%                     uicontrol(fiMainWindowPtr('get'), ...
%                               'Style'   , 'Slider', ...
%                               'Value'   , sliderFusionWindowLevelValue('get', 'min'), ...
%                               'Enable'  , 'on', ...
%                               'BackgroundColor', backgroundColor('get'), ...
%                               'CallBack', @sliderFusionLevelCallback ...
%                               );   
%                 uiFusionSliderLevelPtr('set', uiFusionSliderLevel);
% 
%                 addlistener(uiFusionSliderLevel, 'Value', 'PreSet',@sliderFusionLevelCallback);     
% 
%                 set(uiFusionSliderLevel, 'Visible', 'off');                
% 
%             end

            uiAlphaSlider = uiAlphaSliderPtr('get');
            if isempty(uiAlphaSlider) 

                % uiAlphaSlider = ...
                %     uicontrol(fiMainWindowPtr('get'), ...
                %               'Style'   , 'Slider', ...
                %               'Value'   , sliderAlphaValue('get'), ...
                %               'Enable'  , 'on', ...
                %               'BackgroundColor', backgroundColor('get'), ...
                %               'String'  , 'Alpha',...
                %               'ToolTip', 'Fusion Alpha', ...
                %               'CallBack', @sliderAlphaCallback ...
                %               );    
                % uiAlphaSliderPtr('set', uiAlphaSlider); 
                % 
                % addlistener(uiAlphaSlider,'Value','PreSet',@sliderAlphaCallback);                        
                % %addlistener(uiAlphaSlider, 'ContinuousValueChange', @sliderAlphaCallback);
                % 
                % set(uiAlphaSlider, 'Visible', 'off'); 

                uiAlphaSlider = ...
                    viewerSlider(fiMainWindowPtr('get'), ...
                                 [0 0 30 30], ...              % position
                                 [0 0 0], ...                  % color
                                 [0.8 0.8 0.8], ...
                                 [0.5 0.5 0.5], ...
                                 [0.2 0.2 0.2], ...                        
                                 0, 1, ...                     % min, max
                                 sliderAlphaValue('get'), ...  % initial
                                 @sliderAlphaCallback, ...     % callback
                                 true, ...                     % In motion callback
                                 0.2, ...                      % very faint track
                                 0.6 ...                       % semi-opaque thumb
                                 );

                  uiAlphaSliderPtr('set', uiAlphaSlider); 

                  set(uiAlphaSlider, 'Visible', 'off');
  
            end
            
            % Set buffer
                
            aInput = inputBuffer('get');

            set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
            A = dicomBuffer('get');

            set(uiSeriesPtr('get'), 'Value', dFusionSeriesOffset);
            B = dicomBuffer('get');
            if isempty(B)
                B = aInput{dFusionSeriesOffset};
                clear aInput;
            end
            set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

            
            if numel(size(A))~=numel(size(B)) %Fuse 2D with 3D
if 1
                isFusion('set', false);

                set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

                set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           

                fusionBuffer('reset');
                return;

else
                if numel(size(A))>numel(size(B))
                    [x1,y1,z1]=size(A);
                    [x2,y2,~]=size(B);
                    aTemp = zeros(x2,y2,z1);
                    for nn=1:z1
                        aTemp(:,:,nn)=B(:,:);
                    end
                    B = imresize(aTemp, [x1 y1]);

                    refSliceThickness = computeSliceSpacing(atMetaData);
                    atFusionMetaData{1}.SpacingBetweenSlices = refSliceThickness;



                else

                end
end
            end

            initFusionWindowLevel('set', true); % Need to be fix

            set(btnFusionPtr('get')    , 'Enable', 'off');
            set(uiFusedSeriesPtr('get'), 'Enable', 'off');

            if size(B, 3) == 1
                
                progressBar(0.999, 'Processing fusion, please wait');
                
                % Init axes                
                
                if ~isempty(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    if isvalid(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
%                        cla(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                        delete(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    end
                end
                    
                % Init axe

                axeF = ...
                   axes(uiOneWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    , 'reverse', ...
                        'Box'     , 'off', ...
                        'Tag'     , 'axeF', ...   
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axeF.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                deleteAxesToolbar(axeF);

                set(axeF, 'HitTest', 'off');  % Disable hit testing for axes
                set(axeF, 'XLimMode', 'manual', 'YLimMode', 'manual');  
                set(axeF, 'XMinorTick', 'off', 'YMinorTick', 'off'); 

                grid(axeF, 'off');

                axis(axeF, 'tight');
                axefPtr('set', axeF, get(uiFusedSeriesPtr('get'), 'Value'));
                disableDefaultInteractivity(axeF);

                linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                                
                uistack(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

                if isempty(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                     axesFusionColorbar = ...
                        uiaxes(uiOneWindowPtr('get'), ...
                               'Units'   , 'pixels', ...
                               'Position', [0 0 1 1], ...
                               'Visible' , 'on', ...
                               'Ydir'    , 'normal', ...
                               'Tag'     , 'fusion colorbar', ...   
                               'Box'     , 'off', ...
                               'XLim'    , [0 inf], ...
                               'YLim'    , [0 inf], ...
                               'CLim'    , [0 inf] ...
                             );
                    axesFusionColorbar.Interactions = [];
                    % axesFusionColorbar.Toolbar.Visible = 'off';           
                    axesFusionColorbarPtr('set', axesFusionColorbar, get(uiFusedSeriesPtr('get'), 'Value'));                               
                    disableDefaultInteractivity(axesFusionColorbar);
                    deleteAxesToolbar(axesFusionColorbar);

                    uistack(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                end

                axAxefText = ...
                    uiaxes(uiOneWindowPtr('get'), ...
                         'Units'   , 'normalized', ...
                         'Ydir'    , 'reverse', ...
                         'xlimmode', 'manual',...
                         'ylimmode', 'manual',...
                         'zlimmode', 'manual',...
                         'climmode', 'manual',...
                         'alimmode', 'manual',...
                         'Position', [0 0 0.95 1], ...
                         'Box'     , 'off', ...
                         'Tag'     , 'axAxefText', ...
                         'Visible' , 'off',...
                         'HandleVisibility', 'off' ...
                         );
                axAxefText.Interactions = [];
                % axAxefText.Toolbar.Visible = 'off'; 
                disableDefaultInteractivity(axAxefText);
                deleteAxesToolbar(axAxefText);
             
                if isfield(atFusionMetaData{1}, 'SeriesDescription')
                    sFusedSeriesDescription = atFusionMetaData{1}.SeriesDescription;
                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'_',' ');
                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'^',' ');
                    sFusedSeriesDescription = strtrim(sFusedSeriesDescription);
                else
                    sFusedSeriesDescription = '';
                end

                if isfield(atFusionMetaData{1}, 'SeriesDate')

                    if isempty(atFusionMetaData{1}.SeriesDate)
                        sFusedSeriesDate = '';
                    else
                        sFusedSeriesDate = atFusionMetaData{1}.SeriesDate;
                        if isempty(atFusionMetaData{1}.SeriesTime)
                            sFusedSeriesTime = '000000';
                        else
                            sFusedSeriesTime = atFusionMetaData{1}.SeriesTime;
                        end
                        sFusedSeriesDate = sprintf('%s%s', sFusedSeriesDate, sFusedSeriesTime);
                    end

                    if ~isempty(sFusedSeriesDate)
                        if contains(sFusedSeriesDate,'.')
                            sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
                        end
                        sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
                    end
                else
                    sFusedSeriesDate = '';
                end

                asColorMap = getColorMap('all');
                sColormap = asColorMap{fusionColorMapOffset('get')};

                sAxefText = sprintf('\n%s\n%s\nColormap: %s', ...
                                sFusedSeriesDescription, ...
                                sFusedSeriesDate, ...
                                sColormap ...
                                );

                tAxefText  = text(axAxefText, 1, 0, sAxefText, 'Color', overlayColor('get'), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
                
                disableAxesToolbar(axAxefText);

                axesText('set', 'axef', tAxefText);
        
                if size(A)~=size(B) 

                    [x1,y1,~] = size(A);
                    [x2,y2,~] = size(B);
    
                    B = imresize(B, [x1 y1]);
                end
if 0
                if dSeriesOffset ~= dFusionSeriesOffset
                    if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1);
                    end

                    if atInputTemplate(dSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:);
                    end
                end
end
 %               atInputTemplate(dFusionSeriesOffset).bEdgeDetection = false;

 %               inputTemplate('set', atInputTemplate);

             %   B = resampleImage(A, B);

                fusionBuffer('set', B, dFusionSeriesOffset);
                
                imf = squeeze(fusionBuffer('get', [], dFusionSeriesOffset));    
                
                if gaussFilter('get') == true

                    if isInterpolated('get')

                        imAxeF = imshow(imgaussfilt(imf)   , ...
                                        'Parent'       , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                        'Interpolation', 'bilinear'... 
                                        );    
                    else
                        imAxeF = imshow(imgaussfilt(imf)   , ...
                                        'Parent'       , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                        'Interpolation', 'nearest'... 
                                        );                        
                    end
                else    
                    if isInterpolated('get')
                        imAxeF = imshow(imf, ...
                                        'Parent'   , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                        'Interpolation', 'bilinear'... 
                                        ); 
                    else
                        imAxeF = imshow(imf, ...
                                       'Parent'   , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                       'Interpolation', 'nearest'... 
                                        );                         
                    end
                end                

                
                set(imAxeF, 'Visible', 'off'); 
                set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); % Patch

                % adjAxeCameraViewAngle(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                disableAxesToolbar(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                imAxeFPtr('set', imAxeF, get(uiFusedSeriesPtr('get'), 'Value'));          
                rightClickMenu('add', imAxeF);                   
                      
                if aspectRatio('get') == true
                    
                    if ~isempty(atFusionMetaData{1}.PixelSpacing)
                   
                        xf = atFusionMetaData{1}.PixelSpacing(1);
                        yf = atFusionMetaData{1}.PixelSpacing(2);
                    else
                        xf = computeAspectRatio('x', atFusionMetaData);
                        yf = computeAspectRatio('y', atFusionMetaData);
                    end
                    
                    if xf == 0
                       xf = 1;
                    end
                            
                    if yf == 0
                       yf = 1;
                    end

                    daspect(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf 1]);

                else
                    xf =1;
                    yf =1;

                    daspect(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    axis(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                end

                fusionAspectRatioValue('set', 'x', xf);
                fusionAspectRatioValue('set', 'y', yf);

            else

                progressBar(0.999, 'Processing fusion, please wait');
                
                % Init axes                
                
                if ~isempty(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    if isvalid(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
 %                       cla(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                        delete(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    end
                end

                axes1f = ...
                   axes(uiCorWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    , 'reverse', ...
                        'Tag'     , 'axes1f', ...   
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes1f.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                deleteAxesToolbar(axes1f);     

                set(axes1f, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes1f, 'XLimMode', 'manual', 'YLimMode', 'manual');  
                set(axes1f, 'XMinorTick', 'off', 'YMinorTick', 'off'); 

                grid(axes1f, 'off');

                axis(axes1f, 'tight');
                axes1fPtr('set', axes1f, get(uiFusedSeriesPtr('get'), 'Value'));
                disableDefaultInteractivity(axes1f);
                
                % linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xyz');                                
                uistack(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

                if ~isempty(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    if isvalid(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
%                        cla(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                        delete(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    end
                end                   

                axes2f = ...
                   axes(uiSagWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    , 'reverse', ...
                        'Tag'     , 'axes2f', ...   
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes2f.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                deleteAxesToolbar(axes2f);       

                set(axes2f, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes2f, 'XLimMode', 'manual', 'YLimMode', 'manual');  
                set(axes2f, 'XMinorTick', 'off', 'YMinorTick', 'off'); 

                grid(axes2f, 'off');

                axis(axes2f, 'tight');
                axes2fPtr('set', axes2f, get(uiFusedSeriesPtr('get'), 'Value'));
                disableDefaultInteractivity(axes2f);

                % linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                
                uistack(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                
                if ~isempty(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    if isvalid(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
%                        cla(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                        delete(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    end
                end

                axes3f = ...
                   axes(uiTraWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Tag'     , 'axes3f', ...   
                        'Ydir'    ,'reverse', ...
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes3f.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                deleteAxesToolbar(axes3f);       

                set(axes3f, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes3f, 'XLimMode', 'manual', 'YLimMode', 'manual');  
                set(axes3f, 'XMinorTick', 'off', 'YMinorTick', 'off'); 

                grid(axes3f, 'off');

                axis(axes3f, 'tight');
                disableDefaultInteractivity(axes3f);
               
%                axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')  );
%                set(axes3f, 'XLim', axes3.XLim);
%                set(axes3f, 'YLim', axes3.YLim); 
                
                axes3fPtr('set', axes3f, get(uiFusedSeriesPtr('get'), 'Value'));

                % linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'xy');                
                uistack(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                
                % Axe colorbar

                if isempty(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                    axesFusionColorbar = ...
                        uiaxes(uiTraWindowPtr('get'), ...
                               'Units'   , 'pixels', ...
                               'Position', [0 0 1 1], ...
                               'Visible' , 'on', ...
                               'Ydir'    , 'normal', ...
                               'Tag'     , 'fusion colorbar', ...   
                               'Box'     , 'off', ...
                               'XLim'    , [0 inf], ...
                               'YLim'    , [0 inf], ...
                               'CLim'    , [0 inf] ...
                             );
    
                    axesFusionColorbar.Interactions = [];
                    % axesFusionColorbar.Toolbar.Visible = 'off';           
                    axesFusionColorbarPtr('set', axesFusionColorbar, get(uiFusedSeriesPtr('get'), 'Value'));                               
                    disableDefaultInteractivity(axesFusionColorbar);
                    uistack(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                    deleteAxesToolbar(axesFusionColorbar);
                end

                % Set fusion display text
               
                axAxes3fText = ...
                    uiaxes(uiTraWindowPtr('get'), ...
                         'Units'   , 'normalized', ...
                         'Ydir'    , 'reverse', ...
                         'xlimmode', 'manual',...
                         'ylimmode', 'manual',...
                         'zlimmode', 'manual',...
                         'climmode', 'manual',...
                         'alimmode', 'manual',...
                         'Position', [0 0 0.9 1], ...
                         'Box'     , 'off', ...
                         'Tag'     , 'axAxes3fText', ...
                         'Visible' , 'off',...
                         'HandleVisibility', 'off' ...
                         );
                axAxes3fText.Interactions = [];
                % axAxes3fText.Toolbar.Visible = 'off';      
                disableDefaultInteractivity(axAxes3fText);
                deleteAxesToolbar(axAxes3fText);

                if isfield(atFusionMetaData{1}, 'SeriesDescription')
                    sFusedSeriesDescription = atFusionMetaData{1}.SeriesDescription;
                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'_',' ');
                    sFusedSeriesDescription = strrep(sFusedSeriesDescription,'^',' ');
                    sFusedSeriesDescription = strtrim(sFusedSeriesDescription);
                else
                    sFusedSeriesDescription = '';
                end

                if isfield(atFusionMetaData{1}, 'SeriesDate')

                    if isempty(atFusionMetaData{1}.SeriesDate)
                        sFusedSeriesDate = '';
                    else
                        sFusedSeriesDate = atFusionMetaData{1}.SeriesDate;
                        if isempty(atFusionMetaData{1}.SeriesTime)
                            sFusedSeriesTime = '000000';
                        else
                            sFusedSeriesTime = atFusionMetaData{1}.SeriesTime;
                        end
                        sFusedSeriesDate = sprintf('%s%s', sFusedSeriesDate, sFusedSeriesTime);
                    end

                    if ~isempty(sFusedSeriesDate)
                        if contains(sFusedSeriesDate,'.')
                            sFusedSeriesDate = extractBefore(sFusedSeriesDate,'.');
                        end
                        try
                            sFusedSeriesDate = datetime(sFusedSeriesDate, 'InputFormat', 'yyyyMMddHHmmss');
                        catch
                            sFusedSeriesDate = '';
                        end
                    end
                else
                    sFusedSeriesDate = '';
                end
            
                asColorMap = getColorMap('all');
                sColormap = asColorMap{fusionColorMapOffset('get')};

                sAxe3fText = sprintf('\n%s\n%s\nColormap: %s', ...
                                sFusedSeriesDescription, ...
                                sFusedSeriesDate, ...
                                sColormap ...
                                );
                        
                tAxes3fText = axesText('get', 'axes3f');            
                if ~isempty(tAxes3fText)
                    delete(tAxes3fText)
                end
                tAxes3fText  = text(axAxes3fText, 1, 0, sAxe3fText, 'Color', overlayColor('get'), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
               
                disableAxesToolbar(axAxes3fText);    

                axesText('set', 'axes3f', tAxes3fText);

                if overlayActivate('get') == false
                    set(tAxes3fText, 'Visible', 'off');
                end
        
                if isVsplash('get') == false         
                    if ~isempty(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                        if isvalid(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
%                            cla(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                            delete(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                        end
                    end

                    axesMipf = ...
                       axes(uiMipWindowPtr('get'), ...
                            'Units'   , 'normalized', ...
                            'Position', [0 0 1 1], ...
                            'Visible' , 'off', ...
                            'Ydir'    ,'reverse', ...
                            'Tag'     , 'axeMipf', ...   
                            'Box'     , 'off', ...
                            'XLim'    , [0 inf], ...
                            'YLim'    , [0 inf], ...
                            'CLim'    , [0 inf] ...
                            );
                    axesMipf.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                    % axesMipf.Toolbar.Visible = 'off';  
                    set(axesMipf, 'HitTest', 'off');  % Disable hit testing for axes
                    deleteAxesToolbar(axesMipf);

                    set(axesMipf, 'XLimMode', 'manual', 'YLimMode', 'manual');  
                    set(axesMipf, 'XMinorTick', 'off', 'YMinorTick', 'off'); 
   
                    grid(axesMipf, 'off');

                    axis(axesMipf, 'tight');
                    disableDefaultInteractivity(axesMipf);

                    axesMipfPtr('set', axesMipf, get(uiFusedSeriesPtr('get'), 'Value'));
                    % linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                

                    uistack(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');                    
                end                                                             
                
                % Need to clear some space for the colorbar
                if isVsplash('get') == true && ...
                   ~strcmpi(vSplahView('get'), 'all')

                    if strcmpi(vSplahView('get'), 'coronal')
                        set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                    elseif strcmpi(vSplahView('get'), 'sagittal')
                        set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                    else
                        set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                    end
                else
                    set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);
                end
        
                set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

%                if strcmp(imageOrientation('get'), 'coronal')
%                    B = permute(B, [3 2 1]);
%                elseif strcmp(imageOrientation('get'), 'sagittal')
%                    B = permute(B, [2 3 1]);
%                else
%                    B = permute(B, [1 2 3]);
%                end

if 1
                if dSeriesOffset ~= dFusionSeriesOffset

                    if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1,:);
                    end

                    if atInputTemplate(dSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:,:);
                    end

                    if atInputTemplate(dSeriesOffset).bFlipHeadFeet == true
                        B=B(:,:,end:-1:1);
                    end
                end
end
%                atInputTemplate(dFusionSeriesOffset).bEdgeDetection = false;
%                inputTemplate('set', atInputTemplate);

%                [x1,y1,z1] = size(A);
%                [x2,y2,z2] = size(B);                
                 
    %                 msgbox('Warning: Reslice is not yet supported, the fusion may be wrong!');
%                if ( ( atMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                       strcmpi(atMetaData{1}.Modality, 'ct') ) || ...
%                   ( atFusionMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                     strcmpi(atFusionMetaData{1}.Modality, 'ct') ) ) && ...
%                   numel(atMetaData) ~= 1 && ...
%                   numel(atFusionMetaData) ~= 1

                    tRegistration  = registrationTemplate('get');
                    sInterpolation = tRegistration.Interpolation;
                   
                    if isVsplash('get') == false

                        aRefMip = mipBuffer('get', [], dSeriesOffset);
                        aMip    = mipBuffer('get', [], dFusionSeriesOffset);

%                         if ~isequal(size(aRefMip), size(aMip))

                            aResampledMip = resample3DMIP(aMip, atFusionMetaData, aRefMip, atMetaData, sInterpolation);
%                         else
%                             aResampledMip = aMip;
%                         end
                 
                    end         


%                     if ~isequal(size(A), size(B))
                    if isVsplash('get') == false

                        [B, atFusionMetaData] = resample3DImage(B, atFusionMetaData, A, atMetaData, sInterpolation);

                    else
                        [aResampled, atFusionMetaData] = ...
                            resampleImageTransformMatrix(B, ...
                                                         atFusionMetaData, ...
                                                         A, ...
                                                         atMetaData, ...
                                                         sInterpolation, ...
                                                         true ...
                                                         );  
                                                     
                       if numel(aResampled(aResampled==min(aResampled, [], 'all'))) == numel(aResampled)                            
                                [aResampled, ~] = ...
                                    resampleImageTransformMatrix(B, ...
                                                                 atFusionMetaData, ...
                                                                 A, ...
                                                                 atMetaData, ...
                                                                 'bilinear', ...
                                                                 false ...
                                                                 );         
                        end
                        
                        if numel(A)~=numel(aResampled)                             
                            B = imresize3(aResampled, size(A));
                        else
                            B = aResampled;
                        end                                                    
                    end
%                     end
            

                fusionBuffer('set', B, dFusionSeriesOffset);  
                fusionMetaData('set', atFusionMetaData, dFusionSeriesOffset);  
                
                if isVsplash('get') == false      
                    mipFusionBufferOffset('set', dFusionSeriesOffset);
                    mipFusionBuffer('set', aResampledMip, dFusionSeriesOffset);               
                end
                
                % Init CData
                
                iCoronal  = sliceNumber('get', 'coronal' );
                iSagittal = sliceNumber('get', 'sagittal');
                iAxial    = sliceNumber('get', 'axial'   );        
                iMipAngle = mipAngle('get');

                imf = squeeze(fusionBuffer('get', [], dFusionSeriesOffset));    
                
                % Set Coronal

                if size(imf, 1) < iCoronal
                    iCoronal = size(imf, 1);
                end

                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'coronal') || ...
                    strcmpi(vSplahView('get'), 'all'))
                
                    imComputed = computeMontage(imf, 'coronal', iCoronal);    

                    if gaussFilter('get') == true

                        if isInterpolated('get')

                            imCoronalF = imshow(imgaussfilt(imComputed), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'bilinear'... 
                                                );        
                        else
                            imCoronalF = imshow(imgaussfilt(imComputed), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'nearest'... 
                                                );                                      
                        end
                    else      
                        if isInterpolated('get')

                            imCoronalF = imshow(imComputed, ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'bilinear'... 
                                                );                             
                        else
                            imCoronalF = imshow(imComputed, ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'nearest'... 
                                                ); 
                        end
                    end
 

                    imCoronalFPtr('set', imCoronalF, get(uiFusedSeriesPtr('get'), 'Value')); 


%                     imCoronalF.CData = imComputed;                         

                else                       
               
                    if gaussFilter('get') == true

                        if isInterpolated('get')
             
                            imCoronalF = imshow(imgaussfilt(permute(imf(iCoronal,:,:), [3 2 1])), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'bilinear'... 
                                                 );   
                        else
                            imCoronalF = imshow(imgaussfilt(permute(imf(iCoronal,:,:), [3 2 1])), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'nearest'... 
                                                 );                                      
                        end
                    else      
                        if isInterpolated('get')

                            imCoronalF = imshow(permute(imf(iCoronal,:,:), [3 2 1]), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'bilinear'... 
                                                ); 
                        else
                            imCoronalF = imshow(permute(imf(iCoronal,:,:), [3 2 1]), ...
                                                'Parent'       , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                'Interpolation', 'nearest'... 
                                                );                             
                        end
                        
                    end

                    imCoronalFPtr('set', imCoronalF, get(uiFusedSeriesPtr('get'), 'Value')); 
                    rightClickMenu('add', imCoronalF);

                end
                
                set(imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 

                disableAxesToolbar(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % adjAxeCameraViewAngle(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % Set Sagittal

                if size(imf, 2) < iSagittal
                    iSagittal = size(imf, 2);
                end

                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'sagittal') || ...
                    strcmpi(vSplahView('get'), 'all'))
                
                    imComputed = computeMontage(imf, 'sagittal', iSagittal);  

                    if gaussFilter('get') == true

                        if isInterpolated('get')

                            imSagittalF = imshow(imgaussfilt(imComputed), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'bilinear'... 
                                                 );  
                        else
                            imSagittalF = imshow(imgaussfilt(imComputed), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'nearest'... 
                                                 );                                                                                                  
                        end
                    else                    
                        if isInterpolated('get')

                            imSagittalF = imshow(imComputed, ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'bilinear'... 
                                                 );    
                        else
                            imSagittalF = imshow(imComputed, ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'nearest'... 
                                                 );                            
                        end
                    end
                    
                    imSagittalFPtr('set', imSagittalF, get(uiFusedSeriesPtr('get'), 'Value'));

%                    imSagittalF.CData = imComputed;                           

                else
                  
                     if gaussFilter('get') == true

                        if isInterpolated('get')

                            imSagittalF = imshow(imgaussfilt(permute(imf(:,iSagittal,:), [3 1 2])), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'bilinear'... 
                                                 );    
                        else
                            imSagittalF = imshow(imgaussfilt(permute(imf(:,iSagittal,:), [3 1 2])), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'nearest'... 
                                                 );                                 
                        end
                    else
                        if isInterpolated('get')
                            imSagittalF = imshow(permute(imf(:,iSagittal,:), [3 1 2]), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'bilinear'... 
                                                 );    
                        else
                            imSagittalF = imshow(permute(imf(:,iSagittal,:), [3 1 2]), ...
                                                 'Parent'       , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                                 'Interpolation', 'nearest'... 
                                                 );                              
                        end
                    end
                    

                    imSagittalFPtr('set', imSagittalF, get(uiFusedSeriesPtr('get'), 'Value'));
                    rightClickMenu('add', imSagittalF);
                end                
                
                set(imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 

                disableAxesToolbar(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % adjAxeCameraViewAngle(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
               
                % Apply image translation. The translation xMoveOffset and
                % yMoveOffset is set by resampleImageTransformMatrix
                
%                imSagittalF.XData = [imSagittalF.XData(1)-xMoveOffset imSagittalF.XData(2)-xMoveOffset];
%                imSagittalF.YData = [imSagittalF.YData(1)-yMoveOffset imSagittalF.YData(2)-yMoveOffset];
                                          
                % Set Axial

                if size(imf, 3) < iAxial
                    iAxial = size(imf, 3);
                end

                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'axial') || ...
                    strcmpi(vSplahView('get'), 'all'))

                     imComputed = computeMontage(imf(:,:,end:-1:1), ...
                                                'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1 ...
                                                ); 
%                     fusionBuffer('set', imComputed,  get(uiFusedSeriesPtr('get'), 'Value'));

                    if gaussFilter('get') == true    

                        if isInterpolated('get')
                            
                            imAxialF = imshow(imgaussfilt(imComputed),  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'bilinear'... 
                                              ); 
                        else
                            imAxialF = imshow(imgaussfilt(imComputed),  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'nearest'... 
                                              );                                                                                                                    
                        end
                    else     
                        if isInterpolated('get')

                            imAxialF = imshow(imComputed,  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'bilinear'... 
                                              );                          
                        else
                            imAxialF = imshow(imComputed,  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'nearest'... 
                                              );                                                                                    
                        end
                    end
                    
                    imAxialFPtr('set', imAxialF, get(uiFusedSeriesPtr('get'), 'Value'));
   
                  %  imAxialF.CData = imComputed;

                else

                    if gaussFilter('get') == true

                        if isInterpolated('get')
                       
                            imAxialF = imshow(imgaussfilt(imf(:,:,iAxial)), ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'bilinear'... 
                                              );    
                        else
                            imAxialF = imshow(imgaussfilt(imf(:,:,iAxial)), ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'nearest'... 
                                              );                                
                        end
                    else
                        if isInterpolated('get')

                            imAxialF = imshow(imf(:,:,iAxial),  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'bilinear'... 
                                              );                                
                        else
                            imAxialF = imshow(imf(:,:,iAxial),  ...
                                              'Parent'       , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                              'Interpolation', 'nearest'... 
                                              );                                                                                                                               
                        end
                    end             

                    imAxialFPtr('set', imAxialF, get(uiFusedSeriesPtr('get'), 'Value'));
                    rightClickMenu('add', imAxialF);

                end
                
                set(imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 

                disableAxesToolbar(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % adjAxeCameraViewAngle(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                            
                % Apply image translation. The translation xMoveOffset and
                % yMoveOffset is set by resampleImageTransformMatrix
                
%                imAxialF.XData = [imAxialF.XData(1)-xMoveOffset imAxialF.XData(2)-xMoveOffset];
%                imAxialF.YData = [imAxialF.YData(1)-yMoveOffset imAxialF.YData(2)-yMoveOffset];
                
                % Set Mip

                if isVsplash('get') == false 

                    imComputedMipF = mipFusionBuffer('get', [], dFusionSeriesOffset);                                  

                    if gaussFilter('get') == true

                        if isInterpolated('get')

                            imMipF = imshow(imgaussfilt(permute(imComputedMipF(iMipAngle,:,:), [3 2 1])), ...
                                            'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                            'Interpolation', 'bilinear'... 
                                            );                                                                
                        else

                            imMipF = imshow(imgaussfilt(permute(imComputedMipF(iMipAngle,:,:), [3 2 1])), ...
                                            'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                            'Interpolation', 'nearest'... 
                                            );                              
                        end

                    else
                        if isInterpolated('get')
                            imMipF = imshow(permute(imComputedMipF(iMipAngle,:,:), [3 2 1]),  ...
                                            'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                            'Interpolation', 'bilinear'... 
                                            );               
                        else
                            imMipF = imshow(permute(imComputedMipF(iMipAngle,:,:), [3 2 1]),  ...
                                            'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                            'Interpolation', 'nearest'... 
                                            );                             
                        end
                     end

                    imMipFPtr('set', imMipF, get(uiFusedSeriesPtr('get'), 'Value'));
                    set(imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                end                      
                
                set(imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 

                disableAxesToolbar(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % adjAxeCameraViewAngle(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                % Init Aspect Ratio

                if aspectRatio('get') == true

                    if ~isempty(atFusionMetaData{1}.PixelSpacing)
                        xf = atFusionMetaData{1}.PixelSpacing(1);
                        yf = atFusionMetaData{1}.PixelSpacing(2);
                        zf = computeSliceSpacing(atFusionMetaData);

                        if xf == 0
                            xf = 1;
                        end

                        if yf == 0
                            yf = 1;
                        end

                        if zf == 0
                            zf = xf;
                        end
                    else

                        xf = computeAspectRatio('x', atFusionMetaData) ;
                        yf = computeAspectRatio('y', atFusionMetaData) ;
                        zf = 1;
                    end

                    daspect(axes1fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                    daspect(axes2fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                    daspect(axes3fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                    
                    if isVsplash('get') == false
                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                    end

%                   if strcmp(imageOrientation('get'), 'axial')
%                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
%                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
%                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                                                
%                        if link2DMip('get') == true && isVsplash('get') == false                       
%                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
%                        end
%                   elseif strcmp(imageOrientation('get'), 'coronal')
%                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
%                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);
%                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
%                        if link2DMip('get') == true && isVsplash('get') == false                       
%                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
%                        end
%                    elseif strcmp(imageOrientation('get'), 'sagittal')
%                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);
%                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);
%                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
%                        if link2DMip('get') == true && isVsplash('get') == false                       
%                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);
%                        end
%                    end
                else
                    xf =1;
                    yf =1;
                    zf =1;

                    daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    if isVsplash('get') == false                       
                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                   end
                    
                    axis(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    if isVsplash('get') == false                                           
                        axis(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    end
                end

                fusionAspectRatioValue('set', 'x', xf);
                fusionAspectRatioValue('set', 'y', yf);
                fusionAspectRatioValue('set', 'z', zf);
            end
           
            set(btnFusionPtr('get')    , 'Enable', 'on');
            set(uiFusedSeriesPtr('get'), 'Enable', 'on');

            isFusion('set', true);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

            set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_white.png'));           
        else
                                                
            if isscalar(atInputTemplate)
                if atInputTemplate(dFusionSeriesOffset).bEdgeDetection == false
                    atInputTemplate(dFusionSeriesOffset).bFusedEdgeDetection = false;
                end
            else
                atInputTemplate(dFusionSeriesOffset).bEdgeDetection = false;
            end

%           atInputTemplate(dFusionSeriesOffset).bEdgeDetection = false;
           inputTemplate('set', atInputTemplate);

           isFusion('set', false);

           initFusionWindowLevel('set', false); % Need to be fix

           set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
           set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

           set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));           
         
           if isPlotContours('get') == true % Deactivate plot contours

               setPlotContoursCallback();
           end
           
    %         fusionBuffer('set', '');
        end

        if initFusionWindowLevel('get') == true

            initFusionWindowLevel('set', false);

            if strcmpi(atFusionMetaData{1}.Modality, 'ct')
                if min(B, [], 'all') >= 0
                    dMax = max(B, [], 'all');
                    dMin = min(B, [], 'all');
                else
                    [dMax, dMin] = computeWindowLevel(500, 50);
                end
            else
                sUnitDisplay = getSerieUnitValue(dFusionSeriesOffset);

                if strcmpi(sUnitDisplay, 'SUV')

                    if isfield(atInputTemplate(dFusionSeriesOffset).tQuant, 'tSUV')
                        
                        dMin = suvWindowLevel('get', 'min')/atInputTemplate(dFusionSeriesOffset).tQuant.tSUV.dScale;
                        dMax = suvWindowLevel('get', 'max')/atInputTemplate(dFusionSeriesOffset).tQuant.tSUV.dScale;
                    else
                        dMin = min(B, [], 'all');
                        dMax = max(B, [], 'all');
                    end
                else
                    dMin = min(B, [], 'all');
                    dMax = max(B, [], 'all');
                end
            end

            fusionWindowLevel('set', 'max', dMax);
            fusionWindowLevel('set', 'min', dMin);

%             sliderFusionWindowLevelValue('set', 'min', 0.5);
%             sliderFusionWindowLevelValue('set', 'max', 0.5);

%             set(uiFusionSliderWindowPtr('get'), 'Value', 0.5);
%             set(uiFusionSliderLevelPtr('get' ), 'Value', 0.5);

            getFusionInitWindowMinMax('set', dMax, dMin);

       %     sliderAlphaValue('set', 0.5);
            set(uiAlphaSliderPtr('get') , 'Value', sliderAlphaValue('get'));

             if size(fusionBuffer('get', [], dFusionSeriesOffset), 3) == 1
                 set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
             else
                 set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                 set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                 set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                 if  isVsplash('get') == false      
                     set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                 end
             end

        else
             lFusionMin = fusionWindowLevel('get', 'min');
             lFusionMax = fusionWindowLevel('get', 'max');
             if size(dicomBuffer('get'), 3) == 1
                 set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
             else
                 set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
                 set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
                 set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
                 if isVsplash('get') == false      
                     set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
                 end
             end
        end
        
        uiAlphaSlider = uiAlphaSliderPtr('get');
        
        if ~isempty(uiAlphaSlider) 
            setAlphaSliderPosition(uiAlphaSlider);
            set(uiAlphaSlider, 'BackgroundColor', backgroundColor('get'));
        end
       
        if isFusion('get') == true
            
        ptrFusionColorbar = uiFusionColorbarPtr('get');

        % Set colorbar                
        if size(dicomBuffer('get'), 3) == 1
                
%            if ~isempty(uiFusionColorbarPtr('get'))
%                if isvalid(uiFusionColorbarPtr('get'))
%                    delete(uiFusionColorbarPtr('get'));
%                end
%            end
            bIsGraphic = isgraphics(ptrFusionColorbar);
            if isempty(bIsGraphic)
               bIsGraphic = false;
            end
            
            if ~bIsGraphic 

                % ptrFusionColorbar = ...
                %     colorbar(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                %              'AxisLocation' , 'in', ...
                %              'Tag'          , 'Fusion Colorbar', ...
                %              'EdgeColor'    , overlayColor('get'), ...
                %              'Units'        , 'pixels', ...
                %              'Box'          , 'off', ...
                %              'Location'     , 'east', ...
                %              'ButtonDownFcn', @colorbarCallback ...
                %              );   
                % 
                % ptrFusionColorbar.TickLabels = [];         
                % ptrFusionColorbar.Ticks = [];
                % ptrFusionColorbar.TickLength = 0;
                % ptrFusionColorbar.Interruptible = 'off'; % Prevent interruptions

                ptrFusionColorbar = viewerColorbar(axesFusionColorbarPtr('get', [], dFusionSeriesOffset),  ...
                                            'Fusion Colorbar', ...
                                            getColorMap('one', fusionColorMapOffset('get')));

                uiFusionColorbarPtr('set', ptrFusionColorbar);
                colorbarCallback(ptrFusionColorbar); % Fix for Linux
                                
            else
                setColorbarColormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));
                colormap(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));                
            end
        else
            % Set Colorbar

%            if ~isempty(uiFusionColorbarPtr('get'))
%                if isvalid(uiFusionColorbarPtr('get'))
%                    delete(uiFusionColorbarPtr('get'));
%                end
%            end

            bIsGraphic = isgraphics(ptrFusionColorbar);
            if isempty(bIsGraphic)
               bIsGraphic = false;
            end
            
            if ~bIsGraphic

                % if isVsplash('get') == true && ...
                %    ~strcmpi(vSplahView('get'), 'all')
                % 
                %     if strcmpi(vSplahView('get'), 'coronal')
                %         ptrFusionColorbar = ...
                %             colorbar(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                %                      'AxisLocation' , 'in', ...
                %                      'Tag'          , 'Fusion Colorbar', ...
                %                      'EdgeColor'    , overlayColor('get'), ...
                %                      'Units'        , 'pixels', ...
                %                      'Box'          , 'off', ...
                %                      'Location'     , 'east', ...
                %                      'ButtonDownFcn', @colorbarCallback ...
                %                      );            
                %     elseif strcmpi(vSplahView('get'), 'sagittal')
                %         ptrFusionColorbar = ...
                %             colorbar(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                %                      'AxisLocation' , 'in', ...
                %                      'Tag'          , 'Fusion Colorbar', ...
                %                      'EdgeColor'    , overlayColor('get'), ...
                %                      'Units'        , 'pixels', ...
                %                      'Box'          , 'off', ...
                %                      'Location'     , 'east', ...
                %                      'ButtonDownFcn', @colorbarCallback ...
                %                      );            
                %     else
                %         ptrFusionColorbar = ...
                %             colorbar(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                %                      'AxisLocation' , 'in', ...
                %                      'Tag'          , 'Fusion Colorbar', ...
                %                      'EdgeColor'    , overlayColor('get'), ...
                %                      'Units'        , 'pixels', ...
                %                      'Box'          , 'off', ...
                %                      'Location'     , 'east', ...
                %                      'ButtonDownFcn', @colorbarCallback ...
                %                      );            
                %     end
                % 
                % else
                %     ptrFusionColorbar = ...
                %         colorbar(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                %                  'AxisLocation' , 'in', ...
                %                  'Tag'          , 'Fusion Colorbar', ...
                %                  'EdgeColor'    , overlayColor('get'), ...
                %                  'Units'        , 'pixels', ...
                %                  'Box'          , 'off', ...
                %                  'Location'     , 'east', ...
                %                  'ButtonDownFcn', @colorbarCallback ...
                %                  );            
                % end
                % 
                % ptrFusionColorbar.TickLabels = [];                 
                % ptrFusionColorbar.Ticks = [];
                % ptrFusionColorbar.TickLength = 0;
                % ptrFusionColorbar.Interruptible = 'off';

               ptrFusionColorbar = viewerColorbar(axesFusionColorbarPtr('get', [], dFusionSeriesOffset),  ...
                                                  'Fusion Colorbar', ...
                                                  getColorMap('one', fusionColorMapOffset('get')));

                uiFusionColorbarPtr('set', ptrFusionColorbar);

%                 colormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));    
               
                colorbarCallback(ptrFusionColorbar); % Fix for Linux  
            else
                setColorbarColormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));    
                
                colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));  
                
                if isVsplash('get') == false && link2DMip('get') == true     
                    colormap(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));                 
                end
            end
        end

   %     setColorbarTick(uiFusionColorbarPtr('get'), 10, 100, get(uiFusedSeriesPtr('get'), 'Value'), isFusionColorbarDefaultUnit('get', get(uiFusedSeriesPtr('get'), 'Value')) );

        ptrFusionColorbar = uiFusionColorbarPtr('get');
        if ~isempty(ptrFusionColorbar)

            setFusionColorbarPosition(ptrFusionColorbar);
            ptrFusionColorbar.Parent.YLabel.Position = [ptrFusionColorbar.Parent.YLabel.Position(1) - 10, ptrFusionColorbar.Parent.YLabel.Position(2), ptrFusionColorbar.Parent.YLabel.Position(3)];            
        end


%         aFigurePosition = ptrFusionColorbar.Parent.Position;
%         if size(dicomBuffer('get'), 3) == 1
%             set(ptrFusionColorbar, ...
%                 'Position', [aFigurePosition(3)-48 ...
%                              30 ...
%                              40 ...
%                              ((aFigurePosition(4))/2)-53  ...
%                              ] ...
%                 );
%         else
%             if isVsplash('get') == true && ...
%               ~strcmpi(vSplahView('get'), 'all')
%                 if viewSegPanel('get')
% 
%                     set(ptrFusionColorbar, ...
%                         'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-48 ...
%                                      30 ...
%                                      40 ...
%                                      ((aFigurePosition(4))/2)-44  ...
%                                      ] ...
%                         );
%                 elseif viewKernelPanel('get') == true
% 
%                     set(ptrFusionColorbar, ...
%                         'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-48 ...
%                                      30 ...
%                                      40 ...
%                                      ((aFigurePosition(4))/2)-44  ...
%                                      ] ...
%                         );
%                 elseif viewRoiPanel('get') == true
% 
%                     set(ptrFusionColorbar, ...
%                         'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-48 ...
%                                      30 ...
%                                      40 ...
%                                      ((aFigurePosition(4))/2)-44  ...
%                                      ] ...
%                         );
%                 else
%                     set(ptrFusionColorbar, ...
%                         'Position', [aFigurePosition(3)-48 ...
%                                      30 ...
%                                      40 ...
%                                      ((aFigurePosition(4))/2)-44  ...
%                                      ] ...
%                         );
%                 end
%             else
%                 set(ptrFusionColorbar, ...
%                     'Position', [aFigurePosition(3)-48 ...
%                                  30 ...
%                                  40 ...
%                                  ((aFigurePosition(4))/2)-44  ...
%                                  ] ...
%                     );
%             end
% 
%         end
 
%         axeFusionColorbar = axeFusionColorbarPtr('get');
%         if ~isempty(axeFusionColorbar)
%             set(axeFusionColorbar, 'Position', get(ptrFusionColorbar, 'Position'));
%         end   

         % Use line on colorbar instead of slider in the side
        if isempty(axeFusionColorbarPtr('get'))

            if size(fusionBuffer('get', 'get', get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1
                axeFusionColorbar = axes(uiOneWindowPtr('get'), ...
                                         'Units'   , 'pixels', ...
                                         'Ydir'    , 'reverse', ...
                                         'xlimmode', 'manual',...
                                         'ylimmode', 'manual',...
                                         'zlimmode', 'manual',...
                                         'climmode', 'manual',...
                                         'alimmode', 'manual',...
                                         'Box'     , 'off', ...
                                         'Position', [get(ptrFusionColorbar.Parent, 'Position')], ...
                                         'Visible' , 'off'...
                                         );                
           else
                axeFusionColorbar = axes(uiTraWindowPtr('get'), ...
                                         'Units'   , 'pixels', ...
                                         'Ydir'    , 'reverse', ...
                                         'xlimmode', 'manual',...
                                         'ylimmode', 'manual',...
                                         'zlimmode', 'manual',...
                                         'climmode', 'manual',...
                                         'alimmode', 'manual',...
                                         'Box'     , 'off', ...
                                         'Position', [get(ptrFusionColorbar.Parent, 'Position')], ...
                                         'Visible' , 'off'...
                                         );

            end

            axeFusionColorbar.Interactions = [];
            % axeFusionColorbar.Toolbar.Visible = 'off';                 
            disableDefaultInteractivity(axeFusionColorbar);
            deleteAxesToolbar(axeFusionColorbar);

            axeFusionColorbarPtr('set', axeFusionColorbar);
    
            % Compute colorbar line y offset
    
            dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            
            % Line on colorbar
    
            lineFusionColorbarIntensityMax = line(axeFusionColorbar, [0.1, 0.9], [dYOffsetMax, dYOffsetMax], 'Color', viewerFusionColorbarIntensityMaxLineColor('get'), 'LineWidth', 15); 
            lineFusionColorbarIntensityMin = line(axeFusionColorbar, [0.1, 0.9], [dYOffsetMin, dYOffsetMin], 'Color', viewerFusionColorbarIntensityMinLineColor('get'), 'LineWidth', 15); 
            
            lineFusionColorbarIntensityMaxPtr('set', lineFusionColorbarIntensityMax);
            lineFusionColorbarIntensityMinPtr('set', lineFusionColorbarIntensityMin);
        
         %   set(axeColorbar, 'Visible' , 'off')
        
            set(lineFusionColorbarIntensityMax,'ButtonDownFcn',@lineFusionColorbarIntensityMaxClick);
            set(lineFusionColorbarIntensityMin,'ButtonDownFcn',@lineFusionColorbarIntensityMinClick);
        
            iptSetPointerBehavior(lineFusionColorbarIntensityMax,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
            iptSetPointerBehavior(lineFusionColorbarIntensityMin,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
    
            % Text on colorbar line
        
            textFusionColorbarIntensityMax = text(axeFusionColorbar, 0.1,lineFusionColorbarIntensityMax.YData(1), ' ','Color', viewerFusionColorbarIntensityMaxTextColor('get'),'FontName', 'Arial', 'FontSize',7); %Helvetica
            textFusionColorbarIntensityMin = text(axeFusionColorbar, 0.1,lineFusionColorbarIntensityMin.YData(1), ' ','Color', viewerFusionColorbarIntensityMinTextColor('get'),'FontName', 'Arial', 'FontSize',7); %Helvetica
        
            textFusionColorbarIntensityMaxPtr('set', textFusionColorbarIntensityMax);
            textFusionColorbarIntensityMinPtr('set', textFusionColorbarIntensityMin);
        
            iptSetPointerBehavior(textFusionColorbarIntensityMax,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
            iptSetPointerBehavior(textFusionColorbarIntensityMin,@(obj,src,event) set(fiMainWindowPtr('get'),'Pointer','hand'));
        
            set(textFusionColorbarIntensityMax,'ButtonDownFcn',@lineFusionColorbarIntensityMaxClick);
            set(textFusionColorbarIntensityMin,'ButtonDownFcn',@lineFusionColorbarIntensityMinClick);

            if isempty(isFusionColorbarDefaultUnit('get'))
                isFusionColorbarDefaultUnit('set', true);
            end
            
            % Ajust the intensity 
    
            setFusionColorbarIntensityMaxScaleValue(lineFusionColorbarIntensityMax.YData(1), ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                   );
                                                
            setFusionColorbarIntensityMinScaleValue(lineFusionColorbarIntensityMin.YData(1), ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                    );

            setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));
   
            if strcmpi(atFusionMetaData{1}.Modality, 'ct')
        
                if link2DMip('get') == true && isVsplash('get') == false
        
                    [dLevelMax, dLevelMin] = computeWindowLevel(2500, 415);
                    set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dLevelMin dLevelMax]);
                end        
            end
            
            disableAxesToolbar(axeFusionColorbar);
        end

%         uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
%         aFigurePosition = uiFusionSliderWindow.Parent.Position;
%         if size(dicomBuffer('get'), 3) == 1
% 
%             set(uiFusionSliderWindow, ...
%                 'Position', [aFigurePosition(3)-50 ...
%                              55 ...
%                              12 ...
%                              (aFigurePosition(4)/2)-75  ...
%                              ] ...
%                 );
%         else
%             if isVsplash('get') == true
%                 set(uiFusionSliderWindow, ...
%                     'Position', [aFigurePosition(3)-50 ...
%                                  70 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-75  ...
%                                  ] ...
%                     );
%             else
%                 uiTraWindow = uiTraWindowPtr('get');
%                 aAxePosition = uiTraWindow.Position;
% 
%                 set(uiFusionSliderWindow, ...
%                     'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
%                                  70 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-75  ...
%                                  ] ...
%                     );
%             end
%         end
% 
%         set(uiFusionSliderWindow, ...
%             'BackgroundColor', backgroundColor('get') ...
%             );
% 
%         uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
%         aFigurePosition = uiFusionSliderLevel.Parent.Position;
%         if size(dicomBuffer('get'), 3) == 1
%             set(uiFusionSliderLevel, ...
%                 'Position', [aFigurePosition(3)-21 ...
%                              55 ...
%                              12 ...
%                              (aFigurePosition(4)/2)-75  ...
%                              ] ...
%                 );
%         else
%             if isVsplash('get') == true
%                 set(uiFusionSliderLevel, ...
%                     'Position', [aFigurePosition(3)-21 ...
%                                  70 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-75  ...
%                                  ] ...
%                     );
%             else
%                 uiTraWindow = uiTraWindowPtr('get');
%                 aAxePosition = uiTraWindow.Position;
% 
%                 set(uiFusionSliderLevel, ...
%                     'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
%                                  70 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-75  ...
%                                  ] ...
%                     );
%             end
%         end
% 
%         set(uiFusionSliderLevel, ...
%             'BackgroundColor', backgroundColor('get') ...
%             );
        end

        if isFusion('get') == true

%             uiSliderWindow = uiSliderWindowPtr('get');
%             aFigurePosition = uiSliderWindow.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
%                 set(uiSliderWindow, ...
%                     'Position', [aFigurePosition(3)-50 ...
%                                  (aFigurePosition(4)/2)-15 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-30  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true
%                     set(uiSliderWindow, ...
%                         'Position', [aFigurePosition(3)-50 ...
%                                      aFigurePosition(4)/2 ...
%                                      12 ...
%                                      (aFigurePosition(4)/2)-45  ...
%                                      ] ...
%                         );
%                 else
%                     uiTraWindow = uiTraWindowPtr('get');
%                     aAxePosition = uiTraWindow.Position;
% 
%                     set(uiSliderWindow, ...
%                         'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
%                                      aFigurePosition(4)/2 ...
%                                      12 ...
%                                      (aFigurePosition(4)/2)-45  ...
%                                      ] ...
%                         );
%                 end
%             end
% 
%             set(uiSliderWindow, ...
%                 'BackgroundColor', backgroundColor('get') ...
%                 );
% 
%             uiSliderLevel = uiSliderLevelPtr('get');
%             aFigurePosition = uiSliderLevel.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
% 
%                 set(uiSliderLevel, ...
%                     'Position', [aFigurePosition(3)-21 ...
%                                  (aFigurePosition(4)/2)-15 ...
%                                  12 ...
%                                  (aFigurePosition(4)/2)-30  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true
%                     set(uiSliderLevel, ...
%                         'Position', [aFigurePosition(3)-21 ...
%                                      aFigurePosition(4)/2 ...
%                                      12 ...
%                                      (aFigurePosition(4)/2)-45  ...
%                                      ] ...
%                         );
%                 else
%                     uiTraWindow = uiTraWindowPtr('get');
%                     aAxePosition = uiTraWindow.Position;
% 
%                     set(uiSliderLevel, ...
%                         'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
%                                      aFigurePosition(4)/2 ...
%                                      12 ...
%                                      (aFigurePosition(4)/2)-45  ...
%                                      ] ...
%                         );
%                 end
%             end
% 
%             set(uiSliderLevel, ...
%                 'BackgroundColor', backgroundColor('get') ...
%                 );

             ptrColorbar = uiColorbarPtr('get');
             if ~isempty(ptrColorbar)

                setColorbarPosition(ptrColorbar);
                ptrColorbar.Parent.YLabel.Position = [ptrColorbar.Parent.YLabel.Position(1) - 10, ptrColorbar.Parent.YLabel.Position(2), ptrColorbar.Parent.YLabel.Position(3)];       
             end

%             aFigurePosition = ptrColorbar.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
% 
%                 set(ptrColorbar, ...
%                     'Position', [aFigurePosition(3)-48 ...
%                                  (aFigurePosition(4)/2)-9 ...
%                                  40 ...
%                                  (aFigurePosition(4)/2)+5  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true && ...
%                   ~strcmpi(vSplahView('get'), 'all')
% 
%                     if viewSegPanel('get')
% 
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-48 ...
%                                          (aFigurePosition(4)/2) ...
%                                          40 ...
%                                          (aFigurePosition(4)/2)-4  ...
%                                          ] ...
%                             );
%                     elseif viewKernelPanel('get') == true
% 
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-48 ...
%                                          (aFigurePosition(4)/2) ...
%                                          40 ...
%                                          (aFigurePosition(4)/2)-4  ...
%                                          ] ...
%                             );
%                     elseif viewRoiPanel('get') == true
% 
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-48 ...
%                                          (aFigurePosition(4)/2) ...
%                                          40 ...
%                                          (aFigurePosition(4)/2)-4  ...
%                                          ] ...
%                             );
%                     else
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-48 ...
%                                          (aFigurePosition(4)/2) ...
%                                          40 ...
%                                          (aFigurePosition(4)/2)-4  ...
%                                          ] ...
%                             );
%                     end
%                 else
%                     set(ptrColorbar, ...
%                         'Position', [aFigurePosition(3)-48 ...
%                                      (aFigurePosition(4)/2) ...
%                                      40 ...
%                                      (aFigurePosition(4)/2)-4  ...
%                                      ] ...
%                         );
%                 end
%             end
% 
%             axeColorbar = axeColorbarPtr('get');
%             if ~isempty(axeColorbar)
%                 set(axeColorbar, 'Position', get(ptrColorbar, 'Position'));
%             end

        else

%             uiSliderWindow = uiSliderWindowPtr('get');
%             aFigurePosition = uiSliderWindow.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
% 
%                 set(uiSliderWindow, ...
%                     'Position', [aFigurePosition(3)-50 ...
%                                  35 ...
%                                  12 ...
%                                  aFigurePosition(4)-80  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true
%                     set(uiSliderWindow, ...
%                         'Position', [aFigurePosition(3)-50 ...
%                                      50 ...
%                                      12 ...
%                                      aFigurePosition(4)-95  ...
%                                      ] ...
%                         );
%                 else
%                     uiTraWindow = uiTraWindowPtr('get');
%                     aAxePosition = uiTraWindow.Position;
% 
%                     set(uiSliderWindow, ...
%                         'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
%                                      50 ...
%                                      12 ...
%                                      aFigurePosition(4)-95  ...
%                                      ] ...
%                         );
%                 end
%             end
% 
%             uiSliderLevel = uiSliderLevelPtr('get');
%             aFigurePosition = uiSliderLevel.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
% 
%                 set(uiSliderLevel, ...
%                     'Position', [aFigurePosition(3)-21 ...
%                                  35 ...
%                                  12 ...
%                                  aFigurePosition(4)-80  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true
%                     set(uiSliderLevel, ...
%                         'Position', [aFigurePosition(3)-21 ...
%                                      50 ...
%                                      12 ...
%                                      aFigurePosition(4)-95  ...
%                                      ] ...
%                        );
%                 else
%                     uiTraWindow = uiTraWindowPtr('get');
%                     aAxePosition = uiTraWindow.Position;
% 
%                     set(uiSliderLevel, ...
%                         'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
%                                      50 ...
%                                      12 ...
%                                      aFigurePosition(4)-95  ...
%                                      ] ...
%                        );
%                 end
%             end

            ptrColorbar = uiColorbarPtr('get');
            if ~isempty(ptrColorbar)

                setColorbarPosition(ptrColorbar);
            end

%             aFigurePosition = ptrColorbar.Parent.Position;
%             if size(dicomBuffer('get'), 3) == 1
% 
%                 set(ptrColorbar, ...
%                     'Position', [aFigurePosition(3)-48 ...
%                                  7 ...
%                                  40 ...
%                                  aFigurePosition(4)-11  ...
%                                  ] ...
%                     );
%             else
%                 if isVsplash('get') == true && ...
%                   ~strcmpi(vSplahView('get'), 'all')
%                     if viewSegPanel('get')
% 
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-48 ...
%                                          7 ...
%                                          40 ...
%                                          aFigurePosition(4)-11  ...
%                                          ] ...
%                             );
%                     elseif viewKernelPanel('get') == true
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-48 ...
%                                          7 ...
%                                          40 ...
%                                          aFigurePosition(4)-11  ...
%                                          ] ...
%                             );
%                     elseif viewRoiPanel('get') == true
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-48 ...
%                                          7 ...
%                                          40 ...
%                                          aFigurePosition(4)-11  ...
%                                          ] ...
%                             );
%                     else
%                         set(ptrColorbar, ...
%                             'Position', [aFigurePosition(3)-48 ...
%                                          7 ...
%                                          40 ...
%                                          aFigurePosition(4)-11  ...
%                                          ] ...
%                             );
%                     end
%                 else
%                     set(ptrColorbar, ...
%                         'Position', [aFigurePosition(3)-48 ...
%                                      7 ...
%                                      40 ...
%                                      aFigurePosition(4)-11  ...
%                                      ] ...
%                         );
%                 end
% 
%                 axeColorbar = axeColorbarPtr('get');
%                 if ~isempty(axeColorbar)
%                     set(axeColorbar, 'Position', get(ptrColorbar, 'Position'));
%                 end

%             end
        end

        if isVsplash('get') == false                                                       

            btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
    
            if ~isempty(btnUiTraWindowFullScreen)
    
                aUiTraPosition = get(uiTraWindowPtr('get'), 'Position');
    
                if isFusion('get') == true
                    set(btnUiTraWindowFullScreen, 'Position', [aUiTraPosition(3)-73 34 20 20]);
                else
                    set(btnUiTraWindowFullScreen, 'Position', [aUiTraPosition(3)-73 10 20 20]);
                end
            end

            chkUitraWindowSelected = chkUiTraWindowSelectedPtr('get');
    
            if ~isempty(chkUitraWindowSelected)
                
                aUiTraPosition = get(uiTraWindowPtr('get'), 'Position');
    
                if isFusion('get') == true
                    set(chkUitraWindowSelected, 'Position', [aUiTraPosition(3)-93 34 20 20]);
                else
                    set(chkUitraWindowSelected, 'Position', [aUiTraPosition(3)-93 10 20 20]);
                end                
            end


        end

        if isFusion('get') == true

            if isVsplash('get') == true
                
                if strcmpi(vSplahView('get'), 'Coronal') || ...
                   strcmpi(vSplahView('get'), 'Sagittal')     
        
                    set( uiFusionColorbarPtr('get'), 'Visible', 'off' );
                else
                    set( uiFusionColorbarPtr('get'), 'Visible', 'on' );
                end
            else
                set( uiFusionColorbarPtr('get'), 'Visible', 'on' );
            end

%             set( uiFusionSliderWindowPtr('get'), 'Visible', 'on' );
%             set( uiFusionSliderLevelPtr('get') , 'Visible', 'on' );
            set( uiAlphaSliderPtr('get')       , 'Visible', 'on' );
            
            % Set fused axes on same field of view

            % aFusionSize = size(fusionBuffer('get', [], dFusionSeriesOffset));

             if size(fusionBuffer('get', [], dFusionSeriesOffset), 3) == 1
            % 
                 axe  = axePtr ('get', [], get(uiSeriesPtr('get')     , 'Value'));
                 axef = axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                 XLim = get(axe, 'XLim');
                 YLim = get(axe, 'YLim');

                 %adjAxeCameraViewAngle(axef); 
          
            % 
                % set(axef, 'XLim', axe.XLim);
                % set(axef, 'YLim', axe.YLim); 
           % 
                 % set(axef, 'XLim', [0 aFusionSize(2)]);
                 % set(axef, 'YLim', [0 aFusionSize(1)]);
                 % linkaxes([axe axef], 'xy');  

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

                axefusion = [];
                for rr=1:dNbFusedSeries

                    if ~isempty(axefPtr('get', [], rr))

                        axefusion{end+1} = axefPtr('get', [], rr);
                    end

                end

                 if ~isempty(axefusion)

                    linkaxes([axe axefusion{:}], 'xy'); 
                 end

                 set(axe, 'XLim', XLim);
                 set(axe, 'YLim', YLim);

                 setAxesLimitsFromSource(axe, axef);

                 initAxePlotView(axe);
                 initAxePlotView(axef);               
             else
                axes1  = axes1Ptr ('get', [], get(uiSeriesPtr('get')     , 'Value'));
                axes1f = axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                XLim = get(axes1, 'XLim');
                YLim = get(axes1, 'YLim');

                %adjAxeCameraViewAngle(axes1f); 


                % if isVsplash('get') == true
                    % set(axes1f, 'XLim', axes1.XLim);
                    % set(axes1f, 'YLim', axes1.YLim); 
                % else
                % 
                %     set(axes1f, 'XLim', [0 aFusionSize(2)]);
                %     set(axes1f, 'YLim', [0 aFusionSize(3)]); 
                % end

                % linkaxes([axes1 axes1f], 'xy'); 

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

                axes1fusion = [];
                for rr=1:dNbFusedSeries

                    if ~isempty(axes1fPtr('get', [], rr))

                        axes1fusion{end+1} = axes1fPtr('get', [], rr);
                    end

                end

                if ~isempty(axes1fusion)

                    linkaxes([axes1 axes1fusion{:}], 'xy'); 
                end             

                set(axes1, 'XLim', XLim);
                set(axes1, 'YLim', YLim);

                setAxesLimitsFromSource(axes1, axes1f);
         
                initAxePlotView(axes1);
                initAxePlotView(axes1f);

                axes2  = axes2Ptr ('get', [], get(uiSeriesPtr('get')     , 'Value'));
                axes2f = axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                XLim = get(axes2, 'XLim');
                YLim = get(axes2, 'YLim');

                % adjAxeCameraViewAngle(axes2f); 


                % if isVsplash('get') == true
                    % 
                    % set(axes2f, 'XLim', axes2.XLim);
                    % set(axes2f, 'YLim', axes2.YLim); 

                % else
                %     set(axes2f, 'XLim', [0 aFusionSize(1)]);
                %     set(axes2f, 'YLim', [0 aFusionSize(3)]); 
                % end

                % linkaxes([axes2 axes2f], 'xy'); 

                axes2fusion = [];
                for rr=1:dNbFusedSeries
                    
                    if ~isempty(axes2fPtr('get', [], rr))

                        axes2fusion{end+1} = axes2fPtr('get', [], rr);
                    end

                end

                if ~isempty(axes2fusion)

                    linkaxes([axes2 axes2fusion{:}], 'xy'); 
                end

                set(axes2, 'XLim', XLim);
                set(axes2, 'YLim', YLim);

                setAxesLimitsFromSource(axes2, axes2f);

                initAxePlotView(axes2f);
                initAxePlotView(axes2);

                axes3  = axes3Ptr ('get', [], get(uiSeriesPtr('get')     , 'Value'));
                axes3f = axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                XLim = get(axes3, 'XLim');
                YLim = get(axes3, 'YLim');

                %adjAxeCameraViewAngle(axes3f); 
            
                % if isVsplash('get') == true
                    % set(axes3f, 'XLim', axes3.XLim);
                    % set(axes3f, 'YLim', axes3.YLim); 
                % else
                    % set(axes3f, 'XLim', [0 aFusionSize(2)]);
                    % set(axes3f, 'YLim', [0 aFusionSize(1)]); 
                % end

                % linkaxes([axes3 axes3f], 'xy');       

                axes3fusion = [];
                for rr=1:dNbFusedSeries

                    if ~isempty(axes3fPtr('get', [], rr))

                        axes3fusion{end+1} = axes3fPtr('get', [], rr);
                    end

                end

                if ~isempty(axes3fusion)

                    linkaxes([axes3 axes3fusion{:}], 'xy'); 
                end

                set(axes3, 'XLim', XLim);
                set(axes3, 'YLim', YLim);

                setAxesLimitsFromSource(axes3, axes3f);

                initAxePlotView(axes3);
                initAxePlotView(axes3f);

                if isVsplash('get') == false         

                    axesMip  = axesMipPtr ('get', [], get(uiSeriesPtr('get')     , 'Value'));
                    axesMipf = axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                    XLim = get(axesMip, 'XLim');
                    YLim = get(axesMip, 'YLim');

                    %adjAxeCameraViewAngle(axesMipf); 

                    % set(axesMipf, 'XLim', axesMip.XLim);
                    % set(axesMipf, 'YLim', axesMip.YLim); 
                    % set(axesMipf, 'CameraViewAngle', axesMip.CameraViewAngle);

                    % set(axesMipf, 'XLim', [0 aFusionSize(2)]);
                    % set(axesMipf, 'YLim', [0 aFusionSize(3)]);

                    % linkaxes([axesMip axesMipf], 'xy');   

                    axesMipfusion = [];
                    for rr=1:dNbFusedSeries
    
                        if ~isempty(axesMipfPtr('get', [], rr))
                            axesMipfusion{end+1} = axesMipfPtr('get', [], rr);
                        end
    
                    end
    
                    if ~isempty(axesMipfusion)
    
                        linkaxes([axesMip axesMipfusion{:}], 'xy'); 
                    end

                    set(axesMip, 'XLim', XLim);
                    set(axesMip, 'YLim', YLim);

                    setAxesLimitsFromSource(axesMip, axesMipf);

                    initAxePlotView(axesMip);
                    initAxePlotView(axesMipf);
                  
                end                                
            end
                        
            if size(dicomBuffer('get'), 3) == 1

                set( imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'Visible', 'on');

                alpha( imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),   get(uiAlphaSliderPtr('get'), 'Value'));
                alpha( imAxePtr ('get', [], get(uiSeriesPtr('get')     , 'Value')), 1-get(uiAlphaSliderPtr('get'), 'Value'));   

                % axef = axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));    
                % axef.Toolbar.Visible = 'off'; % We need to keep the toolbar for 3D visualisation
                % deleteAxesToolbar(axef);
           else

                set( imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                set( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                set( imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );

                % axe1f = axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                % axe2f = axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                % axe3f = axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
    
                % axe1f.Toolbar.Visible = 'off';
                % axe2f.Toolbar.Visible = 'off';
                % axe3f.Toolbar.Visible = 'off';

                % delete(axe1f.Toolbar);
                % delete(axe2f.Toolbar);
                % delete(axe3f.Toolbar);

                if link2DMip('get') == true && isVsplash('get') == false      

                    set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );

                    % axeMipf = axesMipfPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    % axeMipf.Toolbar.Visible = 'off';                    
                end

                alpha( imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                
                if link2DMip('get') == true && isVsplash('get') == false  

                    alpha( imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );                                
                end 
                
                if isVsplash('get') == false

                    axeMipf = axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                    % delete(axeMipf.Toolbar);
                end

                alpha( imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                
                if link2DMip('get') == true && isVsplash('get') == false 

                    alpha( imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-get(uiAlphaSliderPtr('get'), 'Value') );                                
                end 
            end

            setFusionColorbarLabel();         

        else
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            isMoveImageActivated('set', false);
            
            set(uiFusedSeriesPtr('get'), 'Enable', 'on');
            
            keyPressFusionStatus('set', 2);
            isCombineMultipleFusion('set', false);

            axeRGBImage = axeRGBImagePtr('get');    
            if ~isempty(axeRGBImage)    
                showRGBColormapImage(false);
            end
                    
            fusionBuffer('reset');

%             delete(uiFusionSliderWindowPtr('get'));
%             delete(uiFusionSliderLevelPtr('get'));

            delete(lineFusionColorbarIntensityMaxPtr('get'));
            delete(lineFusionColorbarIntensityMinPtr('get'));
            delete(textFusionColorbarIntensityMaxPtr('get'));
            delete(textFusionColorbarIntensityMinPtr('get'));            
            
            lineFusionColorbarIntensityMaxPtr('set', []);
            lineFusionColorbarIntensityMinPtr('set', []);
            textFusionColorbarIntensityMaxPtr('set', []);
            textFusionColorbarIntensityMinPtr('set', []);            

            delete(axesFusionColorbarPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
            axesFusionColorbarPtr('set', [], get(uiFusedSeriesPtr('get'), 'Value'));

            delete(uiFusionColorbarPtr('get'));
            uiFusionColorbarPtr('set', []);

            delete(axeFusionColorbarPtr('get'));
            axeFusionColorbarPtr('set', []);

            delete(uiAlphaSliderPtr('get'));
            uiAlphaSliderPtr       ('set', []);                  

            % uiFusionColorbarPtr    ('set', '');
%             uiFusionSliderWindowPtr('set', '');
%             uiFusionSliderLevelPtr ('set', '');
            
            
            if size(dicomBuffer('get'), 3) == 1
                
                axesText('reset', 'axef');
                
                imAxeFcPtr('reset');                                
                imAxeFPtr ('reset');                                
                axefPtr   ('reset');
                axefcPtr  ('reset');
                
                axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                if ~isempty(axe)                        
                    alpha( axe, 1);                
                end
            else
                axesText('reset', 'axes3f');

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

                imCoronal  = imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                imSagittal = imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                imAxial    = imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                % axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                % axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                % axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

                if ~isempty(imCoronal) && ...
                   ~isempty(imSagittal) && ...
                   ~isempty(imAxial)
                    alpha( imCoronal, 1 );
                    alpha( imSagittal, 1 );
                    alpha( imAxial, 1 );
                end
                
                if link2DMip('get') == true && isVsplash('get') == false      

                    mipFusionBuffer('reset');               

                    imMip = imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));

                    % axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    if ~isempty(imMip)
                        alpha(imMip, 1 );                                
                    end
                end                 
            end      

            if isVsplash('get') == false 
            
                setColorbarLabel();
                setColorbarVisible('on');
            else
                if strcmpi(vSplahView('get'), 'axial') || ...
                   strcmpi(vSplahView('get'), 'all')

                    setColorbarLabel();
                    setColorbarVisible('on');              
                end
            end
        end
        
        uiLogo = logoObject('get');
        if (size(dicomBuffer('get'), 3) == 1 && ...
            isFusion('get') == true) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'axial')) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'coronal')) || ...
           (isFusion('get') == true  && ...
            isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'sagittal'))

            set(uiLogo, 'Position', [-20 35 70 20]);
        else
            set(uiLogo, 'Position', [-20 15 70 20]);
        end

        setViewerDefaultColor(true, atMetaData, atFusionMetaData);

        refreshImages();            
    end

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false
   
        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');                        
        mainToolBarEnable('on');     

        if isFusion('get') == true

            if size(dicomBuffer('get'), 3) == 1

                if aspectRatio('get') == true

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');
                else
                    x = 1;
                    y = 1;                   
                end
                    
                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries
    
                    axef = axefPtr('get', [], rr);
                    if ~isempty(axef)                          
                        daspect(axef, [x y 1]);
                    end
                end    

                if isPlotContours('get') == true 
                    daspect(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y 1]);                            
               end 
            else
                if aspectRatio('get') == true

                    x = aspectRatioValue('get', 'x');
                    y = aspectRatioValue('get', 'y');
                    z = aspectRatioValue('get', 'z');
                else
                    x = 1;
                    y = 1;
                    z = 1;                    
                end
        
                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
                
                if isVsplash('get') == false                       
                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
                end
                
                if isFusion('get') == true % TO DO, support fusion with is own aspect
                    
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries
        
                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);
        
                        if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
                            daspect(axes1f, [z x y]);
                            daspect(axes2f, [z y x]);
                            daspect(axes3f, [x y z]);                                        
                        end
                        
                        if isVsplash('get') == false    
                            axesMipf = axesMipfPtr('get', [], rr);
                            if ~isempty(axesMipf)
                                daspect(axesMipf, [z y x]);
                            end
                        end
                        
                    end
                end
                
                if isPlotContours('get') == true && isVsplash('get') == false
                    
                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]);
                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);
                    
                    if isVsplash('get') == false                                                       
                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);
                    end                                
                end

            end

        end

    end

    progressBar(1, 'Ready');

    catch ME   
        logErrorToFile(ME);
        progressBar(1, 'Error:setFusionCallback()');
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
