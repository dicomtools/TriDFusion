function viewRegistrationReport(~, ~)
%function viewRegistrationReport(~, ~)
%Display a Dialog of the registration.
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

    DIAG_REPORT_X = 485;
    DIAG_REPORT_Y = 490;
    
    dlgReport = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DIAG_REPORT_X/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DIAG_REPORT_Y/2) ...
                            DIAG_REPORT_X ...
                            DIAG_REPORT_Y ...
                            ],...
               'Name', 'Registration Report'...
               );

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(dlgReport,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));             

    uicontrol(dlgReport,...
              'style'   , 'listbox',...
              'position', [0 0 DIAG_REPORT_X DIAG_REPORT_Y],...
              'fontsize', 10,...
              'Fontname', 'Monospaced',...
              'Value'   , 1 ,...
              'Selected', 'off',...
              'enable'  , 'on',...
              'string'  , registrationReport('get')...
              );

end
