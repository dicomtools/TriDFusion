function setPlotContoursCallback(~, ~)
%function setPlotContoursCallback()
%Init 2D image contours.
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

    if size(dicomBuffer('get'), 3) == 1 % 2D Image

        if isPlotContours('get') == true

            isPlotContours('set', false);

            linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get',[],  get(uiFusedSeriesPtr('get'), 'Value'))],'off');

            imAxeFcPtr('reset');

        else
            isPlotContours('set', true);

            if isempty(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axeFc = ...
                   axes(uiOneWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Ydir'    , 'reverse', ...
                        'xlimmode', 'manual',...
                        'ylimmode', 'manual',...
                        'zlimmode', 'manual',...
                        'climmode', 'manual',...
                        'alimmode', 'manual',...
                        'Position', [0 0 1 1], ...
                        'color'   ,'none',...
                        'Tag'     , 'axeFc', ...
                        'Visible' , 'off'...
                        );
                axis(axeFc, 'tight');
                axefcPtr('set', axeFc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                uistack(axefcPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'top');
            end

            linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');

            cla(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ,'reset');

            imf = squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            if isShowTextContours('get', 'axe') == true
                sShowTextEnable = 'on';
            else
                sShowTextEnable = 'off';
            end

            if isShowFaceAlphaContours('get')
                [~,imAxeFc] = contourf(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:), 'ShowText', sShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
            else
                [~,imAxeFc] = contour(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:), 'ShowText', sShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
            end

            imAxeFcPtr('set', imAxeFc, get(uiFusedSeriesPtr('get'), 'Value'));

            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , [0 inf], ...
                'YLim'    , [0 inf], ...
                'CLim'    , [0 inf] ...
                );
            axis(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

            linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            colormap( axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')) );

            if aspectRatio('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
%               zf = fusionAspectRatioValue('get', 'z');

                daspect(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf 1]);
            else
                xf =1;
                yf =1;
                zf =1;

                daspect(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);

                axis(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
            end

            set(imAxeFc , 'Visible', 'on');

        end

    else % 3D Images

        if isPlotContours('get') == true

            isPlotContours('set', false);

            linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            if link2DMip('get') == true || isFusion('get') == false
                linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            end

            imCoronalFcPtr ('reset');
            imSagittalFcPtr('reset');
            imAxialFcPtr   ('reset');
            if link2DMip('get') == true || isFusion('get') == false
                imMipFcPtr('reset');
            end

        else
            isPlotContours('set', true);

            % Init axes

            if isempty(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes1fc = ...
                   axes(uiCorWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Ydir'    , 'reverse', ...
                        'xlimmode', 'manual',...
                        'ylimmode', 'manual',...
                        'zlimmode', 'manual',...
                        'climmode', 'manual',...
                        'alimmode', 'manual',...
                        'Position', [0 0 1 1], ...
                        'color'   , 'none',...
                        'Tag'     , 'axes1fc', ...
                        'Visible' , 'off'...
                        );
                axis(axes1fc, 'tight');
                axes1fcPtr('set', axes1fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                uistack(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
            end

            if isempty(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes2fc = ...
                   axes(uiSagWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Ydir'    , 'reverse', ...
                        'xlimmode', 'manual',...
                        'ylimmode', 'manual',...
                        'zlimmode', 'manual',...
                        'climmode', 'manual',...
                        'alimmode', 'manual',...
                        'Position', [0 0 1 1], ...
                        'color'   , 'none',...
                        'Tag'     , 'axes2fc', ...
                        'Visible' , 'off'...
                        );
                axis(axes2fc, 'tight');
                axes2fcPtr('set', axes2fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                uistack(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
            end

            if isempty(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes3fc = ...
                   axes(uiTraWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Ydir'    , 'reverse', ...
                        'xlimmode', 'manual',...
                        'ylimmode', 'manual',...
                        'zlimmode', 'manual',...
                        'climmode', 'manual',...
                        'alimmode', 'manual',...
                        'Position', [0 0 1 1], ...
                        'color'   , 'none',...
                        'Tag'     , 'axes3fc', ...
                        'Visible' , 'off'...
                        );
                axis(axes3fc, 'tight');
                axes3fcPtr('set', axes3fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                uistack(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
            end

            if link2DMip('get') == true && isVsplash('get') == false
                if isempty(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    axesMipfc = ...
                       axes(uiMipWindowPtr('get'), ...
                            'Units'   , 'normalized', ...
                            'Ydir'    , 'reverse', ...
                            'xlimmode', 'manual',...
                            'ylimmode', 'manual',...
                            'zlimmode', 'manual',...
                            'climmode', 'manual',...
                            'alimmode', 'manual',...
                            'Position', [0 0 1 1], ...
                            'color'   , 'none',...
                            'Tag'     , 'axesMipfc', ...
                            'Visible' , 'off'...
                            );
                    axis(axesMipfc, 'tight');
                    axesMipfcPtr('set', axesMipfc, get(uiFusedSeriesPtr('get'), 'Value'));

                    linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                    uistack(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
                end
            end
            
                
            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );

            iMipAngle = mipAngle('get');

            linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'off');
            linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'off');
            linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'off');
            
            if link2DMip('get') == true || isFusion('get') == false
                linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))], 'off');
            end

            cla(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ,'reset');
            cla(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ,'reset');
            cla(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ,'reset');
            
            if link2DMip('get') == true && isVsplash('get') == false
                cla(axesMipfcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
            end

            imf = squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
            imMf = mipFusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            if isShowTextContours('get', 'coronal') == true
                sCoronalShowTextEnable = 'on';
            else
                sCoronalShowTextEnable = 'off';
            end

            if isShowTextContours('get', 'sagittal') == true
                sSagittalShowTextEnable = 'on';
            else
                sSagittalShowTextEnable = 'off';
            end

            if isShowTextContours('get', 'axial') == true
                sAxialShowTextEnable = 'on';
            else
                sAxialShowTextEnable = 'off';
            end

            if isShowTextContours('get', 'mip') == true
                sMipShowTextEnable = 'on';
            else
                sMipShowTextEnable = 'off';
            end

            if isShowFaceAlphaContours('get')
                [~,imCoronalFc ] = contourf(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(iCoronal,:,:), [3 2 1]), 'ShowText', sCoronalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imSagittalFc] = contourf(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(:,iSagittal,:), [3 1 2]), 'ShowText', sSagittalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imAxialFc   ] = contourf(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:,iAxial), 'ShowText', sAxialShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');

                if link2DMip('get') == true && isVsplash('get') == false
                    [~,imMipFc] = contourf(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imMf(iMipAngle,:,:), [3 2 1]), 'ShowText', sMipShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                end
            else

                [~,imCoronalFc ] = contour(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(iCoronal,:,:), [3 2 1]), 'ShowText', sCoronalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imSagittalFc] = contour(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(:,iSagittal,:), [3 1 2]), 'ShowText', sSagittalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imAxialFc   ] = contour(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:,iAxial), 'ShowText', sAxialShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');

                if link2DMip('get') == true && isVsplash('get') == false
                    [~,imMipFc] = contour(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imMf(iMipAngle,:,:), [3 2 1]), 'ShowText', sMipShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                end
            end

            imCoronalFcPtr ('set', imCoronalFc , get(uiFusedSeriesPtr('get'), 'Value') );
            imSagittalFcPtr('set', imSagittalFc, get(uiFusedSeriesPtr('get'), 'Value') );
            imAxialFcPtr   ('set', imAxialFc   , get(uiFusedSeriesPtr('get'), 'Value') );
            
            if link2DMip('get') == true && isVsplash('get') == false
                imMipFcPtr('set', imMipFc, get(uiFusedSeriesPtr('get'), 'Value') );
            end

            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , [0 inf], ...
                'YLim'    , [0 inf], ...
                'CLim'    , [0 inf] ...
                );
            axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

            linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , [0 inf], ...
                'YLim'    , [0 inf], ...
                'CLim'    , [0 inf] ...
                );
            axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

            linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , [0 inf], ...
                'YLim'    , [0 inf], ...
                'CLim'    , [0 inf] ...
                );
            axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

            linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            if link2DMip('get') == true && isVsplash('get') == false
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'Units'   , 'normalized', ...
                    'Position', [0 0 1 1], ...
                    'Visible' , 'off', ...
                    'Ydir'    , 'reverse', ...
                    'XLim'    , [0 inf], ...
                    'YLim'    , [0 inf], ...
                    'CLim'    , [0 inf] ...
                    );

                axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

                linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off');

            end

            colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
            colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
            colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
            
            if link2DMip('get') == true && isVsplash('get') == false
                colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
            end

            if aspectRatio('get') == true

                xf = fusionAspectRatioValue('get', 'x');
                yf = fusionAspectRatioValue('get', 'y');
                zf = fusionAspectRatioValue('get', 'z');
               
                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);

                if isVsplash('get') == false                                    
                    daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                end
                
%               if strcmp(imageOrientation('get'), 'axial')

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf xf yf]);
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf yf xf]);
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [xf yf zf]);
                    
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
%                    end

%               elseif strcmp(imageOrientation('get'), 'coronal')

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                    
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);
%                    end

%                elseif strcmp(imageOrientation('get'), 'sagittal')

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                    
%                    if link2DMip('get') == true && isVsplash('get') == false
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);
%                    end
%               end
            else
                xf =1;
                yf =1;
                zf =1;

                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);
                
                if isVsplash('get') == false
                    daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                end

                axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                
                if isVsplash('get') == false
                    axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                end

            end

            set(imCoronalFc , 'Visible', 'on');
            set(imSagittalFc, 'Visible', 'on');
            set(imAxialFc   , 'Visible', 'on');
            
            if link2DMip('get') == true && isVsplash('get') == false
                set(imMipFc, 'Visible', 'on');
            end
            
            % Need to clear some space for the colorbar
            
            if isVsplash('get') == true && ...
               ~strcmpi(vSplahView('get'), 'all')

                if strcmpi(vSplahView('get'), 'coronal')
                    set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                elseif strcmpi(vSplahView('get'), 'sagittal')
                    set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                else
                    set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);                        
                end
            else
                set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Position', [0 0 0.9000 1]);
            end            
            
        end
    end

end
