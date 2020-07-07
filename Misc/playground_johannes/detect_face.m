faceDetector = vision.CascadeObjectDetector();

%bbox_face = step(faceDetector, image);
[bbox_face,scores] = detect(faceDetector,image);
%scores = -1;


I = insertObjectAnnotation(image,'rectangle',bbox_face,scores);
figure
imshow(I)
title('Detected Face')    