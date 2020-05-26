clear;
close all;

%% Set up parameters
% Input images folder
inputDataDir = 'D:\input_data';

 % Show preliminary images for debugging 
isShow = true;

%% Run the algorithm
gradesTbl = []; % final output

% Get the images full paths
filesPaths = getFilesList(inputDataDir);

grades = zeros(length(filesPaths), 1);

for i=1:length(filesPaths)
    imgOrig = imread(filesPaths{i});
    [~,imgName,~] = fileparts(filesPaths{i});
    
    % Enhance the image
    imgEnh = enhanceLowLightImg(imgOrig, isShow, imgName);
    
    % Extract abdomen circle mask
    [bw_abdomenMask, center, rad] = findAbdomenCircle(imgEnh, isShow, imgOrig, imgName);
    
    % Extract bowel mask (containing bones and dark holes)
    bw_bowelMask = extractBowelMask(bw_abdomenMask, imgEnh, isShow, imgOrig, imgName);
    
    % Gauss filtering and contrast adjustment
    [imgAbdomen_contrast, imgBowel_contrast] =...
        adjustContrastAbdomenBowel(imgOrig, bw_abdomenMask, bw_bowelMask);

    % Extract bones masks 
    [bw_periphBonesMask, bw_maskBones_allAbdomen] = ...
        extractBonesMasks(imgAbdomen_contrast, bw_bowelMask, isShow, imgOrig, imgName, bw_abdomenMask);
    
    % Extract dark holes mask within the bowel 
    bw_BowelBlackHoles_mask =...
        extractBowelBlackHoles(imgBowel_contrast, bw_bowelMask, isShow, imgOrig, imgName);
    
    % Extract mask of the general dark background
    bw_darkBackgroundMask = extractDarkBackgroundMask(imgEnh, isShow, imgName);
    
    grade = gradeBowel(imgOrig, bw_bowelMask, bw_periphBonesMask,...
        bw_darkBackgroundMask, bw_maskBones_allAbdomen, bw_BowelBlackHoles_mask, isShow, imgName);
    
    grades(i) = grade;
    
    %stop here with a break point to see the intermediate figures for each image (if isShow == 1)
    close all; 
end

gradesTbl = table(filesPaths', grades);
