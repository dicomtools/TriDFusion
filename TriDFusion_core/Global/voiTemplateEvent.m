function atVoi = voiTemplateEvent(sAction, dSeriesOffset, atTemplate, atEventTemplate, dUID)
%function atVoi = voiTemplateEvent(sAction, dSeriesOffset, atTemplate, atEventTemplate, dUID)
%Get\Set VOI Template Undo Event.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    persistent patVoi;   

    if strcmpi('add', sAction)

        if ~exist('dNbEvents', 'var')
            dNbEvents = 1;
        end

        if ~isempty(patVoi) && ...
           numel(patVoi) >= dSeriesOffset && ...
           isfield(patVoi{dSeriesOffset}, 'Event')

            dEventOffset = numel(patVoi{dSeriesOffset}.Event)+1;
        else
            dEventOffset = 1;           
        end

        % patVoi{dSeriesOffset}.Event{dEventOffset} = [];

        nTemp  = numel(atTemplate);
        nEvent = numel(atEventTemplate);
        
        % Extract the Tag field from each structure in the cell arrays
        if ~isempty(atTemplate)
            tagsTemplate = cellfun(@(s) s.Tag, atTemplate, 'UniformOutput', false);
        else
            tagsTemplate = [];
        end

        if ~isempty(atEventTemplate)      
            tagsEvent = cellfun(@(s) s.Tag, atEventTemplate, 'UniformOutput', false);
        else
            tagsEvent = [];  
        end
        
        if ~(isempty(tagsTemplate) && isempty(tagsEvent))

            tEvent = [];
            indiceOffset = 1;
    
            if nTemp > nEvent
                
                % Find tags that are in atTemplate but not in atEventTemplate (deleted tags)
                acDeletedTags = setdiff(tagsTemplate, tagsEvent, 'stable');
    
                dNbTags = numel(acDeletedTags);
    
                for idx = 1:dNbTags
                    
                    dTagOffset = find(strcmp( cellfun( @(atTemplate) atTemplate.Tag, atTemplate, 'uni', false ), acDeletedTags(idx) ), 1);
    
                    if ~isempty(dTagOffset)

                        tEvent.Value{indiceOffset}  = atTemplate{dTagOffset};
                        tEvent.Action{indiceOffset} = 'deleted';  
                        tEvent.NbEvents = dNbEvents;
                        tEvent.UID      = dUID;

                        indiceOffset = indiceOffset+1;
                    end
                end
    
                patVoi{dSeriesOffset}.Event{dEventOffset} = tEvent;
    
            elseif nEvent > nTemp
    
                acNewTags = setdiff(tagsEvent, tagsTemplate, 'stable');
    
                dNbTags = numel(acNewTags);
    
                for idx = 1:dNbTags
                    
                    dTagOffset = find(strcmp( cellfun( @(atEventTemplate) atEventTemplate.Tag, atEventTemplate, 'uni', false ), acNewTags(idx) ), 1);
    
                    if ~isempty(dTagOffset)

                        tEvent.Value{indiceOffset}    = atEventTemplate{dTagOffset};
                        tEvent.Action{indiceOffset}   = 'added';  
                        tEvent.NbEvents = dNbEvents;
                        tEvent.UID      = dUID;

                        indiceOffset = indiceOffset+1;
                    end
                end        
                
                patVoi{dSeriesOffset}.Event{dEventOffset} = tEvent;
            else
                adDiffIndices = find(~cellfun(@isequal, atTemplate, atEventTemplate), 1);
    
                if ~isempty(adDiffIndices)
    
                    for idx = adDiffIndices
                    
                        tEvent.Value{indiceOffset}    = atTemplate{idx};
                        tEvent.Action{indiceOffset}   = 'modified';
                        tEvent.NbEvents = dNbEvents;
                        tEvent.UID      = dUID;

                        indiceOffset = indiceOffset+1;
                    end
        
                    patVoi{dSeriesOffset}.Event{dEventOffset} = tEvent;
                end
            end
        end

   elseif strcmpi('set', sAction)
        
        patVoi{dSeriesOffset} = atTemplate; 

    elseif strcmpi('reset', sAction)    
        
        if exist('dSeriesOffset', 'var') % Clear one series
            patVoi{dSeriesOffset} = [];
        else    
            for aa=1:numel(patVoi)
                patVoi{aa} = [];
            end          
        end
    else
        if numel(patVoi) < dSeriesOffset
            atVoi = '';
        else
            atVoi = patVoi{dSeriesOffset};
        end      
    end  
    
end  