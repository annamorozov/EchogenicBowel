function [meanIntens_weight, medIntens, totArea, stats] =...
    getMaskRegionProps(img, bw_mask)

%% Get the properties of a masked region
% Input:  img               - the image to mask
%         bw_mask           - the mask to get the desired area
% Output: meanIntens_weight - mean intensity of the area weighted by the number of
%                             pixels of each object
%         medIntens         - median intensity of the area
%         totArea           - total number of pixels in the area
%         stats             - table of the area properties from regionprops

stats = regionprops('table', bw_mask, img,...
    'MeanIntensity', 'PixelValues', 'Area');

totArea = sum(stats.Area);

% Weighted mean 
meanIntens_weight = sum(stats.MeanIntensity.*stats.Area)./totArea;   

% Median
allPixVals = cat(1,stats.PixelValues{:});
medIntens = median(allPixVals);
