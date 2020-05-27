function randArr = genRandNumsFromArr(arr, n)

%% Generate random numbers from normal distribution of a specific array

% Input:  arr     - array of numbers to get the mean and the std from it
%         n       - number of random numbers to generate
% Output: randArr - output array of generated random numbers

arrMean = mean(arr);
arrStd = std(arr);

randArr = arrStd.*randn(n,1) + arrMean;
