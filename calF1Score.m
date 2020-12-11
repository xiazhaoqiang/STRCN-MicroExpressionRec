function [avgFscore,Fscores] = calF1Score(tarData,gtData)
%CALF1SCORE calculate the unweighted F1 score (macro-averaged F1-score)
% tarData - class labels of prediction, N*1 matrix
% gtData - class labels of ground-truth, N*1 matrix

% Copyright (C) 2018 Zhaoqiang Xia.
% All rights reserved.

tarElements = unique(tarData);
gtElements = unique(gtData);
totalElements = union(tarElements,gtElements);
N = numel(totalElements);
Fscores = zeros(N,1);
% each class
for i = 1:N
    idx1 = find(tarData == totalElements(i)); % i-th class in preditions
    TPs = numel(find(tarData(idx1) == gtData(idx1)));
    FPs = numel(idx1) - TPs;
    idx2 = find(gtData == totalElements(i)); % i-th class in ground-truth
    FNs = numel(find(tarData(idx2) ~= gtData(idx2)));
    Fscores(i) = 2*TPs/(2*TPs+FPs+FNs);
end
avgFscore = mean(Fscores); % each class has at least one sample
end