function bFlip = isDicomImageFlipped(info)

    bFlip = false;
    
    if isempty(info)
        return;
    end
    
    if  numel(info) ~= 1 

        tDicomInfo1 = info{1}; 
        tDicomInfo2 = info{2}; 

        xyz1 = tDicomInfo1.ImagePositionPatient;
        pos1 = tDicomInfo1.ImageOrientationPatient;
        spa1 = tDicomInfo1.PixelSpacing;
        M1 = [ [pos1(1)*spa1(1) ; pos1(2)* spa1(1) ; pos1(3)*spa1(1) ; 0] ...
               [pos1(4)*spa1(2) ; pos1(5)* spa1(2) ; pos1(6)*spa1(2) ; 0] ...
               [0 ; 0 ; 0 ; 0] [xyz1(1) ; xyz1(2) ; xyz1(3) ; 0 ]       ];
        pxyzFirst = M1*[1 ; 1 ; 0 ; 1];

        xyz2 = tDicomInfo2.ImagePositionPatient;
        pos2 = tDicomInfo2.ImageOrientationPatient;
        spa2 = tDicomInfo2.PixelSpacing;
        M2 = [ [pos2(1)*spa2(1) ; pos2(2)* spa2(1) ; pos2(3)*spa1(1) ; 0] ...
               [pos2(4)*spa2(2) ; pos2(5)* spa2(2) ; pos2(6)*spa1(2) ; 0] ...
               [0 ; 0 ; 0 ; 0] [xyz2(1) ; xyz2(2) ; xyz2(3) ; 0 ]       ];
        pxyzLast = M2*[1 ; 1 ; 0 ; 1];

        sOrientation = getImageOrientation(tDicomInfo1.ImageOrientationPatient);

        if      strcmpi(sOrientation, 'Sagittal')
            dSpacingBetweenSlices = (pxyzLast(1) - pxyzFirst(1));

        elseif  strcmpi(sOrientation, 'Coronal')

            dSpacingBetweenSlices = (pxyzLast(2) - pxyzFirst(2));
        else    % Axial

            dSpacingBetweenSlices = (pxyzLast(3) - pxyzFirst(3));
        end

        if dSpacingBetweenSlices > 0

            bFlip = true;
        end
    else
        
        tDicomInfo1 = info{1};

        sOrientation = getImageOrientation(tDicomInfo1.ImageOrientationPatient);

        if strcmpi(tDicomInfo1.Modality, 'RTDOSE')

            if ~isempty(tDicomInfo1.GridFrameOffsetVector)

                dNbFrames = numel(tDicomInfo1.GridFrameOffsetVector);
                
                if dNbFrames >1            
                    dSpacingBetweenSlices = tDicomInfo1.GridFrameOffsetVector(2)-tDicomInfo1.GridFrameOffsetVector(1);
                else
                    dSpacingBetweenSlices = 0;
                end
            else
                dSpacingBetweenSlices =0;
            end
        else
            dSpacingBetweenSlices = tDicomInfo1.SpacingBetweenSlices;
        end


        if      strcmpi(sOrientation, 'Sagittal')

            dCurrentLocation = tDicomInfo1.ImagePositionPatient(1);
            dNextLocation = dCurrentLocation-dSpacingBetweenSlices;

        elseif  strcmpi(sOrientation, 'Coronal')

            dCurrentLocation = tDicomInfo1.ImagePositionPatient(2);
            dNextLocation = dCurrentLocation-dSpacingBetweenSlices;

        else    % Axial
            dCurrentLocation = tDicomInfo1.ImagePositionPatient(3);
            dNextLocation = dCurrentLocation-dSpacingBetweenSlices;
        end

        if dCurrentLocation > dNextLocation  
            
            bFlip = true;
        end

    end
end