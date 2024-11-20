function saveTotalSegmentatorLicenseCallback(~, ~)
%function saveTotalSegmentatorLicenseCallback(~, ~)
%Activate Total Segmentator License.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 224, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    DLG_LICENSE_X = 480;
    DLG_LICENSE_Y = 180;

    if viewerUIFigure('get') == true

        dlgLicense = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_LICENSE_X/2) ...
                                  (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_LICENSE_Y/2) ...
                                 DLG_LICENSE_X ...
                                 DLG_LICENSE_Y ...
                                 ],...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'WindowStyle', 'modal', ...
                   'Name' , 'Activate Total Segmentator License'...
                   );
    else
        dlgLicense = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_LICENSE_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_LICENSE_Y/2) ...
                                DLG_LICENSE_X ...
                                DLG_LICENSE_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'Activate Total Segmentator License',...
                   'Toolbar','none'...
                   );
    end

    axeLicense = ...
        axes(dlgLicense, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 DLG_LICENSE_X DLG_LICENSE_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
    axeLicense.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeLicense.Toolbar.Visible = 'off';
    disableDefaultInteractivity(axeLicense);

         uicontrol(dlgLicense,...
                  'style'     , 'text',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'License:',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', 'white', ...
                  'position', [10 ...
                               125 ...
                               70 ...
                               20], ...
                  'ButtonDownFcn', @visitTotalSegmentatorLicense...
                  );

   edtLicenseString = ...
       uicontrol(dlgLicense,...
                 'style'     , 'edit',...
                 'enable'    , 'on',...
                 'Background', 'white',...
                 'string'    , ' ',...
                 'position'  , [80 125 390 20],...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get') ...
                 );

         uicontrol(dlgLicense,...
                  'style'     , 'text',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'A free non-commercial license can be acquire here:',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', 'white', ...
                  'position', [10 ...
                               75 ...
                               470 ...
                               20], ...
                  'ButtonDownFcn', @visitTotalSegmentatorLicense...
                  );

         uicontrol(dlgLicense,...
                  'style'     , 'text',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...
                  'string'    , 'https://backend.totalsegmentator.com/license-academic/',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', 'white', ...
                  'position', [10 ...
                               50 ...
                               470 ...
                               20], ...
                  'ButtonDownFcn', @visitTotalSegmentatorLicense...
                  );

     % Cancel or Save

     uicontrol(dlgLicense,...
               'String','Cancel',...
               'Position',[385 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'Callback', @cancelSaveLicenseCallback...
               );

     uicontrol(dlgLicense,...
              'String','Save',...
              'Position',[300 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...
              'Callback', @saveLicenseCallback...
              );

    function visitTotalSegmentatorLicense(~, ~)
        web('https://backend.totalsegmentator.com/license-academic/');
    end

    function cancelSaveLicenseCallback(~, ~)

        delete(dlgLicense);
    end


    function saveLicenseCallback(~, ~)

        try

        sPointer = get(fiMainWindowPtr('get'), 'Pointer');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        sCommandLine = sprintf('cmd.exe /c totalseg_set_license -l %s', get(edtLicenseString, 'String'));

        delete(dlgLicense);
        
        [bStatus, sCmdout] = system(sCommandLine);

        if bStatus
            progressBar( 1, 'Error: An error occur during license saving!');
            errordlg(sprintf('An error occur during license saving: %s', sCmdout), 'Segmentation Error');
        else
            msgbox(sCmdout);
        end 

        catch
            progressBar( 1 , 'Error: saveLicenseCallback()' );            
        end

        set(fiMainWindowPtr('get'), 'Pointer', sPointer);
        drawnow;

    end
end