function Scatter = scatter_correctionTEW(NEW, Window, I1)

switch NEW
    case 1

        E1 = Window.Item_1.EnergyWindowRangeSequence.Item_1;
        energyWindow = E1;

    case 2

        E1 = Window.Item_1.EnergyWindowRangeSequence.Item_1;
        E2 = Window.Item_2.EnergyWindowRangeSequence.Item_1;
        energyWindow = [E1, E2];

    case 3

        E1 = Window.Item_1.EnergyWindowRangeSequence.Item_1;
        E2 = Window.Item_2.EnergyWindowRangeSequence.Item_1;
        E3 = Window.Item_3.EnergyWindowRangeSequence.Item_1;
        energyWindow = [E1, E2, E3];
end

Cl = I1(:,:,size(I1,3)/3+1:2*size(I1,3)/NEW);
Ch = I1(:,:,2*size(I1,3)/NEW+1:end);

Wm = energyWindow(1).EnergyWindowUpperLimit - energyWindow(1).EnergyWindowLowerLimit;
Wl = energyWindow(2).EnergyWindowUpperLimit - energyWindow(2).EnergyWindowLowerLimit;
Wh = energyWindow(3).EnergyWindowUpperLimit - energyWindow(3).EnergyWindowLowerLimit;

SC = (Cl+Ch)./(Wl+Wh).*Wm;

b = flip(flip(permute(SC, [3 2 1 4]), 1));

b1 = flip(permute(b, [2 1 3]),3);

Scatter = double(b1(:));

end
