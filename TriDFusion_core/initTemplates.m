function initTemplates()
%function initTemplates()
%Init All Global Templates.
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

    asMainDirectory = mainDir('get');
    if(numel(asMainDirectory))        
        try
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;               
            
        dNbEntry = 1;
        for dDirLoop=1: numel(asMainDirectory)
         %   datasets = folderInfo4che3(asMainDir{ii}, true);

            tDatasets = dicomInfoSortFolder(asMainDirectory{dDirLoop});                
            
            if isfield(tDatasets, 'Contours')
                inputContours('add', tDatasets.Contours{:});
            end

            if isfield(tDatasets, 'FileNames'   ) && ...
               isfield(tDatasets, 'DicomInfos'  ) && ...       
               isfield(tDatasets, 'DicomBuffers')                              

                atFrameInfo = dicomInfoComputeFrames(tDatasets.DicomInfos);

                asSeriesType = lower(tDatasets.DicomInfos{1}.SeriesType);
                
                bGated = false;
                if find(contains(asSeriesType, 'gated'))
                    bGated = true;
                end
                
                bDynamic = false;
                if find(contains(asSeriesType, 'dynamic'))
                    bDynamic = true;
                end
                
       %         sFileList = datasets.FileNames;
                if bGated   == true || ...
                   bDynamic == true || ...
                   ~isempty(atFrameInfo)

                    if bGated   == true || ...
                       bDynamic == true 

                        dNbFrames   = numel(tDatasets.DicomInfos) / tDatasets.DicomInfos{1}.NumberOfSlices;
                        dNbOfSlices = tDatasets.DicomInfos{1}.NumberOfSlices;

                        for dFramesLoop=1:dNbFrames

                            dFrameOffset = dFramesLoop-1;
                            dFrom = 1+ (dFrameOffset * dNbOfSlices);
                            dTo   = dNbOfSlices * dFramesLoop;

                            asFilesList{dNbEntry}  = tDatasets.FileNames(dFrom:dTo);
                            atDicomInfo{dNbEntry}  = tDatasets.DicomInfos(dFrom:dTo);
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers(dFrom:dTo);

                            for dSeriesLoop = 1: numel(atDicomInfo{dNbEntry})
                                if bGated == true
                                    atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Gate %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);
                                else
                                    atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Dynamic %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);                                    
                                end
                                atDicomInfo{dNbEntry}{dSeriesLoop}.din.frame = dFramesLoop;
                            end


                            dNbEntry = dNbEntry+1;

                        end

                    else

                        for dFramesLoop=1:numel(atFrameInfo)
 
                            if dFramesLoop == 1
                                
                                dFrameOffset = dFramesLoop-1;
                                dNbOfSlices  = atFrameInfo{dFramesLoop}.NbSlices;
                                
                                dFrom = 1+ (dFrameOffset * dNbOfSlices);
                                dTo   = dNbOfSlices * dFramesLoop;                                
                            else
                                dNbOfSlices  = atFrameInfo{dFramesLoop}.NbSlices;

                                dFrom = 1+dLastTo;
                                dTo   = dNbOfSlices + dLastTo;                                    
                            end

                            asFilesList{dNbEntry}  = tDatasets.FileNames(dFrom:dTo);
                            atDicomInfo{dNbEntry}  = tDatasets.DicomInfos(dFrom:dTo);
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers(dFrom:dTo);
                            for dSeriesLoop = 1: numel(atDicomInfo{dNbEntry})
                                atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                    sprintf('%s (Frame %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);
                                atDicomInfo{dNbEntry}{dSeriesLoop}.din.frame = dFramesLoop;
                            end

                            dNbEntry = dNbEntry+1;
                            dLastTo  = dTo;
                        end

                    end
                else
                    if numel(tDatasets) == 1
                        
                        asImageType = lower(tDatasets.DicomInfos{1}.ImageType);  
                        
                        bStatic = false;
                        if find(contains(asImageType, 'static')) 
                            bStatic = true;
                        end

                        bWholeBody = false;
                        if find(contains(asImageType, 'whole body')) 
                            bWholeBody = true;
                        end
                        
                        bScreenCapture = false;
                   %     if find(contains(asImageType, 'secondary')) 
                   %         bScreenCapture = true;
                   %     end
                            
                        if bStatic    == true || ...
                           bWholeBody == true || ...      
                           bScreenCapture == true

                            sSeriesDescription = tDatasets.DicomInfos{1}.SeriesDescription;
                           
                            if numel(tDatasets.DicomBuffers) > 1

                                dNbOfImages = numel(tDatasets.DicomBuffers);
    
                                for ll=1:dNbOfImages
                                   
                                    aTemp{1} = tDatasets.DicomBuffers{ll}(:,:);
                             
                                    aDicomBuffer{dNbEntry} = aTemp;
                                
                                    if bStatic == true
                                        tDatasets.DicomInfos{ll}.SeriesDescription = sprintf('%s (Static %d)', sSeriesDescription, ll);
                                    elseif bWholeBody == true
                                        tDatasets.DicomInfos{ll}.SeriesDescription = sprintf('%s (Whole Body %d)', sSeriesDescription, ll);
                                    else
                                        tDatasets.DicomInfos{ll}.SeriesDescription = sprintf('%s (Secondary %d)', sSeriesDescription, ll);
                                    end
                                    
                                    asFilesList{dNbEntry}  = tDatasets.FileNames(ll);
                                    atDicomInfo{dNbEntry}  = tDatasets.DicomInfos(ll);
                                    
                                    dNbEntry = dNbEntry+1;             
                                end                                
                            else

                                if size(tDatasets.DicomBuffers{1}, 3) == 1
                                    dNbOfImages = size(tDatasets.DicomBuffers{1}, 4);
                                else
                                    dNbOfImages = size(tDatasets.DicomBuffers{1}, 3);
                                end                          
                                
                                for ll=1:dNbOfImages
                                                                    
                                    if size(tDatasets.DicomBuffers{1}, 3) == 1
                                        aTemp{1} = tDatasets.DicomBuffers{1}(:,:,1,ll);
                                    else
                                        aTemp{1} = tDatasets.DicomBuffers{1}(:,:,ll);
                                    end
                                    
                                    aDicomBuffer{dNbEntry} = aTemp;
    
                                    if bStatic == true 
                                        tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Static %d)', sSeriesDescription, ll);
                                    elseif bWholeBody == true 
                                        tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Whole Body %d)', sSeriesDescription, ll);
                                    else
                                        tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Secondary %d)', sSeriesDescription, ll);
                                    end
                                    
                                    asFilesList{dNbEntry}  = tDatasets.FileNames;
                                    atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                                    
                                    dNbEntry = dNbEntry+1;                                      
                                end
                            end
                        else
                            asFilesList{dNbEntry}  = tDatasets.FileNames;
                            atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers;

                            dNbEntry = dNbEntry+1;                                
                        end
                    else                    
                        asFilesList{dNbEntry}  = tDatasets.FileNames;
                        atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                        aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers;

                        dNbEntry = dNbEntry+1;
                    end
                end
    %              sFileList = datasets.sFileName;

    %              asFilesList{ii}  = datasets.sFileName;
    %              atDicomInfo{ii}  = datasets.tDicomInfo;
    %              aDicomBuffer{ii} = datasets.aDicomBuffer;
            end
        end

        if exist('asFilesList' , 'var') && ...
           exist('atDicomInfo' , 'var') && ...
           exist('aDicomBuffer', 'var')

            for dSeriesLoop=1: numel(asFilesList)
                tSetInputTemplate(dSeriesLoop).asFilesList  = asFilesList{dSeriesLoop};
                tSetInputTemplate(dSeriesLoop).atDicomInfo  = atDicomInfo{dSeriesLoop};
                tSetInputTemplate(dSeriesLoop).aDicomBuffer = aDicomBuffer{dSeriesLoop};
                
                tSetInputTemplate(dSeriesLoop).sOrientationView    = 'Axial';
                
                tSetInputTemplate(dSeriesLoop).bEdgeDetection      = false;
                tSetInputTemplate(dSeriesLoop).bDoseKernel         = false;    
                tSetInputTemplate(dSeriesLoop).bFlipLeftRight      = false;
                tSetInputTemplate(dSeriesLoop).bFlipAntPost        = false;
                tSetInputTemplate(dSeriesLoop).bFlipHeadFeet       = false;
                tSetInputTemplate(dSeriesLoop).bMathApplied        = false;
                tSetInputTemplate(dSeriesLoop).bFusedDoseKernel    = false;
                tSetInputTemplate(dSeriesLoop).bFusedEdgeDetection = false;
                
                tSetInputTemplate(dSeriesLoop).tMovement = [];
                tSetInputTemplate(dSeriesLoop).tMovement.bMovementApplied = false;
                tSetInputTemplate(dSeriesLoop).tMovement.aGeomtform       = [];                
                
                tSetInputTemplate(dSeriesLoop).tMovement.atSeq{1}.sAxe         = [];
                tSetInputTemplate(dSeriesLoop).tMovement.atSeq{1}.aTranslation = [];
                tSetInputTemplate(dSeriesLoop).tMovement.atSeq{1}.dRotation    = [];
                
            end 
                    
            inputTemplate('set', tSetInputTemplate);

            if numel(inputTemplate('get')) ~= 0

                for dTemplateLoop = 1 : numel(inputTemplate('get'))
                    
                    if isempty(tSetInputTemplate(dTemplateLoop).atDicomInfo{1}.SeriesDate)
                        sVolSeriesDate = '';
                    else
                        sSeriesDate = tSetInputTemplate(dTemplateLoop).atDicomInfo{1}.SeriesDate;
                        if isempty(tSetInputTemplate(dTemplateLoop).atDicomInfo{1}.SeriesTime)                            
                            sSeriesTime = '000000';
                        else
                            sSeriesTime = tSetInputTemplate(dTemplateLoop).atDicomInfo{1}.SeriesTime;
                        end

                        sVolSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);                         
                    end
                        
                    if ~isempty(sVolSeriesDate)
                        if contains(sVolSeriesDate,'.')
                            sVolSeriesDate = extractBefore(sVolSeriesDate,'.');
                        end
                        sVolSeriesDate = datetime(sVolSeriesDate,'InputFormat','yyyyMMddHHmmss');
                    end
                    
                    sVolSeriesDescription = tSetInputTemplate(dTemplateLoop).atDicomInfo{1}.SeriesDescription;

                    asVolumes{dTemplateLoop} = sprintf('%s %s', sVolSeriesDescription, sVolSeriesDate);
                end
                seriesDescription('set', asVolumes);
            end

            setInputOrientation();

            setDisplayBuffer();

            if numel(inputTemplate('get')) ~= 0
                for dTemplateLoop = 1 : numel(inputTemplate('get'))       
                    setQuantification(dTemplateLoop);
                end
            end
            
            cropValue('set', min(dicomBuffer('get'), [], 'all'));
          
        else
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;              
            
            progressBar(1 , 'Error: TriDFusion: no volumes detected!');
            h = msgbox('Error: TriDFusion(): no volumes detected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end
        
        catch
            progressBar(1, 'Error:initTemplates()');          
        end  
        
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;           
    end
end
