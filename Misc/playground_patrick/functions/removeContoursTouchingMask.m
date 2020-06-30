function contours = removeContoursTouchingMask(contours, mask) %% TODO
%REMOVECONTOURSTOUCHINGMASK Removes all contours from the passed set
%which touch the mask
    v = [-1,-1; 0,-1; 1,-1; -1,0; 0,0; 1,0; -1,1; 0,1; 1,1];
    delList = zeros(size(contours));
    for i = 1:size(contours, 1) % Go through all contours
        c = contours{i};
        
        for j = 1:size(c, 1)
            testSet = v + c(j, :);
            for k = 1:9
                if(mask(testSet(k, 1), testSet(k,2))) % Do sth. with this contour
                    delList(i) = 1;
                    break;
                end
            end
            if delList(i)
                break;
            end
        end
    end
    
    contours(delList) = [];
end

