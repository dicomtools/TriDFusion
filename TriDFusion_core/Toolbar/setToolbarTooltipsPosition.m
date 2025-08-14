function setToolbarTooltipsPosition(panelH)

    for c = panelH.Children(:)'
        if strcmp(get(c,'Type'),'axes') % Set the tooltip

            hIcon = findobj(c,'Tag','toolbarIconBtn');
            if ~isempty(hIcon)

                setToolbarObjectTooltipPosition(panelH, hIcon);
            end
        end    
    end

end