function alphaCurveMenu(axeAlphmap, sObject)
%function alphaCurveMenu(axeAlphmap, sObject)
%Set the alpha curve menu.
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

    c = uicontextmenu(fiMainWindowPtr('get'));                           

    axeAlphmap.UIContextMenu = c;
    c.UserData = sObject;

%     uiMoveMarker   = uimenu(c,'Label','Move Marker'  , 'Checked', 'on', 'Callback',@setAlphaCurveAction);
%     uiInsertMarker = uimenu(c,'Label','Insert Marker', 'Callback',@setAlphaCurveAction);
%     uiDeleteMarker = uimenu(c,'Label','Delete Marker', 'Callback',@setAlphaCurveAction);

    uimenu(c,'Label','Move Marker'  , 'Checked', 'on', 'Callback',@setAlphaCurveAction);
    uimenu(c,'Label','Insert Marker', 'Callback',@setAlphaCurveAction);
    uimenu(c,'Label','Delete Marker', 'Callback',@setAlphaCurveAction);

    function setAlphaCurveAction(hObject, ~)
        switch hObject.Label
            case 'Move Marker'   
%                 hObject.Checked = 'on';
%                 uiInsertMarker.Checked = 'off';
%                 uiDeleteMarker.Checked = 'off';   
                dMouseMode = 1;

            case 'Insert Marker'           
%                 hObject.Checked = 'on';
%                 uiMoveMarker.Checked   = 'off';
%                 uiDeleteMarker.Checked = 'off';  
                dMouseMode = 2;

            case 'Delete Marker'           
%                  hObject.Checked = 'on';
%                 uiInsertMarker.Checked = 'off';
%                 uiMoveMarker.Checked   = 'off';                         
                dMouseMode = 3;                        
        end

      %  uiMoveMarker.Checked = 'on';

        if strcmp(hObject.Parent.UserData, 'vol')

            volICObj = volICObject('get');
            if ~isempty(volICObj)
                volICObj.mouseMode = dMouseMode;
            end
        elseif strcmp(hObject.Parent.UserData, 'mip')
            mipICObj = mipICObject('get');
            if ~isempty(mipICObj)
                mipICObj.mouseMode = dMouseMode;
            end  
        elseif strcmp(hObject.Parent.UserData, 'mipfusion')
            mipICFusionObj = mipICFusionObject('get');
            if ~isempty(mipICFusionObj)
                mipICFusionObj.mouseMode = dMouseMode;
            end               
        elseif strcmp(hObject.Parent.UserData, 'volfusion')
            volICFusionObj = volICFusionObject('get');
            if ~isempty(volICFusionObj)
                volICFusionObj.mouseMode = dMouseMode;
            end               
        end        
    end

end