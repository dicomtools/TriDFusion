function setInputOrientation()
%function setInputOrientation()
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

    tInputTemplate = inputTemplate('get');
    
    for pp=1: numel(tInputTemplate)
        
        if  numel(tInputTemplate(pp).asFilesList) ~= 1 % Must be revisited!

            bFlip = getImagePosition(pp);

            if bFlip == true
                tInputTemplate(pp).atDicomInfo  = flip(tInputTemplate(pp).atDicomInfo);
                tInputTemplate(pp).asFilesList  = flip(tInputTemplate(pp).asFilesList);
                tInputTemplate(pp).aDicomBuffer = flip(tInputTemplate(pp).aDicomBuffer);
           end
        else
            tDicomInfo1 = tInputTemplate(pp).atDicomInfo{1};
            
            if strcmpi(tDicomInfo1.PatientPosition, 'FFS')
                tInputTemplate(pp).aDicomBuffer{1} = tInputTemplate(pp).aDicomBuffer{1}(:,:,end:-1:1);
            elseif strcmpi(tDicomInfo1.PatientPosition, 'FFP')
                tInputTemplate(pp).aDicomBuffer{1} = tInputTemplate(pp).aDicomBuffer{1}(end:-1:1,:,:);
            else
            
                bFlip = getImagePosition(pp);
               
                if bFlip == true                   
                    tInputTemplate(pp).aDicomBuffer{1} = tInputTemplate(pp).aDicomBuffer{1}(:,:,end:-1:1);
                end
                               
            end
        end
    end

    inputTemplate('set', tInputTemplate);

    dicomMetaData('set', tInputTemplate(1).atDicomInfo);

end
