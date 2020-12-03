function oneGate(sDirection)   
%function multiGate(mPlay)
%Dispay 2D DICOM 4D Images Previous or Next Gate.
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

    aCurrentBuffer = dicomBuffer('get');
    if size(aCurrentBuffer, 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');               
        return;
    end                

    tInput = inputTemplate('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput) || ...
        numel(tInput) < 2 % Need a least 2 series
        return;
    end

    if ~isfield(tInput(iSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true                        
        return
    end     

    set(uiSeriesPtr('get'), 'Enable', 'off');

    aInput = inputBuffer('get');                     

    if strcmpi(sDirection, 'Foward')
        iOffset = iSeriesOffset+1;  
        if gateUseSeriesUID('get') == true  
            if iOffset > numel(tInput) || ... % End of list
               ~strcmpi(tInput(iSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                               tInput(iSeriesOffset).atDicomInfo{1}.SeriesInstanceUID) 
                        iOffset = bb;
                        break;
                    end
                end                   
            end
        else
            if iOffset > numel(tInput)
                iOffset =1;
            end
        end
    else
        iOffset = iSeriesOffset-1; 

        if gateUseSeriesUID('get') == true                        
            if iOffset == 0 || ... % The list start at 1
               ~strcmpi(tInput(iSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID)

                bOffsetFound = false;
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                               tInput(iSeriesOffset).atDicomInfo{1}.SeriesInstanceUID) 
                        for cc=bb:numel(tInput) % Found the first frame
                            if cc >= numel(tInput) || ... % End of list
                               ~strcmpi(tInput(iSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the last frame
                                        tInput(cc).atDicomInfo{1}.SeriesInstanceUID)
                                iOffset = cc-1;
                                bOffsetFound = true;
                                break;  
                            end
                        end
                    end

                    if bOffsetFound == true
                        break
                    end

                end                   
            end  
        else
            if iOffset == 0
                iOffset = numel(tInput);
            end
        end
    end  

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
        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');
        progressBar(1, 'Error: Resample or Register the series fail!');               
        return;
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
                for jj=1:numel(aInput)
                    set(uiSeriesPtr('get'), 'Value', jj);
                    aBuffer = dicomBuffer('get');                                  
                    if isempty(aBuffer)  
                        aBuffer = aInput{jj};
                        if     strcmp(imageOrientation('get'), 'axial')
                            aBuffer = permute(aInput{iOffset}, [1 2 3]);
                        elseif strcmp(imageOrientation('get'), 'coronal') 
                            aBuffer = permute(aInput{iOffset}, [3 2 1]);    
                        elseif strcmp(imageOrientation('get'), 'sagittal')
                            aBuffer = permute(aInput{iOffset}, [3 1 2]);
                        end    
                        dicomBuffer('set', aBuffer);                      
                    end

                    if jj == 1
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');
                    else
                        lBufferMin = min(aBuffer, [], 'all');
                        lBufferMax = max(aBuffer, [], 'all');
                        if lBufferMin < lMin
                            lMin = lBufferMin;
                        end
                        if lBufferMax > lMax
                            lMax = lBufferMax;
                        end
                    end                                    
                end

                set(uiSeriesPtr('get'), 'Value', iOffset);

            end
        end
        setWindowMinMax(lMax, lMin);   
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
            if atCoreMetaData{2}.ImagePositionPatient(3) - ...
               atCoreMetaData{1}.ImagePositionPatient(3) > 0                    

                 aBuffer = aBuffer(:,:,end:-1:1);                   
            end
        else
            if strcmpi(atCoreMetaData{1}.PatientPosition, 'FFS')
                 aBuffer = aBuffer(:,:,end:-1:1);                   
            end                       
        end                 
end
        dicomBuffer('set', aBuffer);                      
    end 

if 1                                       
     if gateUseSeriesUID('get') == false

        if aspectRatio('get') == true

            atCoreMetaData = dicomMetaData('get');         

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
    set(uiSeriesPtr('get'), 'Enable', 'on');

    refreshImages();               

end
