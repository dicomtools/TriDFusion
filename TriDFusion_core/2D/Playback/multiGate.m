function multiGate(mPlay)
%function multiGate(mPlay)
%Play 2D DICOM 4D Images.
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
        multiFramePlayback('set', false);  
        mPlay.State = 'off';
        return;
    end   

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput) || ...
       numel(tInput) < 2 % Need a least 2 series
        progressBar(1, 'Error: Require at least two 3D Volume!');               
        multiFramePlayback('set', false);  
        mPlay.State = 'off';                
        return;
    end

    if ~isfield(tInput(iSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        progressBar(1, 'Error: Require a 4D series!');       
        multiFramePlayback('set', false);  
        mPlay.State = 'off';                
        return;
    end

    lMinBak = windowLevel('get', 'min');
    lMaxBak = windowLevel('get', 'max');

    set(uiSeriesPtr('get'), 'Enable', 'off');

    pAxes3Text  = axesText('get', 'axes3');
    asAxes3Text = pAxes3Text.String;                                    

%            tOverlay = text(axes3, 0.02, 0.97, '', 'Units','normalized');

%            if strcmp(backgroundColor('get'), 'black')
%                tOverlay.Color = [0.9500 0.9500 0.9500];
%            else
%                tOverlay.Color = [0.1500 0.1500 0.1500];
%            end        
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
%         aBackup = dicomBuffer('get');


    while multiFramePlayback('get')                                  

        set(uiSeriesPtr('get'), 'Value', iOffset);

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

        if size(aCurrentBuffer) ~= size(aBuffer)
            progressBar(1, 'Error: Resample or Register the series!');     
            mPlay.State = 'off';
            multiFramePlayback('set', false);
            break;
        end

        atCoreMetaData = dicomMetaData('get'); 
        if isempty(atCoreMetaData)
            atCoreMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set', atCoreMetaData);
        end    

        if gateUseSeriesUID('get') == false && ...
           gateLookupTable('get') == true 
            if strcmpi(atCoreMetaData{1}.Modality, 'ct')
                [lMax, lMin] = computeWindowLevel(2000, 0);
            else  
                if strcmpi(gateLookupType('get'), 'Relative')                   
                    if strcmpi(atCoreMetaData{1}.Modality, 'pt')
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');                                
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
 %       if numel(tInput(iOffset).asFilesList) ~= 1
 %           if str2double(tInput(iOffset).atDicomInfo{2}.ImagePositionPatient(3)) - ...
 %              str2double(tInput(iOffset).atDicomInfo{1}.ImagePositionPatient(3)) > 0                    

 %                aBuffer = aBuffer(:,:,end:-1:1);                   
 %           end
 %       end    

        if overlayActivate('get') == true

%            pAxes3Text.Visible = 'off';                                    

            sSeriesDescription = atCoreMetaData{1}.SeriesDescription;

            if isVsplash('get') == true          
                [lFirst, lLast] = computeVsplashLayout(aBuffer, 'axial', size(aBuffer, 3)-sliceNumber('get', 'axial')+1);
                sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
            else
                sAxialSliceNumber  = num2str(size(aBuffer, 3)-sliceNumber('get', 'axial')+1);
            end

            if gateUseSeriesUID('get') == true                   
                sAxe3Text = sprintf('%s\nA:%s/%s', ...
                    sSeriesDescription, ...  
                    sAxialSliceNumber, ...
                    num2str(size(aBuffer, 3)));                        
            else
                sAxe3Text = sprintf('%s (Frame %d)\nA:%s/%s', ...
                    sSeriesDescription, ...  
                    iOffset, ...
                    sAxialSliceNumber, ...
                    num2str(size(aBuffer, 3)));  
            end

            if gca == axes3Ptr('get') && ...
               strcmp(windowButton('get'), 'down') && ...
               isVsplash('get') == false

                clickedPt = get(axes3Ptr('get'),'CurrentPoint');
                clickedPtX = round(clickedPt(1,1));

                if clickedPtX < 1 
                    clickedPtX = 1;                       
                end

                if clickedPtX > size(aBuffer, 2)
                    clickedPtX =  size(aBuffer, 2);
                end  

                clickedPtY = round(clickedPt(1,2));
                if clickedPtY < 1 
                    clickedPtY = 1;                       
                end

                if clickedPtY > size(aBuffer, 1)
                    clickedPtY =  size(aBuffer, 1);
                end 

                sAxe3Text = sprintf('%s\n[X,Y] %s,%s', ...
                    sAxe3Text, ...    
                    num2str(clickedPtX), ...
                    num2str(clickedPtY));
            end                    

            set(pAxes3Text, 'String', sAxe3Text);
            set(pAxes3Text, 'Color' , overlayColor('get'));
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
        pause(multiFrameSpeed('get'));
    end

    if isvalid(pAxes3Text)
        set(pAxes3Text, 'String', asAxes3Text);
    end
%           delete(tOverlay);

%       dicomBuffer('set', aBackup);     

    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get') == true     
        setWindowMinMax(lMaxBak, lMinBak);              
    end

    set(uiSeriesPtr('get'), 'Enable', 'on');

    refreshImages();                                         

end
