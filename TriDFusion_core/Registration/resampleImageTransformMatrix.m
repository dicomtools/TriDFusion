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
            
            if deltaZ_mm == 0

                resampImage = dcmImage;
                return;          
            end
        end
    end

    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);

    if bSameOutput == true
        % 
        % [resampImage, RB] = imwarp( ...
        %    dcmImage, TF, ...
        %    'Interp',     sMode, ...
        %    'FillValues', double(min(dcmImage(:))), ...
        %    'OutputView', Rref );

            dDcmFirstZ = getImageZPosition(atDcmMetaData, dcmImage);
            dRefFirstZ = getImageZPosition(atRefMetaData, refImage);
    
            deltaZ_mm = dRefFirstZ - dDcmFirstZ;   % a positive or negative number (mm)
            T = eye(4);
            T(4,3) = deltaZ_mm;
            TF = affine3d(T);

            [resampImage, RB] = imwarp( ...
                dcmImage, Rdcm, TF, ...
                'Interp',    sMode, ...
                'FillValues',double(min(dcmImage(:))), ...
                'OutputView',Rref ...
            );
        % [resampImage, RB] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef));  
   
    else
        [resampImage, RB] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    end
%        if dimsRef(3)==dimsDcm(3)
%            aResampledImageSize = size(resampImage);
%            resampImage=imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)]);
%        end


 %test   end

    dimsRsp = size(resampImage);
    
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
        atDcmMetaData{jj}.Rows                   = dimsRef(1);
        atDcmMetaData{jj}.Columns                = dimsRef(2);
        atDcmMetaData{jj}.SpacingBetweenSlices   = RB.PixelExtentInWorldZ;
        atDcmMetaData{jj}.SliceThickness         = RB.PixelExtentInWorldZ;
        atDcmMetaData{jj}.InstanceNumber         = jj;
        atDcmMetaData{jj}.NumberOfSlices         = dimsRef(3);

        % % % Compute X/Y origin differently for the OutputView case
        % if bSameOutput == true
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

    computedSliceThickness = refSliceThickness;

     % Align first-slice Z per DICOM when using OutputView
    if bSameOutput == true && dimsRsp(3) ~= dimsDcm(3)

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

    if strcmpi(atDcmMetaData{1}.StudyInstanceUID, atRefMetaData{1}.StudyInstanceUID) % Same study         


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
end