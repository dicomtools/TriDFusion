function setFusionCombineRGB(~, ~)
%function  setFusionCombineRGB(~, ~)
%Activate\Deactivate RGB fusion combination.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    persistent aAxeAlphaData;

    persistent aCoronalAlphaData;
    persistent aSagittalAlphaData;
    persistent aAxialAlphaData;
    persistent aMipAlphaData;

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if isCombineMultipleFusion('get') == true

        set(uiFusedSeriesPtr('get'), 'Enable', 'on');

%        set(uiFusionSliderWindowPtr('get'), 'Enable', 'on');
%        set(uiFusionSliderLevelPtr('get') , 'Enable', 'on');

        isCombineMultipleFusion('set', false);

        [sCombination,~, ~, ~] = getRGBcombinedColor('get');
        if ~isempty(sCombination)
            dFusedSeries = get(uiFusedSeriesPtr('get'), 'Value');
            if size(fusionBuffer('get', [], dFusedSeries), 3) == 1

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imAxeF = imAxeFPtr('get', [], rr);

                    if ~isempty(imAxeF)
                        if rr ~= dFusedSeries
                            imAxeF.AlphaData = aAxeAlphaData{rr};
                        end
                    end
                end
            else
                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imCoronalF  = imCoronalFPtr  ('get', [], rr);
                    imSagittalF = imSagittalFPtr ('get', [], rr);
                    imAxialF    = imAxialFPtr    ('get', [], rr);
                    imMipF      = imMipFPtr      ('get', [], rr);

                    if ~isempty(imCoronalF)
                        if rr ~= dFusedSeries
                            imCoronalF.AlphaData = aCoronalAlphaData{rr};
                        end
                    end

                    if ~isempty(imSagittalF)
                        if rr ~= dFusedSeries
                            imSagittalF.AlphaData = aSagittalAlphaData{rr};
                        end
                    end

                    if ~isempty(imAxialF)
                        if rr ~= dFusedSeries
                            imAxialF.AlphaData = aAxialAlphaData{rr};
                        end
                    end

                    if ~isempty(imMipF)
                        if rr ~= dFusedSeries
                            imMipF.AlphaData = aMipAlphaData{rr};
                        end
                    end
                end
            end
        end

        axeRGBImage = axeRGBImagePtr('get');
        if ~isempty(axeRGBImage)
            showRGBColormapImage(false);
        end

        refreshImages();

    else

        initCombineRGB();

        [sCombination,~, ~, ~] = getRGBcombinedColor('get');
        if isempty(sCombination)
            isCombineMultipleFusion('set', false);
            errordlg('At least one Red, Green or Blue color must be used in fusion','Combine RGB');
        else

            dFusedSeries = get(uiFusedSeriesPtr('get'), 'Value');

            if size(fusionBuffer('get', [], dFusedSeries), 3) == 1

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries
                    imAxeF = imAxeFPtr      ('get', [], rr);

                    if ~isempty(imAxeF)
                        aAxeAlphaData{rr} = imAxeF.AlphaData;
                        if rr ~= dFusedSeries
                            imAxeF.AlphaData = 0;
                        end
                    end
                end
            else

                dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                for rr=1:dNbFusedSeries

                    imCoronalF  = imCoronalFPtr  ('get', [], rr);
                    imSagittalF = imSagittalFPtr ('get', [], rr);
                    imAxialF    = imAxialFPtr    ('get', [], rr);
                    imMipF      = imMipFPtr      ('get', [], rr);

                    if ~isempty(imCoronalF)
                        aCoronalAlphaData{rr} = imCoronalF.AlphaData;
                        if rr ~= dFusedSeries
                            imCoronalF.AlphaData = 0;
                        end
                    end

                    if ~isempty(imSagittalF)
                        aSagittalAlphaData{rr} = imSagittalF.AlphaData;
                        if rr ~= dFusedSeries
                            imSagittalF.AlphaData = 0;
                        end
                    end

                    if ~isempty(imAxialF)
                        aAxialAlphaData{rr} = imAxialF.AlphaData;
                        if rr ~= dFusedSeries
                            imAxialF.AlphaData = 0;
                        end
                    end

                    if ~isempty(imMipF)
                        aMipAlphaData{rr} = imMipF.AlphaData;
                        if rr ~= dFusedSeries
                            imMipF.AlphaData = 0;
                        end
                    end
                end

            end

            isCombineMultipleFusion('set', true);

            set(uiFusedSeriesPtr('get'), 'Enable', 'off');

%            set(uiFusionSliderWindowPtr('get'), 'Enable', 'off');
%            set(uiFusionSliderLevelPtr('get') , 'Enable', 'off');
            showRGBColormapImage(true);

            refreshImages();

        end
    end

    catch
        set(uiFusedSeriesPtr('get'), 'Enable', 'on');

%        set(uiFusionSliderWindowPtr('get'), 'Enable', 'on');
%        set(uiFusionSliderLevelPtr('get') , 'Enable', 'on');

        isCombineMultipleFusion('set', false);

        progressBar(1, 'Error:setFusionCombineRGB()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
