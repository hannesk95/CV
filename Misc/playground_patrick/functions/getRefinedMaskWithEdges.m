function [mask] = getRefinedMaskWithEdges(mask, edges, dir)
    switch dir
        %% From Left To Right
        case 1
            for i = 1:600
                j1 = 1;
                while(mask(i, j1) == 0 && j1 < 800-1)
                    j1 = j1 + 1;
                end
    
                j1 = j1-1;
                
                if (j1 < 1)
                    j1 = 1;
                end
    
                while(edges(i, j1) == 0 && j1 < 800-1)
                    j1 = j1+1;
                    mask(i, j1) = 0;
                end
            end
        %% From Right To Left
        case 2
            for i = 1:600
                j2 = 800;
                while(mask(i, j2) == 0 && j2 > 2)
                    j2 = j2 - 1;
                end
    
                j2 = j2 + 1;
            
                if j2 > 800
                    j2 = 800;
                end
    
                while(edges(i, j2) == 0 && j2 > 2)
                    j2 = j2 - 1;
                    mask(i, j2) = 0;
                end
            end
        %% From Top To Bottom
        case 3 
            for j = 1:800
                i = 1;
                while(mask(i, j) == 0 && i < 600-1)
                    i = i + 1;
                end
    
                i = i - 1;
            
                if i < 1
                    i = 1;
                end
    
                while(edges(i, j) == 0 && i < 600-1)
                    i = i + 1;
                    mask(i, j) = 0;
                end
            end
        
        %% From Bottom To Top
        case 4 
            for j = 1:800
                i = 600;
                while(mask(i, j) == 0 && i > 2)
                    i = i - 1;
                end
    
                i = i + 1;
            
                if i > 600
                    i = 600;
                end
    
                while(edges(i, j) == 0 && i > 2)
                    i = i - 1;
                    mask(i, j) = 0;
                end
            end
        
    end
end

