function aLogicalMaskOut = roiConstraintToMask(aImage, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask)
%function  aLogicalMaskOut = roiConstraintToMask(aImage, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask) 
%Return a constrainted image from the roi tag.
%See TdTagOffsetDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% CopydTagOffsetght 2022, Daniel Lafontaine, on behalf of the TdTagOffsetDFusion development team.
% 
% This file is part of The TdTagOffsetple Dimention Fusion (TdTagOffsetDFusion).
% 
% TdTagOffsetDFusion development has been led by:  Daniel Lafontaine
% 
% TdTagOffsetDFusion is distdTagOffsetbuted under the terms of the Lesser GNU Public License. 
% 
%     This version of TdTagOffsetDFusion is free software: you can redistdTagOffsetbute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% TdTagOffsetDFusion is distdTagOffsetbuted in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TdTagOffsetDFusion. If not, see <http://www.gnu.org/licenses/>. 

    if canUseGPU()        
        aLogicalMask = gpuArray(zeros(size(aImage)));
    else
        aLogicalMask = zeros(size(aImage));
    end

    if size(aImage, 3) == 1 % 2D image
        
        for cl=1:numel(asConstraintTagList)
            
            sConstraintTag  = asConstraintTagList{cl};
            
            aTagOffset = strcmp( cellfun( @(tRoiInput) tRoiInput.Tag, tRoiInput, 'uni', false ), sConstraintTag );
             
            dTagOffset = find(aTagOffset, 1);

            if ~isempty(dTagOffset)
                                          
                sAxe   = tRoiInput{dTagOffset}.Axe;

                switch lower(sAxe)
                    case 'axe'

                        aSlice = aImage(:,:);
                        roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, aSlice);

                        aSlice( roiMask) =1;
                        aSlice(~roiMask) =0;

                        aLogicalMask(:,:) = aLogicalMask(:,:)|aSlice; % Add to final mask
                end

            end
        end
        
    else % 3D Image


        for cl=1:numel(asConstraintTagList)
            
            sConstraintTag  = asConstraintTagList{cl};
            sConstraintType = asConstraintTypeList{cl};

            aTagOffset = strcmp( cellfun( @(tRoiInput) tRoiInput.Tag, tRoiInput, 'uni', false ), sConstraintTag );
             
            dTagOffset = find(aTagOffset, 1);


            if ~isempty(dTagOffset)
                                            
                dSliceNb = tRoiInput{dTagOffset}.SliceNb;
                sAxe     = tRoiInput{dTagOffset}.Axe;

                switch lower(sAxe)

                    case 'axes1' % Coronal

                         if strcmpi(sConstraintType, 'Inside Every Slice') 
tic                            
                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, permute(aImage(1,:,:), [3 2 1]));
                            for dd=1:size(aImage, 1)

                                aSlice  = permute(aImage(dd,:,:), [3 2 1]);
                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]); 

                                aLogicalMask(dd,:,:) = aLogicalMask(dd,:,:)|aSlice; % Add to final mask                                        
                            end
toc
                         else

                            aSlice  = permute(aImage(dSliceNb,:,:), [3 2 1]);
                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);  

                            aLogicalMask(dSliceNb,:,:) = aLogicalMask(dSliceNb,:,:)|aSlice; % Add to final mask                                    
                         end

                    case 'axes2' % Sagittal

                         if strcmpi(sConstraintType, 'Inside Every Slice')

                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, permute(aImage(:,1,:), [3 1 2]));

                            for dd=1:size(aImage, 2)

                                aSlice  = permute(aImage(:,dd,:), [3 1 2]);
                                
                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);

                                aLogicalMask(:,dd,:) = aLogicalMask(:,dd,:)|aSlice; % Add to final mask
                            end
                         else

                            aSlice = permute(aImage(:,dSliceNb,:), [3 1 2]);
                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, aSlice);
                            
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aSlice = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);  

                            aLogicalMask(:,dSliceNb,:) = aLogicalMask(:,dSliceNb,:)|aSlice; % Add to final mask

                         end                                

                    case 'axes3' % Axial

                         if strcmpi(sConstraintType, 'Inside Every Slice') 

                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, aImage(:,:,1));

                            for dd=1:size(aImage, 3)

                                aSlice  = aImage(:,:,dd);

                                aSlice( roiMask) =1;
                                aSlice(~roiMask) =0;

                                aLogicalMask(:,:,dd) = aLogicalMask(:,:,dd)|aSlice; % Add to final mask
                            end
                         else

                            aSlice  = aImage(:,:,dSliceNb);
                            roiMask = roiTemplateToMask(tRoiInput{dTagOffset}, aSlice);

                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;

                            aLogicalMask(:,:,dSliceNb) = aLogicalMask(:,:,dSliceNb)|aSlice; % Add to final mask

                         end    
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

    aLogicalMaskOut = gather(aLogicalMask);

    clear aLogicalMask; 

end