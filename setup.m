clear;
close all;

%% Set up parameters
% Input images folder
inputDataDir = 'D:\input_data';
isShow = true; % Show preliminary images for debugging 

%% Run the algorithm
gradesTbl = []; % final output
filesPaths = getFilesList(inputDataDir);    % Get the images full paths

grades = zeros(length(filesPaths), 1);  % Output of non-ML solution

imgPropsForGradingTbl = []; % Table for ML examples generation

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
    
    imgPropsForGrading = getPropsForGrading(imgOrig, bw_bowelMask, bw_periphBonesMask,...
         bw_darkBackgroundMask, bw_maskBones_allAbdomen, bw_BowelBlackHoles_mask);
    imgPropsForGradingTbl = [imgPropsForGradingTbl; imgPropsForGrading];
    
    % Non ML solution
    grade = gradeBowel(imgOrig, bw_bowelMask, bw_periphBonesMask,...
        bw_darkBackgroundMask, bw_maskBones_allAbdomen, bw_BowelBlackHoles_mask, isShow, imgName);
    grades(i) = grade;
    
    %stop here with a break point to see the intermediate figures for each image (if isShow == 1)
    close all; 
end

% Non ML solution
gradesTbl = table(filesPaths', grades);

%% ML part
% Generate examples and create training table
trainTbl = generateTrainTbl(imgPropsForGradingTbl);

% Train SVM model and get model performance summary
perfSum = trainSVM(trainTbl);
