function bw_BowelBlackHoles_mask =...
    extractBowelBlackHoles(imgBowel_contrast, bw_bowelMask, isShow, imgOrig, imgName)

%% Find black holes in the bowel (the darkest areas)

% Input:  imgBowel_contrast       - bowel image with adjusted contrast 
%         bw_bowelMask            - bowel mask
%         isShow                  - show images for debugging 
%         imgOrig                 - the original image for display
%         imgName                 - image name for titles display
% Output: bw_BowelBlackHoles_mask - BW mask of the black holes in the bowel

% Adjusted contrast image masked with bowel mask
bw_Bowel_contrast = imbinarize(imgBowel_contrast); 

% Create mask from black image and bowel mask boundary in white
bowelBoundaries = bwboundaries(bw_bowelMask);  
bw_bowelBound_mask = false(size(bw_bowelMask));
for i = 1:length(bowelBoundaries)
    for j = 1:length(bowelBoundaries{i})
        ind = bowelBoundaries{i}(j,:);
        bw_bowelBound_mask(ind(1),ind(2))=1;
    end
end

% Close the bowel image with holes by the boundary
bw_bowelHoleMask_closed = imadd(bw_bowelBound_mask, bw_Bowel_contrast);

if isShow
    figure; 
    imshow(bw_bowelHoleMask_closed);
    title(sprintf('Bowel holes closed by the white boundary, img %s', imgName));
end

% Create mask of the holes only
bw_BowelBlackHoles_mask = xor(bw_bowelHoleMask_closed, imfill(bw_bowelHoleMask_closed, 'holes'));

%% Display
if isShow
    figure;
    imshow(imgOrig);
    hold on;
    visboundaries(bw_BowelBlackHoles_mask,'Color','g','LineWidth',0.2,'LineStyle','--');
    hold on;
    visboundaries(bw_bowelMask,'Color','r', 'LineWidth', 0.2, 'LineStyle', '--');
    title(sprintf('Original image %s with bowel black holes and bowel bounds', imgName));
end

