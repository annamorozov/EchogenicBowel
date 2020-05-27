function imgPropsForGradingTbl =...
    getPropsForGrading(imgOrig, bw_bowelMask, bw_periphBonesMask,...
    bw_darkBackgroundMask, bw_maskBones_allAbdomen, bw_BowelBlackHoles_mask)

%% Calculate the bowel images properties (potentially will be used as model predictors)
% The function computes the intensity weighted mean, median intensity and
% area (total number of pixels) for each one of the following regions:
% all the dark background pixels, all the bones (bright areas) on the periphery
% (within the abdomen circle but outside the bowel bound), bowel only (excluding
% all the bones and the black holes, area inside the bowel bound, and only dark
% holes within the bowel. 
% Here, the image is first normalized to values [0-1];
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
% Output: imgPropsForGradingTbl   - table with all the properties for each
%                                   region in the columns

%TODO: some code duplicated in gradeBowel

% Gauss filtering and contrast adjustment of the whole original image
imgOrig = rgb2gray(imgOrig);
imgOrig = rescale(imgOrig); % normalize the intensities to [0-1] (double)

imageOrig_gauss = imgaussfilt(imgOrig, 1);
imageOrig_gauss = imadjust(imageOrig_gauss);

% All the dark background pixels
[wMeanIntens_darkBckgr, medIntens_darkBckgr, totArea_darkBckgr] =...
    getMaskRegionProps(imageOrig_gauss, ~bw_darkBackgroundMask);

% All the bones (bright areas) on the periphery
% (within the abdomen circle but outside the bowel bound)
[wMeanIntens_periphBones, medIntens_periphBones, totArea_periphBones] =...
    getMaskRegionProps(imageOrig_gauss, bw_periphBonesMask);

% Mask for bowel only: inside the bowel mask, excluding all the bones and
% the black holes
bw_bowelOnlyMask = bw_bowelMask & (~bw_maskBones_allAbdomen) & (~bw_BowelBlackHoles_mask);

% All the pixels in the "clean" bowel
[wMeanIntens_onlyBowel, medIntens_onlyBowel, totArea_onlyBowel] =...
    getMaskRegionProps(imageOrig_gauss, bw_bowelOnlyMask);

% For extreme cases
% Area inside the bowel bound
[wMeanIntens_allBowel, medIntens_allBowel, totArea_allBowel] =...
    getMaskRegionProps(imageOrig_gauss, bw_bowelMask);

% Only dark holes within the bowel
[wMeanIntens_bowelHoles, medIntens_bowelHoles, totArea_bowelHoles] =...
    getMaskRegionProps(imageOrig_gauss, bw_BowelBlackHoles_mask);

% Only bones within the bowel
bw_bowelBones_mask = bw_bowelMask & bw_maskBones_allAbdomen;
[wMeanIntens_bonesBowel, medIntens_bonesBowel, totArea_bonesBowel]...
    = getMaskRegionProps(imageOrig_gauss, bw_bowelBones_mask);


imgPropsForGradingTbl = table(wMeanIntens_darkBckgr, medIntens_darkBckgr, totArea_darkBckgr,...
    wMeanIntens_periphBones, medIntens_periphBones, totArea_periphBones,...
    wMeanIntens_onlyBowel, medIntens_onlyBowel, totArea_onlyBowel,...
    wMeanIntens_allBowel, medIntens_allBowel, totArea_allBowel,...
    wMeanIntens_bowelHoles, medIntens_bowelHoles, totArea_bowelHoles,...
    wMeanIntens_bonesBowel, medIntens_bonesBowel, totArea_bonesBowel);

