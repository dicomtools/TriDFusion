function rightClickMenu(sAction, objectPtr)
%function aObject = rightClickMenu(sAction, objectPtr)
%Get\Set R Pointer.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    persistent paContextMenu; 

    if     strcmpi('reset', sAction)
        paContextMenu = '';
        
    elseif strcmpi('on', sAction)        
        for ff=1:numel(paContextMenu)
            for gg=1:numel(paContextMenu{ff}.Children)
                paContextMenu{ff}.Children(gg).Visible = 'on';          
            end
        end         
        
    elseif strcmpi('off', sAction)
        for ff=1:numel(paContextMenu)
            for gg=1:numel(paContextMenu{ff}.Children)
                paContextMenu{ff}.Children(gg).Visible = 'off';          
            end
        end           
        
    elseif strcmpi('add', sAction)
        cm = uicontextmenu(fiMainWindowPtr('get'));
        uimenu(cm, 'Text', 'Paste Object', 'Callback', @pasteRoiCallback);
        uimenu(cm, 'Text', 'Hide Menu', 'Separator', 'on', 'Callback', @hideRoiMenuCallback);
        objectPtr.ContextMenu = cm;
                
        paContextMenu{numel(paContextMenu)+1} = objectPtr.ContextMenu;            
    end
    
    function hideRoiMenuCallback(~, ~)
        roiTemplate('set', '');
    end
    
end

