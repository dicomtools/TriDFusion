function dSpacing = spacingBetweenTwoSlices(tDicomInfo1, tDicomInfo2)
%function dSpacing = spacingBetweenTwoSlices(tDicomInfo1, tDicomInfo2)
%Compute the spacing between two slices.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        C. Ross Schmidtlein, schmidtr@mskcc.org
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

    xyz1 = tDicomInfo1.ImagePositionPatient;
    pos1 = tDicomInfo1.ImageOrientationPatient;
    spa1 = tDicomInfo1.PixelSpacing;
    M1 = [ [pos1(1)*spa1(1) ; pos1(2)* spa1(1) ; pos1(3)*spa1(1) ; 0] ...
           [pos1(4)*spa1(2) ; pos1(5)* spa1(2) ; pos1(6)*spa1(2) ; 0] ...
           [0 ; 0 ; 0 ; 0] [xyz1(1) ; xyz1(2) ; xyz1(3) ; 0 ]       ];
    pxyzFirst = M1*[1 ; 1 ; 0 ; 1];

    xyz2 = tDicomInfo2.ImagePositionPatient;
    pos2 = tDicomInfo2.ImageOrientationPatient;
    spa2 = tDicomInfo2.PixelSpacing;
    M2 = [ [pos2(1)*spa2(1) ; pos2(2)* spa2(1) ; pos2(3)*spa1(1) ; 0] ...
           [pos2(4)*spa2(2) ; pos2(5)* spa2(2) ; pos2(6)*spa1(2) ; 0] ...
           [0 ; 0 ; 0 ; 0] [xyz2(1) ; xyz2(2) ; xyz2(3) ; 0 ]       ];
    pxyzLast = M2*[1 ; 1 ; 0 ; 1];
    
    sOrientation = getImageOrientation(tDicomInfo1.ImageOrientationPatient);
            
    if      strcmpi(sOrientation, 'Sagittal')
        dSpacing = pxyzLast(1) - pxyzFirst(1);
    elseif  strcmpi(sOrientation, 'Coronal')
        dSpacing = pxyzLast(2) - pxyzFirst(2);
    else    % Axial
        dSpacing = pxyzLast(3) - pxyzFirst(3);
    end
        
end
