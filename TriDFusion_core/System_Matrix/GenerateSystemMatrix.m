function [aReconstructedImage, atReconstructedMetaData] = GenerateSystemMatrix(acBedImage, atcBedMetaData, atcOption)
%function [aReconstructedImage, atReconstructedMetaData] = GenerateSystemMatrix(acBedImage, atcBedMetaData, atcOption)
%Resconstruct a tomo acquisition
%
%Note: acBedImage    : cell array of the beds.
%      atcBedMetaData: cell array of the beds dicom header.
%      atcOption     : Cell array of beds option template.
%
%Author:      Alexandre Franca Velo, lafontad@mskcc.org
%Contributor: Daniel Lafontaine
%       
%
%Last specifications modified:
%
% Copyright 2023, Alexandre Franca Velo.

tic

    for dBedNumber=1:numel(atcOption) % loop from bed 1-3 

       if atcOption{dBedNumber}.bReconstrucBed == true
            
           
            acBedImage{dBedNumber} = double(acBedImage{dBedNumber}(:,:,end:-1:1)); % Reverse bedx z order

            dNuM = size(acBedImage{dBedNumber},1); 

            L1 = sum(acBedImage{dBedNumber}(:,:,1),1);
            w11 = find(L1~=0);
            L2 = sum(acBedImage{dBedNumber}(:,:,1),2)';
            w22 = find(L2~=0);

            acBedImage{dBedNumber} = acBedImage{dBedNumber}(w22(1):w22(end),w11(1):w11(end),:);

%             acBedImage{dBedNumber} = acBedImage{dBedNumber}(25:104,11:119,:);

        %    format short
        %    [A,B] = uigetfile('*.dcm');
        %    cd(B)
            
              %  I = dicomread(A);
             %   I = squeeze(I);
             %   info = dicominfo(A);
            
            P2 = atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.RadialPosition+20;
            dNFrames = atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.NumberOfFramesInRotation;
            % P2 = [P2;P2];
            
            if isempty(atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.StartAngle)
                dDegree = 0;
            else
                dDegree = atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.StartAngle;
            end
            
            adField = atcBedMetaData{dBedNumber}{1}.DetectorInformationSequence.Item_1.FieldOfViewDimensions;

            if adField(1) == 0
                adField(1) = 587;
            end

            if adField(2) == 0
                adField(2) = 368;
            end

            Pixelsize = atcBedMetaData{dBedNumber}{1}.PixelSpacing;

%             dNEW = double(atcBedMetaData{dBedNumber}{1}.NumberOfEnergyWindows);
            dND = atcBedMetaData{dBedNumber}{1}.NumberOfDetectors;
        
            Dim = atcOption{dBedNumber}.Matrix;
            tamPixel = (dNuM/Dim)*Pixelsize(1);
            Hip = tamPixel.*sqrt(2);
        %     Raio = max(P2(:));
            Raio = tamPixel.*Dim/2;
            % hipotenusa=tamPixel*sqrt(2);
            nRaios = size(acBedImage{dBedNumber},2);
            ROOT = atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.AngularStep;
            % n1 = 24;
            
            sRotation = atcBedMetaData{dBedNumber}{1}.RotationInformationSequence.Item_1.RotationDirection;
        
            progressBar(1/5, sprintf('Acquaring bed %d 2D system matrix.', dBedNumber));
             
            switch sRotation
            
                case 'CW'
            
                    [MP1] = RotationCW(ROOT, nRaios, P2, Raio, Dim, dDegree, tamPixel, dND, adField, dNFrames, Hip);
            
                case 'CC'
            
                    [MP1] = RotationCC(ROOT, nRaios, P2, Raio, Dim, dDegree, tamPixel, dND, adField, dNFrames, Hip);
            end
        
            progressBar(2/5, sprintf('Acquaring bed %d 3D system matrix.', dBedNumber));

            dNbEnergy = atcBedMetaData{dBedNumber}{1}.NumberOfEnergyWindows;
         
            sm = systemmatrix(MP1, Dim, acBedImage, dBedNumber, dNbEnergy);
            
            dEnergyOffset = size( acBedImage{dBedNumber}, 3)/dNbEnergy;

            % Energy Window 1

            E1 = atcBedMetaData{dBedNumber}{1}.EnergyWindowInformationSequence.Item_1.EnergyWindowRangeSequence.Item_1;

            Cm = acBedImage{dBedNumber}(:,:,1:dEnergyOffset);
            Wm = E1.EnergyWindowUpperLimit - E1.EnergyWindowLowerLimit;

            % Energy Window 2

            if dNbEnergy > 1 
                E2 = atcBedMetaData{dBedNumber}{1}.EnergyWindowInformationSequence.Item_2.EnergyWindowRangeSequence.Item_1;
     
                Cl = acBedImage{dBedNumber}(:,:,dEnergyOffset+1:dEnergyOffset*2);
                Wl = E2.EnergyWindowUpperLimit - E2.EnergyWindowLowerLimit; 
            end

            % Energy Window 3

            if dNbEnergy > 2
                E3 = atcBedMetaData{dBedNumber}{1}.EnergyWindowInformationSequence.Item_3.EnergyWindowRangeSequence.Item_1;
       
                Ch = acBedImage{dBedNumber}(:,:,(dEnergyOffset*2)+1:end);              
                Wh = E3.EnergyWindowUpperLimit - E3.EnergyWindowLowerLimit; 
            end

            % Scatter correction

            if atcOption{dBedNumber}.Scatter.CorrectionEnable && ...
               dNbEnergy == 3 % 3 Energy Window

                H2 = Cm -(((Cl+Ch)./(Wl+Wh)).*Wm);
            elseif atcOption{dBedNumber}.Scatter.CorrectionEnable && ...
               dNbEnergy == 2 % 2 Energy Window   

                H2 = Cm; % To do
            else              % 1 Energy Window   
                H2 = Cm;
            end

%            H2 = Cm -(((Cl+Ch)./(Wl+Wh)).*Wm);
             
            H2(H2<0) = 0;
            
            b = flip(permute(H2, [3 2 1 4]),1);   % Sagittal view image
            
            b1 = zeros(size(acBedImage{dBedNumber},2),size(acBedImage{dBedNumber},3)/dNbEnergy,size(acBedImage{dBedNumber},1));
            
            s=1;
            for i=size(acBedImage{dBedNumber},1):-1:1
                b1(:,:,i) = b(:,:,s)';
            s=s+1;
            end
            
            b1 = double(b1(:));
            
            aRecon = ones(size(sm,2),1);
        
            progressBar(3/5, sprintf('Starting bed %d iterration.', dBedNumber));
           
            n = atcOption{dBedNumber}.NbItteration;
        %    h=waitbar(0,'running MLEM');
            for it=1:n
                aRecon(:,it+1)=(sm'*((b1)./((sm*aRecon(:,it))+eps))+eps).*...
                aRecon(:,it)./(sum(sm,1)'+eps);
            %    waitbar(it/n)
                progressBar(it/n, sprintf('Computing bed %1 itteration %d/%d.', dBedNumber, it, n));
        
            end
          %  close(h)
        
            progressBar(4/5, sprintf('Computing bed %d Rotation.', dBedNumber));
          
            acBedImage{dBedNumber} = double(reshape(aRecon(:,n+1),Dim,Dim,size(acBedImage{dBedNumber},1)));


            if dBedNumber == 1
                acBedImage{dBedNumber} = acBedImage{dBedNumber}(:,:,3:end-3);
            else
                 acBedImage{dBedNumber} = acBedImage{dBedNumber}(:,:,3:end);
            end

            se = strel('disk',round(Dim/2)-1,0);
            z = zeros(Dim,Dim);
            z(round(Dim/2),round(Dim/2),:) = 1;
            
            out = imdilate(z,se);
            out = repmat(out,[1 1 size(acBedImage{dBedNumber},3)]);

            out(out==1) = acBedImage{dBedNumber}(out==1);

            acBedImage{dBedNumber} = circshift(out,[0 0]);


            % PSF  = fspecial('gaussian',10,1.5);
        
            % for i=1:128
             %   [J(:,:,i),~] = deconvblind(acBedImage{dBedNumber}(:,:,i),PSF);
            %end
        
            %acBedImage{dBedNumber} = imgaussfilt3(J,1.2);
        
            progressBar(5/(5-0.00001), sprintf('Applying bed %d filtering.', dBedNumber));
        
%             if atcOption{dBedNumber}.Filter.GaussEnable == true 
%                 acBedImage{dBedNumber} = imgaussfilt3(acBedImage{dBedNumber}, atcOption{dBedNumber}.Filter.GaussCuttoff);
%             end

            clear aRecon;
        end
    end
 %   addpath('G:\Documents\simind')
 %   figure, imshow3Dfull(Img1,[])
    % Img1 = imgaussfilt3(Img1,0.8);
    
    % To do: set atcBedMetaData{dBedNumber} for a reconstructed SPECT image.

   
    
    %%
toc    
    

%     acBedImage{dBedNumber}=acBedImage{dBedNumber}(:,end:-1:1,:);     

    % TO DO: need to do a real header

    atReconstructedMetaData = [];

    if atcOption{1}.bReconstrucBed == true % Bed 1
        atReconstructedMetaData{1} = atcBedMetaData{1}{1};
    end

    if isempty(atReconstructedMetaData)
        if atcOption{2}.bReconstrucBed == true % Bed 2
            atReconstructedMetaData{1} = atcBedMetaData{2}{1};
        end
    end

    if isempty(atReconstructedMetaData)    
        if atcOption{3}.bReconstrucBed == true % Bed 3
            atReconstructedMetaData{1} = atcBedMetaData{3}{1};
        end
    end

%     atReconstructedMetaData{1}.SpacingBetweenSlices = 4.7585;
    atReconstructedMetaData{1}.SpacingBetweenSlices = tamPixel.*(Dim/dNuM);
    atReconstructedMetaData{1}.PixelSpacing(1) = tamPixel;
    atReconstructedMetaData{1}.PixelSpacing(2) = tamPixel;

    % FOR NOW: Stitch image

    % Need to be calculate

%     dBed1RemoveBottom = 36;
%     dBed1RemoveTop    = 14;
% 
%     dBed2RemoveBottom = 35;
%     dBed2RemoveTop    = 16;
% 
%     dBed3RemoveBottom = 26;
%     dBed3RemoveTop    = 26;

    dBed1RemoveBottom = 0;
    dBed1RemoveTop    = 0;

    dBed2RemoveBottom = 0;
    dBed2RemoveTop    = 0;

    dBed3RemoveBottom = 26;
    dBed3RemoveTop    = 26;

    % End Need to be calculate

    if atcOption{1}.bReconstrucBed == true && ...  % Bed 1
       atcOption{2}.bReconstrucBed == true && ...  % Bed 2
       atcOption{3}.bReconstrucBed == true         % Bed 3

        aReconstructedImage = cat(3, acBedImage{1}(:,:,(1+dBed1RemoveTop):(end-dBed1RemoveBottom)),...
                                     acBedImage{2}(:,:,(1+dBed2RemoveTop):(end-dBed2RemoveBottom)));        

        aReconstructedImage = cat(3, aReconstructedImage(:,:,:),...
                                     acBedImage{3}(:,:,(1+dBed3RemoveTop):(end-dBed3RemoveBottom)));                     
    else

        if atcOption{1}.bReconstrucBed == true && ...  % Bed 1
           atcOption{2}.bReconstrucBed == true         % Bed 2  

            aReconstructedImage = cat(3, acBedImage{1}(:,:,(1+dBed1RemoveTop):(end-dBed1RemoveBottom)),...
                                         acBedImage{2}(:,:,(1+dBed2RemoveTop):(end-dBed2RemoveBottom)));  

        elseif atcOption{1}.bReconstrucBed == true && ... % Bed 1
               atcOption{3}.bReconstrucBed == true        % Bed 3

            aReconstructedImage = cat(3, acBedImage{1}(:,:,(1+dBed1RemoveTop):(end-dBed1RemoveBottom)),...
                                         acBedImage{3}(:,:,(1+dBed3RemoveTop):(end-dBed3RemoveBottom)));  

        elseif atcOption{2}.bReconstrucBed == true && ... % Bed 2
               atcOption{3}.bReconstrucBed == true        % Bed 3
            
            aReconstructedImage = cat(3, acBedImage{2}(:,:,(1+dBed2RemoveTop):(end-dBed2RemoveBottom)),...
                                         acBedImage{3}(:,:,(1+dBed3RemoveTop):(end-dBed3RemoveBottom)));                  
        
        else % Only one bed, no stitch needed 

            if atcOption{1}.bReconstrucBed == true  % Bed 1
                aReconstructedImage = acBedImage{1};
            end

            if atcOption{2}.bReconstrucBed == true % Bed 2
                aReconstructedImage = acBedImage{2};
            end

            if atcOption{3}.bReconstrucBed == true  % Bed 3
                aReconstructedImage = acBedImage{3};
            end            
        end
    end

    aReconstructedImage = double(aReconstructedImage(:,:,end:-1:1));  % Reverse reconstructed image order

            if atcOption{dBedNumber}.Filter.GaussEnable == true 
                aReconstructedImage = imgaussfilt3(aReconstructedImage, atcOption{dBedNumber}.Filter.GaussCuttoff);
            end

    progressBar(1, 'Ready');
   
end