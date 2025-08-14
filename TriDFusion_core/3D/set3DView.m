function set3DView(viewer, azimuth, elevation)
% Change the camera line of sight
% set3DView(viewer, azimuth, elevation) changes the camera line of sight by
% setting a new camera position based on the azimuth and elevation angles
% specified in degrees.

%   Copyright 2022-2023 The MathWorks, Inc. 

cosAz = cosd(azimuth-90);
sinAz = sind(azimuth-90);

cosEl = cosd(elevation);
sinEl = sind(elevation);

cam2TargetDist = norm(viewer.CameraPosition - viewer.CameraTarget);
targetPos = viewer.CameraTarget;

x(1) = cam2TargetDist * cosEl * cosAz;
x(2) = cam2TargetDist * cosEl * sinAz;
x(3) = cam2TargetDist * sinEl;

cameraPos = x + targetPos;

viewer.CameraPosition = cameraPos;

if azimuth == 0 && (elevation == 90 || elevation == -90)
    viewer.CameraUpVector = [0 1 0];
else
    viewer.CameraUpVector = [0 0 1];
end

end