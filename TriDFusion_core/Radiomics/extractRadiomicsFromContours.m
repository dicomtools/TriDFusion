function extractRadiomicsFromContours(sRadiomicsScript, tReadiomics, bSUVUnit, dSUVScale, bEntireVolume, bContourType, dContourOffset)
%function extractRadiomicsFromContours(sRadiomicsScript, tReadiomics, bSUVUnit, dSUVScale, bEntireVolume, bContourType, dContourOffset)
%Run PyRadiomics, from a mask created from all contours.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atDicomMeta = dicomMetaData('get', [], dSeriesOffset);                              
    atMetaData  = atInput(dSeriesOffset).atDicomInfo;

    % Validate contours

    atVoiInput = voiTemplate('get', dSeriesOffset);
    if isempty(atVoiInput)
        progressBar(1, 'Error: No contours (voi) detected!');
        errordlg('No contours (voi) detected!', 'Contours Validation');  
        return;
    end

    atRoiInput = roiTemplate('get', dSeriesOffset);
    if isempty(atRoiInput)
        progressBar(1, 'Error: No contours (roi) detected!');
        errordlg('No contours (roi) detected!', 'Contours Validation');  
        return;
    end

    % Validate images

    aInputImages = inputBuffer('get');
    aImages = aInputImages{dSeriesOffset};
    if isempty(aImages)
        progressBar(1, 'Error: No images detected!');
        errordlg('No images detected!', 'Image Validation');  
        return;
    end

    asPatientInfoHeader{1,1} = sprintf('Patient Name');
    asPatientInfoHeader{2,1} = sprintf('Patient ID');
    asPatientInfoHeader{3,1} = sprintf('Series Description');
    asPatientInfoHeader{4,1} = sprintf('Accession Number');
    asPatientInfoHeader{5,1} = sprintf('Series Date');
    asPatientInfoHeader{6,1} = sprintf('Series Time');
    asPatientInfoHeader{7,1} = sprintf('Units');

    asPatientInfoHeader{1,2} = sprintf('%s', cleanString(atMetaData{1}.PatientName, '_'));
    asPatientInfoHeader{2,2} = sprintf('%s', atMetaData{1}.PatientID);
    asPatientInfoHeader{3,2} = sprintf('%s', cleanString(atMetaData{1}.SeriesDescription, '_'));
    asPatientInfoHeader{4,2} = sprintf('%s', atMetaData{1}.AccessionNumber);
    asPatientInfoHeader{5,2} = sprintf('%s', atMetaData{1}.SeriesDate);
    asPatientInfoHeader{6,2} = sprintf('%s', atMetaData{1}.SeriesTime);
    asPatientInfoHeader{7,2} = sprintf('%s', getSerieUnitValue(get(uiSeriesPtr('get'), 'Value')));

    % Create an empty directory    

    sNrrdTmpDir = sprintf('%stemp_nrrd_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end
    mkdir(char(sNrrdTmpDir));  
   
    filter = {'*.xls'};

    sCurrentDir  = viewerRootPath('get');

    sMatFile = [sCurrentDir '/' 'lastRadiomicsDir.mat'];
    
    % load last data directory
    if exist(sMatFile, 'file')
                    % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('saveRadiomicsLastUsedDir', 'var')
           sCurrentDir = saveRadiomicsLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
    end
        
    sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
    [file, path] = uiputfile(filter, 'Save radiomics report', sprintf('%s/%s_%s_%s_%s_RADIOMICS_TriDFusion.xls' , ...
        sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sDate) );

    if file ~= 0

        try
            matlab.io.internal.getExcelInstance;
            bExcelInstance = true;
        catch exception %#ok<NASGU>
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
            bExcelInstance = false;
        end

        try 
    
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        try
            saveRadiomicsLastUsedDir = path;
            save(sMatFile, 'saveRadiomicsLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end 

        sXlsFileName = sprintf('%s%s', path, file);
        
        if exist(sXlsFileName, 'file')
            delete(sXlsFileName);
        end

        progressBar(1/5, 'Computing images mask, please wait.');
    
        % Create an empty mask
    
        aImagesMask = zeros(size(aImages));
 
        % If a contour offset is specified, will compute it

        if exist('dContourOffset', 'var') 
            dVoiOffset = dContourOffset;
            dNbVois = dContourOffset;
        else % All contours
            dVoiOffset = 1;
            dNbVois = numel(atVoiInput);
        end

        if bContourType == true

            % Initialize contour type mask           

            aUnspecifiedMask     = [];          
            aBoneMask            = [];                         
            aSoftTissueMask      = [];                         
            aLungMask            = [];                         
            aLiverMask           = [];                         
            aParotidMask         = [];                         
            aBloodPoolMask       = [];                      
            aLymphNodesMask      = [];
            aPrimaryDiseaseMask  = [];
            aCervicalMask        = [];
            aSupraclavicularMask = []; 
            aMediastinalMask     = []; 
            aParaspinalMask      = []; 
            aAxillaryMask        = [];
            aAbdominalMask       = [];
            aUnknowMask          = []; 

            for vv=1:numel(atVoiInput)
                                
                switch lower(atVoiInput{vv}.LesionType)
                    
                    case 'unspecified'
                        aUnspecifiedMask     = zeros(size(aImages));
                        
                    case 'bone'
                        aBoneMask            = zeros(size(aImages));
                         
                    case 'soft tissue'
                        aSoftTissueMask      = zeros(size(aImages));
                        
                    case 'lung'
                        aLungMask            = zeros(size(aImages));
                        
                    case 'liver'
                        aLiverMask           = zeros(size(aImages));
                        
                    case 'parotid'
                        aParotidMask         = zeros(size(aImages));
                        
                    case 'blood pool'
                        aBloodPoolMask       = zeros(size(aImages));

                    case 'lymph nodes'
                        aLymphNodesMask      = zeros(size(aImages));

                    case 'primary disease'
                        aPrimaryDiseaseMask  = zeros(size(aImages));                        

                    case 'cervical' 
                        aCervicalMask        = zeros(size(aImages));  

                    case 'supraclavicular' 
                        aSupraclavicularMask = zeros(size(aImages));                        

                    case 'mediastinal'
                        aMediastinalMask     = zeros(size(aImages));                        

                    case 'paraspinal'
                        aParaspinalMask      = zeros(size(aImages));                        

                    case 'axillary'
                        aAxillaryMask        = zeros(size(aImages));                        

                    case 'abdominal'
                        aAbdominalMask       = zeros(size(aImages));                        

                    otherwise
                        aUnknowMask         = zeros(size(aImages));
                end
            end
        end

        % Create mask
     
        for vv=dVoiOffset:dNbVois
    
            for uu=1:numel(atVoiInput{vv}.RoisTag)
    
                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[atVoiInput{vv}.RoisTag{uu}]} );                
                    
                tRoi = atRoiInput{find(aTagOffset, 1)};
    
                % Resample ROI to original image size
    
                if numel(aImages) ~= numel(dicomBuffer('get', [], dSeriesOffset))
                    pTemp{1} = tRoi;
                    ptrRoiTemp = resampleROIs(dicomBuffer('get', [], dSeriesOffset), atDicomMeta, aImages, atMetaData, pTemp, false);
                    tRoi = ptrRoiTemp{1};
                end  
    
                % Extrac ROI mask
    
                switch lower(tRoi.Axe)                    
                    case 'axe'
                        aImagesSlice = aImages(:,:);
                        aMaskSlice   = aImagesMask(:,:);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
                    
                    case 'axes1'
                        aImagesSlice = permute(aImages(tRoi.SliceNb,:,:), [3 2 1]);
                        aMaskSlice   = permute(aImagesMask(tRoi.SliceNb,:,:), [3 2 1]);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
    
                     
                    case 'axes2'
                        aImagesSlice = permute(aImages(:,tRoi.SliceNb,:), [3 1 2]);
                        aMaskSlice   = permute(aImagesMask(:,tRoi.SliceNb,:), [3 1 2]);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
                        
                   case 'axes3'
                        aImagesSlice = aImages(:,:,tRoi.SliceNb);
                        aMaskSlice   = aImagesMask(:,:,tRoi.SliceNb);
    
                        aCurrentMask = roiTemplateToMask(tRoi, aImagesSlice);
                end 
    
                % Set mask to voi number
                
                aMaskSlice(aCurrentMask==1) = vv;
    
                switch lower(tRoi.Axe)                    
                    case 'axe'
                        aImagesMask(:,:) = aMaskSlice;
                        
                    case 'axes1'
                        aImagesMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
    
                    case 'axes2'
                        aImagesMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                      
                    case 'axes3'
                        aImagesMask(:,:,tRoi.SliceNb) = aMaskSlice;   
                end 


                if bContourType == true


                    switch lower(atVoiInput{vv}.LesionType)
                     
                        case 'unspecified'
                            
                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aUnspecifiedMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aUnspecifiedMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aUnspecifiedMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aUnspecifiedMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aUnspecifiedMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aUnspecifiedMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aUnspecifiedMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aUnspecifiedMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end                             
                            
                        case 'bone'
                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aBoneMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aBoneMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aBoneMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aBoneMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aBoneMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aBoneMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aBoneMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aBoneMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end   
                          
                            
                        case 'soft tissue'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aSoftTissueMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aSoftTissueMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aSoftTissueMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aSoftTissueMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aSoftTissueMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aSoftTissueMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aSoftTissueMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aSoftTissueMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end                              
                            
                        case 'lung'
                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aLungMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLungMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aLungMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLungMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aLungMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aLungMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aLungMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aLungMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end                               
                            
                            
                        case 'liver'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aLiverMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLiverMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aLiverMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLiverMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aLiverMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aLiverMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aLiverMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aLiverMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end     
                          
                            
                        case 'parotid'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aParotidMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aParotidMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aParotidMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aParotidMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aParotidMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aParotidMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aParotidMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aParotidMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end     
                         
                            
                        case 'blood pool'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aBloodPoolMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aBloodPoolMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aBloodPoolMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aBloodPoolMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aBloodPoolMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aBloodPoolMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aBloodPoolMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aBloodPoolMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end   

                        case 'lymph nodes'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aLymphNodesMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLymphNodesMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aLymphNodesMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aLymphNodesMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aLymphNodesMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aLymphNodesMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aLymphNodesMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aLymphNodesMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                        case 'primary disease'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aPrimaryDiseaseMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aPrimaryDiseaseMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aPrimaryDiseaseMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aPrimaryDiseaseMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aPrimaryDiseaseMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aPrimaryDiseaseMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aPrimaryDiseaseMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aPrimaryDiseaseMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                        case 'cervical'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aCervicalMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aCervicalMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aCervicalMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aCervicalMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aCervicalMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aCervicalMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aCervicalMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aCervicalMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                        case 'supraclavicular'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aSupraclavicularMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aSupraclavicularMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aSupraclavicularMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aSupraclavicularMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aSupraclavicularMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aSupraclavicularMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aSupraclavicularMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aSupraclavicularMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                         case 'mediastinal'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aMediastinalMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aMediastinalMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aMediastinalMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aMediastinalMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aMediastinalMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aMediastinalMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aMediastinalMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aMediastinalMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                         case 'paraspinal'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aParaspinalMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aParaspinalMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aParaspinalMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aParaspinalMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aParaspinalMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aParaspinalMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aParaspinalMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aParaspinalMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                         case 'axillary'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aAxillaryMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aAxillaryMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aAxillaryMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aAxillaryMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aAxillaryMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aAxillaryMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aAxillaryMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aAxillaryMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end  

                        case 'abdominal'

                            switch lower(tRoi.Axe)                    
                                case 'axe'
                                    aMaskSlice   = aAbdominalMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aAbdominalMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aAbdominalMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aAbdominalMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aAbdominalMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aAbdominalMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aAbdominalMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aAbdominalMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end 
                            
                        otherwise

                            switch lower(tRoi.Axe)        

                                case 'axe'
                                    aMaskSlice   = aUnknowMask(:,:);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aUnknowMask(:,:) = aMaskSlice;
                                    
                                case 'axes1'
                                    aMaskSlice = permute(aUnknowMask(tRoi.SliceNb,:,:), [3 2 1]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                    
                                    aUnknowMask(tRoi.SliceNb,:,:) = permute(aMaskSlice, [3 2 1]);
                
                                case 'axes2'
                                    aMaskSlice   = permute(aUnknowMask(:,tRoi.SliceNb,:), [3 1 2]);
                                    aMaskSlice(aCurrentMask==1) = 1;
                                   
                                    aUnknowMask(:,tRoi.SliceNb,:) = permute(aMaskSlice, [2 3 1]);
                                  
                                case 'axes3'
                                    aMaskSlice   = aUnknowMask(:,:,tRoi.SliceNb);
                                    aMaskSlice(aCurrentMask==1) = 1;

                                    aUnknowMask(:,:,tRoi.SliceNb) = aMaskSlice;              
                            end   
                          
                     end

                end
    
            end
        end
    
        if bEntireVolume == true
            aEntireImagesMask = aImagesMask;
            aEntireImagesMask(aEntireImagesMask~=0)=1;
        end

        progressBar(2/5, 'Writing .nrrd files, please wait.');
    
        % Write .nrrd files 
        
        origin = atMetaData{end}.ImagePositionPatient;
        
        pixelspacing=zeros(3,1);
        pixelspacing(1)=atMetaData{1}.PixelSpacing(1);
        pixelspacing(2)=atMetaData{1}.PixelSpacing(2);
        pixelspacing(3) = computeSliceSpacing(atMetaData);
       
%         if ~isempty(atMetaData{1}.SliceThickness)
%             if atMetaData{1}.SliceThickness ~= 0
%                 pixelspacing(3) = atMetaData{1}.SliceThickness;
%             else
%                 pixelspacing(3) = computeSliceSpacing(atMetaData);
%             end           
%         else    
%             pixelspacing(3) = computeSliceSpacing(atMetaData);
%         end
    
        sNrrdImagesName = sprintf('%simges.nrrd', sNrrdTmpDir);
        sNrrdMaskName   = sprintf('%smask.nrrd' , sNrrdTmpDir);
    
        if bSUVUnit == true
            aImages = aImages*dSUVScale;
        end

        aImages = transformNrrdImage(aImages);

        nrrdWriter(sNrrdImagesName, squeeze(aImages), pixelspacing, origin, 'raw'); % Write .nrrd images 
        clear aImages;

        aImagesMask = transformNrrdImage(aImagesMask);

        nrrdWriter(sNrrdMaskName, squeeze(aImagesMask), pixelspacing, origin, 'raw'); % Write .nrrd mask
        clear aImagesMask;

        if bEntireVolume == true   

            aEntireImagesMask = transformNrrdImage(aEntireImagesMask);

            sNrrdEntireMaskName = sprintf('%sentire_mask.nrrd' , sNrrdTmpDir);
            nrrdWriter(sNrrdEntireMaskName, squeeze(aEntireImagesMask), pixelspacing, origin, 'raw'); % Write .nrrd mask
            clear aEntireImagesMask;
        end

        if bContourType == true

            sNrrdUnspecifiedMaskName     = '';
            sNrrdBoneMaskName            = '';
            sNrrdSoftTissueMaskName      = '';
            sNrrdLungMaskName            = '';
            sNrrdLiverMaskName           = '';
            sNrrdParotidMaskName         = '';
            sNrrdBloodPoolMaskName       = '';
            sNrrdLymphNodesMaskName      = '';
            sNrrdPrimaryDiseaseMaskName  = '';      
            sNrrdCervicalMaskName        = '';
            sNrrdSupraclavicularMaskName = ''; 
            sNrrdMediastinalMaskName     = ''; 
            sNrrdParaspinalMaskName      = ''; 
            sNrrdAxillaryMaskName        = '';
            sNrrdAbdominalMaskName       = '';            
            sNrrdUnknowMaskName          = '';

            % Unspecified mask 

            if ~isempty(aUnspecifiedMask)

                aUnspecifiedMask = transformNrrdImage(aUnspecifiedMask);
 
                sNrrdUnspecifiedMaskName = sprintf('%sunspecified_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdUnspecifiedMaskName, squeeze(aUnspecifiedMask), pixelspacing, origin, 'raw'); % Write .nrrd mask

                clear aUnspecifiedMask;
            end

            % Bone mask

            if ~isempty(aBoneMask)

                aBoneMask = transformNrrdImage(aBoneMask);

                sNrrdBoneMaskName = sprintf('%sbone_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdBoneMaskName, squeeze(aBoneMask), pixelspacing, origin, 'raw'); % Write .nrrd mask    

                clear aBoneMask;
            end

            % Soft Tissue mask

            if ~isempty(aSoftTissueMask)

                aSoftTissueMask = transformNrrdImage(aSoftTissueMask);

                sNrrdSoftTissueMaskName = sprintf('%ssoft_tissue_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdSoftTissueMaskName, squeeze(aSoftTissueMask), pixelspacing, origin, 'raw'); % Write .nrrd mask

                clear aSoftTissueMask;
            end

            % Lung mask

            if ~isempty(aLungMask)

                aLungMask = transformNrrdImage(aLungMask);

                sNrrdLungMaskName = sprintf('%slung_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdLungMaskName, squeeze(aLungMask), pixelspacing, origin, 'raw'); % Write .nrrd mask      

                clear aLungMask;
            end

            % Liver mask

            if ~isempty(aLiverMask)

                aLiverMask = transformNrrdImage(aLiverMask);

                sNrrdLiverMaskName = sprintf('%sliver_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdLiverMaskName, squeeze(aLiverMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aLiverMask;
            end

            % Parotid mask

            if ~isempty(aParotidMask)

                aParotidMask = transformNrrdImage(aParotidMask);

                sNrrdParotidMaskName = sprintf('%sparotid_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdParotidMaskName, squeeze(aParotidMask), pixelspacing, origin, 'raw'); % Write .nrrd mask     

                clear aParotidMask;
            end

            % Blood Pool mask

            if ~isempty(aBloodPoolMask)

                aBloodPoolMask = transformNrrdImage(aBloodPoolMask);

                sNrrdBloodPoolMaskName = sprintf('%sblood_pool_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdBloodPoolMaskName, squeeze(aBloodPoolMask), pixelspacing, origin, 'raw'); % Write .nrrd mask                      

                clear aBloodPoolMask;
           end

            % Lymph Nodes mask

            if ~isempty(aLymphNodesMask)

                aLymphNodesMask = transformNrrdImage(aLymphNodesMask);

                sNrrdLymphNodesMaskName = sprintf('%slymph_nodes_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdLymphNodesMaskName, squeeze(aLymphNodesMask), pixelspacing, origin, 'raw'); % Write .nrrd mask

                clear aLymphNodesMask;
            end

            % Primary disease mask

            if ~isempty(aPrimaryDiseaseMask)

                aPrimaryDiseaseMask = transformNrrdImage(aPrimaryDiseaseMask);

                sNrrdPrimaryDiseaseMaskName = sprintf('%sprimary_disease_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdPrimaryDiseaseMaskName, squeeze(aPrimaryDiseaseMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aPrimaryDiseaseMask;
            end           

            % Cervical mask

            if ~isempty(aCervicalMask)

                aCervicalMask = transformNrrdImage(aCervicalMask);

                sNrrdCervicalMaskName = sprintf('%scervical_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdCervicalMaskName, squeeze(aCervicalMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aCervicalMask;
            end    

            % Supraclavicular mask

            if ~isempty(aSupraclavicularMask)

                aSupraclavicularMask = transformNrrdImage(aSupraclavicularMask);

                sNrrdSupraclavicularMaskName = sprintf('%ssupraclavicular_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdSupraclavicularMaskName, squeeze(aSupraclavicularMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aSupraclavicularMask;
            end  

            % Mediastinal mask

            if ~isempty(aMediastinalMask)

                aMediastinalMask = transformNrrdImage(aMediastinalMask);

                sNrrdMediastinalMaskName = sprintf('%smediastinal_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdMediastinalMaskName, squeeze(aMediastinalMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aMediastinalMask;
            end  
            
            % Paraspinal mask

            if ~isempty(aParaspinalMask)

                aParaspinalMask = transformNrrdImage(aParaspinalMask);

                sNrrdParaspinalMaskName = sprintf('%sparaspinal_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdParaspinalMaskName, squeeze(aParaspinalMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aParaspinalMask;
            end 

            % Axillary mask

            if ~isempty(aAxillaryMask)

                aAxillaryMask = transformNrrdImage(aAxillaryMask);

                sNrrdAxillaryMaskName = sprintf('%saxillary_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdAxillaryMaskName, squeeze(aAxillaryMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aAxillaryMask;
            end 

            % Abdominal mask

            if ~isempty(aAbdominalMask)

                aAbdominalMask = transformNrrdImage(aAbdominalMask);

                sNrrdAbdominalMaskName = sprintf('%sabdominal_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdAbdominalMaskName, squeeze(aAbdominalMask), pixelspacing, origin, 'raw'); % Write .nrrd mask 

                clear aAbdominalMask;
            end 

            % Unknow mask

            if ~isempty(aUnknowMask)

                aUnknowMask = transformNrrdImage(aUnknowMask);

                sNrrdUnknowMaskName = sprintf('%sunknow_mask.nrrd' , sNrrdTmpDir);
                nrrdWriter(sNrrdUnknowMaskName, squeeze(aUnknowMask), pixelspacing, origin, 'raw'); % Write .nrrd mask   
                
                clear aUnknowMask;
            end

        end

        % Compute all contours
    
        progressBar(3/5, 'Computing radiomics, please wait');

        acResultFile = cell(dNbVois, 1);
        
        sAllContoursCmdout = '';

        if ispc % Windows

            if bEntireVolume == true % Entire volume

                if bContourType == true
                    progressBar(1/3, sprintf('Computing radiomics total contoured volume, it can take several minutes, please be patient.'));
                else
                    progressBar(1/2, sprintf('Computing radiomics total contoured volume, it can take several minutes, please be patient.'));
                end

                sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                writeYamlFile(sParametersFile, tReadiomics, 1);

                sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdEntireMaskName);    

                sEntireMaskResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'TOTAL-CONTOURED-VOLUME');

                [bStatus, sCmdout] = system([sCommandLine ' -o ' sEntireMaskResultFile ' -p ' sParametersFile]);

                if bStatus 
                    progressBar( 1, 'Error: An error occur during radiomics entire volume extraction!');
                    errordlg(sprintf('An error occur during radiomics entire volume extraction: %s', sCmdout), 'Extraction Error');  
                end                

            end

            if bContourType == true

                if bEntireVolume == true % Entire volume
                    bProgressBarOffset = 1/3;
                else
                    bProgressBarOffset = 1/2;
                end
                
                bProgressBarTypeOffset = bProgressBarOffset/16;

                sUnspecifiedMaskResultFile = '';
                sBoneMaskResultFile        = '';
                sSoftTissueResultFile      = '';
                sLungResultFile            = '';
                sLiverResultFile           = '';
                sParotidResultFile         = '';
                sBloodPoolResultFile       = '';
                sLymphNodesResultFile      = '';
                sPrimaryDiseaseResultFile  = '';
                sCervicalResultFile        = '';
                sSupraclavicularResultFile = ''; 
                sMediastinalResultFile     = ''; 
                sParaspinalResultFile      = ''; 
                sAxillaryResultFile        = '';
                sAbdominalResultFile       = '';                   
                sUnknowResultFile          = '';

                % Unspecified

                if ~isempty(sNrrdUnspecifiedMaskName)
                    
                    progressBar(bProgressBarOffset+1*bProgressBarTypeOffset, sprintf('Computing radiomics unspecified, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdUnspecifiedMaskName);    
    
                    sUnspecifiedMaskResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'UNSPECIFIED_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sUnspecifiedMaskResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics unspecified extraction!');
                        errordlg(sprintf('An error occur during radiomics unspecified extraction: %s', sCmdout), 'Extraction Error');  
                    end 
                end

                % Bone

                if ~isempty(sNrrdBoneMaskName)

                    progressBar(bProgressBarOffset+2*bProgressBarTypeOffset, sprintf('Computing radiomics bone, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdBoneMaskName);    
    
                    sBoneMaskResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'BONE_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sBoneMaskResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics bone extraction!');
                        errordlg(sprintf('An error occur during radiomics bone extraction: %s', sCmdout), 'Extraction Error');  
                    end 

                end

                % Soft Tissue

                if ~isempty(sNrrdSoftTissueMaskName)

                    progressBar(bProgressBarOffset+3*bProgressBarTypeOffset, sprintf('Computing radiomics soft tissue, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdSoftTissueMaskName);    
    
                    sSoftTissueResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'SOFT_TISSUE_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sSoftTissueResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics soft tissue extraction!');
                        errordlg(sprintf('An error occur during radiomics soft tissue extraction: %s', sCmdout), 'Extraction Error');  
                    end                     
                end

                % Lung

                if ~isempty(sNrrdLungMaskName)

                    progressBar(bProgressBarOffset+4*bProgressBarTypeOffset, sprintf('Computing radiomics lung, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdLungMaskName);    
    
                    sLungResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'LUNG_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sLungResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics lung extraction!');
                        errordlg(sprintf('An error occur during radiomics lung extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end

                % Liver

                if ~isempty(sNrrdLiverMaskName)

                    progressBar(bProgressBarOffset+5*bProgressBarTypeOffset, sprintf('Computing radiomics liver, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdLiverMaskName);    
    
                    sLiverResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'LIVER_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sLiverResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics liver extraction!');
                        errordlg(sprintf('An error occur during radiomics liver extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end

                % Parotid

                if ~isempty(sNrrdParotidMaskName)

                    progressBar(bProgressBarOffset+6*bProgressBarTypeOffset, sprintf('Computing radiomics parotid, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdParotidMaskName);    
    
                    sParotidResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'PAROTID_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sParotidResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics parotid extraction!');
                        errordlg(sprintf('An error occur during radiomics parotid extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end

                % Blood Pool

                if ~isempty(sNrrdBloodPoolMaskName)

                    progressBar(bProgressBarOffset+7*bProgressBarTypeOffset, sprintf('Computing radiomics blood pool, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdBloodPoolMaskName);    
    
                    sBloodPoolResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'BLOOD_POOL_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sBloodPoolResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics blood pool extraction!');
                        errordlg(sprintf('An error occur during radiomics blood pool extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end    

                % Lymph Nodes

                if ~isempty(sNrrdLymphNodesMaskName)

                    progressBar(bProgressBarOffset+8*bProgressBarTypeOffset, sprintf('Computing radiomics lymph nodes, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdLymphNodesMaskName);    
    
                    sLymphNodesResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'LYMPH_NODES_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sLymphNodesResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics lymph nodes extraction!');
                        errordlg(sprintf('An error occur during radiomics lymph nodes extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end  

                % Primary disease

                if ~isempty(sNrrdPrimaryDiseaseMaskName)

                    progressBar(bProgressBarOffset+9*bProgressBarTypeOffset, sprintf('Computing radiomics primary disease, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdPrimaryDiseaseMaskName);    
    
                    sPrimaryDiseaseResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'PRIMARY_DISEASE_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sPrimaryDiseaseResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end  

                % Cervical

                if ~isempty(sNrrdCervicalMaskName)

                    progressBar(bProgressBarOffset+10*bProgressBarTypeOffset, sprintf('Computing radiomics cervical, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdCervicalMaskName);    
    
                    sCervicalResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'CERVICAL_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sCervicalResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end  

                % Supraclavicular

                if ~isempty(sNrrdSupraclavicularMaskName)

                    progressBar(bProgressBarOffset+11*bProgressBarTypeOffset, sprintf('Computing radiomics supraclavicular, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdSupraclavicularMaskName);    
    
                    sSupraclavicularResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'SUPRACLAVICULAR_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sSupraclavicularResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end  

                % Mediastinal

                if ~isempty(sNrrdMediastinalMaskName)

                    progressBar(bProgressBarOffset+12*bProgressBarTypeOffset, sprintf('Computing radiomics mediastinal, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdMediastinalMaskName);    
    
                    sMediastinalResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'MEDIASTINAL_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sMediastinalResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end 

                % Paraspinal

                if ~isempty(sNrrdParaspinalMaskName)

                    progressBar(bProgressBarOffset+13*bProgressBarTypeOffset, sprintf('Computing radiomics paraspinal, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdParaspinalMaskName);    
    
                    sParaspinalResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'PARASPINAL_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sParaspinalResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end 

                % Axillary

                if ~isempty(sNrrdAxillaryMaskName)

                    progressBar(bProgressBarOffset+14*bProgressBarTypeOffset, sprintf('Computing radiomics axillary, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdAxillaryMaskName);    
    
                    sAxillaryResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'AXILLARY_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sAxillaryResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end 

                % Abdominal

                if ~isempty(sNrrdAbdominalMaskName)

                    progressBar(bProgressBarOffset+15*bProgressBarTypeOffset, sprintf('Computing radiomics abdominal, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdAbdominalMaskName);    
    
                    sAbdominalResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'ABDOMINAL_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sAbdominalResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics primary disease extraction!');
                        errordlg(sprintf('An error occur during radiomics primary disease extraction: %s', sCmdout), 'Extraction Error');  
                    end                      
                end  

                % Unknow

                if ~isempty(sNrrdUnknowMaskName)

                    progressBar(bProgressBarOffset+16*bProgressBarTypeOffset, sprintf('Computing radiomics unknow, it can take several minutes, please be patient.'));
    
                    sParametersFile = sprintf('%sparameters.yaml', sNrrdTmpDir);
                    writeYamlFile(sParametersFile, tReadiomics, 1);
    
                    sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdUnknowMaskName);    
    
                    sUnknowResultFile = sprintf('%s%s.csv', sNrrdTmpDir, 'UNKNOW_MASK');
    
                    [bStatus, sCmdout] = system([sCommandLine ' -o ' sUnknowResultFile ' -p ' sParametersFile]);

                    if bStatus 
                        progressBar( 1, 'Error: An error occur during radiomics unknow extraction!');
                        errordlg(sprintf('An error occur during radiomics unknow extraction: %s', sCmdout), 'Extraction Error');  
                    end                       
                end                        
               
            end

            for vv=dVoiOffset:dNbVois
               
     %           if mod(vv, 5)==1 || vv == dNbVois
                    progressBar(vv/dNbVois-0.009, sprintf('Computing radiomics contour %s (%d/%d), it can take several minutes, please be patient.', atVoiInput{vv}.Label, vv, dNbVois));
     %           end
    
                sParametersFile = sprintf('%sparameters%d.yaml', sNrrdTmpDir, vv);
                writeYamlFile(sParametersFile, tReadiomics, vv);
        
                sCommandLine = sprintf('cmd.exe /c %s %s %s', sRadiomicsScript, sNrrdImagesName, sNrrdMaskName);    
    
                acResultFile{vv} = sprintf('%s%s.csv', sNrrdTmpDir, cleanString(atVoiInput{vv}.Label));
                
                [bStatus, sCmdout] = system([sCommandLine ' -o ' acResultFile{vv} ' -p ' sParametersFile]);
                
                if bStatus 
                    progressBar( 1, 'Error: An error occur during radiomics extraction!');
                    if exist('dContourOffset', 'var') % All contours
                        errordlg(sprintf('An error occur during radiomics extraction: %s', sCmdout), 'Extraction Error');  
                    else % All contours
                        if isempty(sAllContoursCmdout)
                            sAllContoursCmdout = sCmdout;
                        end
                    end
                else % Process succeed
                end
            end

            if ~exist('dContourOffset', 'var') % All contours
            
                if ~isempty(sAllContoursCmdout) 
                    errordlg(sprintf('An error occur during radiomics extraction: %s', sAllContoursCmdout), 'Extraction Error');  
                end
            end

            % Combine all .xls to a file
            progressBar(4/5, 'Combining results, please wait.');

            if bEntireVolume == true % Entire volume

                current_table = readtable(sEntireMaskResultFile); 

                current_table.(1) = [];
    
                aCurrentTableSize = size(current_table);
                aPatientHeaderSize = size(asPatientInfoHeader);

                cCurrenTable = table2cell(current_table);

                if aCurrentTableSize(2) == 3
                    cTempTable = cell(aCurrentTableSize(1), 4);
                    for spl=1:aCurrentTableSize(1)
                        cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                        asSpLit = strsplit(cCurrenTable{spl,3},':');
                        
                        if numel(asSpLit) == 2
                            cTempTable{spl,3}=asSpLit{1};
                            cTempTable{spl,4}=asSpLit{2};
                        end
                    end
                    cCurrenTable = cTempTable;
                    aCurrentTableSize = size(cTempTable);
                end

                cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));

                cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);

                cCombineTable = cell2table([cTempTable; cCurrenTable]);

                writetable(cCombineTable, sXlsFileName, 'Sheet', 'TOTAL-CONTOURED-VOLUME', 'WriteVariableNames', false);
            end

            if bContourType == true

                % Unspecified lesions

                if ~isempty(sUnspecifiedMaskResultFile)

                    current_table = readtable(sUnspecifiedMaskResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'UNSPECIFIED-LESIONS', 'WriteVariableNames', false);                    
                end

                % Bone lesions

                if ~isempty(sBoneMaskResultFile)

                    current_table = readtable(sBoneMaskResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'BONE-LESIONS', 'WriteVariableNames', false);                        
                end

                % Soft tissue lesions

                if ~isempty(sSoftTissueResultFile)

                    current_table = readtable(sSoftTissueResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'SOFT_TISSUE-LESIONS', 'WriteVariableNames', false);                        
                end

                % Lung lesions

                if ~isempty(sLungResultFile)

                    current_table = readtable(sLungResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'LUNG-LESIONS', 'WriteVariableNames', false);                      
                end
                
                % Liver lesions

                if ~isempty(sLiverResultFile)

                    current_table = readtable(sLiverResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'LIVER-LESIONS', 'WriteVariableNames', false);                        
                end

                % Parotid lesions

                if ~isempty(sParotidResultFile)

                    current_table = readtable(sParotidResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'PAROTID-LESIONS', 'WriteVariableNames', false);                      
                end

                % Blood Pool lesions

                if ~isempty(sBloodPoolResultFile)

                    current_table = readtable(sBloodPoolResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'BLOOD_POOL-LESIONS', 'WriteVariableNames', false);                      
                end

                % Lymph Nodes lesions

                if ~isempty(sLymphNodesResultFile)

                    current_table = readtable(sLymphNodesResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'LYMPH_NODES-LESIONS', 'WriteVariableNames', false);                      
                end

                % Primary disease lesions

                if ~isempty(sPrimaryDiseaseResultFile)

                    current_table = readtable(sPrimaryDiseaseResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'PRIMARY_DISEASE-LESIONS', 'WriteVariableNames', false);                      
                end

                % Cervical lesions

                if ~isempty(sCervicalResultFile)

                    current_table = readtable(sCervicalResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'CERVICAL-LESIONS', 'WriteVariableNames', false);                      
                end

                % Supraclavicular lesions

                if ~isempty(sSupraclavicularResultFile)

                    current_table = readtable(sSupraclavicularResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'SUPRACLAVICULAR-LESIONS', 'WriteVariableNames', false);                      
                end

                % Mediastinal lesions

                if ~isempty(sMediastinalResultFile)

                    current_table = readtable(sMediastinalResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'MEDIASTINAL-LESIONS', 'WriteVariableNames', false);                      
                end

                % Paraspinal lesions

                if ~isempty(sParaspinalResultFile)

                    current_table = readtable(sParaspinalResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'PARASPINAL-LESIONS', 'WriteVariableNames', false);                      
                end

                % Axillary lesions

                if ~isempty(sAxillaryResultFile)

                    current_table = readtable(sAxillaryResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'AXILLARY-LESIONS', 'WriteVariableNames', false);                      
                end

                % Abdominal lesions

                if ~isempty(sAbdominalResultFile)

                    current_table = readtable(sAbdominalResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'ABDOMINAL-LESIONS', 'WriteVariableNames', false);                      
                end

                % Unknow lesions

                if ~isempty(sUnknowResultFile)

                    current_table = readtable(sUnknowResultFile); 
    
                    current_table.(1) = [];
        
                    aCurrentTableSize = size(current_table);
                    aPatientHeaderSize = size(asPatientInfoHeader);
    
                    cCurrenTable = table2cell(current_table);
    
                    if aCurrentTableSize(2) == 3
                        cTempTable = cell(aCurrentTableSize(1), 4);
                        for spl=1:aCurrentTableSize(1)
                            cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                            asSpLit = strsplit(cCurrenTable{spl,3},':');
                            
                            if numel(asSpLit) == 2
                                cTempTable{spl,3}=asSpLit{1};
                                cTempTable{spl,4}=asSpLit{2};
                            end
                        end
                        cCurrenTable = cTempTable;
                        aCurrentTableSize = size(cTempTable);
                    end
    
                    cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));
    
                    cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                    cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);
    
                    cCombineTable = cell2table([cTempTable; cCurrenTable]);
    
                    writetable(cCombineTable, sXlsFileName, 'Sheet', 'UNKNOW-LESIONS', 'WriteVariableNames', false);                          
                end
            end

            bFirstLoop = true;
            for vv=dVoiOffset:dNbVois        
                current_table = readtable(acResultFile{vv}); 

                current_table.(1) = [];
    
                aCurrentTableSize = size(current_table);
                aPatientHeaderSize = size(asPatientInfoHeader);

                cCurrenTable = table2cell(current_table);

                if aCurrentTableSize(2) == 3
                    cTempTable = cell(aCurrentTableSize(1), 4);
                    for spl=1:aCurrentTableSize(1)
                        cTempTable(spl,1:3) = cCurrenTable(spl,1:3);
                        asSpLit = strsplit(cCurrenTable{spl,3},':');
                        
                        if numel(asSpLit) == 2
                            cTempTable{spl,3}=asSpLit{1};
                            cTempTable{spl,4}=asSpLit{2};
                        end
                    end
                    cCurrenTable = cTempTable;
                    aCurrentTableSize = size(cTempTable);
                end

                cTempTable = cell(aPatientHeaderSize(1), aCurrentTableSize(2));

                cTempTable(1:aPatientHeaderSize(1),1)=asPatientInfoHeader(1:aPatientHeaderSize(1),1);
                cTempTable(1:aPatientHeaderSize(1),2)=asPatientInfoHeader(1:aPatientHeaderSize(1),2);

                cCombineTable = cell2table([cTempTable; cCurrenTable]);

                if bFirstLoop == false || bEntireVolume == true
    
                    [~,B]=xlsfinfo(sXlsFileName);
                    if any(strcmp(B, acResultFile{vv})) % If name exist 
                        writetable(cCombineTable, sXlsFileName, 'Sheet', vv, 'WriteVariableNames', false);
                    else
                        writetable(cCombineTable, sXlsFileName, 'Sheet', atVoiInput{vv}.Label, 'WriteVariableNames', false);
                    end
                else
                    bFirstLoop = false;
                    writetable(cCombineTable, sXlsFileName, 'Sheet', atVoiInput{vv}.Label, 'WriteVariableNames', false);
                end
            end
    
        elseif isunix % Linux is not yet supported
    
            progressBar( 1, 'Error: Radiomics under Linux is not yet supported');
            errordlg('Radiomics under Linux is not yet supported', 'Machine Learning Validation');
    
        else % Mac is not yet supported
    
            progressBar( 1, 'Error: Radiomics under Mac is not yet supported');
            errordlg('Radiomics under Mac is not yet supported', 'Radiomics Validation');
        end 

        catch 
            progressBar( 1 , 'Error: extractRadiomicsFromContours()' );
        end

        if bExcelInstance == true
            winopen(sXlsFileName);
        end

        progressBar(1, sprintf('Write %s completed', sXlsFileName));

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    % Delete .nrrd folder    
    
    if exist(char(sNrrdTmpDir), 'dir')
        rmdir(char(sNrrdTmpDir), 's');
    end 

%    progressBar(1, 'Ready');

    function aImages = transformNrrdImage(aImages)

        if size(aImages, 3) ~=1
    
            aImages = aImages(:,:,end:-1:1);
        end


%         if size(aImages, 3) ~=1    
%             aImages = imrotate3(aImages, 90, [0 0 1], 'nearest');
%             aImages = aImages(end:-1:1,:,:);
%         else
%             aImages = imrotate(aImages, 90, 'nearest');
%             aImages = aImages(end:-1:1,:);        
%         end
    end
end