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

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    atInput = inputTemplate('get');

    if size(dicomBuffer('get'), 3) == 1 % 2D Image

        if isPlotContours('get') == true

            isPlotContours('set', false);

            % linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get',[],  get(uiFusedSeriesPtr('get'), 'Value'))],'off');

            imAxeFcPtr('reset');

            % Link all fusion axes

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

            axe = axePtr  ('get', [], get(uiSeriesPtr('get'), 'Value'));

            axefusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axefPtr('get', [], rr))

                    axefusion{end+1} = axefPtr('get', [], rr);
                end
            end

            if ~isempty(axefusion)

                linkaxes([axe axefusion{:}], 'xy');
            end

            % All fusion images visible

            for rr=1:dNbFusedSeries

                imAxeF = imAxeFPtr ('get', [], rr);

                if ~isempty(imAxeF)

                    set(imAxeF , 'visible', 'on');
                end
            end

        else
            isPlotContours('set', true);

            aXLim = get(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'XLim');
            aYLim = get(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'YLim');
%             aCLim = get(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim');

            if isempty(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axeFc = ...
                   axes(uiOneWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    ,'reverse', ...
                        'Box'     , 'off', ...
                        'Tag'     , 'axeFc', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axeFc.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                deleteAxesToolbar(axeFc);
                % axeFc.Toolbar = [];

                set(axeFc, 'HitTest', 'off');  % Disable hit testing for axes
                set(axeFc, 'XLimMode', 'manual', 'YLimMode', 'manual');
                set(axeFc, 'XMinorTick', 'off', 'YMinorTick', 'off');

                grid(axeFc, 'off');

                axis(axeFc, 'tight');
                axefcPtr('set', axeFc, get(uiFusedSeriesPtr('get'), 'Value'));
                disableDefaultInteractivity(axeFc);

                linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

%                 uistack(axefcPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'bottom');

                set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'XLim'    , aXLim, ...
                    'YLim'    , aYLim, ...
                    'CLim'    , [0 inf] ...
                    );
            end

            linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');

            cla(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) ,'reset');
            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');

            imf = squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            sUnitDisplay = getSerieUnitValue(get(uiFusedSeriesPtr('get'), 'Value'));
            if strcmpi(sUnitDisplay, 'SUV')
                tQuantification = quantificationTemplate('get');
                if atInput(get(uiFusedSeriesPtr('get'), 'Value')).bDoseKernel == false
                    imf = imf*tQuantification.tSUV.dScale;
                end
            end

            if isShowTextContours('get', 'axe') == true
                sShowTextEnable = 'on';
            else
                sShowTextEnable = 'off';
            end

            if isShowFaceAlphaContours('get')
                [~,imAxeFc] = contourf(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:), 'ShowText', sShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');
            else
                [~,imAxeFc] = contour(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:), 'ShowText', sShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
            end

            disableAxesToolbar(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            imAxeFcPtr('set', imAxeFc, get(uiFusedSeriesPtr('get'), 'Value'));

            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , aXLim, ...
                'YLim'    , aYLim, ...
                'CLim'    , [0 inf] ...
                );

            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'HitTest', 'off');  % Disable hit testing for axes
            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XLimMode', 'manual', 'YLimMode', 'manual');
            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XMinorTick', 'off', 'YMinorTick', 'off');

            grid(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'off');

            axis(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

            % linkaxes([axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'XLim'    , aXLim, ...
                'YLim'    , aYLim, ...
                'CLim'    , [0 inf] ...
                );

            uistack(axefcPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'bottom');

            % Link all fusion axes, including the contour axe

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

            axe   = axePtr  ('get', [], get(uiSeriesPtr('get'), 'Value'));
            axefc = axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            axefusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axefPtr('get', [], rr))

                    axefusion{end+1} = axefPtr('get', [], rr);
                end
            end

            if ~isempty(axefusion)

                linkaxes([axe axefusion{:} axefc], 'xy');
            end

            % All fusion images not visible

            for rr=1:dNbFusedSeries

                imAxeF  = imAxeFPtr ('get', [], rr);

                if ~isempty(imAxeF)

                    set(imAxeF , 'visible', 'off');
                end
            end

            % deleteAxesToolbar(axefc);

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

            % linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            % linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            % linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            % if link2DMip('get') == true || isFusion('get') == false
            %     linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'off');
            % end

            imCoronalFcPtr ('reset');
            imSagittalFcPtr('reset');
            imAxialFcPtr   ('reset');

            % Link all fusion axes, including the contour axe

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

            axes1 = axes1Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));

            axes1fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes1fPtr('get', [], rr))

                    axes1fusion{end+1} = axes1fPtr('get', [], rr);
                end
            end

            if ~isempty(axes1fusion)

                linkaxes([axes1 axes1fusion{:}], 'xy');
            end

            axes2 = axes1Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));

            axes2fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes2fPtr('get', [], rr))

                    axes2fusion{end+1} = axes2fPtr('get', [], rr);
                end
            end

            if ~isempty(axes2fusion)

                linkaxes([axes2 axes2fusion{:}], 'xy');
            end

            axes3 = axes3Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));

            axes3fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes3fPtr('get', [], rr))

                    axes3fusion{end+1} = axes3fPtr('get', [], rr);
                end
            end

            if ~isempty(axes3fusion)

                linkaxes([axes3 axes3fusion{:}], 'xy');
            end

            % All fusion images visible

            for rr=1:dNbFusedSeries

                imCoronalF  = imCoronalFPtr ('get', [], rr);
                imSagittalF = imSagittalFPtr('get', [], rr);
                imAxialF    = imAxialFPtr   ('get', [], rr);

                if ~isempty(imCoronalF) && ...
                   ~isempty(imSagittalF) && ...
                   ~isempty(imAxialF)

                    set(imCoronalF , 'visible', 'on');
                    set(imSagittalF, 'visible', 'on');
                    set(imAxialF   , 'visible', 'on');
                end
            end

            if link2DMip('get') == true || isFusion('get') == false

                imMipFcPtr('reset');

                axesMip   = axesMipPtr  ('get', [], get(uiSeriesPtr('get'), 'Value'));

                axesMipfusion = [];
                for rr=1:dNbFusedSeries

                    if ~isempty(axesMipfPtr('get', [], rr))
                        axesMipfusion{end+1} = axesMipfPtr('get', [], rr);
                    end

                end

                if ~isempty(axesMipfusion)

                    linkaxes([axesMip axesMipfusion{:}], 'xy');
                end

                for rr=1:dNbFusedSeries

                    imMipF = imMipFPtr('get', [], rr);

                    if ~isempty(imMipF)

                        set(imMipF , 'visible', 'on');
                    end
                end

            end

        else
            isPlotContours('set', true);

            % Init axes

            aAxes1XLim = get(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'XLim');
            aAxes1YLim = get(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'YLim');
%             aAxes1CLim = get(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim');

            if isempty(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes1fc = ...
                   axes(uiCorWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    ,'reverse', ...
                        'Tag'     , 'axes1fc', ...
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes1fc.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                % axes1fc.Toolbar = [];
                disableDefaultInteractivity(axes1fc);
                deleteAxesToolbar(axes1fc);

                set(axes1fc, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes1fc, 'XLimMode', 'manual', 'YLimMode', 'manual');
                set(axes1fc, 'XMinorTick', 'off', 'YMinorTick', 'off');

                grid(axes1fc, 'off');

                axis(axes1fc, 'tight');
                axes1fcPtr('set', axes1fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

%                 uistack(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
%                 uistack(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'up');

                set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'XLim'    , aAxes1XLim, ...
                    'YLim'    , aAxes1YLim, ...
                    'CLim'    , [0 inf] ...
                    );
            end

            aAxes2XLim = get(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'XLim');
            aAxes2YLim = get(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'YLim');
%             aAxes2CLim = get(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim');

            if isempty(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes2fc = ...
                   axes(uiSagWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    ,'reverse', ...
                        'Tag'     , 'axes2fc', ...
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes2fc.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                % axes2fc.Toolbar = [];
                disableDefaultInteractivity(axes2fc);
                deleteAxesToolbar(axes2fc);

                set(axes2fc, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes2fc, 'XLimMode', 'manual', 'YLimMode', 'manual');
                set(axes2fc, 'XMinorTick', 'off', 'YMinorTick', 'off');

                grid(axes2fc, 'off');

                axis(axes2fc, 'tight');
                axes2fcPtr('set', axes2fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

%                 uistack(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
%                 uistack(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'up');

                set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'XLim'    , aAxes2XLim, ...
                    'YLim'    , aAxes2YLim, ...
                    'CLim'    , [0 inf] ...
                    );
            end

            aAxes3XLim = get(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'XLim');
            aAxes3YLim = get(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'YLim');
%             aAxes3CLim = get(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim');

            if isempty(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))

                axes3fc = ...
                   axes(uiTraWindowPtr('get'), ...
                        'Units'   , 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'Visible' , 'off', ...
                        'Ydir'    ,'reverse', ...
                        'Tag'     , 'axes3fc', ...
                        'Box'     , 'off', ...
                        'XLim'    , [0 inf], ...
                        'YLim'    , [0 inf], ...
                        'CLim'    , [0 inf] ...
                        );
                axes3fc.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                % axes3fc.Toolbar = [];
                disableDefaultInteractivity(axes3fc);
                deleteAxesToolbar(axes3fc);

                set(axes3fc, 'HitTest', 'off');  % Disable hit testing for axes
                set(axes3fc, 'XLimMode', 'manual', 'YLimMode', 'manual');
                set(axes3fc, 'XMinorTick', 'off', 'YMinorTick', 'off');

                grid(axes3fc, 'off');

                axis(axes3fc, 'tight');
                axes3fcPtr('set', axes3fc, get(uiFusedSeriesPtr('get'), 'Value'));

                linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

%                 uistack(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
%                 uistack(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'up');

                set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'XLim'    , aAxes3XLim, ...
                    'YLim'    , aAxes3YLim, ...
                    'CLim'    , [0 inf] ...
                    );
            end

            if link2DMip('get') == true && isVsplash('get') == false

                aAxesMipXLim = get(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'XLim');
                aAxesMipYLim = get(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'YLim');
%                 aAxesMipCLim = get(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim');

                if isempty(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')))
                    axesMipfc = ...
                       axes(uiMipWindowPtr('get'), ...
                            'Units'   , 'normalized', ...
                            'Position', [0 0 1 1], ...
                            'Visible' , 'off', ...
                            'Ydir'    ,'reverse', ...
                            'Tag'     , 'axesMipfc', ...
                            'Box'     , 'off', ...
                            'XLim'    , [0 inf], ...
                            'YLim'    , [0 inf], ...
                            'CLim'    , [0 inf] ...
                            );
                    axesMipfc.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                    % axesMipfc.Toolbar = [];
                    disableDefaultInteractivity(axesMipfc);
                    deleteAxesToolbar(axesMipfc);

                    set(axesMipfc, 'HitTest', 'off');  % Disable hit testing for axes
                    set(axesMipfc, 'XLimMode', 'manual', 'YLimMode', 'manual');
                    set(axesMipfc, 'XMinorTick', 'off', 'YMinorTick', 'off');

                    grid(axesMipfc, 'off');

                    axis(axesMipfc, 'tight');
                    axesMipfcPtr('set', axesMipfc, get(uiFusedSeriesPtr('get'), 'Value'));

                    linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                    linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

%                     uistack(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');
%                     uistack(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'up');

                    set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                        'XLim'    , aAxesMipXLim, ...
                        'YLim'    , aAxesMipYLim, ...
                        'CLim'    , [0 inf] ...
                       );
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

            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');
            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');
            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');

            if link2DMip('get') == true && isVsplash('get') == false

                cla(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),'reset');
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');
            end

            imf  = squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
            imMf = squeeze(mipFusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            sUnitDisplay = getSerieUnitValue(get(uiFusedSeriesPtr('get'), 'Value'));
            if strcmpi(sUnitDisplay, 'SUV')
                tQuantification = quantificationTemplate('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                if atInput(get(uiFusedSeriesPtr('get'), 'Value')).bDoseKernel == false
                    if ~isempty(tQuantification)
                        setQuantification(get(uiFusedSeriesPtr('get'), 'Value'));
                        tQuantification = quantificationTemplate('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                    end

                    imf = imf*tQuantification.tSUV.dScale;
                    imMf = imMf*tQuantification.tSUV.dScale;
                end
            end

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
                set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');

                [~,imSagittalFc] = contourf(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(:,iSagittal,:), [3 1 2]), 'ShowText', sSagittalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');

                [~,imAxialFc   ] = contourf(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:,iAxial), 'ShowText', sAxialShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');

                if link2DMip('get') == true && isVsplash('get') == false
                    [~,imMipFc] = contourf(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imMf(iMipAngle,:,:), [3 2 1]), 'ShowText', sMipShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                    set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'visible', 'off');
                end
            else

                [~,imCoronalFc ] = contour(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(iCoronal,:,:), [3 2 1]), 'ShowText', sCoronalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imSagittalFc] = contour(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imf(:,iSagittal,:), [3 1 2]), 'ShowText', sSagittalShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                [~,imAxialFc   ] = contour(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), imf(:,:,iAxial), 'ShowText', sAxialShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');

                if link2DMip('get') == true && isVsplash('get') == false
                    [~,imMipFc] = contour(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), permute(imMf(iMipAngle,:,:), [3 2 1]), 'ShowText', sMipShowTextEnable, 'LineWidth', plotContoursLineWidth('get'), 'Visible', 'off');
                end
            end
            
            disableAxesToolbar(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
            disableAxesToolbar(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            imCoronalFcPtr ('set', imCoronalFc , get(uiFusedSeriesPtr('get'), 'Value') );
            imSagittalFcPtr('set', imSagittalFc, get(uiFusedSeriesPtr('get'), 'Value') );
            imAxialFcPtr   ('set', imAxialFc   , get(uiFusedSeriesPtr('get'), 'Value') );

            if link2DMip('get') == true && isVsplash('get') == false

                disableAxesToolbar(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                imMipFcPtr('set', imMipFc, get(uiFusedSeriesPtr('get'), 'Value') );
            end

            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , aAxes1XLim, ...
                'YLim'    , aAxes1YLim, ...
                'CLim'    , [0 inf] ...
                );
            axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');
            disableDefaultInteractivity(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'HitTest', 'off');  % Disable hit testing for axes
            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XLimMode', 'manual', 'YLimMode', 'manual');
            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XMinorTick', 'off', 'YMinorTick', 'off');

            grid(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'off');

            % linkaxes([axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'XLim'    , aAxes1XLim, ...
                'YLim'    , aAxes1YLim, ...
                'CLim'    , [0 inf] ...
                );

            uistack(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

            axes1   = axes1Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));
            axes1fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            axes1fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes1fPtr('get', [], rr))

                    axes1fusion{end+1} = axes1fPtr('get', [], rr);
                end
            end

            if ~isempty(axes1fusion)

                linkaxes([axes1 axes1fusion{:} axes1fc], 'xy');
            end
          
            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , aAxes2XLim, ...
                'YLim'    , aAxes2YLim, ...
                'CLim'    , [0 inf] ...
                );
            axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');
            disableDefaultInteractivity(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'HitTest', 'off');  % Disable hit testing for axes
            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XLimMode', 'manual', 'YLimMode', 'manual');
            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XMinorTick', 'off', 'YMinorTick', 'off');

            grid(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'off');

            % linkaxes([axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'XLim'    , aAxes2XLim, ...
                'YLim'    , aAxes2YLim, ...
                'CLim'    , [0 inf] ...
                );

            uistack(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

            axes2   = axes2Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));
            axes2fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            axes2fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes2fPtr('get', [], rr))

                    axes2fusion{end+1} = axes2fPtr('get', [], rr);
                end
            end

            if ~isempty(axes2fusion)

                linkaxes([axes2 axes2fusion{:} axes2fc], 'xy');
            end

            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'Units'   , 'normalized', ...
                'Position', [0 0 1 1], ...
                'Visible' , 'off', ...
                'Ydir'    , 'reverse', ...
                'XLim'    , aAxes3XLim, ...
                'YLim'    , aAxes3YLim, ...
                'CLim'    , [0 inf] ...
                );
            axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');
            disableDefaultInteractivity(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'HitTest', 'off');  % Disable hit testing for axes
            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XLimMode', 'manual', 'YLimMode', 'manual');
            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XMinorTick', 'off', 'YMinorTick', 'off');

            grid(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'off');

            % linkaxes([axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');

            set(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                'XLim'    , aAxes3XLim, ...
                'YLim'    , aAxes3YLim, ...
                'CLim'    , [0 inf] ...
                );

            uistack(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

            axes3   = axes3Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'));
            axes3fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            axes3fusion = [];
            for rr=1:dNbFusedSeries

                if ~isempty(axes3fPtr('get', [], rr))

                    axes3fusion{end+1} = axes3fPtr('get', [], rr);
                end

            end

            if ~isempty(axes3fusion)

                linkaxes([axes3 axes3fusion{:} axes3fc], 'xy');

                % for jj=1:numel(axes3fusion)
                %     set(axes3fusion{jj}, 'Visible', 'off');
                % end
            end

            for rr=1:dNbFusedSeries

                imCoronalF  = imCoronalFPtr ('get', [], rr);
                imSagittalF = imSagittalFPtr('get', [], rr);
                imAxialF    = imAxialFPtr   ('get', [], rr);

                if ~isempty(imCoronalF) && ...
                   ~isempty(imSagittalF) && ...
                   ~isempty(imAxialF)

                    set(imCoronalF , 'visible', 'off');
                    set(imSagittalF, 'visible', 'off');
                    set(imAxialF   , 'visible', 'off');
                end
            end

            if link2DMip('get') == true && isVsplash('get') == false

                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'Units'   , 'normalized', ...
                    'Position', [0 0 1 1], ...
                    'Visible' , 'off', ...
                    'Ydir'    , 'reverse', ...
                    'XLim'    , aAxesMipXLim, ...
                    'YLim'    , aAxesMipYLim, ...
                    'CLim'    , [0 inf] ...
                    );
                disableDefaultInteractivity(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));

                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'HitTest', 'off');  % Disable hit testing for axes
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XLimMode', 'manual', 'YLimMode', 'manual');
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'XMinorTick', 'off', 'YMinorTick', 'off');

                grid(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'off');

                axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , 'tight');

                % linkaxes([axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')) axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))],'xy');
                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'off');

                set(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')) , ...
                    'XLim'    , aAxesMipXLim, ...
                    'YLim'    , aAxesMipYLim, ...
                    'CLim'    , [0 inf] ...
                    );

                uistack(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'bottom');

                axesMip   = axesMipPtr  ('get', [], get(uiSeriesPtr('get'), 'Value'));
                axesMipfc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                axesMipfusion = [];
                for rr=1:dNbFusedSeries

                    if ~isempty(axesMipfPtr('get', [], rr))
                        axesMipfusion{end+1} = axesMipfPtr('get', [], rr);
                    end

                end

                if ~isempty(axesMipfusion)

                    linkaxes([axesMip axesMipfusion{:} axesMipfc], 'xy');
                end

                for rr=1:dNbFusedSeries

                    imMipF = imMipFPtr('get', [], rr);

                    if ~isempty(imMipF)

                        set(imMipF , 'visible', 'off');
                    end
                end
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

                if isVsplash('get') == false && link2DMip('get') == true
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

    catch ME
         logErrorToFile(ME);
         progressBar(1, 'Error:setPlotContoursCallback()');
     end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
