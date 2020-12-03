function [M,Rot] = getTransformMatrix(info1, sliceThikness1, info2, sliceThikness2)
% This function calculates the 4x4 transform and 3x3 rotation matrix 
% between two image coordinate system. 
% M=Tipp*R*S*T0;
% Tipp:translation
% R:rotation
% S:pixel spacing
% T0:translate to center(0,0,0) if necessary
% info1: dicominfo of 1st coordinate system
% info2: dicominfo of 2nd coordinate system
% Rot: rotation matrix between coordinate system
% Coded by Alper Yaman, Feb 2009
% Updated by Alper Yaman, Jan 2019

    [Mdti,Rdti] = TransMatrix(info1, sliceThikness1);
    [Mtf,Rtf] = TransMatrix(info2, sliceThikness2);
    % First we transform into patient coordinates by multiplying by Mdti, and
    % then we convert again into image coordinates of the second volume by
    % multiplying by inv(Mtf)
    M =  inv(Mtf) * Mdti;
    Rot = inv(Rtf) * Rdti;
    M = M';

    function [M,R] = TransMatrix(info, sliceThikness)

        %This function calculates the 4x4 transform matrix from the image
        %coordinates to patient coordinates. 
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
        %if info.MRAcquisitionType=='3D' % 3D turboflash
        %    S = [ps(2) 0 0 0; 0 ps(1) 0 0; 0 0 sliceThikness 0 ; 0 0 0 1];
        %else % 2D epi dti

            S = [ps(2) 0 0 0; ...
                 0 ps(1) 0 0; ...
                 0 0 sliceThikness 0; ...
                 0 0 0 1];
        %end
        T0 = [ 1 0 0 0; ...
               0 1 0 0; ...
               0 0 1 0; ...
               0 0 0 1];
        M = Tipp * R * S * T0;

    end
end