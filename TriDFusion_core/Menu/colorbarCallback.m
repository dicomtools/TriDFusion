function colorbarCallback(hObject, ~)
%function colorbarCallback(~, ~)
%Display 2D Colorbar Menu.
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
    hObject.UIContextMenu = c;

    uimenu(c,'Label','parula'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','jet'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hsv'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hot'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','cool'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','spring'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','summer'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','autumn'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','winter'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','gray'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','invert linear','Callback',@setColorOffset);
    uimenu(c,'Label','bone'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','copper'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','pink'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','lines'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','colorcube'    ,'Callback',@setColorOffset);
    uimenu(c,'Label','prism'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','flag'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','pet'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hot metal'    ,'Callback',@setColorOffset);

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        dOffset = fusionColorMapOffset('get');
    else
        dOffset = colorMapOffset('get');
    end

    switch dOffset
        case 1
            set(findall(c,'Label','parula'), 'Checked', 'on');
        case 2
            set(findall(c,'Label','jet'), 'Checked', 'on');
        case 3
            set(findall(c,'Label','hsv'), 'Checked', 'on');
        case 4
            set(findall(c,'Label','hot'), 'Checked', 'on');
        case 5
            set(findall(c,'Label','cool'), 'Checked', 'on');
        case 6
            set(findall(c,'Label','spring'), 'Checked', 'on');                    
        case 7
            set(findall(c,'Label','summer'), 'Checked', 'on');
        case 8
            set(findall(c,'Label','autumn'), 'Checked', 'on');
        case 9
            set(findall(c,'Label','winter'), 'Checked', 'on');
        case 10
            set(findall(c,'Label','gray'), 'Checked', 'on');
        case 11
            set(findall(c,'Label','invert linear'), 'Checked', 'on');            
        case 12
            set(findall(c,'Label','bone'), 'Checked', 'on');
        case 13
            set(findall(c,'Label','copper'), 'Checked', 'on');                    
        case 14
            set(findall(c,'Label','pink'), 'Checked', 'on');
        case 15
            set(findall(c,'Label','lines'), 'Checked', 'on');
        case 16
            set(findall(c,'Label','colorcube'), 'Checked', 'on');
        case 17
            set(findall(c,'Label','prism'), 'Checked', 'on');
        case 18
            set(findall(c,'Label','flag'), 'Checked', 'on');
        case 19
            set(findall(c,'Label','pet'), 'Checked', 'on');                    
        case 20
            set(findall(c,'Label','hot metal'), 'Checked', 'on');
    end

    function setColorOffset(source, ~)

        if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
            iOffset = getColorMapOffset(get(source, 'Label'));
            fusionColorMapOffset('set', iOffset);
        else
            iOffset = getColorMapOffset(get(source, 'Label'));
            colorMapOffset('set', iOffset);
        end

        refreshColorMap();

    end
end        

