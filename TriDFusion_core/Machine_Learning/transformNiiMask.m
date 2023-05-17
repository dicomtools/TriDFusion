function aMask = transformNiiMask(aNiiImage, atNiiMetaData, aRefImage, atRefMetaData)  
%function  aMask = transformNiiMask(aNiiImage, atDcmMetaData, aRefImage, atRefMetaData) 
%Rotate and transform .nii ct mask to nm size.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Rotate mask

    aMask = imrotate3(aNiiImage, 90, [0 0 1], 'nearest');
    aMask = aMask(:,:,end:-1:1);

if 1

    xPixelSizeRatio = 0;
    yPixelSizeRatio = 0;
    zMoveOffset =0;

    dMinFusion = min(aMask, [], 'all');                       

    aZsize = size(aRefImage,3);
    bZsize = size(aNiiImage,3); 

    if aZsize ~= bZsize % Z is different

        if aZsize > bZsize
            dRatio = bZsize/aZsize*100;
        else
            dRatio = aZsize/bZsize*100;
        end

        if dRatio < 65  % The z is to far, need to change the method 
            [aMask, ~] = ...
                resampleImageTransformMatrix(aMask, ...
                                             atNiiMetaData, ...
                                             aRefImage, ...
                                             atRefMetaData, ...
                                             'cubic', ...
                                             false ...
                                             );                              
        else
            Btemp = aMask;
            atFusionMetaDataTemp = atNiiMetaData;
            
            [aMask, ~] = ...
                resampleImageTransformMatrix(aMask, ...
                                             atNiiMetaData, ...
                                             aRefImage, ...
                                             atRefMetaData, ...
                                             'cubic', ...
                                             true ...
                                             ); 

            if isempty(aMask(aMask~=dMinFusion)) % The z is to far, need to change the method

                [aMask, ~] = ...
                    resampleImageTransformMatrix(Btemp, ...
                                                 atFusionMetaDataTemp, ...
                                                 aRefImage, ...
                                                 atRefMetaData, ...
                                                 'cubic', ...
                                                 false ...
                                                 ); 
%                            B = imresize3(B, 'OutputSize',size(A));+
            else
                zMoveOffset = (aZsize-bZsize)/2;
            end

            dimsRef = size(aRefImage);         
            dimsRsp = size(aMask);         
            xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
            yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

            if xMoveOffset ~= 0 || yMoveOffset ~= 0 

                xPixelSizeRatio = atFusionMetaDataTemp{1}.PixelSpacing(1);
                yPixelSizeRatio = atFusionMetaDataTemp{1}.PixelSpacing(2);
            else                              

                xPixelSizeRatio = atRefMetaData{1}.PixelSpacing(1);
                yPixelSizeRatio = atRefMetaData{1}.PixelSpacing(2);                                    
            end

            clear Btemp;
            clear atFusionMetaDataTemp;                                 
        end

    else
        [aMask, ~] = ...
            resampleImageTransformMatrix(aMask, ...
                                         atNiiMetaData, ...
                                         aRefImage, ...
                                         atRefMetaData, ...
                                         'cubic', ...
                                         false ...
                                         );     
        dimsRef = size(aRefImage);         
        dimsRsp = size(aMask);         
        xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
        yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

        if xMoveOffset ~= 0 || yMoveOffset ~= 0 
            if xMoveOffset < 1 && yMoveOffset < 1
               if xMoveOffset > 0 && yMoveOffset > 0    
                    aMask=imresize3(aMask, size(aRefImage));
               end
            else
                xPixelSizeRatio = 1;
                yPixelSizeRatio = 1;
            end
        end
    end

    dimsRef = size(aRefImage);         
    dimsRsp = size(aMask);         
    xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
    yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

    if xMoveOffset ~= 0 || yMoveOffset ~= 0 || zMoveOffset ~= 0
        if xMoveOffset < 0 || yMoveOffset < 0 
            aMask = imtranslate(aMask,[-xMoveOffset-xPixelSizeRatio, -yMoveOffset-xPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'full', 'FillValues', min(aMask, [], 'all') ); 
        else                              
            aMask = imtranslate(aMask,[-xMoveOffset+xPixelSizeRatio, -yMoveOffset+yPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aMask, [], 'all') ); 
        end
    end
else
    % Resample mask

    dimsNii = size(aNiiImage);         
    dimsRef = size(aRefImage);         

    niiSliceThickness = computeSliceSpacing(atNiiMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);       

%    [Mnii,~] = TransformMatrix(atNiiMetaData{1}, niiSliceThickness);
%    [Mref,~] = TransformMatrix(atRefMetaData{1}, refSliceThickness);
            
%    M=Mref/Mnii;

%    TF = affine3d(M');

    [M,~] = getTransformMatrix(atNiiMetaData{1}, niiSliceThickness, atRefMetaData{1}, refSliceThickness);
    TF = affine3d(M);

    Rdcm = imref3d(dimsNii, atNiiMetaData{1}.PixelSpacing(2), atNiiMetaData{1}.PixelSpacing(1), niiSliceThickness);

    [aMask, ~] = imwarp(aMask, Rdcm, TF, 'Interp', 'cubic', 'FillValues', double(min(aNiiImage,[],'all')));  

    dimsRsp = size(aMask);         
    xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
    yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

    xPixelSizeRatio = 0;
    yPixelSizeRatio = 0;
    zMoveOffset     = 0;

    if xMoveOffset ~= 0 || yMoveOffset ~= 0 || zMoveOffset ~= 0
        if xMoveOffset < 0 || yMoveOffset < 0 
            aMask = imtranslate(aMask,[-xMoveOffset-xPixelSizeRatio, -yMoveOffset-xPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'full', 'FillValues', min(aMask, [], 'all') ); 
        else                              
            aMask = imtranslate(aMask,[-xMoveOffset+xPixelSizeRatio, -yMoveOffset+yPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aMask, [], 'all') ); 
        end
    end


end