function setColorbarColormap(pColorbar, cMap)

    if isempty(pColorbar)
        return;
    end
    dHeight = round(pColorbar.Parent.Parent.Position(4));
    
    pColorbar.CData =  repmat(cat(3, cMap(:,1), cMap(:,2), cMap(:,3)), 1, dHeight);
end