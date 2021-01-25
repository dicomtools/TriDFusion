function fiMainWindow = TriDFusionCerr(asArgument, cerrPlanC, cerrStructNamC, cerrStructEnaC, cerrStructTraC)
%function TriDFusion(asArgument, cerrPlanC, cerrStructNamC, cerrStructEnaC, cerrStructTraC)
%Triple Dimention Fusion Image Viewer Main.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
% -dv    : Load CERR Dose Volume. 
% -dc    : Load CERR Dose Constraint.
% -fusion 'colormap number': Activate the fusion. If a colormap number is set, it will be use. *Require 2 volumes 
% -mip   : Activate the 3D mip. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
% -iso   : Activate the 3D volume rendering. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
% -vol   : Activate the 3D iso surface. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
% -voi   : Activate the 3D voi.
% -idx   : 3D rendering start index.
% -zoom  : 3D rendering zoom.
% -speed : 3D Redering wait between frame.
% -rec 'filename': Record 3D Rendering. the file name must follow the activation key
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Example:
% cerrStructNamC = {'DL_HEART_MT','DL_AORTA','DL_LA','DL_LV','DL_RA', 'DL_RV','DL_IVC','DL_SVC','DL_PA'}; 
% cerrStructEnaC = {true, true, true, true, true, true, true, false, true};  
% cerrStructTraC = {1, 0.9, 0, 0, 0, 0, 0, 0, 0}; % Transparency is from 0-1
%
% cerrMatFileName = 'C:\Temp\0617-489880_09-09-2000-50891.mat';
% cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
% cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
% cerrPlanC = updatePlanFields(cerrPlanC);
%
% Example 1 - Load a Dose Volume in TriDFusion 2D View  
% fiMainWindow = TriDFusionCerr({'-dv'}, cerrPlanC, cerrStructNamC);
% close(fiMainWindow); 
%
% Example 2 - Load a Dose Volume in TriDFusion 3D View, in fusion, and record the rensering   
% fiMainWindow = TriDFusionCerr({'-dv', '-mip', '-voi', '-fusion 2', '-idx 1', '-speed 0.07', '-zoom 4', '-rec c:\test.gif'}, cerrPlanC, cerrStructNamC, cerrStructEnaC, cerrStructTraC);
% close(fiMainWindow); 
%
% cerrStructNamC = {'Lung_IPSI','Lung_CNTR','PTV'}; % Organ list 
% cerrStructEnaC = {true, true, true}; % True or false show the organ
% cerrStructTraC = {1, 0.9, 0}; % Transparency is from 0-1
% 
% cerrMatFileName = 'H:\Public\Aditya\DoseConstraintDisplay\0617-693410_09-09-2000-32821.mat';
% cerrPlanC = loadPlanC(cerrMatFileName, tempdir);
% cerrPlanC = quality_assure_planC(cerrMatFileName, cerrPlanC);        
% cerrPlanC = updatePlanFields(cerrPlanC);
%
% Example 3 - Load a Dose Constraint in TriDFusion 2D View, in fusion  
% fiMainWindow = TriDFusionCerr({'-dc', '-fusion'}, cerrPlanC, cerrStructNamC);
%
% Example 4 - Load a Dose Constraint in TriDFusion 3D MIP View, in fusion  
% fiMainWindow = TriDFusionCerr({'-dc', '-mip', '-fusion'}, cerrPlanC, cerrStructNamC);
%
%
% Last specifications modified:
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

    argDoseVolume = false;
    argDoseConst  = false;
    argFusion     = false;
    argVoi        = false;
     
    asRendererPriority = [];
    sRecFileName = [];
    
    sZoom  = [];
    sIndex = [];
    sSpeed = [];
    sFusionColormap = [];
   
    if ~exist('asArgument', 'var')
        asArgument = [];
    end
    
    if ~iscell(asArgument)
        asArgument = str2Cell(asArgument);
    end
    
    for k = 1 : length(asArgument)
        
        sCurrentArgument = asArgument{k};
        
        if     contains(sCurrentArgument,'-rec', 'IgnoreCase', true)
            sCurrentArgument = '-rec';
        elseif contains(sCurrentArgument,'-zoom', 'IgnoreCase', true)
            sCurrentArgument = '-zoom';         
        elseif contains(sCurrentArgument,'-idx', 'IgnoreCase', true)
            sCurrentArgument = '-idx';
        elseif contains(sCurrentArgument,'-speed', 'IgnoreCase', true)
            sCurrentArgument = '-speed'; 
        elseif contains(sCurrentArgument,'-fusion', 'IgnoreCase', true)
            sCurrentArgument = '-fusion';             
        end
        
        switch lower(sCurrentArgument)                       

            case '-dv' % Activate Dose Volume
                argDoseVolume = true;
                
            case '-dc' % Activate Dose Constraint
                argDoseConst = true;
               
            case '-fusion' % Activate Fusion
                argFusion = true;                
                sFusionColormap = erase(asArgument{k}, '-fusion'); 
                
            case '-vol' % Activate 3D Volume Rendering
                asRendererPriority{numel(asRendererPriority)+1} = 'vol';
                    
            case '-iso' % Activate 3D ISO Surface
                asRendererPriority{numel(asRendererPriority)+1} = 'iso';
                
            case '-mip' % Activate 3D MIP
                asRendererPriority{numel(asRendererPriority)+1} = 'mip';               
                
            case '-voi' % Activate 3D VOI
                argVoi = true;
                
            case '-rec'% Record Rendering
                sRecFileName = erase(asArgument{k}, '-rec');
                
            case '-idx'% 3D Rendering Starting Index
                sIndex = erase(asArgument{k}, '-idx');   
                
            case '-zoom'% 3D Rendering Zoom
                sZoom = erase(asArgument{k}, '-zoom');   
               
            case '-speed'% 3D Rendering Speed
                sSpeed = erase(asArgument{k}, '-speed');                 
        end
    end  

    % Error Validation
    if argDoseVolume == false && ...
       argDoseConst  == false
        errordlg('Dose Volume (-dv) or Constraint (-dc) must be specify.', ...
                  'TriDFuisionCerr()');
        return;
    end
    
    if argDoseVolume == true && ...
       argDoseConst  == true
        errordlg('Either Dose Volume (-dv) or Constraint (-dc) must be specify, but not both.', ...
                  'TriDFuisionCerr()');
        return;
    end    
    
    if ~exist('cerrPlanC', 'var') 
        errordlg('PlanC  must be specify.', ...
                  'TriDFuisionCerr()');
        return;        
    end
    
    if ~exist('cerrStructNamC', 'var') 
        errordlg('StructNamC  must be specify.', ...
                  'TriDFuisionCerr()');
        return;        
    end
    
    % Initialize Viewer
    TriDFusion();

    if (argDoseVolume == true)                       
        loadCerrDoseVolume(cerrPlanC, cerrStructNamC);
    end
    
    if (argDoseConst == true)       
        loadCerrDoseConstraint(cerrPlanC, cerrStructNamC);        
    end

    % Set 3D Voi Enable list. *Optional
    if exist('cerrStructEnaC', 'var')
        voi3DEnableList('set', cerrStructEnaC);
    end

    % Set 3D Voi Enable list. *Optional
    if exist('cerrStructTraC', 'var')
        voi3DTransparencyList('set', cerrStructTraC);
    end

    % Activate Fusion. 
    if argFusion == true
        setFusionCallback(); 
        
        % Set 3D Fusion Colormap. *Optional
        if numel(sFusionColormap)
            fusionColorMapOffset('set', str2double(sFusionColormap)); % Set Jet Fusion Colormap. *Default is 19 Pet        
        end
    end
          

    for rr=1:numel(asRendererPriority) 
        
        if strcmpi(asRendererPriority{rr}, 'vol') % Init 3D Volume
            set3DCallback(); 
        end
        
        if strcmpi(asRendererPriority{rr}, 'iso') % Init 3D ISO 
            setIsoSurfaceCallback();
        end
        
        if strcmpi(asRendererPriority{rr}, 'mip') % Init 3D MIP
            setMIPCallback();
        end        
    end  

    % Activate 3D VOI.
    if argVoi == true && ...
       numel(asRendererPriority)      
        set3DVoiCallback();
    end

    % Set 3D Zoom. *Optional
    if numel(sZoom) && ...
       numel(asRendererPriority) 
           
        multiFrame3DZoom('set', str2double(sZoom)); % Default is 9, lower number to zoomin
    end

    % Set 3D Speed. *Optional 
    if numel(sSpeed) && ...
       numel(asRendererPriority) 
   
        multiFrame3DSpeed('set', str2double(sSpeed)); % In ms 
    end

    % Set 3D Starting Index. *Optional 
    if numel(sIndex) && ...
       numel(asRendererPriority) 
   
        multiFrame3DIndex('set', str2double(sIndex)); % Starting Rocord Index 1-120. *Optional  
    end

    % Record The Frame. *Optional
    if numel(sRecFileName) && ...
       numel(asRendererPriority)      

        set3DRenderingRecord(sRecFileName);
    end
    
    fiMainWindow = fiMainWindowPtr('get');

end
