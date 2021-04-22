function progressBar(lProgress, sStatus, sColor)
%function progressBar(lProgress, sStatus, sColor)
%Set the status of the Viewer progress bar.
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

    if ~exist('sColor', 'var')
        sColor = 'cyan';
    end

    set(uiProgressWindowPtr('get'), 'title'   , sStatus);

    if lProgress == 1
        set(uiBarPtr('get'), 'BackgroundColor', viewerBackgroundColor ('get'));
    elseif lProgress == -1
        lProgress = 1;
        set(uiBarPtr('get'), 'BackgroundColor', 'red');
    else 
        set(uiBarPtr('get'), 'BackgroundColor', sColor);
    end

    x = get(uiBarPtr('get'), 'Position');

    x(3) = lProgress;       % Corresponds to % progress if unit = normalized
    set(uiBarPtr('get'), 'Position', x);

   drawnow update;
  % refreshdata;
  % refreshdata(uiBarPtr('get'));
  % refreshdata(uiProgressWindowPtr('get'));

end  