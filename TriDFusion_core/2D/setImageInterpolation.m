function setImageInterpolation(bEnable)
%function etImageInterpolation(bEnable)
%Activate or deactivate image interpolation.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if bEnable == 0

        if numel(dicomBuffer('get', [], dSeriesOffset))

            if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                         shading(axePtr('get', [], dSeriesOffset), 'flat');
                    set(imAxePtr('get', [] , dSeriesOffset),  'Interpolation', 'nearest');

                    axe = axePtr('get', [], dSeriesOffset);
                    axe.Toolbar.Visible = 'off';                 

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

                        for rr=1:dNbFusedSeries

%                                 axef = axefPtr('get', [], rr);
                            imAxe = imAxeFPtr('get', [] , rr);

                            if ~isempty(imAxe)
%                                     shading(axef, 'flat');
                                set(imAxe,  'Interpolation', 'nearest');
                            end

                            axef = axefPtr('get', [], rr);

                            if ~isempty(axef)

                                axef.Toolbar.Visible = 'off';                 
                            end
                            
                        end
                    end

                end
            else
                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                         shading(axes1Ptr('get', [], dSeriesOffset), 'flat');
%                         shading(axes2Ptr('get', [], dSeriesOffset), 'flat');
%                         shading(axes3Ptr('get', [], dSeriesOffset), 'flat');
%
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             shading(axesMipPtr('get', [], dSeriesOffset), 'flat');
%                         end

                    set(imCoronalPtr ('get', [] , dSeriesOffset),  'Interpolation', 'nearest');
                    set(imSagittalPtr('get', [] , dSeriesOffset),  'Interpolation', 'nearest');
                    set(imAxialPtr   ('get', [] , dSeriesOffset),  'Interpolation', 'nearest');

                    axes1 = axes1Ptr('get', [], dSeriesOffset);
                    axes2 = axes2Ptr('get', [], dSeriesOffset);
                    axes3 = axes3Ptr('get', [], dSeriesOffset);

                    axes1.Toolbar.Visible = 'off';                 
                    axes2.Toolbar.Visible = 'off';                 
                    axes3.Toolbar.Visible = 'off';                 

                    if link2DMip('get') == true && isVsplash('get') == false

                        set(imMipPtr('get', [], dSeriesOffset),  'Interpolation', 'nearest');

                        axesMip = axesMipPtr('get', [], dSeriesOffset);
                        axesMip.Toolbar.Visible = 'off';                 
                    end

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries

%                                 axes1f = axes1fPtr('get', [], rr);
%                                 axes2f = axes2fPtr('get', [], rr);
%                                 axes3f = axes3fPtr('get', [], rr);


%                                 if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                     shading(axes1f, 'flat');
%                                     shading(axes2f, 'flat');
%                                     shading(axes3f, 'flat');
%                                 end

                            imCoronalF  = imCoronalFPtr ('get', [] , rr);
                            imSagittalF = imSagittalFPtr('get', [] , rr);
                            imAxialF    = imAxialFPtr   ('get', [] , rr);

                            if ~isempty(imCoronalF) && ~isempty(imSagittalF) && ~isempty(imAxialF)

                                set(imCoronalF ,  'Interpolation', 'nearest');
                                set(imSagittalF,  'Interpolation', 'nearest');
                                set(imAxialF   ,  'Interpolation', 'nearest');
                            end

                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);

                            if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)

                                axes1f.Toolbar.Visible = 'off';                 
                                axes2f.Toolbar.Visible = 'off';                 
                                axes3f.Toolbar.Visible = 'off';                                      
                            end

                            if link2DMip('get') == true && isVsplash('get') == false

                                imMipF = imMipFPtr('get', [], rr);
                                if ~isempty(imMipF)
                                    set(imMipF,  'Interpolation', 'nearest');
                                end

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    axesMipf.Toolbar.Visible = 'off';                                      
                                end
                    
                            end

%                                 if link2DMip('get') == true && isVsplash('get') == false
%                                     axesMipf = axesMipfPtr('get', [], rr);
%                                     if ~isempty(axesMipf)
%                                         shading(axesMipf, 'flat');
%                                     end
%                                 end
                        end
                    end

                end
            end
        end
    else
        if numel(dicomBuffer('get', [], dSeriesOffset))

            if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                         shading(axePtr('get', [], dSeriesOffset), 'interp');

                    set(imAxePtr('get', [] , dSeriesOffset),  'Interpolation', 'bilinear');

                    axe = axePtr('get', [], dSeriesOffset);
                    axe.Toolbar.Visible = 'off';    

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));

                        for rr=1:dNbFusedSeries

%                                 axef = axefPtr('get', [], rr);
%
%                                 if ~isempty(axef)
%                                     shading(axef, 'interp');
%                                 end
                            imAxef = imAxeFPtr('get', [] , rr);

                            if ~isempty(imAxef)
%                                     shading(axef, 'flat');
                                set(imAxef,  'Interpolation', 'bilinear');
                            end

                            axef = axefPtr('get', [], rr);

                            if ~isempty(axef)
                                axef.Toolbar.Visible = 'off';                 
                            end
                        end
                    end
               end
            else
                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false
%
%                         shading(axes1Ptr('get', [], dSeriesOffset), 'interp');
%                         shading(axes2Ptr('get', [], dSeriesOffset), 'interp');
%                         shading(axes3Ptr('get', [], dSeriesOffset), 'interp');
%
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             shading(axesMipPtr('get', [], dSeriesOffset), 'interp');
%                         end

                    set(imCoronalPtr ('get', [] , dSeriesOffset),  'Interpolation', 'bilinear');
                    set(imSagittalPtr('get', [] , dSeriesOffset),  'Interpolation', 'bilinear');
                    set(imAxialPtr   ('get', [] , dSeriesOffset),  'Interpolation', 'bilinear');

                    axes1 = axes1Ptr('get', [], dSeriesOffset);
                    axes2 = axes2Ptr('get', [], dSeriesOffset);
                    axes3 = axes3Ptr('get', [], dSeriesOffset);

                    axes1.Toolbar.Visible = 'off';                 
                    axes2.Toolbar.Visible = 'off';                 
                    axes3.Toolbar.Visible = 'off'; 

                    if link2DMip('get') == true && isVsplash('get') == false

                        set(imMipPtr('get', [], dSeriesOffset),  'Interpolation', 'bilinear');

                        axesMip = axesMipPtr('get', [], dSeriesOffset);
                        axesMip.Toolbar.Visible = 'off';                             
                    end

                    if isFusion('get') == true

                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries
%
%                                 axes1f = axes1fPtr('get', [], rr);
%                                 axes2f = axes2fPtr('get', [], rr);
%                                 axes3f = axes3fPtr('get', [], rr);
%
%                                 if ~isempty(axes1f) && ~isempty(axes2f) && ~isempty(axes3f)
%                                     shading(axes1f, 'interp');
%                                     shading(axes2f, 'interp');
%                                     shading(axes3f, 'interp');
%                                 end
%
%                                 if link2DMip('get') == true && isVsplash('get') == false
%
%                                     axesMipf = axesMipfPtr('get', [], rr);
%                                     if ~isempty(axesMipf)
%                                         shading(axesMipf, 'interp');
%                                     end
%                                 end

                            imCoronalF  = imCoronalFPtr ('get', [] , rr);
                            imSagittalF = imSagittalFPtr('get', [] , rr);
                            imAxialF    = imAxialFPtr   ('get', [] , rr);

                            if ~isempty(imCoronalF) && ~isempty(imSagittalF) && ~isempty(imAxialF)

                                set(imCoronalF ,  'Interpolation', 'bilinear');
                                set(imSagittalF,  'Interpolation', 'bilinear');
                                set(imAxialF   ,  'Interpolation', 'bilinear');
                            end

                            if link2DMip('get') == true && isVsplash('get') == false

                                imMipF = imMipFPtr('get', [], rr);
                                if ~isempty(imMipF)
                                    set(imMipF,  'Interpolation', 'bilinear');
                                end

                                axesMipf = axesMipfPtr('get', [], rr);
                                if ~isempty(axesMipf)
                                    axesMipf.Toolbar.Visible = 'off';                                      
                                end                                    
                            end
                        end
                    end
                end
            end
        end
    end
end
