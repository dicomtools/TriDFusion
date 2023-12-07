function imFuzzy = fuzzy3DSegmentation(Img1)
%function imFuzzy = fuzzy3DSegmentation(Img1)
%Fuzzy clustering to segment a 3D image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Alexandre Velo, francaa@mskcc.org
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

% imFuzzy = zeros(size(Img1,1),size(Img1,2),size(Img1,3));
% Img2 = medfilt2(Img1,[3 3]);

op = abs(mod(mean(Img1(:)),nextpow2(mean(Img1(:)))));

Cluster = floor(4*(10/op));

[a,b] = histcounts(Img1);

G = [b(1:end-1); a];
G = G';

options = [op, 200, 1e-5, false];

[~,U] = fcm(G,Cluster,options);
    
maxU = max(U);

d = zeros(Cluster,1);

for i=1:Cluster
    d(i) = length(find(U(i,:) == maxU));   
end
    
index = zeros(Cluster,max(d(:)));
    
for i=1:Cluster
    index(i,1:d(i)) = find(U(i,:) == maxU);
end
    
index(index==0) = NaN;    
index = sortrows(index);
maxInd = max(index(:));

% L = reshape(Img1, numel(Img1), 1);
% L1 = zeros(size(L, 1), ncluster);
% 
% for i = 1:ncluster
%     w1 = index(i, ~isnan(index(i, :)) == 1);
% 
%     % Create a logical mask for the specified range
%     mask = false(size(L));
%     for j = 1:length(w1)-1
%         mask = mask | (L >= G(w1(j), 1) & L < G(w1(j+1), 1));
%     end
%     mask = mask | (L >= G(w1(end), 1) & L <= max(Img1(:)));
% 
%     % Assign labels to the corresponding pixels
%     L1(:, i) = (mask & (L1(:, i) == 0)) * (i - 1);
% end

L = reshape(Img1,numel(Img1),1);
L1 = zeros(size(L,1),Cluster);
    
for i=1:Cluster
    
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
                z = [z ; find((L>=G(w1(j),1) & L<=max(Img1(:))))];
            end
        end
    end

%     L1(z,i) = L(z);    
L1(z,i) = i;
end
    
L1 = reshape(L1,size(Img1,1),size(Img1,2),size(Img1,3),Cluster);

imFuzzy = sum(L1,4);

end