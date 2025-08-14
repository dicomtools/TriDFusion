% clearvars -except Img1
clearvars -except Dicom_A B
close all
clc

addpath('G:\Documents\SPECT_Recon\SytemMatrix\Elliptical')
addpath('G:\Documents\SPECT_Recon\SytemMatrix')

% format short
for i=1:2
    [Dicom_A{i,1},B]  = uigetfile('*.dcm');
    addpath(B)
end

[I1,I,a] = stitchImages(Dicom_A);

% cd('G:\Documents\SPECT_Recon\SytemMatrix\Elliptical');

% A = char(Dicom_A(a(1),1));
A = char(Dicom_A(1,1));

[Rotation, NFrames, Field, ND, NEW, Window, P2, Degree, imSizeX, imSizeY, PixelSize, ROOT, BED, Arc, nRaios, Raio, Dim] = readDicom(A,I,128);

[x, y, ang1, Seq, Seq1, x0, ang] = defineCoordenates(Degree, NFrames, P2, Arc, nRaios, ROOT, Field, Raio, PixelSize, ND, Rotation, Dim);

[Posi, Dist, Lu] = getPosition(Raio, x, y, Seq1, ND, ang, nRaios);

[M, sm] = getSystemMatrix(NFrames, nRaios, Lu, Dist, Dim, I);

I2 = concatenateImages(I1, a, NFrames);

[Img, ~] = SPECTrecon(I2, NEW, Window, sm, 20, Dim, size(I2,1), P2, PixelSize, true, true);

I5 = applyFilter(Img, 1.25);

ImgCr = flipdim(permute(I5, [3 2 1 4]),1);   % Coronal view image

MIP = getMIP(ImgCr);

figure, imshow3Dfull(MIP)
figure, imshow3Dfull(I5)

figure, pcolor(flipud(MIP(:,:,1)))
% caxis([-20 900])
daspect([PixelSize PixelSize PixelSize])
shading("interp")
colormap(flipud(gray))
% colormap(jet)
axis off

figure, pcolor(flip(ImgCr(:,:,73)))
% caxis([-20 900])
daspect([PixelSize PixelSize PixelSize])
shading("interp")
colormap(flipud(gray))
axis off


Display3D = volshow(I5);
Display3D.RenderingStyle =  "VolumeRendering";   
Display3D.Parent.BackgroundColor = [1 1 1];
Display3D.Parent.BackgroundGradient = "off";
Display3D.Colormap = jet;
Display3D.CameraPosition = [0 -5 0];
Display3D.ScaleFactors = [PixelX PixelY PixelZ];
Display3D.CameraViewAngle = 50;


figure, imshow3Dfull(ImgCr)
figure, imshow3Dfull(MIP1)



figure, pcolor(flip(MIP(:,:,1)))
shading("interp")
daspect([PixelSize PixelSize PixelSize])






figure;
for i = 1:13
    I4(:,:,i) = pcolor(flipud(MIP(:,:,i)));
    daspect([PixelSize PixelSize PixelSize])
    shading("interp")
    axis off
    % title(sprintf('Rotation: %d°', i));
    % pause; % Adjust speed
end

P = max(ImgCr,[],3);
figure, pcolor(flipud(P))
shading("interp")
daspect([PixelSize PixelSize PixelSize])
colormap(flipud(gray))
axis off
caxis([0 1000])

%%
% Load CT image (HU values)

folderPath = uigetdir;

% directory = 'G:\Documents\Rotations\DXQAL\PHYSICS-MEDICAL\1.2.840.113619.2.452.3.481097755.437.1741260048.1\1.2.840.113619.2.452.3.481097755.437.1741260048.4';

p = genpath(folderPath);
addpath(p)

a = dir(fullfile(folderPath));

Slope = dicominfo(a(4).name).RescaleIntercept;

ICT = zeros(512,512,251);

s=1;
for i=3:numel(a)
    ICT (:,:,s) = double(dicomread(a(i).name))+Slope;
    % ICT (:,:,s) = dicomread(a(i).name)+Slope;
    % I(:,:,i) = dicomread(k(w(i)));
    s=s+1;
end

%%

% % Step 1: Load volumes and metadata
% ctFolder = 'path_to_ct_dicom_folder';
% spectFolder = 'path_to_spect_dicom_folder';
% 
% ctVol = dicomreadVolume(ctFolder);
% ctInfo = dicominfo(fullfile(ctFolder, 'IM0001.dcm'));
% 
% spectVol = dicomreadVolume(spectFolder);
% spectInfo = dicominfo(fullfile(spectFolder, 'IM0001.dcm'));

% Step 2: Normalize volumes
ctVol = mat2gray(double(ICT));
spectVol = mat2gray(double(I5)); 

% Step 3: Create spatial referencing objects
ctSpacing = [0.9766; 0.9766; 3];
ctRef = imref3d(size(ctVol), ...
    ctSpacing(1), ctSpacing(2), ctSpacing(3));

spectSpacing = [4.795199871063200; 4.795199871063200; 4.795199871063200];
spectRef = imref3d(size(spectVol), ...
    spectSpacing(1), spectSpacing(2), spectSpacing(3));

% Step 4: Register SPECT to CT
[optimizer, metric] = imregconfig('multimodal');
optimizer.MaximumIterations = 50;

tform = imregtform(spectVol, spectRef, ctVol, ctRef, ...
    'affine', optimizer, metric);

% Step 5: Resample registered SPECT into CT space
registeredCT = imwarp(spectVol, spectRef, tform, ...
    'OutputView', ctRef);

MU = registeredCT(:);

MU(MU<=0) = ((MU(MU<=0).*(0.19-0.00025))./min(mu(:)));
MU(MU>0) = (MU(MU>0)*0.29*(0.38-0.19))./(1024*(0.53-0.29));
MU(MU>0) = 0.19+(MU(MU>0));

MU1 = reshape(MU,128,128,155);


% Step 6: Visualize one slice
sliceNum = round(size(spectVol,3)/2);
figure;
imshowpair(ctVol(:,:,164), registeredCT(:,:,164), 'falsecolor');
title('Registered SPECT over CT (Axial View)');


ImgCr = flipdim(permute(ctVol, [3 2 1 4]),1);   % Coronal view image
ImgCr1 = flipdim(permute(registeredCT, [3 2 1 4]),1);   % Coronal view image

figure, imshowpair(ImgCr(:,:,247), ImgCr1(:,:,247), 'falsecolor');


figure;
for i=1:128
    imshowpair(ImgCr(:,:,i), ImgCr1(:,:,i), 'falsecolor');
    drawnow
    pause
end

%%



voxel_size_spect = [PixelSize PixelSize PixelSize]; % Replace with actual SPECT voxel size
voxel_size_ct = [0.9766, 0.9766, 3]; % Replace with actual CT voxel size

% Resize CT attenuation map to match SPECT resolution
mu = imresize3(ICT, size(I5), 'linear');

ImgCr = flipdim(permute(I5, [3 2 1 4]),1);   % Coronal view image
ImgCr1 = flipdim(permute(mu_map_resampled, [3 2 1 4]),1);   % Coronal view image

C = imfuse(ImgCr1(:,:,75),ImgCr(:,:,75),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

imshow(C)

MU = mu(:);

MU(MU<=0) = ((MU(MU<=0).*(0.19-0.00025))./min(mu(:)));
MU(MU>0) = (MU(MU>0)*0.29*(0.38-0.19))./(1024*(0.53-0.29));
MU(MU>0) = 0.19+(MU(MU>0));

MU1 = reshape(MU,128,128,155);



mu_Lu177 = 0.08 * (1+mu_map_resampled / 1000);

attenuation_factor = exp(-mu_Lu177 * 4.79); 

SPECT_corrected = Img .* attenuation_factor;

for z = 1:size(Img, 3)
    SPECT_corrected(:, :, z) = Img(:, :, z) .* exp(-cumsum(mu_Lu177(:, :, z), 3) * 4.79);
end




%%
[84 16 84 32 84 80 84 144]


tic
Cm = I2(:,:,1:size(I2,3)/NEW);
Cl = I2(:,:,size(I2,3)/3+1:2*size(I2,3)/NEW);
Ch = I2(:,:,2*size(I2,3)/NEW+1:end);

Wm = E1.EnergyWindowUpperLimit - E1.EnergyWindowLowerLimit;
Wl = E2.EnergyWindowUpperLimit - E2.EnergyWindowLowerLimit; 
Wh = E3.EnergyWindowUpperLimit - E3.EnergyWindowLowerLimit; 

% H2 = Cm;

H2 = Cm - (((Cl+Ch)./(Wl+Wh)).*Wm);

H2(H2<0) = 0;

b = flip(permute(H2, [3 2 1 4]),1);   % Sagittal view image

b = flip(b,1);

% b1 = zeros(size(I2,1),2*length(P2),size(I2,2));

s=1;
for i=size(I2,1):-1:1
    b1(:,:,i) = b(:,:,s)';
s=s+1;
end

b1 = double(b1(:));

Recon1 = ones(size(sm,2),1);

n=20;
h=waitbar(0,'running MLEM');
for it=1:n
    Recon1(:,it+1)=(sm'*((b1)./((sm*Recon1(:,it))+eps))+eps).*...
    Recon1(:,it)./(sum(sm,1)'+eps);
    waitbar(it/n)
end
close(h)

