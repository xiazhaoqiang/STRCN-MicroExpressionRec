% train the deep model of RCNN
clear all;

% -------------------------------------------------------------------------
%                                                        load network model
% -------------------------------------------------------------------------
% search casme2 and replace with "samm" or "smic" for other two datasets
load('data\rcnn-dag-casme2-1_21_11_12.mat','netStruct');
net = dagnn.DagNN.loadobj(netStruct);

% -------------------------------------------------------------------------
%                                                                   Test
% -------------------------------------------------------------------------
% search casme2 and replace with "samm" or "smic" for other two datasets
imdbPath = 'data\casme2_epoch_5.mat';
imdb = [];
if exist(imdbPath,'file') == 2
    fprintf('Loading imdb...\n');
    if exist(imdb,'var') == 1, clear imdb; end
    imdb = load(imdbPath) ; % input variable¡®imdb¡¯
    fprintf('Testing...\n');
    [perf,Labels] = rcnnTest(net,imdb.data,imdb.labels);
	confMatrix = calConfusionMatrix(Labels,imdb.labels);
    
    fprintf('Accuracy is %.3f.\n',perf);
else
    fprintf('Can''t find the data.\n');
end
