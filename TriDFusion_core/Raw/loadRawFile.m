function loadRawFile( sPathName, sFileName, dimX, dimY)
%function loadRawFile(rawFileName))
%Load .raw file to TriDFusion.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
%
% This file is part of The Triple Dimention Fusion (TriDFusion).
%
% TriDFusion development has been led by: Daniel Lafontaine
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
    atDcmMetaData = dicomMetaData('get');   

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
%    if iSeriesOffset > numel(inputTemplate('get'))  
%        return;
%    end 
    
    try
        
    mainDir('set', sPathName);
        
    rawFileName = sprintf('%s%s', sPathName, sFileName);
        
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
    drawnow;
        
    progressBar(0.5, 'Scaning .raw file');
    
    fid = fopen(rawFileName, 'r', 'ieee-be');
    if fid == -1
      error('Cannot open file: %s', rawFileName);
    end
    
    aBuffer = fread(fid,[dimX dimY], 'uint16');
    fclose(fid);
    
    if ~isempty(tInput)
        
%        tInput(numel(tInput)+1) = tInput(iSeriesOffset);
%        tInput(numel(tInput)).atDicomInfo = atDcmMetaData;        

        asSeriesDescription = seriesDescription('get');
        asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('RAW-%s', sFileName);
        
        tInput(numel(tInput)+1).atDicomInfo = [];        
        
        tInput(numel(tInput)).atDicomInfo{1}.Modality = 'ot';
        tInput(numel(tInput)).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        tInput(numel(tInput)).atDicomInfo{1}.Units = '';
        tInput(numel(tInput)).atDicomInfo{1}.ReconstructionDiameter = [];
        
        tInput(numel(tInput)).atDicomInfo{1}.PixelSpacing(1) = 1;
        tInput(numel(tInput)).atDicomInfo{1}.PixelSpacing(2) = 1;        
        tInput(numel(tInput)).atDicomInfo{1}.SpacingBetweenSlices = 1;
        
%        for jj=1:numel(tInput(numel(tInput)).atDicomInfo)
%            tInput(numel(tInput)).atDicomInfo{jj}.SeriesDescription = asSeriesDescription{numel(asSeriesDescription)};
%            tInput(numel(tInput)).atDicomInfo{jj}.Modality = 'ot';            
%       %     tInput(numel(tInput)).atDicomInfo{jj}.PixelSpacing(1) = 1;
%       %     tInput(numel(tInput)).atDicomInfo{jj}.PixelSpacing(2) = 1;
%       %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(1)=0;
 %      %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(2)=0;
 %      %     tInput(numel(tInput)).atDicomInfo{jj}.ImagePositionPatient(3)=jj;
 %       end
 %       
        tInput(numel(tInput)).bEdgeDetection = false;
        tInput(numel(tInput)).bFlipLeftRight = false;
        tInput(numel(tInput)).bFlipAntPost   = false;
        tInput(numel(tInput)).bFlipHeadFeet  = false;
        tInput(numel(tInput)).bDoseKernel    = false;
        tInput(numel(tInput)).bFusedDoseKernel    = false;
        tInput(numel(tInput)).bFusedEdgeDetection = false;
    
        asSeries = get(uiSeriesPtr('get'), 'String');
        asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};        
    else
        
        asSeriesDescription{1}=sprintf('RAW-%s', sFileName);

        tInput(1).atDicomInfo{1}.Modality = 'ot';
        tInput(1).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        tInput(1).atDicomInfo{1}.Units = '';
        tInput(1).atDicomInfo{1}.ReconstructionDiameter = [];
        
        tInput(1).atDicomInfo{1}.PixelSpacing(1) = 1;
        tInput(1).atDicomInfo{1}.PixelSpacing(2) = 1;        
        tInput(1).atDicomInfo{1}.SpacingBetweenSlices = 1;
        
        tInput(1).bEdgeDetection = false;
        tInput(1).bFlipLeftRight = false;
        tInput(1).bFlipAntPost   = false;
        tInput(1).bFlipHeadFeet  = false;
        tInput(1).bDoseKernel    = false;
        tInput(1).bFusedDoseKernel    = false;
        tInput(1).bFusedEdgeDetection = false;
        
        asSeries{1} = asSeriesDescription{1};              
    end    
    
    seriesDescription('set', asSeriesDescription);
   
    inputTemplate('set', tInput);

    aInputBuffer = inputBuffer('get');        
    aInputBuffer{numel(aInputBuffer)+1} = aBuffer;    
    inputBuffer('set', aInputBuffer);
        
    set(uiSeriesPtr('get'), 'String', asSeries);
    set(uiFusedSeriesPtr('get'), 'String', asSeries);
    
    set(uiSeriesPtr('get'), 'Enable', 'on');

    set(uiSeriesPtr('get'), 'Value', numel(tInput));
    dicomMetaData('set', tInput(numel(tInput)).atDicomInfo);
    dicomBuffer('set', aBuffer);
    setQuantification(numel(tInput));

    tQuant = quantificationTemplate('get');
    tInput(numel(tInput)).tQuant = tQuant;
    inputTemplate('set', tInput);  

    clearDisplay();                       
    initDisplay(3); 

    initWindowLevel('set', true);

    dicomViewerCore();  
    
    setViewerDefaultColor(1, tInput(numel(tInput)).atDicomInfo);
  
    refreshImages();
    
    progressBar(1, sprintf('Import %s completed', sFileName));
  
    catch
        progressBar(1, 'Error:loadRawFile()');                        
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');            
    drawnow;
    

    progressBar(1, 'Ready');

end
