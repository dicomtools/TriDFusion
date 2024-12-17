function aExcludeMask = getMantleCellLymphomaExcludeMask(tMantleCellLymphoma, sSegmentationFolderName, aExcludeMask)
%function aExcludeMask = getMantleCellLymphomaExcludeMask(tMantleCellLymphoma, sSegmentationFolderName, aExcludeMask)
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

    asCardiovascularName = ...
        {'Common Carotid Artery Left',...
         'Common Carotid Artery Right', ...
         'Subclavian Artery Left', ...
         'Subclavian Artery Right', ...
         'Brachiocephalic Trunk', ...
         'Brachiocephalic Vein Left', ...
         'Brachiocephalic Vein Right', ...
         'Pulmonary Vein', ...
         'Superior Vena Cava', ...
         'Heart', ...
         'Atrial Appendage Left', ...
         'Aorta', ...
         'Pulmonary Artery', ...
         'Ventricle Left', ...
         'Ventricle Right', ...
         'Atrium Left', ...
         'Atrium Right', ...
         'Myocardium', ...
         'Portal & Splenic Vein', ...
         'Inferior Vena Cava', ...
         'Iliac Artery Left', ...
         'Iliac Artery Right', ...
         'Iliac Vena Left', ...
         'Iliac Vena Right' ...
         };

        asGastrointestinalTractName = ...
            {'Esophagus', ...
             'Stomach', ...
             'Duodenum', ...
             'Small Bowel', ...
             'Colon', ...
             'Urinary Bladder' ...
             };

    % Brain

   if tMantleCellLymphoma.exclude.organ.brain == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'brain.nii.gz');  

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end

    % Spleen

    if tMantleCellLymphoma.exclude.organ.spleen == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'spleen.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % kidney Left

    if tMantleCellLymphoma.exclude.organ.kidneyLeft == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_left.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % kidney Right

    if tMantleCellLymphoma.exclude.organ.kidneyRight == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_right.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Spinal Cord

    if tMantleCellLymphoma.exclude.organ.spinalCord == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'spinal_cord.nii.gz');

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Adrenal Gland Left

    if tMantleCellLymphoma.exclude.organ.adrenalGlandLeft == true

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

    if tMantleCellLymphoma.exclude.organ.adrenalGlandRight == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'adrenal_gland_right.nii.gz');

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Gallbladder

    if tMantleCellLymphoma.exclude.organ.gallbladder == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'gallbladder.nii.gz');

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Prostate

    if tMantleCellLymphoma.exclude.organ.prostate == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'prostate.nii.gz');

        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Cardiovascular

    if tMantleCellLymphoma.exclude.cardiovascular.all == true

        for cc=1: numel(asCardiovascularName)

            sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, lower(replace(asCardiovascularName{cc},' ', '_' )));
    
            if exist(sNiiFileName, 'file')
    
                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
    
                aExcludeMask(aObjectMask~=0)=1;
    
                clear aObjectMask;
                clear nii;
            end            
        end
    end

    % Gastrointestal Tract

    if tMantleCellLymphoma.exclude.gastrointestalTract.all == true

        for gg=1: numel(asGastrointestinalTractName)

            sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, lower(replace(asGastrointestinalTractName{gg},' ', '_' )));
    
            if exist(sNiiFileName, 'file')
    
                nii = nii_tool('load', sNiiFileName);
                aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
    
                if strcmpi(asGastrointestinalTractName{gg}, 'Urinary Bladder')            

                    aObjectMask = imdilate(aObjectMask, strel('sphere', 5));
                end

                aExcludeMask(aObjectMask~=0)=1;
    
                clear aObjectMask;
                clear nii;
            end            
        end        
    end

    aExcludeMask = aExcludeMask(:,:,end:-1:1);

end