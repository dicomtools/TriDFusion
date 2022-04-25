function exportMultiSlices3D(sPath, sFileName, sExtention, dThikness)
%function exportMultiSlices3D(sPath, sFileName, sExtention)
%Export a 3D object to multiple slices.
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
    
    sImgDirName = '';
    idx = 0;
    dNbSteps = 0;

    atDcmMetaData = dicomMetaData('get'); 

    volObj = volObject('get');
    isoObj = isoObject('get');                        
    mipObj = mipObject('get');            
    
    voiObj = voiObject('get');
    
    volFusionObj = volFusionObject('get');
    isoFusionObj = isoFusionObject('get');                        
    mipFusionObj = mipFusionObject('get');     

    if ~isempty(mipObj)  
        aCameraPosition = mipObj.CameraPosition;       
        aCameraUpVector = mipObj.CameraUpVector;
        aCameraTarget   = mipObj.CameraTarget;
    end

    if ~exist('aCameraPosition','var') && ...
       ~isempty(volObj) 
        aCameraPosition = volObj.CameraPosition;       
        aCameraUpVector = volObj.CameraUpVector;
        aCameraTarget   = volObj.CameraTarget;
    end
    
    if ~exist('aCameraPosition','var') && ...
       ~isempty(isoObj) 
        aCameraPosition = isoObj.CameraPosition;       
        aCameraUpVector = isoObj.CameraUpVector;
        aCameraTarget   = isoObj.CameraTarget;
    end
    
    if ~exist('aCameraPosition','var') && ...
       ~isempty(voiObj) 
        aCameraPosition = voiObj{1}.CameraPosition;       
        aCameraUpVector = voiObj{1}.CameraUpVector;
        aCameraTarget   = voiObj{1}.CameraTarget;        
    end    
    
    if switchTo3DMode('get') == true 
        if ~isempty(volObj)
            volObj.CameraPosition = [0 0 1];
            volObj.CameraUpVector = [0 1 0];
            volObj.CameraTarget   = [0 0 0];
        end
        
        if isFusion('get') == true
            if ~isempty(volFusionObj)
                volFusionObj.CameraPosition = [0 0 1];
                volFusionObj.CameraUpVector = [0 1 0];
                volFusionObj.CameraTarget   = [0 0 0];
            end            
        end        
    end
    
    if switchToMIPMode('get') == true 
        if ~isempty(mipObj)
            mipObj.CameraPosition = [0 0 1];
            mipObj.CameraUpVector = [0 1 0];
            mipObj.CameraTarget   = [0 0 0];
        end
        
        if isFusion('get') == true
            if ~isempty(mipFusionObj)
                mipFusionObj.CameraPosition = [0 0 1];
                mipFusionObj.CameraUpVector = [0 1 0];
                mipFusionObj.CameraTarget   = [0 0 0];
            end            
        end        
    end
    
    if switchToIsoSurface('get') == true 
        if ~isempty(isoObj)
            isoObj.CameraPosition = [0 0 1];
            isoObj.CameraUpVector = [0 1 0];
            isoObj.CameraTarget   = [0 0 0];
        end
        
        if isFusion('get') == true
            if ~isempty(isoFusionObj)
                isoFusionObj.CameraPosition = [0 0 1];
                isoFusionObj.CameraUpVector = [0 1 0];
                isoFusionObj.CameraTarget   = [0 0 0];
            end            
        end        
    end
    
    bDisplayVoi = displayVoi('get');
    if bDisplayVoi == true  % Close VOI     
        set(ui3DDispVoiPtr('get'), 'Value', false);
        display3DVoiCallback();
    end
 
    try
        dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

        aBufferSize = size(dicomBuffer('get'));

        dVolumeZsize = aBufferSize(3)*dcmSliceThickness;
        dNbSteps = round(dVolumeZsize/dThikness)-1;

        dBufferOffset = dThikness/dcmSliceThickness;

        for idx = 1:dNbSteps

            dFromOffset = idx * dBufferOffset;
            dToOffset   = (idx-1) * dBufferOffset;


            dFromComputed = aBufferSize(3)-dFromOffset;
            dToComputed = aBufferSize(3)-dToOffset;

            c = images.spatialref.Cuboid([1,aBufferSize(1)],[1,aBufferSize(2)],[dFromComputed,dToComputed]);
            croppedVolume = imcrop3(squeeze(dicomBuffer('get')),c);        
            if size(croppedVolume, 3) ==1
                croppedVolume = repmat(croppedVolume, 1, 1, 2);
            end

            if switchTo3DMode('get') == true 
                if ~isempty(volObj)          
                    setVolume(volObj, croppedVolume);
                end
            end

            if switchToMIPMode('get') == true 
                if ~isempty(mipObj)          
                    setVolume(mipObj, croppedVolume);
                end
            end

            if switchToIsoSurface('get') == true 
                if ~isempty(isoObj)          
                    setVolume(isoObj, croppedVolume);
                end
            end

            if isFusion('get') == true

                c = images.spatialref.Cuboid([1,aBufferSize(1)],[1,aBufferSize(2)],[dFromComputed,dToComputed]);
                croppedVolume = imcrop3(squeeze(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'))),c);

                if size(croppedVolume, 3) ==1
                    croppedVolume = repmat(croppedVolume, 1, 1, 2);
                end

                if switchTo3DMode('get') == true 

                    if ~isempty(volFusionObj)
                        setVolume(volFusionObj, croppedVolume);                
                    end
                end

                if switchToMIPMode('get') == true 
                    if ~isempty(mipFusionObj)          
                        setVolume(mipFusionObj, croppedVolume);
                    end
                end

                if switchToIsoSurface('get') == true 
                    if ~isempty(isoFusionObj)          
                        setVolume(isoFusionObj, croppedVolume);
                    end
                end            

            end               

            I = getframe(axePtr('get', [], get(uiSeriesPtr('get'), 'Value') ));
            [indI,cm] = rgb2ind(I.cdata, 256);

            if idx == 1

                if strcmpi('*.gif', sExtention) || ...
                   strcmpi('gif', sExtention) 

                    imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrame3DSpeed('get'));

                elseif strcmpi('*.jpg', sExtention) || ...
                       strcmpi('jpg', sExtention)

                    sDirName = sprintf('%s_%s_%s_JPG_3D', atDcmMetaData{1}.PatientName, atDcmMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sImgDirName = [sPath sDirName '//' ];

                    if~(exist(char(sImgDirName), 'dir'))
                        mkdir(char(sImgDirName));
                    end

                    newName = erase(sFileName, '.jpg');
                    newName = sprintf('%s-%d.jpg', newName, idx);
                    imwrite(indI, cm, [sImgDirName newName], 'jpg');

                elseif strcmpi('*.bmp', sExtention) || ...
                       strcmpi('bmp', sExtention) 

                    sDirName = sprintf('%s_%s_%s_BMP_3D', atDcmMetaData{1}.PatientName, atDcmMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sImgDirName = [sPath sDirName '//' ];

                    if~(exist(char(sImgDirName), 'dir'))
                        mkdir(char(sImgDirName));
                    end

                    newName = erase(sFileName, '.bmp');
                    newName = sprintf('%s-%d.bmp', newName, idx);
                    imwrite(indI, cm, [sImgDirName newName], 'bmp');                        
                end
            else
                if strcmpi('*.gif', sExtention) || ...
                   strcmpi('gif', sExtention)       

                    imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrame3DSpeed('get'));

                elseif strcmpi('*.jpg', sExtention) || ...  
                       strcmpi('jpg', sExtention)       

                    newName = erase(sFileName, '.jpg');
                    newName = sprintf('%s-%d.jpg', newName, idx);
                    imwrite(indI, cm, [sImgDirName newName], 'jpg');

                elseif strcmpi('*.bmp', sExtention) || ...
                       strcmpi('bmp', sExtention)

                    newName = erase(sFileName, '.bmp');
                    newName = sprintf('%s-%d.bmp', newName, idx);
                    imwrite(indI, cm, [sImgDirName newName], 'bmp');
                end                        
            end                

            progressBar(idx / dNbSteps, sprintf('Exporting slice %d/%d', idx , dNbSteps), 'red');

        end
    catch
    end
    
    if switchTo3DMode('get') == true 
        if ~isempty(volObj)            
            
            setVolume(volObj, dicomBuffer('get'));
            
            volObj.CameraPosition = aCameraPosition;
            volObj.CameraUpVector = aCameraUpVector;
            volObj.CameraTarget   = aCameraTarget;
        end
        
        if isFusion('get') == true
            if ~isempty(volFusionObj)
                
                setVolume(volFusionObj, fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                
                
                volFusionObj.CameraPosition = aCameraPosition;
                volFusionObj.CameraUpVector = aCameraUpVector;
                volFusionObj.CameraTarget   = aCameraTarget;                
            end
        end
    end
    
    if switchToMIPMode('get') == true 
        if ~isempty(mipObj)            
            
            setVolume(mipObj, dicomBuffer('get'));
            
            mipObj.CameraPosition = aCameraPosition;
            mipObj.CameraUpVector = aCameraUpVector;
            mipObj.CameraTarget   = aCameraTarget;

        end
        
        if isFusion('get') == true
            if ~isempty(mipFusionObj)
                
                setVolume(mipFusionObj, fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                
                
                mipFusionObj.CameraPosition = aCameraPosition;
                mipFusionObj.CameraUpVector = aCameraUpVector;
                mipFusionObj.CameraTarget   = aCameraTarget;                
            end
        end
    end
    
    if switchToIsoSurface('get') == true 
        if ~isempty(isoObj)       
            
            setVolume(isoObj, dicomBuffer('get'));
            
            isoObj.CameraPosition = aCameraPosition;
            isoObj.CameraUpVector = aCameraUpVector;
            isoObj.CameraTarget   = aCameraTarget;
        end
        
        if isFusion('get') == true
            if ~isempty(isoFusionObj)
                
                setVolume(isoFusionObj, fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                
                
                isoFusionObj.CameraPosition = aCameraPosition;
                isoFusionObj.CameraUpVector = aCameraUpVector;
                isoFusionObj.CameraTarget   = aCameraTarget;                
            end
        end
    end
    
    if bDisplayVoi == true  % Restore VOI  
        set(ui3DDispVoiPtr('get'), 'Value', true);
        display3DVoiCallback();
    end
        
    if strcmpi('*.gif', sExtention) || strcmpi('gif', sExtention )
        progressBar(1, sprintf('Write %s completed', sFileName));
    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('*.bmp', sExtention) || ...
           strcmpi('jpg', sExtention) || ...
           strcmpi('bmp', sExtention)            
        progressBar(1, sprintf('Write %d/%d files to %s completed', idx, dNbSteps, sImgDirName));
    end                          
end   
