function importContoursCallback(~, ~)
%function importContoursCallback(~, ~)
%Import RT Structure.
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

    atInput = inputTemplate('get');
    
    if isempty(atInput)
        return;
    end
    
    if size(dicomBuffer('get'), 3) == 1
        return;
    end
  
    filter = {'*.dcm'};

    sCurrentDir  = viewerRootPath('get');

    sMatFile = [sCurrentDir '/' 'importContourLastDir.mat'];
    % load last data directory
    if exist(sMatFile, 'file')
                            % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importContourLastDir', 'var')
            sCurrentDir = importContourLastDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
    end

    [sFileName, sPathName] = uigetfile(sprintf('%s%s', char(sCurrentDir), char(filter)), 'Import Contours');
    if sFileName ~= 0

        try
            importContourLastDir = sPathName;
            save(sMatFile, 'importContourLastDir');
        catch
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
                    
        progressBar(0.3 , sprintf('Importing Contours, please wait'));
        
%        try
            
        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');  
                
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
        drawnow;
            
        sContourFileName = sprintf('%s%s', sPathName, sFileName);
        
        initDcm4che3();

        tInfo = dicominfo4che3(sContourFileName);
                        
        if strcmpi(tInfo.Modality, 'RTSTRUCT')    
            
            dSeriesValue = get(uiSeriesPtr('get'), 'Value');

            atContours = readDicomContours(sContourFileName); 
            
            aContourImported = zeros(size(atContours));            
            
            for bb=1:numel(atInput)
                for dd=1:numel(atContours)
                    
                    progressBar(bb+dd/(numel(atInput)+numel(atContours)), sprintf('Volume %d: Scanning contour ROI %d/%d', bb, dd, numel(atContours)) );      

                    if ~isempty(atContours(dd).Referenced)
                        if strcmpi(atInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Find matching series
                                   atContours(dd).Referenced.SeriesInstanceUID)
    
                            inputContours('add', atContours(dd));
                            
                            setContours({atContours(dd)});
                            aContourImported(dd) = true;
                        end
                    end
                end
            end

       
            set(uiSeriesPtr('get'), 'Value', dSeriesValue);

            setSeriesCallback();
            set(uiSeriesPtr('get'), 'Enable', 'off');                        
        
            progressBar( 1, 'Ready');                
            
            if numel(aContourImported(aContourImported==true))
                
                set(uiCorWindowPtr('get'), 'Visible', 'on');
                set(uiSagWindowPtr('get'), 'Visible', 'on');
                set(uiTraWindowPtr('get'), 'Visible', 'on');
                set(uiMipWindowPtr('get'), 'Visible', 'on');

%                 set(uiSliderLevelPtr ('get'), 'Visible', 'on');
%                 set(uiSliderWindowPtr('get'), 'Visible', 'on');

                set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'on');
                set(lineColorbarIntensityMinPtr('get'), 'Visible', 'on');
        
                set(textColorbarIntensityMaxPtr('get'), 'Visible', 'on');
                set(textColorbarIntensityMinPtr('get'), 'Visible', 'on');

                set(uiSliderCorPtr('get'), 'Visible', 'on');
                set(uiSliderSagPtr('get'), 'Visible', 'on');   
                set(uiSliderTraPtr('get'), 'Visible', 'on');      
                set(uiSliderMipPtr('get'), 'Visible', 'on');      

%                hold off;
                setVoiRoiSegPopup();                        

                refreshImages();
            end
            
            if numel(aContourImported(aContourImported==true)) == 0

                displayContoursAssociationDialog(atContours, aContourImported);
            end
            
             
        end
        
%        catch
%            progressBar(1, 'Error:importContoursCallback()');                          
%        end
        
        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');                        
        mainToolBarEnable('on');  
                
        set(fiMainWindowPtr('get'), 'Pointer', 'default');            
        drawnow;
    end
     
    
    function displayContoursAssociationDialog(atContours, aContourImported)
                
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
                  'Name', 'Associate Contours',...
                  'Toolbar','none'...   
                   );  

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
        axeAssociate.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
        axeAssociate.Toolbar = [];

         sFact = sprintf('%d/%d contours have not been imported', numel(aContourImported(aContourImported==false)), numel(atContours));     
                 
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
                   'Callback', @cancelContoursAssociationCallback...
                   );

         uicontrol(dlgAssociate,...
                  'String','Proceed',...
                  'Position',[300 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedContoursAssociationCallback...
                  );                      
              
              
        function cancelContoursAssociationCallback(~, ~)
            
            delete(dlgAssociate);
        end
                 
        function proceedContoursAssociationCallback(~, ~)
                        
            dSerieOffset = get(uiAssociateSerie, 'Value');              
            
            delete(dlgAssociate);
            
            proceedContoursAssociation(dSerieOffset);
        end
        
        function proceedContoursAssociation(dSerieOffset)
            
            atInput = inputTemplate('get');

            for jj=1:numel(atContours)
                if aContourImported(jj) == false
                    atContours(jj).Referenced.SeriesInstanceUID   = atInput(dSerieOffset).atDicomInfo{1}.SeriesInstanceUID;         
                    atContours(jj).Referenced.FrameOfReferenceUID = atInput(dSerieOffset).atDicomInfo{1}.FrameOfReferenceUID;         
                                                             
                    inputContours('add', atContours(jj));
                        
                    setContours({atContours(jj)}, false);                
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