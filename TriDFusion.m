function TriDFusion(varargin)
%function TriDFusion(varargin)
%Triple Dimention Fusion Image Viewer Main.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
% -3d    : Display 2D View using 3D engine
% -b     : Display 2D Border
% -g     : Apply 3D Gauss Filter
% -i     : TriDFusion is integrated with DIDOM Database Browser
% -fusion: Activate the fusion. *Require 2 volumes 
% -mip   : Activate the 3D mip. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
% -iso   : Activate the 3D volume rendering. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
% -vol   : Activate the 3D iso surface. *The order of activation of the mip, vol and iso dictates the emphasis of each feature of the 3D resulting image
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

    initViewerGlobal();
    
    viewerAxesColor      ('set', [0.149 0.149 0.149]);
    viewerBackgroundColor('set', [0.16 0.18 0.20]);
    viewerForegroundColor('set', [0.94 0.94 0.94]);
    viewerHighlightColor ('set', [0.94 0.94 0.94]);
    viewerShadowColor    ('set', [0.94 0.94 0.94]);
    
    viewerButtonPushedBackgroundColor('set', [0.53 0.63 0.40]);
    viewerButtonPushedForegroundColor('set', [0.1 0.1 0.1]);
    
    arg3DEngine    = false;
    argGaussFilter = false; 
    argBorder      = false;
    argInternal    = false;
    argFusion      = false;
    
    asRendererPriority = [];
    
    varargin = replace(varargin, '"', '');
    varargin = replace(varargin, ']', '');
    varargin = replace(varargin, '[', '');
    
    argLoop=1;
    for k = 1 : length(varargin)
   
        switch lower(varargin{k})
            case '-3d' % 2D display using 3D engine
                arg3DEngine = true;

            case '-b' % Show Border 2D
                argBorder = true; 

            case '-g' % Apply Gauss Filter
                argGaussFilter = true;                

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
                asMainDirArg{argLoop} = varargin{k};
                if asMainDirArg{argLoop}(end) ~= '/'
                    asMainDirArg{argLoop} = [asMainDirArg{argLoop} '/'];                     
                end
                argLoop = argLoop+1; 
                mainDir('set', asMainDirArg);                                 
        end
    end            
    
    is3DEngine   ('set', arg3DEngine    );
    showBorder   ('set', argBorder      );
    gaussFilter  ('set', argGaussFilter ); 
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

    dScreenSize  = get(groot, 'Screensize');

    xPosition = (dScreenSize(3) /2) - (620 /2);
    yPosition = (dScreenSize(4) /2) - (330 /2);
        
    fiMainWindow = ...
        figure('Name', 'TriDFusion (3DF) Image Viewer',...
               'NumberTitle','off',...                           
               'Position'   ,[xPosition, ...
                              yPosition, ...
                              620, ...
                              330 ...
                              ],... 
               'MenuBar'    , 'none',...
               'Toolbar'    , 'none',...
               'resize'     , 'off',...
               'color'      , 'black',...
               'SizeChangedFcn',@resizeFigureCallback...
             );
    fiMainWindowPtr('set', fiMainWindow);

%    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');  
    
%    if argInternal == true
%        sLogoPath = './TriDFusion/logo.png';
%    else
%        sLogoPath = './logo.png';
%    end

%    javaFrame = get(fiMainWindowPtr('get'), 'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogoPath));
   

 %   movegui(fiMainWindowPtr('get'), 'center');                  
    
    uiSplashWindow = ...
        axes(fiMainWindowPtr('get'),...
             'Units'   , 'pixels',...
             'position', [0 30 620 300]...
             );   
                            
    uiProgressWindow = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'          , 'pixels',...
                'position'       , [0 0 620 30],...
                'title'          , 'Ready',...
                'BackgroundColor', viewerBackgroundColor ('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'ShadowColor'    , viewerShadowColor('get'), ...     
                'HighlightColor' , viewerHighlightColor('get') ...     
                );       
    uiProgressWindowPtr('set', uiProgressWindow);
    
    uiBar = uipanel(uiProgressWindow);
    
    set(uiBar, 'BackgroundColor', viewerBackgroundColor('get'));
    set(uiBar, 'ForegroundColor', viewerForegroundColor('get'));     
    set(uiBar, 'ShadowColor'    , viewerBackgroundColor('get'));
    set(uiBar, 'HighlightColor' , viewerBackgroundColor('get'));         
    uiBarPtr('set', uiBar);
    
    set(fiMainWindowPtr('get'), 'doublebuffer', 'off'   );   
    set(fiMainWindowPtr('get'), 'Renderer'    , 'opengl'); 
        
    sRootPath = viewerRootPath('get');
    if isempty(sRootPath)
        imSplash = zeros([300 620 3]);
    else       
        sSplashFile = sprintf('%sscreenDefault.png', sRootPath);
        [imSplash, ~] = imread(sSplashFile);
    end    

  %  imshow(imSplash, 'border', 'tight', 'Parent', uiSplashWindow);
    image(imSplash, 'Parent', uiSplashWindow);
                        
    initTemplates();
      
    delete(uiSplashWindow);
        
    aScreenSize  = get(groot, 'Screensize');

 %   alPosition = get(fiMainWindowPtr('get'), 'Position');
        
 %   lMiddleX = alPosition(1) + (alPosition(3) /2);
 %   lMiddleY = alPosition(2) + (alPosition(4) /2);        
        
    set(fiMainWindowPtr('get'), 'Position', aScreenSize);        
      %  uiProgressWindow.Position = [0, 0, 1440, 30];
        
     %   movegui(fiMainWindowPtr('get'), 'center');                                                         
      
    set(uiProgressWindowPtr('get'), 'Position'   , [0, 0, aScreenSize(3), 30]);
    set(fiMainWindowPtr('get')    , 'Resize'     , 'on');
    set(fiMainWindowPtr('get')    , 'WindowState', 'maximized');
    
    waitfor(fiMainWindowPtr('get'), 'WindowState', 'maximized');
    
    resizeViewer = dicomViewer(); 
            
    setContours();
    
 %   refreshImages();
       
    if argFusion == true % Init 2D Fuison   
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
        
    function resizeFigureCallback(~,~)
        if exist('resizeViewer', 'var')
            resizeViewer();
        end
    end

end