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

    Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
    Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);

    if isequal(dimsRef, dimsDcm)
        
        if isequal(Rdcm.PixelExtentInWorldX, Rref.PixelExtentInWorldX) && ...
           isequal(Rdcm.PixelExtentInWorldY, Rref.PixelExtentInWorldY) && ...
           isequal(Rdcm.PixelExtentInWorldZ, Rref.PixelExtentInWorldZ)

            resampImage = dcmImage;
            return;           
        end
    end

    [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);



%     dRefImageExtentInWorldZ = round(Rref.ImageExtentInWorldZ);
%     dDcmImageExtentInWorldZ = round(Rdcm.ImageExtentInWorldZ);
%   
%     dOffset = round ((dRefImageExtentInWorldZ - dDcmImageExtentInWorldZ)/refSliceThickness);
%     refImage = refImage(:,:,1:end-dOffset);
%     dimsRef = size(refImage);        

%test    [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
%    [resampImage, ~] = imwarp(dcmImage, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef));  

%test    if numel(resampImage) ~=  numel(refImage) % SPECT and CT DX
%sMode='Nearest'
        if bSameOutput == true
            [resampImage, ~] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef));  
        else
            [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
        end
%        if dimsRef(3)==dimsDcm(3)
%            aResampledImageSize = size(resampImage);
%            resampImage=imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)]);
%        end


        aRspSize = size(resampImage);

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
        end

 %test   end

    aResampledImageSize = size(resampImage);

    if numel(atDcmMetaData) ~= 1
        if aResampledImageSize(3) < numel(atDcmMetaData)
            atDcmMetaData = atDcmMetaData(1:numel(atRefMetaData)); % Remove some slices
        else
            for cc=1:aResampledImageSize(3) - numel(atDcmMetaData)
                atDcmMetaData{end+1} = atDcmMetaData{end}; %Add missing slice
            end            
        end
    end
    
    computedSliceThikness = (dimsRef(3) * refSliceThickness) / aResampledImageSize(3); 

    for jj=1:numel(atDcmMetaData)
        
        atDcmMetaData{jj}.InstanceNumber  = jj;               
        atDcmMetaData{jj}.NumberOfSlices  = aResampledImageSize(3);                
        
%        atDcmMetaData{jj}.PixelSpacing(1) = atRefMetaData{1}.PixelSpacing(1);
%        atDcmMetaData{jj}.PixelSpacing(2) = atRefMetaData{1}.PixelSpacing(2);
        atDcmMetaData{jj}.PixelSpacing(1) = dimsDcm(1)/aResampledImageSize(1)*atDcmMetaData{1}.PixelSpacing(1);
        atDcmMetaData{jj}.PixelSpacing(2) = dimsDcm(2)/aResampledImageSize(2)*atDcmMetaData{1}.PixelSpacing(2); 

        if isfield(atDcmMetaData{jj}, 'SliceThickness') && ...
           isfield(atRefMetaData{1} , 'SliceThickness')
            
            atDcmMetaData{jj}.SliceThickness  = atRefMetaData{1}.SliceThickness;
        end

        if isfield(atDcmMetaData{jj}, 'SpacingBetweenSlices') && ...    
           isfield(atRefMetaData{1} , 'SpacingBetweenSlices')

            atDcmMetaData{jj}.SpacingBetweenSlices  = computedSliceThikness;
        end

        atDcmMetaData{jj}.Rows    = aResampledImageSize(1);
        atDcmMetaData{jj}.Columns = aResampledImageSize(2);
        
        
        atDcmMetaData{jj}.ImagePositionPatient(1) =  -(atDcmMetaData{jj}.PixelSpacing(1)*aResampledImageSize(1)/2);
        atDcmMetaData{jj}.ImagePositionPatient(2) =  -(atDcmMetaData{jj}.PixelSpacing(2)*aResampledImageSize(2)/2);
         
    end
              
    for cc=1:numel(atDcmMetaData)-1
        if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + computedSliceThikness;               
            atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation + computedSliceThikness; 
        else
            atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - computedSliceThikness;               
            atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation - computedSliceThikness;             
        end
    end    
    
end