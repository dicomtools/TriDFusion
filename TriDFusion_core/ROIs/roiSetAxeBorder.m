function roiSetAxeBorder(bStatus, pAxe)
%function roiSetAxeBorder(bStatus, pAxe)
%Show\Hide ROI's Axe border.
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
% TriDFusion development has been led by: Daniel Lafontaine
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
    
    if bStatus == true

        if exist('axe', 'var')
            if pAxe == axe
                set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiOneWindowPtr('get'), 'BorderWidth'   , 1);
            end
        end

        if ~isempty(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')))

            if pAxe == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                set(uiCorWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiCorWindowPtr('get'), 'BorderWidth'   , 1);
            end

            if pAxe == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                set(uiSagWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiSagWindowPtr('get'), 'BorderWidth'   , 1);
            end

            if pAxe == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiTraWindowPtr('get'), 'BorderWidth'   , 1);
            end 
        end
    else

        if exist('axe', 'var')
            set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));
        end

        if ~isempty(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')))

            set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
            set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
            set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
        end
    end

end