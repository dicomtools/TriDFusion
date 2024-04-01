function [MP1] = RotationCW(ROOT, nRaios, P2, Raio, Dim, Degree, tamPixel, dND, dField, dNFrames, Hip)
%function [MP, HH] = RotationCW(ROOT, nRaios, P2, Raio, Dim, Degree, tamPixel)
%Rotate clockwise
%
%Note: 
%
%Author:      Alexandre Franca Velo, lafontad@mskcc.org
%Contributor: Daniel Lafontaine
%       
%
%Last specifications modified:
%
% Copyright 2023, Alexandre Franca Velo.

    % MP = sparse(zeros(nRaios*length(P2),Dim^2));
    
    %addpath('G:\Documents\simind\SytemMatrix')
    
    ang = Degree:-ROOT:Degree-179;
    
%     findangle = find(ang>0 & ang<90 | ang>180 & ang<270);

    findangle = dNFrames:-1:dNFrames/2+1;
    g = double(findangle(1)*nRaios:-1:findangle(end)*nRaios-(nRaios-1));   
    
%     if findangle(1) ~= 1
%         findangle = flip(findangle);
%         g = findangle(1)*nRaios:-1:findangle(end)*nRaios-(nRaios-1);    
%     else
%         g = findangle(1)*nRaios:1:findangle(end);
%     end
    
    ang1 = zeros(length(findangle)*nRaios,1);
    
    s=1;
    for i=1:nRaios:length(findangle)*nRaios
        ang1(i:i+nRaios-1) = ang(findangle(s));
        s=s+1;
    end
       
    if length(P2) == 1
        P2 = repmat(P2,[length(findangle) 1]);
    else
    end

%     P1 = linspace(268.5,-268.5,nRaios);
    P1 = linspace(dField(1)/2,-dField(1)/2,nRaios);
    x0 = cosd(ang(findangle)).*P2(findangle)' - sind(ang(findangle)).*P1';
    y0 = sind(ang(findangle)).*P2(findangle)' + cosd(ang(findangle)).*P1';
    
    x1 = reshape(x0,length(findangle)*nRaios,1);
    y1 = reshape(y0,length(findangle)*nRaios,1);
    
    Seq=round(-Raio:tamPixel:Raio,40);
    
    Seq1=flip(Seq);
%     Seq = arrayfun(@(x) str2double(num2str(x,40)), Seq);
%     Seq1 = arrayfun(@(x) str2double(num2str(x,40)), Seq1);
    
    x = ((Seq1-y1)./tand(ang1))+ x1;
    y = ((Seq1-x1).*tand(ang1))+ y1;
    
    a = double(x>-Raio & x<Raio);
    b = double(y>-Raio & y<Raio);
    
    a(a==0) = NaN;
    b(b==0) = NaN;
    
    v(:,:,1) = x.*a;
    v(:,:,2) = Seq1.*a;
    
    h(:,:,1) = Seq1.*b;
    h(:,:,2) = y.*b;
    
    vet1 = [v h];
    
    Posi = zeros(size(vet1,1),size(vet1,2),2);
    
    Posi(:,:,1)=sort(vet1(:,:,1),2);  
    Posi(:,:,2)=sort(vet1(:,:,2),2);  
    
    Dist = sqrt(((Posi(:,1:size(Posi,2)-1,1)-Posi(:,2:size(Posi,2),1)).^2 + (Posi(:,1:size(Posi,2)-1,2)-Posi(:,2:size(Posi,2),2)).^2)./Hip);
    
    Lu = zeros(length(findangle)*nRaios,size(vet1,2),2);
    for kk=1:Dim
        HH(:,:,1)= double((Posi(:,:,1)>=Seq(kk) & Posi(:,:,1)<Seq(kk+1))*kk);
        HH(:,:,2)= double((Posi(:,:,2)<Seq1(kk) & Posi(:,:,2)>=Seq1(kk+1))*kk);
        Lu = Lu + HH;
    end
    
    x01 = -flip(x0);
    
    w = double(Posi(:,:,1)>=reshape(x0,nRaios*length(findangle),1) & Posi(:,:,1)<=reshape(x01,nRaios*length(findangle),1));
    
    w(w==0) = nan;

    Dist1 = Dist.*w(:,1:end-1);
    
    Lu1(:,:,1) = Lu(:,:,1).*w;
    Lu1(:,:,2) = Lu(:,:,2).*w;
    
    Lu2 = zeros(length(Lu1).*2*(dND/2),size(vet1,2));
    Lu2(1:2:length(Lu1)*2*(dND/2),:) = Lu1(1:length(Lu1)*(dND/2),:,2);
    Lu2(2:2:length(Lu1)*2*(dND/2),:) = Lu1(1:length(Lu1)*(dND/2),:,1);
    
    s=1;
    
    n=length(P2)/2*nRaios;
    
    for i=1:n
    
        w = find(Lu2(s,:)>0);
        w1 = find(Lu2(s+1,:)>0);
        if length(w) > length(w1)
            HH1{s,:} = Lu2(s,w(1:end-1));
            HH1{s+1,:} = Lu2(s+1,w1);
        elseif length(w) < length(w1)
            HH1{s,:} = Lu2(s,w);
            HH1{s+1,:} = Lu2(s+1,w1(1:end-1));
        else 
            HH1{s,:} = Lu2(s,w);
            HH1{s+1,:} = Lu2(s+1,w1);
        end
    
        m = find(~isnan(Dist1(i,:))==1);

        HH2{g(i),:} = ((cell2mat(HH1(s))-1).*Dim)+cell2mat(HH1(s+1));
    
        MP{g(i),:} = sparse(1,cell2mat(HH2(g(i))),Dist1(i,m),1,Dim^2);
        MP{length(Lu2)+1-g(i),:} = sparse(reshape(flip(reshape(full(cell2mat(MP(g(i)))),Dim,Dim),1),1,Dim^2));   
    %     N2{i,:} = sparse(reshape(flip(reshape(full(cell2mat(N(i,:))),128,128),2),1,Dim^2));
    
    
        s=s+2;
        if mod(i,10)==1 || i == n % Every 10 to improve speed
            progressBar(i/n, sprintf('Computing 2D system matrix CW rotation step %d/%d.', i, n));
        end
    end
    
    s=1;
    for i=length(MP):-1:1
        N{s,:} = sparse(reshape(flip(reshape(full(cell2mat(MP(i))),Dim,Dim),2),1,Dim^2));
        s=s+1;
    end
        
    MP = [MP;N];

    MP1 = reshape([MP{:}],Dim^2,length(MP))';

    
    progressBar(1, 'Ready');    

end