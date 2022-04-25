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

    [Mdti,Rdti] = TransformMatrix(info1, sliceThikness1);
    [Mtf,Rtf]   = TransformMatrix(info2, sliceThikness2);
    % First we transform into patient coordinates by multiplying by Mdti, and
    % then we convert again into image coordinates of the second volume by
    % multiplying by inv(Mtf)
    M =  inv(Mtf) * Mdti;
    Rot = inv(Rtf) * Rdti;
    M = M';

end