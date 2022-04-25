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

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if ~isempty(tVoiInput) || ...
       ~isempty(tRoiInput)

        bIsVoiTag= false;

        for aa=1:numel(tVoiInput)

            if strcmp(tVoiInput{aa}.Tag, sMaskTag) % Tag is a VOI

                bIsVoiTag = true;

                dNbRoiTag = numel(tVoiInput{aa}.RoisTag);

                for tt=1:dNbRoiTag % Scan all tag

                    for uu=1:numel(tRoiInput)

                        if strcmp(tVoiInput{aa}.RoisTag{tt}, tRoiInput{uu}.Tag) % VOI\ROI tag found

                            if strcmpi(sMaskType, 'Inside This Contour')

                               imBuffer = cropInside(tRoiInput{uu}.Object, ...
                                                      imBuffer, ...
                                                      tRoiInput{uu}.SliceNb, ...
                                                      tRoiInput{uu}.Axe ...
                                                      );    

                               progressBar(tt / dNbRoiTag, 'Mask inside in progress');

                            end

                            if strcmpi(sMaskType, 'Outside This Contour')

                                imBuffer = cropOutside(tRoiInput{uu}.Object, ...
                                                       imBuffer, ...
                                                       tRoiInput{uu}.SliceNb, ...
                                                       tRoiInput{uu}.Axe ...
                                                       );    

                               progressBar(tt / dNbRoiTag, 'Mask outside in progress');
                            end                                    

                            break;
                        end
                    end
                end

                break;
            end
        end

        if bIsVoiTag == false % Tag is a ROI
            for aa=1:numel(tRoiInput)
                if strcmp(tRoiInput{aa}.Tag, sMaskTag) % Tag is a ROI

                    if strcmpi(sMaskType, 'Inside This Contour')

                        imBuffer = cropInside(tRoiInput{aa}.Object, ...
                                              imBuffer, ...
                                              tRoiInput{aa}.SliceNb, ...
                                              tRoiInput{aa}.Axe ...
                                              );    
                    end

                    if strcmpi(sMaskType, 'Outside This Contour')

                        imBuffer = cropOutside(tRoiInput{aa}.Object, ...
                                               imBuffer, ...
                                               tRoiInput{aa}.SliceNb, ...
                                               tRoiInput{aa}.Axe ...
                                               );    
                    end

                    if strcmpi(sMaskType, 'Inside Every Slice')

                        dBufferSize = size(imBuffer);   

                        if     strcmpi(tRoiInput{aa}.Axe, 'Axes1')
                            dLastSliceNb = dBufferSize(1);
                        elseif strcmpi(tRoiInput{aa}.Axe, 'Axes2')
                            dLastSliceNb = dBufferSize(2);
                        elseif strcmpi(tRoiInput{aa}.Axe, 'Axes3')
                            dLastSliceNb = dBufferSize(3);
                        else
                            break;
                        end

                        for dSliceNb=1:dLastSliceNb
                            imBuffer = cropInside(tRoiInput{aa}.Object, ...
                                                   imBuffer, ...
                                                   dSliceNb, ...
                                                   tRoiInput{aa}.Axe ...
                                                   );   

                            progressBar(dSliceNb / dLastSliceNb, 'Mask inside in progress');

                        end                                
                    end

                    if strcmpi(sMaskType, 'Outside Every Slice')

                        dBufferSize = size(imBuffer);   

                        if     strcmpi(tRoiInput{aa}.Axe, 'Axes1')
                            dLastSliceNb = dBufferSize(1);
                        elseif strcmpi(tRoiInput{aa}.Axe, 'Axes2')
                            dLastSliceNb = dBufferSize(2);
                        elseif strcmpi(tRoiInput{aa}.Axe, 'Axes3')
                            dLastSliceNb = dBufferSize(3);
                        else
                            break;
                        end

                        for dSliceNb=1:dLastSliceNb
                            imBuffer = cropOutside(tRoiInput{aa}.Object, ...
                                                   imBuffer, ...
                                                   dSliceNb, ...
                                                   tRoiInput{aa}.Axe ...
                                                   ); 

                            progressBar(dSliceNb / dLastSliceNb, 'Mask outside in progress');

                        end
                    end                            

                break;
                end
            end
        end

        dicomBuffer('set', imBuffer); 

        iOffset = get(uiSeriesPtr('get'), 'Value');
        setQuantification(iOffset);

        refreshImages();

        progressBar(1, 'Ready');

    end               
end
   