%%%%% Generating the training data %%%%%
clear all;

db_type = 'casme2'
load(['..\data\Annotation4' db_type '.mat']);
load('..\data\EnergyMap4Face64_32.mat','mask');
load(['..\data\TrTeSeq_' db_type '.mat'],'TrTeSeq');
% replace the path by yourself
rootDir = 'E:\Datasets\CASME2\preprocessed data\Cropped';

subDirs = dir(rootDir);
[rows,cols] = size(mask);
ind = 0;
colsT = 150;
dimsT = 50;

dataset.labels = [];
dataset.data = [];
rowsT = numel(find(mask == 1));

for i = 1:length(subDirs)
    if(strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..')), continue; end
    if(~subDirs(i).isdir), continue; end
    
    % for each subject
    fprintf('The %dth subject.\n',i-2);
    % replace the variable name by smic and samm manually
    epDir = [rootDir '\' subDirs(i).name];
    tmpIndex = find(casme2.subject == i-2); % casme2->samm,smic
    epFolders = casme2.fname(tmpIndex); % casme2->samm,smic
    epClasses = casme2.emotion(tmpIndex); % casme2->samm,smic
    numFolders = length(epFolders);

    tmpT = [];
    for j = 1:numFolders
        ind = ind + 1;
        % only extend the training data
        if TrTeSeq.training(ind) == 0, continue;end
        
        fprintf('\tThe %dth folder.\n',j);
        
        imgDir = [epDir '\' epFolders{j}];
        imgFiles = dir([imgDir '\*.jpg']);
        K = length(imgFiles);
        imgMatrix = zeros(rowsT,K);
        for k = 1:K
            I = double(rgb2gray(imread([imgDir '\' imgFiles(k).name])));
            I = imresize(I,[rows cols]);
            imgMatrix(:,k) = I(mask);
        end
        tmpT = cat(3,tmpT,dataAug(imgMatrix,colsT));
    end
    dataset.data = cat(3,dataset.data,tmpT);
    tmpL = zeros(size(tmpT,3),1);
    tmpL(:,1) = TrTeSeq.labels(ind);
    dataset.labels = [dataset.labels;tmpL];
end

numS = size(dataset.data,3);
indperm = randperm(numS);
dataset.data = dataset.data(:,:,indperm);
dataset.labels = dataset.labels(indperm,1);

save(['..\data\TrainingSet_' db_type '.mat'],'dataset','-v7.3');