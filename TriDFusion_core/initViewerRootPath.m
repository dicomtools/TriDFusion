function initViewerRootPath()
%function initViewerRootPath()
%Initialize Viewer Root path.
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

    viewerRootPath('set', '');
    
    if isdeployed 
        % User is running an executable in standalone mode. 
        [~, result] = system('set PATH');
        sRootDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        if sRootDir(end) ~= '\' || ...
           sRootDir(end) ~= '/'     
            sRootDir = [sRootDir '/'];
        end         
        viewerRootPath('set', sRootDir);
    else               
        sRootDir = pwd;
        if sRootDir(end) ~= '\' || ...
           sRootDir(end) ~= '/'     
            sRootDir = [sRootDir '/'];
        end   

        if isfile(sprintf('%sscreenDefault.png', sRootDir))
            viewerRootPath('set', sRootDir);
        else
            if integrateToBrowser('get') == true
                if isfile(sprintf('%sTriDFusion/screenDefault.png', sRootDir))
                    viewerRootPath('set', sprintf('%sTriDFusion/', sRootDir) );
                end
            else    
                sRootDir = fileparts(mfilename('fullpath'));
                sRootDir = erase(sRootDir, 'TriDFusion_core');        

                if isfile(sprintf('%sscreenDefault.png', sRootDir))
                    viewerRootPath('set', sRootDir);
                end
            end
        end    
    end
end