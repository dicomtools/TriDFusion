function aMask = getTotalSegmentorLungsMask(sSegmentationFolderName, aMask)
%function aMask = getTotalSegmentorLungsMask(sSegmentationFolderName, aMask)
%Return a lungs mask, from TotalSegmentor segmentation.
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

    asOrganList = {
    'lung_lower_lobe_left.nii.gz',...
    'lung_lower_lobe_right.nii.gz',...
    'lung_middle_lobe_right.nii.gz',...
    'lung_upper_lobe_left.nii.gz',...
    'lung_upper_lobe_right.nii.gz'};

    aObjectMask=[];
    nii=[];

    for bb=1:numel(asOrganList)

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, asOrganList{bb});  

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aMask(aObjectMask~=0)=1;

        end
    end

    clear aObjectMask;
    clear nii;

    aMask=aMask(:,:,end:-1:1);

end