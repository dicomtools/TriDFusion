function aLogicalMask = roiConstraintToMask(aImage, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask)
%function  aLogicalMask = roiConstraintToMask(aImage, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask) 
%Return a constrainted image from the roi tag.
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
% along with TriDFusion. If not, see <http://www.gnu.org/licenses/>. 
        
    aLogicalMask = zeros(size(aImage));

    if size(aImage, 3) == 1 % 2D image
        
        for cl=1:numel(asConstraintTagList)
            
            sConstraintTag  = asConstraintTagList{cl};
            
            for ri=1:numel(tRoiInput)
                
                if strcmpi(tRoiInput{ri}.Tag, sConstraintTag)
                                          
                    sAxe   = tRoiInput{ri}.Axe;

                    switch lower(sAxe)
                        case 'axe'

                            aSlice = aImage(:,:);
                            roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aLogicalMask(:,:) = aLogicalMask(:,:)|aSlice; % Add to final mask
                    end

                    break;        
                end
            end
        end
        
    else % 3D Image
        
        for cl=1:numel(asConstraintTagList)
            
            sConstraintTag  = asConstraintTagList{cl};
            sConstraintType = asConstraintTypeList{cl};
            
            for ri=1:numel(tRoiInput)
           
                if strcmpi(tRoiInput{ri}.Tag, sConstraintTag)
                                            
                    dSliceNb = tRoiInput{ri}.SliceNb;
                    sAxe     = tRoiInput{ri}.Axe;

                    switch lower(sAxe)

                        case 'axes1' % Coronal

                             if strcmpi(sConstraintType, 'Inside Every Slice') 

                                for dd=1:size(aImage, 1)

                                    aSlice  = permute(aImage(dd,:,:), [3 2 1]);
                                    roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);

                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]); 

                                    aLogicalMask(dd,:,:) = aLogicalMask(dd,:,:)|aSlice; % Add to final mask                                        
                                 end
                             else

                                aSlice  = permute(aImage(dSliceNb,:,:), [3 2 1]);
                                roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);  

                                aLogicalMask(dSliceNb,:,:) = aLogicalMask(dSliceNb,:,:)|aSlice; % Add to final mask                                    
                             end

                        case 'axes2' % Sagittal

                             if strcmpi(sConstraintType, 'Inside Every Slice')

                                for dd=1:size(aImage, 2)

                                    aSlice  = permute(aImage(:,dd,:), [3 1 2]);
                                    roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);
                                    
                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                    aLogicalMask(:,dd,:) = aLogicalMask(:,dd,:)|aSlice; % Add to final mask
                                end
                             else

                                aSlice = permute(aImage(:,dSliceNb,:), [3 1 2]);
                                roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);
                                
                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);  

                                aLogicalMask(:,dSliceNb,:) = aLogicalMask(:,dSliceNb,:)|aSlice; % Add to final mask

                             end                                

                        case 'axes3' % Axial

                             if strcmpi(sConstraintType, 'Inside Every Slice') 

                                for dd=1:size(aImage, 3)

                                    aSlice  = aImage(:,:,dd);
                                    roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);

                                    aSlice( roiMask) =1;
                                    aSlice(~roiMask) =0;

                                    aLogicalMask(:,:,dd) = aLogicalMask(:,:,dd)|aSlice; % Add to final mask
                                end
                             else

                                aSlice  = aImage(:,:,dSliceNb);
                                roiMask = roiTemplateToMask(tRoiInput{ri}, aSlice);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aLogicalMask(:,:,dSliceNb) = aLogicalMask(:,:,dSliceNb)|aSlice; % Add to final mask

                             end                                  
                    end  

                    break;
                end
            end
        end                        
    end
    
    if aLogicalMask(aLogicalMask==1) % Need at least one constraint
        
        if bInvertMask == true
            aLogicalMask = ~aLogicalMask;
        else
            aLogicalMask = logical(aLogicalMask);                
        end
    else
        aLogicalMask = [];
    end
end