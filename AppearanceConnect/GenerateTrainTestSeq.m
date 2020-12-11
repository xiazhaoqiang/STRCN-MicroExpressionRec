%%%%%% generate the train and test sequences %%%%%%
clear all;

db_type = 'casme2'
load(['..\data\Annotation4' db_type '.mat']);
% search casme2 and replace with "samm" and "smic"
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

% % one fold
% for i = 1:4
%     num = TrTeSeq.stat(i);
%     Ntr = floor(num*pert);
%     Nte = num - Ntr;
%     ind = find(TrTeSeq.labels == i);
%     indperm = randperm(num);
%     TrTeSeq.training(ind(indperm(1:Ntr))) = 1;
% end
% 
% save('data\TrTeSeq_casme2.mat','TrTeSeq');

% five folds
num = sum(TrTeSeq.stat);
indperm = randperm(num);
s = floor(num/5);
TrTeSeq.training(:,1) = 5;
for i = 1:4
    TrTeSeq.training(indperm(1+i*s-s:i*s),1) = i;
end

save('..\data\TrTeSeq_5folds_casme2.mat','TrTeSeq');