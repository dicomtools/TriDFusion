function setMachineLearningFDGBrownFatSUVCallback(~, ~)
%function setMachineLearningFDGBrownFatSUVCallback()
%Run FDGSUV Tumor Segmentation, The tool is called from the main menu.
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

    [sSegmentatorScript, sSegmentatorCombineMasks] = validateSegmentatorInstallation();
    

    dlgFDGBrownFatSUVSegmentation  = [];
  
    if ~isempty(sSegmentatorScript) ... % External Segmentor is installed
        
        DLG_FDG_BROWN_FAT_PERCENT_X = 380;
        DLG_FDG_BROWN_FAT_PERCENT_Y = 590;
    
        dlgFDGBrownFatSUVSegmentation = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_FDG_BROWN_FAT_PERCENT_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_FDG_BROWN_FAT_PERCENT_Y/2) ...
                                DLG_FDG_BROWN_FAT_PERCENT_X ...
                                DLG_FDG_BROWN_FAT_PERCENT_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'FDG Brown Fat Segmentation',...
                   'Toolbar','none'...               
                   );    

    % Exclude organ list

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'FontWeight','bold'  ,...
                  'string'  , 'Exclude organ list',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 540 300 20]...
                  );

    % Brain

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Brain',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVBrainCallback, ...
                  'position', [60 512 150 20]...
                  );

    chkBrownFatSUVBrain = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVBrain('get'),...
                  'position', [40 515 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVBrainCallback...
                  );

    % Heart

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Heart',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVHeartCallback, ...
                  'position', [60 487 150 20]...
                  );

    chkBrownFatSUVHeart = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVHeart('get'),...
                  'position', [40 490 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVHeartCallback...
                  );

    % Lungs

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Lungs',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVLungsCallback, ...
                  'position', [60 462 150 20]...
                  );

    chkBrownFatSUVLungs = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVLungs('get'),...
                  'position', [40 465 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVLungsCallback...
                  );

    % Trachea

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Trachea',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVTracheaCallback, ...
                  'position', [60 437 150 20]...
                  );

    chkBrownFatSUVTrachea = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVHeart('get'),...
                  'position', [40 440 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVTracheaCallback...
                  );

    % Kidney left

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Kidney left',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVKidneyLeftCallback, ...
                  'position', [60 412 150 20]...
                  );

    chkBrownFatSUVKidneyLeft = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVKidneyLeft('get'),...
                  'position', [40 415 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVKidneyLeftCallback...
                  );

    % Kidney right

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Kidney right',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVKidneyRightCallback, ...
                  'position', [60 387 150 20]...
                  );

    chkBrownFatSUVKidneyRight = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVKidneyRight('get'),...
                  'position', [40 390 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVKidneyRightCallback...
                  );
    
    % Liver

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Liver',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVLiverCallback, ...
                  'position', [60 362 150 20]...
                  );

    chkBrownFatSUVLiver = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVLiver('get'),...
                  'position', [40 365 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVLiverCallback...
                  );

    % Adrenal Gland Left

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Adrenal gland left',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVAdrenalGlandLeftCallback, ...
                  'position', [60 337 150 20]...
                  );

    chkBrownFatSUVAdrenalGlandLeft = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVPancreas('get'),...
                  'position', [40 340 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVAdrenalGlandLeftCallback...
                  );

    % Adrenal Gland Right

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Adrenal gland right',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVAdrenalGlandRightCallback, ...
                  'position', [60 312 150 20]...
                  );

    chkBrownFatSUVAdrenalGlandRight = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVPancreas('get'),...
                  'position', [40 315 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVAdrenalGlandRightCallback...
                  );

    % Spleen

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Spleen',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVSpleenCallback, ...
                  'position', [60 287 150 20]...
                  );

    chkBrownFatSUVSpleen = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVPancreas('get'),...
                  'position', [40 290 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVSpleenCallback...
                  );

    % Gallbladder

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Gallbladder',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVGallbladderCallback, ...
                  'position', [60 262 150 20]...
                  );

    chkBrownFatSUVGallbladder = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVPancreas('get'),...
                  'position', [40 265 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVGallbladderCallback...
                  );

    % Pancreas

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Pancreas',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVPancreasCallback, ...
                  'position', [60 237 150 20]...
                  );

    chkBrownFatSUVPancreas = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVPancreas('get'),...
                  'position', [40 240 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVPancreasCallback...
                  );

    % Skeleton

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Skeleton',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkBrownFatSUVSkeletonCallback, ...
                  'position', [60 212 150 20]...
                  );

    chkBrownFatSUVSkeleton = ...
        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeBrownFatSUVSkeleton('get'),...
                  'position', [40 215 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkBrownFatSUVSkeletonCallback...
                  );

    % Options

        uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'style'     , 'text',...
                  'FontWeight','bold'  ,...
                  'string'    , 'Options',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 165 300 20]...
                  );

        % CT HU threshold

        [dHUMinValue, dHUMaxValue] = FDGBrownFatHUThresholdValue('get');

            uicontrol(dlgFDGBrownFatSUVSegmentation,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'CT HU Threshold',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 137 185 20]...
                      );
    
        edtFDGBrownFatHUThresholdOfMaxValue = ...
            uicontrol(dlgFDGBrownFatSUVSegmentation, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 140 75 20], ...
                      'String'  , num2str(dHUMaxValue), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDGBrownFatHUThresholdValueCallback ...
                      ); 

        edtFDGBrownFatHUThresholdOfMinValue = ...
            uicontrol(dlgFDGBrownFatSUVSegmentation, ...
                      'Style'   , 'Edit', ...
                      'Position', [205 140 75 20], ...
                      'String'  , num2str(dHUMinValue), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDGBrownFatHUThresholdValueCallback ...
                      ); 

        % SUV threshold
    
            uicontrol(dlgFDGBrownFatSUVSegmentation,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'PT SUV Threshold',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 112 250 20]...
                      );
    
        edtFDGBrownFatSUVThresholdOfMaxValue = ...
            uicontrol(dlgFDGBrownFatSUVSegmentation, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 115 75 20], ...
                      'String'  , num2str(FDGBrownFatSUVThresholdValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDGBrownFatSUVThresholdOfMaxValueCallback ...
                      );     
    
         % Pixel Edge
    
            uicontrol(dlgFDGBrownFatSUVSegmentation,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Pixel Edge',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'  , @chkFDGBrownFatSUVPixelEdgeCallback, ...
                      'position', [40 87 150 20]...
                      );
    
        chkFDGBrownFatSUVPixelEdge = ...
            uicontrol(dlgFDGBrownFatSUVSegmentation,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , pixelEdge('get'),...
                      'position', [20 90 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'Callback', @chkFDGBrownFatSUVPixelEdgeCallback...
                      );
    
        % Smallest Contour (ml)
    
            uicontrol(dlgFDGBrownFatSUVSegmentation,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Smallest Contour (ml)',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 62 250 20]...
                      );
    
        edtFDGBrownFatSUVSmalestVoiValue = ...
            uicontrol(dlgFDGBrownFatSUVSegmentation, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(FDGBrownFatSmalestVoiValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDGBrownFatSUVSmalestVoiValueCallback ...
                      );  
    
         % Cancel or Proceed
    
         uicontrol(dlgFDGBrownFatSUVSegmentation,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelFDGBrownFatSUVSegmentationCallback...
                   );
    
         uicontrol(dlgFDGBrownFatSUVSegmentation,...
                  'String','Proceed',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedFDGBrownFatSUVSegmentationCallback...
                  );    
    end

    % Exclude organ list

    % Brain

    function chkBrownFatSUVBrainCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVBrain, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVBrain, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVBrain, 'Value');

        excludeBrownFatSUVBrain('set', bObjectValue);

    end

    % Heart

    function chkBrownFatSUVHeartCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVHeart, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVHeart, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVHeart, 'Value');

        excludeBrownFatSUVHeart('set', bObjectValue);

    end

    % Lungs

    function chkBrownFatSUVLungsCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVLungs, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVLungs, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVLungs, 'Value');

        excludeBrownFatSUVLungs('set', bObjectValue);

    end

    % Trachea

    function chkBrownFatSUVTracheaCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVTrachea, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVTrachea, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVTrachea, 'Value');

        excludeBrownFatSUVTrachea('set', bObjectValue);

    end

    % Kidney Left

    function chkBrownFatSUVKidneyLeftCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVKidneyLeft, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVKidneyLeft, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVKidneyLeft, 'Value');

        excludeBrownFatSUVKidneyLeft('set', bObjectValue);

    end

    % Kidney Right

    function chkBrownFatSUVKidneyRightCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVKidneyRight, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVKidneyRight, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVKidneyRight, 'Value');

        excludeBrownFatSUVKidneyRight('set', bObjectValue);

    end

    % Liver

    function chkBrownFatSUVLiverCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVLiver, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVLiver, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVLiver, 'Value');

        excludeBrownFatSUVLiver('set', bObjectValue);

    end

    % Adrenal Gland Left

    function chkBrownFatSUVAdrenalGlandLeftCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVAdrenalGlandLeft, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVAdrenalGlandLeft, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVAdrenalGlandLeft, 'Value');

        excludeBrownFatSUVAdrenalGlandLeft('set', bObjectValue);

    end

    % Adrenal Gland Right

    function chkBrownFatSUVAdrenalGlandRightCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVAdrenalGlandRight, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVAdrenalGlandRight, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVAdrenalGlandRight, 'Value');

        excludeBrownFatSUVAdrenalGlandRight('set', bObjectValue);

    end

    % Spleen

    function chkBrownFatSUVSpleenCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVSpleen, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVSpleen, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVSpleen, 'Value');

        excludeBrownFatSUVSpleen('set', bObjectValue);

    end

    % Gallbladder

    function chkBrownFatSUVGallbladderCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVGallbladder, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVGallbladder, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVGallbladder, 'Value');

        excludeBrownFatSUVGallbladder('set', bObjectValue);

    end

    % Pancreas

    function chkBrownFatSUVPancreasCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVPancreas, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVPancreas, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVPancreas, 'Value');

        excludeBrownFatSUVPancreas('set', bObjectValue);

    end

    % Skeleton

    function chkBrownFatSUVSkeletonCallback(hObject, ~)  
                
        bObjectValue = get(chkBrownFatSUVSkeleton, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkBrownFatSUVSkeleton, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkBrownFatSUVSkeleton, 'Value');

        excludeBrownFatSUVSkeleton('set', bObjectValue);

    end

    function edtFDGBrownFatSUVSmalestVoiValueCallback(~, ~)

        dObjectValue = str2double(get(edtFDGBrownFatSUVSmalestVoiValue, 'String'));

        if dObjectValue < 0

            dObjectValue = 0;

            set(edtFDGBrownFatSUVSmalestVoiValue, 'String', num2str(dObjectValue));
        end

        FDGSmalestVoiValue('set', dObjectValue);

    end

    function chkFDGBrownFatSUVPixelEdgeCallback(hObject, ~)  
                
        bObjectValue = get(chkFDGBrownFatSUVPixelEdge, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkFDGBrownFatSUVPixelEdge, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkFDGBrownFatSUVPixelEdge, 'Value');

        pixelEdge('set', bObjectValue);
        
        % Set contour panel checkbox

        set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));
    end

    function edtFDGBrownFatHUThresholdValueCallback(~, ~)     

        dBrownFatCTHUMinThreshold = str2double(get(edtFDGBrownFatHUThresholdOfMinValue, 'String'));
        dBrownFatCTHUMaxThreshold = str2double(get(edtFDGBrownFatHUThresholdOfMaxValue, 'String'));

        if dBrownFatCTHUMinThreshold >= dBrownFatCTHUMaxThreshold

            dBrownFatCTHUMinThreshold = dBrownFatCTHUMaxThreshold-1;

            set(edtFDGBrownFatHUThresholdOfMinValue, 'String', num2str(dBrownFatCTHUMinThreshold));
        end

        if dBrownFatCTHUMaxThreshold <= dBrownFatCTHUMinThreshold

            dBrownFatCTHUMaxThreshold = dBrownFatCTHUMinThreshold+1;

             set(edtFDGBrownFatHUThresholdOfMaxValue, 'String', num2str(dBrownFatCTHUMaxThreshold));
           
        end

        FDGBrownFatHUThresholdValue('set', dBrownFatCTHUMinThreshold, dBrownFatCTHUMaxThreshold); % HU
    end

    function edtFDGBrownFatSUVThresholdOfMaxValueCallback(~, ~)     

        dBrownFatThreshold = str2double(get(edtFDGBrownFatSUVThresholdOfMaxValue, 'String'));

        if dBrownFatThreshold <= 0

            dBrownFatThreshold = 2.5;

            set(edtFDGBrownFatSUVThresholdOfMaxValue, 'String', num2str(dBrownFatThreshold));
         
        end

        FDGSegmentationSUVThresholdValue('set', dBrownFatThreshold);

    end

    function cancelFDGBrownFatSUVSegmentationCallback(~, ~)   

        delete(dlgFDGBrownFatSUVSegmentation);
    end
    
    function proceedFDGBrownFatSUVSegmentationCallback(~, ~)

        % Exclude List

        tBrownFatSUV.exclude.organ.brain             = get(chkBrownFatSUVBrain            , 'value');
        tBrownFatSUV.exclude.organ.heart             = get(chkBrownFatSUVHeart            , 'value');
        tBrownFatSUV.exclude.organ.lungs             = get(chkBrownFatSUVLungs            , 'value');
        tBrownFatSUV.exclude.organ.kidneyLeft        = get(chkBrownFatSUVKidneyLeft       , 'value');
        tBrownFatSUV.exclude.organ.kidneyRight       = get(chkBrownFatSUVKidneyRight      , 'value');
        tBrownFatSUV.exclude.organ.liver             = get(chkBrownFatSUVLiver            , 'value');
        tBrownFatSUV.exclude.organ.trachea           = get(chkBrownFatSUVTrachea          , 'value');
        tBrownFatSUV.exclude.organ.adrenalGlandLeft  = get(chkBrownFatSUVAdrenalGlandLeft , 'value');
        tBrownFatSUV.exclude.organ.adrenalGlandRight = get(chkBrownFatSUVAdrenalGlandRight, 'value');
        tBrownFatSUV.exclude.organ.spleen            = get(chkBrownFatSUVSpleen           , 'value');
        tBrownFatSUV.exclude.organ.gallbladder       = get(chkBrownFatSUVGallbladder      , 'value');
        tBrownFatSUV.exclude.organ.pancreas          = get(chkBrownFatSUVPancreas         , 'value');
        tBrownFatSUV.exclude.organ.skeleton          = get(chkBrownFatSUVSkeleton         , 'value');

        % Options

        tBrownFatSUV.options.smalestVoiValue       = str2double(get(edtFDGBrownFatSUVSmalestVoiValue    , 'String'));
        tBrownFatSUV.options.pixelEdge             =            get(chkFDGBrownFatSUVPixelEdge          , 'value' );
        tBrownFatSUV.options.HUThreshold.min       = str2double(get(edtFDGBrownFatHUThresholdOfMinValue , 'String'));
        tBrownFatSUV.options.HUThreshold.max       = str2double(get(edtFDGBrownFatHUThresholdOfMaxValue , 'String'));
        tBrownFatSUV.options.SUVThreshold          = str2double(get(edtFDGBrownFatSUVThresholdOfMaxValue, 'String'));

        delete(dlgFDGBrownFatSUVSegmentation);

        setMachineLearningFDGBrownFatSUV(sSegmentatorScript, sSegmentatorCombineMasks, tBrownFatSUV); 
    end
    
end