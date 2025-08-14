function bUseViewer3d = shouldUseViewer3d()
%function bUseViewer3d = shouldUseViewer3d()
%Returns true if the 3D viewer should be used based on MATLAB release version
% and the status of the viewer UI.
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

    % Check if the MATLAB release is at least R2022b and R2025a
    isAtLeastR2022b = ~isMATLABReleaseOlderThan('R2022b');
    isAtLeastR2025a = ~isMATLABReleaseOlderThan('R2025a');
    hasViewerUI     = viewerUIFigure('get');
    
    % Enable the 3D viewer if either:
    %   1. The release is R2025a or later, or
    %   2. The release is R2022b or later and the viewer UI is enabled.
    bUseViewer3d = isAtLeastR2025a || (isAtLeastR2022b && hasViewerUI);
end