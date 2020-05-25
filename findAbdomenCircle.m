function [bw_abdomenMask, center, rad] = findAbdomenCircle(imgEnh, isShow, imgOrig, imgName)

%% Find the abdomen circular outline
% Input:  imgEnh         - enhanced image
%         isShow         - show images for debugging 
%         imgOrig        - the original image for display
%         imgName        - image name for titles display
% Output: bw_abdomenMask - BW mask of the abdomen circular outline 
%         center         - center coordinates of the strongest circle
%         rad            - radius length of the strongest circle

imgEnh = rgb2gray(imgEnh);

% Compute the gradient magnitude and normalize it
Gmag_enh = imgradient(imgEnh,'prewitt');

Gmag_enh=Gmag_enh-min(Gmag_enh(:)); % shift data such that the smallest element is 0
Gmag_enh=Gmag_enh/max(Gmag_enh(:)); % normalize the shifted data to 1 

bw_Gmag = imbinarize(Gmag_enh, 'adaptive');

% Find circles using Hough transform, use relatively loose parameters
[centers,radii] = imfindcircles(bw_Gmag,[80 180],'ObjectPolarity','bright',...
 'Sensitivity',0.95,'EdgeThreshold',0.2);

center = centers(1,:);
rad = radii(1);

fig = figure;
imshow(imgEnh);
circ = drawcircle('Center',center,'Radius',rad);
bw_abdomenMask = createMask(circ, imgEnh);
close(fig);

%TODO:
% 1. Check that any circles are found
% 2. If no circle found, ask the user to define her own circle ROI.
% 3. If the algorithm is interactive, give the option to show the detected circle, 
%    and allow the user to define her own circle ROI in any case.
% 4. Additional option to (3) - show the user all the detected circles and
%    allow her to choose any of them (may be not also the strongest circle).

%% Display
if isShow
    imgOrig = rgb2gray(imgOrig);

    figure, imshow(imgOrig);
    hold on
    viscircles(center, rad, 'LineWidth',1);
    title(sprintf('Strongest circle of img %s', imgName));
end




