function [sPredictScript] = validateNnUNetv2Installation()
%function [sPredictScript] = validateNnUNetv2Installation()
%Validate machine learning nnUNetv2 installation.
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

    sPredictScript = '';

    if ispc % Windows
        
        [bStatus, sCmdout] = system('WHERE nnUNetv2_predict');
        
        if bStatus 
            progressBar( 1, 'Error: nnUNetv2 not detected!');
            errordlg(sprintf('nnUNetv2 not detected!\n Installation instruction can be found at:\n https://github.com/MIC-DKFZ/nnUNet/blob/master/documentation/installation_instructions.md'), 'nnUNetv2 Validation');  
        else
             sPredictScript = strtrim(char(sCmdout));
        end
              
        
    elseif isunix % Linux is not yet supported
                
        progressBar( 1, 'Error: Machine Learning for Linux is not supported');
        errordlg('Machine Learning for Linux is not supported', 'Machine Learning Validation');
        
    else % Mac is not yet supported
                
        progressBar( 1, 'Error: Machine Learning for Mac is not supported');
        errordlg('Machine Learning for Mac is not supported', 'Machine Learning Validation');
    end
              
        
end
