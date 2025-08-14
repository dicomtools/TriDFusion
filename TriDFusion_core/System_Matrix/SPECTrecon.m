function [I2, Recon1] = SPECTrecon(I1, NEW, Window, sm, n, Dim, Diag, P2, PixelSize, Coll, Scatt)

Recon1 = ones(size(sm,2),1); % Preallocate reconstruction matrix

denominator = sum(sm, 1)' + eps; % Compute denominator once to avoid redundant calculations

apply_deconvolution = Coll;
apply_scatterCorrection = Scatt;

if apply_deconvolution

    % num_iterations = 10; % Adjust based on noise level

    I1 = collimator_correction(I1,10,P2,NEW,PixelSize);

end

if  apply_scatterCorrection

    Scatter = scatter_correctionTEW(NEW, Window, I1);

end

Cm = I1(:,:,1:size(I1,3)/NEW);

b = flip(flip(permute(Cm, [3 2 1 4]), 1));

b1 = flip(permute(b, [2 1 3]),3);

DATA = double(b1(:));

h = waitbar(0, 'running MLEM');

% denominator = sum(sm, 1)' + eps; % Compute denominator once to avoid redundant calculations

for it = 1:n
    % Perform element-wise update efficiently
    Recon1 = ((sm' * (DATA ./ (sm * Recon1 + Scatter + eps))) + eps) ...
        .* Recon1 ./ denominator;

    % Update waitbar every few iterations for efficiency
    % if mod(it, 10) == 0 || it == n
    waitbar(it / n);
    % end
end

close(h);

I2 = reshape(Recon1,Dim+1,Dim+1,Diag);



% Recon1 = ones(size(sm,2),n+1); % Preallocate reconstruction matrix
%
% h = waitbar(0, 'running MLEM');
%
% denominator = sum(sm, 1)' + eps; % Compute denominator once to avoid redundant calculations
%
% for it = 1:n
%     % Perform element-wise update efficiently
%     Recon1(:, it+1) = ((sm' * (DATA ./ (sm * Recon1(:, it) + Scatter + eps))) + eps) ...
%                         .* Recon1(:, it) ./ denominator;
%
%     % Update waitbar every few iterations for efficiency
%     if mod(it, 10) == 0 || it == n
%         waitbar(it / n);
%     end
% end
%
% close(h);


% Recon1 = ones(size(sm,2),1); % Preallocate reconstruction matrix




%
% h = waitbar(0, 'Running OSEM with Collimator Correction');
%
% num_subsets = 8; % Number of subsets
% indices = mod(0:size(sm, 1)-1, num_subsets) + 1; % Assign each row to a subset
%
% total_iterations = n * num_subsets;
% progress = 0;
%
% for it = 1:n
%     for s = 1:num_subsets
%
%         subset_indices = find(indices == s);
%
%         sm_subset = sm(subset_indices, :);
%         DATA_subset = DATA(subset_indices);
%         Scatter_subset = Scatter(subset_indices); % Subset scatter correction
%
%         denominator_subset = sum(sm_subset, 1)' + eps;
%
%         % OSEM update step with scatter and collimator correction
%         Recon1 = ((sm_subset' * (DATA_subset ./ (sm_subset * Recon1 + Scatter_subset + eps))) + eps) ...
%                         .* Recon1 ./ denominator_subset;
%
%         % Update waitbar for subsets
%         progress = progress + 1;
%         waitbar(progress / total_iterations, h, sprintf('Iteration %d/%d, Subset %d/%d', it, n, s, num_subsets));
%     end
% end
%
% close(h);


% Recon1 = ones(size(sm,2),n+1);
%
% h=waitbar(0,'runninI2 g MLEM');
%
% for it=1:n
%
%     Recon1(:,it+1)=(sm'*((DATA)./((sm*Recon1(:,it))+Scatter+eps))+eps).*...
%         Recon1(:,it)./(sum(sm,1)'+eps);
%
%     waitbar(it/n)
%
% end
%
% close(h)

% end

% I2 = reshape(Recon1(:,21),Dim+1,Dim+1,Diag);

end







