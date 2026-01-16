function aRspMip = resample3DMIP(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation)
%function  aRspMip = resample3DMIP(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation)
%Resize a 3D MIP from a reference.
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
%     the Free Software Foundation, either version 3 of the License, for
%     (at your option) any later version.
%
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.

    zMoveOffset =0;

    dimsRef = size(aRefMip,3);
    dimsRsp = size(aRspMip,3); 

    if dimsRef ~= dimsRsp % Z is different

        dMinMipFusion = min(aRspMip, [], 'all');
        % if dimsRef > dimsRsp
        %     dRatio = dimsRsp/dimsRef*100;
        % else
        %     dRatio = dimsRef/dimsRsp*100;
        % end

        if strcmpi(atRspMetaData{1}.Modality, 'nm') || ...
           strcmpi(atRefMetaData{1}.Modality, 'nm') 
            
            aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, false);  
        else
            aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, true);  

            if isempty(aResampledMip(aResampledMip~=dMinMipFusion)) % The z is to far, need to change the method
                
                aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, false);  
            else
                zMoveOffset = (dimsRef-dimsRsp)/2;
            end
        end

    else
        dimsRef = size(aRefMip,2);
        dimsRsp = size(aRspMip,2); 
        
        remainder = mod(dimsRef, dimsRsp);
        if remainder == 0
            aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, false);   
        else
            dMinMipFusion = min(aRspMip, [], 'all');

            aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, true);  
            if isempty(aResampledMip(aResampledMip~=dMinMipFusion)) % The z is to far, need to change the method
                
                aResampledMip = resampleMipTransformMatrix(aRspMip, atRspMetaData, aRefMip, atRefMetaData, sInterpolation, false);  
            end           
        end
     end

    dimsRef = size(aRefMip);         
    dimsRsp = size(aResampledMip);   
    
    xMoveOffset = (dimsRsp(3)-dimsRef(3))/2;
    yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

    if xMoveOffset ~= 0 || yMoveOffset ~= 0 || zMoveOffset ~= 0

        aRspMip = imtranslate(aResampledMip,[-yMoveOffset, 0, -xMoveOffset+zMoveOffset], 'nearest', 'OutputView', 'same', 'FillValues', min(aResampledMip, [], 'all') );    
    else
        aRspMip = aResampledMip;
    end  

    clear aResampledMip;
end