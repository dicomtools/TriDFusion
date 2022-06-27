function init3DfusionBuffer()  
%function init3DfusionBuffer()    
%Init 3D fusion buffer.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput  = inputTemplate('get');
    
    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
       
    % Set buffer % Meta data

    aInput = inputBuffer('get');

    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
    A = dicomBuffer('get');
     if isempty(A)
        A = aInput{iFuseOffset};
     end
    
    atMetaData  = dicomMetaData('get');
    if isempty(atMetaData)
        atMetaData = atInput(iSeriesOffset).atDicomInfo;
    end
        
    set(uiSeriesPtr('get'), 'Value', iFuseOffset);
    
    B = dicomBuffer('get');
    if isempty(B)
        B = aInput{iFuseOffset};
    end
    
    atFuseMetaData = dicomMetaData('get');
    if isempty(atFuseMetaData)
        atFuseMetaData = atInput(iFuseOffset).atDicomInfo;
    end
        
    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
                                                                                                  
    if strcmpi(imageOrientation('get'), 'coronal')
        B = permute(B, [3 2 1]);
    elseif strcmpi(imageOrientation('get'), 'sagittal')
        B = permute(B, [2 3 1]);
    else
        B = permute(B, [1 2 3]);
    end

    if atInput(iSeriesOffset).bFlipLeftRight == true
        B=B(:,end:-1:1,:);
    end

    if atInput(iSeriesOffset).bFlipAntPost == true
        B=B(end:-1:1,:,:);
    end

    if atInput(iSeriesOffset).bFlipHeadFeet == true
        B=B(:,:,end:-1:1);
    end                                 
                                
    [B, ~] = ...
        resampleImageTransformMatrix(B, ...
                                     atFuseMetaData, ...
                                     A, ...
                                     atMetaData, ...
                                     'bilinear', ...
                                     false ...
                                     ); 
     
    if numel(A)~=numel(B)                             
        B = imresize3(B, size(A));
    end
    
    fusionBuffer('set', squeeze(B), iFuseOffset);     

end  