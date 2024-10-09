function [lMin, lMax] = setWindowLevel(im, atMetaData)
%function  [lMin, lMax] = setWindowLevel(im, atMetaData)
%Return window level min/max value.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

   sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));

   initWindowLevel('set', false);
    if strcmpi(atMetaData{1}.Modality, 'ct')
        if min(im, [], 'all') >= 0
            lMin = min(im, [], 'all');
            lMax = max(im, [], 'all');
        else
            [lMax, lMin] = computeWindowLevel(500, 50);
        end
    else
        if strcmpi(sUnitDisplay, 'SUV')
            tQuant = quantificationTemplate('get');
            if isfield(tQuant, 'tSUV')
                if tQuant.tSUV.dScale
                    lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;
                    lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;
                else
                    lMin = min(im, [], 'all');
                    lMax = max(im, [], 'all');
                end
            else
                lMin = min(im, [], 'all');
                lMax = max(im, [], 'all');                
            end
        else
            lMin = min(im, [], 'all');
            lMax = max(im, [], 'all');
        end
    end

    windowLevel('set', 'min', lMin);
    windowLevel('set', 'max', lMax);

%         setWindowMinMax(lMax, lMin);
    getInitWindowMinMax('set', lMax, lMin);

    sliderWindowLevelValue('set', 'min', 0.5);
    sliderWindowLevelValue('set', 'max', 0.5);

end