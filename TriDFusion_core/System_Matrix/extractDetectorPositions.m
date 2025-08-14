function P2 = extractDetectorPositions(DIS, ND)

    for i = 1:ND
        P2(i, :) = DIS.(['Item_' num2str(i)]).RadialPosition;
    end
    
end