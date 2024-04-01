function recordMultiFrame3D(mRecord, sPath, sFileName, sExtention)
%function recordMultiFrame3D(mRecord, sPath, sFileName, sExtention)
%Record 3D Multi-Frame.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        progressBar(1, 'Error: Require a 3D Volume!');  
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;
    end             

    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    if strcmpi('*.dcm', sExtention) || ...
       strcmpi('dcm'  , sExtention)

        if isfield(atMetaData{1}, 'SeriesDescription')
            sSeriesDescription = atMetaData{1}.SeriesDescription;
        else
            sSeriesDescription = '';
        end

        sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MFSC-%s', sSeriesDescription));

        if isempty(sSeriesDescription)
            return;
        end
    end

    setFigureToobarsVisible('off');

    setFigureTopMenuVisible('off');

    volObj = volObject('get');
    isoObj = isoObject('get');                        
    mipObj = mipObject('get');            
    
    voiObj = voiObject('get');
    
    volFusionObj = volFusionObject('get');
    isoFusionObj = isoFusionObject('get');                        
    mipFusionObj = mipFusionObject('get'); 
    
    idxOffset = multiFrame3DIndex('get');

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

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    vec = linspace(0,2*pi(),120)';
    
    if ~isempty(mipObj)  
        aCameraUpVector = mipObj.CameraUpVector;
    end

    if ~exist('aCameraPosition','var') && ~isempty(volObj)
        
        aCameraUpVector = volObj.CameraUpVector;
    end
    
    if ~exist('aCameraPosition','var') && ~isempty(isoObj) 
       
        aCameraUpVector = isoObj.CameraUpVector;
    end
    
    if ~exist('aCameraPosition','var') && ~isempty(voiObj)      
        
        aCameraUpVector = voiObj{1}.CameraUpVector;
    end
    
    if     abs(aCameraUpVector(1)) > abs(aCameraUpVector(2)) && ...
           abs(aCameraUpVector(1)) > abs(aCameraUpVector(3))
   
        aCameraUpVector = [round(aCameraUpVector(1)) 0 0];

    elseif abs(aCameraUpVector(2)) > abs(aCameraUpVector(1)) && ...
           abs(aCameraUpVector(2)) > abs(aCameraUpVector(3))
   
        aCameraUpVector = [0 round(aCameraUpVector(2)) 0];
    else
        aCameraUpVector = [0 0 round(aCameraUpVector(3))];
    end
    
    for idx = 1:120

       if ~multiFrame3DRecord('get')

            multiFrame3DIndex('set', idxOffset);
            break;
       end
       
        if     abs(round(aCameraUpVector(1))) == 1

            myPosition = [zeros(size(vec)) multiFrame3DZoom('get')*sin(vec) multiFrame3DZoom('get')*cos(vec)];

        elseif abs(round(aCameraUpVector(2))) == 1   

            myPosition = [multiFrame3DZoom('get')*sin(vec) zeros(size(vec)) multiFrame3DZoom('get')*cos(vec)];           
        else
            myPosition = [multiFrame3DZoom('get')*cos(vec) multiFrame3DZoom('get')*sin(vec) zeros(size(vec))];
        end

        if ~isempty(mipObj)                    

            mipObj.CameraPosition = myPosition(idxOffset,:);            
            mipObj.CameraUpVector = aCameraUpVector;
        end

        if ~isempty(isoObj)                        

            isoObj.CameraPosition = myPosition(idxOffset,:);
            isoObj.CameraUpVector = aCameraUpVector;
        end

        if ~isempty(volObj)

            volObj.CameraPosition = myPosition(idxOffset,:);
            volObj.CameraUpVector = aCameraUpVector;
        end
        
        if ~isempty(mipFusionObj)                    

            mipFusionObj.CameraPosition = myPosition(idxOffset,:);  
            mipFusionObj.CameraUpVector = aCameraUpVector;
        end

        if ~isempty(isoFusionObj)                        

            isoFusionObj.CameraPosition = myPosition(idxOffset,:);
            isoFusionObj.CameraUpVector = aCameraUpVector;
        end

        if ~isempty(volFusionObj)

            volFusionObj.CameraPosition = myPosition(idxOffset,:);
            volFusionObj.CameraUpVector = aCameraUpVector;
        end
            
        if ~isempty(voiObj)

            for ff=1:numel(voiObj)
                voiObj{ff}.CameraPosition = myPosition(idxOffset,:);
                voiObj{ff}.CameraUpVector = aCameraUpVector;
            end
        end  

        idxOffset = idxOffset+1;

        if idxOffset >= 120
            idxOffset =1;
        end

        I = getframe(axePtr('get', [], get(uiSeriesPtr('get'), 'Value') ));
        [indI,cm] = rgb2ind(I.cdata, 256);

        if idx == 1

            if strcmpi('*.avi', sExtention) || ...
               strcmpi('avi'  , sExtention) || ...
               strcmpi('*.mp4', sExtention) || ...
               strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

            elseif strcmpi('*.gif', sExtention) || ...
                   strcmpi('gif'  , sExtention) 
           
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrame3DSpeed('get'));
                
            elseif strcmpi('*.jpg', sExtention) || ...
                   strcmpi('jpg'  , sExtention)
               
                sDirName = sprintf('%s_%s_%s_JPG_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention) 
               
                sDirName = sprintf('%s_%s_%s_BMP_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');   

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention) 
               
                sDirName = sprintf('%s_%s_%s_PNG_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png'); 

            elseif strcmpi('*.dcm', sExtention) || ...
                   strcmpi('dcm'  , sExtention)

                sDcmDirName = outputDir('get');

                if isempty(sDcmDirName)

                    sDirName = sprintf('%s_%s_%s_DCM_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sDirName = cleanString(sDirName);
                    sDcmDirName = [sPath sDirName '//'];
    
                    if~(exist(char(sDcmDirName), 'dir'))

                        mkdir(char(sDcmDirName));
                    end
                end

                cSeriesInstanceUID = dicomuid;

                sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', idx));

                objectToDicomMultiFrame(sOutFile, axePtr('get', [], dSeriesOffset), sSeriesDescription, cSeriesInstanceUID, idx, 120, dSeriesOffset);                
            end
        else
             if strcmpi('*.avi', sExtention) || ...
                strcmpi('avi'  , sExtention) || ...
                strcmpi('*.mp4', sExtention) || ...
                strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

             elseif strcmpi('*.gif', sExtention) || ...
                    strcmpi('gif'  , sExtention)       
           
                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrame3DSpeed('get'));
                
            elseif strcmpi('*.jpg', sExtention) || ...  
                   strcmpi('jpg'  , sExtention)       
              
                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');
                
            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention)
               
                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention)
               
                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'png');     

            elseif strcmpi('*.dcm', sExtention) || ...
                   strcmpi('dcm'  , sExtention)

                 sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', idx));

                 objectToDicomMultiFrame(sOutFile, axePtr('get', [], dSeriesOffset), sSeriesDescription, cSeriesInstanceUID, idx, 120, dSeriesOffset);                 
            end                        
        end                

        progressBar(idx / 120, 'Recording', 'red');

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

        progressBar(1, sprintf('Write %s completed', [sPath sFileName]));

    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('jpg'  , sExtention) || ...
           strcmpi('*.bmp', sExtention) || ...
           strcmpi('bmp'  , sExtention) || ...
           strcmpi('*.png', sExtention) || ...
           strcmpi('png'  , sExtention) 

        progressBar(1, sprintf('Write %d files to %s completed', 120, sImgDirName));

    elseif strcmpi('*.dcm', sExtention) || ...
           strcmpi('dcm'  , sExtention)

        progressBar(1, sprintf('Write %d files to %s completed', 120, sDcmDirName));
        
    end             
  
    catch
        progressBar(1, sprintf('Error: recordMultiFrame3D()'));
    end

    setFigureToobarsVisible('on');

    setFigureTopMenuVisible('on');

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end   
