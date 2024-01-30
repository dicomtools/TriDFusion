function aMask = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, aMask)
%function aMask = getTotalSegmentorWholeBodyMask(sSegmentationFolderName, aMask)
%Return a WholeBody mask, from TotalSegmentor segmentation.
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
    'rib_left_1.nii.gz',...
    'rib_left_2.nii.gz',...
    'rib_left_3.nii.gz',...
    'rib_left_4.nii.gz',...
    'rib_left_5.nii.gz',...
    'rib_left_6.nii.gz',...
    'rib_left_7.nii.gz',...
    'rib_left_8.nii.gz',...
    'rib_left_9.nii.gz',...
    'rib_left_10.nii.gz',...
    'rib_left_11.nii.gz',...
    'rib_left_12.nii.gz',...
    'rib_right_1.nii.gz',...
    'rib_right_2.nii.gz',...
    'rib_right_3.nii.gz',...
    'rib_right_4.nii.gz',...
    'rib_right_5.nii.gz',...
    'rib_right_6.nii.gz',...
    'rib_right_7.nii.gz',...
    'rib_right_8.nii.gz',...
    'rib_right_9.nii.gz',...
    'rib_right_10.nii.gz',...
    'rib_right_11.nii.gz',...
    'rib_right_12.nii.gz',...  
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
    'vertebrae_T12.nii.gz',...
    'clavicula_right.nii.gz', ...
    'clavicula_left.nii.gz', ...
    'humerus_right.nii.gz', ...
    'humerus_left.nii.gz', ...
    'scapula_right.nii.gz', ...
    'scapula_left.nii.gz', ...
    'hip_right.nii.gz', ...
    'hip_left.nii.gz', ...
    'femur_right.nii.gz', ...
    'femur_left.nii.gz', ...
    'sacrum.nii.gz'};

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

    % New classes in V2
    
    asV2BoneList = {
    'skull.nii.gz',... 
    'sternum.nii.gz',...
    'costal_cartilages.nii.gz'};

    for bb=1:numel(asV2BoneList)

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, asV2BoneList{bb});  

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aMask(aObjectMask~=0) = 1;
        end
    end

    clear aObjectMask;
    clear nii;

    aMask=aMask(:,:,end:-1:1);

end