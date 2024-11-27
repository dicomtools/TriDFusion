function isNetwork = isPathNetwork(path)
%function isNetwork = isPathNetwork(path)
%Return true if it is a network path.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    if ispc
        % Windows: Check for UNC or mapped drives
        if startsWith(path, '\\') || startsWith(path, '//')
            isNetwork = true;
            return;
        end
        % Check mapped network drive using `net use`
        driveLetter = path(1);
        [~, driveInfo] = system(['net use ' driveLetter ':']);
        isNetwork = contains(driveInfo, '\\');
    else
        % Unix-based: Check mount points or protocols
        [~, mountInfo] = system('mount');
        isNetwork = contains(mountInfo, path) && ...
                    (contains(mountInfo, 'smb') || contains(mountInfo, 'nfs') || ...
                     contains(mountInfo, '/Volumes') || contains(mountInfo, '/mnt'));
    end
end