function chkUiCorWindowSelectedCallback(hObject, ~)
%function chkUiCorWindowSelectedCallback(hObject, ~)
%Activate coronal uindow playback.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    set(chkUiSagWindowSelectedPtr('get'), 'Value', false);
    set(chkUiTraWindowSelectedPtr('get'), 'Value', false);     

    if strcmpi(default2DPlaybackPlane('get'), 'coronal')

        set(chkUiCorWindowSelectedPtr('get'), 'Value', false);
        set(chkUiMipWindowSelectedPtr('get'), 'Value', true);
    
        default2DPlaybackPlane('set', 'mip');        
    else
        set(chkUiCorWindowSelectedPtr('get'), 'Value', true);  
        set(chkUiMipWindowSelectedPtr('get'), 'Value', false);
    
        default2DPlaybackPlane('set', 'coronal');
    end

end