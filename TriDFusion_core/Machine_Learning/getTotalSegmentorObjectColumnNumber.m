function dColumnNumber = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, sObject, sDirection)
%function dSliceNumber = getTotalSegmentorObjectColumnNumber(sSegmentationFolderName, sObject, sDirection)
%Get/Set segmentation FDG SUV value.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dColumnNumber = [];

    sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sObject);  

    if exist(sNiiFileName, 'file')

        nii = nii_tool('load', sNiiFileName);
        aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');    

        aObjectMask = aObjectMask(:,:,end:-1:1);

        aSlicesNumber = any(any(aObjectMask, 1), 2);
        
        if ~isempty(aSlicesNumber)

            if numel(aSlicesNumber) > 1
    
                aObjectMask = aObjectMask(:,:,aSlicesNumber);
        
                % Find columns where the mask is present
                maskColumns = any(any(aObjectMask, 1), 3);
                        
                % Calculate the column coordinates of the neighboring pixels
                if strcmpi(sDirection, 'Left')
                    dColumnNumber = find(maskColumns, 1, 'first');
                else
                    dColumnNumber = find(maskColumns, 1, 'last');
                end
            end
        end

        clear aObjectMask;

    end
end