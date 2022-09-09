function drawsphereCallback(~, ~)

    atMetaData = dicomMetaData('get');
    aDicomBuffer = dicomBuffer('get');
    
    a=roiTemplate('get',1);

    ptrRoi = a{1};
    
    switch lower(ptrRoi.Axe) 
        case 'axes1'
            xPixelOffset = ptrRoi.Position(1);
            yPixelOffset = ptrRoi.SliceNb;
            zPixelOffset = ptrRoi.Position(2);            
        case 'axes2'
            xPixelOffset = ptrRoi.SliceNb;
            yPixelOffset = ptrRoi.Position(2);
            zPixelOffset = ptrRoi.Position(1);           
        case 'axes3'
            xPixelOffset = ptrRoi.Position(1);
            yPixelOffset = ptrRoi.Position(2);
            zPixelOffset = ptrRoi.SliceNb;
    end
    

    aSphereMask = zeros(size(aDicomBuffer)); 

    [x,y,z]=meshgrid(1:size(aSphereMask,1),1:size(aSphereMask,2),1:size(aSphereMask,3));

    dRadius=a{1}.Radius; %// e.g. radius=100;
    
    aSphereMask(sqrt((x-xPixelOffset).^2+(y-yPixelOffset).^2+(z-zPixelOffset).^2)<dRadius)=1;    
 
if 1    
    for zz=1:263       
        dRadius = numel(find(aSphereMask(:,:,zz)))/2;
        if dRadius ~=0
            sliceNumber('set', 'axial', zz);
            sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
            pRoi = drawcircle(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'Position', ptrRoi.Position, 'Radius', dRadius/atMetaData{1}.PixelSpacing(1), 'Color', 'red', 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'off', 'FaceSelectable', 1, 'FaceAlpha', roiFaceAlphaValue('get'));
            addRoi(pRoi, 1, 'Unspecified');
            
        end
    end
end    
      
%    maskToVoi(ROI, 'rrr', 'red', 'Axes3', 1, 0);


end