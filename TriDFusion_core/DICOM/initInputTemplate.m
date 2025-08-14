function [atInput, asSeriesDescription] = initInputTemplate(asFilesList, atDicomInfo, aDicomBuffer)
%function [atInput, asSeriesDescription] = initInputTemplate(asFilesList, atDicomInfo, aDicomBuffer)
% Initialize DICOM input template.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = [];
    asSeriesDescription = [];

    dNbFolders = numel(asFilesList);
    
    if dNbFolders > 0

        atInput = struct();

        asSeriesDescription = cell(dNbFolders, 1);

        atInput(dNbFolders).asFilesList         = [];
        atInput(dNbFolders).atDicomInfo         = [];
        atInput(dNbFolders).aDicomBuffer        = [];
        atInput(dNbFolders).bEdgeDetection      = [];   
        atInput(dNbFolders).bDoseKernel         = [];      
        atInput(dNbFolders).bFlipLeftRight      = [];   
        atInput(dNbFolders).bFlipAntPost        = [];   
        atInput(dNbFolders).bFlipHeadFeet       = [];   
        atInput(dNbFolders).bMathApplied        = [];   
        atInput(dNbFolders).bFusedDoseKernel    = [];   
        atInput(dNbFolders).bFusedEdgeDetection = [];   
        
        atInput(dNbFolders).tMovement = [];
        atInput(dNbFolders).tMovement.bMovementApplied = [];   
        atInput(dNbFolders).tMovement.aGeomtform       = [];                
        
        atInput(dNbFolders).tMovement.atSeq{1}.sAxe         = [];
        atInput(dNbFolders).tMovement.atSeq{1}.aTranslation = [];
        atInput(dNbFolders).tMovement.atSeq{1}.dRotation    = [];

        atInput(dNbFolders).aMip = [];
        atInput(dNbFolders).tQuant = [];

        for dSeriesLoop=1: dNbFolders
        
            atInput(dSeriesLoop).asFilesList  = asFilesList{dSeriesLoop};
            atInput(dSeriesLoop).atDicomInfo  = atDicomInfo{dSeriesLoop};
            atInput(dSeriesLoop).aDicomBuffer = aDicomBuffer{dSeriesLoop};
            
            atInput(dSeriesLoop).sOrientationView = 'Axial';
        
            if strcmpi(atDicomInfo{dSeriesLoop}{1}.Modality, 'RTDOSE')
                bDoseKernel = true;
            else
                bDoseKernel = false;
            end
        
            atInput(dSeriesLoop).bEdgeDetection      = false;
            atInput(dSeriesLoop).bDoseKernel         = bDoseKernel;    
            atInput(dSeriesLoop).bFlipLeftRight      = false;
            atInput(dSeriesLoop).bFlipAntPost        = false;
            atInput(dSeriesLoop).bFlipHeadFeet       = false;
            atInput(dSeriesLoop).bMathApplied        = false;
            atInput(dSeriesLoop).bFusedDoseKernel    = false;
            atInput(dSeriesLoop).bFusedEdgeDetection = false;
            
            atInput(dSeriesLoop).tMovement = [];
            atInput(dSeriesLoop).tMovement.bMovementApplied = false;
            atInput(dSeriesLoop).tMovement.aGeomtform       = [];                
            
            atInput(dSeriesLoop).tMovement.atSeq{1}.sAxe         = [];
            atInput(dSeriesLoop).tMovement.atSeq{1}.aTranslation = [];
            atInput(dSeriesLoop).tMovement.atSeq{1}.dRotation    = [];
                                
            if isempty(atInput(dSeriesLoop).atDicomInfo{1}.SeriesDate)
                sVolSeriesDate = '';
            else
                sSeriesDate = atInput(dSeriesLoop).atDicomInfo{1}.SeriesDate;
                if isempty(atInput(dSeriesLoop).atDicomInfo{1}.SeriesTime)                            
                    sSeriesTime = '000000';
                else
                    sSeriesTime = atInput(dSeriesLoop).atDicomInfo{1}.SeriesTime;
                end

                sVolSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);                         
            end
                
            if ~isempty(sVolSeriesDate)
                if contains(sVolSeriesDate,'.')
                    sVolSeriesDate = extractBefore(sVolSeriesDate,'.');
                end
                try
                    % Ensure acquisitionTime is valid
                    if all(sVolSeriesDate == '0') || isempty(sVolSeriesDate)
                        sVolSeriesDate = '00010101010101'; % Default to midnight if invalid
                    end
                          
                    sVolSeriesDate = datetime(sVolSeriesDate,'InputFormat','yyyyMMddHHmmss');
                catch ME   
                    logErrorToFile(ME);
                    sVolSeriesDate = '';
                end
            end
            
            sVolSeriesDescription = atInput(dSeriesLoop).atDicomInfo{1}.SeriesDescription;

            asSeriesDescription{dSeriesLoop} = sprintf('%s %s', sVolSeriesDescription, sVolSeriesDate);
        end
    end
end
