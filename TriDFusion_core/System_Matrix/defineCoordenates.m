function [x, y, ang1, Seq, Seq1, x0, ang] = defineCoordenates(Degree, NFrames, P2, Arc, nRaios, ROOT, Field, Raio, PixelSize, ND, Rotation, Dim)

Seq=round(-Raio:PixelSize*(nRaios/Dim):Raio,40);
Seq1=flip(Seq);

% if length(P2) == 1
%     P2 = repmat(P2,[length(findangle) 1]);
% else
% end

x = zeros(NFrames*nRaios,length(Seq),ND);
y = zeros(NFrames*nRaios,length(Seq),ND);


for det=1:ND

    switch Rotation
        case 'CC'
            ang =  Degree(det):ROOT:Degree(det)+Arc-1;

        case 'CW'
            ang =  Degree(det):-ROOT:Degree(det)-Arc+1;
    end

    ang1 = repelem(ang,nRaios);

    P1 = linspace(Field(1)/2,-Field(1)/2,nRaios);
    x0 = cosd(ang).*P2(det,1:NFrames) - sind(ang).*P1';
    y0 = sind(ang).*P2(det,1:NFrames) + cosd(ang).*P1';

    x1 = x0(:);
    y1 = y0(:);

    x(:,:,det) = ((Seq1-y1)./tand(ang1)')+ x1;
    y(:,:,det) = ((Seq1-x1).*tand(ang1)')+ y1;

end

end

