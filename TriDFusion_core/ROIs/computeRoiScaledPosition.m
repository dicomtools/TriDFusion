function [aNewPosition, aRadius, aSemiAxes, transM] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
%function [aNewPosition, aRadius, aSemiAxes, transM] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, tRoi, Rsmp)
%Compute ROI new position from a scaled image.
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

%     aRadius = [];
%     aSemiAxes = [];
% 
%     % Extract metadata
%     dcmMeta = atDcmMetaData{1};
%     refMeta = atRefMetaData{1};
% 
%     % Ensure nonzero spacing
%     dcmMeta.PixelSpacing(dcmMeta.PixelSpacing==0) = 1;
%     refMeta.PixelSpacing(refMeta.PixelSpacing==0) = 1;
% 
%     % Slice thickness
%     dcmZ = computeSliceSpacing(atDcmMetaData);
%     if dcmZ == 0, dcmZ = dcmMeta.PixelSpacing(1); end
%     refZ = computeSliceSpacing(atRefMetaData);
%     if refZ == 0, refZ = refMeta.PixelSpacing(1); end
% 
%     % Voxel→world affines
%     dcmOri   = reshape(dcmMeta.ImageOrientationPatient, [3,2]);
%     dcmBasis = [dcmOri, cross(dcmOri(:,1), dcmOri(:,2))];
%     dcmScale = diag([dcmMeta.PixelSpacing(:); dcmZ]);
%     A_dcm    = [dcmBasis * dcmScale, dcmMeta.ImagePositionPatient(:); 0 0 0 1];
% 
%     refOri   = reshape(refMeta.ImageOrientationPatient, [3,2]);
%     refBasis = [refOri, cross(refOri(:,1), refOri(:,2))];
%     refScale = diag([refMeta.PixelSpacing(:); refZ]);
%     A_ref    = [refBasis * refScale, refMeta.ImagePositionPatient(:); 0 0 0 1];
% 
%     % Voxel-to-voxel transform
%     transM = inv(A_ref) * A_dcm;
% 
%     % Compute slice-center world coordinates
%     dcmZpos = computeZPosition(atDcmMetaData, dcmImage);
%     refZpos = computeZPosition(atRefMetaData, refImage);
% 
%     dcmZpos = flip_if_needed(refZpos, dcmZpos);
% 
%     % Extract ROI voxels in DCM space
%     N = size(tRoi.Position, 1);
%     switch lower(tRoi.Axe)
%         case {'axe','axes3'} % axial
%             xs = tRoi.Position(:,1);
%             ys = tRoi.Position(:,2);
%             zs = repmat(tRoi.SliceNb, N, 1);
%         case 'axes1'         % coronal (XZ)
%             xs = tRoi.Position(:,1);
%             ys = repmat(tRoi.SliceNb, N, 1);
%             zs = tRoi.Position(:,2);
%         case 'axes2'         % sagittal (YZ)
%             xs = repmat(tRoi.SliceNb, N, 1);
%             ys = tRoi.Position(:,1);
%             zs = tRoi.Position(:,2);
%        otherwise
%             error('Unknown Axe: %s', tRoi.Axe);
%     end
% 
%     % Homogeneous zero-based voxel coords
% 
%     H0 = [xs'; ys'; zs'; ones(1,N)] - repmat([1;1;0;0], 1, N);
%     H2 = transM * H0;
%     Xf = H2(1,:) + 1;
%     Yf = H2(2,:) + 1;
% 
%     switch lower(tRoi.Axe)
% 
%         case 'axe'
%             V = [Xf; Yf; 1];  
% 
%         case 'axes3'
%             % Axial: match world Z
% 
%             zC = dcmZpos(tRoi.SliceNb);
%             [~,idx] = min(abs(refZpos - zC));
%             Zf = repmat(idx, 1, N);
% 
%             V = [Xf; Yf; round(Zf)];        
% 
%         case 'axes1'
%             % Coronal: match world Z in Y direction
% 
%             Zf = zeros(1,N);
%             for ii=1:N
% 
%                 zC = dcmZpos(round(tRoi.Position(ii,2)));
%                 [~,idx] = min(abs(refZpos - zC));
%                 Zf(ii) = idx+1;
%             end
% 
%             V = [Xf; Zf; round(Yf)];
% 
%         case 'axes2'
%             % Sagittal: match world Z in Y direction
% 
%             Zf = zeros(1,N);
%             for ii=1:N
% 
%                 zC = dcmZpos(round(tRoi.Position(ii,2)));
%                 [~,idx] = min(abs(refZpos - zC));
%                 Zf(ii) = idx+1;
%             end
% 
%             V = [ Yf;    Zf;  round(Xf) ];
% 
%         otherwise
%             error('Unsupported Axe: %s', tRoi.Axe);
%     end
% 
%     if strcmpi(tRoi.Type, 'images.roi.rectangle') || ...
%        strcmpi(tRoi.Type, 'images.roi.circle') || ...
%        strcmpi(tRoi.Type, 'images.roi.ellipse')
% 
%         if strcmpi(tRoi.Axe, 'axes1') || ...
%            strcmpi(tRoi.Axe, 'axes2') 
% 
%             scaleX = hypot(transM(1,1), transM(2,1));
%             scaleY = zs./Zf; 
%         else
%             scaleX = hypot(transM(1,1), transM(2,1));
%             scaleY = hypot(transM(1,2), transM(2,2)); 
%         end
%     end
% 
%     switch lower(tRoi.Type)
% 
%         case 'images.roi.rectangle'
% 
%             % Position [X Y Width Height Slice]
%             aNewPosition = zeros(N,5);
%             aNewPosition(:,1) = V(1,:)';
%             aNewPosition(:,2) = V(2,:)';
%             aNewPosition(:,3) = tRoi.Position(:,3) * scaleX;
%             aNewPosition(:,4) = tRoi.Position(:,4) * scaleY;
%             aNewPosition(:,5) = round(V(3,:)');
% 
%         case 'images.roi.circle'
% 
%             % Single radius: use average scaling of both axes
%             rPix = tRoi.Radius;
%             aRadius = rPix * ((scaleX + scaleY)/2);
% 
%             aNewPosition = V';
% 
%         case 'images.roi.ellipse'
% 
%             rPixX = tRoi.SemiAxes(:,1);
%             rPixY = tRoi.SemiAxes(:,2);
%             aSemiAxes = [
%                 rPixX * scaleX, ... % X semi-axis
%                 rPixY * scaleY  ... % Y semi-axis
%             ];  
% 
%             aNewPosition = V';
% 
%         otherwise
% 
%             aNewPosition = V';
%     end
% end
% 
% function zPos = computeZPosition(atMetaData, aImage)
% 
%     n = size(aImage,3);
%     meta0 = atMetaData{1}; meta0.PixelSpacing(meta0.PixelSpacing==0)=1;
%     iop   = meta0.ImageOrientationPatient;
%     normv = cross(iop(1:3),iop(4:6)); normv=normv/norm(normv);
%     if numel(atMetaData)==n
%         zPos=zeros(n,1);
%         for k=1:n, zPos(k)=normv'*atMetaData{k}.ImagePositionPatient(:); end
%     else
%         dZ = computeSliceSpacing(atMetaData);
%         if dZ == 0
%             dZ = meta0.PixelSpacing(1);
%         end
%         base = normv' * meta0.ImagePositionPatient(:);
%         zPos = base + (0:n-1)' * dZ;  
% 
%         if isDicomImageFlipped(atMetaData)
%             zPos = flip(zPos);
%         end
%     end
% end
% 
% function dcmZpos = flip_if_needed(refZpos, dcmZpos)
% 
%     % Determine overall direction
%     upRef = refZpos(end) > refZpos(1);
%     upDcm = dcmZpos(end) > dcmZpos(1);
% 
%     % If they differ, reverse the order of dcmZpos
%     if upRef ~= upDcm
%         dcmZpos = flip(dcmZpos);
%     end
% end
% 



    % if nargin < 6
    %     Rsmp = []; 
    % end

    aRadius   = [];
    aSemiAxes = [];

    % ensure sane PixelSpacing ----
    dcmMeta = atDcmMetaData{1};
    refMeta = atRefMetaData{1};
    if isfield(dcmMeta,'PixelSpacing')
        dcmMeta.PixelSpacing(dcmMeta.PixelSpacing==0) = 1;
    end

    if isfield(refMeta,'PixelSpacing')
        refMeta.PixelSpacing(refMeta.PixelSpacing==0) = 1;
    end

    % display transform (we can switch zMode if needed) ----
    zMode  = 'scale_center';  % 'keep' | 'scale' | 'scale_center'
    transM = buildDisplayTransM(dcmImage, atDcmMetaData, refImage, atRefMetaData, zMode);

    % ROI points in DCM voxel coords (0-based) ----
    N = size(tRoi.Position, 1);

    switch lower(tRoi.Axe)
        case {'axe','axes3'} % axial: plane (col,row), slice = SliceNb
            c = tRoi.Position(:,1) - 1;
            r = tRoi.Position(:,2) - 1;
            s = repmat(tRoi.SliceNb - 1, N, 1);

        case 'axes1' % coronal: plane (col,sliceZ), slice axis is "row" 
            c = tRoi.Position(:,1) - 1;          % x
            r = repmat(tRoi.SliceNb - 1, N, 1);  % slice index
            s = tRoi.Position(:,2) - 1;          % z

        case 'axes2' % sagittal: plane (row,sliceZ), slice axis is "col" 
            c = repmat(tRoi.SliceNb - 1, N, 1);  % slice index
            r = tRoi.Position(:,1) - 1;          % y
            s = tRoi.Position(:,2) - 1;          % z

        otherwise
            error('Unknown Axe: %s', tRoi.Axe);
    end

    H0 = [c'; r'; s'; ones(1,N)];
    H2 = transM * H0;

    % back to 1-based pixel coords
    Xf = H2(1,:) + 1;   % col
    Yf = H2(2,:) + 1;   % row
    Zf = H2(3,:) + 1;   % slice (or z coord, depends on Axe packing below)

    % ALWAYS clamp in-plane coords
    Xf = max(1, min(size(refImage,2), Xf));  % cols
    Yf = max(1, min(size(refImage,1), Yf));  % rows

    % clamp slice axis per Axe 
    nzR = size(refImage,3);
    switch lower(tRoi.Axe)
        case {'axe','axes3'}
            Zf = max(1, min(nzR, Zf));

        case 'axes1'
            Yf = max(1, min(size(refImage,1), Yf));
            Zf = max(1, min(nzR, Zf));

        case 'axes2'
            Xf = max(1, min(size(refImage,2), Xf));
            Zf = max(1, min(nzR, Zf));
    end

    % Pack V 
    switch lower(tRoi.Axe)
        case 'axes1'  % [x z sliceY]
            V = [Xf; Zf; Yf];

        case 'axes2'  % [y z sliceX]
            V = [Yf; Zf; Xf];

        otherwise     % axial: [x y sliceZ]
            if size(refImage,3) <= 1
                V = [Xf; Yf; ones(1,N)];
            else
                V = [Xf; Yf; Zf];
            end
    end

    % scaling from diagonal (valid for buildDisplayTransM) 
    sx = transM(1,1);  if abs(sx) < eps, sx = 1; end
    sy = transM(2,2);  if abs(sy) < eps, sy = 1; end
    sz = transM(3,3);  if abs(sz) < eps, sz = 1; end

    switch lower(tRoi.Axe)
        case {'axe','axes3'}  % XY
            scaleX = sx; scaleY = sy;
        case 'axes1'          % XZ
            scaleX = sx; scaleY = sz;
        case 'axes2'          % YZ
            scaleX = sy; scaleY = sz;
    end

    % output in the same formats resampleROIs expects 
    switch lower(tRoi.Type)
        case 'images.roi.rectangle'
            aNewPosition      = zeros(N,5);
            aNewPosition(:,1) = V(1,:)';
            aNewPosition(:,2) = V(2,:)';
            aNewPosition(:,3) = tRoi.Position(:,3) * scaleX;
            aNewPosition(:,4) = tRoi.Position(:,4) * scaleY;
            aNewPosition(:,5) = round(V(3,:)');

        case 'images.roi.circle'
            aRadius      = tRoi.Radius * mean([scaleX, scaleY]);
            aNewPosition = V';

        case 'images.roi.ellipse'
            aSemiAxes    = [tRoi.SemiAxes(:,1) * scaleX, tRoi.SemiAxes(:,2) * scaleY];
            aNewPosition = V';

        otherwise
            aNewPosition = V';
    end
end


function T = buildDisplayTransM(dcmImage, atDcmMetaData, refImage, atRefMetaData, zMode)
% zMode: 'keep' | 'scale' | 'scale_center'

    psD = atDcmMetaData{1}.PixelSpacing(:); psD(psD==0)=1;
    psR = atRefMetaData{1}.PixelSpacing(:); psR(psR==0)=1;

    dcmZ = computeSliceSpacing(atDcmMetaData); if dcmZ==0, dcmZ = psD(1); end
    refZ = computeSliceSpacing(atRefMetaData); if refZ==0, refZ = psR(1); end

    sx = psD(2)/psR(2);    % col
    sy = psD(1)/psR(1);    % row
    sz = dcmZ/refZ;        % slice

    nxD=size(dcmImage,2); nyD=size(dcmImage,1); nzD=size(dcmImage,3);
    nxR=size(refImage,2); nyR=size(refImage,1); nzR=size(refImage,3);

    c0D=(nxD-1)/2; r0D=(nyD-1)/2; s0D=(nzD-1)/2;
    c0R=(nxR-1)/2; r0R=(nyR-1)/2; s0R=(nzR-1)/2;

    tx = c0R - sx*c0D;
    ty = r0R - sy*r0D;

    switch lower(zMode)
        case 'keep'
            sz = 1;  tz = 0;
        case 'scale'
            tz = 0;
        case 'scale_center'
            tz = s0R - sz*s0D;
        otherwise
            error('Unknown zMode: %s', zMode);
    end

    T = [sx 0  0  tx;
         0  sy 0  ty;
         0  0  sz tz;
         0  0  0  1];
end