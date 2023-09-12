function export3DToSlicesCallback(~, ~)
%function  export3DToSlicesCallback(~, ~)
%Export a 3D object to multiple slices, tool is called from the main menu.
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

    if size(dicomBuffer('get'), 3) == 1
        progressBar(1, 'Error: Export require a 3D Volume!');  
        return;
    end 
    
    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false 
        progressBar(1, 'Error: Export require a 3D object!');  
        return;
    end   
    
    if multiFrame3DPlayback('get') == true || ...
       multiFrame3DRecord('get')   == true 
        progressBar(1, 'Error: Cant export while playback!');  
       return;
    end
                            
    dlgExport = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-360/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-130/2) ...
                            360 ...
                            130 ...
                            ],...
              'MenuBar', 'none',...
              'Resize', 'off', ...    
              'NumberTitle','off',...
              'MenuBar', 'none',...
              'Color', viewerBackgroundColor('get'), ...
              'Name', 'Export 3D Rendering',...
              'Toolbar','none'...   
               );  

     axeExport = ...
        axes(dlgExport, ...
             'Units'   , 'pixels', ...
             'Position', get(dlgExport, 'Position'), ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             ); 
     axeExport.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
     axeExport.Toolbar = [];

     uicontrol(dlgExport,...
              'style'   , 'text',...
              'string'  , 'Slice Thickness (mm):',...
              'horizontalalignment', 'left',...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...                   
              'position', [20 67 200 20]...
              );

    uicontrol(dlgExport,...
              'style'     , 'edit',...
              'Background', 'white',...
              'string'    , num2str(export3DSliceThickess('get')),...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...                 
              'position'  , [220 70 120 20], ...
              'Callback', @editExport3DSlicesThicknessCallback...
              ); 

     % Cancel or Proceed

     uicontrol(dlgExport,...
               'String','Cancel',...
               'Position',[265 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelExport3DToSlicesCallback...
               );

     uicontrol(dlgExport,...
              'String','Proceed',...
              'Position',[180 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @proceedExport3DToSlicesCallback...
              ); 
          

    function editExport3DSlicesThicknessCallback(hObject, ~)
        
        atDcmMetaData = dicomMetaData('get'); 
        
        dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

        aBufferSize = size(dicomBuffer('get'));

        dVolumeZsize = aBufferSize(3)*dcmSliceThickness;
        
        dExportThickness = str2double(get(hObject, 'String'));
                
        if dExportThickness < 0
            dExportThickness = 0;
        end
        
        if dExportThickness > dVolumeZsize
            dExportThickness = dVolumeZsize;
        end
        
        set(hObject, 'String', num2str(dExportThickness));
        
        export3DSliceThickess('set', dExportThickness);
              
    end

    function cancelExport3DToSlicesCallback(~, ~)  
        delete(dlgExport);        
    end
              
    function proceedExport3DToSlicesCallback(~, ~)
        
        try   
            
        delete(dlgExport);
   
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;
        
        is3DPanelActive = view3DPanel('get');
        if is3DPanelActive == true
            setView3DPanel();
        end

        filter = {'*.bmp';'*.jpg';'*.gif'};
        atDcmMetaData = dicomMetaData('get');

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'exportVolumeLastDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('exportVolumeLastDir', 'var')
                sCurrentDir = exportVolumeLastDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end

        [sFileName, sPathName, indx] = uiputfile(filter, 'Save Images', sprintf('%s/%s_%s_%s_3D_Slices_TriDFusion' , sCurrentDir, cleanString(atDcmMetaData{1}.PatientName), cleanString(atDcmMetaData{1}.PatientID), cleanString(atDcmMetaData{1}.SeriesDescription)) );
        
        if sFileName ~= 0

            try
                exportVolumeLastDir = sPathName;
                save(sMatFile, 'exportVolumeLastDir');
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
           
            exportMultiSlices3D(sPathName, sFileName, filter{indx}, export3DSliceThickess('get'));
                     
        end
        
        catch
            progressBar(1, 'Error:proceedExport3DToSlicesCallback()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
        
        if is3DPanelActive == true
            setView3DPanel();
        end
    end
end