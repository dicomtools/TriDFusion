function [aRspImage, atRspMetaData] = resample3DImage(aRspImage, atRspMetaData, aRefImage, atRefMetaData, sInterpolation)
%function  [aRspImage, atRspMetaData] = resample3DImage(aRspImage, atRspMetaData, aRefImage, atRefMetaData, sInterpolation)
%Resize a 3D image from a reference.
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

    xPixelSizeRatio = 0;
    yPixelSizeRatio = 0;
    zMoveOffset =0;
    
    dMinValue = min(aRspImage, [], 'all');                       
    
    dimsRef = size(aRefImage,3);
    dimsRsp = size(aRspImage,3); 
    
    if dimsRef ~= dimsRsp % Z is different
    
        if dimsRef > dimsRsp
            dRatio = dimsRsp/dimsRef*100;
        else
            dRatio = dimsRef/dimsRsp*100;
        end
    
        if dRatio < 65  % The z is to far, need to change the method 
            [aRspImage, atRspMetaData] = ...
                resampleImageTransformMatrix(aRspImage, ...
                                             atRspMetaData, ...
                                             aRefImage, ...
                                             atRefMetaData, ...
                                             sInterpolation, ...
                                             false ...
                                             );                              
        else
            Btemp = aRspImage;
            atRspMetaDataTemp = atRspMetaData;
            
            [aRspImage, atRspMetaData] = ...
                resampleImageTransformMatrix(aRspImage, ...
                                             atRspMetaData, ...
                                             aRefImage, ...
                                             atRefMetaData, ...
                                             sInterpolation, ...
                                             true ...
                                             ); 
    
            if isempty(aRspImage(aRspImage~=dMinValue)) % The z is to far, need to change the method
    
                [aRspImage, atRspMetaData] = ...
                    resampleImageTransformMatrix(Btemp, ...
                                                 atRspMetaDataTemp, ...
                                                 aRefImage, ...
                                                 atRefMetaData, ...
                                                 sInterpolation, ...
                                                 false ...
                                                 ); 
            else
                zMoveOffset = (dimsRef-dimsRsp)/2;
            end
    
            dimsRef = size(aRefImage);         
            dimsRsp = size(aRspImage);         
            xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
            yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;
    
            if xMoveOffset ~= 0 || yMoveOffset ~= 0 
    
                xPixelSizeRatio = atRspMetaDataTemp{1}.PixelSpacing(1);
                yPixelSizeRatio = atRspMetaDataTemp{1}.PixelSpacing(2);
            else                              
    
                xPixelSizeRatio = atRefMetaData{1}.PixelSpacing(1);
                yPixelSizeRatio = atRefMetaData{1}.PixelSpacing(2);                                    
            end
    
            clear Btemp;
            clear atRspMetaDataTemp;                                 
        end
    
    else
        [aRspImage, atRspMetaData] = ...
            resampleImageTransformMatrix(aRspImage, ...
                                         atRspMetaData, ...
                                         aRefImage, ...
                                         atRefMetaData, ...
                                         sInterpolation, ...
                                         false ...
                                         );     
        dimsRef = size(aRefImage);         
        dimsRsp = size(aRspImage);         
        xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
        yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;
    
        if xMoveOffset ~= 0 || yMoveOffset ~= 0 
            if xMoveOffset < 1 && yMoveOffset < 1
               if xMoveOffset > 0 && yMoveOffset > 0    
                    aRspImage=imresize3(aRspImage, size(aRefImage));
               end
            else
                xPixelSizeRatio = 1;
                yPixelSizeRatio = 1;
            end
        end
    end
    
    dimsRef = size(aRefImage);         
    dimsRsp = size(aRspImage);         
    xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
    yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;
    
    if xMoveOffset ~= 0 || yMoveOffset ~= 0 || zMoveOffset ~= 0
        if xMoveOffset < 0 || yMoveOffset < 0 
            aRspImage = imtranslate(aRspImage,[-xMoveOffset-xPixelSizeRatio, -yMoveOffset-xPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'full', 'FillValues', min(aRspImage, [], 'all') ); 
        else                              
            aRspImage = imtranslate(aRspImage,[-xMoveOffset+xPixelSizeRatio, -yMoveOffset+yPixelSizeRatio, zMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aRspImage, [], 'all') ); 
        end
    end
     
end
                    