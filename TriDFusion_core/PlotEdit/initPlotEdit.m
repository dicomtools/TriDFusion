function initPlotEdit()
%function initPlotEdit()
%Init plot edit main function.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atPlotEdit = plotEditTemplate('get', dSeriesOffset);

    if isempty(atPlotEdit)
        return;
    end
        
    idx = [];

    endLoop = numel(atPlotEdit);
    for bb=1:numel(atPlotEdit)
        
        if ~isempty(idx) % Multiple object

            if any(idx == bb)
                continue;
            end
        end

        curPlotEdit = atPlotEdit{bb};
        if isfield(curPlotEdit, 'Object') && ...
           ~isempty(curPlotEdit.Object)   && ...
           isvalid(curPlotEdit.Object)
            continue;
        end

        if mod(bb,25)==1 || bb == endLoop

            progressBar(bb/endLoop, sprintf('Processing object %d/%d', bb, endLoop));
        end

        if ~isempty(atPlotEdit{bb})
            
            switch lower(atPlotEdit{bb}.Axe)
                
                case 'axes1'
                axPlotEdit = axes1Ptr('get', [], dSeriesOffset);       
                
                case 'axes2'
                axPlotEdit = axes2Ptr('get', [], dSeriesOffset);       
                
                case 'axes3'
                axPlotEdit = axes3Ptr('get', [], dSeriesOffset);            
                
                case'axe'
                axPlotEdit = axePtr('get', [], dSeriesOffset);
                
                otherwise
                break;
                
            end
    
            set(fiMainWindowPtr('get'), 'CurrentAxes', axPlotEdit)

            % Multiple Object

            if strcmpi (atPlotEdit{bb}.MultiObject, 'multiple')

                sMultipleTag = atPlotEdit{bb}.MultiTag;

                adTagOffset = cellfun(@(h) strcmpi(h.MultiTag, sMultipleTag), atPlotEdit);
                idx = find(adTagOffset);
                nMatches = numel(idx);
                
                switch nMatches

                    case 2 % Double Arrow or Text arrow
                        
                        % Double Arrow 
                        if strcmpi(atPlotEdit{idx(1)}.Type, 'Quiver') && ...  
                           strcmpi(atPlotEdit{idx(2)}.Type, 'Quiver')   

                            interactiveArrow('showText', false, 'doubleArrow', true, atPlotEdit{idx(1)}, atPlotEdit{idx(2)});
                        else % Text Arrow
                            interactiveArrow('showText', true, 'doubleArrow', false, atPlotEdit{idx(1)}, atPlotEdit{idx(2)});
                        end

                    case 3 % Text Double Arrow
                        interactiveArrow('showText', true, 'doubleArrow', true, atPlotEdit{idx(1)}, atPlotEdit{idx(2)}, atPlotEdit{idx(3)});

                    otherwise
                        continue;
                end
                
                continue;          
            end

            % Single object

            switch lower(atPlotEdit{bb}.Type)

                case 'quiver' % Single Arrow 
                    interactiveArrow('showText', false, 'doubleArrow', false, atPlotEdit{bb});

                case 'text' % Text
                    interactiveText(atPlotEdit{bb});
            end

        end
    end

    % Clean up 
    atPlotEdit = plotEditTemplate('get', dSeriesOffset);

    for bb=1:numel(atPlotEdit)

        if (isfield(atPlotEdit{bb}, 'Object') && ~isvalid(atPlotEdit{bb}.Object)) || ...
           (isfield(atPlotEdit{bb}, 'Object') &&  isempty(atPlotEdit{bb}.Object)) || ...     
           ~isfield(atPlotEdit{bb}, 'Object') 
    
            atPlotEdit{bb} = [];
        end
    end
    
    atPlotEdit(cellfun(@isempty, atPlotEdit)) = [];

    plotEditTemplate('set', dSeriesOffset, atPlotEdit)

    progressBar(1, 'Ready');

end
