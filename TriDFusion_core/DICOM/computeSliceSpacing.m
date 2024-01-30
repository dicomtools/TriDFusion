function dSpacing = computeSliceSpacing(atDicomInfo)
%function dSpacing = computeSliceSpacing(atDicomInfo)
%Compute the spacing between slices.
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

    if numel(atDicomInfo) == 1
        
        if strcmpi(atDicomInfo{1}.Modality, 'RTDOSE')

            if ~isempty(atDicomInfo{1}.GridFrameOffsetVector)

                dNbFrames = numel(atDicomInfo{1}.GridFrameOffsetVector);
                
                if dNbFrames >1
                    dSpacing = abs(atDicomInfo{1}.GridFrameOffsetVector(2)-atDicomInfo{1}.GridFrameOffsetVector(1));
                else
                    dSpacing = 1;
                end
            else
                dSpacing =1;
            end
        else

            dSpacing = abs(atDicomInfo{1}.SpacingBetweenSlices);
            
            if dSpacing == 0
                dSpacing = 1;
            end
        end

        return;
    end

    sumPxyz = 0;
    for cc=1: numel(atDicomInfo)-1

        xyz1 = atDicomInfo{cc}.ImagePositionPatient;
        pos1 = atDicomInfo{cc}.ImageOrientationPatient;
        spa1 = atDicomInfo{cc}.PixelSpacing;
        M1 = [ [pos1(1)*spa1(1) ; pos1(2)* spa1(1) ; pos1(3)*spa1(1) ; 0] ...
               [pos1(4)*spa1(2) ; pos1(5)* spa1(2) ; pos1(6)*spa1(2) ; 0] ...
               [0 ; 0 ; 0 ; 0] [xyz1(1) ; xyz1(2) ; xyz1(3) ; 0 ]       ];
        pxyzFirst = M1*[1 ; 1 ; 0 ; 1];

%               for i = 1:128 % row
%                   for j = 1:128 % column
%                       pxyz1 = M1*[i ; j ; 0 ; 1];
%                       ijk1 = (M1'*M1+1E-10*eye(4))\M1'*pxyz1;
%                   end
%               end

        xyz2 = atDicomInfo{cc+1}.ImagePositionPatient;
        pos2 = atDicomInfo{cc+1}.ImageOrientationPatient;
        spa2 = atDicomInfo{cc+1}.PixelSpacing;
        M2 = [ [pos2(1)*spa2(1) ; pos2(2)* spa2(1) ; pos2(3)*spa1(1) ; 0] ...
               [pos2(4)*spa2(2) ; pos2(5)* spa2(2) ; pos2(6)*spa1(2) ; 0] ...
               [0 ; 0 ; 0 ; 0] [xyz2(1) ; xyz2(2) ; xyz2(3) ; 0 ]       ];
        pxyzLast = M2*[1 ; 1 ; 0 ; 1];
        
%        pxyzLast - pxyzFirst
        
        sOrientation = getImageOrientation(atDicomInfo{cc}.ImageOrientationPatient);

        if      strcmpi(sOrientation, 'Sagittal')
            sumPxyz = sumPxyz + abs(pxyzLast(1) - pxyzFirst(1));
        elseif  strcmpi(sOrientation, 'Coronal')
            sumPxyz = sumPxyz + abs(pxyzLast(2) - pxyzFirst(2));
        else    % Axial
            sumPxyz = sumPxyz + abs(pxyzLast(3) - pxyzFirst(3));
        end

    end

    dSpacing = abs(sumPxyz / (numel(atDicomInfo)-1));
    
    if dSpacing == 0
        dSpacing = abs(atDicomInfo{1}.SpacingBetweenSlices);
    end

end
