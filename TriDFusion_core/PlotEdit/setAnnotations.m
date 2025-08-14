function setAnnotations()
%function setAnnotations()
%Import annotations to 3DF.
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

    try

    atAnnotations = inputAnnotations('get');

    if isempty(atAnnotations)
        return;
    end   
    
    for ds =1: numel(atAnnotations)

        raw = atAnnotations{ds};
        bError = false;

        if isnumeric(raw)
            % uint8 vector → char row
            jsonText = char(raw(:)');  
        elseif isstring(raw) || ischar(raw)
            jsonText = char(raw);
        else
            bError = true;
        end

        if bError == false

            importPlotEdit(jsonText);
        end

    end

    catch ME   
        logErrorToFile(ME);
        progressBar(1, 'Error:setAnnotations()' );
    end

end