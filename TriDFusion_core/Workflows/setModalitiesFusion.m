function setModalitiesFusion(sModality1, dModality1IntensityMin, dModality1IntensityMax, dModality1MIPIntensityMin, dModality1MIPIntensityMax, sModality2, dModality2IntensityMin, dModality2IntensityMax, dModality2MIPIntensityMin, dModality2MIPIntensityMax, bLink2DMip, bViewContourPanel, dSeries1Offset, dSeries2Offset)
%function setModalitiesFusion(sModality1, dModality1IntensityMin, dModality1IntensityMax, dModality1MIPIntensityMin, dModality1MIPIntensityMax, sModality2, dModality2IntensityMin, dModality2IntensityMax, dModality2MIPIntensityMin, dModality2MIPIntensityMax, bLink2DMip, bViewContourPanel, dSeries1Offset, dSeries2Offset)
%Run fusion between 2 modalities. The second modality is use as resample source.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = inputTemplate('get');

    % Modality validation

    if ~exist('dSeries1Offset', 'var')
        dSeries1Offset = [];
        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, sModality1)
                dSeries1Offset = tt;
                break;
            end
        end
    end

    if ~exist('dSeries2Offset', 'var')
        dSeries2Offset = [];
        for tt=1:numel(atInput)
            if strcmpi(atInput(tt).atDicomInfo{1}.Modality, sModality2)
                dSeries2Offset = tt;
                break;
            end
        end
    end

    if isempty(dSeries1Offset) || ...
       isempty(dSeries2Offset)
        progressBar(1, sprintf('Error: Fusion of %s %s not detected!', sModality1, sModality2));
        errordlg(sprintf('Fusion of %s %s not detected!', sModality1, sModality2), 'Modality Validation');
        return;
    end


    atSerie1MetaData = dicomMetaData('get', [], dSeries1Offset);
    atSerie2MetaData = dicomMetaData('get', [], dSeries2Offset);

    aSerie1Image = dicomBuffer('get', [], dSeries1Offset);
    if isempty(aSerie1Image)
        aInputBuffer = inputBuffer('get');
        aSerie1Image = aInputBuffer{dSeries1Offset};
        clear aInputBuffer;
    end

    aSerie2Image = dicomBuffer('get', [], dSeries2Offset);
    if isempty(aSerie2Image)
        aInputBuffer = inputBuffer('get');
        aSerie2Image = aInputBuffer{dSeries2Offset};
        clear aInputBuffer;
    end

    if isempty(atSerie1MetaData)
        atSerie1MetaData = atInput(dSeries1Offset).atDicomInfo;
    end

    if isempty(atSerie2MetaData)
        atSerie2MetaData = atInput(dSeries2Offset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dSeries1Offset

        set(uiSeriesPtr('get'), 'Value', dSeries1Offset);

        setSeriesCallback();
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    progressBar(1/4, 'Resampling series, please wait.');

    if strcmpi(sModality1, 'nm')
        [aResampledImage, atResampledMetaData] = resampleImage(aSerie1Image, atSerie1MetaData, aSerie2Image, atSerie2MetaData, 'Linear', false, true);
    else
        [aResampledImage, atResampledMetaData] = resampleImage(aSerie1Image, atSerie1MetaData, aSerie2Image, atSerie2MetaData, 'Linear', true, true);
    end

    dicomMetaData('set', atResampledMetaData, dSeries1Offset);
    dicomBuffer  ('set', aResampledImage, dSeries1Offset);

    if size(aSerie1Image, 3) ~= 1

        progressBar(6/10, 'Resampling mip, please wait.');

        refMip = mipBuffer('get', [], dSeries2Offset);
        aMip   = mipBuffer('get', [], dSeries1Offset);

        if strcmpi(sModality1, 'nm')
            aMip = resampleMip(aMip, atSerie1MetaData, refMip, atSerie2MetaData, 'Linear', false);
        else
            aMip = resampleMip(aMip, atSerie1MetaData, refMip, atSerie2MetaData, 'Linear', true);
        end

        mipBuffer('set', aMip, dSeries1Offset);

    end

    setQuantification(dSeries1Offset);

    resampleAxes(aResampledImage, atResampledMetaData);

    setImagesAspectRatio();

    refreshImages();

    drawnow;

    progressBar(2/4, 'Resampling roi, please wait.');

    atRoi = roiTemplate('get', dSeries1Offset);

    if ~isempty(atRoi)

        atResampledRois = resampleROIs(aSerie1Image, atSerie1MetaData, aResampledImage, atResampledMetaData, atRoi, true);

        roiTemplate('set', dSeries1Offset, atResampledRois);

         % Triangulate og 1st VOI

        atVoiInput = voiTemplate('get', dSeries1Offset);

        if ~isempty(atVoiInput)

            dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

            triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
        end

        if size(dicomBuffer('get', [], dSeries1Offset), 3) ~= 1
            
            plotRotatedRoiOnMip(axesMipPtr('get', [], dSeries1Offset), dicomBuffer('get', [], dSeries1Offset), mipAngle('get'));       
        end  
    end

    clear aResampledImage;

    % Activate ROI Panel
    if bViewContourPanel == true

        if viewRoiPanel('get') == false

            if ~isempty(voiTemplate('get', dSeries1Offset))
                setViewRoiPanel();
            end
        end
    end


    % Set Modality 1 intendity

    % Set TCS Axes intensity

    sUnitDisplay = getSerieUnitValue(dSeries1Offset);

    switch lower(sUnitDisplay)

        case 'suv'

            tQuant = atInput(dSeries1Offset).tQuant;

            if isfield(tQuant, 'tSUV')
                dSUVScale = tQuant.tSUV.dScale;
            else
                dSUVScale = 1;
            end

            dSeries1Min    = dModality1IntensityMin/dSUVScale;
            dSeries1Max    = dModality1IntensityMax/dSUVScale;

            if size(aSerie1Image, 3) ~= 1

                dSeries1MIPMin = dModality1MIPIntensityMin/dSUVScale;
                dSeries1MIPMax = dModality1MIPIntensityMax/dSUVScale;
            end

        case 'hu'

            [dSeries1Max   , dSeries1Min   ] = computeWindowLevel(dModality1IntensityMax   , dModality1IntensityMin   );

            if size(aSerie1Image, 3) ~= 1
                [dSeries1MIPMax, dSeries1MIPMin] = computeWindowLevel(dModality1MIPIntensityMax, dModality1MIPIntensityMin);
            end

        otherwise

            dSeries1Min    = min(aSerie1Image, [], 'all');
            dSeries1Max    = max(aSerie1Image, [], 'all');

            if size(aSerie1Image, 3) ~= 1

                dSeries1MIPMin = min(aMip, [], 'all');
                dSeries1MIPMax = max(aMip, [], 'all');
            end
    end

    % Set TCS Axes intensity

%     set(uiSliderWindowPtr('get'), 'value', 0.5);
%     set(uiSliderLevelPtr('get') , 'value', 0.5);
%
%     set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries1Max]);
%     set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries1Max]);
%     set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries1Max]);

    windowLevel('set', 'max', dSeries1Max);
    windowLevel('set', 'min' ,dSeries1Min);

    setWindowMinMax(dSeries1Max, dSeries1Min);

    if size(aSerie1Image, 3) ~= 1


        % Set MIP Axe intensity

        set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1MIPMin dSeries1MIPMax]);

        % Deactivate MIP Fusion

        if bLink2DMip == true
            link2DMip('set', true);

            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
            set(btnLinkMipPtr('get'), 'FontWeight', 'bold');
        else
            link2DMip('set', false);

            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
        end
    end

    % Set fusion

    if isFusion('get') == false

        set(uiFusedSeriesPtr('get'), 'Value', dSeries2Offset);

        setFusionCallback();
    end

    % Set Modality 2 intendity

    % Set TCS Axes intensity

    sUnitDisplay = getSerieUnitValue(dSeries2Offset);

    switch lower(sUnitDisplay)

        case 'suv'

            tQuant = atInput(dSeries2Offset).tQuant;

            if isfield(tQuant, 'tSUV')
                dSUVScale = tQuant.tSUV.dScale;
            else
                dSUVScale = 1;
            end

            dSeries2Min    = dModality2IntensityMin/dSUVScale;
            dSeries2Max    = dModality2IntensityMax/dSUVScale;

            if size(aSerie2Image, 3) ~= 1

                dSeries2MIPMin = dModality2MIPIntensityMin/dSUVScale;
                dSeries2MIPMax = dModality2MIPIntensityMax/dSUVScale;
            end

        case 'hu'

            [dSeries2Max   , dSeries2Min   ] = computeWindowLevel(dModality2IntensityMax   , dModality2IntensityMin   );

            if size(aSerie2Image, 3) ~= 1
                [dSeries2MIPMax, dSeries2MIPMin] = computeWindowLevel(dModality2MIPIntensityMax, dModality2MIPIntensityMin);
            end

        otherwise

            dSeries2Min    = min(aSerie2Image, [], 'all');
            dSeries2Max    = max(aSerie2Image, [], 'all');

            if size(aSerie2Image, 3) ~= 1

                dSeries2MIPMin = min(refMip, [], 'all');
                dSeries2MIPMax = max(refMip, [], 'all');
            end
    end

    % Set Fusion TCS Axes intensity

%     set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%     set(uiFusionSliderLevelPtr('get') , 'value', 0.5);
%
%     set(axes1fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries2Max]);
%     set(axes2fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries2Max]);
%     set(axes3fPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries1Min dSeries2Max]);


    fusionWindowLevel('set', 'max', dSeries2Max);
    fusionWindowLevel('set', 'min' ,dSeries2Min);

    setFusionWindowMinMax(dSeries2Max, dSeries2Min);

    if size(aSerie2Image, 3) ~= 1

        % Set Fusion MIP Axe intensity

        set(axesMipfPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dSeries2MIPMin dSeries2MIPMax]);
    end

    if size(aSerie1Image, 3) ~= 1

        progressBar(3/4, 'Set fusion, please wait.');

        sliderCorCallback();
        sliderSagCallback();
        sliderTraCallback();
    end

%    refreshImages();

    clear aSerie1Image;
    clear aSerie2Image;


    progressBar(1, 'Ready');

    catch
        resetSeries(dSeries2Offset, true);
        progressBar( 1 , 'Error: setModalitiesFusion()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
