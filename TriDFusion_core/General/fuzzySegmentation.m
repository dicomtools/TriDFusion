function [Img4, Img5] = fuzzySegmentation(Img1, ncluster, group)
%function [Img4, Img5] = fuzzySegmentation(Img1, ncluster, group)
%Fuzzy clustering to segment an image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Alexandre Velo, francaa@mskcc.org
%          
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
%
% This file is part of The Triple Dimention Fusion (TriDFusion).
%
% TriDFusion development has been led by:  Daniel Lafontaine
%
% TriDFusion is distributed under the terms of the Lesser GNU Public License.
%
%     This version of TriDFusion is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.

    Img4 = zeros(size(Img1,1),size(Img1,2),size(Img1,3));
    
    aImageSize = size(Img1);

    d = zeros(ncluster, 1);

    for J = 1:aImageSize(3)
        
        Im = Img1(:,:,J);
    
        [a,b] = histcounts(Im);
    
        G = [b(1:end-1); a];
        G = G';
        
        [~,U] = fcm(G,ncluster);
        
        maxU = max(U);
        
        for i=1:ncluster
            d(i) = length(find(U(i,:) == maxU));   
        end
        
        index = zeros(ncluster,max(d(:)));
        
        for i=1:ncluster
            index(i,1:d(i)) = find(U(i,:) == maxU);
        end
        
        index(index==0) = NaN;    
        index = sortrows(index);
        maxInd = max(index(:));
    
        L = reshape(Im,numel(Im),1);
        L1 = zeros(size(L,1),ncluster);
        
        for i=1:ncluster
            
            z = [];
            w1 = index(i,~isnan(index(i,:))==1);
            q = sum(w1 == maxInd);
    
            if q~=1
                for j=1:length(w1)
                    z = [z ; find((L>=G(w1(j),1) & L<G(w1(j)+1,1)))];
                end
            else 
                for j=1:length(w1)
                    if j<length(w1)
                        z = [z ; find((L>=G(w1(j),1) & L<G(w1(j)+1,1)))];
                    else
                        z = [z ; find((L>=G(w1(j),1) & L<=max(Im(:))))];
                    end
                end
            end
    
    %     L1(z,i) = L(z);    
        L1(z,i) = 1;
        end
        
        L1 = reshape(L1,size(Img1,1),size(Img1,2),ncluster);
    
        if J<109
            Img4(:,:,J) = sum(L1(:,:,group:end),3);
        else
            Img4(:,:,J) = sum(L1(:,:,group+1:end),3);
        end
    
    end
    
    q = find(squeeze(sum(sum(Img4)))>0);
    
    Img5 = zeros(size(Img1,1),size(Img1,2),size(Img1,3));
    
    for i=q(1):q(length(q))
    
        % Im1 = Img1(:,:,i);
    
        xbw = Img4(:,:,i);
        stats = regionprops(xbw,'Area');
        [~,PosMajorArea] = max([stats.Area]);
        xlb = bwlabel(xbw);
        xbw(xlb==PosMajorArea)=1;
        xbw(xlb~=PosMajorArea)=0;
        % xbw(xbw==1) = Im1(xbw==1);
         
        Img5(:,:,i) = xbw;
    end
end