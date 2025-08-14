function [ctVolumeClean, bedMask, medImg] = removeCTTableAdvanced(ctVolume)
% removeTableByMedianMask  Remove the patient table from an axial CT volume by
%                           computing a median (background) image and segmenting the
%                           most repetitive structure (the table) from the lower region.
%
%   [ctVolumeClean, bedMask, medImg] = removeTableByMedianMask(ctVolume)
%
%   Input:
%       ctVolume - 3D CT volume in axial orientation [rows x cols x slices].
%                  'rows' correspond to the anterior–posterior (AP) direction.
%
%   Output:
%       ctVolumeClean - The CT volume after table removal. In every axial slice,
%                       pixels belonging to the table region are replaced by -1000 HU.
%       bedMask     - Binary mask (2D, size = [rows x cols]) representing the table segmentation.
%       medImg      - The median image (computed over slices), which is used to derive the mask.
%
%   Method:
%     1. Compute the median image across all slices. This image should preserve the table
%        since it is present in nearly every slice.
%     2. Restrict the median image to the bottom region (e.g. the bottom 40% of rows) where the table is expected.
%     3. Normalize the ROI and use an automatic threshold (e.g. Otsu's method) to segment the table.
%     4. Postprocess the mask with morphological operations, and select the largest connected component.
%     5. Apply the resulting mask to all slices (set those pixels to -1000 HU).
%
%   Author: [Your Name]
%   Date: [Date]

airHU = -1000;
[rows, cols, nSlices] = size(ctVolume);

%% Step 1. Compute the Median Image Across Slices
medImg = median(double(ctVolume), 3);

%% Step 2. Restrict Analysis to the Lower Portion of the Image
% Assuming the table lies in the lower 40% of the AP direction.
roiStart = round(rows * 0.6);
roi = medImg(roiStart:end, :);

%% Step 3. Normalize and Segment the ROI
% Normalize the ROI to [0,1] for thresholding.
roiNorm = mat2gray(roi);
% Use Otsu's method to obtain a threshold.
threshLevel = graythresh(roiNorm);
% We assume the table appears dark (low intensity) compared to the patient,
% so use a "<" threshold. You might need to invert if your images differ.
binaryROI = roiNorm < threshLevel;

%% Step 4. Morphological Cleanup and Extraction of the Table
% Fill holes and remove small objects.
binaryROI = imfill(binaryROI, 'holes');
se = strel('disk', 3);
binaryROI = imopen(binaryROI, se);
% Optionally, keep only the largest connected component.
CC = bwconncomp(binaryROI);
if CC.NumObjects >= 1
    areas = cellfun(@numel, CC.PixelIdxList);
    [~, idx] = max(areas);
    cleanROI = false(size(binaryROI));
    cleanROI(CC.PixelIdxList{idx}) = true;
else
    cleanROI = binaryROI;
end

%% Step 5. Map the ROI Mask Back to the Full Image and Generate bedMask
bedMask = false(rows, cols);
bedMask(roiStart:end, :) = cleanROI;
% (At this point, bedMask should capture the invariant table region.)

%% Step 6. Remove the Table from Every Axial Slice Using bedMask
ctVolumeClean = ctVolume;
for i = 1:nSlices
    slice = ctVolumeClean(:,:,i);
    slice(bedMask) = airHU;
    ctVolumeClean(:,:,i) = slice;
end

fprintf('Table removed using median background segmentation.\n');

end
