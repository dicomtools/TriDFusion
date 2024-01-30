function [sDosimetryScript, sDosimetryScriptPath] = validateDosimetryInstallation()
%function [sDosimetryScript, sDosimetryScriptPath] = validateDosimetryInstallation()
%Validate dosimetry installation.
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

    sDosimetryScript = '';
    sDosimetryScriptPath = '';

    if ispc % Windows
        
%         [bStatus, sCmdout] = system('WHERE phits');
         [bStatus, sCmdout] = system('WHERE phits.bat');
        
        if bStatus 
            progressBar( 1, 'Error: PHITS not detected!');
            errordlg(sprintf('PHITS not detected!\n Installation instruction can be found at:\n https://phits.jaea.go.jp/rirekie.html'), 'PHITS Validation');  
        else
             sDosimetryScript = strtrim(char(sCmdout));
             sDosimetryScriptPath   = strrep(sDosimetryScript, 'bin\phits.bat', '');
       end
              
        
    elseif isunix % Linux is not yet supported
                
        progressBar( 1, 'Error: Dosimetry for Linux is not supported');
        errordlg('Dosimetry for Linux is not supported', 'Dosimetry Validation');
        
    else % Mac is not yet supported
                
        progressBar( 1, 'Error: Dosimetry for Mac is not supported');
        errordlg('Dosimetry for Mac is not supported', 'Dosimetry Validation');
    end
              
        
end
