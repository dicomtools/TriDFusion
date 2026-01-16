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
    

    % DICOM volume spatial reference
    dcmMeta = atDcmMetaData{1};
    origin    = dcmMeta.ImagePositionPatient;     % [x0, y0, z0]
    spacing   = dcmMeta.PixelSpacing;             % [rowSpacing; colSpacing]
    % dimsDcm = [nRows, nCols, nSlices]
    Rdcm = imref3d( dimsDcm, ...
        ... % XWorldLimits along columns uses col‐spacing = spacing(2)
        [ origin(1), origin(1) + (dimsDcm(2)-1) * spacing(2) ], ...
        ... % YWorldLimits along rows uses row‐spacing = spacing(1)
        [ origin(2), origin(2) + (dimsDcm(1)-1) * spacing(1) ], ...
        ... % ZWorldLimits from first‐ to last‐slice center
        [ origin(3), origin(3) + (dimsDcm(3)-1) * dcmSliceThickness ] );
    
    % Reference volume spatial reference
    refMeta    = atRefMetaData{1};
    originRef  = refMeta.ImagePositionPatient;    % [x0, y0, z0]
    spacingRef = refMeta.PixelSpacing;            % [rowSpacing; colSpacing]
    % dimsRef = [nRows, nCols, nSlices]
    Rref = imref3d( dimsRef, ...
        ... % XWorldLimits along columns
        [ originRef(1), originRef(1) + (dimsRef(2)-1) * spacingRef(2) ], ...
        ... % YWorldLimits along rows
        [ originRef(2), originRef(2) + (dimsRef(1)-1) * spacingRef(1) ], ...
        ... % ZWorldLimits from first‐ to last‐slice center
        [ originRef(3), originRef(3) + (dimsRef(3)-1) * refSliceThickness ] );

    if isequal(dimsRef, dimsDcm)

        dTolerance = 1e-5;  % Adjust this value based on the acceptable margin

        % Check if pixel extents are equal within the specified tolerance
        if abs(Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) < dTolerance && ...
           abs(Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) < dTolerance && ...
           abs(Rdcm.PixelExtentInWorldZ - Rref.PixelExtentInWorldZ) < dTolerance

            dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
            dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
    
            deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
            
            if deltaZ_mm < dTolerance

                resampImage = dcmImage;
                return;          
            end
        end
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
    TF = affine3d(f);   % keep this for OutputView==2 branch


    % 
    % % --- DICOM volume spatial reference (FIXED: half-voxel boundaries) ---
    % dcmMeta = atDcmMetaData{1};
    % origin  = double(dcmMeta.ImagePositionPatient(:));  % center of first voxel
    % ps      = double(dcmMeta.PixelSpacing(:));          % [row; col]
    % if numel(ps) < 2 || all(ps==0), ps = [1;1]; end
    % 
    % szDcm = dcmSliceThickness;
    % if isempty(szDcm) || szDcm <= 0, szDcm = 1; end
    % 
    % xlim = [ origin(1) - ps(2)/2, origin(1) + (dimsDcm(2)-1)*ps(2) + ps(2)/2 ];
    % ylim = [ origin(2) - ps(1)/2, origin(2) + (dimsDcm(1)-1)*ps(1) + ps(1)/2 ];
    % zlim = [ origin(3) - szDcm/2, origin(3) + (dimsDcm(3)-1)*szDcm + szDcm/2 ];
    % 
    % Rdcm = imref3d(dimsDcm, xlim, ylim, zlim);
    % 
    % % --- Reference volume spatial reference (FIXED: half-voxel boundaries) ---
    % refMeta = atRefMetaData{1};
    % originR = double(refMeta.ImagePositionPatient(:));
    % psR     = double(refMeta.PixelSpacing(:));
    % if numel(psR) < 2 || all(psR==0), psR = [1;1]; end
    % 
    % szRef = refSliceThickness;
    % if isempty(szRef) || szRef <= 0, szRef = 1; end
    % 
    % xlimR = [ originR(1) - psR(2)/2, originR(1) + (dimsRef(2)-1)*psR(2) + psR(2)/2 ];
    % ylimR = [ originR(2) - psR(1)/2, originR(2) + (dimsRef(1)-1)*psR(1) + psR(1)/2 ];
    % zlimR = [ originR(3) - szRef/2,  originR(3) + (dimsRef(3)-1)*szRef  + szRef/2  ];
    % 
    % Rref = imref3d(dimsRef, xlimR, ylimR, zlimR);
    % 
    % % World version of the same transform (needed if you call imwarp(..., Rdcm, ...))
    % A = localIntrinsicToWorldAffine(Rdcm);
    % Mworld  = (A \ (f * A));        % Adcm*Mworld = f*Adcm
    % TFworld = affine3d(Mworld);
    % 
    % if (round(Rdcm.ImageExtentInWorldX) ~= round(Rref.ImageExtentInWorldX)) || ...
    %    (round(Rdcm.ImageExtentInWorldY) ~= round(Rref.ImageExtentInWorldY))
    %     if dRefOutputView == true
    %         dRefOutputView = 2;
    %     end
    % end

    if isequal(dimsRef, dimsDcm)

        dTolerance = 1e-5;  % Adjust this value based on the acceptable margin

        % Check if pixel extents are equal within the specified tolerance
        if abs(Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) < dTolerance && ...
           abs(Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) < dTolerance && ...
           abs(Rdcm.PixelExtentInWorldZ - Rref.PixelExtentInWorldZ) < dTolerance

            dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
            dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
    
            deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
            
            if deltaZ_mm < dTolerance

                resampImage = dcmImage;
                return;          
            end
        end
    end
    
    if dRefOutputView 
        % Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);
        % 
        % Xlimits = [ atRefMetaData{1}.ImagePositionPatient(1), ...
        %             atRefMetaData{1}.ImagePositionPatient(1) + Rref.ImageExtentInWorldX ];
        % Ylimits = [ atRefMetaData{1}.ImagePositionPatient(2), ...
        %             atRefMetaData{1}.ImagePositionPatient(2) + Rref.ImageExtentInWorldY ];
        % Zlimits = [ atRefMetaData{1}.ImagePositionPatient(3), ...
        %             atRefMetaData{1}.ImagePositionPatient(3) + Rref.ImageExtentInWorldZ ];
        % 
        % Rout = imref3d( dimsRef, ...
        %                Xlimits, ...
        %                Ylimits, ...
        %                Zlimits );
        dxD = double(atDcmMetaData{1}.PixelSpacing(2)); % col spacing
        dyD = double(atDcmMetaData{1}.PixelSpacing(1)); % row spacing
        dzD = sliceSpacingFromIPP(atDcmMetaData);
        
        dxR = double(atRefMetaData{1}.PixelSpacing(2));
        dyR = double(atRefMetaData{1}.PixelSpacing(1));
        dzR = sliceSpacingFromIPP(atRefMetaData);
        
        Rdcm = imref3d(size(dcmImage), ...
            [-dxD/2, (size(dcmImage,2)-0.5)*dxD], ...
            [-dyD/2, (size(dcmImage,1)-0.5)*dyD], ...
            [-dzD/2, (size(dcmImage,3)-0.5)*dzD]);
        
        Rref = imref3d(size(refImage), ...
            [-dxR/2, (size(refImage,2)-0.5)*dxR], ...
            [-dyR/2, (size(refImage,1)-0.5)*dyR], ...
            [-dzR/2, (size(refImage,3)-0.5)*dzR]);
        
        
        % image(mm) -> patient(mm)
        [Rm, tm] = imgAxesToPatient(atDcmMetaData); % moving
        [Rf, tf] = imgAxesToPatient(atRefMetaData); % fixed/ref

        A = (Rm') * Rf;                 % 3x3
        b = (tm - tf)' * Rf;            % 1x3
        
        T = eye(4);
        T(1:3,1:3) = A;                 % NO transpose here
        T(4,1:3)   = b;
                
        % --- Remove Y from the transform in fixed-mm axes:
        % Force y' = y and block any y-coupling into x'/z'
        T(:,2) = [0; 1; 0; 0];   % y' = y, no y-translation, no mixing into y'
        T(2,1) = 0;              % no y -> x'
        T(2,3) = 0;              % no y -> z'
        TF = affine3d(T);

        [resampImage, RB] = imwarp( ...
            dcmImage, Rdcm, TF, ...
            'Interp', sMode, ...
            'FillValues', double(min(dcmImage(:))), ...
            'OutputView', Rref );
        
    else

        dcmMeta = atDcmMetaData{1};
        origin  = double(dcmMeta.ImagePositionPatient(:));
        spacing = double(dcmMeta.PixelSpacing(:));   % [row; col]
        if numel(spacing) < 2 || all(spacing==0), spacing = [1;1]; end

        szDcm = computeSliceSpacing(atDcmMetaData);
        if isempty(szDcm) || ~isfinite(szDcm) || szDcm<=0, szDcm = 1; end

        xlim = [ origin(1) - spacing(2)/2, origin(1) + (dimsDcm(2)-1)*spacing(2) + spacing(2)/2 ];
        ylim = [ origin(2) - spacing(1)/2, origin(2) + (dimsDcm(1)-1)*spacing(1) + spacing(1)/2 ];
        zlim = [ origin(3) - szDcm/2,      origin(3) + max(dimsDcm(3)-1,0)*szDcm + szDcm/2      ];
        Rdcm = imref3d(dimsDcm, xlim, ylim, zlim);

        refMeta    = atRefMetaData{1};
        originRef  = double(refMeta.ImagePositionPatient(:));
        spacingRef = double(refMeta.PixelSpacing(:));
        if numel(spacingRef) < 2 || all(spacingRef==0), spacingRef = [1;1]; end

        szRef = computeSliceSpacing(atRefMetaData);
        if isempty(szRef) || ~isfinite(szRef) || szRef<=0, szRef = 1; end

        xlimRef = [ originRef(1) - spacingRef(2)/2, originRef(1) + (dimsRef(2)-1)*spacingRef(2) + spacingRef(2)/2 ];
        ylimRef = [ originRef(2) - spacingRef(1)/2, originRef(2) + (dimsRef(1)-1)*spacingRef(1) + spacingRef(1)/2 ];
        zlimRef = [ originRef(3) - szRef/2,         originRef(3) + max(dimsRef(3)-1,0)*szRef     + szRef/2         ];
        Rref = imref3d(dimsRef, xlimRef, ylimRef, zlimRef);

        % If X or Y extent differs, your pipeline wants OutputView mode
        if (round(Rdcm.ImageExtentInWorldX) ~= round(Rref.ImageExtentInWorldX)) || ...
                (round(Rdcm.ImageExtentInWorldY) ~= round(Rref.ImageExtentInWorldY))
            if dRefOutputView == true
                dRefOutputView = 2;
            end
        end

        % --- TRUE DICOM-based transform (intrinsic -> intrinsic) ---
        % For single-slice series (SPECT etc.), do NOT try to infer a slice direction from slice #2.
        % Use identity in Z and only scale/translate XY if desired.
        if size(dcmImage,3) < 2 || numel(atDcmMetaData) < 2 || size(refImage,3) < 2 || numel(atRefMetaData) < 2
            Mvox = localIntrinsicXYToIntrinsicXY(atDcmMetaData{1}, atRefMetaData{1}, dimsDcm, dimsRef);
        else
            Mvox = localDicomIntrinsicToIntrinsic(atDcmMetaData, atRefMetaData, szDcm, szRef);
        end

        % If you keep source Z, we must neutralize Z fully (not only M(3,3))
        if dRefOutputView == false
            if localIsNearAxial(dcmMeta) && localIsNearAxial(refMeta)
                Mvox(1:2,3) = 0;
                Mvox(3,1:2) = 0;
                Mvox(3,3)   = 1;
                Mvox(4,3)   = 0;
            end
        end

        % --- Make matrix valid for affine3d (fixes your crash) ---
        Mvox = double(Mvox);

        % Upgrade 3x4 -> 4x4
        if isequal(size(Mvox), [3 4])
            Mvox = [Mvox; 0 0 0 1];
        end

        % If translation is in last column, move to last row
        if isequal(size(Mvox), [4 4]) && any(abs(Mvox(1:3,4)) > 1e-12) && all(abs(Mvox(4,1:3)) < 1e-12)
            t = Mvox(1:3,4).';
            Mvox(1:3,4) = 0;
            Mvox(4,1:3) = t;
        end

        % Enforce affine3d constraint
        Mvox(1:3,4) = 0;
        Mvox(4,4)   = 1;

        % Guard against NaN/Inf
        if any(~isfinite(Mvox(:)))
            Mvox = eye(4);  % safest fallback
        end
        Mvox(:,2) = [0; 1; 0; 0];   % y' = y, no y-translation, no mixing into y'
        Mvox(2,1) = 0;              % no y -> x'
        Mvox(2,3) = 0;              % no y -> z'
        % IMPORTANT: this TF is intrinsic->intrinsic
        TF = affine3d(Mvox);

        dxD = double(atDcmMetaData{1}.PixelSpacing(2)); % col spacing
        dyD = double(atDcmMetaData{1}.PixelSpacing(1)); % row spacing
        dzD = sliceSpacingFromIPP(atDcmMetaData);

        
        Rdcm = imref3d(size(dcmImage), ...
            [-dxD/2, (size(dcmImage,2)-0.5)*dxD], ...
            [-dyD/2, (size(dcmImage,1)-0.5)*dyD], ...
            [-dzD/2, (size(dcmImage,3)-0.5)*dzD]);
        
        [resampImage, RB] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    end
    
    dimsRsp = size(resampImage);
    if dRefOutputView 
        
        if dimsRsp(1)~=dimsRef(1) || ...
           dimsRsp(2)~=dimsRef(2) || ...     
           dimsRsp(3)~=dimsRef(3)

            resampImage = imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'Nearest');
        end
    end

    function dz = sliceSpacingFromIPP(atMeta)
        if numel(atMeta) < 2
            if isfield(atMeta{1},'SpacingBetweenSlices') && atMeta{1}.SpacingBetweenSlices > 0
                dz = double(atMeta{1}.SpacingBetweenSlices);
            elseif isfield(atMeta{1},'SliceThickness') && atMeta{1}.SliceThickness > 0
                dz = double(atMeta{1}.SliceThickness);
            else
                dz = 1;
            end
            return;
        end
        iop = double(atMeta{1}.ImageOrientationPatient(:));
        ei  = iop(1:3); ej = iop(4:6);
        en  = cross(ei, ej); en = en./norm(en);
        p1  = double(atMeta{1}.ImagePositionPatient(:));
        p2  = double(atMeta{2}.ImagePositionPatient(:));
        dz  = abs(dot(p2-p1, en));
        if dz == 0, dz = 1; end
    end
    
    function [R, t] = imgAxesToPatient(atMeta)
        m1  = atMeta{1};
        iop = double(m1.ImageOrientationPatient(:));
    
        ei = iop(1:3); ei = ei./norm(ei);  % +columns
        ej = iop(4:6); ej = ej./norm(ej);  % +rows
        en = cross(ei, ej); en = en./norm(en);
    
        % Make en follow acquisition direction when possible
        if numel(atMeta) >= 2
            p1 = double(atMeta{1}.ImagePositionPatient(:));
            p2 = double(atMeta{2}.ImagePositionPatient(:));
            if dot(p2-p1, en) < 0
                en = -en;
            end

        else
            if isImageFlipped(atMeta{1})
                en = -en;
            end    
        end
    
        R = [ei, ej, en];                  % patient = t + R*[x;y;z]  (x,y,z in image-mm axes)
        t = double(m1.ImagePositionPatient(:));
    end
    
    function tf = localIsNearAxial(meta)
        iop = double(meta.ImageOrientationPatient(:));
        row = iop(1:3); col = iop(4:6);
        n = cross(row, col); n = n ./ (norm(n)+eps);
        % near patient Z axis
        tf = abs(abs(n(3)) - 1) < 1e-3;
    end
    
    function M = localDicomIntrinsicToIntrinsic(atSrc, atRef, szSrcFallback, szRefFallback)
    % Returns M such that: [c r s 1] * M = [c' r' s' 1]
    % Mapping is derived from DICOM IPP/IOP + spacing (handles CTDX tilt/rotation).
    
        As = localIntrinsicToPatientRowAffine(atSrc, szSrcFallback);
        Ar = localIntrinsicToPatientRowAffine(atRef, szRefFallback);
    
        % patient = srcIntrinsic * As
        % patient = refIntrinsic * Ar
        % => refIntrinsic = srcIntrinsic * As / Ar
        M = As / Ar;
    end
    
    function A = localIntrinsicToPatientRowAffine(atMetaData, szFallback)
    % Row-vector affine: [c r s 1] * A = [x y z 1] in patient coords (mm)
    % Uses: IPP (slice1), IOP, PixelSpacing, and slice direction from IPP2-IPP1 when available.
    
        m1 = atMetaData{1};
    
        ipp1 = double(m1.ImagePositionPatient(:));
        iop  = double(m1.ImageOrientationPatient(:));
        rowDir = iop(1:3); colDir = iop(4:6);
    
        ps = double(m1.PixelSpacing(:)); % [row; col]
        if numel(ps)<2 || all(ps==0), ps = [1;1]; end
        rowSp = ps(1);
        colSp = ps(2);
    
        % Slice direction/spacing
        sliceSp = szFallback;
        sliceDir = cross(rowDir, colDir);
        sliceDir = sliceDir ./ (norm(sliceDir)+eps);
    
        if numel(atMetaData) >= 2
            ipp2 = double(atMetaData{2}.ImagePositionPatient(:));
            v = ipp2 - ipp1;
            nv = norm(v);
            if isfinite(nv) && nv > 0
                sliceSp = nv;
                sliceDir = v ./ nv;  % handles gantry tilt / oblique
            end
        end
        if isempty(sliceSp) || sliceSp <= 0, sliceSp = 1; end
    
        % We want: patient = ipp1 + (c-1)*colDir*colSp + (r-1)*rowDir*rowSp + (s-1)*sliceDir*sliceSp
        % Put into [c r s 1] * A form:
        t = ipp1(:)' - (colDir(:)'*colSp + rowDir(:)'*rowSp + sliceDir(:)'*sliceSp);
    
        A = [ colDir(:)'*colSp, 0
              rowDir(:)'*rowSp, 0
              sliceDir(:)'*sliceSp, 0
              t, 1 ];
    end
    function M = localIntrinsicXYToIntrinsicXY(srcMeta, refMeta, dimsSrc, dimsRef)
    % Simple intrinsic XY mapping (scale + translate) when Z direction is undefined (single-slice).
    % Uses pixel spacing ratio and centers.
        psS = double(srcMeta.PixelSpacing(:)); if numel(psS)<2 || all(psS==0), psS=[1;1]; end
        psR = double(refMeta.PixelSpacing(:)); if numel(psR)<2 || all(psR==0), psR=[1;1]; end
    
        sx = psS(2)/psR(2);  % col spacing ratio
        sy = psS(1)/psR(1);  % row spacing ratio
    
        % map source center to ref center
        cS = (dimsSrc(2)+1)/2; rS = (dimsSrc(1)+1)/2;
        cR = (dimsRef(2)+1)/2; rR = (dimsRef(1)+1)/2;
    
        tx = cR - sx*cS;
        ty = rR - sy*rS;
    
        M = [ sx  0   0   0
              0   sy  0   0
              0   0   1   0
              tx  ty  0   1 ];
    end

end

