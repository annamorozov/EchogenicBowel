function grade = gradeBowel(imgOrig, bw_bowelMask, bw_periphBonesMask,...
    bw_darkBackgroundMask, bw_maskBones_allAbdomen, bw_BowelBlackHoles_mask,...
    isShow, imgName)

%% Calculate the bowel echogenicity grading
% The function computes the mean weighted intensity of the bones on the
% abdomen periphery (within the abdomen circle but outside the bowel
% bound), and of the dark background (surroundings as amniotic fluid). 
% These means are used as references for the minimal grade
% (0 - dark as amniotic fluid) and maximal grade (6 - bright as the bones
% on the periphery), correspondingly. The range between them divided
% uniformly to intermidiate segments that correspond to the other grades
% (1-5). Bones and black holes are cleaned from the bowel, its mean
% intensity is computed and compared to the segments within the whole range. 
% The grade is deduced according to the closest segment to the bowel mean
% intensity. 
% Extreme cases: if most (more than a defined threshold) of the area inside
% the bowel boundary is segmented as bones, grade "6" will be assigned. 
% If most of the area inside the bowel boundary is segmented as fluids (dark holes),
% the assigned grade will be "0". The default area threshold is 0.5;
%
% Input:  imgOrig                 - the original image
%         bw_bowelMask            - bowel mask
%         bw_periphBonesMask      - mask of the bones on the periphery:
%                                   inside the bowel area but outside the bowel
%         bw_darkBackgroundMask   - mask of dark image areas (as amniotic fluid)
%                                   with 1 in the foreground and 0 in
%                                   the background
%         bw_maskBones_allAbdomen - mask of all the bones in the abdomen
%         bw_BowelBlackHoles_mask - mask of the black holes in the bowel
%         isShow                  - show images for debugging 
%         imgName                 - image name for titles display
% Output: grade                   - number 0-6 (0 - dark as amniotic fluid, 
%                                   6 - bright as the bones)       


% Gauss filtering and contrast adjustment of the whole original image
imgOrig = rgb2gray(imgOrig);
imageOrig_gauss = imgaussfilt(imgOrig, 1);
imageOrig_gauss = imadjust(imageOrig_gauss);

% Weighted mean of all the dark background pixels
wMeanIntens_darkBckgr = getMaskRegionProps(imageOrig_gauss, ~bw_darkBackgroundMask);

% Weighted mean of all the bones (bright areas) on the periphery
% (within the abdomen circle but outside the bowel bound)
wMeanIntens_periphBones = getMaskRegionProps(imageOrig_gauss, bw_periphBonesMask);

% Mask for bowel only: inside the bowel mask, excluding all the bones and
% the black holes
bw_bowelOnlyMask = bw_bowelMask & (~bw_maskBones_allAbdomen) & (~bw_BowelBlackHoles_mask);

% Weighted mean of all the pixels in the "clean" bowel
[wMeanIntens_onlyBowel] = getMaskRegionProps(imageOrig_gauss, bw_bowelOnlyMask);

% For extreme cases
% Area inside the bowel bound
[~, ~, allBowelArea] = getMaskRegionProps(imageOrig_gauss, bw_bowelMask);

% Only dark holes within the bowel
[~, ~, bowelHolesArea] = getMaskRegionProps(imageOrig_gauss, bw_BowelBlackHoles_mask);

% Only bones within the bowel
bw_bowelBones_mask = bw_bowelMask & bw_maskBones_allAbdomen;
[~, ~, bonesBowelArea] = getMaskRegionProps(imageOrig_gauss, bw_bowelBones_mask);
    
% The range between the mean maximum reference-intensity (bones on the
% periphery: within the abdomen but outside the bowel outline), and the 
% mean minimum reference-intensity (the dark background as amniotic fluid)
range = wMeanIntens_periphBones - wMeanIntens_darkBckgr;

% Array of means with 7 segments (0-6)
segmentLen = range/6;
segMeans = zeros(7,1);
segMeans(1) = wMeanIntens_darkBckgr;

for i=2:length(segMeans)
    segMeans(i) = segMeans(1)+segmentLen*(i-1);
end

% Find the segment with the closest mean
[~, closestIndex] = min(abs(segMeans - double(wMeanIntens_onlyBowel)));
closestValue = segMeans(closestIndex);

grade = closestIndex-1;

% Threshold for extreme cases
bowelThresh = 0.5; 
bowelAreaThres = allBowelArea*bowelThresh;

% Most (more than the threshold) of the bowel area is segmented as bones
if bonesBowelArea > bowelAreaThres
    grade = 6;
end

% Most (more than the threshold) of the bowel area is segmented as fluid (dark holes)
if bowelHolesArea > bowelAreaThres
    grade = 0;
end

%% Display
if isShow
    figure;
    imshow(imgOrig);
    hold on;
    visboundaries(bw_maskBones_allAbdomen,'Color','g', 'LineWidth', 0.2, 'LineStyle', '--');
    hold on;
    visboundaries(bw_bowelMask,'Color','r', 'LineWidth', 0.2, 'LineStyle', '--');
    hold on;
    visboundaries(bw_BowelBlackHoles_mask,'Color','b', 'LineWidth', 0.2, 'LineStyle', '--');
    title(sprintf('Bones (green), black holes (blue) and bowel (red) bounds, image %s',imgName));
end

