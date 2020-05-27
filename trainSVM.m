function perfSum = trainSVM(trainTbl) 

%% Train SVM models

% Input:  trainTbl - table with predictors in columns, and last column with
%                    ground truth
% Output: perfSum  - performance summary struct

X = trainTbl(:,1:(width(trainTbl)-1));  % predictors 
Y = trainTbl.res; % labels
kFolds = 5; % folds for cv

t = templateSVM('KernelFunction','linear',...
    'KernelScale', 'auto',...
    'Standardize', true);

options = statset('UseParallel',true);

% train the model
Mdl = fitcecoc(X,Y,'Learners',t,...
'Verbose',2, 'Options',options,...
'Coding','onevsone');

%% Perform k-fold cross-valisation

% Create indices for the k-fold cross-validation.
indices = crossvalind('Kfold',Y,kFolds); 

% Initialize classifier performance objects to measure the performance of
% the classifier. These objects measure the performance of one vs all
% classes
classifPerf_oneVsAll = initClassifPerf4oneVsAll(Y);

for i = 1:kFolds
    test = (indices == i); 
    train = ~test;
    thisPredictions = predict(Mdl, X(test,:));
    
    % update cp 
    for j = 1:length(classifPerf_oneVsAll)
        classperf(classifPerf_oneVsAll{j}, thisPredictions, test);
    end
end

%% Model evaluation

% Confusion matrix
confMat = classifPerf_oneVsAll{i}.CountingMatrix;
confMat = confMat(1:(end-1),1:end);
figure;
confusionchart(confMat, 'ColumnSummary', 'column-normalized');
title('Confusion Matrix for Linear SVM (labels are [1-7])');

% Table with performance metrics
targetClasses = [];
controlClasses = {};
Specificity = [];
Sensitivity = [];
CorrectRate = [];
ErrorRate = [];

% Extract the interesting fields from cp
for i=1:length(classifPerf_oneVsAll)
    cp = classifPerf_oneVsAll{i};
    
    targetClasses     = [targetClasses; cp.TargetClasses];
    controlClasses{i} = cp.ControlClasses';
    Sensitivity       = [Sensitivity; cp.Sensitivity];
    Specificity       = [Specificity; cp.Specificity];
    CorrectRate       = [CorrectRate; cp.CorrectRate]; 
    ErrorRate         = [ErrorRate; cp.ErrorRate]; 
end

perfTbl = table(targetClasses, controlClasses', Sensitivity, Specificity,...
    CorrectRate, ErrorRate);

meanSensitivity = mean(perfTbl.Sensitivity);
meanSpecificity = mean(perfTbl.Specificity);

minSensitivity = min(perfTbl.Sensitivity);
minSpecificity = min(perfTbl.Specificity);

% output struct
perfSum.perfTbl = perfTbl;
perfSum.confMat = confMat;
perfSum.meanSensitivity = meanSensitivity;
perfSum.meanSpecificity = meanSpecificity;
perfSum.minSensitivity = minSensitivity;
perfSum.minSpecificity = minSpecificity;


