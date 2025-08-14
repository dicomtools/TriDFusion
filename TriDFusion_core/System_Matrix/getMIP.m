function MIP = getMIP(ImgCr)

num_frames = 12; % Number of rotation frames
MIP = zeros([size(ImgCr,1), size(ImgCr,2), num_frames]); % Preallocate

s=1;
for angle = 0:30:num_frames*30
    rotated_volume = imrotate3(ImgCr, angle, [0 1 0], 'linear', 'crop'); % Rotate around Z-axis
    MIP(:,:,s) = max(rotated_volume, [], 3); % Compute MIP
    s=s+1;
end

end