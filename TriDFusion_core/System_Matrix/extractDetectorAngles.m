function Degree = extractDetectorAngles(DIS, ND)

    for i = 1:ND
        Degree(i) = DIS.(['Item_' num2str(i)]).StartAngle;
    end
    
end