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

            tFuseInput  = inputTemplate('get');
            iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
            atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

            if ~isempty(volFusionObj) && switchTo3DMode('get') == true
                [aFusionMap, sFusionType] = getVolFusionAlphaMap('get', fusionBuffer('get', [], iFuseOffset), atFuseMetaData);

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

            if ~isempty(mipFusionObj) && switchToMIPMode('get') == true

                [aFusionMap, sFusionType] = getMipFusionAlphaMap('get', fusionBuffer('get', [], iFuseOffset), atFuseMetaData);

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

            if ~isempty(isoFusionObj) && switchToIsoSurface('get')

                set(isoFusionObj, 'Isovalue', isoSurfaceFusionValue('get'));
                set(isoFusionObj, 'IsosurfaceColor', surfaceColor('get', isoColorFusionOffset('get')) );

                isoFusionObject('set', isoFusionObj);
            end

       else
            isFusion('set', false);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

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
       end
    else

        tFuseInput = inputTemplate('get');
        if numel(tFuseInput) == 0
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return
        end

        iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if iSeriesOffset > numel(tFuseInput)
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return;
        end

        iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
        if iFuseOffset > numel(tFuseInput)
            isFusion('set', false);
            set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            fusionBuffer('reset');
            return;
        end

        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
        tMetaData  = dicomMetaData('get');
        if isempty(tMetaData)
            tMetaData = tFuseInput(iSeriesOffset).atDicomInfo;
        end

        set(uiSeriesPtr('get'), 'Value', iFuseOffset);
        tFuseMetaData = dicomMetaData('get');
        if isempty(tFuseMetaData)
            tFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
        end
        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

        if isFusion('get') == false
            
            % Set slider

            uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
            if isempty(uiFusionSliderWindow) 

                uiFusionSliderWindow = ...
                    uicontrol(fiMainWindowPtr('get'), ...
                              'Style'   , 'Slider', ...
                              'Value'   , sliderFusionWindowLevelValue('get', 'max'), ...
                              'Enable'  , 'on', ...
                              'BackgroundColor', backgroundColor('get'), ...
                              'CallBack', @sliderFusionWindowCallback ...
                              ); 
                uiFusionSliderWindowPtr('set', uiFusionSliderWindow);                          

                addlistener(uiFusionSliderWindow, 'Value', 'PreSet',@sliderFusionWindowCallback);     

                set(uiFusionSliderWindow, 'Visible', 'off');                
            end

            uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
            if isempty(uiFusionSliderLevel) 

                uiFusionSliderLevel = ...
                    uicontrol(fiMainWindowPtr('get'), ...
                              'Style'   , 'Slider', ...
                              'Value'   , sliderFusionWindowLevelValue('get', 'min'), ...
                              'Enable'  , 'on', ...
                              'BackgroundColor', backgroundColor('get'), ...
                              'CallBack', @sliderFusionLevelCallback ...
                              );   
                uiFusionSliderLevelPtr('set', uiFusionSliderLevel);

                addlistener(uiFusionSliderLevel, 'Value', 'PreSet',@sliderFusionLevelCallback);     

                set(uiFusionSliderLevel, 'Visible', 'off');                

            end

            uiAlphaSlider = uiAlphaSliderPtr('get');
            if isempty(uiAlphaSlider) 

                uiAlphaSlider = ...
                    uicontrol(fiMainWindowPtr('get'), ...
                              'Style'   , 'Slider', ...
                              'Value'   , sliderAlphaValue('get'), ...
                              'Enable'  , 'on', ...
                              'BackgroundColor', backgroundColor('get'), ...
                              'ToolTip', 'Fusion Alpha', ...
                              'CallBack', @sliderAlphaCallback ...
                              );    
                uiAlphaSliderPtr('set', uiAlphaSlider);                  

                addlistener(uiAlphaSlider,'Value','PreSet',@sliderAlphaCallback);                        

                set(uiAlphaSlider, 'Visible', 'off');                
            end
            
            % Set buffer
                
            aInput = inputBuffer('get');

            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
            A = dicomBuffer('get');

            set(uiSeriesPtr('get'), 'Value', iFuseOffset);
            B = dicomBuffer('get');
            if isempty(B)
                B = aInput{iFuseOffset};
            end
            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

            
            if numel(size(A))~=numel(size(B)) %Fuse 2D with 3D
if 1
                isFusion('set', false);
                set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
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

                    refSliceThickness = computeSliceSpacing(tMetaData);
                    tFuseMetaData{1}.SpacingBetweenSlices = refSliceThickness;



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
                        'xlimmode','manual',...
                        'ylimmode','manual',...
                        'zlimmode','manual',...
                        'climmode','manual',...
                        'alimmode','manual',...
                        'Position', [0 0 1 1], ...
                        'color','none',...
                        'Visible' , 'off'...
                        );
                axis(axeF, 'tight');
                axefPtr('set', axeF, get(uiFusedSeriesPtr('get'), 'Value'));

%                linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                                
                uistack(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
              
                [x1,y1,~] = size(A);
                [x2,y2,~] = size(B);

                B = imresize(B, [x1 y1]);
if 0
                if iSeriesOffset ~= iFuseOffset
                    if tFuseInput(iSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1);
                    end

                    if tFuseInput(iSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:);
                    end
                end
end
 %               tFuseInput(iFuseOffset).bEdgeDetection = false;

 %               inputTemplate('set', tFuseInput);

             %   B = resampleImage(A, B);

                fusionBuffer('set', B, iFuseOffset);
                
                imf = squeeze(fusionBuffer('get', [], iFuseOffset));    
                
                if is3DEngine('get') == true
                    if gaussFilter('get') == true
                       imAxeF = surface(imgaussfilt(imf)   , ...
                                        'linestyle', 'none', ...
                                        'Parent'   , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                        );                                               
                    else    
                       imAxeF = surface(imf, ...
                                       'linestyle', 'none', ...
                                       'Parent'   , axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                       ); 
                    end                

                    if isShading('get')
                        shading(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'interp');
                   else
                        shading(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'flat');
                   end
                   
                   set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'ydir', 'reverse'); % Patch

                else
                     if gaussFilter('get') == true
                       imAxeF = imagesc(imgaussfilt(imf, 1), ...
                                        'Parent', axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                        );
                    else
                        imAxeF = imagesc(imf, ...
                                         'Parent', axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                         );
                    end

                end
                
                set(imAxeF, 'Visible', 'off'); 
                set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); % Patch
                
                imAxeFPtr('set', imAxeF, get(uiFusedSeriesPtr('get'), 'Value'));          
                rightClickMenu('add', imAxeF);                   
                      
                if aspectRatio('get') == true

                    xf = computeAspectRatio('x', tFuseMetaData);
                    yf = computeAspectRatio('y', tFuseMetaData);

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
%                        cla(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                        delete(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    end
                end
                    
                axes1f = ...
                   axes(uiCorWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'xlimmode','manual',...
                        'ylimmode','manual',...
                        'zlimmode','manual',...
                        'climmode','manual',...
                        'alimmode','manual',...
                        'Position', [0 0 1 1], ...
                        'color','none',...
                        'Visible' , 'off'...
                        );
                axis(axes1f, 'tight');
                axes1fPtr('set', axes1f, get(uiFusedSeriesPtr('get'), 'Value'));
                
%                linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                
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
                        'xlimmode','manual',...
                        'ylimmode','manual',...
                        'zlimmode','manual',...
                        'climmode','manual',...
                        'alimmode','manual',...
                        'Position', [0 0 1 1], ...
                        'color','none',...
                        'Visible' , 'off'...
                        );
                axis(axes2f, 'tight');
                axes2fPtr('set', axes2f, get(uiFusedSeriesPtr('get'), 'Value'));

%                linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                
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
                        'xlimmode','manual',...
                        'ylimmode','manual',...
                        'zlimmode','manual',...
                        'climmode','manual',...
                        'alimmode','manual',...
                        'Position', [0 0 1 1], ...
                        'color','none',...
                        'Visible' , 'off'...
                        );
                axis(axes3f, 'tight');
                
%                axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')  );
%                set(axes3f, 'XLim', axes3.XLim);
%                set(axes3f, 'YLim', axes3.YLim); 
                
                axes3fPtr('set', axes3f, get(uiFusedSeriesPtr('get'), 'Value'));
                
%                linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'xy');                
                uistack(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                
                
                if link2DMip('get') == true && isVsplash('get') == false         
                    if ~isempty(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                        if isvalid(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
%                            cla(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                            delete(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                        end
                    end

                    axesMipf = ...
                       axes(uiMipWindowPtr('get'), ...
                            'Units'   , 'normalized', ...
                            'xlimmode','manual',...
                            'ylimmode','manual',...
                            'zlimmode','manual',...
                            'climmode','manual',...
                            'alimmode','manual',...
                            'Position', [0 0 1 1], ...
                            'color','none',...
                            'Visible' , 'off'...
                            );
                    axis(axesMipf, 'tight');
                    axesMipfPtr('set', axesMipf, get(uiFusedSeriesPtr('get'), 'Value'));

%                    linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');                
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
        
                set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                if strcmp(imageOrientation('get'), 'coronal')
                    B = permute(B, [3 2 1]);
                elseif strcmp(imageOrientation('get'), 'sagittal')
                    B = permute(B, [2 3 1]);
                else
                    B = permute(B, [1 2 3]);
                end

if 0
                if iSeriesOffset ~= iFuseOffset

                    if tFuseInput(iSeriesOffset).bFlipLeftRight == true
                        B=B(:,end:-1:1,:);
                    end

                    if tFuseInput(iSeriesOffset).bFlipAntPost == true
                        B=B(end:-1:1,:,:);
                    end

                    if tFuseInput(iSeriesOffset).bFlipHeadFeet == true
                        B=B(:,:,end:-1:1);
                    end
                end
end
%                tFuseInput(iFuseOffset).bEdgeDetection = false;
%                inputTemplate('set', tFuseInput);

%                [x1,y1,z1] = size(A);
%                [x2,y2,z2] = size(B);                
                 
    %                 msgbox('Warning: Reslice is not yet supported, the fusion may be wrong!');
%                if ( ( tMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                       strcmpi(tMetaData{1}.Modality, 'ct') ) || ...
%                   ( tFuseMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                     strcmpi(tFuseMetaData{1}.Modality, 'ct') ) ) && ...
%                   numel(tMetaData) ~= 1 && ...
%                   numel(tFuseMetaData) ~= 1
               
                    aRefMip = mipBuffer('get', [], iSeriesOffset);
                    aMip    = mipBuffer('get', [], iFuseOffset);
                    
%                    if numel(aMip) ~= numel(aRefMip)  % Resample mip  
                        aResampledMip = resampleMipTransformMatrix(aMip, tFuseMetaData, aRefMip, tMetaData, 'bilinear');   
%                    else
%                        aResampledMip = aMip;
%                    end
                    
    %                if numel(A) ~= numel(B) % Resample image                 
                        [B, tFuseMetaData] = ...
                            resampleImageTransformMatrix(B, ...
                                                         tFuseMetaData, ...
                                                         A, ...
                                                         tMetaData, ...
                                                         'bilinear' ...
                                                         ); 
%                    [B, tFuseMetaData] = ...
%                        resampleImage(B, ...
%                                      tFuseMetaData, ...
%                                      A, ...
%                                      tMetaData, ...
%                                      'bilinear', ...
%                                      false, ...
%                                      false ...
%                                      );                                                     
                                                     
     %               end                             
%                else
                    
%                    aRefMip = mipBuffer('get', [], iSeriesOffset);
%                    aMip = mipBuffer('get', [], iFuseOffset);

%                    aResampledMip = resampleMip(aMip, tFuseMetaData, aRefMip, tMetaData, 'bilinear');  
                    
%                    [B, tFuseMetaData] = ...
%                        resampleImage(B, ...
%                                      tFuseMetaData, ...
%                                      A, ...
%                                      tMetaData, ...
%                                      'bilinear', ...
%                                      false, ...
%                                      );
                                                                                                    
%                end

                fusionBuffer('set', B, iFuseOffset);     
                if link2DMip('get') == true && isVsplash('get') == false      
                    mipFusionBufferOffset('set', iFuseOffset);
                    mipFusionBuffer('set', aResampledMip, iFuseOffset);               
                end
                
                % Init CData
                
                iCoronal  = sliceNumber('get', 'coronal' );
                iSagittal = sliceNumber('get', 'sagittal');
                iAxial    = sliceNumber('get', 'axial'   );        
                iMipAngle = mipAngle('get');

                imf = squeeze(fusionBuffer('get', [], iFuseOffset));    
                
                % Set Coronal

                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'coronal') || ...
                    strcmpi(vSplahView('get'), 'all'))
                
                    imComputed = computeMontage(imf, 'coronal', iCoronal);    

                    if gaussFilter('get') == true   
                        imCoronalF = imagesc(imgaussfilt(imComputed),  ...
                                            'Parent', axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                            );                                        
                    else
                        imCoronalF = imagesc(imComputed,  ...
                                            'Parent', axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                            );                         
                    end

                    imCoronalFPtr('set', imCoronalF, get(uiFusedSeriesPtr('get'), 'Value')); 


                    imCoronalF.CData = imComputed;                         

                else                       

                    if is3DEngine('get') == true
                        
                        if gaussFilter('get') == true
                            imCoronalF = surface(imgaussfilt(permute(imf(iCoronal,:,:), [3 2 1]), 1), ...
                                                 'linestyle', 'none', ...
                                                 'Parent'   , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 );                                      
                        else      
                            imCoronalF = surface(permute(imf(iCoronal,:,:), [3 2 1]), ...
                                                 'linestyle','none', ...
                                                 'Parent'   , axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 ); 
                        end
                        
                        if isShading('get')
                            shading(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'interp');
                            shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) , 'interp');
                        else
                            shading(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'flat');
                            shading(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) , 'flat');
                        end
                        
                        set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'ydir', 'reverse'); % Patch

                    else
                         if gaussFilter('get') == true
                            imCoronalF = imagesc(imgaussfilt(permute(imf(iCoronal,:,:), [3 2 1])), ...
                                                 'Parent', axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 );                                                                                                                              
                        else
                            imCoronalF = imagesc(permute(imf(iCoronal,:,:), [3 2 1]),  ...
                                                 'Parent', axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 );               
                         end
                    end
                    

                    imCoronalFPtr('set', imCoronalF, get(uiFusedSeriesPtr('get'), 'Value')); 
                    rightClickMenu('add', imCoronalF);

                end
                
                set(imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
 
                % Set Sagittal
                                                
                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'sagittal') || ...
                    strcmpi(vSplahView('get'), 'all'))
                
                    imComputed = computeMontage(imf, 'sagittal', iSagittal);  

                    if gaussFilter('get') == true
                        imSagittalF  = imagesc(imgaussfilt(imComputed), ...
                                               'Parent', axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                               );                                                                                                  
                    else                    
                        imSagittalF  = imagesc(imComputed, ...
                                               'Parent', axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                               );                                                                                                
                    end

                    imSagittalFPtr('set', imSagittalF, get(uiFusedSeriesPtr('get'), 'Value'));

%                    imSagittalF.CData = imComputed;                           

                else

                    if is3DEngine('get') == true
                        
                        if gaussFilter('get') == true
                            imSagittalF = surface(imgaussfilt(permute(imf(:,iSagittal,:), [3 1 2]),1), ...
                                                  'linestyle', 'none', ...
                                                  'Parent'   , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                  );
                        else    
                            imSagittalF = surface(permute(imf(:,iSagittal,:), [3 1 2]), ...
                                                  'linestyle', 'none', ...
                                                  'Parent'   , axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                  );
                        end

                        if isShading('get')
                            shading(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'interp');
                        else
                            shading(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'flat');
                        end
                        
                        set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'ydir', 'reverse'); % Patch

                    else                    
                         if gaussFilter('get') == true
                            imSagittalF  = imagesc(imgaussfilt(permute(imf(:,iSagittal,:), [3 1 2])), ...
                                                   'Parent', axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                   );                                                                                                                               
                        else
                            imSagittalF  = imagesc(permute(imf(:,iSagittal,:), [3 1 2]), ...
                                                   'Parent', axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                   );                                                                                                                              
                         end
                    end

                    imSagittalFPtr('set', imSagittalF, get(uiFusedSeriesPtr('get'), 'Value'));
                    rightClickMenu('add', imSagittalF);
                end                
                
                set(imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                
                % Set Axial
                                                
                if isVsplash('get') == true && ...
                   (strcmpi(vSplahView('get'), 'axial') || ...
                    strcmpi(vSplahView('get'), 'all'))
                
                     imComputed = computeMontage(imf(:,:,end:-1:1), ...
                                                'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1 ...
                                                ); 
                                            
                    if gaussFilter('get') == true                    
                       imAxialF = imagesc(imgaussfilt(imComputed),  ...
                                          'Parent', axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                          );                                                                                                                    
                    else     
                       imAxialF = imagesc(imComputed,  ...
                                          'Parent', axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                          );                                                                                    
                    end

                    imAxialFPtr('set', imAxialF, get(uiFusedSeriesPtr('get'), 'Value'));

    
                  %  imAxialF.CData = imComputed;

                else
                    if is3DEngine('get') == true
                        if gaussFilter('get') == true
                            imAxialF = surface(imgaussfilt(imf(:,:,iAxial),1), ...
                                               'linestyle', 'none', ...
                                               'Parent'   , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                               ); 
                        else
                           imAxialF = surface(imf(:,:,iAxial), ...
                                              'linestyle', 'none', ...
                                              'Parent'   , axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                              );                                   
                        end

                        if isShading('get')
                            shading(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'interp');
                        else
                            shading(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'flat');
                        end        
                        
                        set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'ydir', 'reverse'); % Patch

                    else
                        if gaussFilter('get') == true
                            imAxialF = imagesc(imgaussfilt(imf(:,:,iAxial)), ...
                                               'Parent', axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                               );                                                                                                                               
                        else
                           imAxialF = imagesc(imf(:,:,iAxial),  ...
                                              'Parent', axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                              );                                                                                                                               
                        end

                    end

                    imAxialFPtr('set', imAxialF, get(uiFusedSeriesPtr('get'), 'Value'));
                    rightClickMenu('add', imAxialF);

                end
                
                set(imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                    
                % Set Mip
                
                if link2DMip('get') == true && ...
                   isVsplash('get') == false         


                    imComputedMipF = mipFusionBuffer('get', [], iFuseOffset);                                  

                    if is3DEngine('get') == true
                        if gaussFilter('get') == true
                            imMipF = surface(imgaussfilt(permute(imComputedMipF(iMipAngle,:,:), [3 2 1]), 1), ...
                                                 'linestyle', 'none', ...
                                                 'Parent'   , axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 ); 
                        else      
                            imMipF = surface(permute(imComputedMipF(iMipAngle,:,:), [3 2 1]), ...
                                                 'linestyle','none', ...
                                                 'Parent'   , axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 ); 
                        end

                        if isShading('get')
                            shading(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'interp');
                        else
                            shading(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'flat');
                        end
                        
                         set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'ydir', 'reverse'); % Patch
                       
                    else
                         if gaussFilter('get') == true
                            imMipF = imagesc(imgaussfilt(permute(imComputedMipF(iMipAngle,:,:), [3 2 1])), ...
                                                 'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 );                                                                

                        else
                            imMipF = imagesc(permute(imComputedMipF(iMipAngle,:,:), [3 2 1]),  ...
                                                 'Parent', axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ...
                                                 );               
                         end
                    end                                             

                    imMipFPtr('set', imMipF, get(uiFusedSeriesPtr('get'), 'Value'));
                    set(imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); 
                end                      
                
                set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off'); % Patch

                % Init Aspect Ratio

                if aspectRatio('get') == true

                    if ~isempty(tFuseMetaData{1}.PixelSpacing)
                        xf = tFuseMetaData{1}.PixelSpacing(1);
                        yf = tFuseMetaData{1}.PixelSpacing(2);
                        zf = computeSliceSpacing(tFuseMetaData);

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

                        xf = computeAspectRatio('x', tFuseMetaData) ;
                        yf = computeAspectRatio('y', tFuseMetaData) ;
                        zf = 1;
                    end

                   if strcmp(imageOrientation('get'), 'axial')
                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                                                
                        if link2DMip('get') == true && isVsplash('get') == false                       
                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                        end
                   elseif strcmp(imageOrientation('get'), 'coronal')
                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);
                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                        if link2DMip('get') == true && isVsplash('get') == false                       
                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                        end
                    elseif strcmp(imageOrientation('get'), 'sagittal')
                        daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);
                        daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);
                        daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                        if link2DMip('get') == true && isVsplash('get') == false                       
                            daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);
                        end
                    end
                else
                    xf =1;
                    yf =1;
                    zf =1;

                    daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    if link2DMip('get') == true && isVsplash('get') == false                       
                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [1 1 1]);
                    end
                    
                    axis(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    axis(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    if link2DMip('get') == true && isVsplash('get') == false                                           
                        axis(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                    end
                end

                fusionAspectRatioValue('set', 'x', xf);
                fusionAspectRatioValue('set', 'y', yf);
                fusionAspectRatioValue('set', 'z', zf);
            end

            progressBar(1, 'Ready');

            set(btnFusionPtr('get')    , 'Enable', 'on');
            set(uiFusedSeriesPtr('get'), 'Enable', 'on');

            isFusion('set', true);

            set(btnFusionPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnFusionPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        else
                                                
            if numel(tFuseInput) == 1
                if tFuseInput(iFuseOffset).bEdgeDetection == false
                    tFuseInput(iFuseOffset).bFusedEdgeDetection = false;
                end
            else
                tFuseInput(iFuseOffset).bEdgeDetection = false;
            end

%           tFuseInput(iFuseOffset).bEdgeDetection = false;
           inputTemplate('set', tFuseInput);

           isFusion('set', false);

           initFusionWindowLevel('set', false); % Need to be fix

           set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
           set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
           
           if isPlotContours('get') == true % Deactivate plot contours
               setPlotContoursCallback();
           end
           
    %         fusionBuffer('set', '');
        end

        if initFusionWindowLevel('get') == true
            initFusionWindowLevel('set', false);

            if strcmpi(tFuseMetaData{1}.Modality, 'ct')
                if min(B, [], 'all') >= 0
                    dMax = max(B, [], 'all');
                    dMin = min(B, [], 'all');
                else
                    [dMax, dMin] = computeWindowLevel(500, 50);
                end
            else
                sUnitDisplay = getSerieUnitValue(iFuseOffset);
                if strcmpi(sUnitDisplay, 'SUV')
                    if tFuseInput(iFuseOffset).tQuant.tSUV.dScale
                        dMin = suvWindowLevel('get', 'min')/tFuseInput(iFuseOffset).tQuant.tSUV.dScale;
                        dMax = suvWindowLevel('get', 'max')/tFuseInput(iFuseOffset).tQuant.tSUV.dScale;
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

            sliderFusionWindowLevelValue('set', 'min', 0.5);
            sliderFusionWindowLevelValue('set', 'max', 0.5);

            set(uiFusionSliderWindowPtr('get'), 'Value', 0.5);
            set(uiFusionSliderLevelPtr('get' ), 'Value', 0.5);

            getFusionInitWindowMinMax('set', dMax, dMin);

       %     sliderAlphaValue('set', 0.5);
            set(uiAlphaSliderPtr('get') , 'Value', sliderAlphaValue('get'));

            if size(fusionBuffer('get', [], iFuseOffset), 3) == 1
                set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
            else
                set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);
                if  link2DMip('get') == true && isVsplash('get') == false      
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
                if  link2DMip('get') == true && isVsplash('get') == false      
                    set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
                end
            end
        end

        uiAlphaSlider = uiAlphaSliderPtr('get');
        aFigurePosition  = uiAlphaSlider.Parent.Position;

        uiSegMainPanel    = uiSegMainPanelPtr('get');
        uiKernelMainPanel = uiKernelMainPanelPtr('get');
        uiRoiMainPanel    = uiRoiMainPanelPtr('get');

        if size(dicomBuffer('get'), 3) == 1

            if viewSegPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiSegMainPanel.Position(3)+10 ...
                                 35 ...
                                 aFigurePosition(3)-uiSegMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            elseif viewKernelPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiKernelMainPanel.Position(3)+10 ...
                                 35 ...
                                 aFigurePosition(3)-uiKernelMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            elseif viewRoiPanel('get') == true
                set(uiAlphaSlider, ...
                    'Position', [uiRoiMainPanel.Position(3)+10 ...
                                 35 ...
                                 aFigurePosition(3)-uiRoiMainPanel.Position(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            else
                set(uiAlphaSlider, ...
                    'Position', [10 ...
                                 35 ...
                                 aFigurePosition(3)-20 ...
                                 15 ...
                                 ] ...
                   );
            end
        else
           if isVsplash('get') == true && ...
               ~strcmpi(vSplahView('get'), 'all')
                if viewSegPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiSegMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)-uiSegMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                elseif viewKernelPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiKernelMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)-uiKernelMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                elseif viewRoiPanel('get') == true

                    set(uiAlphaSlider, ...
                        'Position', [uiRoiMainPanel.Position(3)+10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)-uiRoiMainPanel.Position(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                else
                    set(uiAlphaSlider, ...
                        'Position', [10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)-20 ...
                                     15 ...
                                     ] ...
                        );
                end
           else
                if isVsplash('get') == true
                    set(uiAlphaSlider, ...
                        'Position', [aFigurePosition(3)/2+10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)/2-20 ...
                                     15 ...
                                     ] ...
                        );
                else
                    set(uiAlphaSlider, ...
                        'Position', [aFigurePosition(3)/2.5+10 ...
                                     addOnWidth('get')+50 ...
                                     aFigurePosition(3)/2.5-20 ...
                                     15 ...
                                     ] ...
                        );
                end
            end
        end
        set(uiAlphaSlider, 'BackgroundColor', backgroundColor('get'));
        
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

                ptrFusionColorbar = ...
                    colorbar(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                             'AxisLocation' , 'in', ...
                             'Tag'          , 'Fusion Colorbar', ...
                             'EdgeColor'    , overlayColor('get'), ...
                             'Units'        , 'pixels', ...
                             'Box'          , 'off', ...
                             'Location'     , 'east', ...
                             'ButtonDownFcn', @colorbarCallback ...
                             );   
                         
                ptrFusionColorbar.TickLabels = [];         
                
                uiFusionColorbarPtr('set', ptrFusionColorbar);
                colorbarCallback(ptrFusionColorbar); % Fix for Linux
                                
            else
                colormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));
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

                if isVsplash('get') == true && ...
                   ~strcmpi(vSplahView('get'), 'all')
                    if strcmpi(vSplahView('get'), 'coronal')
                        ptrFusionColorbar = ...
                            colorbar(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                     'AxisLocation' , 'in', ...
                                     'Tag'          , 'Fusion Colorbar', ...
                                     'EdgeColor'    , overlayColor('get'), ...
                                     'Units'        , 'pixels', ...
                                     'Box'          , 'off', ...
                                     'Location'     , 'east', ...
                                     'ButtonDownFcn', @colorbarCallback ...
                                     );            
                    elseif strcmpi(vSplahView('get'), 'sagittal')
                        ptrFusionColorbar = ...
                            colorbar(axes2fPtr('get'), ...
                                     'AxisLocation' , 'in', ...
                                     'Tag'          , 'Fusion Colorbar', ...
                                     'EdgeColor'    , overlayColor('get'), ...
                                     'Units'        , 'pixels', ...
                                     'Box'          , 'off', ...
                                     'Location'     , 'east', ...
                                     'ButtonDownFcn', @colorbarCallback ...
                                     );            
                    else
                        ptrFusionColorbar = ...
                            colorbar(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                     'AxisLocation' , 'in', ...
                                     'Tag'          , 'Fusion Colorbar', ...
                                     'EdgeColor'    , overlayColor('get'), ...
                                     'Units'        , 'pixels', ...
                                     'Box'          , 'off', ...
                                     'Location'     , 'east', ...
                                     'ButtonDownFcn', @colorbarCallback ...
                                     );            
                    end

                else
                    ptrFusionColorbar = ...
                        colorbar(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), ...
                                 'AxisLocation' , 'in', ...
                                 'Tag'          , 'Fusion Colorbar', ...
                                 'EdgeColor'    , overlayColor('get'), ...
                                 'Units'        , 'pixels', ...
                                 'Box'          , 'off', ...
                                 'Location'     , 'east', ...
                                 'ButtonDownFcn', @colorbarCallback ...
                                 );            
                end
                
                ptrFusionColorbar.TickLabels = [];                 
                
                uiFusionColorbarPtr('set', ptrFusionColorbar);
                colorbarCallback(ptrFusionColorbar); % Fix for Linux  
            else
                colormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));    
                
                colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));  
                
                if link2DMip('get') == true && isVsplash('get') == false      
                    colormap(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));                 
                end
            end
        end
        
        ptrFusionColorbar = uiFusionColorbarPtr('get');
        aFigurePosition = ptrFusionColorbar.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1
            set(ptrFusionColorbar, ...
                'Position', [aFigurePosition(3)-49 ...
                             27 ...
                             40 ...
                             ((aFigurePosition(4))/2)-41  ...
                             ] ...
                );
        else
            if isVsplash('get') == true && ...
              ~strcmpi(vSplahView('get'), 'all')
                if viewSegPanel('get')

                    set(ptrFusionColorbar, ...
                        'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aFigurePosition(4))/2)-35  ...
                                     ] ...
                        );
                elseif viewKernelPanel('get') == true

                    set(ptrFusionColorbar, ...
                        'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aFigurePosition(4))/2)-35  ...
                                     ] ...
                        );
                elseif viewRoiPanel('get') == true

                    set(ptrFusionColorbar, ...
                        'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                     29 ...
                                     40 ...
                                     ((aFigurePosition(4))/2)-35  ...
                                     ] ...
                        );
                else
                    set(ptrFusionColorbar, ...
                        'Position', [aFigurePosition(3)-49 ...
                                     29 ...
                                     40 ...
                                     ((aFigurePosition(4))/2)-35  ...
                                     ] ...
                        );
                end
            else
                set(ptrFusionColorbar, ...
                    'Position', [aFigurePosition(3)-49 ...
                                 29 ...
                                 40 ...
                                 ((aFigurePosition(4))/2)-35  ...
                                 ] ...
                    );
            end
        end

        uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
        aFigurePosition = uiFusionSliderWindow.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1

            set(uiFusionSliderWindow, ...
                'Position', [aFigurePosition(3)-50 ...
                             55 ...
                             12 ...
                             (aFigurePosition(4)/2)-75  ...
                             ] ...
                );
        else
            if isVsplash('get') == true
                set(uiFusionSliderWindow, ...
                    'Position', [aFigurePosition(3)-50 ...
                                 70 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-75  ...
                                 ] ...
                    );
            else
                uiTraWindow = uiTraWindowPtr('get');
                aAxePosition = uiTraWindow.Position;

                set(uiFusionSliderWindow, ...
                    'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
                                 70 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-75  ...
                                 ] ...
                    );
            end
        end

        set(uiFusionSliderWindow, ...
            'BackgroundColor', backgroundColor('get') ...
            );

        uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
        aFigurePosition = uiFusionSliderLevel.Parent.Position;
        if size(dicomBuffer('get'), 3) == 1
            set(uiFusionSliderLevel, ...
                'Position', [aFigurePosition(3)-21 ...
                             55 ...
                             12 ...
                             (aFigurePosition(4)/2)-75  ...
                             ] ...
                );
        else
            if isVsplash('get') == true
                set(uiFusionSliderLevel, ...
                    'Position', [aFigurePosition(3)-21 ...
                                 70 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-75  ...
                                 ] ...
                    );
            else
                uiTraWindow = uiTraWindowPtr('get');
                aAxePosition = uiTraWindow.Position;

                set(uiFusionSliderLevel, ...
                    'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
                                 70 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-75  ...
                                 ] ...
                    );
            end
        end

        set(uiFusionSliderLevel, ...
            'BackgroundColor', backgroundColor('get') ...
            );
        end
        if isFusion('get') == true

            uiSliderWindow = uiSliderWindowPtr('get');
            aFigurePosition = uiSliderWindow.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1
                set(uiSliderWindow, ...
                    'Position', [aFigurePosition(3)-50 ...
                                 (aFigurePosition(4)/2)-15 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-30  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true
                    set(uiSliderWindow, ...
                        'Position', [aFigurePosition(3)-50 ...
                                     aFigurePosition(4)/2 ...
                                     12 ...
                                     (aFigurePosition(4)/2)-45  ...
                                     ] ...
                        );
                else
                    uiTraWindow = uiTraWindowPtr('get');
                    aAxePosition = uiTraWindow.Position;

                    set(uiSliderWindow, ...
                        'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
                                     aFigurePosition(4)/2 ...
                                     12 ...
                                     (aFigurePosition(4)/2)-45  ...
                                     ] ...
                        );
                end
            end

            set(uiSliderWindow, ...
                'BackgroundColor', backgroundColor('get') ...
                );

            uiSliderLevel = uiSliderLevelPtr('get');
            aFigurePosition = uiSliderLevel.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderLevel, ...
                    'Position', [aFigurePosition(3)-21 ...
                                 (aFigurePosition(4)/2)-15 ...
                                 12 ...
                                 (aFigurePosition(4)/2)-30  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true
                    set(uiSliderLevel, ...
                        'Position', [aFigurePosition(3)-21 ...
                                     aFigurePosition(4)/2 ...
                                     12 ...
                                     (aFigurePosition(4)/2)-45  ...
                                     ] ...
                        );
                else
                    uiTraWindow = uiTraWindowPtr('get');
                    aAxePosition = uiTraWindow.Position;

                    set(uiSliderLevel, ...
                        'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
                                     aFigurePosition(4)/2 ...
                                     12 ...
                                     (aFigurePosition(4)/2)-45  ...
                                     ] ...
                        );
                end
            end

            set(uiSliderLevel, ...
                'BackgroundColor', backgroundColor('get') ...
                );

            ptrColorbar = uiColorbarPtr('get');
            aFigurePosition = ptrColorbar.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(ptrColorbar, ...
                    'Position', [aFigurePosition(3)-49 ...
                                 (aFigurePosition(4)/2)-9 ...
                                 40 ...
                                 (aFigurePosition(4)/2)+5  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true && ...
                  ~strcmpi(vSplahView('get'), 'all')

                    if viewSegPanel('get')

                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                         (aFigurePosition(4)/2) ...
                                         40 ...
                                         (aFigurePosition(4)/2)-4  ...
                                         ] ...
                            );
                    elseif viewKernelPanel('get') == true

                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                         (aFigurePosition(4)/2) ...
                                         40 ...
                                         (aFigurePosition(4)/2)-4  ...
                                         ] ...
                            );
                    elseif viewRoiPanel('get') == true

                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                         (aFigurePosition(4)/2) ...
                                         40 ...
                                         (aFigurePosition(4)/2)-4  ...
                                         ] ...
                            );
                    else
                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-49 ...
                                         (aFigurePosition(4)/2) ...
                                         40 ...
                                         (aFigurePosition(4)/2)-4  ...
                                         ] ...
                            );
                    end
                else
                    set(ptrColorbar, ...
                        'Position', [aFigurePosition(3)-49 ...
                                     (aFigurePosition(4)/2) ...
                                     40 ...
                                     (aFigurePosition(4)/2)-4  ...
                                     ] ...
                        );
                end
            end
        else

            uiSliderWindow = uiSliderWindowPtr('get');
            aFigurePosition = uiSliderWindow.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderWindow, ...
                    'Position', [aFigurePosition(3)-50 ...
                                 35 ...
                                 12 ...
                                 aFigurePosition(4)-80  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true
                    set(uiSliderWindow, ...
                        'Position', [aFigurePosition(3)-50 ...
                                     50 ...
                                     12 ...
                                     aFigurePosition(4)-95  ...
                                     ] ...
                        );
                else
                    uiTraWindow = uiTraWindowPtr('get');
                    aAxePosition = uiTraWindow.Position;

                    set(uiSliderWindow, ...
                        'Position', [aAxePosition(1)+aAxePosition(3)-50 ...
                                     50 ...
                                     12 ...
                                     aFigurePosition(4)-95  ...
                                     ] ...
                        );
                end
            end

            uiSliderLevel = uiSliderLevelPtr('get');
            aFigurePosition = uiSliderLevel.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(uiSliderLevel, ...
                    'Position', [aFigurePosition(3)-21 ...
                                 35 ...
                                 12 ...
                                 aFigurePosition(4)-80  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true
                    set(uiSliderLevel, ...
                        'Position', [aFigurePosition(3)-21 ...
                                     50 ...
                                     12 ...
                                     aFigurePosition(4)-95  ...
                                     ] ...
                       );
                else
                    uiTraWindow = uiTraWindowPtr('get');
                    aAxePosition = uiTraWindow.Position;

                    set(uiSliderLevel, ...
                        'Position', [aAxePosition(1)+aAxePosition(3)-21 ...
                                     50 ...
                                     12 ...
                                     aFigurePosition(4)-95  ...
                                     ] ...
                       );
                end
            end

            ptrColorbar = uiColorbarPtr('get');
            aFigurePosition = ptrColorbar.Parent.Position;
            if size(dicomBuffer('get'), 3) == 1

                set(ptrColorbar, ...
                    'Position', [aFigurePosition(3)-49 ...
                                 7 ...
                                 40 ...
                                 aFigurePosition(4)-11  ...
                                 ] ...
                    );
            else
                if isVsplash('get') == true && ...
                  ~strcmpi(vSplahView('get'), 'all')
                    if viewSegPanel('get')

                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiSegMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aFigurePosition(4)-11  ...
                                         ] ...
                            );
                    elseif viewKernelPanel('get') == true
                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiKernelMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aFigurePosition(4)-11  ...
                                         ] ...
                            );
                    elseif viewRoiPanel('get') == true
                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-(uiRoiMainPanel.Position(3)/2)-49 ...
                                         7 ...
                                         40 ...
                                         aFigurePosition(4)-11  ...
                                         ] ...
                            );
                    else
                        set(ptrColorbar, ...
                            'Position', [aFigurePosition(3)-49 ...
                                         7 ...
                                         40 ...
                                         aFigurePosition(4)-11  ...
                                         ] ...
                            );
                    end
                else
                    set(ptrColorbar, ...
                        'Position', [aFigurePosition(3)-49 ...
                                     7 ...
                                     40 ...
                                     aFigurePosition(4)-11  ...
                                     ] ...
                        );
                end
            end
        end
     
        if isFusion('get') == true
            
            set( uiFusionColorbarPtr('get')    , 'Visible', 'on' );
            set( uiFusionSliderWindowPtr('get'), 'Visible', 'on' );
            set( uiFusionSliderLevelPtr('get') , 'Visible', 'on' );
            set( uiAlphaSliderPtr('get')       , 'Visible', 'on' );
            
            % Set fused axes on same field of view

            if size(fusionBuffer('get', [], iFuseOffset), 3) == 1

                axe  = axePtr ('get', [], get(uiSeriesPtr('get'), 'Value')  );
                axef = axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                set(axef, 'XLim', axe.XLim);
                set(axef, 'YLim', axe.YLim); 

                linkaxes([axe axef], 'xy');                     
            else
                
                axes1  = axes1Ptr ('get', [], get(uiSeriesPtr('get'), 'Value')  );
                axes1f = axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                set(axes1f, 'XLim', axes1.XLim);
                set(axes1f, 'YLim', axes1.YLim); 

                linkaxes([axes1 axes1f], 'xy'); 

                axes2  = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')  );
                axes2f = axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                set(axes2f, 'XLim', axes2.XLim);
                set(axes2f, 'YLim', axes2.YLim); 

                linkaxes([axes2 axes2f], 'xy'); 

                axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')  );
                axes3f = axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                set(axes3f, 'XLim', axes3.XLim);
                set(axes3f, 'YLim', axes3.YLim); 

                linkaxes([axes3 axes3f], 'xy'); 
                
                if link2DMip('get') == true && isVsplash('get') == false         
                    
                    axesMip  = axesMipPtr ('get', [], get(uiSeriesPtr('get'), 'Value'));
                    axesMipf = axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                    
                    set(axesMipf, 'XLim', axesMip.XLim);
                    set(axesMipf, 'YLim', axesMip.YLim); 

                    linkaxes([axesMip axesMipf], 'xy');               
                end                                
            end
                        
            if size(dicomBuffer('get'), 3) == 1
                set( imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'Visible', 'on' );

                alpha( axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , 1-get(uiAlphaSliderPtr('get'), 'Value') );                    
            else

                set( imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                set( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                set( imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                
                if link2DMip('get') == true && isVsplash('get') == false      
                    set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                end

                alpha( axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
                
                if link2DMip('get') == true && isVsplash('get') == false      
                    alpha( axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );                                
                end 

                alpha( axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                alpha( axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
                
                if link2DMip('get') == true && isVsplash('get') == false      
                    alpha( axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-get(uiAlphaSliderPtr('get'), 'Value') );                                
                end 
            end
            
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
                    mipFusionBuffer('reset');               
                    axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                    if ~isempty(axesMip)
                        alpha(axesMip, 1 );                                
                    end
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

            set(uiLogo, 'Position', [5 35 70 30]);
        else
            set(uiLogo, 'Position', [5 15 70 30]);
        end

        setViewerDefaultColor(true, tMetaData, tFuseMetaData);

        refreshImages(); 
            
    end
    
    catch
        progressBar(1, 'Error:setFusionCallback()');
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
