function importContoursCallback(~, ~)

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
        
        try
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
        drawnow;
            
        sContourFileName = sprintf('%s%s', sPathName, sFileName);
        
        initDcm4che3();

        tInfo = dicominfo4che3(sContourFileName);
                        
        if strcmpi(tInfo.Modality, 'RTSTRUCT')                   
        
            atContours = readDicomContours(sContourFileName); 
            
            aContourImported = zeros(size(atContours));            
            
            for bb=1:numel(atInput)
                for dd=1:numel(atContours)
                    
                    progressBar(bb+dd/(numel(atInput)+numel(atContours)), sprintf('Volume %d: Scanning contour ROI %d/%d', bb, dd, numel(atContours)) );      
             
                    if strcmpi(atInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Find matching series
                               atContours(dd).Referenced.SeriesInstanceUID)

                        inputContours('add', atContours(dd));
                        
                        setContours({atContours(dd)});
                        aContourImported(dd) = true;
                    end
                end
            end
            
            progressBar( 1, 'Ready');                
            
            if numel(aContourImported(aContourImported==true))
                
                set(uiCorWindowPtr('get'), 'Visible', 'on');
                set(uiSagWindowPtr('get'), 'Visible', 'on');
                set(uiTraWindowPtr('get'), 'Visible', 'on');

                set(uiSliderLevelPtr ('get'), 'Visible', 'on');
                set(uiSliderWindowPtr('get'), 'Visible', 'on');

                set(uiSliderCorPtr('get'), 'Visible', 'on');
                set(uiSliderSagPtr('get'), 'Visible', 'on');   
                set(uiSliderTraPtr('get'), 'Visible', 'on');      

%                hold off;

                refreshImages();
            end
            
            if ~(numel(aContourImported(aContourImported==true)) == numel(atContours))

                displayContoursAssociationDialog(atContours, aContourImported);
            end
            
             
        end
        
        catch
            progressBar(1, 'Error:importContoursCallback()');                          
        end

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
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Associate Contours'...
                   );  
               
                  
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
                    atContours(jj).Referenced.SeriesInstanceUID = atInput(dSerieOffset).atDicomInfo{1}.SeriesInstanceUID;         
                
                    inputContours('add', atContours(dd));
                        
                    setContours({atContours(dd)});                
                end
            end
            
            set(uiCorWindowPtr('get'), 'Visible', 'on');
            set(uiSagWindowPtr('get'), 'Visible', 'on');
            set(uiTraWindowPtr('get'), 'Visible', 'on');

            set(uiSliderLevelPtr ('get'), 'Visible', 'on');
            set(uiSliderWindowPtr('get'), 'Visible', 'on');

            set(uiSliderCorPtr('get'), 'Visible', 'on');
            set(uiSliderSagPtr('get'), 'Visible', 'on');   
            set(uiSliderTraPtr('get'), 'Visible', 'on');      

%            hold off;

            refreshImages();
            
            progressBar( 1, 'Ready');      
            
        end                 
        
    end
    
    
end