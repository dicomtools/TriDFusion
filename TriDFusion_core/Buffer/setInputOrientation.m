function setInputOrientation(dSeriesOffset)
%function setInputOrientation(dSeriesOffset)
%Set DICOM Input Images Orientation.
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

    atInput = inputTemplate('get');
    
    if ~isempty(dSeriesOffset)
        dFromLoop = dSeriesOffset;
        dToLoop   = dSeriesOffset;
    else
        dFromLoop = 1;
        dToLoop = numel(atInput);
    end

    for pp=dFromLoop: dToLoop
        
        if  numel(atInput(pp).asFilesList) ~= 1 % Must be revisited!

            bFlip = getImagePosition(pp);

            if bFlip == true
                atInput(pp).atDicomInfo  = flip(atInput(pp).atDicomInfo);
                atInput(pp).asFilesList  = flip(atInput(pp).asFilesList);
                atInput(pp).aDicomBuffer = flip(atInput(pp).aDicomBuffer);
           end
        else
            tDicomInfo1 = atInput(pp).atDicomInfo{1};
            
            if strcmpi(tDicomInfo1.PatientPosition, 'FFS')
                atInput(pp).aDicomBuffer{1} = atInput(pp).aDicomBuffer{1}(:,:,end:-1:1);
            elseif strcmpi(tDicomInfo1.PatientPosition, 'FFP')
                atInput(pp).aDicomBuffer{1} = atInput(pp).aDicomBuffer{1}(end:-1:1,:,:);
            else
            
                bFlip = getImagePosition(pp);
               
                if bFlip == true                   
                    atInput(pp).aDicomBuffer{1} = atInput(pp).aDicomBuffer{1}(:,:,end:-1:1);
                end
                               
            end
        end
    end

    inputTemplate('set', atInput);

end
