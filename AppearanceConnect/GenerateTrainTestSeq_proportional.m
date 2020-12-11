%%%%%% generate the train and test sequences %%%%%%
clear all;

db_type = 'casme2'
load(['..\data\Annotation4' db_type '.mat']);
% search casme2 and replace with "samm" and "smic"
Nfolds = 5;
N = length(casme2.subject);
TrTeSeq.labels = zeros(N,1);
TrTeSeq.training = zeros(N,1);
TrTeSeq.stat = zeros(4,1);
pert = 0.8;

for i = 1:N
    % for each subject
    if strcmp(casme2.emotion{i},'happiness')
        TrTeSeq.labels(i) = 1; TrTeSeq.stat(1) = TrTeSeq.stat(1) + 1;
    elseif strcmp(casme2.emotion{i},'disgust')||strcmp(casme2.emotion{i},'sadness')...
            ||strcmp(casme2.emotion{i},'fear')
        TrTeSeq.labels(i) = 2; TrTeSeq.stat(2) = TrTeSeq.stat(2) + 1;
    elseif strcmp(casme2.emotion{i},'surprise')
        TrTeSeq.labels(i) = 3; TrTeSeq.stat(3) = TrTeSeq.stat(3) + 1;
    else
        TrTeSeq.labels(i) = 4; TrTeSeq.stat(4) = TrTeSeq.stat(4) + 1;
    end
end

% five folds
TrTeSeq.training(:,1) = Nfolds;
for i = 1:4 % i-th emotion
    indperm = randperm(TrTeSeq.stat(i));
    s = floor(TrTeSeq.stat(i)/Nfolds);
    for j = 1:Nfolds-1 % j-th fold
        ind = find(TrTeSeq.labels == i);
        TrTeSeq.training(ind(indperm(1+j*s-s:j*s)),1) = j;
    end
end

save(['..\data\TrTeSeq_' num2str(Nfolds) 'folds_casme2_proportional.mat'],'TrTeSeq');