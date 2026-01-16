function [resampImage, atDcmMetaData, xMoveOffset, yMoveOffset, zMoveOffsetRemaining] = resampleImageTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, bSameOutput)
%function [resampImage, atDcmMetaData, xMoveOffset, yMoveOffset, zMoveOffsetRemaining] = resampleImageTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, bSameOutput)
%Resample any modalities using a transfer matrix.
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
    
    xMoveOffset = [];
    yMoveOffset = [];
    zMoveOffsetRemaining = [];

    dimsRef = size(refImage);        
    dimsDcm = size(dcmImage);


    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);       
    
    if dcmSliceThickness == 1 && refSliceThickness == 1
        resampImage = dcmImage;
        return;
    end

    if dcmSliceThickness == 0 || refSliceThickness == 0
        resampImage = dcmImage;
        return;
    end


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

    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);







% % % % % if 0
% % % % %     % % DICOM volume spatial reference
% % % % %         % Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
% % % % %         % Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);
% % % % %         % 
% % % % %         % % DICOM volume spatial reference
% % % % %         % dcmMeta   = atDcmMetaData{1};
% % % % %         % origin    = dcmMeta.ImagePositionPatient;     % [x0, y0, z0]
% % % % %         % spacing   = dcmMeta.PixelSpacing;             % [rowSpacing; colSpacing]
% % % % %         % % dimsDcm = [nRows, nCols, nSlices]
% % % % %         % Rdcm = imref3d( dimsDcm, ...
% % % % %         %     ... % XWorldLimits along columns uses col‐spacing = spacing(2)
% % % % %         %     [ origin(1), origin(1) + (dimsDcm(2)) * spacing(2) ], ...
% % % % %         %     ... % YWorldLimits along rows uses row‐spacing = spacing(1)
% % % % %         %     [ origin(2), origin(2) + (dimsDcm(1)) * spacing(1) ], ...
% % % % %         %     ... % ZWorldLimits from first‐ to last‐slice center
% % % % %         %     [ origin(3), origin(3) + (dimsDcm(3)) * dcmSliceThickness ] );
% % % % %         % 
% % % % %         % % Reference volume spatial reference
% % % % %         % refMeta    = atRefMetaData{1};
% % % % %         % originRef  = refMeta.ImagePositionPatient;    % [x0, y0, z0]
% % % % %         % spacingRef = refMeta.PixelSpacing;            % [rowSpacing; colSpacing]
% % % % %         % % dimsRef = [nRows, nCols, nSlices]
% % % % %         % Rref = imref3d( dimsRef, ...
% % % % %         %     ... % XWorldLimits along columns
% % % % %         %     [ originRef(1), originRef(1) + (dimsRef(2)) * spacingRef(2) ], ...
% % % % %         %     ... % YWorldLimits along rows
% % % % %         %     [ originRef(2), originRef(2) + (dimsRef(1)) * spacingRef(1) ], ...
% % % % %         %     ... % ZWorldLimits from first‐ to last‐slice center
% % % % %         %     [ originRef(3), originRef(3) + (dimsRef(3)) * refSliceThickness ] );
% % % % %         % 
% % % % % 
% % % % %     % --- DICOM volume spatial reference (used for metadata / extents) ---
% % % % %     dcmMeta = atDcmMetaData{1};
% % % % %     origin  = double(dcmMeta.ImagePositionPatient(:));
% % % % %     spacing = double(dcmMeta.PixelSpacing(:));   % [row; col]
% % % % %     if numel(spacing) < 2 || all(spacing==0), spacing = [1;1]; end
% % % % % 
% % % % %     szDcm = computeSliceSpacing(atDcmMetaData);
% % % % %     if isempty(szDcm) || ~isfinite(szDcm) || szDcm<=0, szDcm = 1; end
% % % % % 
% % % % %     xlim = [ origin(1) - spacing(2)/2, origin(1) + (dimsDcm(2)-1)*spacing(2) + spacing(2)/2 ];
% % % % %     ylim = [ origin(2) - spacing(1)/2, origin(2) + (dimsDcm(1)-1)*spacing(1) + spacing(1)/2 ];
% % % % %     zlim = [ origin(3) - szDcm/2,      origin(3) + max(dimsDcm(3)-1,0)*szDcm + szDcm/2      ];
% % % % %     Rdcm = imref3d(dimsDcm, xlim, ylim, zlim);
% % % % % 
% % % % %     refMeta    = atRefMetaData{1};
% % % % %     originRef  = double(refMeta.ImagePositionPatient(:));
% % % % %     spacingRef = double(refMeta.PixelSpacing(:));
% % % % %     if numel(spacingRef) < 2 || all(spacingRef==0), spacingRef = [1;1]; end
% % % % % 
% % % % %     szRef = computeSliceSpacing(atRefMetaData);
% % % % %     if isempty(szRef) || ~isfinite(szRef) || szRef<=0, szRef = 1; end
% % % % % 
% % % % %     xlimRef = [ originRef(1) - spacingRef(2)/2, originRef(1) + (dimsRef(2)-1)*spacingRef(2) + spacingRef(2)/2 ];
% % % % %     ylimRef = [ originRef(2) - spacingRef(1)/2, originRef(2) + (dimsRef(1)-1)*spacingRef(1) + spacingRef(1)/2 ];
% % % % %     zlimRef = [ originRef(3) - szRef/2,         originRef(3) + max(dimsRef(3)-1,0)*szRef     + szRef/2         ];
% % % % %     Rref = imref3d(dimsRef, xlimRef, ylimRef, zlimRef);
% % % % % 
% % % % %     if isequal(dimsRef, dimsDcm)
% % % % % 
% % % % %         dTolerance = 1e-5;  % Adjust this value based on the acceptable margin
% % % % % 
% % % % %         % Check if pixel extents are equal within the specified tolerance
% % % % %         if abs(Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) < dTolerance && ...
% % % % %            abs(Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) < dTolerance && ...
% % % % %            abs(Rdcm.PixelExtentInWorldZ - Rref.PixelExtentInWorldZ) < dTolerance
% % % % % 
% % % % %             dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
% % % % %             dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
% % % % % 
% % % % %             deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
% % % % % 
% % % % %             if deltaZ_mm < dTolerance
% % % % % 
% % % % %                 resampImage = dcmImage;
% % % % %                 return;          
% % % % %             end
% % % % %         end
% % % % %     end
% % % % % 
% % % % %     [M, R] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
% % % % %     TF = affine3d(M);
% % % % % 
% % % % %     if bSameOutput == true
% % % % %         % 
% % % % %         % [resampImage, RB] = imwarp( ...
% % % % %         %    dcmImage, TF, ...
% % % % %         %    'Interp',     sMode, ...
% % % % %         %    'FillValues', double(min(dcmImage(:))), ...
% % % % %         %    'OutputView', Rref );
% % % % % 
% % % % %             % dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
% % % % %             % dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
% % % % %             % 
% % % % %             % deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
% % % % %             % T = eye(4);
% % % % %             % T(4,3) = deltaZ_mm;
% % % % %             % TF = affine3d(T);
% % % % % % 
% % % % % % dx = mean(Rref.XWorldLimits) - mean(Rdcm.XWorldLimits);   % +0.8944
% % % % % % dy = mean(Rref.YWorldLimits) - mean(Rdcm.YWorldLimits);   % -11.8537
% % % % % % dz = mean(Rref.ZWorldLimits) - mean(Rdcm.ZWorldLimits);   % +16.0615  <-- keep this, NOT -14.15
% % % % % % 
% % % % % % T = eye(4);
% % % % % % T(4,1:3) = [dx dy dz];
% % % % % % TF = affine3d(T);
% % % % % % 
% % % % % % [resampImage, RB] = imwarp( ...
% % % % % %     dcmImage, Rdcm, TF, ...
% % % % % %     'Interp',    sMode, ...
% % % % % %     'FillValues',double(min(dcmImage(:))), ...
% % % % % %     'OutputView',Rref );
% % % % %     dxD = double(atDcmMetaData{1}.PixelSpacing(2)); % col spacing
% % % % %     dyD = double(atDcmMetaData{1}.PixelSpacing(1)); % row spacing
% % % % %     dzD = sliceSpacingFromIPP(atDcmMetaData);
% % % % % 
% % % % %     dxR = double(atRefMetaData{1}.PixelSpacing(2));
% % % % %     dyR = double(atRefMetaData{1}.PixelSpacing(1));
% % % % %     dzR = sliceSpacingFromIPP(atRefMetaData);
% % % % % 
% % % % %     Rdcm = imref3d(size(dcmImage), ...
% % % % %         [-dxD/2, (size(dcmImage,2)-0.5)*dxD], ...
% % % % %         [-dyD/2, (size(dcmImage,1)-0.5)*dyD], ...
% % % % %         [-dzD/2, (size(dcmImage,3)-0.5)*dzD]);
% % % % % 
% % % % %     Rref = imref3d(size(refImage), ...
% % % % %         [-dxR/2, (size(refImage,2)-0.5)*dxR], ...
% % % % %         [-dyR/2, (size(refImage,1)-0.5)*dyR], ...
% % % % %         [-dzR/2, (size(refImage,3)-0.5)*dzR]);
% % % % % 
% % % % % 
% % % % %     % image(mm) -> patient(mm)
% % % % %     [Rm, tm] = imgAxesToPatient(atDcmMetaData); % moving
% % % % %     [Rf, tf] = imgAxesToPatient(atRefMetaData); % fixed/ref
% % % % % 
% % % % %     A = (Rm') * Rf;                 % 3x3
% % % % %     b = (tm - tf)' * Rf;            % 1x3
% % % % % 
% % % % %     T = eye(4);
% % % % %     T(1:3,1:3) = A;                 % NO transpose here
% % % % %     T(4,1:3)   = b;
% % % % % 
% % % % %     TF = affine3d(T);
% % % % % 
% % % % %     [resampImage, RB] = imwarp( ...
% % % % %         dcmImage, Rdcm, TF, ...
% % % % %         'Interp', sMode, ...
% % % % %         'FillValues', double(min(dcmImage(:))), ...
% % % % %         'OutputView', Rref );
% % % % % 
% % % % % 
% % % % %     else
% % % % %         [resampImage, RB] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
% % % % %     end
% % % % % %        if dimsRef(3)==dimsDcm(3)
% % % % % %            aResampledImageSize = size(resampImage);
% % % % % %            resampImage=imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)]);
% % % % % %        end
% % % % % 
% % % % % 
% % % % %  %test   end
% % % % % 
% % % % %     dimsRsp = size(resampImage);
% % % % % 
% % % % %     if numel(atDcmMetaData) ~= 1
% % % % % 
% % % % %         if dimsRsp(3) < numel(atDcmMetaData)
% % % % %             atDcmMetaData = atDcmMetaData(1:dimsRsp(3)); % Remove excess slices
% % % % %         else
% % % % %             for cc = 1:(dimsRsp(3) - numel(atDcmMetaData))
% % % % %                 atDcmMetaData{end+1} = atDcmMetaData{end}; % Add missing slice
% % % % %             end
% % % % %         end
% % % % %     end
% % % % % 
% % % % %     % Update metadata entries based on spatial reference
% % % % %     for jj = 1:numel(atDcmMetaData)
% % % % % 
% % % % %         if numel(atRefMetaData) == numel(atDcmMetaData)
% % % % %             refMeta = atRefMetaData{jj};
% % % % %         else
% % % % %             refMeta = atRefMetaData{1};
% % % % %         end
% % % % % 
% % % % %         % atDcmMetaData{jj}.ImageOrientationPatient = ref.ImageOrientationPatient;
% % % % %         atDcmMetaData{jj}.PixelSpacing           = refMeta.PixelSpacing;
% % % % %         atDcmMetaData{jj}.Rows                   = dimsRef(1);
% % % % %         atDcmMetaData{jj}.Columns                = dimsRef(2);
% % % % %         atDcmMetaData{jj}.SpacingBetweenSlices   = RB.PixelExtentInWorldZ;
% % % % %         atDcmMetaData{jj}.SliceThickness         = RB.PixelExtentInWorldZ;
% % % % %         % atDcmMetaData{jj}.SpacingBetweenSlices   = refMeta.SpacingBetweenSlices;
% % % % %         % atDcmMetaData{jj}.SliceThickness         = refMeta.SliceThickness;        
% % % % %         atDcmMetaData{jj}.InstanceNumber         = jj;
% % % % %         atDcmMetaData{jj}.NumberOfSlices         = dimsRef(3);
% % % % % 
% % % % %         % % % Compute X/Y origin differently for the OutputView case
% % % % %         % if bSameOutput == true
% % % % %         % 
% % % % %         %     shiftX = (Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) / 2;
% % % % %         %     shiftY = (Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) / 2;
% % % % %         % 
% % % % %         %     % Apply to the reference ImagePositionPatient:
% % % % %         %     origIPP = refMeta.ImagePositionPatient;
% % % % %         %     x0      = origIPP(1) - shiftX;
% % % % %         %     y0      = origIPP(2) - shiftY;
% % % % %         % 
% % % % %         % else
% % % % % 
% % % % %             % Center original volume in-plane using half-pixel world-offsets
% % % % %             % Reference origin and spacing
% % % % %             origIPP     = atRefMetaData{1}.ImagePositionPatient;  % [x; y; z]
% % % % %             origSpacing = atRefMetaData{1}.PixelSpacing;          % [row; col]
% % % % % 
% % % % % 
% % % % %             % Compute world-coordinate of the reference grid’s center:
% % % % %             centerX = origIPP(1) + ((dimsRef(2)-1) * origSpacing(2)) / 2;  % along cols
% % % % %             centerY = origIPP(2) + ((dimsRef(1)-1) * origSpacing(1)) / 2;  % along rows
% % % % % 
% % % % %             % Get the **actual** spacing of your resampled image:
% % % % %             newSpacing = atDcmMetaData{jj}.PixelSpacing;  % [row; col]
% % % % % 
% % % % %             % Compute half-extent of the resampled grid in world-units:
% % % % %             halfX = ((dimsRsp(2)-1) * newSpacing(2)) / 2;  % along cols
% % % % %             halfY = ((dimsRsp(1)-1) * newSpacing(1)) / 2;  % along rows
% % % % % 
% % % % %             % Subtract half-extent and then add half a pixel (in mm) to land on the center
% % % % %             x0 = centerX - halfX + newSpacing(2)/2;
% % % % %             y0 = centerY - halfY + newSpacing(1)/2;
% % % % %         % end
% % % % % 
% % % % %         atDcmMetaData{jj}.ImagePositionPatient(1) = x0;
% % % % %         atDcmMetaData{jj}.ImagePositionPatient(2) = y0;
% % % % %     end
% % % % % 
% % % % %     computedSliceThickness = refSliceThickness;
% % % % % 
% % % % %      % Align first-slice Z per DICOM when using OutputView
% % % % %     if bSameOutput == true && dimsRsp(3) ~= dimsDcm(3)
% % % % % 
% % % % %         % Compute slice-normal vector
% % % % %         iop     = atRefMetaData{1}.ImageOrientationPatient;
% % % % %         rowOri  = iop(1:3);
% % % % %         colOri  = iop(4:6);
% % % % %         normOri = cross(rowOri, colOri);
% % % % % 
% % % % %         % Determine Z discrepancy
% % % % %         refZ    = atRefMetaData{1}.ImagePositionPatient(3);
% % % % %         origZ   = atDcmMetaData{1}.ImagePositionPatient(3);
% % % % %         deltaZ  = refZ - origZ;
% % % % % 
% % % % %         % Adjust if discrepancy aligns with acquisition direction
% % % % %         if deltaZ * normOri(3) < 0
% % % % %             atDcmMetaData{1}.ImagePositionPatient(3) = origZ - deltaZ;
% % % % %             atDcmMetaData{1}.SliceLocation           = atDcmMetaData{1}.SliceLocation - deltaZ;
% % % % %         end
% % % % %     end
% % % % % 
% % % % %     % Update slice positions along Z
% % % % %     for cc = 1:(numel(atDcmMetaData) - 1)
% % % % %         if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
% % % % %             atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + computedSliceThickness;
% % % % %             atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation + computedSliceThickness;
% % % % %         else
% % % % %             atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - computedSliceThickness;
% % % % %             atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation - computedSliceThickness;
% % % % %         end
% % % % %     end   
% % % % % else
    
    if bSameOutput
        
        % dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
        % dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
        % 
        % deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
        % T = eye(4);
        % T(4,3) = deltaZ_mm;
        % TF = affine3d(T);
        % 
        % [resampImage, RB] = imwarp( ...
        %     dcmImage, Rdcm, TF, ...
        %     'Interp',    sMode, ...
        %     'FillValues',double(min(dcmImage(:))), ...
        %     'OutputView',Rref ...
        % );
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
        [Rm, tm, ~] = imgAxesToPatient(atDcmMetaData); % moving
        [Rf, tf, ~] = imgAxesToPatient(atRefMetaData); % fixed/ref
        
        A = (Rm') * Rf;                 % 3x3
        b = (tm - tf)' * Rf;            % 1x3
        
        T = eye(4);
        T(1:3,1:3) = A;                 % NO transpose here
        T(4,1:3)   = b;
        
        TF = affine3d(T);
        
    
    
    
            % dxD = double(atDcmMetaData{1}.PixelSpacing(2)); % col spacing
            % dyD = double(atDcmMetaData{1}.PixelSpacing(1)); % row spacing
            % dzD = sliceSpacingFromIPP(atDcmMetaData);
            % 
            % dxR = double(atRefMetaData{1}.PixelSpacing(2));
            % dyR = double(atRefMetaData{1}.PixelSpacing(1));
            % dzR = sliceSpacingFromIPP(atRefMetaData);
            % 
            % Rdcm = imref3d(size(dcmImage), ...
            %     [-dxD/2, (size(dcmImage,2)-0.5)*dxD], ...
            %     [-dyD/2, (size(dcmImage,1)-0.5)*dyD], ...
            %     [-dzD/2, (size(dcmImage,3)-0.5)*dzD]);
            % 
            % Rref = imref3d(size(refImage), ...
            %     [-dxR/2, (size(refImage,2)-0.5)*dxR], ...
            %     [-dyR/2, (size(refImage,1)-0.5)*dyR], ...
            %     [-dzR/2, (size(refImage,3)-0.5)*dzR]);
            % 
            % 
            % % image(mm) -> patient(mm)
            % [Rm, tm] = imgAxesToPatient(atDcmMetaData); % moving
            % [Rf, tf] = imgAxesToPatient(atRefMetaData); % fixed/ref
            % 
            % A = (Rm') * Rf;                 % 3x3
            % b = (tm - tf)' * Rf;            % 1x3
            % 
            % T = eye(4);
            % T(1:3,1:3) = A;                 % NO transpose here
            % T(4,1:3)   = b;
            % 
            % TF = affine3d(T);
    
    
    
    
        [resampImage, RB] = imwarp( ...
            dcmImage, Rdcm, TF, ...
            'Interp', sMode, ...
            'FillValues', double(min(dcmImage(:))), ...
            'OutputView', Rref );


        % if bFlippped
        %     resampImage = resampImage(:,:,end:-1:1);
        % end

%        [resampImage, RB] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef)); 
    else  

        dxD = double(atDcmMetaData{1}.PixelSpacing(2)); % col spacing
        dyD = double(atDcmMetaData{1}.PixelSpacing(1)); % row spacing
        dzD = sliceSpacingFromIPP(atDcmMetaData);
        
        Rdcm = imref3d(size(dcmImage), ...
            [-dxD/2, (size(dcmImage,2)-0.5)*dxD], ...
            [-dyD/2, (size(dcmImage,1)-0.5)*dyD], ...
            [-dzD/2, (size(dcmImage,3)-0.5)*dzD]);
        

        [resampImage, RB] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    
    end
% end
    
    % fprintf("dz_in=%.4f  dz_ref=%.4f\n", RB.PixelExtentInWorldZ, Rref.PixelExtentInWorldZ);
    % fprintf("zIn range:  [%.2f, %.2f]\n", RB.ZWorldLimits(1), RB.ZWorldLimits(2));
    % fprintf("zRef range: [%.2f, %.2f]\n", Rref.ZWorldLimits(1), Rref.ZWorldLimits(2));
    % 


    dimsRsp = size(resampImage);
    if bSameOutput 
        
        if dimsRsp(1)~=dimsRef(1) || ...
           dimsRsp(2)~=dimsRef(2) || ...     
           dimsRsp(3)~=dimsRef(3)

            resampImage = imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'Nearest');
            dimsRsp = size(resampImage);
        end
    end
    % if dRefOutputView == true
    % 
    %     if dimsRsp(1)~=dimsRef(1) || ...
    %        dimsRsp(2)~=dimsRef(2) || ...     
    %        dimsRsp(3)~=dimsRef(3)
    % 
    %         resampImage = imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'Nearest');
    %         dimsRsp = size(resampImage);
    %     end
    % end

    if numel(atDcmMetaData) ~= 1

        if dimsRsp(3) < numel(atDcmMetaData)

            atDcmMetaData = atDcmMetaData(1:dimsRsp(3)); % Remove excess slices
        else
            for cc = 1:(dimsRsp(3) - numel(atDcmMetaData))
                atDcmMetaData{end+1} = atDcmMetaData{end}; % Add missing slice
            end
        end
    end

    % Update metadata entries based on spatial reference
    for jj = 1:numel(atDcmMetaData)

        if numel(atRefMetaData) == numel(atDcmMetaData)
            refMeta = atRefMetaData{jj};
        else
            refMeta = atRefMetaData{1};
        end

        % atDcmMetaData{jj}.ImageOrientationPatient = ref.ImageOrientationPatient;
        atDcmMetaData{jj}.PixelSpacing           = refMeta.PixelSpacing;
        atDcmMetaData{jj}.Rows                   = dimsRsp(1);
        atDcmMetaData{jj}.Columns                = dimsRsp(2);
        atDcmMetaData{jj}.SpacingBetweenSlices   = RB.PixelExtentInWorldZ;
        atDcmMetaData{jj}.SliceThickness         = RB.PixelExtentInWorldZ;
        atDcmMetaData{jj}.InstanceNumber         = jj;
        atDcmMetaData{jj}.NumberOfSlices         = dimsRsp(3);

        % % % Compute X/Y origin differently for the OutputView case
        % if dRefOutputView == 2
        % 
        %     shiftX = (Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) / 2;
        %     shiftY = (Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) / 2;
        % 
        %     % Apply to the reference ImagePositionPatient:
        %     origIPP = refMeta.ImagePositionPatient;
        %     x0      = origIPP(1) - shiftX;
        %     y0      = origIPP(2) - shiftY;
        % 
        % else

            % Center original volume in-plane using half-pixel world-offsets
            % Reference origin and spacing
            origIPP     = atRefMetaData{1}.ImagePositionPatient;  % [x; y; z]
            origSpacing = atRefMetaData{1}.PixelSpacing;          % [row; col]


            % Compute world-coordinate of the reference grid’s center:
            centerX = origIPP(1) + ((dimsRef(2)-1) * origSpacing(2)) / 2;  % along cols
            centerY = origIPP(2) + ((dimsRef(1)-1) * origSpacing(1)) / 2;  % along rows

            % Get the **actual** spacing of your resampled image:
            newSpacing = atDcmMetaData{jj}.PixelSpacing;  % [row; col]

            % Compute half-extent of the resampled grid in world-units:
            halfX = ((dimsRsp(2)-1) * newSpacing(2)) / 2;  % along cols
            halfY = ((dimsRsp(1)-1) * newSpacing(1)) / 2;  % along rows

            % Subtract half-extent and then add half a pixel (in mm) to land on the center
            x0 = centerX - halfX + newSpacing(2)/2;
            y0 = centerY - halfY + newSpacing(1)/2;
        % end

        atDcmMetaData{jj}.ImagePositionPatient(1) = x0;
        atDcmMetaData{jj}.ImagePositionPatient(2) = y0;

    end

    computedSliceThickness = RB.PixelExtentInWorldZ;

     % Align first-slice Z per DICOM when using OutputView
    if bSameOutput && dimsRsp(3) ~= dimsDcm(3)

        % Compute slice-normal vector
        iop     = atRefMetaData{1}.ImageOrientationPatient;
        rowOri  = iop(1:3);
        colOri  = iop(4:6);
        normOri = cross(rowOri, colOri);

        % Determine Z discrepancy
        refZ    = atRefMetaData{1}.ImagePositionPatient(3);
        origZ   = atDcmMetaData{1}.ImagePositionPatient(3);
        deltaZ  = refZ - origZ;

        % Adjust if discrepancy aligns with acquisition direction
        if deltaZ * normOri(3) < 0
            atDcmMetaData{1}.ImagePositionPatient(3) = origZ - deltaZ;
            atDcmMetaData{1}.SliceLocation           = atDcmMetaData{1}.SliceLocation - deltaZ;
        end
    end

    % Update slice positions along Z
    for cc = 1:(numel(atDcmMetaData) - 1)
        if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + computedSliceThickness;
            atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation + computedSliceThickness;
        else
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - computedSliceThickness;
            atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation - computedSliceThickness;
        end
    end

    aRspSize = size(resampImage);

    if strcmpi(atDcmMetaData{1}.StudyInstanceUID, atRefMetaData{1}.StudyInstanceUID) && ... % Same study         
       bSameOutput == false

        if aRspSize(3) ~= dimsRef(3) % Fix for z offset

            if aRspSize(3) > dimsRef(3)

                [dDcmFirstZ, dDcmLastZ] = getImageZPosition(atDcmMetaData, dcmImage);
                [dRefFirstZ, dRefLastZ] = getImageZPosition(atRefMetaData, refImage);

                dFirstOffset = abs(dRefFirstZ - dDcmFirstZ)/refSliceThickness;
%                 dLastOffset = abs(dRefLastZ - dDcmLastZ)/refSliceThickness;


                dImageOffset = round(dFirstOffset);
                zMoveOffsetRemaining = dFirstOffset-dImageOffset;


                resampImage = resampImage(:,:,1+dImageOffset:aRspSize(3));

%                 dOffset = (dRefPosition - dDcmPosition)
%%%%%%% TEMP PATH, NEED TO REVISIT
%                 if dFirstOffset > dLastOffset
%              
%                     resampImage = resampImage(:,:,1+aRspSize(3)-dimsRef(3):end);
%                 else
%            %       resampImage = resampImage(:,:,round(dFirstOffset):aRspSize(3)-(aRspSize(3)-dimsRef(3)) );
%                     resampImage = resampImage(:,:,1:aRspSize(3)-(aRspSize(3)-dimsRef(3)));
%                 end
           else
                aResample = single(zeros(aRspSize(1), aRspSize(2), dimsRef(3)));
                aResample(:,:,:) = min(resampImage, [], 'all');

                [dDcmFirstZ, dDcmLastZ] = getImageZPosition(atDcmMetaData, dcmImage);
                [dRefFirstZ, dRefLastZ] = getImageZPosition(atRefMetaData, refImage);

                dFirstOffset = abs(dRefFirstZ - dDcmFirstZ)/refSliceThickness;
%                 dLastOffset = abs(dRefLastZ - dDcmLastZ)/refSliceThickness;
%                 dOffset = (dRefPosition - dDcmPosition)

                dImageOffset = round(dFirstOffset);
                zMoveOffsetRemaining = dFirstOffset-dImageOffset;

                aResample(:,:,1+dImageOffset:aRspSize(3)+dImageOffset)=resampImage;

%%%%%%% TEMP PATH, NEED TO REVISIT
%                 if dFirstOffset > dLastOffset
%                     aResample(:,:,1+dimsRef(3)-aRspSize(3):end)=resampImage;
%                 else
%                     aResample(:,:,1:dimsRef(3)-(dimsRef(3)-aRspSize(3)))=resampImage;
%                 end

                resampImage = aResample;
                clear aResample;
            end
        else

            [dDcmFirstZ, ~] = getImageZPosition(atDcmMetaData, dcmImage);
            [dRefFirstZ, ~] = getImageZPosition(atRefMetaData, refImage);

            dFirstOffset = (dRefFirstZ - dDcmFirstZ) / refSliceThickness;
            dImageOffset = round(dFirstOffset);
            zMoveOffsetRemaining = dFirstOffset - dImageOffset;

            if dImageOffset ~= 0
                % Create a buffer and roll the data by dImageOffset slices
                aShifted = single(zeros(aRspSize(1), aRspSize(2), dimsRef(3)));
                if dImageOffset > 0
                    % pad at front, drop at back
                    aShifted(:,:,1 + dImageOffset : end) = resampImage(:,:,1 : end - dImageOffset);
                else
                    % pad at back, drop at front
                    off = abs(dImageOffset);
                    aShifted(:,:,1 : end - off) = resampImage(:,:,1 + off : end);
                end
                resampImage = aShifted;
                clear aShifted;
            end             
        end
    end

    % if strcmpi(atDcmMetaData{1}.StudyInstanceUID, atRefMetaData{1}.StudyInstanceUID) && ~bSameOutput
    % 
    %     Nz_out = dimsRef(3);
    %     Nz_in  = aRspSize(3);
    % 
    %     % --- Signed offset in slices ---
    %     % Best: compute along slice-normal, not "patient Z".
    %     iop = double(atRefMetaData{1}.ImageOrientationPatient(:));
    %     ei  = iop(1:3); ej = iop(4:6);
    %     en  = cross(ei, ej); en = en./norm(en);
    % 
    %     sRef0 = dot(double(atRefMetaData{1}.ImagePositionPatient(:)), en);
    % 
    %     % IMPORTANT: use the *original* moving metadata for the moving start, not the already-modified atDcmMetaData.
    %     % If you still have it, use atDcmMetaDataOriginal{1} here.
    %     sDcm0 = dot(double(atDcmMetaData{1}.ImagePositionPatient(:)), en);
    % 
    %     dFirstOffset = (sRef0 - sDcm0) / refSliceThickness;  % signed
    %     dImageOffset = round(dFirstOffset);
    %     zMoveOffsetRemaining = dFirstOffset - dImageOffset;
    % 
    %     % --- Shift volume into reference-sized buffer ---
    %     fillVal = cast(min(resampImage(:)), 'like', resampImage);
    %     out = fillVal * ones(aRspSize(1), aRspSize(2), Nz_out, 'like', resampImage);
    % 
    %     % Map input slice k -> output slice k + dImageOffset
    %     srcStart = max(1, 1 - dImageOffset);
    %     srcEnd   = min(Nz_in, Nz_out - dImageOffset);
    % 
    %     if srcEnd >= srcStart
    %         dstStart = srcStart + dImageOffset;
    %         dstEnd   = srcEnd   + dImageOffset;
    %         out(:,:,dstStart:dstEnd) = resampImage(:,:,srcStart:srcEnd);
    %     end
    % 
    %     resampImage = out;    
    %     clear out;
    % end

    % % % % % % function dz = sliceSpacingFromIPP(atMeta)
    % % % % % %     if numel(atMeta) < 2
    % % % % % %         if isfield(atMeta{1},'SpacingBetweenSlices') && atMeta{1}.SpacingBetweenSlices > 0
    % % % % % %             dz = double(atMeta{1}.SpacingBetweenSlices);
    % % % % % %         elseif isfield(atMeta{1},'SliceThickness') && atMeta{1}.SliceThickness > 0
    % % % % % %             dz = double(atMeta{1}.SliceThickness);
    % % % % % %         else
    % % % % % %             dz = 1;
    % % % % % %         end
    % % % % % %         return;
    % % % % % %     end
    % % % % % %     iop = double(atMeta{1}.ImageOrientationPatient(:));
    % % % % % %     ei  = iop(1:3); ej = iop(4:6);
    % % % % % %     en  = cross(ei, ej); en = en./norm(en);
    % % % % % %     p1  = double(atMeta{1}.ImagePositionPatient(:));
    % % % % % %     p2  = double(atMeta{2}.ImagePositionPatient(:));
    % % % % % %     dz  = abs(dot(p2-p1, en));
    % % % % % %     if dz == 0, dz = 1; end
    % % % % % % end
    % % % % % % 
    % % % % % % function [R, t] = imgAxesToPatient(atMeta)
    % % % % % %     m1  = atMeta{1};
    % % % % % %     iop = double(m1.ImageOrientationPatient(:));
    % % % % % % 
    % % % % % %     ei = iop(1:3); ei = ei./norm(ei);  % +columns
    % % % % % %     ej = iop(4:6); ej = ej./norm(ej);  % +rows
    % % % % % %     en = cross(ei, ej); en = en./norm(en);
    % % % % % % 
    % % % % % %     % Make en follow acquisition direction when possible
    % % % % % %     if numel(atMeta) >= 2
    % % % % % %         p1 = double(atMeta{1}.ImagePositionPatient(:));
    % % % % % %         p2 = double(atMeta{2}.ImagePositionPatient(:));
    % % % % % %         if dot(p2-p1, en) < 0
    % % % % % %             en = -en;
    % % % % % %         end
    % % % % % %     end
    % % % % % % 
    % % % % % %     R = [ei, ej, en];                  % patient = t + R*[x;y;z]  (x,y,z in image-mm axes)
    % % % % % %     t = double(m1.ImagePositionPatient(:));
    % % % % % % end


    function tf = localSameOrientation(metaA, metaB)
        iopA = double(metaA.ImageOrientationPatient(:));
        iopB = double(metaB.ImageOrientationPatient(:));
        tf = all(abs(iopA - iopB) < 1e-4);
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

    function [R, t, bFlipped] = imgAxesToPatient(atMeta)
        bFlipped = false;
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
                bFlipped = true;
            end
        else
            if isImageFlipped(atMeta{1})
                en = -en;
                bFlipped = true;
            end
        end
    
        R = [ei, ej, en];                  % patient = t + R*[x;y;z]  (x,y,z in image-mm axes)
        t = double(m1.ImagePositionPatient(:));
    end

end
