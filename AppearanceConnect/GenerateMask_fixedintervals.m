%%%%% statistic masking regions %%%%%%
clear all;

dataset = 'casme2'; % smic, samm
load(['..\data\Annotation4' dataset '.mat']);
rootDir = ['E:\Programming\MatlabProgram\PatternRecognition\MicroExpressionRec\dataset\' dataset];
subDirs = dir(rootDir);
t = 0;
rows = 64;%128
cols = 48;%96
EnergyMaps = [];
ind = 1;

for i = 1:length(subDirs)
    if(strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..')), continue; end
    if(~subDirs(i).isdir), continue; end
    if(t>0), break; end
    
    imgTensor = [];
    shiftTensor = [];
    % for each subject
    fprintf('The %dth subject.\n',i);
    epDir = [rootDir '\' subDirs(i).name];
    epFolders = dir(epDir);
    numFolders = length(epFolders);

    for j = 1:numFolders
        em = zeros(rows,cols);
        if(strcmp(epFolders(j).name,'.') || strcmp(epFolders(j).name,'..')), continue; end
        if(~epFolders(j).isdir), continue; end
        
        imgDir = [epDir '\' epFolders(j).name];
        imgFiles = dir([imgDir '\*.jpg']);
        K = length(imgFiles);
        for k = 1:K
            I = double(rgb2gray(imread([imgDir '\' imgFiles(k).name])));
            I = imresize(I,[rows cols]);
            imgTensor(:,:,k) = I;
        end
        shiftTensor(:,:,1:K-10) = imgTensor(:,:,11:K);
        shiftTensor(:,:,K-9:K) = imgTensor(:,:,1:10);
        sumTensor = sum(abs(imgTensor - shiftTensor),3);
        
        em = sumTensor;
        em = em/max(em(:));
%         th = mean(em(:));
%         th =  prctile(em(:),80);
%         em(em<th) = 0;
%         imagesc(em);
%         t = t + 1;
        EnergyMaps(:,:,ind) = em;
        ind = ind + 1;
    end
end

avg_em = mean(EnergyMaps,3);
th =  prctile(avg_em(:),75);
bem = avg_em;
bem(avg_em<th) = 0;
bem(avg_em>=th) = 1;
avg_em(avg_em<th) = 0;
figure,imshow(bem);
figure,imshow(avg_em);

if rows < 100, se = strel('disk',1);
elseif rows < 200, se = strel('disk',3);
else se = strel('disk',5);end

mask = im2bw(imopen(bem,se));
figure,imshow(mask);

save(['data\EnergyMap4Face' num2str(rows) '_' num2str(cols) '_evm.mat'],'EnergyMaps','mask');