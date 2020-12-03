function importSTLCallback(~, ~)
%function importSTLCallback(~, ~)
%Import .stl Model.
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

    dlgSTLsize = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-190/2) ...
                            380 ...
                            190 ...
                            ],...
               'Name', 'Import STL Model'...
               );

%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(dlgSTLsize, 'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

    chkFillHoles = ...
        uicontrol(dlgSTLsize,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , true,...
                  'position', [20 140 20 20],...
                  'Callback', @stlFillHolesCallback...
                  );

         uicontrol(dlgSTLsize,...
                  'style'   , 'text',...
                  'enable'  , 'inactive',...
                  'string'  , 'Fill Holes',...
                  'horizontalalignment', 'left',...
                  'position', [40 137 200 20],...
                  'ButtonDownFcn', @stlFillHolesCallback...
                  );

         uicontrol(dlgSTLsize,...
                  'style'   , 'text',...
                  'enable'  , 'On',...
                  'string'  , 'Pixel Value',...
                  'horizontalalignment', 'left',...
                  'position', [20 112 200 20]...
                  );

    edtPixelValue = ...
        uicontrol(dlgSTLsize,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , '1',...
                 'position'  , [130 115 85 20]...
                 );

    aSerieSize = size(dicomBuffer('get'));
    if isempty(aSerieSize)
        sChkEnable = 'off';
        sTxtEnable = 'off';

        xSize = 100;
        ySize = 100;
        zSize = 100;
    else
        if aSerieSize(3) == 1
            sChkEnable = 'off';
            sTxtEnable = 'off';

            xSize = 100;
            ySize = 100;
            zSize = 100;
        else
            sChkEnable = 'on';
            sTxtEnable = 'Inactive';

            xSize = aSerieSize(1);
            ySize = aSerieSize(2);
            zSize = aSerieSize(3);
        end
    end

    chkUseSeries = ...
        uicontrol(dlgSTLsize,...
                  'style'   , 'checkbox',...
                  'enable'  , sChkEnable,...
                  'value'   , true,...
                  'position', [20 90 20 20],...
                  'Callback', @stlUseSerieCallback...
                  );

         uicontrol(dlgSTLsize,...
                  'style'   , 'text',...
                  'enable'  , sTxtEnable,...
                  'string'  , 'Use Current Serie To Generate Output',...
                  'horizontalalignment', 'left',...
                  'position', [40 87 200 20],...
                  'ButtonDownFcn', @stlUseSerieCallback...
                  );

    txtVoxelSize = ...
         uicontrol(dlgSTLsize,...
                  'style'   , 'text',...
                  'enable'  , 'On',...
                  'string'  , 'Output XYZ Size',...
                  'horizontalalignment', 'left',...
                  'position', [20 62 200 20]...
                  );

    edtVoxelSizeX = ...
        uicontrol(dlgSTLsize,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(xSize),...
                 'position'  , [130 65 40 20]...
                 );

    edtVoxelSizeY = ...
        uicontrol(dlgSTLsize,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(ySize),...
                 'position'  , [175 65 40 20]...
                 );

    edtVoxelSizeZ = ...
        uicontrol(dlgSTLsize,...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'string'    , num2str(zSize),...
                 'position'  , [220 65 40 20]...
                 );

    if get(chkUseSeries, 'Value') == true
        set(txtVoxelSize , 'Enable', 'off');
        set(edtVoxelSizeX, 'Enable', 'off');
        set(edtVoxelSizeY, 'Enable', 'off');
        set(edtVoxelSizeZ, 'Enable', 'off');
    else
        set(txtVoxelSize , 'Enable', 'on');
        set(edtVoxelSizeX, 'Enable', 'on');
        set(edtVoxelSizeY, 'Enable', 'on');
        set(edtVoxelSizeZ, 'Enable', 'on');
    end

     % Cancel or Proceed

     uicontrol(dlgSTLsize,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'Callback', @cancelImportSTLCallback...
               );

     uicontrol(dlgSTLsize,...
              'String','Open',...
              'Position',[200 7 75 25],...
              'Callback', @okImportSTLCallback...
              );

    function stlFillHolesCallback(hObject, ~)

        if get(chkFillHoles, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkFillHoles, 'Value', true);
            else
                set(chkFillHoles, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkFillHoles, 'Value', false);
            else
                set(chkFillHoles, 'Value', true);
            end
        end
    end

    function stlUseSerieCallback(hObject, ~)

        if get(chkUseSeries, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUseSeries, 'Value', true);
            else
                set(chkUseSeries, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox')
                set(chkUseSeries, 'Value', false);
            else
                set(chkUseSeries, 'Value', true);

            end
        end

        if get(chkUseSeries, 'Value') == true
            set(txtVoxelSize , 'Enable', 'off');
            set(edtVoxelSizeX, 'Enable', 'off');
            set(edtVoxelSizeY, 'Enable', 'off');
            set(edtVoxelSizeZ, 'Enable', 'off');
        else
            set(txtVoxelSize , 'Enable', 'on');
            set(edtVoxelSizeX, 'Enable', 'on');
            set(edtVoxelSizeY, 'Enable', 'on');
            set(edtVoxelSizeZ, 'Enable', 'on');
        end

     end

     function okImportSTLCallback(~, ~)

         filter = {'*.stl'};

         sCurrentDir = pwd;
         if integrateToBrowser('get') == true
             sCurrentDir = [sCurrentDir '/TriDFusion'];
         end

         sMatFile = [sCurrentDir '/' 'exportIsoLastUsedDir.mat'];
         % load last data directory
         if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('exportIsoLastUsedDir', 'var')
                sCurrentDir = exportIsoLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
         end

         [file, path] = uigetfile(sprintf('%s%s', char(sCurrentDir), char(filter)), 'Import STL');
         if file ~= 0

            try
                exportIsoLastUsedDir = path;
                save(sMatFile, 'exportIsoLastUsedDir');
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
                h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            aSerieSize = size(dicomBuffer('get'));
            if ~isempty(aSerieSize) && ...
               get(chkUseSeries, 'Value') == true
                if aSerieSize(3) == 1
                    XBufSize = str2double(get(edtVoxelSizeX, 'string'));
                    yBufSize = str2double(get(edtVoxelSizeY, 'string'));
                    zBufSize = str2double(get(edtVoxelSizeZ, 'string'));
                else
                    xBufSize = aSerieSize(1);
                    yBufSize = aSerieSize(2);
                    zBufSize = aSerieSize(3);
                end
            else
                xBufSize = str2double(get(edtVoxelSizeX, 'string'));
                yBufSize = str2double(get(edtVoxelSizeY, 'string'));
                zBufSize = str2double(get(edtVoxelSizeZ, 'string'));
            end

            bFillHoles = get(chkFillHoles, 'Value');
            dPixelValue = str2double(get(edtPixelValue, 'String'));

            delete(dlgSTLsize);

            readSTLModel(path, file, xBufSize, yBufSize, zBufSize, dPixelValue, bFillHoles);

         else
            delete(dlgSTLsize);
         end

     end

     function cancelImportSTLCallback(~, ~)
        delete(dlgSTLsize);
     end
end
