function aMask = getTotalSegmentorVertebraeMask(sSegmentationFolderName, aMask)
%function aMask = getTotalSegmentorVertebraeMask(sSegmentationFolderName, aMask)
%Return a vertebrae mask, from TotalSegmentor segmentation.
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

    asBoneList = {
    'vertebrae_C1.nii.gz',...
    'vertebrae_C2.nii.gz',...
    'vertebrae_C3.nii.gz',...
    'vertebrae_C4.nii.gz',...
    'vertebrae_C5.nii.gz',...
    'vertebrae_C6.nii.gz',...
    'vertebrae_C7.nii.gz',...
    'vertebrae_L1.nii.gz',...
    'vertebrae_L2.nii.gz',...
    'vertebrae_L3.nii.gz',...
    'vertebrae_L4.nii.gz',...
    'vertebrae_L5.nii.gz',...
    'vertebrae_T1.nii.gz',...
    'vertebrae_T2.nii.gz',...
    'vertebrae_T3.nii.gz',...
    'vertebrae_T4.nii.gz',...
    'vertebrae_T5.nii.gz',...
    'vertebrae_T6.nii.gz',...
    'vertebrae_T7.nii.gz',...
    'vertebrae_T8.nii.gz',...
    'vertebrae_T9.nii.gz',...   
    'vertebrae_T10.nii.gz',...
    'vertebrae_T11.nii.gz',...
    'vertebrae_T12.nii.gz'};

    aObjectMask=[];
    nii=[];

    for bb=1:numel(asBoneList)

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, asBoneList{bb});  

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