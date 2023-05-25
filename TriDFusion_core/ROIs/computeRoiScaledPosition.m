function [aNewPosition, aRadius, aSemiAxes, transM] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
%function [aNewPosition, aRadius, aSemiAxes, transM] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
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
    
%    dcmMatrix = TransformMatrix(atDcmMetaData{1}, dcmSliceThickness);
%    refMatrix = TransformMatrix(atRefMetaData{1}, refSliceThickness);
    
%    dcmMatrix=getAffineXfm(atDcmMetaData);
%    refMatrix=getAffineXfm(atRefMetaData);
    
%    f = dcmMatrix' /refMatrix';
%    f(isnan(f))=0;
%    f(isinf(f))=0;
%    TF = affine3d(f);
        
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
       
    % Set origin to the edge of first pixel
    
%    atDcmMetaData{1}.ImagePositionPatient(1) = atDcmMetaData{1}.ImagePositionPatient(1)-(atDcmMetaData{1}.PixelSpacing(1));
%    atDcmMetaData{1}.ImagePositionPatient(2) = atDcmMetaData{1}.ImagePositionPatient(2)-(atDcmMetaData{1}.PixelSpacing(2));
  
%    atRefMetaData{1}.ImagePositionPatient(1) = atRefMetaData{1}.ImagePositionPatient(1)-(atRefMetaData{1}.PixelSpacing(1));
%    atRefMetaData{1}.ImagePositionPatient(2) = atRefMetaData{1}.ImagePositionPatient(2)-(atRefMetaData{1}.PixelSpacing(2));     

    % Set origin to the edge of first pixel. ImagePositionPatient is the
    % coordinates of top left middle of first pixel.  

if 1    
    if ~((round(Rdcm.ImageExtentInWorldX) > round(Rref.ImageExtentInWorldX)) && ...
        (round(Rdcm.ImageExtentInWorldX) > round(Rref.ImageExtentInWorldX))) && ...
        ~((round(Rdcm.ImageExtentInWorldX) < round(Rref.ImageExtentInWorldX)) && ...
          (round(Rdcm.ImageExtentInWorldX) < round(Rref.ImageExtentInWorldX)))   
    
        atDcmMetaData{1}.ImagePositionPatient(1) = -(atDcmMetaData{1}.PixelSpacing(1)/2);
        atDcmMetaData{1}.ImagePositionPatient(2) = -(atDcmMetaData{1}.PixelSpacing(2)/2);
  
        atRefMetaData{1}.ImagePositionPatient(1) = -(atRefMetaData{1}.PixelSpacing(1)/2);
        atRefMetaData{1}.ImagePositionPatient(2) = -(atRefMetaData{1}.PixelSpacing(2)/2);    
    end
end
%    atDcmMetaData{1}.ImagePositionPatient(1) = 0;
%    atDcmMetaData{1}.ImagePositionPatient(2) = 0;
  
%    atRefMetaData{1}.ImagePositionPatient(1) = 0;
%    atRefMetaData{1}.ImagePositionPatient(2) = 0;  

%    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
%    M(4,1)=0
%    M(4,2)=0
    
%    TF = affine3d(M); 
    
    [Mdti,~] = TransformMatrix(atDcmMetaData{1}, dcmSliceThickness);
    [Mtf,~]  = TransformMatrix(atRefMetaData{1}, refSliceThickness);
            
    M=Mtf/Mdti;
%    TF = invert(affine3d(M')); 
      
    xScale = M(2,2);
    yScale = M(1,1);  
    zScale = M(3,3);  
%    zScale = 1;  
           
    a3DOffset = zeros(size(tRoi.Position, 1),3);
        
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
         
            a3DOffset(:,1)=tRoi.Position(:,1);
            a3DOffset(:,2)=tRoi.Position(:,2);
            a3DOffset(:,3)=tRoi.SliceNb;                
    end
                
%    out = pctransform(pointCloud(a3DOffset), TF);
    

%    [outX, outY, outZ] = transformPointsForward(TF, a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3)); 

%    Mdti  = getAffineXfm(atDcmMetaData, dcmSliceThickness);
%    Mtf   = getAffineXfm(atRefMetaData, refSliceThickness);
if 1    
    transM = inv(Mtf) * Mdti;
    [outX, outY, outZ]  = applyTransMatrix(transM, a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3)); 
else
    transM = inv(Mtf) * Mdti;
   
    transM = (Mdti'/Mtf')';


    [outX, outY, outZ] = transformPointsForward(affine3d(transM'), a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3));

end
%    [~, ~, outZ]  = applyTransMatrix(transM', a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3)); 

%    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', 'Linear');      
%    dimsRsp = size(resampImage);         

if 1
    if    (round(Rdcm.ImageExtentInWorldX) > round(Rref.ImageExtentInWorldX)) && ...
          (round(Rdcm.ImageExtentInWorldX) > round(Rref.ImageExtentInWorldX))   

        xMoveOffset = Rref.PixelExtentInWorldX/xScale;
        yMoveOffset = Rref.PixelExtentInWorldY/yScale;


    elseif(round(Rdcm.ImageExtentInWorldX) < round(Rref.ImageExtentInWorldX)) && ...
          (round(Rdcm.ImageExtentInWorldX) < round(Rref.ImageExtentInWorldX))

        xMoveOffset = -Rref.PixelExtentInWorldX/xScale;
        yMoveOffset = -Rref.PixelExtentInWorldY/yScale;

    else
        xMoveOffset = 0;
        yMoveOffset = 0;        
    end
else
    xMoveOffset = 0;
    yMoveOffset = 0;
end


%    xMoveOffset = ((round(Rdcm.ImageExtentInWorldX)-round(Rref.ImageExtentInWorldX)/2))/(Rdcm.PixelExtentInWorldX/xScale)-(Rdcm.XWorldLimits(1)/5.6);
%    yMoveOffset = ((round(Rdcm.ImageExtentInWorldY)-round(Rref.ImageExtentInWorldY)/2))/(Rdcm.PixelExtentInWorldY/yScale)-(Rdcm.YWorldLimits(1)/5.6);
    
    
%    zMoveOffset = ((Rdcm.ImageExtentInWorldZ-Rref.ImageExtentInWorldZ)/2);
         
    switch lower(tRoi.Axe)

        case lower('axe')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = outX(:);
                aNewPosition(2) = outY(:);
                aNewPosition(3) = tRoi.Position(3)/xScale;
                aNewPosition(4) = tRoi.Position(4)/yScale;
                aNewPosition(5) = 1;
            else
                aNewPosition(:,1) = outX(:);
                aNewPosition(:,2) = outY(:);
                aNewPosition(:,3) = 1;
            end

        case lower('axes1')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = outX(:);
                aNewPosition(2) = outZ(:);
                aNewPosition(3) = tRoi.Position(3)/yScale;
                aNewPosition(4) = tRoi.Position(4);
                aNewPosition(5) = outY(:);
            else
                aNewPosition(:,1) = outX(:)-xMoveOffset;
                aNewPosition(:,2) = outZ(:);
                aNewPosition(:,3) = outY(:)-yMoveOffset;
            end

        case lower('axes2')

            if strcmpi(tRoi.Type, 'images.roi.rectangle')

                aNewPosition(1) = outY(:);
                aNewPosition(2) = outZ(:);
                aNewPosition(3) = tRoi.Position(3)/xScale;
                aNewPosition(4) = tRoi.Position(4);
                aNewPosition(5) = outX(:);
            else
                aNewPosition(:,1) = outY(:)-yMoveOffset;
                aNewPosition(:,2) = outZ(:);
                aNewPosition(:,3) = outX(:)-xMoveOffset;
            end

        case lower('axes3')
            
            if strcmpi(tRoi.Type, 'images.roi.rectangle')
                
%                if numel(refImage) > numel(dcmImage)

%                    aNewPosition(1) = out.Location(1);
%                    aNewPosition(2) = out.Location(2);
%                    aNewPosition(3) = tRoi.Position(3)*xScale;
%                    aNewPosition(4) = tRoi.Position(4)*yScale;
%                    aNewPosition(5) = out.Location(3);
%                else
                    aNewPosition(1) = outX(:)-xMoveOffset;
                    aNewPosition(2) = outY(:)-yMoveOffset;
                    aNewPosition(3) = tRoi.Position(3)/xScale;
                    aNewPosition(4) = tRoi.Position(4)/yScale;
                    aNewPosition(5) = outZ(:);                    
%                end
            else
                    aNewPosition(:,1) = outX(:)-xMoveOffset;
                    aNewPosition(:,2) = outY(:)-yMoveOffset;
%                    aNewPosition(:,1) = outX(:);
%                    aNewPosition(:,2) = outY(:);
                    aNewPosition(:,3) = outZ(:);                    

            end
    end

    switch lower(tRoi.Type)

        case lower('images.roi.circle')

            switch lower(tRoi.Axe)

                case lower('axe')
                    aRadius = tRoi.Radius/xScale;

                case lower('axes1')
                    aRadius = tRoi.Radius/zScale;

                case lower('axes2')
                    aRadius = tRoi.Radius/zScale;

                case lower('axes3')
                    aRadius = tRoi.Radius/xScale;
            end


        case lower('images.roi.ellipse')

            switch lower(tRoi.Axe)

                case lower('axe')
                    aSemiAxes = tRoi.SemiAxes/xScale;

                case lower('axes1')
                    aSemiAxes = tRoi.SemiAxes/zScale;

                case lower('axes2')
                    aSemiAxes = tRoi.SemiAxes/zScale;

                case lower('axes3')
                    aSemiAxes = tRoi.SemiAxes/xScale;
            end
    end    
    
end



