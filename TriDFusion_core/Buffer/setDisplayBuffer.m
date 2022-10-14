function setDisplayBuffer()
%function setDisplayBuffer()
%Set DICOM Input DICOM Globals Function.
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

%       iInstanceNumber = 0;
    tInput = inputTemplate('get');
%        aInput = ''; 
    for i=1: numel(tInput)                                                                               
        if size(tInput(i).aDicomBuffer{1}, 4) == 1 
            aSize = size(tInput(i).aDicomBuffer{1});
    %        X(aSize(1), aSize(2), numel(tInput(i).asFilesList))=0;
    %        aInput{i} = gpuArray(X);
            if numel(aSize) == 2
                aInput{i}(aSize(1), aSize(2), numel(tInput(i).asFilesList))=0;

         %       aInput = dicomread(char(tInput(1).asFilesList(1)));

                 for ii=1: numel(tInput(i).asFilesList)

                     if ~isempty(tInput(i).aDicomBuffer{ii})
                       aInput{i}(:,:,ii) = tInput(i).aDicomBuffer{ii};

                        if tInput(i).atDicomInfo{ii}.RescaleSlope ~= 0
                            aInput{i}(:,:,ii) = tInput(i).atDicomInfo{ii}.RescaleIntercept + (aInput{i}(:,:,ii) * tInput(i).atDicomInfo{ii}.RescaleSlope);
                        else
                            if isfield(tInput(i).atDicomInfo{ii}, 'RealWorldValueMappingSequence') % SUV Spect
                                if tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope = tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aInput{i}(:,:,ii) = fIntercept + (double(aInput{i}(:,:,ii)) * fSlope);                            
                                end                        
                            end                            
                        end
                    end
                 end  
            else
                 for ii=1: numel(tInput(i).asFilesList)

                    if ~isempty(tInput(i).aDicomBuffer{ii})
                        aInput{i} = tInput(i).aDicomBuffer{ii};

                        if tInput(i).atDicomInfo{ii}.RescaleSlope ~= 0
                            aInput{i} = tInput(i).atDicomInfo{ii}.RescaleIntercept + (aInput{i} * tInput(i).atDicomInfo{ii}.RescaleSlope);
                        else
                            if isfield(tInput(i).atDicomInfo{ii}, 'RealWorldValueMappingSequence') % SUV Spect
                                if tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope = tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = tInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aInput{i} = fIntercept + (double(aInput{i}) * fSlope);                            
                                end                        
                            end
                        end
                    end
                 end
            end
        else
%        X = tInput(1).aDicomBuffer{1};
%        aInput = tInput(1).aDicomBuffer{1};

            aSize = size(tInput(i).aDicomBuffer{1});
          %  X(aSize(1), aSize(2), aSize(4))=0;
            aInput{i}(aSize(1), aSize(2), aSize(4))=0;
            aInput{i} = tInput(i).aDicomBuffer{1}(:,:,:);

            if isfield(tInput(i).atDicomInfo{1}, 'RescaleIntercept') && ...
               isfield(tInput(i).atDicomInfo{1}, 'RescaleSlope')
                      
                if tInput(i).atDicomInfo{1}.RescaleSlope ~= 0
                    aInput{i} = tInput(1).atDicomInfo{1}.RescaleIntercept + (aInput{i} * tInput(1).atDicomInfo{1}.RescaleSlope);
                else
                    if isfield(tInput(i).atDicomInfo{1}, 'RealWorldValueMappingSequence') % SUV Spect
                        if tInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                            fSlope     = tInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                            fIntercept = tInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                            aInput{i} = fIntercept + (double(aInput{i}) * fSlope);                            
                        end                        
                    end
                end
            end  
        end
    
    end                
    
 %   if canUseGPU()    
%        for mm=1:numel(aInput)
%            aInput{mm} = uint16(aInput{mm});
%        end
 %   end
    
    inputBuffer('set', aInput);

    dicomBuffer('set', aInput{1});                    
    
    for mm=1:numel(aInput)
        if size(aInput{mm}, 3) ~= 1
            aMip = computeMIP(gather(aInput{mm}));
            mipBuffer('set', aMip, mm);
            tInput(mm).aMip = aMip; 
        end
    end
    
    inputTemplate('set', tInput);
 
    progressBar(1, 'Ready'); 

end
