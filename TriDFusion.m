function TriDFusion(varargin)
%function TriDFusion(varargin)
%Triple Dimention Fusion (3DF) Image Viewer main function.
%
% TriDFusion is a powerful tool for visualizing and processing DICOM images 
% with 3D rendering capabilities. It supports multiple visualization modes, 
% including MIP, volume rendering, and iso surface generation, along with 
% image fusion and workflow execution.
%
% For more details on options and usage, refer to TriDFusion.doc (or .pdf).
%
% **Option Settings:** 
% - Must fit on a single line.
%
% **Options:**
% - '-3d'     : Display a 2D view using the 3D engine.
% - '-b'      : Display a 2D border.
% - '-i'      : Integrates TriDFusion with the DIDOM Database Browser.
% - '-fusion' : Activate image fusion (*requires two volumes*).
% - '-mip'    : Enable 3D Maximum Intensity Projection (MIP). 
% - '-vol'    : Enable 3D volume rendering.
% - '-iso'    : Enable 3D iso surface rendering.
% - '-w name' : Execute a workflow.
% - '-r path' : Set a destination path.
%
% **Rendering Note:**
% The activation order of '-mip', '-vol', and '-iso' influences the emphasis 
% of each feature in the final 3D image.
%
% **Usage Examples:**
% - TriDFusion();  
%   Opens the graphical user interface.
% 
% - TriDFusion('path_to_dicom_series_folder');
%   Opens the GUI with a DICOM image.
% 
% - TriDFusion('path_to_dicom_series_folder_1', 'path_to_dicom_series_folder_2');
%   Opens the GUI with two DICOM images.
% 
% - TriDFusion('path_to_dicom_series_folder_1', 'path_to_dicom_series_folder_2', '-fusion');
%   Opens the GUI with two DICOM images and fuses them.
% 
% - TriDFusion('path_to_dicom_series_folder', '-mip');
%   Opens the GUI with a DICOM image and generates a 3D MIP.
% 
% - TriDFusion('path_to_dicom_series_folder', '-iso');
%   Opens the GUI with a DICOM image and creates a 3D iso surface model.
% 
% - TriDFusion('path_to_dicom_series_folder', '-vol');
%   Opens the GUI with a DICOM image and performs 3D volume rendering.
% 
% - TriDFusion('path_to_dicom_series_folder', '-mip', '-iso', '-vol');
%   Opens the GUI with a DICOM image and applies a combination of 3D MIP, 
%   iso surface, and volume rendering. Any combination can be used.
% 
% - TriDFusion('path_to_dicom_series_folder', '-w', 'workflow_name');
%   Opens the GUI with a DICOM image and executes a specified workflow.  
%   See 'processWorkflow.m' for available options. Default values are in 'dicomViewer.m'.
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

    useLocalTempFolder('set', true); % For opening speed improvment

    viewerUIFigure('set', false); % Tested wih Matlab 2023b

    viewerSUVtype('set', 'BW'); % Body Weight

    initViewerGlobal();
    
    % Set view default color

    viewerAxesColor      ('set', [0.149 0.149 0.149]);
    viewerBackgroundColor('set', [0.16 0.18 0.20]);
    viewerForegroundColor('set', [0.94 0.94 0.94]);
    viewerHighlightColor ('set', [0.94 0.94 0.94]);
    viewerShadowColor    ('set', [0.94 0.94 0.94]);
    
    viewerButtonPushedBackgroundColor('set', [0.53 0.63 0.40]);
    viewerButtonPushedForegroundColor('set', [0.1 0.1 0.1]);

    viewerColorbarIntensityMaxLineColor('set', [0.53 0.63 0.40]);
    viewerColorbarIntensityMinLineColor('set', [0.53 0.63 0.40]);
    viewerColorbarIntensityMaxTextColor('set', [0 0 0]);
    viewerColorbarIntensityMinTextColor('set', [0 0 0]);

    viewerFusionColorbarIntensityMaxLineColor('set', [0.53 0.63 0.40]);
    viewerFusionColorbarIntensityMinLineColor('set', [0.53 0.63 0.40]);
    viewerFusionColorbarIntensityMaxTextColor('set', [0 0 0]);
    viewerFusionColorbarIntensityMinTextColor('set', [0 0 0]);

    % viewerCrossLinesColor('set', [0.85, 0.25, 0.85]);
    viewerCrossLinesColor('set', [0.0000, 0.9608, 0.8275]); % Cyan
    viewerProgressBarLineColor('set',  [0.0000, 0.9608, 0.8275]);
    
    viewerToolbarHeight('set', 35);
    viewerToolbarIconSize('set', 25);

    viewerTopBarHeight('set', 65);
    viewerTopBarIconSize('set', 50);
    viewerTopBarColor('set', [0.2 0.2 0.2]);

    addOnWidth('set', 0);

    arg3DEngine = false;
    argBorder   = false;
    argInternal = false;
    argFusion   = false;
    
    dOutputDirOffset = 0;
    dRendererPriorityOffset = 1;

    asRendererPriority = cell(1, 1000);
    asMainDirArg = cell(1, 1000);
    sWorkflowName = [];
    
    argLoop=1;
    for k = 1 : length(varargin)

        sSwitchAndArgument = char(varargin{k});

        sSwitchAndArgument = replace(sSwitchAndArgument, '"', '');
        sSwitchAndArgument = replace(sSwitchAndArgument, ']', '');
        sSwitchAndArgument = replace(sSwitchAndArgument, '[', '');

        % sSwitchAndArgument = erase(char(varargin{k}), ['"', '[', ']']);

        switch lower(sSwitchAndArgument)
            
            case '-r' % Output directory

                if k+1 <= length(varargin)

                    if dOutputDirOffset == 0

                        sOutputPath = char(varargin{k+1});
                        sOutputPath = strrep(strrep(strrep(sOutputPath, '"', ''), '[', ''), ']', '');
                    
                        if ~endsWith(sOutputPath, {'/', '\'}) 

                            sOutputPath = sprintf('%s/', sOutputPath);   
                        end
                    
                        dOutputDirOffset = k+1;
                        outputDir('set', sOutputPath);
                    end
                end

            case '-w' % Workflow name

                if k+1 <= length(varargin)
                    sWorkflowName = strrep(strrep(strrep(char(varargin{k+1}), '"', ''), '[', ''), ']', '');
                end

            case '-3d' % 2D display using 3D engine
                arg3DEngine = true;

            case '-b' % Show Border 2D
                argBorder = true;               

            case '-i' % Viewer Integrate With DICOM DB Browser
                argInternal = true;                               

            case '-fusion' % Activate Fusion
                argFusion = true;                
                
            case '-vol' % Activate 3D Volume Rendering
                asRendererPriority{dRendererPriorityOffset} = 'vol';

                dRendererPriorityOffset = dRendererPriorityOffset+1;

            case '-iso' % Activate 3D ISO Surface
                asRendererPriority{dRendererPriorityOffset} = 'iso';

                dRendererPriorityOffset = dRendererPriorityOffset+1;
                
            case '-mip' % Activate 3D MIP
                asRendererPriority{dRendererPriorityOffset} = 'mip';   

                dRendererPriorityOffset = dRendererPriorityOffset+1;
               
            otherwise
                
                if k ~= dOutputDirOffset % The output dir is set before

                    asMainDirArg{argLoop} = sSwitchAndArgument;

                    if ~endsWith(asMainDirArg{argLoop}, {'/', '\'}) 
                    
                        asMainDirArg{argLoop} = sprintf('%s/',asMainDirArg{argLoop});                     
                    end
                    argLoop = argLoop+1; 
                end
        end
    end            

    % Remove all empty cell

    asMainDirArg = asMainDirArg(~cellfun(@isempty, asMainDirArg)); 
    asRendererPriority = asRendererPriority(~cellfun(@isempty, asRendererPriority)); 

    mainDir('set', asMainDirArg);                                 

    viewerTempDirectory('set', char([tempname '/']));
    
    if exist(viewerTempDirectory('get'), 'dir')

        rmdir(viewerTempDirectory('get'), 's');
    end
    mkdir(viewerTempDirectory('get'));
    
    is3DEngine('set', arg3DEngine);
    showBorder('set', argBorder  );
    
    seriesDescription ('set', ' ');
    integrateToBrowser('set', argInternal);

    cropValue('set', 0);
    
    imageSegEditValue('set', 'lower', 0);
    imageSegEditValue('set', 'upper', 0);
    
    useCropEditValue('set', 'lower', false);
    useCropEditValue('set', 'upper', false);

    imageCropEditValue('set', 'lower', 0);
    imageCropEditValue('set', 'upper', 1); 
     
    initViewerRootPath();
    
    viewerSetFullScreenIcon();

    sRootPath = viewerRootPath('get');

    if isempty(sRootPath)

        imSplash = zeros([300 620 3]);
    else       
        sSplashFile = sprintf('%sscreenDefault.png', sRootPath);
        if exist(sSplashFile, 'file')
            [imSplash, ~] = imread(sSplashFile);
        else
            imSplash = zeros([300 620 3]);
        end
    end 
    
    [imgHeight, imgWidth, ~] = size(imSplash);

    aScreenSize  = get(groot, 'Screensize');

    xPosition = (aScreenSize(3) /2) - (imgWidth /2);
    yPosition = (aScreenSize(4) /2) - (imgHeight /2);

    if viewerUIFigure('get') == true

        fiMainWindow = ...
            uifigure('Name', 'TriDFusion (3DF) Image Viewer',...
                     'NumberTitle','off',...                           
                     'Position'   ,[xPosition, ...
                                   yPosition, ...
                                   imgWidth, ...
                                   imgHeight ...
                                   ],... 
                    'MenuBar'    , 'none',...
                    'AutoResizeChildren', 'off', ...
                    'Toolbar'    , 'none',...
                    'color'      , 'black',...
                    'WindowStyle', 'normal',...
                    'SizeChangedFcn',@resizeFigureCallback...
                    );
    else
        fiMainWindow = ...
            figure('Name', 'TriDFusion (3DF) Image Viewer',...
                   'NumberTitle','off',...                           
                   'Position'   ,[xPosition, ...
                                  yPosition, ...
                                  imgWidth, ...
                                  imgHeight ...
                                  ],... 
                   'MenuBar'    , 'none',...
                   'AutoResizeChildren', 'off', ...
                   'Toolbar'    , 'none',...
                   'color'      , 'black',...
                   'WindowStyle', 'normal',...
                   'SizeChangedFcn',@resizeFigureCallback...
                 );        
    end

    if viewerUIFigure('get') == true 

        if isMATLABReleaseOlderThan('R2025a')

            DnD_uifigure(fiMainWindow, @openDnDImagesCallback);
        end
    end

    fiMainWindowPtr('set', fiMainWindow);

    set(fiMainWindow, 'DefaultUipanelUnits', 'normalized');

    setFigureDefaults(fiMainWindowPtr('get'));

    iptPointerManager(fiMainWindowPtr('get'));

    setObjectIcon(fiMainWindow);                
    
    uiSplashWindow = ...
        axes(fiMainWindowPtr('get'),...
             'Units'   , 'pixels',...
             'HitTest' , 'off', ...
             'position', [0 30 imgWidth imgHeight]...
             );   
    % uiSplashWindow.Toolbar.Visible = 'off';
    deleteAxesToolbar(uiSplashWindow);
    disableDefaultInteractivity(uiSplashWindow);

    uiProgressWindow = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'          , 'pixels',...
                'position'       , [0 0 imgWidth 30],...
                'title'          , 'Ready',...
                'HitTest'        , 'off', ...
                'BackgroundColor', viewerBackgroundColor ('get'), ...
                'ForegroundColor', viewerForegroundColor('get') ...
                );       
    uiProgressWindowPtr('set', uiProgressWindow);
    
    uiBar = uipanel(uiProgressWindow, 'Units', 'normalized');
    
    set(uiBar, 'BackgroundColor', viewerBackgroundColor('get'));
    set(uiBar, 'ForegroundColor', viewerForegroundColor('get'));  
    set(uiBar, 'Position', [0 0 1 1]);  
    
    uiBarPtr('set', uiBar);    
          
    imshow(imSplash,'border','tight','Parent', uiSplashWindow);
    disableAxesToolbar(uiSplashWindow);
    % uiSplashWindow.Toolbar.Visible = 'off';
       
    if useLocalTempFolder('get') == true

        try

        sMousePointer = get(fiMainWindowPtr('get'), 'Pointer');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow; 

        asMainDir = mainDir('get');
        if ~isempty(asMainDir)

            dNbDir = numel(asMainDir);

            for jj=1:dNbDir

                if isPathNetwork(asMainDir{jj})

                    progressBar((jj/dNbDir)-0.00001, sprintf('Parsing folder %d/%d, please wait', jj, dNbDir));
                  
                    sTmpDir = sprintf('%stemp_%s_%d/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'), jj);
                    mkdir(sTmpDir);

                    if ispc

                        cmd = sprintf('robocopy "%s" "%s" /MIR /R:0 /W:0 /MT:32 /Z /NFL /NDL /NC /NS /NP > nul 2>&1', asMainDir{jj}, sTmpDir);
                        system(cmd);
                                               
                    elseif isunix

                        rsyncCmd = sprintf('rsync -a "%s/" "%s/"', asMainDir{jj}, sTmpDir);
                        system(rsyncCmd); % Execute the rsync command 
                    
                    else
                        copyfile(asMainDir{jj}, sTmpDir, 'f'); % Fallback for non-Unix systems                   
                    end
                   
                    asMainDir{jj} = sTmpDir;
                  
                end
    
            end

            mainDir('set', asMainDir);
        end
        
        catch ME
            logErrorToFile(ME);
        end

        progressBar(1, 'Ready');

        set(fiMainWindowPtr('get'), 'Pointer', sMousePointer);
        drawnow; 

    end
    
    initTemplates();
      
    delete(uiSplashWindow);
        
    set(fiMainWindowPtr('get'), 'Position', aScreenSize);   

    set(uiProgressWindowPtr('get'), 'Position', [0, 0, aScreenSize(3), 30]);

    set(uiBarPtr('get'), 'Position', [0, 0,  aScreenSize(3), 1]);

    set(fiMainWindowPtr('get'), 'Resize'     , 'on');
    set(fiMainWindowPtr('get'), 'WindowState', 'maximized');

    drawnow;
    drawnow;
                                                            
    resizeViewer = dicomViewer(); 
    
    set(fiMainWindowPtr('get'), 'Resize'     , 'on');
    set(fiMainWindowPtr('get'), 'WindowState', 'maximized');

    drawnow;
    drawnow;

    setContours();
    setAnnotations();
   
    drawnow;
    drawnow;

 %   refreshImages();
       
    if argFusion == true % Init 2D Fusion  

        setFusionCallback();        
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

    if ~isempty(sWorkflowName)

         processWorkflow(sWorkflowName);
    end

    function resizeFigureCallback(~,~)
        
        if exist('resizeViewer', 'var')
            
            resizeViewer();
        end
    end

end