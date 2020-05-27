function classifPerf_oneVsAll = initClassifPerf4oneVsAll(GT)

% The function creates CP objects in "one vs all" manner, where each time
% the target class is one of the classes and the control classes are all
% the others. Returns a list of cp objects with all possible combinations
% of one vs all.

% Input: GT                   - Ground Truth array
% Output classifPerf_oneVsAll - array of classifier performance objects

classifPerf_oneVsAll = {};
classes = unique(GT);

% one (target) vs all (control)
for i = 1:length(classes)
    tgt = (classes == (i-1)); 
    ctrl = ~tgt;
    
    classifPerf_oneVsAll{i} = classperf(GT, 'Positive', classes(tgt),...
        'Negative', classes(ctrl));
end
    