function setSegmentationLu177(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, bUseDefault)
%function setSegmentationLu177(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge, bUseDefault)
%Run Lu177 Segmentation base on normal liver Threshold.
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

    gdLymphNodesSUVThresholdValue = [];
    gdBoneSUVThresholdValue  = [];

    gbLymphNodesSegmentation = [];
    gbBoneSegmentation = [];

    atInput = inputTemplate('get');

    % Modality validation

    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break
        end
    end

    dNMSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'nm')
            dNMSerieOffset = tt;
            break
        end
    end

    if isempty(dCTSerieOffset) || ...
       isempty(dNMSerieOffset)
        progressBar(1, 'Error: PSMA Lu177 tumor segmentation require a CT and NM image!');
        errordlg('PSMA Lu177 tumor segmentation require a CT and NM image!', 'Modality Validation');
        return;
    end


    atNMMetaData = dicomMetaData('get', [], dNMSerieOffset);
    atCTMetaData = dicomMetaData('get', [], dCTSerieOffset);

    aNMImage = dicomBuffer('get', [], dNMSerieOffset);
    if isempty(aNMImage)
        aInputBuffer = inputBuffer('get');
        aNMImage = aInputBuffer{dNMSerieOffset};
    end

    aCTImage = dicomBuffer('get', [], dCTSerieOffset);
    if isempty(aCTImage)
        aInputBuffer = inputBuffer('get');
        aCTImage = aInputBuffer{dCTSerieOffset};
    end

    if isempty(atNMMetaData)
        atNMMetaData = atInput(dNMSerieOffset).atDicomInfo;
    end

    if isempty(atCTMetaData)
        atCTMetaData = atInput(dCTSerieOffset).atDicomInfo;
    end

    if get(uiSeriesPtr('get'), 'Value') ~= dNMSerieOffset
        set(uiSeriesPtr('get'), 'Value', dNMSerieOffset);

        setSeriesCallback();
    end

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    atRoiInput = roiTemplate('get', dNMSerieOffset);

    bResetSeries = true;

    if ~isempty(atRoiInput)

        aTagOffset = strcmpi( cellfun( @(atRoiInput) atRoiInput.Label, atRoiInput, 'uni', false ), {'Normal Liver'} );
        dTagOffset = find(aTagOffset, 1);

        aSlice = [];

        if ~isempty(dTagOffset)

            switch lower(atRoiInput{dTagOffset}.Axe)

                case 'axes1'
                    aSlice = permute(aNMImage(atRoiInput{dTagOffset}.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    aSlice = permute(aNMImage(:,atRoiInput{dTagOffset}.SliceNb,:), [3 1 2]);

                case 'axes3'
                    aSlice = aNMImage(:,:,atRoiInput{dTagOffset}.SliceNb);
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

                Lu177ThresholdValuesDialog();

                if gbProceedWithSegmentation == false
                    return;
                end

                bResetSeries = false;
            else
                gbLymphNodesSegmentation = true;
                gbBoneSegmentation = true;

                gdLymphNodesSUVThresholdValue = Lu177LymphNodesSUVThresholdValue('get');
                gdBoneSUVThresholdValue       = Lu177BoneSUVThresholdValue('get');
            end
        end
    else
        if bUseDefault == false

            waitfor(msgbox('Warning: Normal Liver ROI not found. Draw an ROI on the normal liver, right-click on the ROI, and select the predefined label ''Normal Liver,'' or manually input the Lymph Nodes and Bone SUV Threshold into the following dialog.', 'Warning'));

            Lu177ThresholdValuesDialog();

            if gbProceedWithSegmentation == false
                return;
            end

            bResetSeries = false;
        else
            gbLymphNodesSegmentation = true;
            gbBoneSegmentation = true;

            gdLymphNodesSUVThresholdValue = Lu177LymphNodesSUVThresholdValue('get');
            gdBoneSUVThresholdValue       = Lu177BoneSUVThresholdValue('get');
        end
    end

    % Apply ROI constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dNMSerieOffset);

    bInvertMask = invertConstraint('get');

    tRoiInput = roiTemplate('get', dNMSerieOffset);

    aNMImageTemp = aNMImage;
    aLogicalMask = roiConstraintToMask(aNMImageTemp, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);
    aNMImageTemp(aLogicalMask==0) = 0;  % Set constraint

    if bResetSeries == true

        resetSeries(dNMSerieOffset, true);
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if isInterpolated('get') == false

        isInterpolated('set', true);

        setImageInterpolation(true);
    end

    progressBar(5/10, 'Resampling data series, please wait...');

    [aResampledNMImageTemp, ~] = resampleImage(aNMImageTemp, atNMMetaData, aCTImage, atCTMetaData, 'Linear', false, false);
    [aResampledNMImage, atResampledNMMetaData] = resampleImage(aNMImage, atNMMetaData, aCTImage, atCTMetaData, 'Linear', false, true);

    dicomMetaData('set', atResampledNMMetaData, dNMSerieOffset);
    dicomBuffer  ('set', aResampledNMImage, dNMSerieOffset);

    aResampledNMImage = aResampledNMImageTemp;

    clear aNMImageTemp;
    clear aResampledNMImageTemp;

    progressBar(6/10, 'Resampling MIP, please wait...');

    refMip = mipBuffer('get', [], dCTSerieOffset);
    aMip   = mipBuffer('get', [], dNMSerieOffset);

    aMip = resampleMip(aMip, atNMMetaData, refMip, atCTMetaData, 'Linear', false);

    mipBuffer('set', aMip, dNMSerieOffset);

    setQuantification(dNMSerieOffset);

    tQuant = quantificationTemplate('get');

    if isfield(tQuant, 'tSUV')
        dSUVScale = tQuant.tSUV.dScale;
    else
        dSUVScale = 1;
    end

    progressBar(7/10, 'Computing mask, please wait...');

    aBWMask = aResampledNMImage;

    dMin = min(aBWMask, [], 'all');

%    dThreshold = (4.44/gdNormalLiverMean)*(gdNormalLiverMean+gdNormalLiverSTD);

    if isempty(gbLymphNodesSegmentation) && ...
       isempty(gbBoneSegmentation)

        dThreshold = (1.5*gdNormalLiverMean) + (2*gdNormalLiverSTD);

        if dThreshold < 2.5
            dThreshold = 2.5;
        end

        aBWMask(aBWMask*dSUVScale<dThreshold)=dMin;

        aBWMask = imbinarize(aBWMask);
    end

    progressBar(8/10, 'Computing CT map, please wait...');

%     tRegistration = registrationTemplate('get');
%
%     optimizer = tRegistration.Optimizer;
%     metric    = tRegistration.Metric;

%     [BWCT, ~, ~, ~, ~] = ...
%         registerImage(aCTImage             , ...
%                       atCTMetaData         , ...
%                       aResampledNMImage    , ...
%                       atResampledNMMetaData, ...
%                       aLogicalMask         , ...
%                       'translation', 'multimodal', ...
%                       optimizer            , ...
%                       metric               , ...
%                       true                 , ...
%                       false                );

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

    if ~isequal(size(BWCT), size(aResampledNMImage)) % Verify if both images are in the same field of view

        BWCT = resample3DImage(BWCT, atCTMetaData, aResampledNMImage, atResampledNMMetaData, 'Cubic');

        BWCT = imbinarize(BWCT);

        if ~isequal(size(BWCT), size(aResampledNMImage)) % Verify if both images are in the same field of view
            BWCT = resizeMaskToImageSize(BWCT, aResampledNMImage);
        end
    else
        BWCT = imbinarize(BWCT);
    end

    progressBar(9/10, 'Generating contours, please wait...');

    imMask = aResampledNMImage;
%     imMask(aBWMask == 0) = dMin;

    setSeriesCallback();

%     sFormula = '(4.44/Normal Liver SUVmean)x(Normal Liver SUVmean + Normal Liver SD), Soft Tissue & Bone SUV 3, CT Bone Map';
    if isempty(gbLymphNodesSegmentation) && ...
       isempty(gbBoneSegmentation)

        sFormula = '(1.5 x Normal Liver SUVmean)+(2 x Normal Liver SD), Lymph Nodes & Bone SUV 2.5, CT Bone Map';
        maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, 0, false, 0, true, sFormula, BWCT, dSmalestVoiValue,  gdNormalLiverMean, gdNormalLiverSTD, 'TUMOR');
    else
        if gbLymphNodesSegmentation== true && ... % Lymph Nodes and Bone
           gbBoneSegmentation == true

            aBWMask(aBWMask*dSUVScale<gdLymphNodesSUVThresholdValue)=dMin;
            aBWMask = imbinarize(aBWMask);

            sFormula = 'Lymph Nodes & Bone SUV, CT Bone Map';
            maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdLymphNodesSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue, [],[],[], gbBoneSegmentation);
        else
            if gbLymphNodesSegmentation== true % Lymph Nodes

                aBWMask(aBWMask*dSUVScale<gdLymphNodesSUVThresholdValue)=dMin;

                aBWMask(BWCT==1) = dMin;
                aBWMask = imbinarize(aBWMask);

                sFormula = 'Lymph Nodes';
                maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdLymphNodesSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue);
            else % Bone
                aBWMask(aBWMask*dSUVScale<gdBoneSUVThresholdValue)=dMin;

                aBWMask(BWCT==0) = dMin;
                aBWMask = imbinarize(aBWMask);

                sFormula = 'Bone';
                maskAddVoiToSeries(imMask, aBWMask, dPixelEdge, false, gdBoneSUVThresholdValue, false, 0, false, sFormula, BWCT, dSmalestVoiValue);
            end

        end
    end

    clear aResampledNMImage;
    clear aBWMask;
    clear refMip;
    clear aMip;
    clear BWCT;
    clear imMask;

    setVoiRoiSegPopup();

    % Set TCS Axes intensity

    dMin = 0/dSUVScale;
    dMax = 7/dSUVScale;

    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    setWindowMinMax(dMax, dMin);

    dMin = 0/dSUVScale;
    dMax = 7/dSUVScale;

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

    atVoiInput = voiTemplate('get', dNMSerieOffset);

    if ~isempty(atVoiInput)

        dRoiOffset = round(numel(atVoiInput{1}.RoisTag)/2);

        triangulateRoi(atVoiInput{1}.RoisTag{dRoiOffset});
    end

    % Activate ROI Panel

    if viewRoiPanel('get') == false
        setViewRoiPanel();
    end

    refreshImages();

    plotRotatedRoiOnMip(axesMipPtr('get', [], dNMSerieOffset), dicomBuffer('get', [], dNMSerieOffset), mipAngle('get'));

    clear aNMImage;
    clear aCTImage;


    progressBar(1, 'Ready');

    catch ME
        logErrorToFile(ME);
        resetSeries(dNMSerieOffset, true);
        progressBar( 1 , 'Error: setSegmentationLu177()' );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function Lu177ThresholdValuesDialog()

        DLG_Lu177_MEAN_SD_X = 380;
        DLG_Lu177_MEAN_SD_Y = 215;

        if viewerUIFigure('get') == true

            dlgLu177SUVThreshold = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Lu177_MEAN_SD_X/2) ...
                                      (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Lu177_MEAN_SD_Y/2) ...
                                      DLG_Lu177_MEAN_SD_X ...
                                      DLG_Lu177_MEAN_SD_Y ...
                                     ],...
                       'Resize', 'off', ...
                       'Color', viewerBackgroundColor('get'),...
                       'WindowStyle', 'modal', ...
                       'Name' , 'Lu177 Segmentation Threshold'...
                       );
        else
            dlgLu177SUVThreshold = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_Lu177_MEAN_SD_X/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_Lu177_MEAN_SD_Y/2) ...
                                    DLG_Lu177_MEAN_SD_X ...
                                    DLG_Lu177_MEAN_SD_Y ...
                                    ],...
                       'MenuBar', 'none',...
                       'Resize', 'off', ...
                       'NumberTitle','off',...
                       'MenuBar', 'none',...
                       'Color', viewerBackgroundColor('get'), ...
                       'Name', 'Lu177 Segmentation Threshold',...
                       'Toolbar','none'...
                       );
        end

        setObjectIcon(dlgLu177SUVThreshold);

        % Lymph Nodes Segmentation

        chkLymphNodesSegmentation = ...
            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , Lu177LymphNodesSegmentation('get'),...
                      'position', [20 165 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @chkLymphNodesSegmentationCallback...
                      );

            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Lymph Nodes Segmentation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'ButtonDownFcn'  , @chkLymphNodesSegmentationCallback, ...
                      'position', [40 165 250 20]...
                      );

       if get(chkLymphNodesSegmentation, 'Value') == true
           sLymphNodesEnable = 'on';
       else
           sLymphNodesEnable = 'off';
       end

            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Lymph Nodes SUV Threshold Value',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [40 140 245 20]...
                      );

        edtLu177LymphNodesSUVThresholdValue = ...
            uicontrol(dlgLu177SUVThreshold, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 140 75 20], ...
                      'String'  , num2str(Lu177LymphNodesSUVThresholdValue('get')), ...
                      'Enable'  , sLymphNodesEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtLu177LymphNodesSUVThresholdValueCallback ...
                      );

        % Bone Segmentation

        chkBoneSegmentation = ...
            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , Lu177BoneSegmentation('get'),...
                      'position', [20 90 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @chkBoneSegmentationCallback...
                      );

            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Bone Segmentation',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'ButtonDownFcn'  , @chkBoneSegmentationCallback, ...
                      'position', [40 90 250 20]...
                      );

       if get(chkBoneSegmentation, 'Value') == true
           sBoneEnable = 'on';
       else
           sBoneEnable = 'off';
       end

            uicontrol(dlgLu177SUVThreshold,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Bone SUV Threshold Value',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [40 65 245 20]...
                      );

        edtLu177BoneSUVThresholdValue = ...
            uicontrol(dlgLu177SUVThreshold, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(Lu177BoneSUVThresholdValue('get')), ...
                      'Enable'  , sBoneEnable, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtLu177BoneSUVThresholdValueCallback ...
                      );

         % Cancel or Proceed

         uicontrol(dlgLu177SUVThreshold,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'Callback', @cancelLu177SUVThreshold...
                   );

         uicontrol(dlgLu177SUVThreshold,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedLu177SUVThreshold...
                  );

        waitfor(dlgLu177SUVThreshold);

        function chkLymphNodesSegmentationCallback(hObject, ~)

            bObjectValue = get(chkLymphNodesSegmentation, 'Value');

            if strcmpi(get(hObject, 'Style'), 'text')

                set(chkLymphNodesSegmentation, 'Value', ~bObjectValue);
            end

            bObjectValue = get(chkLymphNodesSegmentation, 'Value');

            if bObjectValue == true

                set(edtLu177LymphNodesSUVThresholdValue, 'Enable', 'On');
            else
                set(edtLu177LymphNodesSUVThresholdValue, 'Enable', 'Off');
            end

            Lu177LymphNodesSegmentation('set', bObjectValue);
        end

        function edtLu177LymphNodesSUVThresholdValueCallback(~, ~)

            dSUVValue = str2double(get(edtLu177LymphNodesSUVThresholdValue, 'Value'));

            if dSUVValue < 0

                set(edtLu177LymphNodesSUVThresholdValue, 'Value', num2str(1));
            end

            Lu177LymphNodesSUVThresholdValue('set', dSUVValue);
        end

        function chkBoneSegmentationCallback(hObject, ~)

            bObjectValue = get(chkBoneSegmentation, 'Value');

            if strcmpi(get(hObject, 'Style'), 'text')

                set(chkBoneSegmentation, 'Value', ~bObjectValue);
            end

            bObjectValue = get(chkBoneSegmentation, 'Value');

            if bObjectValue == true

                set(edtLu177BoneSUVThresholdValue, 'Enable', 'On');
            else
                set(edtLu177BoneSUVThresholdValue, 'Enable', 'Off');
            end

            Lu177BoneSegmentation('set', bObjectValue);

        end

        function edtLu177BoneSUVThresholdValueCallback(~, ~)

            dSUVValue = str2double(get(edtLu177BoneSUVThresholdValue, 'Value'));

            if dSUVValue < 0

                set(edtLu177BoneSUVThresholdValue, 'Value', num2str(1));
            end

            Lu177BoneSUVThresholdValue('set', dSUVValue);
        end

        function proceedLu177SUVThreshold(~, ~)

            gbLymphNodesSegmentation = get(chkLymphNodesSegmentation, 'Value');
            gbBoneSegmentation       = get(chkBoneSegmentation, 'Value');

            gdLymphNodesSUVThresholdValue = str2double(get(edtLu177LymphNodesSUVThresholdValue, 'String'));
            gdBoneSUVThresholdValue       = str2double(get(edtLu177BoneSUVThresholdValue, 'String'));

            delete(dlgLu177SUVThreshold);

            gbProceedWithSegmentation = true;
        end

        function cancelLu177SUVThreshold(~, ~)

            delete(dlgLu177SUVThreshold);
            gbProceedWithSegmentation = false;
        end

    end
end
