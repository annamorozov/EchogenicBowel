function [bw_periphBonesMask, bw_maskBones_allAbdomen] = ...
    extractBonesMasks(imgAbdomen_contrast, bw_bowelMask,...
                      isShow, imgOrig, imgName, bw_abdomenMask)

%% Extract the bones masks (the brightest areas)
% Input:  imgAbdomen_contrast     - abdomen image with adjusted contrast 
%         bw_bowelMask            - bowel mask
%         isShow                  - show images for debugging 
%         imgOrig                 - the original image for display
%         imgName                 - image name for titles display
%         bw_abdomenMask          - abdomen circular mask
% Output: bw_periphBonesMask      - BW mask of the bones on the periphery:
%                                   inside the bowel area but outside the bowel
%         bw_maskBones_allAbdomen - BW mask of all the bones in the abdomen

% Extract the bones on the periphery - inside the abdomen mask but outside
% the bowel area
imgPeriphery_contrast = imgAbdomen_contrast;
imgPeriphery_contrast(bw_bowelMask) = 0;

% Find thresholds for 3 levels: dark, medium-gray and bright - the bones
thresh = multithresh(imgPeriphery_contrast,2);
imgPeriphery_segmented = imquantize(imgPeriphery_contrast,thresh);

% Bones are the brightest and have the highest level (3)
bw_periphBonesMask = (imgPeriphery_segmented == 3);

% Compute the periphery bones mean intensity
abdomenStats = regionprops('table', imgPeriphery_segmented, imgAbdomen_contrast, 'MeanIntensity');

% Define the threshold for bones in the bowel as the mean intensity of the
% periphery bones
thresh = abdomenStats.MeanIntensity(3);
bw_maskBones_allAbdomen = imbinarize(imgAbdomen_contrast, thresh/double(max(max(imgAbdomen_contrast))));

%% Display
if isShow
    figure;
    imshow(imgOrig);
    hold on;
    visboundaries(bw_maskBones_allAbdomen,'Color','g', 'LineWidth', 0.2, 'LineStyle', ':');
    hold on;
    visboundaries(bw_bowelMask,'Color','r', 'LineWidth', 0.2, 'LineStyle', '--');
    hold on;
    visboundaries(bw_abdomenMask,'Color','b', 'LineWidth', 0.2, 'LineStyle', '--');
    title(sprintf('Bones (green), abdomen (blue) and bowel (red) bounds, image %s',imgName));
end


