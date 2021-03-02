function refreshImages()
%function refreshImages()
%Refresh the 2D DICOM images and overlay base on position.
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

    im  = dicomBuffer('get');
    imf = fusionBuffer('get');

    if overlayActivate('get') == true

        atMetaData = dicomMetaData('get');                    

        if isfield(atMetaData{1}, 'PatientName')
            sPatientName = atMetaData{1}.PatientName; 
            sPatientName = strrep(sPatientName,'^',' ');
            sPatientName = strtrim(sPatientName);
        else
            sPatientName = '';     
        end               

        if isfield(atMetaData{1}, 'PatientID')
            sPatientID = atMetaData{1}.PatientID;
            sPatientID = strtrim(sPatientID);
        else    
            sPatientID = '';
        end

        if isfield(atMetaData{1}, 'PatientName')
            sSeriesDescription = atMetaData{1}.SeriesDescription;
            sSeriesDescription = strrep(sSeriesDescription,'_',' ');
            sSeriesDescription = strrep(sSeriesDescription,'^',' ');
            sSeriesDescription = strtrim(sSeriesDescription);
        else
            sSeriesDescription = '';
        end

        if isfield(atMetaData{1}, 'SeriesDate')
            
            if isempty(atMetaData{1}.SeriesDate)
                sSeriesDate = '';
            else
                sSeriesDate = atMetaData{1}.SeriesDate;
                if isempty(atMetaData{1}.SeriesTime)                            
                    sSeriesTime = '000000';
                else
                    sSeriesTime = atMetaData{1}.SeriesTime;
                end                
                sSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime); 
            end

            if ~isempty(sSeriesDate)
                if contains(sSeriesDate,'.') 
                    sSeriesDate = extractBefore(sSeriesDate,'.');
                end
                sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMddHHmmss');                                       
            end
        else
            sSeriesDate = '';
        end

    end

    if size(im, 3) == 1 
        imAxe  = imAxePtr ('get');
        imAxeF = imAxeFPtr('get');

%             lMin  = windowLevel('get', 'min');
%             lMax = windowLevel('get', 'max');

        im=im(:,:);

%               imshow(im, [lMin lMax], 'Parent', axe);
%           if exist('axe')
%               cla(axe,'reset');
%           end

%           set(axe, 'Units', 'normalized','Position', [0 0 1 1], 'Visible' , 'off', 'Ydir','reverse', 'XLim', [0 inf], 'YLim', [0 inf], 'CLim', [lMin lMax]);

%            if aspectRatio('get') == true
%                daspect(axe, [1 1 1]);                
%            end

%            if gaussFilter('get') == true
%   %             imagesc(imgaussfilt(im, 1), 'Parent', axe);
%                surface(imgaussfilt(im), 'linestyle','none', 'Parent', axe); 
%            else    
         %   surface(im, 'linestyle','none', 'Parent', axe); 
         imAxe.CData = im;  
         if isFusion('get') == true
            imAxeF.CData  = imf;
        end                
%   %             imagesc(im, 'Parent', axe);
%            end

%             if isShading('get') == true
%                 shading(axe, 'interp');
%             end

        if overlayActivate('get') == true

            clickedPt = get(axePtr('get'), 'CurrentPoint');

            aBufferSize = size(im);

            clickedPtX = round(clickedPt(1,1));
            if clickedPtX < 1 
                clickedPtX = 1;                       
            end
            if clickedPtX > aBufferSize(2)
                clickedPtX =  aBufferSize(2);
            end  

            clickedPtY = round(clickedPt(1,2));
            if clickedPtY < 1 
                clickedPtY = 1;                       
            end
            if clickedPtY > aBufferSize(1)
                clickedPtY =  aBufferSize(1);
            end 

            tQuant = quantificationTemplate('get');
            dCurrent = im(clickedPtY, clickedPtX);

            sAxeText = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\n[X,Y] %s,%s', ...
                sPatientName, ...
                sPatientID,  ...
                sSeriesDescription, ...  
                sSeriesDate,...
                num2str(tQuant.tCount.dMin), ...
                num2str(tQuant.tCount.dMax), ...                          
                num2str(tQuant.tCount.dSum),...
                num2str(dCurrent),...
                num2str(clickedPtX), ...
                num2str(clickedPtY));

            tAxeText = axesText('get', 'axe');
            tAxeText.String = sAxeText;
            tAxeText.Color  = overlayColor('get'); 
        end

%         overlayText();

%         colormap(axe, getColorMap('one', colorMapOffset('get')));
%         colorbar(axe, 'EdgeColor', overlayColor('get'), 'ButtonDownFcn', @colorbarCallback);                             

    else
        imCoronal  = imCoronalPtr ('get');
        imSagittal = imSagittalPtr('get');
        imAxial    = imAxialPtr   ('get');  

        imCoronalF  = imCoronalFPtr ('get'); 
        imSagittalF = imSagittalFPtr('get'); 
        imAxialF    = imAxialFPtr   ('get'); 

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );

        if isVsplash('get') == true       

            if strcmpi(vSplahView('get'), 'coronal') || ...
               strcmpi(vSplahView('get'), 'all')

                imComputed = computeMontage(im, 'coronal', iCoronal);

                imAxSize = size(imCoronal.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                imCoronal.CData = imComputed; 
            end

            if strcmpi(vSplahView('get'), 'sagittal') || ...
               strcmpi(vSplahView('get'), 'all')                

                imComputed = computeMontage(im, 'sagittal', iSagittal);

                imAxSize = size(imSagittal.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                imSagittal.CData = imComputed; 
            end      

            if strcmpi(vSplahView('get'), 'axial') || ...
               strcmpi(vSplahView('get'), 'all')   

                imComputed = computeMontage(im(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                imAxSize = size(imAxial.CData);
                imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                imAxial.CData = imComputed;  
         %       imAxial.CData = imAxial.CData(:,end:-1:1); % reverse order
            end

            if isFusion('get') == true
                if strcmpi(vSplahView('get'), 'coronal') || ...
                   strcmpi(vSplahView('get'), 'all')                    
                    imComputed = computeMontage(imf, 'coronal', iCoronal);

                    imAxSize = size(imCoronalF.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imCoronalF.CData = imComputed; 
                end

                if strcmpi(vSplahView('get'), 'sagittal') || ...
                   strcmpi(vSplahView('get'), 'all')                    
                    imComputed = computeMontage(imf, 'sagittal', iSagittal);

                    imAxSize = size(imSagittalF.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imSagittalF.CData = imComputed; 
                end

                if strcmpi(vSplahView('get'), 'axial') || ...
                   strcmpi(vSplahView('get'), 'all')                     
                    imComputed = computeMontage(imf(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                    imAxSize = size(imAxialF.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imAxialF.CData = imComputed; 
            %        imAxialF.CData = imAxialF.CData(:,end:-1:1);
                end
            end

            dVsplashLayoutX = vSplashLayout('get', 'x');
            dVsplashLayoutY = vSplashLayout('get', 'y');

            ptMontageAxes1 = montageText('get', 'axes1');                 
            for aa=1:numel(ptMontageAxes1)
                delete(ptMontageAxes1{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'coronal', iCoronal);                    

            xOffset = imCoronal.XData(2)/dVsplashLayoutX;
            yOffset = imCoronal.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes1{iPointerOffset} = text(axes1Ptr('get'), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes1{iPointerOffset}, 'Visible', 'off');    
                    end                            
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes1', ptMontageAxes1);

            ptMontageAxes2 = montageText('get', 'axes2');                 
            for aa=1:numel(ptMontageAxes2)
                delete(ptMontageAxes2{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'sagittal', iSagittal);                    

            xOffset = imSagittal.XData(2)/dVsplashLayoutX;
            yOffset = imSagittal.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes2{iPointerOffset} = text(axes2Ptr('get'), ((jj-1)*xOffset)+1, ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes2{iPointerOffset}, 'Visible', 'off');    
                    end
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes2', ptMontageAxes2);

            ptMontageAxes3 = montageText('get', 'axes3');                 
            for aa=1:numel(ptMontageAxes3)
                delete(ptMontageAxes3{aa});
            end

            [lFirst, ~] = computeVsplashLayout(im, 'axial', size(dicomBuffer('get'), 3)-iAxial+1);                   

            xOffset = imAxial.XData(2)/dVsplashLayoutX;
            yOffset = imAxial.YData(2)/dVsplashLayoutY;

            iPointerOffset=1;
            for hh=1:dVsplashLayoutY
                for jj=1:dVsplashLayoutX
                    ptMontageAxes3{iPointerOffset} = text(axes3Ptr('get'), ((jj-1)*xOffset)+1 , ((hh-1)*yOffset)+1, sprintf('\n%s', num2str(lFirst+iPointerOffset-1)), 'Color', overlayColor('get'));
                    if overlayActivate('get') == false
                        set(ptMontageAxes3{iPointerOffset}, 'Visible', 'off');    
                    end                            
                    iPointerOffset = iPointerOffset+1;
               end
            end

            montageText('set', 'axes3', ptMontageAxes3);  

    else    
        imCoronal.CData  = permute(im(iCoronal,:,:), [3 2 1]);
        imSagittal.CData = permute(im(:,iSagittal,:), [3 1 2]) ;
        imAxial.CData    = im(:,:,iAxial);            

        if isFusion('get') == true
            imCoronalF.CData  = permute(imf(iCoronal,:,:) , [3 2 1]);
            imSagittalF.CData = permute(imf(:,iSagittal,:), [3 1 2]) ;
            imAxialF.CData    = imf(:,:,iAxial);   
        end
   end

    tRefreshRoi = roiTemplate('get');
    if ~isempty(tRefreshRoi) 
        for bb=1:numel(tRefreshRoi)
           if isvalid(tRefreshRoi{bb}.Object) 
               if (strcmpi(tRefreshRoi{bb}.Axe, 'Axes1') && ...
                    iCoronal == tRefreshRoi{bb}.SliceNb) || ...
                   (strcmpi(tRefreshRoi{bb}.Axe, 'Axes2')&& ...
                    iSagittal == tRefreshRoi{bb}.SliceNb)|| ...
                   (strcmpi(tRefreshRoi{bb}.Axe, 'Axes3') && ...
                    iAxial == tRefreshRoi{bb}.SliceNb)

                    if isVsplash('get') == true
                        tRefreshRoi{bb}.Object.Visible = 'off';
                    else
                        tRefreshRoi{bb}.Object.Visible = 'on';
                    end
                else
                    tRefreshRoi{bb}.Object.Visible = 'off';
                end    
           end
        end
    end            

        if crossActivate('get') == true && ...
           isVsplash('get') == false 

            iSagittalSize = size(im,2);
            iCoronalSize  = size(im,1);
            iAxialSize    = size(im,3);

            alAxes1Line = axesLine('get', 'axes1');

            alAxes1Line{1}.XData = [iSagittal iSagittal];
            alAxes1Line{1}.YData = [iAxial-1 iAxial+1];

            alAxes1Line{2}.XData = [iSagittal-1 iSagittal+1];
            alAxes1Line{2}.YData = [iAxial iAxial];

            alAxes1Line{3}.XData = [0 iSagittal-crossSize('get')];
            alAxes1Line{3}.YData = [iAxial iAxial];

            alAxes1Line{4}.XData = [iSagittal+crossSize('get') iSagittalSize];
            alAxes1Line{4}.YData = [iAxial iAxial];

            alAxes1Line{5}.XData = [iSagittal iSagittal];
            alAxes1Line{5}.YData = [0 iAxial-crossSize('get')];

            alAxes1Line{6}.XData = [iSagittal iSagittal];
            alAxes1Line{6}.YData = [iAxial+crossSize('get') iAxialSize];


            alAxes2Line = axesLine('get', 'axes2');

            alAxes2Line{1}.XData = [iCoronal iCoronal];
            alAxes2Line{1}.YData = [iAxial-1 iAxial+1];

            alAxes2Line{2}.XData = [iCoronal-1 iCoronal+1];
            alAxes2Line{2}.YData = [iAxial iAxial];

            alAxes2Line{3}.XData = [0 iCoronal-crossSize('get')];
            alAxes2Line{3}.YData = [iAxial iAxial];

            alAxes2Line{4}.XData = [iCoronal+crossSize('get') iCoronalSize];
            alAxes2Line{4}.YData = [iAxial iAxial];

            alAxes2Line{5}.XData = [iCoronal iCoronal];
            alAxes2Line{5}.YData = [0 iAxial-crossSize('get')];

            alAxes2Line{6}.XData = [iCoronal iCoronal];
            alAxes2Line{6}.YData = [iAxial+crossSize('get') iAxialSize];                    


            alAxes3Line = axesLine('get', 'axes3');

            alAxes3Line{1}.XData = [iSagittal iSagittal];
            alAxes3Line{1}.YData = [iCoronal-1 iCoronal+1];

            alAxes3Line{2}.XData = [iSagittal-1 iSagittal+1];
            alAxes3Line{2}.YData = [iCoronal iCoronal];

            alAxes3Line{3}.XData = [0  iSagittal-crossSize('get')];
            alAxes3Line{3}.YData = [iCoronal iCoronal];

            alAxes3Line{4}.XData = [iSagittal+crossSize('get') iSagittalSize];
            alAxes3Line{4}.YData = [iCoronal iCoronal];

            alAxes3Line{5}.XData = [iSagittal iSagittal];
            alAxes3Line{5}.YData = [0 iCoronal-crossSize('get')];

            alAxes3Line{6}.XData = [iSagittal iSagittal];
            alAxes3Line{6}.YData = [iCoronal+crossSize('get') iCoronalSize];

        end

        if overlayActivate('get') == true

            tAxes1Text = axesText('get', 'axes1');

            clickedPt = get(gca,'CurrentPoint');
            clickedPtX = num2str(round(clickedPt(1,1)));
            clickedPtY = num2str(round(clickedPt(1,2)));              

            if gca == axes1Ptr('get') || ...
               (isVsplash('get') == true && ...
                strcmpi(vSplahView('get'), 'coronal'))

                if strcmp(windowButton('get'), 'down')

                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'coronal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe1Text = sprintf('\n%s\n%s\n%s\nC: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...                           
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 1)));                            
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')                         
                       [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxe1Text = sprintf('C:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 1)));
                    else
                        sAxe1Text = sprintf('\nC:%s/%s\n[X,Y] %s,%s', num2str(sliceNumber('get', 'coronal' )), num2str(size(dicomBuffer('get'), 1)), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                        strcmpi(vSplahView('get'), 'coronal') 
                            [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                            sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                            sAxe1Text = sprintf('\n%s\n%s\n%s\nC: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...                           
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 1)));                                                     
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'coronal')
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxe1Text = sprintf('C:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 1)));                        
                    else
                        sAxe1Text = sprintf('C:%s/%s', num2str(sliceNumber('get', 'coronal' )), num2str(size(dicomBuffer('get'), 1)));                        
                    end
                end
                tAxes1Text.String = sAxe1Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'coronal') 
                        [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        tAxes1Text.String = sprintf('\n%s\n%s\n%s\nC: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...                           
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 1)));     
                elseif isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'all')                                                
                    [lFirst, lLast] = computeVsplashLayout(im, 'coronal', sliceNumber('get', 'coronal'));
                    tAxes1Text.String = ['C:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 1))];                        
                else
                    tAxes1Text.String = ['C:' num2str(sliceNumber('get', 'coronal' )) '/' num2str(size(dicomBuffer('get'), 1))];
                end
            end
            tAxes1Text.Color = overlayColor('get');                        

            tAxes2Text = axesText('get', 'axes2');

            if gca == axes2Ptr('get') || ... 
               (isVsplash('get') == true && ...
                strcmpi(vSplahView('get'), 'sagittal'))

                if strcmp(windowButton('get'), 'down')
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'sagittal') 
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));                            
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe2Text = sprintf('\n%s\n%s\n%s\nS: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...                           
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 2)));                        
                    elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));                            
                        sAxe2Text = sprintf('S:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 2)));
                    else
                        sAxe2Text = sprintf('\nS:%s/%s\n[X,Y] %s,%s', num2str(sliceNumber('get', 'sagittal' )), num2str(size(dicomBuffer('get'), 2)), clickedPtX, clickedPtY);
                    end
                else
                    if isVsplash('get') == true && ...
                       strcmpi(vSplahView('get'), 'sagittal') 
                        [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));                            
                        sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                        sAxe2Text = sprintf('\n%s\n%s\n%s\nS: %s/%s', ...
                            sPatientName, ...
                            sPatientID, ...
                            sSeriesDescription, ...                           
                            sAxialSliceNumber, ...
                            num2str(size(dicomBuffer('get'), 2)));  
                     elseif isVsplash('get') == true && ...
                           strcmpi(vSplahView('get'), 'all')                           
                       [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));                            
                       sAxe2Text = sprintf('S:%s-%s/%s', num2str(lFirst), num2str(lLast), num2str(size(dicomBuffer('get'), 2)));
                    else
                        sAxe2Text = sprintf('S:%s/%s', num2str(sliceNumber('get', 'sagittal' )), num2str(size(dicomBuffer('get'), 2)));
                    end
                end
                tAxes2Text.String = sAxe2Text;
            else
                if isVsplash('get') == true && ...
                   strcmpi(vSplahView('get'), 'sagittal') 
                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));                            
                    sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    tAxes2Text.String = sprintf('\n%s\n%s\n%s\nS: %s/%s', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...                           
                        sAxialSliceNumber, ...
                        num2str(size(dicomBuffer('get'), 2))); 
                 elseif isVsplash('get') == true && ...
                        strcmpi(vSplahView('get'), 'all')                             
                    [lFirst, lLast] = computeVsplashLayout(im, 'sagittal', sliceNumber('get', 'sagittal'));
                    tAxes2Text.String = ['S:' num2str(lFirst) '-' num2str(lLast) '/' num2str(size(dicomBuffer('get'), 2))];
                else
                    tAxes2Text.String = ['S:' num2str(sliceNumber('get', 'sagittal')) '/' num2str(size(dicomBuffer('get'), 2))];
                end
            end
            tAxes2Text.Color  = overlayColor('get');

            tOverlayQuant = quantificationTemplate('get');
            atMetaData = dicomMetaData('get');          

            bDisplayAxe3 = true;
            mGate = gateIconMenuObject('get');
            if multiFramePlayback('get') == true && ...
               strcmpi(get(mGate, 'State'), 'on')
                bDisplayAxe3 = false;
            end

            if bDisplayAxe3 == true
                if isVsplash('get') == true && ...         
                   (strcmpi(vSplahView('get'), 'axial') || ...
                    strcmpi(vSplahView('get'), 'all')) 
                    [lFirst, lLast] = computeVsplashLayout(im, 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);
                    sAxialSliceNumber = [num2str(lFirst) '-' num2str(lLast)];
                    sAxe3Text = sprintf('\n%s\n%s\n%s\nA: %s/%s', ...
                        sPatientName, ...
                        sPatientID, ...
                        sSeriesDescription, ...                           
                        sAxialSliceNumber, ...
                        num2str(size(dicomBuffer('get'), 3)));                     
                else
                    sAxialSliceNumber = num2str(size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                    switch lower(atMetaData{1}.Modality)
                        case {'pt', 'nm'}

                            if strcmpi(atMetaData{1}.Units, 'BQML') && ...
                               isDoseKernel('get') == false && ...    
                               isfield(tOverlayQuant, 'tSUV') 
                                suvValue = im(iCoronal,iSagittal,iAxial) * tOverlayQuant.tSUV.dScale;
                                sAxe3Text = sprintf('\n\n\n\n\n\n%s\n%s\n%s\n%s\n(SUV is decay-corrected to the scan start time)\nMin SUV/W: %s -- %s Bq/cc\nMax SUV/W: %s -- %s Bq/cc\nTotal SUV/W: %s -- %s mCi\nCurrent SUV/W: %s -- %s Bq/cc\nA: %s/%s', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sSeriesDate,...
                                    num2str(tOverlayQuant.tSUV.dMin), ...
                                    num2str(tOverlayQuant.tCount.dMin), ...
                                    num2str(tOverlayQuant.tSUV.dMax), ...
                                    num2str(tOverlayQuant.tCount.dMax), ...                          
                                    num2str(tOverlayQuant.tSUV.dTot), ...
                                    num2str(tOverlayQuant.tSUV.dmCi), ...
                                    num2str(suvValue), ...
                                    num2str(im(iCoronal,iSagittal,iAxial)), ...                              
                                    sAxialSliceNumber, ...
                                    num2str(size(dicomBuffer('get'), 3)));
                            else
                                sAxe3Text = sprintf('\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nA: %s/%s', ...
                                    sPatientName, ...
                                    sPatientID, ...
                                    sSeriesDescription, ...
                                    sSeriesDate,...
                                    num2str(tOverlayQuant.tCount.dMin), ...
                                    num2str(tOverlayQuant.tCount.dMax), ...                          
                                    num2str(tOverlayQuant.tCount.dSum), ...
                                    num2str(im(iCoronal,iSagittal,iAxial)), ...                              
                                    sAxialSliceNumber, ...
                                    num2str(size(dicomBuffer('get'), 3)));                             
                            end

                        case 'ct'

                            [dWindow, dLevel] = computeWindowMinMax(windowLevel('get', 'max'), windowLevel('get', 'min'));
                            sWindowName = getWindowName(dWindow, dLevel);
                            sAxe3Text = sprintf('\n\n\n\n\n%s\n%s\n%s\n%s\nMin HU: %s\nMax HU: %s\nWindow/Level (%s): %s/%s\nCurrent HU: %s\nA: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sSeriesDate,...
                                num2str(tOverlayQuant.tHU.dMin), ...
                                num2str(tOverlayQuant.tHU.dMax), ...
                                sWindowName,...
                                num2str(round(dWindow)), ...
                                num2str(round(dLevel)), ...                       
                                num2str(im(iCoronal,iSagittal,iAxial)), ...
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 3)));

                       otherwise
                            sAxe3Text = sprintf('\n\n\n\n\n%s\n%s\n%s\n%s\nMin: %s\nMax: %s\nTotal: %s\nCurrent: %s\nA: %s/%s', ...
                                sPatientName, ...
                                sPatientID, ...
                                sSeriesDescription, ...
                                sSeriesDate,...
                                num2str(tOverlayQuant.tCount.dMin), ...
                                num2str(tOverlayQuant.tCount.dMax), ...                          
                                num2str(tOverlayQuant.tCount.dSum), ...
                                num2str(im(iCoronal,iSagittal,iAxial)), ...                              
                                sAxialSliceNumber, ...
                                num2str(size(dicomBuffer('get'), 3)));                        
                    end  

       %         sAxe3Text = sprintf('%s\n%s\n%s\nCurrent SUV/W:%s -- %d Bq/cc\nA :%s/%s', sPatientName, sPatientID, sSeriesDescription, num2str(suvValue),im(iCoronal,iSagittal,iAxial),num2str(sliceNumber('get', 'axial')),num2str(size(dicomBuffer('get'), 3)));

                    if gca == axes3Ptr('get') && strcmp(windowButton('get'), 'down')
                        sAxe3Text = sprintf('\n%s\n[X,Y] %s,%s', sAxe3Text, clickedPtX, clickedPtY);
                    end
                end

                tAxes3Text = axesText('get', 'axes3');
                tAxes3Text.String = sAxe3Text;
                tAxes3Text.Color  = overlayColor('get');                        
            end   
        end                                          
    end

end
