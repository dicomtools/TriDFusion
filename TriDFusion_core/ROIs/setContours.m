function setContours()
%function setContours()
%Set Contours to Input Template.
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

    atInput    = inputTemplate('get');
    atContours = inputContours('get');
    aBuffer    =  inputBuffer('get');
     
    if isempty(atContours)
        return;
    end

    for bb=1:numel(atInput)
        
        mask = zeros(size(aBuffer{bb}));

        for cc=1:numel(atContours)
            
            for dd=1:numel(atContours{cc})
                
                if strcmpi(atInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Find matching series
                           atContours{cc}(dd).Referenced.SeriesInstanceUID)
if 0                    
                    for ee=1:numel(atContours{cc}(dd).Referenced.SOP)
                        for ff=1:numel(atInput(bb).atDicomInfo)
                            if strcmpi(atContours{cc}(dd).Referenced.SOP(ee).SOPInstanceUID, ...
                                       atInput(bb).atDicomInfo{ff}.SOPInstanceUID)
                                mask(:,:,ff)
                            end
                        end
                    end
end
if 0                       
                    segments = atContours{cc}(dd).ContourData;   
                    
                    xfm = getAffineXfm(atInput(bb).atDicomInfo);
                    
                    for j=1:numel(segments)
                        out = pctransform(pointCloud(segments{j}),invert(affine3d(xfm')));
                        points{j} = [round(out.Location(:,1)) round(out.Location(:,2))] ;
                        z = round(out.Location(:,3));
                        ROI.Position = [points{j}(:,1), points{j}(:,2)];
                        aRoiPosition = ROI.Position;
                        
                        axRoi = axes3Ptr('get');
                        aColor = atContours{cc}(dd).Color;
                        sliceNumber('set', 'axial', z);
                        B = ROI.Position;
                        sTag = sprintf('%s-%d/%d', atContours{cc}(dd).ROIName, j, numel(segments));
                        
                        pRoi = drawfreehand(axRoi, 'Position',flip(B{1}, 2), 'Color', [aColor], 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'off');                          
                        
                    end

       
                     
                    maskToVoi(aMask, atContours{cc}(dd).ROIName, atContours{cc}(dd).Color);      
end                   
                end
            end
        end
    end
    
    
    
    
    function A = getAffineXfm(headers)
    % Constants
    N = length(headers);
    dr = headers{1}.PixelSpacing(1);
    dc = headers{1}.PixelSpacing(2);
    F(:,1) = headers{1}.ImageOrientationPatient(1:3);
    F(:,2) = headers{1}.ImageOrientationPatient(4:6);
    T1 = headers{1}.ImagePositionPatient;
    TN = headers{end}.ImagePositionPatient;
    k = (T1 - TN) ./ (1 - N);
    % Build affine transformation
    A = [[F(1,1)*dr F(1,2)*dc k(1) T1(1)]; ...
        [F(2,1)*dr F(2,2)*dc k(2) T1(2)]; ...
        [F(3,1)*dr F(3,2)*dc k(3) T1(3)]; ...
        [0         0         0    1    ]];
    end    
end 