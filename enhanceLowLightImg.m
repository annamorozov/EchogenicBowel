function imgEnh = enhanceLowLightImg(imgOrig, isShow, imgName)

%% Enhance image with low light via haze reducing
% Input:  imgOrig - image to enhance
%         isShow  - show images for debugging 
%         imgName - image name for titles display
% Output: imgEnh  - enhanced image

% Invert the original image - shows the haze in areas with low light
imgInv = imcomplement(imgOrig);

% Reduce haze
imgInv_woHaze = imreducehaze(imgInv,'Method','approx','ContrastEnhancement','boost');
imgCompl = imcomplement(imgInv_woHaze);

% Remove noise from the enhanced image, preserve edges
imgEnh = imguidedfilter(imgCompl);

%% Display
if isShow
    figure
    montage({imgOrig, imgEnh});
    title(sprintf('Before and after enhancement for image %s', imgName));
end

