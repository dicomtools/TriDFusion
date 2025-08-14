function I1 = collimator_correction(I1, num_iterations, P2, NEW,PixelSize) 

% num_iterations = 10; % Number of deconvolution iterations

% Collimator parameters
hole_diameter = 0.294; % cm (collimator hole diameter)
hole_length = 4.064; % cm (collimator hole length)
intrinsic_resolution = 0.38; % cm at 140 keV (Tc-99m detector resolution)
d = cat(2,P2(1,:),P2(2,:))./10;

% Image voxel size (XY plane)
voxel_size_spect = [PixelSize, PixelSize]; % cm per voxel (XY plane resolution)
num_projections = size(I1, 3)./NEW; % Number of projections

% Initialize output projections
% Loop through each projection
for proj = 1:num_projections
    % Get detector-to-patient distance for this projection
    

    % Compute the **total system resolution** (FWHM) in XY plane
    FWHM_collimator = hole_diameter * ( (1 + d(proj) / hole_length )); % Collimator contribution
    FWHM_total = sqrt(FWHM_collimator^2 + intrinsic_resolution^2); % Quadratic sum

    % Convert **FWHM to standard deviation (sigma)**
    sigma_xy = FWHM_total; 
    
    % sigma_xy = FWHM_total / (2.355); % Convert to pixel units

    % Define PSF size (limit to reasonable range)
    psf_size_xy = min(11, floor(6 * sigma_xy)); % 3 sigma rule
    psf_size_xy = max(3, psf_size_xy); % Minimum 3x3 PSF

    % Create 2D Gaussian PSF
    [X, Y] = meshgrid(-psf_size_xy:psf_size_xy, -psf_size_xy:psf_size_xy);
    psf = exp(-(X.^2 + Y.^2) / (2 * sigma_xy^2));
    psf = psf / sum(psf(:)); % Normalize PSF

    % Apply **2D Richardson-Lucy deconvolution** to the projection
    I1(:, :, proj) = deconvlucy(I1(:, :, proj), psf, num_iterations);
end

% Update the reconstructed volume with the deconvolved projections
end




% function I1_deconv = collimator_correction(I1, num_iterations) 
% 
%     % num_iterations = 10; % Adjust based on noise level
% 
%     % Define Collimator PSF (Gaussian kernel for deconvolution)
%     sigma_xy = 2;  % Blurring in the XY plane
%     sigma_z = 1;    % Less blurring along the Z-axis
%     psf_size_xy = min(11, min(size(I1, 2), size(I1, 3)));
%     psf_size_z = min(7, size(I1, 1));
% 
%     psf_size_xy = max(3, psf_size_xy); % Minimum 3x3 for meaningful deconvolution
%     psf_size_z = max(3, psf_size_z);   % Minimum 3 in Z-direction
% 
%     [X, Y, Z] = ndgrid(-psf_size_z:psf_size_z, -psf_size_xy:psf_size_xy, -psf_size_xy:psf_size_xy);
%     collimator_psf = exp(-(X.^2 / (2 * sigma_z^2) + Y.^2 / (2 * sigma_xy^2) + Z.^2 / (2 * sigma_xy^2)));
%     collimator_psf = collimator_psf / sum(collimator_psf(:)); % Normalize PSF
% 
%     % Initialize output array
%     I1_deconv = zeros(size(I1));
% 
%     % Apply Richardson-Lucy Deconvolution Slice-by-Slice
%     for z = 1:size(I1, 3)  % Loop through 360 slices
%         % Ensure the PSF size does not exceed image size in XY
%         psf_slice = collimator_psf(:, :, ceil(end/2));
%         psf_slice = psf_slice(1:min(size(psf_slice,1), size(I1,1)), ...
%             1:min(size(psf_slice,2), size(I1,2)));
% 
%         I1_deconv(:, :, z) = deconvlucy(I1(:, :, z), psf_slice, num_iterations);
%     end
%     % Update the reconstructed image with the deconvolved version
% 
% end