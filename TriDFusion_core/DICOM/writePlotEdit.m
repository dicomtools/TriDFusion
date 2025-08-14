function writePlotEdit(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bShowSeriesDescriptionDialog, sOvewriteSeriesDescription)
%function writePlotEdit(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bShowSeriesDescriptionDialog, sOvewriteSeriesDescription)
%Export plot edit to a DICOM file.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
% along with TriDFusion.cIf not, see <http://www.gnu.org/licenses/>.

    try

    atInput = inputTemplate('get');
    if dSeriesOffset > numel(atInput)
        return;
    end
        
    if ~isempty(atInput(dSeriesOffset).asFilesList)
        
        sInputFile = atInput(dSeriesOffset).asFilesList{1};
        if ~isempty(sInputFile) && exist(sInputFile, 'file')
            
            tMetaData = dicominfo(string(sInputFile));
        else
            tMetaData = atInput(dSeriesOffset).atDicomInfo{1};
        end
    else % CERR
        tMetaData = atInput(dSeriesOffset).atDicomInfo{1};
    end
        
    % Set series label
    
    if exist('sOvewriteSeriesDescription', 'var')

        sSeriesDescription = sOvewriteSeriesDescription;
    else

        if isfield(tMetaData, 'SeriesDescription')

            sSeriesDescription = tMetaData.SeriesDescription;
        else
            sSeriesDescription = '';
        end
        
        sSeriesDescription = sprintf('ANN-%s', sSeriesDescription);
    
    
        if bShowSeriesDescriptionDialog == true
    
            sSeriesDescription = getViewerSeriesDescriptionDialog(sSeriesDescription);
            
            if isempty(sSeriesDescription)
                return;
            end
        end
    end

    % Resample contours (if needed)
    
    atPlotEdit = plotEditTemplate('get', dSeriesOffset);

    if isempty(atPlotEdit)
        return;
    end
            
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
    
    if modifiedImagesContourMatrix('get') == false

        if ~isequal(size(aInputBuffer), size(aDicomBuffer))
               
            atPlotEdit = resamplePlotEdit(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, atPlotEdit, false);

        end        
    end
    
    atPlotEdit = cellfun(@(s) rmfield(s,'Object'), atPlotEdit, 'UniformOutput',false);

    jsonText = jsonencode(atPlotEdit);

    
    % Set metadata information
    
    info = struct();        
    info.Filename = [];
    info.FileModDate = datetime;
    info.ManufacturerModelName = 'TRIDFUSION';
    
    if isfield(tMetaData, 'StudyDate')
        info.StudyDate = tMetaData.StudyDate;
    else
        info.StudyDate = '';
    end
    
    if isfield(tMetaData, 'StudyTime')
        info.StudyTime = tMetaData.StudyTime;
    else
        info.StudyTime = '';
    end
    
    if isfield(tMetaData, 'PatientName')
        info.PatientName = tMetaData.PatientName;
    else
        info.PatientName = '';
    end
    
    if isfield(tMetaData, 'PatientID')
        info.PatientID = tMetaData.PatientID;
    else
        info.PatientID = '';
    end

    if isfield(tMetaData, 'PatientBirthDate')
        info.PatientBirthDate = tMetaData.PatientBirthDate;
    else
        info.PatientBirthDate = '';
    end

    if isfield(tMetaData, 'PatientSex')
        info.PatientSex = tMetaData.PatientSex;
    else
        info.PatientSex = '';
    end

    if isfield(tMetaData, 'ReferringPhysicianName')
        info.ReferringPhysicianName = tMetaData.ReferringPhysicianName;
    else
        info.ReferringPhysicianName = '';
    end
        
    info.StudyInstanceUID  = tMetaData.StudyInstanceUID;
    info.SeriesInstanceUID = dicomuid;
        
    info.SeriesDescription = sSeriesDescription;
    if isfield(tMetaData, 'StudyDescription')
        info.StudyDescription = tMetaData.StudyDescription;
    else
        info.StudyDescription = '';
    end
    
    if isfield(tMetaData, 'StudyID')
        info.StudyID = tMetaData.StudyID;
    else
        info.StudyID = '';
    end
    
    if isfield(tMetaData, 'AccessionNumber')
        info.AccessionNumber = tMetaData.AccessionNumber;
    else
        info.AccessionNumber = '';
    end
    
    info.SeriesNumber = 1;
    info.StructureSetLabel = 'TRIDFUSION';

    info.StructureSetDate = char(datetime('now', 'Format', 'yyyyMMdd'));
    info.StructureSetTime = char(datetime('now', 'Format', 'HHmmss.SSS'));

    info.SOPClassUID        = '1.2.840.10008.5.1.4.1.1.7'; % Secondary Capture
    
    info.StudyInstanceUID   = tMetaData.StudyInstanceUID;
    info.SeriesInstanceUID  = dicomuid();
    info.SOPInstanceUID     = dicomuid();

    info.Private_0029_0010 = 'TriDFusion';  
    info.Private_0029_1010  = jsonText;
    info.Private_0029_1011  = '3DF_Annotations';

    if bSubDir == true
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_ANN_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir);       
    end
    
    sOutFile = sprintf('%s%s.dcm', sWriteDir, info.SeriesInstanceUID);
    dicomwrite([], sOutFile, info, 'CreateMode', 'copy','WritePrivate', true);
    
    progressBar( 1, sprintf('Export %s completed %s', sOutFile) );

    catch ME   
        logErrorToFile(ME);
        progressBar(1, sprintf('Error:writePlotEdit(), %s', sOutDir) );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
 

