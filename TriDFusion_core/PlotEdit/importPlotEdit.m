function importPlotEdit(jsonText)
%function importPlotEdit(jsonText)
%Import plot edit from a json text file.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    try

    atInput = inputTemplate('get');
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if isempty(atInput)
        return;
    end

    jsonText = regexprep(jsonText, '[\x00\s]+$', '');
    atPlotEditRaw = jsondecode(jsonText);
    
    if isstruct(atPlotEditRaw)
        
        atPlotEditRaw = num2cell(atPlotEditRaw);
    end

    if numel(atPlotEditRaw) > 1
        uids = cellfun(@(s) s.SeriesInstanceUID, atPlotEditRaw, 'UniformOutput', false);
        
        % Find the unique UIDs and an index vector
        [uniqueUIDs, ~, ic] = unique(uids);
        
        groupsPlotEdit = cell(numel(uniqueUIDs),1);
        
        for k = 1:numel(uniqueUIDs)
            groupsPlotEdit{k} = atPlotEditRaw(ic == k);
        end
    else
        groupsPlotEdit{1} = atPlotEditRaw;
    end

    for pe=1:numel(groupsPlotEdit) % Nb series

        for di = 1:numel(atInput)

            atPlotEdit = groupsPlotEdit{pe};
            if isstruct(atPlotEdit)
                atPlotEdit = {atPlotEdit};
            end        

            if strcmpi(atPlotEdit{1}.SeriesInstanceUID, atInput(di).atDicomInfo{1}.SeriesInstanceUID) % Series found

                atCurPlotEdit = plotEditTemplate('get', di);
                if ~isempty(atCurPlotEdit)
                    atPlotEdit = vertcat(atPlotEdit, atCurPlotEdit);
                end
                plotEditTemplate('set', di, atPlotEdit);

                if di == dSeriesOffset 
                    initPlotEdit();
                    refreshImages();
                end
                break;
            end
        end
    end

    catch ME
       logErrorToFile(ME);  
       progressBar(1, 'Error:importPlotEdit()');                          
    end
end