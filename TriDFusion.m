function TriDFusion(varargin)
%function TriDFusion(varargin)
%Triple Dimention Fusion Image Viewer Main.
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

    initViewerGlobal();
    
    arg3DEngine    = false;
    argGaussFilter = false; 
    argBorder      = false;
    argInternal    = false;
   
    varargin = replace(varargin, '"', '');
    varargin = replace(varargin, ']', '');
    varargin = replace(varargin, '[', '');
    
    argLoop=1;
    for k = 1 : length(varargin)
        sSwitchAndArgument = varargin{k};
        
        cSwitch = sSwitchAndArgument(1:2);
        
        switch cSwitch
            case '-3d'
                arg3DEngine = true;
                
            case '-b'
                argBorder = true; 
                
            case '-g'
                argGaussFilter = true;                
                
            case '-i'
                argInternal = true;                               
                
            otherwise
                asMainDirArg{argLoop} = sSwitchAndArgument;
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
    
    dScreenSize  = get(groot, 'Screensize');

    xPosition = (dScreenSize(3) /2) - (620 /2);
    yPosition = (dScreenSize(4) /2) - (330 /2);
        
    fiMainWindow = ...
        figure('Name', 'TriDFusion Image Viewer',...
               'NumberTitle','off',...                           
               'Position'   ,[xPosition, ...
                              yPosition, ...
                              620, ...
                              330 ...
                              ],... 
               'MenuBar'    , 'none',...
               'Toolbar'    ,'none',...
               'resize'     , 'off',...
               'color'      ,'black',...
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
                'Units'   , 'pixels',...
                'position', [0 0 620 30],...
                'title'   , 'Ready'...
                );       
    uiProgressWindowPtr('set', uiProgressWindow);
    
    uiBar = uipanel(uiProgressWindow);
    uiBarPtr('set', uiBar);
    
    set(fiMainWindowPtr('get'), 'doublebuffer', 'off'   );   
    set(fiMainWindowPtr('get'), 'Renderer'    , 'opengl'); 
    
    sScreenDir = pwd;
    if sScreenDir(end) ~= '\' || ...
       sScreenDir(end) ~= '/'     
        sScreenDir = [sScreenDir '/'];
    end   
         
    if argInternal == true
        sSplashFile = sprintf('%sTriDFusion//screenDefault.png', sScreenDir);
    else
        sSplashFile = sprintf('%sscreenDefault.png', sScreenDir);
    end

    [imSplash, ~] = imread(sSplashFile);
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
                                 
    function resizeFigureCallback(~,~)
        if exist('resizeViewer', 'var')
            resizeViewer();
        end
    end

end