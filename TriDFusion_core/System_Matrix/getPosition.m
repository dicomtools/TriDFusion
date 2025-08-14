function [Posi, Dist, Lu] = getPosition(Raio, x, y, Seq1, ND, ang, nRaios)

Lu = zeros(size(x,1),2*size(y,2),2,ND);

a = double(x>-Raio & x<Raio);
b = double(y>-Raio & y<Raio);

a(a==0) = NaN;
b(b==0) = NaN;

Dist = zeros(size(x,1),2*size(y,2)-1,2);

for det = 1:ND

    v(:,:,1) = x(:,:,det).*a(:,:,det);
    v(:,:,2) = Seq1.*a(:,:,det);
    
    h(:,:,1) = Seq1.*b(:,:,det);
    h(:,:,2) = y(:,:,det).*b(:,:,det);
    
    vet1 = [v h];  

    [Posi, interval1, interval2] = sortPosition(ang, vet1, nRaios); 
    
    Dist(:,:,det) = (sqrt(diff(Posi(:,:,1),1,2).^2 + diff(Posi(:,:,2),1,2).^2)).*10^-3;
    
    Lu = getLu(Posi, Lu, det, Raio, interval1, interval2);


end

end
