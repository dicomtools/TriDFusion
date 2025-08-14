function [M, sm] = getSystemMatrix(NFrames, nRaios, Lu, Dist, Dim, I1)

Q = ~isnan(Dist);

rotated_N = cell(2*NFrames*nRaios, 1);

for i = 1:NFrames*nRaios
    N1 = sparse(Lu(i, Q(i, :, 1), 1, 1), Lu(i, Q(i, :, 1), 2, 1), Dist(i, Q(i, :, 1), 1), Dim+1, Dim+1);
    N2 = sparse(Lu(i, Q(i, :, 2), 1, 2), Lu(i, Q(i, :, 2), 2, 2), Dist(i, Q(i, :, 2), 2), Dim+1, Dim+1);
    rotated_N{i} = N1(:);
    rotated_N{i+NFrames*nRaios} = N2(:);
end

M = (cat(2, rotated_N{:}));

% sm = [];

sm = getSystemMatrix3D(M, size(I1,1), nRaios, NFrames, Dim);

end