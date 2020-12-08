function loadCerrDoseVolume(sPathName, sFileName)
%function loadCerrDoseVolume(cerrFileName)
%Load CERR Scan and Dose to TriDFusion.
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

    scanNum = 1;
    doseNum = 1;
    structNamC = {'DL_HEART_MT','DL_AORTA','DL_LA','DL_LV','DL_RA',...
                  'DL_RV','DL_IVC','DL_SVC','DL_PA'};
              
    cerrFileName = sprintf('%s%s', sPathName, sFileName);
              
    % Load planC
    try
        planC = loadPlanC(cerrFileName,tempdir);
    catch
        return;
    end
    planC = updatePlanFields(planC);
    planC = quality_assure_planC(cerrFileName,planC);

    % Get scan, dose, struct volumes
    [scan3M, dose3M, strMaskC, ~, ~] = getScanDoseStrVolumes(scanNum, doseNum, structNamC, planC);

    RA = imref3d(size(scan3M));
    RB = imref3d(size(dose3M));
%       [D,RD] = imfuse(scan3M,RA,dose3M,RB,'ColorChannels',[1 2 0]);

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
        tNewInput(2).atDicomInfo{ii}.SeriesDescription = sprintf('Dose: %s', tNewInput(1).atDicomInfo{ii}.SeriesDescription);
        tNewInput(2).atDicomInfo{ii}.Units = 'DOSE';
    end     
    
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
 
end