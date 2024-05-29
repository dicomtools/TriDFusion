function setDisplayBuffer(dSeriesOffset)
%function setDisplayBuffer(dSeriesOffset)
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

    atInput = inputTemplate('get');

    aInputBuffer = cell(numel(atInput), 1);

    if ~isempty(dSeriesOffset)
        dFromLoop = dSeriesOffset;
        dToLoop   = dSeriesOffset;
    else
        dFromLoop = 1;
        dToLoop = numel(atInput);
    end

    for i=dFromLoop: dToLoop                                                                              

        if size(atInput(i).aDicomBuffer{1}, 4) == 1 
            aSize = size(atInput(i).aDicomBuffer{1});
    %        X(aSize(1), aSize(2), numel(atInput(i).asFilesList))=0;
    %        aInputBuffer{i} = gpuArray(X);
            if numel(aSize) == 2
                
                aInputBuffer{i} = single(zeros(aSize(1), aSize(2), numel(atInput(i).asFilesList)));

         %       aInputBuffer = dicomread(char(atInput(1).asFilesList(1)));

                 for ii=1: numel(atInput(i).asFilesList)

                     if ~isempty(atInput(i).aDicomBuffer{ii})
                       aInputBuffer{i}(:,:,ii) = atInput(i).aDicomBuffer{ii};

                        if atInput(i).atDicomInfo{ii}.RescaleSlope ~= 0
                            aInputBuffer{i}(:,:,ii) = atInput(i).atDicomInfo{ii}.RescaleIntercept + (aInputBuffer{i}(:,:,ii) * atInput(i).atDicomInfo{ii}.RescaleSlope);
                        else
                            if isfield(atInput(i).atDicomInfo{ii}, 'RealWorldValueMappingSequence') % SUV Spect
                                if atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope = atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aInputBuffer{i}(:,:,ii) = fIntercept + (aInputBuffer{i}(:,:,ii) * fSlope);                            
                                end                        
                            end                            
                        end
                    end
                 end  
            else
                 for ii=1: numel(atInput(i).asFilesList)

                    if ~isempty(atInput(i).aDicomBuffer{ii})

                        aInputBuffer{i} = single(atInput(i).aDicomBuffer{ii});

                        if atInput(i).atDicomInfo{ii}.RescaleSlope ~= 0
                            aInputBuffer{i} = atInput(i).atDicomInfo{ii}.RescaleIntercept + (aInputBuffer{i} * atInput(i).atDicomInfo{ii}.RescaleSlope);
                        else
                            if isfield(atInput(i).atDicomInfo{ii}, 'RealWorldValueMappingSequence') % SUV Spect
                                if atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope = atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = atInput(i).atDicomInfo{ii}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aInputBuffer{i} = fIntercept + (aInputBuffer{i} * fSlope);                            
                                end                        
                            end
                        end

                        if strcmpi(atInput(i).atDicomInfo{ii}.Modality, 'RTDOSE')
            
                            if isfield(atInput(i).atDicomInfo{ii}, 'DoseGridScaling')
            
                                if atInput(i).atDicomInfo{ii}.DoseGridScaling ~= 0
                                     aInputBuffer{i} = aInputBuffer{i} * atInput(i).atDicomInfo{ii}.DoseGridScaling;
                                end
            
                            end
                        end                        
                    end
                 end
            end
        else
%        X = atInput(1).aDicomBuffer{1};
%        aInputBuffer = atInput(1).aDicomBuffer{1};

            if strcmpi(atInput(i).atDicomInfo{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7') || ... % Secondary Capture Image IOD
               strcmpi(atInput(i).atDicomInfo{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7.4')     
      
                aInputBuffer{i} = atInput(i).aDicomBuffer{1};
            else
                aSize = size(atInput(i).aDicomBuffer{1});
              %  X(aSize(1), aSize(2), aSize(4))=0;
                aInputBuffer{i}(aSize(1), aSize(2), aSize(4))=0;
                aInputBuffer{i} = single(atInput(i).aDicomBuffer{1}(:,:,:));
    
                if isfield(atInput(i).atDicomInfo{1}, 'RescaleIntercept') && ...
                   isfield(atInput(i).atDicomInfo{1}, 'RescaleSlope')
                          
                    if atInput(i).atDicomInfo{1}.RescaleSlope ~= 0
                        aInputBuffer{i} = atInput(i).atDicomInfo{1}.RescaleIntercept + (aInputBuffer{i} * atInput(i).atDicomInfo{1}.RescaleSlope);
                    else
                        if isfield(atInput(i).atDicomInfo{1}, 'RealWorldValueMappingSequence') % SUV Spect
                            if atInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                fSlope     = atInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                fIntercept = atInput(i).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                aInputBuffer{i} = fIntercept + (aInputBuffer{i} * fSlope);                            
                            end                        
                        end
                    end
                end  
                
                if strcmpi(atInput(i).atDicomInfo{1}.Modality, 'RTDOSE')
    
                    if isfield(atInput(i).atDicomInfo{1}, 'DoseGridScaling')
    
                        if atInput(i).atDicomInfo{1}.DoseGridScaling ~= 0
                            aInputBuffer{i} = aInputBuffer{i} * atInput(i).atDicomInfo{1}.DoseGridScaling;
                        end
    
                    end
                end
            end

        end
        
% To reduce memory usage                
        atInput(i).aDicomBuffer = [];
% To reduce memory usage  

% % For image co-registration
% 
%         dSliceThickness = computeSliceSpacing(atInput(i).atDicomInfo);       
% 
%         dPixelSpacingX = atInput(i).atDicomInfo{1}.PixelSpacing(1);
%         dPixelSpacingY = atInput(i).atDicomInfo{1}.PixelSpacing(2);
% 
%         if dSliceThickness ~= 0 && dPixelSpacingX ~= 0 && dPixelSpacingY ~= 0  
% 
%             [Mdti,~] = TransformMatrix(atInput(i).atDicomInfo{1}, dSliceThickness);
% 
%             TF = affine3d(Mdti');
% 
%             if 1
%                [aInputBuffer{i}, ~] = imwarp(aInputBuffer{i}, TF, 'Interp', 'Nearest', 'FillValues', double(min(aInputBuffer{i},[],'all')), 'OutputView', imref3d(size(aInputBuffer{i})));  
%             else
% 
%                 % [aInputBuffer{i}, ~] = imwarp(aInputBuffer{i}, Rdcm, TF,'Interp', 'Nearest', 'FillValues', double(min(aInputBuffer{i},[],'all')));  
%             end
% 
%         end
% 
% % End For image co-registration

    end                
    

 %   if canUseGPU()    
 %       for mm=1:numel(aInputBuffer)
 %           aInputBuffer{mm} = uint16(aInputBuffer{mm});
 %       end
 %   end
    if isempty(dSeriesOffset)
    
        inputBuffer('set', aInputBuffer);
        
        for mm=1:numel(aInputBuffer)
    
            if size(aInputBuffer{mm}, 3) ~= 1
    
                aMip = computeMIP(gather(aInputBuffer{mm}));
        
                atInput(mm).aMip = aMip; 
            end
        end
        
    else
        aOldInputBuffer = inputBuffer('get');

        for mm=1:numel(atInput)

            if mm == dSeriesOffset
                
                if size(aInputBuffer{mm}, 3) ~= 1
        
                    aMip = computeMIP(gather(aInputBuffer{mm}));
            
                    atInput(mm).aMip = aMip; 
                end              
            else
                aInputBuffer{mm} = aOldInputBuffer{mm};
            end
        end

        inputBuffer('set', aInputBuffer);        
    end

    inputTemplate('set', atInput);
 
    progressBar(1, 'Ready'); 

end
