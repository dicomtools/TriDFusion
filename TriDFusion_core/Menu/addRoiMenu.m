                    
function addRoiMenu(ptrRoi)
    % if 0
    b = uimenu(ptrRoi.UIContextMenu, ...
               'Label'          , 'Expanded Menu...', ...
               'UserData'       , ptrRoi, ...
               'MenuSelectedFcn', @(src, event) displayRoiMenuCallback(src) ...
               );

    uimenu(b,'Label', 'Expanded Menu...', 'Visible', 'off'); % Dummy menu
    % else
    %     ptrRoi.UIContextMenu.ContextMenuOpeningFcn = @(src, event) displayRoiMenuCallback(src);
    % end
end