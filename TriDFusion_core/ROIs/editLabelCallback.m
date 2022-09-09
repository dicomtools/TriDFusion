function editLabelCallback(hObject, ~)
%function editLabelCallback(hObject, ~)
%Edit ROIs VOIs Label.
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

    edtLabelName = ...
        uicontrol(editLabelWindow,...
              'style'     , 'edit',...
              'horizontalalignment', 'left',...
              'Background', 'white',...
              'string'    , hObject.UserData.Label,...
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

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
        atInput = inputTemplate('get');

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));     
        
        if isempty(atRoiInput) 
            aTagOffset = 0;
        else
            aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {hObject.UserData.Tag} );            
        end
        
        if aTagOffset(aTagOffset==1) % tag is a roi

            dTagOffset = find(aTagOffset, 1);

            if ~isempty(dTagOffset)

                hObject.UserData.Label = sLabel;

                atRoiInput{dTagOffset}.Color = sLabel;
                if isvalid(atRoiInput{dTagOffset}.Object)
                    atRoiInput{dTagOffset}.Object.Label = sLabel;
                end

                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
            end

            % Set roi label input template tRoi

            if isfield(atInput(dSerieOffset), 'tRoi')

                atInputRoi = atInput(dSerieOffset).tRoi;
                aTagOffset = strcmp( cellfun( @(atInputRoi) atInputRoi.Tag, atInputRoi, 'uni', false ), {hObject.UserData.Tag} );      

                dTagOffset = find(aTagOffset, 1);

                if ~isempty(dTagOffset)
                    atInput(dSerieOffset).tRoi{dTagOffset}.Label = sLabel;
                    inputTemplate('set', atInput);                
                end
            end                        
            
%            setVoiRoiSegPopup(); Not need for ROI
        end        
       
        delete(editLabelWindow);
                
   end

end
