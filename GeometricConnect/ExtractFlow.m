%%%%% Extract optical flow for image sequences %%%%%
clear all;

% search casme2 and replace with "samm" and "smic" for other two datasets
% dataFile = '..\data\Annotation4casme2.mat';
dataFile = '..\data\Annotation4casme2.mat';

% Load data
load(dataFile,'casme2'); % casme2

% Preprocessing
Nseq = numel(casme2.subject);
rows = 300;
cols = 245;

alpha = 5:12;

for numAug = 1:numel(alpha)
    rootDir = ['..\dataset\casme2_alpha' num2str(alpha(numAug)) '\'];
    saveFile = ['..\data\dataset_of_casme2_' num2str(alpha(numAug)) '.mat'];
    % Process each sequence
    fprintf('\nOptical Flow of sequences are generating...\n\n');
    imdb.data = [];
    imdb.labels = [];
    imdb.indexes = [];
    idx = 1;
    for i = 1:Nseq
        if isnan(casme2.onset(i)) || isnan(casme2.apex(i))
            fprintf('The %d-th sequence (sub%02d-%s) does not exist...\n',i,casme2.subject(i),casme2.fname{i});
            continue;
        end
        preDir = sprintf('sub%02d%s%s%s',casme2.subject(i),filesep,casme2.fname{i},filesep);
        filePath_1 = [rootDir preDir 'reg_img' num2str(casme2.onset(i)) '.jpg'];
        filePath_2 = [rootDir preDir 'reg_img' num2str(casme2.apex(i)) '.jpg'];
        if ~exist(filePath_1) || ~exist(filePath_2)
            fprintf('The %d-th sequence (sub%02d-%s) cannot be accessed...\n',i,casme2.subject(i),casme2.fname{i});
            continue;
        end
        img1 = imresize(imread(filePath_1),[rows cols]);
        img2 = imresize(imread(filePath_2),[rows cols]);
        %     if isempty(img1) || isempty(img2)
        %         fprintf('The %d-th sequence (sub%02d-%s) cannot be accessed...\n',i,casme2.subject(i),casme2.fname{i});
        %         continue;
        %     end
        
        fprintf('The %d-th sequence...\n',i);
        % extract the flow
        uv = estimate_flow_interface(img1, img2, 'classic+nl-fast');
        imdb.data = cat(4,imdb.data,uv);
        % labeling
        if strcmp(casme2.emotion{i},'happiness')
            imdb.labels(idx,1) = 1;
        elseif strcmp(casme2.emotion{i},'disgust')||strcmp(casme2.emotion{i},'sadness')...
                ||strcmp(casme2.emotion{i},'fear')||strcmp(casme2.emotion{i},'contempt')...
				||strcmp(casme2.emotion{i},'anger')
            imdb.labels(idx,1) = 2;
        elseif strcmp(casme2.emotion{i},'surprise')
            imdb.labels(idx,1) = 3;
        else
            imdb.labels(idx,1) = 4;
        end
        imdb.indexes(idx,1) = i;
		
%		if strcmp(smic.emotion{i},'positive')
%            imdb.labels(idx,1) = 1;
%        elseif strcmp(casme2.emotion{i},'negative')
%            imdb.labels(idx,1) = 2;
%        else strcmp(casme2.emotion{i},'surprise')
%            imdb.labels(idx,1) = 3;
        
        idx = idx + 1;
    end
    save(saveFile,'imdb');
end