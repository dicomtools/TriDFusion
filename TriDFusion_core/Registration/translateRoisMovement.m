function atRoiInput = translateRoisMovement(atRoiInput, refImage, atRefMetaData, aOffset, bUpdateObject)

    for jj=1:numel(atRoiInput)
                        
        if roiHasMaxDistances(atRoiInput{jj}) == true
            
            atRoiInput{jj}.MaxDistances.MaxXY.Line.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxCY.Line.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxXY.Text.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxCY.Text.Visible = 'off';                                    
        end 

        switch lower( atRoiInput{jj}.Axe)

            case 'axe'

                atRoiInput{jj}.Position(:,1) = atRoiInput{jj}.Position(:,1) + aOffset(1);
                atRoiInput{jj}.Position(:,2) = atRoiInput{jj}.Position(:,2) + aOffset(2);

            case 'axes1'

                atRoiInput{jj}.Position(:,1) = atRoiInput{jj}.Position(:,1) + aOffset(2);
                atRoiInput{jj}.Position(:,2) = atRoiInput{jj}.Position(:,2) + aOffset(3);
                atRoiInput{jj}.SliceNb       = atRoiInput{jj}.SliceNb + round(aOffset(1));

            case 'axes2'

                atRoiInput{jj}.Position(:,1) = atRoiInput{jj}.Position(:,1) + aOffset(1);
                atRoiInput{jj}.Position(:,2) = atRoiInput{jj}.Position(:,2) + aOffset(3);
                atRoiInput{jj}.SliceNb       = atRoiInput{jj}.SliceNb + round(aOffset(2));

            otherwise
               
                atRoiInput{jj}.Position(:,1) = atRoiInput{jj}.Position(:,1) + aOffset(1);
                atRoiInput{jj}.Position(:,2) = atRoiInput{jj}.Position(:,2) + aOffset(2);
                atRoiInput{jj}.SliceNb       = atRoiInput{jj}.SliceNb + round(aOffset(3));
        end
       
        if roiHasMaxDistances(atRoiInput{jj}) == true
            
            tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoiInput{jj}, false, false);
            atRoiInput{jj}.MaxDistances = tMaxDistances;
        end

        if ~isstruct(atRoiInput{jj}.Object)
        
            if isvalid(atRoiInput{jj}.Object) && bUpdateObject == true                                  
            
                atRoiInput{jj}.Object.Position = atRoiInput{jj}.Position;

                if isfield(atRoiInput{jj}, 'Vertices')

                    atRoiInput{jj}.Vertices = atRoiInput{jj}.Object.Vertices;
                end
            end                
        end
        
    end
end