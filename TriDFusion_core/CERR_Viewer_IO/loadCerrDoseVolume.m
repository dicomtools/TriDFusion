function loadCerrDoseVolume(cerrFileName)

    scanNum = 1;
    doseNum = 1;
    structNamC = {'DL_HEART_MT','DL_AORTA','DL_LA','DL_LV','DL_RA',...
          'DL_RV','DL_IVC','DL_SVC','DL_PA'};

    % Load planC
    planC = loadPlanC(cerrFileName,tempdir);
    planC = updatePlanFields(planC);
    planC = quality_assure_planC(cerrFileName,planC);

    % Get scan, dose, struct volumes
    [scan3M, dose3M, strMaskC, ~, ~] = getScanDoseStrVolumes(scanNum, doseNum, structNamC, planC);

    RA = imref3d(size(scan3M));
    RB = imref3d(size(dose3M));
%       [D,RD] = imfuse(scan3M,RA,dose3M,RB,'ColorChannels',[1 2 0]);



    for ii=1:numel(planC{1,3}(1).scanInfo)
        tTemplate{ii} = planC{1,3}(1).scanInfo(ii).DICOMHeaders;
   end

    t.atDicomInfo = tTemplate;
    
    t.aDicomBuffer{1} = scan3M;
    t.aDicomBuffer{2} = dose3M;

    inputTemplate('set', t);
    dicomBuffer('set', scan3M);
    inputBuffer('set', t.aDicomBuffer);
    dicomMetaData('set', tTemplate{1});   
end