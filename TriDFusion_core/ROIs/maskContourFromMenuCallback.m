function maskContourFromMenuCallback(hObject, ~)
%function maskContourFromMenuCallback(hObject, ~)
%Mask a ROI or VOI, the function is called from a menu.
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

    imBuffer = dicomBuffer('get');  
    if isempty(imBuffer)        
        return;
    end

    sMaskType = get(hObject, 'Label');
    sMaskTag  = get(hObject, 'UserData'); 

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if ~isempty(atRoi)

        aTagOffset = strcmp( cellfun( @(atVoi) atVoi.Tag, atVoi, 'uni', false ), {sMaskTag} );

        if aTagOffset(aTagOffset==1) % tag is a voi

            dNbRoiTag = numel(atVoi{aTagOffset}.RoisTag);

            for tt=1:dNbRoiTag % Scan all tag
                
                aRoiTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {[atVoi{aTagOffset}.RoisTag{tt}]} );
                dRoiTagOffset = find(aRoiTagOffset, 1);           
           
                if ~isempty(dRoiTagOffset)
                    
                    switch lower(atRoi{dRoiTagOffset}.Axe)
                        
                        case 'axe'
                        aMask = createMask(atRoi{dRoiTagOffset}.Object, imBuffer(:,:));

                        case 'axes1'
                        aMask = createMask(atRoi{dRoiTagOffset}.Object, permute(imBuffer(atRoi{dRoiTagOffset}.SliceNb,:,:), [3 2 1]));

                        case 'axes2'
                        aMask = createMask(atRoi{dRoiTagOffset}.Object, permute(imBuffer(:,atRoi{dRoiTagOffset}.SliceNb,:), [3 1 2]));

                        case 'axes3'
                        aMask = createMask(atRoi{dRoiTagOffset}.Object, imBuffer(:,:,atRoi{dRoiTagOffset}.SliceNb));
                        
                    end
                       
                    if strcmpi(sMaskType, 'Inside This Contour')

                        
                       imBuffer = cropInside(aMask, ...
                                              imBuffer, ...
                                              atRoi{dRoiTagOffset}.SliceNb, ...
                                              atRoi{dRoiTagOffset}.Axe ...
                                              );    
                    end

                    if strcmpi(sMaskType, 'Outside This Contour')

                        imBuffer = cropOutside(aMask, ...
                                               imBuffer, ...
                                               atRoi{dRoiTagOffset}.SliceNb, ...
                                               atRoi{dRoiTagOffset}.Axe ...
                                               );    
                    end                                                        
                end
            end
            
        else % tag is a roi

            aRoiTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {sMaskTag} );
            dRoiTagOffset = find(aRoiTagOffset, 1);  
                
            if ~isempty(dRoiTagOffset)
                
                switch lower(atRoi{dRoiTagOffset}.Axe)
                   
                    case 'axe'
                    aMask = createMask(atRoi{dRoiTagOffset}.Object, imBuffer(:,:));

                    case 'axes1'
                    aMask = createMask(atRoi{dRoiTagOffset}.Object, permute(imBuffer(atRoi{dRoiTagOffset}.SliceNb,:,:), [3 2 1]));

                    case 'axes2'
                    aMask = createMask(atRoi{dRoiTagOffset}.Object, permute(imBuffer(:,atRoi{dRoiTagOffset}.SliceNb,:), [3 1 2]));

                    case 'axes3'
                    aMask = createMask(atRoi{dRoiTagOffset}.Object, imBuffer(:,:,atRoi{dRoiTagOffset}.SliceNb));
                end

                if strcmpi(sMaskType, 'Inside This Contour')
                
                    imBuffer = cropInside(aMask, ...
                                          imBuffer, ...
                                          atRoi{dRoiTagOffset}.SliceNb, ...
                                          atRoi{dRoiTagOffset}.Axe ...
                                          );    
                end

                if strcmpi(sMaskType, 'Outside This Contour')

                    imBuffer = cropOutside(aMask, ...
                                           imBuffer, ...
                                           atRoi{dRoiTagOffset}.SliceNb, ...
                                           atRoi{dRoiTagOffset}.Axe ...
                                           );    
                end

                if strcmpi(sMaskType, 'Inside Every Slice')

                    dBufferSize = size(imBuffer);   
                    
                    switch lower(atRoi{dRoiTagOffset}.Axe)

                        case 'axes1'
                        dLastSliceNb = dBufferSize(1);                            

                        case 'axes2'
                        dLastSliceNb = dBufferSize(2);                            

                        case 'axes3'
                        dLastSliceNb = dBufferSize(3);
                    end

                    for dSliceNb=1:dLastSliceNb
                        
                        imBuffer = cropInside(aMask, ...
                                              imBuffer, ...
                                              dSliceNb, ...
                                              atRoi{dRoiTagOffset}.Axe ...
                                              );   
                    end                                
                end

                if strcmpi(sMaskType, 'Outside Every Slice')

                    dBufferSize = size(imBuffer);   
                    
                    switch lower(atRoi{dRoiTagOffset}.Axe)

                        case 'axes1'
                        dLastSliceNb = dBufferSize(1);

                        case 'axes2'
                        dLastSliceNb = dBufferSize(2);

                        case 'axes3'
                        dLastSliceNb = dBufferSize(3);
                    end

                    for dSliceNb=1:dLastSliceNb
                        imBuffer = cropOutside(aMask, ...
                                               imBuffer, ...
                                               dSliceNb, ...
                                               atRoi{dRoiTagOffset}.Axe ...
                                               ); 
                    end
                end                            
            end
        end

        dicomBuffer('set', imBuffer); 

        setQuantification(get(uiSeriesPtr('get'), 'Value'));

        refreshImages();

        progressBar(1, 'Ready');

    end               
end
   