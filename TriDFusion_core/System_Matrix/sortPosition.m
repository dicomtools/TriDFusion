function [Posi, interval1, interval2] = sortPosition(ang, vet1, nRaios)

    findangle1 = find(ang>=0 & ang<=90 | ang>=180 & ang<=270);
    findangle2 = find(ang>90 & ang<180 | ang>270 & ang<360);
    
        
    if ~isempty(findangle1)
        interval1 = findangle1(1)*nRaios-(nRaios-1):findangle1(end)*nRaios;
        Posi(interval1,:,1)=sort(vet1(interval1,:,1),2);  
        Posi(interval1,:,2)=sort(vet1(interval1,:,2),2); 
    else
    end

    if ~isempty(findangle2)
        interval2 = findangle2(1)*nRaios-(nRaios-1):findangle2(end)*nRaios;
        Posi(interval2,:,1)=sort(vet1(interval2,:,1),2);  
        Posi(interval2,:,2)=sort(vet1(interval2,:,2),2,'descend'); 
    else
    end

    Q = sum(~isnan(Posi(interval2,:,2)),2);

    for i=1:length(Q)
        Posi(interval2(i),:,2) = circshift(Posi(interval2(i),:,2),[0 Q(i)]);
    end


end
