function sm = systemmatrix(MP1, Dim, acBedImage, dBedNumber, dNbEnergy)
% function sm = systemmatrix(P2, Dim, MP, nRaios, I)
%function sm = systemmatrix(P2, Dim, MP, nRaios, I)
%Generate 3D system matrix
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

%addpath('G:\Documents\simind\SytemMatrix')

%     sm = sparse(size(I,1)*size(I,2)*2*length(P2),Dim^2.*nRaios);
%     
%     s=1;
%     n=1;
%     
%     MP = cell2mat(MP);
%     
%  %   h=waitbar(0,'System Matrix');
%     
%     for i=1:nRaios
%         sm(n:n+size(MP,1)-1,s:s+Dim^2-1) = MP;
%         s = s+size(MP,2);
%         n = n+size(MP,1);
% %        waitbar(i/nRaios)
% 
%         if mod(i, 10)==1 || i == nRaios % Every 10 to improve speed
%             progressBar(i/nRaios, sprintf('Computing 3D system matrix step %d/%d.', i, nRaios));
%         end
% 
%     end
%   %  close(h)
% 
%     progressBar(1, 'Ready');

   
%     MP = cell2mat(MP);

%     MP1 = reshape([MP{:}],Dim^2,length(MP))';
    
    D = full(MP1((full(MP1)~=0)));
    
    [row,col] = find(MP1~=0);
    
    col1 = col+(0:size(acBedImage{dBedNumber},1)-1).*Dim^2;
    row1 = row+(0:size(acBedImage{dBedNumber},1)-1).*size(MP1,1);
    D1 = repmat(D,[1 size(acBedImage{dBedNumber},1)]);
    
%     [row,col] = find(MP~=0);
%     
%     for i=1:size(acBedImage{dBedNumber},1)
%         col1(:,i) = col+(i-1).*Dim^2;
%         row1(:,i) = row+(i-1).*size(MP,1);
%         
%         if mod(i, 10)==1 || i == size(acBedImage{dBedNumber},1) % Every 10 to improve speed
%             progressBar(i/size(acBedImage{dBedNumber},1), sprintf('Computing 3D system matrix step %d/%d.', i, size(acBedImage{dBedNumber},1)));
%         end
%     end
    
%     sm = sparse(row1,col1,tamPixel*10E-4,size(acBedImage{dBedNumber},1)*size(acBedImage{dBedNumber},2)*size(acBedImage{dBedNumber},3)/dNbEnergy,Dim^2*size(acBedImage{dBedNumber},1));
%     sm = sparse(row1,col1,6.4*10E-4,size(acBedImage{dBedNumber},1)*size(acBedImage{dBedNumber},2)*size(acBedImage{dBedNumber},3)/dNbEnergy,Dim^2*size(acBedImage{dBedNumber},1));
    sm = sparse(row1,col1,D1.*10E-4,size(acBedImage{dBedNumber},1)*size(acBedImage{dBedNumber},2)*size(acBedImage{dBedNumber},3)/dNbEnergy,Dim^2*size(acBedImage{dBedNumber},1));

    progressBar(1, 'Ready');


end

