
function [M,R] = TransformMatrix(info, sliceThikness, bT0CeterPixel)

    %This function calculates the 4x4 transform matrix from the image
    %coordinates to patient coordinates. 
    
    if info.PixelSpacing(1) == 0 || ...
       info.PixelSpacing(2) == 0 || ...
       sliceThikness == 0 
        M = eye(4);
        R = eye(4);
    else
        if isempty(info.ImageOrientationPatient(info.ImageOrientationPatient~=0))
            M = eye(4);
            R = eye(4);            
        else
            ipp=info.ImagePositionPatient;
            iop=info.ImageOrientationPatient;
            ps=info.PixelSpacing;
            Tipp=[1 0 0 ipp(1); ...
                  0 1 0 ipp(2); ...
                  0 0 1 ipp(3); ...
                  0 0 0 1];
            r=iop(1:3);  c=iop(4:6); s=cross(r',c');
            R = [r(1) c(1) s(1) 0; ...
                 r(2) c(2) s(2) 0; ...
                 r(3) c(3) s(3) 0; ...
                 0 0 0 1];
        %    if strcmpi(info.MRAcquisitionType, '3D') % 3D turboflash
        %        S = [ps(2) 0 0 0; 0 ps(1) 0 0; 0 0 sliceThikness 0 ; 0 0 0 1];
        %    else % 2D epi dti

                S = [ps(2) 0 0 0; ...
                     0 ps(1) 0 0; ...
                     0 0 sliceThikness 0; ...
                     0 0 0 1];
        %    end
            if bT0CeterPixel == true

                T0 = [1 0 0 -0.5;
                      0 1 0 -0.5;
                      0 0 1 -0.5;
                      0 0 0 1];                
            else
                T0 = [ 1 0 0 0; ...
                       0 1 0 0; ...
                       0 0 1 0; ...
                       0 0 0 1];
            end

            M = Tipp * R * S * T0;
        end
    end
end