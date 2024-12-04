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

    if ~isempty(atRoiTemplate)        

        dVoiTagOffset = find(cellfun(@(c) any(strcmp(c.RoisTag, hObject.UserData.Tag)), atVoiTemplate), 1);
        
        if ~isempty(dVoiTagOffset) % tag is a voi

            dNbRoiTag = numel(atVoiTemplate{dVoiTagOffset}.RoisTag);

            for tt=1:dNbRoiTag % Scan all tag
                
                dRoiTagOffset = find(strcmp( cellfun( @(atRoiTemplate) atRoiTemplate.Tag, atRoiTemplate, 'uni', false ), {[atVoiTemplate{dVoiTagOffset}.RoisTag{tt}]} ), 1);
           
                if ~isempty(dRoiTagOffset)
                    
                    switch lower(atRoiTemplate{dRoiTagOffset}.Axe)
                        
                        case 'axe'
                        aMask = createMask(atRoiTemplate{dRoiTagOffset}.Object, imBuffer(:,:));

                        case 'axes1'
                 %       aMask = createMask(atRoiTemplate{dRoiTagOffset}.Object, permute(imBuffer(atRoiTemplate{dRoiTagOffset}.SliceNb,:,:), [3 2 1]));
                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, permute(imBuffer(atRoiTemplate{dRoiTagOffset}.SliceNb,:,:), [3 2 1]));
                        
                        case 'axes2'
                 %       aMask = createMask(atRoiTemplate{dRoiTagOffset}.Object, permute(imBuffer(:,atRoiTemplate{dRoiTagOffset}.SliceNb,:), [3 1 2]));
                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, permute(imBuffer(:,atRoiTemplate{dRoiTagOffset}.SliceNb,:), [3 1 2]));

                        case 'axes3'
                  %      aMask = createMask(atRoiTemplate{dRoiTagOffset}.Object, imBuffer(:,:,atRoiTemplate{dRoiTagOffset}.SliceNb));
                        aMask = roiTemplateToMask(atRoiTemplate{dRoiTagOffset}, imBuffer(:,:,atRoiTemplate{dRoiTagOffset}.SliceNb));
                        
                    end
                       
                    if strcmpi(sMaskType, 'Inside This Contour')

                        
                       imBuffer = cropInside(aMask, ...
                                              imBuffer, ...
                                              atRoiTemplate{dRoiTagOffset}.SliceNb, ...
                                              atRoiTemplate{dRoiTagOffset}.Axe ...
                                              );    
                    end

                    if strcmpi(sMaskType, 'Outside This Contour')
                                                
                        imBuffer = cropOutside(aMask, ...
                                               imBuffer, ...
                                               atRoiTemplate{dRoiTagOffset}.SliceNb, ...
                                               atRoiTemplate{dRoiTagOffset}.Axe ...
                                               );    
                    end                                                        
                end
            end

        end
        
        modifiedMatrixValueMenuOption('set', true);

        dicomBuffer('set', imBuffer); 

        setQuantification(dSeriesOffset);

        refreshImages();

        clear imBuffer;
%        progressBar(1, 'Ready');

    end               
end
   