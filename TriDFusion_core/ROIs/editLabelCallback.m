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
               'Name', 'Edit Label'...
               );

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(editLabelWindow, 'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));  

    uicontrol(editLabelWindow,...
              'style'   , 'text',...
              'string'  , 'Label Name:',...
              'horizontalalignment', 'left',...
              'position', [20 52 80 25]...
              );

    edtLabelName = ...
        uicontrol(editLabelWindow,...
              'style'     , 'edit',...
              'horizontalalignment', 'left',...
              'Background', 'white',...
              'string'    , hObject.UserData.Label,...
              'position'  , [100 55 150 25], ...
              'Callback', @acceptEditLabelCallback...
              );

    % Cancel or Proceed

   uicontrol(editLabelWindow,...
             'String','Cancel',...
             'Position',[200 7 100 25],...
             'Callback', @cancelEditLabelCallback...
             );

   uicontrol(editLabelWindow,...
             'String','Ok',...
             'Position',[95 7 100 25],...
             'Callback', @acceptEditLabelCallback...
             );

   function cancelEditLabelCallback(~, ~)
        delete(editLabelWindow);
   end

   function acceptEditLabelCallback(~, ~)
       
        hObject.UserData.Label = get(edtLabelName, 'String');
        
        atRoi = roiTemplate('get');

        for bb=1:numel(atRoi)
            if strcmpi(hObject.UserData.Tag, atRoi{bb}.Tag)
                atRoi{bb}.Label = hObject.UserData.Label;
                roiTemplate('set', atRoi);
                break;
            end
        end 
    
        delete(editLabelWindow);
   end

   setVoiRoiSegPopup();

end
