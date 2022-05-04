function [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
%function [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
%Comput ROI new position from a scaled image.
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

    dimsRef = size(refImage);        
    dimsDcm = size(dcmImage);

    if ~exist('Rsmp', 'var')
        Rsmp = [];
    end
    
    aRadius = [];
    aSemiAxes = [];

    if strcmpi(tRoi.Type, 'images.roi.rectangle')
        aNewPosition = zeros(size(tRoi.Position, 1),5);
    else
        aNewPosition = zeros(size(tRoi.Position, 1),3);
    end

    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);
    
    dcmMatrix = TransformMatrix(atDcmMetaData{1}, dcmSliceThickness);
    refMatrix = TransformMatrix(atRefMetaData{1}, refSliceThickness);
    
    f = dcmMatrix ./refMatrix;
    f(isnan(f))=0;
    f(isinf(f))=0;
      
    xScale = f(2,2);
    yScale = f(1,1);
    
    if dcmSliceThickness == 0  
        dcmSliceThickness = 1;
    end
      
    if atDcmMetaData{1}.PixelSpacing(1) == 0 && ...
       atDcmMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atDcmMetaData)
            atDcmMetaData{1}.PixelSpacing(1) =1;
            atDcmMetaData{1}.PixelSpacing(2) =1;
        end       
    end
    
    if refSliceThickness == 0  
        refSliceThickness = 1;
    end
      
    if atRefMetaData{1}.PixelSpacing(1) == 0 && ...
       atRefMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atRefMetaData)
            atRefMetaData{1}.PixelSpacing(1) =1;
            atRefMetaData{1}.PixelSpacing(2) =1;
        end       
    end
    
    Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);
      
    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);         
        
    a3DOffset = zeros(size(tRoi.Position, 1),3);
    
    xMoveOffset = (dimsDcm(1)-dimsRef(1))/2;
    yMoveOffset = (dimsDcm(2)-dimsRef(2))/2;   
    
    switch lower(tRoi.Axe)

        case lower('axe')

            a3DOffset(:,1)= tRoi.Position(:,1);
            a3DOffset(:,2)= tRoi.Position(:,2);
            a3DOffset(:,3)= 1;

        case lower('axes1')

            a3DOffset(:,1)=tRoi.Position(:,1);
            a3DOffset(:,2)=tRoi.SliceNb;
            a3DOffset(:,3)=tRoi.Position(:,2);

        case lower('axes2')

            a3DOffset(:,1)=tRoi.SliceNb;
            a3DOffset(:,2)=tRoi.Position(:,1);
            a3DOffset(:,3)=tRoi.Position(:,2);

        case lower('axes3')
            if numel(refImage) > numel(dcmImage)
                a3DOffset(:,1)=tRoi.Position(:,1);
                a3DOffset(:,2)=tRoi.Position(:,2);
                a3DOffset(:,3)=tRoi.SliceNb;                
            else
                a3DOffset(:,1)=tRoi.Position(:,1);
                a3DOffset(:,2)=tRoi.Position(:,2);
                a3DOffset(:,3)=tRoi.SliceNb;
            end
    end
    
    out = pctransform(pointCloud(a3DOffset), TF);
 
    switch lower(tRoi.Axe)

        case lower('axe')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = out.Location(1);
                aNewPosition(2) = out.Location(2);
                aNewPosition(3) = tRoi.Position(3)*xScale;
                aNewPosition(4) = tRoi.Position(4)*yScale;
                aNewPosition(5) = 1;
            else
                aNewPosition(:,1) = out.Location(:,1);
                aNewPosition(:,2) = out.Location(:,2);
                aNewPosition(:,3) = 1;
            end

        case lower('axes1')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = out.Location(1);
                aNewPosition(2) = out.Location(3);
                aNewPosition(3) = tRoi.Position(3)*yScale;
                aNewPosition(4) = tRoi.Position(4);
                aNewPosition(5) =  out.Location(2);
            else
                aNewPosition(:,1) = out.Location(:,1);
                aNewPosition(:,2) = out.Location(:,3);
                aNewPosition(:,3) = out.Location(:,2);
            end

        case lower('axes2')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = out.Location(2);
                aNewPosition(2) = out.Location(3);
                aNewPosition(3) = tRoi.Position(3)*xScale;
                aNewPosition(4) = tRoi.Position(4);
                aNewPosition(5) = out.Location(1);
            else
                aNewPosition(:,1) = out.Location(:,2);
                aNewPosition(:,2) = out.Location(:,3);
                aNewPosition(:,3) = out.Location(:,1);
            end

        case lower('axes3')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = out.Location(1);
                aNewPosition(2) = out.Location(2);
                aNewPosition(3) = tRoi.Position(3)*xScale;
                aNewPosition(4) = tRoi.Position(4)*yScale;
                aNewPosition(5) = out.Location(3);
            else
                if numel(refImage) > numel(dcmImage)
                    aNewPosition(:,1) = out.Location(:,1);
                    aNewPosition(:,2) = out.Location(:,2);
                    aNewPosition(:,3) = out.Location(:,3);                    
                else
                    aNewPosition(:,1) = out.Location(:,1);
                    aNewPosition(:,2) = out.Location(:,2);
                    aNewPosition(:,3) = out.Location(:,3);                      
                end
            end
    end

    switch lower(tRoi.Type)

        case lower('images.roi.circle')

            switch lower(tRoi.Axe)

                case lower('axe')
                    aRadius = tRoi.Radius*xScale;

                case lower('axes1')
                    aRadius = tRoi.Radius*zScale;

                case lower('axes2')
                    aRadius = tRoi.Radius*zScale;

                case lower('axes3')
                    aRadius = tRoi.Radius*xScale;
            end


        case lower('images.roi.ellipse')

            switch lower(tRoi.Axe)

                case lower('axe')
                    aSemiAxes = tRoi.SemiAxes*xScale;

                case lower('axes1')
                    aSemiAxes = tRoi.SemiAxes*zScale;

                case lower('axes2')
                    aSemiAxes = tRoi.SemiAxes*zScale;

                case lower('axes3')
                    aSemiAxes = tRoi.SemiAxes*xScale;
            end
    end

end