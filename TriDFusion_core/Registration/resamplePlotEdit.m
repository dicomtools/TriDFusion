function atPlotEdit = resamplePlotEdit(dcmImage, atDcmMetaData, refImage, atRefMetaData, atPlotEdit, bUpdateObject)
%function atPlotEdit = resamplePlotEdit(dcmImage, atDcmMetaData, refImage, atRefMetaData, atPlotEdit, bUpdateObject)
%Resample any plot edit object.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if isempty(atPlotEdit)
        return;
    end

    aRefSize = size(refImage);
    aDcmSize = size(dcmImage);

    dcmMeta = atDcmMetaData{1};
    refMeta = atRefMetaData{1};

    % --- fallback PixelSpacing → ImagerPixelSpacing if missing/zero
    if ~isfield(dcmMeta,'PixelSpacing') || isempty(dcmMeta.PixelSpacing) || all(dcmMeta.PixelSpacing==0)
        if isfield(dcmMeta,'ImagerPixelSpacing')
            dcmMeta.PixelSpacing = dcmMeta.ImagerPixelSpacing;
        end
    end
    if ~isfield(refMeta,'PixelSpacing') || isempty(refMeta.PixelSpacing) || all(refMeta.PixelSpacing==0)
        if isfield(refMeta,'ImagerPixelSpacing')
            refMeta.PixelSpacing = refMeta.ImagerPixelSpacing;
        end
    end

    % ensure no zeros
    dcmMeta.PixelSpacing(dcmMeta.PixelSpacing==0) = 1;
    refMeta.PixelSpacing(refMeta.PixelSpacing==0) = 1;

    % --- slice spacing (Z) fallback to SpacingBetweenSlices or SliceThickness
    dcmZ = computeSliceSpacing(atDcmMetaData);
    if dcmZ==0
        if isfield(dcmMeta,'SpacingBetweenSlices')
            dcmZ = dcmMeta.SpacingBetweenSlices;
        elseif isfield(dcmMeta,'SliceThickness')
            dcmZ = dcmMeta.SliceThickness;
        else
            dcmZ = dcmMeta.PixelSpacing(1);
        end
    end
    refZ = computeSliceSpacing(atRefMetaData);
    if refZ==0
        if isfield(refMeta,'SpacingBetweenSlices')
            refZ = refMeta.SpacingBetweenSlices;
        elseif isfield(refMeta,'SliceThickness')
            refZ = refMeta.SliceThickness;
        else
            refZ = refMeta.PixelSpacing(1);
        end
    end

    dcmOri   = reshape(dcmMeta.ImageOrientationPatient, [3,2]);
    dcmBasis = [dcmOri, cross(dcmOri(:,1), dcmOri(:,2))];
    dcmScale = diag([dcmMeta.PixelSpacing(:); dcmZ]);
    A_dcm    = [dcmBasis * dcmScale, dcmMeta.ImagePositionPatient(:); 0 0 0 1];

    refOri   = reshape(refMeta.ImageOrientationPatient, [3,2]);
    refBasis = [refOri, cross(refOri(:,1), refOri(:,2))];
    refScale = diag([refMeta.PixelSpacing(:); refZ]);
    A_ref    = [refBasis * refScale, refMeta.ImagePositionPatient(:); 0 0 0 1];

    transM = inv(A_ref) * A_dcm;
    
    for pe=1:numel(atPlotEdit)
        
        axe = lower(atPlotEdit{pe}.Axe);

        switch axe
            case {'axe','axes3'}, idx = [1,2];
            case 'axes1'        , idx = [1,3];
            case 'axes2'        , idx = [2,3];
            case 'axesmip'      , idx = [1,3];

            otherwise 
                continue;
        end

        % full 2×2 + translation
        M = transM(idx, idx);
        t = transM(idx, 4);

        if ismember(axe, {'axes1','axes2'})

            % Same logic than computeRoiScaledPosition.m
            
            N = 1; 

            switch axe
                case 'axes1'
                    xs = 1;
                    ys = atPlotEdit{pe}.SliceNb;
                case 'axes2'
                    xs = atPlotEdit{pe}.SliceNb;
                    ys = 1;                    
            end            

            zs = 1;

            H0 = [xs'; ys'; zs'; ones(1,N)] - repmat([1;1;0;0], 1, N);
            H2 = transM * H0;
            Xf = H2(1,:) + 1;
            Yf = H2(2,:) + 1;

            switch axe
                case 'axes1', atPlotEdit{pe}.SliceNb = round(Yf);
                case 'axes2', atPlotEdit{pe}.SliceNb = round(Xf);
            end
        end

        switch lower(atPlotEdit{pe}.Type)

            case 'quiver'
                x0 = atPlotEdit{pe}.XData;   
                y0 = atPlotEdit{pe}.YData;
                u0 = atPlotEdit{pe}.UData;   
                v0 = atPlotEdit{pe}.VData;
    
                % flatten, apply M, then add translation to positions only
                pts = M * [x0(:)'; y0(:)'];
                pts(1,:) = pts(1,:) + t(1);
                pts(2,:) = pts(2,:) + t(2);
    
                vec = M * [u0(:)'; v0(:)'];   % no translation on vectors
    
                % reshape back
                xData = reshape(pts(1,:), size(x0));
                yData = reshape(pts(2,:), size(y0));
                uData = reshape(vec(1,:), size(u0));
                vData = reshape(vec(2,:), size(v0));
    
                % assign
                atPlotEdit{pe}.XData = xData;
                atPlotEdit{pe}.YData = yData;
                atPlotEdit{pe}.UData = uData;
                atPlotEdit{pe}.VData = vData;
    
                if bUpdateObject && ...
                   isfield(atPlotEdit{pe},'Object') && ...
                   isvalid(atPlotEdit{pe}.Object)

                    set(atPlotEdit{pe}.Object, ...
                        'XData', xData, ...
                        'YData', yData, ...
                        'UData', uData, ...
                        'VData', vData);
                end
    
            case 'text'

                pos = atPlotEdit{pe}.Position;      

                p0 = pos(1:2)';         
                p1 = M * p0 + t;         
                pos(1:2) = p1';          

                atPlotEdit{pe}.Position = pos;
            
                if bUpdateObject && ...
                   isfield(atPlotEdit{pe},'Object') && ...
                   isvalid(atPlotEdit{pe}.Object)

                    set(atPlotEdit{pe}.Object, 'Position', pos);
                end
        end
    end

end
