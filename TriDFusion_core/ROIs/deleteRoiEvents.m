function deleteRoiEvents(hObject, ~)
%function deleteRoiEvents(hObject,~)  
%Delete ROI\VOI Event.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    tDeleteInput = inputTemplate('get');        
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tDeleteInput)  
        return;
    end

    for bb=1:numel(tDeleteInput(iOffset).tRoi)
        if strcmpi(hObject.Tag, tDeleteInput(iOffset).tRoi{bb}.Tag)

            if isfield(tDeleteInput(iOffset), 'tVoi')
                for vv=1:numel(tDeleteInput(iOffset).tVoi)
                    for tt=1:numel(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                        if strcmpi(tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt}, hObject.Tag)
                            tDeleteInput(iOffset).tVoi{vv}.RoisTag{tt} = [];
                            tDeleteInput(iOffset).tVoi{vv}.RoisTag(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.RoisTag)) = [];  

                            tDeleteInput(iOffset).tVoi{vv}.tMask{tt} = [];
                            tDeleteInput(iOffset).tVoi{vv}.tMask(cellfun(@isempty, tDeleteInput(iOffset).tVoi{vv}.tMask)) = [];  

                            if isempty(tDeleteInput(iOffset).tVoi{vv}.RoisTag)
                                tDeleteInput(iOffset).tVoi{vv} = [];
                                tDeleteInput(iOffset).tVoi(cellfun(@isempty, tDeleteInput(iOffset).tVoi)) = [];  
                            end

                            if isempty(tDeleteInput(iOffset).tVoi)
                               voiTemplate('set', '');
                            else
                               voiTemplate('set', tDeleteInput(iOffset).tVoi);
                            end    

                            break;
                        end
                    end
                end
            end

            tDeleteInput(iOffset).tRoi{bb} = [];
            tDeleteInput(iOffset).tRoi(cellfun(@isempty, tDeleteInput(iOffset).tRoi)) = [];     
            
            if ~isempty(copyRoiPtr('get'))
                if strcmpi(get(hObject, 'Tag'), get(copyRoiPtr('get'), 'Tag'))
                    copyRoiPtr('set', '');
                end
                
            end

            if isempty(tDeleteInput(iOffset).tRoi)
                roiTemplate('set', '');
            else
                roiTemplate('set', tDeleteInput(iOffset).tRoi);
            end     

            inputTemplate('set', tDeleteInput);

            break;
        end
    end

    setVoiRoiSegPopup();

end