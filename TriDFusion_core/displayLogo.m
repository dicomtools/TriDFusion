function uiLogo = displayLogo(uiWindow)
%function uiLogo = displayLogo(uiWindow)
%   DISPLAYVIEWERLOGO(uiWindow) renders the TriDFusion (3DF) logo within the
%   provided UI window (uiWindow). The function adapts the logo's position
%   and appearance based on the current viewing modes and settings.
%
%   Input:
%       uiWindow - Handle to the user interface window where the logo will be displayed.
%
%   Behavior:
%       - Positions the logo differently if fusion mode is active.
%       - Adjusts text color based on the background and 3D mode settings.
%       - Ensures the logo maintains transparency and proper interactivity settings.
%
%   Example:
%       % Assuming 'uipanel' is a handle to an existing figure window:
%       displayViewerLogo(uipanel);
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

    % Check 3D mode and view conditions

    is3DMode        = switchTo3DMode('get') || ...
                      switchToIsoSurface('get') || ...
                      switchToMIPMode('get');
    aDicomSize      = size(dicomBuffer('get'), 3);
    isVsplashActive = isVsplash('get');
    vSplashView     = vSplahView('get');
    isFusionActive  = isFusion('get');

    if isgraphics(uiWindow, 'axes') % If the input an axes, we will use it uipanel.

        uiWindow = uiWindow.Parent;
    end

    % Determine the position based on conditions

    if ~is3DMode && (aDicomSize == 1 || ...
       (isVsplashActive && any(strcmpi(vSplashView, {'axial', 'coronal', 'sagittal'}))))

        aPosition = [-20, isFusionActive * 20 + 15, 70, 20];
    else
        aPosition = [-20, 15, 70, 20];
    end
    
    % Create the uiLogo axes
    uiLogo = axes(uiWindow, ...
                  'Units', 'pixels', ...
                  'Position', aPosition, ...
                  'Visible', 'off');

    uiLogo.Interactions = [];
    disableDefaultInteractivity(uiLogo);
    deleteAxesToolbar(uiLogo);
   
    % Define the root path and logo file path
    sRootPath = viewerRootPath('get');
    logoPath = fullfile(sRootPath, 'logo.png');
    
    % Check if the logo file exists
    if exist(logoPath, 'file')
        % Read the logo image
        [logoImage, ~, alphaChannel] = imread(logoPath);
    
        % Display the logo image on the uiLogo axes
        hImage = imshow(logoImage, 'Parent', uiLogo);
        
        % Set the alpha data to the image's alpha channel to preserve transparency
        set(hImage, 'AlphaData', alphaChannel);
    
        % Hold the current content of uiLogo axes
        hold(uiLogo, 'on');
    
        % Get the size of the logo image
        [imgHeight, imgWidth, ~] = size(logoImage);
    
        % Define the position for the text
        textX = imgWidth + 10; % 10 pixels to the right of the image
        textY = imgHeight / 2; % Vertically centered
    
        % Display the text on the uiLogo axes
        t = text(uiLogo, textX, textY, 'TriDFusion (3DF)', ...
            'Color', 'k', 'FontSize', 10, 'VerticalAlignment', 'middle');
    
        % Release the hold on the uiLogo axes
        hold(uiLogo, 'off');
    end
    
    % Determine text color based on mode and background
    if is3DMode
        bgColor = surfaceColor('get', background3DOffset('get'));
    else
        bgColor = backgroundColor('get');
    end

    if any(strcmpi(bgColor, {'black', 'blue'}))
        t.Color = [0.8500, 0.8500, 0.8500];
    else
        t.Color = [0.1500, 0.1500, 0.1500];
    end
    
    disableAxesToolbar(uiLogo);

end
