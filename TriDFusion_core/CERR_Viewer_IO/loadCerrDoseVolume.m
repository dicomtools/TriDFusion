function loadCerrDoseVolume(cerrFileName)
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