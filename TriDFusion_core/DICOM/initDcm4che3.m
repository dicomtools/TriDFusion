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
% 
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.  

    checkjava = which('org.dcm4che2.io.DicomInputStream');
    if isempty(checkjava)

        libpath = './lib/'; 
        javaaddpath([libpath 'dcm4che-core-3.2.1.jar']);
        javaaddpath([libpath 'dcm4che-image-3.2.1.jar']);
        javaaddpath([libpath 'dcm4che-imageio-3.2.1.jar']);
        javaaddpath([libpath 'dcm4che-net-3.2.1.jar'])

        javaaddpath([libpath 'slf4j-api-1.6.1.jar']);
        javaaddpath([libpath 'slf4j-log4j12-1.6.1.jar']);
        javaaddpath([libpath 'log4j-1.2.16.jar']);
    end
end