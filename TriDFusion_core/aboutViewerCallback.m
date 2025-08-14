function aboutViewerCallback(~, ~)
%function aboutViewerCallback(~, ~)
%Display Viewer About.
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

    sRootPath  = viewerRootPath('get');
    sAboutFile = sprintf('%s/about.txt', sRootPath);

    sDisplayBuffer = '';

    % Open the file for reading
    fFileID = fopen(sAboutFile, 'r');
    if fFileID == -1
        % If the file couldn't be opened, display a warning and exit
        warning('Could not open file: %s', sAboutFile);
        return;
    end
    
    dNbLines = 0;
    % Read the file line by line
    tline = fgetl(fFileID);
    while ischar(tline)
        % Append the line to the display buffer
        sDisplayBuffer = sprintf('%s%s\n',sDisplayBuffer, tline);  % More efficient string concatenation
        tline = fgetl(fFileID);

        dNbLines = dNbLines+1;
    end
    
    % Close the file after reading
    fclose(fFileID);

    % % Show the content in a message box
    % h = msgbox(sDisplayBuffer, 'About','help');

    xSize = 420;
    ySize = round(25*dNbLines);

    dlgAbout = ...
        uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-xSize/2) ...
                        (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-ySize/2) ...
                        xSize ...
                        ySize ...
                        ],...
               'Resize'     , 'off', ...
               'Color'      , viewerBackgroundColor('get'),...
               'WindowStyle', 'modal', ...
               'Name'       , 'About'...
               );

    sRootPath = viewerRootPath('get');
            
    if ~isempty(sRootPath) 
                    
        dlgAbout.Icon = fullfile(sRootPath, 'logo.png');
    end

    aDlgPosition = get(dlgAbout, 'Position');

    uicontrol(dlgAbout,...
              'String','OK',...
              'Position',[(aDlgPosition(3)/2)-(75/2) 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @okAboutCallback...
              );   

    % Display text with line breaks
    uicontrol(dlgAbout, ...
              'Style'   , 'text', ...
              'HorizontalAlignment','left', ...
              'String'  , sDisplayBuffer, ...
              'Position', [10 40 aDlgPosition(3)-20 aDlgPosition(4)-50], ... % Adjusted padding              'HorizontalAlignment', 'left', ...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'),...
              'FontSize', 10, ...
              'FontName', 'Arial');
    
    drawnow;

    function okAboutCallback(~, ~)

        delete(dlgAbout);
    end
end
