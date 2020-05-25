function bw_bowelMask = extractBowelMask(bw_abdomenMask, imgEnh,...
    isShow, imgOrig, imgName)

%% Extract the bowel mask (still containing bones and dark areas inside)
% Input:  bw_abdomenMask - abdomen circular mask  
%         imgEnh         - enhanced image
%         isShow         - show images for debugging 
%         imgOrig        - the original image for display
%         imgName        - image name for titles display
% Output: bw_bowelMask   - BW mask of the bowel outline


% Mask the enhanced img with the abdomen circle mask
imageEnh_abdomen = rgb2gray(imgEnh);
imageEnh_abdomen(~bw_abdomenMask) = 0;

bwAbdom = imbinarize(imageEnh_abdomen, 'adaptive');

% Compute the distance transform of the enhanced (binary) image 
bwAbdom_binDist = bwdist(~bwAbdom);

% Close small openings in the transform image before watershed segmentation
se = strel('disk',2);
bwAbdom_binDist = imclose(bwAbdom_binDist,se);

% Watershed segmentation of the abdomen area
labelsAbdom = watershed(bwAbdom_binDist, 8); 
labelsAbdom(~bwAbdom) = 0; 

if isShow
    figure;
    imshow(label2rgb(labelsAbdom,'jet','m'));
    title(sprintf('Img %s watershed segmentation, labels inside the abdomen', imgName));
end

% Mask out the biggest segment - the area between the abdomen circle and
% the bowel bound
lbl_mask = labelsAbdom;
lbl_mask(lbl_mask == 1) = 0;   
lbl_mask = logical(lbl_mask);

if isShow
    figure;
    imshow(lbl_mask, []);
    title(sprintf('Img %s labels mask after the outer label removal', imgName));
end

% Extract the bowel mask 
bound_mask = boundarymask(lbl_mask); 
bw_bowelMask = imfill(bound_mask,'holes');

if isShow
    figure
    imshow(imgOrig);
    hold on;
    visboundaries(bw_bowelMask,'Color','r', 'LineWidth', 0.5, 'LineStyle', '--');
    hold on;
    visboundaries(bw_abdomenMask,'Color','b', 'LineWidth', 0.5, 'LineStyle', '--');
    title(sprintf('Orig image %s with circle abdomen bound and bowel bound',imgName));
end


