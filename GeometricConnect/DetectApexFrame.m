%%%%% calculate the apex frame %%%%%%
clear all;

% search casme2 and replace with "samm" and "smic" for other two datasets
load('..\data\Annotation4casme2.mat');
alpha = 8;
rootDir = ['..\dataset\casme2_alpha' num2str(alpha)];
rootDir = 'D:\Datasets\CASME2\ProcessedData\Cropped';

rows = 10;%128,64
cols = 8;%96,48
NSeq = numel(casme2.fname);

%%
diffVec = zeros(NSeq,1);
for i = 1:NSeq  
    % for each sequence
    fprintf('The %dth sequence.\n',i);
    strSub = sprintf('sub%02d',casme2.subject(i,1));
    imgDir = fullfile(rootDir,filesep,strSub,filesep,casme2.fname(i,1));
    
    imgFiles = dir([imgDir{1} '\*.jpg']);
    imgTensor = [];
    shiftTensor = [];
    K = length(imgFiles);
    for k = 1:K
        I = double(rgb2gray(imread([imgDir{1} filesep imgFiles(k).name])));
        I = imresize(I,[rows cols]);
        imgTensor(:,:,k) = I;
    end
    shiftTensor = repmat(imgTensor(:,:,1),[1 1 k]);%K
    ranges = floor(K*0.2):ceil(K*0.7);
%     ranges = 1:k;
%     sumT = sum(abs(imgTensor - shiftTensor),2);
%     sumF = squeeze(sum(sumT,1));
    sumT = std(imgTensor(:,:,ranges) - shiftTensor(:,:,ranges),0,[1 2]);
    sumF = squeeze(sumT);
    [mValue,mInd] = max(sumF);
    
    if isempty(mInd) || isnan(mValue)
        apexFrame(i,1) = round(K/2) + casme2.onset(i,1);
    else
        apexFrame(i,1) = mInd(1) + casme2.onset(i,1);
    end
    
    diffVec(i) = casme2.apex(i) - apexFrame(i);
    if isnan(diffVec(i)) diffVec(i)=0; end
end
score = sum(abs(diffVec))

casme2.apex = apexFrame;
save('..\data\Annotation4casme2_ac.mat','casme2');