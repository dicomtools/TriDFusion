function sm = getSystemMatrix3D(M, Diag, nRaios, NFrames, Dim)
% 
M1 = M';

[row,col,val] = find(M1);

R = repelem({val},Diag,1);

% h=waitbar(0,'System Matrix');
% 
% for i=1:nRaios    
%     col1(:,i) = col+(i-1).*(Dim+1)^2;
%     row1(:,i) = row+(i-1).*(nRaios)*NFrames*2;
% %     val(:,i) = {full((M(M~=0)))};
%     waitbar(i/nRaios)
% end
% 
% close(h)

iVec = (0:Diag-1)'; % Column vector for indices
col1 = col + iVec' .* (Dim+1)^2;
row1 = row + iVec' .* (nRaios * NFrames * 2);

R = cat(2, R{:});

sm = sparse(row1,col1,R,2*NFrames*nRaios*Diag,(Dim+1)^2*Diag);


end








