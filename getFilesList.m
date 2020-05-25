function filesList = getFilesList(inputDataDir)

%% Extract full paths of the files
% Input:  inputDataDir - folder containing the images
% Output: filesList    - list with files full paths

dirContent = dir(inputDataDir);
filesList = {};

k=0;
for i=1:length(dirContent)
    if ~dirContent(i).isdir
        k = k+1;
        filesList{k} = fullfile(dirContent(i).folder, dirContent(i).name);
    end
end

%%TODO: 
% 1. check that the files are indeed in image format (.png, jpg, etc.)
% 2. If not all files are images, find only the ones that are images