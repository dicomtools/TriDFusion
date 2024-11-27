function [atRoi, transM] = resampleROIs(dcmImage, atDcmMetaData, refImage, atRefMetaData, atRoi, bUpdateObject)
%function  [atRoi, transM] = resampleROIs(dcmImage, atDcmMetaData, refImage, atRefMetaData, atRoi, bUpdateObject)
%Resample any ROIs.
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

    transM = [];

    aRefImageSize = size(refImage);

    for jj=1:numel(atRoi)
                
        [aNewPosition, aRadius, aSemiAxes, transM] = computeRoiScaledPosition(refImage, atRefMetaData, dcmImage, atDcmMetaData, atRoi{jj});
        
        if aRefImageSize(3) ~= 1       

            if round(aNewPosition(1,3)) > aRefImageSize(3)
                
                aNewPosition(:,3) = aRefImageSize(3);
            end
        end
        
        if ~isempty(atRoi{jj}.MaxDistances) 
            
            if isvalid(atRoi{jj}.MaxDistances.MaxXY.Line)

                atRoi{jj}.MaxDistances.MaxXY.Line.Visible = 'off';
                atRoi{jj}.MaxDistances.MaxCY.Line.Visible = 'off';
            end

            if isvalid(atRoi{jj}.MaxDistances.MaxXY.Text)

                atRoi{jj}.MaxDistances.MaxXY.Text.Visible = 'off';
                atRoi{jj}.MaxDistances.MaxCY.Text.Visible = 'off';                        
            end
        end 

        switch lower( atRoi{jj}.Type)

            case lower('images.roi.circle')

                switch lower( atRoi{jj}.Axe)

                    case 'axes1'

                         atRoi{jj}.Position = [];

                        progressBar(1, 'Error: Copy of a circle from a coronal plane is not yet supported!');
%                        msgbox('Error: copyRoiVoiToSerie(): Copy of a circle from a coronal plane is not yet supported!', 'Error');

                    case 'axes2'

                         atRoi{jj}.Position = [];

                        progressBar(1, 'Error: Copy of a circle from a sagitttal plane is not yet supported!');
%                        msgbox('Error: copyRoiVoiToSerie(): Copy of a circle from a sagitttal plane is not yet supported!', 'Error');

                    otherwise

                         atRoi{jj}.Position(:,1) = aNewPosition(:, 1);
                         atRoi{jj}.Position(:,2) = aNewPosition(:, 2);
                         atRoi{jj}.SliceNb       = round(aNewPosition(1,3));
                         atRoi{jj}.Radius        = aRadius;
                         
                         if ~isstruct(atRoi{jj}.Object)

                             if isvalid(atRoi{jj}.Object) && bUpdateObject == true

                                 atRoi{jj}.Object.Position = atRoi{jj}.Position;
                                 atRoi{jj}.Object.Radius   = atRoi{jj}.Radius;
                                 atRoi{jj}.Vertices        = atRoi{jj}.Object.Vertices;
                            end
                         end
                         
                         tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoi{jj}, false, false);
                         atRoi{jj}.MaxDistances = tMaxDistances;                       
                end


            case lower('images.roi.ellipse')

                switch lower( atRoi{jj}.Axe)

                    case 'axes1'

                         atRoi{jj}.Position = [];

                        progressBar(1, 'Error: Copy of an ellipse from a coronal plane is not yet supported!');
%                        msgbox('Error: copyRoiVoiToSerie(): Copy of an ellipse from a coronal plane is not yet supported!', 'Error');


                    case 'axes2'

                         atRoi{jj}.Position = [];

                        progressBar(1, 'Error: Copy of an ellipse from a sagittal plane is not yet supported!');
%                        msgbox('Error: copyRoiVoiToSerie(): Copy of an sagittal from a coronal plane is not yet supported!', 'Error');

                    otherwise

                         atRoi{jj}.Position(:,1) = aNewPosition(:, 1);
                         atRoi{jj}.Position(:,2) = aNewPosition(:, 2);
                         atRoi{jj}.SliceNb       = round(aNewPosition(1,3));
                         atRoi{jj}.SemiAxes      = aSemiAxes;
                                          
                         if ~isstruct(atRoi{jj}.Object)

                             if isvalid(atRoi{jj}.Object) && bUpdateObject == true                

                                atRoi{jj}.Object.Position = atRoi{jj}.Position;
                                atRoi{jj}.Object.SemiAxes = atRoi{jj}.SemiAxes;
                                atRoi{jj}.Vertices        = atRoi{jj}.Object.Vertices;
                             end
                         end

                         tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoi{jj}, false, false);
                         atRoi{jj}.MaxDistances = tMaxDistances;

                end

            case lower('images.roi.rectangle')

                 atRoi{jj}.Position(1) = aNewPosition(1);
                 atRoi{jj}.Position(2) = aNewPosition(2);
                 atRoi{jj}.Position(3) = aNewPosition(3);
                 atRoi{jj}.Position(4) = aNewPosition(4);
                 atRoi{jj}.SliceNb     = round(aNewPosition(5));
                 
                 xs = [aNewPosition(1) aNewPosition(1)+aNewPosition(3) aNewPosition(1)+aNewPosition(3) aNewPosition(1)];
                 ys = [aNewPosition(2) aNewPosition(2) aNewPosition(2)+aNewPosition(4) aNewPosition(2)+aNewPosition(4)];
                 atRoi{jj}.Vertices    = [xs' ys'];
                 
                 if ~isstruct(atRoi{jj}.Object)

                     if isvalid(atRoi{jj}.Object) && bUpdateObject == true                                 

                        atRoi{jj}.Object.Position = atRoi{jj}.Position;
                        atRoi{jj}.Vertices        = atRoi{jj}.Object.Vertices;
                     end
                 end

                 tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoi{jj}, false, false);
                 atRoi{jj}.MaxDistances = tMaxDistances;

            otherwise
                 atRoi{jj}.Position(:,1) = aNewPosition(:, 1);
                 atRoi{jj}.Position(:,2) = aNewPosition(:, 2);
                 atRoi{jj}.SliceNb       = round(aNewPosition(1,3));
                 
                 tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoi{jj}, false, false);
                 atRoi{jj}.MaxDistances = tMaxDistances;
                
                 if ~isstruct(atRoi{jj}.Object)

                     if isvalid(atRoi{jj}.Object) && bUpdateObject == true                                  

                        atRoi{jj}.Object.Position = atRoi{jj}.Position;
                     end                
                 end
        end        
             
    end

end
