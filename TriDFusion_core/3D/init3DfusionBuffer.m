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

    atInputTemplate  = inputTemplate('get');
    
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    dFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');
       
    % Set buffer % Meta data

    aInput = inputBuffer('get');

%    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
    A = dicomBuffer('get', [], dSeriesOffset);
    if isempty(A)
        A = aInput{dSeriesOffset};
    end
    
    atMetaData  = dicomMetaData('get', [], dSeriesOffset);
    if isempty(atMetaData)
        atMetaData = atInputTemplate(dSeriesOffset).atDicomInfo;
    end
        
%    set(uiSeriesPtr('get'), 'Value', dFuseOffset);
    
    B = dicomBuffer('get', [], dFuseOffset);
    if isempty(B)
        
        B = aInput{dFuseOffset};
       
        if     strcmpi(imageOrientation('get'), 'axial')
        %    B = B;
        elseif strcmpi(imageOrientation('get'), 'coronal')
            B = reorientBuffer(B, 'coronal');
        elseif strcmpi(imageOrientation('get'), 'sagittal')
            B = reorientBuffer(B, 'sagittal');
        end

        if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
            B=B(:,end:-1:1,:);
        end

        if atInputTemplate(dSeriesOffset).bFlipAntPost == true
            B=B(end:-1:1,:,:);
        end

        if atInputTemplate(dSeriesOffset).bFlipHeadFeet == true
            B=B(:,:,end:-1:1);
        end        
    end
 
    atFuseMetaData = dicomMetaData('get', [], dFuseOffset);
    if isempty(atFuseMetaData)
        atFuseMetaData = atInputTemplate(dFuseOffset).atDicomInfo;
    end
        
%    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
           
    [aResampled, ~] = ...
        resampleImageTransformMatrix(B, ...
                                     atFuseMetaData, ...
                                     A, ...
                                     atMetaData, ...
                                     'bilinear', ...
                                     true ...
                                     ); 
                                 
    if numel(aResampled(aResampled==min(aResampled, [], 'all'))) == numel(aResampled)                            
        [aResampled, ~] = ...
            resampleImageTransformMatrix(B, ...
                                         atFuseMetaData, ...
                                         A, ...
                                         atMetaData, ...
                                         'bilinear', ...
                                         false ...
                                         );         
    end
     
    if numel(A)~=numel(aResampled)                             
        aResampled = imresize3(aResampled, size(A));
    end
    
    fusionBuffer('set', squeeze(aResampled), dFuseOffset);     
    
    clear A;
    clear B;
    clear aInput;
    clear aResampled;

end  