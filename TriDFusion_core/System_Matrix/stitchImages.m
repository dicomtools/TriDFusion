function [I1,I,a] = stitchImages(Dicom_A)

% I = zeros(155,128,96);
% 
% for i = 1:2
% 
%     A = char(Dicom_A(i,1));
% 
%     I1(:,:,:,i) = double(dicomread(A));
% 
%     info = dicominfo(A);
% 
%     k(i) = info.DetectorInformationSequence.Item_2.ImagePositionPatient(3);
% 
%     % num = regexp(k, '\d+', 'match'); % Extracts all numbers as a cell array
%     % 
%     % T(i) = str2double(num{end}); % Converts the last extracted number to a double
% 
% end
% 
% [~,b] = min(k(:));
% 
% [~,l] = max(k(:));
% 
% switch b
% 
%     case 2
% 
%         I(79:155,:,:) = I1(26:102, :, 1:96, b);
%         I(1:78,:,:) = I1(24:101, :, [48:-1:1 96:-1:49], l);
% 
%     otherwise
% 
%         I(1:78,:,:) = I1(24:101, :, 1:96, b);
%         I(79:155,:,:) = I1(26:102, :, [48:-1:1 96:-1:49], l);
% 
% end

I1 = cell(1,2); 
I2 = cell(1,2); 

for i = 1:2
    P{i} = squeeze(double(dicomread(char(Dicom_A(i,1)))));
    f = max(P{i}, [], 3);
    L1 = sum(f, 2); 
    L2 = sum(f, 1); 
    w1 = find(L1 ~= 0); 
    w2 = find(L2 ~= 0); 
    I1{i} = P{i}(w1(1)+2:w1(end),w2(1):w2(end),:);
    I2{i} = f(w1(1)+2:w1(end), w2(1):w2(end)); 
end

% k = I2{1};
% k1 = I2{2};

% a1 = mean(k1(78,1:50)-k(2,1:50));
% a2 = mean(k(78,1:50)-k1(2,1:50));

% [~ , a] = min([mean(k1(78,1:50)-k(2,1:50)), mean(k(78,1:50)-k1(2,1:50))]);

% [~ , a(1)] = min([sqrt(((sum(I2{1}(78,:) - I2{2}(2,:)))^2)/128), sqrt(((sum(I2{2}(78,:) - I2{1}(2,:)))^2)/128)]);
% [~ , a(2)] = max([sqrt(((sum(I2{1}(78,:) - I2{2}(2,:)))^2)/128), sqrt(((sum(I2{2}(78,:) - I2{1}(2,:)))^2)/128)]);;

[~ , a(1)] = min([1-(sum((mean(I2{1}(78,:))-I2{1}(78,:)).*(mean(I2{2}(2,:))-I2{2}(2,:))))/sqrt(sum(((mean(I2{1}(78,:))-I2{1}(78,:)).^2)).*(sum(((mean(I2{2}(2,:))-I2{2}(2,:)).^2)))),...
    1-(sum((mean(I2{2}(78,:))-I2{2}(78,:)).*(mean(I2{1}(2,:))-I2{1}(2,:))))/sqrt(sum(((mean(I2{2}(78,:))-I2{2}(78,:)).^2)).*(sum(((mean(I2{1}(2,:))-I2{1}(2,:)).^2))))]);

[~ , a(2)] = max([1-(sum((mean(I2{1}(78,:))-I2{1}(78,:)).*(mean(I2{2}(2,:))-I2{2}(2,:))))/sqrt(sum(((mean(I2{1}(78,:))-I2{1}(78,:)).^2)).*(sum(((mean(I2{2}(2,:))-I2{2}(2,:)).^2)))),...
    1-(sum((mean(I2{2}(78,:))-I2{2}(78,:)).*(mean(I2{1}(2,:))-I2{1}(2,:))))/sqrt(sum(((mean(I2{2}(78,:))-I2{2}(78,:)).^2)).*(sum(((mean(I2{1}(2,:))-I2{1}(2,:)).^2))))]);


% if a1 < a2
% 
%     I = [k1(1:end-2, :); k(4:end, :)];
% 
% else 
% 
%      I = [k(1:end-2, :); k1(4:end, :)];
% 
% end

% switch a
% 
%     case 1
% 
%     I = [k1(1:end-2, :); k(4:end, :)];
% 
%     otherwise
% 
%      I = [k(1:end-2, :); k1(4:end, :)];
% 
% end

switch a(1)

    case 1

    I = [I2{1}(1:end-2,:); I2{2}(4:end,:)];

    % Img = cat(1,I1{1}(1:end-2,:,:),I1{2}(4:end,:,[48:-1:1 96:-1:49 144:-1:97 192:-1:145 240:-1:193 288:-1:241]));

    otherwise

    I = [I2{2}(1:end-2,:); I2{1}(4:end, :)];
     
     % Img = cat(1,I1{2}(1:end-2,:,:),I1{1}(4:end,:,[48:-1:1 96:-1:49 144:-1:97 192:-1:145 240:-1:193 288:-1:241]));


end

figure, imagesc(I)



end





