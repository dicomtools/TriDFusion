function setDoseKernel(dModel, sTissue, sIsotope, dKernelKernelCutoffDistance, sKernelInterpolation, bUseCtMap, dCtOffset)
%function setDoseKernel(dModel, sTissue, sIsotope, dKernelKernelCutoffDistance, sKernelInterpolation, bUseCtMap, dCtOffset)
%Image convolution from a kernel.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        Brad Beattie, beattieb@mskcc.org
%        C. Ross Schmidtlein, schmidtr@mskcc.org
%        Assen Kirov, kirova@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dlgMicrosphereReport = [];
    axeMicrosphereReport = [];
    listMicrosphereReport = [];

    tInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(tInput)
        return;
    end

    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    aBuffer = dicomBuffer('get', [], dSeriesOffset);

    if isempty(aBuffer)
        return;
    end

    try

        
    % Delete visual boundary, if any

    vBoundAxes1Ptr = visBoundAxes1Ptr('get');
    vBoundAxes2Ptr = visBoundAxes2Ptr('get');
    vBoundAxes3Ptr = visBoundAxes3Ptr('get');

    if ~isempty(vBoundAxes1Ptr)
        delete(vBoundAxes1Ptr);
    end

    if ~isempty(vBoundAxes2Ptr)
        delete(vBoundAxes2Ptr);
    end

    if ~isempty(vBoundAxes3Ptr)
        delete(vBoundAxes3Ptr);
    end

    % Set input template 

    tInput(dSeriesOffset).bDoseKernel = false;
    if numel(tInput) == 1 && isFusion('get') == false
        tInput(dSeriesOffset).bFusedDoseKernel = false;
    end

    progressBar(0.5, 'Processing kernel, please wait.');

    tDoseKernel = getDoseKernelTemplate();

    tKernel = tDoseKernel.Kernel{dModel}.(sTissue).(sIsotope);

    asField = fieldnames(tKernel);

    if numel(asField) == 2
        aDistance = tKernel.(asField{1});
        aDoseR2   = tKernel.(asField{2});
    else
       
        progressBar(0, 'Error:setDoseKernel() invalid kernel!');
                
        return;
    end

    aActivity = double(dicomBuffer('get', [], dSeriesOffset));

    % For radioembolization using microspheres loaded with isotope with half-life T1/2
    % 1)	From PET image – Activity A in kBq for each voxel at time of scan: Ascan= Bq/mL * Vvox(mL)
    % 2)	Activity at injection of microspheres: A0=A*2[(Tscan-Tinjection)/T1/2]
    % 3)	Calculate the total number of disintegrations in the voxel  [Bq * s] =
    % = Cumulative activity Acum= A0 * T1/2(s) / ln(2) = A0 (Bq) *1.442695* T1/2 (s)
    % 4)	Calculate total number of beta-particles (e.g. beta) using the yield Yb
    % Nb= Acum * Yb
    % 5)	Nb,scaled = Nb/(4*107  ) ; (4*10^7 primaries used per George Kagadis e-mail 5-14-20)

    % 6)	Cumulative Dose to point at distance r (mm), D(r) = Nb,scaled * DPKr2(r) / r2

    % For Y-90:
    % T1/2 = 2.6684 d
    % Yb = 1.0

    % Note for non-microsphere tracers:  There will be:
    % - uptake curve which will change step 2
    % - effective half-life due to biological clearance which will change step 3 and trapezoidal integration may be used instead

    atCoreMetaData = dicomMetaData('get');
                
    if kernelMicrosphereInSpecimen('get') == true
        
       % RadiopharmaceuticalInformationSequence is missing, a popup
       % window will be polulated
       
       tMicrosphereInfo = radiopharmaceuticalInformationDialog(); 
       
        if isempty(tMicrosphereInfo) % Cancel        
    
            progressBar(0, 'Ready');                  
            return;
        else 
            dPixelSpacingX = tMicrosphereInfo.dPixelSpacingX;     
            dPixelSpacingY = tMicrosphereInfo.dPixelSpacingY;          
            dPixelSpacingZ = tMicrosphereInfo.dPixelSpacingZ;      
            
            sSeriesDate = tMicrosphereInfo.sCallibrationDate;
            sSeriesTime = tMicrosphereInfo.sCallibrationTime;
            
            sRadiopharmaceuticalStartDate = tMicrosphereInfo.sInfusionDate;
            sRadiopharmaceuticalStartTime = tMicrosphereInfo.sInfusionTime;            
            
            sRadionuclideHalfLife = tMicrosphereInfo.sHalfLife;            
            sRadiopharmaceutical = tMicrosphereInfo.sTreatmentType;                         
            
            sRadiopharmaceuticalStartDateTime = ...
                sprintf('%s%s.00', sRadiopharmaceuticalStartDate, sRadiopharmaceuticalStartTime);
                        
            for jj=1:numel(atCoreMetaData)
                atCoreMetaData{jj}.PixelSpacing(1) = dPixelSpacingX;
                atCoreMetaData{jj}.PixelSpacing(2) = dPixelSpacingY;
                atCoreMetaData{jj}.SpacingBetweenSlices = dPixelSpacingZ;

                atCoreMetaData{jj}.SeriesDate = sSeriesDate;
                atCoreMetaData{jj}.SeriesTime = sSeriesTime;

                atCoreMetaData{jj}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = ...
                    sRadiopharmaceuticalStartDateTime;

                atCoreMetaData{jj}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = sRadionuclideHalfLife;

                atCoreMetaData{jj}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical = sRadiopharmaceutical;        
                atCoreMetaData{jj}.Modality = 'pt';
                
                if ~strcmpi(atCoreMetaData{jj}.SOPClassUID, atCoreMetaData{jj}.MediaStorageSOPClassUID)   
                    atCoreMetaData{jj}.SOPClassUID = atCoreMetaData{jj}.MediaStorageSOPClassUID;  
                end
            end                                        
        end

        bResizePixelSize   = tMicrosphereInfo.bResizePixelSize;            
        dResizeX           = tMicrosphereInfo.dResizePixelSpacingX;            
        dResizeY           = tMicrosphereInfo.dResizePixelSpacingY;            
        dResizeZ           = tMicrosphereInfo.dResizePixelSpacingZ;            
        dMicrosphereVolume = tMicrosphereInfo.dMicrosphereVolume;   
        dSpecimenVolume    = tMicrosphereInfo.dSpecimenVolume;   
        
        progressBar(0.6, 'Processing microsphere, please wait.');
                          
        aActivity(aActivity~=0)=0;
        
        [aActivity, acActivityReport] = computeMicrospereActivity(aActivity, atCoreMetaData, sRadiopharmaceutical, dMicrosphereVolume);
                        

%                dicomBuffer('set', aActivity);
%                return;
        
        
        if bResizePixelSize == true
            
            progressBar(0.7, 'Resampling image, please wait.');
            
            % Resample image
            
            [aActivity, atCoreMetaData] = resampleMicrospereImage(aActivity, atCoreMetaData, dResizeX, dResizeY, dResizeZ);
            
        end

        
        % Calibrate the activity 
                        
        
        if dSpecimenVolume ~= 0                    
            aActivity = aActivity/dSpecimenVolume;
        end
        
    else
        if isempty(atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime)
            
            progressBar(1, 'Error: Dose RadiopharmaceuticalStartDateTime is missing!');
            h = msgbox('Error: setDoseKernel(): Dose RadiopharmaceuticalStartDateTime is missing!', 'Error');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end                
    end
    
    for jj=1:numel(atCoreMetaData)
        if isfield(atCoreMetaData{jj}, 'RescaleSlope')
            atCoreMetaData{jj}.RescaleSlope = 1;
        end
        if isfield(atCoreMetaData{jj}, 'RescaleIntercept')
            atCoreMetaData{jj}.RescaleIntercept = 0;
        end
        if isfield(atCoreMetaData{jj}, 'Units')
            atCoreMetaData{jj}.Units = 'DOSE';
        end
    end

    dicomMetaData('set', atCoreMetaData);
    
    
    % ASK: converting from mm to cm ??
    
    
    xPixelInMm = atCoreMetaData{1}.PixelSpacing(1);
    yPixelInMm = atCoreMetaData{1}.PixelSpacing(2);
    zPixelInMm = computeSliceSpacing(atCoreMetaData);

    xPixelInCm = atCoreMetaData{1}.PixelSpacing(1)/10;
    yPixelInCm = atCoreMetaData{1}.PixelSpacing(2)/10;
    zPixelInCm = computeSliceSpacing(atCoreMetaData)/10;            
    
%            sigmaX = atCoreMetaData{1}.PixelSpacing(1)/10;
%            sigmaY = atCoreMetaData{1}.PixelSpacing(2)/10;
%            sigmaZ = computeSliceSpacing(atCoreMetaData)/10;
                
%            if strcmpi(imageOrientation('get'), 'coronal')
%                xPixel = sigmaX;
%                yPixel = sigmaZ;
%                zPixel = sigmaY;
%            end
    
    
%            if strcmpi(imageOrientation('get'), 'sagittal')
%                xPixel = sigmaY;
%                yPixel = sigmaZ;
%                zPixel = sigmaX;
%            end
    
%            if strcmpi(imageOrientation('get'), 'axial')
%                xPixel = sigmaX;
%                yPixel = sigmaY;
%                zPixel = sigmaZ;
%            end

% ASK: Decay correction

USE_LDM_METHOD = true;

    if USE_LDM_METHOD == false

        injDateTime = atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
        acqTime     = atCoreMetaData{1}.SeriesTime;
        acqDate     = atCoreMetaData{1}.SeriesDate;
        halfLife    = str2double(atCoreMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);
    
        if numel(injDateTime) == 14
            injDateTime = sprintf('%s.00', injDateTime);
        end
    
        datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
        dateInjDate = datenum(datetimeInjDate);
    
        if numel(acqTime) == 6
            acqTime = sprintf('%s.00', acqTime);
        end
    
        datetimeAcqDate = datetime([acqDate acqTime],'InputFormat','yyyyMMddHHmmss.SS');
        dayAcqDate = datenum(datetimeAcqDate);
    
        TscanMinusTinjection = (dayAcqDate - dateInjDate)*(24*60*60); % Acquisition start time
    end

    switch lower(sIsotope)
        
        case 'y90'
            
            betaYield = 1; %Beta yield Y-90
            nbOfParticuleSimulated = 4E7;
            
        case 'y9010e7'
            betaYield = 1; %Beta yield Y-90
            nbOfParticuleSimulated = 10E7; 
            
         case 'y9010e8'
            betaYield = 1; %Beta yield Y-90
            nbOfParticuleSimulated = 10E8;       

        otherwise
if 1                              
             progressBar(1, 'Error: This isotope is not yet validated!');
             h = msgbox('Error: setDoseKernel(): This isotope is not yet validated!', 'Error');
%                     if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                     else
%                        sLogo = './logo.png';
%                     end

%                     javaFrame = get(h, 'JavaFrame');
%                     javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
             return;
end
     end
% ASK: equations 

    if USE_LDM_METHOD == true % LDM method
        
        switch lower(sTissue)
                
            case 'water'
                dNormFactor = 49.7;
                    
            case 'softtissue' % Liver
                dNormFactor = 47.8;
                    
            otherwise
                dNormFactor = 49.7;
        end

        aActivity = dNormFactor*aActivity/10^6;
    
    else  % Kernel convolution method
       
        aActivity = aActivity .* (xPixelInCm .* yPixelInCm .* zPixelInCm); % 1) From PET image – Activity A in Bq for each voxel at time of scan: Ascan = Bq/mL * Vvox(mL)
        A0 = aActivity * 2^((TscanMinusTinjection / halfLife));       % 2) Activity at injection of microspheres: A0 = A * 2^((Tscan - Tinjection) / T1/2)
        Acum = A0 .* halfLife .* 1 / log(2);                            % 3) Calculate the total number of disintegrations in the voxel Acum = A0(Bq) * 1.442695 * T1/2(s)
        Nb = Acum .* betaYield;                                        % 4) Calculate total number of beta-particles (e.g. beta) using the yield Yb Nb = Acum * Yb
        aActivity = Nb ./ nbOfParticuleSimulated;                      % 5) Nb,scaled = Nb / (4*10^7)
        aActivity = aActivity .* 202.53 ./atCoreMetaData{1}.PatientWeight;

    end
    
    aDose = aDoseR2./aDistance.^2;                                    % 6) Cumulative Dose to point at distance r (mm), D(r) = Nb,scaled * DPKr2(r) / r2  

%           aActivity = NbScaled;

    % Set Meshgrid
   % dKernelDistance = str2double(get(uiEditKernelCutoff, 'String'));

%            dKernelCutoff = str2double(get(uiEditKernelCutoff, 'String'));
% ASK: Kernel cut-off level
%            dMax = max(aDose, [], 'all')/dKernelCutoff; % Dose kernel truncated to the cutoff of the max dose
%            aVector = find(aDose<=dMax);

%            dFirst = aVector(1);

%            dDistance = aDistance(dFirst);
    
%            dDistance = aDistance(end); % mm
%            dDistance = 100; % mm

%ASK: size of kernel in voxels

    fromToX = ceil(dKernelKernelCutoffDistance/xPixelInMm);
    fromX = -abs(fromToX);
    toX   =  abs(fromToX);

    fromToY = ceil(dKernelKernelCutoffDistance/yPixelInMm);
    fromY = -abs(fromToY);
    toY   =  abs(fromToY);

    fromToZ = ceil(dKernelKernelCutoffDistance/zPixelInMm);
    fromZ = -abs(fromToZ);
    toZ   =  abs(fromToZ);
    
    progressBar(0.75, 'Creating meshgrid, please wait.');

    try 
        [X,Y,Z] = meshgrid(fromX:toX,fromY:toY,fromZ:toZ);
    catch
        % Try a meshgrid 10x smaler 
         [X,Y,Z] = meshgrid(fromX/10:toX/10,fromY/10:toY/10,fromZ/10:toZ/10);               
    end
    
    % Interpolate Meshgrid

    distanceMatrix = sqrt((X*xPixelInMm).^2+(Y*yPixelInMm).^2+(Z*zPixelInMm).^2);
    
%            vqKernel = interp1(aDistance, aDose, distanceMatrix, 'pchip', 'extrap'); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.

  

    progressBar(0.85, sprintf('Processing %s interpolatiion, please wait.', sKernelInterpolation ));

if 1
   [uniqueDistance, idx] = unique(aDistance);
    uniqueDose = aDose(idx);

    % Kernel in 3D in mm: 
%         vqKernel = interp1(aDistance, aDose, distanceMatrix, asKernelInterpolation{dInterpolationValue}, 'extrap'); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.
    vqKernel = interp1(uniqueDistance, uniqueDose, distanceMatrix, sKernelInterpolation, 'extrap'); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.
%           vqKernel = interp1(aDistance, aDose, distanceMatrix, asKernelInterpolation{dInterpolationValue}); %interpolation method: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', or 'spline'.
%     vqKernel = vqKernel/sum(vqKernel, 'all')*49.67;
else
    % Remove duplicate points from aDistance and aDose
    [uniqueDistance, idx] = unique(aDistance);
    uniqueDose = aDose(idx);
    
    % Create a gridded interpolant object using the 'linear' interpolation method
    interpObj = griddedInterpolant(uniqueDistance, uniqueDose, 'linear');
    
    % Interpolate the values using the gridded interpolant
    vqKernel = interpObj(distanceMatrix);
    
    % Handle extrapolation by setting values outside the domain to NaN
    vqKernel(distanceMatrix < min(uniqueDistance) | distanceMatrix > max(uniqueDistance)) = NaN;   
end

% ASK: Kernel Convolution
    % here; vqKernel has to be in voxels, not mm
    if USE_LDM_METHOD == true

        dKernelSum = sum(vqKernel, 'all');
        if dKernelSum == 0
            dKernelSum = 1;
        end
        vqKernel =  vqKernel/dKernelSum;
       
    end
    
    progressBar(0.95, sprintf('Processing convolution, please wait.'));
     
    aActivity = convn(aActivity, vqKernel, 'same');
    % Pad the input array to handle boundary conditions
%    padSize = floor(size(vqKernel)/2);
%    aActivityPadded = padarray(aActivity, padSize, 'replicate');
    
    % Perform the convolution
%    aActivity = convn(aActivityPadded, vqKernel, 'valid');

    % check mean dose in center of sphere
%            mean(aActivity(62:66,62:66,23:26), 'All')
    
    % Apply CT constraint 

    if bUseCtMap == true
        
        progressBar(0.95, 'Processing CT mask, please wait.');

        aRefBuffer = dicomBuffer('get');
        atRefMetaData = dicomMetaData('get');

        tInput = inputTemplate('get');

        tKernelCtDoseMap = kernelCtDoseMapUiValues('get');

        aCtBuffer = dicomBuffer('get', [], tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

        atCtMetaData = dicomMetaData('get', [], tKernelCtDoseMap{dCtOffset}.dSeriesNumber);
        if isempty(atCtMetaData)

            atCtMetaData = tInput(tKernelCtDoseMap{dCtOffset}.dSeriesNumber).atDicomInfo;
            dicomMetaData('set', atCtMetaData);
        end

        if isempty(aCtBuffer)

            aInput = inputBuffer('get');
            aCtBuffer = aInput{tKernelCtDoseMap{dCtOffset}.dSeriesNumber};
            
  %          if strcmpi(imageOrientation('get'), 'coronal')
  %              aCtBuffer = permute(aCtBuffer, [3 2 1]);
  %          elseif strcmpi(imageOrientation('get'), 'sagittal')
  %              aCtBuffer = permute(aCtBuffer, [2 3 1]);
  %          else
  %              aCtBuffer = permute(aCtBuffer, [1 2 3]);
  %          end

            if tInput(dSeriesOffset).bFlipLeftRight == true
                aCtBuffer=aCtBuffer(:,end:-1:1,:);
            end

            if tInput(dSeriesOffset).bFlipAntPost == true
                aCtBuffer=aCtBuffer(end:-1:1,:,:);
            end

            if tInput(dSeriesOffset).bFlipHeadFeet == true
                aCtBuffer=aCtBuffer(:,:,end:-1:1);
            end

            dicomBuffer('set', aCtBuffer, tKernelCtDoseMap{dCtOffset}.dSeriesNumber);

        end

  %      set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

        dUpperValue = str2double( get(uiEditKernelUpperTreshold, 'String') );
        dLowerValue = str2double( get(uiEditKernelLowerTreshold, 'String') );
        if get(chkUnitTypeKernel, 'Value') == true
            [dUpperValue, dLowerValue] = computeWindowLevel(dUpperValue, dLowerValue);
        end

        dCtMIn = min(double(aCtBuffer),[], 'all');

        aCtBuffer(aCtBuffer<=dLowerValue) = dCtMIn;
        aCtBuffer(aCtBuffer>=dUpperValue) = dCtMIn;

        aCtBuffer(aCtBuffer==dCtMIn)=0;
        aCtBuffer(aCtBuffer~=0)=1;

        [aResamCt, ~] = resampleImage(aCtBuffer, atCtMetaData, aRefBuffer, atRefMetaData, 'Nearest', 2, false);

        dResampMIn = min(double(aResamCt),[], 'all');

        aResamCt(aResamCt==dResampMIn)=0;
        aResamCt(aResamCt~=0)=1;

        aActivity(aResamCt==0) = aBuffer(aResamCt==0);
    end
    
     % Apply ROI constraint 

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dSeriesOffset);

    aLogicalMask = roiConstraintToMask(aBuffer, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);        
    
    aActivity(aLogicalMask==0) = aBuffer(aLogicalMask==0); % Set constraint      
    
    dicomBuffer('set', aActivity, dSeriesOffset);

    setQuantification(dSeriesOffset);

    if link2DMip('get') == true
        imMip = computeMIP(aActivity);
        mipBuffer('set', imMip, dSeriesOffset);
    end

    tInput(dSeriesOffset).bDoseKernel = true;
    if numel(tInput) == 1 && isFusion('get') == false
        tInput(dSeriesOffset).bFusedDoseKernel = true;
    end

    inputTemplate('set', tInput);
           
    dMin = min(aActivity, [], 'all');
    dMax = max(aActivity, [], 'all');
    
    if kernelMicrosphereInSpecimen('get') == true
        if bResizePixelSize == true
            setWindowMinMax(dMax, dMin, false); % setWindowMinMax() will refreshImages(), need to clear the display before
            
            clearDisplay();
            initDisplay(3);

            dicomViewerCore();
        else
            setWindowMinMax(dMax, dMin, true); % setWindowMinMax() will refreshImages()
%                    refreshImages();
        end
    else
        setWindowMinMax(dMax, dMin, true); % setWindowMinMax() will refreshImages()
%                refreshImages();
    end

    modifiedMatrixValueMenuOption('set', true);

    if exist('acActivityReport', 'var')
        if ~isempty(acActivityReport)
            sReport = strjoin(acActivityReport(1,:),',');    
            for jj=2:size(acActivityReport, 1) 
                sReport = sprintf('%s\n%s', sReport, strjoin(acActivityReport(jj,:),','));    
            end

            DLG_REPORT_X = 1024;
            DLG_REPORT_Y = 480;
            
            dlgMicrosphereReport = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_REPORT_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_REPORT_Y/2) ...
                                    DLG_REPORT_X ...
                                    DLG_REPORT_Y ...
                                    ],...
                       'MenuBar'    , 'none',...
                       'Resize'     , 'on', ...    
                       'NumberTitle','off',...
                       'MenuBar'    , 'none',...
                       'Color'      , viewerBackgroundColor('get'), ...
                       'Name'       , 'Microsphere Activity Report',...
                       'Toolbar'    ,'none',...               
                       'SizeChangedFcn',@resizeMicrosphereReportCallback...
                       );     

            axeMicrosphereReport = ...                   
                axes(dlgMicrosphereReport, ...
                     'Units'   , 'pixels', ...
                     'Position', [0 0 DLG_REPORT_X DLG_REPORT_Y], ...
                     'Color'   , viewerBackgroundColor('get'),...
                     'XColor'  , viewerForegroundColor('get'),...
                     'YColor'  , viewerForegroundColor('get'),...
                     'ZColor'  , viewerForegroundColor('get'),...             
                     'Visible' , 'off'...             
                     );  
            axeMicrosphereReport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
            axeMicrosphereReport.Toolbar = []; 

            listMicrosphereReport = ...                   
                uicontrol(dlgMicrosphereReport,...
                          'style'   , 'listbox',...
                          'position', [0 0 DLG_REPORT_X DLG_REPORT_Y],...
                          'fontsize', 10,...
                          'Fontname', 'Monospaced',...
                          'Value'   , 1 ,...
                          'Selected', 'off',...
                          'enable'  , 'on',...
                          'string'  , sReport...
                          );          
        end
    end

    progressBar(1, 'Ready');

    catch
        progressBar(1, 'Error:setDoseKernel()');
    end

    function resizeMicrosphereReportCallback(~, ~)

        if ~isempty(dlgMicrosphereReport)
              
            aDialogPosition  = get(dlgMicrosphereReport, 'Position');
    
            if ~isempty(axeMicrosphereReport)

                set(axeMicrosphereReport, ...
                    'Position', ...
                    [0 ...
                     0 ...
                     aDialogPosition(3) ...
                     aDialogPosition(4) ...
                    ]); 
            end
    
            if ~isempty(listMicrosphereReport)

                set(listMicrosphereReport, ...
                    'Position', ...
                    [0 ...
                     0 ...
                     aDialogPosition(3) ...
                     aDialogPosition(4) ...
                    ]);
            end
        end
    end
end

