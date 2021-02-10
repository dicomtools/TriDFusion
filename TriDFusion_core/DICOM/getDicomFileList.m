function [tFileList, iNbFiles] = getDicomFileList(sDirName, tFileList)
%function [tFileList, iNbFiles] = getDicomFileList(sDirName, tFileList, iNbFiles)
%Return a structure and the nb of dicom files.
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

    iNbFiles    = 0;
    iNbContours = 0;
    
    f = java.io.File(char(sDirName));
    asFileList = f.listFiles();

    for iLoop=1:length(asFileList)

        progressBar(iLoop / length(asFileList), 'Acquiring file list');

        if ~asFileList(iLoop).isDirectory               
            
            tInfo = dicominfo4che3(asFileList(iLoop));

            if ~isempty(tInfo)
                
                if strcmpi(tInfo.Modality, 'RTSTRUCT')
                    iNbContours = iNbContours+1;
                    sFileName = asFileList(iLoop);

                    tContours = readDicomContours(asFileList(iLoop)); 
                    
                    tFileList.Contours {iNbContours} = tContours;
                    tFileList.FileName {iNbContours} = sFileName;
                    tFileList.DicomInfo{iNbContours} = tInfo;
                    
                    iNbFiles = iNbFiles+1; 
               else
                    dInstanceNumber = 0;
                    adImagePositionPatient = [0 0 0];
                    sFileName = asFileList(iLoop);

                    if (isfield(tInfo,'InstanceNumber'))
                        if numel(tInfo.InstanceNumber)                        
                            dInstanceNumber=tInfo.InstanceNumber; 
                        end    
                    end

                    if (isfield(tInfo,'ImagePositionPatient'))
                        if ~isempty(tInfo.ImagePositionPatient)
                            adImagePositionPatient = tInfo.ImagePositionPatient;  
                        end
                    end

                    iNbFiles = iNbFiles+1; 
                    tFileList.FileName {iNbFiles}              = sFileName;
                    tFileList.DicomInfo{iNbFiles}              = tInfo;
                    tFileList.InstanceNumber(iNbFiles)         = dInstanceNumber;
                    tFileList.ImagePositionPatient(iNbFiles,:) = adImagePositionPatient(:)';
                end
            end
        end
    end

    progressBar(1, 'Ready');

end