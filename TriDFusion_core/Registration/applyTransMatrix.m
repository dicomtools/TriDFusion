%function  [outX, outY, outZ] = applyTransMatrix(transM, xV, yV, zV)
%Compute spatial coordinate using a transformation matrix. 
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

function [outX, outY, outZ] = applyTransMatrix(transM, xV, yV, zV)

    pointsM = [reshape(xV,[],1), reshape(yV,[],1) reshape(zV,[],1)]';    

    %Rotation.
    pointsM = transM(1:3,1:3) * pointsM;

    %Translation XY
    outX = pointsM(1,:) + transM(1,4);
    outY = pointsM(2,:) + transM(2,4);

    %Translation Z
    transM = transM'; % Patch for spect

    pointsM = [reshape(xV,[],1), reshape(yV,[],1) reshape(zV,[],1)]';         
    pointsM = transM(1:3,1:3) * pointsM;

    outZ = pointsM(3,:) + transM(3,4);

end