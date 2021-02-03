function initKernelPanel()
%function initKernelPanel()
%Kernel Panel Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
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

    if isempty(dicomBuffer('get'))
         sEnable = 'on';
    else
        if size(dicomBuffer('get'), 3) == 1
            sEnable = 'off';
        else
            sEnable = 'on';
        end
    end

    % Reset or Proceed

        uicontrol(uiKernelPanelPtr('get'),...
                  'String','Reset',...
                  'Position',[15 300 100 25],...
                  'Callback', @resetKernelCallback...
                  );

    % 3D Dose Kernel

    tDoseKernel = getDoseKernelTemplate();

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'    , '3D Dose Kernel',...
                  'horizontalalignment', 'left',...
                  'position', [15 250 200 20]...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'style'   , 'text',...
                  'string'  , 'Kernel Model',...
                  'horizontalalignment', 'left',...
                  'position', [15 222 115 20]...
                  );

    uiKernelModel = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [130 225 130 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'Callback', @uiKernelModelCallback...
                  );

  if ~isempty(tDoseKernel)
    set(uiKernelModel, 'String', tDoseKernel.ModelName);
  end

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'style'   , 'text',...
                  'string'  , 'Tissue Dependant',...
                  'horizontalalignment', 'left',...
                  'position', [15 197 115 20]...
                  );

    uiKernelTissue = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [130 200 130 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'Callback', @uiKernelTissueCallback...
                 );

  if ~isempty(tDoseKernel)
    set(uiKernelTissue, 'String', tDoseKernel.Tissue{get(uiKernelModel, 'Value')});
  end

         uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'style'   , 'text',...
                  'string'  , 'Isotope',...
                  'horizontalalignment', 'left',...
                  'position', [15 172 115 20]...
                  );

    uiKernelIsotope = ...
        uicontrol(uiKernelPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position', [130 175 130 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , sEnable, ...
                  'Callback', @uiKernelIsotopeCallback...
                  );

   if ~isempty(tDoseKernel)
    set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
  end
        uicontrol(uiKernelPanelPtr('get'),...
                  'Enable'  , sEnable, ...
                  'String', 'Apply',...
                  'Position',[160 140 100 25],...
                  'Callback', @doseKernelCallback...
                  );

    % 3D Gauss Filter

        uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , '3D Gauss Filter',...
                  'horizontalalignment', 'left',...
                  'position', [15 90 200 20]...
                  );

         uicontrol(uiKernelPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Kernel XYZ size (mm)',...
                  'horizontalalignment', 'left',...
                  'position', [15 62 200 20]...
                  );

    edtGaussFilterX = ...
        uicontrol(uiKernelPanelPtr('get'),...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , gaussFilterValue('get', 'x'),...
                 'position'  , [130 65 40 20]...
                 );

    edtGaussFilterY = ...
        uicontrol(uiKernelPanelPtr('get'),...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , gaussFilterValue('get', 'y'),...
                 'position'  , [175 65 40 20]...
                 );

        edtGaussFilterZ = ...
        uicontrol(uiKernelPanelPtr('get'),...
                 'enable'    , sEnable,...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , gaussFilterValue('get', 'z'),...
                 'position'  , [220 65 40 20]...
                 );

        uicontrol(uiKernelPanelPtr('get'),...
                  'String','Filter',...
                  'Position',[160 30 100 25],...
                  'Callback', @gaussFilterCallback...
                  );

    function uiKernelModelCallback(~, ~)
        if ~isempty(tDoseKernel)
            set(uiKernelTissue, 'Value', 1);
            set(uiKernelTissue, 'String', tDoseKernel.Tissue{get(uiKernelModel, 'Value')});
        end

        if ~isempty(tDoseKernel)
           set(uiKernelIsotope, 'Value', 1);
           set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
        end
    end
    function uiKernelTissueCallback(~, ~)
        if ~isempty(tDoseKernel)
            set(uiKernelIsotope, 'Value', 1);
            set(uiKernelIsotope, 'String', tDoseKernel.Isotope{get(uiKernelModel, 'Value')}{get(uiKernelTissue, 'Value')});
        end
    end

    function uiKernelIsotopeCallback(~, ~)
    end

    function doseKernelCallback(hObject, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        set(uiKernelTissue , 'Enable', 'off');
        set(uiKernelIsotope, 'Enable', 'off');
        set(uiKernelModel  , 'Enable', 'off');
        set(hObject        , 'Enable', 'off');

        try
            setDoseKernel();
        catch
            progressBar(1, 'Error: An error occur during kernel processing!');
            h = msgbox('Error: doseKernelCallback(): An error occur during kernel processing!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end

        set(uiKernelTissue , 'Enable', 'on');
        set(uiKernelIsotope, 'Enable', 'on');
        set(uiKernelModel  , 'Enable', 'on');
        set(hObject        , 'Enable', 'on');

        function setDoseKernel()

            isDoseKernel('set', false);

            tInput = inputTemplate('get');
            dOffset = get(uiSeriesPtr('get'), 'Value');

            if dOffset > numel(tInput)
                return;
            end

            progressBar(0.999, 'Processing kernel, please wait');

            dModel   = get(uiKernelModel   , 'Value');

            dTissue   = get(uiKernelTissue , 'Value' );
            asTissue  = get(uiKernelTissue , 'String');

            dIsotope = get(uiKernelIsotope , 'Value' );
            asIsotope = get(uiKernelIsotope, 'String');

            tKernel = tDoseKernel.Kernel{dModel}.(asTissue{dTissue}).(asIsotope{dIsotope});

            asField = fieldnames(tKernel);

            if numel(asField) == 2
                aDistance = tKernel.(asField{1});
                aDoseR2   = tKernel.(asField{2});
            end

            aActivity = dicomBuffer('get');

            atCoreMetaData = dicomMetaData('get');

            sigmaX = atCoreMetaData{1}.PixelSpacing(1)/10;
            sigmaY = atCoreMetaData{1}.PixelSpacing(2)/10;
            sigmaZ = computeSliceSpacing(atCoreMetaData)/10;

            if strcmp(imageOrientation('get'), 'coronal')
                xPixel = sigmaX;
                yPixel = sigmaZ;
                zPixel = sigmaY;
            end
            if strcmp(imageOrientation('get'), 'sagittal')
                xPixel = sigmaY;
                yPixel = sigmaZ;
                zPixel = sigmaX;
            end
            if strcmp(imageOrientation('get'), 'axial')
                xPixel = sigmaX;
                yPixel = sigmaY;
                zPixel = sigmaZ;
            end

%atCoreMetaData{1}.dose.RadiopharmaceuticalStartDateTime = '20200219193453.00';

            if isempty(atCoreMetaData{1}.dose.RadiopharmaceuticalStartDateTime)
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

            injDateTime = atCoreMetaData{1}.dose.RadiopharmaceuticalStartDateTime;
            acqTime     = atCoreMetaData{1}.SeriesTime;
            acqDate     = atCoreMetaData{1}.SeriesDate;
            halfLife    = str2double(atCoreMetaData{1}.dose.RadionuclideHalfLife);

            for jj=1:numel(atCoreMetaData)
                if isfield(atCoreMetaData{jj}, 'RescaleSlope')
                    atCoreMetaData{jj}.RescaleSlope = 0;
                end
                if isfield(atCoreMetaData{jj}, 'RescaleIntercept')
                    atCoreMetaData{jj}.RescaleIntercept = 0;
                end
                if isfield(atCoreMetaData{jj}, 'Units')
                    atCoreMetaData{jj}.Units = 'DOSE';
                end
            end
            
            dicomMetaData('set', atCoreMetaData);
            
            if numel(injDateTime) == 14
                injDateTime = sprintf('%s.00', injDateTime);
            end

            datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
            daateInjDate = datenum(datetimeInjDate);

            if numel(acqTime) == 6
                acqTime = sprintf('%s.00', acqTime);
            end

            datetimeAcqDate = datetime([acqDate acqTime],'InputFormat','yyyyMMddHHmmss.SS');
            dayAcqDate = datenum(datetimeAcqDate);

            relT = (dayAcqDate - daateInjDate)*(24*60*60); % Acquisition start time

            switch lower(asIsotope{dIsotope})
                case 'y90'
                    betaYield = 1; %Beta yield Y-90
                    betaFactor = 4E7;

                case 'i124'
                    betaYield = 0.92; %Beta yield Y-90
                    betaFactor = 4E7;

                 otherwise
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

%                     aActivity = aActivity*xPixel*yPixel*zPixel; % in mm
             aActivity = aActivity*xPixel*yPixel*zPixel/1000; % in cn
             aActivity = aActivity*2^(relT/halfLife)*halfLife/log(2)*betaYield/betaFactor;

             aDose = zeros(numel(aDoseR2),1);
             for kk=1:numel(aDoseR2)
                 aDose(kk) = aDoseR2(kk)/aDistance(kk)^2;
             end
             % aDose = aDoseR2./aDistance.^2;

            dMax = max(aDose)/1000;
            aVector = find(aDose<dMax);

            dFirst = aVector(1);
            dDistance = aDistance(dFirst);
            %  dDistance = max(aDistance, [], 'all');

            aXYZPixel = zeros(3,1);
            aXYZPixel(1)=xPixel;
            aXYZPixel(2)=yPixel;
            aXYZPixel(3)=zPixel;

            fromTo = ceil(dDistance/min(aXYZPixel, [], 'all'));
            from = 0-abs(fromTo);
            to = abs(fromTo);
            [X,Y,Z] = meshgrid(from:to,from:to,from:to);

            distanceMatrix = sqrt((X*xPixel).^2+(Y*yPixel).^2+(Z*zPixel).^2);
            vqKernel = interp1(aDistance, aDose, distanceMatrix, 'nearest', 'extrap');
            doseBuffer = convn(aActivity, vqKernel, 'same');

            dicomBuffer('set', doseBuffer);

            dMin = min(doseBuffer, [], 'all');
            dMax = max(doseBuffer, [], 'all');

            setWindowMinMax(dMax, dMin);

            isDoseKernel('set', true);

            refreshImages();

            progressBar(1, 'Ready');

        end

    end

    function gaussFilterCallback(~, ~)

        if isempty(dicomBuffer('get'))
            return;
        end

        tInput = inputTemplate('get');
        dOffset = get(uiSeriesPtr('get'), 'Value');

        if dOffset <= numel(tInput)

            aInput = dicomBuffer('get');
            if numel(aInput)
                x = str2double(get(edtGaussFilterX, 'String'));
                y = str2double(get(edtGaussFilterY, 'String'));
                z = str2double(get(edtGaussFilterZ, 'String'));

                atCoreMetaData = dicomMetaData('get');

                if x <= 0
                    set(edtGaussFilterX, 'String', '0.1');
                    x = 0.1;
                end

                if y <= 0
                    set(edtGaussFilterY, 'String', '0.1');
                    y = 0.1;
                end

                if z <= 0
                    set(edtGaussFilterZ, 'String', '0.1');
                    z = 0.1;
                end

                sigmaX = x/atCoreMetaData{1}.PixelSpacing(1);
                sigmaY = y/atCoreMetaData{1}.PixelSpacing(2);

                if size(dicomBuffer('get'), 3) == 1
                    sigmaZ = 1;
                else
                    dComputed = computeSliceSpacing(atCoreMetaData);
                    if dComputed == 0
                        sigmaZ = z/1;
                    else
                        sigmaZ = z/dComputed;
                   end
                end

                if strcmp(imageOrientation('get'), 'coronal')
                    xPixel = sigmaX;
                    yPixel = sigmaZ;
                    zPixel = sigmaY;
                end
                if strcmp(imageOrientation('get'), 'sagittal')
                    xPixel = sigmaY;
                    yPixel = sigmaZ;
                    zPixel = sigmaX;
                end
                if strcmp(imageOrientation('get'), 'axial')
                    xPixel = sigmaX;
                    yPixel = sigmaY;
                    zPixel = sigmaZ;
                end

                dicomBuffer('set', imgaussfilt3(aInput,[xPixel,yPixel,zPixel]));

                if switchTo3DMode('get')     == false &&  ...
                   switchToIsoSurface('get') == false  && ...
                   switchToMIPMode('get')    == false

                    refreshImages();
                end
            end
        end
    end

    function resetKernelCallback(~, ~)

        tInitInput = inputTemplate('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInitInput)
            return;
        end

        aInput = inputBuffer('get');

        if ~strcmp(imageOrientation('get'), 'axial')
            imageOrientation('set', 'axial');
        end

        if     strcmp(imageOrientation('get'), 'axial')
            aBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aBuffer = permute(aInput{iOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aBuffer = permute(aInput{iOffset}, [3 1 2]);
        end
if 0
        if numel(tInitInput(iOffset).asFilesList) ~= 1

            if ~isempty(tInitInput(iOffset).atDicomInfo{1}.ImagePositionPatient)

                if tInitInput(iOffset).atDicomInfo{2}.ImagePositionPatient(3) - ...
                   tInitInput(iOffset).atDicomInfo{1}.ImagePositionPatient(3) > 0
                    aBuffer = aBuffer(:,:,end:-1:1);

                end
            end
        else
            if strcmpi(tInitInput(iOffset).atDicomInfo{1}.PatientPosition, 'FFS')
                aBuffer = aBuffer(:,:,end:-1:1);
            end
        end
end
        isDoseKernel('set', false);
        
        dicomBuffer('set',aBuffer);

        dicomMetaData('set', tInitInput(iOffset).atDicomInfo);

        setQuantification(iOffset);

        fusionBuffer('reset');
        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', 'default');

        clearDisplay();
        initDisplay(3);

        initWindowLevel('set', true);
        quantificationTemplate('set', tInitInput(iOffset).tQuant);

        dicomViewerCore();

        triangulateCallback();

        refreshImages();

    end

end
