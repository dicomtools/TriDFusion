function recordMultiGate(mRecord, sPath, sFileName, sExtention)
%function oneFrame(sDirection)
%Record 2D DICOM 4D Images.
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

    tInput = inputTemplate('get');

    aCurrentBuffer = dicomBuffer('get');
    if size(aCurrentBuffer, 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');               
        multiFrameRecord('set', false);  
        mRecord.State = 'off';
        return;
    end   

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput) || ...
       numel(tInput) < 2 % Need a least 2 series
        progressBar(1, 'Error: Require at least two 3D Volume!');               
        multiFrameRecord('set', false);  
        mRecord.State = 'off';           
        return;
    end

    if ~isfield(tInput(iSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        progressBar(1, 'Error: Require a 4D series!');       
        multiFrameRecord('set', false);  
        mRecord.State = 'off';           
        return
    end    
    
    lMinBak = windowLevel('get', 'min');
    lMaxBak = windowLevel('get', 'max');

    set(uiSeriesPtr('get'), 'Enable', 'off');

    switch gca
        case axes1Ptr('get')
            iLastSlice = size(dicomBuffer('get'), 1);  
            iCurrentSlice = sliceNumber('get', 'coronal');                        
             aAxe = axes1Ptr('get');         

        case axes2Ptr('get')
            iLastSlice = size(dicomBuffer('get'), 2);    
            iCurrentSlice = sliceNumber('get', 'sagittal');                         
            aAxe = axes2Ptr('get');   

        case axes3Ptr('get')
            iLastSlice = size(dicomBuffer('get'), 3);            
            iCurrentSlice = sliceNumber('get', 'axial');
            aAxe = axes3Ptr('get');   

        otherwise
            iLastSlice = size(dicomBuffer('get'), 3);            
            iCurrentSlice = sliceNumber('get', 'axial');
            aAxe = axes3Ptr('get');
    end  

    set(uiSliderSagPtr('get'), 'Visible', 'off');
    set(uiSliderCorPtr('get'), 'Visible', 'off');
    set(uiSliderTraPtr('get'), 'Visible', 'off');

    if aAxe == axes1Ptr('get')
        logoObj = logoObject('get');
        if ~isempty(logoObj)
            delete(logoObj);
            logoObject('set', '');
        end
    end

    if aAxe == axes3Ptr('get')
        set(uiSliderWindowPtr('get'), 'Visible', 'off');
        set(uiSliderLevelPtr('get') , 'Visible', 'off');
        set(uiColorbarPtr('get')   , 'Visible', 'off');  
        if isFusion('get')
            set(uiFusionSliderWindowPtr('get'), 'Visible', 'off');
            set(uiFusionSliderLevelPtr('get') , 'Visible', 'off');
            set(uiAlphaSliderPtr('get')       , 'Visible', 'off');                         
            set(uiFusionColorbarPtr('get')   , 'Visible', 'off');                         
        end
    end

    if overlayActivate('get') == true                    
        if     aAxe == axes1Ptr('get')
            pAxes1Text = axesText('get', 'axes1');
            pAxes1Text.Visible = 'off';                       
        elseif aAxe == axes2Ptr('get')
            pAxes2Text = axesText('get', 'axes2');
            pAxes2Text.Visible = 'off';                        
        else    
            pAxes3Text = axesText('get', 'axes3');
            pAxes3Text.Visible = 'off'; 
        end                   
    end

    if crossActivate('get') == true && ...
       isVsplash('get') == false

        if     aAxe == axes1Ptr('get')
            alAxes1Line = axesLine('get', 'axes1');
            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = 'off';
            end
        elseif aAxe == axes2Ptr('get')
            alAxes2Line = axesLine('get', 'axes2');
            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = 'off';
            end
        else    
            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = 'off';
            end    
        end                    
    end

    sLogo = sprintf('%s\n', 'TriDFusion');  
    tLogo = text(aAxe, 0.02, 0.03, sLogo, 'Units','normalized');
    if strcmp(backgroundColor('get'), 'black')
        tLogo.Color = [0.8500 0.8500 0.8500];
    else
        tLogo.Color = [0.1500 0.1500 0.1500];
    end  

    tOverlay = text(aAxe, 0.02, 0.97, '', 'Units','normalized');
    if strcmp(backgroundColor('get'), 'black')
        tOverlay.Color = [0.8500 0.8500 0.8500];
    else
        tOverlay.Color = [0.1500 0.1500 0.1500];
    end       

    if overlayActivate('get') == false
        set(tOverlay, 'Visible', 'off');
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

    aInput  = inputBuffer('get');                     
    iOffset = iSeriesOffset;

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get') == true && ...
       strcmpi(gateLookupType('get'), 'Absolute')

        for jj=1:numel(tInput)
            set(uiSeriesPtr('get'), 'Value', jj);
            aBuffer = dicomBuffer('get');                                  
            if isempty(aBuffer)  
                if     strcmp(imageOrientation('get'), 'axial')
                    aBuffer = permute(aInput{jj}, [1 2 3]);
                elseif strcmp(imageOrientation('get'), 'coronal') 
                    aBuffer = permute(aInput{jj}, [3 2 1]);    
                elseif strcmp(imageOrientation('get'), 'sagittal')
                    aBuffer = permute(aInput{jj}, [3 1 2]);
                end 
                dicomBuffer('set', aBuffer);
            end

            if jj == 1
                lAbsoluteMin = min(aBuffer, [], 'all');
                lAbsoluteMax = max(aBuffer, [], 'all');
            else
                lBufferMin = min(aBuffer, [], 'all');
                lBufferMax = max(aBuffer, [], 'all');
                if lBufferMin < lAbsoluteMin
                    lAbsoluteMin = lBufferMin;
                end
                if lBufferMax > lAbsoluteMax
                    lAbsoluteMax = lBufferMax;
                end
            end                                    
        end                            
    end 

    bWriteSucessfull = true;           
    for idx=1: iNbSeries

        if ~multiFrameRecord('get')
            break;
        end

        set(uiSeriesPtr('get'), 'Value', iOffset);
        atCoreMetaData = dicomMetaData('get'); 
        if isempty(atCoreMetaData)
            atCoreMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set',atCoreMetaData);
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
if 0
            if numel(atCoreMetaData) ~= 1

                if ~isempty(atCoreMetaData{1}.ImagePositionPatient)

                    if atCoreMetaData{2}.ImagePositionPatient(3) - ...
                       atCoreMetaData{1}.ImagePositionPatient(3) > 0
                        aBuffer = aBuffer(:,:,end:-1:1);                   

                    end
                end            
            else
                if strcmpi(atCoreMetaData{1}.PatientPosition, 'FFS')
                        aBuffer = aBuffer(:,:,end:-1:1);                   
                end
            end 
end                    
            dicomBuffer('set', aBuffer);                      
        end

        if size(aCurrentBuffer) ~= size(aBuffer)
            progressBar(1, 'Error: Resample or Register the series!');     
            multiFrameRecord('set', false);  
            bWriteSucessfull = false;
            mRecord.State = 'off';           
            break;
        end                

        if gateUseSeriesUID('get') == false && ...
           gateLookupTable('get') == true 
            if strcmpi(atCoreMetaData{1}.Modality, 'ct')
                if min(aBuffer, [], 'all') >= 0
                    lMin = min(aBuffer, [], 'all');
                    lMax = max(aBuffer, [], 'all');                 
                else
                    [lMax, lMin] = computeWindowLevel(2000, 0);
                end    
            else  
                if strcmpi(gateLookupType('get'), 'Relative')      
                    
                    sUnitDisplay = getSerieUnitValue(iOffset);                        

                    if strcmpi(sUnitDisplay, 'SUV')
                        tQuant = quantificationTemplate('get');                                
                        if tQuant.tSUV.dScale                
                            lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;  
                            lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;                        
                        else
                            lMin = min(aBuffer, [], 'all');
                            lMax = max(aBuffer, [], 'all');                     
                        end
                    else            
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');                    
                    end
                else
                    lMin = lAbsoluteMin;
                    lMax = lAbsoluteMax;
                end
            end
            setWindowMinMax(lMax, lMin); 
        end
if 1           

        if gateUseSeriesUID('get') == false

            if aspectRatio('get') == true

                if ~isempty(atCoreMetaData{1}.PixelSpacing)
                    x = atCoreMetaData{1}.PixelSpacing(1);
                    y = atCoreMetaData{1}.PixelSpacing(2);                                                   
                    z = computeSliceSpacing(atCoreMetaData);                   

                    if x == 0
                        x = 1;
                    end

                    if y == 0
                        y = 1;
                    end                    

                    if z == 0
                        z = x;
                    end
                else

                    x = computeAspectRatio('x', atCoreMetaData);
                    y = computeAspectRatio('y', atCoreMetaData);
                    z = 1;                      
                end

               if strcmp(imageOrientation('get'), 'axial') 
                    daspect(axes1Ptr('get'), [z x y]); 
                    daspect(axes2Ptr('get'), [z y x]); 
                    daspect(axes3Ptr('get'), [x y z]); 

               elseif strcmp(imageOrientation('get'), 'coronal') 
                    daspect(axes1Ptr('get'), [x y z]); 
                    daspect(axes2Ptr('get'), [y z x]); 
                    daspect(axes3Ptr('get'), [z x y]);       

                elseif strcmp(imageOrientation('get'), 'sagittal')  
                    daspect(axes1Ptr('get'), [y x z]); 
                    daspect(axes2Ptr('get'), [x z y]); 
                    daspect(axes3Ptr('get'), [z x y]);                                                                        
               end

            else
                x =1;
                y =1;
                z =1;

                daspect(axes1Ptr('get'), [z x y]); 
                daspect(axes2Ptr('get'), [z y x]); 
                daspect(axes3Ptr('get'), [x y z]);                    

                axis(axes1Ptr('get'), 'normal');
                axis(axes2Ptr('get'), 'normal');                    
                axis(axes3Ptr('get'), 'normal');   

            end

            aspectRatioValue('set', 'x', x);
            aspectRatioValue('set', 'y', y);
            aspectRatioValue('set', 'z', z);  
        end    
end                      
%        if numel(tInput(iOffset).asFilesList) ~= 1
%            if str2double(tInput(iOffset).atDicomInfo{2}.ImagePositionPatient(3)) - ...
%               str2double(tInput(iOffset).atDicomInfo{1}.ImagePositionPatient(3)) > 0                    

%                 aBuffer = aBuffer(:,:,end:-1:1);                   
%            end
%        end    

        if overlayActivate('get') == true

            if     aAxe == axes1Ptr('get')
                if isVsplash('get') == true 
                    [lFirst, lLast] = computeVsplashLayout(aBuffer, 'coronal', iCurrentSlice);
                    sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));  
                else
                    sSliceNb = sprintf('%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));  
                end

            elseif aAxe == axes2Ptr('get')

                if isVsplash('get') == true 
                   [lFirst, lLast] = computeVsplashLayout(aBuffer, 'sagittal', iCurrentSlice);
                   sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));  
               else
                    sSliceNb = sprintf('%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));  
                end
            else    

                if isVsplash('get') == true 
                    [lFirst, lLast] = computeVsplashLayout(aBuffer, 'axial', 1+iLastSlice-iCurrentSlice);
                    sSliceNb = sprintf('%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));  
                else                       
                    sSliceNb = sprintf('%s/%s', num2str(1+iLastSlice-iCurrentSlice), num2str(iLastSlice));  
                end
            end                      

            sAxeText = sprintf('\nFrame %d\n%s', ...
                iOffset, ...
                sSliceNb);                            

            set(tOverlay, 'String', sAxeText);                    
        end

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

        refreshImages();                                         
        

    
        I = getframe(aAxe);
        [indI,cm] = rgb2ind(I.cdata, 256);

        if idx == 1

            if strcmpi('*.gif', sExtention)     
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)  

                sDirName = sprintf('%s_%s_%s_JPG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) 
                sDirName = sprintf('%s_%s_%s_BMP_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');                        
            end
        else
            if strcmpi('*.gif', sExtention)     
                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)   
                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');
            elseif strcmpi('*.bmp', sExtention)   
                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');
            end                        
        end
        
        try
            tRefreshRoi = roiTemplate('get');
            if ~isempty(tRefreshRoi) 
                for bb=1:numel(tRefreshRoi)
                    if isvalid(tRefreshRoi{bb}.Object) 
                        tRefreshRoi{bb}.Object.Visible = 'off';
                    end
                end
            end  
        catch
        end
        progressBar(idx / iNbSeries, 'Recording', 'red');               


%           if gateUseSeriesUID('get') == true 
%               if iOffset == iSeriesOffset
%                   break
%               end
%           end

    end                  


    set(uiSliderSagPtr('get'), 'Visible', 'on');
    set(uiSliderCorPtr('get'), 'Visible', 'on');
    set(uiSliderTraPtr('get'), 'Visible', 'on');

    if aAxe == axes3Ptr('get')
        set(uiSliderWindowPtr('get'), 'Visible', 'on');
        set(uiSliderLevelPtr('get') , 'Visible', 'on');
        set(uiColorbarPtr('get')   , 'Visible', 'on');  
        if isFusion('get')
            set(uiFusionSliderWindowPtr('get'), 'Visible', 'on');
            set(uiFusionSliderLevelPtr('get') , 'Visible', 'on');
            set(uiAlphaSliderPtr('get')       , 'Visible', 'on');                         
            set(uiFusionColorbarPtr('get')   , 'Visible', 'on');                         
        end                    
    end

    if overlayActivate('get')                    
        if     aAxe == axes1Ptr('get')
            pAxes1Text = axesText('get', 'axes1');
            pAxes1Text.Visible = 'on';                       
        elseif aAxe == axes2Ptr('get')
            pAxes2Text = axesText('get', 'axes2');
            pAxes2Text.Visible = 'on';                        
        else    
            pAxes3Text = axesText('get', 'axes3');
            pAxes3Text.Visible = 'on'; 
        end                   
    end

    if crossActivate('get') == true  && ...
       isVsplash('get') == false

        if     aAxe == axes1Ptr('get')
            alAxes1Line = axesLine('get', 'axes1');
            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = 'on';
            end
        elseif aAxe == axes2Ptr('get')
            alAxes2Line = axesLine('get', 'axes2');
            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = 'on';
            end
        else    
            alAxes3Line = axesLine('get', 'axes3');
            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = 'on';
            end    
        end
    end                  

    delete(tLogo);
    delete(tOverlay);

    if aAxe == axes1Ptr('get')
        uiLogo = displayLogo(uiCorWindowPtr('get'));
        logoObject('set', uiLogo);
    end

    if bWriteSucessfull == true
        if strcmpi('*.gif', sExtention) 
            progressBar(1, sprintf('Write %s completed', sFileName));
        elseif strcmpi('*.jpg', sExtention) || ...
               strcmpi('*.bmp', sExtention)
            progressBar(1, sprintf('Write %d files to %s completed', iNbSeries, sImgDirName));
        end
    end
%          dicomBuffer('set', aBackup);                      
    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get') == true     
        setWindowMinMax(lMaxBak, lMinBak);              
    end

    set(uiSeriesPtr('get'), 'Enable', 'on');  

    refreshImages();              
end
