function setMachineLearningLu177Callback(~, ~)
%function setMachineLearningLu177Callback()
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

    sSegmentatorPath = validateSegmentatorInstallation();
    dlgMachineLearningLu177  = [];
  
    if ~isempty(sSegmentatorPath) % External Segmentor is installed

        DLG_LU177_PERCENT_X = 380;
        DLG_LU177_PERCENT_Y = 355;
    
        dlgMachineLearningLu177 = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_LU177_PERCENT_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_LU177_PERCENT_Y/2) ...
                                DLG_LU177_PERCENT_X ...
                                DLG_LU177_PERCENT_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'FDG Lymph Node SUV Segmentation',...
                   'Toolbar','none'...               
                   );    

    % Exclude organ list

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'FontWeight','bold'  ,...
                  'string'  , 'Exclude organ list',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 315 300 20]...
                  );

    % Brain

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Brain',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177BrainCallback, ...
                  'position', [60 287 150 20]...
                  );

    chkLu177Brain = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177Brain('get'),...
                  'position', [40 290 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177BrainCallback...
                  );

    % Spleen

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Spleen',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177SpleenCallback, ...
                  'position', [60 262 150 20]...
                  );

    chkLu177Spleen = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177Spleen('get'),...
                  'position', [40 265 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177SpleenCallback...
                  );

    % Kidney left

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Kidney left',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177KidneyLeftCallback, ...
                  'position', [60 237 150 20]...
                  );

    chkLu177KidneyLeft = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177KidneyLeft('get'),...
                  'position', [40 240 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177KidneyLeftCallback...
                  );

    % Kidney right

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Kidney right',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177KidneyRightCallback, ...
                  'position', [60 212 150 20]...
                  );

    chkLu177KidneyRight = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177KidneyRight('get'),...
                  'position', [40 215 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177KidneyRightCallback...
                  );
    
    % Small bowel

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Small bowel',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177SmallBowelCallback, ...
                  'position', [60 187 150 20]...
                  );

    chkLu177SmallBowel = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177SmallBowel('get'),...
                  'position', [40 190 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177SmallBowelCallback...
                  );

    % Urinary bladder

        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Urinary bladder',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkLu177UrinaryBladderCallback, ...
                  'position', [60 162 150 20]...
                  );

    chkLu177UrinaryBladder = ...
        uicontrol(dlgMachineLearningLu177,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , excludeLu177UrinaryBladder('get'),...
                  'position', [40 165 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkLu177UrinaryBladderCallback...
                  );

    % Options

        uicontrol(dlgMachineLearningLu177,...
                  'style'     , 'text',...
                  'FontWeight','bold'  ,...
                  'string'    , 'Options',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 115 300 20]...
                  );    

         % Pixel Edge
    
            uicontrol(dlgMachineLearningLu177,...
                      'style'   , 'text',...
                      'Enable'  , 'Inactive',...
                      'string'  , 'Pixel Edge',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'  , @chkFDGLu177PixelEdgeCallback, ...
                      'position', [40 87 150 20]...
                      );
    
        chkFDGLu177PixelEdge = ...
            uicontrol(dlgMachineLearningLu177,...
                      'style'   , 'checkbox',...
                      'enable'  , 'on',...
                      'value'   , pixelEdge('get'),...
                      'position', [20 90 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'Callback', @chkFDGLu177PixelEdgeCallback...
                      );
    
        % Smallest Contour (ml)
    
            uicontrol(dlgMachineLearningLu177,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Smallest Contour (ml)',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 62 250 20]...
                      );
    
        edtFDGLu177SmalestVoiValue = ...
            uicontrol(dlgMachineLearningLu177, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(FDGSmalestVoiValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtFDGLu177SmalestVoiValueCallback ...
                      );  
    
         % Cancel or Proceed
    
         uicontrol(dlgMachineLearningLu177,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelMachineLearningLu177Callback...
                   );
    
         uicontrol(dlgMachineLearningLu177,...
                  'String','Proceed',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedMachineLearningLu177Callback...
                  );    
    end

    % Exclude organ list

    % Brain

    function chkLu177BrainCallback(hObject, ~)  
                
        bObjectValue = get(chkLu177Brain, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkLu177Brain, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkLu177Brain, 'Value');

        excludeLu177Brain('set', bObjectValue);

    end

    % Kidney Left

    function chkLu177KidneyLeftCallback(hObject, ~)  
                
        bObjectValue = get(chkLu177KidneyLeft, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkLu177KidneyLeft, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkLu177KidneyLeft, 'Value');

        excludeLu177KidneyLeft('set', bObjectValue);

    end

    % Kidney Right

    function chkLu177KidneyRightCallback(hObject, ~)  
                
        bObjectValue = get(chkLu177KidneyRight, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkLu177KidneyRight, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkLu177KidneyRight, 'Value');

        excludeLu177KidneyRight('set', bObjectValue);

    end

    % Small Bowel

    function chkLu177SmallBowelCallback(hObject, ~)  
                
        bObjectValue = get(chkLu177SmallBowel, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkLu177SmallBowel, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkLu177SmallBowel, 'Value');

        excludeLu177SmallBowel('set', bObjectValue);

    end


    % Spleen

    function chkLu177SpleenCallback(hObject, ~)  
                
        bObjectValue = get(chkLu177Spleen, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkLu177Spleen, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkLu177Spleen, 'Value');

        excludeLu177Spleen('set', bObjectValue);

    end

    function edtFDGLu177SmalestVoiValueCallback(~, ~)

        dObjectValue = str2double(get(edtFDGLu177SmalestVoiValue, 'String'));

        if dObjectValue < 0

            dObjectValue = 0;

            set(edtFDGLu177SmalestVoiValue, 'String', num2str(dObjectValue));
        end

        FDGSmalestVoiValue('set', dObjectValue);

    end

    function chkFDGLu177PixelEdgeCallback(hObject, ~)  
                
        bObjectValue = get(chkFDGLu177PixelEdge, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkFDGLu177PixelEdge, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkFDGLu177PixelEdge, 'Value');

        pixelEdge('set', bObjectValue);
        
        % Set contour panel checkbox

        set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));
    end


    function cancelMachineLearningLu177Callback(~, ~)   

        delete(dlgMachineLearningLu177);
    end
    
    function proceedMachineLearningLu177Callback(~, ~)

        % Exclude List

        % Other Organs

        tLu177.exclude.organ.brain       = get(chkLu177Brain      , 'value');
        tLu177.exclude.organ.kidneyLeft  = get(chkLu177KidneyLeft , 'value');
        tLu177.exclude.organ.kidneyRight = get(chkLu177KidneyRight, 'value');
        tLu177.exclude.organ.spleen      = get(chkLu177Spleen, 'value');

        % Gastrointestinal Tract Name

        tLu177.exclude.gastrointestinal.smallBowel     = get(chkLu177SmallBowel    , 'value');
        tLu177.exclude.gastrointestinal.urinaryBladder = get(chkLu177UrinaryBladder, 'value');

        % Options

        tLu177.options.smalestVoiValue = str2double(get(edtFDGLu177SmalestVoiValue    , 'String'));
        tLu177.options.pixelEdge       = get(chkFDGLu177PixelEdge                     , 'value');

        delete(dlgMachineLearningLu177);

        setMachineLearningLu177(sSegmentatorPath, tLu177); 
    end
    
end