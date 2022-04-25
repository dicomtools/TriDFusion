function [aMovedDicomBuffer, aMovedFusionBuffer, bMovementApplied] = applyManualMovment(aDicomBuffer, aFusionBuffer, aOffset, bMoveFusion)
%function  [aMovedDicomBuffer, aMovedFusionBuffer, bMovementApplied] = applyManualMovment(aDicomBuffer, aFusionBuffer, aOffset)
%Apply manual translation to both, dicom and fusion buffer. 
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

    tInput = inputTemplate('get');
    
    dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
    
    aMovedDicomBuffer  = aDicomBuffer;
    aMovedFusionBuffer = aFusionBuffer;
        
    bMovementApplied = false;
    
    progressBar(0.999, 'Processing Translation, please wait');

    if size(aDicomBuffer, 3) == 1 % 2D image
        
        if aOffset(1) ~= 0 || ...
           aOffset(2) ~= 0 
          
            if bMoveFusion == true
                aMovedFusionBuffer = translateImageMovement(aMovedFusionBuffer, aOffset);
            end

            yScale = size(aDicomBuffer,1)/size(aFusionBuffer,1);
            xScale = size(aDicomBuffer,2)/size(aFusionBuffer,2);
            
            f = [ yScale 0      0      0
                  0      xScale 0      0
                  0      0      1      0
                  0      0      0      1];

            TF = affine3d(f);
            
            a3DOffset = zeros(1,3);
            a3DOffset(1)=aOffset(1);
            a3DOffset(2)=aOffset(2);

            pcOut = pctransform(pointCloud(a3DOffset), TF);
                        
            aScaledOffset = zeros(1, 2);
            aScaledOffset(1) = pcOut.Location(1); % X
            aScaledOffset(2) = pcOut.Location(2); % Y
            
            aMovedDicomBuffer = translateImageMovement(aMovedDicomBuffer, aScaledOffset);

            bMovementApplied = true;
            
            tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;
            if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axe';
                tInput(dFusedSeriesOffset).tMovement.atSeq{1}.aTranslation = TF;                       
            else
                dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axe';
                tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.aTranslation = TF;              
            end              
        end
    else
        
        if aOffset(1) ~= 0 || ...
           aOffset(2) ~= 0 || ...     
           aOffset(3) ~= 0 
        
            if bMoveFusion == true
                aMovedFusionBuffer = translateImageMovement(aMovedFusionBuffer, aOffset);
            end

            yScale = size(aDicomBuffer,1)/size(aFusionBuffer,1);
            xScale = size(aDicomBuffer,2)/size(aFusionBuffer,2);
            zScale = size(aDicomBuffer,3)/size(aFusionBuffer,3);
            
            f = [ yScale 0      0      0
                  0      xScale 0      0
                  0      0      zScale 0
                  0      0      0      1];


            TF = affine3d(f);

            pcOut = pctransform(pointCloud(aOffset), TF);
                        
            aScaledOffset = zeros(1,3);
            aScaledOffset(1) = pcOut.Location(1); % X
            aScaledOffset(2) = pcOut.Location(2); % Y
            aScaledOffset(3) = pcOut.Location(3); % Z          
            
            aMovedDicomBuffer = translateImageMovement(aMovedDicomBuffer, aScaledOffset);
            
            bMovementApplied = true;
            
            tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;
            if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axes';
                tInput(dFusedSeriesOffset).tMovement.atSeq{1}.aTranslation = TF;                       
            else
                dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axes';
                tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.aTranslation = TF;              
            end             
        end         
    end
    
    inputTemplate('set', tInput);
    
    progressBar(1, 'Ready');

end