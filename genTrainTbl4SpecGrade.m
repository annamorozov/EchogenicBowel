function trainTbl = genTrainTbl4SpecGrade(origTbl, origGrade, reqGrade, nSamp)

%% Generate examples for specific grade
% The selected predictors are intesity weighted mean and area of the following regions:
% "cleaned" bowel, all the bowel, bowel dark holes, bowel bones, periphery bones.
% The numbers for means and areas are generated randomly, from normal
% distribution with mean and std of the original image set.

% Input:  origTbl   - image properties of the original images (given in input data)
%         origGrade - the grade of the original images (calculted by non-ML solution)
%         reqGrade  - the requested grade
%         nSamp     - number of samples to generate
% Output: trainTbl  - training table for the requested grade with the predictors in
%                     columns. The last column is ground truth labels.

coef = (1/(origGrade+1))*(reqGrade+1);  % intensity coefficient

% periphery bones
col = origTbl.wMeanIntens_periphBones;
wMeanIntens_periphBones = genRandNumsFromArr(col, nSamp);

col = origTbl.totArea_periphBones;
totArea_periphBones = genRandNumsFromArr(col, nSamp);

% onlyBowel
col = origTbl.wMeanIntens_onlyBowel;
wMeanIntens_onlyBowel = genRandNumsFromArr(col, nSamp);

col = origTbl.totArea_onlyBowel;
totArea_onlyBowel = genRandNumsFromArr(col, nSamp);

% allBowel
col = origTbl.wMeanIntens_allBowel;
wMeanIntens_allBowel = genRandNumsFromArr(col, nSamp);

col = origTbl.totArea_allBowel;
totArea_allBowel = genRandNumsFromArr(col, nSamp);

% bowelHoles
col = origTbl.wMeanIntens_bowelHoles;
wMeanIntens_bowelHoles = genRandNumsFromArr(col, nSamp);

col = origTbl.totArea_bowelHoles;
totArea_bowelHoles = genRandNumsFromArr(col, nSamp);

% bonesBowel
col = origTbl.wMeanIntens_bonesBowel;
wMeanIntens_bonesBowel = genRandNumsFromArr(col, nSamp);

col = origTbl.totArea_bonesBowel;
totArea_bonesBowel = genRandNumsFromArr(col, nSamp);

% Resulting table
trainTbl = table(wMeanIntens_periphBones, totArea_periphBones,...
    wMeanIntens_onlyBowel*coef, totArea_onlyBowel,...
    wMeanIntens_allBowel*coef, totArea_allBowel,...
    wMeanIntens_bowelHoles, totArea_bowelHoles,...
    wMeanIntens_bonesBowel, totArea_bonesBowel,...
    'VariableNames', {'wMeanIntens_periphBones', 'totArea_periphBones',...
    'wMeanIntens_onlyBowel', 'totArea_onlyBowel',...
    'wMeanIntens_allBowel', 'totArea_allBowel',...
    'wMeanIntens_bowelHoles', 'totArea_bowelHoles',...
    'wMeanIntens_bonesBowel', 'totArea_bonesBowel'});

% Last column - ground truth
trainTbl.res = reqGrade * ones(height(trainTbl),1);
