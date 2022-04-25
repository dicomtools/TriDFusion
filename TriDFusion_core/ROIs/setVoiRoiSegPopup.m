function setVoiRoiSegPopup()
%function setVoiRoiSegPopup()
%Init Segmentation ROI VOI Popup Menu .
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

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    uiDeleteVoiRoiPanel = uiDeleteVoiRoiPanelObject('get');

    uiPrevVoiRoiPanel = uiPrevVoiRoiPanelObject('get');
    uiDelVoiRoiPanel  = uiDelVoiRoiPanelObject('get');
    uiNextVoiRoiPanel = uiNextVoiRoiPanelObject('get');

    asVOIsList = repmat({''},numel(tVoiInput),1);
    dNbVOIs = numel(tVoiInput);

    if ~isempty(tVoiInput)

        for aa=1:dNbVOIs
            asVOIsList{aa} = tVoiInput{aa}.Label;
            
            for rr=1:numel(tVoiInput{aa}.RoisTag) % Enable VOI right click menu 
                for rt=1:numel(tRoiInput)
                    if strcmp(tRoiInput{rt}.Tag, tVoiInput{aa}.RoisTag{rr})
                        voiDefaultMenu(tRoiInput{rt}.Object, tVoiInput{aa}.Tag);                      
                        break;
                    end
                end
            end
            
        end

        if numel(asVOIsList) ~= 0

            dVoiOffset = get(uiDeleteVoiRoiPanel, 'Value');
            if dVoiOffset > dNbVOIs
                set(uiDeleteVoiRoiPanel, 'Value', 1);
            end

            set(uiDeleteVoiRoiPanel, 'Enable', 'on');
            set(uiDeleteVoiRoiPanel, 'String', asVOIsList);

            set(uiPrevVoiRoiPanel, 'Enable', 'on');
            set(uiDelVoiRoiPanel , 'Enable', 'on');
            set(uiNextVoiRoiPanel, 'Enable', 'on');
        else
            set(uiDeleteVoiRoiPanel, 'Value' , 1);
            set(uiDeleteVoiRoiPanel, 'Enable', 'off');
            set(uiDeleteVoiRoiPanel, 'String', ' ');

            set(uiPrevVoiRoiPanel, 'Enable', 'off');
            set(uiDelVoiRoiPanel , 'Enable', 'off');
            set(uiNextVoiRoiPanel, 'Enable', 'off');
        end
    else
        set(uiDeleteVoiRoiPanel, 'Value' , 1);
        set(uiDeleteVoiRoiPanel, 'Enable', 'off');
        set(uiDeleteVoiRoiPanel, 'String', ' ');

        set(uiPrevVoiRoiPanel, 'Enable', 'off');
        set(uiDelVoiRoiPanel , 'Enable', 'off');
        set(uiNextVoiRoiPanel, 'Enable', 'off');
    end

end
