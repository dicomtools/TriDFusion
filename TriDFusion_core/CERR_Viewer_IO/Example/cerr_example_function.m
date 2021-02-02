
if 1 % CERR Dose Volume Example 
    
cerrStructNamC = {'DL_HEART_MT','DL_AORTA','DL_LA','DL_LV','DL_RA', 'DL_RV','DL_IVC','DL_SVC','DL_PA'}; 
cerrStructEnaC = {true, true, true, true, true, true, true, false, true};  
cerrStructTraC = {1, 0.9, 0, 0, 0, 0, 0, 0, 0}; % Transparency is from 0-1

cerrMatFileName = 'H:\Public\Aditya\DoseConstraintDisplay\0617-693410_09-09-2000-32821.mat';

cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
cerrPlanC = updatePlanFields(cerrPlanC);

% fiMainWindow = TriDFusionCerr({'-dv', '-mip', '-voi', '-fusion'}, cerrPlanC, cerrStructNamC);
fiMainWindow = TriDFusionCerr({'-dv', '-mip', '-voi', '-fusion 2', '-idx 1', '-speed 0.07', '-zoom 4', '-rec c:\temp\test_cerr_dose_volume.gif'}, cerrPlanC, cerrStructNamC, cerrStructEnaC, cerrStructTraC);

close(fiMainWindow);

end



if 1 % CERR Dose Constraint Example 

cerrStructNamC = {'Lung_IPSI','Lung_CNTR','PTV'}; % Organ list 
cerrStructEnaC = {true, true, true}; % True or false show the organ
cerrStructTraC = {1, 0.9, 0}; % Transparency is from 0-1

cerrMatFileName = 'H:\Public\Aditya\DoseConstraintDisplay\0617-693410_09-09-2000-32821.mat';

cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
cerrPlanC = updatePlanFields(cerrPlanC);

fiMainWindow = TriDFusionCerr({'-dc', '-mip', '-fusion 2', '-idx 1', '-speed 0.07', '-zoom 4', '-rec c:\temp\test_cerr_dose_constraint.gif'}, cerrPlanC, cerrStructNamC, cerrStructEnaC, cerrStructTraC);

close(fiMainWindow);

end

