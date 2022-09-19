function aSphereMask = getSphereMask(aDicomBuffer, xPixelOffset, yPixelOffset, zPixelOffset, dRadius)
                       
    aSphereMask = zeros(size(aDicomBuffer)); 

    [x,y,z] = meshgrid(1:size(aSphereMask,1),1:size(aSphereMask,2),1:size(aSphereMask,3));
   
    aSphereMask(sqrt((x-xPixelOffset).^2+(y-yPixelOffset).^2+(z-zPixelOffset).^2) < dRadius) = 1;    
end