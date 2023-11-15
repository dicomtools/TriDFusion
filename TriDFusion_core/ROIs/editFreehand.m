function editFreehand(hf, he)

% Create a mask for the target freehand.
tmask = hf.createMask();
[m, n,~] = size(tmask);
% Include the boundary pixel locations
boundaryInd = sub2ind([m,n], hf.Position(:,2), hf.Position(:,1));
tmask(boundaryInd) = true;

% Create a mask from the editor ROI
emask = he.createMask();
boundaryInd = sub2ind([m,n], he.Position(:,2), he.Position(:,1));
emask(boundaryInd) = true;

% Check if center of the editor ROI is inside the target freehand. If you
% use a different editor ROI, ensure to update center computation.
center = he.Center; %
isAdd = hf.inROI(center(1), center(2));
if isAdd
    % Add the editor mask to the freehand mask
    newMask = tmask|emask;
else
    % Delete out the part of the freehand which intersects the editor
    newMask = tmask&~emask;
end

% Update the freehand ROI
perimPos = bwboundaries(newMask, 4, 'noholes');
hf.Position = [perimPos{1}(:,2), perimPos{1}(:,1)];

end