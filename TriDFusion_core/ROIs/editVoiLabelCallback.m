function editVoiLabelCallback(hObject, ~)
%function editVoiLabelCallback(hObject, ~)
%Edit VOI and assiciated ROIs Label.
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

    EDIT_DIALOG_X = 310;
    EDIT_DIALOG_Y = 100;

    editLabelWindow = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-EDIT_DIALOG_X/2) ...
               (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-EDIT_DIALOG_Y/2) ...
               EDIT_DIALOG_X ...
               EDIT_DIALOG_Y],...
               'Color', viewerBackgroundColor('get'), ...
               'Name', 'Edit Label'...
               );


    uicontrol(editLabelWindow,...
              'style'   , 'text',...
              'string'  , 'Label Name:',...
              'horizontalalignment', 'left',...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...   
              'position', [20 52 80 25]...
              );

    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value')); 

    gdVoiTagOffset = find(cellfun(@(c) any(strcmp(c.RoisTag, hObject.UserData.Tag)), atVoiInput), 1);
    
    if ~isempty(gdVoiTagOffset)

        sVoiLabel = atVoiInput{gdVoiTagOffset}.Label;

    else
        sVoiLabel = '';
    end    

    edtLabelName = ...
        uicontrol(editLabelWindow,...
              'style'     , 'edit',...
              'horizontalalignment', 'left',...
              'Background', 'white',...
              'string'    , sVoiLabel,...
              'position'  , [100 55 150 25], ...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...              
              'Callback', @acceptEditLabelCallback...
              );

    % Cancel or Proceed

    editLabelCancelWindow = ...
    uicontrol(editLabelWindow,...
             'String','Cancel',...
             'Position',[200 7 100 25],...
             'BackgroundColor', viewerBackgroundColor('get'), ...
             'ForegroundColor', viewerForegroundColor('get'), ...                
             'Callback', @cancelEditLabelCallback...
             );

    editLabelOkWindow = ...
    uicontrol(editLabelWindow,...
             'String','Ok',...
             'Position',[95 7 100 25],...
             'BackgroundColor', viewerBackgroundColor('get'), ...
             'ForegroundColor', viewerForegroundColor('get'), ...                
             'Callback', @acceptEditLabelCallback...
             );

    function cancelEditLabelCallback(~, ~)
        
        delete(editLabelWindow);
    end

    function acceptEditLabelCallback(~, ~)
        
        set(editLabelCancelWindow, 'Enable', 'off');
        set(editLabelOkWindow    , 'Enable', 'off');

        sLabel = get(edtLabelName, 'String');

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    
        atVoiInput = voiTemplate('get', dSeriesOffset);                
        atRoiInput = roiTemplate('get', dSeriesOffset);                
       
        if ~isempty(atVoiInput) 
            
            if ~isempty(gdVoiTagOffset)
    
                atVoiInput{gdVoiTagOffset}.Label = sLabel;
    
                dNbRois = numel(atVoiInput{gdVoiTagOffset}.RoisTag);
    
                for vv=1: dNbRois
    
                    dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{gdVoiTagOffset}.RoisTag{vv} ) );
    
                    if ~isempty(dRoiTagOffset) % Found the Tag 
    
                        atRoiInput{dRoiTagOffset}.Label = sprintf('%s (roi %d/%d)',sLabel, vv, dNbRois);
    
                        if isvalid(atRoiInput{dRoiTagOffset}.Object)
    
                            atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                        end
                                 
                    end
    
                end
    
                roiTemplate('set', dSeriesOffset, atRoiInput);
                voiTemplate('set', dSeriesOffset, atVoiInput);
                
                setVoiRoiSegPopup(); 
    
            end         
        end     
       
        delete(editLabelWindow);
                
   end

end
