function TriDFusion(varargin)
%function TriDFusion(varargin)
%Triple Dimention Fusion (3DF) Image Viewer main function.
%See TriDFuison.doc (or pdf) for more information about options.
%
% Note: Option settings must fit on one line and can contain at most one semicolon.
% -3d    : Display 2D View using 3D engine.
% -b     : Display 2D Border.
% -i     : TriDFusion is integrated with DIDOM Database Browser.
% -fusion: Activate the fusion. *Requires 2 volumes.
% -mip   : Activate the 3D MIP. *The order of activation of the MIP, vol, and iso dictates the emphasis of each feature of the 3D resulting image.
% -vol   : Activate the 3D volume rendering. *The order of activation of the MIP, vol, and iso dictates the emphasis of each feature of the 3D resulting image.
% -iso   : Activate the 3D iso surface. *The order of activation of the MIP, vol, and iso dictates the emphasis of each feature of the 3D resulting image.
% -w name: Execute a workflow.
% -r path: Set a destination path. 
%
% Example:
% TriDFusion(); Open the graphical user interface.
% TriDFusion('path_to_dicom_series_folder'); Open the graphical user interface with a DICOM image.
% TriDFusion('path_to_dicom_series_folder_1', 'path_to_dicom_series_folder_2');  Open the graphical user interface with 2 DICOM images.
% TriDFusion('path_to_dicom_series_folder_1', 'path_to_dicom_series_folder_2', '-fusion'); Open the graphical user interface with 2 DICOM images and fuse them.
% TriDFusion('path_to_dicom_series_folder', '-mip'); Open the graphical user interface with a DICOM image and create a 3D MIP.
% TriDFusion('path_to_dicom_series_folder', '-iso'); Open the graphical user interface with a DICOM image and create a 3D iso surface model.
% TriDFusion('path_to_dicom_series_folder', '-vol'); Open the graphical user interface with a DICOM image and create a 3D volume rendering.
% TriDFusion('path_to_dicom_series_folder', '-mip', '-iso', '-vol'); Open the graphical user interface with a DICOM image and create a fusion of a 3D MIP, iso surface, and volume rendering. Any combination can be used. 
% TriDFusion('path_to_dicom_series_folder', '-w', 'workflow_name'); Open the graphical user interface with a DICOM image and execute a workflow. Refer to processWorkflow.m for a list of available options. Refer to dicomViewer.m for workflows the default values. 
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
    
    % Set view defbault color

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

    viewerCrossLinesColor('set', [0 1 1]);

    viewerProgressBarLineColor('set',  [0 1 1]);

    arg3DEngine = false;
    argBorder   = false;
    argInternal = false;
    argFusion   = false;
    
    dOutputDirOffset = 0;
 
    asRendererPriority = [];
    sWorkflowName = [];

%    varargin = replace(varargin, '"', '');
%    varargin = replace(varargin, ']', '');
%    varargin = replace(varargin, '[', '');
    
    argLoop=1;
    for k = 1 : length(varargin)

        sSwitchAndArgument = char(varargin{k});

        sSwitchAndArgument = replace(sSwitchAndArgument, '"', '');
        sSwitchAndArgument = replace(sSwitchAndArgument, ']', '');
        sSwitchAndArgument = replace(sSwitchAndArgument, '[', '');

        switch lower(sSwitchAndArgument)
            
            case '-r' % Output directory
                if k+1 <= length(varargin)

                    if dOutputDirOffset == 0

                        sOutputPath = char(varargin{k+1});

                        sOutputPath = replace(sOutputPath, '"', '');
                        sOutputPath = replace(sOutputPath, ']', '');
                        sOutputPath = replace(sOutputPath, '[', '');

                        if sOutputPath(end) ~= '/' && ...
                           sOutputPath(end) ~= '\'

                            sOutputPath = [sOutputPath '/'];   
                        end

                        dOutputDirOffset = k+1;
                        outputDir('set', sOutputPath);                                                         
                    end
                end

            case '-w' % Workflow name

                if k+1 <= length(varargin)

                    sWorkflowName = char(varargin{k+1});

                    sWorkflowName = replace(sWorkflowName, '"', '');
                    sWorkflowName = replace(sWorkflowName, ']', '');
                    sWorkflowName = replace(sWorkflowName, '[', '');
                                  
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
                asRendererPriority{numel(asRendererPriority)+1} = 'vol';
                    
            case '-iso' % Activate 3D ISO Surface
                asRendererPriority{numel(asRendererPriority)+1} = 'iso';
                
            case '-mip' % Activate 3D MIP
                asRendererPriority{numel(asRendererPriority)+1} = 'mip';                                                
                
            otherwise
                
                if k ~= dOutputDirOffset % The output dir is set before

                    asMainDirArg{argLoop} = sSwitchAndArgument;
                    if asMainDirArg{argLoop}(end) ~= '/'
                        asMainDirArg{argLoop} = [asMainDirArg{argLoop} '/'];                     
                    end
                    argLoop = argLoop+1; 
                    mainDir('set', asMainDirArg);                                 
                end
        end
    end            
       
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

    aScreenSize  = get(groot, 'Screensize');

    xPosition = (aScreenSize(3) /2) - (620 /2);
    yPosition = (aScreenSize(4) /2) - (330 /2);

    if viewerUIFigure('get') == true
        
        fiMainWindow = ...
            uifigure('Name', 'TriDFusion (3DF) Image Viewer',...
                     'NumberTitle','off',...                           
                     'Position'   ,[xPosition, ...
                                   yPosition, ...
                                   620, ...
                                   330 ...
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
                                  620, ...
                                  330 ...
                                  ],... 
                   'MenuBar'    , 'none',...
                   'AutoResizeChildren', 'off', ...
                   'Toolbar'    , 'none',...
                   'color'      , 'black',...
                   'SizeChangedFcn',@resizeFigureCallback...
                 );        
    end

    if viewerUIFigure('get') == true

        DnD_uifigure(fiMainWindow, @openDnDImagesCallback);
    end

    fiMainWindowPtr('set', fiMainWindow);

    set(fiMainWindow, 'DefaultUipanelUnits', 'normalized');
% 
%     set(fiMainWindow, 'DefaultLineHitTest' , 'off');
%     set(fiMainWindow, 'DefaultPatchHitTest', 'off');
%     set(fiMainWindow, 'DefaultTextHitTest' , 'off');


    % set(fiMainWindow, 'AutoResizeChildren', 'off');

    % if viewerUIFigure('get') == true
    %     set(fiMainWindow, 'Renderer', 'opengl'); 
    %     set(fiMainWindow, 'GraphicsSmoothing', 'off'); 
    % else
    %     set(fiMainWindow, 'Renderer', 'opengl'); 
    %     set(fiMainWindow, 'doublebuffer', 'on');   
    % end

    setFigureDefaults(fiMainWindowPtr('get'));

    iptPointerManager(fiMainWindowPtr('get'));

    sRootPath = viewerRootPath('get');
    
    if ~isempty(sRootPath)

        javaFrame = get(fiMainWindowPtr('get'), 'JavaFrame');

        if ~isempty(javaFrame)
            
            javaFrame.setFigureIcon(javax.swing.ImageIcon(sprintf('%s/logo.png', sRootPath)));       
        end
    end

%      
%     
%     if argInternal == true
%         sLogoPath = './TriDFusion/logo.png';
%     else
%         sLogoPath = './logo.png';
%     end
% 
%     javaFrame = get(fiMainWindowPtr('get'), 'JavaFrame');
%     javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogoPath));
   

 %   movegui(fiMainWindowPtr('get'), 'center');                  
    
    uiSplashWindow = ...
        axes(fiMainWindowPtr('get'),...
             'Units'   , 'pixels',...
             'HitTest' , 'off', ...
             'position', [0 30 620 300]...
             );   
    uiSplashWindow.Toolbar.Visible = 'off';
    disableDefaultInteractivity(uiSplashWindow);

    uiProgressWindow = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'          , 'pixels',...
                'position'       , [0 0 620 30],...
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
        
%     sRootPath = viewerRootPath('get');
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

  %  imshow(imSplash, 'border', 'tight', 'Parent', uiSplashWindow);
%     image(imSplash, 'Parent', uiSplashWindow);
    imshow(imSplash,'border','tight','Parent', uiSplashWindow);
    uiSplashWindow.Toolbar.Visible = 'off';
       
    if useLocalTempFolder('get') == true

        try

        sMousePointer = get(fiMainWindowPtr('get'), 'Pointer');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow update; 

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
        catch
        end

        progressBar(1, 'Ready');

        set(fiMainWindowPtr('get'), 'Pointer', sMousePointer);
        drawnow update; 

    end
    
    initTemplates();
      
    delete(uiSplashWindow);
        
%     aScreenSize  = get(groot, 'Screensize');

 %   alPosition = get(fiMainWindowPtr('get'), 'Position');
        
 %   lMiddleX = alPosition(1) + (alPosition(3) /2);
 %   lMiddleY = alPosition(2) + (alPosition(4) /2);        

    
    set(fiMainWindowPtr('get'), 'Position', aScreenSize);   

    set(uiProgressWindowPtr('get'), 'Position', [0, 0, aScreenSize(3), 30]);

    set(uiBarPtr('get'), 'Position', [0, 0,  aScreenSize(3), 1]);

    drawnow update;

      %  uiProgressWindow.Position = [0, 0, 1440, 30];
        
     %   movegui(fiMainWindowPtr('get'), 'center');                                                         
      
    set(fiMainWindowPtr('get'), 'Resize'     , 'on');
    set(fiMainWindowPtr('get'), 'WindowState', 'maximized');

    drawnow update;

    % set(fiMainWindowPtr('get'), 'WindowState', 'maximized');
    
    resizeViewer = dicomViewer(); 

    setContours();
    
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