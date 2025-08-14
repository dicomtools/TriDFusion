function initDcm4che3()
%function initDcm4che3()
%Initialize Dcm4che3 neeeded library.
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
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.  

    checkjava = which('org.dcm4che3.io.DicomInputStream');
    
    if isempty(checkjava)
        
        sRootPath  = viewerRootPath('get');
        libpath = sprintf('%s/lib/',sRootPath); 
                    
        javaaddpath([libpath 'dcm4che-core-5.33.1.jar']);        
        javaaddpath([libpath 'dcm4che-tool-common-5.33.1.jar']);        
        javaaddpath([libpath 'slf4j-api-2.0.16.jar']);        
        javaaddpath([libpath 'logback-core-1.5.12.jar']);        
        javaaddpath([libpath 'commons-cli-1.9.0.jar']);         
    end
end