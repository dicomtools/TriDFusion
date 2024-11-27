function setFigureDefaults(fiWindow)
%function setFigureDefaults(fiWindow)
%Set a figure default behavior.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Activate double buffering 
    set(fiWindow, 'doublebuffer', 'on');   

    % Disable graphics smoothing
    set(fiWindow, 'GraphicsSmoothing', 'off');
    
    % Set renderer to opengl for 3D volshow
    set(fiWindow, 'Renderer', 'opengl'); 
    
    % Remove alphamap transparency is not needed
    set(fiWindow, 'Alphamap', linspace(0, 1, 64)); 
    
    % Cancel ongoing operations instead of queuing them
    set(fiWindow, 'BusyAction', 'cancel');
    
    % Disable clipping to improve speed
    set(fiWindow, 'Clipping', 'off');
      
    % Remove unnecessary child objects (if any) to reduce overhead
    set(fiWindow, 'Children', []);  
    
    % Disable interruptibility if there's no need to interrupt operations
    % set(fiWindow, 'Interruptible', 'off');
    
    % Remove colormap or reduce its complexity 
    set(fiWindow, 'Colormap', parula);  
    
    % Set CloseRequestFcn to 'closereq' (standard behavior)
    set(fiWindow, 'CloseRequestFcn', 'closeFigure');
end