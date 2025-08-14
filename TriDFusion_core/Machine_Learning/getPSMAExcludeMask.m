function aExcludeMask = getPSMAExcludeMask(tPSMA, sSegmentationFolderName, aExcludeMask)
%function aExcludeMask = getPSMAExcludeMask(tPSMA, sSegmentationFolderName, aExcludeMask)
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

    if isfield(tPSMA.exclude.organ, 'brain') && ...
       tPSMA.exclude.organ.brain == true

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

    if isfield(tPSMA.exclude.organ, 'spleen') && ...
       tPSMA.exclude.organ.spleen == true

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

    if isfield(tPSMA.exclude.organ, 'kidneyLeft') && ...
       tPSMA.exclude.organ.kidneyLeft == true

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

    if isfield(tPSMA.exclude.organ, 'kidneyRight') && ...
       tPSMA.exclude.organ.kidneyRight == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'kidney_right.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Liver

    if isfield(tPSMA.exclude.organ, 'liver') && ...
       tPSMA.exclude.organ.liver == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'liver.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Gastrointestinal Tract Name

    % Urinary Bladder

    if isfield(tPSMA.exclude.gastrointestinal, 'urinaryBladder') && ...
       tPSMA.exclude.gastrointestinal.urinaryBladder == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'urinary_bladder.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end 

    % Small Bowel

    if isfield(tPSMA.exclude.gastrointestinal, 'smallBowel') && ...
       tPSMA.exclude.gastrointestinal.smallBowel == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'small_bowel.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end

    % Doudenum

    if isfield(tPSMA.exclude.gastrointestinal, 'duodenum') && ...
       tPSMA.exclude.gastrointestinal.duodenum == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'duodenum.nii.gz');
                                                                 
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end

    % Stomach

    if isfield(tPSMA.exclude.gastrointestinal, 'stomach') && ...
       tPSMA.exclude.gastrointestinal.stomach == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'stomach.nii.gz');
    
        if exist(sNiiFileName, 'file')

            nii = nii_tool('load', sNiiFileName);
            aObjectMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');

            aExcludeMask(aObjectMask~=0)=1;

            clear aObjectMask;
            clear nii;
        end
    end

    % Colon

    if isfield(tPSMA.exclude.gastrointestinal, 'colon') && ...
       tPSMA.exclude.gastrointestinal.colon == true

        sNiiFileName = sprintf('%s%s', sSegmentationFolderName, 'colon.nii.gz');
    
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