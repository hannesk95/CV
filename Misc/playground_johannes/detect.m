

function [bb] = detect(image)
    detector = peopleDetectorACF;
    [bboxes,scores] = detect(detector,image);
    
    I = insertObjectAnnotation(image,'rectangle',bboxes,scores);
    figure
    imshow(I)
    title('Detected People and Detection Scores')    
end



