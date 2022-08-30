function setMoveImageCallback(~, ~)
%function  setMoveImageCallback(~, ~)
%Apply manual translation and rotation to both, dicom and fusion buffer. 
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    persistent pInitImAxeFXData;       
    persistent pInitImAxeFYData;      

    persistent pInitImCoronalFXData;       
    persistent pInitImCoronalFYData;  
    persistent pInitImSagittalFXData;       
    persistent pInitImSagittalFYData;      
    persistent pInitImAxialFXData;       
    persistent pInitImAxialFYData;   
            
    atTemplate   = inputTemplate('get');
    aInputBuffer = inputBuffer('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    iFusionOffset = get(uiFusedSeriesPtr('get'), 'Value');

    set(uiSeriesPtr('get'), 'Value', iFusionOffset);            

    aDicomBuffer = dicomBuffer('get');

    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

    if isempty(aDicomBuffer)
        aDicomBuffer = aInputBuffer{iFusionOffset};
    end

    if size(aDicomBuffer, 3) == 1
        if iSeriesOffset ~= iFusionOffset
            if atTemplate(iSeriesOffset).bFlipLeftRight == true
                aDicomBuffer=aDicomBuffer(:,end:-1:1);
            end

            if atTemplate(iSeriesOffset).bFlipAntPost == true
                aDicomBuffer=aDicomBuffer(end:-1:1,:);
            end
        end                
    else
        if iSeriesOffset ~= iFusionOffset                
            if atTemplate(iSeriesOffset).bFlipLeftRight == true
                aDicomBuffer=aDicomBuffer(:,end:-1:1,:);
            end

            if atTemplate(iSeriesOffset).bFlipAntPost == true
                aDicomBuffer=aDicomBuffer(end:-1:1,:,:);
            end

            if atTemplate(iSeriesOffset).bFlipHeadFeet == true
                aDicomBuffer=aDicomBuffer(:,:,end:-1:1);
            end
        end

        if strcmpi(imageOrientation('get'), 'coronal')
            aDicomBuffer = permute(aDicomBuffer, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aDicomBuffer = permute(aDicomBuffer, [2 3 1]);
        else
            aDicomBuffer = permute(aDicomBuffer, [1 2 3]);
        end                
    end

    if isMoveImageActivated('get') == false

        set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           

        isMoveImageActivated('set', true);

        fusedImageMovementValues('init');
        fusedImageRotationValues('init');               

        if size(aDicomBuffer, 3) == 1

            imAxeF = imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            pInitImAxeFXData = get(imAxeF,'XData');       
            pInitImAxeFYData = get(imAxeF,'YData');                 
        else

            imCoronalF  = imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
            imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
            imAxialF    = imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value'));  

            pInitImCoronalFXData  =  get(imCoronalF,'XData');       
            pInitImCoronalFYData  =  get(imCoronalF,'YData');  

            pInitImSagittalFXData =  get(imSagittalF,'XData');       
            pInitImSagittalFYData =  get(imSagittalF,'YData');  

            pInitImAxialFXData    =  get(imAxialF,'XData');       
            pInitImAxialFYData    =  get(imAxialF,'YData');
        end

    else
        
        try

        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;   
    
        isMoveImageActivated('set', false);            

        iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        iFusionOffset = get(uiFusedSeriesPtr('get'), 'Value');  

        if size(aDicomBuffer, 3) == 1

            imAxeF = imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            imAxeFXData = get(imAxeF,'XData');       
            imAxeFYData = get(imAxeF,'YData');  

            aOffsetAxeFXData  = imAxeFXData-pInitImAxeFXData;
            aOffsetAxeFYData  = imAxeFYData-pInitImAxeFYData;    

            aMovementOffset = [aOffsetAxeFXData(1) aOffsetAxeFYData(1)];

        else

            imCoronalF  = imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
%                imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
            imAxialF    = imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value'));              

%                imCoronalFXData  =  get(imCoronalF,'XData');       
            imCoronalFYData  =  get(imCoronalF,'YData');  

%                imSagittalFXData =  get(imSagittalF,'XData');       
%                imSagittalFYData =  get(imSagittalF,'YData');  

            imAxialFXData    =  get(imAxialF,'XData');       
            imAxialFYData    =  get(imAxialF,'YData');

%                aOffsetCoronalFXData  = imCoronalFXData-pInitImCoronalFXData;
            aOffsetCoronalFYData  = imCoronalFYData-pInitImCoronalFYData;

%                aOffsetSagittalFXData = imSagittalFXData-pInitImSagittalFXData;
%                aOffsetSagittalFYData = imSagittalFYData-pInitImSagittalFYData;

            aOffsetAxialFXData    = imAxialFXData-pInitImAxialFXData;
            aOffsetAxialFYData    = imAxialFYData-pInitImAxialFYData; 

            xOffset = aOffsetAxialFXData(1);
            yOffset = aOffsetAxialFYData(1);
            zOffset = aOffsetCoronalFYData(1);

            aMovementOffset = [xOffset yOffset zOffset];

        end

        aFusionBuffer = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));                              

        [aMovedDicomBuffer, aMovedFusionBuffer, bMovementApplied] = applyManualMovment(aDicomBuffer, aFusionBuffer, aMovementOffset, true);
        [aMovedDicomBuffer, aMovedFusionBuffer, bRotationApplied] = applyManualRotation(aMovedDicomBuffer, aMovedFusionBuffer, true);

        if bMovementApplied == true || ...
           bRotationApplied == true     

            % Set DICOM Buffer 

            set(uiSeriesPtr('get'), 'Value', iFusionOffset);
            
            dicomBuffer('set', aMovedDicomBuffer);

            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

            if size(aMovedDicomBuffer, 3) ~= 1           
                mipBuffer('set', computeMIP(aMovedDicomBuffer), iFusionOffset);    
            end

            % Set Fusion Buffer 

            fusionBuffer('set', aMovedFusionBuffer, get(uiFusedSeriesPtr('get'), 'Value'));
            if size(aMovedFusionBuffer, 3) ~= 1           

                if link2DMip('get') == true && ...
                   isVsplash('get') == false    

                    mipFusionBuffer('set', computeMIP(aMovedFusionBuffer), iFusionOffset);                                     
                end            
            end

            % Reset Image Offset

            if bMovementApplied == true 
                if size(aMovedFusionBuffer, 3) == 1 % 2d Images        
                    imAxeF = imAxeFPtr('get', [], iFusionOffset);

                    imAxeF.XData = pInitImAxeFXData;
                    imAxeF.YData = pInitImAxeFYData;

                else  % 3d Images      
                    imCoronalF  = imCoronalFPtr ('get', [], iFusionOffset); 
                    imSagittalF = imSagittalFPtr('get', [], iFusionOffset); 
                    imAxialF    = imAxialFPtr   ('get', [], iFusionOffset);  

                    imCoronalF.XData  = pInitImCoronalFXData;
                    imCoronalF.YData  = pInitImCoronalFYData;

                    imSagittalF.XData = pInitImSagittalFXData;
                    imSagittalF.YData = pInitImSagittalFYData;

                    imAxialF.XData    = pInitImAxialFXData;
                    imAxialF.YData    = pInitImAxialFYData;
                end
            end
            
            % Update Series Description

            if updateDescription('get') == true
                
                asDescription = seriesDescription('get');
                
                asDescription{iFusionOffset} = sprintf('MOV-MAN %s', asDescription{iFusionOffset});
                asDescription{iSeriesOffset} = sprintf('REF-MAN %s', asDescription{iSeriesOffset});                
                
                seriesDescription('set', asDescription);
            
            end          
            
            refreshImages();
            
            % Move Associated Series
                       
            if associateRegistrationModality('get') == true
                
                adAssociatedSeries = [];
            
                sStudyInstanceUID    = atTemplate(iFusionOffset).atDicomInfo{1}.StudyInstanceUID;
                sSeriesInstanceUID   = atTemplate(iFusionOffset).atDicomInfo{1}.SeriesInstanceUID;
                sFrameOfReferenceUID = atTemplate(iFusionOffset).atDicomInfo{1}.FrameOfReferenceUID;
                        
                for mm=1:numel(atTemplate) % Find associated series

                    sCurrentStudyInstanceUID = ...
                        atTemplate(mm).atDicomInfo{1}.StudyInstanceUID;

                    sCurrentSeriesInstanceUID = ...
                        atTemplate(mm).atDicomInfo{1}.SeriesInstanceUID;

                    sCurrentFrameOfReferenceUID = ...                               
                        atTemplate(mm).atDicomInfo{1}.FrameOfReferenceUID;


                    if strcmpi(sStudyInstanceUID   , sCurrentStudyInstanceUID) && ... % Will need to switch and move the sub modality
                       strcmpi(sFrameOfReferenceUID, sCurrentFrameOfReferenceUID) 

                        if ~strcmpi(sSeriesInstanceUID, sCurrentSeriesInstanceUID) % We don't want to register the series twice   
                            if mm ~= iSeriesOffset % We don't move the reference
                                adAssociatedSeries{numel(adAssociatedSeries)+1} = mm;                                     
                            end
                        end
                    end
                end
                
                if ~isempty(adAssociatedSeries) % Move all Associated Series
                    
                    for aa=1:numel(adAssociatedSeries)
                        
                        iAssociatedOffset = adAssociatedSeries{aa};
                        
                        set(uiSeriesPtr('get'), 'Value', iAssociatedOffset);            

                        aDicomBuffer = dicomBuffer('get');

                        set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                        if isempty(aDicomBuffer)
                            aDicomBuffer = aInputBuffer{iAssociatedOffset};
                        end

                        if size(aDicomBuffer, 3) == 1
                            if iSeriesOffset ~= iAssociatedOffset
                                if atTemplate(iSeriesOffset).bFlipLeftRight == true
                                    aDicomBuffer=aDicomBuffer(:,end:-1:1);
                                end

                                if atTemplate(iSeriesOffset).bFlipAntPost == true
                                    aDicomBuffer=aDicomBuffer(end:-1:1,:);
                                end
                            end                
                        else
                            if iSeriesOffset ~= iAssociatedOffset                
                                if atTemplate(iSeriesOffset).bFlipLeftRight == true
                                    aDicomBuffer=aDicomBuffer(:,end:-1:1,:);
                                end

                                if atTemplate(iSeriesOffset).bFlipAntPost == true
                                    aDicomBuffer=aDicomBuffer(end:-1:1,:,:);
                                end

                                if atTemplate(iSeriesOffset).bFlipHeadFeet == true
                                    aDicomBuffer=aDicomBuffer(:,:,end:-1:1);
                                end
                            end

                            if strcmpi(imageOrientation('get'), 'coronal')
                                aDicomBuffer = permute(aDicomBuffer, [3 2 1]);
                            elseif strcmp(imageOrientation('get'), 'sagittal')
                                aDicomBuffer = permute(aDicomBuffer, [2 3 1]);
                            else
                                aDicomBuffer = permute(aDicomBuffer, [1 2 3]);
                            end                
                        end
                        
                        [aMovedDicomBuffer, ~, bMovementApplied] = applyManualMovment(aDicomBuffer, aFusionBuffer, aMovementOffset, false);
                        [aMovedDicomBuffer, ~, bRotationApplied] = applyManualRotation(aMovedDicomBuffer, aMovedFusionBuffer, false);

                        if bMovementApplied == true || ...
                           bRotationApplied == true 
                       
                            % Set DICOM Buffer 

                            set(uiSeriesPtr('get'), 'Value', iAssociatedOffset);

                            dicomBuffer('set', aMovedDicomBuffer);

                            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                            if size(aMovedDicomBuffer, 3) ~= 1           
                                mipBuffer('set', computeMIP(aMovedDicomBuffer), iAssociatedOffset);    
                            end
                            
                            % Update Series Description

                            if updateDescription('get') == true

                                asDescription = seriesDescription('get');

                                asDescription{iAssociatedOffset} = sprintf('MOV-MAN %s', asDescription{iAssociatedOffset});

                                seriesDescription('set', asDescription);

                            end             
                        end                        
    
                    end
                end
      
            end
            
        end
        
        catch
            progressBar(1, 'Error:setMoveImageCallback()');           
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end
         
end