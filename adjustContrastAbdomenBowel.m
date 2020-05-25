function [imgAbdomen_contrast, imgBowel_contrast] =...
    adjustContrastAbdomenBowel(imgOrig, bw_abdomenMask, bw_bowelMask)

%% Filter and adjust contrast of abdomen area 

% Input:  imgOrig             - the original image
%         bw_abdomenMask      - abdomen mask
%         bw_bowelMask        - bowel mask
% Output: imgAbdomen_contrast - abdomen area image after filtering and
%                               contrast adjustment
%         imgBowel_contrast   - bowel area image after filtering and
%                               contrast adjustment

% Original img with abdomen circle mask
imgOrig_abdomen = rgb2gray(imgOrig);
imgOrig_abdomen(~bw_abdomenMask) = 0;

% Gauss filter 
imgAbdomen_gauss = imgaussfilt(imgOrig_abdomen, 1);

% Adjust the contrast - saturate top and bottom 1% intensities
imgAbdomen_contrast = imadjust(imgAbdomen_gauss);

imgBowel_contrast = imgAbdomen_contrast;
imgBowel_contrast(~bw_bowelMask) = 0;
