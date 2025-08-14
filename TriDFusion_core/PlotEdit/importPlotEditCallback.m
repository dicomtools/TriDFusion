function importPlotEditCallback(~, ~)
%function importPlotEditCallback(~, ~)
%Import plot edit from a file, the tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    filter = {'*.dcm'};

    sCurrentDir  = viewerRootPath('get');

    sMatFile = [sCurrentDir '/' 'importPlotEditLastDir.mat'];
    % load last data directory
    if exist(sMatFile, 'file')
                            % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importPlotEditLastDir', 'var')
            sCurrentDir = importPlotEditLastDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
    end

    [sFileName, sPathName] = uigetfile(sprintf('%s%s', char(sCurrentDir), char(filter)), 'Import PlotEdits');
    if sFileName ~= 0

        try
            importPlotEditLastDir = sPathName;
            save(sMatFile, 'importPlotEditLastDir');

        catch ME
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%            h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end

        try

        % Deactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'off');
        mainToolBarEnable('off');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        sPlotEditFileName = sprintf('%s%s', sPathName, sFileName);

        % Read only the metadata
        info = dicominfo(sPlotEditFileName);

        % Make sure our tag is there
        if isfield(info,'Private_0029_1010')

            bError = false;

            raw = info.Private_0029_1010;
            if isnumeric(raw)
                % uint8 vector → char row
                jsonText = char(raw(:)');
            elseif isstring(raw) || ischar(raw)
                jsonText = char(raw);
            else
                errordlg('Unsupported data type for Private_0029_1010!', 'Tag Error');
                bError = true;
            end

            if bError == false

                importPlotEdit(jsonText);

            end
        end

        catch ME
           logErrorToFile(ME);
           progressBar(1, 'Error:importPlotEditCallback()');
        end

        % Reactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'on');
        mainToolBarEnable('on');

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end


    function displayPlotEditsAssociationDialog(atPlotEdits, aPlotEditImported)

        if viewerUIFigure('get') == true

            dlgAssociate = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-480/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-190/2) ...
                                    480 ...
                                    190 ...
                                    ],...
                         'Resize'     , 'off', ...
                         'Color'      , viewerBackgroundColor('get'),...
                         'WindowStyle', 'modal', ...
                         'Name'       , 'Associate PlotEdits'...
                        );
         else

            dlgAssociate = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-480/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-190/2) ...
                                    480 ...
                                    190 ...
                                    ],...
                      'MenuBar', 'none',...
                      'Resize', 'off', ...
                      'NumberTitle','off',...
                      'MenuBar', 'none',...
                      'Color', viewerBackgroundColor('get'), ...
                      'Name', 'Associate PlotEdits',...
                      'Toolbar','none'...
                       );
        end

        setObjectIcon(dlgAssociate);

        axeAssociate = ...
            axes(dlgAssociate, ...
                 'Units'   , 'pixels', ...
                 'Position', get(dlgAssociate, 'Position'), ...
                 'Color'   , viewerBackgroundColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...
                 'Visible' , 'off'...
                 );
        axeAssociate.Interactions = [];
        deleteAxesToolbar(axeAssociate);
        % axeAssociate.Toolbar = [];

         sFact = sprintf('%d/%d PlotEdits have not been imported', numel(aPlotEditImported(aPlotEditImported==false)), numel(atPlotEdits));

             uicontrol(dlgAssociate,...
                       'style'   , 'text',...
                       'string'  , sFact,...
                       'horizontalalignment', 'left',...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', 'red', ...
                       'position', [20 140 440 20]...
                       );

              uicontrol(dlgAssociate,...
                       'style'   , 'text',...
                       'string'  , 'Warning: Proceed can lead to error!',...
                       'horizontalalignment', 'left',...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', 'red', ...
                       'position', [20 120 440 20]...
                       );

             uicontrol(dlgAssociate,...
                       'style'   , 'text',...
                       'string'  , 'Associate with:',...
                       'horizontalalignment', 'left',...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'position', [20 65 440 20]...
                       );

        uiAssociateSerie = ...
             uicontrol(dlgAssociate, ...
                       'Style'   , 'popup', ...
                       'Position', [190 65 270 25], ...
                       'String'  , get(uiSeriesPtr('get'), 'String'), ...
                       'Value'   , get(uiSeriesPtr('get'), 'Value'),...
                       'BackgroundColor', viewerBackgroundColor ('get'), ...
                       'ForegroundColor', viewerForegroundColor('get') ...
                       );


         % Cancel or Proceed

         uicontrol(dlgAssociate,...
                   'String','Cancel',...
                   'Position',[385 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...
                   'Callback', @cancelPlotEditsAssociationCallback...
                   );

         uicontrol(dlgAssociate,...
                  'String','Proceed',...
                  'Position',[300 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @proceedPlotEditsAssociationCallback...
                  );


        function cancelPlotEditsAssociationCallback(~, ~)

            delete(dlgAssociate);
        end

        function proceedPlotEditsAssociationCallback(~, ~)

            dSerieOffset = get(uiAssociateSerie, 'Value');

            delete(dlgAssociate);

            proceedPlotEditsAssociation(dSerieOffset);
        end

        function proceedPlotEditsAssociation(dSerieOffset)

            atInput = inputTemplate('get');

            for jj=1:numel(atPlotEdits)
                if aPlotEditImported(jj) == false
                    atPlotEdits(jj).Referenced.SeriesInstanceUID   = atInput(dSerieOffset).atDicomInfo{1}.SeriesInstanceUID;
                    atPlotEdits(jj).Referenced.FrameOfReferenceUID = atInput(dSerieOffset).atDicomInfo{1}.FrameOfReferenceUID;

                    inputAnnotations('add', atPlotEdits(jj));

                    setAnnotations({atPlotEdits(jj)});
                end
            end

            set(uiCorWindowPtr('get'), 'Visible', 'on');
            set(uiSagWindowPtr('get'), 'Visible', 'on');
            set(uiTraWindowPtr('get'), 'Visible', 'on');
            set(uiMipWindowPtr('get'), 'Visible', 'on');

%             set(uiSliderLevelPtr ('get'), 'Visible', 'on');
%             set(uiSliderWindowPtr('get'), 'Visible', 'on');

            set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(lineColorbarIntensityMinPtr('get'), 'Visible', 'on');

            set(textColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(textColorbarIntensityMinPtr('get'), 'Visible', 'on');

            set(uiSliderCorPtr('get'), 'Visible', 'on');
            set(uiSliderSagPtr('get'), 'Visible', 'on');
            set(uiSliderTraPtr('get'), 'Visible', 'on');
            set(uiSliderMipPtr('get'), 'Visible', 'on');

%            hold off;

            clearDisplay();

            if size(dicomBuffer('get'), 3) == 1
                initDisplay(1);
            else
                initDisplay(3);
            end

            dicomViewerCore();

            progressBar( 1, 'Ready');

        end

    end


end
