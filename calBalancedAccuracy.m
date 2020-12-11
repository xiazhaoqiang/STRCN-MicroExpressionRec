function [avgAcc,Acc] = calBalancedAccuracy(tarData,gtData)
%CALBALANCEDACCURACY calculate the balance accuracy (Unweighted Average Recal)
% tarData - class labels of prediction, N*1 matrix
% gtData - class labels of ground-truth, N*1 matrix

% Copyright (C) 2018 Zhaoqiang Xia.
% All rights reserved.

tarElements = unique(tarData);
gtElements = unique(gtData);
totalElements = union(tarElements,gtElements);
N = numel(totalElements);
Acc = zeros(N,1);
for i = 1:N
    idx1 = find(gtData == totalElements(i));
    if isempty(idx1), continue; end
    idx2 = find(tarData(idx1) == gtData(idx1));
    Acc(i) = numel(idx2)/numel(idx1);
end
avgAcc = mean(Acc); % each class has at least one sample
end