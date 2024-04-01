function loadDcmFile(asMainDirectory, sFileName, bInitDisplay)
%function loadDcmFile(asMainDirectory, sFileName, bInitDisplay)
%Load .dcm file to TriDFusion.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
    
    atInput = inputTemplate('get');
    
    try

    if bInitDisplay == true    

        set(uiSeriesPtr('get'), 'Enable', 'off');       

        mainToolBarEnable('off');

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow; 
        
        releaseRoiWait();
    
        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
    
        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnZoomPtr('get'), 'FontWeight', 'normal');
        zoomTool('set', false);
        zoom(fiMainWindowPtr('get'), 'off');           
    
        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
        set(btnPanPtr('get'), 'FontWeight', 'normal');
        panTool('set', false);
        pan(fiMainWindowPtr('get'), 'off');     
    
        set(rotate3DMenu('get'), 'Checked', 'off');         
        rotate3DTool('set', false);
        rotate3d(fiMainWindowPtr('get'), 'off');
    
        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);              
        datacursormode(fiMainWindowPtr('get'), 'off');  
        
        switchTo3DMode    ('set', false);
        switchToIsoSurface('set', false);
        switchToMIPMode   ('set', false);
    
        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnFusionPtr('get'), 'FontWeight', 'normal');
    
        set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btn3DPtr('get'), 'FontWeight', 'normal');
    
        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');
    
        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnMIPPtr('get'), 'FontWeight', 'normal');
        
        progressBar(0.5, 'Reading DICOM, please wait.');
    end

    if isempty(sFileName)

        [asFilesList, atDicomInfo, aDicomBuffer] = readDicomFolder(asMainDirectory);
    else
        asFilesList{1}{1}  = sFileName;
        atDicomInfo{1}{1}  = dicominfo4che3(sFileName);
        aDicomBuffer{1}{1} = readDcm4che3(sFileName, atDicomInfo{1}{1});

        if strcmpi(atDicomInfo{1}{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7') || ... % Screen capture
           strcmpi(atDicomInfo{1}{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7.4')

            aDicomBuffer{1}{1} = reshape(aDicomBuffer{1}{1}, [size(aDicomBuffer{1}{1}, 1), size(aDicomBuffer{1}{1}, 2), 1, 3]);
        end
    end

    if ~isempty(asFilesList) && ...
       ~isempty(atDicomInfo) && ...
       ~isempty(aDicomBuffer)
       
        [atNewInput, asSeriesDescription] = initInputTemplate(asFilesList, atDicomInfo, aDicomBuffer);

        asNewSeriesDescription = seriesDescription('get');

        for jj=1:numel(atNewInput)

            if isempty(atInput)

                atInput = struct(atNewInput(1));
                
                inputTemplate('set', atInput);
        
                setInputOrientation(1);
        
                setDisplayBuffer(1);  

                aInputBuffer = inputBuffer('get');

                dicomBuffer('set', aInputBuffer{1}, 1);    
          
                atInput = inputTemplate('get');

                if size(aInputBuffer{1}, 3) ~= 1

                    mipBuffer('set', atInput(1).aMip, 1);
                end
                
                clear aInputBuffer;

                asNewSeriesDescription = cell(1, 1);
                asNewSeriesDescription{1} = asSeriesDescription{1};

                seriesDescription('set', asNewSeriesDescription);

                setQuantification(1);
            else
                atInput(end+1) = atNewInput(jj);

                inputTemplate('set', atInput);
        
                setInputOrientation(numel(atInput));
        
                setDisplayBuffer(numel(atInput));

                aInputBuffer = inputBuffer('get');

                dicomBuffer('set', aInputBuffer{numel(atInput)}, numel(atInput));    

                atInput = inputTemplate('get');

                if size(aInputBuffer{numel(atInput)}, 3) ~= 1

                    mipBuffer('set', atInput(numel(atInput)).aMip, numel(atInput));
                end

                clear aInputBuffer;

                asNewSeriesDescription{numel(asNewSeriesDescription)+1} = asSeriesDescription{jj};

                seriesDescription('set', asNewSeriesDescription);

                setQuantification(numel(atInput));
            end
            
            % setContours(tContours, false);

        end
              

        set(uiSeriesPtr('get'), 'String', asNewSeriesDescription);
        set(uiFusedSeriesPtr('get'), 'String', asNewSeriesDescription);

        if bInitDisplay == true    
    
            set(uiSeriesPtr('get'), 'Value', numel(atInput));
    
            imageOrientation('set', 'axial');       
        end
    
   
        if bInitDisplay == true    

            atInput = inputTemplate('get');
 
            dicomMetaData('set', atInput(numel(atInput)).atDicomInfo, numel(atInput));

            cropValue('set', min(dicomBuffer('get'), [], 'all'));
    
            clearDisplay();  
    
            initDisplay(3); 
        
            initWindowLevel('set', true);
        
            dicomViewerCore();  
            
            setViewerDefaultColor(1, atInput(numel(atInput)).atDicomInfo);
               
            refreshImages();
            
            % Activate playback
           
            if size(dicomBuffer('get'), 3) ~= 1
                setPlaybackToolbar('on');
            end
            
            setRoiToolbar('on');
            
        end
    
        if isempty(sFileName)

            progressBar(1, sprintf('Import of folder %s completed.', asMainDirectory{1}));
        else
            progressBar(1, sprintf('Import of series %s completed.', sFileName));
        end
    end

    catch
        progressBar(1, 'Error:loadDcmFile()');                        
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 

    if bInitDisplay == true    
    
        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');        
        mainToolBarEnable('on');
         
    end
end
