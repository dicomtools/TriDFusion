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

    dSeriesOffset      = get(uiSeriesPtr('get'), 'Value');
    dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
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

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)
      
        if strcmpi('*.avi', sExtention) || ...
           strcmpi('avi', sExtention)

            tClassVideoWriter = VideoWriter([sPath sFileName], 'Motion JPEG AVI');

        else
            tClassVideoWriter = VideoWriter([sPath sFileName],  'MPEG-4');
        end

        tClassVideoWriter.FrameRate = 1/multiFrame3DSpeed('get');
        tClassVideoWriter.Quality = 100;

        open(tClassVideoWriter);
    end

    sImgDirName = '';
    idx = 0;
    dNbSteps = 0;

    atDcmMetaData = dicomMetaData('get', [], dSeriesOffset); 

    volObj = volObject('get');
    isoObj = isoObject('get');                        
    mipObj = mipObject('get');            
    
    voiObj = voiObject('get');
    
    volFusionObj = volFusionObject('get');
    isoFusionObj = isoFusionObject('get');                        
    mipFusionObj = mipFusionObject('get');  

    ptrViewer3d = viewer3dObject('get');

    if isempty(ptrViewer3d)
    
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
    else
        setFigureToobarsVisible('off');

        setFigureTopMenuVisible('off');

        drawnow;
        drawnow;

        aCameraPosition = ptrViewer3d.CameraPosition;       
        aCameraUpVector = ptrViewer3d.CameraUpVector;
        aCameraTarget   = ptrViewer3d.CameraTarget;

        set3DView(ptrViewer3d, 0, 90);                 
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
            croppedVolume = imcrop3(squeeze(dicomBuffer('get', [], dSeriesOffset)),c); 

            if size(croppedVolume, 3) == 1

                croppedVolume = repmat(croppedVolume, 1, 1, 3);
            elseif size(croppedVolume, 3) == 2

                croppedVolume = cat(3, croppedVolume, croppedVolume(:, :, 2)); % Duplicate the second slice
            end

            if switchTo3DMode('get') == true 

                if ~isempty(volObj)          
                                
                    if isempty(ptrViewer3d)

                        setVolume(volObj, croppedVolume);
                    else
                        volObj.Data = croppedVolume;
                    end
                end
            end

            if switchToMIPMode('get') == true 

                if ~isempty(mipObj)          
                    
                    if isempty(ptrViewer3d)

                        setVolume(mipObj, croppedVolume);
                    else
                        mipObj.Data = croppedVolume;
                    end

                end
            end

            if switchToIsoSurface('get') == true 

                if ~isempty(isoObj)          

                    if isempty(ptrViewer3d)
                    
                        setVolume(isoObj, croppedVolume);
                    else
                        isoObj.Data = croppedVolume;
                    end
                end
            end

            if isFusion('get') == true

                c = images.spatialref.Cuboid([1,aBufferSize(1)],[1,aBufferSize(2)],[dFromComputed,dToComputed]);
                croppedVolume = imcrop3(squeeze(fusionBuffer('get', [], dFusedSeriesOffset)),c);

                if size(croppedVolume, 3) == 1
    
                    croppedVolume = repmat(croppedVolume, 1, 1, 3);
                elseif size(croppedVolume, 3) == 2
    
                    croppedVolume = cat(3, croppedVolume, croppedVolume(:, :, 2)); % Duplicate the second slice
                end

                if switchTo3DMode('get') == true 

                    if ~isempty(volFusionObj)
                        
                        if isempty(ptrViewer3d)

                            setVolume(volFusionObj, croppedVolume);                
                        else
                            volFusionObj.Data = croppedVolume;
                        end
                    end
                end

                if switchToMIPMode('get') == true 

                    if ~isempty(mipFusionObj)          

                        if isempty(ptrViewer3d)
                        
                            setVolume(mipFusionObj, croppedVolume);
                        else
                            mipFusionObj.Data = croppedVolume;
                        end
                    end
                end

                if switchToIsoSurface('get') == true 

                    if ~isempty(isoFusionObj)          

                        if isempty(ptrViewer3d)
                        
                            setVolume(isoFusionObj, croppedVolume);
                        else
                            mipFusionObj.Data = isoFusionObj;
                        end
                    end
                end            

            end  

            if isempty(ptrViewer3d) % Old volshow
    
                I = getframe( axePtr('get', [], dSeriesOffset) );
                I = I.cdata;
            else
                set3DView(ptrViewer3d, 0, 90);                 

                I = getObjectFrame( axePtr('get', [], dSeriesOffset) );
            end

            if strcmpi('*.avi', sExtention) || ...
               strcmpi('avi'  , sExtention) || ...
               strcmpi('*.mp4', sExtention) || ...
               strcmpi('mp4'  , sExtention) || ...   
               strcmpi('*.gif', sExtention) || ...
               strcmpi('gif'  , sExtention) 

                if idx == 1 % We can't write different image size.
                    
                    aFirstImageSize = size(I);
                else
                    if ~isequal(size(I), aFirstImageSize)
        
                        I = imresize3(I, aFirstImageSize);
                    end
                end
            end

            [indI, cm] = rgb2ind(I, 256); % Convert to indexed image 

            if idx == 1

                if strcmpi('*.avi', sExtention) || ...
                   strcmpi('avi'  , sExtention) || ...
                   strcmpi('*.mp4', sExtention) || ...
                   strcmpi('mp4'  , sExtention)
    
                        writeVideo(tClassVideoWriter, I);
    
                elseif strcmpi('*.gif', sExtention) || ...
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

                elseif strcmpi('*.png', sExtention) || ...
                       strcmpi('png'  , sExtention) 
    
                    sDirName = sprintf('%s_%s_%s_PNG_2D', atDcmMetaData{1}.PatientName, atDcmMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sImgDirName = [sPath sDirName '//'];
    
                    if~(exist(char(sImgDirName), 'dir'))
    
                        mkdir(char(sImgDirName));
                    end
    
                    newName = erase(sFileName, '.png');
                    newName = sprintf('%s-%d.png', newName, idx);
    
                    imwrite(indI, cm, [sImgDirName newName], 'png');  

                end
            else
                 if strcmpi('*.avi', sExtention) || ...
                    strcmpi('avi'  , sExtention) || ...
                    strcmpi('*.mp4', sExtention) || ...
                    strcmpi('mp4'  , sExtention)
    
                     writeVideo(tClassVideoWriter, I);                

                 elseif strcmpi('*.gif', sExtention) || ...
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

                elseif strcmpi('*.png', sExtention) || ...
                       strcmpi('png'  , sExtention)
    
                    newName = erase(sFileName, '.png');
                    newName = sprintf('%s-%d.png', newName, idx);
                    imwrite(indI, cm, [sImgDirName newName], 'png');                     
                end                        
            end                

            progressBar(idx / dNbSteps, sprintf('Exporting slice %d/%d', idx , dNbSteps), 'red');

        end
        
    catch ME   
        logErrorToFile(ME);
        progressBar(1, 'Error:exportMultiSlices3D()');           
    end

    if isempty(ptrViewer3d)
    
        if switchTo3DMode('get') == true 

            if ~isempty(volObj)            
                
                setVolume(volObj, dicomBuffer('get', [], dSeriesOffset));
                
                volObj.CameraPosition = aCameraPosition;
                volObj.CameraUpVector = aCameraUpVector;
                volObj.CameraTarget   = aCameraTarget;
            end
            
            if isFusion('get') == true

                if ~isempty(volFusionObj) 
                    
                    setVolume(volFusionObj, fusionBuffer('get', [], dFusedSeriesOffset));                
                    
                    volFusionObj.CameraPosition = aCameraPosition;
                    volFusionObj.CameraUpVector = aCameraUpVector;
                    volFusionObj.CameraTarget   = aCameraTarget;                
                end
            end
        end
        
        if switchToMIPMode('get') == true 

            if ~isempty(mipObj)            
                
                setVolume(mipObj, dicomBuffer('get', [], dSeriesOffset));
                
                mipObj.CameraPosition = aCameraPosition;
                mipObj.CameraUpVector = aCameraUpVector;
                mipObj.CameraTarget   = aCameraTarget;
    
            end
            
            if isFusion('get') == true

                if ~isempty(mipFusionObj)
                    
                    setVolume(mipFusionObj, fusionBuffer('get', [], dFusedSeriesOffset));                
                    
                    mipFusionObj.CameraPosition = aCameraPosition;
                    mipFusionObj.CameraUpVector = aCameraUpVector;
                    mipFusionObj.CameraTarget   = aCameraTarget;                
                end
            end
        end
        
        if switchToIsoSurface('get') == true 

            if ~isempty(isoObj)       
                
                setVolume(isoObj, dicomBuffer('get', [], dSeriesOffset));
                
                isoObj.CameraPosition = aCameraPosition;
                isoObj.CameraUpVector = aCameraUpVector;
                isoObj.CameraTarget   = aCameraTarget;
            end
            
            if isFusion('get') == true

                if ~isempty(isoFusionObj)
                    
                    setVolume(isoFusionObj, fusionBuffer('get', [], dFusedSeriesOffset));                
                    
                    isoFusionObj.CameraPosition = aCameraPosition;
                    isoFusionObj.CameraUpVector = aCameraUpVector;
                    isoFusionObj.CameraTarget   = aCameraTarget;                
                end
            end
        end
    else

        ptrViewer3d.CameraPosition = aCameraPosition;
        ptrViewer3d.CameraUpVector = aCameraUpVector;
        ptrViewer3d.CameraTarget   = aCameraTarget;    

        if switchTo3DMode('get') == true 

            if ~isempty(volObj)            
                
                volObj.Data = dicomBuffer('get', [], dSeriesOffset);
            end
            
            if isFusion('get') == true

                if ~isempty(volFusionObj) 
                   
                    volFusionObj.Data = fusionBuffer('get', [], dFusedSeriesOffset);                             
                end
            end
        end
        
        if switchToMIPMode('get') == true 

            if ~isempty(mipObj)            
                
                mipObj.Data = dicomBuffer('get', [], dSeriesOffset);    
            end
            
            if isFusion('get') == true

                if ~isempty(mipFusionObj)

                    mipFusionObj.Data = fusionBuffer('get', [], dFusedSeriesOffset);                                            
                end
            end
        end
        
        if switchToIsoSurface('get') == true 

            if ~isempty(isoObj)       

                isoObj.Data = dicomBuffer('get', [], dSeriesOffset);    
            end
            
            if isFusion('get') == true

                if ~isempty(isoFusionObj)

                    isoFusionObj.Data = fusionBuffer('get', [], dFusedSeriesOffset);                                                           
                end
            end
        end      
    end

    if bDisplayVoi == true  % Restore VOI  

        set(ui3DDispVoiPtr('get'), 'Value', true);
        display3DVoiCallback();
    end

    if ~isempty(ptrViewer3d) % New volshow

        setFigureToobarsVisible('on');

        setFigureTopMenuVisible('on');  

        drawnow;
        drawnow;
    end

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...     
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)

        close(tClassVideoWriter);
    end

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention) || ...
       strcmpi('*.gif', sExtention) || ...
       strcmpi('gif'  , sExtention)       

        progressBar(1, sprintf('Write %s completed', sFileName));

    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('*.bmp', sExtention) || ...
           strcmpi('jpg', sExtention) || ...
           strcmpi('bmp', sExtention)            
        progressBar(1, sprintf('Write %d/%d files to %s completed', idx, dNbSteps, sImgDirName));
    end                          
end   
