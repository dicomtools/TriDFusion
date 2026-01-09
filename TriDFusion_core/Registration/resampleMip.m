function resampImage = resampleMip(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, dRefOutputView)
%function resampImage = resampleMip(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, dRefOutputView)
%Resample any modalities.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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
       
    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);
    
    if isempty(dcmSliceThickness) || dcmSliceThickness <= 0, dcmSliceThickness = 1; end
    if isempty(refSliceThickness) || refSliceThickness <= 0, refSliceThickness = 1; end
    
    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, ...
                               atRefMetaData{1}, refSliceThickness);
    
    if dRefOutputView == false % Keep source z
        M(3,3) = 1;
    end
    
    xScale = M(1,1); if xScale == 0, xScale = 1; end
    zScale = M(3,3); if zScale == 0, zScale = 1; end
    
    xExtended = M(4,1);
    zExtended = M(4,3);
    
    % Intrinsic (voxel) transform you originally intended
    f = [ xScale     0 0         0
          0          1 0         0
          0          0 zScale    0
          xExtended  0 zExtended 1];
    
    TFvox = affine3d(f);   % keep this for OutputView==2 branch

    % 
    % % Rdcm  = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    % % Rref  = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);
    %     % DICOM volume spatial reference
    % dcmMeta   = atDcmMetaData{1};
    % origin    = dcmMeta.ImagePositionPatient;     % [x0, y0, z0]
    % spacing   = dcmMeta.PixelSpacing;             % [rowSpacing; colSpacing]
    % % dimsDcm = [nRows, nCols, nSlices]
    % Rdcm = imref3d( dimsDcm, ...
    %     ... % XWorldLimits along columns uses col‐spacing = spacing(2)
    %     [ origin(1), origin(1) + (dimsDcm(2)-1) * spacing(2) ], ...
    %     ... % YWorldLimits along rows uses row‐spacing = spacing(1)
    %     [ origin(2), origin(2) + (dimsDcm(1)-1) * spacing(1) ], ...
    %     ... % ZWorldLimits from first‐ to last‐slice center
    %     [ origin(3), origin(3) + (dimsDcm(3)-1) * dcmSliceThickness ] );
    % 
    % % Reference volume spatial reference
    % refMeta    = atRefMetaData{1};
    % originRef  = refMeta.ImagePositionPatient;    % [x0, y0, z0]
    % spacingRef = refMeta.PixelSpacing;            % [rowSpacing; colSpacing]
    % % dimsRef = [nRows, nCols, nSlices]
    % Rref = imref3d( dimsRef, ...
    %     ... % XWorldLimits along columns
    %     [ originRef(1), originRef(1) + (dimsRef(2)-1) * spacingRef(2) ], ...
    %     ... % YWorldLimits along rows
    %     [ originRef(2), originRef(2) + (dimsRef(1)-1) * spacingRef(1) ], ...
    %     ... % ZWorldLimits from first‐ to last‐slice center
    %     [ originRef(3), originRef(3) + (dimsRef(3)-1) * refSliceThickness ] );
    % 
    % if (round(Rdcm.ImageExtentInWorldX) ~= round(Rref.ImageExtentInWorldX)) && ...
    %    (round(Rdcm.ImageExtentInWorldY) ~= round(Rref.ImageExtentInWorldY))
    %     if dRefOutputView == true
    %         dRefOutputView = 2;
    %     end
    % end


    % --- DICOM volume spatial reference (FIXED: half-voxel boundaries) ---
    dcmMeta = atDcmMetaData{1};
    origin  = double(dcmMeta.ImagePositionPatient(:));  % center of first voxel
    ps      = double(dcmMeta.PixelSpacing(:));          % [row; col]
    if numel(ps) < 2 || all(ps==0), ps = [1;1]; end
    
    szDcm = dcmSliceThickness;
    if isempty(szDcm) || szDcm <= 0, szDcm = 1; end
    
    xlim = [ origin(1) - ps(2)/2, origin(1) + (dimsDcm(2)-1)*ps(2) + ps(2)/2 ];
    ylim = [ origin(2) - ps(1)/2, origin(2) + (dimsDcm(1)-1)*ps(1) + ps(1)/2 ];
    zlim = [ origin(3) - szDcm/2, origin(3) + (dimsDcm(3)-1)*szDcm + szDcm/2 ];
    
    Rdcm = imref3d(dimsDcm, xlim, ylim, zlim);
    
    % --- Reference volume spatial reference (FIXED: half-voxel boundaries) ---
    refMeta = atRefMetaData{1};
    originR = double(refMeta.ImagePositionPatient(:));
    psR     = double(refMeta.PixelSpacing(:));
    if numel(psR) < 2 || all(psR==0), psR = [1;1]; end
    
    szRef = refSliceThickness;
    if isempty(szRef) || szRef <= 0, szRef = 1; end
    
    xlimR = [ originR(1) - psR(2)/2, originR(1) + (dimsRef(2)-1)*psR(2) + psR(2)/2 ];
    ylimR = [ originR(2) - psR(1)/2, originR(2) + (dimsRef(1)-1)*psR(1) + psR(1)/2 ];
    zlimR = [ originR(3) - szRef/2,  originR(3) + (dimsRef(3)-1)*szRef  + szRef/2  ];
    
    Rref = imref3d(dimsRef, xlimR, ylimR, zlimR);

    % World version of the same transform (needed if you call imwarp(..., Rdcm, ...))
    A = localIntrinsicToWorldAffine(Rdcm);
    Mworld  = (A \ (f * A));        % Adcm*Mworld = f*Adcm
    TFworld = affine3d(Mworld);

    if (round(Rdcm.ImageExtentInWorldX) ~= round(Rref.ImageExtentInWorldX)) || ...
       (round(Rdcm.ImageExtentInWorldY) ~= round(Rref.ImageExtentInWorldY))
        if dRefOutputView == true
            dRefOutputView = 2;
        end
    end

    dFill = double(min(dcmImage,[],'all'));
    
    if dRefOutputView == 2
        % intrinsic warp
        [resampImage, ~] = imwarp(dcmImage, TFvox, 'Interp', sMode, ...
            'FillValues', dFill, 'OutputView', imref3d(dimsRef));
    else
        % world warp (THIS is what removes the offset)
        [resampImage, ~] = imwarp(dcmImage, Rdcm, TFworld, 'Interp', sMode, ...
            'FillValues', dFill);
    end
    
    dimsRsp = size(resampImage);

    if dRefOutputView == true

        if dimsRsp(1)~=dimsRef(1) || ...
           dimsRsp(2)~=dimsRef(2) || ...     
           dimsRsp(3)~=dimsRef(3)

            resampImage = imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'nearest');
%            dimsRsp = size(resampImage);
        end
    end
end

function A = localIntrinsicToWorldAffine(R)
% Row-vector affine mapping intrinsic -> world for axis-aligned imref3d
    sx = R.PixelExtentInWorldX;
    sy = R.PixelExtentInWorldY;
    sz = R.PixelExtentInWorldZ;

    tx = R.XWorldLimits(1) - 0.5*sx;
    ty = R.YWorldLimits(1) - 0.5*sy;
    tz = R.ZWorldLimits(1) - 0.5*sz;

    A = [ sx  0   0   0
          0   sy  0   0
          0   0   sz  0
          tx  ty  tz  1 ];
end
