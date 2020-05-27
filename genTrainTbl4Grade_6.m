function trainTbl = genTrainTbl4Grade_6(origTbl, origGrade, nSamp)

%% Generate examples for specific grade, special cases for grade 6
% Same as genTrainTbl4SpecGrade, but with additional extreme cases:
% 1. "Clean" bowel area segmented correctly and has same mean intensity as periphery
%    bones
% 2. "Clean" bowel segmented very small, the rest segmented as bowel bones

% Input:  origTbl   - image properties of the original images (given in input data)
%         origGrade - the grade of the original images (calculted by non-ML solution)
%         nSamp     - number of samples to generate
% Output: trainTbl  - training table for the requested grade with the predictors in
%                     columns. The last column is ground truth labels.

reqGrade = 6;
coef = (1/(origGrade+1))*(reqGrade+1);

% Generate the basic table in the same way
trainTbl = genTrainTbl4SpecGrade(origTbl, origGrade, reqGrade, nSamp);

%% onlyBowel
% Case 1: bowel segmented correctly, has same mean intensity as periphery
% bones
col = origTbl.wMeanIntens_periphBones;
wMeanIntens_onlyBowel1 = genRandNumsFromArr(col, nSamp/2);

col = origTbl.totArea_onlyBowel;
totArea_onlyBowel1 = genRandNumsFromArr(col, nSamp/2);

% Case 2: bowel segmented very small, the rest segmented as bowel bones
col = origTbl.wMeanIntens_onlyBowel;
wMeanIntens_onlyBowel2 = genRandNumsFromArr(col, nSamp/2);
wMeanIntens_onlyBowel2 = coef * wMeanIntens_onlyBowel2; 

col = origTbl.totArea_onlyBowel;
totArea_onlyBowel2 = genRandNumsFromArr(col, nSamp/2);
totArea_onlyBowel2 = totArea_onlyBowel2 * 0.3;

wMeanIntens_onlyBowel = [wMeanIntens_onlyBowel1; wMeanIntens_onlyBowel2];
totArea_onlyBowel = [totArea_onlyBowel1; totArea_onlyBowel2];

%% bonesBowel
% Case 1: bowel segmented correctly, has same mean intensity as periphery
% bones
col = origTbl.totArea_bonesBowel;
totArea_bonesBowel1 = genRandNumsFromArr(col, nSamp/2);

% Case 2: bowel segmented very small, the rest segmented as bowel bones
col = origTbl.totArea_bonesBowel;
totArea_bonesBowel2 = genRandNumsFromArr(col, nSamp/2);
totArea_bonesBowel2 = totArea_bonesBowel2 * 1.7;

totArea_bonesBowel = [totArea_bonesBowel1; totArea_bonesBowel2];

%% allBowel

% Case 1: bowel segmented correctly, has same mean intensity as periphery
% bones
% Case 2: bowel segmented very small, the rest segmented as bowel bones

col = origTbl.wMeanIntens_bonesBowel;
wMeanIntens_allBowel = genRandNumsFromArr(col, nSamp);

%% Construct the table - change the relevant columns
trainTbl.wMeanIntens_onlyBowel = wMeanIntens_onlyBowel;
trainTbl.totArea_onlyBowel = totArea_onlyBowel;

trainTbl.totArea_bonesBowel = totArea_bonesBowel;

trainTbl.wMeanIntens_allBowel = wMeanIntens_allBowel;
