function [lFirst, lLast] = computeVsplashLayout(im, sAxe, dSlice)
%function [lFirst, lLast] = computeVsplashLayout(im, sAxe, dSlice)
%Compute 2D vSplash Layout.
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

    lLayoutX = vSplashLayout('get', 'x');
    lLayoutY = vSplashLayout('get', 'y');

    switch lower(sAxe)
        case 'coronal'
            dAxeSize = size(im, 1);

        case 'sagittal'
            dAxeSize = size(im, 2);

        case 'axial'
            dAxeSize = size(im, 3);
    end

    lMatrixSize = lLayoutX*lLayoutY;
    lFirst = round(dSlice - (lMatrixSize/2));
    lLast  = round((dSlice + (lMatrixSize/2)) -1);

    if lFirst < 1
        lFirst = 1;
        lLast  = lMatrixSize;
    end

    if lFirst + lMatrixSize > dAxeSize
        lFirst = dAxeSize-lMatrixSize+1;
        lLast  = dAxeSize;                
    end

end