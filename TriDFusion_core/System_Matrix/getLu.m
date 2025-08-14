function Lu = getLu(Posi, Lu, det, Raio, interval1, interval2)


xWorldLimits = [-Raio Raio];
yWorldLimits =  [-Raio Raio];

Lu(interval1,:,1,det) = floor(round((axes2pix(size(Posi,2)/2,xWorldLimits,Posi(interval1,:,1))),10));
Lu(interval1,:,2,det) = floor(round((axes2pix(size(Posi,2)/2,yWorldLimits,Posi(interval1,:,2))),10));

Lu(interval2,:,1,det) = floor(round((axes2pix(size(Posi,2)/2,xWorldLimits,Posi(interval2,:,1))),10)); 
Lu(interval2,:,2,det) = ceil(round((axes2pix(size(Posi,2)/2,yWorldLimits,Posi(interval2,:,2))),10));

% [Q1,~] = find(Lu(:,1,2,det)==129);


end