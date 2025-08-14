function [Rotation, NFrames, Field, ND, NEW, Window, P2, Degree, imSizeX, imSizeY, PixelSize, ROOT, BED, Arc, nRaios, Raio, Dim] = readDicom(A,I,Dim)


% % Validate inputs
%     if nargin ~= 3
%         error('readDicom requires exactly three input arguments.');
%     end
%     if ~iscell(I1)
%         error('I1 must be a cell array containing DICOM images.');
%     end
%     if ~ischar(A) && ~isstring(A)
%         error('A must be a valid DICOM file path.');
%     end
%

info = dicominfo(A);


Rotation = info.RotationInformationSequence.Item_1.RotationDirection;
NFrames = double(info.RotationInformationSequence.Item_1.NumberOfFramesInRotation);
Field = info.DetectorInformationSequence.Item_1.FieldOfViewDimensions;
ND = double(info.NumberOfDetectors);
NEW = double(info.NumberOfEnergyWindows);
Window = info.EnergyWindowInformationSequence;
P2 = extractDetectorPositions(info.DetectorInformationSequence, ND);
Degree = extractDetectorAngles(info.DetectorInformationSequence, ND);
imSizeX = size(I,2);
% imSizeX = double(info.Width)-16;
% imSizeY = double(info.Height)-8;
imSizeY = [];
PixelSize = double(info.PixelSpacing(1));
ROOT = info.RotationInformationSequence.Item_1.AngularStep;
BED = info.SeriesDescription;

Arc = info.RotationInformationSequence.Item_1.ScanArc;
nRaios = imSizeX;
Raio = double(imSizeX / 2 * PixelSize);
% Dim = 153;
Dim = Dim-1;


end



% 
% 
% 
% function [Rotation, NFrames, Field, ND, NEW, energyWindow, P2, Degree, imSizeX, imSizeY, PixelSize, ROOT, BED, Arc, nRaios, Raio, Dim, Img, Window] = readDicom(A,I1,a)
% 
% % I1 = double(squeeze(dicomread(A)));
% % I1 = [];
% 
% info = dicominfo(A);
% 
% imSizeX = double(info.Width);
% imSizeY = double(info.Height);
% 
% PixelSize = double(info.PixelSpacing(1));
% 
% Arc = info.RotationInformationSequence.Item_1.ScanArc;
% 
% BED = info.SeriesDescription;
% 
% ROOT = info.RotationInformationSequence.Item_1.AngularStep;
% 
% Rotation = info.RotationInformationSequence.Item_1.RotationDirection;
% 
% NFrames = double(info.RotationInformationSequence.Item_1.NumberOfFramesInRotation);
% 
% Field = info.DetectorInformationSequence.Item_1.FieldOfViewDimensions;
% 
% ND = double(info.NumberOfDetectors);
% 
% DIS = info.DetectorInformationSequence;
% 
% NEW = double(info.NumberOfEnergyWindows);
% 
% Window =  info.EnergyWindowInformationSequence;
% 
% energyWindow = [];
% 
% % switch NEW
% %     case 1
% % 
% %         E1 = info.EnergyWindowInformationSequence.Item_1.EnergyWindowRangeSequence.Item_1;
% %         energyWindow = E1;
% % 
% %     case 2
% % 
% %         E1 = info.EnergyWindowInformationSequence.Item_1.EnergyWindowRangeSequence.Item_1;
% %         E2 = info.EnergyWindowInformationSequence.Item_2.EnergyWindowRangeSequence.Item_1;
% %         energyWindow = [E1, E2];
% % 
% %     case 3
% % 
% %         E1 = info.EnergyWindowInformationSequence.Item_1.EnergyWindowRangeSequence.Item_1;
% %         E2 = info.EnergyWindowInformationSequence.Item_2.EnergyWindowRangeSequence.Item_1;
% %         E3 = info.EnergyWindowInformationSequence.Item_3.EnergyWindowRangeSequence.Item_1;
% %         energyWindow = [E1, E2, E3];
% % end
% 
% 
% switch ND
% 
%     case 1
%         P2(1,:) = DIS.Item_1.RadialPosition;
%         Degree(1) = DIS.Item_1.StartAngle;
% 
%     case 2
%         P2(1,:) = DIS.Item_1.RadialPosition;
%         P2(2,:) = DIS.Item_2.RadialPosition;
% 
%         Degree(1) = DIS.Item_1.StartAngle;
%         Degree(2) = DIS.Item_2.StartAngle;
% end
% 
% Raio = double(imSizeX/2.*PixelSize);
% 
% nRaios = 128;
% 
% Dim = 127;
% 
% % Img = [];
% 
% Img = cat(1,I1{a(1)}(1:end-2,:,:),I1{a(2)}(4:end,:,[NFrames:-1:1 NFrames*2:-1:NFrames*2-(NFrames-1) NFrames*3:-1:NFrames*3-(NFrames-1) NFrames*4:-1:NFrames*4-(NFrames-1) NFrames*5:-1:NFrames*5-(NFrames-1) NFrames*6:-1:NFrames*6-(NFrames-1)]));
% 
% end


% function [Rotation, NFrames, Field, ND, NEW, energyWindow, P2, Degree, imSizeX, imSizeY, I1, PixelSize, ROOT, BED, Arc, I2, nRaios, Raio, Dim] = readDicom(A)
%
% info = dicominfo(A);
%
% % Read DICOM image efficiently
% I1 = double(squeeze(dicomread(A)));
%
% % Direct assignment of metadata values
% imSizeX = double(info.Width);
% imSizeY = double(info.Height);
% PixelSize = double(info.PixelSpacing(1));
%
% Arc = info.RotationInformationSequence.Item_1.ScanArc;
% BED = info.SeriesDescription;
% ROOT = info.RotationInformationSequence.Item_1.AngularStep;
% Rotation = info.RotationInformationSequence.Item_1.RotationDirection;
% NFrames = info.RotationInformationSequence.Item_1.NumberOfFramesInRotation;
% Field = info.DetectorInformationSequence.Item_1.FieldOfViewDimensions;
% ND = info.NumberOfDetectors;
% NEW = info.NumberOfEnergyWindows;
%
% % Vectorized energy window extraction
% energyWindow = arrayfun(@(k) info.EnergyWindowInformationSequence.(['Item_', num2str(k)]).EnergyWindowRangeSequence.Item_1, 1:NEW, 'UniformOutput', false);
% energyWindow = cell2mat(energyWindow);
%
% % Ensure P2 and Degree are preallocated correctly
% P2 = zeros(ND, 1); % Default size
% Degree = zeros(1, ND);
%
% for k = 1:ND
%     itemName = ['Item_', num2str(k)];
%     if isfield(info.DetectorInformationSequence, itemName)
%         item = info.DetectorInformationSequence.(itemName);
%         if isfield(item, 'RadialPosition')
%             P2(k, 1:numel(item.RadialPosition)) = item.RadialPosition;
%         end
%         if isfield(item, 'StartAngle')
%             Degree(k) = item.StartAngle;
%         end
%     end
% end
%
% % Compute radius
% Raio = (imSizeX / 2) * PixelSize;
%
% % Efficiently crop non-zero regions of I1
% [w1, ~] = find(sum(I1(:,:,1), 1) ~= 0);
% [w2, ~] = find(sum(I1(:,:,1), 2) ~= 0);
% I2 = I1(w2(1):w2(end), w1(1):w1(end), :);
%
% % Fixed output values
% nRaios = 128;
% Dim = 127;
%
% end

