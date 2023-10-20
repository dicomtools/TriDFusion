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

    tQuantification = quantificationTemplate('get', [], get(uiSeriesPtr('get'), 'Value'));

    dImageMin = tQuantification.tCount.dMin;
    dImageMax = tQuantification.tCount.dMax; 
            
    dMin = windowLevel('get', 'min');
    dMax = windowLevel('get', 'max');
    
    dWLAdjCoe = (dImageMax-dImageMin)/1024;

    aPosDiff = get(0, 'PointerLocation') - pdInitialCoord;

    dMax = dMax + (aPosDiff(2) * dWLAdjCoe);
    dMin = dMin + (aPosDiff(1) * dWLAdjCoe);

%     if (dMax < 1)
%         dMax = 1;
%     end

    if aPosDiff(1) == 0 && aPosDiff(2) == 0

        ptrRoi = copyRoiPtr('get');

        if ~isempty(ptrRoi) && isvalid(ptrRoi) && ptrRoi.Parent == gca
            
            rightClickMenu('on');

    %        windowButton('set', 'up'); % Fix for Linux

        else
            rightClickMenu('off');
        end

    else
        rightClickMenu('off');
        
        if dMax > dMin
            
            windowLevel('set', 'max', dMax);
            windowLevel('set', 'min', dMin);
    
            % Compute colorbar line y offset
        
            dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));
    
            % Ajust the intensity 
    
            setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );
    
            setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );
    
            setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));
    
        end        
    end



    pdInitialCoord = get(0,'PointerLocation');

%     if isVsplash('get') == false      
%         refreshImages();
%     end
end
