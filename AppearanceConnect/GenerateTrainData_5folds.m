%%%%% Generating the training data %%%%%
clear all;

db_type = 'casme2'
load(['..\data\Annotation4' db_type '.mat']);
load('data\EnergyMap4Face64_32.mat','mask');
load('data\TrTeSeq_5folds_casme2.mat','TrTeSeq');
% replace the path by yourself
rootDir = 'E:\Datasets\CASME2\preprocessed data\Cropped';
subDirs = dir(rootDir);
[rows,cols] = size(mask);
ind = 0;
Nfolds = 5;
%
for i = 1:Nfolds
    dataset(i).labels = [];
    dataset(i).data = [];
end

rowsT = numel(find(mask == 1));
colsT = 30;

for i = 1:length(subDirs)
    if(strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..')), continue; end
    if(~subDirs(i).isdir), continue; end
    
    % for each subject
    fprintf('The %dth subject.\n',i-2);
    
    epDir = [rootDir '\' subDirs(i).name];
    tmpIndex = find(casme2.subject == i-2);
    epFolders = casme2.fname(tmpIndex); % casme2->samm,smic
    epClasses = casme2.emotion(tmpIndex); % casme2->samm,smic
    numFolders = length(epFolders);

    tmpT = [];
    for j = 1:numFolders
        ind = ind + 1;
        % only extend the training data
        
        fprintf('\tThe %dth folder.\n',j);
        
        imgDir = [epDir '\' epFolders{j}];
        imgFiles = dir([imgDir '\*.jpg']);
        K = length(imgFiles);
        imgMatrix = single(zeros(rowsT,K));
        for k = 1:K
            I = single(rgb2gray(imread([imgDir '\' imgFiles(k).name])));
            I = imresize(I,[rows cols]);
            imgMatrix(:,k) = single(I(mask));
        end
        tmpT = cat(3,tmpT,single(dataAug(imgMatrix,colsT)));
    end
    dataset(TrTeSeq.training(ind)).data = cat(3,dataset(TrTeSeq.training(ind)).data,tmpT);
    tmpL = single(zeros(size(tmpT,3),1));
    tmpL(:,1) = single(TrTeSeq.labels(ind));
    dataset(TrTeSeq.training(ind)).labels = [dataset(TrTeSeq.training(ind)).labels;tmpL];
end

% imdb and epoch
for i = 1:Nfolds
    ImgTensor = dataset(i);
    save(['data\TrainingSet_' db_type '_fold_' num2str(i) '.mat'],'ImgTensor','-v7.3');
end