function a3DLogicalMask = voiTemplateToMask(tVoi, atRoi, aImage)
%function a3DLogicalMask = voiTemplateToMask(tVoi, atRoi, aImage)
%Compute a 3D logical mask from VOI template.
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

    % dNbRois = numel(tVoi.RoisTag);
    % 
    % a3DLogicalMask = false(size(aImage));
    % 
    % imCDataAxes1 = false([size(aImage, 2), size(aImage, 3)]);
    % imCDataAxes2 = false([size(aImage, 1), size(aImage, 3)]);
    % imCDataAxes3 = false([size(aImage, 1), size(aImage, 2)]);  
    % 
    % for rr=1:dNbRois
    % 
    %     dTagOffset = find(strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), tVoi.RoisTag{rr} ), 1);
    % 
    %     if ~isempty(dTagOffset)
    % 
    %         pRoi = atRoi{dTagOffset};
    % 
    %         switch(lower(pRoi.Axe))
    % 
    %             case lower( 'Axes1')
    % 
    %                 imCData = roiTemplateToMask(pRoi, imCDataAxes1);
    %                 a3DLogicalMask(pRoi.SliceNb,:,:) = a3DLogicalMask(pRoi.SliceNb,:,:) | permute(imCData, [3 2 1]);
    % 
    %             case lower( 'Axes2')          
    % 
    %                 imCData = roiTemplateToMask(pRoi, imCDataAxes2);
    %                 a3DLogicalMask(pRoi.SliceNb,:,:) = a3DLogicalMask(:,pRoi.SliceNb,:) | permute(imCData, [3 1 2]);
    % 
    %             case lower( 'Axes3')                   
    %                 imCData = roiTemplateToMask(pRoi, imCDataAxes3);
    %                 a3DLogicalMask(:,:,pRoi.SliceNb) = a3DLogicalMask(:,:,pRoi.SliceNb) | imCData;  
    %         end  
    % 
    %     end
    % end

    % Precompute dimensions and temporary masks
    dNbRois = numel(tVoi.RoisTag);
    a3DLogicalMask = false(size(aImage));
    sz = size(aImage);
    
    imCDataAxes1 = false([sz(2), sz(3)]);
    imCDataAxes2 = false([sz(1), sz(3)]);
    imCDataAxes3 = false([sz(1), sz(2)]);
    
    % Precompute lower-case strings for axes comparison
    sLowerAxes1 = 'axes1';
    sLowerAxes2 = 'axes2';
    sLowerAxes3 = 'axes3';
    
    % Precompute ROI tags once instead of inside the loop
    roiTags = cellfun(@(roi) roi.Tag, atRoi, 'UniformOutput', false);
    
    for rr = 1:dNbRois
        % Find the ROI index matching the current tag
        dTagOffset = find(strcmp(roiTags, tVoi.RoisTag{rr}), 1);
        
        if ~isempty(dTagOffset)

            pRoi = atRoi{dTagOffset};

            switch lower(pRoi.Axe)

                case sLowerAxes1
                    imCData = roiTemplateToMask(pRoi, imCDataAxes1);
                    a3DLogicalMask(pRoi.SliceNb,:,:) = a3DLogicalMask(pRoi.SliceNb,:,:) | permute(imCData, [3 2 1]);

                case sLowerAxes2          
                    imCData = roiTemplateToMask(pRoi, imCDataAxes2);
                    a3DLogicalMask(pRoi.SliceNb,:,:) = a3DLogicalMask(:,pRoi.SliceNb,:) | permute(imCData, [3 1 2]);

                case sLowerAxes3                   
                    imCData = roiTemplateToMask(pRoi, imCDataAxes3);
                    a3DLogicalMask(:,:,pRoi.SliceNb) = a3DLogicalMask(:,:,pRoi.SliceNb) | imCData;
            end  
        end
    end
    
end