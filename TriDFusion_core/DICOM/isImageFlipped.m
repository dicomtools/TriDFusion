function bFlip = isImageFlipped(tDicomInfo1)
%function bFlip = isImageFlipped(tDicomInfo1)
%Return yes/no the image is flipped.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    bFlip = false;

    sOrientation = getImageOrientation(tDicomInfo1.ImageOrientationPatient);

    if strcmpi(tDicomInfo1.Modality, 'RTDOSE')

        if ~isempty(tDicomInfo1.GridFrameOffsetVector)

            dNbFrames = numel(tDicomInfo1.GridFrameOffsetVector);
            
            if dNbFrames >1            
                dSpacingBetweenSlices = tDicomInfo1.GridFrameOffsetVector(2)-tDicomInfo1.GridFrameOffsetVector(1);
            else
                dSpacingBetweenSlices = 0;
            end
        else
            dSpacingBetweenSlices =0;
        end
    else
        dSpacingBetweenSlices = tDicomInfo1.SpacingBetweenSlices;
    end


    if      strcmpi(sOrientation, 'Sagittal')

        dCurrentLocation = tDicomInfo1.ImagePositionPatient(1);
        dNextLocation = dCurrentLocation-dSpacingBetweenSlices;

    elseif  strcmpi(sOrientation, 'Coronal')

        dCurrentLocation = tDicomInfo1.ImagePositionPatient(2);
        dNextLocation = dCurrentLocation-dSpacingBetweenSlices;

    else    % Axial
        dCurrentLocation = tDicomInfo1.ImagePositionPatient(3);
        dNextLocation = dCurrentLocation-dSpacingBetweenSlices;
    end

    if dCurrentLocation > dNextLocation  
        
        bFlip = true;
    end
end