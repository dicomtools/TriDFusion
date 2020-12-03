function dLength = computeLineLength(atRoiMetaData, sAxe, roiObject)
%function dLength = computeLineLength(atRoiMetaData, sAxe, roiObject)
%Compute Line Lenght from ROIs.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    xAxial = atRoiMetaData{1}.PixelSpacing(1);
    yAxial = atRoiMetaData{1}.PixelSpacing(2);

    if strcmpi(sAxe, 'Axe') % Planar
        xPixel = xAxial;
        yPixel = yAxial;
    else
        zAxial = computeSliceSpacing(atRoiMetaData);       

        if strcmpi(sAxe, 'Axes1') % Coronal    

            if strcmp(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = yAxial;
            end
            if strcmp(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = xAxial;
            end
            if strcmp(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
            end
       end

       if strcmpi(sAxe, 'Axes2') % Sagittal   
            if strcmp(imageOrientation('get'), 'coronal')
                xPixel = yAxial;
                yPixel = xAxial;
            end
            if strcmp(imageOrientation('get'), 'sagittal')
                xPixel = zAxial;
                yPixel = yAxial;
            end
            if strcmp(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
            end                
        end

        if strcmpi(sAxe, 'Axes3') % Axial  

            if strcmp(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = zAxial;
            end
            if strcmp(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = zAxial;
            end
            if strcmp(imageOrientation('get'), 'axial')
                xPixel = xAxial;
                yPixel = yAxial;
            end
        end

    end

    x1 = roiObject.Position(1,1);
    y1 = roiObject.Position(1,2);

    x2 = roiObject.Position(2,1);
    y2 = roiObject.Position(2,2);

    deltax = (x1-x2) * xPixel;
    deltay = (y1-y2) * yPixel;

   dLength = sqrt(deltax^2 + deltay^2);

end

