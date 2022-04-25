function adjWL(dInitCoord)
%function adjWL(dInitCoord)
%Ajust 2D Window Level using mouse right click.
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

    persistent pdInitialCoord;

    if exist('dInitCoord', 'var')
        pdInitialCoord = dInitCoord;
    end

    dMIn = windowLevel('get', 'min');
    dMax = windowLevel('get', 'max');

    dWLAdjCoe = (dMax + 1)/1024;

    aPosDiff = get(0, 'PointerLocation') - pdInitialCoord;

    dMax = dMax + aPosDiff(2) * dWLAdjCoe;
    dMIn = dMIn + aPosDiff(1) * dWLAdjCoe;

    if (dMax < 1)
        dMax = 1;
    end

    if aPosDiff(1) == 0 && aPosDiff(2) == 0

        if ~isempty(copyRoiPtr('get'))
            rightClickMenu('on');

    %        windowButton('set', 'up'); % Fix for Linux

        else
            rightClickMenu('off');
        end

    else
        rightClickMenu('off');
    end

    if dMax > dMIn

        aCLim(1) = dMIn;
        aCLim(2) = dMax;

%        getInitWindowMinMax('set', aCLim(2), aCLim(1));

%        set(uiSliderWindowPtr('get'), 'value', 0.5);
%        set(uiSliderLevelPtr('get') , 'value', 0.5);
        
        windowLevel('set', 'max', aCLim(2));
        windowLevel('set', 'min', aCLim(1));

        if (size(dicomBuffer('get'), 3) == 1)
            set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')),'CLim', aCLim);
        else
            set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')),'CLim', aCLim);
            set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')),'CLim', aCLim);
            set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')),'CLim', aCLim);
%            if link2DMip('get') == true && isVsplash('get') == false  
%                set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')),'CLim', aCLim);
%            end
        end

    end

    pdInitialCoord = get(0,'PointerLocation');

end
