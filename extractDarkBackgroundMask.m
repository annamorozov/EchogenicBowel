function bw_darkBackgroundMask = extractDarkBackgroundMask(imgEnh, isShow, imgName)

%% Find the mask for black (or very dark) background (fluids, very prominent acoustic shawods etc.)
% Input:  imgEnh                 - enhanced image
%         isShow                 - show images for debugging 
%         imgName                - image name for titles display
% Output: bw_darkBackgroundMask  - mask with 1 in the foreground and 0 in
%                                  the background

bw_darkBackgroundMask = imbinarize(rgb2gray(imgEnh));

%TODO: 
% We want only the actual background and not the upper corners of the
% image with completely no signal and absolutely black pixels (properties of
% the US images). These corners need to be masked out and not included in
% this background mask.

%% Display
if isShow
    figure
    montage({imgEnh, bw_darkBackgroundMask});
    title(sprintf('Enhanced image %s and its mask for dark background', imgName));
end
