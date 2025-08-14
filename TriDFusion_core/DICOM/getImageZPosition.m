      
function [dFirstZ, dLastZ] = getImageZPosition(atDicomInfo, aImage)
    
    dFirstZ =[];
    dLastZ = [];

    aImageSize = size(aImage);

    if isscalar(atDicomInfo)


        if strcmpi(atDicomInfo{1}.Modality, 'RTDOSE')

            if ~isempty(atDicomInfo{1}.GridFrameOffsetVector)

                dNbFrames = numel(atDicomInfo{1}.GridFrameOffsetVector);
                
                if dNbFrames >1
                    dSpacing = abs(atDicomInfo{1}.GridFrameOffsetVector(2)-atDicomInfo{1}.GridFrameOffsetVector(1));
                else
                    dSpacing = 1;
                end
            else
                dSpacing =1;
            end

        else

            dSpacing = abs(atDicomInfo{1}.SpacingBetweenSlices);
            
            if dSpacing == 0
                dSpacing = 1;
            end
        end

        xyz1 = atDicomInfo{1}.ImagePositionPatient;
        pos1 = atDicomInfo{1}.ImageOrientationPatient;
        spa1 = atDicomInfo{1}.PixelSpacing;
        M1 = [ [pos1(1)*spa1(1) ; pos1(2)* spa1(1) ; pos1(3)*spa1(1) ; 0] ...
               [pos1(4)*spa1(2) ; pos1(5)* spa1(2) ; pos1(6)*spa1(2) ; 0] ...
               [0 ; 0 ; 0 ; 0] [xyz1(1) ; xyz1(2) ; xyz1(3) ; 0 ]       ];
        pxyzFirst = M1*[1 ; 1 ; 0 ; 1];


        sOrientation = getImageOrientation(atDicomInfo{1}.ImageOrientationPatient);

        if      strcmpi(sOrientation, 'Sagittal')
            dFirstZ = pxyzFirst(1);
            dLastZ = dFirstZ+(dSpacing*(aImageSize(1)-1));
        elseif  strcmpi(sOrientation, 'Coronal')
            dFirstZ = pxyzFirst(2);
            dLastZ = dFirstZ+(dSpacing*(aImageSize(2)-1));
        else    % Axial
            dFirstZ = pxyzFirst(3);
            dLastZ = dFirstZ+(dSpacing*(aImageSize(3)-1));
        end     

        bFlip = isImageFlipped(atDicomInfo{1});
        if bFlip == true
            dFlip = dFirstZ;
            dFirstZ = dLastZ;
            dLastZ = dFlip;
        end

    else

        for cc=1: numel(atDicomInfo)-1
    
            xyz1 = atDicomInfo{cc}.ImagePositionPatient;
            pos1 = atDicomInfo{cc}.ImageOrientationPatient;
            spa1 = atDicomInfo{cc}.PixelSpacing;
            M1 = [ [pos1(1)*spa1(1) ; pos1(2)* spa1(1) ; pos1(3)*spa1(1) ; 0] ...
                   [pos1(4)*spa1(2) ; pos1(5)* spa1(2) ; pos1(6)*spa1(2) ; 0] ...
                   [0 ; 0 ; 0 ; 0] [xyz1(1) ; xyz1(2) ; xyz1(3) ; 0 ]       ];
            pxyzFirst = M1*[1 ; 1 ; 0 ; 1];
    
    %               for i = 1:128 % row
    %                   for j = 1:128 % column
    %                       pxyz1 = M1*[i ; j ; 0 ; 1];
    %                       ijk1 = (M1'*M1+1E-10*eye(4))\M1'*pxyz1;
    %                   end
    %               end
    
            xyz2 = atDicomInfo{cc+1}.ImagePositionPatient;
            pos2 = atDicomInfo{cc+1}.ImageOrientationPatient;
            spa2 = atDicomInfo{cc+1}.PixelSpacing;
            M2 = [ [pos2(1)*spa2(1) ; pos2(2)* spa2(1) ; pos2(3)*spa1(1) ; 0] ...
                   [pos2(4)*spa2(2) ; pos2(5)* spa2(2) ; pos2(6)*spa1(2) ; 0] ...
                   [0 ; 0 ; 0 ; 0] [xyz2(1) ; xyz2(2) ; xyz2(3) ; 0 ]       ];
            pxyzLast = M2*[1 ; 1 ; 0 ; 1];
            
    %        pxyzLast - pxyzFirst
            
            sOrientation = getImageOrientation(atDicomInfo{cc}.ImageOrientationPatient);

            if isempty (dFirstZ)
                if      strcmpi(sOrientation, 'Sagittal')
                    dFirstZ = pxyzFirst(1);
                elseif  strcmpi(sOrientation, 'Coronal')
                    dFirstZ = pxyzFirst(2);
                else    % Axial
                    dFirstZ = pxyzFirst(3);
                end            
            end  

            if isempty (dLastZ)
                dLastZ = dFirstZ;         
            end  

            if      strcmpi(sOrientation, 'Sagittal')
                dLastZ = dLastZ + pxyzLast(1) - pxyzFirst(1);
            elseif  strcmpi(sOrientation, 'Coronal')
                dLastZ = dLastZ + pxyzLast(2) - pxyzFirst(2);
            else    % Axial
                dLastZ = dLastZ + pxyzLast(3) - pxyzFirst(3);
            end


        end

    end

end