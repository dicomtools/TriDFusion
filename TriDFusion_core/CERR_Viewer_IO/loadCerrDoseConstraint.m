% visualizeDoseConstraint.m
%
% This script produces visualization of regions violating dosimetric
% constraints. 
%
% User inputs:
%   structNamC: cell array of structure names to visualize. PTV is required.
%   doseThreshold: constraint violations are regions recieving dose less
%   than this threshold.
%
% APA, 12/8/2020
function loadCerrDoseConstraint(sPathName, sFileName)

    progressBar(0.1, 'Loading CERR PlanC');

    cerrFileName = sprintf('%s%s', sPathName, sFileName);

    %sPathName = 'C:\Temp\DoseConstraintDisplay\';
    %sFileName = '0617-693410_09-09-2000-32821.mat';
    
    try
        planC = loadPlanC(cerrFileName,tempdir);
        planC = updatePlanFields(planC);
        planC = quality_assure_planC(cerrFileName,planC);
    catch
        progressBar(1, 'Error: loadCerrDoseConstraint() Cant Load CERR PlanC!');
        return;
    end
    
    progressBar(0.3, 'Set Matching Index');

    indexS = planC{end};

    structNamC = {'Lung_IPSI','Lung_CNTR','PTV'};
    doseThreshold = 72;

    scanNum = 1;
    doseNum = 1;

    strC = {planC{indexS.structures}.structureName};
    strIndex = getMatchingIndex(structNamC{1},strC,'exact');
    [scan3M,dose3M,strMaskC,xyzGridC,strColorC] = ...
        getScanDoseStrVolumes(scanNum,doseNum,structNamC,planC);
    
    sizV = size(strMaskC{1});
    
    progressBar(0.5, 'Set Matching Index');

    % Generate mask for constraint
    ptvInd = getMatchingIndex('PTV',structNamC,'exact');
    maskConstr3M = false(sizV);
    maskConstr3M(dose3M < doseThreshold & strMaskC{ptvInd}) = true;

    % Replace structure "volume mask" with "surface mask"
    for iStr = 1:length(structNamC)
         surfRcsM = getSurfacePoints(strMaskC{iStr},1,1);
         indSurfV = sub2ind(sizV,surfRcsM(:,1),surfRcsM(:,2),surfRcsM(:,3));
         maskEdge3M = false(sizV);
         maskEdge3M(indSurfV) = true;
         maskEdgeC{iStr} = maskEdge3M;
    end

    ctOffset = planC{indexS.scan}(scanNum).scanInfo(1).CTOffset;
    scanArray3M = single(planC{indexS.scan}(scanNum).scanArray) - ctOffset;

    numStructs = length(structNamC);
    numConstr = 1;
    labelColorM = ones(numStructs+numConstr+1,3);
    labelColorM(2:end-numConstr,:) = repmat([0,0.81,0.81],numStructs,1);
    labelColorM(numStructs+2:end,:) = repmat([1,0.41,0.38],numConstr,1);

    labelOpacityV = zeros(numStructs+numConstr+1,1);
    labelOpacityV(2:1+numStructs,1) = 0.03;
    labelOpacityV(numStructs+2:end) = 0.1;
    
    progressBar(0.7, 'Masking Edge.');

    maskEdge3M = zeros(sizV,'uint16');
    for iStr = 1:numStructs
        maskEdge3M(maskEdgeC{iStr}) = iStr;
    end
    maskEdge3M(maskConstr3M) = numStructs+1;

    [minr, maxr, minc, maxc, mins, maxs]= compute_boundingbox(maskEdge3M);
    maskEdge3M = maskEdge3M(minr:maxr, minc:maxc, mins:maxs);
    scanArray3M = scanArray3M(minr:maxr, minc:maxc, mins:maxs);

    [xV,yV,zV] = getScanXYZVals(planC{indexS.scan}(scanNum));
    dx = xV(2)-xV(1);
    dy = yV(1)-yV(2);
    dz = zV(2)-zV(1);

    sx = 1;
    sy = dy/dx;
    sz = dz/dx;

    %figure, 
    %h = labelvolshow(maskEdge3M, scanArray3M, 'ScaleFactors',[sy,sx,sz],'BackgroundColor','w',...
    %    'LabelColor',labelColorM,'ShowIntensityVolume',false,'LabelOpacity',labelOpacityV);
    
    progressBar(0.9, 'Initializing Viewer');

    for ii=1:numel(planC{1,3}(1).scanInfo)
        tTemplate{ii} = planC{1,3}(1).scanInfo(ii).DICOMHeaders;
        sPatientName = sprintf('%s^%s^%s^%s^%s', ...
                           planC{1,3}(1).scanInfo(ii).DICOMHeaders.PatientName.FamilyName, ...
                           planC{1,3}(1).scanInfo(ii).DICOMHeaders.PatientName.GivenName, ...
                           planC{1,3}(1).scanInfo(ii).DICOMHeaders.PatientName.MiddleName, ...
                           planC{1,3}(1).scanInfo(ii).DICOMHeaders.PatientName.NamePrefix, ...
                           planC{1,3}(1).scanInfo(ii).DICOMHeaders.PatientName.NameSuffix );
                                                                                                                 
        tTemplate{ii}.PatientName      = sPatientName;
        tTemplate{ii}.AcquisitionTime  = planC{1,3}(1).scanInfo(ii).acquisitionTime; 
        tTemplate{ii}.NumberOfSlices = numel(planC{1,3}(1).scanInfo);
        if isempty(tTemplate{ii}.AcquisitionTime)
            tTemplate{ii}.AcquisitionTime = '000000';
        end
        
        tTemplate{ii}.SeriesTime          = planC{1,3}(1).scanInfo(ii).seriesTime;
        if isempty(tTemplate{ii}.SeriesTime)
            tTemplate{ii}.SeriesTime = '000000';
        end
            
        tTemplate{ii}.ActualFrameDuration = planC{1,3}(1).scanInfo(ii).frameAcquisitionDuration;
        tTemplate{ii}.PatientWeight       = planC{1,3}(1).scanInfo(ii).patientWeight;
        tTemplate{ii}.PatientSize         = planC{1,3}(1).scanInfo(ii).patientSize;
       
        if ~isfield(tTemplate{ii}, 'SeriesType')
            tTemplate{ii}.SeriesType{1} = '';
            tTemplate{ii}.SeriesType{2} = '';
        end        
        
        if ~isfield(tTemplate{ii}, 'AccessionNumber')
            tTemplate{ii}.AccessionNumber = '';
        end
        
        if ~isfield(tTemplate{ii}, 'ReconstructionDiameter')        
            tTemplate{ii}.ReconstructionDiameter = 0;
        end
        
        if ~isfield(tTemplate{ii}, 'SpacingBetweenSlices')        
            tTemplate{ii}.SpacingBetweenSlices = 0;
        end
                           
    end
   
    tNewInput(1).atDicomInfo = tTemplate;
    tNewInput(2).atDicomInfo = tTemplate;
    for ii=1:numel(tNewInput(2).atDicomInfo)
        tNewInput(2).atDicomInfo{ii}.Modality = 'PT';
        tNewInput(2).atDicomInfo{ii}.SeriesDescription = sprintf('Constraint: %s', tNewInput(1).atDicomInfo{ii}.SeriesDescription);
        tNewInput(2).atDicomInfo{ii}.Units = 'Constraint';
    end     
    
    scan3M = scanArray3M;
    dose3M = maskEdge3M;
    
    tNewInput(1).aDicomBuffer = scan3M;
    tNewInput(2).aDicomBuffer = dose3M;

    inputTemplate('set', tNewInput);
    dicomBuffer  ('set', scan3M);
    
    aBuffer{1}=scan3M;
    aBuffer{2}=dose3M;
   
    inputBuffer  ('set', aBuffer);
    dicomMetaData('set', tTemplate);          
         
    mainDir('set', sPathName);
    
    isDoseKernel('set', false);
    isFusion('set', false);

    initWindowLevel('set', true);
    initFusionWindowLevel ('set', true);
    roiTemplate('set', '');
    voiTemplate('set', '');

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

    viewSegPanel('set', false);
    objSegPanel = viewSegPanelMenuObject('get');
    if ~isempty(objSegPanel)
        objSegPanel.Checked = 'off';
    end

    viewKernelPanel('set', false);
    objKernelPanel = viewKernelPanelMenuObject('get');
    if ~isempty(objKernelPanel)
        objKernelPanel.Checked = 'off';
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
    set(uiSeriesPtr('get'), 'Enable', 'off');

    set(btnFusionPtr    ('get'), 'Enable', 'off');
    set(btnRegisterPtr  ('get'), 'Enable', 'off');
    set(uiFusedSeriesPtr('get'), 'Value' , 1    );
    set(uiFusedSeriesPtr('get'), 'String', ' '  );
    set(uiFusedSeriesPtr('get'), 'Enable', 'off');

    isVsplash('set', false);
    set(btnVsplashPtr('get')   , 'BackgroundColor', 'default');
    set(btnVsplashPtr('get')   , 'Enable', 'off');
    set(uiEditVsplahXPtr('get'), 'Enable', 'off');
    set(uiEditVsplahYPtr('get'), 'Enable', 'off');

    registrationReport('set', '');            
    
    switchTo3DMode    ('set', false);
    switchToIsoSurface('set', false);
    switchToMIPMode   ('set', false);

    rotate3d off

    set(btnFusionPtr('get'), 'BackgroundColor', 'default');

    set(btn3DPtr('get')        , 'BackgroundColor', 'default');
    set(btnIsoSurfacePtr('get'), 'BackgroundColor', 'default');
    set(btnMIPPtr('get')       , 'BackgroundColor', 'default');

    set(btnTriangulatePtr('get'), 'BackgroundColor', 'white');

    imageOrientation('set', 'axial');    
    
    if numel(inputTemplate('get')) ~= 0

        for ii = 1 : numel(inputTemplate('get'))
            sNewVolSeriesDate = [tNewInput(ii).atDicomInfo{1}.SeriesDate tNewInput(ii).atDicomInfo{1}.SeriesTime];
            if contains(sNewVolSeriesDate,'.')
                sNewVolSeriesDate = extractBefore(sNewVolSeriesDate,'.');
            end
            sNewVolSeriesDate = datetime(sNewVolSeriesDate,'InputFormat','yyyyMMddHHmmss');
            sNewVolSeriesDescription = tNewInput(ii).atDicomInfo{1}.SeriesDescription;

            sNewVolumes{ii} = sprintf('%s %s', sNewVolSeriesDescription, sNewVolSeriesDate);
        end

        seriesDescription('set', sNewVolumes);

        set(uiSeriesPtr('get'), 'String', sNewVolumes);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        if  numel(sNewVolumes) > 1
            set(btnRegisterPtr('get'), 'Enable', 'on');
            set(btnFusionPtr('get')  , 'Enable', 'on');

            set(uiFusedSeriesPtr('get'), 'String', sNewVolumes);
            set(uiFusedSeriesPtr('get'), 'Enable', 'on');
            set(uiFusedSeriesPtr('get'), 'Value', 2);
        end
        
        set(btnVsplashPtr('get')   , 'Enable', 'on');
        set(uiEditVsplahXPtr('get'), 'Enable', 'on');
        set(uiEditVsplahYPtr('get'), 'Enable', 'on');
    end  
    
    setQuantification();
    
    clearDisplay();
    initDisplay(3);

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
    
    setPlaybackToolbar('on');
    setRoiToolbar('on');
        
    refreshImages();
   
    progressBar(1, 'Ready');

end


