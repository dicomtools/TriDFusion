function maskContourFromVoiMenuCallback(hObject, ~)
%function maskContourFromVoiMenuCallback(hObject, ~)
%Mask a VOI, the function is called from voi default menu.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    imBuffer = dicomBuffer('get', [], dSeriesOffset); 

    if isempty(imBuffer)   

        return;
    end

    sMaskType = get(hObject, 'Label');

    atRoiTemplate = roiTemplate('get', dSeriesOffset);
    atVoiTemplate = voiTemplate('get', dSeriesOffset);

    imMask = false(size(imBuffer));

    if ~isempty(atVoiTemplate)        

        dVoiTagOffset = find(cellfun(@(c) any(strcmp(c.RoisTag, hObject.UserData.Tag)), atVoiTemplate), 1);
        
        if ~isempty(dVoiTagOffset) % tag is a voi

            dNbRoiTag = numel(atVoiTemplate{dVoiTagOffset}.RoisTag);

            for tt=1:dNbRoiTag % Scan all tag
                
                dRoiTagOffset = find(strcmp( cellfun( @(atRoiTemplate) atRoiTemplate.Tag, atRoiTemplate, 'uni', false ), {[atVoiTemplate{dVoiTagOffset}.RoisTag{tt}]} ), 1);
           
                if ~isempty(dRoiTagOffset)
                    
                    sAxe = atRoiTemplate{dRoiTagOffset}.Axe;
                    dSliceNumber = atRoiTemplate{dRoiTagOffset}.SliceNb;

                    switch lower(sAxe)
                        
                        case 'axe'

                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}.Object, imBuffer(:,:));

                        imMask(:,:) = imMask(:,:) | aMask;

                       case 'axes1'

                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, permute(imBuffer(dSliceNumber,:,:), [3 2 1]));

                        imMask(dSliceNumber,:,:) = imMask(dSliceNumber,:,:) | permute(aMask, [3 2 1]);
                     
                        case 'axes2'     

                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, permute(imBuffer(:,dSliceNumber,:), [3 1 2]));

                        imMask(:,dSliceNumber,:) = imMask(:,dSliceNumber,:) | permute(aMask, [2 3 1]);


                        case 'axes3'

                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, imBuffer(:,:,dSliceNumber));
                            
                        imMask(:,:,dSliceNumber) = imMask(:,:,dSliceNumber) | aMask;

                    end
                end
            end
        
            if any(imMask(:))

                if strcmpi(sMaskType, 'Inside This Contour')
        
                    imBuffer(imMask) = cropValue('get');

                else % 'Outside This Contour'
                    imMask = ~imMask;
                    imBuffer(imMask) = cropValue('get');                                           
                end                                                        
                
                modifiedMatrixValueMenuOption('set', true);
        
                dicomBuffer('set', imBuffer, dSeriesOffset); 
        
                setQuantification(dSeriesOffset);
        
                refreshImages();
            end

        end
    end 
    
    clear imMask;
    clear imBuffer;

end
   