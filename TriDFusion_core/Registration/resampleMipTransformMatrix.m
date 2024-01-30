function [resampImage, atDcmMetaData, zMoveOffsetRemaining] = resampleMipTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, bSameOutput)
%function [resampImage, atDcmMetaData, zMoveOffsetRemaining] = resampleMipTransformMatrix(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, bSameOutput)
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

    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    
    xScale    = M(1,1);
    if xScale == 0
        xScale = 1;
    end
    
    zScale    = M(3,3);
    if zScale == 0
        zScale = 1;
    end
    
    xExtended = M(4,1);
    zExtended = M(4,3);
 
    f = [ xScale     0 0         0
          0          1 0         0
          0          0 zScale    0
          xExtended  0 zExtended 1];          
    
    TF = affine3d(f);
    
    Rdcm  = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    
%    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')) );  
    
%    if numel(resampImage) ~=  numel(refImage) % SPECT and CT DX
    if bSameOutput == true
        [resampImage, ~] = imwarp(dcmImage, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef));  
    else
        [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    end

    aRspSize = size(resampImage);

    if aRspSize(3) ~= dimsRef(3) % Fix for z offset

        if aRspSize(3) > dimsRef(3)

            [dDcmFirstZ, dDcmLastZ] = getImageZPosition(atDcmMetaData, dcmImage);
            [dRefFirstZ, dRefLastZ] = getImageZPosition(atRefMetaData, refImage);

            dFirstOffset = abs(dRefFirstZ - dDcmFirstZ)/refSliceThickness;
%                 dLastOffset = abs(dRefLastZ - dDcmLastZ)/refSliceThickness;


            dImageOffset = round(dFirstOffset);
            zMoveOffsetRemaining = dFirstOffset-dImageOffset;



             resampImage = resampImage(:,:,1:end);
            
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
            aResample = zeros(aRspSize(1), aRspSize(2), dimsRef(3));

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
    end

%        if dimsRef(3)==dimsDcm(3)
%            aResampledImageSize = size(resampImage);
%            resampImage=imresize3(resampImage, [aResampledImageSize(1) aResampledImageSize(2) dimsRef(3)]);
%        end
        

%    end
        
end