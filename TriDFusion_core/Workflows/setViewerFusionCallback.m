function setViewerFusionCallback(~, ~)
%function setViewerFusionCallback()
%Create a fuison between 2 modality, The tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = inputTemplate('get');
    aInputBuffer = inputBuffer('get');

    if numel(atInput) < 2
        progressBar(1, 'Error: Fusion requires at least two modalities.');
        errordlg('Error: Fusion requires at least two modalities!', 'Two modalities Validation');  
        return;
    end

   dSerie1Offset = [];
   dSerie2Offset = [];

    for ct=1:numel(atInput)
        if strcmpi(atInput(ct).atDicomInfo{1}.Modality, 'ct')
            dSerie2Offset = ct;
        end
    end
    

    if ~isempty(dSerie2Offset) % A CT exist

        for ii=1:numel(atInput) 

            if ii==dSerie2Offset
                continue;
            end

            if strcmpi(atInput(ii).atDicomInfo{1}.StudyInstanceUID, ... % Same Study
               atInput(dSerie2Offset).atDicomInfo{1}.StudyInstanceUID) 

               if size(aInputBuffer{ii}, 3) ~= 1 && ... % Can't fuse a CT with a 2D image
                  size(aInputBuffer{dSerie2Offset}, 3) ~= 1 

                    if strcmpi(atInput(ii).atDicomInfo{1}.Modality, 'ct') % The second series is also a CT
                        dSerie1Offset  = dSerie2Offset;                    
                        dSerie2Offset = ii;
                    else % Second series is a different modality
                        dSerie1Offset = ii;
                    end
                    break;
               end
            end
        end
    else
        
        for ii=1:numel(atInput) 

            if ii+1 > numel(atInput)
                break;
            end

            if strcmpi(atInput(ii).atDicomInfo{1}.StudyInstanceUID, ... % Same Study
               atInput(ii+1).atDicomInfo{1}.StudyInstanceUID) 

                if size(aInputBuffer{ii}, 3) == 1 && ... % Two 2D image
                   size(aInputBuffer{ii+1}, 3) == 1 

                    dSerie1Offset = ii;
                    dSerie2Offset = ii+1;
                    break;
                else
                    if size(aInputBuffer{ii}, 3) ~= 1 && ... % Two 3D image
                          size(aInputBuffer{ii+1}, 3) ~= 1 
                            dSerie1Offset = ii;
                            dSerie2Offset = ii+1;                       
                        break;
                   end
                end
            end
        end
       
    end
    
    if isempty(dSerie1Offset) || isempty(dSerie2Offset)
        progressBar(1, 'Error: Unable to find two modalities for fusion.');
        errordlg('Error: Unable to find two modalities for fusion!', 'Fusion Validation');  
    else
        sModality1 = atInput(dSerie1Offset).atDicomInfo{1}.Modality;
        sModality2 = atInput(dSerie2Offset).atDicomInfo{1}.Modality;

        if strcmpi(sModality1, 'ct')
            dMin1 = 50;
            dMax1 = 500;      
        else
            dMin1 = 0;
            dMax1 = 7; 
        end

        if strcmpi(sModality2, 'ct')
            dMin2 = 50;
            dMax2 = 500;      
        else
            dMin2 = 0;
            dMax2 = 7; 
        end

        setModalitiesFusion(sModality1, dMin1, dMax1, dMin1, dMax1, sModality2, dMin2, dMax2, dMin2, dMax2, false, true, dSerie1Offset, dSerie2Offset);
    end
    
    clear aInputBuffer;
  
end