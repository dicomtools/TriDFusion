function recordMultiFrame(mRecord, sPath, sFileName, sExtention)
%function recordMultiFrame(mRecord, sPath, sFileName, sExtention)
%Record 2D Frames.
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
        multiFrameRecord('set', false);                
        mRecord.State = 'off';
        return;
    end 

    atCoreMetaData = dicomMetaData('get');

    if gca == axes1Ptr('get') || ...
       (isVsplash('get') == true && ...
        strcmpi(vSplahView('get'), 'coronal'))

        iLastSlice = size(dicomBuffer('get'), 1);  
        iCurrentSlice = sliceNumber('get', 'coronal');                        
         aAxe = axes1Ptr('get');                 

    elseif gca == axes2Ptr('get') || ...
       (isVsplash('get') == true && ...
        strcmpi(vSplahView('get'), 'sagittal'))
        iLastSlice = size(dicomBuffer('get'), 2);    
        iCurrentSlice = sliceNumber('get', 'sagittal');                         
        aAxe = axes2Ptr('get');   

    else
        iLastSlice = size(dicomBuffer('get'), 3);            
        iCurrentSlice = sliceNumber('get', 'axial');
        aAxe = axes3Ptr('get');
    end

    set(uiSliderSagPtr('get'), 'Visible', 'off');
    set(uiSliderCorPtr('get'), 'Visible', 'off');
    set(uiSliderTraPtr('get'), 'Visible', 'off');
if 0
    if aAxe == axes1Ptr('get')
        logoObj = logoObject('get');
        if ~isempty(logoObj)
            delete(logoObj);
            logoObject('set', '');
        end
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

    iSavedCurrentSlice = iCurrentSlice;

    for idx = 1:iLastSlice

        if ~multiFrameRecord('get')
            break;
        end

        if     aAxe == axes1Ptr('get')
            sliceNumber('set', 'coronal', iCurrentSlice); 
            if isVsplash('get') == true    
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'coronal', iCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));                        
            else                    
                sSliceNb = sprintf('\n%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));  
            end

        elseif aAxe == axes2Ptr('get')
            sliceNumber('set', 'sagittal', iCurrentSlice); 

            if isVsplash('get') == true    
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'sagittal', iCurrentSlice);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));                        
            else
                sSliceNb = sprintf('\n%s/%s', num2str(iCurrentSlice), num2str(iLastSlice));  
            end
        else    
            sliceNumber('set', 'axial', iCurrentSlice); 
            if isVsplash('get') == true          
                [lFirst, lLast] = computeVsplashLayout(dicomBuffer('get'), 'axial', iLastSlice-iCurrentSlice+1);
                sSliceNb = sprintf('\n%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(iLastSlice));
            else
                sSliceNb = sprintf('\n%s/%s', num2str(1+iLastSlice-iCurrentSlice), num2str(iLastSlice));  
            end
        end

        set(tOverlay, 'String', sSliceNb);

        refreshImages();

        if aAxe == axes3Ptr('get')
            iCurrentSlice = iCurrentSlice-1;
            if iCurrentSlice <1
                iCurrentSlice =iLastSlice;
            end
        else
            iCurrentSlice = iCurrentSlice+1;
            if iCurrentSlice > iLastSlice
                iCurrentSlice =1;
            end                        
        end

        I = getframe(aAxe);
        [indI,cm] = rgb2ind(I.cdata, 256);

        if idx == 1

            if strcmpi('*.gif', sExtention)     
                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrameSpeed('get'));
            elseif strcmpi('*.jpg', sExtention)  

                sDirName = sprintf('%s_%s_%s_JPG_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
                sImgDirName = [sPath sDirName '//' ];

                if~(exist(char(sImgDirName), 'dir'))
                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, idx);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) 
                sDirName = sprintf('%s_%s_%s_BMP_2D', atCoreMetaData{1}.PatientName, atCoreMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sDirName = cleanString(sDirName);
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

        progressBar(idx / iLastSlice, 'Recording', 'red');

    end

    if     aAxe == axes1Ptr('get')
        sliceNumber('set', 'coronal', iSavedCurrentSlice); 
    elseif aAxe == axes2Ptr('get')
        sliceNumber('set', 'sagittal', iSavedCurrentSlice);                         
    else    
        sliceNumber('set', 'axial', iSavedCurrentSlice);                         
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

    if crossActivate('get') == true && ...                   
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
if 0
    if aAxe == axes1Ptr('get')
        uiLogo = displayLogo(uiCorWindowPtr('get'));
        logoObject('set', uiLogo);
    end
end
    refreshImages();

    if strcmpi('*.gif', sExtention) 
        progressBar(1, sprintf('Write %s completed', sFileName));
    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('*.bmp', sExtention)
        progressBar(1, sprintf('Write %d files to %s completed', iLastSlice, sImgDirName));
    end              
end
