function aExcludeMask = getBrownFatSUVExcludeMask(tBrownFatSUV, sSegmentationFolderName, sSegmentatorCombineMasks, aExcludeMask)
%function aExcludeMask = getBrownFatSUVExcludeMask(tBrownFatSUV, sSegmentationFolderName, sSegmentatorCombineMasks, aExcludeMask)
%The function return a 3D mask, of a .nii file.
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

    % Brain

    if tBrownFatSUV.exclude.organ.brain == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'brain.nii.gz');  

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end

    % Heart

    if tBrownFatSUV.exclude.organ.heart == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'heart.nii.gz');  

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');


            % INCLUDE 15 slices beneath the heart, based on the heart's largest area.

            slicesWithMask = any(any(aObjectMask, 1), 2);

            aSliceNumber = find(slicesWithMask);

            areas = zeros(1,numel(aSliceNumber));
            for jj = 1:numel(aSliceNumber)
                areas(jj) = sum(aObjectMask(:, :, aSliceNumber(jj)), 'all');
            end     
            
            % Find the slice with the maximum area
            [~, maxIndex] = max(areas);

            aArea = aObjectMask(:, :, aSliceNumber(maxIndex));
            aArea = imfill(aArea);

            for jj=1:15
                aObjectMask(:,:,aSliceNumber(1)-jj) = aArea;
            end

            % /INCLUDE 15 slices beneath the heart, based on the heart's largest area.
     
            % EXTEND XY SIZE

            seXY = strel('disk', 3); % Increase Mask in XY

            % Initialize the extended mask
            aExtendedMask = zeros(size(aObjectMask));
            
            % Apply dilation to each XY slice separately
            for z = 1:size(aExtendedMask, 3)
                aExtendedMask(:,:,z) = imdilate(aObjectMask(:,:,z), seXY);
            end

            aObjectMask = aExtendedMask;

            clear aExtendedMask;

            % /EXTEND XY SIZE

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;

        else % Heart need to be combined

            sNiiFileName = 'combined_heart.nii.gz';

            sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s%s -m heart', sSegmentatorCombineMasks, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    

            [bStatus, sCmdout] = system(sCommandLine);

            if bStatus 
                progressBar( 1, 'Error: An error occur during heart combine mask!');
                errordlg(sprintf('An error occur during heart combine mask: %s', sCmdout), 'Segmentation Error');  
            else % Process succeed

                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                
                if exist(sNiiFileName, 'file')
                    nii = nii_tool('load', sNiiFileName);
                    aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                    aExcludeMask(aObjectMask~=0)=1;
        
                    clear aObjectMask;
                    clear nii;
               end

            end            
        end
    end

    % Lungs

    if tBrownFatSUV.exclude.organ.lungs == true

        % Lungs need to be combined

        sNiiFileName = 'combined_lungs.nii.gz';

        sCommandLine = sprintf('cmd.exe /c python.exe %s -i %s -o %s%s -m lung', sSegmentatorCombineMasks, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    

        [bStatus, sCmdout] = system(sCommandLine);

        if bStatus 
            progressBar( 1, 'Error: An error occur during heart combine mask!');
            errordlg(sprintf('An error occur during lung combine mask: %s', sCmdout), 'Segmentation Error');  
        else % Process succeed

            sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
            
            if exist(sNiiFileName, 'file')
                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

                aExcludeMask(aObjectMask~=0)=1;
    
                clear aObjectMask;
                clear nii;
           end

        end                    
    end

    % kidney Left

    if tBrownFatSUV.exclude.organ.kidneyLeft == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_left.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            % EXTEND XY SIZE

            seXY = strel('disk', 5); % Increase Mask in XY

            % Initialize the extended mask
            aExtendedMask = zeros(size(aObjectMask));
            
            % Apply dilation to each XY slice separately
            for z = 1:size(aExtendedMask, 3)
                aExtendedMask(:,:,z) = imdilate(aObjectMask(:,:,z), seXY);
            end

            aObjectMask = aExtendedMask;

            clear aExtendedMask;

            % /EXTEND XY SIZE

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % kidney Right

    if tBrownFatSUV.exclude.organ.kidneyRight == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_right.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            % EXTEND XY SIZE

            seXY = strel('disk', 5); % Increase Mask in XY

            % Initialize the extended mask
            aExtendedMask = zeros(size(aObjectMask));
            
            % Apply dilation to each XY slice separately
            for z = 1:size(aExtendedMask, 3)
                aExtendedMask(:,:,z) = imdilate(aObjectMask(:,:,z), seXY);
            end

            aObjectMask = aExtendedMask;

            clear aExtendedMask;

            % /EXTEND XY SIZE

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Liver

    if tBrownFatSUV.exclude.organ.liver == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 


    % Trachea

    if tBrownFatSUV.exclude.organ.trachea == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'trachea.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Adrenal Gland Left

    if tBrownFatSUV.exclude.organ.adrenalGlandLeft == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'adrenal_gland_left.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Adrenal Gland Right

    if tBrownFatSUV.exclude.organ.adrenalGlandRight == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'adrenal_gland_right.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Spleen

    if tBrownFatSUV.exclude.organ.spleen == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'spleen.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Gallbladder

    if tBrownFatSUV.exclude.organ.gallbladder == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'gallbladder.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Pancreas

    if tBrownFatSUV.exclude.organ.pancreas == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'pancreas.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 
                    
    aExcludeMask = aExcludeMask(:,:,end:-1:1);

end