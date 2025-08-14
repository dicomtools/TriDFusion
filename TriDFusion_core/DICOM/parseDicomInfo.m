function tDicomEntry = parseDicomInfo(tinfo)
%function tDicomEntry = parseDicomInfo(tinfo)
%Extracts key DICOM metadata into a structured format.
%  DESCRIPTION:
%  This function processes the metadata of a DICOM file and extracts key 
%  patient and study details into a structured output. It ensures compatibility 
%  with different formats of 'PatientName' (structured or plain text) and 
%  provides default values for missing fields.
%
%  PARAMETERS:
%  - 'tinfo' (struct): A structure containing DICOM metadata obtained 
%    from 'dicominfo()'. Expected fields include:
%      - 'PatientName'
%      - 'PatientID'
%      - 'StudyInstanceUID'
%      - 'SeriesInstanceUID'
%      - 'Modality'
%      - 'AccessionNumber'
%
%  FUNCTIONALITY:
%  - If 'tinfo' is empty, returns an empty structure.
%  - Extracts 'PatientName' while handling structured ('FamilyName', 'GivenName') 
%    and unstructured formats.
%  - Reads 'PatientID', 'StudyInstanceUID', 'SeriesInstanceUID', 'Modality', 
%    and 'AccessionNumber', setting empty values if missing.
%  - Formats 'PatientName' as "FamilyName^GivenName" for consistency.
%
%  RETURN VALUE:
%  - 'tDicomEntry' (struct): A structured representation of the key DICOM fields:
%      - 'PatientName'       : Formatted as "FamilyName^GivenName"
%      - 'PatientID'         : Patient identifier
%      - 'StudyInstanceUID'  : Unique study identifier
%      - 'SeriesInstanceUID' : Unique series identifier
%      - 'Modality'          : Scan modality (e.g., CT, PET)
%      - 'Accession'         : Accession number for the study
%
%  USAGE EXAMPLE:
%     tinfo = dicominfo('example.dcm');
%     tDicomEntry = parseDicomInfo(tinfo);
%     disp(tDicomEntry);
%
%  ERROR HANDLING:
%  - Returns an empty structure if 'tinfo' is empty.
%  - Handles both structured and unstructured 'PatientName' formats.
%  - Ensures missing fields do not cause runtime errors.
%
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.

    % Return an empty structure if tinfo is empty.

    if isempty(tinfo)
        tDicomEntry = struct();
        return;
    end

    if isfield(tinfo, 'PatientName')
        if isstruct(tinfo.PatientName)
            if isfield(tinfo.PatientName, 'FamilyName')
                familyName = tinfo.PatientName.FamilyName;
            else
                familyName = '';
            end
            if isfield(tinfo.PatientName, 'GivenName')
                givenName = tinfo.PatientName.GivenName;
            else
                givenName = '';
            end
        else
            % If PatientName is not a struct, assume it's a string.
            fullName = tinfo.PatientName;
            parts = strsplit(fullName, '^');
            if ~isempty(parts)
                familyName = parts{1};
            else
                familyName = '';
            end
            if numel(parts) > 1
                givenName = parts{2};
            else
                givenName = '';
            end
        end
    else
        familyName = '';
        givenName = '';
    end
    sPatientName = sprintf('%s^%s', familyName, givenName);
    
    if isfield(tinfo, 'PatientID')
        sPatientID = tinfo.PatientID;
    else
        sPatientID = '';
    end

    if isfield(tinfo, 'StudyInstanceUID')
        sStudyInstanceUID = tinfo.StudyInstanceUID;
    else
        sStudyInstanceUID = '';
    end

    if isfield(tinfo, 'SeriesInstanceUID')
        sSeriesInstanceUID = tinfo.SeriesInstanceUID;
    else
        sSeriesInstanceUID = '';
    end

    if isfield(tinfo, 'Modality')
        sModality = tinfo.Modality;
    else
        sModality = '';
    end

    if isfield(tinfo, 'AccessionNumber')
        sAccession = tinfo.AccessionNumber;
    else
        sAccession = '';
    end

    tDicomEntry.PatientName       = sPatientName;
    tDicomEntry.PatientID         = sPatientID;
    tDicomEntry.StudyInstanceUID  = sStudyInstanceUID;
    tDicomEntry.SeriesInstanceUID = sSeriesInstanceUID;
    tDicomEntry.Modality          = sModality; 
    tDicomEntry.Accession         = sAccession;    
end