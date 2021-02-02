
if 1 % CERR Dose Volume Example 
    
cerrStructNamC = {'DL_HEART_MT','DL_AORTA','DL_LA','DL_LV','DL_RA', 'DL_RV','DL_IVC','DL_SVC','DL_PA'}; 
cerrStructEnaC = {true, true, true, true, true, true, true, false, true};  
cerrStructTraC = {1, 0.9, 0, 0, 0, 0, 0, 0, 0}; % Transparency is from 0-1

cerrMatFileName = 'H:\Public\Aditya\DoseConstraintDisplay\0617-693410_09-09-2000-32821.mat';

cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
cerrPlanC = updatePlanFields(cerrPlanC);

% Initialize Viewer
TriDFusion();

loadCerrDoseVolume(cerrPlanC, cerrStructNamC);

% Set 3D Voi Enable list. *Optional
voi3DEnableList('set', cerrStructEnaC);

% Set 3D Voi Enable list. *Optional
voi3DTransparencyList('set', cerrStructTraC);

% Activate Fusion. 
setFusionCallback(); 

% Set 3D Fusion Colormap. *Optional
fusionColorMapOffset('set', 2); % Set Jet Fusion Colormap. *Default is 19 Pet

% Activate 3D MIP. 
setMIPCallback();

% Activate 3D VOI. 
set3DVoiCallback();


% To change MIP alphamap and colormap. *Optional
mipObj = mipObject('get');

aAlphamap = get(mipObj, 'Alphamap'); % 256x1
aColormap = get(mipObj, 'Colormap'); % 256x3

set(mipObj, 'Alphamap', aAlphamap); 
set(mipObj, 'Colormap', aColormap);

% To change MIP Fusion alphamap and colormap.*Optional
mipFusionObj = mipFusionObject('get');

aAlphamap = get(mipFusionObj, 'Alphamap'); % 256x1 
aColormap = get(mipFusionObj, 'Colormap'); % 256x3

set(mipFusionObj, 'Alphamap', aAlphamap); 
set(mipFusionObj, 'Colormap', aColormap);  


% Set 3D Zoom. *Optional
multiFrame3DZoom('set', 3); % % Lower the number to zoomin

% Set 3D Speed. *Optional 
multiFrame3DSpeed('set', 0.07); % In ms 

% Set 3D Starting Index. *Optional 
multiFrame3DIndex('set', 1); % Starting Rocord Index 1-120. *Optional  

% Record The Frame. *Optional

sRecFileName = 'c:\temp\test_cerr_dose_volume.gif';

set3DRenderingRecord(sRecFileName);

close(fiMainWindowPtr('get'));

end



if 1 % CERR Dose Constraint Example 

cerrStructNamC = {'Lung_IPSI','Lung_CNTR','PTV'}; % Organ list 
cerrStructEnaC = {true, true, true}; % True or false show the organ
cerrStructTraC = {1, 0.9, 0}; % Transparency is from 0-1

cerrMatFileName = 'H:\Public\Aditya\DoseConstraintDisplay\0617-693410_09-09-2000-32821.mat';

cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
cerrPlanC = updatePlanFields(cerrPlanC);

% Initialize Viewer
TriDFusion();

loadCerrDoseConstraint(cerrPlanC, cerrStructNamC);

% Set 3D Voi Enable list. *Optional
voi3DEnableList('set', cerrStructEnaC);

% Set 3D Voi Enable list. *Optional
voi3DTransparencyList('set', cerrStructTraC);

% Activate Fusion. 
setFusionCallback(); 

% Set Fusion Colormap. *Optional
fusionColorMapOffset('set', 2); % Set Jet Fusion Colormap. *Default is 19 Pet

% Activate 3D MIP. 
setMIPCallback();

% Activate 3D VOI. 
set3DVoiCallback();

% To change MIP alphamap and colormap. *Optional
mipObj = mipObject('get');

aAlphamap = get(mipObj, 'Alphamap'); % 256x1
aColormap = get(mipObj, 'Colormap'); % 256x3

set(mipObj, 'Alphamap', aAlphamap); 
set(mipObj, 'Colormap', aColormap);

% To change MIP Fusion alphamap and colormap. *Optional
mipFusionObj = mipFusionObject('get');

aAlphamap = get(mipFusionObj, 'Alphamap'); % 256x1 
aColormap = get(mipFusionObj, 'Colormap'); % 256x3

set(mipFusionObj, 'Alphamap', aAlphamap); 
set(mipFusionObj, 'Colormap', aColormap);  

% Set 3D Zoom. *Optional
multiFrame3DZoom('set', 4); % Lower the number to zoomin

% Set 3D Speed. *Optional 
multiFrame3DSpeed('set', 0.07); % In ms 

% Set 3D Starting Index. *Optional 
multiFrame3DIndex('set', 1); % Starting Rocord Index 1-120. *Optional  

% Record The 3D Rendering

sRecFileName = 'c:\temp\test_cerr_dose_constraint.gif';

set3DRenderingRecord(sRecFileName);

close(fiMainWindowPtr('get'));

end

