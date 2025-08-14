function loadCerrPlanC(planC)
%function loadCerrPlanC(planC))
%Load CERR planC to TriDFusion.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
%
% This file is part of The Triple Dimention Fusion (TriDFusion).
%
% TriDFusion development has been led by: Daniel Lafontaine
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

    % Deactivate main tool bar
    set(uiSeriesPtr('get'), 'Enable', 'off');
    mainToolBarEnable('off');

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    releaseRoiWait();

    set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
    set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
    % set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
    set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));

    set(zoomMenu('get'), 'Checked', 'off');
    set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnZoomPtr('get'), 'FontWeight', 'normal');
    set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_grey.png'));
    zoomTool('set', false);
    zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');

    set(panMenu('get'), 'Checked', 'off');
    set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnPanPtr('get'), 'FontWeight', 'normal');
    set(btnPanPtr('get'), 'CData', resizeTopBarIcon('pan_grey.png'));
    panTool('set', false);
    panMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');

    set(rotate3DMenu('get'), 'Checked', 'off');
    rotate3DTool('set', false);
    rotate3d(fiMainWindowPtr('get'), 'off');

    set(dataCursorMenu('get'), 'Checked', 'off');
    dataCursorTool('set', false);
    datacursormode(fiMainWindowPtr('get'), 'off');

    if isFusion('get') == true % Deactivate fusion
         setFusionCallback();
    end

    set(uiSeriesPtr('get'), 'Value' , 1);

    copyRoiPtr('set', '');

    isMoveImageActivated('set', false);

    outputDir('set', '');

    dicomMetaData('reset');

    quantificationTemplate('reset');

    dicomBuffer  ('reset');
    fusionBuffer ('reset');

    mipBuffer      ('reset');
    mipFusionBuffer('reset');

    inputBuffer  ('set', '');

    inputTemplate('set', '');
    inputContours('set', '');
    inputAnnotations('set', '');

    roiTemplate ('reset');
    voiTemplate ('reset');
    plotEditTemplate('reset');

    progressBar(0.5, 'Scaning CERR planC');

    for hh=1:numel(planC{1,3}) % Loop all series
        atTemplate = [];
        for ii=1:numel(planC{1,3}(hh).scanInfo) % Loop all dicom files

            atTemplate{ii} = planC{1,3}(hh).scanInfo(ii).DICOMHeaders;

            if isfield(planC{1,3}(hh).scanInfo(ii).DICOMHeaders, 'FrameofReferenceUID')
                atTemplate{ii}.FrameOfReferenceUID = planC{1,3}(hh).scanInfo(ii).DICOMHeaders.FrameofReferenceUID;
            end

            if isfield(planC{1,3}(1).scanInfo(ii).DICOMHeaders, 'PatientName')

                sPatientName = sprintf('%s^%s^%s^%s^%s', ...
                                   planC{1,3}(hh).scanInfo(ii).DICOMHeaders.PatientName.FamilyName, ...
                                   planC{1,3}(hh).scanInfo(ii).DICOMHeaders.PatientName.GivenName, ...
                                   planC{1,3}(hh).scanInfo(ii).DICOMHeaders.PatientName.MiddleName, ...
                                   planC{1,3}(hh).scanInfo(ii).DICOMHeaders.PatientName.NamePrefix, ...
                                   planC{1,3}(hh).scanInfo(ii).DICOMHeaders.PatientName.NameSuffix );
            else
                sPatientName = sprintf('CERR planC scan %d', hh);
            end

            atTemplate{ii}.PatientName     = sPatientName;
            atTemplate{ii}.NumberOfSlices  = numel(planC{1,3}(hh).scanInfo);

            if ~isfield(atTemplate{ii}, 'AcquisitionDate')
                atTemplate{ii}.AcquisitionDate = '';
            end

            if ~isfield(atTemplate{ii}, 'AcquisitionTime')
                atTemplate{ii}.AcquisitionTime = '';
            end

            if ~isfield(atTemplate{ii}, 'SeriesDate')
                atTemplate{ii}.SeriesDate = '';
            end

            if ~isfield(atTemplate{ii}, 'SeriesTime')
                atTemplate{ii}.SeriesTime = '';
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'frameAcquisitionDuration')
                atTemplate{ii}.ActualFrameDuration = planC{1,3}(hh).scanInfo(ii).frameAcquisitionDuration;
            else
                atTemplate{ii}.ActualFrameDuration = '';
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'patientWeight')
                atTemplate{ii}.PatientWeight       = planC{1,3}(hh).scanInfo(ii).patientWeight;
            else
                atTemplate{ii}.PatientWeight       = [];
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'patientSize')
                atTemplate{ii}.PatientSize         = planC{1,3}(hh).scanInfo(ii).patientSize;
            else
                atTemplate{ii}.PatientSize         = [];
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'patientSex')
                atTemplate{ii}.PatientSex          = planC{1,3}(hh).scanInfo(ii).patientSex;
            else
                atTemplate{ii}.PatientSex          = '';
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'patientAge')
                atTemplate{ii}.PatientAge          = planC{1,3}(hh).scanInfo(ii).patientAge;
            else
                atTemplate{ii}.PatientAge          = '';
            end

            if isfield( planC{1,3}(hh).scanInfo(ii), 'patientBirthDate')
                atTemplate{ii}.PatientBirthDate    = planC{1,3}(hh).scanInfo(ii).patientBirthDate;
            else
                atTemplate{ii}.PatientBirthDate    = '';
            end

            if ~isfield(atTemplate{ii}, 'SeriesType')
                atTemplate{ii}.SeriesType = '';
            end

            if ~isfield(atTemplate{ii}, 'AccessionNumber')
                atTemplate{ii}.AccessionNumber = '';
            end

            if ~isfield(atTemplate{ii}, 'ReconstructionDiameter')
                atTemplate{ii}.ReconstructionDiameter = 0;
            end

            if ~isfield(atTemplate{ii}, 'SpacingBetweenSlices')
                atTemplate{ii}.SpacingBetweenSlices = 0;
            end

            if ~isfield(atTemplate{ii}, 'Units')
                atTemplate{ii}.Units = '';
            end

            if isfield(planC{1,3}(hh).scanInfo(ii).DICOMHeaders, 'RadiopharmaceuticalInformationSequence')

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime  = planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime;
                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime   = planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime;
                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose         = num2str(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose);
                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife          = num2str(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);
                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction  = planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction;

                jDate = atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
                sFormatedDate = sprintf('%s%02s%02s%02s%02s%02s.00', num2str(1900+jDate.getYear()), num2str(jDate.getMonth()+1), num2str(jDate.getDate()), num2str(jDate.getHours()),num2str(jDate.getMinutes()), num2str(jDate.getSeconds()));

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = sFormatedDate;

                jDate = atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDateTime;
                sFormatedDate = sprintf('%s%02s%02s%02s%02s%02s.00', num2str(1900+jDate.getYear()), num2str(jDate.getMonth()+1), num2str(jDate.getDate()), num2str(jDate.getHours()),num2str(jDate.getMinutes()), num2str(jDate.getSeconds()));

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDateTime  = sFormatedDate;

                % RadiopharmaceuticalCodeSequence

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeValue = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue);

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodingSchemeDesignator = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator);

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning);

                % RadionuclideCodeSequence

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue);

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator);

                atTemplate{ii}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning = ...
                    char(planC{1,3}(hh).scanInfo(ii).DICOMHeaders.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning);

            end
        end

        atNewInput(hh).atDicomInfo = atTemplate;

        atNewInput(hh).atDicomInfo{1}.din = [];

        aBuffer{hh}=planC{1,3}(hh).scanArray;

    end

    for ii=1:numel(atNewInput)

        atNewInput(ii).asFilesList    = [];
        atNewInput(ii).asFilesList{1} = '';

        atNewInput(ii).sOrientationView    = 'Axial';

        if strcmpi(atNewInput(ii).atDicomInfo{1}.Modality, 'RTDOSE')
            bDoseKernel = true;
        else
            bDoseKernel = false;
        end

        atNewInput(ii).bEdgeDetection      = false;
        atNewInput(ii).bFlipLeftRight      = false;
        atNewInput(ii).bFlipAntPost        = false;
        atNewInput(ii).bFlipHeadFeet       = false;
        atNewInput(ii).bDoseKernel         = bDoseKernel;
        atNewInput(ii).bMathApplied        = false;
        atNewInput(ii).bFusedDoseKernel    = false;
        atNewInput(ii).bFusedEdgeDetection = false;

        atNewInput(ii).tMovement = [];

        atNewInput(ii).tMovement.bMovementApplied = false;
        atNewInput(ii).tMovement.aGeomtform       = [];

        atNewInput(ii).tMovement.atSeq{1}.sAxe         = [];
        atNewInput(ii).tMovement.atSeq{1}.aTranslation = [];
        atNewInput(ii).tMovement.atSeq{1}.dRotation    = [];
    end

    for mm=1:numel(aBuffer)
        aMip = computeMIP(aBuffer{mm});
        mipBuffer('set', aMip, mm);
        atNewInput(mm).aMip = aMip;
    end

    inputTemplate('set', atNewInput);

    inputBuffer  ('set', aBuffer);

    dicomBuffer  ('set', aBuffer{1});

    dicomMetaData('set', atNewInput(1).atDicomInfo);

    if isFusion('get') == true
        setFusionCallback();
    end
    isFusion('set', false);

    initWindowLevel('set', true);
    initFusionWindowLevel ('set', true);

    deleteAlphaCurve('vol');
    deleteAlphaCurve('volfusion');

    volColorObj = volColorObject('get');
    if ~isempty(volColorObj)
        delete(volColorObj);
        volColorObject('set', '');
    end

    deleteAlphaCurve('mip');
    deleteAlphaCurve('mipfusion');

    mipColorObj = mipColorObject('get');
    if ~isempty(mipColorObj)
        delete(mipColorObj);
        mipColorObject('set', '');
    end

    logoObj = logoObject('get');
    if ~isempty(logoObj)
        delete(logoObj);
        logoObject('set', '');
    end

    volObj = volObject('get');
    if ~isempty(volObj)
        delete(volObj);
        volObject('set', '');
    end

    volFuisonObj = volFusionObject('get');
    if ~isempty(volFuisonObj)
        delete(volFuisonObj);
        volFusionObject('set', '');
    end

    isoObj = isoObject('get');
    if ~isempty(isoObj)
        delete(isoObj);
        isoObject('set', '');
    end

    mipObj = mipObject('get');
    if ~isempty(mipObj)
        delete(mipObj);
        mipObject('set', '');
    end

    mipFusionObj = mipFusionObject('get');
    if ~isempty(mipFusionObj)
        delete(mipFusionObj);
        mipObject('set', '');
    end

    voiObj = voiObject('get');
    if ~isempty(voiObj)
        for vv=1:numel(voiObj)
            delete(voiObj{vv})
        end
        voiObject('set', '');
    end

    isoGateObj = isoGateObject('get');
    if ~isempty(isoGateObj)
        for vv=1:numel(isoGateObj)
            delete(isoGateObj{vv});
        end
        isoGateObject('set', '');
    end

    mipGateObj = mipGateObject('get');
    if ~isempty(mipGateObj)
        for vv=1:numel(mipGateObj)
            delete(mipGateObj{vv});
        end
        mipGateObject('set', '');
    end

    volGateObj = volGateObject('get');
    if ~isempty(volGateObj)
        for vv=1:numel(volGateObj)
            delete(volGateObj{vv})
        end
        volGateObject('set', '');
    end

    voiGateObj = voiGateObject('get');
    if ~isempty(voiGateObj)
        for tt=1:numel(voiGateObj)
            for ll=1:numel(voiGateObj{tt})
                delete(voiGateObj{tt}{ll});
            end
        end
        voiGateObject('set', '');
    end

    ui3DGateWindowObj = ui3DGateWindowObject('get');
    if ~isempty(ui3DGateWindowObj)
        for vv=1:numel(ui3DGateWindowObj)
            delete(ui3DGateWindowObj{vv})
        end
        ui3DGateWindowObject('set', '');
    end

    uiSegMainPanel = uiSegMainPanelPtr('get');
    if ~isempty(uiSegMainPanel)
        set(uiSegMainPanel, 'Visible', 'off');
    end

    viewSegPanel('set', false);
    objSegPanel = viewSegPanelMenuObject('get');
    if ~isempty(objSegPanel)
        objSegPanel.Checked = 'off';
    end

    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    if ~isempty(uiKernelMainPanel)
        set(uiKernelMainPanel, 'Visible', 'off');
    end

    viewKernelPanel('set', false);
    objKernelPanel = viewKernelPanelMenuObject('get');
    if ~isempty(objKernelPanel)
        objKernelPanel.Checked = 'off';
    end

    uiRoiMainPanel = uiRoiMainPanelPtr('get');
    if ~isempty(uiRoiMainPanel)
        set(uiRoiMainPanel, 'Visible', 'off');
    end

    viewRoiPanel('set', false);
    objRoiPanel = viewRoiPanelMenuObject('get');
    if ~isempty(objRoiPanel)
        objRoiPanel.Checked = 'off';
    end

    view3DPanel('set', false);
    init3DPanel('set', true);

    obj3DPanel = view3DPanelMenuObject('get');
    if ~isempty(obj3DPanel)
        obj3DPanel.Checked = 'off';
    end

    mPlay = playIconMenuObject('get');
    if ~isempty(mPlay)
        mPlay.State = 'off';
 %       playIconMenuObject('set', '');
    end

    mRecord = recordIconMenuObject('get');
    if ~isempty(mRecord)
        mRecord.State = 'off';
  %      recordIconMenuObject('set', '');
    end

    isoMaskCtSerieOffset ('set', 1);
    kernelCtSerieOffset  ('set', 1);
    mipFusionBufferOffset('set', 1);

    multiFrame3DPlayback('set', false);
    multiFrame3DRecord  ('set', false);
    multiFrame3DIndex   ('set', 1);
    multiFrame3DZoom    ('set', 0);
%            setPlaybackToolbar('off');

    multiFramePlayback('set', false);
    multiFrameRecord  ('set', false);
    multiFrameZoom    ('set', 'in' , 1);
    multiFrameZoom    ('set', 'out', 1);
    multiFrameZoom    ('set', 'axe', []);

    set(uiSeriesPtr('get'), 'Value' , 1);
    set(uiSeriesPtr('get'), 'String', ' ');

    set(uiFusedSeriesPtr('get'), 'Value' , 1    );
    set(uiFusedSeriesPtr('get'), 'String', ' '  );

    isVsplash('set', false);
    set(btnVsplashPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnVsplashPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnVsplashPtr('get'), 'FontWeight', 'normal');
    set(btnVsplashPtr('get'), 'CData', resizeTopBarIcon('splash_grey.png'));

    registrationReport('set', '');

    switchTo3DMode    ('set', false);
    switchToIsoSurface('set', false);
    switchToMIPMode   ('set', false);

    set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnFusionPtr('get'), 'FontWeight', 'normal');
    set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));

    set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btn3DPtr('get'), 'FontWeight', 'normal');
    set(btn3DPtr('get'), 'CData', resizeTopBarIcon('3d_volume_grey.png'));

    set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');
    set(btnIsoSurfacePtr('get'), 'CData', resizeTopBarIcon('3d_iso_grey.png'));

    set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    % set(btnMIPPtr('get'), 'FontWeight', 'normal');
    set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_grey.png'));

    set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
    set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
    % set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
    set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));

    imageOrientation('set', 'axial');

    if numel(inputTemplate('get')) ~= 0

        for ii = 1 : numel(inputTemplate('get'))

            if isempty(atNewInput(ii).atDicomInfo{1}.SeriesDate)
                sNewVolSeriesDate = '';
            else
                sSeriesDate = atNewInput(ii).atDicomInfo{1}.SeriesDate;
                if isempty(atNewInput(ii).atDicomInfo{1}.SeriesTime)
                    sSeriesTime = '000000';
                else
                    sSeriesTime = atNewInput(ii).atDicomInfo{1}.SeriesTime;
                end

                sNewVolSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
            end

            if ~isempty(sNewVolSeriesDate)
                if contains(sNewVolSeriesDate,'.')
                    sNewVolSeriesDate = extractBefore(sNewVolSeriesDate,'.');
                end
                sNewVolSeriesDate = datetime(sNewVolSeriesDate,'InputFormat','yyyyMMddHHmmss');
            end

            sNewVolSeriesDescription = atNewInput(ii).atDicomInfo{1}.SeriesDescription;

            sNewVolumes{ii} = sprintf('%s %s', sNewVolSeriesDescription, sNewVolSeriesDate);

            setQuantification(ii);
        end

        seriesDescription('set', sNewVolumes);

        set(uiSeriesPtr('get'), 'String', sNewVolumes);

        if  numel(sNewVolumes) > 1
            set(uiFusedSeriesPtr('get'), 'String', sNewVolumes);
            set(uiFusedSeriesPtr('get'), 'Value', 2);
        else
            set(uiFusedSeriesPtr('get'), 'String', sNewVolumes);
            set(uiFusedSeriesPtr('get'), 'Value', 1);
        end

    end

    cropValue('set', min(dicomBuffer('get'), [], 'all'));

    clearDisplay();
    initDisplay(3);

%    link2DMip('set', true);

%    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

    dicomViewerCore();

    setViewerDefaultColor(true, dicomMetaData('get'));

    getMipAlphaMap('set', '', 'auto');
%    getVolAlphaMap('set', '', 'auto');

    getMipFusionAlphaMap('set', '', 'linear');
%    getVolFusionAlphaMap('set', '', 'linear');

%    volLinearAlphaValue      ('set', 0.75);
%    volLinearFusionAlphaValue('set', 0.75);

    mipLinearAlphaValue      ('set', 0.75);
    mipLinearFuisonAlphaValue('set', 0.75);

    set(uiCorWindowPtr('get'), 'Visible', 'off');
    set(uiSagWindowPtr('get'), 'Visible', 'off');
    set(uiTraWindowPtr('get'), 'Visible', 'off');
    set(uiMipWindowPtr('get'), 'Visible', 'off');

%     set(uiSliderLevelPtr ('get'), 'Visible', 'off');
%     set(uiSliderWindowPtr('get'), 'Visible', 'off');

    set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'off');
    set(lineColorbarIntensityMinPtr('get'), 'Visible', 'off');

    set(textColorbarIntensityMaxPtr('get'), 'Visible', 'off');
    set(textColorbarIntensityMinPtr('get'), 'Visible', 'off');

    set(uiSliderCorPtr('get'), 'Visible', 'off');
    set(uiSliderSagPtr('get'), 'Visible', 'off');
    set(uiSliderTraPtr('get'), 'Visible', 'off');
    set(uiSliderMipPtr('get'), 'Visible', 'off');

    strMaskC = [];
    for mm=1:numel(planC{1,4})
        [strMaskC{mm}, planC] = getStrMask(mm,planC);
    end

    for mm=1:numel(strMaskC)

        progressBar(0.7+(0.299999*mm/numel(strMaskC)), sprintf('Processing Contour %d/%d', mm, numel(strMaskC)));

        if get(uiSeriesPtr('get'), 'Value') ~= planC{4}(mm).associatedScan
            set(uiSeriesPtr('get'), 'Value', planC{4}(mm).associatedScan);
            setSeriesCallback();
            mainToolBarEnable('off');
        end

        if contourVisibilityRoiPanelValue('get') == false

            contourVisibilityRoiPanelValue('set', true);
            set(chkContourVisibilityPanelObject('get'), 'Value', true);
        end

        aVoiColor   = planC{4}(mm).structureColor;
        sStructName = planC{4}(mm).structureName;

        maskToVoi(strMaskC{mm}, sStructName, 'Unspecified', aVoiColor, 'axial', planC{4}(mm).associatedScan, true);
    end

    set(uiCorWindowPtr('get'), 'Visible', 'on');
    set(uiSagWindowPtr('get'), 'Visible', 'on');
    set(uiTraWindowPtr('get'), 'Visible', 'on');
    set(uiMipWindowPtr('get'), 'Visible', 'on');

%     set(uiSliderLevelPtr ('get'), 'Visible', 'on');
%     set(uiSliderWindowPtr('get'), 'Visible', 'on');

    set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'on');
    set(lineColorbarIntensityMinPtr('get'), 'Visible', 'on');

    set(textColorbarIntensityMaxPtr('get'), 'Visible', 'on');
    set(textColorbarIntensityMinPtr('get'), 'Visible', 'on');

    set(uiSliderCorPtr('get'), 'Visible', 'on');
    set(uiSliderSagPtr('get'), 'Visible', 'on');
    set(uiSliderTraPtr('get'), 'Visible', 'on');
    set(uiSliderMipPtr('get'), 'Visible', 'on');

    set(fiMainWindowPtr('get'), 'Pointer', 'default');

    drawnow;

    refreshImages();

%    atMetaData = dicomMetaData('get');

%    if strcmpi(atMetaData{1}.Modality, 'ct')
%        link2DMip('set', false);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
%    end

    % Activate playback

    if size(dicomBuffer('get'), 3) ~= 1
        setPlaybackToolbar('on');
    end

    setRoiToolbar('on');

    progressBar(1, 'Import planC completed.');

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:loadCerrPlanC()');
    end

    % Reactivate main tool bar
    set(uiSeriesPtr('get'), 'Enable', 'on');
    mainToolBarEnable('on');

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
