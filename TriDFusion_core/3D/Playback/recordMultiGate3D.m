function recordMultiGate3D(mRecord, sPath, sFileName, sExtention)
%function recordMultiGate3D(mRecord, sPath, sFileName, sExtention)
%Record 3D DICOM 4D Images.
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

    if size(dicomBuffer('get'), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');  
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;
    end 

    volGateObj = volGateObject('get');                                
    isoGateObj = isoGateObject('get');                
    mipGateObj = mipGateObject('get');
    voiGateObj = voiGateObject('get');

    volIc = volICObject('get');
    mipIc = mipICObject('get');
    volFusionIc = volICFusionObject('get');
    mipFusionIc = mipICFusionObject('get');
    
    volObjBak  = volObject('get');                      
    isoObjBak  = isoObject('get');                                       
    mipObjBak  = mipObject('get');      
    
    if isFusion('get') == true
        tFuseInput     = inputTemplate('get');
        iFuseOffset    = get(uiFusedSeriesPtr('get'), 'Value');   
        atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;                      
    end
    
    volGateFusionObj = volGateFusionObject('get');                                
    isoGateFusionObj = isoGateFusionObject('get');                
    mipGateFusionObj = mipGateFusionObject('get');        

    volFusionObjBak  = volFusionObject('get');                      
    isoFusionObjBak  = isoFusionObject('get');                                       
    mipFusionObjBak  = mipFusionObject('get');
    
    voiObjBak = voiObject('get');            

%       aBackup = dicomBuffer('get');
    aInput  = inputBuffer('get');                     

    tInput = inputTemplate('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput) || ...
       numel(tInput) < 2 % Need a least 2 series
        progressBar(1, 'Error: Require at least two 3D Volume!');  
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;           
    end

    if ~isfield(tInput(iSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        progressBar(1, 'Error: Require a dynamic 3D Volume!');  
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;
    end

    if gateUseSeriesUID('get') == true                        
        iOffset = iSeriesOffset;

        for idx=1: numel(tInput) 

            iOffset = iOffset+1;

            if iOffset > numel(tInput) || ... % End of list
               ~strcmpi(tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID) 
                        iOffset = bb;
                        break;
                    end

                end                   
            end 
            if iOffset == iSeriesOffset
                iNbSeries = idx;
                break
            end
        end
    else
        iNbSeries = numel(tInput);
    end

    set(btn3DPtr('get')        , 'Enable', 'off');                        
    set(btnIsoSurfacePtr('get'), 'Enable', 'off');                        
    set(btnMIPPtr('get')       , 'Enable', 'off'); 
    
    if isFusion('get') == true
        set(btnFusionPtr('get'), 'Enable', 'off');             
    end
    
    set(uiOneWindowPtr('get'), 'Visible', 'off');       

    ui3DGateWindow = ui3DGateWindowObject('get');

    if isempty(ui3DGateWindow)
        for tt=1:iNbSeries
            if view3DPanel('get') == false
                ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                      'Units'   , 'pixels',...
                                      'BorderWidth', showBorder('get'),...
                                      'HighlightColor', [0 1 1],...
                                      'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                                      'position', [0 ...
                                                   addOnWidth('get')+30 ...
                                                   getMainWindowSize('xsize')-280 ...
                                                   getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30]);
            else
                ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                      'Units'   , 'pixels',...
                                      'BorderWidth', showBorder('get'),...
                                      'HighlightColor', [0 1 1],...
                                      'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                                      'position', [680 ...
                                                   addOnWidth('get')+30 ...
                                                   getMainWindowSize('xsize')-680 ...
                                                   getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30]);
            end
            ui3DWindow{tt}.Visible = 'off';                      
        end  

    end

    if isempty(ui3DGateWindow)
        ui3DGateWindowObject('set', ui3DWindow);
    else
        ui3DWindow = ui3DGateWindow;
    end             

    ui3DLogo = ui3DLogoObject('get');
    if ~isempty(ui3DLogo)
        for tt=1:numel(ui3DLogo)
            delete(ui3DLogo{tt});
        end
    end

    for tt=1:iNbSeries
        ui3DLogo{tt} = displayLogo(ui3DWindow{tt});
    end            
    ui3DLogoObject('set', ui3DLogo);

    uiVolColorbar = volColorObject('get');                                           
    if ~isempty(uiVolColorbar)
        delete(uiVolColorbar);
    end                          
    volColorObject('set', '');   

    uiMipColorbar = mipColorObject('get');                               
    if ~isempty(uiMipColorbar)
        delete(uiMipColorbar);
    end
    mipColorObject('set', '');            

    for tt=1:iNbSeries
        if displayVolColorMap('get') == true && ...
           switchTo3DMode('get') == true
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion 
                ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolFusionOffset('get')));
            else
                ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolOffset('get')));
            end
            volColorObject('set', ui3DVolColorbar{tt});  
        end    
    end

    if displayVolColorMap('get') == false || ...
       switchTo3DMode('get') == false

        ui3DVolColorbar = '';
        volColorObject('set', '');  
    end

    for tt=1:iNbSeries
        if displayMIPColorMap('get') == true && ...
           switchToMIPMode('get') == true
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion 
                ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipFusionOffset('get')));                
            else
                ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipOffset('get')));                
            end
            mipColorObject('set', ui3DMipColorbar{tt});  
        end
    end

    if displayMIPColorMap('get') == false || ...
       switchToMIPMode('get') == false
        ui3DMipColorbar = '';
        mipColorObject('set', '');  
    end                                   

    dNbSurface = 0;
    if switchToMIPMode('get') == true    
        dNbSurface = dNbSurface+1;
    end

    if switchToIsoSurface('get') == true
        dNbSurface = dNbSurface+1;
    end

    if switchTo3DMode('get') == true    
        dNbSurface = dNbSurface+1;
    end

    iOffset = iSeriesOffset;          
    for tt=1:iNbSeries

        set(uiSeriesPtr('get'), 'Value', iOffset);
        atCoreMetaData = dicomMetaData('get'); 
        if isempty(atCoreMetaData)
            atCoreMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set', atCoreMetaData);
        end     

        aBuffer = dicomBuffer('get');
        if isempty(aBuffer)
            if     strcmp(imageOrientation('get'), 'axial')
                aBuffer = permute(aInput{iOffset}, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal') 
                aBuffer = permute(aInput{iOffset}, [3 2 1]);    
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aBuffer = permute(aInput{iOffset}, [3 1 2]);
            end        
                  
            dicomBuffer('set', aBuffer);

        end 

        for dPriorityLoop=1:3
            
            if switchToMIPMode('get') == true   
                
                dPriority = surface3DPriority('get', 'MaximumIntensityProjection');
                                
                if isempty(mipGateObj)&&(dPriority == dPriorityLoop)
                    mipObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'MaximumIntensityProjection', atCoreMetaData);               
                    if isFusion('get') == true
                        if isempty(mipGateFusionObj)
                            mipFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'MaximumIntensityProjection', atFuseMetaData);
                        end
                    end                      
                end                
                
            end

            if switchToIsoSurface('get') == true   
                
                dPriority = surface3DPriority('get', 'Isosurface');                        
                
                if isempty(isoGateObj) &&(dPriority == dPriorityLoop)                   
                    isoObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'Isosurface', atCoreMetaData);
                    if isFusion('get') == true
                        if isempty(isoGateFusionObj)
                            isoFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'Isosurface', atFuseMetaData);
                        end
                    end                    
                end
            end

            if switchTo3DMode('get') == true    
                
                dPriority = surface3DPriority('get', 'VolumeRendering');                                                
                
                if isempty(volGateObj) &&(dPriority == dPriorityLoop)                                       
                    volObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'VolumeRendering', atCoreMetaData);   
                    if isFusion('get') == true
                        if isempty(volGateFusionObj)
                            volFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'VolumeRendering', atFuseMetaData);
                        end
                    end                       
                end
            end  

        end

        if isempty(voiGateObj)
            if isfield(tInput(iOffset), 'tVoi')
                voiTemplate('set', tInput(iOffset).tVoi);             
                voiGate{iOffset} = initVoiIsoSurface(ui3DWindow{tt});                         
            else
                voiGate{iOffset} = '';
            end                 
        end

        set(ui3DWindow{tt}, 'Visible', 'off');

        iOffset = iOffset+1;

        if gateUseSeriesUID('get') == true                        

            if iOffset > numel(tInput) || ... % End of list
               ~strcmpi(tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID) 
                        iOffset = bb;
                        break;
                    end

                end                   
            end  
        else
            if iOffset > numel(tInput)
                iOffset = 1;
            end
        end

        progressBar(tt / iNbSeries, 'Initializing surface', 'red');

    end

    if isempty(voiGateObj)           
        voiGateObject('set', voiGate); 
    else
        voiGate = voiGateObj; 
    end
    if switchToMIPMode('get') == true  
        
        if isempty(mipGateObj)                                                        
            mipGateObject('set', mipObj);
        else
            mipObj = mipGateObj;                    
        end
        
        if isFusion('get') == true
            if isempty(mipGateFusionObj)                                                        
                mipGateFusionObject('set', mipFusionObj);
            else
                mipFusionObj = mipGateFusionObj;                    
            end            
        end

        dCameraViewAngle = mipObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        aScaleFactors    = mipObjBak.ScaleFactors;                
        aBackgroundColor = mipObjBak.BackgroundColor; 
        aPosition        = mipObjBak.CameraPosition;
        aUpVector        = mipObjBak.CameraUpVector;        
        aMipAlphamap     = mipObjBak.Alphamap;
        aMipColormap     = mipObjBak.Colormap; 
        
        if isFusion('get') == true
            aMipFusionAlphamap = mipFusionObjBak.Alphamap;
            aMipFusionColormap = mipFusionObjBak.Colormap;             
        else
            if ~isempty(mipGateFusionObj)                    
                aZeros = zeros(256,1);                    
                for tt=1:numel(mipGateFusionObj)                
                    mipGateFusionObj{tt}.Alphamap = aZeros;
                end
            end             
        end
        
        for tt=1:numel(mipObj)                
            mipObj{tt}.ScaleFactors    = aScaleFactors;
            mipObj{tt}.BackgroundColor = aBackgroundColor;
            mipObj{tt}.CameraPosition  = aPosition;
            mipObj{tt}.CameraUpVector  = aUpVector;
            mipObj{tt}.Alphamap        = aMipAlphamap;
            mipObj{tt}.Colormap        = aMipColormap;    
            
            if isFusion('get') == true
                mipFusionObj{tt}.ScaleFactors    = aScaleFactors;
                mipFusionObj{tt}.BackgroundColor = aBackgroundColor;
                mipFusionObj{tt}.CameraPosition  = aPosition;
                mipFusionObj{tt}.CameraUpVector  = aUpVector;
                mipFusionObj{tt}.Alphamap        = aMipFusionAlphamap;
                mipFusionObj{tt}.Colormap        = aMipFusionColormap;                
            end

        end
    else    
        if ~isempty(mipGateObj)                    
            aZeros = zeros(256,1);                    
            for tt=1:numel(mipGateObj)                
                mipGateObj{tt}.Alphamap = aZeros;
            end
        end
        
        if ~isempty(mipGateFusionObj)                    
            aZeros = zeros(256,1);                    
            for tt=1:numel(mipGateFusionObj)                
                mipGateFusionObj{tt}.Alphamap = aZeros;
            end
        end            
    end

    if switchToIsoSurface('get') == true    
        
        if isempty(isoGateObj)                                                                        
            isoGateObject('set', isoObj);
        else
            isoObj = isoGateObj;
        end

        if isFusion('get') == true
            if isempty(isoGateFusionObj)                                                                        
                isoGateFusionObject('set', isoFusionObj);
            else
                isoFusionObj = isoGateFusionObj;
            end            
        end
        
        dCameraViewAngle = isoObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        aScaleFactors    = isoObjBak.ScaleFactors;                
        aBackgroundColor = isoObjBak.BackgroundColor; 
        aPosition        = isoObjBak.CameraPosition;
        aUpVector        = isoObjBak.CameraUpVector;
        aIsovalue        = isoObjBak.Isovalue;
        aIsosurfaceColor = isoObjBak.IsosurfaceColor; 
        
        if isFusion('get') == true
            aFusionIsovalue        = isoFusionObjBak.Isovalue;
            aFusionIsosurfaceColor = isoFusionObjBak.IsosurfaceColor;         
        else
             aFusionIsovalue = 1;           
        end                                                             

        for tt=1:numel(isoObj)                
            isoObj{tt}.ScaleFactors    = aScaleFactors;
            isoObj{tt}.BackgroundColor = aBackgroundColor;
            isoObj{tt}.CameraPosition  = aPosition;
            isoObj{tt}.CameraUpVector  = aUpVector;
            isoObj{tt}.Isovalue        = aIsovalue;
            isoObj{tt}.IsosurfaceColor = aIsosurfaceColor;   
            if isFusion('get') == true
                isoFusionObj{tt}.ScaleFactors    = aScaleFactors;
                isoFusionObj{tt}.BackgroundColor = aBackgroundColor;
                isoFusionObj{tt}.CameraPosition  = aPosition;
                isoFusionObj{tt}.CameraUpVector  = aUpVector;
                isoFusionObj{tt}.Isovalue        = aFusionIsovalue;
                isoFusionObj{tt}.IsosurfaceColor = aFusionIsosurfaceColor;                  
            end

        end
    else
        if ~isempty(isoGateObj)                    
            for tt=1:numel(isoGateObj)                
                isoGateObj{tt}.Isovalue = 1;
            end
        end  
        
        if ~isempty(isoGateFusionObj)                    
            for tt=1:numel(isoGateFusionObj)                
                isoGateFusionObj{tt}.Isovalue = 1;
            end
        end          
    end

    if switchTo3DMode('get') == true    
        if isempty(volGateObj)                                                                                        
            volGateObject('set', volObj);
        else
            volObj = volGateObj;
        end  
        
        if isFusion('get') == true
            if isempty(volGateFusionObj)                                                                                        
                volGateFusionObject('set', volFusionObj);
            else
                volFusionObj = volGateFusionObj;
            end              
        end

        dCameraViewAngle = volObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        aScaleFactors = volObjBak.ScaleFactors;                
        aBackgroundColor = volObjBak.BackgroundColor; 

        aPosition = volObjBak.CameraPosition;
        aUpVector = volObjBak.CameraUpVector;

        aVolAlphamap = volObjBak.Alphamap;
        aVolColormap = volObjBak.Colormap; 
        
        if isFusion('get') == true
            aVolFusionAlphamap = volFusionObjBak.Alphamap;
            aVolFusionColormap = volFusionObjBak.Colormap;     
        else
            if ~isempty(volGateFusionObj)                    
                aZeros = zeros(256,1);                    
                for tt=1:numel(volGateFusionObj)                
                    volGateFusionObj{tt}.Alphamap = aZeros;
                end
            end             
        end
        
        for tt=1:numel(volObj)                
            volObj{tt}.ScaleFactors = aScaleFactors;
            volObj{tt}.BackgroundColor = aBackgroundColor;

            volObj{tt}.CameraPosition = aPosition;
            volObj{tt}.CameraUpVector = aUpVector;

            volObj{tt}.Alphamap = aVolAlphamap;
            volObj{tt}.Colormap = aVolColormap;  
            if isFusion('get') == true
                volFusionObj{tt}.ScaleFactors = aScaleFactors;
                volFusionObj{tt}.BackgroundColor = aBackgroundColor;

                volFusionObj{tt}.CameraPosition = aPosition;
                volFusionObj{tt}.CameraUpVector = aUpVector;

                volFusionObj{tt}.Alphamap = aVolFusionAlphamap;
                volFusionObj{tt}.Colormap = aVolFusionColormap;                  
            end
        end
    else
        if ~isempty(volGateObj)                    
            aZeros = zeros(256,1);                    
            for tt=1:numel(volGateObj)                
                volGateObj{tt}.Alphamap = aZeros;
            end
        end
        
        if ~isempty(volGateFusionObj)                    
            aZeros = zeros(256,1);                    
            for tt=1:numel(volGateFusionObj)                
                volGateFusionObj{tt}.Alphamap = aZeros;
            end
        end        
    end     

    if ~isempty(voiGate)
         for tt=1:numel(voiGate)   
            if ~isempty(voiGate{tt})
                for ll=1:numel(voiGate{tt})      
                    if displayVoi('get') == true  
                        set(voiGate{tt}{ll}, 'Renderer', 'Isosurface');
                    else
                        set(voiGate{tt}{ll}, 'Renderer', 'LabelOverlayRendering');
                    end               
                end
             end
         end
    end             

    progressBar(1, 'Ready');

    for tt=1:iNbSeries
       if ~multiFrame3DRecord('get')
            break;
       end    

       set(uiSeriesPtr('get'), 'Value', tt);
       atCoreMetaData = dicomMetaData('get'); 
       if isempty(atCoreMetaData)
           atCoreMetaData = tInput(iOffset).atDicomInfo;
           dicomMetaData('set',atCoreMetaData);
       end 

        set(ui3DWindow{tt}, 'Visible', 'on');               

        I = getframe(axePtr('get'));
        [indI,cm] = rgb2ind(I.cdata, 256);
        if tt == 1

            if strcmpi('*.gif', sExtention)     
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrame3DSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)  

                sDirName = sprintf('%s_%s_%s_JPG_3D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) 
                sDirName = sprintf('%s_%s_%s_BMP_3D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');                        
            end
        else
            if strcmpi('*.gif', sExtention)     
                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrame3DSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)   
                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');
            elseif strcmpi('*.bmp', sExtention)   
                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');
            end                        
        end

        set(ui3DWindow{tt}, 'Visible', 'off');

        progressBar(tt / iNbSeries, 'Recording', 'red');

    end

    if ~isempty(ui3DVolColorbar)
        for oo=1:numel(ui3DVolColorbar)                            
            delete(ui3DVolColorbar{oo});
        end
        volColorObject('set', '');                
    end 

    if ~isempty(ui3DMipColorbar)
        for oo=1:numel(ui3DMipColorbar)                                                        
            delete(ui3DMipColorbar{oo});
        end
        mipColorObject('set', '');                
    end  

    for tt=1:numel(ui3DWindow)
        set(ui3DWindow{tt}, 'Visible', 'off');                   
    end

    if switchTo3DMode('get') == true
        
        volObjBak.ScaleFactors    = aScaleFactors;
        volObjBak.BackgroundColor = aBackgroundColor; 
        volObjBak.CameraPosition  = aPosition;
        volObjBak.CameraUpVector  = aUpVector;
        volObjBak.CameraViewAngle = dCameraViewAngle;
        volObjBak.Alphamap        = aVolAlphamap;
        volObjBak.Colormap        = aVolColormap;                
        
        volObject('set', volObjBak);               
       
        if isFusion('get') == true
            volFusionObjBak.ScaleFactors    = aScaleFactors;
            volFusionObjBak.BackgroundColor = aBackgroundColor; 
            volFusionObjBak.CameraPosition  = aPosition;
            volFusionObjBak.CameraUpVector  = aUpVector;   
            volFusionObjBak.CameraViewAngle = dCameraViewAngle;
            volFusionObjBak.Alphamap        = aVolFusionAlphamap;
            volFusionObjBak.Colormap        = aVolFusionColormap;    
            
            volFusionObject('set', volFusionObjBak); 
        end
        
        if ~isempty(volIc)
            volIc.surfObj = volObjBak;
            volICObject('set', volIc); 
        end
        
        if ~isempty(volFusionIc)
            volFusionIc.surfObj = volFusionObjBak;
            volICFusionObject('set', volFusionIc); 
        end              

    end     

    if switchToMIPMode('get') == true
        
        mipObjBak.ScaleFactors    = aScaleFactors;
        mipObjBak.BackgroundColor = aBackgroundColor; 
        mipObjBak.CameraPosition  = aPosition;
        mipObjBak.CameraUpVector  = aUpVector;   
        mipObjBak.CameraViewAngle = dCameraViewAngle;
        mipObjBak.Alphamap        = aMipAlphamap;
        mipObjBak.Colormap        = aMipColormap;                
        
        if isFusion('get') == true
            mipFusionObjBak.ScaleFactors    = aScaleFactors;
            mipFusionObjBak.BackgroundColor = aBackgroundColor; 
            mipFusionObjBak.CameraPosition  = aPosition;
            mipFusionObjBak.CameraUpVector  = aUpVector;   
            mipFusionObjBak.CameraViewAngle = dCameraViewAngle;
            mipFusionObjBak.Alphamap        = aMipFusionAlphamap;
            mipFusionObjBak.Colormap        = aMipFusionColormap;    
            
            mipFusionObject('set', mipFusionObjBak); 
        end
        
        mipObject('set', mipObjBak); 
        
        if ~isempty(mipIc)
            mipIc.surfObj = mipObjBak;
            mipICObject('set', mipIc); 
        end
        
        if ~isempty(mipFusionIc)
            mipFusionIc.surfObj = mipFusionObjBak;
            mipICFusionObject('set', mipFusionIc); 
        end   

    end

    if switchToIsoSurface('get') == true          
        
        isoObjBak.ScaleFactors    = aScaleFactors;
        isoObjBak.BackgroundColor = aBackgroundColor; 
        isoObjBak.CameraPosition  = aPosition;
        isoObjBak.CameraUpVector  = aUpVector;
        isoObjBak.CameraViewAngle = dCameraViewAngle;
        isoObjBak.Isovalue        = aIsovalue;
        isoObjBak.IsosurfaceColor = aIsosurfaceColor; 

        isoObject('set', isoObjBak);
        
        if isFusion('get') == true
            isoFusionObjBak.ScaleFactors    = aScaleFactors;
            isoFusionObjBak.BackgroundColor = aBackgroundColor; 
            isoFusionObjBak.CameraPosition  = aPosition;
            isoFusionObjBak.CameraUpVector  = aUpVector;
            isoFusionObjBak.CameraViewAngle = dCameraViewAngle;
            isoFusionObjBak.Isovalue        = aFusionIsovalue;
            isoFusionObjBak.IsosurfaceColor = aFusionIsosurfaceColor; 

            isoFusionObject('set', isoFusionObjBak);            
        end
    end   

    if displayVolColorMap('get') == true && ...   
       switchTo3DMode('get') == true
   
        if isFusion('get') == true && ...
           get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion 
            uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolFusionOffset('get')) );
        else               
            uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
        end
        volColorObject('set', uivolColorbar);                               
    end    
        
    if displayMIPColorMap('get') == true && ...
        switchToMIPMode('get') == true  
        if isFusion('get') == true && ...
           get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion 
            uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipFusionOffset('get')));
        else
            uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
        end
        mipColorObject('set', uimipColorbar);                
    end    

        
    if ~isempty(voiObjBak)   
        for ll=1:numel(voiObjBak)                        
            set(voiObjBak{ll}, 'CameraPosition', aPosition);
            set(voiObjBak{ll}, 'CameraUpVector', aUpVector);
            set(voiObjBak{ll}, 'BackgroundColor',aBackgroundColor);              
        end   

        voiObject  ('set', voiObjBak);  
    end

    set(uiOneWindowPtr('get'), 'Visible', 'on');                     

%        dicomBuffer('set', aBackup);

    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

    set(btn3DPtr('get')        , 'Enable', 'on');                        
    set(btnIsoSurfacePtr('get'), 'Enable', 'on');                        
    set(btnMIPPtr('get')       , 'Enable', 'on');     

    if isFusion('get') == true
        set(btnFusionPtr('get'), 'Enable', 'on');             
    end        
    
    if strcmpi('*.gif', sExtention) 
        progressBar(1, sprintf('Write %s completed', sFileName));
    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('*.bmp', sExtention)
        progressBar(1, sprintf('Write %d files to %s completed', iNbSeries, sImgDirName));
    end             
end
