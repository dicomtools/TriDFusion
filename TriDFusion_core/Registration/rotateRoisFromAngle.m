function atRoiInput = rotateRoisFromAngle(atRoiInput, refImage, atRefMetaData, dRotation, sAxe ,bUpdateObject)

    aImageSize = size(refImage);

    switch lower(sAxe)

        case 'axe' % 2D

            xSize = aImageSize(1);
            ySize = aImageSize(2);

        case 'axes1' % Coronal

            xSize = aImageSize(2);
            ySize = aImageSize(3);

        case 'axes2' % Sagittal

            xSize = aImageSize(1);
            ySize = aImageSize(3);

        case 'axes3' % Axial

            xSize = aImageSize(1);
            ySize = aImageSize(2);

        otherwise
            return;
    end

    theta = deg2rad(-dRotation); % Rotation in degrees
    
    % Rotation matrices 
    R = [cos(theta), -sin(theta);
         sin(theta),  cos(theta)];

    for jj=1:numel(atRoiInput)
                                
        if roiHasMaxDistances(atRoiInput{jj}) == true
        
            atRoiInput{jj}.MaxDistances.MaxXY.Line.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxCY.Line.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxXY.Text.Visible = 'off';
            atRoiInput{jj}.MaxDistances.MaxCY.Text.Visible = 'off';                        
        end
     
        aCoords = atRoiInput{jj}.Position(:, 1:2); % Extract X, Y coordinates
        
        aCenter = [xSize/2, ySize/2];     

        aTranslatedCoords = aCoords - aCenter; % Translate points to align image center with origin
        
        aRotatedCoords = (R * aTranslatedCoords')'; % Apply the rotation matrix
        
        aFinalCoords = aRotatedCoords + aCenter; % Translate points back to original position

        switch lower( atRoiInput{jj}.Type)

            case 'images.roi.rectangle'
                    
                if strcmpi(atRoiInput{jj}.Axe, sAxe)

                    % atRoiInput{jj}.Position(:, 1:2) = aFinalCoords; % Update ROI positions

                    atRoiInput{jj}.Rotatable = true;
                    atRoiInput{jj}.RotationAngle = atRoiInput{jj}.RotationAngle + dRotation;

                    if roiHasMaxDistances(atRoiInput{jj}) == true
     
                        tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoiInput{jj}, false, false);
                        atRoiInput{jj}.MaxDistances = tMaxDistances;
                    end
    
                    if ~isstruct(atRoiInput{jj}.Object)
    
                        if isvalid(atRoiInput{jj}.Object) && bUpdateObject == true                                  
    
                            atRoiInput{jj}.Object.Position      = atRoiInput{jj}.Position;
                            atRoiInput{jj}.Object.Rotatable     = atRoiInput{jj}.Rotatable;
                            atRoiInput{jj}.Object.RotationAngle = atRoiInput{jj}.RotationAngle;
    
                            if isfield(atRoiInput{jj}, 'Vertices')
    
                                atRoiInput{jj}.Vertices = atRoiInput{jj}.Object.Vertices;
                            end
                        end                
                    end
                end

             case 'images.roi.ellipse'

                if strcmpi(atRoiInput{jj}.Axe, sAxe)

                    atRoiInput{jj}.Position(:, 1:2) = aFinalCoords; % Update ROI positions

                    atRoiInput{jj}.RotationAngle = atRoiInput{jj}.RotationAngle + dRotation;

                    if roiHasMaxDistances(atRoiInput{jj}) == true
  
                        tMaxDistances = computeRoiFarthestPoint(refImage, atRefMetaData, atRoiInput{jj}, false, false);
                        atRoiInput{jj}.MaxDistances = tMaxDistances;
                    end

                    if ~isstruct(atRoiInput{jj}.Object)
    
                        if isvalid(atRoiInput{jj}.Object) && bUpdateObject == true                                  
    
                            atRoiInput{jj}.Object.Position = atRoiInput{jj}.Position;
                            atRoiInput{jj}.Object.RotationAngle = atRoiInput{jj}.RotationAngle;
    
                            if isfield(atRoiInput{jj}, 'Vertices')
    
                                atRoiInput{jj}.Vertices = atRoiInput{jj}.Object.Vertices;
                            end
                        end                
                    end
                end

             otherwise
                

                if strcmpi(atRoiInput{jj}.Axe, sAxe)
                    
                    atRoiInput{jj}.Position(:, 1:2) = aFinalCoords; % Update ROI positions

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
    end
end