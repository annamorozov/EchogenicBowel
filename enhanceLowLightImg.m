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

% Low-light images can have high noise levels. Enhancing low-light images can increase this noise level. Denoising can be a useful post-processing step.
% filters input image A under self-guidance, using A itself as the guidance image. This can be used for edge-preserving smoothing of image A.

imgEnh = imguidedfilter(imgCompl);

%% Display
if isShow
    figure
    montage({imgOrig, imgEnh});
    title(sprintf('Before and after enhancement for image %s', imgName));
end

