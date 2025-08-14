function setSegmentationGa68DOTATATE(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, dNormalLiverThresholdMultiplier, bUseDefault)
%function setSegmentationGa68DOTATATE(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, dNormalLiverThresholdMultiplier, bUseDefault)
%Run Ga68DOTATATE Segmentation base on normal liver Threshold.
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

    gbProceedWithSegmentation = false;
    gdNormalLiverMean = [];
    gdNormalLiverSTD = [];
    gaLiverMask = [];

    atInput = inputTemplate('get');

    % Modality validation

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break;
        end
    end

    dPTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')
            dPTSerieOffset = tt;
            break;
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dPTSerieOffset)
        progressBar(1, 'Error: FDG tumor segmentation require a CT and PT image!');
        errordlg('FDG tumor segmentation require a CT and PT image!', 'Modality Validation');
        return;
    end


    atPTMetaData = dicomMetaData('get', [], dPTSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aPTImage = dicomBuffer('get', [], dPTSerieOffset);
    if isempty(aPTImage)
        aInputBuffer = inputBuffer('get');
        aPTImage = aInputBuffer{dPTSerieOffset};
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    if isempty(atPTMetaData)
        atPTMetaData = atInput(dPTSerieOffset).atDicomInfo;
    end

    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dPTSerieOffset
        set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

        setSeriesCallback();
    end

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    atRoiInput = roiTemplate('get', dPTSerieOffset);

    if ~isempty(atRoiInput)

        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Normal Liver'} );
        dTagOffset = find(aTagOffset, 1);

        aSlice = [];

        if ~isempty(dTagOffset)

            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'
                    aSlice = permute(aPTImage(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    aSlice = permute(aPTImage(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                case 'axes3'
                    aSlice = aPTImage(:,:,atRoiInput{dTagOffset}.SliceNb);
            end

            aLogicalMask = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);

            gdNormalLiverMean = mean(aSlice(aLogicalMask), 'all')   * dSUVScale;


   %         H = fspecial('average',5);
   %         blurred = imfilter(aSlice(aLogicalMask),H,'replicate');

            gdNormalLiverSTD = std(aSlice(aLogicalMask), [],'all') * dSUVScale;

            clear aSlice;
        else
            if bUseDefault == false

                waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));

                Ga68DOTATATENormalLiverMeanSDDialog();

                if gbProceedWithSegmentation == false
                    return;
                end
            else
                gdNormalLiverMean = Ga68DOTATATENormalLiverMeanValue('get');
                gdNormalLiverSTD  = Ga68DOTATATENormalLiverSDValue('get');

            end
        end
    else
        if bUseDefault == false

            waitfor(msgbox('Warning: Please define a Normal Liver ROI. Draw an ROI on the normal liver, right-click on the ROI, and select Predefined Label ''Normal Liver,'' or manually input a normal liver mean and SD into the following dialog.', 'Warning'));

            Ga68DOTATATENormalLiverMeanSDDialog();

            if gbProceedWithSegmentation == false
                return;
            end

        else
            gdNormalLiverMean = Ga68DOTATATENormalLiverMeanValue('get');
            gdNormalLiverSTD  = Ga68DOTATATENormalLiverSDValue('get');

        end
    end

    if ~isempty(atRoiInput)

        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Liver'} );
        dTagOffset = find(aTagOffset, 1);

        if ~isempty(dTagOffset)

            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'
                    aSlice = permute(aPTImage(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    aSlice = permute(aPTImage(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                case 'axes3'
                    aSlice = aPTImage(:,:,atRoiInput{dTagOffset}.SliceNb);
            end

            gaLiverMask = false(size(aPTImage));

            aLogicalMask = roiTemplateToMask(atRoiInput{dTagOffset}, aSlice);

            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'

                    for kk=1:size(aPTImage, 1)

                        aSlice = permute(gaLiverMask(kk,:,:), [3 2 1]); % 10% of Threshold Liver
                        aSlice(aLogicalMask)=true;
                        gaLiverMask(kk,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                    end

                case 'axes2'

                    for kk=1:size(gaLiverMask, 2)
                        aSlice = permute(gaLiverMask(:,kk,:), [3 1 2]); % 10% of Threshold Liver
                        aSlice(aLogicalMask)=true;
                        gaLiverMask(:,kk,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                    end

                case 'axes3'

                    for kk=1:size(gaLiverMask, 3)
                        aSlice = gaLiverMask(:,:,kk); % 10% of Threshold Liver
                        aSlice(aLogicalMask)=true;
                        gaLiverMask(:,:,kk) = aSlice;
                    end
            end

        end
    end


    % Apply ROI constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dPTSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dPTSerieOffset);

    aPTImageTemp = aPTImage;
    aLogicalMask = roiConstraintToMask(aPTImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);

    if any(aLogicalMask(:) ~= 0)

        aPTImageTemp(aLogicalMask==0) = 0;  % Set constraint
    end

    resetSeries(dPTSerieOffset, true);

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if isInterpolated('get') == false

        isInterpolated('set', true);

        setImageInterpolation(true);
    end

    progressBar(5/11, 'Resampling data series, please wait...');

    [aResampledPTImageTemp, ~] = resampleImage(aPTImageTemp, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);
    [aResampledPTImage, atResampledPTMetaData] = resampleImage(aPTImage, atPTMetaData, aCTImage, atCTMetaData, 'Linear', true, false);

    dicomMetaData('set', atResampledPTMetaData, dPTSerieOffset);
    dicomBuffer  ('set', aResampledPTImage, dPTSerieOffset);

    aResampledPTImage = aResampledPTImageTemp;

    clear aPTImageTemp;
    clear aResampledPTImageTemp;


    progressBar(6/11, 'Resampling MIP, please wait...');

    refMip = mipBuffer('get', [], dCTSerieOffset);
    aMip   = mipBuffer('get', [], dPTSerieOffset);

    aMip = resampleMip(aMip, atPTMetaData, refMip, atCTMetaData, 'Linear', true);

    mipBuffer('set', aMip, dPTSerieOffset);

    setQuantification(dPTSerieOffset);

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    if ~isempty(gaLiverMask)

        [gaLiverMask, ~] = resampleImage(gaLiverMask, atPTMetaData, aCTImage, atCTMetaData, 'Nearest', true, false);

        progressBar(7/11, 'Computing liver mask, please wait.');

        dLiverThreshold = (dNormalLiverThresholdMultiplier*gdNormalLiverMean) + (2*gdNormalLiverSTD);

        aLiverBWMask = aResampledPTImage;

        dMin = min(aLiverBWMask, [], 'all');

        aLiverBWMask(aLiverBWMask*dSUVScale<dLiverThreshold)=dMin;

        aLiverBWMask = imbinarize(aLiverBWMask);

        aLiverBWMask(gaLiverMask==0)=0;
    end

    progressBar(8/11, 'Computing mask, please wait...');

    aBWMask = aResampledPTImage;

    dMin = min(aBWMask, [], 'all');

%     dThreshold = max(aResampledPTImage, [], 'all')*dBoundaryPercent;
    dThreshold = (4.44/gdNormalLiverMean)*(gdNormalLiverMean+gdNormalLiverSTD);
    if dThreshold < 3
        dThreshold = 3;
    end

    aBWMask(aBWMask*dSUVScale<dThreshold)=dMin;

    aBWMask = imbinarize(aBWMask);

    progressBar(9/11, 'Computing CT map, please wait...');

    % BWCT = aCTImage;

    BWCT = aCTImage >= dBoneMaskThreshold;   % Logical mask creation
    BWCT = imfill(single(BWCT), 4, 'holes'); % Fill holes in the binary mask

%     BWCT = aCTImage;
%
%     % Thresholding to create a binary mask
%     BWCT = BWCT >= dBoneMaskThreshold;
%
%     % Perform morphological closing to smooth contours and fill small gaps
%     se = strel('disk', 3); % Adjust the size as needed
%     BWCT = imclose(BWCT, se);
%
%     % Fill holes in the binary image
%     BWCT = imfill(BWCT, 'holes');
%
%     % Optional: Remove small objects that are not part of the bone
%     BWCT = bwareaopen(BWCT, 100); % Adjust the size threshold as needed
%
%     % Perform another round of morphological closing if necessary
%     BWCT = imclose(BWCT, se);
%
%     % Optional: Perform morphological opening to remove small spurious regions
%     BWCT = imopen(BWCT, se);

    if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view

        BWCT = resample3DImage(BWCT, atCTMetaData, aResampledPTImage, atResampledPTMetaData, 'Cubic');

        BWCT = imbinarize(BWCT);

        if ~isequal(size(BWCT), size(aResampledPTImage)) % Verify if both images are in the same field of view
            BWCT = resizeMaskToImageSize(BWCT, aResampledPTImage);
        end
    else
        BWCT = imbinarize(BWCT);
    end

    progressBar(10/11, 'Generating contours, please wait...');

    imMask = aResampledPTImage;
%     imMask(aBWMask == 0) = dMin;

    if ~isempty(gaLiverMask)

        aBWMask(gaLiverMask) = 0;
        imMask (gaLiverMask) = dMin;
    end

    setSeriesCallback();

    sFormula = '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map';
    maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, 0, false, 0, true, sFormula, BWCT, dSmalestVoiValue,  gdNormalLiverMean, gdNormalLiverSTD);

    if ~isempty(gaLiverMask)

        sFormula = 'Liver';

        imMaskLiver = aResampledPTImage;
        imMaskLiver(gaLiverMask == 0) = dMin;

        maskAddVoiToSeries(imMaskLiver, aLiverBWMask, dPixelEdge, false, dLiverThreshold, false, 0, false, sFormula, BWCT, dSmalestVoiValue);

        clear imMaskLiver;
        clear aLiverBWMask;
        clear gaLiverMask;
   end

    clear aResampledPTImage;
    clear aBWMask;
    clear refMip;
    clear aMip;
    clear BWCT;
    clear imMask;


    setVoiRoiSegPopup();

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    % Set TCS Axes intensity

    dMin = 0/dSUVScale;
    dMax = 10/dSUVScale;

    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    setWindowMinMax(dMax, dMin);

    dMin = 0/dSUVScale;
    dMax = 20/dSUVScale;

    % Set MIP Axe intensity

    set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dMin dMax]);

    % Deactivate MIP Fusion

    link2DMip('set', false);

    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    %  set(btnLinkMipPtr('get'), 'FontWeight', 'normal');
    set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_grey.png'));

    % Set fusion

    if isFusion('get') == false

        set(uiFusedSeriesPtr('get'), 'Value', dCTSerieOffset);

        sliderAlphaValue('set', 0.65);

        setFusionCallback();
    end

    [dMax, dMin] = computeWindowLevel(500, 50);

    fusionWindowLevel('set', 'max', dMax);
    fusionWindowLevel('set', 'min' ,dMin);

    setFusionWindowMinMax(dMax, dMin);

    % Triangulate og 1st VOI

    atVoiInput = voiTemplate('get', dPTSerieOffset);

    if ~isempty(atVoiInput)

        dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

        triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
    end

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();

    plotRotatedRoiOnMip(axesMipPtr('get', [], dPTSerieOffset), dicomBuffer('get', [], dPTSerieOffset), mipAngle('get'));

    clear aPTImage;
    clear aCTImage;


    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dPTSerieOffset, true);
        progressBar( 1 , 'Error: setSegmentationGa68DOTATATE()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function Ga68DOTATATENormalLiverMeanSDDialog()

        DLG_Ga68DOTATATE_MEAN_SD_X = 380;
        DLG_Ga68DOTATATE_MEAN_SD_Y = 150;

        if viewerUIFigure('get') == true

            dlgGa68DOTATATEmeanSD = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Ga68DOTATATE_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Ga68DOTATATE_MEAN_SD_Y/2) ...
                                    DLG_Ga68DOTATATE_MEAN_SD_X ...
                                    DLG_Ga68DOTATATE_MEAN_SD_Y ...
                                    ],...
                       'Resize', 'off', ...
                       'Color', viewerBackgroundColor('get'),...
                       'WindowStyle', 'modal', ...
                       'Name' , 'Ga68DOTATATE Segmentation Mean and SD'...
                       );
        else
            dlgGa68DOTATATEmeanSD = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Ga68DOTATATE_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Ga68DOTATATE_MEAN_SD_Y/2) ...
                                    DLG_Ga68DOTATATE_MEAN_SD_X ...
                                    DLG_Ga68DOTATATE_MEAN_SD_Y ...
                                    ],...
                       'MenuBar', 'none',...
                       'Resize', 'off', ...
                       'NumberTitle','off',...
                       'MenuBar', 'none',...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'Ga68DOTATATE Segmentation Mean and SD',...
                       'Toolbar','none'...
                       );
        end

        % Normal Liver Mean

            uicontrol(dlgGa68DOTATATEmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Mean',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [20 90 250 20]...
                      );

        edtGa68DOTATATENormalLiverMeanValue = ...
            uicontrol(dlgGa68DOTATATEmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 90 75 20], ...
                      'String'  , num2str(Ga68DOTATATENormalLiverMeanValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtGa68DOTATATENormalLiverMeanValueCallback ...
                      );

        % Normal Liver Standard Deviation

            uicontrol(dlgGa68DOTATATEmeanSD,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Normal Liver Standard Deviation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [20 65 250 20]...
                      );

        edtGa68DOTATATENormalLiverSDValue = ...
            uicontrol(dlgGa68DOTATATEmeanSD, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(Ga68DOTATATENormalLiverSDValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtGa68DOTATATENormalLiverSDValueCallback ...
                      );

         % Cancel or Proceed

         uicontrol(dlgGa68DOTATATEmeanSD,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'Callback', @cancelGa68DOTATATEmeanSDCallback...
                   );

         uicontrol(dlgGa68DOTATATEmeanSD,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedGa68DOTATATEmeanSDCallback...
                  );

        waitfor(dlgGa68DOTATATEmeanSD);

        function edtGa68DOTATATENormalLiverMeanValueCallback(~, ~)

            dMeanValue = str2double(get(edtGa68DOTATATENormalLiverMeanValue, 'Value'));

            if dMeanValue < 0
                dMeanValue = 0.1;
                set(edtGa68DOTATATENormalLiverMeanValue, 'Value', num2str(dMeanValue));
            end

            Ga68DOTATATENormalLiverMeanValue('set', dMeanValue);
        end

        function edtGa68DOTATATENormalLiverSDValueCallback(~, ~)

            dSDValue = str2double(get(edtGa68DOTATATENormalLiverSDValue, 'Value'));

            if dSDValue < 0
                dSDValue = 0.1;
                set(edtGa68DOTATATENormalLiverSDValue, 'Value', num2str(dSDValue));
            end

            Ga68DOTATATENormalLiverSDValue('set', dSDValue);
        end

        function proceedGa68DOTATATEmeanSDCallback(~, ~)

            gdNormalLiverMean = str2double(get(edtGa68DOTATATENormalLiverMeanValue, 'String'));
            gdNormalLiverSTD  = str2double(get(edtGa68DOTATATENormalLiverSDValue, 'String'));

            delete(dlgGa68DOTATATEmeanSD);
            gbProceedWithSegmentation = true;
        end

        function cancelGa68DOTATATEmeanSDCallback(~, ~)

            delete(dlgGa68DOTATATEmeanSD);
            gbProceedWithSegmentation = false;
        end
    end
end
