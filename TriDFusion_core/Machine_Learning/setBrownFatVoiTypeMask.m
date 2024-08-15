function [atVoiInput, atRoiInput] = setBrownFatVoiTypeMask(aAnnotatedMask, atVoiInput, atRoiInput)
%function [atVoiInput, atRoiInput] = setBrownFatVoiTypeMask(aAnnotatedMask, atVoiInput, atRoiInput)
%Associate VOIs and ROIs to a type, from an annoted mask.
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

    dNbElements = numel(atVoiInput);

    for cc=1:dNbElements

        if mod(cc,5)==1 || cc == 1 || cc == dNbElements
            
            progressBar( cc/dNbElements-0.0001, sprintf('Associating contour %d/%d, please wait.', cc, dNbElements) );
        end

        ptrVoiInput = atVoiInput{cc};

        imVoiMask = zeros(size(aAnnotatedMask));

        adRoiTags = zeros(1, numel(ptrVoiInput.RoisTag));
        dNbTags = numel(ptrVoiInput.RoisTag);

        for uu=1:dNbTags
    
            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrVoiInput.RoisTag{uu}]} );

            dOffset = find(aTagOffset, 1);

            ptrRoi = atRoiInput{dOffset};

            adRoiTags(uu) = dOffset;

            switch lower(ptrRoi.Axe)    

                case 'axe'

                imVoiMask(:, :) = imVoiMask(:, :)| aRoiLogicalMask;
    
                case 'axes1'

                aSlice = permute(aAnnotatedMask(ptrRoi.SliceNb,:,:), [3 2 1]);
                
                aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);

                imVoiMask(ptrRoi.SliceNb, :, :) = imVoiMask(ptrRoi.SliceNb, :, :)|permuteBuffer(aRoiLogicalMask, 'coronal');
                
                case 'axes2'

                aSlice = permute(aAnnotatedMask(:,ptrRoi.SliceNb,:), [3 1 2]) ;

                aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);
         
                imVoiMask(:, ptrRoi.SliceNb, :) = imVoiMask(:, ptrRoi.SliceNb, :)|permuteBuffer(aRoiLogicalMask, 'sagittal');
                
                case 'axes3'
                
                aSlice  = aAnnotatedMask(:,:,ptrRoi.SliceNb);  
                
                aRoiLogicalMask = roiTemplateToMask(ptrRoi, aSlice);

                imVoiMask(:, :, ptrRoi.SliceNb) = imVoiMask(:, :, ptrRoi.SliceNb)|aRoiLogicalMask;
            end 

        end

        dClosestMaskIndex = findClosestAnnotatedMask(aAnnotatedMask, imVoiMask);

        switch dClosestMaskIndex

            case 1 % vertebrae_C
                sLesionType = 'Cervical';

            case 2 % vertebrae_T
                sLesionType = 'Paraspinal';

            case 3 % clavicula
                sLesionType = 'Supraclavicular';

            case 4 % Kidneys
                sLesionType = 'Abdominal';

            case 5 % scapula
                sLesionType = 'Axillary';

            case 6 % sternum
                sLesionType = 'Mediastinal';

%                 case 7 % ribs
%                     sLesionType = 'Mediastinal';
        end

        sLesionShortName = '';
        [bLesionOffset, ~, asLesionShortName] = getLesionType(sLesionType);   
        for jj=1:numel(asLesionShortName)
            if contains(atVoiInput{cc}.Label, asLesionShortName{jj})
                sLesionShortName = asLesionShortName{jj};
                break;
            end
        end  

        for uu=1:dNbTags
   
            atRoiInput{adRoiTags(uu)}.LesionType = sLesionType;
            atRoiInput{adRoiTags(uu)}.Label = replace(atRoiInput{adRoiTags(uu)}.Label, sLesionShortName, asLesionShortName{bLesionOffset});      
        end

        atVoiInput{cc}.LesionType = sLesionType;
        atVoiInput{cc}.Label = replace(atVoiInput{cc}.Label, sLesionShortName, asLesionShortName{bLesionOffset});

    end

    progressBar( 1, 'Ready' );

end