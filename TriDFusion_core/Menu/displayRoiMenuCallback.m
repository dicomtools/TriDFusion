function displayRoiMenuCallback(src)

    if isscalar(src.Children)

        voiDefaultMenu(src);

        roiDefaultMenu(src);

        uimenu(src,'Label', 'Hide/View Face Alpha', 'UserData',src.UserData, 'Callback', @hideViewFaceAlhaCallback);
        uimenu(src,'Label', 'Clear Waypoints'     , 'UserData',src.UserData, 'Callback', @clearWaypointsCallback  );

        constraintMenu(src);

        cropMenu(src);

        uimenu(src,'Label', 'Display Statistics' , 'UserData', src.UserData, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    else

        if strcmpi(src.UserData.UserData, 'voi-roi')

            dExpendedMenuIndex = find(strcmpi({src.UserData.ContextMenu.Children.Label}, 'Expanded Menu...'), 1);

            if ~isempty(dExpendedMenuIndex)

                % Find the Volume-of-interest folder

                dVoiFolderIndex = find(strcmpi({src.UserData.ContextMenu.Children(dExpendedMenuIndex).Children.Label}, 'Volume-of-interest'), 1);

                if ~isempty(dVoiFolderIndex)

                    % Activate mVoiFolder

                    if strcmpi(src.UserData.ContextMenu.Children(dExpendedMenuIndex).Children(dVoiFolderIndex).Visible, 'off')

                        set(src.UserData.ContextMenu.Children(dExpendedMenuIndex).Children(dVoiFolderIndex), 'Visible', 'on');

                        % Get children of the mVoiFolder

                        children = src.UserData.ContextMenu.Children(dExpendedMenuIndex).Children(dVoiFolderIndex).Children;

                        % Activate mVoiConstraint & mVoiMask

                        set(children, 'Visible', 'on');

                        % Set both Mask and Constraint submenus

                        for childIdx = 1:numel(children)

                            set(children(childIdx).Children, 'Visible', 'on');
                        end
                    end
                end
            end
        end
    end

end
