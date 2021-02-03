function setRegistrationCallback(~, ~)
%function setRegistrationCallback(~, ~)
%Set Registration and Resampling Main Function.
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

    tRegistration = registrationTemplate('get');

    dlgRegister = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-810/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-520/2) ...
                            810 ...
                            545 ...
                            ],...
               'Name', 'Image Registration'...
               );

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(dlgRegister,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

    lbRegWindow = ...
        uicontrol(dlgRegister,...
                  'style'   , 'listbox',...
                  'position', [325 0 485 520],...
                  'fontsize', 10,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , seriesDescription('get'),...
                  'Callback', @lbRegWindowCallback...
                  );

    set(lbRegWindow, 'Max',2, 'Min',0);

        uicontrol(dlgRegister,...
                  'String','Reset',...
                  'Position',[15 500 100 25],...
                  'Callback', @resetRegistrationCallback...
                  );

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Resample',...
                  'horizontalalignment', 'left',...
                  'position', [15 450 200 20]...
                  );
          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Interpolation',...
                  'horizontalalignment', 'left',...
                  'position', [15 422 200 20]...
                  );

    switch lower(tRegistration.Interpolation)
        case 'linear'
            dInterpolation = 1;
        case 'cubic'
            dInterpolation = 2;
        case 'nearest'
            dInterpolation = 3;
        otherwise
            dInterpolation = 1;
    end

    uiInterpolation = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'position', [180 425 130 20],...
                  'String'  , {'Linear', 'Cubic', 'Nearest'}, ...
                  'Value'   , dInterpolation ...
                  );

        uicontrol(dlgRegister,...
                  'String','Resample',...
                  'Position',[210 390 100 25],...
                  'Callback', @resampleCallback...
                  );

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Registration',...
                  'horizontalalignment', 'left',...
                  'position', [15 340 200 20]...
                  );

    chkSeriesDescription = ...
          uicontrol(dlgRegister,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , updateDescription('get'),...
                  'position', [180 315 20 20],...
                  'Callback', @updateDescriptionCallback...
                  );

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Update Description',...
                  'horizontalalignment', 'left',...
                  'position', [15 312 160 20],...
                  'Enable', 'Inactive',...
                  'ButtonDownFcn', @updateDescriptionCallback...
                  );

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Transformation',...
                  'horizontalalignment', 'left',...
                  'position', [15 287 200 20]...
                  );

    switch lower(tRegistration.Transformation)
        case 'translation'
            dTransformValue = 1;
        case 'rigid'
            dTransformValue = 2;
        case 'similarity'
            dTransformValue = 3;
        case 'affine'
            dTransformValue = 4;
        otherwise
            dTransformValue = 1;
    end

    uiTransformation = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'position', [180 290 130 20],...
                  'String'  , {'Translation', 'Rigid', 'Similarity', 'Affine'}, ...
                  'Value'   , dTransformValue ...
                  );

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Matric',...
                  'horizontalalignment', 'left',...
                  'position', [15 265 200 20]...
                  );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Nb Of Spatial Samples',...
                  'horizontalalignment', 'left',...
                  'position', [15 237 200 20]...
                  );

    uiNumberOfSpatialSamples = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Metric.NumberOfSpatialSamples),...
                 'position'  , [180 240 130 20]...
                 );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Nb Of Histogram Bins',...
                  'horizontalalignment', 'left',...
                  'position', [15 212 200 20]...
                  );

    uiNumberOfHistogramBins = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Metric.NumberOfHistogramBins),...
                 'position'  , [180 215 130 20]...
                 );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Use All Pixels',...
                  'horizontalalignment', 'left',...
                  'position', [15 187 200 20]...
                  );

    if tRegistration.Metric.UseAllPixels == true
        dAllPixelsValue = 1;
    else
        dAllPixelsValue = 2;
    end

    uiUseAllPixels = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'position', [180 190 130 20],...
                  'String'  , {'True' 'False'}, ...
                  'Value'   , dAllPixelsValue ...
                  );

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Optimizer',...
                  'horizontalalignment', 'left',...
                  'position', [15 165 200 20]...
                  );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Growth Factor',...
                  'horizontalalignment', 'left',...
                  'position', [15 137 200 20]...
                  );

    uiGrowthFactor = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Optimizer.GrowthFactor),...
                 'position'  , [180 140 130 20]...
                 );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Epsilon (e-06)',...
                  'horizontalalignment', 'left',...
                  'position', [15 112 200 20]...
                  );

    uiEpsilon = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Optimizer.Epsilon/1e-06),...
                 'position'  , [180 115 130 20]...
                 );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Initial Radius (e-03)',...
                  'horizontalalignment', 'left',...
                  'position', [15 87 200 20]...
                  );

    uiInitialRadius = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Optimizer.InitialRadius/1e-03),...
                 'position'  , [180 90 130 20]...
                 );

         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Maximum Iterations',...
                  'horizontalalignment', 'left',...
                  'position', [15 62 200 20]...
                  );

    uiMaximumIterations = ...
        uicontrol(dlgRegister,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(tRegistration.Optimizer.MaximumIterations),...
                 'position'  , [180 65 130 20]...
                 );

        uicontrol(dlgRegister,...
                  'String','Register',...
                  'Position',[210 30 100 25],...
                  'Callback', @registerCallback...
                  );

    adLbSeries = zeros(size(seriesDescription('get')));
    dNextPosition = 1;

    function lbRegWindowCallback(~, ~)

        adLbOffset = get(lbRegWindow,  'Value');
        asLbString = get(lbRegWindow,  'String');
        asSeriesString = seriesDescription('get');

        if numel(adLbOffset) > numel(asLbString) || ...
           isempty(seriesDescription('get'))
            return;
        end

        if numel(adLbOffset) == 0 % No entry
            set(lbRegWindow, 'String', seriesDescription('get'));
            for jj=1:numel(adLbSeries)
                adLbSeries(jj) = 0;
            end
        elseif numel(adLbOffset) == 1 % First Entry
            dLbOffset = adLbOffset(1);

            for jj=1:numel(adLbSeries)
                if jj==dLbOffset
                    adLbSeries(dLbOffset) = 1;
                    asSeriesString{dLbOffset} = sprintf('1- %s', asSeriesString{dLbOffset});
                    dNextPosition = 2;
                else
                    adLbSeries(jj) = 0;
                end
            end

            set(lbRegWindow, 'String', asSeriesString);
        else
            dNbElementCurrent = 1;
            for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
                if adLbSeries(ll) ~= 0
                    dNbElementCurrent = dNbElementCurrent+1;
                end
            end

            if dNbElementCurrent > numel(adLbOffset) % Substract one position
                adNewSeries = zeros(size(seriesDescription('get')));
                for jj=1:numel(adNewSeries) % Set a new array
                    for kk=1:numel(adLbOffset)
                        if adLbOffset(kk)==jj
                            adNewSeries(jj)=adLbSeries(adLbOffset(kk));
                        end
                    end
                end

                for jj=1:numel(adNewSeries) % Reset all series with 0
                    if adNewSeries(jj) == 0
                        asLbString{jj}=sprintf('%s', asSeriesString{jj});
                    end
                end

                dMissingElement =1;
                for kk=1:numel(adLbSeries(adLbOffset)) % Find the series offset to substract
                    for jj=1:numel(adNewSeries)
                        if adNewSeries(jj) == dMissingElement
                            dMissingElement = dMissingElement+1;
                        end
                    end
                end

                for jj=1:numel(adNewSeries)
                    if adNewSeries(jj) > dMissingElement
                        adNewSeries(jj) = adNewSeries(jj)-1;
                        asLbString{jj}=sprintf('%d- %s', adNewSeries(jj), asSeriesString{jj});
                    end
                end

                adLbSeries = adNewSeries;
                dNextPosition = dNextPosition -1;

            else  % Add one position

                for jj=1:numel(adLbOffset)
                    dCurOffset = adLbOffset(jj);
                    for kk=1:numel(asSeriesString)
                        if kk==dCurOffset && ...
                           adLbSeries(kk) == 0

                            adLbSeries(kk) = dNextPosition;
                            asLbString{kk}=sprintf('%d- %s', adLbSeries(kk), asSeriesString{kk});
                            dNextPosition = dNextPosition+1;
                        end
                    end

                end
            end

            dListboxTop = get(lbRegWindow, 'ListboxTop');
            set(lbRegWindow, 'String', asLbString);
            set(lbRegWindow, 'ListboxTop', dListboxTop);
        end

    end

    function resetRegistrationCallback(~, ~)

        tInitInput = inputTemplate('get');
        dInitOffset = get(uiSeriesPtr('get'), 'Value');
        if dInitOffset > numel(tInitInput)
            return;
        end

        set(uiSeriesPtr('get'), 'Enable', 'off');

        aInput = inputBuffer('get');

        if ~strcmp(imageOrientation('get'), 'axial')
            imageOrientation('set', 'axial');
        end

        asDescription = seriesDescription('get');
        for jj=1:numel(aInput)

            set(uiSeriesPtr('get'), 'Value', jj);

            if     strcmp(imageOrientation('get'), 'axial')
                aBuffer = permute(aInput{jj}, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal')
                aBuffer = permute(aInput{jj}, [3 2 1]);
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aBuffer = permute(aInput{jj}, [3 1 2]);
            end
if 0
            if numel(tInitInput(jj).asFilesList) ~= 1

                if ~isempty(tInitInput(jj).atDicomInfo{1}.ImagePositionPatient)

                    if tInitInput(jj).atDicomInfo{2}.ImagePositionPatient(3) - ...
                       tInitInput(jj).atDicomInfo{1}.ImagePositionPatient(3) > 0
                        aBuffer = aBuffer(:,:,end:-1:1);

                    end
                end
            else
                if strcmpi(tInitInput(jj).atDicomInfo{1}.PatientPosition, 'FFS')
                    aBuffer = aBuffer(:,:,end:-1:1);
                end
            end
end
            sInitSeriesDate = [tInitInput(jj).atDicomInfo{1}.SeriesDate tInitInput(jj).atDicomInfo{1}.SeriesTime];
            if contains(sInitSeriesDate,'.')
                sInitSeriesDate = extractBefore(sInitSeriesDate,'.');
            end

            sInitSeriesDate = datetime(sInitSeriesDate,'InputFormat','yyyyMMddHHmmss');

            sInitSeriesDescription = tInitInput(jj).atDicomInfo{1}.SeriesDescription;

            asDescription{jj} = sprintf('%s %s', sInitSeriesDescription, sInitSeriesDate);


            dicomBuffer('set',aBuffer);

            dicomMetaData('set', tInitInput(jj).atDicomInfo);

            setQuantification(jj);
        end
        seriesDescription('set', asDescription);

        set(uiSeriesPtr('get'), 'Value', dInitOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        fusionBuffer('reset');
        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', 'default');
        
        isDoseKernel('set', false);

        delete(dlgRegister);

        clearDisplay();
        initDisplay(3);

        initWindowLevel('set', true);
        quantificationTemplate('set', tInitInput(dInitOffset).tQuant);

        dicomViewerCore();

%              triangulateCallback();

        refreshImages();
    end

    function resampleCallback(~, ~)

        asInterpolation = get(uiInterpolation, 'String');
        sInterpolation  = asInterpolation{get(uiInterpolation, 'Value')};
        registrationTemplate('set', tRegistration);

        dNbElements = 0;
        for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
            if adLbSeries(ll) ~= 0
                dNbElements = dNbElements+1;
            end
        end

        if dNbElements < 2
            progressBar(1, 'Error: At least 2 volumes must be selected!');
            h = msgbox('Error: registerCallback(): At least 2 volumes must be selected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end

        tInput = inputTemplate('get');
        aInput = inputBuffer('get');

        dInitOffset = get(uiSeriesPtr('get'), 'Value');

        set(uiSeriesPtr('get'), 'Enable', 'off');

        bInitRef = true;
        dNextSeries = 1;
        for hh=1:dNbElements
            for kk=1:numel(adLbSeries)

                set(uiSeriesPtr('get'), 'Value', kk);
                aBuffer    = dicomBuffer('get');
                atMetaData = dicomMetaData('get');

                if ~isempty(aInput{kk}) && ...
                   ~(size(aInput{kk}, 3) == 1)

                    if  isempty(aBuffer)

                        if     strcmp(imageOrientation('get'), 'axial')
                            aBuffer = permute(aInput{kk}, [1 2 3]);
                        elseif strcmp(imageOrientation('get'), 'coronal')
                            aBuffer = permute(aInput{kk}, [3 2 1]);
                        elseif strcmp(imageOrientation('get'), 'sagittal')
                            aBuffer = permute(aInput{kk}, [3 1 2]);
                        end
if 0
                        if numel(tInput(kk).asFilesList) ~= 1

                            if ~isempty(tInput(kk).atDicomInfo{1}.ImagePositionPatient)

                                if tInput(kk).atDicomInfo{2}.ImagePositionPatient(3) - ...
                                   tInput(kk).atDicomInfo{1}.ImagePositionPatient(3) > 0
                                    aBuffer = aBuffer(:,:,end:-1:1);

                                end
                            end
                        else
                            if strcmpi(tInput(kk).atDicomInfo{1}.PatientPosition, 'FFS')
                                aBuffer = aBuffer(:,:,end:-1:1);
                            end
                        end
end
                    end
                end

                if isempty(atMetaData)
                    atMetaData = tInput(kk).atDicomInfo;
                end

                if adLbSeries(kk) == 1 && bInitRef == true
              %      dInitOffset = kk;
                    bInitRef = false;
                    atRefMetaData = atMetaData;
                    refImage = aBuffer;
                    dNextSeries = 2;

                    dicomBuffer('set', refImage);
                    dicomMetaData('set', atRefMetaData);
                    setQuantification(kk);

                    break;
                end

                if dNextSeries >1
                    if adLbSeries(kk) == dNextSeries

                        progressBar(dNextSeries/dNbElements-0.000001, sprintf('Processing resampling %d/%d, please wait', dNextSeries-1, dNbElements-1));

                        [aBuffer, atMetaData] = resampleImage(aBuffer, atMetaData, refImage, atRefMetaData, sInterpolation);
                        dicomMetaData('set', atMetaData);
                        dicomBuffer('set', aBuffer);

                        setQuantification(kk);

                        dNextSeries = dNextSeries+1;

                    end
                end
            end

        end

        progressBar(1, 'Ready');

        set(uiSeriesPtr('get'), 'Value', dInitOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', 'default');

        delete(dlgRegister);

        clearDisplay();
        initDisplay(3);

    %    dicomViewerCore();

    %    initWindowLevel('set', true);
    %    quantificationTemplate('set', tInput(dInitOffset).tQuant);

        dicomViewerCore();

        setViewerDefaultColor(true, dicomMetaData('get'));

%            triangulateCallback();

        refreshImages();
%            refreshImages();
    end

    function registerCallback(~, ~)

        asInterpolation = get(uiInterpolation, 'String');
        sInterpolation  = asInterpolation{get(uiInterpolation, 'Value')};

        tRegistration.Interpolation = lower(sInterpolation);

        asTransformation = get(uiTransformation, 'String');
        sTransformation = asTransformation{get(uiTransformation, 'Value')};

        tRegistration.Transformation = lower(sTransformation);

        tRegistration.Metric.NumberOfSpatialSamples = str2double(get(uiNumberOfSpatialSamples, 'String'));
        tRegistration.Metric.NumberOfHistogramBins  = str2double(get(uiNumberOfHistogramBins , 'String'));

        asUseAllPixels = get(uiUseAllPixels, 'String');
        sUseAllPixels  = asUseAllPixels{get(uiUseAllPixels, 'Value')};
        if strcmpi(sUseAllPixels, 'True')
            bUseAllPixels = true;
        else
            bUseAllPixels = false;
        end
        tRegistration.Metric.UseAllPixels = bUseAllPixels;

        tRegistration.Optimizer.GrowthFactor = str2double(get(uiGrowthFactor, 'String'));

        dEpsilon = str2double(get(uiEpsilon, 'String')) * 1e-06;
        tRegistration.Optimizer.Epsilon = dEpsilon;


        dInitialRadius = str2double(get(uiInitialRadius, 'String')) * 1e-03;
        tRegistration.Optimizer.InitialRadius = dInitialRadius;

        tRegistration.Optimizer.MaximumIterations = str2double(get(uiMaximumIterations, 'String'));

        registrationTemplate('set', tRegistration);

        sMode     = tRegistration.Transformation;
        metric    = tRegistration.Metric;
        optimizer = tRegistration.Optimizer;

        dNbElements = 0;
        for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
            if adLbSeries(ll) ~= 0
                dNbElements = dNbElements+1;
            end
        end

        if dNbElements < 2
            progressBar(1, 'Error: At least 2 volumes must be selected!');
            h = msgbox('Error: registerCallback(): At least 2 volumes must be selected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end

        tInput = inputTemplate('get');
        aInput = inputBuffer('get');

        dInitOffset = get(uiSeriesPtr('get'), 'Value');

        set(uiSeriesPtr('get'), 'Enable', 'off');

        registrationReport('set', '');

        bInitRef = true;
        dNextSeries = 1;
        for hh=1:dNbElements
            for kk=1:numel(adLbSeries)

                set(uiSeriesPtr('get'), 'Value', kk);
                aBuffer    = dicomBuffer('get');
                atMetaData = dicomMetaData('get');

                if ~isempty(aInput{kk})

                    if(size(aInput{kk}, 3) == 1)
                        if  isempty(aBuffer)
                            aBuffer  = aInput{kk};
                        end
                    else

                        if  isempty(aBuffer)

                            if     strcmp(imageOrientation('get'), 'axial')
                                aBuffer = permute(aInput{kk}, [1 2 3]);
                            elseif strcmp(imageOrientation('get'), 'coronal')
                                aBuffer = permute(aInput{kk}, [3 2 1]);
                            elseif strcmp(imageOrientation('get'), 'sagittal')
                                aBuffer = permute(aInput{kk}, [3 1 2]);
                            end
                        end
                    end
                end

                if isempty(atMetaData)
                    atMetaData = tInput(kk).atDicomInfo;
                end

                if adLbSeries(kk) == 1 && bInitRef == true
             %       dInitOffset = kk;
                    bInitRef = false;
                    atRefMetaData = atMetaData;
                    refImage = aBuffer;
                    dNextSeries = 2;

                    if get(chkSeriesDescription, 'Value') == true
                        atRefMetaData{kk}.SeriesDescription  = sprintf('REF-COREG %s', atRefMetaData{kk}.SeriesDescription);
                        asDescription = seriesDescription('get');
                        asDescription{kk} = sprintf('REF-COREG %s', asDescription{kk});

                        seriesDescription('set', asDescription);
                    end

                    dicomBuffer('set', refImage);
                    dicomMetaData('set', atRefMetaData);
                    setQuantification(kk);

                    updateDescription('set', get(chkSeriesDescription, 'Value'));

                    break;
                end

                if dNextSeries >1
                    if adLbSeries(kk) == dNextSeries

                        progressBar(dNextSeries/dNbElements-0.000001, sprintf('Processing registration %d/%d, please wait', dNextSeries-1, dNbElements-1));
                        [aBuffer, atMetaData, Rregistered, Rmoving] = registerImage(aBuffer, atMetaData, refImage, atRefMetaData, sMode, optimizer, metric, updateDescription('get'));

                        sReport = sprintf('Registration %d', dNextSeries-1);
                        sReport = sprintf('%s\nFixed Volume : %s', sReport, atRefMetaData{1}.SeriesDescription);
                        sReport = sprintf('%s\nMoving Volume: %s', sReport, atMetaData{1}.SeriesDescription);

                        sRmoving = R_regToString(Rmoving);
                        sReport = sprintf('%s\n\nMoving Volume:\n%s', sReport, sRmoving);
                        sRregistered = R_regToString(Rregistered);
                        sReport = sprintf('%s\n\nRegistrated Volume:\n%s\n\n', sReport, sRregistered);

                        registrationReport('add', sReport);

                        dicomBuffer('set', aBuffer);
                        dicomMetaData('set', atMetaData);
                        dNextSeries = dNextSeries+1;
                    end
                end
            end

        end

        progressBar(1, 'Ready');

        set(uiSeriesPtr('get'), 'Value', dInitOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', 'default');

        delete(dlgRegister);

        clearDisplay();
        initDisplay(3);

  %      initWindowLevel('set', true);
  %      quantificationTemplate('set', tInput(dInitOffset).tQuant);

        dicomViewerCore();

        setViewerDefaultColor(true, dicomMetaData('get'));

%         triangulateCallback();

        refreshImages();

%        refreshImages();
 %       aBuffer = registerImage(aBuffer, atMetaData, refImage, tInput(iRefOffset).atDicomInfo, sMode, optimizer, metric);

    end

    function updateDescriptionCallback(hObject, ~)

         if get(chkSeriesDescription, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'Checkbox')
                set(chkSeriesDescription, 'Value', true);
            else
                set(chkSeriesDescription, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')
                set(chkSeriesDescription, 'Value', false);
            else
                set(chkSeriesDescription, 'Value', true);
            end
         end

    end
end
